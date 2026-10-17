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

**Tributação na v1**

- Impostos e retenções são registrados pelo usuário.
- O app não calcula IR devido nem gera DARF.
- Os simuladores usam alíquotas configuradas pelo usuário.

## 8. Dashboard (carteira real)

**Indicadores exibidos**

- Patrimônio, valor investido, valor de mercado e caixa.
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

**Telas**

- Dashboard, Carteira e Detalhe do ativo.
- Operações.
- Renda fixa, FIIs, Cripto e Internacional.
- Renda passiva, Benchmarks e Risco.
- Carteiras hipotéticas e Simuladores.
- Análises, Alertas e Relatórios.
- Sincronização (save) e Backup.
- Fontes de dados e Configurações.

**Padrões visuais**

- Tabelas ordenáveis, busca e filtros.
- Estados de carregamento e mensagens de erro claros.
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

**F8. Classes, benchmarks, risco e renda passiva**

§12.

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
