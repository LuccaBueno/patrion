import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/market/market_data_service.dart';
import '../../application/settings/market_preferences.dart';
import '../providers.dart';

/// Estado das atualizações de mercado desta sessão.
class MarketRefreshState {
  const MarketRefreshState({
    this.running,
    this.lastTask,
    this.lastRunAt,
    this.lastResult,
  });

  /// Descrição da atualização em andamento (nulo se nenhuma).
  final String? running;
  final String? lastTask;
  final DateTime? lastRunAt;
  final RefreshResult? lastResult;

  bool get busy => running != null;

  /// A última tentativa falhou por falta de conexão.
  bool get offline => lastResult?.offline ?? false;
}

/// Executa as atualizações (uma de cada vez) e guarda o resultado da última
/// para a interface (SPEC §5: sinalização de erros e de falta de conexão).
class MarketRefreshController extends Notifier<MarketRefreshState> {
  var _queue = Future<void>.value();

  @override
  MarketRefreshState build() => const MarketRefreshState();

  MarketDataService get _service => ref.read(marketDataServiceProvider);

  Future<RefreshResult> run(
    String task,
    Future<RefreshResult> Function(MarketDataService service) job,
  ) {
    final completer = Completer<RefreshResult>();
    _queue = _queue.then((_) async {
      if (!ref.mounted) {
        completer.complete(RefreshResult());
        return;
      }
      state = MarketRefreshState(
        running: task,
        lastTask: state.lastTask,
        lastRunAt: state.lastRunAt,
        lastResult: state.lastResult,
      );
      RefreshResult result;
      try {
        result = await job(_service);
      } on Object catch (error) {
        result = RefreshResult()
          ..failures.add(ProviderFailure('patrion', '$error'));
      }
      if (ref.mounted) {
        state = MarketRefreshState(
          lastTask: task,
          lastRunAt: DateTime.now(),
          lastResult: result,
        );
      }
      completer.complete(result);
    });
    return completer.future;
  }

  /// [automatic]: chamada pela atualização automática (respeita o horário
  /// de pregão e o intervalo mínimo dos provedores que pedem isso).
  Future<RefreshResult> refreshPortfolio({bool automatic = false}) => run(
    automatic ? 'Atualização automática' : 'Atualização da carteira',
    (s) => s.refreshPortfolio(automatic: automatic),
  );
}

/// Atualização automática enquanto o app está aberto (SPEC §5): uma logo
/// depois de abrir e depois a cada intervalo configurado.
class MarketAutoRefresh extends ConsumerStatefulWidget {
  const MarketAutoRefresh({
    required this.child,
    this.firstDelay = const Duration(seconds: 5),
    super.key,
  });

  final Widget child;
  final Duration firstDelay;

  @override
  ConsumerState<MarketAutoRefresh> createState() => _MarketAutoRefreshState();
}

class _MarketAutoRefreshState extends ConsumerState<MarketAutoRefresh> {
  Timer? _first;
  Timer? _periodic;
  int? _minutes;

  @override
  void initState() {
    super.initState();
    _first = Timer(widget.firstDelay, _tick);
  }

  void _tick() {
    if (!mounted) return;
    final minutes =
        ref.read(marketRefreshMinutesProvider).value ??
        _minutes ??
        MarketPreferences.defaultRefreshMinutes;
    if (minutes == 0) return;
    unawaited(
      ref
          .read(marketRefreshProvider.notifier)
          .refreshPortfolio(automatic: true),
    );
  }

  void _schedule(int minutes) {
    if (_minutes == minutes) return;
    _minutes = minutes;
    _periodic?.cancel();
    _periodic = minutes == 0
        ? null
        : Timer.periodic(Duration(minutes: minutes), (_) => _tick());
  }

  @override
  void dispose() {
    _first?.cancel();
    _periodic?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = ref.watch(marketRefreshMinutesProvider).value;
    if (minutes != null) _schedule(minutes);
    return widget.child;
  }
}
