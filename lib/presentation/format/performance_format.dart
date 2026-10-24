import '../../domain/portfolio/performance.dart';
import '../../core/time/local_date.dart';
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

/// Início de um período com a data real dos dados (M-12): "desde 31/12/2025"
/// ou, quando os registros começam depois do início pedido, "desde
/// 22/10/2026, início dos registros".
String sinceLabel(LocalDate requested, LocalDate? firstData) =>
    firstData != null && firstData.isAfter(requested)
    ? 'desde ${Fmt.date(firstData)}, início dos registros'
    : 'desde ${Fmt.date(requested)}';

/// Motivos de "indisponível" das métricas de rentabilidade (M-12).
abstract final class PerformanceReasons {
  static String noIndex(String name) =>
      'Sem $name guardado. Atualize os indicadores em Configurações → '
      'Fontes de dados.';

  /// O CDI do período ainda não saiu: o Banco Central publica o de cada dia
  /// no dia útil seguinte.
  static String cdiPending(LocalDate lastPublished) =>
      'O CDI depois de ${Fmt.date(lastPublished)} ainda não foi publicado '
      '(o Banco Central publica o de cada dia no dia útil seguinte).';

  /// O IPCA do mês seguinte a [lastPublished] ainda não saiu.
  static String ipcaPending(LocalDate lastPublished) {
    final next = LocalDate(
      lastPublished.year,
      lastPublished.month,
      1,
    ).addMonths(1);
    return 'O IPCA de ${Fmt.monthYear(next)} ainda não foi publicado (o '
        'IBGE divulga por volta do dia 10 do mês seguinte).';
  }

  static String mwrTooShort(int days, int minDays) =>
      'A TIR precisa de pelo menos $minDays dias de histórico '
      '(${days == 1 ? 'há 1 dia' : 'há $days dias'}).';

  static const mwrNoSolution =
      'Os fluxos do período não têm uma taxa que os equilibre.';
}

/// Explicação do total aplicado (Painel e Carteira).
const totalAppliedInfo =
    'Aportes (compras com custos, inclusive o saldo inicial, na data '
    'informada) menos resgates (vendas, líquidas de custos).';

/// A definição única de ganho (M-12; `docs/FORMULAS.md` §3.1).
const totalGainInfo =
    'Ganho total = patrimônio − total aplicado + proventos recebidos. O '
    'lucro das vendas já está dentro (a venda sai do aplicado). Aportes não '
    'são ganho. Percentual sobre o total aportado.';
