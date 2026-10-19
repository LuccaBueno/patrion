import 'package:decimal/decimal.dart';

import '../../application/market/market_data_service.dart';
import '../../core/time/instant_format.dart';
import '../../domain/market/market_data.dart';
import '../../domain/market/market_price.dart';
import '../../domain/market/provider_catalog.dart';
import 'formatters.dart';
import 'sync_labels.dart';

extension MarketDataTypeLabel on MarketDataType {
  String get label => switch (this) {
    MarketDataType.close => 'fechamento',
    MarketDataType.intraday => 'intradiário',
    MarketDataType.adjusted => 'ajustado',
    MarketDataType.estimated => 'estimado',
    MarketDataType.calculated => 'calculado',
  };
}

/// Textos dos dados de mercado: sempre com fonte, data e tipo (regra 2).
abstract final class MarketLabels {
  /// Data de referência de um preço: com hora para cotações.
  static String refOf(MarketPrice p) => p.refAt == null
      ? Fmt.date(p.refDate)
      : SyncLabels.instant(formatInstant(p.refAt!));

  /// "Cotação intradiária da brapi em 17/10/2026 15:30 (até 30 min de
  /// atraso)".
  static String price(MarketPrice p) {
    final kind = p.dataType == MarketDataType.intraday
        ? 'Cotação intradiária'
        : 'Preço de ${p.dataType.label}';
    final delay = p.delayNote == null ? '' : ' (${p.delayNote})';
    return '$kind · ${ProviderCatalog.nameOf(p.source)} · ${refOf(p)}$delay';
  }

  /// "Coletado em 17/10/2026 15:31".
  static String collected(String collectedAt) =>
      'coletado em ${SyncLabels.instant(collectedAt)}';

  /// Valor de um indicador na unidade publicada.
  static String indicator(IndicatorPoint p) {
    final v = Fmt.number(p.value, maxDecimals: 6);
    return switch (p.series.unit) {
      IndicatorUnit.pctDay => '$v% ao dia',
      IndicatorUnit.pctMonth => '$v% no mês',
      IndicatorUnit.pctYear => '$v% ao ano',
      IndicatorUnit.indexNumber => v,
    };
  }

  /// "R$ 5,4321".
  static String fx(Decimal value) => 'R\$ ${Fmt.number(value, maxDecimals: 4)}';

  static String fxKind(FxKind kind) => switch (kind) {
    FxKind.ptaxClose => 'PTAX de fechamento',
    FxKind.reference => 'referência do BCE',
  };

  /// Resumo de uma atualização para a barra de avisos.
  static String result(RefreshResult r) {
    if (r.offline) {
      return 'Sem conexão: os dados de mercado não foram atualizados. Os '
          'valores mostrados são os últimos guardados, com a data de cada um.';
    }
    final parts = <String>[
      r.updated == 0
          ? 'Nada novo para gravar'
          : '${r.updated} ${r.updated == 1 ? 'registro atualizado' : 'registros atualizados'}',
      if (r.failures.isNotEmpty)
        'falha em ${{for (final f in r.failures) ProviderCatalog.nameOf(f.provider)}.join(', ')}',
      if (r.unsupported.isNotEmpty)
        'sem fonte disponível para ${r.unsupported.toSet().join(', ')}',
    ];
    return parts.join(' · ');
  }
}
