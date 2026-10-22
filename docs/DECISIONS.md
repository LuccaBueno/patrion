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
| `url_launcher` | 6.3.3 | BSD-3 | Abrir a página da Release no navegador (verificador de atualizações, F7; registrado na D-40) |
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

### 2026-10-17 — D-11: Chaves de API (aprovada em 2026-10-17; local substituído pela D-34)

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

### 2026-10-17 — D-28: Identidade e HLC depois de restaurar um backup (Fase 5)

- Decisão: ao restaurar, o `dev_identity` do banco restaurado é substituído pela identidade deste PC (mesmo `device_id` e nome), e o último HLC fica no **maior** entre o HLC atual deste PC, o do banco restaurado e o maior HLC dos registros restaurados. A lista de backups conhecidos (`dev_backups`) também é preservada.
- Alternativas: manter a identidade do backup (um backup de outro PC faria dois PCs terem o mesmo `device_id`, e os HLCs empatariam no desempate); manter o último HLC do backup (as alterações feitas depois da restauração poderiam ter HLC menor que alterações que este PC já exportou, e perderiam para elas no outro PC).
- Motivo: o HLC de um dispositivo nunca pode voltar (SINCRONIZACAO.md). Depois de restaurar, o usuário pode importar saves dos outros PCs para recuperar o que foi feito lá.

### 2026-10-17 — D-29: Arquivo de save e regras da mesclagem (Fase 5)

- Decisão:
  - **Formato**: ZIP `.invsave` com `manifest.json`, `manifest.sha256` e `data/<tabela>.jsonl` (um objeto JSON por linha, colunas com os nomes do banco, todos os valores em texto ou nulo). SHA-256 de cada tabela no manifesto e do manifesto em arquivo próprio: o pacote `archive` 4.5.2 não confere o CRC32 do ZIP na leitura, então o app não depende dele. `formatVersion` (formato do arquivo) é separado de `schemaVersion` (banco).
  - **Tabelas**: todas as que têm os campos de sincronização, descobertas no banco; chaves estrangeiras lidas do SQLite (`PRAGMA foreign_key_list`). As `dev_` nunca entram.
  - **Conflito** = mesmo registro alterado dos dois lados desde a última troca e versões diferentes. Cada save leva `knownPeers` (o maior HLC que o autor recebeu de cada PC); o destino compara o HLC local com o que o autor já conhecia dele e o HLC recebido com o último importado do autor (`dev_sync_peers`). Assim, a versão que o outro PC escolheu já sabendo da sua não aparece como conflito de novo na volta.
  - **Unificação por chave natural**: fica o registro de **menor `id`**, regra que os dois PCs aplicam igual; o outro vira tombstone e alias. Também unifica características de renda fixa do mesmo ativo e configurações compartilhadas da mesma chave (`asset_aliases.entity` aceita `fixed_income_terms` e `shared_setting`, além de `institution`, `account` e `asset`). Um registro absorvido que chegue vivo de um save antigo é dobrado no canônico e volta a ser tombstone.
  - **Toda alteração feita pela mesclagem é alteração local** (HLC deste PC): remapear referências, unificar, regravar a versão escolhida num conflito. Linhas recebidas sem mudança são gravadas como vieram. Com isso, A→B e B→A deixam os bancos idênticos, inclusive nos HLCs.
  - `operations.origin` é preservado como veio do PC que criou a operação (o valor `save_merge` não é usado nas linhas recebidas: mudar a origem faria os dois PCs terem conteúdos diferentes para o mesmo HLC).
  - **Duplicatas**: mesma data, ativo, tipo, quantidade e preço (SPEC §10.4); para movimentos só de caixa, também conta e valor, para não acusar todos os depósitos do mesmo dia. Só sinalizadas.
  - **Backup antes de importar** é feito ao confirmar a importação (antes de qualquer alteração), não ao abrir a prévia, para não criar backups de importações canceladas.
  - **Tabelas hipotéticas criadas já no schema 3** (`hypo_portfolios`, `hypo_holdings`, `hypo_cashflow_rules`, `hypo_scenarios`, com as colunas de `BANCO.md` §5), sem telas nem serviços, para o formato do save levá-las desde a v1.0 e o teste S10 ser real. `hypo_runs` fica para a F9, junto com a opção de exportar a série (desmarcada por padrão).
  - **Dados de mercado (`market/`)**: o manifesto marca `included: false` até existirem tabelas `mkt_` (F6). Chaves de API não existem ainda (F6) e não vão no save.
- Alternativas: detectar conflito só por "mudou dos dois lados desde o último HLC recebido" (mostraria de novo, na volta, o conflito que o outro PC já resolveu); escolher o canônico pelo registro mais antigo por `created_at` (depende de relógios); manter `origin = save_merge` nas linhas recebidas (quebra a convergência).
- Motivo: SPEC §10 (idempotência, nada se desfaz, convergência, relógios) com regras determinísticas e testáveis.

