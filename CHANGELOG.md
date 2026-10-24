# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Versões seguem [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

## [1.4.0] - 2026-10-24

Painel único com abas, números coerentes e o fim do piscar (ajustes M-10 a M-12).

### Alterado

- **Painel com abas:** Visão geral · Rentabilidade · Comparação · Risco. O **Desempenho saiu do menu** (agora: Painel, Carteira, Renda passiva, Operações); as três abas de desempenho têm o mesmo conteúdo de antes e o mesmo período. Benchmarks passou a se chamar Comparação. O endereço antigo leva à Rentabilidade.
- **Visão geral mais simples:** o patrimônio em número grande; numa linha, ganho total, hoje e total aplicado; lucro realizado, proventos de 12 meses e TIR (com a rentabilidade no ano); a evolução patrimonial; distribuição e aportes; proventos e altas e baixas; câmbio e indicadores no rodapé. "Mais números" e "Maiores posições" saíram por serem repetidos; o que só existia lá está no ícone (i) do patrimônio. Cabe em até 2 telas em 1280 × 800.
- **Uma definição de ganho:** ganho total = patrimônio − total aplicado + proventos, igual no Painel, no título do gráfico em "Tudo" e na Carteira (que ganhou a linha "Carteira toda"). Nos outros períodos, o gráfico diz "ganho no período" e mostra os aportes à parte (aporte não é ganho).
- O **saldo inicial conta como aporte** na data informada.
- Os textos longos dos gráficos foram para o ícone (i).

### Adicionado

- **Olho para ocultar valores** ao lado do patrimônio: troca todos os valores em reais do app por "R$ ••••" (inclusive gráficos) e fica lembrado neste computador.

### Corrigido

- A tela **Desempenho piscava** e voltava à primeira aba durante a atualização e o download do histórico: a tela agora fica com os números anteriores enquanto recalcula, e o cálculo só roda de novo quando os dados mudam de verdade.
- O título do gráfico falava em "patrimônio cresceu" somando os aportes; o ganho do período deixava de fora o ganho do primeiro dia.
- A linha do **total aplicado** aparecia como uma linha vertical no fim do gráfico quando havia poucos dias.
- Períodos que começam antes dos registros diziam "desde 31/12/2025"; agora dizem a data real ("desde 22/10/2026, início dos registros").
- **CDI do período** aparecia como 0,00% quando o dia ainda não tinha sido publicado; agora soma os dias publicados e diz até quando, ou "indisponível" com o motivo. O IPCA do mês anterior ao início ficava de fora.
- **TIR** em poucos dias aparecia como "indisponível" sem explicação; agora exige 30 dias e diz isso. Todo "indisponível" mostra o motivo.
- "Maiores altas e baixas" mostram a data do fechamento de referência.
- Sharpe e beta de 1 ano ficavam indisponíveis nos fins de semana.

## [1.3.0] - 2026-10-23

Fase 8: desempenho, benchmarks, risco, renda passiva e análises por classe.

### Adicionado

- **Desempenho** (menu): o mesmo período para três abas, com 1M, 3M, 6M, YTD, 1A, 3A, 5A, 10A, Tudo e Personalizado (só aparecem os períodos que os dados sustentam).
  - **Rentabilidade:** tabela mês a mês com o ano e o acumulado, o CDI do ano e o "% do CDI"; rentabilidade do período (TWR), CDI, retorno real (descontado o IPCA), taxa anual equivalente e a TIR para comparar.
  - **Benchmarks:** CDI, Selic, IPCA, IGP-M, Ibovespa, IFIX, Bitcoin, S&P 500 e Nasdaq contra a carteira no mesmo intervalo, com fonte, moeda, período, metodologia, retorno acumulado e ao ano e a diferença em pontos percentuais; gráfico em base 100 com até 4 índices. IMA e IDkA aparecem como indisponíveis (histórico pago na ANBIMA); S&P 500 e Nasdaq dependem da fonte Yahoo, que vem desligada.
  - **Risco:** volatilidade, queda máxima (com pico, fundo e recuperação), Sharpe e beta da carteira; volatilidade e queda de cada ativo pelo preço ajustado; correlação entre os ativos; concentração (maior posição, cinco maiores, HHI) por ativo, classe, setor, país e moeda; exposição cambial; liquidez; e **alocação-alvo por classe**, com a distância até o alvo em pontos e em reais (vale em todos os computadores).
