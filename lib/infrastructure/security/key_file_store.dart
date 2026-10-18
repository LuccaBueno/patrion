import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/security/key_file.dart';

/// Lê e grava o arquivo de chaves (`patrion.keys.json`) ao lado do banco
/// (DECISIONS D-24 e D-32). A gravação é atômica: arquivo temporário e troca.
class KeyFileStore {
  const KeyFileStore(this.dataDir);

  static const fileName = 'patrion.keys.json';

  final String dataDir;

  String get path => p.join(dataDir, fileName);

  bool get exists => File(path).existsSync();

  /// Lança `DataError` se o arquivo existir e estiver inválido.
  KeyFile? read() => readAt(path);

  void write(KeyFile file) => writeAt(path, file);

  void delete() {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  }

  /// Guarda de lado um arquivo de chaves que não corresponde ao banco (por
  /// exemplo, de uma ativação interrompida), sem apagá-lo.
  String setAside() {
    final target = '$path.descartado-${DateTime.now().millisecondsSinceEpoch}';
    File(path).renameSync(target);
    return target;
  }

  static KeyFile? readAt(String path) {
    final f = File(path);
    if (!f.existsSync()) return null;
    return KeyFile.decode(f.readAsStringSync());
  }

  static void writeAt(String path, KeyFile file) {
    final temp = File('$path.novo');
    temp.writeAsStringSync(file.encode(), flush: true);
    temp.renameSync(path);
  }
}
