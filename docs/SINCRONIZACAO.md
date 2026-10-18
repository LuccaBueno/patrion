# Sincronização

Estado em 18/10/2026 (Fase 5B). A sincronização entre computadores funciona pelo **arquivo de save** (`.invsave`, SPEC §10), sem servidor: um PC exporta, o outro importa e mescla. O arquivo pode ser protegido por senha (§10.6, desde a F5B; detalhes em `BLOQUEIO.md`).

## Identidade dos registros

- `id`: UUID v7 gerado no app (`core/ids/id_generator.dart`), texto minúsculo com hífens. Nunca autoincremento.
- `device_id`: UUID v7 criado na primeira execução e guardado em `dev_identity`. Identifica o PC como autor das alterações. Não vai no save como configuração (o manifesto leva o id e o nome do PC de origem).

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

**Importação de um save** (`HlcClock.receive`): antes de gravar, o relógio local avança para depois do maior HLC recebido. Um PC com relógio adiantado "puxa" o outro para a frente, e as próximas alterações locais continuam vencendo as anteriores, mesmo com o relógio atrasado (caso S6).

**Persistência:** o último HLC emitido ou recebido fica em `dev_identity.last_hlc`, gravado na mesma transação de cada escrita. Ao reabrir o app, o relógio continua dali, mesmo que o relógio do Windows tenha voltado. Ao restaurar um backup, o último HLC nunca volta (DECISIONS D-28).

## Campos de sincronização e repositório base

Toda tabela sincronizável usa o mixin `SyncColumns` (`data/db/tables.dart`) e tem índice em `hlc`. As escritas do app passam por `SyncRepository` (`data/repositories/sync_repository.dart`):

| Operação | O que o repositório faz |
|---|---|
| `insertRow` | gera `id`; preenche `created_at` = `updated_at` = agora (UTC), `hlc` novo, `device_id` deste PC, `deleted_at` nulo |
| `updateRow` | recusa registro inexistente ou excluído; atualiza `updated_at`, `hlc` e `device_id`; preserva `id` e `created_at` |
| `softDelete` | grava `deleted_at` (tombstone) e avança `hlc`; a linha nunca é apagada |
| consultas | `findRowById` e `selectAlive` ignoram tombstones; `allRowsIncludingDeleted` traz tudo em ordem de HLC |

A única outra escrita em tabelas sincronizáveis é a da mesclagem (`data/sync/sync_tables_gateway.dart`): ela grava as linhas recebidas exatamente como vieram (com o HLC do autor) e carimba com o HLC deste PC só o que ela mesma altera.

Chaves naturais (ex.: ticker + mercado + classe) são aplicadas pelo repositório e pelos serviços, não por índice único, porque dois PCs podem criar a mesma entidade com ids diferentes e a mesclagem precisa recebê-las antes de unificar.

## O arquivo de save

Um ZIP com extensão `.invsave` (codec em `domain/sync/invsave_codec.dart`):

```
manifest.json          manifesto
manifest.sha256        SHA-256 do manifest.json
data/<tabela>.jsonl    um registro por linha, inclusive tombstones
```

**Manifesto** (`domain/sync/save_manifest.dart`):

| Campo | Conteúdo |
|---|---|
| `format`, `formatVersion` | `patrion-invsave`, versão 1 do formato do arquivo |
| `appVersion`, `schemaVersion` | versão do app e do schema do banco que gerou o save |
| `device` | `id` e `name` do PC de origem |
| `createdAt` | instante UTC |
| `maxHlc` | maior HLC entre os registros |
| `counts` | registros por tabela |
| `files` | SHA-256 de cada `data/<tabela>.jsonl` |
| `knownPeers` | para cada PC do qual o autor já importou saves, o maior HLC recebido dele (base da detecção de conflitos) |
| `encryption` | `{"scheme": "none"}` no save sem senha. No save protegido, `{"scheme": "aes-256-gcm", "kdf": {...}, "nonce": ..., "payload": "payload.bin"}` (DECISIONS D-32, abaixo) |
| `market` | `{"included": false}`. A pasta `market/` com dados de mercado entra quando existirem dados de mercado no banco (F6) |

