# Fórmulas financeiras

Estado em 17/10/2026 (Fase 4). Este documento descreve as fórmulas que o código usa hoje: posições (§1 a §3, Fase 3) e o motor financeiro da SPEC §9 (§4 a §10, Fase 4).

Toda fórmula daqui tem teste. Os casos de referência estão em `CASOS_DE_TESTE.md`.

## 0. Precisão e arredondamento (DECISIONS D-03)

- Valores, quantidades, preços, taxas e câmbio usam `Decimal`, nunca ponto flutuante.
- Divisões internas: 20 casas decimais, meio para o par (`DecimalMath.divide`, `lib/core/money/decimal_math.dart`). A divisão é feita só com inteiros (o resultado é o mesmo da fração exata arredondada), e `rescale` devolve a forma compacta do número, para cadeias longas de multiplicações (o índice do TWR de 10 anos) não crescerem a cada passo.
- Exibição: 2 casas para moeda, meio para cima (`Fmt.money`). Percentuais com 2 casas na tela.
- Somas, subtrações e multiplicações são exatas.

## 1. Posições e caixa (`PortfolioCalculator`, `lib/domain/portfolio/portfolio_calculator.dart`)

As posições não são gravadas: são recalculadas a partir de todas as operações vivas sempre que algo muda. Por isso, editar uma operação antiga atualiza tudo o que vem depois dela (SPEC §7).

### 1.1 Ordem de processamento

1. Data da operação (`trade_date`).
2. No mesmo dia, a ordem de criação (`id`, UUID v7).
3. Exceção: as duas pontas de uma transferência têm a mesma data; a saída é sempre processada antes da entrada.

### 1.2 Notação

Para cada operação: `V` = valor bruto (o informado ou quantidade × preço unitário), `C` = custos + impostos informados, `L = V − C` (líquido). Para cada posição (conta + ativo): `Q` = quantidade, `K` = custo total, `R` = lucro realizado.

Preço médio: `PM = K ÷ Q` (só quando `Q > 0`).

### 1.3 Efeito de cada tipo

| Tipo | Posição | Caixa da conta |
|---|---|---|
| Compra, aporte, reinvestimento | `Q += q`; `K += V + C` | `−(V + C)` |
| Venda; resgate com quantidade | `B = K × q ÷ Q`; `Q −= q`; `K −= B`; `R += L − B` | `+L` |
| Resgate sem quantidade | `f = min(1, V ÷ S)`, com `S` = último saldo informado até a data (ou `K`, se não houver); `B = K × f`; `K −= B`; `R += L − B`; se `f = 1`, `Q = 0` | `+L` |
| Depósito | — | `+V` |
| Retirada | — | `−(V + C)` |
| Transferência de dinheiro | — | origem `−(V + C)`; destino `+L` |
| Transferência de ativo (custódia) | origem: `B = K × q ÷ Q`, `Q −= q`, `K −= B` (sem lucro); destino: `Q += q`, `K += B` | origem `−C` |
| Dividendo, JCP, rendimento de FII, juros | proventos brutos `+= V`, líquidos `+= L`; `PM` não muda | `+L` |
| Amortização | `A = min(V, K)`; `K −= A`; `R += L − A` | `+L` |
| Bonificação | `Q += q`; `K += V` (custo atribuído, se informado) | `−C` |
| Desdobramento e grupamento (de `a` para `b`) | `Q = Q × b ÷ a`; `K` não muda | `−C` |
| Vencimento | `R += L − K`; `Q = 0`; `K = 0` | `+L` |
| Taxa, imposto, retenção | — | `−(V + C)` |
| Ajuste manual com ativo | `Q += q`; `K += V` (podem ser negativos) | — |
| Ajuste manual sem ativo | — | `+V` (pode ser negativo) |

Convenções brasileiras (SPEC §9): o preço médio inclui os custos de compra; proventos não alteram o preço médio; custos de venda reduzem o valor recebido; desdobramento e grupamento mantêm o custo total.

### 1.4 Inconsistências sinalizadas