- **Renda passiva** (menu): recebido em 12 meses, média mensal, renda sobre o patrimônio e sobre o custo; recebido, anunciado e projetado separados; proventos por mês; próximos pagamentos; por ano e por ativo.
- **Lançar proventos pagos:** a B3 publica os proventos dos seus ativos; o app mostra os já pagos que não estão registrados, com a quantidade que você tinha na data-com (pelas operações, por corretora), e grava só depois da prévia e da confirmação, com o IR do JCP informado na hora. Se a posição foi lançada como saldo inicial depois da data-com, o provento não é sugerido e a tela explica por quê.
- **Visões por classe na Carteira:** FIIs (P/VP pelo informe da CVM, DY de 12 meses, rendimentos por mês, liquidez, recebido/anunciado/estimado), Renda fixa (saldo informado, projeção pelo indexador e valor de mercado lado a lado, rentabilidade e % do CDI), Cripto e Internacional (retorno na moeda, efeito do câmbio e em reais).
- Novos índices guardados: **IFIX** (B3), **Bitcoin** (Binance) e S&P 500 e Nasdaq (Yahoo, opcional).
- Faixa compacta de **câmbio e indicadores** no rodapé do Painel (o clique leva a Fontes de dados).

### Alterado

- Painel: "Comparar com" ganhou o IFIX.
- Gravar uma preferência sincronizada (como os alvos) não recalcula mais a carteira inteira; só o controle de caixa recalcula.

### Corrigido

- Consulta de índices no Yahoo (o "^" de `^GSPC` era codificado duas vezes).
- O Bitcoin da Binance não grava mais o candle do dia ainda aberto como fechamento.

## [1.2.0] - 2026-10-23

Histórico de 10 anos, página do ativo em tela cheia, Painel com a evolução do patrimônio e corretora escolhida na hora.

### Adicionado

- **Histórico completo de cotações em segundo plano:** ao adicionar um ativo e ao abrir o app, os fechamentos diários dos últimos 10 anos (ou desde a listagem) de todos os ativos com cotação automática, com os proventos e eventos. Na B3, um arquivo anual do COTAHIST serve a todos os ativos e é apagado depois de lido. O andamento aparece no rodapé do menu; se o app for fechado, continua na próxima abertura. Em Configurações > Fontes de dados, cada ativo mostra desde quando há histórico, com o botão "Baixar histórico completo".
- **Página do ativo em tela cheia** (clique na linha da Carteira): valor da posição, lucro e variação do dia no topo, com Comprar e Vender; gráfico grande só com o desempenho do ativo no mercado (1M, 6M, 1A, 5A, 10A e Tudo), com a variação do período, máxima e mínima, tooltip e a opção "Preço ajustado por proventos" (calculado, sem as quedas falsas das datas ex e dos desdobramentos); cartões com os números da posição e a divisão por corretora; abas Operações, Proventos e Dados do ativo.
- **Evolução patrimonial no Painel:** o patrimônio dia a dia com o total aplicado em degraus (o espaço entre os dois é o ganho), períodos 6M, 1A, 5A e Tudo e a opção "Comparar com" CDI, Ibovespa e IPCA: em R$, quanto você teria com os mesmos aportes no índice (simulação hipotética); em %, a rentabilidade da carteira (TWR) contra os índices.
- Faixa no topo do Painel: patrimônio, total aplicado, ganho e rentabilidade no ano.
- **Ibovespa** diário, pela B3, atualizado com os demais indicadores.
- **Corretora / custodiante** no "Adicionar ativo" e no Comprar: escolha uma das usadas ou digite uma nova (o app cria a corretora e a conta "Principal" ao salvar).
- **Carteira por corretora:** filtro (lembrado entre aberturas) e "Agrupar por corretora", com subtotais; o mesmo ativo em duas corretoras continua numa linha só.
- **Transferir de corretora** na página do ativo, mantendo o preço médio.

### Alterado

- O histórico, o câmbio e os indicadores passam a começar 10 anos antes (eram 5), salvo se você escolheu outro ano em Fontes de dados.
- O painel lateral de detalhes da Carteira foi substituído pela página do ativo.
- Painel: distribuição numa rosca só, com seletor (ativo, classe, setor, corretora) e o total no centro; aportes com compras em verde e vendas em cinza; os demais números ficam em "Mais números".
- **Cadastros saiu do menu:** agora é Configurações > Corretoras e ativos, para corrigir cadastros.
- Cálculos com muitas multiplicações em sequência (como a rentabilidade de 10 anos) ficaram muito mais rápidos, com os mesmos resultados.

