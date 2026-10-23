import 'package:decimal/decimal.dart';

import '../../application/market/market_data_service.dart';
import '../../core/time/instant_format.dart';
import '../../core/time/local_date.dart';
import '../../domain/market/market_data.dart';
import '../../domain/market/market_price.dart';
import '../../domain/market/provider_catalog.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/portfolio_valuation.dart';
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

/// Origem do preço usado numa posição: o texto do tooltip (fonte, data,
/// tipo e coleta), a nota curta e se está desatualizado.
typedef ValuationNote = ({String message, String short, bool stale});

/// Textos dos dados de mercado: sempre com fonte, data e tipo (regra 2).
abstract final class MarketLabels {
  /// De onde veio o preço ou saldo de [v]; nulo sem valor de mercado.
  static ValuationNote? valuation(ValuedPosition v, LocalDate today) {
    if (v.marketValue == null) return null;
    final market = v.marketPrice;
    if (market != null) {
      final stale = MarketPricing.isStale(
        market,
        today,
        market: v.asset?.market.code,
      );
      return (
        message:
            '${price(market)}\n${collected(market.collectedAt)}'
            '${stale ? '\nDesatualizado: a data é anterior ao último pregão.' : ''}',
        short:
            '${ProviderCatalog.shortNameOf(market.source)} · ${refOf(market)}',
        stale: stale,
      );
    }
    final source = v.valuationKind == ValuationKind.balance
        ? 'Saldo informado'
        : 'Preço informado';
    return (
      message:
          '$source em ${Fmt.date(v.valuationDate!)}'
          '${v.valuationStale ? '\nHá operações depois desta data: o valor pode estar desatualizado.' : ''}',
      short: 'informado · ${Fmt.date(v.valuationDate!)}',
      stale: v.valuationStale,
    );
  }

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
      IndicatorUnit.indexNumber when p.series == IndicatorSeries.btcUsd =>
        'US\$ ${Fmt.number(p.value, maxDecimals: 2)}',
      IndicatorUnit.indexNumber =>
        '${Fmt.number(p.value, maxDecimals: 2)} pontos',
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
