# Patrion — Lista de mudanças (uso real)

Itens observados no uso da v1.0.0. Cada item traz o problema, a mudança, o critério de pronto e a prioridade.
Ao enviar ao Claude Code, cole esta lista no início do prompt da fase e peça: "Implemente os itens M-xx antes de começar a fase; atualize a SPEC e o DECISIONS.md quando a mudança alterar uma regra."

## Situação

| Item | Situação |
|---|---|
| M-01 a M-05 | **Feitos** na versão 1.1.0 (exceto M-04 itens 4, 5 e 9, que passaram para o M-09) |
| M-06 a M-09 | **Feitos** na versão 1.2.0 |
| Fase 8 | **Feita** na versão 1.3.0 |
| M-10 a M-12 | **Pendentes** (antes de publicar a próxima Release) |

---

### M-01 — Adição rápida de ações e FIIs pelo ticker
- **Onde:** Carteira (botão "Adicionar ativo") e Cadastros → Novo ativo
- **Problema:** adicionar uma ação exige cadastrar o ativo com 11 campos (classe, mercado, nome, moeda, país, liquidez, setor, segmento, ISIN, preço, observações) e só depois registrar a compra em outra tela. O ticker também não é normalizado ("bbas3").
- **Mudança:**
  1. Botão **"Adicionar ativo"** com um formulário curto: **ticker** (aceita minúsculas e converte para maiúsculas), **quantidade**, **preço** (unitário ou preço médio), **data** e **conta** (vem preenchida com a última usada ou a única existente).
  2. Ao sair do campo do ticker, o app **consulta as fontes** (B3/COTAHIST, brapi) e preenche sozinho: nome, classe (ação, FII, ETF, BDR), mercado B3, moeda BRL, país BR, ISIN, setor e segmento quando disponíveis, e cotação automática. O nome e a classe aparecem para conferir antes de salvar.
  3. Se o ativo já está cadastrado, o formulário só registra a compra.
  4. Opção **"Posição que já tenho (saldo inicial)"**: quantidade + preço médio + data aproximada, com o aviso "a TIR fica aproximada; para rentabilidade exata, registre as compras individuais". **Este é o modo padrão ao montar a carteira pela primeira vez** (o usuário copia quantidade e preço médio da corretora).
  5. Os outros campos (liquidez, observações etc.) ficam numa seção recolhida **"Mais detalhes"**.
  6. Se o ticker não for encontrado (ou estiver offline), o app permite seguir com o cadastro manual atual.
  7. Renda fixa, cripto e internacional continuam com os formulários próprios por enquanto.
- **Critério de pronto:** digitar "bbas3", 100 e 25,00 e salvar cria o ativo BBAS3 com nome e classe corretos e a compra registrada, em uma única tela. Ticker inexistente mostra aviso e permite o cadastro manual. Funciona offline com os dados já baixados.
- **Prioridade:** alta
- **Fase:** ajuste avulso antes da F8

### M-02 — Reorganizar o menu lateral: uso diário em cima, configurações embaixo
- **Onde:** menu lateral e tela de Configurações
- **Problema:** Sincronização, Backup e Fontes de dados ficam no mesmo nível de Início, Carteira e Operações, misturando uso diário com manutenção. Configurações fica no meio da lista, e o menu vai crescer com as próximas fases.
- **Mudança:**
  1. **Parte de cima do menu** (uso diário): Painel (M-04), Carteira (M-05) e Operações (Cadastros sai do menu no M-06). As telas das próximas fases (Renda passiva, Benchmarks, Hipotéticas, Simuladores) entram aqui.
  2. **Rodapé do menu, separado por um divisor:**
     - **Sincronizar**: atalho direto para exportar e importar o save, com indicador quando a última sincronização tiver 7 dias ou mais;
     - **Configurações**: sempre a última posição.
  3. **Configurações** passa a ter seções:
     - Geral: tema e preferências;
     - Segurança: senha, Windows Hello, bloqueio por inatividade e chave de recuperação;
     - Fontes de dados: chaves, cota da brapi e intervalo de atualização;
     - Backup: backup manual, restauração e lista de backups;
     - Sincronização: histórico e opções do save;
     - Sobre: versão, atualizações e licenças.
  4. Avisos que hoje levam a Backup ou Fontes de dados passam a abrir a seção correspondente de Configurações.
  5. A tela vazia ("Nenhum investimento registrado") oferece o botão **"Adicionar ativo"** (M-01).
