# Fontes de dados

Pesquisa feita em **17/10/2026** (Fase 1) e revisada em **18/10/2026** (Fase 6), com base na documentação publicada e em chamadas reais de teste. Cada chamada de teste levou só tickers públicos (PETR4, HGLG11, BTC), nunca dados da carteira.

Legenda da coluna "Verificado":

- **Testado:** chamada real feita em 17/10/2026 e resposta conferida.
- **Doc.:** confirmado na documentação oficial do provedor.
- **Terceiros:** só fontes não oficiais; tratar como não confirmado.

Preços, limites e condições mudam. Esta matriz foi revisada na Fase 6 e deve ser revisada de novo sempre que um adaptador falhar.

## 1. Resumo e recomendação

| Necessidade | Fonte principal | Alternativa | Observação |
|---|---|---|---|
| CDI, Selic, IPCA, IGP-M, TR | BCB SGS | IBGE SIDRA (IPCA, INPC) | Oficial, gratuito, sem chave |
| Câmbio USD e outras moedas | BCB PTAX (Olinda) | Frankfurter (BCE) | PTAX é a referência oficial no Brasil |
| Histórico de preços BR (ações, FIIs, ETFs, BDRs) | B3 COTAHIST | brapi (pago) / Yahoo (não oficial) | Preço bruto oficial desde 1986; o ajuste é calculado no app |
| Proventos e eventos BR | B3 (endpoints do site de empresas e fundos listados) | brapi | Listas incompletas: validar com o COTAHIST (ver §3) |
| Cotação atual BR (atrasada) | brapi Free (com chave) | Yahoo (não oficial) | Atraso de até 30 min no plano gratuito |
| Tesouro Direto | Tesouro Transparente (CSV) | brapi (pago) | Preços e taxas diários, histórico completo num arquivo |
| Fundos (cotas diárias) e FIIs (informe mensal) | CVM Dados Abertos | — | Arquivos mensais/anuais em ZIP |
| Internacional (ações, ETFs, REITs) | Finnhub (cotação) + Yahoo (histórico, não oficial) | Twelve Data, Alpha Vantage (limitados) | Não há fonte gratuita, oficial e completa |
| Cripto | CoinGecko Demo (cotação) + Binance (histórico) | CoinGecko pago | Demo só tem 1 ano de histórico |
| IMA, IDkA | ANBIMA (site: últimos 5 dias úteis) | — | Histórico só pelo ANBIMA Feed (pago); fica como "indisponível" |
| S&P 500, Nasdaq | Yahoo (não oficial, desligado por padrão) | — (Finnhub e Twelve Data gratuitos não têm os índices) | Benchmarks internacionais são o ponto mais frágil |

### Ponto crítico: backtest de retorno total BR

**Existe um caminho gratuito viável, com uma ressalva importante.**

1. O **COTAHIST** da B3 traz o preço oficial, **sem ajuste**, de todos os ativos negociados, por dia, desde 1986. Ele inclui o campo "fator de cotação".
2. Os **endpoints do site da B3** (empresas e fundos listados) trazem:
   - proventos em dinheiro (dividendos, JCP, rendimentos de FII), com data-com, valor e preço de fechamento na data-com. Para a PETR4 vieram 343 registros paginados;
   - eventos em ações (desdobramento, grupamento, bonificação), com fator, desde 1994.
3. Com esses dados, o app calcula o fator de ajuste e as séries de **retorno de preço** e **retorno total** por conta própria, com metodologia documentada em `FORMULAS.md`.

**Ressalva verificada em teste:** a lista de eventos em ações **está incompleta**. O desdobramento 4:1 da PETR4 em 01/09/2005 aparece no COTAHIST (fechamento de R$ 130,00 em 31/08/2005 e R$ 32,30 em 01/09/2005, com fator de cotação 1 nos dois dias) e no Yahoo, mas **não aparece** na lista de eventos da B3 nem na da brapi.

Por isso, a proposta é:

- detectar saltos de preço no COTAHIST que não tenham evento correspondente e marcar o trecho como "evento suspeito, não confirmado";
- permitir que o usuário cadastre ou confirme o evento manualmente (com a fonte "manual");
- nunca ajustar automaticamente com base num salto de preço sem evento confirmado. O backtest mostra o aviso e deixa o usuário decidir;
- oferecer importação de proventos e eventos por CSV (Fase 11) como reforço.

