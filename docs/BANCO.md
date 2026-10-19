# Modelo de dados

**Situação:** aprovado na Fase 1 (17/10/2026). Este documento deve sempre refletir o schema real.

**Implementado:**

- Schema versão 1 (Fase 2, 17/10/2026): `dev_identity`, `dev_settings` e `shared_settings`.
- Schema versão 2 (Fase 3, 17/10/2026): `institutions`, `accounts`, `assets`, `fixed_income_terms`, `operations` e `manual_valuations`, com os campos e índices descritos em §3, mais índice em `hlc` em todas. As colunas que referenciam outras tabelas são chaves estrangeiras (`PRAGMA foreign_keys = ON`). Migração 1 → 2 só cria tabelas e índices; o backup automático antes dela está em §9.
- Schema versão 3 (Fase 5, 17/10/2026): `asset_aliases`, `hypo_portfolios`, `hypo_holdings`, `hypo_cashflow_rules`, `hypo_scenarios` (só as tabelas, para o save já levá-las; telas e cálculos na F9, DECISIONS D-29), `dev_sync_peers`, `dev_sync_history` e `dev_backups`. Migração 2 → 3 só cria tabelas e índices. `hypo_runs` continua planejada (F9).

As demais tabelas descritas abaixo ainda são planejadas, cada uma com nova versão de schema e migração. Posições e totais ainda não usam as tabelas `drv_` (§7): são recalculados em memória (DECISIONS D-20).

## 1. Visão geral

