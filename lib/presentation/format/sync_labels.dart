import 'package:decimal/decimal.dart';

import '../../application/sync/save_service.dart';
import '../../core/time/instant_format.dart';
import '../../core/time/local_date.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/operation_type.dart';
import '../../domain/portfolio/portfolio_calculator.dart';
import '../../domain/sync/sync_rows.dart';
import 'formatters.dart';
import 'labels.dart';

/// Rótulos da sincronização e dos backups na interface.
abstract final class SyncLabels {
  static const _tables = {
    'institutions': 'Instituições',
    'accounts': 'Contas',
    'assets': 'Ativos',
    'fixed_income_terms': 'Características de renda fixa',
    'operations': 'Operações',
    'manual_valuations': 'Preços e saldos informados',
    'shared_settings': 'Configurações compartilhadas',
    'asset_aliases': 'Registros unificados',
    'hypo_portfolios': 'Carteiras hipotéticas',
    'hypo_holdings': 'Composição das carteiras hipotéticas',
    'hypo_cashflow_rules': 'Aportes e retiradas hipotéticos',
    'hypo_scenarios': 'Cenários hipotéticos',
  };

  static const _entities = {
    'institution': 'Instituição',
    'account': 'Conta',
    'asset': 'Ativo',
    'fixed_income_terms': 'Características de renda fixa',
    'shared_setting': 'Configuração',
  };

  static const _columns = {
    'name': 'Nome',
    'symbol': 'Código',
    'market': 'Mercado',
    'asset_class': 'Classe',
    'type': 'Tipo',
    'trade_date': 'Data',
    'quantity': 'Quantidade',
    'unit_price': 'Preço',
    'gross_amount': 'Valor',
    'fees': 'Custos',
    'taxes': 'Impostos',
    'account_id': 'Conta',
    'asset_id': 'Ativo',
    'notes': 'Observações',
    'value': 'Valor',
    'ref_date': 'Data de referência',
  };

  static String table(String name) => _tables[name] ?? name;

  static String entity(String code) => _entities[code] ?? code;

  static String column(String name) => _columns[name] ?? name;

  /// Descrição curta de um registro, para conflitos, unificações e
  /// duplicatas.
  static String describe(String table, SyncRow row) {
    switch (table) {
      case 'operations':
        final type = _operationType(row['type']);
        final parts = [
          date(row['trade_date']),
          type,
          if (row['quantity'] != null) 'qtd ${number(row['quantity'])}',
          if (row['unit_price'] != null) 'preço ${number(row['unit_price'])}',
          if (row['quantity'] == null && row['gross_amount'] != null)
            'valor ${number(row['gross_amount'])}',
        ];
        return parts.join(' · ');
      case 'assets':
        final market = _market(row['market']);
        return '${row['symbol']} ($market)';
      case 'institutions' || 'accounts' || 'hypo_portfolios':
        return row['name'] ?? '';
      case 'shared_settings':
        return row['key'] ?? '';
      case 'manual_valuations':
        return 'Informado em ${date(row['ref_date'])}';
      default:
        return 'Registro ${row.id.substring(0, 8)}';
    }
  }

  /// Colunas de dados que diferem entre [a] e [b] (e a exclusão).
  static List<(String label, String a, String b)> differences(
    SyncTableSchema schema,
    SyncRow a,
    SyncRow b,
  ) {
    final result = <(String, String, String)>[];
    if (a.isDeleted != b.isDeleted) {
      result.add((
        'Situação',
        a.isDeleted ? 'excluído' : 'ativo',
        b.isDeleted ? 'excluído' : 'ativo',
      ));
    }
    for (final c in schema.dataColumns) {
      if (a[c] == b[c]) continue;
      result.add((column(c), value(c, a[c]), value(c, b[c])));
    }
    return result;
  }

  static String value(String column, String? raw) {
    if (raw == null) return '—';
    if (column.endsWith('_date')) return date(raw);
    if (column == 'type') return _operationType(raw);
    if (const {
      'quantity',
      'unit_price',
      'gross_amount',
      'fees',
      'taxes',
      'value',
      'rate',
      'spread',
    }.contains(column)) {
      return number(raw);
    }
    if (column.endsWith('_id')) return raw.substring(0, 8);
    return raw;
  }

  static String number(String? raw) {
    if (raw == null) return '—';
    final d = Decimal.tryParse(raw);
    return d == null ? raw : Fmt.number(d);
  }

  static String date(String? raw) {
    if (raw == null) return '—';
    try {
      return Fmt.date(LocalDate.parse(raw));
    } on FormatException {
      return raw;
    }
  }

  /// Instante UTC gravado (ISO-8601) no horário local.
  static String instant(String raw) {
    try {
      final local = parseInstant(raw).toLocal();
      String two(int v) => v.toString().padLeft(2, '0');
      return '${two(local.day)}/${two(local.month)}/${local.year} '
          '${two(local.hour)}:${two(local.minute)}';
    } on FormatException {
      return raw;
    }
  }

  static String bytes(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size + 512) ~/ 1024} KB';
    final tenths = (size * 10 + 524288) ~/ 1048576;
    return '${tenths ~/ 10},${tenths % 10} MB';
  }

  /// Uma inconsistência que a importação criaria na carteira real.
  static String warning(ImportWarning w) {
    final what = [
      if (w.operationType != null) w.operationType!.label,
      if (w.assetSymbol != null) w.assetSymbol!,
      if (w.accountLabel != null) 'em ${w.accountLabel}',
    ].join(' ');
    final when = Fmt.date(w.date);
    final subject = what.isEmpty ? 'Operação de $when' : '$what, $when';
    return switch (w.kind) {
      PortfolioIssueKind.oversold =>
        '$subject: a quantidade vendida ou transferida fica maior que a '
            'posição na data.',
      PortfolioIssueKind.missingTransferLeg =>
        '$subject: transferência sem a ponta de saída.',
      PortfolioIssueKind.unknownAsset =>
        '$subject: o ativo da operação não está cadastrado.',
      PortfolioIssueKind.currencyMismatch =>
        '$subject: moeda diferente da moeda da posição.',
    };
  }

  static String _operationType(String? code) {
    for (final t in OperationType.values) {
      if (t.code == code) return t.label;
    }
    return code ?? '';
  }

  static String _market(String? code) {
    for (final m in Market.values) {
      if (m.code == code) return m.label;
    }
    return code ?? '';
  }
}
