# Fórmulas financeiras

Estado em 17/10/2026 (Fase 3). Este documento descreve as fórmulas que o código usa hoje. O motor financeiro completo (SPEC §9: retornos, CAGR, XIRR, TWR, MWR, juros, base 252) entra na Fase 4, e as seções correspondentes serão acrescentadas aqui.

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
- Retorno simples = resultado não realizado ÷ custo das posições com valor de mercado. Não inclui proventos e não é TWR nem MWR (F4).
- Lucro realizado e proventos = soma de todas as posições, inclusive encerradas.
- Alocação = valor de mercado de cada grupo (mais o caixa, na alocação por classe) ÷ total. Posições sem preço ficam fora.
