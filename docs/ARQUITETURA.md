# Arquitetura

Estado em 17/10/2026 (Fase 2). Este documento descreve o código que existe; o que ainda não foi feito aparece como "a partir da F*n*".

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
| `core/` | só pacotes Dart puros (`uuid`, `path`) | qualquer outra camada; Flutter, Drift, Dio |
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
4. Abre o banco (`AppDatabase.open`, em um isolate de fundo) e carrega ou cria a identidade do dispositivo (`DeviceIdentityStore`).
5. Cria o `SyncContext` (HLC + `device_id`) e entrega banco, contexto e pastas à interface como provedores do Riverpod.
6. Se algo falhar, mostra a tela "O Patrion não conseguiu iniciar" com a mensagem e a pasta dos logs.

## Dados e sincronização

- Banco: `data/db/app_database.dart` (Drift, `schemaVersion` 1). Tabelas em `data/db/tables.dart`; detalhes em `BANCO.md`.
- Campos de sincronização: mixin `SyncColumns`, presente em toda tabela sincronizável.
- Escritas sincronizáveis: só por subclasses de `SyncRepository` (`data/repositories/sync_repository.dart`), que preenchem `id`, `created_at`, `updated_at`, `hlc`, `device_id` e `deleted_at`. Não existe exclusão física.
- HLC e ids: `core/sync/hlc.dart` e `core/ids/id_generator.dart`. Funcionamento em `SINCRONIZACAO.md`.

## Interface

- `presentation/app.dart`: `MaterialApp.router`, pt-BR, temas claro e escuro (D-18).
- `presentation/router/app_router.dart`: rotas e itens da navegação lateral. Uma tela nova entra na lista `navDestinations` e ganha uma rota.
- `presentation/providers.dart`: provedores do Riverpod. Banco, contexto de sincronização e ambiente são sobrescritos em `main.dart` (e nos testes, com banco em memória).
- Telas atuais: Início (placeholder até a F3) e Configurações (tema, pastas, identificador do dispositivo, versão).

## Erros e logs

- Tipos de erro (`core/errors/app_error.dart`): `NetworkError`, `DataError`, `CalculationError`, `InternalError` (SPEC §18).
- Logs: `infrastructure/logging/rotating_file_log.dart` (D-16). Pasta: `%APPDATA%\Patrion\logs\`.
