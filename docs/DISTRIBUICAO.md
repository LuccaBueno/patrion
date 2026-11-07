# Distribuição

Como o Patrion é empacotado, publicado, instalado, atualizado e removido (SPEC §19; DECISIONS D-06, D-07, D-38 a D-40).

## O que vai em cada Release

| Arquivo | Conteúdo |
|---|---|
| `Patrion-X.Y.Z-instalador.exe` | Instalador do Inno Setup 6 |
| `Patrion-X.Y.Z-portatil.zip` | Pasta `Patrion\` com o app e um `LEIA-ME.txt` |
| `SHA256SUMS.txt` | Somas SHA-256 dos dois arquivos |
| `SHA256SUMS.txt.minisig` | Assinatura das somas (só na Release, feita pelo workflow; D-62) |
| Notas | Seção da versão no `CHANGELOG.md` + requisitos, instalação, atualização e desinstalação (`installer/RELEASE_TEMPLATE.md`) |

**Avisos de terceiros:** `AVISOS_DE_TERCEIROS.txt` vai junto do app (instalador e ZIP). Os textos das licenças do SQLCipher (BSD-3) e do OpenSSL (Apache-2.0, embutido no `sqlcipher.dll`) ficam em `assets/licenses/` e aparecem em Configurações > Sobre > "Licenças de terceiros", junto das licenças do Flutter e dos pacotes Dart (que o Flutter reúne sozinho em `NOTICES.Z`).

O pacote leva o runtime do Visual C++ (`vcruntime140*.dll`, `msvcp140*.dll`), copiado pelo CMake (`InstallRequiredSystemLibraries`): o app abre num Windows sem o "Visual C++ Redistributable". O UCRT já faz parte do Windows 10 e 11.

## Instalador

- **Por usuário**, em `%LOCALAPPDATA%\Programs\Patrion`, sem pedir administrador. No primeiro diálogo dá para escolher "para todos os usuários" (Program Files, pede UAC).
- Atalho no Menu Iniciar; atalho na área de trabalho opcional (desmarcado).
- Tarefa "Abrir arquivos de save (.invsave) com o Patrion" (marcada): grava `Software\Classes\.invsave` e `Patrion.Save` em HKCU (ou HKLM, para todos), com o comando `"...\patrion.exe" "%1"`. A desinstalação remove essas chaves.
- **Versão identificada** em "Aplicativos instalados" (nome, versão, editor) e no recurso de versão do `.exe`.
- **Atualização por cima:** o `AppId` é fixo (`{5A345516-F4A3-4E8D-B057-50475B9F06F9}`), então a nova versão instala na mesma pasta. Antes de copiar, o instalador apaga só `{app}\data` (os assets da versão anterior, que são do app, não do usuário).
- **App aberto:** o app cria o mutex `PatrionAppMutex`; o instalador e o desinstalador pedem para fechá-lo e não continuam enquanto ele estiver aberto (não fecham à força). Em modo silencioso, o instalador sai com erro.
- **Desinstalação não apaga os dados.** O script não tem `[UninstallDelete]`; no fim, uma mensagem mostra onde os dados ficaram. Um teste (`test/installer_test.dart`) impede que essas regras regridam.

## Onde ficam os dados

| Pasta | Conteúdo | Atualização | Desinstalação |
|---|---|---|---|
| `%LOCALAPPDATA%\Programs\Patrion\` | App | Substituída | Removida |
| `%APPDATA%\Patrion\` | Banco (`patrion.db`), `backups\`, `logs\`, chaves, `instance\` | Intocada | **Mantida** |
| `%LOCALAPPDATA%\Patrion\cache\` | Arquivos baixados, descartáveis | Intocada | Mantida (pode apagar) |

Para apagar tudo de vez, depois de desinstalar: apague `%APPDATA%\Patrion` e `%LOCALAPPDATA%\Patrion`. Faça antes um backup ou um save se quiser guardar a carteira.

## Versão portátil

O ZIP tem a pasta `Patrion\` com o app e um `LEIA-ME.txt`. Não instala nada: sem atalho, sem entrada em "Aplicativos instalados", sem associação do `.invsave`. Usa as **mesmas pastas de dados** da versão instalada (`%APPDATA%\Patrion`); para outra pasta, use um atalho com `--data-dir` e `--cache-dir`. A instância única vale entre a portátil e a instalada (mesma pasta de dados = uma janela só).

## `.invsave` e instância única

- Duplo clique num `.invsave` abre o Patrion em Configurações > Sincronização com a prévia da importação. Nada é aplicado sem "Aplicar". Com o bloqueio ativo, a prévia aparece depois do desbloqueio.
- Uma instância por pasta de dados: a primeira trava `instance\patrion.lock`; a segunda grava o pedido em `instance\inbox\`, autoriza a primeira a tomar o foco e sai. A primeira lê o pedido, traz a janela para a frente e abre o arquivo. Pastas diferentes (`--data-dir`) abrem ao mesmo tempo.
- Se outro programa já tiver sido escolhido no Windows para `.invsave`, o Windows mantém a escolha do usuário: use "Abrir com" > Patrion > "Sempre".

## Verificador de atualizações

- Configurações > Sobre > Atualizações: "Verificar ao abrir o app" (ligado; no máximo uma vez a cada 24 horas), "Incluir versões de teste (beta e rc)" (desligado) e "Verificar agora" (no máximo uma vez por minuto).
- Consulta `https://api.github.com/repos/LuccaBueno/patrion/releases/latest` (ou `/releases`, com as versões de teste), sem token. A requisição leva só `User-Agent: Patrion/<versão>`; nada da carteira. O repositório fica só em `AppInfo.releasesRepository`.
- Compara pelo SemVer (`pub_semver`). Uma versão mais nova aparece com as notas, a data e o botão "Abrir página de download" (só abre páginas do próprio repositório no GitHub); "Ignorar esta versão" tira o aviso do Painel até sair outra.
- Sem internet, a consulta automática falha em silêncio e tenta na próxima abertura; "Verificar agora" mostra "Sem conexão".
- **"Atualizar agora"** (M-14; DECISIONS D-62): em Sobre e no aviso do Painel, baixa, confere a assinatura e o SHA-256, faz um backup `pre-atualizacao`, instala em modo silencioso e reabre o app. O log do instalador fica em `logs\atualizacao-<versão>.log`. Opção "Baixar em segundo plano e instalar ao fechar o app" (desligada).
- **Versão portátil e build de desenvolvimento:** sem o arquivo `patrion.instalado` ao lado do `.exe`, não há o botão; a tela explica e leva à página de download.
- **Da 1.4.1 para a 1.5.0, a atualização é manual:** o atualizador só existe a partir da 1.5.0.

