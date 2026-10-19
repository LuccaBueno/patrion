# Patrion {{VERSAO}}

Lançada em {{DATA}}.

{{CHANGELOG}}

## Requisitos do sistema

- Windows 10 ou 11, 64 bits (x64).
- Cerca de 100 MB livres para o app, além dos dados.
- Internet só para as cotações, os indicadores e a verificação de atualizações. Sem internet, o app funciona com os últimos dados guardados.

## Arquivos

| Arquivo | Para quê |
|---|---|
| `Patrion-{{VERSAO}}-instalador.exe` | Instalador (recomendado). Instala só para o seu usuário, sem pedir administrador. |
| `Patrion-{{VERSAO}}-portatil.zip` | Versão portátil, sem instalar. Veja o `LEIA-ME.txt` dentro do ZIP. |
| `SHA256SUMS.txt` | Somas SHA-256 dos arquivos, para conferir o download. |

## Instalação

1. Baixe `Patrion-{{VERSAO}}-instalador.exe`.
2. Execute. O app não é assinado digitalmente: se o Windows mostrar "O Windows protegeu o computador" (SmartScreen), clique em **Mais informações** e **Executar assim mesmo**.
3. Escolha os atalhos e se os arquivos `.invsave` devem abrir com o Patrion.

## Atualização

Feche o Patrion e execute o instalador da nova versão: ele instala por cima da anterior, na mesma pasta. Os dados (`%APPDATA%\Patrion`) não são tocados. Se o banco precisar de migração, o app faz um backup automático antes, ao abrir.

## Desinstalação

Pelo Windows ("Aplicativos instalados" > Patrion > Desinstalar). Os dados continuam em `%APPDATA%\Patrion`; para apagá-los de vez, apague essa pasta manualmente.

## Verificar o download (opcional)

No PowerShell, na pasta do download:

```powershell
Get-FileHash .\Patrion-{{VERSAO}}-instalador.exe -Algorithm SHA256
```

Compare com a linha do arquivo em `SHA256SUMS.txt`. A soma detecta um download corrompido; como fica no mesmo lugar do arquivo, não prova que ele não foi adulterado.
