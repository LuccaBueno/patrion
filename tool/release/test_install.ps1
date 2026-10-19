<#
.SYNOPSIS
  Testa instalação, atualização por cima e desinstalação do Patrion sem
  perder dados (SPEC §19, "Testes de distribuição").

.DESCRIPTION
  1. Instala a versão antiga (silenciosa) e confere arquivos, atalho,
     versão registrada e associação do .invsave.
  2. Abre o app e espera o banco ser criado.
  3. Abre uma segunda instância com um .invsave: ela deve entregar o arquivo
     à janela aberta e sair.
  4. Com o app aberto, a atualização silenciosa deve recusar (AppMutex).
  5. Fecha o app, atualiza por cima e confere versão, pasta e dados intactos.
  6. Abre a nova versão.
  7. Desinstala e confere: app, atalho e associação removidos; dados
     intactos.

  Sem -DataDir, usa a pasta padrão (%APPDATA%\Patrion) e abre o .invsave
  pela associação, como num duplo clique: é o modo para o Windows Sandbox ou
  um PC sem o Patrion. Com -DataDir, o app usa só a pasta de teste.

.EXAMPLE
  .\test_install.ps1 -OldInstaller .\Patrion-0.9.0-instalador.exe `
    -NewInstaller .\Patrion-1.0.0-instalador.exe -WorkDir C:\teste
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string]$OldInstaller,
  [Parameter(Mandatory)] [string]$NewInstaller,
  [Parameter(Mandatory)] [string]$WorkDir,
  [string]$DataDir,
  [string]$InstallDir
)

$ErrorActionPreference = 'Stop'
$appId = '{5A345516-F4A3-4E8D-B057-50475B9F06F9}_is1'
$uninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$appId"
$results = New-Object System.Collections.Generic.List[object]

New-Item -ItemType Directory -Force $WorkDir | Out-Null
$WorkDir = (Resolve-Path $WorkDir).Path
$OldInstaller = (Resolve-Path $OldInstaller).Path
$NewInstaller = (Resolve-Path $NewInstaller).Path
$defaultData = -not $DataDir
if ($defaultData) { $DataDir = Join-Path $env:APPDATA 'Patrion' }
if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA 'Programs\Patrion' }
$exe = Join-Path $InstallDir 'patrion.exe'
$db = Join-Path $DataDir 'patrion.db'
$shortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Patrion.lnk'

function Check([string]$name, [bool]$ok, [string]$detail = '') {
  $results.Add([pscustomobject]@{ Teste = $name; Ok = $ok; Detalhe = $detail })
  $mark = if ($ok) { 'OK  ' } else { 'FALHOU' }
  Write-Host ("[{0}] {1} {2}" -f $mark, $name, $detail)
}

function Version-Of([string]$installer) {
  if ((Split-Path $installer -Leaf) -match 'Patrion-(.+)-instalador\.exe') { return $Matches[1] }
  throw "Nome de instalador inesperado: $installer"
}

function Install([string]$installer, [string]$log) {
  $argv = @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/CURRENTUSER',
    '/TASKS=assocsave', "/DIR=`"$InstallDir`"", "/LOG=`"$log`"")
  $p = Start-Process -FilePath $installer -ArgumentList $argv -Wait -PassThru
  return $p.ExitCode
}

function App-Args([string[]]$extra) {
  $a = @()
  if (-not $defaultData) {
    $a += @('--data-dir', "`"$DataDir`"", '--cache-dir', "`"$(Join-Path $WorkDir 'cache')`"")
  }
  return $a + $extra
}

function Start-App {
  $p = Start-Process -FilePath $exe -ArgumentList (App-Args @()) -PassThru
  for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Milliseconds 500
    if ((Test-Path $db) -and -not $p.HasExited) { Start-Sleep -Seconds 3; break }
  }
  return $p
}

function Stop-App($p) {
  if ($p -and -not $p.HasExited) {
    $null = $p.CloseMainWindow()
    if (-not $p.WaitForExit(15000)) { Stop-Process -Id $p.Id -Force }
  }
  Get-Process patrion -ErrorAction SilentlyContinue | Stop-Process -Force
  Start-Sleep -Seconds 1
}

function Log-Text {
  $logs = Join-Path $DataDir 'logs'
  if (-not (Test-Path $logs)) { return '' }
  return (Get-ChildItem $logs -File | Sort-Object LastWriteTime | ForEach-Object {
      Get-Content $_.FullName -Raw -Encoding UTF8 }) -join "`n"
}

function Data-Hash {
  if (-not (Test-Path $db)) { return '' }
  return (Get-FileHash $db -Algorithm SHA256).Hash
}

$old = Version-Of $OldInstaller
$new = Version-Of $NewInstaller
Write-Host "Teste de instalação: $old -> $new"
Write-Host "Instalação: $InstallDir"
Write-Host "Dados:      $DataDir"
if (Test-Path $uninstallKey) { throw 'O Patrion já está instalado neste usuário. Desinstale antes.' }

