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
