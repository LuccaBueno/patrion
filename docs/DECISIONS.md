# Decisões técnicas

Registro de decisões. Cada entrada traz a data, a decisão, as alternativas consideradas e o motivo. Nunca apague uma entrada: se uma decisão mudar, crie uma nova entrada e marque a antiga como "substituída".

## Decisões já tomadas pelo usuário

| Tema | Decisão |
|---|---|
| Plataforma v1 | Windows 10 e 11 x64 |
| Stack | Flutter, Drift (SQLite), Riverpod, Dio e tipo decimal |
| Sincronização | Arquivo `.invsave` com mesclagem (SPEC §10), sem servidor |
| Identidade dos registros | UUID v7 + HLC + tombstones |
| Instalador | Inno Setup 6 |
| Tributação na v1 | Só registro; o app não calcula IR nem gera DARF |
| Publicação | `push`, tags e Releases só com autorização |

## A decidir na Fase 1

Todas aprovadas pelo usuário em 17/10/2026, com os ajustes registrados em cada entrada.

| Tema | Situação |
|---|---|
| Versão do Flutter | Aprovada: 3.47.7 (D-01) |
| Pacotes de gráficos, PDF, XLSX, UUID e decimal | Aprovados (D-02 a D-04; XLSX adiado) |
| Pasta de dados e tipo de instalação | Aprovados com ajuste (D-05 e D-06) |
| Repositório público ou privado | Aprovado: público (D-07) |
| Fontes de dados | Aprovadas (D-08), detalhes em `FONTES_DE_DADOS.md` |
| Regra de execução no backtest | Aprovada (D-09) |

## Registro

### 2026-10-17 — D-01: Versão do Flutter (aprovada em 2026-10-17)

- Decisão: Flutter **3.47.7** (stable), Dart **3.13.5**. A mesma versão é fixada no CI (`subosito/flutter-action` com `flutter-version: 3.47.7`).
- Alternativas: acompanhar sempre o stable mais recente (builds não reprodutíveis).
- Motivo: é a versão instalada e o stable atual (lançada em 08/10/2026). Atualizações de versão viram uma entrada nova aqui.

### 2026-10-17 — D-02: Dependências (aprovada em 2026-10-17)

Versões consultadas no pub.dev em 17/10/2026. No `pubspec.yaml` elas entram com `^` (compatíveis na mesma versão maior) e o `pubspec.lock` é versionado, então o build é reprodutível. Todas declaram suporte a Windows e têm licença permissiva.

**Produção**

| Pacote | Versão | Licença | Uso |
|---|---|---|---|
| `drift` | 2.35.2 | MIT | ORM e migrações SQLite |
| `drift_flutter` | 0.3.1 | MIT | Abertura do banco no Flutter (não adotado, ver D-14) |
| `sqlite3` | 3.7.1 | MIT | SQLite nativo, embutido pelos build hooks do Dart |
| `flutter_riverpod` | 3.4.3 | MIT | Estado e injeção de dependências |
| `dio` | 5.11.1 | MIT | HTTP (adaptadores de dados de mercado) |
| `decimal` | 3.2.6 | Apache-2.0 | Valores monetários, quantidades e taxas |
| `uuid` | 4.6.0 | MIT | UUID v7 |
| `fl_chart` | 1.2.0 | MIT | Gráficos |
| `go_router` | 18.1.0 | BSD-3 | Navegação |
| `path_provider` | 2.1.6 | BSD-3 | Pastas do Windows |
| `path` | 1.9.1 | BSD-3 | Caminhos |
| `intl` | 0.20.3 | BSD-3 | Formatação pt-BR de números e datas |
| `logging` | 1.3.0 | BSD-3 | Logs (com gravador rotativo próprio) |
| `archive` | 4.5.2 | MIT | ZIP do `.invsave` e do COTAHIST |
| `crypto` | 3.0.7 | BSD-3 | SHA-256 dos arquivos do save |
| `file_picker` | 13.1.0 | MIT | Escolher destino de save e backup |
| `window_manager` | 0.5.2 | MIT | Tamanho mínimo e título da janela |
| `flutter_secure_storage` | 11.2.0 | BSD-3 | Chaves de API no Gerenciador de Credenciais do Windows |
| `package_info_plus` | 10.2.2 | BSD-3 | Versão do app (manifest do save, sobre) |
| `pub_semver` | 2.2.1 | BSD-3 | Comparação de versões (verificador de atualizações, F7) |
| `clock` | 1.1.3 | Apache-2.0 | Relógio injetável (testes de HLC e datas) |

Entram só quando a fase correspondente começar (registradas agora para aprovação):

| Pacote | Versão | Licença | Fase | Uso |
|---|---|---|---|---|
| `pdf` | 3.13.1 | Apache-2.0 | F13 | Relatórios PDF |
| `printing` | 5.15.1 | Apache-2.0 | F13 | Impressão e visualização do PDF |
| `csv` | 8.0.0 | MIT | F11 | Importação e exportação CSV |
| XLSX | — | — | F13 | Ver D-04 |

**Desenvolvimento**

