import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/config/app_info.dart';
import 'package:patrion/core/config/launch_options.dart';

void main() {
  group('LaunchOptions', () {
    test('sem argumentos usa as pastas padrão', () {
      final o = LaunchOptions.parse([]);
      expect(o.dataDir, isNull);
      expect(o.cacheDir, isNull);
    });

    test('aceita valor separado e com =', () {
      final o = LaunchOptions.parse([
        '--data-dir',
        r'D:\PatrionB',
        r'--cache-dir=D:\cacheB',
      ]);
      expect(o.dataDir, r'D:\PatrionB');
      expect(o.cacheDir, r'D:\cacheB');
    });

    test('ignora argumentos desconhecidos', () {
      final o = LaunchOptions.parse([r'C:\x\arquivo.invsave', '--outro']);
      expect(o.dataDir, isNull);
    });

    test('recusa pasta ausente ou vazia', () {
      expect(() => LaunchOptions.parse(['--data-dir']), throwsFormatException);
      expect(
        () => LaunchOptions.parse(['--cache-dir=']),
        throwsFormatException,
      );
    });
  });

  test('AppInfo.version acompanha o pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([^+\s]+)',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match?.group(1), AppInfo.version);
  });
}
