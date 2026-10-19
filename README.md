# Patrion — Investimentos e Patrimônio

Aplicativo desktop pessoal para Windows 10 e 11 que registra, acompanha, analisa e simula investimentos. Os dados ficam no computador e são sincronizados entre PCs por arquivo (`.invsave`), sem servidor.

O app não é corretora, não executa ordens e não faz recomendações de investimento. Simulações e projeções são sempre hipotéticas.

**Situação:** versão 1.0.0 preparada (Fase 7, distribuição): carteira real, motor financeiro (juros, CDI, XIRR, TWR), backup, restauração e sincronização entre computadores pelo arquivo de save, bloqueio opcional do app, cotações e indicadores automáticos com fonte e data, instalador, versão portátil e verificador de atualizações. Veja `docs/PROGRESS.md`.

## Documentação

| Arquivo | Conteúdo |
|---|---|
| `docs/SPEC.md` | Especificação e fases |
| `docs/DECISIONS.md` | Decisões técnicas |
| `docs/ARQUITETURA.md` | Camadas e organização do código |
| `docs/BANCO.md` | Modelo de dados |
| `docs/FORMULAS.md` | Fórmulas financeiras |
| `docs/SINCRONIZACAO.md` | Arquivo de save, HLC e regras da mesclagem |
| `docs/BACKUP.md` | Backup, restauração e procedimento de recuperação |
| `docs/BLOQUEIO.md` | Bloqueio do app, chaves, chave de recuperação e senha do arquivo de save |
| `docs/FONTES_DE_DADOS.md` | Provedores de dados avaliados |
| `docs/DESENVOLVIMENTO.md` | Ambiente, comandos, migrações e CI |
| `docs/DISTRIBUICAO.md` | Instalador, versão portátil, Releases, atualizações e testes de instalação |
| `docs/SOLUCAO_DE_PROBLEMAS.md` | Problemas comuns de instalação, `.invsave`, atualizações e dados |
| `docs/PROGRESS.md` | Estado atual |
| `CHANGELOG.md` | Histórico de versões |

## Instalação

Baixe o instalador (`Patrion-X.Y.Z-instalador.exe`) ou o ZIP portátil na página de [Releases](https://github.com/LuccaBueno/patrion/releases). Windows 10 ou 11, 64 bits. O app não é assinado: o SmartScreen pede "Mais informações" > "Executar assim mesmo". Para atualizar, feche o app e execute o instalador da versão nova; os dados ficam onde estão. Detalhes em `docs/DISTRIBUICAO.md`.

## Desenvolvimento

Requisitos: Windows 10/11 x64, Flutter 3.47.7 (stable), Visual Studio 2022 com "Desenvolvimento para desktop com C++" e o **Modo de Desenvolvedor do Windows ligado** (o build com plugins exige links simbólicos). Detalhes em `docs/DESENVOLVIMENTO.md`.

```powershell
flutter pub get
dart run build_runner build
dart format .
flutter analyze
flutter test
flutter run -d windows
flutter build windows --release
```

## Onde ficam os dados

- Banco, backups e logs: `%APPDATA%\Patrion\` (logs em `logs\patrion.log`)
- Backups em `%APPDATA%\Patrion\backups\`: automáticos antes de atualizar o formato do banco, de importar um save e de restaurar, e manuais pela tela Backup (`docs/BACKUP.md`)
- Sincronização entre computadores pelo arquivo de save `.invsave`, sem servidor, com senha opcional (`docs/SINCRONIZACAO.md`)
- Bloqueio opcional (Configurações): banco criptografado com SQLCipher, senha, Windows Hello, bloqueio por inatividade e chave de recuperação (`docs/BLOQUEIO.md`)
- Cache descartável (arquivos baixados): `%LOCALAPPDATA%\Patrion\cache\`

Esses dados ficam fora da pasta de instalação e sobrevivem a atualização e desinstalação. Para usar outra pasta: `patrion.exe --data-dir <pasta> --cache-dir <pasta>`.