- Venda, resgate ou transferência maior que a posição na data (`oversold`).
- Entrada de transferência sem a ponta de saída.
- Ativo inexistente; moeda da operação diferente da moeda da posição.

O serviço de operações recusa gravar, editar ou excluir uma operação que crie uma inconsistência nova.

## 2. Valor de mercado (`PortfolioValuator`)

Para a data de hoje (`asOf`), conforme a fonte de preço do ativo:

**Ativo com preço informado** (`price_source = manual`):

1. Se há saldo informado para a conta e o ativo, vale o mais recente com data ≤ `asOf`.
2. Senão, `valor = Q × P`, com `P` = preço unitário informado mais recente com data ≤ `asOf`.

**Ativo com cotação automática** (`price_source = market`): vale o mais recente entre o saldo informado, o preço informado e o preço de mercado (§2.1). Na mesma data, vale o informado pelo usuário. Com o preço de mercado, `valor = Q × P` e a posição guarda a fonte, a data, o tipo e o atraso do preço.

Em todos os casos:

3. Sem preço nem saldo: **indisponível** (regra 1). O valor nunca é estimado pelo custo.
4. Preço ou saldo em moeda diferente da posição é ignorado (o valor da posição não é convertido).
5. Saldo com data anterior à última operação da posição é marcado como desatualizado.

### 2.1 Preço de mercado (`MarketPricing`, `MarketPriceBook`; `lib/domain/market/market_price.dart`)

Montado só com o que está guardado no banco (sem rede):

- **Candidatos**: as cotações guardadas do ativo (uma por fonte) e o último fechamento guardado (`mkt_prices`, tipo fechamento, preço bruto da fonte).
- **Escolha**: vale a data de referência mais recente; na mesma data, a de instante mais novo. A data de uma cotação é o dia do instante dela no horário de Brasília (UTC−3).
- **COTAHIST**: o preço vem por lote de `fator de cotação` ações; preço unitário = fechamento ÷ fator.
- **Tesouro Direto**: o título cadastrado é ligado ao do Tesouro Transparente pelo produto (Selic, Prefixado, IPCA+, com ou sem juros semestrais, Renda+, Educa+) e pelo vencimento. Só com uma correspondência única; o preço é o PU de venda da manhã (o que o Tesouro paga no resgate antecipado), ou o PU base se faltar.
- **Desatualizado**: a data de referência é anterior ao último dia útil (calendário B3) antes de hoje; em cripto, que não fecha, anterior a ontem. O valor continua aparecendo, com a data e um ícone.

### 2.2 Indicadores derivados (`MarketIndicators`, `lib/domain/market/market_indicators.dart`)

- **CDI anualizado**: `(1 + d ÷ 100)^252 − 1`, com `d` = último CDI diário publicado (% ao dia). Exemplo: 0,055131% a.d. → 14,90% a.a.
- **IPCA em 12 meses**: `∏(1 + mᵢ ÷ 100) − 1` sobre os 12 meses terminados no último mês publicado. Se faltar algum mês, fica **indisponível** (nada é preenchido). Exemplo: 0,5% em 12 meses → 6,1678%.

### 2.3 Patrimônio total em reais (`ConsolidatedEquity`)

`Σ patrimônio(moeda) × câmbio(moeda)`, com o patrimônio em reais somado sem conversão e o câmbio mais recente guardado de cada moeda contra o real (PTAX de fechamento; na mesma data, a PTAX antes da referência do BCE), pelo valor de venda (ou de compra, se faltar o de venda). Arredondado a 2 casas, meio para cima. Se faltar o câmbio de alguma moeda, o total fica **indisponível**; é **parcial** se algum patrimônio somado for parcial. Os totais por moeda (§3) continuam sem conversão.

### 2.4 Carteira por ativo e variação do preço (`Holdings`, `lib/domain/portfolio/holdings.dart`; `MarketPricing.withReferences`)