# 1. Instalação da versão antiga
$code = Install $OldInstaller (Join-Path $WorkDir 'instalar-antiga.log')
Check 'Instalação da versão antiga' ($code -eq 0) "código $code"
Check 'Executável instalado' (Test-Path $exe) $exe
Check 'Runtime do Visual C++ junto do app' (Test-Path (Join-Path $InstallDir 'vcruntime140.dll'))
Check 'Atalho no Menu Iniciar' (Test-Path $shortcut)
$reg = Get-ItemProperty $uninstallKey -ErrorAction SilentlyContinue
Check 'Versão registrada no Windows' ($reg -and $reg.DisplayVersion -eq $old) "$($reg.DisplayVersion)"
$assoc = (Get-ItemProperty 'HKCU:\Software\Classes\.invsave' -ErrorAction SilentlyContinue).'(default)'
$command = (Get-ItemProperty 'HKCU:\Software\Classes\Patrion.Save\shell\open\command' -ErrorAction SilentlyContinue).'(default)'
Check 'Associação do .invsave' (($assoc -eq 'Patrion.Save') -and ($command -like "*$exe*%1*")) "$command"

# 2. Primeira abertura
$app = Start-App
Check 'O app abre e cria o banco' ((Test-Path $db) -and -not $app.HasExited) $db
Check 'Log de inicialização' ((Log-Text) -match "Iniciando Patrion") ''

# 3. Segunda instância com um .invsave
$save = Join-Path $WorkDir 'teste-instancia.invsave'
[IO.File]::WriteAllText($save, 'nao e um save de verdade')
if ($defaultData) {
  Start-Process -FilePath $save  # duplo clique (associação)
  $second = $null
} else {
  $second = Start-Process -FilePath $exe -ArgumentList (App-Args @("`"$save`"")) -PassThru
}
$received = $false
for ($i = 0; $i -lt 40 -and -not $received; $i++) {
  Start-Sleep -Milliseconds 500
  $received = (Log-Text) -match 'Arquivo recebido para abrir \(outra instância\): teste-instancia\.invsave'
}
Check 'O .invsave chega à janela já aberta' $received ''
if ($second) {
  $exited = $second.WaitForExit(15000)
  Check 'A segunda instância sai sozinha' ($exited -and $second.ExitCode -eq 0) "código $($second.ExitCode)"
}
Check 'A primeira instância continua aberta' (-not $app.HasExited) ''
$count = @(Get-Process patrion -ErrorAction SilentlyContinue).Count
Check 'Só uma janela do Patrion' ($count -eq 1) "$count processo(s)"

# 4. Atualizar com o app aberto deve recusar
$code = Install $NewInstaller (Join-Path $WorkDir 'atualizar-aberto.log')
$reg = Get-ItemProperty $uninstallKey -ErrorAction SilentlyContinue
Check 'Com o app aberto, o instalador não atualiza' (($code -ne 0) -and $reg.DisplayVersion -eq $old) "código $code, versão $($reg.DisplayVersion)"

# 5. Atualização por cima
Stop-App $app
$before = Data-Hash
$dataFiles = @(Get-ChildItem $DataDir -Recurse -File | Select-Object -ExpandProperty FullName)
$code = Install $NewInstaller (Join-Path $WorkDir 'atualizar.log')
Check 'Atualização por cima' ($code -eq 0) "código $code"
$reg = Get-ItemProperty $uninstallKey -ErrorAction SilentlyContinue
Check 'Nova versão registrada' ($reg -and $reg.DisplayVersion -eq $new) "$($reg.DisplayVersion)"
Check 'Mesma pasta de instalação' ($reg -and ($reg.InstallLocation.TrimEnd('\') -eq $InstallDir.TrimEnd('\'))) "$($reg.InstallLocation)"
Check 'Banco intacto depois de atualizar' (($before -ne '') -and ($before -eq (Data-Hash))) ''
$missing = @($dataFiles | Where-Object { -not (Test-Path $_) })
Check 'Nenhum arquivo de dados sumiu' ($missing.Count -eq 0) "$($missing.Count) faltando"

# 6. Nova versão abre
$app = Start-App
Check 'A nova versão abre com os mesmos dados' ((Test-Path $db) -and -not $app.HasExited) ''
Stop-App $app

# 7. Desinstalação
$before = Data-Hash
$uninstaller = Join-Path $InstallDir 'unins000.exe'
$p = Start-Process -FilePath $uninstaller -ArgumentList @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART') -Wait -PassThru
for ($i = 0; $i -lt 60 -and (Test-Path $exe); $i++) { Start-Sleep -Milliseconds 500 }
Start-Sleep -Seconds 2
Check 'Desinstalação' ($p.ExitCode -eq 0) "código $($p.ExitCode)"
Check 'App removido' (-not (Test-Path $exe)) ''
Check 'Atalho removido' (-not (Test-Path $shortcut)) ''
Check 'Registro de desinstalação removido' (-not (Test-Path $uninstallKey)) ''
Check 'Associação do .invsave removida' (-not (Test-Path 'HKCU:\Software\Classes\Patrion.Save')) ''
Check 'Dados continuam depois de desinstalar' ((Test-Path $db) -and ($before -eq (Data-Hash))) $DataDir
Check 'Backups e logs continuam' ((Test-Path (Join-Path $DataDir 'logs')) -and (Test-Path (Join-Path $DataDir 'backups'))) ''

$report = Join-Path $WorkDir 'resultado.txt'
$results | Format-Table -AutoSize | Out-String -Width 200 | Set-Content $report -Encoding UTF8
$failed = @($results | Where-Object { -not $_.Ok }).Count
Write-Host ''
Write-Host "$($results.Count - $failed) de $($results.Count) verificações OK. Relatório: $report"
if ($failed -gt 0) { exit 1 }