### 2026-10-17 — D-30: Backups, metadados e restauração (Fase 5)

- Decisão:
  - Nome `patrion_<AAAA-MM-DD_hh-mm-ss-mmmZ>_<motivo>_schema-v<N>_app-<versão>.db`, com os metadados num `<nome>.db.json` ao lado (formato `patrion-backup`, versão 1: data, motivo, schema, versão do app, PC, tamanho, SHA-256 e `encryption`) e em `dev_backups` (coluna `encryption`, padrão `none`). O backup anterior à migração (D-19) mantém o nome dele e passa a gravar o `.json` e a ser registrado em `dev_backups` quando o banco abre.
  - Retenção: 10 mais recentes de cada motivo automático (`pre-migracao`, `pre-importacao`, `pre-restauracao`); manuais nunca são apagados.
  - Toda leitura de um arquivo de banco fechado (versão, integridade, identidade) passa por `DatabaseFileInspector` (D-24, item 1). Backups pelo app usam `VACUUM INTO` na conexão aberta.
  - Restauração: confere o arquivo antes de pedir confirmação; confirmação com caixa "Entendo que os dados atuais serão substituídos"; backup `pre-restauracao`; troca do arquivo com o banco fechado (cópia temporária conferida e depois a troca) e reabertura da **sessão** do banco sem reiniciar o app (`presentation/session/app_session.dart`). Se a abertura falhar, volta o arquivo anterior.
  - A sessão (banco, identidade e `SyncContext`) é um objeto que pode ser fechado e recriado, e a interface é remontada do zero a cada sessão. É a base do bloqueio da F5B (D-24, itens 5 e 6).
- Alternativas: pedir para reiniciar o app depois de restaurar (pior para o usuário e não prepara a F5B); empacotar banco e metadados num ZIP (a restauração manual ficaria mais difícil e exigiria arquivos temporários com a carteira).
- Motivo: SPEC §11 e D-24.

### 2026-10-17 — D-31: Diálogos de arquivo (Fase 5)

- Decisão: `file_picker` 13.1.0 (aprovado em D-02) atrás da interface `FileDialogs` (`presentation/services/file_dialogs.dart`), trocada por caminhos fixos nos testes de widget. O save é gerado em memória e gravado pelo diálogo de salvar (`FilePicker.saveFile` com os bytes); o backup em outra pasta usa o seletor de pasta; importar e restaurar usam o seletor de arquivo com filtro (`*.invsave`, `*.db`).
- Limitação conhecida: no Windows, o `saveFile` do `file_picker` 13.1.0 não repassa o filtro de extensões, então o diálogo de salvar mostra "All Files (*.*)". O nome sugerido já termina em `.invsave`.
- Motivo: usar o pacote já aprovado e manter os testes de interface sem diálogos nativos.

### 2026-10-17 — D-32: Bloqueio do app — bibliotecas e criptografia (F5B)

- Decisão (conclui as escolhas deixadas em aberto na D-24):
  - **SQLCipher Community Edition** pelo próprio `sqlite3` 3.7.1, com `hooks: user_defines: sqlite3: source: sqlcipher` no `pubspec.yaml` (sem pacote novo). Conferido em 17/10/2026: SQLCipher 4.19.0 sobre SQLite 3.53.4; sem a chave, "file is not a database"; `VACUUM INTO` num banco criptografado gera cópia criptografada com a mesma chave; `sqlcipher_export` converte aberto ↔ criptografado nos dois sentidos, mas **não copia o `PRAGMA user_version`** (o app copia). Todos os testes passam a usar esse build; sem chave ele se comporta como o SQLite comum. Licenças: SQLCipher CE (BSD-3) e OpenSSL (Apache-2.0), a incluir nos avisos da distribuição (F7). O SQLite3MultipleCiphers (MIT) fica como alternativa.
  - **`pointycastle` 4.0.0** (MIT, Bouncy Castle, Dart puro, Windows/Android/iOS): Argon2id e AES-256-GCM. Medido: Argon2id com 64 MiB e 3 passadas leva ~1,1 s (teste em JIT); PBKDF2-SHA256 com 600 mil iterações leva ~2,9 s. A derivação roda num isolate, para a tela não travar. Alternativa: `cryptography` 2.9.0 (Apache-2.0), com menos uso e o Argon2 também em Dart puro.
  - **`local_auth` 3.0.2** (BSD-3, time do Flutter; `local_auth_windows` 2.0.2 usa o `UserConsentVerifier` do Windows Hello, e o mesmo pacote atende Android e iOS no futuro). O plugin compila com `/await` (corrotinas experimentais), que o MSVC 14.5x do Visual Studio 18 (runner `windows-latest` do CI) recusa: `windows/CMakeLists.txt` define `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` só para esse alvo, até o plugin migrar para `<coroutine>`.
  - **`ffi` 2.2.0** (BSD-3, time do Dart) para chamar o DPAPI do Windows (`CryptProtectData`).
  - **`flutter_secure_storage` não é usado** (aprovado na D-02 para chaves de API): no Windows ele grava num arquivo da pasta do app (`%APPDATA%\<empresa>\<app>`), fora da pasta de dados escolhida (não acompanharia `--data-dir`), e o plugin C++ exige as bibliotecas ATL no build. Para as chaves de API (F6) a escolha será revista.