## [1.1.0] - 2026-10-22

Ajustes de uso real: adição rápida pelo ticker, menu reorganizado, caixa opcional, Carteira com painel de detalhes e Painel com gráficos.

### Adicionado

- **Adicionar ativo pelo ticker** (Carteira e Cadastros): digite o ticker (ex.: "bbas3"), a quantidade e o preço; o app busca nome, classe, ISIN, setor e segmento na B3 e na brapi e registra o ativo e a compra numa tela só. Ativo já cadastrado: só a compra. Opção "Posição que já tenho (saldo inicial)" para copiar quantidade e preço médio da corretora (padrão na carteira vazia). Ticker não encontrado ou sem internet: aviso e cadastro manual. Funciona sem internet com os dados já baixados. Renda fixa, cripto e internacional continuam no "Cadastro completo".
- **Painel de detalhes do ativo** na Carteira, sem trocar de tela: lucro em R$, total aplicado, variação do dia, gráfico da cotação (1S a Tudo) com a linha do preço médio, % da carteira, proventos, operações e os botões Comprar e Vender.
- **Painel com gráficos:** patrimônio, resultado total e variação do dia em destaque; distribuição por ativo, classe, setor e instituição; aportes do mês e do ano com barras dos últimos 12 meses; proventos por mês; maiores altas e baixas do dia ou do mês.
- Opção **"Controlar saldo em caixa"** em Configurações > Geral (vale nos computadores sincronizados).

### Alterado

- **Caixa opcional, desligado por padrão:** compras e vendas não movimentam caixa e o patrimônio é o valor de mercado das posições, sem patrimônio negativo por falta de depósitos. Ligando a opção, volta o comportamento da 1.0.0. A rentabilidade (TIR) não muda.
- **Menu:** Painel (antigo Início), Carteira, Operações e Cadastros em cima; Sincronizar e Configurações no rodapé. Sincronizar leva direto ao save e avisa quando a última sincronização tem 7 dias ou mais.
- **Configurações** em seções: Geral, Segurança, Fontes de dados, Backup, Sincronização e Sobre (as telas de Backup, Fontes de dados e Sincronização passaram para cá).
- **Carteira:** um item por ativo (somando as contas), do maior valor para o menor, com valor da posição, preço médio, cotação atual (com fonte e data) e valorização; ativos sem cotas ficam no fim, em cinza.
- Tickers digitados em minúsculas são gravados em maiúsculas; o código do fracionário ("BBAS3F") vira o do lote padrão.

### Corrigido

- "Atualizar agora" passou a buscar a cotação de um ativo recém-cadastrado com cotação automática que ainda não tem operações, e a página do ativo mostra essa cotação.
- Cartões de aviso vazios (como "Nenhuma posição") não ocupam mais a altura toda da tela.

## [1.0.0] - 2026-10-22

Primeira versão utilizável: carteira real, motor financeiro, backup e sincronização por arquivo, bloqueio opcional, dados de mercado e instalador.

### Alterado

- Carteira: na janela de 1280 px, a tabela inteira (até a coluna "Resultado") aparece sem rolar para o lado. A classe fica embaixo do ativo, a conta embaixo da instituição e o percentual embaixo do resultado.
- Carteira: coluna "Preço médio / Atual", com o preço médio e, embaixo, o preço atual por unidade, para comparar de relance; a fonte e a data da cotação aparecem ao passar o mouse, e sem cotação aparece "indisponível". No detalhe do ativo, o preço atual fica em destaque ao lado do preço médio.
- A prévia da importação de um save avisa, antes de aplicar, quando a carteira resultante fica inconsistente (por exemplo, uma venda maior que a posição depois de vendas feitas nos dois computadores), e recalcula o aviso quando a versão de um conflito muda.
- O SQLite do app passou a ser o build do SQLCipher (sem chave, ele funciona como o SQLite comum).
- Dashboard: os valores dos cards ficam sempre numa linha (a fonte diminui se não couber); o percentual do resultado não realizado passou para a nota do card.
- Temas claro e escuro refeitos: fundo e superfícies neutros (grafite no escuro, branco e cinza-claro no claro), verde-esmeralda só em destaques e dourado só no símbolo e no nome (DECISIONS D-18).

