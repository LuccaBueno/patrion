# Arquitetura

Estado em 17/10/2026 (Fase 5). Este documento descreve o código que existe; o que ainda não foi feito aparece como "a partir da F*n*".

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
| `domain/` | `core/`; pacotes Dart puros (`archive` e `crypto` no formato do save) | `data/`, `application/`, `infrastructure/`, `presentation/`; Flutter, Drift, Dio |
| `application/` | `core/`, `domain/`, `data/` (repositórios) | `presentation/` |
| `data/` | `core/`, `domain/`, Drift | `presentation/` |
| `infrastructure/` | `core/`, `domain/` (modelos), `application/` (interfaces que implementa, ex.: `BackupFileSystem`), pacotes de sistema | `presentation/` |
| `presentation/` | todas | — |

Outras verificações automáticas: fora de `presentation/`, nenhum arquivo usa `double` (regra 6, DECISIONS D-03); a carteira real (`application/portfolio`, `domain/portfolio`, dashboard e carteira na interface) não menciona as tabelas hipotéticas (`BANCO.md` §8).

## Inicialização (`lib/main.dart`)

1. Abre a janela (`window_manager`, tamanho mínimo 960 × 640).
2. Lê `--data-dir` e `--cache-dir` (`LaunchOptions`) e resolve as pastas (`AppPathsResolver`, DECISIONS D-05), criando-as se preciso.
3. Liga os logs rotativos (`setupLogging`, D-16) e os capturadores de erros não tratados.
4. Cria o `SessionManager` (`presentation/session/app_session.dart`) e chama `start()`. Sem o bloqueio, abre a sessão na hora; com o bloqueio (banco criptografado e `patrion.keys.json`), mostra a tela de desbloqueio e só abre a sessão depois da senha, da chave de recuperação ou do Windows Hello (`BLOQUEIO.md`). A **sessão** (`openSession`) abre sempre na ordem:
   - (com o bloqueio) a chave do banco já liberada;
   - se o banco existente estiver num schema antigo, backup anterior à migração (`PreMigrationBackup`, D-19), criptografado com a mesma chave quando há bloqueio; sem backup válido, para aqui;
   - abre o banco (`AppDatabase.open`, em um isolate de fundo, com `PRAGMA key` quando há chave; o Drift migra se preciso);
   - carrega ou cria a identidade do dispositivo (`DeviceIdentityStore`) e cria o `SyncContext` (HLC + `device_id`);
   - registra em `dev_backups` o backup da migração, se houve.
5. `SessionHost` monta a interface sobre a sessão, com banco, contexto, pastas e chave como provedores do Riverpod, dentro do `InactivityGuard` (bloqueio por inatividade). Quando a sessão troca (restauração de backup, bloqueio, desbloqueio, ativação ou desativação do bloqueio), a árvore inteira é remontada do zero; bloqueado, só existe a tela de desbloqueio.
6. Se algo falhar, mostra a tela "O Patrion não conseguiu iniciar" com a mensagem e a pasta dos logs.

## Dados e sincronização

- Banco: `data/db/app_database.dart` (Drift, `schemaVersion` 3, passos de migração em `app_database.steps.dart`). Tabelas em `data/db/tables.dart`; detalhes em `BANCO.md`.
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

## Motor financeiro (Fase 4)

Funções puras em `domain/finance/` (Dart puro, sem `double`), com fórmulas em `FORMULAS.md` §4 a §10 e decisões em D-26 e D-27.

| Camada | Arquivos | Papel |
|---|---|---|
| `core/` | `money/decimal_math.dart` | Também `ln`, `exp` e `pow` com expoente fracionário, em ponto fixo (D-26) |
| | `time/local_date.dart` | Também soma de meses e dia da semana |
| `domain/finance/` | `business_calendar.dart` | Dias úteis com os feriados nacionais (base 252) |
| | `interest.dart` | Juros simples e compostos, equivalência de taxas, nominal e efetiva, bases de dias |
| | `index_accrual.dart` | CDI e Selic acumulados, percentual do indexador e spread |
| | `cash_flow.dart` | Fluxos de caixa e XIRR |
| | `returns.dart` | Retorno simples, acumulado, real, CAGR, anualização, TWR, retornos por dia, mês e ano, decomposição cambial e `ReturnMethod` |
| `domain/portfolio/` | `performance.dart` | Fluxos do investidor a partir das operações e MWR líquido, bruto e sem proventos, por ativo e por moeda |
| `application/portfolio/` | `portfolio_query.dart` | `PortfolioSnapshot.performance(moeda)` e `assetPerformance(id)`, calculados na primeira consulta |

Na interface, o dashboard mostra o resultado total e a TIR (MWR) da moeda, e o detalhe do ativo mostra resultado e TIR com e sem proventos e antes de custos, sempre com a metodologia num tooltip. TWR, retornos por período, retorno real, efeito cambial e benchmarks estão prontos no domínio e aparecem quando houver histórico de cotações, IPCA e câmbio (F6).

## Backup e save (Fase 5)

Detalhes em `SINCRONIZACAO.md` e `BACKUP.md`; decisões em D-28 a D-31.