**O que vai:** todas as tabelas sincronizáveis (as que têm os campos de sincronização), descobertas pelo próprio banco: cadastros, operações, preços informados, configurações compartilhadas, `asset_aliases` e as tabelas hipotéticas. Uma tabela nova entra no save sem código extra.

**O que não vai:** tabelas `dev_` (identidade, configurações do dispositivo, histórico, backups), dados derivados, logs e chaves de API.

**Senha do arquivo (F5B).** Ao salvar, o app pergunta se o arquivo deve ser protegido por senha (marcado por padrão com o bloqueio do app ativo). O save protegido é um ZIP com `manifest.json` (só versões, PC de origem, data e os parâmetros da criptografia; sem contagens nem dados), `manifest.sha256` e `payload.bin`: o save comum inteiro, cifrado com AES-256-GCM e chave Argon2id (64 MiB, 3 passadas) derivada da senha. Ao importar, o app pede a senha, decifra e valida o save de dentro como sempre; o manifesto de dentro precisa bater com o de fora. Sem senha, quem tiver o arquivo lê a carteira; a tela avisa.

### Validação na importação

Antes de qualquer alteração, o arquivo inteiro é recusado se:

- não for um ZIP legível ou não tiver manifesto;
- o SHA-256 do manifesto ou de qualquer tabela não bater;
- houver arquivo não declarado, tabela ausente, contagem diferente da do manifesto ou HLC máximo diferente;
- o formato for mais novo que o conhecido ou o schema for mais novo que o do app;
- o save for protegido por senha e a senha estiver errada (ou o conteúdo cifrado tiver sido alterado: o AES-GCM recusa os dois);
- uma linha tiver colunas diferentes das da tabela, id repetido ou HLC inválido;
- um registro referenciar outro que não existe nem no banco nem no arquivo.

Um byte alterado no conteúdo de qualquer arquivo é recusado. Bytes que não carregam conteúdo (datas e campos de cabeçalho do ZIP, bits de preenchimento do deflate) não mudam os dados; o teste S8 confere, byte a byte, que nenhum deles produz uma importação diferente da original.

**Schema mais antigo:** convertido na importação (`domain/sync/save_contents.dart`), passo a passo. As versões 2 e 3 só criaram tabelas, então hoje a conversão só considera vazias as tabelas que não existiam.

## Mesclagem

Planejada em Dart puro (`domain/sync/merge_planner.dart`), sem ler nem gravar nada; o serviço (`application/sync/save_service.dart`) lê o banco, mostra a prévia e aplica.

1. **Por `id`.** Registro só de um lado é mantido ou adicionado. Dos dois lados, vence o maior `hlc` (o texto do HLC desempata pelo `device_id`). Tombstones se propagam como qualquer alteração.
2. **Conflitos.** É conflito quando o mesmo registro mudou nos dois PCs desde a última troca entre eles e as versões diferem. "Desde a última troca" usa dois HLCs (DECISIONS D-29):
   - do lado local, a alteração é desconhecida do autor do save se o HLC dela for maior que o maior HLC deste PC que o autor já tinha recebido (vem em `knownPeers` do manifesto e fica em `dev_sync_peers.last_hlc_sent`);
   - do lado recebido, a alteração é nova para este PC se o HLC dela for maior que o do último save importado desse autor (`dev_sync_peers.last_hlc_received`).

   O padrão é a versão de maior HLC (a mais recente). Se o usuário escolher a outra na prévia, ela é regravada como alteração local, com HLC novo, para vencer nos dois PCs.
