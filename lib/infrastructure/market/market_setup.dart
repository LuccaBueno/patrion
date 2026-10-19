import 'package:clock/clock.dart';

import '../../application/market/market_data_service.dart';
import '../../application/market/market_ports.dart';
import '../../domain/market/provider_catalog.dart';
import 'market_http.dart';
import 'providers/b3_cotahist_provider.dart';
import 'providers/b3_events_provider.dart';
import 'providers/bcb_providers.dart';
import 'providers/brapi_provider.dart';
import 'providers/global_providers.dart';
import 'providers/open_data_providers.dart';

/// Montagem dos adaptadores de mercado (DECISIONS D-35).
abstract final class MarketSetup {
  /// Intervalo mínimo entre requisições de cada provedor, abaixo dos
  /// limites publicados (`FONTES_DE_DADOS.md`).
  static final policies = <String, HttpPolicy>{
    // Basic: 8 créditos por minuto.
    ProviderCatalog.twelveData.code: const HttpPolicy(
      minInterval: Duration(milliseconds: 7600),
    ),
    // Sem chave, o limite é baixo e compartilhado por IP.
    ProviderCatalog.coingecko.code: const HttpPolicy(
      minInterval: Duration(milliseconds: 2500),
    ),
    // O SGS alterna dados, páginas de erro e 502 na mesma consulta.
    ProviderCatalog.bcbSgs.code: const HttpPolicy(
      minInterval: Duration(seconds: 1),
      timeout: Duration(seconds: 40),
      maxAttempts: 4,
    ),
    ProviderCatalog.b3Events.code: const HttpPolicy(
      minInterval: Duration(seconds: 1),
    ),
    ProviderCatalog.yahoo.code: const HttpPolicy(
      minInterval: Duration(seconds: 1),
    ),
    ProviderCatalog.tesouro.code: const HttpPolicy(
      timeout: Duration(seconds: 60),
    ),
    ProviderCatalog.cvm.code: const HttpPolicy(timeout: Duration(seconds: 60)),
  };

  static MarketHttp http() => MarketHttp(policies: policies);

  /// Provedores na ordem de preferência. As chaves são lidas a cada uso:
  /// cadastrar ou apagar uma chave vale na próxima requisição.
  static MarketProviders providers({
    required MarketHttp http,
    required ApiKeyStore keys,
    required String cacheDir,
    Clock wallClock = const Clock(),
  }) {
    String? key(String code) => keys.read(code);
    final brapi = BrapiProvider(
      http,
      apiKey: () => key(ProviderCatalog.brapi.code),
      wallClock: wallClock,
    );
    final coingecko = CoinGeckoProvider(
      http,
      apiKey: () => key(ProviderCatalog.coingecko.code),
      wallClock: wallClock,
    );
    final finnhub = FinnhubProvider(
      http,
      apiKey: () => key(ProviderCatalog.finnhub.code),
      wallClock: wallClock,
    );
    final twelve = TwelveDataProvider(
      http,
      apiKey: () => key(ProviderCatalog.twelveData.code),
      wallClock: wallClock,
    );
    final yahoo = YahooProvider(http, wallClock: wallClock);
    return MarketProviders(
      quotes: [brapi, coingecko, finnhub, twelve, yahoo],
      history: [
        BinanceProvider(http, wallClock: wallClock),
        twelve,
        yahoo,
      ],
      batchHistory: B3CotahistProvider(
        http,
        cacheDir: cacheDir,
        wallClock: wallClock,
      ),
      events: [B3EventsProvider(http, wallClock: wallClock)],
      indicators: [
        BcbSgsProvider(http, wallClock: wallClock),
        IbgeSidraProvider(http, wallClock: wallClock),
      ],
      fx: [
        BcbPtaxProvider(http, wallClock: wallClock),
        FrankfurterProvider(http, wallClock: wallClock),
      ],
      treasury: TesouroProvider(http, cacheDir: cacheDir, wallClock: wallClock),
      funds: CvmProvider(http, wallClock: wallClock),
    );
  }
}
