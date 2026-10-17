# Casos de teste de referência

Valores calculados à mão e conferidos. Eles são a verdade de referência para os testes do motor financeiro (Fase 4) e da sincronização (Fase 5). Se o código discordar, o código está errado, a menos que você encontre um erro aqui. Nesse caso, mostre o cálculo e pergunte antes de alterar.

Arredondamento de exibição: 2 casas para valores em R$. Os cálculos internos usam precisão total.

## 1. Preço médio, venda e eventos (ação BR)

| # | Operação | Detalhe | Quantidade | Custo total | Preço médio |
|---|---|---|---|---|---|
| 1 | Compra | 100 × R$ 30,00 + R$ 5,00 de custos | 100 | 3.005,00 | 30,05 |
| 2 | Compra | 50 × R$ 36,00 + R$ 4,00 de custos | 150 | 4.809,00 | 32,06 |
| 3 | Venda | 60 × R$ 40,00 − R$ 6,00 de custos | 90 | 2.885,40 | 32,06 |
| 4 | Dividendo | R$ 0,50 por ação (90 ações) | 90 | 2.885,40 | 32,06 |
| 5 | Desdobramento 1:2 | — | 180 | 2.885,40 | 16,03 |

Resultados esperados:

- **Venda (op. 3):**
  - valor líquido recebido: 2.394,00;
  - custo baixado: 60 × 32,06 = 1.923,60;
  - lucro realizado: **470,40**.
- **Dividendo (op. 4):**
  - R$ 45,00 registrados como provento;
  - preço médio não muda.
- **Desdobramento (op. 5):**
  - custo total inalterado.
- **Grupamento 10:1 depois da op. 5:**
  - quantidade 18;
  - preço médio 160,30;
  - custo 2.885,40.
- **Editar a op. 1:** mudar a quantidade para 200 recalcula todas as linhas seguintes.

## 2. Juros compostos

- R$ 10.000,00 a 1% a.m. por 12 meses: **R$ 11.268,25**.

## 3. Equivalência de taxas

- 12% a.a. equivale a **0,948879% a.m.**
- 12% a.a. equivale a **0,044982% ao dia útil** (base 252).

## 4. CDI acumulado

- CDI de 10,65% a.a. por 21 dias úteis: fator (1,1065)^(21/252), retorno de **0,846915%**.
- Com R$ 1.000,00 a 100% do CDI: **R$ 1.008,47**.

## 5. XIRR

- Fluxo de −1.000,00 em 01/01/2024 e +1.100,00 em 01/01/2025 (366 dias, convenção /365): XIRR = **9,9714% a.a.**
- Esse valor confirma que a implementação usa dias corridos/365, como o XIRR do Excel.

## 6. TWR versus MWR

Fluxos:

| Data | Evento | Valor da carteira depois |
|---|---|---|
| 01/01/2024 | Aporte de 1.000 | 1.000 |
| 01/01/2025 | Carteira valia 1.100 (+10%); aporte de 1.000 | 2.100 |
| 01/01/2026 | Queda de 10% | 1.890 |

Resultados esperados:

- **TWR:** 1,10 × 0,90 − 1 = **−1,00%** no período.
- **MWR (XIRR):** **−3,7093% a.a.**

A diferença é proposital: este caso testa se a interface explica qual métrica está sendo mostrada.

## 7. Ativo internacional e câmbio

- **Compra:** 10 ações a US$ 100,00, com câmbio de 5,00 → R$ 5.000,00.
- **Hoje:** US$ 110,00, com câmbio de 5,50 → R$ 6.050,00.

Retornos esperados:

- Retorno em USD: **10,00%**.
- Retorno em BRL: **21,00%**.

Decomposição:

- Efeito do ativo: 10,00%.
- Efeito cambial: 10,00%.
- Efeito cruzado: 1,00% (0,10 × 0,10).

## 8. Backtest mínimo (frações permitidas, sem custos)

Ativos X e Y, capital de 1.000, pesos de 50/50.

| | t0 | t1 | t2 |
|---|---|---|---|
| Preço X | 10 | 20 | 10 |
| Preço Y | 10 | 10 | 10 |

Sem rebalanceamento:

- Compra inicial: 50 X e 50 Y.
- Patrimônio: 1.000 → **1.500** → **1.000**.

Com rebalanceamento em t1:

- Em t1, a carteira de 1.500 vira 750 + 750 (37,5 X e 75 Y).
- Em t2, o patrimônio é **1.125**.

Look-ahead: o rebalanceamento em t1 só pode usar preços de t1 ou anteriores. Um teste deve garantir que alterar o preço de t2 não muda nenhuma decisão tomada em t1.

## 9. Sincronização (arquivo .invsave)

Em todos os casos, A e B começam sincronizados.

| # | Cenário | Resultado esperado |
|---|---|---|
| S1 | A cria a operação O1. A exporta e B importa. | B tem O1 com o mesmo `id`. |
| S2 | B importa o mesmo arquivo de novo. | Nada muda; a prévia mostra 0 alterações. |
| S3 | A edita O1 (qtd 10→20). B edita O1 depois (qtd 10→30). A↔B. | Conflito na prévia. Padrão: vence a qtd 30 (HLC maior). Os dois PCs terminam iguais. |
| S4 | A exclui O1. B importa. | O1 fica excluída em B (tombstone). |
| S5 | B importa um save antigo de A, de antes da edição de S3. | Nada regride. |
| S6 | O relógio de B está 2 dias adiantado. B edita, depois A edita. A↔B. | Resultado previsível pelo HLC, sem perder a edição de A por causa do relógio. |
| S7 | A e B cadastram PETR4 separadamente, com UUIDs diferentes. | Após importar, existe um único ativo PETR4, com as operações dos dois PCs ligadas a ele. |
| S8 | Arquivo com um byte alterado. | Recusado pela verificação de checksum; banco intacto. |
| S9 | Falha simulada no meio da importação. | Rollback completo; banco igual ao de antes. |
| S10 | Save com carteiras hipotéticas. | Elas chegam separadas; o patrimônio real de B não muda. |