O banco é um único arquivo SQLite (`%APPDATA%\Patrion\patrion.db`, ver DECISIONS D-05), acessado via Drift, com migrações versionadas e testadas. Arquivos baixados (COTAHIST, CSVs) ficam fora do banco, no cache descartável em `%LOCALAPPDATA%\Patrion\cache\`.

As tabelas se dividem em cinco grupos:

| Grupo | Prefixo | Sincronizável | Vai no save | Exemplo |
|---|---|---|---|---|
| Carteira real e cadastros | (nenhum) | Sim | Sim, em `data/` | `operations` |
| Configurações compartilhadas | (nenhum) | Sim | Sim, em `data/` | `allocation_targets` |
| Carteiras hipotéticas | `hypo_` | Sim | Sim, em `data/` | `hypo_portfolios` |
| Dados de mercado | `mkt_` | Não (chave natural) | Opcional, em `market/` | `mkt_prices` |
| Dispositivo e derivados | `dev_`, `drv_` | Não | Não | `dev_settings`, `drv_positions` |

## 2. Convenções

**Tipos**

| Conteúdo | Tipo SQLite | Formato |
|---|---|---|
| Identificador | `TEXT` | UUID v7, minúsculo, com hífens |
| Instante | `TEXT` | ISO-8601 UTC com ms: `2026-10-17T17:30:00.000Z` |
| Data de calendário | `TEXT` | `AAAA-MM-DD` |
| Decimal (dinheiro, quantidade, preço, taxa, câmbio) | `TEXT` | Representação canônica do `Decimal` (`"30.05"`). Nunca `REAL`. |
| Enumeração | `TEXT` | Código estável em inglês (`buy`, `sell`, `split`) |
| Estrutura variável | `TEXT` | JSON (só para parâmetros e premissas, nunca para dados que precisam de consulta) |
| Moeda | `TEXT` | ISO 4217 (`BRL`, `USD`); cripto pelo código do ativo |

**Campos de sincronização** (presentes em toda tabela sincronizável; abreviados como **[sync]** abaixo)

| Campo | Tipo | Regra |
|---|---|---|
| `id` | TEXT PK | UUID v7 gerado no app |
| `created_at` | TEXT | UTC, preenchido na criação |
| `updated_at` | TEXT | UTC, atualizado em toda escrita |
| `hlc` | TEXT | HLC da última alteração (ver DECISIONS D-10) |
| `device_id` | TEXT | Dispositivo que fez a última alteração |
| `deleted_at` | TEXT NULL | Tombstone. Registros sincronizáveis nunca são apagados fisicamente. |

- Toda escrita passa por um repositório base que preenche esses campos e avança o HLC.
- Consultas comuns filtram `deleted_at IS NULL`.
- Índice em `hlc` em todas as tabelas sincronizáveis (para exportar e calcular a mesclagem).
- Chaves estrangeiras entre tabelas sincronizáveis apontam para `id`. Como o registro referenciado nunca é apagado fisicamente, as referências continuam válidas após um tombstone.
- Unicidade de chave natural (por exemplo, ticker + mercado) é aplicada **pelo app**, não por índice único, porque dois PCs podem criar a mesma entidade com UUIDs diferentes, e a mesclagem precisa recebê-los antes de unificar (SPEC §10.4).

## 3. Cadastros e carteira real (sincronizáveis)

### `institutions`

Corretoras, bancos e exchanges.

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `name` | TEXT | Nome exibido |
| `name_key` | TEXT | Nome normalizado (chave natural para unificação) |
| `kind` | TEXT | `broker`, `bank`, `exchange`, `other` |
| `country` | TEXT | ISO 3166 alfa-2 |
| `notes` | TEXT NULL | |

### `accounts`

Contas dentro de uma instituição.

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `institution_id` | TEXT FK | |
| `name` | TEXT | Chave natural: `institution_id` + nome normalizado |
| `kind` | TEXT | `brokerage`, `checking`, `savings`, `crypto_wallet`, `other` |
| `currency` | TEXT | Moeda principal |
| `archived_at` | TEXT NULL | |

### `assets`

Catálogo de ativos. É compartilhado entre a carteira real e as hipotéticas: ele descreve o instrumento, não a posição de ninguém.

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `symbol` | TEXT | Ticker ou código (`PETR4`, `AAPL`, `BTC`, `TESOURO-IPCA-2035`) |
| `market` | TEXT | `B3`, `NYSE`, `NASDAQ`, `CRYPTO`, `TESOURO`, `OTC`, `MANUAL` |
| `asset_class` | TEXT | `stock_br`, `fii`, `etf_br`, `bdr`, `fixed_income`, `treasury`, `bank_product`, `stock_intl`, `etf_intl`, `reit`, `crypto`, `cash` |
| `name` | TEXT | |
| `currency` | TEXT | Moeda de negociação |
| `country` | TEXT | |
| `isin` | TEXT NULL | |
| `sector` | TEXT NULL | |
| `segment` | TEXT NULL | |
| `liquidity` | TEXT NULL | `daily`, `d_plus_n`, `at_maturity`, `other` |
| `price_source` | TEXT | `market` (vem de `mkt_`) ou `manual` |
| `notes` | TEXT NULL | |

Chave natural: `symbol` + `market` + `asset_class`.

### `fixed_income_terms`

Características de renda fixa (1:1 com `assets` de classe `fixed_income` ou `treasury`).

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `asset_id` | TEXT FK | |
| `product` | TEXT | `cdb`, `rdb`, `lci`, `lca`, `lc`, `debenture`, `cri`, `cra`, `tesouro_selic`, `tesouro_prefixado`, `tesouro_ipca` |
| `issuer` | TEXT NULL | Emissor |
| `indexer` | TEXT | `pre`, `cdi`, `selic`, `ipca`, `igpm` |
| `rate` | TEXT | Decimal. Percentual do indexador (ex.: 110% do CDI) ou taxa prefixada |
| `spread` | TEXT NULL | Decimal. Taxa adicional (ex.: IPCA + 6%) |
| `day_count` | TEXT | `bus252`, `act365`, `act360`, `30_360` |
| `issue_date` | TEXT | |
| `maturity_date` | TEXT | |
| `grace_until` | TEXT NULL | Carência |
| `liquidity` | TEXT | |
| `tax_regime` | TEXT | `regressive_ir`, `exempt`, `other` (só informativo; o app não calcula IR) |
| `costs_notes` | TEXT NULL | |

### `operations`

Todas as operações da carteira real (SPEC §7).

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `account_id` | TEXT FK | |
| `asset_id` | TEXT FK NULL | Nulo para movimentos só de caixa |
| `type` | TEXT | `buy`, `sell`, `contribution`, `redemption`, `deposit`, `withdrawal`, `transfer_out`, `transfer_in`, `dividend`, `jcp`, `fii_income`, `interest`, `amortization`, `bonus_shares`, `split`, `reverse_split`, `maturity`, `fee`, `tax`, `withholding`, `reinvestment`, `manual_adjustment` |
| `trade_date` | TEXT | Data da operação |
| `settlement_date` | TEXT NULL | |
| `quantity` | TEXT NULL | Decimal |
| `unit_price` | TEXT NULL | Decimal, na moeda da operação |
| `gross_amount` | TEXT NULL | Decimal |
| `fees` | TEXT | Decimal, padrão `"0"` |
| `taxes` | TEXT | Decimal, padrão `"0"` (impostos e retenções informados) |
| `currency` | TEXT | |
| `fx_rate` | TEXT NULL | Decimal, para BRL, quando a moeda não é BRL |
| `ratio_from` | TEXT NULL | Decimal. Eventos: 1 em "1:2" |
| `ratio_to` | TEXT NULL | Decimal. Eventos: 2 em "1:2" |
| `transfer_group_id` | TEXT NULL | Liga as duas pontas de uma transferência |
| `related_operation_id` | TEXT FK NULL | Ex.: reinvestimento ligado ao provento |
| `justification` | TEXT NULL | Obrigatória para `manual_adjustment` |
| `notes` | TEXT NULL | |
| `origin` | TEXT | `manual`, `csv_import`, `save_merge` |

Índices: (`asset_id`, `trade_date`), (`account_id`, `trade_date`), `trade_date`.

### `manual_valuations`

Preços e saldos informados pelo usuário (preço manual, saldo de caixinha, valor de um título informado pela instituição).

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `asset_id` | TEXT FK | |
| `account_id` | TEXT FK NULL | Obrigatório para saldos de produtos bancários |
| `ref_date` | TEXT | Data de referência |
| `kind` | TEXT | `unit_price` ou `balance` |
| `value` | TEXT | Decimal |
| `currency` | TEXT | |
| `notes` | TEXT NULL | |

### `market_event_reviews`

Decisões do usuário sobre eventos corporativos de mercado: confirmar um evento suspeito, rejeitar um evento errado ou adicionar um evento ausente nas fontes (ver `FONTES_DE_DADOS.md` §1). É dado do usuário, por isso sincroniza.

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `symbol` | TEXT | |
| `market` | TEXT | |
| `event_kind` | TEXT | `split`, `reverse_split`, `bonus_shares`, `cash_dividend`, `jcp`, `fii_income` |
| `ex_date` | TEXT | |
| `factor` | TEXT NULL | Decimal |
| `amount` | TEXT NULL | Decimal, por cota/ação |
| `action` | TEXT | `confirm`, `reject`, `add` |
| `mkt_event_key` | TEXT NULL | Referência ao evento de `mkt_corporate_events`, se existir |
| `notes` | TEXT NULL | |

### `asset_aliases`

Registro da unificação de entidades duplicadas pela mesclagem (SPEC §10.4).

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `entity` | TEXT | `institution`, `account`, `asset`, `fixed_income_terms`, `shared_setting` |
| `alias_id` | TEXT | UUID absorvido |
| `canonical_id` | TEXT | UUID que permaneceu |

Ao unificar, as referências são remapeadas e o registro absorvido recebe tombstone. O alias permite remapear referências que cheguem depois, vindas de saves antigos.

## 4. Configurações compartilhadas (sincronizáveis)

Vão no save, conforme SPEC §10.1.

| Tabela | Campos principais | Para quê |
|---|---|---|
| `shared_settings` | [sync], `key` (TEXT), `value_json` (TEXT) | Preferências que valem em todos os PCs (moeda de exibição, benchmarks padrão, alíquotas usadas nos simuladores). Chave natural: `key`. |
| `categories` | [sync], `dimension` (`strategy`, `objective`, `custom`), `name`, `color` | Agrupamentos do usuário |
| `asset_categories` | [sync], `asset_id`, `category_id` | Ligação ativo ↔ categoria |
| `allocation_targets` | [sync], `dimension` (`class`, `currency`, `country`, `category`, `asset`), `key`, `target_pct` (Decimal), `band_pct` (Decimal NULL) | Alocação-alvo |
| `goals` | [sync], `name`, `target_amount`, `currency`, `target_date`, `notes` | Metas |
| `alert_rules` | [sync], `kind`, `asset_id` NULL, `params_json`, `enabled` | Regras de alerta |

## 5. Carteiras hipotéticas (sincronizáveis, separadas)

Ficam em tabelas próprias com prefixo `hypo_`. **Nenhuma consulta da carteira real lê essas tabelas**, e nenhuma escrita hipotética toca as tabelas reais. Um teste de arquitetura vai garantir que os repositórios reais não importam nada de `hypo_`.

### `hypo_portfolios`

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `name` | TEXT | |
| `description` | TEXT NULL | |
| `objective` | TEXT NULL | |
| `start_date` | TEXT | |
| `base_currency` | TEXT | |
| `initial_capital` | TEXT | Decimal |
| `composition_mode` | TEXT | `weight` ou `quantity` |
| `benchmark_json` | TEXT NULL | Ativos ou índices de comparação |
| `rebalance_json` | TEXT | Regra (nenhuma, periódica, banda) |
| `assumptions_json` | TEXT | Premissas (custos, proventos reinvestidos ou não, regra de execução) |
| `methodology` | TEXT NULL | |
| `archived_at` | TEXT NULL | |
| `duplicated_from_id` | TEXT NULL | |

### `hypo_holdings`

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `portfolio_id` | TEXT FK | |
| `asset_id` | TEXT FK | Referencia o catálogo `assets` |
| `weight_pct` | TEXT NULL | Decimal |
| `quantity` | TEXT NULL | Decimal |
| `amount` | TEXT NULL | Decimal |

### `hypo_cashflow_rules`

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `portfolio_id` | TEXT FK | |
| `kind` | TEXT | `contribution` ou `withdrawal` |
| `frequency` | TEXT | `monthly`, `quarterly`, `yearly`, `once` |
| `amount` | TEXT NULL | Decimal (valor fixo) |
| `pct` | TEXT NULL | Decimal (percentual do patrimônio) |
| `adjustment` | TEXT | `none`, `ipca`, `fixed_rate` |
| `start_date` / `end_date` | TEXT | `end_date` nulo = sem fim |

### `hypo_scenarios`

Cenários de projeção (pessimista, base, otimista e personalizados).

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `portfolio_id` | TEXT FK NULL | Nulo para cenários dos simuladores |
| `name` | TEXT | |
| `kind` | TEXT | `pessimistic`, `base`, `optimistic`, `custom` |
| `assumptions_json` | TEXT | Retornos hipotéticos, inflação, câmbio, custos |

### `hypo_runs`

Cada execução de backtest, projeção ou simulador, com tudo o que é preciso para reproduzi-la (SPEC §13.10).

| Campo | Tipo | Observação |
|---|---|---|
| [sync] | | |
| `portfolio_id` | TEXT FK NULL | Nulo para simuladores avulsos |
| `kind` | TEXT | `backtest`, `projection`, `compound_interest`, `retirement`, `goal`, `comparator` |
| `label` | TEXT NULL | |
| `params_json` | TEXT | Parâmetros completos, incluindo a regra de execução |
| `data_fingerprint_json` | TEXT | Fontes, datas de referência e de coleta dos dados usados |
| `app_version` | TEXT | |
| `engine_version` | TEXT | Versão do motor de cálculo |
| `summary_json` | TEXT | Resultados resumidos |
| `series_json` | TEXT NULL | Série do patrimônio (compactável), guardada para exibição offline. É recalculável a partir de `params_json` e dos dados de mercado, por isso **não vai no save** por padrão; a exportação só a inclui se o usuário marcar a opção (desmarcada por padrão). Na importação, a série ausente é recalculada sob demanda. |
| `warnings_json` | TEXT | Lacunas, eventos suspeitos, limitações |

## 6. Dados de mercado (`mkt_`, não sincronizáveis por HLC)

Não são dados do usuário: vêm dos provedores. Usam **chave natural** em vez de UUID, e a mesclagem com a pasta `market/` do save é por união: para a mesma chave, vale o registro com `collected_at` mais recente.

Todo registro guarda `source`, `ref_date` (ou `ref_at`), `collected_at` e `data_type` (`close`, `intraday`, `adjusted`, `estimated`, `calculated`), conforme a regra inviolável 2.

| Tabela | Chave | Campos |
|---|---|---|
| `mkt_prices` | (`symbol`, `market`, `ref_date`, `source`, `data_type`) | `open`, `high`, `low`, `close`, `volume`, `currency`, `quote_factor`, `collected_at` |
| `mkt_quotes` | (`symbol`, `market`, `source`) | Última cotação: `price`, `currency`, `ref_at`, `delay_note`, `data_type`, `collected_at` |
| `mkt_corporate_events` | (`symbol`, `market`, `event_kind`, `ex_date`, `source`, `seq`) | `com_date`, `payment_date`, `factor`, `amount`, `currency`, `status` (`paid`, `announced`, `suspect`), `raw_label`, `isin`, `collected_at` |
| `mkt_indicators` | (`series_code`, `ref_date`, `source`) | `value`, `unit` (`pct_day`, `pct_month`, `pct_year`, `index`), `collected_at` |
| `mkt_fx_rates` | (`base`, `quote`, `ref_date`, `kind`, `source`) | `bid`, `ask`, `ref_at`, `collected_at` (`kind`: `ptax_close`, `reference`) |
| `mkt_treasury_prices` | (`title`, `maturity_date`, `ref_date`, `source`) | `buy_rate`, `sell_rate`, `buy_pu`, `sell_pu`, `base_pu`, `collected_at` |
| `mkt_fund_quotas` | (`cnpj`, `ref_date`, `kind`, `source`) | `quota`, `nav`, `holders`, `isin`, `name`, `collected_at` (`kind`: informe mensal de FII ou cota diária) |
| `mkt_instruments` | (`symbol`, `market`, `source`) | `isin`, `name`, `source_id` (identificador no provedor), `collected_at` |

Todas as colunas são texto (decimais exatos, regra 6). O calendário de feriados da base 252 fica no código (`BusinessCalendar`), não numa tabela. O estado de cada provedor neste PC (ligado ou desligado, último sucesso e erro, uso da cota do mês) fica em `dev_provider_state` (§7), que nunca vai no save. As chaves de API ficam fora do banco (DECISIONS D-34).

Valores ajustados por proventos e eventos são **calculados** pelo app a partir dos preços brutos e de eventos confirmados, e gravados com `data_type = 'calculated'` e `source = 'patrion'`. Eles podem ser apagados e recalculados a qualquer momento.

## 7. Dispositivo, sincronização e derivados (não sincronizáveis)

### Dispositivo (`dev_`) — nunca vão no save

| Tabela | Campos | Para quê |
|---|---|---|
| `dev_identity` | `device_id`, `device_name`, `created_at`, `last_hlc` | Uma linha só. Identidade deste PC e último HLC emitido. |
| `dev_settings` | `key`, `value_json`, `updated_at` | Configurações do dispositivo: intervalo de atualização, tamanho da janela, tema, tempo de inatividade do bloqueio (`lock.idle_minutes`), última pasta usada, provedores ligados |
| `dev_sync_peers` | `peer_device_id`, `peer_name`, `last_hlc_received` (maior HLC do último save importado do parceiro), `last_hlc_sent` (maior HLC deste PC que o parceiro confirmou ter recebido, vindo do manifesto dele), `last_sync_at` | Base para detectar conflitos (SPEC §10.4, D-29) e avisar sincronização antiga |
| `dev_sync_history` | `id`, `direction` (`export`/`import`), `peer_device_id`, `peer_name`, `file_name`, `at`, `max_hlc`, `counts_json` (só contagens), `result` (`ok`/`failed`), `message` | Histórico de sincronizações |
| `dev_backups` | `id`, `path`, `at`, `reason`, `schema_version`, `app_version`, `size`, `sha256`, `encryption` (`none` ou `sqlcipher-4`, D-24 e D-32; o `keyId` fica no `.json` do backup) | Backups e retenção (`BACKUP.md`) |
| `dev_provider_state` | `provider`, `enabled`, `last_success_at`, `last_error_at`, `last_error`, `quota_used`, `quota_period` | Controle de limites e estado dos provedores |

Chaves de API **não ficam no banco**: ficam no Gerenciador de Credenciais do Windows (DECISIONS D-11).

### Derivados (`drv_`) — recalculados, nunca vão no save

| Tabela | Conteúdo |
|---|---|
| `drv_positions` | Posição por conta e ativo: quantidade, custo total, preço médio, lucro realizado |
| `drv_position_history` | Posição e valor por dia (base da evolução patrimonial) |
| `drv_portfolio_daily` | Patrimônio, aportes e retorno diário da carteira real |

Podem ser apagadas a qualquer momento. São recalculadas a partir da operação mais antiga afetada por uma alteração (SPEC §7) e depois de cada importação de save.

## 8. Separação entre real e hipotético

- Tabelas reais e hipotéticas são distintas (`operations` versus `hypo_*`).
- O catálogo `assets` e os dados `mkt_` são compartilhados, porque descrevem instrumentos e mercado, não posições.
- Os derivados (`drv_`) só são calculados a partir das tabelas reais. Resultados hipotéticos ficam em `hypo_runs`.
- O dashboard real só lê `drv_` e as tabelas reais.
- Testes obrigatórios (F9): criar e executar uma carteira hipotética não altera nenhuma linha das tabelas reais nem dos `drv_`.

## 9. Migrações

- `schemaVersion` do Drift começa em 1 na F2 e sobe a cada mudança.
- Cada versão tem migração passo a passo e um snapshot do schema gerado pelo `drift_dev` (`drift_schemas/`), usado em testes de migração.
- Antes de migrar, o app faz um backup automático (SPEC §11, DECISIONS D-19): antes de abrir o banco, lê o `user_version`; se for antigo, grava uma cópia com `VACUUM INTO` em `backups\`, confere a integridade e só então deixa o Drift migrar. Sem backup válido, o banco não é aberto. Banco de versão mais nova que a do app é recusado. Ficam os 10 backups de migração mais recentes.
- O save registra `schema_version`. Saves mais antigos são convertidos na importação; mais novos são recusados.
- Mudanças incompatíveis no schema só com aprovação do usuário (CLAUDE.md).

## Banco criptografado (F5B)

Com o bloqueio do app ativo, o mesmo schema fica num arquivo criptografado pelo SQLCipher 4 (chave bruta de 256 bits, `PRAGMA key`). As chaves ficam fora do banco, em `patrion.keys.json` ao lado dele (e, com o Windows Hello, em `patrion.hello.bin`). Nada no schema muda: migrações, backups e o save funcionam igual. Detalhes em `BLOQUEIO.md`.
