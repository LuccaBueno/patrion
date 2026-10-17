# Progresso

Atualizado pelo Claude ao final de cada fase ou sessão.

## Fase atual

**Fase 3 concluída** em 17/10/2026. Próxima: Fase 4 (Motor financeiro).

## Concluído

### Fase 3 — Carteira real

Critério de pronto atendido: os dados persistem depois de reiniciar o app. Isso foi verificado por teste automático (banco em arquivo fechado e reaberto) e no executável real (dados gravados, app fechado e reaberto, mesmos valores na tela). CI verde ([run 39064585361](https://github.com/LuccaBueno/patrion/actions/runs/39064585361), commit `f99c5f2`, 175 testes).

**1. O que foi implementado**

- **Schema 2** com `institutions`, `accounts`, `assets`, `fixed_income_terms`, `operations` e `manual_valuations`, todas sincronizáveis (campos de sync, índice em `hlc`, chaves estrangeiras). A migração 1 → 2 é passo a passo (`stepByStep`), com snapshot e teste de preservação de dados.
- **Backup automático antes de qualquer migração** (pendência da F2, SPEC §11, D-19): antes de abrir o banco, o app lê o `user_version`. Se ele for antigo, grava uma cópia com `VACUUM INTO` em `backups\`, confere integridade e versão e só então migra. Se o backup falhar, o banco não é aberto. Um banco de versão mais nova é recusado. Ficam os 10 backups de migração mais recentes.
- **Cadastros** (`RegistryService`): instituições, contas (com arquivamento) e ativos de todas as classes da SPEC §6, com as características de renda fixa. As chaves naturais são aplicadas pelo app. Exclusão só de cadastros sem uso, sempre lógica.
- **Todos os tipos de operação de §7** (`OperationService`): validação por tipo, moeda igual à do ativo e aviso de duplicata com confirmação. Também recusa alterações que criem inconsistência (venda maior que a posição, inclusive ao editar ou excluir uma operação antiga). Transferências entre contas (dinheiro ou custódia) são gravadas em par. O ajuste manual exige justificativa (D-21).
- **Preço informado manualmente** (`ValuationService`): preço unitário (vale para todas as contas) ou saldo por conta, sempre com a data de referência. Sem preço, o valor fica "indisponível" e o patrimônio aparece como parcial (D-22).
- **Posições** (`PortfolioCalculator`, Dart puro): quantidade, custo, preço médio com custos, lucro realizado, proventos bruto e líquido e caixa por conta. Tudo é recalculado a partir de todas as operações a cada alteração, então editar uma operação antiga recalcula as seguintes (D-20, `FORMULAS.md`). Os casos de `CASOS_DE_TESTE.md` §1 passam.
- **Telas:**
  - Início (dashboard inicial): patrimônio, valor investido, valor de mercado, caixa, resultado não realizado e realizado, proventos, alocação por classe e por instituição, maiores posições e vencimentos em 90 dias. Os totais são separados por moeda, há avisos de caixa negativo e de inconsistências, e a data dos preços aparece no topo.
  - Carteira: posições em tabela ordenável, com busca e opção de mostrar as encerradas.
  - Detalhe do ativo: posição por conta, características do título, preços informados e operações.
  - Operações: busca, filtro por conta e grupo, ordenação, criação, edição e exclusão; formulário que se adapta ao tipo.
  - Cadastros.
- Formatação e leitura de números pt-BR direto do `Decimal` (D-23). Cabeçalho das telas se ajusta a janelas estreitas.
- Decisões D-19 a D-23 registradas; `FORMULAS.md` criado; `BANCO.md`, `ARQUITETURA.md`, `DESENVOLVIMENTO.md`, README e CHANGELOG atualizados.

**2. Arquivos criados ou alterados**

- `lib/core/`: `money/decimal_math.dart`, `time/local_date.dart` (novos).
- `lib/domain/portfolio/`: `codes.dart`, `entities.dart`, `operation_type.dart`, `operation_validator.dart`, `portfolio_calculator.dart`, `portfolio_valuation.dart`, `portfolio_summary.dart` (novos).
- `lib/data/`: `db/tables.dart`, `db/app_database.dart` (+ `.g.dart`, `app_database.steps.dart` gerado); `repositories/` `institution_repository.dart`, `asset_repository.dart`, `operation_repository.dart`, `manual_valuation_repository.dart`, `portfolio_repositories.dart` (novos).
- `lib/application/portfolio/`: `registry_service.dart`, `operation_service.dart`, `valuation_service.dart`, `portfolio_query.dart` (novos).
- `lib/infrastructure/backup/pre_migration_backup.dart` (novo); `lib/main.dart` (chama o backup antes de abrir o banco).
- `lib/presentation/`: `format/` (formatação e rótulos), `widgets/common.dart`, `screens/dashboard/`, `screens/portfolio/` (carteira e detalhe), `screens/operations/` (tabela e diálogos), `screens/registry/`, `router/app_router.dart`, `providers.dart`. Removido `screens/home_screen.dart`.
- `drift_schemas/patrion/drift_schema_v2.json`; `test/data/db/migrations/patrion/` (`migration_test.dart`, `generated/schema_v2.dart`).
- `test/`: `core/money/`, `core/time/local_date_test.dart`, `domain/portfolio/` (3 arquivos), `application/portfolio/portfolio_services_test.dart`, `infrastructure/backup/pre_migration_backup_test.dart`, `presentation/format/formatters_test.dart`, `presentation/portfolio_screens_test.dart`, `helpers/app_harness.dart`, `helpers/portfolio_fixture.dart`; `data/db/database_test.dart` (tabelas novas).
- Docs: `FORMULAS.md` (novo); `DECISIONS.md`, `BANCO.md`, `ARQUITETURA.md`, `DESENVOLVIMENTO.md`, `PROGRESS.md`, `README.md`, `CHANGELOG.md`.

**3. Testes executados (17/10/2026)**

- `dart run build_runner build`: sem diferenças no código versionado.
- `dart format --set-exit-if-changed .`: 90 arquivos, 0 alterados.
- `flutter analyze`: "No issues found!".
- `flutter test`: **175 testes, todos passaram** (70 na F2). Entre os novos:
  - casos de `CASOS_DE_TESTE.md` §1, inclusive a edição da operação 1;
  - todos os tipos de operação;
  - migração 1 → 2 com dados;
  - backup antes da migração: banco novo, banco já atual, backup íntegro, falha que impede a migração, banco mais novo recusado e retenção;
  - persistência ao fechar e reabrir;
  - telas, nos temas claro e escuro, em janela de 960 × 640.
- `flutter build windows --release`: compilou `patrion.exe`.
- **Execução real do `.exe`** com `--data-dir` temporário:
  - Banco no **schema 1**, como o de um usuário da F2, com tema escuro gravado. O app criou `backups\patrion_2026-10-17_19-43-12-749Z_pre-migracao_v1-v2_app-0.1.0.db`, migrou ("Banco aberto (schema 2)" no log) e manteve o tema escuro.
  - Depois gravei uma carteira de exemplo nesse banco, fechei e reabri o app. Nenhum backup novo (o banco já estava no schema 2), e as telas mostraram os mesmos dados, conferidos por captura de tela: dashboard (lucro realizado R$ 470,40, proventos R$ 45,00, caixa R$ 12.630,00), Carteira, Operações, formulário de nova operação e Detalhe do ativo.
  - O fechamento pela janela encerrou o processo.

**4. Problemas e limitações**

- Encontrado na execução real: os ícones novos da navegação apareciam vazios porque o build incremental reaproveitou a fonte de ícones reduzida da F2. Resolvido com `flutter clean`; documentado em `DESENVOLVIMENTO.md` (o CI sempre parte do zero).
- No `.exe` real, conferi as telas com dados e a abertura do formulário. Criar uma operação pela interface foi testado só nos testes de widget, não no executável.
- Sem câmbio até a F6: cada moeda tem seus totais, sem conversão para BRL.
- Retorno mostrado é o simples sobre o custo, rotulado como tal. Rentabilidade por período, TWR, MWR, evolução patrimonial e benchmarks ficam para a F4 e a F6, e o dashboard avisa isso.
- O caixa é calculado de todas as operações. Quem não registra depósitos vê caixa negativo, com um aviso explicando o porquê.
- O backup antes da migração ainda não é registrado em `dev_backups` (sem SHA-256). Isso entra na F5, com backup manual e restauração.
- Na mesma data, operações criadas no mesmo milissegundo não têm ordem garantida (UUID v7). Só faz diferença para as pontas de transferência, que são tratadas à parte.

**5. Pendências**

- F5: registrar backups em `dev_backups`, backup manual, restauração e procedimento de recuperação (SPEC §11).
- F5: deixar backup, restauração e o manifesto do save preparados para o bloqueio do app (DECISIONS D-24, itens 1 a 6).
- F5B (v1.x, registrada na SPEC §3 e §21): bloqueio do app com SQLCipher, senha, Windows Hello, bloqueio por inatividade e chave de recuperação. Não implementada.
- Da F1: confirmar Finnhub e Twelve Data (F6); licenças do CKAN do Tesouro e do portal da CVM (F6); toolchain Android (futuro).

**6. Como executar e o que testar manualmente**

```powershell
flutter run -d windows
# ou
build\windows\x64\runner\Release\patrion.exe
```

Na primeira abertura com o banco da F2, confira `%APPDATA%\Patrion\backups\`: deve haver um `patrion_..._pre-migracao_v1-v2_app-0.1.0.db`. O tema escolhido antes continua.

Roteiro sugerido:

1. **Cadastros:**
   - Crie uma instituição e uma conta.
   - Crie um ativo (ex.: PETR4, Ações BR, B3) e um título de renda fixa (classe Renda fixa, com taxa, emissão e vencimento).
   - Tente criar a mesma instituição de novo: deve aparecer um aviso.
2. **Operações:** registre o caso de `CASOS_DE_TESTE.md` §1:
   - compra de 100 × 30,00 com 5,00 de custos;
   - compra de 50 × 36,00 com 4,00;
   - venda de 60 × 40,00 com 6,00;
   - dividendo de 90 × 0,50;
   - desdobramento de 1 para 2.
   - Em Carteira, confira 180 ações a R$ 16,03; no detalhe, lucro realizado de R$ 470,40 e proventos de R$ 45,00.
3. Edite a primeira compra para 200 ações e veja tudo ser recalculado. Tente vender mais do que tem: deve ser recusado.
4. Grave uma operação igual a outra: deve aparecer "Possível duplicata".
5. **Preço:** no detalhe do ativo, use "Informar preço". O valor de mercado e o resultado aparecem com a data. Sem preço, aparece "indisponível".
6. Registre um depósito e veja o caixa. Faça uma transferência entre duas contas, de dinheiro e de ativo.
7. **Persistência:** feche e reabra o app; tudo continua lá.
8. Repita algumas telas no tema claro e com a janela no tamanho mínimo.

### Fase 2 — Fundação

Critério de pronto atendido: CI verde ([run 39059157741](https://github.com/LuccaBueno/patrion/actions/runs/39059157741), commit `c3bce2d`) e testes de HLC e dos repositórios passando.

**1. O que foi implementado**

- Camadas `core/`, `domain/`, `application/`, `data/`, `infrastructure/` e `presentation/`, com teste automático das regras de dependência e da proibição de `double` fora de `presentation/` (`test/architecture_test.dart`).
- Drift com migrações: `AppDatabase` (schema versão 1: `dev_identity`, `dev_settings`, `shared_settings`), snapshot em `drift_schemas/`, auxiliares de teste gerados e teste que compara o schema do código com o snapshot. Conversor de `Decimal` para `TEXT` canônico (D-03).
- Infraestrutura de sincronização: UUID v7, HLC (`core/sync/hlc.dart`), `device_id` criado na primeira execução, último HLC persistido em `dev_identity`, mixin `SyncColumns` e `SyncRepository` (insert, update, tombstone, consultas que ignoram excluídos, todas em transação). Repositório concreto: `SharedSettingsRepository`, com chave natural aplicada pelo app.
- Pastas (D-05) com `--data-dir` e `--cache-dir`; logs rotativos (D-16); erros por tipo (rede, dados, cálculo, interno); captura de erros não tratados; tela de erro de inicialização.
- Navegação lateral (`go_router`), temas claro e escuro (D-18), preferência de tema por dispositivo, telas Início (placeholder até a F3) e Configurações (tema, pastas, identificador do dispositivo, versão). Janela com tamanho mínimo 960 × 640.
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
- O backup automático antes de migrações (SPEC §11) ainda não existe; só será necessário quando surgir o schema 2, e entra com o backup na F5 (ou antes, na F3, se a F3 criar a versão 2 do schema). **Resolvido na F3** (D-19).

**5. Pendências**

- Da F1: confirmar Finnhub e Twelve Data (F6); licenças do CKAN do Tesouro e do portal da CVM (F6); toolchain Android (futuro).
- Backup antes de migração: implementar junto com a primeira migração real (schema 2, provavelmente na F3). **Resolvido na F3.**

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

Ver as seções 4 e 5 das Fases 3, 2 e 1 acima.

## Próximo passo

Fase 4 (Motor financeiro), conforme `docs/SPEC.md` §21: §9 completo e `FORMULAS.md`, até todos os casos de `CASOS_DE_TESTE.md` passarem.

## Histórico de sessões

| Data | Fase | Resumo |
|---|---|---|
| 2026-10-17 | F1 | Ambiente, fontes de dados, decisões e modelo de dados aprovados; projeto criado e primeiro build Windows |
| 2026-10-17 | F2 | Fundação: camadas, Drift, HLC e repositórios base, navegação, tema, logs, ícone e CI verde |
| 2026-10-17 | F3 | Carteira real: schema 2 com backup automático antes de migrar, cadastros, todos os tipos de operação, preço manual, posições, dashboard inicial e telas de carteira, operações e cadastros |
