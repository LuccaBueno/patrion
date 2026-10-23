import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';

import '../../core/time/local_date.dart';
import '../../data/repositories/device_settings_repository.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';
import '../portfolio/portfolio_query.dart';
import '../settings/market_preferences.dart';
import 'market_data_service.dart';

final _log = Logger('mercado');

/// Andamento do histórico completo, para a interface ("Baixando histórico
/// de BBAS3… 2019").
class BackfillProgress {
  const BackfillProgress({
    required this.symbols,
    required this.step,
    required this.done,
    required this.total,
    this.percent,
  });

  /// Ativos atendidos neste passo.
  final List<String> symbols;

  /// Ano do COTAHIST (`2019`), `proventos` ou o ticker de fora da B3.
  final String step;

  /// Passos concluídos e total previsto nesta execução.
  final int done;
  final int total;

  /// Percentual baixado do arquivo em andamento, quando a fonte informa.
  final int? percent;

  String get label {
    final names = symbols.length <= 3
        ? symbols.join(', ')
        : '${symbols.take(3).join(', ')} e mais ${symbols.length - 3}';
    return switch (step) {
      eventsStep => 'Baixando proventos e eventos de $names…',
      _ when int.tryParse(step) != null =>
        'Baixando histórico de $names… $step',
      _ => 'Baixando histórico de $names…',
    };
  }

  static const eventsStep = 'proventos';

  BackfillProgress withPercent(int p) => BackfillProgress(
    symbols: symbols,
    step: step,
    done: done,
    total: total,
    percent: p,
  );
}

/// O que já foi baixado, por ativo (`dev_settings`, só deste PC: os dados
/// de mercado podem ser apagados e baixados de novo).
class BackfillState {
  BackfillState({
    Map<String, Map<int, LocalDate>>? years,
    Map<String, LocalDate>? events,
    Map<String, LocalDate>? others,
  }) : years = years ?? {},
       events = events ?? {},
       others = others ?? {};

  /// Ano do COTAHIST lido para o ticker e a data da leitura.
  final Map<String, Map<int, LocalDate>> years;

  /// Última busca de proventos e eventos do ticker.
  final Map<String, LocalDate> events;

  /// Última busca do histórico dos ativos de fora da B3.
  final Map<String, LocalDate> others;

  static BackfillState decode(String? json) {
    if (json == null) return BackfillState();
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      Map<String, LocalDate> dates(Object? v) => {
        for (final MapEntry(:key, :value)
            in ((v as Map<String, Object?>?) ?? const {}).entries)
          key: LocalDate.parse(value! as String),
      };
      return BackfillState(
        years: {
          for (final MapEntry(:key, :value)
              in ((map['years'] as Map<String, Object?>?) ?? const {}).entries)
            key: {
              for (final MapEntry(key: y, value: d)
                  in (value! as Map<String, Object?>).entries)
                int.parse(y): LocalDate.parse(d! as String),
            },
        },
        events: dates(map['events']),
        others: dates(map['others']),
      );
    } on Object catch (e) {
      // Estado ilegível: começa de novo (só custa baixar outra vez).
      _log.warning('Estado do histórico ilegível; recomeçando', e);
      return BackfillState();
    }
  }

  String encode() => jsonEncode({
    'years': {
      for (final MapEntry(:key, :value) in years.entries)
        key: {
          for (final MapEntry(key: y, value: d) in value.entries) '$y': '$d',
        },
    },
    'events': {for (final e in events.entries) e.key: '${e.value}'},
    'others': {for (final e in others.entries) e.key: '${e.value}'},
  });
}

