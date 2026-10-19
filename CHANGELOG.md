# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Versões seguem [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Alterado

- A prévia da importação de um save avisa, antes de aplicar, quando a carteira resultante fica inconsistente (por exemplo, uma venda maior que a posição depois de vendas feitas nos dois computadores), e recalcula o aviso quando a versão de um conflito muda.
- O SQLite do app passou a ser o build do SQLCipher (sem chave, ele funciona como o SQLite comum).
- Dashboard: os valores dos cards ficam sempre numa linha (a fonte diminui se não couber); o percentual do resultado não realizado passou para a nota do card.
- CI: `actions/checkout` atualizado para a v7 (Node.js 24), eliminando o aviso de descontinuação do Node.js 20.
- Especificação: bloqueio do app (banco criptografado com SQLCipher, senha, Windows Hello, bloqueio por inatividade e chave de recuperação) planejado para a fase F5B da v1.x, com o impacto na arquitetura registrado em DECISIONS D-24 (implementado, ver Adicionado).
- Temas claro e escuro refeitos: fundo e superfícies neutros (grafite no escuro, branco e cinza-claro no claro), verde-esmeralda só em destaques e dourado só no símbolo e no nome (DECISIONS D-18).

### Adicionado

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