### Corrigido

- Indicadores do Banco Central (SGS): a atualização não mostra mais "erro inesperado" nem "formato inesperado" quando ainda não há dado novo (o app pede a partir do último dado guardado), e repete as consultas quando o serviço responde, de forma passageira, uma página de erro. Se uma série falhar, as outras são atualizadas normalmente e aparece um aviso só, com o nome das séries que ficaram sem dado.

### Adicionado

- Fase 7 (distribuição):
  - Instalador para Windows 10 e 11 (x64): instala só para o seu usuário, sem pedir administrador (ou para todos, se preferir), com atalho no Menu Iniciar e atalho opcional na área de trabalho. A nova versão instala por cima da anterior, e o instalador pede para fechar o app se ele estiver aberto.
  - A desinstalação não apaga os dados (`%APPDATA%\Patrion`) e mostra onde eles ficaram.
  - Versão portátil em ZIP, com `LEIA-ME.txt` explicando onde ficam os dados.
  - Arquivos `.invsave` abrem com o Patrion: o duplo clique leva à Sincronização com a prévia da importação, que pede a confirmação antes de aplicar. Com o bloqueio ativo, a importação espera o desbloqueio.
  - Uma janela por pasta de dados: abrir o app (ou um `.invsave`) com ele já aberto traz a janela existente para a frente, em vez de abrir uma segunda cópia sobre o mesmo banco.
  - Verificador de atualizações em Configurações > Atualizações: consulta as Releases do GitHub ao abrir o app (no máximo uma vez por dia, pode ser desligado) ou em "Verificar agora", mostra as notas da versão e o link de download, permite ignorar uma versão e, por padrão, ignora as versões de teste (beta e rc). O Início avisa quando há versão nova. Sem internet, nada acontece.
  - O runtime do Visual C++ vai junto do app, que abre num Windows sem o "Visual C++ Redistributable".
  - Workflow de release no GitHub Actions: na tag `vX.Y.Z`, gera o instalador, o ZIP portátil e as somas SHA-256 e cria a Release como rascunho (tags `-beta` e `-rc` viram pré-lançamento).
  - Avisos de terceiros: Configurações > Sobre > "Licenças de terceiros" (com o SQLCipher e o OpenSSL, além das bibliotecas do Flutter) e o arquivo `AVISOS_DE_TERCEIROS.txt` junto do app, com as fontes de dados e as suas licenças.
  - `docs/DISTRIBUICAO.md` e `docs/SOLUCAO_DE_PROBLEMAS.md`.
- Fase 6 (dados de mercado):
  - Cotações automáticas: ações, FIIs, ETFs e BDRs da B3 (brapi e fechamento oficial do COTAHIST), Tesouro Direto (Tesouro Transparente), cripto (CoinGecko e Binance) e ações e ETFs dos EUA (Finnhub e Twelve Data, com chave; Yahoo opcional, desligado por padrão). Cada preço aparece com a fonte, a data e, ao passar o mouse, o tipo, a coleta e o atraso; um preço antigo aparece com a data e um ícone de desatualizado.
  - Câmbio (PTAX do Banco Central, com a referência do BCE como alternativa) e indicadores (CDI, Selic, meta Selic, IPCA e IGP-M do Banco Central; IPCA também pelo IBGE), com CDI anualizado e IPCA em 12 meses calculados. Painel "Câmbio e indicadores" no Início.
  - Patrimônio total em reais no Início quando a carteira tem mais de uma moeda, pelo câmbio mais recente guardado (com a data e a fonte do câmbio).
  - Atualização automática com o app aberto (ao abrir e a cada 30 minutos, configurável ou desligada) e manual: "Atualizar agora", "Atualizar este ativo" e "Baixar histórico" no detalhe do ativo, e "Testar conexão" em cada provedor.
  - Tela "Fontes de dados": o que cada provedor fornece e o que recebe (só códigos de ativos e de séries), licença, limites, estado (último acesso, erro, uso da cota), ligar e desligar, chave de API e ano inicial do histórico.
  - Chaves de API digitadas na tela e guardadas só neste computador, protegidas pelo Windows; nunca vão no save, nos backups nem no log.
  - Histórico da B3 pelo COTAHIST: só os anos (ou dias) que faltam, e o arquivo baixado é apagado depois de extraído.
  - Sem internet, o app avisa "sem conexão" e continua com os últimos dados guardados, cada um com a sua data; a atualização para cedo quando o computador está sem rede.
  - Cadastro de ativo com a escolha "cotação automática" ou "preço ou saldo informado" (sugerida pela classe), e ação em "Fontes de dados" para passar os ativos antigos para a cotação automática.
  - O arquivo de save pode levar os dados de mercado já baixados (opção marcada por padrão), para o outro computador funcionar sem internet. Com eles, o arquivo usa o formato 2.
  - brapi na atualização automática só em horário de pregão da B3 (dias úteis, 10:00 às 18:30 de Brasília) e no máximo a cada 30 minutos por ativo; "Fontes de dados" mostra quanto da cota mensal da brapi já foi usado, o app avisa a partir de 80% e, com a cota esgotada, os ativos da B3 usam o fechamento oficial do COTAHIST.