- **Critério de pronto:** o menu mostra no máximo 4 itens de uso diário em cima e Sincronizar + Configurações no rodapé. Todas as funções atuais de Backup, Fontes de dados e Sincronização continuam acessíveis em Configurações. Exportar um save leva no máximo 2 cliques a partir de qualquer tela.
- **Prioridade:** média
- **Fase:** ajuste avulso antes da F8

### M-03 — Controle de caixa opcional (desligado por padrão)
- **Onde:** cálculo de Patrimônio e Caixa; Configurações → Geral; cadastro de contas
- **Problema:** cada compra é descontada do caixa da conta. Quem não registra depósitos vê caixa e patrimônio **negativos** (ex.: patrimônio −R$ 3.729,60 logo após registrar uma compra), o que não faz sentido para quem só quer acompanhar os ativos que tem na corretora.
- **Mudança:**
  1. Nova opção **"Controlar saldo em caixa"**, **desligada por padrão** (por conta ou geral).
  2. Desligada: compras e vendas não movimentam caixa; o card "Caixa" e o aviso de caixa negativo somem; **Patrimônio = valor de mercado das posições**; proventos e vendas continuam aparecendo em seus próprios cards.
  3. Ligada: comportamento atual (depósitos, retiradas, caixa calculado e aviso de negativo).
  4. Saldo em dinheiro parado pode ser registrado como um ativo "Caixa" com saldo informado, se o usuário quiser incluí-lo no patrimônio.
  5. A TIR continua considerando compras e vendas como fluxos (não depende do caixa).
- **Critério de pronto:** com a opção desligada, registrar uma compra de R$ 3.729,60 deixa o patrimônio igual ao valor de mercado da posição (nunca negativo) e nenhum aviso de caixa aparece. Ligando a opção, o comportamento atual volta e os testes antigos de caixa continuam passando.
- **Prioridade:** alta
- **Fase:** ajuste avulso antes da F8

### M-04 — Painel com gráficos do patrimônio
- **Onde:** tela Início (renomeada para "Painel")
- **Problema:** o Início é uma grade de números (cards) sem gráficos; não mostra a distribuição do patrimônio de forma visual nem quanto foi investido no mês/ano.
- **Mudança:** uma tela visual, com o que for útil para entender a carteira de relance:
  1. **Destaque no topo:** patrimônio total, resultado total (R$ e %) e variação do dia.
  2. **Distribuição (gráficos de rosca ou barras):** por ativo, por classe (ações, FIIs, renda fixa…), por setor e por instituição.
  3. **Aportes:** investido no mês e no ano, e gráfico de barras com os aportes por mês (últimos 12 meses), separando compras e vendas.
  4. **Evolução do patrimônio:** linha do valor da carteira ao longo do tempo, com o total investido sobreposto (mostra quanto é aporte e quanto é rendimento).
  5. **Rentabilidade:** no mês, no ano e desde o início, comparada com CDI e Ibovespa (barra ou linha).
  6. **Proventos:** recebidos por mês (barras) e total dos últimos 12 meses.
  7. **Maiores altas e baixas** da carteira no dia ou no mês.
  8. Câmbio e indicadores (já existe) vão para uma faixa compacta no rodapé.
  9. Seletor de período (1M, 6M, 1A, 5A, tudo) para os gráficos de evolução e rentabilidade.
- **Critério de pronto:** com uma carteira de exemplo de 5+ ativos, o Painel mostra os gráficos acima com valores que batem com a Carteira; nenhum gráfico inventa dados (sem histórico suficiente, mostra "indisponível" com o motivo).
- **Prioridade:** alta
- **Fase:** **F8** (itens 4, 5 e 9 dependem do histórico e dos benchmarks da F8); itens 1, 2, 3, 6 e 7 podem vir antes, no ajuste avulso