- **Chaves** (desenho da D-24, confirmado):
  - chave do banco aleatória de 256 bits, passada ao SQLCipher como chave bruta (`PRAGMA key = "x'…'"`), sem a KDF interna;
  - guardada "embrulhada" com AES-256-GCM em `patrion.keys.json`, ao lado do banco: uma cópia com a chave derivada da senha e outra com a chave derivada da chave de recuperação, cada uma com sal próprio;
  - KDF: **Argon2id, 64 MiB, 3 passadas, paralelismo 1, sal de 16 bytes, saída de 32 bytes**, com os parâmetros gravados no arquivo (podem subir no futuro sem quebrar arquivos antigos);
  - `keyId`: identificador aleatório da chave do banco, gravado no arquivo de chaves e nos metadados de cada backup criptografado;
  - trocar a senha só reembrulha a chave; o banco não é recriptografado.
- **Chave de recuperação**: 160 bits aleatórios em Base32 de Crockford, 32 caracteres em 8 grupos de 4 (`XXXX-XXXX-…`), mostrada uma única vez. Na leitura, ignora hífens, espaços e maiúsculas/minúsculas, e aceita O/0 e I/L/1 trocados.
- **Windows Hello**: opcional e por PC. A chave do banco é protegida com o DPAPI do usuário do Windows num arquivo ao lado do banco (`patrion.hello.bin`) e só é lida depois que o Windows Hello confirma o usuário. Protege contra quem copia a pasta de dados para outro PC ou outra conta; **não** protege contra quem já está logado na mesma conta do Windows (limitação mostrada nas Configurações).
- **Senha do arquivo de save**: AES-256-GCM sobre o `.invsave` inteiro, com chave Argon2id (mesmos parâmetros) e sal e nonce próprios. O arquivo continua sendo um ZIP com `manifest.json`, que passa a dizer `encryption.scheme = "aes-256-gcm"` e os parâmetros, e `payload.bin` com o save original cifrado. A versão da F5 lê esse manifesto e recusa o arquivo com a mensagem "protegido por senha".
- Motivo: SPEC §3 e §10.6, D-24; bibliotecas mantidas, com licença permissiva e suporte a Windows e às plataformas móveis.

### 2026-10-18 — D-33: Bloqueio do app — sessão, ordem das operações e backups (F5B)

- Decisão:
  - **Sessão com fases** (`SessionManager`, `presentation/session/app_session.dart`): aberta, bloqueada, ocupada (trocando o banco) e falha. Bloqueado, a árvore de widgets só tem a tela de desbloqueio: o `ProviderScope` da sessão é descartado, o banco é fechado e os bytes da chave são zerados (`DatabaseKey.destroy`). Strings do Dart não podem ser zeradas; o texto do `PRAGMA key` some quando o coletor de lixo o recolhe (limitação registrada).
  - **Estado decidido pelo disco ao abrir**: cabeçalho do `patrion.db` (`SQLite format 3` = sem criptografia) e existência do `patrion.keys.json`. Ativar grava primeiro as chaves e depois troca o banco; desativar troca o banco e depois apaga as chaves. Com essa ordem, uma interrupção sempre deixa um estado reconhecível: banco aberto + chaves → as chaves são postas de lado; banco criptografado + chaves → desbloqueio. A conversão guarda o banco original como `patrion.db.anterior` até o novo abrir.
  - **Conversão** com `sqlcipher_export` para um arquivo novo, conferida (integridade, `user_version` copiado à mão, contagem de registros de cada tabela, cabeçalho criptografado ou não conforme pedido).
  - **Backups**: com o bloqueio, o `VACUUM INTO` gera cópia criptografada com a mesma chave (conferido); cada backup criptografado leva ao lado uma cópia do arquivo de chaves (`<backup>.keys.json`) e o `keyId` nos metadados. Restaurar converte o backup para a criptografia atual do banco; um backup de outra chave pede a senha ou a chave de recuperação da época. Ao ativar, os backups sem criptografia **da pasta de backups** são criptografados no lugar (opção marcada por padrão); os de outras pastas, escolhidas pelo usuário, não são tocados e a tela avisa quantos são.
  - **Inatividade**: um `Listener` acima do `MaterialApp` (vê também os diálogos) e um `HardwareKeyboard` handler reiniciam o temporizador; o tempo fica em `dev_settings` (`lock.idle_minutes`, padrão 15, 0 = nunca). Sem o bloqueio ativo, não há temporizador.
  - **Chave de recuperação**: continua valendo depois de usada (a SPEC não pede o contrário); há "Gerar nova chave de recuperação", que pede a senha. Recuperar exige definir uma senha nova na mesma tela.
  - **Senha**: mínimo de 8 caracteres. Sem limite de tentativas: o Argon2id (~1 s por tentativa) é o freio contra adivinhação.
  - **Windows Hello**: só pode ser ativado com o Windows Hello disponível (`UserConsentVerifier`); a cópia da chave (DPAPI) é apagada ao desativar o Hello ou o bloqueio.
