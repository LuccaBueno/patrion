# Progresso

Atualizado pelo Claude ao final de cada fase ou sessão.

## Fase atual

**Ajustes M-06 a M-09 (`docs/MUDANCAS.md`), versão 1.2.0, em andamento** desde 23/10/2026, na ordem pedida: M-08 (histórico) → M-07 (página do ativo) → M-09 (Painel) → M-06 (corretoras). Feito: **M-08**. A 1.1.0 (M-01 a M-05) terminou em 23/10/2026, sem tag nem Release. Pendência sua antiga: Windows Hello (F5B).

## Concluído

### Ajustes M-06 a M-09 (desde 23/10/2026)

Cada item tem um commit; o relatório completo sai no fim (com a 1.2.0).

**M-08 — Histórico completo de cotações em segundo plano (concluído)** (DECISIONS D-48, altera D-35; SPEC §5; FONTES_DE_DADOS §1)

- Ano inicial padrão de 10 anos (era 5). `HistoryBackfillService` baixa o COTAHIST anual do ano mais recente ao mais antigo, um arquivo por ano para todos os ativos da B3 com cotação automática (inclusive posições encerradas), com os proventos e eventos (renovados a cada 30 dias) e o histórico dos ativos de fora da B3. Cada ano lido fica registrado por ticker em `dev_settings`: fechar o app no meio perde só o ano em andamento. Roda depois da atualização automática da abertura, depois de cadastrar um ativo (rápido ou completo) e pelo botão "Baixar histórico completo".
- Arquivos anuais numa fila própria do HTTP (`lane`), com progresso do download: a atualização diária e o "Atualizar agora" não esperam. Sobras de downloads interrompidos são apagadas no início e no fim.
- Progresso no rodapé do menu ("Baixando histórico de BBAS3… 2019", com barra) e, em Fontes de dados, a seção "Histórico de cotações" com, por ativo, desde quando há fechamentos e o botão "Baixar histórico completo".
- Arquivos: `application/market/history_backfill.dart` (novo), `market_data_service.dart` (`downloadCotahistYear`, `usesBatchHistory`, `hasHistorySource`, `hasEventsSource`), `market_ports.dart`, `settings/market_preferences.dart`, `infrastructure/market/market_http.dart`, `providers/b3_cotahist_provider.dart` (`cleanAnnual`), `presentation/services/market_refresh.dart` (`HistoryBackfillController` e o gatilho da abertura), `screens/market/history_widgets.dart` (novo), `data_sources_screen.dart`, `shell/app_shell.dart`, `add_asset_dialog.dart`, `registry_dialogs.dart`, `providers.dart`.
- Testes: `history_backfill_test.dart` (10 anos do mais recente ao mais antigo e uma vez só; sem rede no meio para e continua de onde parou; ano corrente relido depois de 10 dias; ano lido antes de terminar é relido; ativo novo com um arquivo para os dois; ano inicial escolhido; "Baixar histórico completo"; chamada durante a execução; sem ativos), `data_sources_screen_test.dart` (seção por ativo), `market_data_service_test.dart` (indicadores desde 10 anos).
- **No app real** (build release copiado para o scratchpad, pasta de dados de teste; seus dados intocados), carteira de exemplo com BBAS3, PETR4, TAEE11, VALE3 e HGLG11: em cerca de um minuto, 2.685 pregões de 04/01/2016 a 22/10/2026 para cada um, os eventos (inclusive o desdobramento 1:2 do BBAS3 em 16/04/2024) e a pasta de cache vazia no fim. O rodapé do menu mostrou "Baixando proventos e eventos de BBAS3, HGLG11, PETR4 e mais 2…" com a barra. **Retomada:** com 2016 a 2018 esquecidos no estado, matei o app no meio do download de 2017 (ZIP parcial no cache); na reabertura o log disse "2 anos", baixou 2017 e 2016 e o cache terminou vazio.
- Observação: o seu Patrion estava aberto a partir de `build\windows\x64\runner\Release` (sem `--data-dir`, com os seus dados). Não mexi nele, mas o `flutter build` substituiu o `data\app.so` dessa pasta: ao reabrir esse executável, ele já roda o código novo (e baixa o histórico de 10 anos dos seus ativos).

### Ajustes de uso real antes da F8 (desde 22/10/2026)

Itens de `docs/MUDANCAS.md`. Cada item tem um commit; o relatório completo sai no fim (com a 1.1.0).

**M-01 — Adição rápida pelo ticker (concluído)** (DECISIONS D-42, SPEC §7)

- Formulário "Adicionar ativo" na Carteira (botão no topo) e em Cadastros ("Adicionar ativo" e "Cadastro completo"): ticker em maiúsculas, quantidade, preço, data e conta (última usada ou a única; sem conta, pede a corretora e cria a "Conta principal"). Modos "Posição que já tenho (saldo inicial)" (padrão na carteira vazia, com o aviso da TIR aproximada) e "Nova compra" (com custos opcionais). "Mais detalhes" recolhido.
- Ao sair do ticker, consulta o catálogo da B3 (COTAHIST diário, no cache, funciona offline) e a brapi (lista sem chave; com chave, nome completo, setor e a cotação, que já é guardada). Ativo já cadastrado: só a compra. Não encontrado ou sem conexão: aviso e cadastro manual (nome e classe). Ativo, conta e compra numa transação só.
- Arquivos: `application/portfolio/quick_add_service.dart`, `application/market/market_ports.dart` (`TickerInfo`), `market_data_service.dart` (`lookupTicker`), `infrastructure/market/providers/b3_ticker_catalog.dart`, `brapi_provider.dart` (`BrapiLookup`), `domain/market/tickers.dart`, `presentation/screens/portfolio/add_asset_dialog.dart`; `MessageCard` não estica mais na altura.
- Testes: `ticker_lookup_test.dart` (catálogo com linhas reais do COTAHIST de 21/10, offline, arquivo não publicado; brapi com e sem chave, 404, nomes), `quick_add_service_test.dart`, `market_data_service_test.dart` (junção das fontes, cota, offline, fonte desligada), `tickers_test.dart`, `add_asset_dialog_test.dart` ("bbas3", 100, 25,00; inexistente; já cadastrado; offline). Suíte inteira: 474 testes passando antes dos ajustes finais; analyze sem problemas.
- **No app real** (build release, pasta de dados de teste no scratchpad com a sua chave da brapi copiada; seus dados intocados), em 1280 × 800: "bbas3" virou BBAS3, "Banco do Brasil S.A." / Ação vieram da B3 e da brapi, e salvar criou o ativo e o saldo inicial numa tela só, já com cotação (R$ 23,92, brapi). HGLG11 veio como FII, com "Nova compra" e a conta preenchidas.

**M-02 — Menu e Configurações por seções (concluído)** (DECISIONS D-43, SPEC §16)

- Menu: Painel, Carteira, Operações e Cadastros em cima; Sincronizar (com marca quando a última sincronização tem 7 dias ou mais) e Configurações no rodapé, depois de um divisor.
- Configurações com seções e endereço próprio: Geral, Segurança, Fontes de dados, Backup, Sincronização e Sobre. Endereços antigos redirecionam; avisos abrem a seção certa. Painel e Carteira vazios oferecem "Adicionar ativo".
- Arquivos: `presentation/router/app_router.dart` (`Routes`, rodapé, redirecionamentos), `shell/app_shell.dart`, `screens/settings_screen.dart`, `dashboard_screen.dart`, `portfolio_screen.dart`, sessão e telas que apontavam para os endereços antigos.
- Testes: `app_test.dart` (menu, posição do rodapé, Sincronizar em 1 clique até "Salvar arquivo de save", todas as seções abrem, endereços antigos); testes de telas ajustados aos novos endereços. Suíte inteira: 476 passando; analyze sem problemas.
- **No app** (1280 × 800, pasta de teste): menu com 4 itens em cima e o rodapé; Sincronizar abre a seção com "Salvar arquivo de save"; Geral, Backup e Fontes de dados cabem sem rolagem lateral. O build release foi conferido depois: abre e redimensiona normalmente (uma captura em branco no meio da abertura era da minha ferramenta de captura, não do app).


**M-03 — Controle de caixa opcional (concluído)** (DECISIONS D-44, altera D-21; SPEC §8; FORMULAS §2)

- Configurações → Geral → "Controlar saldo em caixa", **desligado por padrão**, geral e sincronizado (`shared_settings`). Desligado: caixa fora dos totais, sem card "Caixa" nem aviso de caixa negativo, patrimônio = valor de mercado das posições. Ligado: o comportamento da 1.0.0. A TIR e o resultado não mudam. No saldo inicial do cadastro rápido, com o caixa ligado, "Não mexer no caixa" registra o depósito do mesmo valor.
- Arquivos: `domain/portfolio/portfolio_summary.dart` (`trackCash`), `application/settings/portfolio_preferences.dart`, `portfolio_query.dart`, `portfolio_repositories.dart` (recalcula quando a preferência muda), `providers.dart`, `settings_screen.dart`, `dashboard_screen.dart`, `add_asset_dialog.dart`. A lista de seções das Configurações passou a destacar só a seção escolhida.
- Testes: compra de R$ 3.729,60 sem depósito (patrimônio = posição, sem aviso; ligando, volta o caixa −3.729,60 com aviso), TIR igual com e sem o controle, retrato com o caixa ligado e desligado; os testes antigos de caixa do Painel rodam com a opção ligada e passam; teste de tela do padrão e do botão em Configurações. Suíte inteira: 479 passando.
- **No app (release, 1280 × 800):** a carteira de teste que mostrava patrimônio −R$ 108,00 e caixa −R$ 2.500,00 passou a mostrar patrimônio R$ 2.392,00 (o valor da posição), sem card de caixa nem aviso.


**M-05 — Carteira como lista por ativo, com painel de detalhes (concluído)** (DECISIONS D-45, SPEC §16, FORMULAS §2.4)

- Lista com um item por ativo (contas somadas), do maior valor da posição para o menor: ativo (código, nome, "100 cotas"), valor da posição em destaque, preço médio, cotação atual (fonte e data embaixo, detalhe no tooltip), valorização % com cor, sinal e ícone, e "Detalhes". Sem cotação, "indisponível" e ordem pelo total aplicado; zero cotas no fim, em cinza. Cabe em 1280 px.
- Painel por cima da lista: lucro em R$ (não realizado + realizado), total aplicado, preço médio, cotação, variação do dia (R$ e %, desde o fechamento anterior guardado), % da carteira, proventos, gráfico (1S a Tudo) com a linha tracejada do preço médio, operações e "Comprar"/"Vender". Sem histórico, "indisponível" com o motivo e "Baixar histórico".
- Arquivos: `domain/portfolio/holdings.dart`, `domain/market/market_price.dart` (`PriceReference`, `PriceChange`, `withReferences`), `market_price_book.dart`, `market_repository.dart` (`closesSince`), `portfolio_query.dart`, `presentation/screens/portfolio/portfolio_screen.dart` (reescrita), `asset_panel.dart`, `trade_dialog.dart`; `fl_chart` 1.2.0 no `pubspec.yaml`.
- Testes: `holdings_test.dart` (ordem, valorização, lucro, % da carteira, contas somadas, câmbio na ordem, variação do dia e do mês, sem fechamento), `portfolio_list_test.dart` (5 ativos: ordem, valorização −4,32%, painel com lucro, total aplicado, variação −R$ 18,00 (−0,75%), gráfico com a linha do PM em 25; sem histórico, indisponível; comprar pelo painel reordena; vender tudo leva ao fim, em cinza), `portfolio_width_test.dart` refeito para a lista (Segoe UI real, 1264 px úteis). Suíte inteira: 486 passando; analyze sem problemas.
- **No app (release, 1280 × 800)**, carteira de teste com BBAS3, PETR4, VALE3, HGLG11 e ITUB4 adicionados pelo formulário rápido: lista na ordem dos valores, cotações da brapi com fonte e data; painel do PETR4 com lucro, variação do dia contra o fechamento de 21/10 (COTAHIST) e gráfico com a linha do preço médio. Corrigi depois da conferência os rótulos do eixo do gráfico (mínimo e máximo sobrepostos, última data cortada).