## Assinatura de código e SmartScreen

O instalador e o app não têm certificado de assinatura de código (a assinatura das atualizações, abaixo, é outra coisa: só o app a confere). Na primeira execução o Windows SmartScreen mostra "O Windows protegeu o computador": clique em **Mais informações** e **Executar assim mesmo**. A assinatura exige certificado pago (opção futura). As somas SHA-256 sozinhas detectam um download corrompido, mas, publicadas no mesmo lugar do arquivo, não protegem contra adulteração.

## Assinatura das atualizações

O app só instala uma versão se o `SHA256SUMS.txt` tiver uma assinatura válida da chave embutida (DECISIONS D-62). Esta é a conferência que o botão "Atualizar agora" depende.

### Configurar a chave (uma vez)

1. Gere a chave, numa pasta **fora do repositório**. O comando imprime só a chave pública:

   ```powershell
   cd tool\signing; dart pub get; dart run bin\generate_key.dart C:\caminho\patrion-update-key.txt
   ```

2. Grave o segredo no ambiente `release` do GitHub:

   ```powershell
   Get-Content C:\caminho\patrion-update-key.txt -Raw | gh secret set PATRION_UPDATE_SIGNING_KEY --env release
   ```

3. Ponha a chave pública em `AppInfo.updatePublicKeys` (`lib/core/config/app_info.dart`).
4. Guarde o arquivo da chave **fora do PC** (gerenciador de senhas ou pendrive criptografado), como a chave de recuperação, e apague-o do PC. O GitHub não deixa ler o segredo de volta.

### Ambiente `release`

Criado no repositório com aprovação manual e só para tags `v*`. Cada tag para no job `sign` até a aprovação em Actions.

### Conferir uma Release por fora do app