- Cada ativo soma as posições de todas as contas: quantidade, **total aplicado** (custo da posição atual, com custos de compra), **valor da posição** (soma dos valores de mercado; **indisponível** se alguma conta não tem preço nem saldo), lucro realizado e proventos.
- **Preço médio** = total aplicado ÷ quantidade (20 casas, half-even).
- **Valorização** = (cotação atual − preço médio) ÷ preço médio. Sem preço unitário (avaliação por saldo): valor da posição ÷ total aplicado − 1. Não inclui proventos.
- **Lucro em R$** = (valor da posição − total aplicado) + lucro realizado.
- **% da carteira** = valor da posição ÷ soma dos valores das posições com preço na mesma moeda.
- **Variação do dia**: por unidade, cotação atual − último fechamento guardado **antes** da data da cotação; na posição, quantidade × essa diferença; em %, a diferença ÷ o fechamento. **Variação no mês**: o mesmo contra o último fechamento até o fim do mês anterior. Os fechamentos são os brutos guardados (COTAHIST e outros), por unidade (`unitClose`), dos últimos 45 dias. Sem o fechamento de referência, a variação é **indisponível** (nunca estimada).
- **Ordem da lista**: com posição, pelo valor da posição, decrescente (sem cotação, pelo total aplicado; outras moedas convertidas pelo câmbio mais recente guardado, só para ordenar); ativos com zero cotas no fim, pelo código.

### 2.5 Gráfico do ativo e preço ajustado (`PriceSeries`, `lib/domain/market/price_series.dart`; M-07)

- **Fechamentos**: o preço publicado de cada pregão, por unidade (`unitClose`, que divide pelo fator de cotação), um por data.
- **Preço ajustado por proventos e eventos** (tipo "calculado"; nunca é o preço negociado): para trás, cada preço anterior à data ex de um evento é multiplicado pelo fator do evento; os fatores se acumulam, e o último preço não muda.
  - provento em dinheiro (dividendo, JCP, rendimento de FII, amortização, outros) de valor `D` por ação: `1 − D ÷ P`, com `P` o último fechamento antes da data ex (a data com). JCP pelo valor bruto;
  - desdobramento, grupamento ou bonificação de multiplicador `q` (2 num 1:2; 0,1 num grupamento 10:1; 1,1 numa bonificação de 10%): `1 ÷ q`;
  - ficam de fora: eventos suspeitos, sem valor ou fator, fora da série e proventos com `D ≥ P`.
  - Exemplo real (BBAS3, desdobramento 1:2 em 16/04/2024): 56,46 em 15/04 vira 28,23; 27,91 em 16/04 fica igual. Sem o ajuste, a queda de −50,6% aparece no gráfico com um aviso.
- **Saltos suspeitos**: variação de pregão para pregão a partir de −40% ou +66,7% sem evento em ações com data ex entre o dia seguinte ao primeiro pregão e três dias depois do segundo. O gráfico avisa; o ajuste não corrige (`FONTES_DE_DADOS.md` §1).
- **Período**: a partir de hoje menos 31, 183, 366, 1.827 ou 3.653 dias (1M a 10A), ou a série toda; disponível se o primeiro fechamento for até 10 dias depois do início. **Variação do período** = último ÷ primeiro − 1; máxima e mínima com as datas.

## 3. Totais do dashboard (`PortfolioSummary`)

Calculados separadamente para cada moeda (o total em reais está em §2.3):

- Valor investido = Σ `K` das posições abertas.
- Valor de mercado = Σ valor das posições com preço ou saldo.
- Caixa = Σ caixa das contas na moeda.
- Patrimônio = valor de mercado + caixa, com o **controle de caixa ligado**. Com ele desligado (padrão desde a 1.1.0, DECISIONS D-44), o caixa não entra: **patrimônio = valor de mercado das posições**, e dinheiro parado entra como um ativo da classe Caixa com saldo informado. É **parcial** quando há posições sem preço; o custo delas aparece à parte. A TIR e o resultado não dependem do controle de caixa (compras e vendas são sempre fluxos).
- Resultado não realizado = valor de mercado − custo das posições com valor de mercado.
- Retorno simples = resultado não realizado ÷ custo das posições com valor de mercado. Não inclui proventos e não é TWR nem MWR (para esses, ver §8 e §10).
- Lucro realizado e proventos = soma de todas as posições, inclusive encerradas.
- Alocação = valor de mercado de cada grupo (mais o caixa, na alocação por classe) ÷ total. Posições sem preço ficam fora.

