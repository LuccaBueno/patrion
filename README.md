# Patrion — Investimentos e Patrimônio

Aplicativo desktop pessoal para Windows 10 e 11 que registra, acompanha, analisa e simula investimentos. Os dados ficam no computador e são sincronizados entre PCs por arquivo (`.invsave`), sem servidor.

O app não é corretora, não executa ordens e não faz recomendações de investimento. Simulações e projeções são sempre hipotéticas.

**Situação:** em desenvolvimento. Fases 5 e 5B concluídas: carteira real (cadastros, todos os tipos de operação, preço informado, posições e dashboard), motor financeiro (juros, CDI, XIRR, TWR), backup, restauração e sincronização entre computadores pelo arquivo de save, e bloqueio opcional do app (banco criptografado, senha, Windows Hello, inatividade e chave de recuperação). Cotações automáticas chegam na Fase 6. Veja `docs/PROGRESS.md`.

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
| `docs/PROGRESS.md` | Estado atual |
| `CHANGELOG.md` | Histórico de versões |

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