### M-05 — Carteira como lista principal (estilo Nubank), com painel de detalhes por ativo
- **Onde:** tela Carteira
- **Problema:** a lista atual tem colunas técnicas (classe, conta, PM em duas linhas) e não destaca onde está o dinheiro. Lucro em R$, total aplicado, variação do dia e gráfico da cotação não ficam a um clique. Registrar compras e vendas exige ir a outra tela.
- **Mudança:**
  1. **Lista em ordem decrescente de valor da posição** (quantidade × cotação atual): o ativo onde há mais dinheiro fica no topo.
  2. **Cada linha mostra, nesta ordem:**
     - **Ativo:** ticker e nome, com a quantidade de cotas em texto menor embaixo (ex.: "100 cotas");
     - **Valor da posição:** quantidade × cotação atual, em destaque;
     - **Preço médio;**
     - **Cotação atual** (data e fonte no tooltip);
     - **Valorização %:** (cotação atual − preço médio) ÷ preço médio, em cor de ganho/perda, com sinal e ícone;
     - **Botão "Detalhes"** (ou clique na linha).
  3. **Painel de detalhes do ativo** (abre ao lado ou por cima da lista, sem trocar de tela):
     - **Lucro em R$:** valor da posição − total aplicado (não realizado), mais o lucro realizado em vendas, se houver;
     - **Total aplicado:** preço médio × quantidade (custo da posição atual);
     - **Variação do dia:** em R$ e % (cotação atual × fechamento anterior), com a data de referência;
     - **Gráfico da cotação**, com seletor de período (1S, 1M, 6M, 1A, 5A, tudo) e uma **linha horizontal no preço médio**, para ver de relance se a cotação está acima ou abaixo dele;
     - **% da carteira** e proventos recebidos do ativo;
     - **Histórico de operações** do ativo;
     - Botões **"Comprar"** e **"Vender"**, já com o ativo preenchido (pedem só quantidade, preço, data e custos opcionais).
  4. **Ativos com zero cotas** vão para o **fim da lista**, em cinza (por enquanto, sem esconder).
  5. Ativos sem cotação ficam ordenados pelo total aplicado, com "indisponível" na cotação, na valorização e no valor da posição.
  6. Botão **"Adicionar ativo"** (M-01) no topo da tela.
  7. Continua cabendo em 1280 px sem rolagem lateral.
- **Critério de pronto:** com 5 ativos, a ordem segue o valor da posição; a valorização % bate com (cotação − PM) ÷ PM; o painel mostra lucro em R$, total aplicado, variação do dia e o gráfico com a linha do PM; vender todas as cotas leva o ativo ao fim da lista; "Comprar" pelo painel registra a compra sem sair da Carteira e a lista se reordena. Sem histórico de cotações, o gráfico mostra "indisponível" com o motivo (nunca inventa pontos).
- **Prioridade:** alta (é a tela mais usada)
- **Fase:** ajuste avulso antes da F8 (o histórico de cotações já existe desde a F6)

### M-06 — Corretora escolhida na hora; Cadastros sai do menu principal
- **Onde:** formulário "Adicionar ativo" (M-01), Comprar/Vender (M-05), Carteira, menu lateral, Configurações
- **Problema:** antes de registrar o primeiro ativo é preciso ir a Cadastros criar instituição e conta. Depois disso, a tela Cadastros quase não é usada, mas ocupa espaço no menu diário. Ao mesmo tempo, os ativos **precisam continuar separados por corretora/custodiante**.
- **Mudança:**
  1. **Campo "Corretora / custodiante"** no "Adicionar ativo" e no Comprar/Vender:
     - lista as corretoras já usadas, com a última usada pré-selecionada;
     - permite digitar uma nova (ex.: "XP"): o app cria a instituição e uma conta padrão ("XP · Principal") na hora, sem sair do formulário;
     - na primeira vez que o app é usado, é o único dado de cadastro que o usuário precisa informar.
  2. **Separação por corretora na Carteira:**
     - **filtro por corretora** no topo da lista (Todas / Nubank / XP / …), lembrado entre aberturas do app;
     - o **mesmo ticker em duas corretoras** aparece em **uma linha consolidada** (quantidade, valor e preço médio somados); o painel de Detalhes mostra a **quebra por corretora** (quantidade, preço médio e valor em cada uma);
     - opção **"Agrupar por corretora"**: a lista ganha seções por corretora, com o subtotal de cada uma.
  3. No Painel (M-04), o gráfico **"Por corretora"** continua mostrando quanto está em cada custodiante.
  4. **Transferência de custódia** (mudar ações de uma corretora para outra) fica acessível no painel de Detalhes do ativo, mantendo o preço médio.
  5. **Cadastros sai do menu principal** e vira a seção **"Corretoras e ativos"** em Configurações, usada só para corrigir: renomear corretora ou conta, arquivar conta, editar ativo (fonte de cotação, renda fixa), excluir cadastro sem uso.