- Fase 5B (bloqueio do app):
  - Bloqueio opcional, por computador, em Configurações: o banco de dados passa a ser criptografado (SQLCipher) e só abre com a senha. A conversão de um banco existente faz um backup antes, é conferida e pode ser desfeita ("Desativar o bloqueio", com a senha).
  - Tela de desbloqueio na abertura; "Bloquear agora"; bloqueio por inatividade (padrão 15 minutos; 1, 5, 30, 60 minutos ou nunca), que fecha o banco e descarta os dados da memória.
  - Chave de recuperação mostrada uma única vez ao ativar; "Esqueci a senha" libera os dados com ela e define uma nova senha. Também é possível trocar a senha e gerar nova chave de recuperação.
  - Desbloqueio opcional pelo Windows Hello (rosto, digital ou PIN), com a chave protegida pela conta do Windows.
  - Backups criptografados com o bloqueio ativo, cada um com uma cópia do arquivo de chaves; ao ativar, os backups antigos da pasta de backups também são criptografados. Backups de uma chave anterior são restaurados com a senha da época.
  - Senha do arquivo de save: ao salvar, o arquivo pode ser protegido (AES-256-GCM, chave Argon2id); ao importar, o app pede a senha.
  - `docs/BLOQUEIO.md`.
- Fase 5 (backup e save):
  - Arquivo de save `.invsave` para sincronizar computadores sem servidor: "Salvar arquivo de save", "Importar save" e "Importar e gerar novo save", com nome padrão `Patrion_<PC>_<data>.invsave`.
  - Importação com prévia: registros novos, alterados e excluídos por tabela, conflitos (com a escolha da versão de cada lado), cadastros repetidos que serão unificados e possíveis operações duplicadas (só sinalizadas).
  - Mesclagem por registro com relógio lógico (HLC): importar o mesmo arquivo de novo não muda nada, um arquivo antigo não desfaz alterações, os dois PCs terminam iguais e relógios desacertados não fazem perder edições.
  - Ativos, instituições e contas cadastrados separadamente nos dois PCs viram um só, com as operações dos dois ligadas a ele.
  - Arquivo conferido por SHA-256 antes de importar; corrompido, alterado, de versão mais nova ou protegido por senha é recusado sem tocar no banco. Importação numa única transação: se algo falhar, nada muda.
  - Saves de versões anteriores do banco são convertidos na importação.
  - Tela Sincronização com os computadores sincronizados e o histórico; aviso no Início quando a última sincronização tem 7 dias ou mais.
  - Tela Backup: backup manual (na pasta de backups ou em outra pasta), lista dos backups e restauração com confirmação explícita e backup automático do estado atual antes. A restauração reabre o banco sem fechar o app.
  - Backups automáticos antes de importar um save e de restaurar, com retenção dos 10 mais recentes de cada tipo; backups manuais nunca são apagados. Todo backup é conferido e tem metadados (data, versão, SHA-256) num arquivo `.json` ao lado.
  - Banco no schema versão 3, com migração automática.
  - `docs/BACKUP.md` com o procedimento de recuperação; `docs/SINCRONIZACAO.md` com o formato do arquivo e as regras da mesclagem.