| Camada | Arquivos | Papel |
|---|---|---|
| `domain/sync/` | `sync_rows.dart` | Linha sincronizável (coluna → texto), estrutura das tabelas e ordem de dependência |
| | `save_manifest.dart`, `invsave_codec.dart` | Manifesto e arquivo `.invsave` (ZIP, JSONL, SHA-256), com toda a validação |
| | `save_contents.dart` | Conversão de saves de schema antigo e validação das linhas |
| | `natural_keys.dart`, `merge_planner.dart` | Chaves naturais e plano da mesclagem (por id e HLC, conflitos, aliases, unificação, duplicatas), puro |
| `domain/backup/` | `backup_metadata.dart` | Motivos e metadados dos backups (com o campo de criptografia) |
| `data/sync/` | `sync_tables_gateway.dart` | Leitura genérica das tabelas sincronizáveis e gravação do plano numa transação |
| `data/repositories/` | `sync_peers_repository.dart`, `backup_registry_repository.dart` | `dev_sync_peers`, `dev_sync_history` e `dev_backups`; `VACUUM INTO` pela conexão do app |
| `application/sync/` | `save_service.dart` | Exportar, prévia, aplicar (backup antes, transação única, histórico) |
| `application/backup/` | `backup_service.dart`, `backup_ports.dart` | Backup manual e automático, retenção, registro e conferência antes de restaurar |
| `infrastructure/backup/` | `database_file_inspector.dart` | Único ponto que abre um arquivo de banco fechado (D-24) |
| | `local_backup_file_system.dart`, `pre_migration_backup.dart` | Arquivos de backup, metadados, retenção e troca do banco na restauração |
| `presentation/session/` | `app_session.dart`, `session_host.dart` | Sessão do banco que pode ser fechada e reaberta (restauração; F5B) |
| `presentation/screens/` | `sync/`, `backup/` | Telas Sincronização (com a prévia da importação) e Backup |
| `presentation/services/` | `file_dialogs.dart` | Diálogos de arquivo do Windows atrás de uma interface (D-31) |

## Bloqueio do app (Fase 5B)

Detalhes em `BLOQUEIO.md`; decisões em D-24, D-32 e D-33.

| Camada | Arquivos | Papel |
|---|---|---|
| `core/crypto/` | `crypto_box.dart`, `database_key.dart` | Argon2id, AES-256-GCM e números aleatórios (`pointycastle`); chave do banco que pode ser zerada |
| `domain/security/` | `key_file.dart`, `recovery_key.dart` | Arquivo de chaves (chave do banco embrulhada pela senha e pela chave de recuperação), chave de recuperação e regras da senha |
| `domain/sync/` | `invsave_codec.dart` (`protect`, `unprotect`) | Senha do arquivo de save |
| `application/security/` | `security_ports.dart` | Interfaces do Windows Hello e do cofre da chave para o Hello |
| `application/settings/` | `lock_preferences.dart` | Tempo de inatividade (configuração deste PC) |
| `infrastructure/security/` | `key_file_store.dart`, `database_encryption.dart` | Arquivo de chaves no disco; conversão do banco fechado entre aberto e criptografado, em dois tempos |
| | `windows_hello.dart`, `dpapi.dart` | Windows Hello (`local_auth`) e cópia da chave protegida pelo DPAPI (FFI) |
| `infrastructure/backup/` | `database_file_inspector.dart` | Abre arquivos de banco com chave e faz o `sqlcipher_export` (copiando o `user_version`) |
| `presentation/session/` | `app_session.dart`, `inactivity_guard.dart` | Fases da sessão (aberta, bloqueada, ocupada, falha), desbloqueio, ativar/desativar, inatividade |
| `presentation/screens/security/` | `unlock_screen.dart`, `lock_settings_section.dart`, `security_dialogs.dart` | Tela de desbloqueio, seção nas Configurações e diálogos (senha, chave de recuperação) |

## Interface

- `presentation/app.dart`: `MaterialApp.router`, pt-BR, temas claro e escuro (D-18).
- `presentation/router/app_router.dart`: rotas e itens da navegação lateral. Uma tela nova entra na lista `navDestinations` e ganha uma rota.
- `presentation/providers.dart`: provedores do Riverpod. Banco, contexto de sincronização, ambiente e controlador da sessão são sobrescritos pelo `SessionHost` (e nos testes, com banco em memória e diálogos de arquivo simulados).
- Telas atuais (`presentation/screens/`): Início (dashboard, com o aviso de sincronização antiga), Carteira, Detalhe do ativo (`/carteira/ativo/:id`), Operações, Cadastros (instituições, contas e ativos), Sincronização, Backup e Configurações.
- `presentation/format/`: formatação e leitura de números e datas em pt-BR direto do `Decimal` (D-23) e rótulos em português das enumerações.
- `presentation/widgets/common.dart`: estrutura de página, estados de carregamento e erro, "indisponível", ganho/perda com cor, sinal e ícone, campos de número e data, diálogos de formulário.

## Erros e logs

- Tipos de erro (`core/errors/app_error.dart`): `NetworkError`, `DataError`, `CalculationError`, `InternalError` (SPEC §18).
- Logs: `infrastructure/logging/rotating_file_log.dart` (D-16). Pasta: `%APPDATA%\Patrion\logs\`.