- **Critério de pronto:** num banco vazio, adicionar o primeiro ativo informando só ticker, quantidade, preço e "Nubank" cria tudo sem passar por Cadastros. Comprar o mesmo ticker na XP mostra uma linha consolidada, com a quebra Nubank/XP nos Detalhes. O filtro "XP" mostra só o que está na XP. O menu principal não tem mais Cadastros, e todas as funções dele estão em Configurações → Corretoras e ativos.
- **Prioridade:** média
- **Fase:** ajuste avulso, depois do M-01 a M-05

### M-07 — Página do ativo em tela cheia no lugar do painel lateral
- **Onde:** Carteira (clique na linha) e "Página do ativo"
- **Problema:** o painel lateral de Detalhes (M-05) é estreito: o gráfico fica pequeno, os números ficam espremidos e o painel cobre as colunas da lista (cotação e valorização somem). Não dá para analisar a evolução do ativo ao longo dos anos.
- **Mudança:**
  1. **Clicar na linha abre a página do ativo em tela cheia**, com botão "Voltar" para a Carteira (que mantém filtro e posição de rolagem). O painel lateral deixa de existir.
  2. **Cabeçalho:** ticker, nome, classe e corretora; à direita, valor da posição em destaque, lucro em R$ e % e variação do dia; botões **Comprar** e **Vender**.
  3. **Gráfico principal grande** (ocupa a largura da página, ~45% da altura), mostrando **só o desempenho da ação no mercado**, independente da minha carteira e de quando eu comprei:
     - **cotação da ação** ao longo do tempo (fechamento diário);
     - seletor de período: 1M, 6M, **1A**, 5A, 10A e Tudo (períodos do mercado, não "desde a minha compra");
     - **variação do período em destaque** (ex.: "+18,4% em 1 ano") e máxima/mínima do período;
     - **cursor com tooltip** ao passar o mouse: data, cotação e variação desde o início do período;
     - eixo de valores com escala legível (sem começar em zero quando isso esconder a variação);
     - opção **"Preço ajustado por proventos"** (calculado, rotulado como tal) para não mostrar quedas falsas em datas "ex";
     - **sem comparação com índices** neste gráfico (a comparação fica só na evolução patrimonial do Painel, M-09);
     - **Nada da carteira no gráfico** (sem linha de preço médio, sem marcadores de compra/venda, sem valor da posição). Esses dados ficam nos cartões e na aba Operações.
  4. **Cartões abaixo do gráfico**, em grade larga: total aplicado, preço médio, cotação atual, lucro não realizado, lucro realizado, proventos recebidos, % da carteira, quebra por corretora (M-06).
  5. **Abas inferiores:** Operações (tabela com edição), Proventos (por mês), Dados do ativo (setor, segmento, ISIN, fonte da cotação).
  6. Sem dados para o período escolhido, o botão do período aparece desabilitado com o motivo no tooltip (ex.: "histórico disponível desde 03/2019").
- **Critério de pronto:** clicando em BBAS3 abre a página em tela cheia; o gráfico em 5A mostra cinco anos de fechamentos da ação com a variação do período em destaque, sem nenhum dado da carteira desenhado; o tooltip funciona com o mouse; em 1280 px nada fica cortado.
- **Prioridade:** alta
- **Fase:** ajuste avulso (depende do M-08 para ter anos de histórico)

### M-08 — Histórico completo de cotações baixado automaticamente
- **Onde:** Adicionar ativo (M-01), atualização de dados, Configurações → Fontes de dados
- **Problema:** o gráfico de 1A mostra só ~9 dias (14/10 a 22/10/2026): o app guardou apenas os fechamentos recentes. Para ver a evolução ao longo dos anos é preciso o histórico longo de cada ativo.
- **Mudança:**
  1. Ao **adicionar um ativo** (ou na primeira atualização depois desta versão, para os já cadastrados), o app **baixa o histórico de fechamentos em segundo plano** desde o ano inicial configurado (padrão: **10 anos**, ou desde a listagem do ativo), usando o COTAHIST anual (já implementado) e apagando os arquivos brutos depois (D-05).
  2. Progresso visível e discreto ("Baixando histórico de BBAS3… 2019/2026"), sem travar o app; pode continuar na próxima abertura se o app for fechado.
  3. Um único download anual serve a **todos os ativos** da B3 (o COTAHIST traz todos de uma vez): ao adicionar um ativo novo, os anos já processados são relidos só se o arquivo ainda estiver em cache; caso contrário, baixa de novo só o necessário.
  4. **Proventos e eventos** (desdobramentos, grupamentos) do ativo baixados junto, para o preço ajustado do M-07 e a evolução do M-09; eventos suspeitos seguem a regra já existente (aviso, confirmação manual).
  5. Configurações → Fontes de dados mostra, por ativo, desde quando há histórico e um botão "Baixar histórico completo".