| Pacote | Versão | Licença | Uso |
|---|---|---|---|
| `drift_dev` | 2.35.1 | MIT | Geração de código e verificação de migrações |
| `build_runner` | 2.17.1 | BSD-3 | Geração de código |
| `flutter_lints` | 6.0.0 | BSD-3 | Regras de análise (mais regras próprias em `analysis_options.yaml`) |
| `mocktail` | 1.0.5 | MIT | Dublês nos testes |

- Alternativas descartadas:
  - `sqlite3_flutter_libs`: marcado como fim de vida (`0.6.0+eol`); o `sqlite3` 3.x já embute a biblioteca nativa.
  - Gerador do Riverpod (`riverpod_generator`) e `freezed`: menos código manual, mas mais geração de código e builds mais lentos. Começamos sem eles; dá para adotar depois sem mudar a arquitetura.
  - Syncfusion (gráficos e XLSX): licença comercial (licença comunitária exige cadastro e tem condições de receita). Evitado.
  - `logger`: menos controle sobre o formato e a rotação; `logging` é do time do Dart.
  - `http_mock_adapter` e `dio_smart_retry`: sem manutenção desde 2023/2024. Retentativa e dublês do Dio serão implementados no próprio projeto.
- Motivo: manutenção ativa, licenças MIT/BSD/Apache, suporte a Windows e caminho aberto para Android e iOS (`window_manager` é só desktop e fica isolado em `infrastructure/`; o suporte móvel dos demais será conferido antes da versão móvel).

### 2026-10-17 — D-03: Dinheiro, quantidades e arredondamento (aprovada em 2026-10-17)

- Decisão:
  - Valores monetários, quantidades, preços, câmbio e taxas usam `Decimal`. `double` nunca é usado para esses valores.
  - No banco, decimais ficam em `TEXT` com a representação canônica (por exemplo, `"3005.00"` vira `"3005"`), por meio de um conversor do Drift. Nada de `REAL`.
  - Divisões internas: resultado com **20 casas decimais**, arredondamento **meio para o par** (half-even), para não acumular viés.
  - Exibição: **2 casas** para R$ e moedas, **meio para cima** (arredondamento comercial), que é o que o usuário confere à mão. Percentuais com 2 casas na tela e precisão total nos cálculos.
  - Potências com expoente fracionário, como (1,1065)^(21/252), e logaritmos usam funções próprias em `domain/` (série de Taylor para `exp` e `ln` com 30 casas), testadas contra os casos de `CASOS_DE_TESTE.md`.
  - **Exceção única (ajuste do usuário em 17/10/2026):** a conversão de `Decimal` para `double` é permitida **somente na camada de apresentação** (`presentation/`), para desenhar gráficos. Nunca em cálculos, em `domain/`, `application/`, `data/` ou `infrastructure/`, nem em persistência. Registrado também na regra 6 do `CLAUDE.md`.
- Alternativas: inteiros em centavos (não servem para quantidades fracionárias de cripto nem para PU de títulos); `double` (proibido pelo CLAUDE.md).
- Motivo: precisão, reprodutibilidade e regra inviolável 6. A documentação final fica em `FORMULAS.md` (F4).

### 2026-10-17 — D-04: XLSX (adiada, aprovada em 2026-10-17)

- Decisão: escolher na F13. Candidato hoje: `excel` 4.0.6 (MIT), mas a última versão é de 08/2024.
- Alternativas: Syncfusion XLSIO (licença comercial); gerar o XLSX à mão com `archive` (o formato é XML compactado).
- Motivo: não há necessidade antes da v2; reavaliar a manutenção na época.

### 2026-10-17 — D-05: Pasta de dados (aprovada em 2026-10-17)

