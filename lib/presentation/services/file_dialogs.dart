import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Diálogos de arquivo. A interface existe para os testes de widget
/// trocarem os diálogos do Windows por caminhos fixos.
abstract interface class FileDialogs {
  /// Pede onde salvar e grava [bytes]. Devolve o caminho ou `null` se o
  /// usuário cancelar.
  Future<String?> saveBytes({
    required String dialogTitle,
    required String suggestedName,
    required String extension,
    required Uint8List bytes,
  });

  /// Pede um arquivo com uma das [extensions]. `null` se cancelar.
  Future<String?> pickFile({
    required String dialogTitle,
    required List<String> extensions,
  });

  /// Pede uma pasta. `null` se cancelar.
  Future<String?> pickDirectory({required String dialogTitle});
}

/// Diálogos nativos do Windows (`file_picker`, DECISIONS D-02).
class PlatformFileDialogs implements FileDialogs {
  const PlatformFileDialogs();

  @override
  Future<String?> saveBytes({
    required String dialogTitle,
    required String suggestedName,
    required String extension,
    required Uint8List bytes,
  }) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: suggestedName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: [extension],
    );
    return uri?.toFilePath();
  }

  @override
  Future<String?> pickFile({
    required String dialogTitle,
    required List<String> extensions,
  }) async {
    final files = await FilePicker.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    return files.isEmpty ? null : files.single.path;
  }

  @override
  Future<String?> pickDirectory({required String dialogTitle}) =>
      FilePicker.getDirectoryPath(dialogTitle: dialogTitle);
}
