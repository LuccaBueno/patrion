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

## Testar a sincronização entre duas pastas de dados

Duas instâncias do app podem rodar ao mesmo tempo, cada uma com a sua pasta (`--data-dir`), simulando dois PCs. O roteiro passo a passo está em `PROGRESS.md` (Fase 5). Os dois "PCs" aparecem com o mesmo nome do computador; o identificador do dispositivo (Configurações) é diferente.

Nos testes, `test/helpers/sync_pc.dart` monta dois "PCs" em memória com relógios próprios, e `syncBoth` faz A→B e B→A.

## Mudanças no banco

1. Altere as tabelas em `lib/data/db/tables.dart` e suba `schemaVersion` em `app_database.dart`.
2. Rode `dart run build_runner build` e `dart run drift_dev make-migrations`. Isso grava o snapshot `drift_schemas/patrion/drift_schema_vN.json`, gera os auxiliares de teste em `test/data/db/migrations/` e o arquivo de passos de migração.
3. Escreva o passo de migração (`from<N-1>To<N>` em `onUpgrade: stepByStep(...)`, `app_database.dart`) e o teste de preservação de dados em `test/data/db/migrations/patrion/migration_test.dart`.
4. Atualize `docs/BANCO.md`.

Não é preciso mexer no backup: ao abrir um banco com `user_version` menor que `AppDatabase.latestSchemaVersion`, o app grava a cópia em `backups\` antes de migrar (DECISIONS D-19). Para conferir à mão, rode o executável com `--data-dir` apontando para uma cópia de um banco antigo e veja a pasta `backups\` e o log ("Backup antes da migração vN→vM").

Mudanças incompatíveis no schema só com aprovação do usuário (CLAUDE.md). O código gerado e os snapshots são versionados (DECISIONS D-15); o CI falha se estiverem desatualizados.

## SQLCipher e testes do bloqueio

O `sqlite3` usa o build do **SQLCipher** (`hooks: user_defines: sqlite3: source: sqlcipher` no `pubspec.yaml`, DECISIONS D-32). Ele vale para o app e para todos os testes; sem chave, o banco se comporta como o SQLite comum. O build gera `sqlcipher.dll` ao lado do `patrion.exe`. Se a pasta `build\windows\x64\runner\Release\` tiver uma `sqlite3.dll` de builds antigos, ela é sobra e pode ser apagada (ou rode `flutter clean`).

- Os testes que derivam chaves usam `KdfPolicy.fastForTests` (Argon2id com 64 KiB), para rodar rápido; um teste de cada (arquivo de chaves e save com senha) roda com os parâmetros de produção.
- O Windows Hello e o cofre da chave têm dublês em `test/helpers/fake_security.dart`; o DPAPI real é testado em `test/infrastructure/security/hello_vault_test.dart` (só no Windows).
- Para testar o bloqueio à mão sem mexer nos seus dados, use `--data-dir` com uma pasta de teste (roteiro em `PROGRESS.md`, Fase 5B). Apagar a pasta de teste apaga tudo, inclusive as chaves.

## Ícone do app

O `.ico` e o PNG do símbolo são gerados a partir do SVG (DECISIONS D-17):

```powershell
dart run tool/gen_app_icon.dart
```

Rode de novo sempre que `assets/branding/patrion-simbolo.svg` mudar e faça commit dos arquivos gerados.

## Testes de widget com o banco

Os testes de interface usam banco em memória (`test/helpers/test_database.dart`). Ao final de cada teste, o app precisa ser desmontado (`AppHarness.run` em `test/helpers/app_harness.dart`, ou `withApp` em `test/presentation/app_test.dart`): o Drift encerra os streams de consulta com um timer, e sem isso o fechamento do banco trava a execução dos testes.

- As consultas do Drift rodam fora do relógio falso do teste: depois de cada ação, use `AppHarness.settle()` (deixa o tempo real andar e redesenha).
- Escritas feitas pelo teste depois de montar o app vão dentro de `tester.runAsync(...)`.
- `test/helpers/portfolio_fixture.dart` cria serviços da carteira com uma instituição, duas contas e dois ativos.

## Ícones novos não aparecem no build de release

O build de release reduz a fonte de ícones aos ícones usados no código. Na F3 o build incremental reaproveitou a fonte antiga e os ícones novos da navegação apareceram vazios. Se isso acontecer, rode `flutter clean` e gere o build de novo (o CI sempre parte do zero).

## Onde ficam os dados e os logs

| O quê | Onde |
|---|---|
| Banco | `%APPDATA%\Patrion\patrion.db` (criptografado com o bloqueio ativo; chaves em `patrion.keys.json` e, com o Windows Hello, `patrion.hello.bin`. Ver `BLOQUEIO.md`) |
| Backups | `%APPDATA%\Patrion\backups\` (antes de migrações, de importar um save e de restaurar; manuais). Ver `BACKUP.md` |
| Logs | `%APPDATA%\Patrion\logs\patrion.log` (rotativos, D-16) |
| Cache | `%LOCALAPPDATA%\Patrion\cache\` |

Com `--data-dir`, banco, backups e logs ficam na pasta indicada. A tela Configurações mostra os caminhos em uso.

## CI

`.github/workflows/ci.yml` roda em todo push e PR, no `windows-latest`, com o Flutter fixado: código gerado atualizado, `dart format`, `flutter analyze`, `flutter test` e `flutter build windows --release`. Permissões mínimas (`contents: read`).

`.github/workflows/release.yml` roda na tag `vX.Y.Z` (Release em rascunho) ou em "Run workflow" (ensaio, com os arquivos como artefato). Ver `DISTRIBUICAO.md`.

## Instalador e Release

Inno Setup 6 instalado (no PC do desenvolvedor, em `%LOCALAPPDATA%\Programs\Inno Setup 6`, fora do `PATH`; o script também procura em Program Files, no `PATH` e em `$env:ISCC`).

```powershell
powershell -ExecutionPolicy Bypass -File tool\release\build_release.ps1             # dist\: instalador, ZIP, SHA256SUMS, notas
powershell -ExecutionPolicy Bypass -File tool\release\build_release.ps1 -SkipBuild  # reaproveita o build
powershell -ExecutionPolicy Bypass -File tool\release\test_install.ps1 ...          # teste de instalação (DISTRIBUICAO.md)
powershell -ExecutionPolicy Bypass -File tool\release\sandbox_test.ps1              # o mesmo no Windows Sandbox
```

Os scripts `.ps1` são salvos em UTF-8 **com BOM**: sem ele, o Windows PowerShell 5.1 lê os acentos errado.

**O build release se comporta diferente dos testes.** Os testes rodam em JIT; o release é AOT, que remove código e campos não usados. Um objeto com recurso nativo (arquivo, trava) guardado só num campo que nunca é lido pode ser coletado e fechado (D-39). O teste de instalação roda o app de verdade e pega esse tipo de problema.
