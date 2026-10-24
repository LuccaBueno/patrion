import 'dart:async';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/backup/backup_service.dart';
import '../application/market/history_backfill.dart';
import '../application/market/market_data_service.dart';
import '../application/market/market_overview.dart';
import '../application/market/market_ports.dart';
import '../application/settings/market_preferences.dart';
import '../application/settings/portfolio_preferences.dart';
import '../application/settings/portfolio_view_preferences.dart';
import '../application/portfolio/operation_service.dart';
import '../application/portfolio/portfolio_query.dart';
import '../application/portfolio/quick_add_service.dart';
import '../application/portfolio/registry_service.dart';
import '../application/portfolio/valuation_service.dart';
import '../application/portfolio/class_views_service.dart';
import '../application/portfolio/passive_income_service.dart';
import '../application/portfolio/risk_service.dart';
import '../application/portfolio/wealth_service.dart';
import '../core/time/local_date.dart';
import '../domain/portfolio/codes.dart';
import '../application/settings/appearance_service.dart';
import '../application/settings/lock_preferences.dart';
import '../application/sync/save_service.dart';
import '../application/updates/update_checker.dart';
import '../core/config/app_paths.dart';
import '../core/crypto/database_key.dart';
import '../data/db/app_database.dart';
import '../data/repositories/backup_registry_repository.dart';
import '../data/repositories/device_settings_repository.dart';
import '../data/repositories/market_repository.dart';
import '../data/repositories/portfolio_repositories.dart';
import '../data/repositories/provider_state_repository.dart';
import '../data/repositories/shared_settings_repository.dart';
import '../data/repositories/sync_peers_repository.dart';
import '../data/sync/market_save_gateway.dart';
import '../data/sync/sync_context.dart';
import '../data/sync/sync_tables_gateway.dart';
import '../domain/security/key_file.dart';
import '../infrastructure/backup/local_backup_file_system.dart';
import '../infrastructure/market/market_http.dart';
import '../infrastructure/market/market_setup.dart';
import '../infrastructure/market/providers/b3_cotahist_provider.dart';
import '../infrastructure/security/api_key_store.dart';
import '../infrastructure/updates/github_release_feed.dart';
import 'services/file_dialogs.dart';
import 'services/market_refresh.dart';
import 'services/open_requests.dart';

/// Ambiente montado na inicialização (`main.dart`). Os provedores abaixo são
/// sobrescritos no `ProviderScope` raiz; nos testes, com um banco em memória.
class AppEnvironment {
  const AppEnvironment({
    required this.paths,
    required this.deviceId,
    required this.deviceName,
    required this.appVersion,
  });

  final AppPaths paths;
  final String deviceId;
  final String deviceName;
  final String appVersion;
}

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => throw UnimplementedError('Sobrescrito na inicialização'),
);

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Sobrescrito na inicialização'),
);

final syncContextProvider = Provider<SyncContext>(
  (ref) => throw UnimplementedError('Sobrescrito na inicialização'),
);

final deviceSettingsRepositoryProvider = Provider<DeviceSettingsRepository>(
  (ref) => DeviceSettingsRepository(ref.watch(databaseProvider)),
);

final sharedSettingsRepositoryProvider = Provider<SharedSettingsRepository>(
  (ref) => SharedSettingsRepository(
    ref.watch(databaseProvider),
    ref.watch(syncContextProvider),
  ),
);

final appearanceServiceProvider = Provider<AppearanceService>(
  (ref) => AppearanceService(ref.watch(deviceSettingsRepositoryProvider)),
);

final themePreferenceProvider = StreamProvider<ThemePreference>(
  (ref) => ref.watch(appearanceServiceProvider).watchTheme(),
);

/// Valores em dinheiro ocultos neste PC (olho do Painel, M-11).
final hideValuesProvider = StreamProvider<bool>(
  (ref) => ref.watch(appearanceServiceProvider).watchHideValues(),
);

// -- Carteira real (F3) -------------------------------------------------------