Com o [minisign](https://jedisct1.github.io/minisign/) e a chave pública de `AppInfo.updatePublicKeys`:

```powershell
minisign -Vm SHA256SUMS.txt -P <chave pública>
```

### Chave perdida ou vazada

Gerar outra chave, publicar uma versão com a pública nova e instalá-la **manualmente** nos PCs. Os passos estão em DECISIONS D-62.

## Gerar uma Release

### No PC (para testar)

```powershell
powershell -ExecutionPolicy Bypass -File tool\release\build_release.ps1
```

Gera `dist\` com o instalador, o ZIP, `SHA256SUMS.txt` e `RELEASE_NOTES.md`. Usa o Inno Setup de `%LOCALAPPDATA%\Programs\Inno Setup 6`, de Program Files, do `PATH` ou de `$env:ISCC`. `-SkipBuild` reaproveita o build existente; `-Version 0.9.0` gera um instalador com outra versão (só para testar a atualização).

### Publicar (só com autorização do usuário)

1. `CHANGELOG.md` com a seção `## [X.Y.Z] - AAAA-MM-DD` (as notas saem dela) e `version: X.Y.Z+N` no `pubspec.yaml` (um teste confere `AppInfo.version`).
2. Commit, push e CI verde.
3. `git tag vX.Y.Z` e `git push origin vX.Y.Z`.
4. O workflow `Release` (`.github/workflows/release.yml`) confere a tag com o `pubspec.yaml`, roda formatação, análise e testes, instala o Inno Setup se preciso e gera os arquivos.
5. Aprovar o job `sign` em Actions (ambiente `release`). Ele assina as somas e cria a **Release em rascunho**. Tags com `-beta` ou `-rc` viram pré-lançamento.
6. Revisar o rascunho no GitHub e publicar.

"Run workflow" no workflow `Release` faz um ensaio: gera os arquivos e guarda como artefato do workflow por 7 dias, sem criar Release.

## Testes de distribuição

### Automático

`tool\release\test_install.ps1` instala a versão antiga, abre o app, abre uma segunda instância com um `.invsave`, tenta atualizar com o app aberto, atualiza por cima, abre a nova versão e desinstala, conferindo em cada passo arquivos, atalho, versão registrada, associação e dados (26 verificações).

- No PC de desenvolvimento, com pastas de teste (não toca nos dados reais):

  ```powershell
  .\tool\release\test_install.ps1 -OldInstaller <0.9.0.exe> -NewInstaller dist\Patrion-1.0.0-instalador.exe `
    -WorkDir C:\temp\teste -DataDir C:\temp\teste\dados -InstallDir C:\temp\teste\app
  ```

- No **Windows Sandbox** (Windows limpo, descartável): `tool\release\sandbox_test.ps1` gera o instalador 0.9.0 de teste, abre o Sandbox e roda o teste na pasta de dados padrão, abrindo o `.invsave` pela associação (como num duplo clique). Resultado em `dist\sandbox\trabalho\resultado.txt`. Precisa do recurso "Área Restrita do Windows" ligado.

### Manual (roteiro)

Feito no Windows Sandbox ou num PC sem Flutter, depois do teste automático ou no lugar dele:

1. **Instalar e abrir.** Execute `Patrion-1.4.1-instalador.exe` com dois cliques. Confira o aviso do SmartScreen ("Mais informações" > "Executar assim mesmo"), a instalação sem pedido de administrador, o atalho no Menu Iniciar e o app abrindo no fim.
2. **Registrar uma operação.** Carteira > "Adicionar ativo": um ticker (ex.: "bbas3"), a quantidade e o preço. O ativo aparece na lista; na janela padrão (1280 px), a valorização e "Detalhes" aparecem sem rolar para o lado.
3. **Carteira hipotética:** chega na Fase 9 (SPEC §21); pule por enquanto.
4. **Fechar e reabrir.** Os dados continuam.
5. **Usar offline.** Desligue a rede (no Sandbox: `<Networking>Disable</Networking>` no `.wsb`, ou desconecte o adaptador). Abra o app: aviso "Sem conexão", dados guardados com as datas; Configurações > Sobre > Atualizações > "Verificar agora" mostra "Sem conexão" sem travar.
6. **Save entre duas instalações.** Sincronizar (rodapé do menu) > "Salvar arquivo de save". Leve o arquivo para outra instalação (outro PC, outro Sandbox ou `--data-dir` diferente) e dê **dois cliques** nele: o Patrion abre em Configurações > Sincronização com a prévia; "Aplicar" importa. Com o app já aberto, dois cliques no arquivo trazem a janela existente para a frente com a prévia.
7. **Atualizar de versão.** Com o app aberto, execute o instalador de novo (ou o de uma versão mais nova): ele pede para fechar o app. Feche e continue. Os dados, as configurações e os backups continuam; Configurações > Sobre mostra a versão nova.
8. **Desinstalar sem perder dados.** "Aplicativos instalados" > Patrion > Desinstalar. A mensagem final mostra a pasta dos dados. Confira que `%APPDATA%\Patrion` continua com `patrion.db`, `backups\` e `logs\`, que o atalho sumiu e que o `.invsave` deixou de abrir com o Patrion. Reinstale: a carteira volta como estava.
