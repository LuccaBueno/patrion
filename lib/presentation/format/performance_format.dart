import '../../domain/portfolio/performance.dart';
import 'formatters.dart';

/// Texto do MWR: taxa anual, ou o retorno do período quando ele tem menos
/// de um ano (anualizar prazos curtos exagera o resultado).
extension MoneyWeightedReturnText on MoneyWeightedReturn {
  /// `+12,34% a.a.` ou `+3,21% no período`.
  String get text => isShortPeriod
      ? '${Fmt.percent(period)} no período'
      : '${Fmt.percent(annual)} a.a.';

  /// `de 10/01/2024 a 10/06/2024`.
  String get range => 'de ${Fmt.date(start)} a ${Fmt.date(end)}';
}