- **Critério de pronto:** adicionar BBAS3 num banco novo resulta, alguns minutos depois, em fechamentos diários dos últimos 10 anos; o gráfico 5A do M-07 aparece completo; a pasta de cache fica vazia ao final; com o app fechado no meio, o download continua na próxima abertura.
- **Prioridade:** alta (sem ele, M-07 e M-09 ficam vazios)
- **Fase:** ajuste avulso, **antes** do M-07 e do M-09

### M-09 — Painel: evolução patrimonial em destaque e gráficos mais claros
- **Onde:** tela Painel
- **Problema:** não existe gráfico de evolução patrimonial, e os gráficos atuais não são fáceis de ler nem respondem às perguntas principais ("quanto eu tenho?", "quanto eu coloquei?", "quanto rendeu?", "como está dividido?").
- **Mudança:** (absorve os itens 4, 5 e 9 do M-04)
  1. **Gráfico principal e em destaque: Evolução patrimonial.** É o elemento mais importante do app por enquanto: fica no topo do Painel, ocupando toda a largura e cerca de metade da altura da tela.
     - área preenchida com o **patrimônio** dia a dia (quantidade de cada ativo em cada dia × fechamento do dia);
     - linha em degraus com o **total aplicado** (aportes acumulados menos resgates), de modo que o espaço entre as duas é o **ganho**;
     - seletor de período (6M, 1A, 5A, Tudo) e tooltip com data, patrimônio, aplicado e ganho (R$ e %);
     - marcadores discretos nos meses com aportes;
     - **opção "Comparar com"** (desligada por padrão), com caixas para **CDI**, **Ibovespa** e **IPCA**:
       - em **R$**: desenha, para cada índice marcado, a linha de **"quanto eu teria se os mesmos aportes, nas mesmas datas, tivessem ido para o índice"** (linha fina, cor neutra, rotulada como simulação);
       - alternância **R$ / %**: em %, mostra a rentabilidade da carteira (TWR) contra os índices, todos começando em 0% no início do período, explicado no ícone de informação;
       - o tooltip mostra a diferença da carteira para cada índice marcado (ex.: "Carteira R$ 52.300 · CDI R$ 49.800 · +R$ 2.500").
  2. **Faixa de números acima do gráfico**, grande e simples: Patrimônio · Total aplicado · Ganho (R$ e %) · Rentabilidade no ano.
  3. *(Removido: a comparação com índices passa a ser a opção "Comparar com" do gráfico principal, não um gráfico separado.)*
  4. **Distribuição:** um único gráfico de rosca com seletor (por ativo / por classe / por setor / por corretora), com o total no centro e a lista de percentuais ao lado (ordenada, com valor em R$).
  5. **Aportes por mês:** barras dos últimos 12 meses (compras em verde, vendas em cinza), com o total do mês e do ano.
  6. **Proventos por mês:** barras dos últimos 12 meses, com o total.
  7. **Princípios visuais** para todos os gráficos:
     - no máximo **uma ideia por gráfico**, título em forma de resposta (ex.: "Seu patrimônio cresceu R$ X em 1 ano");
     - cores consistentes (marca = carteira, cinza = referências, verde/vermelho só para ganho/perda);
     - tooltip em todos os gráficos, valores em R$ formatados, datas em pt-BR;
     - sem dados suficientes: o gráfico mostra "indisponível" com o motivo, nunca pontos inventados.