- Alternativas: reescrever o banco no lugar com `PRAGMA rekey` (o SQLCipher não criptografa um banco aberto assim, e uma falha no meio deixaria o único arquivo em estado incerto); pedir para reiniciar o app depois de ativar (pior para o usuário); apagar os backups antigos sem criptografia ao ativar (apagaria dados sem pedido).
- Motivo: SPEC §3 e §11, regra 5 (os dados nunca ficam sem uma cópia legível) e D-24.

### 2026-10-18 — D-34: Chaves de API (F6; substitui a D-11 quanto ao local)

- Decisão: as chaves de API ficam num arquivo próprio na pasta de dados, `patrion.apikeys.bin`, protegido pelo **DPAPI** do Windows (conta do usuário, com entropia própria `patrion-apikeys-v1`), lido por `DpapiApiKeyStore` (`infrastructure/security/api_key_store.dart`).
  - **Fora do banco**: não vão no save, nos backups nem na pasta `market/`. A SPEC §10.1 permitia levá-las no save como opção; por pedido do usuário (18/10/2026), elas **nunca** vão no save.
  - **Fora do log**: o cofre só registra "chave gravada" ou "removida", sem o provedor nem a chave; as requisições levam a chave em cabeçalho (`Authorization`, `X-Finnhub-Token`, `x-cg-demo-api-key`), nunca na URL, e as mensagens de erro do acesso HTTP não incluem URL completa nem cabeçalhos.
  - **Digitadas só na tela** "Fontes de dados", num campo oculto; depois de guardada, a tela mostra só "Chave cadastrada neste computador" (trocar ou apagar).
  - **Por PC**: uma cópia da pasta de dados em outro computador ou outra conta do Windows não abre o arquivo; o app avisa e pede para cadastrar de novo.
  - As chaves são lidas a cada requisição: cadastrar ou apagar vale na hora.
- Alternativas: `flutter_secure_storage` (D-11; descartado na F5B, D-32, para não trazer outro plugin nativo, e o DPAPI já é usado pelo Windows Hello); tabela `dev_settings` em texto (iria para os backups); Gerenciador de Credenciais via FFI (mais código para a mesma proteção do DPAPI).
- Motivo: regra 7, SPEC §3 (privacidade) e o pedido do usuário. Limitação: quem está logado na mesma conta do Windows consegue abrir o arquivo (mesma limitação do DPAPI registrada em D-24).

### 2026-10-18 — D-35: Dados de mercado — provedores, ordem, atualização e cache (F6)

- Pendências da F1 resolvidas (sem fonte inviável):
  - **Finnhub**: no swagger oficial, o plano gratuito tem a cotação atual dos EUA (`/quote`); candles históricos e outras bolsas são pagos. Usado só para cotação dos EUA, com chave.
  - **Twelve Data**: plano Basic com 8 créditos por minuto e 800 por dia, EUA, câmbio e cripto; B3 só nos pagos. Usado para histórico diário e cotação dos EUA, com chave, com intervalo mínimo de 7,6 s entre requisições.
  - **Tesouro Transparente** (CKAN) e **CVM Dados Abertos**: licença ODbL.
  - Mudanças encontradas: o SGS recusa requisições sem `User-Agent`; o Frankfurter mudou para `api.frankfurter.dev/v1`.
  - O teste com chaves reais é do usuário (roteiro no relatório da F6): as chaves nunca passam pelo chat.
- Ordem de preferência (`infrastructure/market/market_setup.dart`):
  - Cotação: brapi (B3; sem chave, só os tickers de teste) → CoinGecko (cripto) → Finnhub (EUA) → Twelve Data (EUA) → Yahoo (desligado por padrão).
  - Histórico: B3 COTAHIST em lote (B3) → Binance (cripto em BRL) → Twelve Data → Yahoo.
  - Câmbio: PTAX → Frankfurter. Indicadores: SGS → SIDRA (IPCA). Tesouro: Tesouro Transparente. FIIs: CVM. Proventos e eventos: B3.
  - Provedor desligado ou sem chave é pulado; em falha, vale a próxima fonte. Cota mensal da brapi (15.000) contada em `dev_provider_state`.
