import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:decimal/decimal.dart';

import '../../../application/market/market_ports.dart';
import '../../../core/time/instant_format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/finance/business_calendar.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/provider_catalog.dart';
import '../market_http.dart';
import 'parse.dart';

/// B3 — proventos e eventos do site de empresas e fundos listados
/// (`FONTES_DE_DADOS.md` §2.5b). Endereços internos, não documentados.
///
/// - Empresas: proventos recentes e todos os eventos em ações do
///   "complemento" e o histórico de proventos em dinheiro, paginado.
/// - FIIs: rendimentos e eventos do complemento do fundo.
/// - O evento é do ativo pelo ISIN; sem ISIN conhecido, pela classe do
///   ticker (3 = ON, 4 = PN…).
/// - A data com vem da B3; a data ex é o dia útil seguinte.
class B3EventsProvider implements CorporateEventsProvider {
  B3EventsProvider(
    this._http, {
    Clock wallClock = const Clock(),
    BusinessCalendar? calendar,
    this.maxHistoryPages = 10,
  }) : _clock = wallClock,
       _calendar = calendar ?? BusinessCalendar.brazil;

  final MarketHttp _http;
  final Clock _clock;
  final BusinessCalendar _calendar;
  final int maxHistoryPages;

  static const _host = 'sistemaswebb3-listados.b3.com.br';

  @override
  String get code => ProviderCatalog.b3Events.code;

  @override
  bool supports(MarketInstrument i) =>
      i.market == 'B3' &&
      (i.assetClass == 'stock_br' || i.assetClass == 'fii') &&
      RegExp(r'^[A-Z]{4}\d{1,2}$').hasMatch(i.symbol.toUpperCase());

  static String _param(Map<String, Object?> json) =>
      base64.encode(utf8.encode(jsonEncode(json)));

  @override
  Future<List<CorporateEvent>> events(MarketInstrument i) async {
    final symbol = i.symbol.toUpperCase();
    final issuer = symbol.substring(0, 4);
    final now = formatInstant(_clock.now());
    final today = LocalDate.fromDateTime(_clock.now().toLocal());
    final fii = i.assetClass == 'fii';
    final supplementPath = fii
        ? '/fundsProxy/fundsCall/GetListedSupplementFunds/'
              '${_param({'cnpj': '0', 'identifierFund': issuer, 'typeFund': 7})}'
        : '/listedCompaniesProxy/CompanyCall/GetListedSupplementCompany/'
              '${_param({'issuingCompany': issuer, 'language': 'pt-br'})}';
    final supplementText = await _http.getText(
      code,
      Uri.https(_host, supplementPath),
    );
    final supplement = parseSupplement(
      supplementText,
      symbol: symbol,
      isin: i.isin,
      fii: fii,
    );
    final raw = <B3RawEvent>[...supplement.events];

    if (!fii && supplement.tradingName != null) {
      for (var page = 1; page <= maxHistoryPages; page++) {
        final text = await _http.getText(
          code,
          Uri.https(
            _host,
            '/listedCompaniesProxy/CompanyCall/GetListedCashDividends/'
            '${_param({'language': 'pt-br', 'pageNumber': page, 'pageSize': 120, 'tradingName': supplement.tradingName})}',
          ),
        );
        final (events, pages) = parseCashHistory(text, symbol: symbol);
        raw.addAll(events);
        if (page >= pages) break;
      }
    }
    return finish(raw, symbol: symbol, collectedAt: now, today: today);
  }