- **Observação importante sobre os dados:** a evolução patrimonial só pode começar na **data das operações registradas**. Posições lançadas como "saldo inicial" com a data de hoje fazem o gráfico começar hoje. Para ver anos de evolução, registre as compras com as **datas reais** (ou aproximadas) — o app deve explicar isso no próprio gráfico quando o histórico for curto.
- **Critério de pronto:** com compras registradas em datas espalhadas por 2+ anos e histórico baixado (M-08), o Painel mostra em destaque a curva do patrimônio acima da linha do total aplicado; ligando "Comparar com CDI", aparece a linha simulada com os mesmos aportes no CDI (em R$) e, em %, a comparação de rentabilidade; a distribuição com seletor funciona; os valores do dia final batem com a Carteira; o tooltip funciona em todos os gráficos.
- **Prioridade:** alta
- **Fase:** ajuste avulso (equivale a antecipar parte da F8: evolução patrimonial, TWR e benchmarks); depende do M-08

---

### M-10 — Bug: a tela Desempenho fica piscando
- **Onde:** Desempenho (abas Rentabilidade, Benchmarks e Risco)
- **Problema:** a tela pisca continuamente, como se fosse redesenhada ou recarregada em loop.
- **Mudança:**
  1. Reproduzir com um teste que falhe e achar a causa (suspeitas: provider recalculando a cada frame, `setState`/`watch` em loop, animação reiniciando, consulta ao banco disparada no `build`).
  2. Corrigir de forma que a tela só seja recalculada quando os dados mudarem (operação nova, cotação nova, troca de período).
  3. Conferir que o mesmo problema não acontece no Painel, na Carteira e na Renda passiva.
- **Critério de pronto:** a tela fica parada (sem piscar) por 1 minuto aberta; um teste garante que o cálculo de rentabilidade não roda mais de uma vez sem mudança de dados.
- **Prioridade:** **alta (bug)**
- **Fase:** correção imediata

### M-11 — Painel único, mais simples (Desempenho entra no Painel), estilo Nubank
- **Onde:** Painel, Desempenho e menu lateral
- **Problema:** o Painel tem informações repetidas e é longo demais para rolar. Exemplos na tela atual: Patrimônio = Valor de mercado; Total aplicado = Valor investido; Ganho = Resultado total = Resultado não realizado (todos R$ 673,32); "Maiores posições" repete a rosca "por ativo". O Desempenho é uma tela separada com assuntos que o usuário espera encontrar no Painel.
- **Referências de organização:** Nubank (um número grande no topo, poucos blocos, detalhe sob demanda, botão de ocultar valores), Kinvo (gráfico investido × saldo separando aporte de rendimento), Snowball Analytics (valor, investido, lucro total, TIR e renda passiva no topo; análises detalhadas em abas).
- **Mudança:** nenhuma função é removida; só reorganizada.
  1. **Desempenho deixa de ser item do menu.** O Painel ganha abas no topo: **Visão geral · Rentabilidade · Comparação · Risco** (as três últimas são as abas atuais do Desempenho, sem mudança de conteúdo). Menu fica: Painel, Carteira, Renda passiva, Operações.
  2. **Visão geral, de cima para baixo:**
     - **Topo (estilo Nubank):** "Patrimônio" em número grande, com o ícone de **olho para ocultar valores** (troca todos os R$ do app por "••••", lembrado entre aberturas). Logo abaixo, numa linha: **Ganho total** (R$ e %) · **Hoje** (R$ e %) · **Total aplicado**.
     - **Linha de 3 números pequenos** (só os que não se repetem): Lucro realizado · Proventos (12 meses) · Rentabilidade (TIR a.a.). Cada um com o ícone (i) explicando a métrica.
     - **Gráfico de evolução patrimonial** (o atual, com "Comparar com"), em destaque.
     - **Duas colunas:** Distribuição (rosca com seletor) | Aportes por mês.
     - **Duas colunas:** Proventos por mês | Maiores altas e baixas.
     - **Faixa de câmbio e indicadores** no rodapé (já existe).
  3. **Saem** (por serem repetidos): a seção "Mais números" inteira e o bloco "Maiores posições" (a Carteira e a rosca "por ativo" já mostram isso). Se algum número só existia ali, ele vai para o tooltip do número correspondente no topo.
  4. A Visão geral deve caber em **até 2 telas de rolagem** em 1280 × 800.
  5. **Hierarquia visual:** um único número grande por tela; títulos dos blocos em forma de resposta ("Você aportou R$ X em 12 meses"); textos explicativos longos vão para o ícone (i), não ficam abaixo dos gráficos.