- Decisão (com o ajuste do usuário em 17/10/2026): dados em `%APPDATA%\Patrion\` (pasta "Roaming") e cache em `%LOCALAPPDATA%\Patrion\cache\`:

  ```
  %APPDATA%\Patrion\
    patrion.db         banco SQLite
    backups\           backups automáticos e manuais
    logs\              logs rotativos
  %LOCALAPPDATA%\Patrion\
    cache\             arquivos baixados e descartáveis (COTAHIST, CSVs de provedores)
  ```

- O cache pode ser apagado a qualquer momento sem perda de dados: o que importa já foi gravado no banco.
- **Complemento (pedido do usuário em 17/10/2026):** os arquivos brutos do COTAHIST são **temporários**. Depois que os tickers de interesse forem extraídos e gravados no banco (`mkt_prices`), o arquivo baixado (ZIP e TXT) é **apagado do cache**. Se o mesmo ano for necessário de novo (outro ticker, por exemplo), ele é baixado outra vez. Implementação na F6.
- O COTAHIST é baixado **sob demanda**, só os anos necessários (para os ativos e o período pedidos), a partir de um **ano inicial configurável** nas configurações do dispositivo. Depois de processado, o app guarda só os tickers de interesse no banco.
- O caminho dos dados pode ser trocado pelo argumento `--data-dir <pasta>` (e o do cache por `--cache-dir <pasta>`). Isso é necessário para testar a sincronização entre duas pastas de dados no mesmo PC (critério da F5) e para a versão portátil, se o usuário quiser.
- A versão portátil (ZIP) usa a mesma pasta por padrão, documentada em `DISTRIBUICAO.md`.
- Alternativas: `%LOCALAPPDATA%` (equivalente num PC pessoal; Roaming é o sugerido pela SPEC e o padrão do `path_provider`); pasta do executável (perde dados ao atualizar e viola a regra 5).
- Motivo: fica fora da instalação e sobrevive a atualização, reinstalação e desinstalação.

### 2026-10-17 — D-06: Tipo de instalação (aprovada em 2026-10-17)

- Decisão: instalação **por usuário**, em `%LOCALAPPDATA%\Programs\Patrion`, sem pedir privilégio de administrador (`PrivilegesRequired=lowest`). O Inno Setup permite, se o usuário quiser, escolher "para todos os usuários" no diálogo (`PrivilegesRequiredOverridesAllowed=dialog`).
- Alternativas: Program Files (pede UAC a cada atualização).
- Motivo: app pessoal de um usuário; atualizar sem UAC é mais simples, e a associação do `.invsave` pode ser feita em `HKCU`.

### 2026-10-17 — D-07: Repositório público (aprovada em 2026-10-17)

- Decisão: repositório **público** no GitHub. O verificador de atualizações (F7) consulta `api.github.com/repos/<dono>/patrion/releases/latest` sem token. O repositório é configurado num único lugar do código.
- Alternativas: código privado com um repositório público só de Releases; repositório privado sem verificador automático.
- Motivo: escolha do usuário. Evita token embutido no app (regra 7). Consequência: nada sensível pode ir para o repositório (já garantido pelo `.gitignore` e pela regra 7).

### 2026-10-17 — D-08: Fontes de dados (aprovada em 2026-10-17)

Detalhes, testes e riscos em `FONTES_DE_DADOS.md`.

- Indicadores (CDI, Selic, IPCA, IGP-M): **BCB SGS**; IPCA alternativo pelo **IBGE SIDRA**.
- Câmbio: **PTAX (BCB Olinda)**; **Frankfurter (BCE)** para moedas não cobertas.
- Histórico BR: **B3 COTAHIST** (preço bruto oficial) + **proventos e eventos do site da B3**; ajuste e retorno total **calculados pelo app**, com detecção de eventos faltantes e confirmação manual.
- Cotação BR atual: **brapi Free** (com chave do usuário; até 30 min de atraso).
- Tesouro Direto: **Tesouro Transparente** (CSV).
- Fundos e FIIs (informes): **CVM Dados Abertos**.
- Cripto: **CoinGecko Demo** (cotação, com atribuição) + **Binance** (histórico).
- Internacional e benchmarks S&P 500/Nasdaq: **Finnhub** (cotação, a confirmar) e **Yahoo** como adaptador **opcional, desligado por padrão** (não oficial; aprovado pelo usuário), com aviso na tela "Fontes de dados".
- IMA/IDkA: **indisponível** (só pagos).
- Descartados: Alpha Vantage (25 req/dia), Stooq (bloqueio por verificação JavaScript), raspagem de sites (Status Invest, Fundamentus).
- Motivo: fontes oficiais e gratuitas sempre que possível; nenhuma opção gratuita entrega histórico BR ajustado e completo, e mesmo a paga (brapi Pro) tem lacuna de eventos.

### 2026-10-17 — D-09: Regra de execução no backtest (aprovada em 2026-10-17)

- Decisão:
  - Decisões na data *t* usam só dados com data de referência ≤ *t*.
  - A execução acontece no **preço de fechamento do pregão *t*** (o mesmo usado para decidir), coerente com `CASOS_DE_TESTE.md` §8.
  - Se *t* não for pregão para o ativo, executa no **próximo pregão** com dado disponível.
  - Proventos em dinheiro entram na data de pagamento (reinvestidos no fechamento desse dia, se a opção estiver ligada). Eventos em ações entram na data "ex".
  - A regra é registrada em cada execução e documentada em `HIPOTETICAS.md`.
- Alternativas: executar no fechamento de *t+1* (mais conservador; pode virar opção futura).
- Motivo: simples, reprodutível e verificável pelos casos de teste.

### 2026-10-17 — D-10: Formato de datas, HLC e identidade (aprovada em 2026-10-17)

- Decisão:
  - Instantes (`created_at`, `updated_at`, `deleted_at`, coletas) em UTC, gravados como `TEXT` ISO-8601 com milissegundos (`2026-10-17T17:30:00.000Z`).
  - Datas de calendário (pregão, operação, vencimento) como `TEXT` `AAAA-MM-DD`, sem fuso.
  - HLC como `TEXT` ordenável lexicograficamente: `<ms UTC com 15 dígitos>-<contador com 5 dígitos>-<device_id>`. A comparação de texto já resolve o empate pelo `device_id`.
  - `id`: UUID v7 em texto minúsculo com hífens.
  - `device_id`: UUID v7 gerado na primeira execução e guardado só no banco local (não vai no save como configuração; aparece só como autor dos registros).
- Alternativas: instantes em inteiros (menos legíveis no JSONL do save).
- Motivo: legibilidade no save, ordenação natural e mesclagem determinística.

### 2026-10-17 — D-11: Chaves de API (aprovada em 2026-10-17)

- Decisão: chaves ficam no **Gerenciador de Credenciais do Windows** via `flutter_secure_storage`, nunca no banco nem no código. Por isso, elas não vão no save. A opção futura de exportá-las (SPEC §10.1) será explícita, desmarcada por padrão e com aviso.
- Alternativas: tabela de configurações do dispositivo em texto puro.
- Motivo: regra 7 e proteção extra se o banco for copiado.

### 2026-10-17 — D-12: Símbolo do app (aprovada em 2026-10-17)

- Decisão: versão vetorial simplificada em `assets/branding/patrion-simbolo.svg`: três cristais em verde chapado (#1F6B4F e #2A8A64) com facetas douradas (#C9A86A) sobre fundo #0E1A16 com cantos arredondados. Conferida em 256, 48, 32 e 16 px. Ela gera o `.ico` (16 a 256 px) na F2/F7.
- Alternativas: o usuário fornece um símbolo próprio.
- Motivo: SPEC §16 pede uma versão legível em 16 px.

### 2026-10-17 — D-13: Paleta, temas e navegação (Fase 2) — paleta e temas substituídos por D-18; navegação continua valendo

- Decisão:
  - Paleta da marca (SPEC §16) sem ajustes: fundo `#0E1A16`, esmeralda `#1F6B4F` (e `#2A8A64` nas faces claras do símbolo), dourado `#C9A86A`, marfim `#F2E9D8`.
  - Tema escuro: fundo `#0E1A16`, texto marfim, primária `#7FD3AE` (esmeralda clara, para ter contraste sobre o fundo escuro) e superfícies em tons de verde-escuro. Tema claro: gerado a partir da esmeralda (`ColorScheme.fromSeed`), com primária `#1F6B4F`.
  - O dourado é só de marca (nome, símbolo). No tema claro ele vira `#8A6D2F`, porque o `#C9A86A` não tem contraste suficiente sobre fundo claro.
  - Cores de dado, próprias de cada tema (`SemanticColors`): ganho `#1B7F4B` / `#6FD39B`, perda `#B3261E` / `#FF8A80`, hipotético `#6A4FB3` / `#B9A6F2` (identidade das telas de simulação). A cor nunca é o único indicador: ganho e perda também levam sinal e ícone, e telas hipotéticas levam o rótulo.
  - Tema "Seguir o Windows" por padrão, com opção Claro/Escuro. É configuração do dispositivo (`dev_settings`), não vai no save.
  - Navegação lateral (`NavigationRail`) com `go_router` (`ShellRoute`). Rótulos ao lado dos ícones a partir de 1100 px de largura. Janela com tamanho mínimo de 960 × 640.
