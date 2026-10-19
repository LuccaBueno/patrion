<#
.SYNOPSIS
  Monta as notas da Release (SPEC §19, "Conteúdo de cada Release").

.DESCRIPTION
  Junta a seção "## [<versão>]" do CHANGELOG.md (novidades, correções e
  problemas conhecidos) com os requisitos do sistema e as instruções de
  instalação e atualização de installer\RELEASE_TEMPLATE.md.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string]$Version,
  [Parameter(Mandatory)] [string]$OutFile
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')

$changelog = Get-Content (Join-Path $root 'CHANGELOG.md') -Encoding UTF8
$start = -1
$date = ''
for ($i = 0; $i -lt $changelog.Count; $i++) {
  if ($changelog[$i] -match "^## \[$([regex]::Escape($Version))\](?:\s*-\s*(\S+))?") {
    $start = $i + 1
    $date = $Matches[1]
    break
  }
}
if ($start -lt 0) {
  throw "CHANGELOG.md não tem a seção ## [$Version]."
}
$section = New-Object System.Collections.Generic.List[string]
for ($i = $start; $i -lt $changelog.Count; $i++) {
  if ($changelog[$i] -match '^## ') { break }
  # Um nível abaixo: "### Adicionado" vira "## Adicionado" na Release.
  $section.Add(($changelog[$i] -replace '^###', '##'))
}

$template = Get-Content (Join-Path $root 'installer\RELEASE_TEMPLATE.md') -Raw -Encoding UTF8
$notes = $template.Replace('{{VERSAO}}', $Version).
  Replace('{{DATA}}', $(if ($date) { $date } else { (Get-Date -Format 'yyyy-MM-dd') })).
  Replace('{{CHANGELOG}}', ($section -join "`n").Trim())

[IO.File]::WriteAllText($OutFile, $notes, (New-Object Text.UTF8Encoding $false))
Write-Host "Notas: $OutFile"