  /// Junta as fontes, tira repetidos, calcula a data ex e numera eventos
  /// iguais na mesma data.
  List<CorporateEvent> finish(
    List<B3RawEvent> raw, {
    required String symbol,
    required String collectedAt,
    required LocalDate today,
  }) {
    final seen = <String>{};
    final unique = <B3RawEvent>[];
    for (final e in raw) {
      final key = '${e.kind.code}|${e.comDate}|${e.amount}|${e.factor}';
      if (seen.add(key)) unique.add(e);
    }
    unique.sort((a, b) => a.comDate.compareTo(b.comDate));
    final seqs = <String, int>{};
    return [
      for (final e in unique)
        () {
          final exDate = _calendar.nextBusinessDay(e.comDate.addDays(1));
          final key = '${e.kind.code}|$exDate';
          final seq = seqs[key] = (seqs[key] ?? -1) + 1;
          final reference = e.paymentDate ?? exDate;
          return CorporateEvent(
            symbol: symbol,
            market: 'B3',
            kind: e.kind,
            exDate: exDate,
            comDate: e.comDate,
            paymentDate: e.paymentDate,
            factor: e.factor,
            amount: e.amount,
            currency: e.amount == null ? null : 'BRL',
            status: reference.isAfter(today)
                ? CorporateEventStatus.announced
                : CorporateEventStatus.paid,
            rawLabel: e.label,
            isin: e.isin,
            source: ProviderCatalog.b3Events.code,
            seq: seq,
            collectedAt: collectedAt,
          );
        }(),
    ];
  }

  /// Complemento da empresa ou do fundo: `cashDividends` e `stockDividends`
  /// (a B3 devolve uma lista com um objeto para empresas e um objeto para
  /// fundos).
  static ({List<B3RawEvent> events, String? tradingName}) parseSupplement(
    String text, {
    required String symbol,
    required String? isin,
    required bool fii,
  }) {
    const name = 'B3 (proventos)';
    var json = MarketParse.json(name, text);
    if (json is List<Object?>) {
      if (json.isEmpty) return (events: const [], tradingName: null);
      json = json.first;
    }
    final root = MarketParse.map(name, json, 'resposta');
    final events = <B3RawEvent>[];
    bool mine(Object? assetIsin) =>
        matchesIsin(symbol, isin, '${assetIsin ?? ''}', fii: fii);

    for (final d in (root['cashDividends'] as List<Object?>?) ?? const []) {
      if (d is! Map<String, Object?> || !mine(d['isinCode'])) continue;
      final com = MarketParse.brDate(d['lastDatePrior']);
      final amount = MarketParse.decimal(d['rate'], brazilian: true);
      final kind = cashKind('${d['label']}', fii: fii);
      if (com == null || amount == null || kind == null) continue;
      events.add(
        B3RawEvent(
          kind: kind,
          comDate: com,
          paymentDate: _validPayment(MarketParse.brDate(d['paymentDate'])),
          amount: amount,
          label: '${d['label']}'.trim(),
          isin: '${d['isinCode']}',
        ),
      );
    }
    for (final d in (root['stockDividends'] as List<Object?>?) ?? const []) {
      if (d is! Map<String, Object?> || !mine(d['isinCode'])) continue;
      final com = MarketParse.brDate(d['lastDatePrior']);
      final published = MarketParse.decimal(d['factor'], brazilian: true);
      final label = '${d['label']}'.trim();
      final event = stockEvent(label, published);
      if (com == null || event == null) continue;
      events.add(
        B3RawEvent(
          kind: event.$1,
          comDate: com,
          factor: event.$2,
          label: label,
          isin: '${d['isinCode']}',
        ),
      );
    }
    final tradingName = '${root['tradingName'] ?? ''}'.trim();
    return (
      events: events,
      tradingName: tradingName.isEmpty ? null : tradingName,
    );
  }

  /// Histórico paginado de proventos em dinheiro de uma empresa. Filtra pela
  /// espécie do ticker (`typeStock`: ON, PN, PNA, PNB, UNT).
  static (List<B3RawEvent>, int) parseCashHistory(
    String text, {
    required String symbol,
  }) {
    const name = 'B3 (proventos)';
    final root = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final page = root['page'];
    final pages = page is Map<String, Object?>
        ? int.tryParse('${page['totalPages']}') ?? 1
        : 1;
    final kindOfStock = stockTypeOf(symbol);
    final events = <B3RawEvent>[];
    for (final r in (root['results'] as List<Object?>?) ?? const []) {
      if (r is! Map<String, Object?>) continue;
      if (kindOfStock != null && '${r['typeStock']}'.trim() != kindOfStock) {
        continue;
      }
      final com = MarketParse.brDate(r['lastDatePriorEx']);
      final amount = MarketParse.decimal(r['valueCash'], brazilian: true);
      final kind = cashKind('${r['corporateAction']}', fii: false);
      if (com == null || amount == null || kind == null) continue;
      events.add(
        B3RawEvent(
          kind: kind,
          comDate: com,
          amount: amount,
          label: '${r['corporateAction']}'.trim(),
        ),
      );
    }
    return (events, pages);
  }