- Alternativas: `NavigationDrawer` fixo (ocupa mais espaço em telas menores).
- Motivo: SPEC §16 (desktop, navegação lateral, tema claro e escuro, cor não é o único indicador).

### 2026-10-17 — D-14: Abertura do banco sem `drift_flutter`

- Decisão: o banco é aberto com `NativeDatabase.createInBackground` (de `package:drift/native.dart`) no caminho calculado pelo próprio app (D-05). O `drift_flutter` (D-02) não é usado.
- Alternativas: `drift_flutter`, que abre o banco em uma pasta do `path_provider`.
- Motivo: o `drift_flutter` 0.3.1 ainda puxa `sqlite3_flutter_libs` e `sqlcipher_flutter_libs`, ambos marcados como fim de vida (`+eol`), que a D-02 já tinha descartado. Como o caminho do banco vem de D-05 (inclusive `--data-dir`), o `drift_flutter` não traria vantagem. O SQLite nativo continua vindo do `sqlite3` 3.x (build hooks).
- Observação: o `drift_dev` 2.35.1 limita o `build_runner` a 2.16.2 (D-02 citava 2.17.1). A versão sobe quando o `drift_dev` permitir.

### 2026-10-17 — D-15: Código gerado versionado

- Decisão: os arquivos gerados (`*.g.dart`), os snapshots do schema (`drift_schemas/`) e os auxiliares gerados dos testes de migração (`test/data/db/migrations/*/generated/`) **vão para o repositório**. O CI roda `dart run build_runner build` e falha se o resultado for diferente do versionado.
- Alternativas: gerar só no CI e no PC, sem versionar.
- Motivo: o projeto compila logo depois do `git clone`, as diferenças de schema aparecem na revisão do commit, e o snapshot é obrigatório para testar migrações (`BANCO.md` §9).

### 2026-10-17 — D-16: Logs

