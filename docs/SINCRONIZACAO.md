# Sincronização

Estado em 17/10/2026 (Fase 2). A **infraestrutura** de sincronização existe: identidade dos registros, HLC, `device_id`, tombstones e repositório base. O **arquivo de save** (`.invsave`, exportar, importar e mesclar, SPEC §10) chega na F5.

## Identidade dos registros

- `id`: UUID v7 gerado no app (`core/ids/id_generator.dart`), texto minúsculo com hífens. Nunca autoincremento.
- `device_id`: UUID v7 criado na primeira execução e guardado em `dev_identity`. Identifica o PC como autor das alterações. Não vai no save como configuração.

## Hybrid Logical Clock (HLC)

Implementação: `core/sync/hlc.dart`. Formato em texto (DECISIONS D-10):

```
001760722200000-00007-0192a2b3-....-device_id
└──── ms UTC ──┘ └cont┘ └──── device_id ────┘
```

O texto ordena igual ao HLC: primeiro pelo instante, depois pelo contador e, no empate, pelo `device_id`.

**Alteração local** (`HlcClock.send`):

- Se o relógio do PC passou do último HLC, o novo HLC usa o relógio e contador 0.
- Se não (mesmo milissegundo, ou relógio do PC voltou no tempo), mantém o instante do último HLC e soma 1 no contador.
- Se o contador passar de 99999, avança 1 ms e zera o contador. A ordem continua estrita.

**Registro recebido de outro PC** (`HlcClock.receive`, usado na importação do save na F5):

- O novo HLC local fica maior que o local anterior e que o remoto. Um PC com relógio adiantado "puxa" o outro para a frente, e as próximas alterações locais continuam vencendo as anteriores, mesmo com o relógio atrasado.

**Persistência:** o último HLC emitido ou recebido fica em `dev_identity.last_hlc`, gravado na mesma transação de cada escrita. Ao reabrir o app, o relógio continua dali, mesmo que o relógio do Windows tenha voltado.

## Campos de sincronização e repositório base

Toda tabela sincronizável usa o mixin `SyncColumns` (`data/db/tables.dart`) e tem índice em `hlc`. As escritas passam por `SyncRepository` (`data/repositories/sync_repository.dart`):

| Operação | O que o repositório faz |
|---|---|
| `insertRow` | gera `id`; preenche `created_at` = `updated_at` = agora (UTC), `hlc` novo, `device_id` deste PC, `deleted_at` nulo |
| `updateRow` | recusa registro inexistente ou excluído; atualiza `updated_at`, `hlc` e `device_id`; preserva `id` e `created_at` |
| `softDelete` | grava `deleted_at` (tombstone) e avança `hlc`; a linha nunca é apagada |
| consultas | `findRowById` e `selectAlive` ignoram tombstones; `allRowsIncludingDeleted` traz tudo em ordem de HLC (base da exportação) |

Valores que quem chama tentar colocar nos campos de sincronização são ignorados. Cada escrita roda em transação: se falhar, nem o registro nem o último HLC são gravados.

Chaves naturais (ex.: `shared_settings.key`) são aplicadas pelo repositório da tabela, não por índice único, porque dois PCs podem criar a mesma entidade com ids diferentes e a mesclagem precisa recebê-las antes de unificar (SPEC §10.4).

## Testes

- `test/core/sync/hlc_test.dart`: formato, ordem, relógio voltando, estouro do contador, recepção de HLC adiantado/atrasado e dois PCs com relógios dessincronizados.
- `test/data/repositories/sync_repository_test.dart`: preenchimento dos campos, tombstone sem exclusão física, HLC crescente com o relógio voltando, rollback.
- `test/data/sync/device_identity_test.dart`: `device_id` e HLC sobrevivem ao reinício do app com o relógio atrasado.