**Riscos dessa escolha:**

- Os endpoints JSON do site da B3 **não são uma API documentada**. Funcionam hoje, sem chave, mas podem mudar sem aviso. O adaptador deve falhar de forma clara e o app continua com o que já tem em cache.
- O COTAHIST anual é grande (2005: TXT de 44,8 MB descompactado; 2025: ZIP de 89 MB). Por isso ele é baixado **sob demanda**, só os anos necessários, a partir de um ano inicial configurável, para o cache descartável em `%LOCALAPPDATA%\Patrion\cache\` (DECISIONS D-05). O app guarda no banco só os tickers de interesse. Depois, a atualização usa os arquivos diários, que são pequenos.
- Ativos deslistados existem no COTAHIST (bom para viés de sobrevivência), mas seus eventos podem não estar mais no site da B3.

**Alternativa paga:** brapi Pro (R$ 1.399,90/ano) entrega histórico de 10+ anos, `adjustedClose` (proventos + desdobramentos + grupamentos), preços brutos (`includeRaw`) e proventos completos. Mesmo assim, ela sofre da mesma lacuna de eventos verificada acima, porque `stockDividends` também não trouxe o desdobramento de 2005.

## 2. Matriz por provedor

### 2.1 Banco Central — SGS (séries temporais)

| Item | Detalhe |
|---|---|
| Dados | Milhares de séries: CDI (12), Selic diária (11), Selic meta (432), IPCA (433), IGP-M (189), INPC (188), TR (226) etc. |
| Endpoint | `https://api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados?formato=json&dataInicial=dd/MM/aaaa&dataFinal=dd/MM/aaaa` e `/dados/ultimos/{n}` |
| Limites e custo | Gratuito. Desde 26/03/2025, séries diárias exigem filtro de datas e aceitam no máximo **10 anos por consulta** (testado: a consulta de 2000 a 2015 foi recusada com essa mensagem). Não há limite de taxa publicado: usar intervalo conservador. |
| Chave | Não |
| Atualização | Diária (CDI/Selic em D+1); mensal para índices de preço |
| Histórico | Desde a criação de cada série (Selic desde 1986) |
| Ajuste | Não se aplica |
| Licença | ODbL (Open Data Commons Open Database License), indicada no portal de dados abertos |
| Limitações e falha | Paginar por janelas de 10 anos. Em falha: usar cache; IPCA pode vir do SIDRA. |
| Verificado | Testado (CDI) + Doc. |

### 2.2 Banco Central — PTAX (Olinda)

| Item | Detalhe |
|---|---|
| Dados | Cotação de compra e venda do dólar e de outras moedas (boletins intermediários e fechamento) |
| Endpoint | `https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/CotacaoDolarPeriodo(...)` e `CotacaoMoedaPeriodo(...)` (OData, JSON) |
| Limites e custo | Gratuito; sem limite publicado |
| Chave | Não |
| Atualização | Dias úteis (o fechamento do dia testado tinha horário de 13h) |
| Histórico | Várias décadas (data inicial não conferida; o app só pede a partir do ano inicial configurado) |
| Licença | Dados abertos do BCB (ODbL) |
| Limitações e falha | Só dias úteis no Brasil. Em falha: cache e Frankfurter para moedas não-USD. |
| Verificado | Testado |

### 2.3 IBGE — SIDRA

| Item | Detalhe |
|---|---|
| Dados | IPCA (tabela 1737 e outras), INPC, PIB etc. |
| Endpoint | `https://apisidra.ibge.gov.br/values/t/{tabela}/n1/all/v/{variavel}/p/{periodo}` |
| Limites e custo | Gratuito; limite por consulta não conferido (o app pede só o período que falta) |
| Chave | Não |
| Atualização | Mensal (IPCA por volta do dia 10) |
| Histórico | Série longa do IPCA (data inicial não conferida; o app só pede a partir do ano inicial configurado) |
| Licença | Dados públicos do IBGE |
| Limitações e falha | Formato com cabeçalho na primeira linha. Alternativa: SGS 433. |
| Verificado | Testado |

