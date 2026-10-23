import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// Carrega a Segoe UI do Windows, a fonte que o app usa de verdade. Com a
/// fonte de teste padrão (cada letra é um quadrado), a largura não confere.
Future<bool> loadSegoeUi() async {
  const dir = r'C:\Windows\Fonts';
  final files = [
    'segoeui.ttf',
    'seguisb.ttf',
    'segoeuib.ttf',
  ].map((f) => File(p.join(dir, f))).where((f) => f.existsSync()).toList();
  if (files.isEmpty) return false;
  final loader = FontLoader('Segoe UI');
  for (final f in files) {
    final bytes = f.readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
  return true;
}
