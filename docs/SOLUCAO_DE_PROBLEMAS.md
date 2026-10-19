# Solução de problemas

## Instalação

**"O Windows protegeu o computador" (SmartScreen).** O instalador não é assinado digitalmente (`DISTRIBUICAO.md`). Clique em "Mais informações" e "Executar assim mesmo". Se quiser, confira antes a soma SHA-256 com a do `SHA256SUMS.txt` da Release.

**O instalador diz que o Patrion está aberto.** Feche o app (inclusive outra cópia portátil aberta) e clique em "Tentar novamente". O instalador não fecha o app à força para não interromper uma gravação.

**O app não abre depois de instalar, sem mensagem.** Veja o log em `%APPDATA%\Patrion\logs\patrion.log`. Se o log não existir, rode `patrion.exe` pelo PowerShell para ver a mensagem. O app leva o runtime do Visual C++; se faltar algum `vcruntime140*.dll` ou `msvcp140*.dll` na pasta de instalação, reinstale.

**Quero instalar para todos os usuários.** No primeiro diálogo do instalador, escolha "Instalar para todos os usuários" (pede administrador). Os dados continuam por usuário, em `%APPDATA%\Patrion`.

## Arquivos `.invsave`

**Dois cliques no `.invsave` não abrem o Patrion.** A associação é uma tarefa do instalador (marcada por padrão). Se outro programa já tiver sido escolhido, o Windows mantém a escolha: botão direito > "Abrir com" > "Escolher outro aplicativo" > Patrion > "Sempre". Na versão portátil não há associação: use Sincronização > "Importar save".

**Cliquei no `.invsave` e nada aconteceu.** Se o app já estava aberto, a janela existente vem para a frente com a prévia; se o Windows não deixou trazê-la para a frente, ela pisca na barra de tarefas. Com o bloqueio ativo, a prévia aparece depois do desbloqueio.

**Abri o app duas vezes e só apareceu uma janela.** É o esperado: uma janela por pasta de dados, para que duas cópias não gravem no mesmo banco. Para duas pastas ao mesmo tempo, use `--data-dir` diferentes.

## Atualizações

**"Verificar agora" diz "Sem conexão".** O app consulta `api.github.com`; confira a internet, um proxy ou firewall. Nada mais depende disso.

**"O GitHub limitou as consultas deste computador".** A API pública permite 60 consultas por hora por endereço IP (somadas a outros programas na mesma rede). Espere e tente mais tarde.

**Ignorei uma versão por engano.** Configurações > Atualizações > "Voltar a avisar".

## Dados

**Desinstalei e quero apagar os dados de vez.** Apague `%APPDATA%\Patrion` e `%LOCALAPPDATA%\Patrion`. Não há como recuperar depois; faça antes um backup ou um save.

**Reinstalei e a carteira sumiu.** A desinstalação não apaga os dados; confira se o app está usando a mesma pasta (Configurações > "Dados deste computador") e se ele foi aberto com `--data-dir`. Para voltar a um estado anterior, veja `BACKUP.md`.

**O app abriu com "O Patrion não conseguiu iniciar".** A mensagem e o log (`%APPDATA%\Patrion\logs\`) dizem o motivo. Para um banco danificado ou um backup a restaurar, veja o procedimento de recuperação em `BACKUP.md`; para o bloqueio, `BLOQUEIO.md`.