### 3.1 Painel (`DashboardMetrics`, `lib/domain/portfolio/dashboard_metrics.dart`; M-04)

- **Resultado total %** = resultado total (§10) ÷ dinheiro aplicado (compras e aportes, com custos, desde o início).
- **Variação do dia da carteira** = Σ quantidade × (cotação − fechamento anterior) dos ativos com cotação de mercado e fechamento anterior guardado; em %, ÷ Σ quantidade × fechamento anterior desses ativos. Ativos sem a variação ficam fora e o valor aparece como **parcial**; sem nenhum, **indisponível**.
- **Aportes do mês** = Σ (valor + custos) das compras, aportes e reinvestimentos com data no mês, na moeda; **no ano**, do 1º de janeiro até hoje. A compra de **saldo inicial** (cadastro rápido) não conta. **Vendas** = Σ (valor − custos) de vendas e resgates. **Proventos** = Σ (valor − custos) de dividendos, JCP, rendimentos e juros, pela data registrada.
- **Distribuição** = §3 (alocação), por ativo, classe, setor (do cadastro; sem setor, "Sem setor informado") e instituição. Até 7 fatias; o resto vira "Outros".
- **Maiores altas e baixas** = ativos com a variação do dia (ou do mês, §2.4) calculada, ordenados pela variação %.

### 3.2 Evolução patrimonial (`WealthHistory`, `lib/domain/portfolio/wealth_history.dart`; M-09)

- Um ponto por dia útil (e por dia com operação), da primeira operação até hoje, em reais.
- **Patrimônio do dia** = soma, por ativo, da quantidade no fim do dia (o motor de posições até a data, §1) × o último fechamento até a data (`unitClose`), ou o preço ou saldo informado mais recente, pelas mesmas regras da Carteira (§2 e §2.1); outras moedas pelo câmbio do dia (último até a data; PTAX antes da referência do BCE). O último dia usa os valores do retrato da Carteira: os números finais são os mesmos.
- **Total aplicado** = Σ compras, aportes, reinvestimentos e ajustes manuais (valor + custos) − Σ vendas, resgates, amortizações e vencimentos (valor − custos), acumulados. Proventos não entram (saem da carteira; o patrimônio não inclui o caixa). **Ganho** = patrimônio − aplicado; em % sobre o aplicado.
- **Ativo sem preço num dia** (comprado antes do primeiro fechamento guardado, ou com preço informado só depois): fica fora do patrimônio e do aplicado até o primeiro preço; então entra com o aplicado acumulado até ali e, no TWR, como um aporte do próprio valor (sem retorno inventado). **Sem nenhum preço até hoje**: fora da evolução (o gráfico diz quais).
- **TWR** (§8.3) com os fluxos do dia no fim do dia: `antes = patrimônio − (aportes − resgates) + proventos`, fator `antes ÷ patrimônio da véspera`. Os proventos contam como retorno (saem como retirada). Dia que começa com a carteira vazia não tem retorno. **Rentabilidade no ano** = TWR de 31/12 do ano anterior até hoje.

### 3.3 Comparação com índices (`IndexLevels`, `Benchmark`, `lib/domain/finance/benchmark.dart`; M-09)

- **Nível do índice** por data: CDI = Π(1 + taxa diária ÷ 100) dos dias úteis publicados; IPCA = Π(1 + variação mensal ÷ 100), com cada mês distribuído de forma geométrica pelos dias corridos (`(1 + v)^(1/dias)` por dia; o último dia do mês fica exato) e parado depois do último mês publicado; Ibovespa = os próprios pontos de fechamento. Sem dado num dia, vale o nível anterior.
- **Em R$, "os mesmos aportes no índice"** (hipotético): `S(d) = S(d−1) × nível(d) ÷ nível(d−1) + (aplicado(d) − aplicado(d−1))`. Só existe se o índice cobre o primeiro dia da carteira. Os proventos não entram (como no patrimônio).
- **Em %**: carteira = TWR do período; índice = nível(fim) ÷ nível(início) − 1; os dois começam em 0% no início do período. A diferença aparece em pontos percentuais.
- Exemplo (teste): aportes de 1.000 no dia 1 e 1.200 no dia 3, CDI fictício de 1% ao dia: 1.000; 1.010; 2.220,10; 2.242,301.

