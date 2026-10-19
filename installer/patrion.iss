; Instalador do Patrion (Inno Setup 6). SPEC §19; DECISIONS D-06 e D-38.
;
; Gerado por tool/release/build_release.ps1, que passa a versão do
; pubspec.yaml:
;   ISCC /DAppVersion=1.0.0 /DSourceDir=<build\windows\x64\runner\Release> patrion.iss
;
; Regras:
; - Instala por usuário em %LOCALAPPDATA%\Programs\Patrion, sem pedir
;   administrador; o diálogo permite instalar para todos os usuários.
; - Os dados do usuário ficam em %APPDATA%\Patrion (D-05), fora da pasta de
;   instalação. Nem a atualização nem a desinstalação mexem neles: este
;   script não tem [UninstallDelete] e o [InstallDelete] só limpa a pasta
;   "data" do próprio app dentro de {app}.
; - O AppId nunca muda: é o que faz a nova versão instalar por cima da
;   anterior.

#ifndef AppVersion
  #error Informe a versão: ISCC /DAppVersion=X.Y.Z patrion.iss
#endif
#ifndef SourceDir
  #define SourceDir "..\build\windows\x64\runner\Release"
#endif

#define AppName "Patrion"
#define AppExe "patrion.exe"
#define AppRepo "https://github.com/LuccaBueno/patrion"
; Versão numérica para o recurso de versão do Windows: sem o sufixo
; "-beta.1" ou "-rc.1".
#define Dash Pos("-", AppVersion)
#define AppVersionNumeric Dash > 0 ? Copy(AppVersion, 1, Dash - 1) : AppVersion

[Setup]
AppId={{5A345516-F4A3-4E8D-B057-50475B9F06F9}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Lucca Bueno
AppPublisherURL={#AppRepo}
AppSupportURL={#AppRepo}/issues
AppUpdatesURL={#AppRepo}/releases
AppCopyright=Copyright (C) 2026 Lucca Bueno
VersionInfoVersion={#AppVersionNumeric}
VersionInfoProductVersion={#AppVersionNumeric}
VersionInfoProductTextVersion={#AppVersion}
VersionInfoDescription=Instalador do {#AppName}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
UsePreviousAppDir=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
; O app aberto cria este mutex (windows\runner\main.cpp): o instalador pede
; para fechá-lo antes de continuar, sem fechar à força.
AppMutex=PatrionAppMutex,Global\PatrionAppMutex
CloseApplications=no
ChangesAssociations=yes
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
OutputBaseFilename=Patrion-{#AppVersion}-instalador
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
SetupLogging=yes

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[CustomMessages]
brazilianportuguese.AssocGroup=Arquivos:
brazilianportuguese.AssocSave=Abrir arquivos de save (.invsave) com o Patrion
brazilianportuguese.SaveFileType=Arquivo de save do Patrion
brazilianportuguese.DataKept=O Patrion foi removido. Seus dados continuam em:%n%n%1%n%nPara apagá-los de vez, apague essa pasta manualmente.

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "assocsave"; Description: "{cm:AssocSave}"; GroupDescription: "{cm:AssocGroup}"

[InstallDelete]
; Só os arquivos do próprio app (assets da versão anterior). Os dados do
; usuário não ficam aqui.
Type: filesandordirs; Name: "{app}\data"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Registry]
; Associação do .invsave (HKA: HKCU na instalação por usuário, HKLM para
; todos os usuários). Removida na desinstalação.
Root: HKA; Subkey: "Software\Classes\.invsave"; ValueType: string; ValueName: ""; ValueData: "Patrion.Save"; Flags: uninsdeletevalue; Tasks: assocsave
Root: HKA; Subkey: "Software\Classes\.invsave\OpenWithProgids"; ValueType: string; ValueName: "Patrion.Save"; ValueData: ""; Flags: uninsdeletevalue; Tasks: assocsave
Root: HKA; Subkey: "Software\Classes\Patrion.Save"; ValueType: string; ValueName: ""; ValueData: "{cm:SaveFileType}"; Flags: uninsdeletekey; Tasks: assocsave
Root: HKA; Subkey: "Software\Classes\Patrion.Save\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#AppExe},0"; Tasks: assocsave
Root: HKA; Subkey: "Software\Classes\Patrion.Save\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: assocsave
Root: HKA; Subkey: "Software\Classes\Applications\{#AppExe}\SupportedTypes"; ValueType: string; ValueName: ".invsave"; ValueData: ""; Flags: uninsdeletekey

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[Code]
// Ao terminar a desinstalação, lembra onde os dados ficaram (não são
// apagados; SPEC §19).
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DataDir: String;
begin
  if (CurUninstallStep = usPostUninstall) and not UninstallSilent then
  begin
    DataDir := ExpandConstant('{userappdata}\Patrion');
    MsgBox(FmtMessage(CustomMessage('DataKept'), [DataDir]), mbInformation, MB_OK);
  end;
end;