final portfolioRepositoriesProvider = Provider<PortfolioRepositories>(
  (ref) => PortfolioRepositories(
    ref.watch(databaseProvider),
    ref.watch(syncContextProvider),
  ),
);

final registryServiceProvider = Provider<RegistryService>(
  (ref) => RegistryService(ref.watch(portfolioRepositoriesProvider)),
);

final operationServiceProvider = Provider<OperationService>(
  (ref) => OperationService(ref.watch(portfolioRepositoriesProvider)),
);

final valuationServiceProvider = Provider<ValuationService>(
  (ref) => ValuationService(ref.watch(portfolioRepositoriesProvider)),
);

/// Cadastro rápido pelo ticker (M-01).
final quickAddServiceProvider = Provider<QuickAddService>(
  (ref) => QuickAddService(
    ref.watch(portfolioRepositoriesProvider),
    ref.watch(registryServiceProvider),
    ref.watch(operationServiceProvider),
  ),
);

/// Preferências da carteira que vão no save (controle de caixa, M-03).
final portfolioPreferencesProvider = Provider<PortfolioPreferences>(
  (ref) => PortfolioPreferences(ref.watch(sharedSettingsRepositoryProvider)),
);

final trackCashProvider = StreamProvider<bool>(
  (ref) => ref.watch(portfolioPreferencesProvider).watchTrackCash(),
);

/// Alocação-alvo por classe (F8, Desempenho → Risco).
final allocationTargetsProvider = StreamProvider<Map<AssetClass, Decimal>>(
  (ref) => ref.watch(portfolioPreferencesProvider).watchTargets(),
);

final portfolioQueryProvider = Provider<PortfolioQuery>(
  (ref) => PortfolioQuery(
    ref.watch(portfolioRepositoriesProvider),
    market: ref.watch(marketRepositoryProvider),
    preferences: ref.watch(portfolioPreferencesProvider),
  ),
);

/// Retrato da carteira real, recalculado a cada alteração. Uma releitura com
/// os mesmos dados não é repassada às telas (M-10).
final portfolioSnapshotProvider = StreamProvider<PortfolioSnapshot>(
  (ref) => ref
      .watch(portfolioQueryProvider)
      .watch()
      .distinct((a, b) => a.dataKey == b.dataKey),
);

/// O retrato atual, avisando só quando cadastros, operações ou preços
/// informados mudam. Para os cálculos que leem o mercado por conta própria
/// e já recalculam com o [marketTickProvider]: uma cotação nova não os
/// dispara duas vezes (M-10).
Future<PortfolioSnapshot> _holdingsSnapshot(Ref ref) async {
  await ref.watch(portfolioSnapshotProvider.selectAsync((s) => s.holdingsKey));
  return ref.read(portfolioSnapshotProvider.future);
}

// -- Sessão, backup e save (F5) ----------------------------------------------

/// Troca da sessão do banco: restauração de backup e bloqueio do app (F5B).
/// Nulo nos testes que não montam a sessão.
abstract interface class SessionController implements Listenable {
  /// Restaura o backup [path]. Para um backup criptografado com outra chave,
  /// lança `BackupLockedError` sem [backupSecret] (senha ou chave de
  /// recuperação da época do backup).
  Future<void> restore(String path, {String? backupSecret});

  /// O bloqueio (banco criptografado com senha) está ativo neste PC.
  bool get lockEnabled;

  /// O desbloqueio pelo Windows Hello está ativo.
  bool get helloEnabled;

  Future<bool> helloAvailable();

  /// Criptografa o banco com uma senha nova e devolve a chave de
  /// recuperação (mostrada uma única vez).
  Future<String> enableLock(String password, {bool encryptBackups = true});

  /// A chave de recuperação da última ativação, ainda não mostrada; a tela
  /// a mostra uma vez (a sessão troca na ativação e a tela é remontada).
  String? takePendingRecoveryKey();

  /// Volta ao banco sem criptografia. Pede a senha atual.
  Future<void> disableLock(String password);

  Future<void> changePassword(String current, String next);

