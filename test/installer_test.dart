import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regras do instalador (SPEC §19; DECISIONS D-38) que não podem regredir.
void main() {
  final iss = File('installer/patrion.iss').readAsStringSync();
  final runner = File('windows/runner/main.cpp').readAsStringSync();
  final testScript = File('tool/release/test_install.ps1').readAsStringSync();

  /// Linhas de uma seção do .iss, sem comentários.
  List<String> section(String name) {
    final lines = iss.split(RegExp(r'\r?\n'));
    final start = lines.indexWhere((l) => l.trim() == '[$name]');
    if (start < 0) return const [];
    return [
      for (final l
          in lines
              .skip(start + 1)
              .takeWhile((l) => !l.trimLeft().startsWith('[')))
        if (l.trim().isNotEmpty && !l.trimLeft().startsWith(';')) l,
    ];
  }

  test('a desinstalação não apaga nada além do app', () {
    expect(section('UninstallDelete'), isEmpty);
    expect(iss, isNot(contains('{userappdata}\\Patrion"; Flags')));
  });

  test('a atualização só limpa a pasta "data" do próprio app', () {
    final deletes = section('InstallDelete');
    expect(deletes, hasLength(1));
    expect(deletes.single, contains('Name: "{app}\\data"'));
  });

  test('o AppId é fixo e o mesmo do teste de instalação', () {
    const appId = '5A345516-F4A3-4E8D-B057-50475B9F06F9';
    expect(iss, contains('AppId={{$appId}'));
    expect(testScript, contains('{$appId}_is1'));
  });

  test('o instalador espera o app fechar pelo mutex que o runner cria', () {
    final mutex = RegExp(
      r'^AppMutex=(.+)$',
      multiLine: true,
    ).firstMatch(iss)!.group(1)!.split(',');
    for (final name in mutex) {
      final cpp = name.trim().replaceAll(r'\', r'\\');
      expect(runner, contains('L"$cpp"'), reason: name);
    }
  });

  test('instala por usuário e associa o .invsave', () {
    expect(iss, contains('PrivilegesRequired=lowest'));
    expect(iss, contains(r'DefaultDirName={autopf}\{#AppName}'));
    expect(iss, contains(r'Subkey: "Software\Classes\.invsave"'));
    expect(iss, contains('ChangesAssociations=yes'));
    expect(iss, contains('"%1"'));
  });
}