- Decisão:
  - Pacote `logging`, com gravador rotativo próprio em `%APPDATA%\Patrion\logs\` (ou `<--data-dir>\logs\`).
  - Arquivo atual `patrion.log`; ao passar de 1 MB, ele vira `patrion.1.log` e assim por diante, mantendo 5 arquivos antigos (no máximo ~6 MB).
  - Formato: `<instante UTC> <NÍVEL> [origem] mensagem | erro de <tipo>: ...`, com a pilha quando houver. Nível padrão: INFO.
  - Tipos de erro (SPEC §18): rede, dados, cálculo e interno (`core/errors/app_error.dart`).
  - Os logs são técnicos: nenhum valor patrimonial, quantidade, preço da carteira ou chave de API vai para o log (regra 7). Isso é responsabilidade de quem registra; a revisão de código confere.
- Alternativas: pacote `logger` (já descartado em D-02); gravar no banco (cresce sem controle e viraria dado do usuário).
- Motivo: SPEC §18 e regra 7.

### 2026-10-17 — D-17: Geração do ícone

- Decisão: o `.ico` (16, 20, 24, 32, 40, 48, 64, 128 e 256 px) e o PNG do símbolo usado no app (`assets/branding/patrion-simbolo-256.png`) são gerados por um script Dart próprio, `tool/gen_app_icon.dart`, a partir de `assets/branding/patrion-simbolo.svg`. O script rasteriza com superamostragem (16 × 16 amostras por pixel até 64 px; 8 × 8 acima) e grava DIB de 32 bits até 128 px e PNG em 256 px, como o Windows espera.
- O script só aceita os elementos usados no símbolo (`rect` com cantos arredondados e `polygon`, cores chapadas) e para com erro se o SVG mudar para algo que ele não desenha.
- Alternativas: Inkscape ou ImageMagick (não instalados e sem fixação de versão no CI); pacote `flutter_launcher_icons` (não gera `.ico` a partir de SVG).
- Motivo: reprodutível, sem ferramenta externa, e o resultado foi conferido carregando o `.ico` pelo próprio Windows (System.Drawing) em 16, 24, 32 e 48 px.

### 2026-10-17 — D-18: Temas neutros, verde só em destaques (substitui a paleta e os temas da D-13)

- Contexto: o usuário reprovou o tema escuro da D-13, todo esverdeado (fundo e superfícies verdes, geradas por `ColorScheme.fromSeed`).
- Decisão (regras também na SPEC §16):
  - **Fundo e superfícies neutros**, sem tom verde. O esquema de cores é montado à mão (sem `fromSeed`) e sem tinta de elevação (`surfaceTint` transparente), que também tingiria as superfícies.

    | Papel | Escuro | Claro |
    |---|---|---|
    | Fundo da janela | `#0F1113` | `#F4F5F6` |
    | Superfície (cartões, menu lateral) | `#16191C` | `#FFFFFF` |
    | Superfície elevada (campos, menus, diálogos) | `#1D2125` | `#ECEEF0` |
    | Bordas e divisórias | `#2A2F34` | `#D9DDE1` |
    | Texto | `#ECEDEE` | `#16191C` |
    | Texto secundário | `#9BA1A6` | `#565C61` |

  - **Verde-esmeralda só em destaques** (item selecionado do menu, botão principal, foco, toggles, links): primária `#3DAA80` com texto `#0F1113` no escuro (o `#1F6B4F` não tem contraste sobre o fundo quase preto) e `#1F6B4F` com texto branco no claro. Indicador de seleção: `#1F6B4F` no escuro e `#D4EBE1` no claro. A cor terciária é neutra, para o dourado não aparecer em componentes automáticos.
  - **Dourado com muita moderação:** símbolo, nome PATRION e no máximo um destaque por tela; nunca em texto comum. `#C9A86A` no escuro e `#7E6329` no claro (o `#8A6D2F` da D-13 ficava com contraste 4,46 sobre o fundo claro).
  - **Ganho e perda com cores próprias**, diferentes do verde da marca: ganho `#4ADE6F` / `#167A33` (verde mais amarelado e saturado que o esmeralda), perda `#FF7B72` / `#B3261E`. Hipotético continua `#B9A6F2` / `#6A4FB3`. A cor nunca é o único indicador (sinal, ícone, rótulo).
  - Ícones e textos informativos comuns usam o cinza secundário, não o verde.
- Verificação automática (`test/presentation/theme/app_theme_test.dart`): fundos, superfícies, bordas e textos sem matiz verde; contraste WCAG AA (texto ≥ 7:1, texto secundário, cores de dado e dourado ≥ 4,5:1, texto sobre primária ≥ 4,5:1); dourado fora das cores automáticas; ganho distinguível da primária.
- Alternativas: manter o `fromSeed` e só sobrescrever o fundo (os demais tons gerados continuariam esverdeados).
- Motivo: pedido do usuário; interface mais sóbria, em que o verde e o dourado chamam atenção justamente por aparecerem pouco.

### 2026-10-17 — D-19: Backup automático antes de migrar o schema (Fase 3)