**M-04 — Painel com gráficos, itens 1, 2, 3, 6 e 7 (concluído)** (DECISIONS D-46, SPEC §8 e §21, FORMULAS §3.1)

- Início virou **Painel**. Destaques: patrimônio, resultado total (R$ e % sobre o aplicado) e variação do dia (R$ e %, parcial quando falta algum ativo). Roscas por ativo, classe, setor e instituição com legenda em texto. Aportes no mês e no ano, com barras de 12 meses (compras × vendas; o saldo inicial não conta). Proventos por mês e total de 12 meses. Maiores altas e baixas no dia ou no mês.
- Itens 4, 5 e 9 registrados na F8 (SPEC §21), como pedido; o item 8 (faixa de câmbio no rodapé) não estava na lista pedida e também ficou registrado na F8.
- Arquivos: `domain/portfolio/dashboard_metrics.dart`, `entities.dart` (`InitialBalance`), `presentation/screens/dashboard/dashboard_charts.dart` (rosca, barras, cores), `dashboard_screen.dart`.
- Testes: `dashboard_metrics_test.dart` (meses, saldo inicial fora, moeda, ano, variação do dia parcial e indisponível, altas e baixas), teste de tela do Painel em `portfolio_list_test.dart` (5 ativos: patrimônio igual à soma da Carteira, variação −R$ 18,00 parcial, roscas com os valores da Carteira, aportes do mês e do ano, proventos de 12 meses, altas/baixas no dia e no mês), `chart_labels_test.dart`. Suíte inteira: 491 passando.
- **No app (release, 1280 × 800):** destaques, quatro roscas (setores vindos da brapi), aportes e "nada registrado" nos proventos, altas e baixas. Corrigi depois da conferência os rótulos do eixo das barras (quebravam linha; agora "20 mil") e o mês atual sem rótulo.


**Verificação do "Atualizar agora" (pedido junto com os M-xx) — problema encontrado e corrigido** (DECISIONS D-47)

- Reproduzido no app real: pasta de dados nova no scratchpad, chave da brapi copiada (o arquivo protegido pelo DPAPI da sua conta), TAEE11 cadastrado com "Cotação automática" pelo cadastro completo, sem operações. "Atualizar agora" registrava "Atualização da carteira: 0 ativos" e o ativo ficava sem preço.
- Causa: a atualização só cobria ativos com posição aberta; e a página do ativo só procurava o preço entre as posições.
- Correção: a atualização cobre também os ativos com preço de mercado ainda sem operações (posições encerradas continuam fora); o retrato guarda o preço de todos os ativos e a página do ativo o mostra. Depois: "1 ativos" no log e R$ 44,90 (brapi, 22/10/2026 18:30) na página do TAEE11.
- Testes: `market_data_service_test.dart` (o ativo novo é consultado, o encerrado não; o teste falha no código antigo, conferido), `portfolio_screens_test.dart` (página do ativo sem operações mostra a cotação).
- Observação: durante a atualização automática da abertura (numa pasta nova ela baixa cinco anos de indicadores e leva cerca de um minuto), o botão "Atualizar agora" fica desabilitado ("Atualizando…"); o clique nesse intervalo não faz nada.

**Versão 1.1.0 — relatório final dos ajustes (23/10/2026)**

