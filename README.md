# Patrion — Investimentos e Patrimônio

Aplicativo desktop pessoal para Windows 10 e 11 que registra, acompanha, analisa e simula investimentos. Os dados ficam no computador e são sincronizados entre PCs por arquivo (`.invsave`), sem servidor.

O app não é corretora, não executa ordens e não faz recomendações de investimento. Simulações e projeções são sempre hipotéticas.

**Situação:** em desenvolvimento. Fase 2 concluída: fundação com banco, infraestrutura de sincronização, navegação, tema e logs; o cadastro de investimentos chega na Fase 3. Veja `docs/PROGRESS.md`.

## Documentação

| Arquivo | Conteúdo |
|---|---|
| `docs/SPEC.md` | Especificação e fases |
| `docs/DECISIONS.md` | Decisões técnicas |
| `docs/ARQUITETURA.md` | Camadas e organização do código |
| `docs/BANCO.md` | Modelo de dados |
| `docs/SINCRONIZACAO.md` | Identidade dos registros, HLC e tombstones |
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
- Cache descartável (arquivos baixados): `%LOCALAPPDATA%\Patrion\cache\`

Esses dados ficam fora da pasta de instalação e sobrevivem a atualização e desinstalação. Para usar outra pasta: `patrion.exe --data-dir <pasta> --cache-dir <pasta>`.