- Decisão:
  - Antes de abrir o banco, o app lê o `PRAGMA user_version` do arquivo (`PreMigrationBackup`, `lib/infrastructure/backup/`). Se for menor que `AppDatabase.latestSchemaVersion`, grava uma cópia com `VACUUM INTO` em `<pasta de dados>\backups\` e confere a cópia (`PRAGMA integrity_check` = `ok` e `user_version` igual ao original).
  - Nome do arquivo: `patrion_<AAAA-MM-DD_hh-mm-ss-mmmZ>_pre-migracao_v<de>-v<para>_app-<versão>.db` (data UTC primeiro, para a ordem do nome ser a cronológica; sem `:`, proibido no Windows).
  - Se o backup falhar, o banco **não é aberto** e a migração não acontece: o app mostra a tela de erro de inicialização.
  - Banco de uma versão mais nova do app (`user_version` maior que o conhecido) é recusado com mensagem, sem tocar no arquivo.
  - Retenção: os 10 backups de migração mais recentes. Backups de outros tipos (manuais, F5) não entram nessa conta.
  - O registro em `dev_backups` (com SHA-256) e a restauração entram na F5, com o resto da SPEC §11.
- Alternativas: fazer o backup dentro do `onUpgrade` do Drift (o banco já estaria aberto e no meio da migração); copiar o arquivo com `File.copy` (pode copiar um estado inconsistente se houver diário pendente).
- Motivo: SPEC §11 e `BANCO.md` §9. A primeira migração real (schema 1 → 2) acontece nesta fase.

### 2026-10-17 — D-20: Posições recalculadas em memória (Fase 3)

- Decisão: posições, caixa e totais são calculados em memória a partir de todas as operações (função pura `PortfolioCalculator`) a cada alteração nas tabelas da carteira. As tabelas derivadas `drv_*` de `BANCO.md` §7 ainda não existem.
- Alternativas: gravar `drv_positions` e recalcular a partir da operação alterada.
- Motivo: com o volume de um usuário (centenas a poucos milhares de operações), o recálculo completo leva milissegundos, é mais simples e não tem como ficar dessincronizado. As tabelas `drv_` entram quando a evolução diária (F4/F6) exigir; a regra "dados derivados não são sincronizáveis" continua valendo.

### 2026-10-17 — D-21: Regras das operações (Fase 3)

- Decisão (fórmulas em `FORMULAS.md` §1):
  - Cada conta tem caixa por moeda, calculado de todas as operações: compras debitam, vendas e proventos creditam. Caixa negativo gera um aviso no dashboard ("registre os depósitos"), sem esconder nem ajustar nada.
  - Transferência = duas operações (`transfer_out` e `transfer_in`) com o mesmo `transfer_group_id`, criadas, editadas e excluídas juntas. Transferência de ativo leva quantidade e custo proporcional, sem lucro realizado.
  - Resgate sem quantidade (produtos acompanhados por saldo) baixa o custo na proporção valor resgatado ÷ último saldo informado até a data; sem saldo informado, baixa pelo próprio valor.
  - Bonificação: o valor bruto, se informado, é o custo atribuído e entra no custo.
  - Ajuste manual exige justificativa e é o único tipo que aceita quantidade e valor negativos. Com ativo, muda quantidade e custo; sem ativo, muda o caixa.
  - Antes de gravar, editar ou excluir, o serviço recalcula a carteira e recusa o que criaria inconsistência nova (por exemplo, editar uma compra antiga de modo que uma venda posterior fique maior que a posição).
  - Duplicata: operação viva com a mesma conta, ativo, tipo, data, quantidade, preço e valor. O app avisa e só grava com confirmação.
  - A moeda da operação precisa ser a do ativo. O câmbio da operação é opcional e só registrado.
- Motivo: SPEC §7 e §9. Regras simples, explicáveis e cobertas por testes, que o motor da F4 reaproveita.

### 2026-10-17 — D-22: Preço manual e totais por moeda (Fase 3)

- Decisão:
  - Preço unitário informado (`manual_valuations.kind = unit_price`) vale para o ativo em todas as contas; saldo informado (`balance`) vale para uma conta. Informar de novo na mesma data substitui o valor (mesmo registro, novo HLC).
  - A fonte é "informado por você", com a data de referência visível. Sem preço nem saldo, o valor de mercado aparece como "indisponível" e o patrimônio é marcado como parcial (regra 1).
  - Sem câmbio (F6), o dashboard mostra os totais de cada moeda separadamente, sem converter.
- Alternativas: estimar o valor pelo custo quando não houver preço (viola a regra 1); converter com o câmbio da última operação (seria um câmbio antigo apresentado como atual).
- Motivo: regras invioláveis 1 e 2; a SPEC pede BRL como padrão "com opção de ver a moeda original", o que fica completo na F6.

### 2026-10-17 — D-23: Entrada de números e datas na interface (Fase 3)

- Decisão: campos numéricos aceitam `1.234,56`, `1234,56`, `0.5` e `1234`. Com vírgula, ela é a decimal e os pontos são de milhar; sem vírgula, um único ponto é decimal e mais de um são de milhar. Datas em `dd/mm/aaaa` (ou `AAAA-MM-DD`) e por calendário. A leitura e a formatação são feitas direto sobre o `Decimal` (`lib/presentation/format/formatters.dart`), sem passar por ponto flutuante.
- Motivo: uso em pt-BR, com tolerância a quem digita com ponto decimal; regra 6.

### 2026-10-17 — D-24: Bloqueio do app com SQLCipher — impacto e preparação (registrado, implementação na F5B)

- Contexto: pedido do usuário para registrar na SPEC (§3, "Bloqueio do app"; fase F5B na v1.x) banco criptografado com SQLCipher, senha na abertura, Windows Hello opcional, bloqueio por inatividade e chave de recuperação. **Nada foi implementado.** Esta entrada avalia o impacto na arquitetura atual e lista o que as fases anteriores precisam deixar preparado.

**Viabilidade com a stack atual (sem trocar a stack)**

- O pacote `sqlite3` 3.x, já usado pelo Drift (D-14), distribui builds do SQLCipher Community Edition para Windows x64 (e Android, iOS, Linux e macOS). A troca é por configuração do build hook no `pubspec.yaml` (`hooks: user_defines: sqlite3: source: sqlcipher`), sem pacote novo e sem o `sqlcipher_flutter_libs` (fim de vida, D-02).
- Licenças: SQLCipher CE é BSD-3; no Windows o build liga o OpenSSL (Apache-2.0). A distribuição (F7) precisa incluir os avisos de licença. Alternativa registrada: SQLite3MultipleCiphers (`source: sqlite3mc`, MIT), que tem modo compatível com o formato do SQLCipher. A escolha final entre os dois fica para o início da F5B.
- O build do SQLCipher pode trazer um SQLite um pouco mais antigo que o padrão (aviso do próprio pacote). Conferir na F5B se `VACUUM INTO` e os recursos usados pelo Drift estão disponíveis.
- Windows Hello: o plugin `local_auth` (com `local_auth_windows`) usa o `UserConsentVerifier`, que só confirma a presença do usuário e não protege uma chave. Opção mais forte a avaliar: guardar a chave do banco protegida pelo Windows (Credential Manager/DPAPI, já usado em D-11) e liberá-la só depois da confirmação do Hello. Isso protege contra quem copia a pasta de dados, mas não contra quem já está logado na mesma conta do Windows. A limitação deve aparecer nas Configurações.

**Desenho proposto das chaves**

- Uma chave aleatória do banco (256 bits) é passada ao SQLCipher como chave bruta (`PRAGMA key = "x'...'"`), sem a KDF interna.
- Essa chave é guardada "embrulhada" (criptografada com AES-GCM) duas vezes: com uma chave derivada da senha (Argon2id ou PBKDF2-SHA256 com muitas iterações; escolher e registrar na F5B) e com uma chave derivada da chave de recuperação. Opcionalmente, uma terceira cópia fica protegida pelo Windows para o Hello.
- As chaves embrulhadas, os sais e os parâmetros da KDF ficam num arquivo pequeno ao lado do banco (por exemplo, `patrion.keys.json`), fora do banco. Trocar a senha só reembrulha a chave: o banco não é recriptografado.
- Novo pacote provável: um de criptografia (AES-GCM e KDF), avaliado e registrado aqui antes de usar, como pede o CLAUDE.md.

**Impacto na arquitetura atual**

| Ponto | Hoje | Com o bloqueio |
|---|---|---|
| Inicialização (`main.dart`) | Abre o banco antes do `runApp` e entrega o `AppDatabase` como provedor fixo | O app sobe primeiro numa tela de desbloqueio; o banco, o `SyncContext` e os provedores que dependem dele só existem depois da chave. Pede um estado "bloqueado/desbloqueado" na raiz e provedores do banco que possam ser descartados e recriados. |
| Backup antes de migrar (`PreMigrationBackup`, D-19) | Abre o arquivo com `sqlite3` sem chave | Precisa receber a chave (ou uma função que abre a conexão) antes de ler o `user_version`. Por isso ele roda depois do desbloqueio. `VACUUM INTO` num banco SQLCipher gera cópia criptografada com a mesma chave; conferir na F5B. |
| Backups e restauração (F5) | Ainda não implementados | Backups criptografados só servem com a chave: os metadados do backup precisam dizer se ele é criptografado e qual arquivo de chaves usar. Na restauração, o app valida a chave antes de substituir o banco. |
| Arquivo de save (F5) | Formato ainda não implementado | O save leva a carteira inteira em JSONL dentro de um ZIP: com o banco protegido, um save aberto seria a maior brecha. O manifesto precisa prever, desde a F5, um campo de criptografia (`encryption: none` na v1.0), para a F5B adicionar a senha do arquivo sem quebrar o formato. |
| Bloqueio por inatividade | — | Fechar o banco com streams do Drift ativos: desmontar as telas, cancelar as assinaturas (`PortfolioQuery.watch` já cancela sem esperar), fechar o `AppDatabase` e descartar os provedores. |
| Testes | Banco em memória sem chave | Os testes atuais continuam sem criptografia. Os testes de criptografia usam arquivo temporário com o build SQLCipher. |
| Conversão do banco existente | — | Uma vez: backup, `sqlcipher_export` do banco aberto para um novo criptografado, verificação e troca dos arquivos. A desativação faz o caminho inverso. |
| Sincronização (HLC, UUID) | Independente do armazenamento | Sem impacto. Cada PC tem a própria chave; os dados viajam pelo save. |
| Móvel (futuro) | — | SQLCipher existe para Android e iOS no mesmo pacote; Windows Hello vira biometria do sistema. Sem obstáculo. |
| Logs (D-16) | Sem valores patrimoniais | Continuam assim; a senha, as chaves e a chave de recuperação nunca vão para o log. |

**Preparação exigida até a F5B (vale para as próximas fases)**

1. Toda abertura do banco passa por um único ponto: `AppDatabase.open` e o `PreMigrationBackup`. Nenhum código novo abre `patrion.db` por conta própria (relatórios, F6 e F5 incluídos).
2. A F5 desenha backup, restauração e `dev_backups` sabendo que o arquivo pode ser criptografado: metadados com o campo de criptografia e validação da chave na restauração.
3. A F5 reserva no `manifest.json` do save um campo de criptografia (`none` na v1.0).
4. Nenhum dado da carteira é gravado fora do banco sem pedido explícito do usuário: o cache (F6) guarda só dados de mercado; arquivos temporários de importação e exportação são apagados ao terminar.
5. Código que roda em segundo plano (atualização de cotações na F6, alertas na F13) depende do provedor do banco e para quando ele deixa de existir, em vez de guardar uma referência ao `AppDatabase` aberto na inicialização.
6. O `main.dart` continua só compondo: a ordem "pastas → logs → backup antes de migrar → banco → identidade" deve poder ganhar o passo "desbloqueio" antes do backup sem mexer nas telas.

- Alternativas consideradas: criptografar só o arquivo de save e os backups, com o banco aberto (protege menos: uma cópia da pasta de dados expõe tudo); usar o BitLocker do Windows (protege o disco, não a pasta copiada nem o PC logado; continua recomendado como complemento).
- Motivo: registrar o impacto agora evita que as fases 4 a 7 criem obstáculos para a F5B (CLAUDE.md, "não crie obstáculos").

### 2026-10-17 — D-25: Versões das actions do CI

- Decisão: `actions/checkout@v7` (v7.0.1, de 20/07/2026, roda em Node.js 24), no lugar da v4, que usava o Node.js 20 descontinuado e gerava aviso no CI. `subosito/flutter-action@v2` continua (v2.23.0 é composta e usa `actions/cache@v5`, que já roda em Node.js 24).
- Motivo: aviso de descontinuação do Node.js 20 nos runners do GitHub.

### 2026-10-17 — D-26: Funções transcendentes em `Decimal` (Fase 4)

- Decisão: `DecimalMath.ln`, `exp` e `pow` (expoente fracionário ou negativo) implementados no próprio app, em ponto fixo sobre `BigInt` com 60 casas internas, e devolvidos com 20 casas, meio para o par (D-03). `exp` reduz o argumento por potências de 2 até |x| ≤ 1/16 e soma a série de Taylor; `ln` traz o argumento para [1, 2) com potências de 2 e usa `2·atanh((m − 1)/(m + 1))`. Expoente inteiro usa multiplicações sucessivas.
- Alternativas: converter para `double` e usar `dart:math` (viola a regra 6 e perde precisão: `double` tem ~16 dígitos); adicionar um pacote de precisão arbitrária (nenhum mantido que trabalhe com o `Decimal` do pacote `decimal`).
- Motivo: XIRR, equivalência de taxas, base 252 e CAGR precisam de potências fracionárias. As funções são testadas contra valores conhecidos (ln 2, ln 10, e, √2) com 20 casas.

### 2026-10-17 — D-27: Motor financeiro — convenções (Fase 4)

- Decisão (fórmulas em `FORMULAS.md` §4 a §10):
  - **XIRR**: dias corridos ÷ 365, como o Excel. Resolvido por Newton protegido por bisseção, num intervalo de −99% a 100.000% a.a. onde o valor presente troca de sinal; precisão de 10⁻¹² na taxa. Sem troca de sinal, o resultado é "indisponível". Com mais de uma troca de sinal nos fluxos (pode haver mais de uma TIR), escolhe a raiz mais perto de 10% a.a. e sinaliza.
  - **MWR na interface**: XIRR dos fluxos do investidor nos ativos (compras, vendas, proventos, custos), com o valor de mercado como fluxo final na data do preço mais recente (ou da última operação, se for depois). O caixa parado nas contas fica fora. Com menos de 365 dias, a tela mostra o retorno do período em vez da taxa anual (anualizar prazos curtos exagera o número).
  - **TWR**: fluxos no fim do dia; o motor está pronto e testado (`CASOS_DE_TESTE.md` §6), mas a tela ainda não mostra, porque precisa do valor da carteira em cada data de fluxo. Com preços informados só de vez em quando, isso seria inventar valores intermediários (regra 1). Entra com o histórico de cotações da F6.
  - **Base 252**: calendário de feriados nacionais da ANBIMA calculado pelo app (fixos, Carnaval, Sexta-feira Santa e Corpus Christi a partir da Páscoa; 20/11 a partir de 2024). Dias úteis contados com o início incluído e o fim excluído. Feriados extraordinários podem ser passados ao calendário.
  - **CDI/Selic**: fator diário `(1 + taxa)^(1/252)` com precisão total; os truncamentos da B3 (8 casas no fator diário, 16 no acumulado) não são aplicados.
  - **30/360**: convenção europeia (30E/360).
  - Retorno real, efeito cambial e benchmarks: funções prontas e testadas; aparecem na tela quando houver IPCA, câmbio e índices (F6/F8).
- Alternativas: Modified Dietz como aproximação do TWR com preços esparsos (continua precisando do valor nas datas dos fluxos); mostrar a TIR anualizada sempre (números absurdos em prazos de dias).
- Motivo: SPEC §9 ("informe a metodologia"; "nunca divida uma taxa anual por 365") e regra 1.
