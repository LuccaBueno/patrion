# Patrion — Lista de mudanças (uso real)

Itens observados no uso da v1.0.0. Cada item traz o problema, a mudança, o critério de pronto e a prioridade.
Ao enviar ao Claude Code, cole esta lista no início do prompt da fase e peça: "Implemente os itens M-xx antes de começar a fase; atualize a SPEC e o DECISIONS.md quando a mudança alterar uma regra."

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
  1. **Parte de cima do menu** (uso diário): Painel (M-04), Carteira (M-05), Operações e Cadastros. As telas das próximas fases (Renda passiva, Benchmarks, Hipotéticas, Simuladores) entram aqui.
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

---

## Prompt sugerido para enviar ao Claude Code

```
Leia CLAUDE.md e docs/PROGRESS.md. Antes da Fase 8, implemente os ajustes
de uso real abaixo (M-01 a M-05). Atualize a SPEC e o DECISIONS.md quando
uma mudança alterar uma regra, inclua testes e confira visualmente no app.
O item M-04 entra só nos itens 1, 2, 3, 6 e 7; os itens 4, 5 e 9 ficam para
a Fase 8. Ao final, rode format, analyze, test e build, atualize PROGRESS.md
e CHANGELOG (versão 1.1.0), faça push e confirme que o CI ficou verde.
Não crie tag nem Release sem eu pedir.

[cole aqui os itens M-01 a M-05]
```
