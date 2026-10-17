# Progresso

Atualizado pelo Claude ao final de cada fase ou sessão.

## Fase atual

**Fase 2 concluída** em 17/10/2026. Próxima: Fase 3 (Carteira real).

## Concluído

### Fase 2 — Fundação

Critério de pronto atendido: CI verde ([run 39059157741](https://github.com/LuccaBueno/patrion/actions/runs/39059157741), commit `c3bce2d`) e testes de HLC e dos repositórios passando.

**1. O que foi implementado**

- Camadas `core/`, `domain/`, `application/`, `data/`, `infrastructure/` e `presentation/`, com teste automático das regras de dependência e da proibição de `double` fora de `presentation/` (`test/architecture_test.dart`).
- Drift com migrações: `AppDatabase` (schema versão 1: `dev_identity`, `dev_settings`, `shared_settings`), snapshot em `drift_schemas/`, auxiliares de teste gerados e teste que compara o schema do código com o snapshot. Conversor de `Decimal` para `TEXT` canônico (D-03).
- Infraestrutura de sincronização: UUID v7, HLC (`core/sync/hlc.dart`), `device_id` criado na primeira execução, último HLC persistido em `dev_identity`, mixin `SyncColumns` e `SyncRepository` (insert, update, tombstone, consultas que ignoram excluídos, todas em transação). Repositório concreto: `SharedSettingsRepository`, com chave natural aplicada pelo app.
- Pastas (D-05) com `--data-dir` e `--cache-dir`; logs rotativos (D-16); erros por tipo (rede, dados, cálculo, interno); captura de erros não tratados; tela de erro de inicialização.
- Navegação lateral (`go_router`), temas claro e escuro (D-13), preferência de tema por dispositivo, telas Início (placeholder até a F3) e Configurações (tema, pastas, identificador do dispositivo, versão). Janela com tamanho mínimo 960 × 640.
- Ícone `.ico` (16 a 256 px) e PNG do símbolo gerados por `tool/gen_app_icon.dart` a partir do SVG (D-17).
- CI no GitHub Actions (`windows-latest`, Flutter 3.47.7, `contents: read`): código gerado atualizado, formatação, análise, testes e build.
- D-05 complementada: o COTAHIST bruto é apagado do cache depois da extração (pedido do usuário). Novas decisões D-13 a D-17.

**2. Arquivos criados ou alterados**

- `lib/`: `main.dart`; `core/` (config, ids, sync/hlc, time, errors); `domain/settings/`; `application/settings/`; `data/` (db, sync, repositories); `infrastructure/` (logging, system); `presentation/` (app, providers, router, shell, screens, theme).
- `test/`: core, data (inclui migrations/generated), application, infrastructure, presentation, `architecture_test.dart`, `helpers/test_database.dart`. Removido `test/widget_test.dart`.
- Raiz: `pubspec.yaml`/`.lock`, `build.yaml`, `analysis_options.yaml`, `drift_schemas/`, `tool/gen_app_icon.dart`, `.github/workflows/ci.yml`, `windows/runner/resources/app_icon.ico`, `assets/branding/patrion-simbolo-256.png`, `README.md`, `CHANGELOG.md`, `CLAUDE.md` (comandos).
- Docs: `ARQUITETURA.md`, `SINCRONIZACAO.md`, `DESENVOLVIMENTO.md` (novos); `DECISIONS.md`, `BANCO.md`, `PROGRESS.md` (alterados).

**3. Testes executados (17/10/2026)**

- Local: `dart run build_runner build` sem diferenças no código versionado; `dart format --set-exit-if-changed .`: 47 arquivos, 0 alterados; `flutter analyze`: "No issues found!"; `flutter test`: 70 testes, todos passaram; `flutter build windows --release`: compilou `patrion.exe`.
- Execução real do `.exe` com `--data-dir` temporário: janela "Patrion" abriu e respondeu, criou `patrion.db`, `backups\`, `logs\` e o cache; o log registrou início e "Banco aberto (schema 1)"; fechou com código 0. Conferi por captura de tela a tela inicial (tema claro, navegação lateral, símbolo e ícone na barra de título).
- `.ico` lido pelo Windows (System.Drawing) em 16, 24, 32 e 48 px e conferido visualmente.
- CI: todos os passos com sucesso (run 39059157741).

**4. Problemas e limitações**

- O build Windows exige o **Modo de Desenvolvedor** ligado (links simbólicos dos plugins). Documentado em `DESENVOLVIMENTO.md` e no README.
- Testes de widget com Drift precisam desmontar o app ao final (senão o fechamento do banco trava a execução). Resolvido com `withApp` e documentado.
- `build_runner` fica em 2.16.2 por limite do `drift_dev` (D-14).
- O tema escuro foi conferido só pelos testes de widget, não por captura de tela.
- O backup automático antes de migrações (SPEC §11) ainda não existe; só será necessário quando surgir o schema 2, e entra com o backup na F5 (ou antes, na F3, se a F3 criar a versão 2 do schema).

**5. Pendências**

- Da F1: confirmar Finnhub e Twelve Data (F6); licenças do CKAN do Tesouro e do portal da CVM (F6); toolchain Android (futuro).
- Backup antes de migração: implementar junto com a primeira migração real (schema 2, provavelmente na F3).

**6. Como executar e o que testar manualmente**

```powershell
flutter run -d windows
# ou
build\windows\x64\runner\Release\patrion.exe
```

Conferir:

- O ícone novo aparece na barra de título e na barra de tarefas.
- A navegação lateral alterna entre Início e Configurações; com a janela estreita (< 1100 px) os rótulos ficam abaixo dos ícones.
- Em Configurações, trocar o tema (Seguir o Windows / Claro / Escuro), fechar e reabrir o app: o tema escolhido continua.
- Em Configurações, as pastas mostradas existem (`%APPDATA%\Patrion`, `%LOCALAPPDATA%\Patrion\cache`) e há um `patrion.log` em `logs\`.
- Rodar com `patrion.exe --data-dir D:\PatrionB`: o app usa a outra pasta e mostra outro identificador de dispositivo.

### Fase 1 — Ambiente e decisões

**1. O que foi implementado**

- Ambiente verificado: Flutter 3.47.7 / Dart 3.13.5, Visual Studio Build Tools 2022 (C++ e Windows SDK 10.0.26100), Git 2.55, GitHub CLI autenticado, Inno Setup 6 (instalação por usuário em `%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe`, fora do PATH).
- Pesquisa das fontes de dados com testes reais (`docs/FONTES_DE_DADOS.md`).
- Decisões D-01 a D-12 aprovadas pelo usuário, com ajustes em D-03, D-05, D-07 e D-08 (`docs/DECISIONS.md`).
- Modelo de dados aprovado (`docs/BANCO.md`).
- Regra 6 do `CLAUDE.md` atualizada (exceção de `double` só para gráficos em `presentation/`).
- Projeto Flutter só para Windows (org `io.github.luccabueno`), app vazio com nome e subtítulo, título da janela e recursos do executável como "Patrion".
- `.gitignore` com bancos, saves, backups, segredos e cache; repositório Git local na branch `main`.
- README e CHANGELOG.
- Proposta de símbolo vetorial (`assets/branding/patrion-simbolo.svg`).

**2. Arquivos criados ou alterados**

- Docs: `docs/FONTES_DE_DADOS.md`, `docs/BANCO.md` (novos); `docs/DECISIONS.md`, `docs/PROGRESS.md`, `CLAUDE.md` (alterados).
- Projeto: `pubspec.yaml`, `analysis_options.yaml` (lints mais rígidos), `lib/main.dart`, `test/widget_test.dart`, `windows/` (gerado; `main.cpp` e `Runner.rc` ajustados), `.gitignore`, `README.md`, `CHANGELOG.md`.

**3. Testes executados (17/10/2026)**

- `dart format .`: 2 arquivos, 0 alterados.
- `flutter analyze`: "No issues found!".
- `flutter test`: 1 teste, todos passaram.
- `flutter build windows --release`: compilou `build\windows\x64\runner\Release\patrion.exe`.
- Execução do `.exe`: a janela "Patrion" abriu e respondeu; fechou com código 0. A conferência visual da tela não foi feita por mim.

**4. Problemas e limitações**

- Listas de eventos corporativos da B3 e da brapi estão incompletas (ver `FONTES_DE_DADOS.md` §1).
- Limites do Finnhub e cobertura do Twelve Data não confirmados em fonte oficial.
- Endpoints de proventos do site da B3 não são API documentada.
- O ícone do executável ainda é o padrão do Flutter (o `.ico` será gerado a partir do símbolo na F2/F7).

**5. Pendências**

- Confirmar Finnhub e Twelve Data com chaves reais (Fase 6).
- Conferir licenças do CKAN do Tesouro e do portal da CVM (Fase 6).
- Toolchain Android incompleta (`cmdline-tools` e licenças); só importa no futuro.

**6. Como executar e o que testar manualmente**

```powershell
flutter run -d windows
```

ou abra `build\windows\x64\runner\Release\patrion.exe`. Conferir: a janela abre com o título "Patrion", fundo verde-escuro, "PATRION" em dourado e o subtítulo "Investimentos e Patrimônio".

## Pendências e problemas conhecidos

Ver as seções 4 e 5 das Fases 2 e 1 acima.

## Próximo passo

Fase 3 (Carteira real), conforme `docs/SPEC.md` §21.

## Histórico de sessões

| Data | Fase | Resumo |
|---|---|---|
| 2026-10-17 | F1 | Ambiente, fontes de dados, decisões e modelo de dados aprovados; projeto criado e primeiro build Windows |
| 2026-10-17 | F2 | Fundação: camadas, Drift, HLC e repositórios base, navegação, tema, logs, ícone e CI verde |
