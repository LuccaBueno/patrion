import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../core/errors/app_error.dart';
import '../../core/time/instant_format.dart';

/// Grava os registros do `logging` em arquivos rotativos (SPEC §18).
///
/// - Arquivo atual: `<logsDir>\patrion.log`.
/// - Ao passar de [maxBytes], ele vira `patrion.1.log`, o `.1` vira `.2` e
///   assim por diante, até [maxFiles] arquivos antigos.
///
/// Os logs são técnicos: quem chama não deve registrar valores patrimoniais
/// (regra 7). A escrita é síncrona para não perder a última linha antes de um
/// fechamento abrupto; o volume de log do app é pequeno.
class RotatingFileLog {
  RotatingFileLog({
    required this.logsDir,
    this.maxBytes = 1024 * 1024,
    this.maxFiles = 5,
  });

  static const baseName = 'patrion';

  final String logsDir;
  final int maxBytes;
  final int maxFiles;

  String get currentFile => p.join(logsDir, '$baseName.log');

  String _archivedFile(int index) => p.join(logsDir, '$baseName.$index.log');

  /// Formata e grava um registro.
  void write(LogRecord record) => writeLine(format(record));

  /// Formato: `<instante UTC> <NÍVEL> [logger] mensagem`, seguido do erro e
  /// da pilha, quando houver.
  static String format(LogRecord record) {
    final buffer = StringBuffer()
      ..write(formatInstant(record.time))
      ..write(' ')
      ..write(record.level.name)
      ..write(' [')
      ..write(record.loggerName)
      ..write('] ')
      ..write(record.message);
    final error = record.error;
    if (error != null) {
      buffer.write(error is AppError ? ' | erro de ${error.kind}: ' : ' | ');
      buffer.write(error);
    }
    if (record.stackTrace != null) {
      buffer
        ..write('\n')
        ..write(record.stackTrace.toString().trimRight());
    }
    return buffer.toString();
  }

  void writeLine(String line) {
    final file = File(currentFile);
    file.parent.createSync(recursive: true);
    if (file.existsSync() && file.lengthSync() >= maxBytes) {
      _rotate();
    }
    file.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
  }

  void _rotate() {
    final oldest = File(_archivedFile(maxFiles));
    if (oldest.existsSync()) oldest.deleteSync();
    for (var i = maxFiles - 1; i >= 1; i--) {
      final file = File(_archivedFile(i));
      if (file.existsSync()) file.renameSync(_archivedFile(i + 1));
    }
    File(currentFile).renameSync(_archivedFile(1));
  }
}

/// Liga o `Logger.root` ao arquivo rotativo. Devolve o gravador, útil para
/// mostrar a pasta dos logs na tela.
RotatingFileLog setupLogging({required String logsDir, Level? level}) {
  final log = RotatingFileLog(logsDir: logsDir);
  Logger.root.level = level ?? Level.INFO;
  Logger.root.onRecord.listen((record) {
    try {
      log.write(record);
    } on FileSystemException {
      // Sem log em disco (pasta bloqueada, disco cheio): o app continua.
    }
  });
  return log;
}
