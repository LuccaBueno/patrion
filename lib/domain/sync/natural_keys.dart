import '../portfolio/entities.dart';
import 'sync_rows.dart';

/// Chave natural de uma tabela: dois registros vivos com a mesma chave e ids
/// diferentes representam a mesma entidade e são unificados na mesclagem
/// (SPEC §10.4, `docs/BANCO.md` §2).
class NaturalKeySpec {
  const NaturalKeySpec({
    required this.table,
    required this.entity,
    required this.keyOf,
  });

  final String table;

  /// Valor gravado em `asset_aliases.entity`.
  final String entity;

  /// Chave do registro, já normalizada.
  final String Function(SyncRow row) keyOf;
}

String _norm(String? v) => normalizeNameKey(v ?? '');
String _upper(String? v) => (v ?? '').trim().toUpperCase();

/// Na ordem em que a unificação acontece: uma instituição unificada muda a
/// chave das contas, e um ativo unificado muda a das características de
/// renda fixa.
final naturalKeySpecs = <NaturalKeySpec>[
  NaturalKeySpec(
    table: 'institutions',
    entity: 'institution',
    keyOf: (r) => _norm(r['name_key']),
  ),
  NaturalKeySpec(
    table: 'accounts',
    entity: 'account',
    keyOf: (r) => '${r['institution_id']}|${_norm(r['name'])}',
  ),
  NaturalKeySpec(
    table: 'assets',
    entity: 'asset',
    keyOf: (r) => '${_upper(r['symbol'])}|${r['market']}|${r['asset_class']}',
  ),
  NaturalKeySpec(
    table: 'fixed_income_terms',
    entity: 'fixed_income_terms',
    keyOf: (r) => '${r['asset_id']}',
  ),
  NaturalKeySpec(
    table: 'shared_settings',
    entity: 'shared_setting',
    keyOf: (r) => '${r['key']}',
  ),
];

/// Tabela dos aliases criados pela unificação.
const aliasTable = 'asset_aliases';
