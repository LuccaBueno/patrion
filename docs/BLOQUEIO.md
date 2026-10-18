# Bloqueio do app e senha do arquivo de save

Estado em 18/10/2026 (Fase 5B). SPEC §3 ("Bloqueio do app") e §10.6; decisões em DECISIONS D-24, D-32 e D-33.

O bloqueio é **opcional e por PC**: é ativado em Configurações → "Bloqueio do app". Sem ele, o app funciona como antes (banco sem criptografia).

## O que protege

- **Banco criptografado (SQLCipher 4).** Sem a chave, o `patrion.db` não abre ("file is not a database") e o conteúdo não aparece no arquivo.
- **Backups criptografados.** Com o bloqueio ativo, todo backup sai criptografado com a mesma chave. Ao ativar, os backups antigos da pasta de backups também são criptografados (opção marcada por padrão).
- **Senha na abertura.** O banco só abre depois da senha, da chave de recuperação ou do Windows Hello.
- **Bloqueio por inatividade.** Sem mouse nem teclado pelo tempo configurado (padrão 15 minutos; 1, 5, 15, 30, 60 minutos ou "nunca"), o app fecha o banco, descarta as telas e a chave e volta à tela de desbloqueio. Há também "Bloquear agora".

O que **não** protege: quem está logado na sua conta do Windows enquanto o app está desbloqueado; com o Windows Hello ativo, quem está logado na sua conta consegue ler a cópia da chave guardada pelo Windows (ver abaixo). O BitLocker continua recomendado como complemento.

## Chaves

```
<pasta de dados>\
  patrion.db            banco criptografado (SQLCipher, chave bruta de 256 bits)
  patrion.keys.json     a chave do banco "embrulhada" pela senha e pela chave de recuperação
  patrion.hello.bin     (só com o Windows Hello) a chave do banco protegida pelo DPAPI do Windows
  backups\
    patrion_..._manual_schema-v3_app-0.1.0.db         backup criptografado
    patrion_..._manual_schema-v3_app-0.1.0.db.json    metadados (encryption: sqlcipher-4, keyId)
    patrion_..._manual_schema-v3_app-0.1.0.keys.json  cópia do arquivo de chaves da época do backup
```

- A **chave do banco** é aleatória (256 bits). Ela nunca é gravada em claro.
- `patrion.keys.json` guarda duas cópias dela cifradas com AES-256-GCM: uma com a chave derivada da **senha**, outra com a chave derivada da **chave de recuperação**. Cada cópia tem sal e nonce próprios; a derivação é **Argon2id com 64 MiB, 3 passadas e paralelismo 1**, com os parâmetros gravados no arquivo. O `keyId` identifica a chave do banco.
- **Trocar a senha** só reembrulha a chave: o banco não muda, e os backups continuam abrindo.
- **Gerar nova chave de recuperação** troca só a cópia da recuperação; a chave anterior deixa de valer para o arquivo de chaves atual (mas continua valendo para as cópias `.keys.json` dos backups antigos).
- A **chave de recuperação** tem 32 caracteres em 8 grupos (`XXXX-XXXX-…`, Base32 de Crockford, 160 bits). Ela é mostrada uma única vez, ao ativar (ou ao gerar outra). Na digitação, hífens, espaços e maiúsculas/minúsculas não importam, e O/0 e I/L/1 são equivalentes.
- **Sem a senha e sem a chave de recuperação, os dados não podem ser recuperados**, nem pelo app, nem por ninguém.

## Ativar e desativar

**Ativar** (Configurações → "Ativar o bloqueio…"): senha (8 caracteres ou mais) duas vezes.

1. Gera a chave do banco, a chave de recuperação e o arquivo de chaves.
2. Faz um backup `pre-bloqueio` do banco ainda sem criptografia.
3. Fecha o banco, grava o `patrion.keys.json` e converte o banco (`sqlcipher_export` para um arquivo novo, conferido: integridade, versão do schema e contagem de registros de cada tabela). O original fica como `patrion.db.anterior` até o banco novo abrir.
4. Abre o banco criptografado; apaga o `patrion.db.anterior`.
5. Criptografa os backups antigos da pasta de backups (se marcado). Backups em outras pastas ficam como estão; a tela avisa quantos.
6. Mostra a chave de recuperação. O botão "Concluir" só libera depois de marcar "Guardei a chave de recuperação".

Se algo falhar nos passos 3 e 4, o banco anterior volta, o arquivo de chaves é apagado e o app continua sem criptografia.

**Desativar** ("Desativar o bloqueio…"): pede a senha atual, faz um backup `pre-desbloqueio` (criptografado), converte o banco para aberto, apaga o arquivo de chaves e a cópia do Windows Hello. Os backups criptografados continuam criptografados e pedem a senha da época para serem restaurados.

