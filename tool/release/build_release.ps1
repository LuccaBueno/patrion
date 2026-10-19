<#
.SYNOPSIS
  Gera os arquivos de uma Release do Patrion (SPEC §19; DECISIONS D-38).

.DESCRIPTION
  Em dist\ (ou -OutDir):
    Patrion-<versão>-instalador.exe   instalador (Inno Setup 6)
    Patrion-<versão>-portatil.zip     versão portátil
    SHA256SUMS.txt                    somas SHA-256 dos dois
    RELEASE_NOTES.md                  notas da Release (do CHANGELOG.md)

  A versão vem do pubspec.yaml. O mesmo script roda no PC e no workflow de
  release do GitHub Actions.

.PARAMETER SkipBuild
  Usa o build já existente em build\windows\x64\runner\Release.

.PARAMETER Version
  Versão a usar no lugar da do pubspec.yaml (só para testes de instalação,
  por exemplo gerar uma "0.9.0" para testar a atualização por cima).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tool\release\build_release.ps1
#>
[CmdletBinding()]
param(
  [switch]$SkipBuild,
  [string]$OutDir = 'dist',
  [string]$Version
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $root

function Find-Iscc {
  $candidates = @(
    $env:ISCC,
    (Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
    (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'),
    (Join-Path $env:ProgramFiles 'Inno Setup 6\ISCC.exe')
  )
  foreach ($c in $candidates) {
    if ($c -and (Test-Path $c)) { return $c }
  }
  throw 'Inno Setup 6 (ISCC.exe) não encontrado. Instale-o ou defina $env:ISCC.'
}

$pubspec = Get-Content 'pubspec.yaml' -Raw
if ($pubspec -notmatch '(?m)^version:\s*([0-9A-Za-z.\-]+)') {
  throw 'Versão não encontrada no pubspec.yaml.'
}
$pubspecVersion = $Matches[1]
if (-not $Version) { $Version = $pubspecVersion }
Write-Host "Patrion $Version"

$release = Join-Path $root 'build\windows\x64\runner\Release'
if (-not $SkipBuild) {
  flutter build windows --release
  if ($LASTEXITCODE -ne 0) { throw 'flutter build windows falhou.' }
}
foreach ($f in @('patrion.exe', 'flutter_windows.dll', 'vcruntime140.dll', 'msvcp140.dll', 'data\app.so')) {
  if (-not (Test-Path (Join-Path $release $f))) {
    throw "Build incompleto: falta $f em $release"
  }
}

$out = Join-Path $root $OutDir
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null

# Instalador
$iscc = Find-Iscc
& $iscc /Q "/DAppVersion=$Version" "/DSourceDir=$release" "/O$out" 'installer\patrion.iss'
if ($LASTEXITCODE -ne 0) { throw 'ISCC falhou.' }
$installer = Join-Path $out "Patrion-$Version-instalador.exe"

# ZIP portátil: uma pasta "Patrion" com o app e o LEIA-ME.
$stage = Join-Path $out 'portatil'
$appDir = Join-Path $stage 'Patrion'
New-Item -ItemType Directory -Force $appDir | Out-Null
Copy-Item (Join-Path $release '*') $appDir -Recurse
$readme = Get-Content 'installer\LEIA-ME-PORTATIL.txt' -Raw -Encoding UTF8
$readme = $readme.Replace('{{VERSAO}}', $Version)
[IO.File]::WriteAllText((Join-Path $appDir 'LEIA-ME.txt'), $readme, (New-Object Text.UTF8Encoding $true))
$zip = Join-Path $out "Patrion-$Version-portatil.zip"
Compress-Archive -Path $appDir -DestinationPath $zip -CompressionLevel Optimal
Remove-Item $stage -Recurse -Force

# Somas SHA-256 (conferência de download corrompido; não protegem contra
# adulteração, ver docs/DISTRIBUICAO.md).
$sums = foreach ($f in @($installer, $zip)) {
  $h = (Get-FileHash $f -Algorithm SHA256).Hash.ToLower()
  "$h  $(Split-Path $f -Leaf)"
}
[IO.File]::WriteAllLines((Join-Path $out 'SHA256SUMS.txt'), $sums)

# Notas da Release
& (Join-Path $PSScriptRoot 'release_notes.ps1') -Version $Version -OutFile (Join-Path $out 'RELEASE_NOTES.md')

Write-Host ''
Get-ChildItem $out | ForEach-Object {
  '{0,-40} {1,10:N0} KB' -f $_.Name, ($_.Length / 1KB)
}
