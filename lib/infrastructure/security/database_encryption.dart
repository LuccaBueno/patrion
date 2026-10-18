import 'dart:io';

import '../../core/crypto/database_key.dart';
import '../backup/database_file_inspector.dart';

/// Converte o arquivo do banco, fechado, entre aberto e criptografado
/// (ativar e desativar o bloqueio, SPEC §3).
///
/// A troca é em dois tempos, para nunca haver um momento sem um banco
/// legível no disco:
///
/// 1. [convert] grava a versão convertida num arquivo temporário, confere
///    (integridade, versão, contagens) e só então troca: o banco original
///    fica guardado como `patrion.db.anterior`;
/// 2. depois de o banco novo abrir no app, [discardPrevious] apaga o
///    anterior; se algo falhar, [restorePrevious] o põe de volta.
abstract final class DatabaseEncryption {
  static String previousOf(String databaseFile) => '$databaseFile.anterior';

  static void convert({
    required String databaseFile,
    DatabaseKey? from,
    DatabaseKey? to,
  }) {
    final temp = '$databaseFile.convertendo';
    DatabaseFileInspector.convert(
      source: databaseFile,
      sourceKey: from,
      target: temp,
      targetKey: to,
    );
    final previous = previousOf(databaseFile);
    _delete(previous);
    _deleteAuxiliary(databaseFile);
    File(databaseFile).renameSync(previous);
    File(temp).renameSync(databaseFile);
  }

  static bool hasPrevious(String databaseFile) =>
      File(previousOf(databaseFile)).existsSync();

  /// Apaga o banco anterior à conversão (que pode estar sem criptografia).
  static void discardPrevious(String databaseFile) =>
      _delete(previousOf(databaseFile));

  /// Volta o banco anterior à conversão.
  static void restorePrevious(String databaseFile) {
    final previous = File(previousOf(databaseFile));
    if (!previous.existsSync()) return;
    _delete(databaseFile);
    _deleteAuxiliary(databaseFile);
    previous.renameSync(databaseFile);
  }

  static void _deleteAuxiliary(String databaseFile) {
    for (final suffix in ['-journal', '-wal', '-shm']) {
      _delete('$databaseFile$suffix');
    }
  }

  static void _delete(String path) {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  }
}