- Fase 4 (motor financeiro):
  - Juros simples e compostos, equivalência de taxas, taxa nominal e efetiva, bases de 252 dias úteis, /365, /360 e 30/360.
  - Calendário de dias úteis com os feriados nacionais (Carnaval, Sexta-feira Santa e Corpus Christi calculados pela Páscoa).
  - CDI e Selic acumulados na base 252, com percentual do indexador e taxa adicional.
  - XIRR com datas irregulares, TWR, retorno simples, acumulado, real e anualizado (CAGR), retornos por dia, mês e ano, e separação do efeito cambial.
  - Potências, logaritmos e exponenciais calculados com decimais exatos, sem ponto flutuante.
  - Dashboard: cards "Resultado total" e "Rentabilidade (TIR)", com o período e a explicação da metodologia.
  - Detalhe do ativo: card "Desempenho" com resultado e TIR com e sem proventos e antes de custos.
  - `docs/FORMULAS.md` com as fórmulas do motor financeiro.
- Fase 3 (carteira real):
  - Cadastro de instituições, contas (com arquivamento) e ativos de todas as classes, incluindo as características de títulos de renda fixa.
  - Todos os tipos de operação da SPEC §7: compra, venda, aporte, resgate, depósito, retirada, transferência entre contas (dinheiro ou custódia), dividendos, JCP, rendimentos de FII, juros, amortização, bonificação, desdobramento, grupamento, vencimento, taxas, impostos, retenções, reinvestimento e ajuste manual com justificativa.
  - Validação por tipo de operação, aviso de possível duplicata e recusa de alterações que deixariam uma posição negativa.
  - Preço unitário e saldo informados manualmente, sempre com a data de referência; sem preço, o valor de mercado aparece como "indisponível".
  - Posições recalculadas a partir das operações (preço médio com custos, lucro realizado, proventos, desdobramentos e grupamentos), e caixa por conta.
  - Telas: dashboard inicial (patrimônio, valor investido, valor de mercado, caixa, resultado, proventos, alocação por classe e instituição, maiores posições e vencimentos próximos), Carteira, Detalhe do ativo, Operações (busca, filtros e ordenação) e Cadastros.
  - Banco no schema versão 2, com migração automática a partir da versão 1.
  - Backup automático do banco antes de qualquer migração, com verificação de integridade e retenção dos 10 mais recentes. Se o backup falhar, o banco não é migrado.
  - `docs/FORMULAS.md` com as fórmulas de posição, valor de mercado e totais.
- Fase 2 (fundação):
  - Camadas do projeto (`core`, `domain`, `application`, `data`, `infrastructure`, `presentation`) com teste automático das regras de dependência.
  - Banco SQLite com Drift (schema versão 1: `dev_identity`, `dev_settings`, `shared_settings`), snapshot do schema e teste de schema.
  - Infraestrutura de sincronização: UUID v7, Hybrid Logical Clock, `device_id`, tombstones e repositório base que preenche os campos de sincronização.
  - Pastas de dados em `%APPDATA%\Patrion` e cache em `%LOCALAPPDATA%\Patrion\cache`, com `--data-dir` e `--cache-dir`.
  - Logs técnicos rotativos em `%APPDATA%\Patrion\logs` e erros por tipo (rede, dados, cálculo, interno).
  - Navegação lateral, temas claro e escuro (seguindo o Windows por padrão) e tela de Configurações com as pastas em uso.
  - Tela de erro quando o app não consegue iniciar.
  - Ícone do app (16 a 256 px) gerado a partir do símbolo.
  - CI no GitHub Actions: formatação, análise, testes e build Windows.
- Fase 1: projeto Flutter para Windows com app vazio (nome e subtítulo).
- Documentação: fontes de dados, decisões técnicas, modelo de dados.
- Proposta de símbolo vetorial do app (`assets/branding/patrion-simbolo.svg`).

### Problemas conhecidos

- O instalador e o app não são assinados digitalmente: o Windows SmartScreen mostra um aviso na primeira execução ("Mais informações" > "Executar assim mesmo").
- Não há atualização automática: o verificador avisa e abre a página da versão; o instalador é baixado e executado à mão.
- O desbloqueio pelo Windows Hello ainda não foi testado num computador com o Hello configurado.
- Se outro programa já tiver sido escolhido no Windows para abrir arquivos `.invsave`, o Windows mantém essa escolha; use "Abrir com" > Patrion.
