import 'dart:io';

import 'signing.dart';

/// Assina um arquivo (DECISIONS D-62): grava `<arquivo>.minisig`.
///
/// `dart run bin/sign_file.dart <arquivo> <app_info.dart> <comentário>`
///
/// A chave vem só da variável `PATRION_UPDATE_SIGNING_KEY` e nunca é impressa.
/// Recusa assinar com uma chave cuja parte pública não esteja em
/// `app_info.dart`: o app não aceitaria a Release.
Future<void> main(List<String> args) async {
  if (args.length != 3) {
    stderr.writeln(
      'Uso: dart run bin/sign_file.dart <arquivo> <app_info.dart> <comentário>',
    );
    exit(64);
  }
  final secret = Platform.environment['PATRION_UPDATE_SIGNING_KEY'];
  if (secret == null || secret.trim().isEmpty) {
    stderr.writeln('PATRION_UPDATE_SIGNING_KEY não definida.');
    exit(1);
  }
  final SigningKey key;
  try {
    key = SigningKey.parse(secret);
  } on FormatException {
    stderr.writeln('PATRION_UPDATE_SIGNING_KEY ilegível.');
    exit(1);
  }
  final public = await key.publicKey();
  if (!File(args[1]).readAsStringSync().contains("'$public'")) {
    stderr.writeln('A chave pública $public não está em ${args[1]}.');
    exit(1);
  }
  final target = File(args[0]);
  final signature = await key.sign(target.readAsBytesSync(), comment: args[2]);
  File('${target.path}.minisig').writeAsStringSync(signature);
  stdout.writeln('Assinado com a chave $public');
}
