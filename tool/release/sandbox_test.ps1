<#
.SYNOPSIS
  Abre o Windows Sandbox (Windows limpo e descartável) e roda nele o teste de
  instalação, atualização e desinstalação (tool\release\test_install.ps1).

.DESCRIPTION
  Precisa do recurso "Área Restrita do Windows" (Windows Sandbox) ligado:
    Painel de Controle > Programas > Ativar ou desativar recursos do Windows
    > Área Restrita do Windows (pede reinicialização).

  Usa dist\Patrion-<versão>-instalador.exe (gerado por build_release.ps1) e
  gera, se faltar, um instalador "0.9.0" do mesmo build só para testar a
  atualização por cima. O resultado aparece em dist\sandbox\resultado.txt;
  o Sandbox continua aberto para os testes manuais (docs/DISTRIBUICAO.md).
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$sandboxExe = Join-Path $env:windir 'System32\WindowsSandbox.exe'
if (-not (Test-Path $sandboxExe)) {
  throw 'Windows Sandbox não está habilitado. Ligue "Área Restrita do Windows" em "Ativar ou desativar recursos do Windows".'
}

$dist = Join-Path $root 'dist'
$new = Get-ChildItem $dist -Filter 'Patrion-*-instalador.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $new) { throw 'Rode antes tool\release\build_release.ps1.' }

$work = Join-Path $dist 'sandbox'
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Force $work | Out-Null
Copy-Item $new.FullName $work
$old = Join-Path $work 'Patrion-0.9.0-instalador.exe'
$oldBuild = Join-Path $root 'dist-teste-0.9.0'
& (Join-Path $PSScriptRoot 'build_release.ps1') -SkipBuild -Version 0.9.0 -OutDir 'dist-teste-0.9.0' 2>$null | Out-Null
Copy-Item (Join-Path $oldBuild 'Patrion-0.9.0-instalador.exe') $old
Remove-Item $oldBuild -Recurse -Force
Copy-Item (Join-Path $PSScriptRoot 'test_install.ps1') $work

$inside = 'C:\Users\WDAGUtilityAccount\Desktop\patrion-teste'
$command = "powershell -NoProfile -ExecutionPolicy Bypass -File $inside\test_install.ps1 " +
  "-OldInstaller $inside\Patrion-0.9.0-instalador.exe -NewInstaller $inside\$($new.Name) -WorkDir $inside\trabalho"
$wsb = @"
<Configuration>
  <VGpu>Default</VGpu>
  <Networking>Default</Networking>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>$work</HostFolder>
      <SandboxFolder>$inside</SandboxFolder>
      <ReadOnly>false</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <LogonCommand>
    <Command>$command</Command>
  </LogonCommand>
</Configuration>
"@
$wsbFile = Join-Path $work 'patrion-teste.wsb'
[IO.File]::WriteAllText($wsbFile, $wsb)
Write-Host "Abrindo o Windows Sandbox. Resultado: $work\trabalho\resultado.txt"
Start-Process $sandboxExe -ArgumentList "`"$wsbFile`""
