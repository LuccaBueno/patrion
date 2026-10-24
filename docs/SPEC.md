# Especificação — Patrion

Este é o documento de referência. As fases e prioridades estão em §21. O que não pertence à fase atual é referência futura: não implemente antes da hora.

## 1. Objetivo

Aplicativo pessoal para:

- registrar investimentos;
- acompanhar cotações e indicadores;
- calcular rentabilidade e evolução patrimonial;
- comparar com benchmarks;
- analisar risco, concentração e renda passiva;
- simular estratégias com carteiras hipotéticas (backtest e projeções).

Os dados ficam no computador e são sincronizados entre PCs por arquivo, sem internet.

O app não é corretora, não executa ordens e não faz recomendações de investimento.

## 2. Plataformas

A v1 roda no Windows 10 e 11 (x64). Android e iOS ficam para o futuro, reaproveitando `domain/`, `application/` e `data/`.

## 3. Dados locais, privacidade e offline

**Banco e persistência**

- O banco SQLite é criado na primeira execução, numa pasta persistente do usuário (por exemplo, `%APPDATA%\Patrion\`). A pasta final é decidida na Fase 1.
- As migrações são versionadas e testadas.
- Operações com várias escritas usam transação.

**Funcionamento offline**

Sem internet, o app permite:

- consultar a carteira;
- registrar operações;
- calcular métricas;
- ver o histórico salvo;
- rodar simulações com dados já baixados;
- gerar relatórios;
- exportar e importar o arquivo de save.

Funções que precisam de internet avisam quando não há conexão.

**Privacidade**

- O app não pede senhas bancárias.
- O app não guarda chaves privadas de cripto.
- A tela "Fontes de dados" explica o que é enviado a cada provedor.

**Bloqueio do app (v1.x, fase F5B)**

Proteção dos dados deste PC contra quem tem acesso ao computador ou a uma cópia da pasta de dados. Impacto na arquitetura e preparação em `DECISIONS.md` D-24.

- **Banco criptografado com SQLCipher.** Sem a chave, o arquivo `patrion.db` não pode ser lido. Os backups (§11) também ficam criptografados.
- **Senha na abertura.** O banco só é aberto depois da senha correta. A senha não é guardada: dela se deriva, com uma função de derivação lenta (KDF), a chave que libera a chave do banco.
- **Desbloqueio opcional pelo Windows Hello** (rosto, digital ou PIN), configurável por PC. A senha continua valendo como alternativa.
- **Bloqueio por inatividade.** Depois de um tempo configurável sem uso (padrão: 15 minutos; opção "nunca"), o app fecha o banco, limpa os dados da memória e volta à tela de desbloqueio. Também há um botão "Bloquear agora".
- **Chave de recuperação.** Ao ativar o bloqueio, o app mostra uma chave de recuperação, uma única vez, para o usuário guardar fora do PC. Ela libera o banco se a senha for esquecida e permite definir uma nova. Sem senha e sem chave de recuperação, os dados não podem ser recuperados, e o app avisa isso claramente.
- **Ativação opcional.** O bloqueio é ativado nas Configurações. A conversão do banco aberto para criptografado é feita com backup antes e pode ser desfeita (desativar volta ao banco aberto, com a senha).
- **Por PC.** Cada computador tem a própria senha. O arquivo de save (§10) tem proteção própria (senha do arquivo), definida junto com esta fase.
- **Testes obrigatórios:** banco ilegível sem a chave; senha errada recusada; troca de senha sem perda de dados; recuperação pela chave; bloqueio por inatividade fecha o banco; backup criptografado restaurável; migração de schema com o banco criptografado.

## 4. Fontes de dados

Antes de implementar (Fase 1), pesquise a documentação atual de cada fonte. Não presuma que um serviço é gratuito, ilimitado, oficial ou em tempo real.

O resultado vai em `docs/FONTES_DE_DADOS.md`, com uma matriz por provedor contendo:

- dados disponíveis e cobertura;
- limites de requisição e custo;
- necessidade de chave;
- frequência de atualização;
- profundidade do histórico;
- se o histórico vem ajustado por proventos e eventos;
- licença e condições de uso;
- limitações e alternativa em caso de falha.

**Candidatos a avaliar**

- Banco Central (SGS e PTAX)
- IBGE (SIDRA)
- CVM (dados abertos)
- B3
- Tesouro Direto e Tesouro Transparente
- brapi
- Alpha Vantage
- Finnhub
- Twelve Data
- Stooq
- CoinGecko
- outras fontes relevantes

**Implementação**

- Adaptadores independentes.
- Cache.
- Timeout.
- Retentativa com backoff.
- Controle de limites de requisição.
- Sem requisições duplicadas.
- Fonte e data registradas em cada dado.

**Ponto crítico**

O backtest de retorno total depende de histórico de ativos brasileiros com proventos e eventos corporativos (desdobramentos, grupamentos, bonificações). Se nenhuma fonte gratuita for viável, informe e proponha uma alternativa, por exemplo:

- backtest só de retorno de preço, com aviso claro;
- proventos vindos de outra fonte;
- importação manual por CSV.

## 5. Atualização de dados

**Automática (com o app aberto)**

- Intervalo configurável.
- Prioridade para os ativos da carteira.
- Respeito aos limites das APIs.
- Registro da última atualização.
- Sinalização de dados desatualizados e de erros.
- **Histórico completo em segundo plano** (ajuste M-08, DECISIONS D-48): ao cadastrar um ativo e ao abrir o app, os fechamentos diários desde o ano inicial (padrão: 10 anos, ou desde a listagem) de todos os ativos com cotação automática, inclusive os de posição encerrada, com os proventos e eventos. Na B3, um arquivo anual do COTAHIST por vez, para todos os ativos, apagado depois de lido. Progresso discreto no menu; continua de onde parou na próxima abertura. Fontes de dados mostra, por ativo, desde quando há histórico e o botão "Baixar histórico completo".

**Manual**

O usuário pode atualizar:

- um ativo, uma categoria ou a carteira inteira;
- câmbio;
- indicadores econômicos;
- fundamentos;
- séries históricas.

**Regras**

- Não chame de "tempo real" um dado atrasado.
- Não preencha lacunas do histórico inventando valores.

## 6. Classes de ativos

- **Renda variável BR:** ações, FIIs, ETFs e BDRs.
- **Renda fixa BR:** Tesouro Selic, Prefixado e IPCA+; CDB, RDB, LCI, LCA, LC, debêntures, CRI e CRA. Cada título registra indexador, taxa, vencimento, liquidez, carência, instituição, custos e tributação.
- **Produtos bancários** (caixinhas, contas remuneradas): saldo e rendimento informados manualmente.
- **Internacional:** ações, ETFs e REITs, com moeda de negociação e câmbio.
- **Cripto:** BTC, ETH e outras cobertas pelas fontes.
- **Caixa:** BRL, USD, EUR e outras moedas, além de valores em trânsito.

Os ativos podem ser agrupados por classe, país, moeda, instituição, conta, setor, segmento, liquidez, estratégia e objetivo.

## 7. Operações

**Tipos**

- Compra e venda.
- Aporte e resgate.
- Depósito, retirada e transferência entre contas.
- Proventos: dividendos, JCP, rendimentos de FII e juros.
- Eventos: amortização, bonificação, desdobramento, grupamento e vencimento.
- Custos: taxas, impostos e retenções.
- Reinvestimento.
- Ajuste manual, sempre com justificativa.

**Campos (conforme o tipo)**

Data, ativo, quantidade, preço, valor bruto, custos, impostos, moeda, câmbio, conta e observações.

**Comportamento**

- Validações e detecção de duplicatas.
- Editar uma operação antiga recalcula posições e métricas a partir dela.

**Adição rápida de ativos da B3 (ajuste M-01, DECISIONS D-42)**

- Formulário curto "Adicionar ativo" (Carteira e Configurações → Corretoras e ativos): ticker (normalizado: maiúsculas; fracionário vira o lote padrão), quantidade, preço (unitário ou médio), data e **corretora / custodiante** (ajuste M-06, DECISIONS D-52: lista as corretoras usadas, com a última pré-selecionada; um nome novo cria a instituição e a conta "Principal" ao salvar, sem passar por cadastros).
- Ao sair do ticker, o app consulta o catálogo da B3 (COTAHIST diário, guardado no cache) e a brapi, e preenche nome, classe (ação, FII, ETF, BDR), mercado B3, BRL, BR, ISIN, setor, segmento e cotação automática. Nome e classe aparecem para conferir. Sem resultado ou sem internet, o usuário segue com o cadastro manual.
- Ativo já cadastrado: só registra a compra. "Posição que já tenho (saldo inicial)" grava uma compra na data aproximada (padrão na carteira vazia), com o aviso de que a TIR fica aproximada.
- Renda fixa, cripto e internacional continuam com o cadastro completo.

**Tributação na v1**

- Impostos e retenções são registrados pelo usuário.
- O app não calcula IR devido nem gera DARF.
- Os simuladores usam alíquotas configuradas pelo usuário.

## 8. Dashboard (carteira real)

**Painel (ajuste M-04, itens 1, 2, 3, 6 e 7; DECISIONS D-46).** A tela Início passou a se chamar Painel. Destaques no topo: patrimônio, resultado total (R$ e % sobre o aplicado) e variação do dia (R$ e %, desde o fechamento anterior; parcial quando algum ativo não tem a variação). Distribuição em rosca por ativo, classe, setor e instituição, com a legenda em texto (nome, % e valor). Aportes no mês e no ano e barras dos últimos 12 meses (compras e aportes × vendas e resgates; o saldo inicial do cadastro rápido não conta como aporte). Proventos por mês (barras) e total dos últimos 12 meses. Maiores altas e baixas da carteira no dia ou no mês. Sem dado, cada bloco mostra "indisponível" ou "nada registrado" com o motivo. Evolução, rentabilidade comparada e seletor de período vieram no ajuste M-09 (abaixo), antecipando parte da F8 (§21).

**Painel com evolução patrimonial (ajuste M-09, DECISIONS D-51; antecipa parte da F8).** No topo, uma faixa de números: patrimônio (com a variação do dia embaixo), total aplicado (aportes − resgates), ganho (R$ e % sobre o aplicado) e rentabilidade no ano (TWR). Em destaque, ocupando a largura e cerca de metade da altura, a **evolução patrimonial** (`FORMULAS.md` §3.2): área com o patrimônio dia a dia, linha em degraus com o total aplicado e marcadores nos dias de aporte; períodos 6M, 1A (padrão), 5A e Tudo; título em forma de resposta ("Seu patrimônio cresceu R$ X em 1 ano") e tooltip com data, patrimônio, aplicado e ganho. **"Comparar com"** (desligado por padrão): CDI, Ibovespa e IPCA; em R$, a linha "os mesmos aportes, nas mesmas datas, no índice" (simulação hipotética, rotulada); em %, o TWR da carteira contra os índices, todos a partir de 0% (`FORMULAS.md` §3.3); o tooltip mostra a diferença para cada índice. Índice sem dados para o período fica desabilitado com o motivo. Quando o histórico é curto, o gráfico explica que a evolução começa na data das operações registradas. Abaixo: distribuição numa rosca só, com seletor (ativo, classe, setor, corretora), o total no centro e a lista ao lado; aportes por mês (compras em verde, vendas em cinza); proventos por mês; maiores altas e baixas; e, em "Mais números", os demais indicadores (resultado total, investido, mercado, caixa, não realizado, TIR, realizado, proventos). Cores: a da marca para a carteira, cinza para referências, verde e vermelho só para ganho e perda.

**Painel único com abas (ajuste M-11, DECISIONS D-60; 1.4.0).** A organização acima mudou: o Painel tem as abas Visão geral, Rentabilidade, Comparação e Risco (o Desempenho saiu do menu); o topo tem um número grande (patrimônio, com o olho que oculta os valores) e uma linha com ganho total, hoje e total aplicado; "Mais números" e "Maiores posições" saíram (o que só existia lá está no (i)); o título do gráfico diz o ganho (M-12, `FORMULAS.md` §3.1). Detalhes em §16.

**Indicadores exibidos**

- Patrimônio, valor investido, valor de mercado e caixa. O **controle do saldo em caixa é opcional e vem desligado** (ajuste M-03, DECISIONS D-44; Configurações → Geral, vale em todos os computadores): desligado, compras e vendas não movimentam caixa, o card "Caixa" e o aviso de caixa negativo somem e o patrimônio é o valor de mercado das posições; ligado, vale o comportamento da 1.0.0 (depósitos, retiradas, caixa calculado e aviso de caixa negativo). Dinheiro parado pode entrar como um ativo da classe Caixa com saldo informado. A TIR não depende do caixa.
- Lucro ou prejuízo.
- Rentabilidade acumulada e por período.
- Proventos e renda passiva.
- Alocação por classe, moeda, país e instituição.
- Maiores posições.
- Evolução patrimonial.
- Comparação com benchmarks.
- Vencimentos próximos.
- Data da última atualização.

**Gráficos**

- Interativos, com tooltip, legenda e seleção de período.
- Períodos: 1D, 5D, 1M, 3M, 6M, YTD, 1A, 3A, 5A, 10A, 20A, 30A, todo o histórico e personalizado.
- Aparecem só os períodos que os dados sustentam.

## 9. Motor financeiro (domain/, Dart puro)

**Métricas**

- Quantidade, preço médio, custo e valor de mercado.
- Lucro realizado e não realizado.
- Proventos.
- Retorno simples e acumulado; diário, mensal e anual.
- CAGR, XIRR, TWR e MWR.
- Retorno bruto e líquido de custos.
- Retorno nominal e real.
- Efeito cambial separado do desempenho do ativo.
- Retorno com e sem proventos.
- Retorno na moeda original e em BRL.

**Convenções brasileiras (padrão)**

- O preço médio inclui os custos de compra.
- Proventos não alteram o preço médio.
- Custos de venda reduzem o valor recebido na venda.
- Desdobramento e grupamento ajustam quantidade e preço médio, mantendo o custo total.

**Juros**

- Juros simples e compostos.
- Taxa nominal e efetiva; equivalência de taxas.
- Base de 252 dias úteis, com calendário de feriados nacionais, para CDI, Selic e títulos que usam essa base. Bases de dias corridos, /360 ou /365 quando aplicável.
- Nunca divida uma taxa anual por 365 como regra geral.

**Precisão**

- Tipo decimal e arredondamento documentado.
- Suporte a datas irregulares e fluxos negativos.
- Ao comparar números, informe a metodologia (por exemplo, TWR versus MWR).

Os testes começam pelos casos de `docs/CASOS_DE_TESTE.md`.

## 10. Sincronização entre computadores: arquivo de save (.invsave)

**Objetivo:** manter dois ou mais PCs com os mesmos dados sem internet, levando um arquivo de um para o outro. O meio de transporte não importa para o app: pendrive, rede local, e-mail ou nuvem.

### 10.1 Conteúdo do arquivo

O save é um ZIP com extensão `.invsave`, contendo:

- **`manifest.json`:**
  - identificador e versão do formato;
  - versão do app e versão do schema;
  - id e nome do dispositivo;
  - data e hora em UTC;
  - HLC máximo;
  - contagem de registros por tabela;
  - SHA-256 de cada arquivo.
- **`data/<tabela>.jsonl`:** todos os registros sincronizáveis, incluindo os excluídos (tombstones).
- **`market/`** (opcional, marcado por padrão): histórico de preços, câmbio e indicadores já baixados, para o outro PC funcionar offline.

**O que não vai no save**

- Dados derivados.
- Logs.
- Configurações do dispositivo (intervalo de atualização, janelas, caminhos).
- Chaves de API. Podem ir como opção, desmarcada por padrão e com aviso.

**Configurações**

- As configurações são divididas em "do dispositivo" e "compartilhadas".
- As compartilhadas (metas, alocação-alvo, alertas, categorias) vão no save.
- As do dispositivo ficam só no PC.

**Snapshot completo**

O save é sempre um snapshot completo, não incremental. Isso é mais simples e robusto, e o arquivo fica pequeno para uso pessoal.

### 10.2 Exportar

- Botão "Salvar arquivo de save".
- Nome padrão: `Patrion_<NomeDoPC>_<AAAA-MM-DD_HHmm>.invsave`.
- O usuário escolhe o destino.
- Ao terminar, o app mostra um resumo.

### 10.3 Importar (mesclar)

1. **Validar** o ZIP, o manifest, os checksums e o formato.
   - Schema mais novo que o do app: recusar e pedir a atualização do app.
   - Schema mais antigo: converter durante a importação.
2. **Fazer backup automático** do banco local antes de qualquer alteração.
3. **Calcular a mesclagem e mostrar uma prévia:** registros novos, atualizados, excluídos, conflitos e possíveis duplicatas.
4. **Confirmar e aplicar** numa única transação. Se algo falhar, nada é alterado.
5. **Recalcular os dados derivados** e registrar a sincronização no histórico (dispositivo de origem, data, HLC e contagens).

### 10.4 Regras de mesclagem

**Mesclagem por `id`**

- Registro presente só de um lado: é mantido ou adicionado.
- Registro presente dos dois lados: vence o maior `hlc`. Em caso de empate, decide o `device_id`.

**Exclusões**

São tombstones e se propagam como qualquer outra alteração.

**Conflitos**

- Conflito é o mesmo registro alterado nos dois PCs desde a última sincronização entre eles. Para detectar isso, o app guarda, para cada dispositivo parceiro, o último HLC trocado.
- Conflitos aparecem na prévia. O padrão é manter a versão mais recente, mas o usuário pode escolher a outra.

**Entidades com chave natural**

Exemplos: ativo (ticker + bolsa/tipo), instituição e conta. Se dois UUIDs diferentes representam a mesma entidade (por exemplo, PETR4 cadastrado nos dois PCs), o app:

- unifica as duas;
- remapeia as referências;
- registra o alias.

**Possíveis duplicatas de operações**

Mesma data, ativo, tipo, quantidade e preço, mas ids diferentes: o app sinaliza e nunca apaga sozinho.

**Carteiras hipotéticas**

Carteiras hipotéticas, cenários e resultados salvos vão no save e continuam separados da carteira real.

**Propriedades obrigatórias**

- **Idempotência:** importar o mesmo arquivo de novo não muda nada.
- **Nada se desfaz:** importar um arquivo antigo não apaga alterações mais novas.
- **Convergência:** depois de A→B e B→A, os dois PCs ficam com o mesmo estado.
- **Relógios:** a mesclagem funciona mesmo com relógios dessincronizados entre os PCs (por isso o HLC).

### 10.5 Fluxo de uso

Quando há alterações nos dois PCs:

1. PC A exporta.
2. PC B importa (mesclando).
3. PC B exporta.
4. PC A importa.

A opção "Importar e gerar novo save" faz os passos 2 e 3 de uma vez.

O app avisa, sem bloquear, quando a última sincronização com outro dispositivo for antiga.

### 10.6 Depois (v1.x)

- Criptografia opcional do save com senha: AES-256-GCM, com chave derivada por Argon2id ou PBKDF2 e parâmetros documentados.
- Pasta de sincronização: ao abrir, o app procura saves de outros dispositivos numa pasta configurada; ao fechar, oferece exportar.
- Abrir um `.invsave` com duplo clique leva à tela de importação (associação feita pelo instalador na Fase 7).

### 10.7 Testes obrigatórios

- Exportar e importar, ida e volta.
- Idempotência.
- Convergência A↔B.
- Conflito.
- Exclusão propagada.
- Importação de arquivo antigo.
- Arquivo corrompido ou com checksum inválido.
- Schema mais novo e schema mais antigo.
- Mesmo ativo com UUIDs diferentes.
- Rollback quando a importação falha.
- Relógio adiantado em um dos PCs.
- Separação entre real e hipotético preservada.

## 11. Backup e restauração

O backup é diferente do save:

- **Backup:** cópia integral do banco deste PC, para recuperação. Restaurar substitui tudo.
- **Save:** mesclagem entre PCs.

**Requisitos**

- Backup manual com escolha do destino, usando cópia consistente (por exemplo, `VACUUM INTO`).
- Data e versão no nome do arquivo ou nos metadados.
- Validação de integridade.
- Restauração com confirmação explícita e backup automático do estado atual antes.
- Backups automáticos antes de migrações e importações, com retenção limitada.
- Procedimento de recuperação documentado.

## 12. Análises por classe, benchmarks, risco e renda passiva

### 12.1 FIIs

Quando houver dados:

- P/VP e DY;
- histórico de rendimentos;
- vacância e segmento;
- liquidez;
- emissões e amortizações.

Rendimento recebido, anunciado e estimado são coisas diferentes e aparecem separados.

### 12.2 Renda fixa

- Comparação entre títulos prefixados, pós-fixados e IPCA+.
- Separação entre o saldo informado pela instituição, a projeção calculada e o valor de mercado estimado.

### 12.3 Cripto

Custo, preço médio, cotação e retorno em BRL.

### 12.4 Internacional

Retorno na moeda original e em BRL, separando o efeito cambial.

### 12.5 Benchmarks

**Índices**

- CDI, IPCA e Ibovespa.
- IMA e IDkA, se houver fonte.
- S&P 500, Nasdaq e BTC.
- Outros relevantes.

**Exibição**

- Fonte, moeda, período e metodologia de cada benchmark.
- Retorno acumulado e anual.
- Diferença em pontos percentuais.
- Série normalizada.

### 12.6 Risco

- Volatilidade e drawdown máximo.
- Correlação.
- Concentração por ativo, classe, setor, país e moeda.
- Exposição cambial e liquidez.
- Desvio em relação à alocação-alvo.
- Sharpe e beta só quando os dados forem suficientes e comparáveis.

### 12.7 Renda passiva

- Totais por tipo, mês, ano e ativo.
- Média mensal e calendário de pagamentos.
- Relação entre renda e patrimônio.
- Separação entre recebido, anunciado e projetado.

## 13. Carteiras hipotéticas

### 13.1 Gestão

**Ações disponíveis:** criar, editar, duplicar, renomear, arquivar e excluir.

**Campos de cada carteira**

- Nome, descrição e objetivo.
- Data inicial, moeda-base e capital.
- Ativos com pesos ou quantidades.
- Premissas.
- Benchmark.
- Regra de rebalanceamento.
- Histórico de execuções.
- Metodologia.

Uma carteira hipotética não exige posição correspondente na carteira real.

### 13.2 Composição

**Formas de montar**

- Por percentual.
- Por valor ou quantidade.

**Validações**

- Os percentuais devem somar 100%.
- Caixa residual é permitido.

**O que a tela mostra**

- Distribuição, classes, países e moedas.
- Concentração.
- Quantidades teóricas.
- Arredondamentos e custos.

### 13.3 Backtest

**Parâmetros**

- Data inicial e data final.
- Capital, ativos e pesos.
- Aportes e saques periódicos (fixos, reajustados ou percentuais).
- Proventos reinvestidos ou retirados.
- Custos e tributação, quando representável.
- Rebalanceamento.
- Benchmark e moeda de apresentação.

**Saídas**

- Patrimônio ao longo do tempo.
- Retorno acumulado e anualizado; CAGR; TWR e MWR.
- Valores inicial e final.
- Total de aportes e saques; proventos.
- Lucro ou prejuízo.
- Volatilidade e drawdown.
- Alocação ao longo do tempo.
- Comparação com benchmarks.
- Desempenho por ativo.
- Decomposição do resultado (valorização, proventos, câmbio e fluxos), quando possível.

O dinheiro aportado aparece sempre separado do rendimento gerado.

### 13.4 Rebalanceamento

**Modalidades**

- Sem rebalanceamento.
- Mensal, trimestral, semestral ou anual.
- Por banda de tolerância definida pelo usuário.

**Comportamento**

O app calcula as compras e vendas teóricas, incluindo custos. Ele nunca gera ordens reais.

### 13.5 Comparação

- Duas ou mais carteiras e benchmarks no mesmo gráfico.
- Sempre que possível, com as mesmas datas, capital, fluxos, moeda e metodologia.

### 13.6 Rigor do backtest

- Usar dados reais e identificados.
- Decisões tomadas na data t usam só dados disponíveis até t (sem look-ahead).
- Executar no preço disponível da data, com a regra definida e documentada (por exemplo, fechamento do dia ou próximo pregão).
- Separar retorno de preço e retorno total.
- Considerar eventos corporativos e proventos quando houver dados.
- Tratar o câmbio corretamente.
- Sinalizar lacunas nos dados, nunca preenchê-las inventando valores.
- Documentar o viés de sobrevivência e os ativos deslistados.

Sem dados confiáveis para o backtest, o app informa a limitação e oferece uma projeção com premissas explícitas, sem misturar as duas modalidades.

### 13.7 Projeção

**Parâmetros**

- Capital, composição, aportes e saques.
- Prazo de 1, 3, 5, 10, 20 ou 30 anos, ou personalizado.
- Retornos hipotéticos por ativo ou classe.
- Inflação e câmbio.
- Custos e impostos estimados.
- Reinvestimento e rebalanceamento.

**Cenários**

- Pessimista, base e otimista, todos editáveis.
- Sempre rotulados como hipotéticos.

### 13.8 Avançado (v2)

**Ferramentas**

- Monte Carlo.
- Faixas de resultados.
- Probabilidade de atingir uma meta.
- Testes de estresse e choques.
- Análise de sensibilidade.

**Condições**

- Só com metodologia documentada e testes.
- A arquitetura deve estar preparada para isso desde a Fase 9.

### 13.9 Separação da carteira real

- Armazenamento próprio.
- Telas e gráficos identificados visualmente como simulação.
- Exportação separada.
- Funciona offline com o histórico já salvo.

### 13.10 Reprodutibilidade

- Os mesmos dados com as mesmas premissas produzem o mesmo resultado.
- Cada execução salva os parâmetros e a identificação dos dados usados (fonte e datas).

### 13.11 Testes

- Alocação inicial.
- Evolução de preços.
- Proventos e reinvestimento.
- Aportes e saques.
- Custos.
- Rebalanceamento.
- Câmbio.
- Cálculo de retorno.
- Comparação com benchmarks.
- Datas sem dados.
- Ausência de look-ahead.
- Carteira real intocada.
- Reprodutibilidade.

## 14. Simuladores

- Juros compostos.
- Aposentadoria e independência financeira.
- Metas (aporte necessário para atingir um objetivo).
- Comparador de investimentos: retorno, risco, liquidez, custos e tributação estimada.

Todos usam premissas explícitas e nunca alteram dados reais.

## 15. Análise fundamentalista (v2)

**Indicadores**

Quando houver fonte confiável:

- P/L, P/VP, P/S, EV/EBITDA e EV/EBIT;
- DY e FCF Yield;
- PEG;
- ROE, ROIC e ROA;
- margens e crescimento;
- LPA;
- dívida líquida e DL/EBITDA;
- cobertura de juros;
- FCO e FCL;
- payout e histórico de dividendos.

Cada indicador traz fórmula, unidade, período, fonte e limitações.

**Lentes de análise**

- **Graham:** valor intrínseco e margem de segurança. Inclui a fórmula LPA × (8,5 + 2g), com convenções e limitações documentadas; ela não é tratada como universal.
- **Buffett:** consistência dos resultados, retorno sobre capital, geração de caixa, dívida, margens e DCF em três cenários.
- **Fisher:** crescimento, P&D e margens, separando dados objetivos de avaliações qualitativas.
- **Lynch:** crescimento de lucros, P/L, PEG, dívida e caixa.

**Saída**

- Indicadores, fatores favoráveis e riscos.
- Dados ausentes e premissas.
- Nunca uma recomendação ou garantia de retorno.

## 16. Interface

**Identidade visual**

- Nome: Patrion. Subtítulo: "Investimentos e Patrimônio".
- Esboço da logo em `assets/branding/patrion-logo-esboco.png`: cristais facetados em verde-esmeralda com arestas douradas, sobre fundo verde quase preto, e nome em caixa alta com o "A" sem a barra.
- Cores da marca: verde-esmeralda (~#1F6B4F) e dourado (~#C9A86A). O fundo verde quase preto (~#0E1A16) fica só no símbolo e na logo, não na interface.
- Regras de cor da interface (valores exatos em `DECISIONS.md` D-18):
  - **Fundo e superfícies neutros**, sem tom verde. Tema escuro: quase preto/grafite (fundo #0F1113, superfícies #16191C e #1D2125, bordas sutis #2A2F34, texto #ECEDEE e secundário #9BA1A6). Tema claro: branco e cinza-claro neutros, com texto grafite.
  - **Verde-esmeralda só em destaques:** item selecionado do menu (indicador), botão principal, foco, toggles e links.
  - **Dourado com muita moderação:** símbolo, nome PATRION e, no máximo, um destaque por tela. Nunca em texto comum.
  - O dourado é cor de marca, não de dado: **ganho e perda usam cores próprias**, diferentes do verde da marca, com bom contraste nos dois temas.
- O esboço é uma imagem com textura e brilho, boa para tela de abertura e README. Para ícone do app (.ico de 16 a 256 px), favicon e instalador, crie uma versão vetorial simplificada só do símbolo (cores chapadas, sem textura), legível em 16 px. Na Fase 1, proponha essa versão ou peça uma ao usuário.

**Geral**

- Em português brasileiro, pensada para desktop, com navegação lateral.
- As telas aparecem conforme as fases forem implementadas.
- **Menu lateral (ajuste M-02, DECISIONS D-43):** em cima, só as telas de uso diário. Na 1.2.0: Painel, Carteira e Operações (Cadastros saiu do menu no ajuste M-06 e virou Configurações → Corretoras e ativos). A F8 (1.3.0) acrescentou **Desempenho** e **Renda passiva**; no ajuste M-11 (1.4.0, DECISIONS D-60) o Desempenho saiu do menu e virou abas do Painel. Menu na 1.4.0: **Painel, Carteira, Renda passiva, Operações**. As fases seguintes (Hipotéticas, Simuladores) entram aqui, antes de Operações. No rodapé, depois de um divisor: **Sincronizar** (leva direto à exportação e importação do save, com uma marca quando a última sincronização com outro computador tem 7 dias ou mais) e **Configurações**, sempre por último.
- **Configurações** tem seções: Geral (tema e preferências), Segurança (senha, Windows Hello, inatividade, chave de recuperação), Fontes de dados (chaves, cota da brapi, intervalo), Backup (manual, restauração, lista), Sincronização (save, computadores, histórico) e Sobre (versão, atualizações, licenças e pastas). Avisos que levavam a Backup ou Fontes de dados abrem a seção correspondente.

**Telas**

Situação na 1.4.0 (F8 e ajustes M-10 a M-12): existem Painel (§8, com as abas Visão geral, Rentabilidade, Comparação e Risco), Carteira (com as visões por classe), página do ativo, Renda passiva, Operações e Configurações (com Corretoras e ativos, Fontes de dados, Backup e Sincronização). As telas com outra fase marcada ainda não existem.

- **Painel (§8; ajustes M-04, M-09, M-11 e M-12; DECISIONS D-59 e D-60):** uma tela com abas no topo — **Visão geral · Rentabilidade · Comparação · Risco** (endereços `/`, `/painel/rentabilidade`, `/painel/comparacao` e `/painel/risco`; `/desempenho` leva à Rentabilidade). As três últimas são as antigas abas do Desempenho (Benchmarks virou "Comparação"), com o mesmo conteúdo e o mesmo período nas três.
  - **Visão geral**, de cima para baixo: o **Patrimônio** em número grande, com o (i) (data dos preços, caixa, custo das posições e resultado não realizado) e o **olho** que oculta os valores; numa linha, **Ganho total** (R$ e %), **Hoje** (R$ e %) e **Total aplicado**; três números pequenos — **Lucro realizado**, **Proventos (12 meses)** e **Rentabilidade (TIR a.a.)**, com a rentabilidade no ano embaixo —, cada um com o (i); a **evolução patrimonial** com "Comparar com"; em duas colunas, **Distribuição** (rosca com seletor) e **Aportes por mês**; em duas colunas, **Proventos por mês** e **Maiores altas e baixas**; os vencimentos dos próximos 90 dias, quando há; e a faixa de **câmbio e indicadores** no rodapé, que leva a Fontes de dados.
  - Saíram (repetidos): "Mais números" e "Maiores posições" (a Carteira e a rosca por ativo mostram isso); o que só existia lá foi para o (i) do número correspondente.
  - **Hierarquia:** um só número grande; títulos dos blocos em forma de resposta ("Você aportou em 3 dos últimos 12 meses"); textos longos no (i), não embaixo dos gráficos; nenhum valor repetido (exceção de propósito: em "Tudo", o título do gráfico é o ganho total, M-12). Em 1280 × 800, cabe em até 2 telas de rolagem.
  - **Olho (ocultar valores):** troca todos os valores em reais (e outras moedas) do app por "R$ ••••", inclusive eixos e tooltips dos gráficos; percentuais continuam visíveis. Lembrado neste computador. Ao abrir, os valores ficam ocultos até a preferência ser lida.
- **Carteira (ajuste M-05, DECISIONS D-45):** lista principal com um item por ativo (todas as contas somadas), do maior valor da posição para o menor; cada linha mostra ativo (código, nome e quantidade de cotas), valor da posição em destaque, preço médio, cotação atual (fonte e data embaixo; tipo e coleta no tooltip), valorização % com cor, sinal e ícone, e o botão "Detalhes". Sem cotação, "indisponível" e ordem pelo total aplicado; com zero cotas, no fim e em cinza. Cabe em 1280 px sem rolagem lateral. O clique na linha (ou em "Detalhes") abre a **página do ativo em tela cheia** (ajuste M-07, DECISIONS D-49; o painel lateral do M-05 deixou de existir), e "Voltar" retorna à Carteira com a busca e a rolagem.
- **Corretoras na Carteira (ajuste M-06, DECISIONS D-52):** filtro por corretora no topo da lista (Todas / Nubank / XP…), lembrado entre aberturas neste computador; o mesmo ticker em várias corretoras aparece numa linha só (quantidade, valor e preço médio somados), com a quebra por corretora (quantidade, preço médio e valor) na página do ativo; opção "Agrupar por corretora", com uma seção e o subtotal em reais de cada uma. Comprar usa o mesmo campo "Corretora / custodiante" do "Adicionar ativo" (aceita corretora nova); Vender oferece só as corretoras com o ativo. **Transferência de custódia** na página do ativo ("Transferir de corretora"): leva cotas de uma corretora para outra com o mesmo custo e preço médio (`FORMULAS.md` §1.3). **Corretoras e ativos** (antes "Cadastros") fica em Configurações, para corrigir: renomear corretora ou conta, arquivar conta, editar ativo (fonte da cotação, renda fixa) e excluir cadastro sem uso; `/cadastros` leva para lá.
- **Página do ativo (ajuste M-07, DECISIONS D-49):** cabeçalho fixo com ticker, nome, classe e corretoras; à direita, o valor da posição em destaque, o lucro (R$ e valorização %) e a variação do dia, com "Comprar", "Vender" e um menu (editar, informar preço, outra operação, atualizar). **Gráfico grande** (~45% da altura) só com o desempenho do ativo no mercado: fechamentos diários, períodos de mercado 1M, 6M, 1A (padrão), 5A, 10A e Tudo (sem dados, o período fica desabilitado com "Histórico disponível desde mm/aaaa"), variação do período em destaque ("+18,4% em 1 ano"), máxima e mínima, tooltip com data, cotação e variação desde o início do período, eixo sem começar em zero e a opção "Preço ajustado por proventos" (calculado, `FORMULAS.md` §2.5). Nada da carteira no gráfico (sem preço médio, sem compras e vendas) e sem comparação com índices. Avisos: evento em ações no período (a queda não é perda) e saltos sem evento registrado (possível desdobramento não listado; não corrigido). Abaixo, cartões em grade: total aplicado, preço médio, cotação atual, lucro não realizado, lucro realizado, proventos recebidos, % da carteira e a quebra por corretora. Abas: Operações (tabela com edição), Proventos (por mês) e Dados do ativo (cadastro, dados de mercado com o histórico guardado e "Baixar histórico completo", desempenho/TIR, características de renda fixa e preços informados).
- **Totais da Carteira (M-12):** acima da lista, "Carteira toda": patrimônio, aplicado e o ganho total, o mesmo do Painel (FORMULAS §3.1).
- **Visões por classe na Carteira (F8, DECISIONS D-57):** abas acima da lista — Todos (a lista atual), FIIs, Renda fixa, Cripto e Internacional —, cada uma só aparece quando a carteira tem a classe (§12.1 a §12.4). Não há tela separada por classe no menu.
- **Desempenho (F8, DECISIONS D-53 a D-55):** desde a 1.4.0 são as abas Rentabilidade (tabela mês × ano), Comparação (§12.5) e Risco (§12.6) do Painel, com o seletor de período de §8.
- **Renda passiva (F8, §12.7, DECISIONS D-56):** totais, meses, calendário e lançamento dos proventos pagos.
- Operações (lista com busca e filtros, edição e exclusão).
- Carteiras hipotéticas (F9) e Simuladores (F10), com identificação visual própria.
- Relatórios e Alertas (F13).
- Configurações, com Geral, Segurança, Fontes de dados, Corretoras e ativos, Backup, Sincronização e Sobre como seções.

**Padrões visuais**

- Tabelas ordenáveis, busca e filtros.
- Estados de carregamento e mensagens de erro claros. Ao recalcular, a tela fica com os números anteriores até os novos ficarem prontos (sem piscar, M-10).
- Todo "indisponível" tem o motivo no tooltip (M-12).
- Tema claro e escuro.
- BRL como moeda padrão, com opção de ver a moeda original.
- Cor nunca é o único indicador de informação.
- Telas de simulação com identificação visual própria.

## 17. Importação, exportação, relatórios e alertas

**Importação**

CSV com prévia, validação, detecção de duplicatas e confirmação antes de gravar.

**Exportação**

- Formatos: CSV, XLSX e PDF.
- Conteúdo: carteira, operações, proventos, rentabilidade, evolução patrimonial, simulações, backtests, comparações e projeções.
- Todo relatório traz data de geração, período, moeda, metodologia e limitações.

**Alertas (com o app aberto)**

- Preço e variação percentual.
- Concentração e alocação.
- Vencimentos e metas.
- Dados desatualizados e falhas de API.

Não prometa alertas com o app fechado.

## 18. Logs e erros

- Logs técnicos rotativos, sem valores patrimoniais.
- Erros diferenciados por tipo: rede, dados, cálculo e interno.
- Quando uma API falha, o app continua funcionando offline.
- A localização dos logs fica documentada.

## 19. GitHub, CI e distribuição

### Repositório

- `.gitignore` adequado.
- README e CHANGELOG.
- Versionamento semântico (SemVer) com tags.
- Branch `main` sempre estável.

### GitHub Actions

Configuração geral:

- Runner Windows.
- Versão do Flutter fixada.
- Permissões mínimas.
- Nenhum token exposto nos logs.

Workflows:

- **Em todo push e PR:** verificação de formatação, `analyze`, `test` e `build`.
- **Em tag `vX.Y.Z`:** build de release, instalador, ZIP portátil e publicação no GitHub Releases.
  - A publicação é feita como rascunho até eu aprovar.
  - Tags com sufixo `-beta` ou `-rc` viram pré-lançamento.

### Conteúdo de cada Release

- Versão e data.
- Notas: novidades, correções e problemas conhecidos.
- Requisitos do sistema.
- Instalador `.exe` e ZIP portátil.
- Instruções de instalação e atualização.

### Instalador (Inno Setup)

- Instalação em Program Files ou por usuário (decidir na Fase 1).
- Atalho no Menu Iniciar e atalho opcional na área de trabalho.
- Desinstalação padrão que não apaga os dados.
- Identificação da versão instalada.
- Atualização sobre a versão anterior sem perder dados.
- Associação da extensão `.invsave` ao app.

### Versão portátil

ZIP com todos os arquivos necessários, com a localização dos dados documentada.

### Assinatura de código

Sem assinatura, o Windows SmartScreen mostra um aviso na instalação; isso deve estar documentado. A assinatura exige certificado pago e fica como opção futura.

### Verificador de atualizações

- Consulta a última Release estável e compara as versões no padrão SemVer.
- Mostra as notas da versão e o link de download.
- Não bloqueia o uso quando não há internet.
- Limita a frequência das consultas.
- Ignora pré-lançamentos por padrão.
- O repositório é configurado num único lugar do código.

Atenção: Releases de repositório privado não podem ser consultadas sem autenticação. A estratégia é decidida em `DECISIONS.md`.

### Atualização automática (v2)

Só pode ser implementada com:

- verificação de integridade e autenticidade;
- preservação dos dados;
- recuperação em caso de falha;
- modelo de confiança documentado.

Um hash publicado no mesmo lugar do arquivo não protege contra adulteração.

### Testes de distribuição

Feitos preferencialmente no Windows Sandbox ou num PC sem Flutter:

- instalar e abrir;
- registrar uma operação;
- criar uma carteira hipotética;
- fechar e reabrir;
- atualizar de versão;
- desinstalar sem perder dados;
- usar offline;
- exportar e importar o save entre duas instalações.

## 20. Documentação (em docs/, PT-BR, sempre refletindo o estado real)

- README
- ARQUITETURA
- BANCO
- FONTES_DE_DADOS
- FORMULAS
- SINCRONIZACAO
- HIPOTETICAS (metodologia e limitações)
- DESENVOLVIMENTO
- DISTRIBUICAO
- BACKUP
- SOLUCAO_DE_PROBLEMAS
- ROADMAP
- CHANGELOG (na raiz)

## 21. Fases

Cada fase termina com o relatório descrito no `CLAUDE.md`, atualização de `PROGRESS.md` e do CHANGELOG, e commit. A ordem só muda se eu pedir.

### v1.0 — app utilizável

**F1. Ambiente e decisões**

Entregas:

- Verificar as ferramentas.
- Pesquisar as fontes de dados e criar `FONTES_DE_DADOS.md`.
- Escolher as dependências e registrar em `DECISIONS.md`.
- Propor o modelo de dados em `BANCO.md`, já com os campos de sincronização e com as tabelas hipotéticas separadas.
- Criar o projeto e o repositório Git.
- Fazer o primeiro build Windows.

Pronto quando:

- o app vazio abre no Windows;
- as decisões foram aprovadas por mim.

**F2. Fundação**

Entregas:

- Camadas do projeto.
- Drift com migrações.
- Infraestrutura de sincronização: UUID v7, HLC, `device_id`, tombstones e repositórios base.
- Navegação e tema.
- Logs.
- CI com `analyze`, `test` e `build`.

Pronto quando:

- o CI está verde;
- os testes de HLC e dos repositórios passam.

**F3. Carteira real**

Entregas:

- Instituições, contas e ativos.
- Todos os tipos de operação de §7.
- Preço informado manualmente.
- Posições.
- Dashboard inicial.

Pronto quando:

- os dados persistem após reiniciar o app.

**F4. Motor financeiro**

Entregas:

- §9 completo.
- `FORMULAS.md`.

Pronto quando:

- todos os casos de `CASOS_DE_TESTE.md` passam.

**F5. Backup e save**

Entregas:

- §11.
- §10, exceto §10.6.

Pronto quando:

- os testes de §10.7 passam;
- a sincronização manual entre duas pastas de dados funciona.

**F6. Dados de mercado**

Entregas:

- Adaptadores escolhidos na F1.
- Cache e atualização automática e manual.
- Câmbio, CDI, Selic e IPCA.
- Tela "Fontes de dados".

Pronto quando:

- as cotações reais aparecem com fonte e data;
- o app funciona sem internet.

**F7. Distribuição**

Entregas:

- Instalador e ZIP portátil.
- Workflow de release.
- Verificador de atualizações.
- Associação da extensão `.invsave`.

Pronto quando:

- a versão v1.0.0 existe, com instalador testado em ambiente limpo.

### v1.x

**F5B. Bloqueio do app**

Entregas:

- §3, "Bloqueio do app": SQLCipher, senha, Windows Hello, bloqueio por inatividade e chave de recuperação.
- Proteção por senha do arquivo de save.

Pronto quando:

- os testes obrigatórios de §3 passam;
- um banco já existente é convertido para criptografado e volta a abrir no app real, com Windows Hello e com a senha.

A numeração "F5B" indica que a fase depende da F5 (backup e save). Ela é a primeira da v1.x e não renumera as seguintes.

**F8. Classes, benchmarks, risco e renda passiva** — concluída na versão 1.3.0 (23/10/2026)

§12, mais o que sobrou de §8 e §9 para a carteira real.

**Já entregue (antecipado nos ajustes M-04 e M-09, versões 1.1.0 e 1.2.0; DECISIONS D-46, D-50 e D-51)** — não se refaz na F8:

- [x] Evolução patrimonial dia a dia com o total aplicado e os marcadores de aporte (§8; `FORMULAS.md` §3.2).
- [x] TWR da carteira e rentabilidade no ano (faixa do Painel).
- [x] Comparação com CDI, Ibovespa e IPCA no Painel: em R$ ("os mesmos aportes no índice", hipotético) e em % (TWR × índices a partir de 0%), com a diferença no tooltip (`FORMULAS.md` §3.3).
- [x] Seletor de período do Painel (6M, 1A, 5A, Tudo).
- [x] Ibovespa diário pela B3 (`FONTES_DE_DADOS.md` §2.5d).
- [x] Distribuição por ativo, classe, setor e corretora; aportes e proventos por mês; maiores altas e baixas.
- [x] Proventos e eventos da B3 baixados para os ativos da carteira (M-08), usados no preço ajustado.

**Escopo da F8 (entregue na 1.3.0; DECISIONS D-53 a D-57)**, em seis partes, cada uma com commit e `PROGRESS.md` atualizado:

1. **Desempenho → Rentabilidade (§8 e §9).** Tela nova no menu.
   - Tabela mês × ano com o TWR da carteira em cada mês, o total do ano e o acumulado; por linha (ano), o CDI do ano e a rentabilidade em % do CDI.
   - Retorno nominal e real (descontado o IPCA) no período escolhido; CAGR quando o período tem mais de um ano.
   - Seletor de período ampliado: 1M, 3M, 6M, YTD, 1A, 3A, 5A, 10A, Tudo e personalizado (datas). Só aparecem os períodos que os dados sustentam (§8).
   - Metodologia (TWR, e a TIR/MWR ao lado para comparar) explicada no ícone de informação.
2. **Desempenho → Benchmarks (§12.5).**
   - Índices: CDI, Selic, IPCA e IGP-M (BCB), Ibovespa e **IFIX** (B3, a mesma fonte do Ibovespa), BTC (Binance, em BRL desde 10/2020, e USD antes, convertido pela PTAX; rotulado), S&P 500 e Nasdaq (Yahoo, opcional e desligado por padrão: com ele desligado, aparecem como "indisponível — ative a fonte em Fontes de dados").
   - **IMA e IDkA ficam indisponíveis**: a ANBIMA só publica os últimos 5 dias úteis de graça e o histórico é pago (`FONTES_DE_DADOS.md` §1). Aparecem na lista como "indisponível" com esse motivo. *(Redução de escopo de §12.5 aprovada em 23/10/2026.)*
   - Para cada índice escolhido: fonte, moeda, período coberto e metodologia; retorno acumulado e anualizado; diferença em p.p. para a carteira; série normalizada (base 100) num gráfico com a carteira.
   - O "Comparar com" do Painel continua com CDI, Ibovespa e IPCA (sem duplicar); ganha o IFIX.
3. **Desempenho → Risco (§12.6).**
   - Volatilidade anualizada e drawdown máximo (com as datas do pico, do fundo e da recuperação) da carteira, a partir do índice TWR diário, e de cada ativo, a partir do preço ajustado.
   - Correlação entre os ativos da carteira (matriz de retornos diários; só pares com 60 pregões ou mais em comum, senão "indisponível").
   - Concentração por ativo, classe, setor, país e moeda: maior posição, cinco maiores e o índice HHI.
   - Exposição cambial (% do patrimônio em cada moeda estrangeira) e liquidez (% por liquidez cadastrada: diária, no vencimento, outra).
   - **Alocação-alvo por classe** (editada na própria aba e guardada em `shared_settings`, sincronizada, sem tabela nova): desvio atual em p.p. e em R$ para cada classe. É informação, não recomendação.
   - Sharpe (CDI como taxa livre de risco) e beta (contra o Ibovespa) só com 12 meses ou mais de dados diários; senão "indisponível" com o motivo.
4. **Renda passiva (§12.7).** Tela nova no menu.
   - Totais por tipo (dividendos, JCP, rendimentos de FII, juros), por mês (barras), por ano e por ativo; média mensal dos últimos 12 meses.
   - Relação renda/patrimônio: rendimento dos últimos 12 meses sobre o patrimônio atual e sobre o custo.
   - Três colunas separadas: **recebido** (operações registradas), **anunciado** (proventos da B3 com pagamento futuro × quantidade na data-com) e **projetado** (média de 12 meses, rotulada como hipotética).
   - Calendário dos próximos pagamentos anunciados (data-com, pagamento, valor por cota e total estimado).
   - **Lançar proventos pagos:** a B3 já traz os proventos pagos dos ativos da carteira; o app mostra os que ainda não foram registrados (quantidade na data-com × valor), com prévia e confirmação antes de gravar como operações comuns (com a observação "Lançado dos proventos da B3", editáveis depois). A quantidade na data-com sai das operações registradas; se a posição foi lançada como saldo inicial depois da data-com, o provento não é sugerido e a tela explica o motivo. Nada é gravado sem a confirmação. *(Item novo, fora do texto original de §12.7, aprovado em 23/10/2026.)*
5. **Visões por classe na Carteira (§12.1 a §12.4).**
   - **FIIs:** P/VP (cotação ÷ valor patrimonial por cota do informe mensal da CVM, com o mês de referência), DY de 12 meses (proventos da B3 ÷ cotação), rendimentos por mês, segmento, liquidez (volume médio diário de 30 pregões do COTAHIST) e amortizações (eventos da B3). Rendimento recebido, anunciado e estimado separados. **Vacância e emissões ficam indisponíveis** (a CVM só traz isso no informe trimestral, em formato não estruturado por imóvel; `FONTES_DE_DADOS.md` será atualizado). *(Redução de escopo de §12.1 aprovada em 23/10/2026.)*
   - **Renda fixa:** por título, lado a lado, o saldo informado pela instituição (com a data), a projeção calculada pelo indexador e, no Tesouro, o valor de mercado estimado (PU de venda do Tesouro Transparente); agrupados em prefixados, pós-fixados e IPCA+, com a taxa, o vencimento e a rentabilidade desde a aplicação em % a.a. e em % do CDI do mesmo período.
   - **Cripto:** custo, preço médio, cotação e retorno em BRL (cotação em USD convertida pela PTAX quando preciso).
   - **Internacional:** retorno na moeda original e em BRL, com o efeito cambial separado (`FORMULAS.md` §9).
6. **Painel e acabamento.**
   - Faixa compacta de câmbio e indicadores no rodapé do Painel (item 8 do M-04), substituindo o cartão de mercado atual.
   - `FORMULAS.md` (volatilidade, drawdown, correlação, HHI, Sharpe, beta, P/VP, DY, renda/patrimônio), `FONTES_DE_DADOS.md` (IFIX, BTC, IMA/IDkA, vacância), `DECISIONS.md`, CHANGELOG 1.3.0.

Fora da F8: confirmação manual de eventos suspeitos e importação CSV (F11), carteiras hipotéticas (F9), exportação e alertas (F13).

Pronto quando:

- a tabela mês × ano bate com o TWR do Painel no mesmo período, e o CDI do ano bate com o acumulado do SGS;
- cada benchmark mostra fonte, período e metodologia, e os indisponíveis mostram o motivo (nenhum valor inventado);
- volatilidade, drawdown, Sharpe e beta têm testes com séries de resultado conhecido e ficam "indisponível" com dados insuficientes;
- num FII com informe da CVM, o P/VP e o DY batem com o cálculo manual; sem informe, "indisponível";
- a Renda passiva separa recebido, anunciado e projetado, e lançar os proventos pagos da B3 grava as operações só depois da confirmação, sem duplicar os já registrados;
- as telas novas cabem em 1280 px, e o CI está verde.

**F9. Carteiras hipotéticas e backtest**

§13.1 a §13.6 e §13.9 a §13.11.

**F10. Projeções e simuladores**

§13.7 e §14.

**F11. Melhorias do save e importação CSV**

§10.6 e a importação CSV de §17.

### v2

**F12. Análise fundamentalista**

§15.

**F13. Relatórios e alertas**

Exportação e alertas de §17.

**F14. Monte Carlo e testes de estresse**

§13.8.

**F15. Atualização automática**

§19.
