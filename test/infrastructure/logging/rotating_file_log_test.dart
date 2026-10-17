import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/infrastructure/logging/rotating_file_log.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('patrion_logs_');
  });

  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('formato: instante UTC, nível, logger e mensagem', () {
    final record = LogRecord(
      Level.WARNING,
      'Provedor sem resposta',
      'brapi',
      const NetworkError('tempo esgotado'),
    );
    final line = RotatingFileLog.format(record);
    expect(
      line,
      matches(
        RegExp(
          r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z WARNING \[brapi\] '
          r'Provedor sem resposta \| erro de rede: rede: tempo esgotado$',
        ),
      ),
    );
  });

  test('grava linhas no arquivo atual', () {
    final log = RotatingFileLog(logsDir: dir.path);
    log.writeLine('a');
    log.writeLine('b');
    expect(File(log.currentFile).readAsStringSync(), 'a\nb\n');
  });

  test('rotaciona ao passar do limite e mantém só maxFiles antigos', () {
    final log = RotatingFileLog(logsDir: dir.path, maxBytes: 10, maxFiles: 2);
    for (var i = 0; i < 6; i++) {
      log.writeLine('linha-$i-xxxxx'); // cada linha já passa de 10 bytes
    }
    final names = dir.listSync().map((f) => p.basename(f.path)).toList()
      ..sort();
    expect(names, ['patrion.1.log', 'patrion.2.log', 'patrion.log']);
    expect(File(log.currentFile).readAsStringSync(), 'linha-5-xxxxx\n');
    expect(
      File(p.join(dir.path, 'patrion.2.log')).readAsStringSync(),
      'linha-3-xxxxx\n',
    );
  });
}