### 3.4 Rentabilidade por período e mês a mês (`ReturnTable`, `PeriodPerformance`, `lib/domain/portfolio/performance_report.dart`; F8)

Tudo sai do índice do TWR da evolução patrimonial (§3.2), com os proventos como retorno.

- **Mês e ano** (§8.4): `índice no último ponto do mês (ou do ano) ÷ índice no último ponto antes dele − 1`. Mês sem nenhum ponto fica em branco. O primeiro mês e o primeiro ano começam no primeiro ponto (parciais); o ano corrente vai até o último ponto. **Acumulado** do ano = `índice no fim do ano ÷ índice no primeiro ponto − 1`.
- **CDI do ano**: crescimento do nível do CDI (§3.3) entre a mesma base e o mesmo fim do retorno do ano (o último ponto do ano anterior, ou o primeiro ponto, até o último ponto do ano). **% do CDI** = `TWR do ano ÷ CDI do ano` (só com CDI positivo).
- **Período** (1M a 10A, YTD, Tudo, personalizado): dia-base = hoje menos o período (YTD: 31/12 do ano anterior; personalizado: a véspera do primeiro dia escolhido); o retorno conta do fim do dia-base (o último ponto até ele) até o último ponto. Um período só aparece se a carteira já existia no dia-base.
- **CDI e IPCA do período**: `nível(fim) ÷ nível(base) − 1`, com o nível de cada data sendo o último publicado até ela (o IPCA para no último mês publicado, e a tela diz até quando). **Retorno real** = `(1 + TWR) ÷ (1 + IPCA) − 1` (§8.1).
- **CAGR** (só em períodos de mais de 366 dias): `(1 + TWR)^(365 ÷ dias) − 1`.
- **TIR do período** (§7): fluxos = `−patrimônio` no fim do dia-base, `proventos − (aportes − resgates)` em cada dia seguinte e `+patrimônio` no último dia. Em menos de 365 dias, mostrada como o equivalente do período (`(1 + taxa)^(dias ÷ 365) − 1`), porque anualizar prazos curtos exagera o resultado.
- Exemplos (testes): +10% em jan, fev e dez de 2025 dão 33,1% no ano e, com CDI de 10%, 331% do CDI; o caso de `CASOS_DE_TESTE.md` §6 dá TWR −1,00% e TIR −3,7093% a.a.

### 3.5 Benchmarks (`BenchmarkComparison`, `IndexLevels`; `lib/domain/finance/benchmark_comparison.dart` e `benchmark.dart`; F8)

- **Nível de cada índice** pela unidade publicada (§3.3): taxa diária (CDI, Selic) = Π(1 + taxa ÷ 100); variação mensal (IPCA, IGP-M) = Π(1 + v ÷ 100), distribuída pelos dias do mês e parada no último mês publicado; pontos (Ibovespa, IFIX, S&P 500, Nasdaq) e preço (Bitcoin em US$) = o próprio valor. Sem dado num dia, vale o último até a data.
- **Índices em dólar** (Bitcoin, S&P 500, Nasdaq) em reais, calculado: `nível_R$(d) = nível_US$(d) × PTAX(d)`, com a PTAX de venda do último dia útil até `d`. Datas antes da primeira PTAX ficam de fora. O retorno em dólar aparece ao lado, e `(1 + r_R$) = (1 + r_US$) × (1 + r_câmbio)` (§9).
- **Intervalo**: do fim do dia-base do período (o mesmo da Rentabilidade, §3.4) até `fim = mín(último dia do período, último dia com dado do índice)`. O índice precisa ter dado até o dia-base; senão fica indisponível, com a data desde quando há dados.
- **Retorno acumulado** = `nível(fim) ÷ nível(base) − 1`; **ao ano** (só acima de 366 dias) = `(1 + acumulado)^(365 ÷ dias) − 1`; **carteira** = TWR do mesmo intervalo (base até `fim`); **diferença** = carteira − índice, em pontos percentuais.
- **Série normalizada** (gráfico): `100 × nível(d) ÷ nível(base)`, com 100 no dia-base; a carteira usa o índice do TWR.
- Exemplos (testes): Ibovespa de 100 a 110 com a carteira de 1.000 a 1.200: índice +10%, carteira +20%, diferença +10 p.p.; Bitcoin de US$ 100 a 110 com a PTAX de 5,00 a 5,50: +21% em reais e +10% em dólar; CDI de 21% em 731 dias: 9,99% ao ano.

