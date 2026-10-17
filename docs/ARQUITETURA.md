# Arquitetura

Estado em 17/10/2026 (Fase 3). Este documento descreve o código que existe; o que ainda não foi feito aparece como "a partir da F*n*".

## Camadas

```
lib/
  core/            configuração, datas, ids, HLC, erros (Dart puro)
  domain/          entidades, regras e cálculos financeiros (Dart puro)
  application/     casos de uso
  data/            tabelas Drift, repositórios, contexto de sincronização
  infrastructure/  pastas do Windows, logs, janela; APIs externas (F6)
  presentation/    tema, navegação, telas e provedores do Riverpod
  main.dart        composição: monta tudo e chama runApp
test/              espelha lib/ (mais architecture_test.dart e helpers/)
tool/              scripts de desenvolvimento (gerar o ícone)
```

Regras de dependência (verificadas por `test/architecture_test.dart`):

| Camada | Pode importar | Não pode importar |
|---|---|---|
| `core/` | só pacotes Dart puros (`uuid`, `path`, `decimal`) | qualquer outra camada; Flutter, Drift, Dio |
| `domain/` | `core/` | `data/`, `application/`, `infrastructure/`, `presentation/`; Flutter, Drift, Dio |
| `application/` | `core/`, `domain/`, `data/` (repositórios) | `presentation/` |
| `data/` | `core/`, `domain/`, Drift | `presentation/` |
| `infrastructure/` | `core/`, pacotes de sistema | `presentation/` |
| `presentation/` | todas | — |

Outra verificação automática: fora de `presentation/`, nenhum arquivo usa `double` (regra 6, DECISIONS D-03).

## Inicialização (`lib/main.dart`)

1. Abre a janela (`window_manager`, tamanho mínimo 960 × 640).
2. Lê `--data-dir` e `--cache-dir` (`LaunchOptions`) e resolve as pastas (`AppPathsResolver`, DECISIONS D-05), criando-as se preciso.
3. Liga os logs rotativos (`setupLogging`, D-16) e os capturadores de erros não tratados.
4. Se o banco existente estiver num schema antigo, faz o backup anterior à migração (`PreMigrationBackup`, DECISIONS D-19); sem backup válido, para aqui.
5. Abre o banco (`AppDatabase.open`, em um isolate de fundo; o Drift migra se preciso) e carrega ou cria a identidade do dispositivo (`DeviceIdentityStore`).
6. Cria o `SyncContext` (HLC + `device_id`) e entrega banco, contexto e pastas à interface como provedores do Riverpod.
7. Se algo falhar, mostra a tela "O Patrion não conseguiu iniciar" com a mensagem e a pasta dos logs.

## Dados e sincronização

- Banco: `data/db/app_database.dart` (Drift, `schemaVersion` 2, passos de migração em `app_database.steps.dart`). Tabelas em `data/db/tables.dart`; detalhes em `BANCO.md`.
- Backup antes de migrar: `infrastructure/backup/pre_migration_backup.dart` (D-19).
- Campos de sincronização: mixin `SyncColumns`, presente em toda tabela sincronizável.
- Escritas sincronizáveis: só por subclasses de `SyncRepository` (`data/repositories/sync_repository.dart`), que preenchem `id`, `created_at`, `updated_at`, `hlc`, `device_id` e `deleted_at`. Não existe exclusão física.
- HLC e ids: `core/sync/hlc.dart` e `core/ids/id_generator.dart`. Funcionamento em `SINCRONIZACAO.md`.

## Carteira real (Fase 3)

Fluxo de uma alteração: tela → serviço (`application/portfolio/`) → repositório (`data/repositories/`) → banco. A leitura volta pelo `PortfolioQuery`, que observa as tabelas e recalcula o retrato a cada mudança.

| Camada | Arquivos | Papel |
|---|---|---|
| `core/` | `money/decimal_math.dart`, `time/local_date.dart` | Divisão com 20 casas meio para o par; data de calendário |
| `domain/portfolio/` | `entities.dart`, `codes.dart`, `operation_type.dart` | Instituição, conta, ativo, renda fixa, operação, preço informado e enumerações com códigos estáveis |
| | `operation_validator.dart` | Preenchimento obrigatório de cada tipo de operação |
| | `portfolio_calculator.dart` | Posições, caixa e inconsistências a partir das operações (`FORMULAS.md` §1) |
| | `portfolio_valuation.dart`, `portfolio_summary.dart` | Valor de mercado pelos preços informados e totais do dashboard (`FORMULAS.md` §2 e §3) |
| `data/repositories/` | `institution_repository.dart`, `asset_repository.dart`, `operation_repository.dart`, `manual_valuation_repository.dart`, `portfolio_repositories.dart` | Conversão entre linhas e entidades; todos herdam de `SyncRepository` |
| `application/portfolio/` | `registry_service.dart` | Cadastros: chaves naturais e exclusão só de cadastros sem uso |
| | `operation_service.dart` | Grava operações: validação, duplicatas, consistência e transferências em par |
| | `valuation_service.dart` | Preço unitário e saldo informados |
| | `portfolio_query.dart` | `PortfolioSnapshot`: cadastros, operações, posições e resumo, recalculados a cada alteração |

Posições e totais não são gravados (D-20).

## Interface

- `presentation/app.dart`: `MaterialApp.router`, pt-BR, temas claro e escuro (D-18).
- `presentation/router/app_router.dart`: rotas e itens da navegação lateral. Uma tela nova entra na lista `navDestinations` e ganha uma rota.
- `presentation/providers.dart`: provedores do Riverpod. Banco, contexto de sincronização e ambiente são sobrescritos em `main.dart` (e nos testes, com banco em memória).
- Telas atuais (`presentation/screens/`): Início (dashboard), Carteira, Detalhe do ativo (`/carteira/ativo/:id`), Operações, Cadastros (instituições, contas e ativos) e Configurações.
- `presentation/format/`: formatação e leitura de números e datas em pt-BR direto do `Decimal` (D-23) e rótulos em português das enumerações.
- `presentation/widgets/common.dart`: estrutura de página, estados de carregamento e erro, "indisponível", ganho/perda com cor, sinal e ícone, campos de número e data, diálogos de formulário.

## Erros e logs

- Tipos de erro (`core/errors/app_error.dart`): `NetworkError`, `DataError`, `CalculationError`, `InternalError` (SPEC §18).
- Logs: `infrastructure/logging/rotating_file_log.dart` (D-16). Pasta: `%APPDATA%\Patrion\logs\`.