  /// Nova chave de recuperação (a anterior deixa de valer).
  Future<String> newRecoveryKey(String password);

  Future<void> setHello(bool enabled);

  /// Fecha o banco e volta à tela de desbloqueio.
  Future<void> lockNow();
}

final sessionControllerProvider = Provider<SessionController?>((ref) => null);

/// Aviso deixado pela troca de sessão (resultado da restauração).
final sessionNoticeProvider = Provider<String?>((ref) => null);

/// Arquivos `.invsave` recebidos para abrir (nulo nos testes que não usam).
final openRequestsProvider = Provider<OpenRequests?>((ref) => null);

/// Diálogos de arquivo do Windows (sobrescritos nos testes).
final fileDialogsProvider = Provider<FileDialogs>(
  (ref) => const PlatformFileDialogs(),
);

final backupServiceProvider = Provider<BackupService>((ref) {
  final env = ref.watch(appEnvironmentProvider);
  final security = ref.watch(sessionSecurityProvider);
  return BackupService(
    registry: BackupRegistryRepository(ref.watch(databaseProvider)),
    files: const LocalBackupFileSystem(),
    backupsDir: env.paths.backupsDir,
    appVersion: env.appVersion,
    deviceId: env.deviceId,
    deviceName: env.deviceName,
    key: security.key,
    keys: security.keys,
  );
});

final backupsProvider = StreamProvider<List<BackupEntry>>(
  (ref) => ref.watch(backupServiceProvider).watch(),
);

final syncPeersRepositoryProvider = Provider<SyncPeersRepository>(
  (ref) => SyncPeersRepository(ref.watch(databaseProvider)),
);

final saveServiceProvider = Provider<SaveService>((ref) {
  final env = ref.watch(appEnvironmentProvider);
  return SaveService(
    tables: SyncTablesGateway(
      ref.watch(databaseProvider),
      ref.watch(syncContextProvider),
    ),
    peers: ref.watch(syncPeersRepositoryProvider),
    sync: ref.watch(syncContextProvider),
    backups: ref.watch(backupServiceProvider),
    appVersion: env.appVersion,
    deviceName: env.deviceName,
    portfolio: ref.watch(portfolioQueryProvider),
    market: MarketSaveGateway(ref.watch(databaseProvider)),
  );
});

final syncPeersProvider = StreamProvider<List<DevSyncPeerRow>>(
  (ref) => ref.watch(syncPeersRepositoryProvider).watchPeers(),
);

final syncHistoryProvider = StreamProvider<List<DevSyncHistoryRow>>(
  (ref) => ref.watch(syncPeersRepositoryProvider).watchHistory(),
);

// -- Bloqueio (F5B) -----------------------------------------------------------

final lockPreferencesProvider = Provider<LockPreferences>(
  (ref) => LockPreferences(ref.watch(deviceSettingsRepositoryProvider)),
);

/// Minutos sem uso até bloquear (0 = nunca).
final idleMinutesProvider = StreamProvider<int>(
  (ref) => ref.watch(lockPreferencesProvider).watchIdleMinutes(),
);

/// Chave do banco aberto e arquivo de chaves atual, para os backups saírem
/// criptografados com o bloqueio ativo.
class SessionSecurity {
  const SessionSecurity({this.key, this.keys});

  final DatabaseKey? key;

  /// Atualizado quando a senha muda (a sessão continua a mesma).
  final KeyFile? keys;
}

final sessionSecurityProvider = Provider<SessionSecurity>(
  (ref) => const SessionSecurity(),
);

/// Aviso deixado por uma troca do bloqueio (ativar, desativar, recuperar),
/// mostrado nas Configurações.
final lockNoticeProvider = Provider<String?>((ref) => null);

// -- Dados de mercado (F6) ----------------------------------------------------

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepository(ref.watch(databaseProvider)),
);

final providerStateRepositoryProvider = Provider<ProviderStateRepository>(
  (ref) => ProviderStateRepository(ref.watch(databaseProvider)),
);

