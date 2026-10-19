import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

final _log = Logger('instance');

/// Uma instância do app por pasta de dados (DECISIONS D-39).
///
/// A primeira instância trava `instance\patrion.lock` (trava do sistema,
/// liberada quando o processo termina, mesmo num travamento). A segunda não
/// abre o banco: ela grava os arquivos que recebeu (por exemplo, o `.invsave`
/// do duplo clique) em `instance\inbox\` e termina; a primeira lê o pedido,
/// abre os arquivos e vem para a frente.
///
/// Pastas de dados diferentes (`--data-dir`) continuam podendo rodar ao
/// mesmo tempo, como no teste de sincronização entre duas pastas.
class InstanceGate {
  InstanceGate._(this._lock, this._inbox);

  static const lockFileName = 'patrion.lock';
  static const inboxFolder = 'inbox';

  /// Pedidos mais antigos que isto, achados ao abrir, são descartados (eram
  /// de uma instância anterior que terminou sem lê-los).
  static const staleAfter = Duration(minutes: 1);

  final RandomAccessFile _lock;
  final Directory _inbox;
  final _requests = StreamController<List<String>>.broadcast();
  Timer? _timer;

  /// Tenta ser a instância principal de [instanceDir]. Devolve nulo se outra
  /// instância já estiver aberta com a mesma pasta.
  static Future<InstanceGate?> acquire(
    String instanceDir, {
    Duration pollInterval = const Duration(milliseconds: 400),
  }) async {
    await Directory(instanceDir).create(recursive: true);
    final file = File(p.join(instanceDir, lockFileName));
    final raf = await file.open(mode: FileMode.append);
    try {
      await raf.lock(FileLock.exclusive);
    } on FileSystemException {
      await raf.close();
      return null;
    }
    final inbox = Directory(p.join(instanceDir, inboxFolder));
    await inbox.create(recursive: true);
    final gate = InstanceGate._(raf, inbox);
    await gate._dropStale();
    gate._timer = Timer.periodic(pollInterval, (_) => gate._poll());
    return gate;
  }

  /// Entrega [files] à instância principal de [instanceDir]. Mesmo sem
  /// arquivos, o pedido faz a janela aberta vir para a frente.
  static Future<void> forward(String instanceDir, List<String> files) async {
    final inbox = Directory(p.join(instanceDir, inboxFolder));
    await inbox.create(recursive: true);
    final name = '${DateTime.now().microsecondsSinceEpoch}-$pid';
    final tmp = File(p.join(inbox.path, '$name.tmp'));
    await tmp.writeAsString(
      jsonEncode({
        'files': [for (final f in files) p.absolute(f)],
      }),
      flush: true,
    );
    // Renomear é atômico: a instância principal nunca lê um pedido pela
    // metade.
    await tmp.rename(p.join(inbox.path, '$name.json'));
    _allowForeground();
  }

  /// Arquivos pedidos por outras instâncias (lista vazia: só trazer a janela
  /// para a frente).
  Stream<List<String>> get requests => _requests.stream;

  Future<void> _dropStale() async {
    final limit = DateTime.now().subtract(staleAfter);
    for (final entity in _inbox.listSync()) {
      if (entity is! File) continue;
      try {
        if (entity.lastModifiedSync().isBefore(limit)) entity.deleteSync();
      } on FileSystemException {
        // Outro processo pode estar mexendo; fica para a próxima.
      }
    }
  }

  var _polling = false;

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final pending =
          _inbox
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.json'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
      for (final file in pending) {
        List<String> files;
        try {
          final json = jsonDecode(await file.readAsString());
          files = [
            for (final f in (json as Map<String, Object?>)['files']! as List)
              f as String,
          ];
        } on Object catch (error) {
          _log.warning('Pedido de abertura ilegível: ${file.path}', error);
          files = const [];
        }
        try {
          await file.delete();
        } on FileSystemException {
          continue; // tenta de novo na próxima volta
        }
        _requests.add(files);
      }
    } on FileSystemException catch (error) {
      _log.warning('Falha ao ler os pedidos de abertura', error);
    } finally {
      _polling = false;
    }
  }

  Future<void> close() async {
    _timer?.cancel();
    await _requests.close();
    await _lock.close();
  }

  /// Permite que a instância principal tome o foco: o Windows só deixa trazer
  /// uma janela para a frente se o processo que recebeu o clique autorizar.
  static void _allowForeground() {
    if (!Platform.isWindows) return;
    try {
      final user32 = DynamicLibrary.open('user32.dll');
      final allow = user32
          .lookupFunction<Int32 Function(Uint32), int Function(int)>(
            'AllowSetForegroundWindow',
          );
      allow(0xFFFFFFFF); // ASFW_ANY
    } on Object catch (error) {
      _log.fine('AllowSetForegroundWindow indisponível', error);
    }
  }
}
