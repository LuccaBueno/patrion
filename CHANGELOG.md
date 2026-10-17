# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Versões seguem [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Adicionado

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