3. **Aliases.** Referências a registros absorvidos (`asset_aliases`) são remapeadas para o registro que permaneceu, seguindo cadeias (a → b → c). Um registro absorvido que chegue vivo de um save antigo é dobrado no que permaneceu (se for mais recente, os dados dele passam para lá) e volta a ser tombstone: nada ressuscita.
4. **Chave natural.** Registros vivos com a mesma chave são unificados: instituição (nome normalizado), conta (instituição + nome normalizado), ativo (código + mercado + classe), características de renda fixa (ativo) e configuração compartilhada (chave). Fica o de **menor `id`** (o mesmo nos dois PCs); o outro recebe tombstone, vira alias e as referências são remapeadas.
5. **Possíveis duplicatas** de operações: mesma data, ativo, tipo, quantidade e preço (para movimentos só de caixa, também conta e valor), com pelo menos uma chegando agora. Só sinalizadas, nunca apagadas.

Toda alteração feita pela própria mesclagem (remapear, unificar, escolher a versão mais antiga) é uma alteração local, com o HLC deste PC. Assim, depois de A→B e B→A, os dois bancos ficam **idênticos, inclusive nos HLCs**.

**Propriedades** (todas com teste):

- Idempotência: importar o mesmo arquivo de novo produz uma prévia vazia.
- Nada se desfaz: um save antigo não muda nada.
- Convergência: depois de A→B e B→A, os dois PCs ficam iguais.
- Relógios: a mesclagem funciona com relógios dessincronizados (HLC).
- Separação: carteiras hipotéticas chegam nas tabelas `hypo_` e não mudam a carteira real.

### Aplicação

1. Validação e prévia (nada é alterado). A prévia também confere a **carteira resultante**: aplica o plano numa transação que é sempre desfeita, recalcula a carteira e compara as inconsistências com as de antes. As novas (por exemplo, uma venda maior que a posição depois de vendas feitas nos dois PCs) aparecem num aviso antes de aplicar, com ativo, conta e data. O aviso não bloqueia, e é recalculado quando o usuário troca a versão de um conflito. Essa conferência não avança o relógio HLC.
2. Ao confirmar: backup automático do banco (`pre-importacao`, SPEC §11).
3. Numa única transação: o relógio avança para depois do maior HLC recebido, o plano é recalculado com o banco de agora e as escolhas dos conflitos, as linhas são gravadas (chaves estrangeiras conferidas só no fim, `defer_foreign_keys`) e `dev_sync_peers` é atualizado. Se algo falhar, nada é alterado (S9).
4. As telas recalculam posições e totais na hora (as escritas avisam as consultas observadas).
5. O histórico (`dev_sync_history`) registra a importação, com sucesso ou falha, só com contagens.

### Fluxo de uso (SPEC §10.5)

1. PC A: "Salvar arquivo de save".
2. PC B: "Importar e gerar novo save" (mescla e já grava o save de volta).
3. PC A: "Importar save" com o arquivo gerado no PC B.

A tela Sincronização lista os computadores com quem este PC já trocou saves e o histórico. O Início avisa, sem bloquear, quando a última importação de algum PC tem 7 dias ou mais.

## Testes

- `test/application/sync/save_sync_test.dart`: casos S1 a S10 de `CASOS_DE_TESTE.md` §9 e os itens de SPEC §10.7 (ida e volta, idempotência, convergência, conflito, exclusão, arquivo antigo, arquivo corrompido, schema mais novo e mais antigo, mesmo ativo com UUIDs diferentes, rollback, relógio adiantado, real × hipotético), com dois "PCs" em memória (`test/helpers/sync_pc.dart`).
- `test/domain/sync/merge_planner_test.dart` e `invsave_codec_test.dart`: regras da mesclagem e formato do arquivo.
- `test/application/sync/save_sync_test.dart` também cobre a conferência da carteira resultante na prévia e a senha do arquivo.
- `test/presentation/sync_backup_screens_test.dart`: exportar, prévia com conflito, aviso de carteira inconsistente, save com senha, arquivo recusado e aviso no Início.
- `test/core/sync/hlc_test.dart`, `test/data/repositories/sync_repository_test.dart`, `test/data/sync/device_identity_test.dart`: HLC, repositório base e identidade.