1. **Implementado:** M-01 (adição rápida pelo ticker), M-02 (menu e Configurações por seções), M-03 (caixa opcional, desligado por padrão), M-04 itens 1, 2, 3, 6 e 7 (Painel com destaques, roscas, aportes, proventos, altas e baixas), M-05 (Carteira como lista por ativo com painel de detalhes) e a correção do "Atualizar agora" (D-47). Detalhes de cada item acima.
2. **Arquivos (resumo):** os listados em cada item; na versão: `pubspec.yaml` (1.1.0+2), `core/config/app_info.dart`, `CHANGELOG.md` (seção 1.1.0), `README.md`, `docs/DISTRIBUICAO.md` (roteiro manual com o formulário rápido e o Sincronizar do rodapé), `docs/SOLUCAO_DE_PROBLEMAS.md` e `docs/ARQUITETURA.md` (telas e caminhos novos de Configurações).
3. **Testes (resultados reais):** `dart format .` sem mudanças; `flutter analyze` sem problemas; `flutter test` com **493 testes passando**; `flutter build windows --release` compilou, e o `patrion.exe` tem versão 1.1.0+2. O release abriu numa pasta de dados de teste e registrou "Iniciando Patrion 1.1.0" no log. **CI verde** ([run 39907635338](https://github.com/LuccaBueno/patrion/actions/runs/39907635338), commit `995c843`; format, analyze, testes e build release). As conferências visuais de cada item estão acima.
4. **Problemas e limitações:** do M-04, evolução do patrimônio, rentabilidade comparada, seletor de período e faixa de câmbio ficam para a F8. O dinheiro parado (M-03, item 4) entra como ativo da classe Caixa com saldo informado, que já existia (D-44); o controle de caixa é geral, não por conta. Durante a atualização automática da abertura, "Atualizar agora" fica desabilitado.
5. **Pendências:** tag e Release v1.1.0 (só quando você pedir); Windows Hello (F5B), antiga.
6. **Como testar:** `flutter run -d windows` ou o instalador gerado por `tool\release\build_release.ps1`. Confira: Carteira > "Adicionar ativo" com "bbas3", 100 e 25,00; a ordem da lista e o painel de "Detalhes" (gráfico com a linha do preço médio, Comprar e Vender); o Painel batendo com a Carteira; o patrimônio sem caixa negativo e, ligando Configurações > Geral > "Controlar saldo em caixa", o caixa de volta; o Sincronizar no rodapé até "Salvar arquivo de save"; e "Atualizar agora" com um ativo recém-cadastrado.


### Ajustes antes da tag v1.0.0 (19/10/2026)

Dois pedidos depois da Fase 7, incluídos na 1.0.0 (ainda sem tag): falhas do SGS e preço atual na Carteira (DECISIONS D-41).

**1. O que foi implementado**

- **Falhas do SGS — causa encontrada.** Consultei o SGS real várias vezes com as mesmas URLs. A mesma consulta alterna os dados, uma página HTML de erro **com status 200**, `{"erro":{}}` e 502 (instabilidade do BCB). Um período sem dados responde **404** "Value(s) not found". O IPCA de um mês ainda não publicado responde sempre `{"erro":{}}`. A janela de 5 anos (abaixo do limite de 10) e a Selic diária não eram o problema. As duas mensagens que você viu vinham daí:
  - "erro inesperado": nosso. A busca incremental pedia a partir do dia (ou mês) **seguinte** ao último dado guardado, quase sempre um período vazio, e o 404 do "sem dados" não era tratado. No log de hoje aparece `HttpStatusError(bcb_sgs, 404)` duas vezes. O log não dizia a série (agora diz); refazendo as consultas que o app faria hoje, dão 404 as de período vazio: IGP-M de outubro (ainda não publicado) e CDI e Selic depois do último dia publicado.
  - "página de erro" e "formato inesperado": do BCB (a página HTML com status 200), mais o `{"erro":{}}` do IPCA de outubro (nosso, pelo mesmo período vazio).
- **Correções:** a busca começa **no último dado guardado (incluído)**, então o período sempre tem dado e regravar é idempotente; o 404 "not found" vira lista vazia; respostas 200 inválidas são repetidas (1 s, 2 s, 4 s; 4 tentativas no SGS). Cada série segue independente, e as falhas de um provedor viram **um aviso só**, com as séries ("Séries não atualizadas: CDI e IGP-M. …"). O IPCA que vem do IBGE não conta como falha. O log passou a dizer a série (`bcb_sgs (CDI): dados`).
- **Preço atual na Carteira:** coluna "Preço médio / Atual" com o preço médio em cima e o preço unitário atual em negrito embaixo (ícone de desatualizado quando for o caso), com fonte, data, tipo e coleta no tooltip. Sem cotação, "indisponível" (também no CDB avaliado por saldo, que não tem preço unitário). O percentual fica só no resultado. Para caber em 1280 px: conta em duas linhas (instituição e conta), cabeçalho "Qtd." (tooltip "Quantidade") e espaçamento menor.
- **Detalhe do ativo:** "Preço atual" em destaque (fonte maior, negrito) ao lado do preço médio, com fonte e data embaixo e o detalhe no tooltip.

**2. Arquivos alterados (resumo)**

- SGS: `infrastructure/market/providers/bcb_providers.dart`, `market_http.dart` (`getText(retryIf:)`), `market_setup.dart`, `application/market/market_data_service.dart`.
- Carteira: `presentation/screens/portfolio/portfolio_screen.dart`, `asset_detail_screen.dart`, `presentation/format/market_labels.dart` (`MarketLabels.valuation`).
- Testes: `providers_test.dart` (404 "sem dados", página de erro repetida até vir o dado, página persistente vira erro), `market_data_service_test.dart` (busca a partir do último dado; falha de três séries não trava as outras, IPCA pelo IBGE, um aviso só), `portfolio_width_test.dart` (pior caso com cotação da brapi antiga, ícone e tooltip com fonte e data), `portfolio_screens_test.dart` (preço atual na carteira e no detalhe; "indisponível").
- Docs: DECISIONS D-41, FONTES_DE_DADOS §2.1, CHANGELOG (1.0.0: Alterado e Corrigido).

**3. Testes executados e resultados reais**

- `dart format --set-exit-if-changed .`: 200 arquivos, 0 alterados. `flutter analyze`: sem problemas. `flutter test`: **452 testes passando**. `flutter build windows --release`: compilou.
- **SGS real** com o adaptador corrigido: CDI, Selic, meta Selic, IPCA e IGP-M desde 01/01/2021 baixados sem falha (as retentativas apareceram no log e resolveram). Pedidos a partir de hoje: lista vazia, sem erro. Única falha restante: o IPCA pedido a partir de 01/10 (sempre `{"erro":{}}`), consulta que o app não faz mais.
- **App real (build release)** numa pasta de dados de teste fictícia (no scratchpad, seus dados intocados): a atualização automática gravou 8.100 registros **sem nenhuma falha** e sem aviso do SGS no log. Carteira na janela de 1280 × 720: tabela inteira visível, com folga até "Resultado". PETR4 e VALE3 pela brapi, HGLG11 pelo COTAHIST, ITSA4 e o CDB com "indisponível". Detalhe da PETR4 com "Preço atual" em destaque ao lado do preço médio. Capturas só da janela do Patrion.
- **Não conferido no app real:** o tooltip ao passar o mouse (o mouse simulado não aciona o tooltip do Flutter, e não movi o seu cursor). O texto do tooltip está coberto pelos testes de widget.
- `tool/release/build_release.ps1`: regenerou `dist\Patrion-1.0.0-instalador.exe` (13,6 MB), `Patrion-1.0.0-portatil.zip` (16,3 MB), `SHA256SUMS.txt` e `RELEASE_NOTES.md` (com as duas mudanças). O `test_install.ps1` **não** foi rodado de novo: o instalador não mudou, só o app dentro dele.

**4. Problemas e limitações**

- O SGS continua instável do lado do BCB. Se ele falhar nas 4 tentativas, a série fica para a próxima atualização, com um aviso só.
- Com "Qtd." e a conta em duas linhas, nomes de instituição ou conta com mais de 150 px são cortados com "…" (o nome inteiro fica no tooltip).

**5. Pendências**

- As mesmas da Fase 7: seu teste em ambiente limpo, autorizar a tag `v1.0.0` e publicar a Release em rascunho.

**6. O que testar manualmente**

- Abra o app (ou instale o novo `dist\Patrion-1.0.0-instalador.exe` por cima) e use "Atualizar agora" em Fontes de dados: CDI, Selic, meta Selic, IPCA e IGP-M sem falha. Se o SGS falhar, deve aparecer um aviso só, com o nome das séries.
- Carteira em 1280 px: coluna "Preço médio / Atual" e "Resultado" visíveis sem rolar. Passe o mouse no preço atual: aparecem fonte, data, tipo e coleta.
- Detalhe de um ativo: "Preço atual" em destaque ao lado do preço médio.

### Fase 7 — Distribuição

Critério de pronto (SPEC §21): a versão v1.0.0 existe, com instalador testado em ambiente limpo.

- **v1.0.0 preparada:** `pubspec.yaml` 1.0.0+1, `CHANGELOG.md` com a seção `[1.0.0]`, instalador, ZIP e notas gerados e conferidos. A tag `v1.0.0` e a Release **não foram criadas** (só com o seu pedido).
- **Instalador testado neste PC** (26 de 26 verificações, `tool/release/test_install.ps1`), com pastas de instalação e de dados de teste: instalação, segunda instância com `.invsave`, recusa de atualizar com o app aberto, atualização 0.9.0 → 1.0.0 por cima, desinstalação mantendo os dados e sem sobras no registro. **Ambiente limpo: não testado** (o Windows Sandbox não está habilitado neste PC; ligá-lo pede administrador e reinicialização). Roteiro no item 6.

**1. O que foi implementado**

- **Instalador** (Inno Setup 6, `installer/patrion.iss`): por usuário em `%LOCALAPPDATA%\Programs\Patrion`, sem administrador (opção "para todos"); Menu Iniciar e atalho opcional na área de trabalho; atualização por cima (AppId fixo); pede para fechar o app aberto (mutex `PatrionAppMutex` criado pelo runner) e nunca o fecha à força; desinstalação sem apagar dados, com mensagem de onde eles ficaram; versão em "Aplicativos instalados"; associação do `.invsave`, removida na desinstalação.
- **Runtime do Visual C++** junto do app (CMake), para abrir num Windows sem o Redistributable.
- **ZIP portátil** com `LEIA-ME.txt` (onde ficam os dados, `--data-dir`, SmartScreen).
- **Avisos de terceiros** (pendência da F5B e da F6): textos do SQLCipher e do OpenSSL 4.0.3 (embutido no `sqlcipher.dll`) na tela Configurações > Sobre > "Licenças de terceiros", junto das licenças do Flutter; `AVISOS_DE_TERCEIROS.txt` no pacote, com as fontes de dados.
- **`.invsave` pelo Explorador:** o duplo clique abre a Sincronização com a prévia da importação (nada é aplicado sem "Aplicar"); com bloqueio, depois do desbloqueio.
- **Instância única por pasta de dados:** a segunda instância entrega o arquivo à janela aberta, que vem para a frente, e sai. Pastas diferentes (`--data-dir`) abrem juntas. No teste do app real apareceu um defeito que os testes unitários não pegavam: no build release, a trava se soltava logo depois da abertura (o AOT removia o campo e o coletor de lixo fechava o arquivo). Corrigido e registrado na D-39.
- **Verificador de atualizações:** Configurações > Atualizações (ao abrir, no máximo uma vez por dia, desligável; "Verificar agora"; versões de teste opcionais; notas; "Abrir página de download"; "Ignorar esta versão") e aviso no Início. Releases do GitHub sem token, SemVer, sem internet não atrapalha.
- **Workflow de release** (`.github/workflows/release.yml`): na tag `vX.Y.Z`, confere a versão, roda formatação, análise e testes, gera os arquivos e cria a Release em **rascunho** (`-beta`/`-rc` = pré-lançamento). "Run workflow" faz um ensaio sem Release.
- **Scripts:** `tool/release/build_release.ps1` (instalador, ZIP, SHA-256, notas), `release_notes.ps1`, `test_install.ps1` e `sandbox_test.ps1`.
- **Pedido extra:** na janela de 1280 px, a tabela da Carteira cabe inteira, até "Resultado" (classe embaixo do ativo, preço médio embaixo da quantidade, percentual embaixo do resultado). Medido com a Segoe UI: 906 px de tabela numa área de 975 px.
- **Docs:** `DISTRIBUICAO.md`, `SOLUCAO_DE_PROBLEMAS.md`, ARQUITETURA, DESENVOLVIMENTO, README, DECISIONS D-38 a D-40 e `url_launcher` na D-02.

**2. Arquivos criados ou alterados (resumo)**

- Novos: `installer/` (`patrion.iss`, `LEIA-ME-PORTATIL.txt`, `RELEASE_TEMPLATE.md`, `AVISOS_DE_TERCEIROS.txt`), `tool/release/*.ps1`, `.github/workflows/release.yml`, `assets/licenses/`, `lib/application/updates/update_checker.dart`, `lib/infrastructure/updates/github_release_feed.dart`, `lib/infrastructure/system/single_instance.dart`, `lib/presentation/services/open_requests.dart`, `lib/presentation/services/native_licenses.dart`, `lib/presentation/screens/updates/update_widgets.dart`, `docs/DISTRIBUICAO.md`, `docs/SOLUCAO_DE_PROBLEMAS.md`.
- Alterados: `lib/main.dart`, `core/config/` (versão, repositório, arquivos recebidos, pasta `instance`), `window_setup.dart`, Sincronização, Configurações, Início, `app.dart`, `session_host.dart`, `providers.dart`, Carteira, `windows/CMakeLists.txt`, `windows/runner/main.cpp`, `pubspec.yaml` (1.0.0, `pub_semver`, `url_launcher`, assets), `.gitignore` (`dist/`).
- Testes novos: largura da Carteira (com a Segoe UI), instância única, opções da linha de comando, verificador (7), adaptador do GitHub (5), telas de atualização e licenças (4), abertura do `.invsave`, regras do instalador (5).

**3. Testes executados e resultados reais**

- `dart format --set-exit-if-changed .`: 200 arquivos, 0 alterados.
- `flutter analyze`: sem problemas.
- `flutter test`: **447 testes passando**.
- `flutter build windows --release`: compilou.
- `tool/release/build_release.ps1`: gerou `Patrion-1.0.0-instalador.exe` (13,6 MB), `Patrion-1.0.0-portatil.zip` (16,3 MB), `SHA256SUMS.txt` e `RELEASE_NOTES.md`.
- `tool/release/test_install.ps1` neste PC (pastas de teste, dados reais intocados): **26 de 26**.
- CI no GitHub Actions (push `ebce697`): **verde** (run 39194666868). Ensaio do workflow de release ("Run workflow", run 39194693238): **verde** em 8 min; instalou o Inno Setup, gerou instalador, ZIP e somas e guardou o artefato `patrion-release-ensaio`, sem criar Release (a etapa da Release ficou como "skipped", como esperado).

**4. Problemas e limitações**

- **Sem teste em ambiente limpo ainda** (critério de pronto): o Windows Sandbox não está habilitado aqui.
- O teste de atualização usa um instalador "0.9.0" gerado do mesmo build (só o instalador tem outra versão): confere o mecanismo de atualização por cima, não uma migração real entre versões do app.
- O teste automático confere que o `.invsave` chega à janela aberta (pelo log); a prévia na tela foi conferida só no teste de widget. A largura da Carteira também foi medida em teste de widget (com a Segoe UI), não numa captura do app.
- Não assinado: aviso do SmartScreen (documentado). Sem atualização automática (Fase 15).
- O ZIP gerado no PowerShell 5.1 usa `\` nos caminhos internos (o Explorador do Windows abre normalmente); o do workflow usa o PowerShell 7.
- As notas da Release saem do CHANGELOG inteiro da 1.0.0, inclusive dois itens internos ("CI: actions/checkout…" e "Especificação: …"); dá para tirá-los antes de publicar.

**5. Pendências**

- Você: teste em ambiente limpo (roteiro abaixo) e autorizar a tag `v1.0.0`. Depois da tag, revisar a Release em rascunho e publicar.
- Você (antiga): Windows Hello (F5B). A chave da brapi (F6) já está cadastrada e testada.
- F8 em diante, conforme a SPEC.

**6. Como executar e o que testar manualmente**

Os arquivos estão em `dist\` (não versionados): `Patrion-1.0.0-instalador.exe`, `Patrion-1.0.0-portatil.zip`, `SHA256SUMS.txt`, `RELEASE_NOTES.md`. Para gerar de novo: `powershell -ExecutionPolicy Bypass -File tool\release\build_release.ps1`.

**Opção A — Windows Sandbox (recomendado):**

1. Ligue o recurso: Painel de Controle > Programas > "Ativar ou desativar recursos do Windows" > **Área Restrita do Windows** (pede reinicialização). Requer Windows 11 Pro (o seu é) e virtualização ligada na BIOS.
2. No PowerShell, na pasta do projeto: `powershell -ExecutionPolicy Bypass -File tool\release\sandbox_test.ps1`. O Sandbox abre e roda sozinho o teste automático (instalar 0.9.0, abrir, `.invsave` por duplo clique, atualizar com o app aberto, atualizar por cima, desinstalar). Espere o PowerShell do Sandbox terminar e veja `dist\sandbox\trabalho\resultado.txt` (deve dizer 26 de 26).
3. Ainda no Sandbox, faça o roteiro manual da opção B com o instalador em `Desktop\patrion-teste\`. O Sandbox é descartável: ao fechar, tudo some.

**Opção B — roteiro manual** (no Sandbox ou num PC sem Flutter; detalhes em `docs/DISTRIBUICAO.md`, "Testes de distribuição"):

1. **Instalar:** dois cliques em `Patrion-1.0.0-instalador.exe`. Confira o SmartScreen ("Mais informações" > "Executar assim mesmo"), que não pede administrador, a opção do `.invsave` marcada, o atalho no Menu Iniciar e o app abrindo no fim.
2. **Usar:** cadastre instituição e conta, registre um depósito e uma compra. Na Carteira, com a janela no tamanho padrão, a coluna "Resultado" aparece sem rolar para o lado.
3. **Fechar e reabrir:** os dados continuam. Configurações > Sobre mostra 1.0.0; "Licenças de terceiros" lista SQLCipher e OpenSSL.
4. **Offline:** sem rede, o app abre com o aviso "Sem conexão"; Configurações > Atualizações > "Verificar agora" mostra "Sem conexão" e nada trava.
5. **Save:** Sincronização > "Salvar arquivo de save". Feche o app e dê dois cliques no arquivo: o app abre na Sincronização com a prévia. Repita com o app aberto: a janela vem para a frente com a prévia, sem abrir outra. (Entre duas instalações: leve o arquivo ao outro PC ou Sandbox.)
6. **Atualizar sem perder dados:** com o app aberto, execute o instalador de novo: ele pede para fechar o app. Feche, continue; os dados continuam. (Com uma versão mais nova no futuro, o mesmo vale.)
7. **Desinstalar sem perder dados:** "Aplicativos instalados" > Patrion > Desinstalar. A mensagem final mostra `%APPDATA%\Patrion`. Confira que a pasta continua com `patrion.db`, `backups\` e `logs\`, que o atalho sumiu e que o `.invsave` não abre mais com o Patrion. Reinstale: a carteira volta como estava.
8. **Portátil:** extraia o ZIP, abra `Patrion\patrion.exe`; ele usa os mesmos dados da instalada (não abra as duas juntas: a segunda só traz a primeira para a frente).

**Neste PC (com Flutter)**, sem tocar nos seus dados: `powershell -ExecutionPolicy Bypass -File tool\release\test_install.ps1 -OldInstaller <instalador 0.9.0> -NewInstaller dist\Patrion-1.0.0-instalador.exe -WorkDir C:\temp\teste -DataDir C:\temp\teste\dados -InstallDir C:\temp\teste\app` (o 0.9.0 sai de `build_release.ps1 -SkipBuild -Version 0.9.0 -OutDir dist-0.9.0`).

### Fase 6 — Dados de mercado

Critério de pronto (SPEC §21): as cotações reais aparecem com fonte e data; o app funciona sem internet.

- **Cotações reais com fonte e data: verificado no app real** (build release, pasta de dados de teste separada da sua): PETR4 pela brapi (16/10/2026 23:29, intradiário com até 30 min de atraso), BTC pela CoinGecko, HGLG11 pelo fechamento do COTAHIST (16/10/2026) e Tesouro Selic 2031 pelo Tesouro Transparente (15/10/2026, com o ícone de desatualizado), além de USD e EUR pela PTAX (16/10/2026) e IPCA pelo IBGE (09/2026).
- **Sem internet: verificado no app real**, com o app aberto sem acesso à rede (proxy inexistente só para o processo do Patrion): aviso "Sem conexão", carteira e Início com os últimos valores guardados, cada um com a sua data. Também coberto por testes automáticos.

**1. O que foi implementado**

- **Pendências da F1:** nenhuma fonte é inviável. Finnhub (gratuito: só cotação dos EUA; histórico pago) e Twelve Data (Basic: 8 créditos/min, 800/dia; EUA, câmbio e cripto; B3 pago) confirmados na documentação oficial. Tesouro Transparente e CVM: licença ODbL. O SGS passou a exigir `User-Agent` e o Frankfurter mudou de endereço (D-35).
- **Adaptadores** (um por provedor, atrás de interfaces): BCB SGS e PTAX, IBGE SIDRA, Frankfurter, brapi, B3 COTAHIST, B3 proventos e eventos, Tesouro Transparente, CVM, CoinGecko, Binance, Finnhub, Twelve Data e Yahoo (desligado por padrão). Acesso HTTP com timeout, retentativa com backoff, `Retry-After`, fila e intervalo mínimo por provedor e deduplicação.
- **Cache** nas tabelas `mkt_` (schema 4), por chave natural, cada dado com fonte, data de referência, data de coleta e tipo. Estado de cada provedor em `dev_provider_state` (ligado, último sucesso, último erro, cota do mês).
- **Atualização automática** com o app aberto (5 s depois de abrir e a cada 30 minutos; 15, 60, 240 ou desligada) e **manual**: carteira inteira ("Atualizar agora"), um ativo ("Atualizar este ativo"), histórico ("Baixar histórico") e teste de cada provedor. Só ativos com posição aberta e "cotação automática"; sempre a partir do último dado guardado.
- **COTAHIST:** só os anos (ou os dias recentes) que faltam, a partir do ano inicial configurável (padrão: 5 anos atrás); o ZIP e o TXT são apagados depois da extração, inclusive em falha. Verificado com a B3 real: a pasta de cache fica vazia depois.
- **Câmbio, CDI, Selic e IPCA:** PTAX (alternativa BCE), SGS (CDI, Selic, meta Selic, IPCA, IGP-M) e SIDRA (IPCA). CDI anualizado e IPCA em 12 meses calculados (FORMULAS §2.2). Painel "Câmbio e indicadores" no Início e em Fontes de dados.
- **Patrimônio total em reais** no Início quando há mais de uma moeda (FORMULAS §2.3), indisponível se faltar o câmbio de alguma moeda.
- **Tela "Fontes de dados"** (`/fontes`): o que cada provedor fornece e recebe, licença, limites, estado, liga/desliga, chave de API, teste, intervalo da atualização e ano inicial do histórico.
- **Chaves de API (D-34):** digitadas só na tela, num campo oculto; guardadas em `patrion.apikeys.bin` na pasta de dados, protegido pelo DPAPI do Windows; fora do banco, do save, dos backups e do log; enviadas só em cabeçalho, nunca na URL.
- **Fonte de preço do ativo:** "cotação automática" ou "preço ou saldo informado" no cadastro (sugerida pela classe). Os ativos criados antes da F6 continuam com preço informado; Fontes de dados oferece trocá-los de uma vez.
- **Avaliação:** num ativo com cotação automática, vale o mais recente entre o informado e o de mercado; na mesma data, o informado (FORMULAS §2.1).
- **Save (D-36):** pasta `market/` opcional (marcada por padrão), mesclada pela coleta mais recente; formato 2 só quando leva dados de mercado.
- **brapi (D-37, pedido durante a fase):** na atualização automática, só em horário de pregão da B3 (dias úteis, 10:00 às 18:30 de Brasília) e no máximo a cada 30 minutos por ativo; "Fontes de dados" mostra a cota do mês usada (número, percentual e barra); aviso a partir de 80% (no resumo da atualização e no Início); cota esgotada: a brapi não é chamada e os ativos da B3 usam o fechamento oficial do COTAHIST.
- Decisões D-34 a D-37; FORMULAS §2.1 a §2.3; FONTES_DE_DADOS, SINCRONIZACAO, BANCO e ARQUITETURA atualizados.

**2. Arquivos criados ou alterados (resumo)**

- Domínio: `lib/domain/market/` (`market_data.dart`, `provider_catalog.dart`, `market_price.dart`, `market_indicators.dart`); `domain/portfolio/portfolio_valuation.dart`; `domain/sync/invsave_codec.dart` e `save_manifest.dart` (pasta `market/`).
- Aplicação: `lib/application/market/` (`market_ports.dart`, `market_data_service.dart`, `market_price_book.dart`, `market_overview.dart`), `settings/market_preferences.dart`, `portfolio/portfolio_query.dart`, `sync/save_service.dart`.
- Dados: `data/db/tables.dart` (schema 4) e migração, `repositories/market_repository.dart`, `repositories/provider_state_repository.dart`, `sync/market_save_gateway.dart`.
- Infraestrutura: `infrastructure/market/` (`market_http.dart`, `market_setup.dart`, `providers/*.dart`), `security/api_key_store.dart`, `core/json/exact_json.dart`.
- Interface: `screens/market/data_sources_screen.dart`, `services/market_refresh.dart`, `format/market_labels.dart`; Início, Carteira, detalhe do ativo, cadastro do ativo, diálogo e prévia do save, navegação e `providers.dart`.
- Testes: `test/domain/market/`, `test/application/market/`, `test/application/sync/save_market_test.dart`, `test/data/repositories/market_repository_test.dart`, `test/infrastructure/market/` (com respostas reais em `test/fixtures/market/`), `test/infrastructure/security/api_key_store_test.dart`, `test/presentation/data_sources_screen_test.dart`.

**3. Testes executados e resultados reais**

- `dart format` (nenhuma mudança), `flutter analyze` (sem problemas), `flutter test`: **419 testes passando**; `flutter build windows --release` compilou.
- CI: o primeiro run (commit `5ca9880`) falhou em 2 testes porque a fixture do COTAHIST não tinha ido para o repositório (a regra `COTAHIST_*` do `.gitignore` a excluía no Windows); corrigido com uma exceção para `test/fixtures/`. **CI verde** ([run 39185712361](https://github.com/LuccaBueno/patrion/actions/runs/39185712361), commit `21c9b43`, 419 testes; format, analyze, código gerado e build release passaram).
- Novos: regras do preço de mercado, Tesouro, desatualização, CDI anualizado, IPCA 12 meses (com mês faltando = indisponível), patrimônio em reais; avaliação com preço de mercado; repositório (preços, câmbio, indicadores, Tesouro, cotações) e estado dos provedores (cota mensal); serviço (cotação com fonte e data na carteira, só o código vai ao provedor, provedor desligado, falha com fonte seguinte, PTAX fora → BCE, cota atingida, sem internet com os dados guardados e parada antecipada, histórico só dos trechos que faltam, indicadores incrementais, chamadas simultâneas); save com dados de mercado (ida e volta, coleta mais nova vence, sem a opção, com senha); codec (formato 2, conteúdo alterado, valor não texto); cofre de chaves com o DPAPI real; telas (provedores, chave some da tela, "Atualizar agora" sem internet, cotação da brapi com fonte e data, troca dos ativos antigos para cotação automática); a tela nova em janela estreita. Da D-37: janela de pregão (horários, fim de semana, feriado, fuso), brapi fora do pregão só na manual, intervalo de 30 minutos, aviso de 80%, cota esgotada com o COTAHIST na carteira e contagem nova no mês seguinte, e a cota e o aviso na tela.
- **Verificação com a internet real** (script de verificação fora do repositório, numa pasta de dados de teste, sem chaves): brapi (PETR4), COTAHIST (fechamentos diários e histórico de 01/10 a 16/10/2026), Tesouro, CVM, CoinGecko, PTAX, SIDRA e proventos da B3 (169 registros da PETR4) responderam. Depois, o app real (build release) com a mesma pasta, com e sem rede (capturas só da janela do Patrion).
- **Não verificado com dados reais:** Finnhub, Twelve Data e CoinGecko com chave (precisam das suas chaves; cobertos por testes com respostas reais gravadas) e o SGS do Banco Central (fora do ar, ver item 4).

**4. Problemas e limitações**

- **SGS do Banco Central fora do ar** desde pelo menos 17/10/2026 16:25 até 18/10/2026 22:00: toda consulta com dados responde uma página "Requisição inválida", e o próprio site do SGS (`www3.bcb.gov.br/sgspub`) responde erro 500. Parece indisponibilidade do serviço (fim de semana), não mudança da API, por isso não tratei como fonte inviável. Enquanto isso, CDI, Selic, meta Selic e IGP-M ficam "indisponíveis" (sem nada inventado) e o IPCA vem do IBGE. **Se continuar fora nos próximos dias úteis, me avise para eu procurar uma alternativa** (com sua aprovação, como pede o CLAUDE.md).
- **brapi sem chave** responde agora só PETR4, VALE3, MGLU3 e ITUB4 (MXRF11 e HGLG11 passaram a pedir chave entre 17 e 18/10). Sem chave, os outros ativos da B3 usam o fechamento oficial do COTAHIST do último pregão.
- Os ativos que você cadastrou antes da F6 estão com "preço informado": use "Usar cotações" em Fontes de dados (ou Editar no ativo) para passá-los à cotação automática.
- O histórico guardado é o preço bruto da fonte. O ajuste por proventos e eventos, o TWR, a rentabilidade por período, a evolução patrimonial e os benchmarks na tela ficam para a F8 (§12; a SPEC não os põe na F6). O PROGRESS da F4 dizia "F6" para essa exibição: ela foi para a F8 porque depende do ajuste por eventos e da tela de benchmarks.
- Sem internet, a primeira atualização ainda tenta duas fontes (cerca de 20 s) antes de concluir que o PC está sem rede.
- Numa janela de 1280 px, a coluna "Resultado" da Carteira fica fora da área visível (a tabela rola na horizontal).
- A cotação da CoinGecko sem chave tem limite baixo e compartilhado por IP; a do Tesouro é a da manhã do último dia útil publicado.
- A cota da brapi é contada só neste PC; se a mesma chave for usada em outro computador, o uso real é maior que o mostrado (a tela avisa).
- O save com dados de mercado usa o formato 2: uma versão anterior do app recusa esse arquivo ("formato mais novo"); atualize o app nos dois PCs ou desmarque a opção.

**5. Pendências**

- Você: testar com a sua chave da brapi (roteiro abaixo); opcionalmente, Finnhub, Twelve Data e CoinGecko.
- Você (da F5B): Windows Hello num PC com o Hello configurado.
- Conferir o SGS de novo num dia útil; se seguir fora, decidir uma alternativa para CDI e Selic.
- F7: instalador e ZIP, associação do `.invsave`, avisos de licença do SQLCipher, do OpenSSL e as atribuições das fontes de dados.
- F8: ajuste por proventos e eventos, TWR, rentabilidade por período, evolução, benchmarks, retorno real e efeito cambial na tela.
- F9: `hypo_runs`; F11: pasta de sincronização.

**6. Como executar e o que testar manualmente**

```powershell
flutter build windows --release
```

ou abra `build\windows\x64\runner\Release\patrion.exe`.

**Roteiro com a sua chave da brapi** (a chave é digitada só no app; não me mande a chave):

1. Abra o app e vá em **Fontes de dados**. No card **brapi**, confira "Envia: só o código do ativo… e a sua chave" e os limites do plano gratuito.
2. Cole ou digite a chave no campo **Chave de API** e clique **Guardar chave**. O campo some e aparece "Chave cadastrada neste computador".
3. Clique **Testar conexão** no card da brapi. Deve aparecer "brapi respondeu corretamente." e o estado "Funcionando · último acesso em …".
4. Se os seus ativos foram cadastrados antes desta fase, use **Usar cotações** no aviso do topo de Fontes de dados (ou **Editar → Preço: Cotação automática** em cada ativo).
5. Clique **Atualizar agora** e espere o aviso de conclusão (sem o SGS, aparece "falha em Banco Central — SGS"; isso é esperado enquanto ele estiver fora do ar).
6. Em **Carteira**, cada ativo da B3 deve mostrar o valor com "brapi · data hora" embaixo. Passe o mouse no valor: tipo (intradiário), coleta e "atraso de até 30 min (plano gratuito da brapi)". Confira um ativo que não seja PETR4, VALE3, MGLU3 ou ITUB4 (sem chave ele viria do COTAHIST).
7. Abra um ativo e veja o card **Dados de mercado** (fonte, data, tipo, coleta, atraso). Clique **Baixar histórico**: o "Histórico guardado" passa a mostrar os dias e o período.
8. Em Fontes de dados, a linha "Cota do mês" da brapi deve contar as requisições (número, percentual e barra). A atualização automática só consulta a brapi em dia útil, das 10:00 às 18:30, e no máximo a cada 30 minutos por ativo: fora desse horário, deixe o app aberto e confira que a data da cotação não muda (a manual consulta a qualquer hora).
9. Opcional: **Apagar** a chave. A brapi passa a atender só PETR4, VALE3, MGLU3 e ITUB4; os outros ativos da B3 voltam a mostrar o fechamento do COTAHIST, com a data do pregão.
10. Sem internet (desligue o Wi-Fi), clique **Atualizar agora**: aparece "Sem conexão…" e os valores continuam, com a data de cada um.
11. Opcional: **Salvar arquivo de save** com "Levar os dados de mercado já baixados" e importe no outro PC; lá, a carteira deve mostrar os mesmos preços e datas mesmo sem internet.

### Fase 5B — Bloqueio do app

Critério de pronto (SPEC §21): os testes obrigatórios de §3 passam, e um banco já existente é convertido para criptografado e volta a abrir no app real, com Windows Hello e com a senha.

- **Com a senha: verificado no app real.**
- **Com o Windows Hello: não foi possível verificar neste PC**, que não tem o Windows Hello configurado (o Windows responde `DeviceNotPresent`). A parte do Hello está implementada e coberta por teste com dublê, mas precisa do seu teste manual num PC com Hello (roteiro abaixo, passo 9).

Antes da F5B, as duas pendências da F5 foram resolvidas (commits `745585a` e `be6f8cc`). CI verde ([run 39156647820](https://github.com/LuccaBueno/patrion/actions/runs/39156647820), commit `ae96edf`, 329 testes).

**1. O que foi implementado**

- **Pendências da F5:**
  - A prévia da importação **avisa, antes de aplicar, quando a carteira resultante fica inconsistente** (venda maior que a posição, transferência sem a ponta de saída, ativo inexistente, moeda diferente). O app aplica o plano numa transação que é sempre desfeita, recalcula a carteira e mostra só as inconsistências novas, com ativo, conta e data. O aviso não bloqueia e é recalculado quando o usuário troca a versão de um conflito. Essa conferência não grava nada nem avança o relógio HLC.
  - **Teste da falha ao reabrir no meio de uma restauração**: o arquivo do backup já está no lugar do banco quando a reabertura falha. O teste confere que o app volta o banco anterior **intacto, registro a registro (inclusive HLCs)**, íntegro, com a mesma identidade e o mesmo HLC, e sem arquivo temporário sobrando.
- **Banco criptografado com SQLCipher** (D-32): o `sqlite3` passou a usar o build do SQLCipher 4.19 (SQLite 3.53.4), sem pacote novo. A chave é aleatória, de 256 bits, passada como chave bruta.
- **Arquivo de chaves** `patrion.keys.json`: a chave do banco embrulhada (AES-256-GCM) pela senha e pela chave de recuperação, com Argon2id (64 MiB, 3 passadas). A senha nunca é guardada.
- **Ativar e desativar** em Configurações → "Bloqueio do app":
  - backup antes (`pre-bloqueio`, `pre-desbloqueio`);
  - conversão conferida (integridade, versão, contagens) e troca em dois tempos, com volta ao estado anterior se algo falhar;
  - ao ativar, os backups antigos da pasta de backups também são criptografados (opção marcada por padrão).
- **Tela de desbloqueio** na abertura; **"Bloquear agora"**; **bloqueio por inatividade** (padrão 15 min; 1, 5, 30, 60 min ou nunca), que fecha o banco, descarta as telas e os provedores e zera a chave.
- **Chave de recuperação** mostrada uma única vez (o diálogo só fecha depois de "Guardei a chave de recuperação"). "Esqueci a senha" pede a chave e uma nova senha. Também dá para trocar a senha e gerar nova chave de recuperação.
- **Windows Hello** opcional: a chave do banco é guardada protegida pelo DPAPI da conta do Windows (`patrion.hello.bin`) e só é lida depois da confirmação do Hello. A limitação (não protege contra quem está logado na mesma conta) aparece nas Configurações.
- **Backups criptografados**: cada um leva o `keyId` nos metadados e uma cópia do arquivo de chaves ao lado. Restaurar converte para a criptografia atual; um backup de uma chave anterior pede a senha da época.
- **Interrupções**: ao abrir, o app reconhece uma ativação ou desativação interrompida pelo estado dos arquivos e segue sem perder dados. Banco criptografado sem o arquivo de chaves mostra como recuperar.
- **Senha do arquivo de save**:
  - ao salvar, "Proteger o arquivo com senha" (marcado por padrão com o bloqueio ativo);
  - o arquivo vira `manifest.json` (sem dados) + `payload.bin` cifrado (AES-256-GCM, Argon2id);
  - ao importar, o app pede a senha; "Importar e gerar novo save" oferece a mesma senha;
  - a versão da F5 recusa esse arquivo dizendo que ele é protegido por senha.
- Documentos: `BLOQUEIO.md` (novo); decisões D-32 e D-33.

**2. Arquivos criados ou alterados**

- `lib/core/crypto/` (novo): `crypto_box.dart` (Argon2id, AES-GCM, aleatórios), `database_key.dart`.
- `lib/domain/`:
  - `security/` (novo): `key_file.dart`, `recovery_key.dart`;
  - `sync/invsave_codec.dart` (`protect`, `unprotect`, `readManifest`) e `sync/save_manifest.dart` (parâmetros da criptografia);
  - `backup/backup_metadata.dart` (`keyId`, motivos novos).
- `lib/application/`:
  - `security/security_ports.dart` e `settings/lock_preferences.dart` (novos);
  - `backup/backup_service.dart` e `backup_ports.dart` (chave, cópia do arquivo de chaves, backups de outra chave, criptografar os antigos);
  - `sync/save_service.dart` (conferência da carteira resultante, senha do arquivo).
- `lib/data/`: `db/app_database.dart` (`open` com chave), `sync/sync_tables_gateway.dart` (aplicação sem avançar o HLC, para a prévia).
- `lib/infrastructure/`:
  - `security/` (novo): `key_file_store.dart`, `database_encryption.dart`, `windows_hello.dart`, `dpapi.dart`;
  - `backup/database_file_inspector.dart` (chave, conversão), `local_backup_file_system.dart`, `pre_migration_backup.dart`.
- `lib/presentation/`:
  - `session/app_session.dart` (fases, desbloqueio, ativar/desativar, restauração com chaves), `session_host.dart`, `inactivity_guard.dart` (novo);
  - `screens/security/` (novo: tela de desbloqueio, seção das Configurações, diálogos);
  - `screens/sync/save_password_dialog.dart` (novo), `sync_screen.dart`, `import_preview_dialog.dart`;
  - `screens/backup/backup_screen.dart`, `settings_screen.dart`, `providers.dart`, `format/sync_labels.dart`;
  - `lib/main.dart`.
- `pubspec.yaml`/`.lock`: SQLCipher pelo hook do `sqlite3`; `pointycastle` 4.0.0, `local_auth` 3.0.2, `ffi` 2.2.0 (D-32). `windows/flutter/` (registro do plugin do `local_auth`) e `windows/CMakeLists.txt` (compilação do plugin no Visual Studio 18).
- `test/`:
  - novos: `presentation/session/app_lock_test.dart`, `presentation/security_screens_test.dart`, `domain/security/key_file_test.dart`, `infrastructure/security/hello_vault_test.dart`, `helpers/fake_security.dart`;
  - ampliados: `application/sync/save_sync_test.dart`, `application/backup/backup_service_test.dart`, `presentation/sync_backup_screens_test.dart`, `helpers/sync_pc.dart`.
- Docs: `BLOQUEIO.md` (novo); `DECISIONS.md`, `BACKUP.md`, `SINCRONIZACAO.md`, `ARQUITETURA.md`, `BANCO.md`, `DESENVOLVIMENTO.md`, `PROGRESS.md`, `README.md`, `CHANGELOG.md`.

**3. Testes executados (18/10/2026)**

- `dart run build_runner build`: sem diferenças no código versionado.
- `dart format --set-exit-if-changed .`: 150 arquivos, 0 alterados.
- `flutter analyze`: "No issues found!".
- `flutter test`: **329 testes, todos passaram** (285 na F5). Entre os novos:
  - **Testes obrigatórios de SPEC §3**, com banco em arquivo e o SQLCipher de verdade (`app_lock_test.dart`, 19 testes):
    - banco ilegível sem a chave: o SQLite não abre ("file is not a database"), o texto não aparece no arquivo, o arquivo de chaves não tem a senha nem a chave;
    - senha errada recusada, o app continua bloqueado;
    - troca de senha sem perda de dados (a antiga deixa de valer);
    - recuperação pela chave (digitada em minúsculas, sem hífens, com O no lugar de 0) com nova senha;
    - bloqueio fecha o banco (consultas falham) e zera a chave; outro início do app pede a senha;
    - backup criptografado restaurável; backup sem criptografia restaurado com o bloqueio ativo fica criptografado; backup de uma chave anterior só restaura com a senha da época; backups antigos criptografados ao ativar continuam restauráveis;
    - migração de schema 2 → 3 com o banco criptografado: backup anterior à migração criptografado, com o arquivo de chaves ao lado, e dados preservados;
    - desativar com a senha (senha errada recusada); Windows Hello com dublê (ativa, desbloqueia, recusa sem confirmação, indisponível não ativa); ativação interrompida; banco criptografado sem arquivo de chaves.
  - Chave de recuperação já pendente quando a sessão nova aparece: o teste falhava antes da correção do bug do item 4.
  - Arquivo de chaves com os **parâmetros de produção** (Argon2id 64 MiB), AAD (uma cópia não serve no lugar da outra), arquivo alterado, formato da chave de recuperação; AES-GCM recusa chave, nonce e AAD errados; DPAPI real.
  - Inatividade com relógio falso (1 min sem uso bloqueia; o uso adia; "nunca" e bloqueio desativado não bloqueiam); tela de desbloqueio; seção das Configurações; diálogo da chave de recuperação.
  - Save com senha: ida e volta, pede a senha, senha errada não muda nada, conteúdo ilegível no arquivo, byte alterado no conteúdo cifrado recusado (mesmo com o SHA-256 refeito), parâmetros de produção, e pela interface (salvar com senha num PC e importar no outro).
  - Pendências da F5: conferência da carteira resultante (3 testes de serviço e 1 de tela) e falha ao reabrir no meio da restauração.
- `flutter build windows --release`: compilou `patrion.exe` (com `sqlcipher.dll`).
- **Execução real do `.exe`** com uma pasta de dados de teste (`--data-dir`), semeada pelos serviços do app com um banco **sem criptografia** já existente (Corretora Exemplo, conta Principal, PETR4: compra de 100 × R$ 30,00) e um backup manual. Comandado por cliques e teclado, conferido por captura da janela do app:
  1. Configurações → "Ativar o bloqueio…" → senha duas vezes → "Ativar". Aviso "Bloqueio ativado. O banco de dados agora é criptografado." e a **chave de recuperação** no diálogo (copiada pelo botão do app).
  2. App fechado. No disco: `patrion.db` criptografado e sem o texto "Corretora Exemplo"; `patrion.keys.json` sem a senha; o backup manual antigo e o `pre-bloqueio` criptografados, cada um com o `.keys.json` ao lado.
  3. App aberto de novo: **tela de desbloqueio**. Senha errada → "Senha incorreta." e continua bloqueado. **Senha certa → Carteira com PETR4, 100 ações, R$ 30,00, custo R$ 3.000,00.**
  4. "Bloquear depois de" = 1 minuto, sem mexer: aos 50 s o app continuava aberto; aos 75 s estava na tela de desbloqueio (**inatividade**).
  5. "Esqueci a senha" → chave de recuperação digitada em minúsculas + nova senha → app aberto com "Senha redefinida.".
  6. "Bloquear agora" → senha antiga recusada → nova aceita.
  7. Backup → "Restaurar" no backup manual (criptografado na ativação) → confirmação → "Backup restaurado". O banco continua criptografado e a Carteira mostra PETR4 com 100 ações.
  8. Log: registra ativação, senha incorreta, bloqueio, redefinição e aberturas, **sem senha, sem chave de recuperação e sem valores**.
  - **Não verificado no app real:** Windows Hello (este PC não tem o Hello configurado; a opção aparece desativada com "não está configurado neste computador", que é o comportamento esperado). Desativar o bloqueio e o save com senha foram verificados só pelos testes automáticos.
- CI: o primeiro run (commit `04d2816`) falhou no build: o runner `windows-latest` passou a usar o Visual Studio 18 (MSVC 14.51), que recusa as corrotinas experimentais usadas pelo plugin `local_auth_windows`. Corrigido em `windows/CMakeLists.txt` (D-32). **CI verde** ([run 39156647820](https://github.com/LuccaBueno/patrion/actions/runs/39156647820), commit `ae96edf`, 329 testes; analyze, format, código gerado e build release passaram).

**4. Problemas e limitações**

- **Bug encontrado na execução real e corrigido:** depois de ativar, a chave de recuperação não aparecia (a tela nova procurava a chave antes de o gerenciador guardá-la). Corrigido (`a398682`), com teste que falhava antes da correção. Também ajustado: depois de uma senha errada, o cursor volta ao campo da senha.
- O Windows Hello não pôde ser testado neste PC (ver acima).
- A chave fica na memória enquanto o app está desbloqueado (é preciso, para o banco funcionar). Ao bloquear, os bytes da chave são zerados, mas o texto do `PRAGMA key` é uma `String` do Dart, que não pode ser zerada: some quando o coletor de lixo a recolhe (D-33).
- Com o Windows Hello ativo, quem está logado na sua conta do Windows consegue ler a cópia da chave sem o Hello (limitação do DPAPI, mostrada nas Configurações; D-24).
- O botão "Copiar" do diálogo da chave de recuperação põe a chave na área de transferência do Windows (que pode ter histórico ativado). Prefira anotar ou imprimir.
- Sem limite de tentativas de senha: o Argon2id (~1 s por tentativa) é o freio (D-33).
- Ao ativar, backups sem criptografia **fora** da pasta de backups (feitos com "Backup em outra pasta") ficam como estão; a tela avisa quantos.
- Trocar a senha não muda as cópias `.keys.json` dos backups já feitos. Eles continuam abrindo com a chave atual do banco (mesmo `keyId`); se o bloqueio for desativado e ativado de novo, um backup antigo pede a senha que valia quando ele foi feito.
- A pasta `build\windows\x64\runner\Release\` tinha uma `sqlite3.dll` de builds antigos (sobra; o app usa a `sqlcipher.dll`). O CI sempre parte do zero. Na distribuição (F7), incluir os avisos de licença do SQLCipher (BSD-3) e do OpenSSL (Apache-2.0).
- Durante uma ação demorada da tela Backup, a barra de progresso aparece atrás do diálogo de confirmação (comportamento da F5, só visual).

**5. Pendências**

- Você: testar o Windows Hello num PC com o Hello configurado (roteiro, passo 9).
- F6: incluir `market/` no save; chaves de API (o `flutter_secure_storage` da D-02 será revisto, D-32).
- F7: associar `.invsave` no instalador; avisos de licença do SQLCipher e do OpenSSL.
- F9: `hypo_runs` e a opção de levar a série no save; telas das carteiras hipotéticas.
- F11: pasta de sincronização (§10.6).
- Da F1: confirmar Finnhub e Twelve Data (F6); licenças do CKAN do Tesouro e do portal da CVM (F6); toolchain Android (futuro).

**6. Como executar e o que testar manualmente**

```powershell
flutter build windows --release
```

**Roteiro: senha, bloqueio por inatividade e chave de recuperação.** Use uma pasta de teste, para não mexer nos seus dados.

Preparação:

1. Abra o app com uma pasta de teste e crie alguns dados (uma instituição, uma conta, um ativo e uma compra):

   ```powershell
   build\windows\x64\runner\Release\patrion.exe --data-dir C:\PatrionTeste\Bloqueio
   ```

   Faça também um backup (Backup → "Fazer backup agora").

Ativar e senha:

2. Configurações → "Bloqueio do app" → "Ativar o bloqueio…":
   - tente uma senha curta ou duas senhas diferentes: o app recusa e explica;
   - use uma senha com 8 caracteres ou mais, deixe marcado "Criptografar também os backups…" e clique em "Ativar".
3. Aparece a **chave de recuperação** (32 caracteres em 8 grupos). Anote-a. O botão "Concluir" só libera depois de marcar "Guardei a chave de recuperação". O aviso "Bloqueio ativado…" aparece nas Configurações.
4. Feche o app. Em `C:\PatrionTeste\Bloqueio\` confira que existe `patrion.keys.json`. Se quiser, abra o `patrion.db` num editor de texto: não aparece nenhum nome que você cadastrou (com o bloqueio desativado, aparecem).
5. Abra o app de novo: aparece **"Patrion bloqueado"**.
   - digite uma senha errada: "Senha incorreta." e nada abre;
   - digite a senha certa: o app abre com os seus dados.
6. Configurações → "Trocar a senha…" (senha atual + nova duas vezes). Depois "Bloquear agora": a senha antiga é recusada e a nova abre.

Bloqueio por inatividade:

7. Configurações → "Bloquear depois de" → "1 minuto". Não mexa no mouse nem no teclado sobre o app por pouco mais de 1 minuto: o app volta à tela de bloqueio. Repita mexendo no app a cada 30 segundos: ele não bloqueia. Depois, volte a 15 minutos (ou escolha "Nunca" para conferir que ele não bloqueia).

Chave de recuperação:

8. Na tela de bloqueio, "Esqueci a senha":
   - digite uma chave errada: o app recusa;
   - digite a chave do passo 3 (pode ser em minúsculas e sem os hífens) e uma nova senha duas vezes: o app abre com "Senha redefinida.";
   - "Bloquear agora": a senha antiga não abre mais; a nova abre;
   - (opcional) "Gerar nova chave de recuperação…": pede a senha e mostra outra chave; a anterior deixa de valer.

Windows Hello (num PC com o Hello configurado: rosto, digital ou PIN):

9. Configurações → ligue "Desbloquear com o Windows Hello": o Windows pede a confirmação.
   - "Bloquear agora" → na tela de bloqueio, "Usar o Windows Hello" → confirme → o app abre;
   - cancele uma vez para ver que nada abre;
   - feche e abra o app e repita;
   - desligue a opção e confira que o botão some da tela de bloqueio.

Backups e save com senha:

10. Backup: os backups aparecem como "criptografado". Restaure o backup do passo 1 (criptografado na ativação): os dados voltam e o app continua com o bloqueio.
11. Sincronização → "Salvar arquivo de save": "Proteger o arquivo com senha" vem marcado; defina uma senha. Em outra pasta de dados (outro "PC", `--data-dir C:\PatrionTeste\B`), "Importar save…": o app pede a senha do arquivo. Com a senha errada, "Senha do arquivo incorreta…"; com a certa, a prévia aparece.

Desativar:

12. Configurações → "Desativar o bloqueio…" → senha. O app reabre sem pedir senha, `patrion.keys.json` some da pasta e os dados continuam. Os backups criptografados continuam pedindo a senha da época para serem restaurados.

Aviso de carteira inconsistente na importação (pendência da F5):

13. Com duas pastas sincronizadas (roteiro da Fase 5) e um ativo com 100 ações nos dois: venda 80 em A e 50 em B (datas diferentes). Salve um save em A e importe em B: a prévia mostra "Depois de aplicar, a carteira fica com 1 operação inconsistente", com o ativo, a conta e a data da venda que fica sem posição.

O que conferir também: o log (`C:\PatrionTeste\Bloqueio\logs\patrion.log`) registra ativação, bloqueios e senhas incorretas sem a senha, sem a chave de recuperação e sem valores.

**Importante:** sem a senha e sem a chave de recuperação, os dados criptografados não podem ser recuperados. Procedimentos de recuperação em `docs/BLOQUEIO.md`.

### Fase 5 — Backup e save

Critério de pronto: os testes de SPEC §10.7 passam (com os casos S1 a S10 de `CASOS_DE_TESTE.md` §9) e a sincronização manual entre duas pastas de dados funciona. As duas coisas foram verificadas: pelos testes automáticos e no executável real, com duas pastas de dados, clicando na interface e nos diálogos do Windows (detalhes no item 3). CI verde ([run 39073060690](https://github.com/LuccaBueno/patrion/actions/runs/39073060690), commit `67c5b2f`, 285 testes).

**1. O que foi implementado**

- **Arquivo de save `.invsave`** (SPEC §10.1 e §10.2): ZIP com `manifest.json`, `manifest.sha256` e `data/<tabela>.jsonl`, com todas as tabelas sincronizáveis, inclusive tombstones. O manifesto tem as versões do formato, do app e do schema, o PC de origem, a data UTC, o HLC máximo, as contagens, o SHA-256 de cada arquivo, o que o autor já recebeu de cada PC (`knownPeers`) e o **campo de criptografia** (`encryption: none`), reservado para a senha do arquivo da F5B (D-24). Nome padrão `Patrion_<PC>_<AAAA-MM-DD_HHmm>.invsave`; ao salvar, um resumo.
- **Importação com mesclagem** (§10.3 e §10.4):
  - validação completa antes de tocar no banco: ZIP, checksums, contagens, HLC máximo, formato, schema (mais novo é recusado; mais antigo é convertido), colunas e referências;
  - prévia com alterações por tabela, conflitos (com a escolha da versão), unificações e possíveis duplicatas;
  - backup automático antes de aplicar e aplicação numa única transação;
  - telas recalculadas na hora e registro no histórico.
- **Regras da mesclagem** (D-29), planejadas em Dart puro: por `id` e HLC; conflito quando o registro mudou dos dois lados desde a última troca (usando o que cada PC sabe do outro); aliases e unificação por chave natural (instituição, conta, ativo, características de renda fixa, configuração compartilhada), com o registro de menor `id` permanecendo; duplicatas só sinalizadas. Toda alteração feita pela mesclagem é carimbada com o HLC local, então A→B e B→A deixam os bancos idênticos.
- **"Importar e gerar novo save"** e aviso, sem bloquear, quando a última sincronização com algum PC tem 7 dias ou mais (§10.5).
- **Backup** (§11): manual na pasta de backups ou em outra pasta; cópia com `VACUUM INTO`, conferida (integridade e versão); data, motivo, schema e versão do app no nome; metadados num `.json` ao lado e em `dev_backups`, com SHA-256 e **campo de criptografia** (D-24, D-30). Backups automáticos antes de migrar (D-19, agora também registrados), de importar e de restaurar, com retenção dos 10 mais recentes de cada tipo.
- **Restauração**: conferência do arquivo antes da confirmação (integridade, schema, SHA-256, sem criptografia), confirmação explícita, backup do estado atual, troca do arquivo e reabertura do banco sem fechar o app. A identidade deste PC e o relógio HLC nunca voltam (D-28).
- **Sessão do banco que pode ser fechada e reaberta** (`presentation/session/`): a interface é remontada do zero quando a sessão troca. É a base do bloqueio da F5B (D-24, itens 5 e 6). Toda leitura de arquivo de banco fechado passa por `DatabaseFileInspector` (D-24, item 1).
- **Schema 3**: `asset_aliases`; tabelas hipotéticas de configuração (só as tabelas, para o save já levá-las e o S10 ser real); `dev_sync_peers`, `dev_sync_history` e `dev_backups`.
- Telas **Sincronização** e **Backup** na navegação. `docs/BACKUP.md` (novo, com o procedimento de recuperação), `SINCRONIZACAO.md` reescrito, decisões D-28 a D-31.

**2. Arquivos criados ou alterados**

- `lib/domain/sync/` (novo): `sync_rows.dart`, `save_manifest.dart`, `invsave_codec.dart`, `save_contents.dart`, `natural_keys.dart`, `merge_planner.dart`. `lib/domain/backup/backup_metadata.dart` (novo).
- `lib/data/`: `db/tables.dart` e `db/app_database.dart` (schema 3, + `.g.dart` e `app_database.steps.dart` gerados); `sync/sync_tables_gateway.dart` (novo); `sync/device_identity_store.dart` (`adopt`); `repositories/sync_peers_repository.dart` e `backup_registry_repository.dart` (novos).
- `lib/application/`: `sync/save_service.dart`, `backup/backup_service.dart`, `backup/backup_ports.dart` (novos).
- `lib/infrastructure/backup/`: `database_file_inspector.dart`, `local_backup_file_system.dart` (novos); `pre_migration_backup.dart` (metadados e inspetor único).
- `lib/presentation/`: `session/app_session.dart`, `session/session_host.dart`, `screens/sync/` (tela e prévia), `screens/backup/backup_screen.dart`, `services/file_dialogs.dart`, `format/sync_labels.dart` (novos); `providers.dart`, `router/app_router.dart`, `screens/dashboard/dashboard_screen.dart` (aviso). `lib/main.dart` passa a abrir a sessão.
- `drift_schemas/patrion/drift_schema_v3.json`; `test/data/db/migrations/patrion/` (`generated/schema_v3.dart`, teste da migração 2 → 3).
- `test/`: `application/sync/save_sync_test.dart`, `application/backup/backup_service_test.dart`, `domain/sync/merge_planner_test.dart`, `domain/sync/invsave_codec_test.dart`, `presentation/sync_backup_screens_test.dart`, `helpers/sync_pc.dart` (novos); `helpers/app_harness.dart` (pastas, provedores extras, `pumpUntil`), `architecture_test.dart` (real × hipotético), `infrastructure/backup/pre_migration_backup_test.dart`.
- `pubspec.yaml`/`.lock`: `archive` 4.5.2, `crypto` 3.0.7 e `file_picker` 13.1.0, já aprovados em D-02.
- Docs: `BACKUP.md` (novo); `SINCRONIZACAO.md`, `DECISIONS.md`, `BANCO.md`, `ARQUITETURA.md`, `DESENVOLVIMENTO.md`, `PROGRESS.md`, `README.md`, `CHANGELOG.md`.

**3. Testes executados (17/10/2026)**

- `dart run build_runner build`: sem diferenças no código versionado.
- `dart format --set-exit-if-changed .`: 130 arquivos, 0 alterados.
- `flutter analyze`: "No issues found!".
- `flutter test`: **285 testes, todos passaram** (232 na F4). Entre os novos:
  - **S1 a S10**, cada um com teste próprio, entre eles:
    - S3: conflito na prévia, padrão = qtd 30, os dois PCs iguais; e escolhendo a versão 20;
    - S6: com o relógio de B 2 dias adiantado, a edição posterior de A vence; sem troca entre as edições, o conflito aparece e a edição de A pode ser escolhida;
    - S7: PETR4 cadastrado nos dois PCs vira um ativo só, com as operações dos dois e 150 ações; um save antigo não ressuscita o absorvido;
    - S8: um byte alterado no conteúdo é recusado e o banco fica intacto; além disso, alterei cada byte do arquivo, um de cada vez, e nenhum produziu importação diferente da original;
    - S9: falha simulada na 4ª escrita, banco e `dev_sync_peers` iguais aos de antes, histórico com a falha;
    - S10: hipotéticas chegam nas tabelas `hypo_`, totais reais de B iguais.
  - Itens de §10.7 que não são S1 a S10: schema mais novo recusado, schema mais antigo convertido, save com senha recusado, arquivo que não é ZIP, manifesto com criptografia, contagens e SHA-256, backup antes de importar.
  - Comparação dos dois PCs depois de A→B e B→A: os bancos ficam idênticos, registro a registro, inclusive nos HLCs.
  - Telas recalculadas depois de importar. Esse teste falha sem a correção do bug descrito no item 4.
  - Backup e restauração com banco em arquivo:
    - nome, metadados, SHA-256 e integridade;
    - retenção;
    - recusas antes de restaurar (inexistente, não é banco, schema mais novo, SHA-256 alterado, criptografado);
    - restauração com backup do estado anterior, identidade e HLC mantidos, e backup de outro PC.
  - Migração 2 → 3 com dados; telas de sincronização e backup (exportar, prévia com conflito, arquivo recusado, confirmação explícita, aviso no Início).
- `flutter build windows --release`: compilou `patrion.exe`.
- **Execução real do `.exe` com duas pastas de dados** (`--data-dir`), cada uma semeada pelos serviços do app com a mesma corretora, conta e PETR4 cadastrados separadamente (A: 100 × R$ 30; B: 50 × R$ 35). Na interface e nos diálogos nativos do Windows, conferido por captura de tela:
  1. A: "Salvar arquivo de save": diálogo do Windows com o nome padrão; resumo com 4 registros (3 KB).
  2. B: "Importar e gerar novo save": prévia com 3 unificações (Corretora Exemplo, Principal, PETR4 (B3)), aplicada, novo save com 11 registros.
  3. A: "Importar save" com o arquivo de B. A Carteira de A mostrou PETR4, 150 ações, preço médio R$ 31,67, custo R$ 4.750,00, atualizada na hora.
  4. A: o mesmo arquivo de novo: "Nenhuma alteração".
  5. A: "Fazer backup agora" e restauração do backup "Antes de importar um save", com a confirmação. O app reabriu o banco sozinho, mostrou o aviso e a Carteira voltou a 100 ações. Reimportei o save de B e voltou a 150.
  6. Fechados os dois apps, comparei os bancos: **as 12 tabelas sincronizáveis estão idênticas** nas duas pastas (11 registros, inclusive HLCs), os `device_id` são diferentes, todos os backups têm o `.json`, e os logs não têm avisos nem erros (só contagens, nenhum valor).

**4. Problemas e limitações**

- **Bug encontrado na execução real e corrigido:** depois de importar, a Carteira de B continuava com os dados antigos até reabrir o app. As escritas da mesclagem não avisavam as consultas observadas do Drift. Corrigido, com teste que falhava antes da correção.
- Também na execução real: a prévia em A mostrava "Excluídos 1" em Instituições, Contas e Ativos. Eram os cadastros absorvidos em B chegando já excluídos; nada de A seria excluído. Agora eles não contam como exclusões, e a prévia explica numa nota. Conferido por teste; não repeti esse passo no `.exe`.
- O arquivo de save **não é criptografado** (a senha do arquivo é da F5B/F11). A tela avisa.
- No diálogo de **salvar**, o filtro mostra "All Files (*.*)": o `file_picker` 13.1.0 não repassa o filtro no Windows (D-31). O nome sugerido já termina em `.invsave`; o diálogo de abrir filtra `*.invsave`.
- Com as duas pastas no mesmo PC, os dois "computadores" aparecem com o mesmo nome (o nome do Windows). O identificador do dispositivo, em Configurações, é diferente.
- `market/` (dados de mercado) não vai no save: ainda não há dados de mercado no banco (F6). Chaves de API também não existem ainda.
- A importação não confere a consistência da carteira resultante: edições concorrentes podem gerar, por exemplo, uma venda maior que a posição. O Início já avisa sobre operações inconsistentes.
- Não simulei uma falha ao reabrir o banco no meio da restauração (o caminho que volta o arquivo anterior). Ele está implementado e documentado, mas sem teste automático.
- A conversão de saves de schema antigo foi testada com um save de schema 2 montado no teste: não existem saves reais anteriores à F5.

**5. Pendências**

- F5B: senha do arquivo de save (o campo `encryption` do manifesto já existe), backups criptografados (o campo `encryption` dos metadados já existe), bloqueio por inatividade sobre a sessão reabrível.
- F6: incluir `market/` no save, opção de exportar chaves de API (desmarcada, com aviso).
- F7: associar `.invsave` no instalador (abrir com duplo clique leva à importação, §10.6).
- F9: `hypo_runs` e a opção de levar a série no save; telas das carteiras hipotéticas.
- F11: pasta de sincronização (§10.6).
- Da F1: confirmar Finnhub e Twelve Data (F6); licenças do CKAN do Tesouro e do portal da CVM (F6); toolchain Android (futuro).

**6. Como executar e o que testar manualmente**

```powershell
flutter build windows --release
```

**Roteiro: sincronização entre duas pastas de dados no seu PC**

Preparação:

1. Crie duas pastas, por exemplo `C:\PatrionTeste\A` e `C:\PatrionTeste\B`, e uma pasta para os arquivos de save, `C:\PatrionTeste\saves`.
2. Abra dois terminais do PowerShell na raiz do repositório e inicie um "PC" em cada:

   ```powershell
   build\windows\x64\runner\Release\patrion.exe --data-dir C:\PatrionTeste\A
   ```

   ```powershell
   build\windows\x64\runner\Release\patrion.exe --data-dir C:\PatrionTeste\B
   ```

   As duas janelas podem ficar abertas ao mesmo tempo. Em Configurações, confira que cada uma mostra a sua pasta de dados e um identificador de dispositivo diferente (o nome do computador é o mesmo).

Primeira sincronização, com cadastros repetidos:

3. **Em A**:
   - em Cadastros, crie a instituição "Corretora Exemplo", a conta "Principal" e o ativo PETR4 (Ações BR, B3);
   - em Operações, registre uma compra de 100 × R$ 30,00.
4. **Em B**: crie os mesmos cadastros (mesmos nomes, separadamente) e uma compra de 50 × R$ 35,00.
5. **Em A**: Sincronização → "Salvar arquivo de save". Salve em `C:\PatrionTeste\saves`. Confira o resumo (contagens por tabela).
6. **Em B**: Sincronização → "Importar e gerar novo save…" → escolha o arquivo de A. Na prévia, devem aparecer 3 cadastros repetidos que serão unificados (instituição, conta e PETR4). Clique em "Aplicar e gerar novo save" e salve o novo arquivo na mesma pasta.
7. **Em B**: a Carteira mostra um único PETR4 com 150 ações, preço médio R$ 31,67.
8. **Em A**: Sincronização → "Importar save…" → arquivo gerado por B → Aplicar. A Carteira de A também mostra 150 ações. Em Cadastros, há uma instituição, uma conta e um PETR4.

Idempotência e arquivo antigo:

9. **Em A**: importe de novo o mesmo arquivo de B. A prévia deve dizer "Nenhuma alteração".
10. **Em B**: importe o primeiro save de A (o do passo 5, que é antigo). Nada deve mudar, e nenhum PETR4 repetido volta.

Conflito:

11. **Em A**: edite a compra de 100 para 120 ações. **Depois, em B**, edite a mesma compra para 130.
12. **Em A**: salve um save. **Em B**: "Importar e gerar novo save" com ele. A prévia mostra "Conflitos (1)", com as duas versões lado a lado; a de B (mais recente) vem marcada.
    - para testar o padrão, aplique como está;
    - para testar a escolha, marque "Usar a recebida".
13. **Em A**: importe o save gerado por B. Não deve aparecer conflito, e os dois PCs ficam com o mesmo valor (130 no padrão, 120 se você escolheu a recebida).

Exclusão:

14. **Em A**: exclua uma operação, salve um save e importe em B. A prévia mostra 1 excluído em Operações, e a operação some em B.

Arquivo alterado:

15. Copie um `.invsave`, abra a cópia num editor hexadecimal (ou mude a extensão para `.zip` e edite um `data\*.jsonl` dentro dele) e tente importar. Deve aparecer "O arquivo de save está corrompido ou foi alterado… Nada foi importado".

Backup e restauração:

16. **Em A**: Backup → "Fazer backup agora". O backup aparece na lista e em `C:\PatrionTeste\A\backups\`, com um `.json` ao lado.
17. Registre uma operação nova. Depois clique em "Restaurar" no backup do passo 16:
    - o botão só libera depois de marcar "Entendo que os dados atuais serão substituídos";
    - depois de restaurar, o app reabre sozinho, mostra o aviso com o arquivo do estado anterior, e a operação nova não está mais lá;
    - a lista ganhou um backup "Antes de restaurar um backup".
18. Importe de novo o último save de B em A: o que veio de B volta.

Aviso de sincronização antiga:

19. (Opcional, só com as pastas de teste.) Feche as janelas. Para ver o aviso no Início sem esperar 7 dias, adiante o relógio do Windows em 8 dias e abra A. O Início deve avisar "A última sincronização com <PC> foi há 8 dias". Volte o relógio depois.

O que conferir também: os logs (`C:\PatrionTeste\A\logs\patrion.log`) registram exportações, importações, backups e restaurações só com contagens, sem valores.

Para recuperação manual sem o app, veja `docs/BACKUP.md`.

### Fase 4 — Motor financeiro

Critério de pronto: os casos de `CASOS_DE_TESTE.md` que pertencem ao motor financeiro (§1 a §7) passam. O §8 (backtest) é da F9 e o §9 (sincronização) é da F5, conforme a SPEC §21; eles ficam para essas fases. CI verde ([run 39068071876](https://github.com/LuccaBueno/patrion/actions/runs/39068071876), commit `88cc5f0`, 232 testes).

**1. O que foi implementado**

- **Potência, logaritmo e exponencial em `Decimal`** (`DecimalMath.ln`, `exp`, `pow` com expoente fracionário), sem `double`, em ponto fixo de 60 casas e resultado com 20 (D-26).
- **Juros** (`Interest`): simples e compostos, taxa equivalente, nominal ↔ efetiva, fatores compostos e lineares entre datas nas bases 252, /365, /360 e 30E/360.
- **Calendário de dias úteis** (`BusinessCalendar`): feriados nacionais da ANBIMA (fixos; Carnaval, Sexta-feira Santa e Corpus Christi pela Páscoa; 20/11 a partir de 2024), contagem de dias úteis, próximo dia útil e soma de dias úteis.
- **CDI e Selic** (`IndexAccrual`): fator diário na base 252, percentual do indexador, acumulado de séries diárias, taxa constante e spread.
- **XIRR** (`Xirr`): dias corridos ÷ 365, Newton protegido por bisseção, "indisponível" sem solução e aviso quando há várias trocas de sinal.
- **Retornos** (`Returns`, `Twr`, `PeriodReturns`, `FxDecomposition`): simples, acumulado, real, anualização e CAGR, TWR, retornos diários, mensais e anuais, decomposição do efeito cambial, e `ReturnMethod` para rotular a metodologia.
- **Desempenho da carteira real** (`PerformanceCalculator`): fluxos do investidor a partir das operações; resultado total com e sem proventos; MWR (TIR) líquido, sem proventos e bruto (antes de custos); por ativo e por moeda (D-27).
- **Interface:**
  - Dashboard: novos cards "Resultado total" e "Rentabilidade (TIR)", com o período e um tooltip que explica a metodologia (MWR × TWR). Com menos de um ano, a TIR aparece como retorno do período.
  - **Os valores dos cards não quebram mais linha** (pedido do usuário): o valor fica numa linha e a fonte diminui se não couber. O percentual do resultado não realizado foi para a nota do card.
  - Detalhe do ativo: card "Desempenho" com resultado total e sem proventos, TIR líquida, sem proventos e bruta, aplicado, vendas e resgates, custos e impostos.
- `FORMULAS.md` §4 a §10; decisões D-26 e D-27; `ARQUITETURA.md` atualizado.

**2. Arquivos criados ou alterados**

- `lib/core/`: `money/decimal_math.dart` (`ln`, `exp`, `pow`, `rescale`), `time/local_date.dart` (`addMonths`, `weekday`, `isWeekend`).
- `lib/domain/finance/` (novo): `business_calendar.dart`, `interest.dart`, `index_accrual.dart`, `cash_flow.dart`, `returns.dart`.
- `lib/domain/portfolio/performance.dart` (novo); `portfolio_valuation.dart` (referência da documentação).
- `lib/application/portfolio/portfolio_query.dart` (`performance` e `assetPerformance`).
- `lib/presentation/`: `screens/dashboard/dashboard_screen.dart`, `screens/portfolio/asset_detail_screen.dart`, `widgets/common.dart` (`PnlText.singleLine`), `format/labels.dart`, `format/performance_format.dart` (novo).
- `test/`: `domain/finance/reference_cases_test.dart`, `finance_functions_test.dart`, `business_calendar_test.dart`, `domain/portfolio/performance_test.dart` (novos); `core/money/decimal_math_test.dart`, `core/time/local_date_test.dart`, `presentation/portfolio_screens_test.dart` (ampliados).
- Docs: `FORMULAS.md`, `DECISIONS.md`, `ARQUITETURA.md`, `PROGRESS.md`, `CHANGELOG.md`.

**3. Testes executados (17/10/2026)**

- `dart format --set-exit-if-changed .`: 101 arquivos, 0 alterados.
- `flutter analyze`: "No issues found!".
- `flutter test`: **232 testes, todos passaram** (175 na F3). Entre os novos:
  - `CASOS_DE_TESTE.md`:
    - §2: R$ 11.268,25;
    - §3: 0,948879% a.m. e 0,044982% ao dia útil;
    - §4: 0,846915% e R$ 1.008,47, também acumulando 21 taxas diárias e contando os 21 dias úteis pelo calendário;
    - §5: 9,9714% a.a.;
    - §6: TWR −1,00% e MWR −3,7093% a.a., também a partir de operações;
    - §7: USD 10%, BRL 21%, efeitos de 10%, 10% e 1%;
    - o §1 continua passando (`portfolio_calculator_test.dart`) e foi repetido no cálculo de desempenho.
  - `ln`, `exp` e `pow` contra valores conhecidos com 20 casas.
  - Feriados de 2025, Páscoa e os 252 dias úteis de 2025.
  - XIRR negativo, fora de ordem, sem solução e com várias trocas de sinal; TWR com retirada e sem capital; retornos por mês, ano e dia.
  - Widget: os valores dos cards do dashboard ficam numa linha com valores na casa das centenas de bilhões, em janela de 960 × 640. Conferi que esse teste falha se o ajuste for removido.
- `flutter build windows --release`: compilou `patrion.exe`.
- **Execução real do `.exe`** com `--data-dir` temporário e uma carteira de exemplo gravada pelos serviços do app:
  - dashboard com todos os valores numa linha (patrimônio R$ 1.410.149,56, resultado total +R$ 160.149,56, TIR +8,23% a.a. de 10/01/2023 a 16/10/2026);
  - detalhe do ativo com o card "Desempenho" (resultado total +R$ 108.915,00, conferido à mão);
  - o fechamento pela janela encerrou o processo.

**4. Problemas e limitações**

- **TWR, retornos por mês e ano, retorno real, efeito cambial e benchmarks** estão prontos e testados no domínio, mas **não aparecem na tela**: dependem do histórico de cotações, do IPCA e do câmbio (F6). Calcular o TWR com preços informados de vez em quando exigiria inventar valores intermediários (regra 1, D-27).
- A TIR da carteira considera só os investimentos: o caixa parado nas contas fica fora (o card diz isso).
- Os truncamentos da B3 no CDI (8 e 16 casas) não são aplicados; a diferença fica abaixo de um centavo em valores usuais.
- O calendário tem só os feriados nacionais. Feriados extraordinários podem ser passados ao calendário, mas ainda não há tela para isso.
- IPCA+ (pró-rata da inflação) e a marcação a mercado de títulos ficam para a F8 (SPEC §12.2), quando houver as séries.
- `CASOS_DE_TESTE.md` §8 (backtest) e §9 (sincronização) não foram executados nesta fase: são da F9 e da F5.

**5. Pendências**

- F5: backup, restauração, `dev_backups` e o arquivo de save (§10 e §11), com a preparação de D-24.
- F6: mostrar TWR, rentabilidade por período, evolução, benchmarks, retorno real e efeito cambial com dados reais.
- Da F1: confirmar Finnhub e Twelve Data (F6); licenças do CKAN do Tesouro e do portal da CVM (F6); toolchain Android (futuro).

**6. Como executar e o que testar manualmente**

```powershell
flutter run -d windows
# ou
build\windows\x64\runner\Release\patrion.exe
```

Roteiro sugerido:

1. Com a carteira da F3 (ou o caso de `CASOS_DE_TESTE.md` §1), informe um preço para o ativo e abra o **Início**:
   - "Resultado total" = lucro realizado + resultado não realizado + proventos;
   - "Rentabilidade (TIR)" mostra o período; passe o mouse no ícone (i) para ler a explicação MWR × TWR;
   - com menos de um ano de histórico, aparece "% no período" em vez de "% a.a.".
2. Diminua a janela até o tamanho mínimo: nenhum valor dos cards deve quebrar linha (a fonte diminui).
3. No detalhe do ativo, confira o card "Desempenho": com proventos, a TIR é maior que "sem proventos"; a bruta é maior que a líquida quando há custos.
4. Apague o preço do ativo: resultado total e TIR ficam "indisponíveis", com o motivo no tooltip.
5. Para conferir o §6: compre 100 × R$ 10,00 em 01/01/2024 e 50 × R$ 20,00 em 01/01/2025, e informe o preço R$ 12,60 em 01/01/2026. A TIR do ativo deve ser −3,71% a.a.

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

Ver as seções 4 e 5 das Fases 7, 6, 5B, 5, 4, 3, 2 e 1 acima.

## Próximo passo

Fechar a F7: seu teste do instalador em ambiente limpo (Windows Sandbox) e a autorização para criar a tag `v1.0.0`, que gera a Release em rascunho para você revisar e publicar. Depois, Fase 8 (classes, benchmarks, risco e renda passiva).

## Histórico de sessões

| Data | Fase | Resumo |
|---|---|---|
| 2026-10-17 | F1 | Ambiente, fontes de dados, decisões e modelo de dados aprovados; projeto criado e primeiro build Windows |
| 2026-10-17 | F2 | Fundação: camadas, Drift, HLC e repositórios base, navegação, tema, logs, ícone e CI verde |
| 2026-10-17 | F3 | Carteira real: schema 2 com backup automático antes de migrar, cadastros, todos os tipos de operação, preço manual, posições, dashboard inicial e telas de carteira, operações e cadastros |
| 2026-10-17 | F4 | Motor financeiro: ln/exp/pow em Decimal, juros e bases, calendário de dias úteis, CDI, XIRR, TWR, retornos e câmbio; resultado total e TIR por ativo e por moeda na interface; cards do dashboard sem quebra de linha |
| 2026-10-17 | F5 | Backup e save: arquivo .invsave com mesclagem por HLC, conflitos, unificação de cadastros repetidos e prévia; backup manual e automático com metadados e restauração com reabertura do banco; schema 3; S1 a S10 e sincronização real entre duas pastas de dados |
| 2026-10-18 | F5B | Pendências da F5 (aviso de carteira inconsistente na prévia; teste da falha ao reabrir na restauração) e bloqueio do app: SQLCipher, senha, chave de recuperação, Windows Hello, inatividade, backups criptografados e senha do arquivo de save; conversão de um banco existente verificada no app real |
| 2026-10-18 | F6 | Dados de mercado: pendências da F1, schema 4, 14 adaptadores, cache, atualização automática e manual, câmbio e indicadores, patrimônio em reais, tela Fontes de dados, chaves com DPAPI, dados de mercado no save; cotações reais e funcionamento sem internet verificados no app real |
| 2026-10-19 | F7 | Distribuição: instalador Inno Setup (por usuário, atualização por cima, desinstalação sem perder dados, associação do .invsave), runtime do Visual C++ no pacote, ZIP portátil, avisos de licença, instância única por pasta de dados, verificador de atualizações, workflow de release em rascunho e teste de instalação (26/26 neste PC); Carteira cabe em 1280 px; v1.0.0 preparada, sem tag |
