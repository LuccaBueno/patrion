import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../../application/market/market_ports.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/finance/business_calendar.dart';
import '../../../domain/market/provider_catalog.dart';
import '../market_http.dart';
import 'b3_cotahist_provider.dart';

final _log = Logger('mercado');

/// Catálogo dos tickers negociados na B3 (nome resumido, classe e ISIN),
/// tirado do arquivo diário do COTAHIST do último pregão (M-01).
///
/// Fica no cache (`b3_tickers.json`): é dado de mercado público e pode ser
/// baixado de novo. Serve o cadastro rápido mesmo sem internet. O ZIP e o
/// TXT são apagados depois da extração (D-05).
class B3TickerCatalog implements TickerInfoProvider {
  B3TickerCatalog(
    this._http, {
    required this.cacheDir,
    Clock wallClock = const Clock(),
    BusinessCalendar? calendar,
  }) : _clock = wallClock,
       _calendar = calendar ?? BusinessCalendar.brazil;

  final MarketHttp _http;
  final String cacheDir;
  final Clock _clock;
  final BusinessCalendar _calendar;

  static const fileName = 'b3_tickers.json';

  /// Quantos pregões para trás procurar um arquivo diário já publicado.
  static const _maxDaysBack = 6;

  _Catalog? _cached;

  /// Dia em que o catálogo já foi baixado nesta sessão (no máximo uma vez
  /// por dia, mesmo que o ticker procurado não exista).
  LocalDate? _refreshedOn;

  String get path => p.join(cacheDir, fileName);

  @override
  String get code => ProviderCatalog.b3Cotahist.code;

  @override
  bool supports(String market) => market == 'B3';

  @override
  Future<TickerInfo?> lookup(String symbol) async {
    final wanted = symbol.toUpperCase();
    var catalog = _load();
    final hit = catalog?.tickers[wanted];
    if (hit != null) return _info(wanted, hit);
    final today = _today;
    if (_refreshedOn == today) return null;
    if (catalog != null && !catalog.date.isBefore(_lastSession)) return null;
    try {
      catalog = await _refresh();
    } on NetworkError {
      // Sem internet: vale o catálogo já baixado.
      if (catalog == null) rethrow;
      return null;
    }
    final fresh = catalog.tickers[wanted];
    return fresh == null ? null : _info(wanted, fresh);
  }

  /// Baixa o arquivo diário mais recente publicado e regrava o catálogo.
  Future<_Catalog> _refresh() async {
    _refreshedOn = _today;
    final dir = Directory(p.join(cacheDir, B3CotahistProvider.folderName))
      ..createSync(recursive: true);
    var day = _lastSession;
    for (var tries = 0; tries < _maxDaysBack; tries++) {
      final name =
          'COTAHIST_D${_two(day.day)}${_two(day.month)}${day.year}.ZIP';
      final zip = p.join(dir.path, name);
      try {
        await _http.download(
          code,
          Uri.https('bvmf.bmfbovespa.com.br', '/InstDados/SerHist/$name'),
          zip,
        );
        final tickers = await extract(zip);
        final catalog = _Catalog(day, tickers);
        _save(catalog);
        _log.info('Catálogo de tickers da B3: ${tickers.length} ($day)');
        return catalog;
      } on HttpStatusError catch (e) {
        if (e.statusCode != 404) {
          throw DataError(
            'A B3 não forneceu o arquivo $name (${e.statusCode}).',
          );
        }
      } finally {
        B3CotahistProvider.deleteRaw(zip);
      }
      day = _previousSession(day);
    }
    throw const DataError(
      'A B3 ainda não publicou o arquivo dos últimos dias.',
    );
  }

  /// Lê o arquivo diário e devolve `{ticker: [nome, classe, isin]}` dos
  /// papéis do mercado à vista de classes que o app conhece.
  static Future<Map<String, List<String>>> extract(String zipPath) {
    final txt = B3CotahistProvider.txtPathOf(zipPath);
    return Isolate.run(() {
      B3CotahistProvider.unzipSingle(zipPath, txt);
      final result = <String, List<String>>{};
      final lines = const LineSplitter().convert(
        latin1.decode(File(txt).readAsBytesSync()),
      );
      for (final line in lines) {
        final r = B3CotahistProvider.parseLine(line, const {});
        if (r == null || r.marketType != '010') continue;
        final assetClass = classOf(r.bdiCode, r.shortName);
        if (assetClass == null) continue;
        result[r.symbol] = [nameOf(r), assetClass, r.isin];
      }
      return result;
    });
  }

  /// Classe pelo código BDI. Fiagro entra como FII (o app não tem classe
  /// própria; o tratamento é o mesmo).
  static String? classOf(String bdiCode, String shortName) => switch (bdiCode) {
    '02' || '07' || '08' => 'stock_br',
    '12' || '13' => 'fii',
    '14' when shortName.startsWith('FIAGRO') || shortName.startsWith('FII') =>
      'fii',
    '14' => 'etf_br',
    '32' || '33' || '34' || '35' || '36' => 'bdr',
    _ => null,
  };

  /// "BRASIL ON NM": nome resumido e especificação, como a B3 publica.
  static String nameOf(CotahistRecord r) =>
      '${r.shortName} ${r.spec}'.trim().replaceAll(RegExp(r'\s+'), ' ');

  TickerInfo _info(String symbol, List<String> row) => TickerInfo(
    symbol: symbol,
    market: 'B3',
    source: code,
    name: row[0],
    assetClass: row[1],
    isin: row[2].isEmpty ? null : row[2],
  );

  _Catalog? _load() {
    final cached = _cached;
    if (cached != null) return cached;
    final file = File(path);
    if (!file.existsSync()) return null;
    try {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final tickers = (json['tickers']! as Map<String, Object?>).map(
        (k, v) => MapEntry(k, [for (final x in v! as List<Object?>) '$x']),
      );
      return _cached = _Catalog(LocalDate.parse('${json['date']}'), tickers);
    } on Object catch (error) {
      _log.warning('Catálogo de tickers ilegível; será baixado de novo', error);
      return null;
    }
  }

  void _save(_Catalog catalog) {
    final temp = File('$path.novo')
      ..writeAsStringSync(
        jsonEncode({'date': '${catalog.date}', 'tickers': catalog.tickers}),
        flush: true,
      );
    temp.renameSync(path);
    _cached = catalog;
  }

  LocalDate get _today => LocalDate.fromDateTime(_clock.now().toLocal());

  /// Último pregão completo: o dia útil antes de hoje.
  LocalDate get _lastSession => _previousSession(_today);

  LocalDate _previousSession(LocalDate from) {
    var d = from.addDays(-1);
    while (!_calendar.isBusinessDay(d)) {
      d = d.addDays(-1);
    }
    return d;
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

class _Catalog {
  const _Catalog(this.date, this.tickers);

  /// Pregão do arquivo de onde o catálogo saiu.
  final LocalDate date;
  final Map<String, List<String>> tickers;
}