### 2.4 CVM — Dados Abertos

| Item | Detalhe |
|---|---|
| Dados | Cotas diárias de fundos (`FI/DOC/INF_DIARIO`), informe mensal de FIIs (`FII/DOC/INF_MENSAL`: patrimônio, cotistas, rendimentos, imóveis), demonstrações de companhias (DFP/ITR, útil na v2) |
| Endpoint | `https://dados.cvm.gov.br/dados/...` (arquivos ZIP/CSV) |
| Limites e custo | Gratuito; arquivos grandes |
| Chave | Não |
| Atualização | Cotas: diária (arquivo mensal atualizado); FII: mensal, com defasagem |
| Histórico | Vários anos de arquivos (datas iniciais não conferidas; o app só pede os anos necessários) |
| Ajuste | Cotas de fundos já são líquidas de taxas; não há "ajuste" de eventos |
| Licença | Dados abertos do governo federal, licença ODbL (conferido em 18/10/2026) |
| Limitações e falha | Não traz cotação de mercado de FII (essa vem da B3). Defasagem do informe mensal. |
| Verificado | Testado (arquivos acessíveis) |

### 2.5 B3

**a) COTAHIST (séries históricas)**

| Item | Detalhe |
|---|---|
| Dados | Abertura, máxima, mínima, médio, fechamento, volume, negócios, ISIN, fator de cotação, de todos os ativos à vista e outros mercados |
| Endpoint | `https://bvmf.bmfbovespa.com.br/InstDados/SerHist/COTAHIST_A{aaaa}.ZIP` (anual), `_M{mmaaaa}` (mensal), `_D{ddmmaaaa}` (diário). Layout de largura fixa (245 colunas). |
| Limites e custo | Gratuito; arquivos anuais de dezenas de MB |
| Chave | Não |
| Atualização | Arquivo diário após o fechamento (fim de pregão; não é intradiário) |
| Histórico | Desde 1986 |
| Ajuste | **Nenhum.** Preço bruto. O ajuste é calculado pelo app. |
| Licença | Uso conforme termos do site da B3 (download público). Redistribuição comercial exige licença de market data da B3; o uso pessoal local está dentro do que o site oferece. |
| Limitações e falha | Download pesado no primeiro uso. Sem cotação durante o pregão. Em falha: cache local. |
| Verificado | Testado (2005 e 2025) |

**b) Proventos e eventos (site de empresas e fundos listados)**

| Item | Detalhe |
|---|---|
| Dados | Proventos em dinheiro (com data-com, valor, preço de fechamento na data-com), eventos em ações (desdobramento, grupamento, bonificação, com fator), subscrições. Empresas e FIIs. |
| Endpoint | `https://sistemaswebb3-listados.b3.com.br/listedCompaniesProxy/CompanyCall/GetListedSupplementCompany/{base64}`, `.../GetListedCashDividends/{base64}` (paginado) e `fundsProxy/fundsCall/GetListedSupplementFunds/{base64}` |
| Limites e custo | Gratuito; sem limite publicado |
| Chave | Não |
| Atualização | Conforme os anúncios (inclui proventos futuros já aprovados) |
| Histórico | Proventos em dinheiro paginados (PETR: 343 registros); eventos em ações desde 1994 |
| Licença | Endpoints internos do site, **não documentados como API pública** |
| Limitações e falha | Podem mudar sem aviso. **Lista de eventos incompleta** (§1). Em falha: brapi ou CSV manual. |
| Verificado | Testado (PETR e HGLG) |

**c) Market data oficial (UP2DATA, feeds)**: pago e voltado a empresas; fora do escopo.

### 2.6 Tesouro Direto / Tesouro Transparente

