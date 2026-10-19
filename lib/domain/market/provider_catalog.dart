/// Necessidade de chave de API.
enum KeyRequirement { none, optional, required }

/// Descrição de um provedor de dados de mercado (`docs/FONTES_DE_DADOS.md`,
/// DECISIONS D-08 e D-35). Mostrada na tela "Fontes de dados".
class ProviderInfo {
  const ProviderInfo({
    required this.code,
    required this.name,
    required this.site,
    required this.role,
    required this.sends,
    required this.license,
    required this.limits,
    this.key = KeyRequirement.none,
    this.keyHelp,
    this.attribution,
    this.defaultEnabled = true,
    this.warning,
  });

  /// Código gravado em `source` dos dados e em `dev_provider_state`.
  final String code;
  final String name;
  final String site;

  /// Para que o app usa este provedor.
  final String role;

  /// O que vai em cada requisição (SPEC §3, privacidade; regra 8).
  final String sends;
  final String license;
  final String limits;
  final KeyRequirement key;

  /// Onde obter a chave.
  final String? keyHelp;

  /// Atribuição exigida pela licença, mostrada junto dos dados.
  final String? attribution;
  final bool defaultEnabled;

  /// Aviso (por exemplo, fonte não oficial).
  final String? warning;
}

/// Provedores usados pelo app, na ordem da tela.
abstract final class ProviderCatalog {
  static const bcbSgs = ProviderInfo(
    code: 'bcb_sgs',
    name: 'Banco Central — SGS',
    site: 'https://dadosabertos.bcb.gov.br',
    role: 'CDI, Selic, meta Selic, IPCA e IGP-M',
    sends: 'Só o código da série e o período pedido.',
    license: 'Dados abertos do Banco Central (ODbL)',
    limits:
        'Gratuito, sem chave. Até 10 anos por consulta nas séries diárias; o '
        'app consulta em janelas menores.',
  );

  static const bcbPtax = ProviderInfo(
    code: 'bcb_ptax',
    name: 'Banco Central — PTAX',
    site: 'https://olinda.bcb.gov.br',
    role: 'Câmbio oficial (PTAX de fechamento) de dólar, euro e outras moedas',
    sends: 'Só a moeda e o período pedido.',
    license: 'Dados abertos do Banco Central (ODbL)',
    limits: 'Gratuito, sem chave. Só dias úteis.',
  );

  static const ibgeSidra = ProviderInfo(
    code: 'ibge_sidra',
    name: 'IBGE — SIDRA',
    site: 'https://apisidra.ibge.gov.br',
    role: 'IPCA, como alternativa ao Banco Central',
    sends: 'Só a tabela e o período pedido.',
    license: 'Dados públicos do IBGE',
    limits: 'Gratuito, sem chave.',
  );

  static const frankfurter = ProviderInfo(
    code: 'frankfurter',
    name: 'Frankfurter (BCE)',
    site: 'https://frankfurter.dev',
    role: 'Câmbio de referência do Banco Central Europeu, quando falta PTAX',
    sends: 'Só as moedas e o período pedido.',
    license: 'Taxas de referência do BCE, serviço aberto',
    limits: 'Gratuito, sem chave.',
  );

  static const brapi = ProviderInfo(
    code: 'brapi',
    name: 'brapi',
    site: 'https://brapi.dev',
    role: 'Cotação atual de ações, FIIs, ETFs e BDRs da B3',
    sends: 'Só o código do ativo (por exemplo, PETR4) e a sua chave.',
    license: 'Serviço privado; termos do site',
    limits:
        'Plano gratuito: 15.000 requisições por mês, uma por vez, cotação '
        'atualizada a cada 30 minutos (não é tempo real). Sem chave, só '
        'PETR4, VALE3, MGLU3 e ITUB4 (conferido em 18/10/2026).',
    key: KeyRequirement.optional,
    keyHelp: 'Crie uma conta em brapi.dev e copie o token do painel.',
  );

  static const b3Cotahist = ProviderInfo(
    code: 'b3_cotahist',
    name: 'B3 — Séries históricas (COTAHIST)',
    site: 'https://www.b3.com.br',
    role:
        'Histórico oficial de preços da B3 (fechamento, sem ajuste) e '
        'fechamento do último pregão',
    sends:
        'Nada sobre você: baixa o arquivo público do ano ou do dia, e o app '
        'separa só os ativos da carteira.',
    license:
        'Arquivos públicos do site da B3, para uso pessoal; redistribuição '
        'comercial exige licença da B3',
    limits:
        'Gratuito, sem chave. O arquivo de um ano tem dezenas de MB: o app '
        'baixa só os anos necessários e apaga o arquivo depois de extrair.',
  );

  static const b3Events = ProviderInfo(
    code: 'b3_events',
    name: 'B3 — Proventos e eventos',
    site: 'https://www.b3.com.br',
    role:
        'Dividendos, JCP, rendimentos de FII, desdobramentos, grupamentos e '
        'bonificações',
    sends: 'Só o código da empresa ou do fundo (por exemplo, PETR).',
    license: 'Endereços internos do site da B3, não documentados como API',
    limits:
        'Gratuito, sem chave. Pode mudar sem aviso. A lista de eventos em '
        'ações pode ter lacunas (por exemplo, o desdobramento da PETR4 em '
        '2005).',
    warning: 'Não é uma API oficial: se mudar, o app avisa e usa o que já tem.',
  );