**Interrupções** (o app fecha no meio): ao abrir, o app olha o cabeçalho do `patrion.db`:

| Banco | Arquivo de chaves | O que o app faz |
|---|---|---|
| sem criptografia | não existe | abre normalmente |
| sem criptografia | existe | ativação interrompida antes da troca (ou desativação depois dela): o arquivo de chaves é posto de lado (`patrion.keys.json.descartado-…`) e o app abre sem criptografia |
| criptografado | existe | tela de desbloqueio |
| criptografado | não existe | não abre e explica como recuperar (abaixo) |

## Windows Hello

Opcional, por PC, e só com o bloqueio ativo (Configurações → "Desbloquear com o Windows Hello"). Ao ativar, o Windows Hello confirma o usuário e a chave do banco é gravada em `patrion.hello.bin`, protegida pelo DPAPI da sua conta do Windows. Na tela de desbloqueio, "Usar o Windows Hello" pede o rosto, a digital ou o PIN e só então lê essa cópia.

- Protege contra quem copia a pasta de dados para outro PC ou outra conta: lá o DPAPI não abre o arquivo.
- **Não** protege contra quem já está logado na sua conta do Windows: o DPAPI abre o arquivo sem pedir o Hello. A tela de Configurações mostra essa limitação.
- A senha continua valendo. Se o Windows Hello não estiver configurado no PC, a opção fica desativada.

## Senha do arquivo de save

Ao salvar um save, o app pergunta se o arquivo deve ser protegido por senha (marcado por padrão com o bloqueio ativo). A senha é do arquivo, não do PC: o outro computador precisa dela para importar.

```
Patrion_PC_2026-10-18_1530.invsave   (ZIP)
  manifest.json      versão, PC de origem, data e os parâmetros da criptografia (sem contagens nem dados)
  manifest.sha256
  payload.bin        o save original inteiro, cifrado com AES-256-GCM (chave Argon2id da senha)
```

- O manifesto de fora diz `encryption.scheme = "aes-256-gcm"`, com `kdf` (Argon2id, 64 MiB, 3 passadas, sal) e `nonce`. Dentro do `payload.bin` está o save comum, validado como sempre depois de decifrado.
- Senha errada ou arquivo alterado: "Senha do arquivo incorreta, ou o arquivo foi alterado. Nada foi importado." (o AES-GCM não distingue os dois casos).
- "Importar e gerar novo save" oferece usar a mesma senha do arquivo importado no save de volta.
- A versão da F5 lê o manifesto de fora e recusa o arquivo dizendo que ele é protegido por senha.

## Recuperação manual

**Esqueci a senha:** na tela de desbloqueio, "Esqueci a senha" → chave de recuperação e nova senha.

**O app diz que o arquivo de chaves não está na pasta de dados:** o `patrion.keys.json` foi apagado ou movido. Se ele não puder ser recuperado:

1. Feche o Patrion.
2. Na pasta `backups\`, pegue o `.keys.json` de um backup recente **feito com o bloqueio atual** (o `keyId` dentro dele é igual ao do `.json` de metadados do backup e ao do banco atual: os backups feitos depois da última ativação servem).
3. Copie-o para a pasta de dados com o nome `patrion.keys.json` e abra o app. A senha ou a chave de recuperação são as que valiam quando aquele backup foi feito.

**Restaurar um backup manualmente** (o app não abre): siga `BACKUP.md`. Um backup criptografado só serve com o arquivo de chaves do mesmo `keyId`: copie também o `.keys.json` dele para a pasta de dados como `patrion.keys.json`.

## Testes

- `test/presentation/session/app_lock_test.dart` (testes obrigatórios de SPEC §3, com banco em arquivo e o SQLCipher de verdade): banco ilegível sem a chave; senha errada recusada; troca de senha sem perda de dados; recuperação pela chave; bloqueio fecha o banco e zera a chave; backup criptografado restaurável (inclusive de uma chave anterior, com a senha da época, e backup aberto restaurado com o bloqueio ativo); backups antigos criptografados ao ativar; desativar; Windows Hello (com dublê); interrupções ao abrir; migração de schema 2 → 3 com o banco criptografado.
- `test/domain/security/key_file_test.dart`: arquivo de chaves com os parâmetros de produção, AAD, arquivo alterado, troca de senha, formato da chave de recuperação, AES-GCM.
- `test/infrastructure/security/hello_vault_test.dart`: DPAPI real.
- `test/presentation/security_screens_test.dart`: inatividade (com relógio falso), tela de desbloqueio, seção das Configurações e diálogo da chave de recuperação.
- `test/application/sync/save_sync_test.dart` e `test/presentation/sync_backup_screens_test.dart`: save com senha (ida e volta, senha errada, byte alterado, conteúdo ilegível, parâmetros de produção, pela interface).