final marketPreferencesProvider = Provider<MarketPreferences>(
  (ref) => MarketPreferences(ref.watch(deviceSettingsRepositoryProvider)),
);

/// Chaves de API deste PC, fora do banco e do save (DECISIONS D-34).
final apiKeyStoreProvider = Provider<ApiKeyStore>((ref) {
  if (!Platform.isWindows) return MemoryApiKeyStore();
  return DpapiApiKeyStore(ref.watch(appEnvironmentProvider).paths.dataDir);
});

/// Acesso HTTP dos provedores (sobrescrito nos testes, sem rede).
final marketHttpProvider = Provider<MarketHttp>((ref) => MarketSetup.http());

final marketProvidersProvider = Provider<MarketProviders>(
  (ref) => MarketSetup.providers(
    http: ref.watch(marketHttpProvider),
    keys: ref.watch(apiKeyStoreProvider),
    cacheDir: ref.watch(appEnvironmentProvider).paths.cacheDir,
  ),
);

final marketDataServiceProvider = Provider<MarketDataService>(
  (ref) => MarketDataService(
    repo: ref.watch(marketRepositoryProvider),
    states: ref.watch(providerStateRepositoryProvider),
    providers: ref.watch(marketProvidersProvider),
    preferences: ref.watch(marketPreferencesProvider),
    portfolio: ref.watch(portfolioQueryProvider),
  ),
);

final providerStatesProvider = StreamProvider<List<ProviderState>>(
  (ref) => ref.watch(providerStateRepositoryProvider).watchAll(),
);

/// Intervalo da atualização automática, em minutos (0 = desligada).
final marketRefreshMinutesProvider = StreamProvider<int>(
  (ref) => ref.watch(marketPreferencesProvider).watchRefreshMinutes(),
);

/// Câmbio e indicadores mais recentes guardados (painel do Início e Fontes
/// de dados), recalculados quando os dados de mercado mudam.
final marketOverviewProvider = StreamProvider<MarketOverview>((ref) {
  final repo = ref.watch(marketRepositoryProvider);
  return MarketOverview.watch(repo);
});

/// Estado das atualizações de mercado (automática e manuais).
final marketRefreshProvider =
    NotifierProvider<MarketRefreshController, MarketRefreshState>(
      MarketRefreshController.new,
    );

/// Histórico completo em segundo plano (M-08).
final historyBackfillServiceProvider = Provider<HistoryBackfillService>((ref) {
  final cacheDir = ref.watch(appEnvironmentProvider).paths.cacheDir;
  return HistoryBackfillService(
    market: ref.watch(marketDataServiceProvider),
    settings: ref.watch(deviceSettingsRepositoryProvider),
    preferences: ref.watch(marketPreferencesProvider),
    portfolio: ref.watch(portfolioQueryProvider),
    cleanCache: () => B3CotahistProvider.cleanAnnual(cacheDir),
  );
});

final historyBackfillProvider =
    NotifierProvider<HistoryBackfillController, HistoryBackfillUiState>(
      HistoryBackfillController.new,
    );

// Atualizações (SPEC §19; DECISIONS D-40)

/// Versões publicadas (sobrescrito nos testes, sem rede).
final releaseFeedProvider = Provider<ReleaseFeed>((ref) => GitHubReleaseFeed());

final updateCheckerProvider = Provider<UpdateChecker>(
  (ref) => UpdateChecker(
    settings: ref.watch(deviceSettingsRepositoryProvider),
    feed: ref.watch(releaseFeedProvider),
    current: Version.parse(ref.watch(appEnvironmentProvider).appVersion),
  ),
);

final updateSnapshotProvider = StreamProvider<UpdateSnapshot>(
  (ref) => ref.watch(updateCheckerProvider).watch(),
);

/// Abre um endereço no navegador padrão (sobrescrito nos testes).
final linkOpenerProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

// -- Evolução patrimonial (M-09) ---------------------------------------------

final wealthServiceProvider = Provider<WealthService>(
  (ref) => WealthService(ref.watch(marketRepositoryProvider)),
);