## 4. Potências, logaritmos e exponenciais (`DecimalMath`, DECISIONS D-26)

- `ln x`, `e^x` e `b^e` com expoente fracionário são calculados sem ponto flutuante: ponto fixo com 60 casas internas, resultado com 20 casas, meio para o par.
- `b^e` com `e` inteiro: multiplicações sucessivas (aceita base negativa). Com `e` fracionário: `e^(e × ln b)`, só para `b > 0`.
- `ln`, `exp` e `pow` lançam erro nos casos indefinidos (`ln 0`, `0^−1`, base negativa com expoente fracionário).

## 5. Juros e bases de contagem (`Interest`, `BusinessCalendar`; `lib/domain/finance/`)

Taxas em fração (0,12 = 12%).

| Conceito | Fórmula |
|---|---|
| Juros simples | `M = PV × (1 + i × n)` |
| Juros compostos | `M = PV × (1 + i)^n` (`n` pode ser fracionário) |
| Taxa equivalente | `i_destino = (1 + i_origem)^(p_origem ÷ p_destino) − 1`, com `p` = períodos por ano (12% a.a. → a.m.: `1,12^(1/12) − 1`) |
| Nominal → efetiva | `(1 + j ÷ m)^m − 1`, com `m` capitalizações por ano |
| Efetiva → nominal | `m × ((1 + i)^(1/m) − 1)` |
| Fator de uma taxa anual entre duas datas | `(1 + i)^(dias ÷ dias do ano)`; linear: `1 + i × dias ÷ dias do ano` |

Bases (`DayCount`):

| Base | Dias | Dias do ano |
|---|---|---|
| `bus252` | dias úteis de `início` (incluído) a `fim` (excluído) | 252 |
| `act365` | dias corridos | 365 |
| `act360` | dias corridos | 360 |
| `30_360` | 30E/360: `360 × Δano + 30 × Δmês + (d₂ − d₁)`, com dia 31 → 30 | 360 |

Uma taxa anual nunca é dividida por 365 como regra geral: o prazo é convertido pela base do instrumento.

Calendário de dias úteis (`BusinessCalendar.brazil`): segunda a sexta, menos os feriados nacionais do calendário da ANBIMA:

- fixos: 1/1, 21/4, 1/5, 7/9, 12/10, 2/11, 15/11, 20/11 (a partir de 2024) e 25/12;
- móveis, contados da Páscoa (algoritmo de Meeus/Jones/Butcher): segunda e terça de Carnaval (−48 e −47 dias), Sexta-feira Santa (−2) e Corpus Christi (+60).

Feriados estaduais e municipais não entram. Datas extraordinárias podem ser acrescentadas.

## 6. CDI e Selic (`IndexAccrual`)

- Fator diário de uma taxa anual `r` (base 252) a `p` do indexador: `1 + p × ((1 + r)^(1/252) − 1)`.
- Acumulado de uma série diária (uma taxa por dia útil): produto dos fatores diários.
- Taxa constante por `du` dias úteis: a 100%, `(1 + r)^(du/252)`; com outro `p`, fator diário`^du`.
- Taxa adicional (CDI + s): o fator do indexador é multiplicado por `(1 + s)^(du/252)`.
- Precisão total. Os truncamentos da B3 (fator diário com 8 casas, acumulado com 16) não são aplicados; a diferença fica abaixo de um centavo em valores usuais.