| Item | Detalhe |
|---|---|
| Dados | Taxas e PUs de compra e venda de todos os títulos, por dia; também há conjuntos de vendas, resgates e estoque |
| Endpoint | CSV no CKAN: `https://www.tesourotransparente.gov.br/ckan/dataset/df56aa42-.../PrecoTaxaTesouroDireto.csv` |
| Limites e custo | Gratuito; um arquivo único com todo o histórico (vários MB) |
| Chave | Não |
| Atualização | Diária (valores da manhã do dia útil) |
| Histórico | Arquivo único com todo o histórico publicado (o app grava só a partir do ano inicial configurado) |
| Ajuste | Não se aplica (PU já é o preço do título) |
| Licença | Dados abertos do Tesouro Nacional, licença ODbL indicada no CKAN (conferido em 18/10/2026; arquivo de 14,6 MB atualizado em 16/10/2026) |
| Limitações e falha | Não é cotação em tempo real. O site do Tesouro Direto tem JSON interno, mas ele já mudou e bloqueou acessos no passado; não usar. |
| Verificado | Testado |

### 2.7 brapi

| Item | Detalhe |
|---|---|
| Dados | Cotações BR (ações, FIIs, ETFs, BDRs), histórico, proventos, eventos, fundamentos, câmbio, cripto, Tesouro, inflação e juros |
| Planos | **Free:** R$ 0, 15.000 req/mês, 1 req simultânea, 1 ticker por req, histórico de até 3 meses, atualização a cada 30 min, só diário. **Startup:** R$ 1.199,90/ano, 150 mil req/mês, histórico de 1 ano, proventos de 1 ano. **Pro:** R$ 1.399,90/ano, 500 mil req/mês, histórico de 10+ anos, proventos completos, preços brutos. |
| Chave | Sim (header `Authorization: Bearer`). Sem chave: só PETR4, VALE3, MGLU3, ITUB4, MXRF11 e HGLG11, a 20 req/min por IP. |
| Atualização | 30 / 15 / 5 min conforme o plano. **Não é tempo real.** |
| Histórico | Depende do plano (acima). Os tickers de teste sem chave retornaram histórico desde 2000. |
| Ajuste | `adjustedClose` considera proventos, desdobramentos e grupamentos. `close` às vezes vem ajustado e às vezes não (documentação). Preço bruto só no Pro. |
| Licença | Serviço privado; seguir os termos do site |
| Limitações e falha | Plano Free não serve para backtest. Eventos incompletos (§1). Respeitar `Retry-After` em 429. Em falha: cache e, para fechamento, COTAHIST. |
| Verificado | Testado + Doc. |

### 2.8 Alpha Vantage

| Item | Detalhe |
|---|---|
| Dados | Ações globais, forex, cripto, indicadores |
| Limites e custo | Free: **25 req/dia** (página oficial). Premium a partir de US$ 49,99/mês (75 req/min). |
| Chave | Sim |
| Ajuste | `TIME_SERIES_DAILY_ADJUSTED` é premium (Terceiros) |
| Cobertura BR | Sufixo `.SAO` citado pela comunidade; não confirmado na documentação |
| Limitações | 25 req/dia inviabiliza uso diário. **Não recomendado.** |
| Verificado | Doc. (limite e preço) + Terceiros |

### 2.9 Finnhub

| Item | Detalhe |
|---|---|
| Dados | Cotação EUA em tempo real, fundamentos básicos, forex, cripto, notícias |
| Limites e custo | Free: uso pessoal; limite de 30 requisições por segundo (o app usa bem menos) |
| Chave | Sim |
| Histórico | Candles históricos e bolsas fora dos EUA são **pagos** (confirmado no swagger oficial em 18/10/2026) |
| Limitações | Usado só para a cotação atual de ações e ETFs dos EUA, com a chave do usuário |
| Verificado | Doc. (swagger oficial, 18/10/2026); teste com chave real no roteiro do usuário |

### 2.10 Twelve Data

| Item | Detalhe |
|---|---|
| Limites e custo | Basic (grátis): 8 créditos/min, 800/dia; EUA, câmbio e cripto. Grow US$ 79/mês; Pro US$ 229/mês. |
| Chave | Sim (a chave `demo` não serve para testes reais) |
| Cobertura BR | Só nos planos pagos (conferido em 18/10/2026) |
| Licença | Basic indica uso interno; direitos de exibição não listados |
| Limitações | Usado para o histórico diário (sem ajuste) e como segunda fonte de cotação dos EUA, com a chave do usuário; o app espera 7,6 s entre requisições |
| Verificado | Doc. (18/10/2026); teste com chave real no roteiro do usuário |