- **Critério de pronto:** o menu não tem mais "Desempenho"; as abas Rentabilidade, Comparação e Risco do Painel mostram o mesmo conteúdo de antes; nenhum valor aparece duas vezes na Visão geral; o olho oculta todos os valores em R$ do app; a Visão geral cabe em até 2 rolagens em 1280 × 800.
- **Prioridade:** alta
- **Fase:** ajuste avulso

### M-12 — Números e rótulos inconsistentes no Painel
- **Onde:** Painel (cartões, gráfico de evolução, aportes, altas e baixas) e Rentabilidade
- **Problema:** com a carteira real (posições lançadas em 22/10/2026), a tela mostra números que parecem se contradizer:
  1. O cartão **Ganho** mostra **+R$ 673,32**, mas o gráfico diz "**Ganho de R$ 97,32**" e o título "**Seu patrimônio cresceu R$ 1.473,97**" (que soma aportes ao crescimento e soa como ganho).
  2. No gráfico de evolução, a linha do **total aplicado** não aparece como degraus: surge uma **linha vertical no fim do gráfico**.
  3. "Rentabilidade no ano" diz "**TWR desde 31/12/2025**", mas não há operações antes de 22/10/2026.
  4. Aportes: o título diz "Você aportou R$ 5.106,25" e o subtítulo diz "**o saldo inicial não conta**", mas o valor é justamente o saldo inicial.
  5. "Maiores altas e baixas" no modo **Dia** mostra "**desde 22/10/2026**" (deveria ser a data do fechamento anterior).
  6. "CDI no período" mostra **0,00%** num período de 2 dias (deveria somar os dias publicados ou dizer "ainda não publicado").
  7. TIR e retorno real aparecem só como "indisponível", sem dizer por quê.
- **Mudança:**
  1. **Uma definição única de ganho**, usada em todo o app: *Ganho total = patrimônio − total aplicado (+ lucro realizado + proventos)*. No gráfico, o título usa o mesmo número quando o período é "Tudo"; nos outros períodos, diz "**ganho no período**" e mostra a diferença em relação ao início do período, deixando claro que **aportes não são ganho** (ex.: "Seu patrimônio é R$ 5.779 · ganho de R$ 97 no período · R$ 1.377 de aportes").
  2. Corrigir o desenho do **total aplicado** como linha em degraus visível desde a primeira operação.
  3. Rótulos de período sempre com a **data real de início dos dados** ("desde 22/10/2026, início dos registros").
  4. Aportes: decidir uma regra (o saldo inicial **conta** como aporte na data informada) e deixar o subtítulo coerente.
  5. Altas e baixas: mostrar a data do fechamento usado como referência.
  6. CDI do período: somar os dias publicados e indicar quando o último dia ainda não saiu.
  7. Todo "indisponível" mostra o **motivo** no tooltip (ex.: "TIR precisa de pelo menos 30 dias de histórico").
  8. Teste que confere que **Ganho**, título do gráfico (em "Tudo") e Carteira mostram o mesmo valor.
- **Critério de pronto:** com a carteira atual, nenhum par de números na tela parece se contradizer; todo período mostra a data real de início; todo "indisponível" explica o motivo.
- **Prioridade:** alta
- **Fase:** ajuste avulso, junto com o M-11

---

## Prompt sugerido para enviar ao Claude Code (M-10 a M-12)

Salve este arquivo em `C:\dev\patrion\docs\MUDANCAS.md`, abra uma conversa nova (`/clear`) e cole:

```
Leia CLAUDE.md, docs/PROGRESS.md e docs/MUDANCAS.md. Implemente os itens
pendentes M-10 a M-12, nesta ordem: M-10 (bug de piscar), M-12 (números
e rótulos) e M-11 (Painel único com abas; Desempenho sai do menu).

- Atualize SPEC §16 e DECISIONS.md com a nova organização das telas.
- Faça commit e atualize o PROGRESS.md ao fim de cada item.
- Inclua testes. Confira cada tela no app real em 1280 x 800, nos temas
  claro e escuro, abrindo o executável e olhando a janela (não só
  renderizando widgets). Se não conseguir capturar a janela, diga isso.

Ao final, rode format, analyze, test e build, atualize CHANGELOG (1.4.0) e
faça push (se o push for bloqueado, me avise para eu rodar). Confirme que o
CI ficou verde. Não crie tag nem Release. No relatório, inclua um roteiro
para eu testar cada item.
```