Exemplo (`CASOS_DE_TESTE.md` §4): 10,65% a.a. por 21 dias úteis → `1,1065^(21/252) − 1 = 0,846915%`; R$ 1.000,00 → R$ 1.008,47.

## 7. XIRR (`Xirr`, `lib/domain/finance/cash_flow.dart`)

Fluxos do ponto de vista do investidor: negativo quando o dinheiro sai (compra, aporte), positivo quando volta (venda, provento, valor final).

`Σ Fᵢ ÷ (1 + r)^((dᵢ − d₀) ÷ 365) = 0`

- Dias corridos ÷ 365, a convenção do XIRR do Excel (`CASOS_DE_TESTE.md` §5: 366 dias dão 9,9714% a.a., não 10%).
- Solução: o valor presente é avaliado numa grade de −99% a 100.000% a.a.; no intervalo com troca de sinal mais perto de 10%, Newton protegido por bisseção até a taxa variar menos de 10⁻¹².
- Sem fluxos positivos e negativos, ou com todos na mesma data: sem solução ("indisponível").
- Fluxos com mais de uma troca de sinal podem ter mais de uma TIR: o resultado é sinalizado (`multipleSignChanges`).

## 8. Retornos (`Returns`, `Twr`, `PeriodReturns`; `lib/domain/finance/returns.dart`)

Toda métrica de retorno tem uma metodologia (`ReturnMethod`), e a tela diz qual está mostrando.

### 8.1 Simples, acumulado e real

- Simples: `final ÷ inicial − 1`.
- Acumulado: `Π(1 + rᵢ) − 1`.
- Real: `(1 + nominal) ÷ (1 + inflação) − 1`.

### 8.2 Anualização e CAGR

- Anualizar um retorno do período: `(1 + r)^(base ÷ dias) − 1`, com base 365 (dias corridos, padrão) ou 252 (dias úteis).
- Desanualizar: `(1 + a)^(dias ÷ base) − 1`.
- CAGR: `(final ÷ inicial)^(365 ÷ dias) − 1`.
- Não anualiza com prazo zero nem com retorno ≤ −100%.

### 8.3 TWR

Pontos com o valor da carteira no fim do dia antes do fluxo (`Vᵢ`) e o fluxo externo do dia (`Fᵢ`: aporte +, retirada −):

`TWR = Π (Vᵢ ÷ (Vᵢ₋₁ + Fᵢ₋₁)) − 1`

- Subperíodo sem capital (valor anterior e atual zero) é pulado.
- Valor que surge do zero sem aporte: retorno indefinido ("indisponível").
- Exemplo (`CASOS_DE_TESTE.md` §6): `1100 ÷ 1000 × 1890 ÷ 2100 − 1 = −1,00%`, enquanto o MWR dos mesmos fluxos é −3,7093% a.a. O TWR mede os ativos; o MWR mede o investidor, que aportou mais antes da queda.

### 8.4 Retornos diários, mensais e anuais

A partir do índice do TWR (1 no primeiro ponto, multiplicado pelo fator de cada subperíodo): retorno do período = `índice no último ponto do período ÷ índice no último ponto antes dele − 1`. O primeiro período começa no primeiro ponto (pode ser parcial).

## 9. Câmbio (`FxDecomposition`)

`(1 + r_BRL) = (1 + r_ativo) × (1 + r_câmbio)`, então `r_BRL = r_ativo + r_câmbio + r_ativo × r_câmbio`.

- `r_ativo`: retorno na moeda original.
- `r_câmbio`: variação da cotação da moeda em BRL.
- Efeito cruzado: `r_ativo × r_câmbio`.

Exemplo (`CASOS_DE_TESTE.md` §7): US$ 100 → 110 e câmbio 5,00 → 5,50: ativo 10%, câmbio 10%, cruzado 1%, total em BRL 21%.

## 10. Desempenho de ativos e da carteira (`PerformanceCalculator`, `lib/domain/portfolio/performance.dart`)

Fluxos do investidor por ativo (somando todas as contas) ou por moeda (todos os ativos da moeda). `V` = valor bruto, `C` = custos + impostos.