### 2.11 Stooq

| Item | Detalhe |
|---|---|
| Situação | **Inviável para automação.** O endpoint de CSV (`/q/d/l/`) responde com uma página de verificação em JavaScript (testado). Relatos de 2026 indicam chave obtida por CAPTCHA e cota diária. |
| Alternativa | Yahoo (não oficial) ou Twelve Data |
| Verificado | Testado + Terceiros |

### 2.12 CoinGecko

| Item | Detalhe |
|---|---|
| Dados | Preço de milhares de criptos em BRL e USD |
| Limites e custo | Demo (grátis, com chave): 100 req/min, 10.000 créditos/mês, histórico diário de **1 ano**, **atribuição obrigatória**. API pública sem chave também responde (testado), mas com limites menores e janela histórica limitada (consulta de 2014 recusada). Pago a partir de US$ 35/mês. |
| Chave | Demo: sim |
| Licença | Exige atribuição visível ("Data provided by CoinGecko") |
| Limitações | Histórico curto no Demo |
| Verificado | Testado + Doc. |

### 2.13 Outras fontes relevantes

**Binance (API pública de mercado)**

- Candles diários sem chave, desde a listagem do par. BTCBRL desde 13/10/2020 (testado); BTCUSDT desde 2017.
- Bom para o histórico de cripto além de 1 ano.
- Os pesos de requisição são publicados na documentação. Preço da própria corretora, não índice.

**Yahoo Finance (endpoint `v8/finance/chart`, não oficial)**

- Sem chave; histórico longo (PETR4.SA desde 2000), proventos, desdobramentos (inclui o de 2005 da PETR4) e `adjclose` (testado).
- **Não é API oficial.** A API pública foi encerrada em 2017, não há contrato nem limite publicado, e os termos de uso restringem a coleta automatizada.
- Proposta: adaptador **opcional, desligado por padrão**, com aviso na tela "Fontes de dados", usado só como alternativa para internacional e benchmarks (S&P 500, Nasdaq) e para conferência de eventos.

**Frankfurter (taxas de referência do BCE)**

- Sem chave, testado (EUR→BRL e USD).
- Alternativa à PTAX para moedas não cobertas.

**ANBIMA**

- IMA e IDkA: o site público mostra só os últimos 5 dias úteis.
- O histórico está no ANBIMA Feed, que é pago.
- Benchmarks IMA/IDkA ficam como "indisponível" até haver fonte.

**Status Invest, Fundamentus, Investidor10**

- Só raspagem de HTML, sem API e com termos restritivos.
- Não usar.

## 3. Regras de implementação (Fase 6)

- Um adaptador por provedor, atrás de interfaces (`QuoteProvider`, `HistoryProvider`, `CorporateEventsProvider`, `IndicatorProvider`, `FxProvider`).
- Cada dado gravado com fonte, data de referência, data de coleta e tipo (fechamento, intradiário, ajustado, estimado ou calculado).
- O ajuste por proventos e eventos é **calculado** pelo app a partir de dados brutos e marcado como "calculado", com a metodologia em `FORMULAS.md`.
- Controle de limites por provedor (cota mensal da brapi, 10 anos por consulta no SGS, pesos da Binance).
- Cache, timeout, retentativa com backoff exponencial e respeito a `Retry-After`.
- Deduplicação de requisições em andamento.
- Nenhuma requisição leva quantidades, valores ou composição da carteira: só tickers e séries.

## 4. Revisão da Fase 6 (18/10/2026)

- Finnhub e Twelve Data confirmados na documentação oficial (§2.9 e §2.10). Nenhuma fonte se mostrou inviável.
- Licenças: Tesouro Transparente e CVM com ODbL.
- Mudanças encontradas: o SGS do Banco Central recusa requisições sem `User-Agent`; o Frankfurter passou para `api.frankfurter.dev/v1`.
- Ordem de preferência e fallback, atualização e cache: DECISIONS D-35. Chaves de API: D-34. Dados de mercado no save: D-36.
- Pendente: o teste com chaves reais (brapi, Finnhub, Twelve Data, CoinGecko) é feito pelo usuário na tela "Fontes de dados"; as chaves nunca passam pelo chat nem pelo repositório.