- Atualização (SPEC §5): automática com o app aberto, 5 s depois de abrir e depois a cada 30 minutos (15, 30, 60, 240 minutos ou desligada, por PC em `dev_settings`); manual pela carteira inteira ("Atualizar agora"), por ativo ("Atualizar este ativo" e "Baixar histórico") e pelo teste de cada provedor. Uma atualização por vez; pedidos simultâneos da carteira viram um só.
  - A carteira atualiza só ativos com posição aberta e fonte de preço "cotação automática": cotação atual, fechamentos recentes da B3 (arquivos diários do COTAHIST, só a janela que falta, até 15 dias), Tesouro (se o último dia guardado for anterior ao último pregão), informe de FII (se tiver mais de 40 dias), câmbio de USD, EUR e das moedas da carteira e os indicadores, sempre a partir do último dado guardado.
  - **Histórico** a partir de um ano inicial por PC (padrão: 5 anos antes do atual). Só os trechos que faltam (antes do primeiro e depois do último dia guardado). No COTAHIST, só os anos necessários; o ZIP e o TXT são apagados depois da extração, inclusive em falha (D-05).
  - **Sem internet**: as falhas de rede viram "sem conexão" na tela; tudo continua funcionando com o que está guardado, cada dado com a sua data. Nada é preenchido ou estimado.
- Fonte de preço do ativo: "cotação automática" ou "preço ou saldo informado". Ativo novo recebe a sugestão da classe (renda fixa privada, produto bancário e caixa: informado; as demais: automática). Os ativos criados antes da F6 continuam com preço informado; "Fontes de dados" oferece trocá-los de uma vez (com confirmação).
- Avaliação: num ativo com cotação automática, vale o mais recente entre o preço ou saldo informado e o preço de mercado; na mesma data, o informado (`FORMULAS.md` §2.1).
- Alternativas: atualizar todos os ativos cadastrados (gasta cota com ativos sem posição); preencher com o custo quando falta cotação (proibido pela regra 1).
- Motivo: SPEC §4 e §5, regras 1, 2 e 8.

### 2026-10-18 — D-36: Dados de mercado no save (F6)

- Decisão: a pasta `market/` do save (SPEC §10.1) leva todas as tabelas `mkt_` com registros, uma linha JSON por registro, com todos os valores em texto. Opção "Levar os dados de mercado já baixados", marcada por padrão, no diálogo de salvar.
  - **Formato do arquivo 2** só quando o save leva `market/`; sem ela, o save continua no formato 1, que as versões anteriores do app leem. Uma versão anterior recusa o formato 2 com "formato mais novo: atualize o aplicativo".
  - O manifesto traz `market: {"included": true, "counts": {...}}` e o SHA-256 de cada arquivo em `files`; a validação é a mesma das tabelas (checksum, contagem, arquivo não declarado, colunas exatas, campos obrigatórios, valores só texto ou nulo).
  - **Mesclagem** pela chave primária de cada tabela: registro novo entra; um que já existe só é trocado se a coleta recebida (`collected_at`) for mais recente. Nada é apagado. Roda na mesma transação da importação.
  - Dados de mercado de um save de outro schema são ignorados (são baixados de novo); a prévia avisa.
  - No save protegido por senha, a pasta vai dentro do conteúdo cifrado.
- Alternativas: levar só o histórico (o outro PC ficaria sem câmbio e indicadores offline); usar HLC nos dados de mercado (são dados de terceiros, não edições do usuário).
- Motivo: SPEC §10.1 ("para o outro PC funcionar offline") e regra 2 (a origem de cada dado viaja junto).

### 2026-10-18 — D-37: brapi — horário de pregão, intervalo mínimo e cota (F6, pedido do usuário)

- Decisão (pedido do usuário em 18/10/2026):
  - **Horário de pregão:** na atualização automática, a brapi só é chamada em dias úteis da B3, das 10:00 às 18:30 de Brasília (UTC−3, sem horário de verão desde 2019). A meia hora depois do fim do call de fechamento (18:00) pega a última cotação do dia, que chega com até 30 minutos de atraso. Fora da janela, os ativos da B3 ficam com o fechamento oficial do COTAHIST. "Atualizar agora" e "Atualizar este ativo" consultam a qualquer hora (`MarketSchedule`, `domain/market/market_schedule.dart`).
  - **Intervalo mínimo de 30 minutos** por ativo na atualização automática, pela data de coleta da última cotação da brapi guardada; vale mesmo com o intervalo automático configurado em 15 minutos.
  - **Cota mensal** (15.000 requisições no plano gratuito, no catálogo do provedor): contada por PC em `dev_provider_state`. A tela "Fontes de dados" mostra o uso do mês (número, percentual e barra). A partir de 80%, a atualização e o Início avisam. Esgotada, a brapi não é chamada nem contada até o mês seguinte, e os ativos da B3 usam o fechamento oficial do COTAHIST (que a atualização da carteira já baixa).
  - Os campos `monthlyQuota`, `autoOnlyInSession` e `minAutoInterval` do catálogo servem para outros provedores no futuro.
