# Fórmulas financeiras

Estado em 17/10/2026 (Fase 4). Este documento descreve as fórmulas que o código usa hoje: posições (§1 a §3, Fase 3) e o motor financeiro da SPEC §9 (§4 a §10, Fase 4).

Toda fórmula daqui tem teste. Os casos de referência estão em `CASOS_DE_TESTE.md`.

## 0. Precisão e arredondamento (DECISIONS D-03)

- Valores, quantidades, preços, taxas e câmbio usam `Decimal`, nunca ponto flutuante.
- Divisões internas: 20 casas decimais, meio para o par (`DecimalMath.divide`, `lib/core/money/decimal_math.dart`).
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

Só com preços e saldos informados pelo usuário até a F6. Para a data de hoje (`asOf`):

1. Se há saldo informado para a conta e o ativo, vale o mais recente com data ≤ `asOf`.
2. Senão, `valor = Q × P`, com `P` = preço unitário informado mais recente com data ≤ `asOf`.
3. Sem preço nem saldo: **indisponível** (regra 1). O valor nunca é estimado pelo custo.
4. Preço ou saldo em moeda diferente da posição é ignorado (sem câmbio até a F6).
5. Saldo com data anterior à última operação da posição é marcado como desatualizado.

## 3. Totais do dashboard (`PortfolioSummary`)

Calculados separadamente para cada moeda (nada é convertido até a F6):

- Valor investido = Σ `K` das posições abertas.
- Valor de mercado = Σ valor das posições com preço ou saldo.
- Caixa = Σ caixa das contas na moeda.
- Patrimônio = valor de mercado + caixa. É **parcial** quando há posições sem preço; o custo delas aparece à parte.
- Resultado não realizado = valor de mercado − custo das posições com valor de mercado.
- Retorno simples = resultado não realizado ÷ custo das posições com valor de mercado. Não inclui proventos e não é TWR nem MWR (para esses, ver §8 e §10).
- Lucro realizado e proventos = soma de todas as posições, inclusive encerradas.
- Alocação = valor de mercado de cada grupo (mais o caixa, na alocação por classe) ÷ total. Posições sem preço ficam fora.

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
