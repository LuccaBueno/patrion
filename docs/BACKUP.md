# Backup e recuperação

Estado em 17/10/2026 (Fase 5). SPEC §11; decisões em DECISIONS D-19, D-24, D-28 e D-30.

**Backup ≠ save.** O backup é a cópia integral do banco deste computador, para recuperação: restaurar substitui tudo. O save (`SINCRONIZACAO.md`) leva dados de um PC para outro e mescla.

## Onde ficam

```
%APPDATA%\Patrion\                 (ou a pasta de --data-dir)
  patrion.db                       banco
  backups\
    patrion_2026-10-17_21-45-55-919Z_manual_schema-v3_app-0.1.0.db
    patrion_2026-10-17_21-45-55-919Z_manual_schema-v3_app-0.1.0.db.json
    patrion_..._pre-importacao_schema-v3_app-0.1.0.db (+ .json)
    patrion_..._pre-restauracao_schema-v3_app-0.1.0.db (+ .json)
    patrion_..._pre-migracao_v2-v3_app-0.1.0.db (+ .json)
```

O nome traz a data e hora **UTC** (ordenável), o motivo, a versão do schema e a do app. Backups manuais podem ir para outra pasta (pendrive, por exemplo), escolhida na tela.

## Tipos e retenção

| Motivo | Quando | Retenção |
|---|---|---|
| `manual` | botão "Fazer backup agora" ou "Backup em outra pasta" | nunca apagado pelo app |
| `pre-migracao` | antes de o app atualizar o schema do banco (D-19) | 10 mais recentes |
| `pre-importacao` | antes de aplicar a importação de um save | 10 mais recentes |
| `pre-restauracao` | antes de restaurar um backup | 10 mais recentes |

## Como o backup é feito

1. Cópia consistente com `VACUUM INTO`, pela conexão aberta do app (único ponto que abre o `patrion.db`, D-24).
2. Verificação da cópia: `PRAGMA integrity_check` = `ok` e versão do schema igual à do banco. Se falhar, a cópia é apagada e o app avisa; nada muda.
3. Metadados no arquivo `.json` ao lado e em `dev_backups`: data, motivo, schema, versão do app, PC de origem, tamanho, **SHA-256** e **criptografia** (`none` na v1.0; com o banco criptografado da F5B, esse campo dirá o esquema e o arquivo de chaves).

## Restauração (tela Backup)

1. Escolha um backup da lista ou "Restaurar de um arquivo…".
2. O app confere o arquivo **antes** de pedir confirmação: banco legível e íntegro, schema que esta versão abre, identidade do Patrion, sem criptografia e, se houver o `.json`, SHA-256 igual ao do momento do backup. Um arquivo recusado não chega a ser oferecido.
3. Confirmação explícita: o diálogo mostra data, motivo, PC e versão, e o botão "Restaurar" só libera depois de marcar "Entendo que os dados atuais serão substituídos".
4. O app faz um backup `pre-restauracao` do estado atual, fecha o banco, troca o arquivo (cópia temporária na mesma pasta, conferida, e só então a troca) e abre de novo. Backup de schema antigo é migrado ao abrir (com o backup anterior à migração).
5. A identidade deste PC continua a mesma, mesmo que o backup seja de outro PC, e o relógio HLC nunca volta (D-28): alterações feitas depois da restauração vencem as que este PC já tinha exportado.
6. Se a abertura falhar, o app volta o arquivo do passo 4 e avisa.

Depois de restaurar, os dados podem estar mais antigos que os de outros PCs. Importe um save recente dos outros computadores para trazer de volta o que foi feito lá.

## Procedimento de recuperação manual

Use só se o app não abrir (por exemplo, "O Patrion não conseguiu iniciar").

1. Feche o Patrion.
2. Abra `%APPDATA%\Patrion\` no Explorador.
3. Renomeie `patrion.db` para `patrion.db.com-problema` (não apague: pode ser útil depois). Se existirem `patrion.db-journal`, `patrion.db-wal` ou `patrion.db-shm`, mova-os junto.
4. Em `backups\`, escolha o backup mais recente que você quer (o nome começa pela data UTC). Copie-o para `%APPDATA%\Patrion\` e renomeie a cópia para `patrion.db`.
5. Abra o Patrion. Se o backup for de um schema antigo, o app faz o backup anterior à migração e atualiza.
6. Se um arquivo `patrion.db.restaurando` tiver sobrado (restauração interrompida no meio da troca), ele é uma cópia conferida do backup escolhido: pode ser renomeado para `patrion.db` no passo 4.

Os logs (`%APPDATA%\Patrion\logs\patrion.log`) registram cada backup, restauração e falha, sem valores patrimoniais.

## Testes

- `test/application/backup/backup_service_test.dart`: backup manual (nome, metadados, SHA-256, integridade), outra pasta, retenção, recusas antes de restaurar (inexistente, não é banco, schema mais novo, SHA-256 alterado, criptografado) e restauração com banco em arquivo (dados do backup, backup do estado anterior, identidade e HLC mantidos, backup de outro PC).
- `test/infrastructure/backup/pre_migration_backup_test.dart`: backup antes de migrar (D-19).
- `test/presentation/sync_backup_screens_test.dart`: backup pela tela e confirmação explícita.