/// Conta as mudanças nos dados de mercado, no máximo uma a cada
/// [marketTickInterval] (o histórico completo grava muitas vezes seguidas).
/// Regravar o que já estava guardado não conta (M-10).
final marketTickProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(marketRepositoryProvider);
  final controller = StreamController<int>();
  var count = 0;
  Timer? pending;
  var version = repo.contentVersion();
  final sub = repo.watchChanges().listen((_) {
    pending ??= Timer(marketTickInterval, () async {
      pending = null;
      try {
        final before = await version;
        final now = await repo.contentVersion();
        if (now == before || controller.isClosed) return;
        version = Future.value(now);
        controller.add(++count);
      } on Object {
        // Banco fechado no meio (troca de sessão): a próxima sessão relê.
      }
    });
  });
  controller.add(count);
  ref.onDispose(() {
    pending?.cancel();
    unawaited(sub.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});

const marketTickInterval = Duration(seconds: 3);

// Quem recalcula com o tique observa só o número: a passagem de "carregando"
// para o primeiro valor não é uma mudança de dados (M-10).

/// Evolução patrimonial e índices, recalculados quando a carteira ou os
/// dados de mercado mudam.
final wealthOverviewProvider = FutureProvider<WealthOverview>((ref) async {
  ref.watch(marketTickProvider.select((t) => t.value ?? 0));
  final snap = await _holdingsSnapshot(ref);
  return ref.watch(wealthServiceProvider).load(snap);
});

/// Risco da carteira no período (F8), calculado num isolate como a
/// evolução.
final riskReportProvider =
    FutureProvider.family<RiskReport, (LocalDate, LocalDate)>((
      ref,
      range,
    ) async {
      final overview = await ref.watch(wealthOverviewProvider.future);
      return RiskService(
        useIsolate: ref.watch(wealthServiceProvider).useIsolate,
      ).compute(overview, from: range.$1, to: range.$2);
    });

// -- Vista da Carteira (M-06) -------------------------------------------------

final portfolioViewPreferencesProvider = Provider<PortfolioViewPreferences>(
  (ref) =>
      PortfolioViewPreferences(ref.watch(deviceSettingsRepositoryProvider)),
);

/// Corretora escolhida no filtro da Carteira (nulo = todas).
final brokerFilterProvider = StreamProvider<String?>(
  (ref) => ref.watch(portfolioViewPreferencesProvider).watchBroker(),
);

final groupByBrokerProvider = StreamProvider<bool>(
  (ref) => ref.watch(portfolioViewPreferencesProvider).watchGroup(),
);

// -- Renda passiva (F8) -------------------------------------------------------

final passiveIncomeServiceProvider = Provider<PassiveIncomeService>(
  (ref) => PassiveIncomeService(
    ref.watch(portfolioRepositoriesProvider),
    ref.watch(marketRepositoryProvider),
  ),
);

/// Proventos registrados e os da B3, recalculados quando a carteira ou os
/// dados de mercado mudam.
final passiveIncomeProvider = FutureProvider<PassiveIncomeOverview>((
  ref,
) async {
  ref.watch(marketTickProvider.select((t) => t.value ?? 0));
  final snap = await _holdingsSnapshot(ref);
  return ref.watch(passiveIncomeServiceProvider).load(snap);
});

// -- Visões por classe da Carteira (F8) ---------------------------------------

/// FIIs, renda fixa e outras moedas, com o que está guardado.
final classViewsProvider = FutureProvider<ClassViewsData>((ref) async {
  ref.watch(marketTickProvider.select((t) => t.value ?? 0));
  final snap = await ref.watch(portfolioSnapshotProvider.future);
  final fx = ref.watch(marketOverviewProvider).value?.fx ?? const {};
  return ClassViewsService(ref.watch(marketRepositoryProvider)).load(
    snap,
    toBrl: {
      for (final MapEntry(:key, :value) in fx.entries)
        if (value.mid != null) key: value.mid!,
    },
  );
});
