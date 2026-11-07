import 'dart:io';

import 'signing.dart';

/// Gera a chave de assinatura das Releases (DECISIONS D-62).
///
/// `dart run bin/generate_key.dart <arquivo>` grava a chave privada no arquivo
/// e imprime só a pública. Não sobrescreve um arquivo existente.
Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln('Uso: dart run bin/generate_key.dart <arquivo>');
    exit(64);
  }
  final file = File(args.single);
  if (file.existsSync()) {
    stderr.writeln('${file.path} já existe; nada foi alterado.');
    exit(1);
  }
  final key = SigningKey.generate();
  file.writeAsStringSync(key.encode());
  stdout.writeln('Chave privada gravada em ${file.path}');
  stdout.writeln('Chave pública: ${await key.publicKey()}');
}