/// Histórico completo de cotações em segundo plano (M-08, DECISIONS D-48).
///
/// - Ativos da B3: o COTAHIST anual, do ano mais recente para o mais antigo,
///   até o ano inicial configurado (padrão: dez anos). Um arquivo serve a
///   todos os ativos; os arquivos brutos são apagados logo depois (D-05).
/// - Cada ano lido fica registrado por ativo: fechar o app no meio só perde
///   o ano em andamento, e a próxima execução continua de onde parou.
/// - Um ano está completo se foi lido depois de terminar; o ano corrente,
///   se foi lido há até [freshDays] dias (depois disso, a atualização diária
///   cobre os últimos dias).
/// - Proventos e eventos (B3) de cada ativo, renovados a cada [eventsDays].
/// - Ativos de fora da B3: o histórico do provedor individual, uma vez por
///   dia.
class HistoryBackfillService {
  HistoryBackfillService({
    required this._market,
    required this._settings,
    required this._preferences,
    required this._portfolio,
    this._cleanCache,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  final MarketDataService _market;
  final DeviceSettingsRepository _settings;
  final MarketPreferences _preferences;
  final PortfolioQuery _portfolio;

  /// Apaga sobras de downloads interrompidos (arquivos anuais).
  final void Function()? _cleanCache;
  final Clock _clock;

  static const stateKey = 'market.history_backfill';
  static const freshDays = 10;
  static const eventsDays = 30;

  Future<RefreshResult>? _running;
  bool _again = false;

  LocalDate get _today => LocalDate.fromDateTime(_clock.now().toLocal());

  bool get running => _running != null;

  Future<BackfillState> state() async =>
      BackfillState.decode(await _settings.get(stateKey));

  Future<void> _save(BackfillState s) => _settings.put(stateKey, s.encode());

  /// O ano [year] lido em [readOn] está completo.
  static bool yearComplete(int year, LocalDate readOn, LocalDate today) =>
      readOn.year > year || today.daysSince(readOn) <= freshDays;

  /// Baixa o que falta. Chamadas durante uma execução fazem a execução
  /// repetir no fim (um ativo novo entrou no meio).
  Future<RefreshResult> run({void Function(BackfillProgress)? onProgress}) {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final future = _loop(onProgress).whenComplete(() => _running = null);
    _running = future;
    return future;
  }

  /// Esquece o que foi baixado de [symbol] ("Baixar histórico completo"): a
  /// próxima execução lê de novo todos os anos e os proventos.
  Future<void> forget(String symbol) async {
    final s = await state();
    s.years.remove(symbol);
    s.events.remove(symbol);
    s.others.remove(symbol);
    await _save(s);
  }

  Future<RefreshResult> _loop(
    void Function(BackfillProgress)? onProgress,
  ) async {
    final result = RefreshResult();
    _cleanCache?.call();
    try {
      do {
        _again = false;
        result.merge(await _once(onProgress));
      } while (_again);
    } finally {
      _cleanCache?.call();
    }
    return result;
  }

  /// Ativos que precisam de histórico: os com preço de mercado, inclusive
  /// os de posição encerrada (a evolução patrimonial passa por eles).
  Future<List<Asset>> _assets() async {
    final snap = await _portfolio.load();
    return [
      for (final a in snap.assets.values)
        if (a.priceSource == PriceSource.market &&
            a.assetClass != AssetClass.cash &&
            a.assetClass != AssetClass.treasury &&
            _market.hasHistorySource(a))
          a,
    ];
  }

  Future<RefreshResult> _once(
    void Function(BackfillProgress)? onProgress,
  ) async {
    final result = RefreshResult();
    final assets = await _assets();
    if (assets.isEmpty) return result;
    final today = _today;
    final startYear = await _preferences.historyStartYear(today.year);
    final state = await this.state();
    final b3 = {
      for (final a in assets)
        if (_market.usesBatchHistory(a)) a.symbol.toUpperCase(),
    };
    final years = [
      for (var y = today.year; y >= startYear; y--)
        if (b3.any((s) => !_done(state, s, y, today))) y,
    ];
    final withEvents = [
      for (final a in assets)
        if (_market.hasEventsSource(a) && _stale(state.events, a, today)) a,
    ];
    final others = [
      for (final a in assets)
        if (!_market.usesBatchHistory(a) && _stale(state.others, a, today, 1))
          a,
    ];
    final total = years.length + others.length + (withEvents.isEmpty ? 0 : 1);
    if (total == 0) return result;
    var done = 0;
    _log.info(
      'Histórico completo: ${b3.length} ativos da B3, ${years.length} anos; '
      '${others.length} de fora da B3',
    );

    for (final year in years) {
      final wanted = {
        for (final s in b3)
          if (!_done(state, s, year, today)) s,
      };
      final progress = BackfillProgress(
        symbols: wanted.toList()..sort(),
        step: '$year',
        done: done,
        total: total,
      );
      onProgress?.call(progress);
      // O arquivo traz todos os ativos: lê todos de uma vez.
      final read = await _market.downloadCotahistYear(
        b3,
        year,
        onProgress: (f) => onProgress?.call(progress.withPercent(f)),
      );
      result.merge(read.result);
      done++;
      if (!read.ok) {
        // Sem rede, os anos seguintes falhariam igual: fica para a próxima.
        if (read.result.offline) return result;
        continue;
      }
      for (final s in b3) {
        (state.years[s] ??= {})[year] = today;
      }
      await _save(state);
    }

    if (withEvents.isNotEmpty) {
      onProgress?.call(
        BackfillProgress(
          symbols: [for (final a in withEvents) a.symbol.toUpperCase()],
          step: BackfillProgress.eventsStep,
          done: done,
          total: total,
        ),
      );
      for (final a in withEvents) {
        final r = await _market.refreshEvents(a);
        result.merge(r);
        if (r.failures.isEmpty) state.events[a.symbol.toUpperCase()] = today;
      }
      await _save(state);
      done++;
    }

    for (final a in others) {
      onProgress?.call(
        BackfillProgress(
          symbols: [a.symbol.toUpperCase()],
          step: a.symbol.toUpperCase(),
          done: done++,
          total: total,
        ),
      );
      final r = await _market.downloadHistory(
        a,
        from: LocalDate(startYear, 1, 1),
      );
      result.merge(r);
      if (r.failures.isEmpty) {
        state.others[a.symbol.toUpperCase()] = today;
        await _save(state);
      }
    }
    return result;
  }

  static bool _done(BackfillState s, String symbol, int year, LocalDate today) {
    final readOn = s.years[symbol]?[year];
    return readOn != null && yearComplete(year, readOn, today);
  }

  static bool _stale(
    Map<String, LocalDate> dates,
    Asset a,
    LocalDate today, [
    int days = eventsDays,
  ]) {
    final last = dates[a.symbol.toUpperCase()];
    return last == null || today.daysSince(last) >= days;
  }

  /// Anos já lidos de [symbol] e o mais antigo, para a tela de Fontes de
  /// dados.
  Future<int?> firstYearRead(String symbol) async {
    final years = (await state()).years[symbol.toUpperCase()]?.keys;
    if (years == null || years.isEmpty) return null;
    return years.reduce((a, b) => a < b ? a : b);
  }

  /// Aguarda a execução em andamento (testes).
  Future<void> idle() async {
    final running = _running;
    if (running != null) await running;
  }
}
