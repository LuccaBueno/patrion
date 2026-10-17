# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Versões seguem [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Alterado

- Dashboard: os valores dos cards ficam sempre numa linha (a fonte diminui se não couber); o percentual do resultado não realizado passou para a nota do card.
- CI: `actions/checkout` atualizado para a v7 (Node.js 24), eliminando o aviso de descontinuação do Node.js 20.
- Especificação: bloqueio do app (banco criptografado com SQLCipher, senha, Windows Hello, bloqueio por inatividade e chave de recuperação) planejado para a fase F5B da v1.x, com o impacto na arquitetura registrado em DECISIONS D-24. Ainda não implementado.
- Temas claro e escuro refeitos: fundo e superfícies neutros (grafite no escuro, branco e cinza-claro no claro), verde-esmeralda só em destaques e dourado só no símbolo e no nome (DECISIONS D-18).

### Adicionado

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
