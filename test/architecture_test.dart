import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Regras de dependência entre camadas (CLAUDE.md, "Arquitetura").
void main() {
  List<(String, String)> importsIn(String folder) {
    final result = <(String, String)>[];
    final dir = Directory(p.join('lib', folder));
    if (!dir.existsSync()) return result;
    final importPattern = RegExp(
      r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );
    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      for (final m in importPattern.allMatches(file.readAsStringSync())) {
        result.add((file.path, m.group(1)!));
      }
    }
    return result;
  }

  const forbiddenInPureLayers = [
    'package:flutter/',
    'package:flutter_riverpod/',
    'package:drift/',
    'package:dio/',
    'package:sqlite3/',
    'package:path_provider/',
    'dart:ui',
  ];

  for (final layer in ['domain', 'core']) {
    test('$layer/ é Dart puro (sem Flutter, Drift, Dio ou provedores)', () {
      final violations = [
        for (final (file, uri) in importsIn(layer))
          if (forbiddenInPureLayers.any(uri.startsWith)) '$file -> $uri',
      ];
      expect(violations, isEmpty);
    });
  }

  test('domain/ só importa core/ e o próprio domain/', () {
    final violations = [
      for (final (file, uri) in importsIn('domain'))
        if (RegExp(r'(^|/)(data|application|infrastructure|presentation)/')
            .hasMatch(uri))
          '$file -> $uri',
    ];
    expect(violations, isEmpty);
  });

  test('core/ não depende de nenhuma outra camada do app', () {
    final violations = [
      for (final (file, uri) in importsIn('core'))
        if (RegExp(
          r'(^|/)(domain|application|data|infrastructure|presentation)/',
        ).hasMatch(uri))
          '$file -> $uri',
    ];
    expect(violations, isEmpty);
  });

  test(
    'a carteira real não lê nem grava as tabelas hipotéticas (BANCO.md §8)',
    () {
      final violations = <String>[];
      for (final folder in [
        p.join('lib', 'application', 'portfolio'),
        p.join('lib', 'domain', 'portfolio'),
        p.join('lib', 'presentation', 'screens', 'dashboard'),
        p.join('lib', 'presentation', 'screens', 'portfolio'),
      ]) {
        for (final file in Directory(folder).listSync(recursive: true)) {
          if (file is! File || !file.path.endsWith('.dart')) continue;
          if (RegExp(
            r'hypo',
            caseSensitive: false,
          ).hasMatch(file.readAsStringSync())) {
            violations.add(file.path);
          }
        }
      }
      final repos = File(
        p.join('lib', 'data', 'repositories', 'portfolio_repositories.dart'),
      ).readAsStringSync();
      if (repos.contains('hypo')) violations.add('portfolio_repositories.dart');
      expect(violations, isEmpty);
    },
  );

  test('só presentation/ converte para double (regra 6)', () {
    final violations = <String>[];
    for (final layer in [
      'core',
      'domain',
      'application',
      'data',
      'infrastructure',
    ]) {
      final dir = Directory(p.join('lib', layer));
      if (!dir.existsSync()) continue;
      for (final file in dir.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart') || file.path.endsWith('.g.dart')) {
          continue;
        }
        final text = file.readAsStringSync();
        if (RegExp(r'\.toDouble\(\)|\bdouble\b').hasMatch(text)) {
          violations.add(file.path);
        }
      }
    }
    expect(violations, isEmpty);
  });
}
