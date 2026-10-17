# Desenvolvimento

## Requisitos

- Windows 10 ou 11 x64.
- Flutter **3.47.7** (stable), conforme DECISIONS D-01.
- Visual Studio 2022 (ou Build Tools) com "Desenvolvimento para desktop com C++" e Windows SDK.
- **Modo de Desenvolvedor do Windows ligado.** Com plugins (`path_provider`, `window_manager`), o `flutter build windows` exige links simbólicos e falha com "Building with plugins requires symlink support" sem ele. Para ligar: `start ms-settings:developers`.

## Comandos (PowerShell, na raiz do repositório)

```powershell
flutter pub get
dart run build_runner build                 # código gerado do Drift
dart format .
flutter analyze
flutter test
flutter run -d windows
flutter build windows --release
```

Rodar com outra pasta de dados (por exemplo, para simular um segundo PC):

```powershell
flutter run -d windows --dart-entrypoint-args="--data-dir=D:\PatrionB,--cache-dir=D:\PatrionB\cache"
# ou, com o executável já gerado:
build\windows\x64\runner\Release\patrion.exe --data-dir D:\PatrionB
```

## Mudanças no banco

1. Altere as tabelas em `lib/data/db/tables.dart` e suba `schemaVersion` em `app_database.dart`.
2. Rode `dart run build_runner build` e `dart run drift_dev make-migrations`. Isso grava o snapshot `drift_schemas/patrion/drift_schema_vN.json`, gera os auxiliares de teste em `test/data/db/migrations/` e o arquivo de passos de migração.
3. Escreva o passo de migração e o teste de migração da versão anterior para a nova.
4. Atualize `docs/BANCO.md`.

Mudanças incompatíveis no schema só com aprovação do usuário (CLAUDE.md). O código gerado e os snapshots são versionados (DECISIONS D-15); o CI falha se estiverem desatualizados.

## Ícone do app

O `.ico` e o PNG do símbolo são gerados a partir do SVG (DECISIONS D-17):

```powershell
dart run tool/gen_app_icon.dart
```

Rode de novo sempre que `assets/branding/patrion-simbolo.svg` mudar e faça commit dos arquivos gerados.

## Testes de widget com o banco

Os testes de interface usam banco em memória (`test/helpers/test_database.dart`). Ao final de cada teste, o app precisa ser desmontado (`withApp` em `test/presentation/app_test.dart`): o Drift encerra os streams de consulta com um timer, e sem isso o fechamento do banco trava a execução dos testes.

## Onde ficam os dados e os logs

| O quê | Onde |
|---|---|
| Banco | `%APPDATA%\Patrion\patrion.db` |
| Backups (F5) | `%APPDATA%\Patrion\backups\` |
| Logs | `%APPDATA%\Patrion\logs\patrion.log` (rotativos, D-16) |
| Cache | `%LOCALAPPDATA%\Patrion\cache\` |

Com `--data-dir`, banco, backups e logs ficam na pasta indicada. A tela Configurações mostra os caminhos em uso.

## CI

`.github/workflows/ci.yml` roda em todo push e PR, no `windows-latest`, com o Flutter fixado: código gerado atualizado, `dart format`, `flutter analyze`, `flutter test` e `flutter build windows --release`. Permissões mínimas (`contents: read`).