- Limitação: a brapi conta as requisições da chave em todos os PCs; o app conta só as deste PC (a tela avisa).
- Alternativas: consultar a cota pela API da brapi (não há endpoint documentado no plano gratuito); bloquear também a atualização manual fora do pregão (o usuário pode querer conferir a qualquer hora).
- Motivo: pedido do usuário; SPEC §5 (respeito aos limites das APIs).

### 2026-10-18 — D-38: Instalador, ZIP portátil e Release (F7)

- Decisão:
  - **Instalador** do Inno Setup 6 (`installer/patrion.iss`), por usuário (D-06), com `AppId` fixo `{5A345516-F4A3-4E8D-B057-50475B9F06F9}` (nunca muda: é o que faz a atualização instalar por cima). Atalho no Menu Iniciar, atalho na área de trabalho opcional, associação do `.invsave` em `HKA` (HKCU ou HKLM) como tarefa marcada, `ChangesAssociations=yes`, interface em português (`BrazilianPortuguese.isl`).
  - **Dados intocados:** nenhum `[UninstallDelete]`; o `[InstallDelete]` limpa só `{app}\data` (assets da versão anterior). A desinstalação mostra onde os dados ficaram. `test/installer_test.dart` protege essas regras.
  - **App aberto:** o runner cria o mutex `PatrionAppMutex` (e `Global\PatrionAppMutex`); o instalador usa `AppMutex` e `CloseApplications=no`: pede para fechar, nunca fecha à força.
  - **Runtime do Visual C++** junto do app pelo CMake (`InstallRequiredSystemLibraries`, sem o UCRT, que já vem no Windows 10 e 11). Sem isso, o app não abre num Windows limpo.
  - **ZIP portátil**: pasta `Patrion\` com o app e o `LEIA-ME.txt` (`installer/LEIA-ME-PORTATIL.txt`). Mesmas pastas de dados da versão instalada (D-05).
  - **Licenças:** os textos do SQLCipher (BSD-3) e do OpenSSL 4.0.3 (Apache-2.0, embutido no `sqlcipher.dll`), obtidos dos repositórios oficiais em 19/10/2026, ficam em `assets/licenses/` e entram na tela de licenças do Flutter (`NativeLicenses`), em Configurações > Sobre. `installer/AVISOS_DE_TERCEIROS.txt` vai junto do app (instalador e ZIP) com esses componentes, o runtime do Visual C++ e as fontes de dados (pendência da F5B e da F6).
  - **Release:** `tool/release/build_release.ps1` gera instalador, ZIP, `SHA256SUMS.txt` e notas (seção da versão no `CHANGELOG.md` + `installer/RELEASE_TEMPLATE.md`). O mesmo script roda no PC e no workflow `.github/workflows/release.yml`, disparado pela tag `vX.Y.Z`: confere a tag com o `pubspec.yaml`, roda formatação, análise e testes, instala o Inno Setup pelo Chocolatey se o runner não tiver e cria a Release **em rascunho** com `gh release create --draft` (`--prerelease` para `-beta` e `-rc`). Permissão `contents: write` só nesse job. `workflow_dispatch` faz um ensaio que guarda os arquivos como artefato.
  - **Versão:** `pubspec.yaml` `version: X.Y.Z+N`; a tag é `vX.Y.Z`; `AppInfo.version` acompanha (teste). O recurso de versão do instalador usa `X.Y.Z` sem o sufixo de pré-lançamento.
  - **Testes de distribuição:** `tool/release/test_install.ps1` (26 verificações: instalar, abrir, segunda instância com `.invsave`, atualizar com o app aberto, atualizar por cima, desinstalar mantendo os dados) e `tool/release/sandbox_test.ps1` (o mesmo no Windows Sandbox, na pasta de dados padrão).
- Alternativas: MSIX (exige assinatura e muda a pasta de dados para a virtualizada do pacote); WiX (mais verboso, sem ganho para um app por usuário); exigir o "Visual C++ Redistributable" no instalador (download extra e UAC).
- Motivo: SPEC §19 e D-06. Um Windows recém-instalado (ou o Windows Sandbox) não tem garantidamente o runtime do Visual C++, de que o app e os plugins dependem.

### 2026-10-18 — D-39: Instância única por pasta de dados e abertura do `.invsave` (F7)

- Decisão:
  - Argumentos soltos na linha de comando são arquivos para abrir (`LaunchOptions.files`); é assim que o Windows passa o `.invsave` do duplo clique.
  - **Uma instância por pasta de dados** (`InstanceGate`, `infrastructure/system/single_instance.dart`): a primeira trava `<dados>\instance\patrion.lock` (trava do sistema, liberada quando o processo termina, mesmo num travamento). A segunda não abre o banco e não mostra janela: grava `{"files": [...]}` em `instance\inbox\` (arquivo temporário renomeado, atômico), chama `AllowSetForegroundWindow` e sai. A primeira lê a pasta a cada 400 ms, apaga o pedido, traz a janela para a frente e abre os arquivos. Pedidos com mais de 1 minuto achados ao abrir são descartados.
  - Pastas diferentes (`--data-dir`) abrem ao mesmo tempo (teste de sincronização entre duas pastas, D-05).
  - Os arquivos esperam numa fila fora da sessão (`OpenRequests`): com o bloqueio ativo, depois do desbloqueio. A fila leva à Sincronização, que abre a prévia da importação do arquivo; nada é aplicado sem confirmação.
  - O log registra só o nome do arquivo recebido.
  - **Cuidado do AOT:** o build release removia o campo com o arquivo da trava (só escrito; `close()` nunca é chamado pelo app), o coletor de lixo fechava o arquivo e a trava sumia logo depois de abrir. Os arquivos de trava ficam numa lista estática (`_openLocks`). Achado no teste de instalação; os testes unitários (JIT) não pegam.
- Alternativas: mutex nomeado por FFI (o `GetLastError` depois de uma chamada FFI não é confiável no Dart); instância única no runner C++ com `WM_COPYDATA` (precisaria localizar a janela certa entre pastas de dados diferentes); deixar abrir duas instâncias (duas cópias gravando o mesmo banco).
- Motivo: SPEC §19 (associação do `.invsave`) e integridade do banco.

### 2026-10-18 — D-40: Verificador de atualizações (F7)

- Decisão:
  - `UpdateChecker` (`application/updates/`) atrás da interface `ReleaseFeed`; o adaptador `GitHubReleaseFeed` (`infrastructure/updates/`) consulta `api.github.com/repos/<AppInfo.releasesRepository>/releases/latest` sem token (D-07) ou, com as versões de teste, `/releases?per_page=30` (maior versão SemVer que não seja rascunho). Cabeçalho só com `User-Agent: Patrion/<versão>`.
  - Comparação SemVer com `pub_semver`; `1.0.0 > 1.0.0-rc.1`. Pré-lançamentos ignorados por padrão (opção "Incluir versões de teste"). Tags fora do padrão `vX.Y.Z` são ignoradas.
  - Frequência: automática no máximo uma vez a cada 24 horas (10 s depois de abrir; pode ser desligada); manual no máximo uma vez por minuto. A API sem token permite 60 consultas por hora por IP.
  - Estado em `dev_settings` (`updates.state`, só deste PC): opções, última consulta bem-sucedida, última versão encontrada (com notas e link) e versão ignorada.
  - Sem internet ou com erro, a automática falha em silêncio e mantém o último resultado; a manual mostra a mensagem. Nunca bloqueia o uso.
  - Interface: Configurações > Atualizações (opções, "Verificar agora", notas, "Abrir página de download", "Ignorar esta versão") e aviso no Início. O link só abre páginas do próprio repositório no GitHub (outro endereço vira o link da tag).
  - `url_launcher` 6.3.3 (BSD-3, do time do Flutter, suporta Windows, Android e iOS) para abrir o navegador.
- Alternativas: baixar e executar o instalador sozinho (é a atualização automática da Fase 15, que exige verificação de autenticidade); consultar a página HTML das Releases (frágil).
- Motivo: SPEC §19 ("Verificador de atualizações").

### 2026-10-19 — D-41: Falhas intermitentes do SGS e preço atual na Carteira (pós-F7)

- Contexto: na atualização de 19/10/2026 (dia útil) o app mostrou duas falhas do SGS. Consultas repetidas ao SGS real mostraram que a mesma URL alterna os dados, uma página HTML de erro com **status 200**, `{"erro":{}}` e 502; e que um período sem dados responde **404** com `Value(s) not found` (às vezes com status 200), enquanto o IPCA de um mês ainda não publicado responde sempre `{"erro":{}}`. As janelas de 5 anos (abaixo do limite de 10) e a Selic diária não eram o problema.
- Decisão:
  - **Do nosso lado:** (1) a busca incremental pedia a partir do dia (ou mês) seguinte ao último guardado, quase sempre um período vazio: o 404 virava "erro inesperado" e o `{"erro":{}}` do IPCA, "formato inesperado". Agora começa **no último dado guardado (incluído)**, então o período sempre tem dado e a regravação é idempotente (chave natural). (2) O adaptador trata 404 com `not found` como lista vazia.
  - **Do BCB:** `MarketHttp.getText(retryIf:)` repete respostas 2xx que são falha passageira (página HTML ou `{"erro"...}` sem `not found`), com a mesma espera do 5xx (1 s, 2 s, 4 s); o SGS passou a 4 tentativas. Esgotadas, a última resposta é recusada como antes (`DataError`).
  - Cada série continua independente (a falha de uma não interrompe as outras). As falhas de um provedor nos indicadores viram **um aviso só**, com as séries que ficaram sem dado ("Séries não atualizadas: CDI e IGP-M. …"); uma série obtida por outra fonte (IPCA pelo IBGE) não conta como falha. O log passou a dizer a série (`bcb_sgs (CDI): dados`), nunca valores.
  - **Carteira:** coluna "Preço médio / Atual" (duas linhas, como o cabeçalho): preço médio em cima, preço unitário atual em negrito embaixo, com o ícone de desatualizado; fonte, data, tipo e coleta no tooltip (mesmo texto do valor de mercado, `MarketLabels.valuation`). Sem preço: "indisponível" (avaliação por saldo não tem preço unitário). O percentual continua só no resultado. Para caber em 1280 px: conta em duas linhas (instituição e conta, cortadas com tooltip acima de 150 px), "Qtd." no cabeçalho (tooltip "Quantidade") e espaçamento de 16 px. No detalhe do ativo, "Preço atual" em destaque ao lado do preço médio, com fonte e data embaixo.
- Alternativas: trocar o SGS por outra fonte (desnecessário: o serviço responde, só de forma instável); tratar `{"erro":{}}` como "sem dados" (esconderia falhas reais); coluna separada para o preço atual (não cabia em 1280 px).
- Motivo: regra 1 (sem dado inventado, nada some sem aviso) e pedido do usuário.

### 2026-10-22 — D-42: Adição rápida de ativos pelo ticker (M-01, ajuste antes da F8)

- Contexto: no uso real, adicionar uma ação exigia cadastrar o ativo com 11 campos e registrar a compra em outra tela; o ticker não era normalizado ("bbas3").
- Decisão:
  - **Formulário curto "Adicionar ativo"** (Carteira e Cadastros; renda fixa, cripto e internacional continuam no "Cadastro completo"): ticker, quantidade, preço, data e conta; nome e classe aparecem para conferir; setor, segmento, ISIN, liquidez, fonte de preço e observações ficam em "Mais detalhes". Ativo já cadastrado (mesmo ticker na B3): só a compra. Sem conta cadastrada, o formulário pede o nome da corretora e cria a instituição com uma "Conta principal" em BRL.
  - **Ticker normalizado** (`Tickers.normalize`): maiúsculas e sem espaços nos mercados de ticker (B3, NYSE, Nasdaq, cripto, balcão); na B3, o código do fracionário ("BBAS3F") vira o do lote padrão. Códigos do Tesouro e manuais ficam como digitados. Vale também no cadastro completo.
  - **Consulta ao sair do campo** (`MarketDataService.lookupTicker`, provedores `TickerInfoProvider`, na ordem): (1) **catálogo da B3** tirado do arquivo diário do COTAHIST do último pregão (classe pelo código BDI: 02/07/08 ação, 12/13 FII e Fiagro, 14 ETF — Fiagro e FII pelo nome —, 32 a 36 BDR; nome resumido + especificação; ISIN), guardado no cache (`b3_tickers.json`, ~70 KB) e baixado de novo só quando falta um ticker e o catálogo é anterior ao último pregão (no máximo uma vez por dia); o ZIP e o TXT são apagados (D-05). (2) **brapi**: a lista `/api/quote/list?search=` responde **sem chave** (vai sem o cabeçalho, para não gastar a cota) e dá nome, tipo, setor (traduzido do inglês) e subsetor; com chave, a cotação com `modules=summaryProfile` dá o nome completo, setor e indústria em português e o **preço, guardado como qualquer cotação** (o ativo novo já sai com valor de mercado). Classe e ISIN vêm da primeira fonte que informa (o catálogo oficial); nome, setor e segmento, da última (a brapi). A consulta conta uma requisição na cota da brapi e respeita fontes desligadas. Só o ticker vai às fontes (regra 8).
  - **Sem resultado:** "não encontrado" (fontes responderam) ou "sem conexão" (nenhuma respondeu); o usuário preenche nome e classe e segue com o cadastro manual. Ticker que nenhuma fonte conhece fica com preço informado (manual); offline, com preço de mercado. Funciona offline com o catálogo já baixado.
  - **Saldo inicial** ("Posição que já tenho"): uma **compra** na data aproximada com a nota "Saldo inicial (posição informada pela corretora)"; é o modo padrão enquanto a carteira não tem operações. A tela avisa que a TIR fica aproximada. Não foi criado um código novo de origem ou tipo de operação: um PC com a 1.0.0 não reconheceria o código no save.
  - Ativo, conta e compra são gravados **numa transação só** (`QuickAddService`). Depois de gravar, o app busca a cotação do ativo novo em segundo plano (fechamento do COTAHIST).
- Alternativas: catálogo de tickers no banco (cresceria o banco com dado público recuperável); classe pelo final do código (ambígua no "11": unit, FII ou ETF); tipo de operação "saldo inicial" (quebraria a compatibilidade do save com a 1.0.0).
- Motivo: pedido do usuário (uso real); regras 1, 2 e 8.
