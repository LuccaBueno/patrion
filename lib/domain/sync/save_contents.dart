import '../../core/errors/app_error.dart';
import '../../core/sync/hlc.dart';
import 'sync_rows.dart';

/// Conversão de saves de schemas antigos (SPEC §10.3) e validação do
/// conteúdo contra o schema atual.
///
/// Cada passo converte as tabelas da versão `n` para `n + 1`. Tabelas que
/// não existiam ficam vazias. Hoje nenhum passo muda colunas: as versões 2 e
/// 3 só criaram tabelas (`docs/BANCO.md`). Uma futura mudança de coluna ganha
/// aqui o passo que preenche ou transforma o campo.
abstract final class SaveContents {
  static final Map<
    int,
    Map<String, List<SyncRow>> Function(Map<String, List<SyncRow>>)
  >
  _steps = {
    // v1 → v2: só tabelas novas (cadastros e carteira).
    1: (tables) => tables,
    // v2 → v3: só tabelas novas (aliases e carteiras hipotéticas).
    2: (tables) => tables,
  };

  /// Converte [tables] do schema [from] para o [to].
  static Map<String, List<SyncRow>> upgrade(
    Map<String, List<SyncRow>> tables, {
    required int from,
    required int to,
  }) {
    var current = tables;
    for (var v = from; v < to; v++) {
      final step = _steps[v];
      if (step == null) {
        throw DataError(
          'Não sei converter saves do schema $v. Gere um save novo no outro '
          'computador.',
        );
      }
      current = step(current);
    }
    return current;
  }

  /// Confere se cada tabela existe no schema atual, se cada linha tem
  /// exatamente as colunas da tabela, se os ids não se repetem e se os campos
  /// de sincronização são válidos. Lança [DataError] na primeira falha.
  static void validate(
    Map<String, List<SyncRow>> tables,
    Map<String, SyncTableSchema> schemas,
  ) {
    for (final MapEntry(key: name, value: rows) in tables.entries) {
      final schema = schemas[name];
      if (schema == null) {
        throw DataError('O save tem uma tabela desconhecida ($name).');
      }
      final expected = schema.columns.toSet();
      final ids = <String>{};
      for (final row in rows) {
        final columns = row.keys.toSet();
        if (columns.length != expected.length ||
            !columns.containsAll(expected)) {
          throw DataError(
            'O save tem registros de $name com colunas diferentes das '
            'esperadas.',
          );
        }
        final id = row['id'];
        final hlc = row['hlc'];
        if (id == null || id.isEmpty || !ids.add(id)) {
          throw DataError('O save tem um id inválido ou repetido em $name.');
        }
        if (hlc == null || row['device_id'] == null) {
          throw DataError('O save tem um registro de $name sem HLC.');
        }
        try {
          Hlc.parse(hlc);
        } on FormatException {
          throw DataError('O save tem um HLC inválido em $name.');
        }
        if (row['created_at'] == null || row['updated_at'] == null) {
          throw DataError('O save tem um registro de $name sem datas.');
        }
      }
    }
  }
}