| Operação | Líquido | Bruto (antes de custos) | Sem proventos |
|---|---|---|---|
| Compra, aporte, reinvestimento | `−(V + C)` | `−V` | igual ao líquido |
| Venda, resgate, amortização, vencimento | `+(V − C)` | `+V` | igual ao líquido |
| Dividendo, JCP, rendimento, juros | `+(V − C)` | `+V` | fora |
| Taxa, imposto, retenção do ativo | `−(V + C)` | fora | igual ao líquido |
| Bonificação, desdobramento, grupamento, transferência entre contas | `−C` | fora | igual ao líquido |
| Ajuste manual com ativo | `−V` | `−V` | igual ao líquido |
| Depósito e retirada | fora (caixa) | fora | fora |
| Valor final | `+` valor de mercado das posições abertas | igual | igual |

- Data do valor final: a mais recente entre a dos preços e saldos usados e a da última operação.
- Sem preço ou saldo em alguma posição aberta: valor final e TIR "indisponíveis" (nunca estimados pelo custo).
- Resultado total = valor final + Σ fluxos líquidos (vendas + proventos − aplicações − custos). Sem proventos: o mesmo sem os proventos.
- MWR = XIRR dos fluxos (§7). Com menos de 365 dias, a tela mostra o equivalente no período: `(1 + TIR)^(dias ÷ 365) − 1`.
- O caixa parado nas contas não entra: é a TIR dos investimentos.

## 11. Risco (`Risk`, `Concentration`, `lib/domain/finance/risk.dart`; `RiskService`; F8)

Séries de nível: a carteira pelo índice do TWR (§3.2), cada ativo pelo preço ajustado por proventos e eventos (§2.5), os índices pelos níveis de §3.3. A janela do período começa no último nível até o dia-base (§3.4).

- **Retornos**: `rᵢ = nívelᵢ ÷ nívelᵢ₋₁ − 1`, entre níveis consecutivos.
- **Retornos por ano** observados: `n × 365,25 ÷ (dias corridos da amostra)` (≈ 252 em pregões da B3, 365 em cripto); usados para anualizar.
- **Volatilidade** = desvio padrão amostral (n − 1) dos retornos × √(retornos por ano). Mínimo de 20 retornos.
- **Queda máxima (drawdown)** = mín(`nível ÷ maior nível anterior − 1`), com o pico, o fundo e a **recuperação** (primeiro dia, depois do fundo, em que o nível volta ao do pico; sem recuperação até o fim do período, diz isso).
- **Correlação** (Pearson) dos retornos entre as datas que as duas séries têm em comum; mínimo de 60 retornos em comum. Os 10 maiores ativos da carteira.
- **Beta** = `cov(r_carteira, r_Ibovespa) ÷ var(r_Ibovespa)`, nas datas em comum. **Sharpe** = média ÷ desvio dos retornos em excesso ao CDI do mesmo intervalo (`rᵢ − CDI(dᵢ₋₁, dᵢ)`), × √(retornos por ano). Os dois só com 12 meses (365 dias e mais de 200 retornos); sem o índice, indisponíveis.
- **Concentração** (por ativo, classe, setor, país ou moeda; valores em reais da Carteira): maior peso, soma dos cinco maiores, **HHI** = Σ pesoᵢ² (de 1/n a 1) e o número efetivo `1 ÷ HHI`.
- **Exposição cambial** e **liquidez**: peso de cada moeda e de cada liquidez do cadastro (sem ela, a padrão da classe: diária para bolsa, cripto, Tesouro e caixa; "não informada" para renda fixa e produtos bancários).
- **Alocação-alvo**: para cada classe, `peso − alvo` em p.p. e `patrimônio × alvo − valor da classe` em reais (quanto falta, +, ou sobra, −). Informação, não recomendação.
- Exemplos (testes): ±1% em 20 dias corridos dão 19,61% a.a.; níveis 100, 120, 90, 100, 125 dão queda de 25% recuperada no último dia; retornos 1,5 × os do mercado dão beta 1,5; CDI + 0,1% ± 1% ao dia dá Sharpe 1,9088; pesos 50/30/20 dão HHI 0,38 (2,63 posições efetivas).