  static const tesouro = ProviderInfo(
    code: 'tesouro',
    name: 'Tesouro Transparente',
    site: 'https://www.tesourotransparente.gov.br',
    role: 'Preços e taxas diários dos títulos do Tesouro Direto',
    sends: 'Nada sobre você: baixa o arquivo público com todos os títulos.',
    license: 'Dados abertos do Tesouro Nacional (ODbL)',
    limits: 'Gratuito, sem chave. Arquivo único (cerca de 15 MB), diário.',
  );

  static const cvm = ProviderInfo(
    code: 'cvm',
    name: 'CVM — Dados abertos',
    site: 'https://dados.cvm.gov.br',
    role:
        'Informe mensal de FIIs (valor patrimonial por cota, patrimônio, '
        'cotistas) e cotas diárias de fundos',
    sends: 'Nada sobre você: baixa os arquivos públicos do mês ou do ano.',
    license: 'Dados abertos do governo federal (ODbL)',
    limits: 'Gratuito, sem chave. Informe de FII com defasagem de um mês.',
  );

  static const coingecko = ProviderInfo(
    code: 'coingecko',
    name: 'CoinGecko',
    site: 'https://www.coingecko.com',
    role: 'Cotação atual de criptomoedas em real e dólar',
    sends: 'Só o identificador da moeda (por exemplo, bitcoin) e a sua chave.',
    license: 'Plano Demo: atribuição obrigatória',
    limits:
        'Sem chave, limite baixo e variável (compartilhado por IP). Com a '
        'chave Demo (gratuita): 100 requisições por minuto, com cota mensal '
        'de créditos.',
    key: KeyRequirement.optional,
    keyHelp: 'Crie uma conta Demo em coingecko.com/api e copie a chave.',
    attribution: 'Data provided by CoinGecko',
  );

  static const binance = ProviderInfo(
    code: 'binance',
    name: 'Binance (dados públicos)',
    site: 'https://www.binance.com',
    role: 'Histórico diário de criptomoedas',
    sends: 'Só o par negociado (por exemplo, BTCBRL).',
    license: 'API pública de mercado; termos da Binance',
    limits:
        'Gratuito, sem chave, com limite por peso das requisições. Preço da '
        'própria corretora, não um índice.',
  );

  static const finnhub = ProviderInfo(
    code: 'finnhub',
    name: 'Finnhub',
    site: 'https://finnhub.io',
    role: 'Cotação atual de ações e ETFs dos EUA',
    sends: 'Só o código do ativo (por exemplo, AAPL) e a sua chave.',
    license: 'Plano gratuito para uso pessoal',
    limits:
        'Plano gratuito: cotação dos EUA, 30 requisições por segundo no '
        'máximo (o app usa bem menos). Histórico e outras bolsas só nos '
        'planos pagos.',
    key: KeyRequirement.required,
    keyHelp: 'Crie uma conta em finnhub.io e copie a chave do painel.',
  );

  static const twelveData = ProviderInfo(
    code: 'twelve_data',
    name: 'Twelve Data',
    site: 'https://twelvedata.com',
    role: 'Histórico diário de ações e ETFs dos EUA',
    sends: 'Só o código do ativo e a sua chave.',
    license: 'Plano Basic (gratuito)',
    limits:
        'Plano Basic: 8 créditos por minuto e 800 por dia; EUA, câmbio e '
        'cripto. A B3 só nos planos pagos.',
    key: KeyRequirement.required,
    keyHelp: 'Crie uma conta em twelvedata.com e copie a chave do painel.',
  );

  static const yahoo = ProviderInfo(
    code: 'yahoo',
    name: 'Yahoo Finance (não oficial)',
    site: 'https://finance.yahoo.com',
    role:
        'Alternativa para histórico internacional e índices (S&P 500, '
        'Nasdaq)',
    sends: 'Só o código do ativo ou do índice.',
    license:
        'Não é uma API oficial; os termos do Yahoo restringem a coleta '
        'automatizada',
    limits: 'Sem chave e sem limite publicado.',
    defaultEnabled: false,
    warning:
        'Desligado por padrão. Ligue só se aceitar usar uma fonte não '
        'oficial, que pode parar de funcionar sem aviso.',
  );

  static const all = [
    bcbSgs,
    bcbPtax,
    ibgeSidra,
    frankfurter,
    brapi,
    b3Cotahist,
    b3Events,
    tesouro,
    cvm,
    coingecko,
    binance,
    finnhub,
    twelveData,
    yahoo,
  ];

  /// Dados criados pelo próprio app (por exemplo, valores calculados).
  static const appCode = 'patrion';

  static ProviderInfo? byCode(String code) {
    for (final p in all) {
      if (p.code == code) return p;
    }
    return null;
  }

  /// Nome para mostrar ao lado de um dado.
  static String nameOf(String code) =>
      code == appCode ? 'Patrion (calculado)' : byCode(code)?.name ?? code;
}