  static LocalDate? _validPayment(LocalDate? d) =>
      d == null || d.year >= 9999 || d.year < 1900 ? null : d;

  /// Espécie da ação pelo final do ticker.
  static String? stockTypeOf(String symbol) {
    final m = RegExp(r'(\d{1,2})$').firstMatch(symbol);
    return switch (m?.group(1)) {
      '3' => 'ON',
      '4' => 'PN',
      '5' => 'PNA',
      '6' => 'PNB',
      '7' => 'PNC',
      '8' => 'PND',
      '11' => 'UNT',
      _ => null,
    };
  }

  /// O ISIN do evento é o do ativo? Com ISIN conhecido, compara; sem ele,
  /// usa o padrão do ISIN brasileiro (`BRPETRACNPR6`: ACNOR = ON,
  /// ACNPR = PN, CTF = cota de fundo…).
  static bool matchesIsin(
    String symbol,
    String? known,
    String eventIsin, {
    required bool fii,
  }) {
    if (eventIsin.isEmpty) return false;
    if (known != null && known.isNotEmpty) return eventIsin == known;
    if (fii) return eventIsin.substring(6).startsWith('CTF');
    final pattern = switch (stockTypeOf(symbol)) {
      'ON' => 'ACNOR',
      'PN' => 'ACNPR',
      'PNA' => 'ACNPA',
      'PNB' => 'ACNPB',
      'UNT' => 'CDAM',
      _ => null,
    };
    return pattern != null &&
        eventIsin.length >= 11 &&
        eventIsin.substring(6, 6 + pattern.length) == pattern;
  }

  static CorporateEventKind? cashKind(String label, {required bool fii}) {
    final l = label.toUpperCase();
    if (l.contains('JRS') || l.contains('JUROS')) return CorporateEventKind.jcp;
    if (l.contains('DIVIDENDO')) return CorporateEventKind.cashDividend;
    if (l.contains('RENDIMENTO')) {
      return fii
          ? CorporateEventKind.fiiIncome
          : CorporateEventKind.cashDividend;
    }
    if (l.contains('AMORTIZA')) return CorporateEventKind.amortization;
    if (l.contains('RESTITU')) return CorporateEventKind.otherCash;
    return null;
  }

  /// Converte o fator publicado pela B3 no multiplicador da quantidade:
  /// desdobramento e bonificação vêm em porcentagem de aumento ("100" =
  /// 1:2), grupamento vem como o próprio multiplicador ("0,01" = 100:1).
  static (CorporateEventKind, Decimal)? stockEvent(
    String label,
    Decimal? published,
  ) {
    if (published == null || published <= Decimal.zero) return null;
    final l = label.toUpperCase();
    final percent =
        Decimal.one +
        (published / Decimal.fromInt(100)).toDecimal(
          scaleOnInfinitePrecision: 20,
        );
    if (l.contains('DESDOBR')) return (CorporateEventKind.split, percent);
    if (l.contains('BONIFIC')) return (CorporateEventKind.bonusShares, percent);
    if (l.contains('GRUPAM')) {
      return (CorporateEventKind.reverseSplit, published);
    }
    return null;
  }
}

/// Evento lido de uma das respostas da B3, antes de juntar e numerar.
class B3RawEvent {
  const B3RawEvent({
    required this.kind,
    required this.comDate,
    required this.label,
    this.paymentDate,
    this.amount,
    this.factor,
    this.isin,
  });

  final CorporateEventKind kind;
  final LocalDate comDate;
  final LocalDate? paymentDate;
  final Decimal? amount;
  final Decimal? factor;
  final String label;
  final String? isin;
}
