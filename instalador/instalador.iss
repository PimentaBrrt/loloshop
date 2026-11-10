; O instalador do Loloshop e do Illostrator: um setup pequeno que baixa a versão mais nova de cada
; app escolhido dos Releases do GitHub e instala do mesmo jeito que install/instalar.ps1 de cada
; repositório (mesmas pastas, nomes, tarefas e servidores MCP), então vai por cima de uma
; instalação feita por eles. Os apps continuam se atualizando com o atualizar.ps1 de cada um.
;
; Compilado pelo workflow .github/workflows/instalador.yml (Inno Setup 6):
;   ISCC.exe instalador\instalador.iss

#define Versao GetDateTimeString('yyyy.mm.dd', '.', '')

[Setup]
; Nunca mude o AppId: é por ele que o Windows reconhece uma instalação anterior.
AppId={{3024DDF6-8928-489F-944D-CE0CE1AF82E4}
AppName=Loloshop e Illostrator
AppVersion={#Versao}
AppVerName=Loloshop e Illostrator
AppPublisher=PimentaBrrt
AppPublisherURL=https://github.com/PimentaBrrt/loloshop
; Os apps ficam em %LOCALAPPDATA%\Programs\Loloshop e ...\Illostrator; aqui, só o desinstalador.
DefaultDirName={localappdata}\Programs\Loloshop e Illostrator
DisableWelcomePage=no
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
RestartApplications=no
WizardStyle=modern
; A girafa do Loloshop e o gatinho do Illostrator (os ícones dos apps), em 100%, 150% e 200% de zoom.
WizardImageFile=lateral-100.bmp,lateral-150.bmp,lateral-200.bmp
WizardSmallImageFile=canto-100.bmp,canto-150.bmp,canto-200.bmp
SetupIconFile=..\layer\overlay\assets\app-icon\photocraft.ico
UninstallDisplayIcon={uninstallexe}
UninstallDisplayName=Loloshop e Illostrator
OutputDir=Output
OutputBaseFilename=Instalar-Loloshop-e-Illostrator
Compression=lzma2
SolidCompression=yes

[Languages]
Name: "pt"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Messages]
WelcomeLabel1=Loloshop e Illostrator
WelcomeLabel2=Este assistente instala o Loloshop, para editar fotos, e o Illostrator, para desenhar ilustrações vetoriais.%n%nEle baixa a versão mais nova de cada um (uns 250 MB por app). Depois disso eles se atualizam sozinhos.
FinishedHeadingLabel=Tudo pronto!
FinishedLabelNoIcons=Os apps estão no Menu Iniciar e se atualizam sozinhos.%n%nSe você conectou ao Claude Desktop: feche o Claude pelo ícone perto do relógio (Sair) e abra de novo.
FinishedLabel=Os apps estão no Menu Iniciar e se atualizam sozinhos.%n%nSe você conectou ao Claude Desktop: feche o Claude pelo ícone perto do relógio (Sair) e abra de novo.

[Types]
Name: "full"; Description: "Os dois apps"
Name: "custom"; Description: "Escolher"; Flags: iscustom

[Components]
Name: "loloshop"; Description: "Loloshop: edição de fotos (baseado no Photoshop)"; Types: full custom
Name: "illostrator"; Description: "Illostrator: ilustração vetorial (baseado no Illustrator)"; Types: full custom

[Tasks]
Name: "desktopicon"; Description: "Criar atalhos na Área de Trabalho"
Name: "claude"; Description: "Conectar ao Claude Desktop (o Claude cria arte com os apps)"

[InstallDelete]
; A versão que o atualizar.ps1 tinha guardado para trocar depois é mais velha que a de agora.
Type: files; Name: "{localappdata}\Programs\Loloshop\*.new"; Components: loloshop
Type: files; Name: "{localappdata}\Programs\Loloshop\*.new.txt"; Components: loloshop
Type: files; Name: "{localappdata}\Programs\Loloshop\*.part"; Components: loloshop
Type: files; Name: "{localappdata}\Programs\Illostrator\*.new"; Components: illostrator
Type: files; Name: "{localappdata}\Programs\Illostrator\*.new.txt"; Components: illostrator
Type: files; Name: "{localappdata}\Programs\Illostrator\*.part"; Components: illostrator
; O desinstalador de uma instalação feita por instalar.ps1: agora é o do Windows (Apps instalados).
Type: files; Name: "{localappdata}\Programs\Loloshop\desinstalar.ps1"; Components: loloshop
Type: files; Name: "{localappdata}\Programs\Illostrator\desinstalar.ps1"; Components: illostrator

[Files]
Source: "configurar.ps1"; DestDir: "{app}"; Flags: ignoreversion
; Baixados para {tmp} na página "Pronto para instalar" (NextButtonClick, abaixo). ExternalSize é o
; tamanho aproximado de cada um, para a conta de espaço em disco do assistente.
Source: "{tmp}\Loloshop.exe"; DestDir: "{localappdata}\Programs\Loloshop"; Flags: external ignoreversion; ExternalSize: 160000000; Components: loloshop
Source: "{tmp}\loloshop-cli.exe"; DestDir: "{localappdata}\Programs\Loloshop"; Flags: external ignoreversion; ExternalSize: 115000000; Components: loloshop
Source: "{tmp}\loloshop-atualizar.ps1"; DestDir: "{localappdata}\Programs\Loloshop"; DestName: "atualizar.ps1"; Flags: external ignoreversion; Components: loloshop
Source: "{tmp}\loloshop-versao.txt"; DestDir: "{localappdata}\Programs\Loloshop"; DestName: "versao.txt"; Flags: external ignoreversion; Components: loloshop
Source: "{tmp}\loloshop-versao.txt"; DestDir: "{localappdata}\Programs\Loloshop"; DestName: "versao-cli.txt"; Flags: external ignoreversion; Components: loloshop
Source: "{tmp}\Illostrator.exe"; DestDir: "{localappdata}\Programs\Illostrator"; Flags: external ignoreversion; ExternalSize: 195000000; Components: illostrator
Source: "{tmp}\illostrator-cli.exe"; DestDir: "{localappdata}\Programs\Illostrator"; Flags: external ignoreversion; ExternalSize: 135000000; Components: illostrator
Source: "{tmp}\illostrator-atualizar.ps1"; DestDir: "{localappdata}\Programs\Illostrator"; DestName: "atualizar.ps1"; Flags: external ignoreversion; Components: illostrator
Source: "{tmp}\illostrator-versao.txt"; DestDir: "{localappdata}\Programs\Illostrator"; DestName: "versao.txt"; Flags: external ignoreversion; Components: illostrator
Source: "{tmp}\illostrator-versao.txt"; DestDir: "{localappdata}\Programs\Illostrator"; DestName: "versao-cli.txt"; Flags: external ignoreversion; Components: illostrator

[Icons]
Name: "{userprograms}\Loloshop"; Filename: "{localappdata}\Programs\Loloshop\Loloshop.exe"; WorkingDir: "{localappdata}\Programs\Loloshop"; Components: loloshop
Name: "{userdesktop}\Loloshop"; Filename: "{localappdata}\Programs\Loloshop\Loloshop.exe"; WorkingDir: "{localappdata}\Programs\Loloshop"; Components: loloshop; Tasks: desktopicon
Name: "{userstartup}\Loloshop - atualizar"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{localappdata}\Programs\Loloshop\atualizar.ps1"""; Flags: runminimized; Components: loloshop
Name: "{userprograms}\Illostrator"; Filename: "{localappdata}\Programs\Illostrator\Illostrator.exe"; WorkingDir: "{localappdata}\Programs\Illostrator"; Components: illostrator
Name: "{userdesktop}\Illostrator"; Filename: "{localappdata}\Programs\Illostrator\Illostrator.exe"; WorkingDir: "{localappdata}\Programs\Illostrator"; Components: illostrator; Tasks: desktopicon
Name: "{userstartup}\Illostrator - atualizar"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{localappdata}\Programs\Illostrator\atualizar.ps1"""; Flags: runminimized; Components: illostrator

[Run]
Filename: "{localappdata}\Programs\Loloshop\Loloshop.exe"; Description: "Abrir o Loloshop"; Flags: postinstall nowait skipifsilent unchecked; Components: loloshop
Filename: "{localappdata}\Programs\Illostrator\Illostrator.exe"; Description: "Abrir o Illostrator"; Flags: postinstall nowait skipifsilent unchecked; Components: illostrator

[UninstallRun]
; A tarefa diária, os servidores MCP e os atalhos de uma instalação antiga, dos dois apps.
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\configurar.ps1"" -App Loloshop -Remove"; Flags: runhidden; RunOnceId: "RemoverLoloshop"
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\configurar.ps1"" -App Illostrator -Remove"; Flags: runhidden; RunOnceId: "RemoverIllostrator"

[UninstallDelete]
; As versões baixadas pelo atualizar.ps1 e o log. As preferências dos apps e as pastas
; Imagens\Loloshop Claude e Imagens\Illostrator Claude ficam.
Type: filesandordirs; Name: "{localappdata}\Programs\Loloshop"
Type: filesandordirs; Name: "{localappdata}\Programs\Illostrator"

[Code]
var
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage('Baixando os apps', 'Baixando a versão mais nova dos Releases do GitHub...', @OnDownloadProgress);
end;

{ O tag do Release mais novo de Repo (build-...), lido da API do GitHub. }
function LatestTag(const Repo, Key: String): String;
var
  Json: AnsiString;
  S: String;
  P: Integer;
begin
  Result := '';
  DownloadTemporaryFile('https://api.github.com/repos/' + Repo + '/releases/latest', Key + '-release.json', '', @OnDownloadProgress);
  if not LoadStringFromFile(ExpandConstant('{tmp}\' + Key + '-release.json'), Json) then
    Exit;
  S := String(Json);
  P := Pos('"tag_name"', S);
  if P = 0 then
    Exit;
  Delete(S, 1, P + Length('"tag_name"'));
  P := Pos('"', S);
  Delete(S, 1, P);
  P := Pos('"', S);
  Result := Copy(S, 1, P - 1);
end;

{ Põe na fila os arquivos de um app, do Release mais novo, e grava o tag para o atualizar.ps1
  saber que esta é a versão instalada (sem isso ele baixaria tudo de novo ao meio-dia). }
procedure AddApp(const Repo, Name, Key: String);
var
  Tag: String;
begin
  Tag := LatestTag(Repo, Key);
  if Tag = '' then
    RaiseException('não achei a versão mais nova do ' + Name);
  SaveStringToFile(ExpandConstant('{tmp}\' + Key + '-versao.txt'), Tag, False);
  DownloadPage.Add('https://github.com/' + Repo + '/releases/download/' + Tag + '/' + Name + '-windows-x64.exe', Name + '.exe', '');
  DownloadPage.Add('https://github.com/' + Repo + '/releases/download/' + Tag + '/' + Name + '-cli-windows-x64.exe', Key + '-cli.exe', '');
  DownloadPage.Add('https://raw.githubusercontent.com/' + Repo + '/main/install/atualizar.ps1', Key + '-atualizar.ps1', '');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID <> wpReady then
    Exit;
  DownloadPage.Clear;
  DownloadPage.Show;
  try
    try
      if WizardIsComponentSelected('loloshop') then
        AddApp('PimentaBrrt/loloshop', 'Loloshop', 'loloshop');
      if WizardIsComponentSelected('illostrator') then
        AddApp('PimentaBrrt/Illostrator', 'Illostrator', 'illostrator');
      DownloadPage.Download;
    except
      if not DownloadPage.AbortedByUser then
        SuppressibleMsgBox('Não deu para baixar os apps: ' + GetExceptionMessage + #13#10#13#10 + 'Confira a internet e tente de novo.', mbCriticalError, MB_OK, IDOK);
      Result := False;
    end;
  finally
    DownloadPage.Hide;
  end;
end;

{ O Claude Desktop deixa o servidor MCP de cada app aberto, e um .exe aberto não pode ser trocado.
  Fechar o servidor só desconecta o app do Claude até ele ser aberto de novo. }
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  Code: Integer;
begin
  Result := '';
  if WizardIsComponentSelected('loloshop') then
    Exec('taskkill.exe', '/F /IM loloshop-cli.exe', '', SW_HIDE, ewWaitUntilTerminated, Code);
  if WizardIsComponentSelected('illostrator') then
    Exec('taskkill.exe', '/F /IM illostrator-cli.exe', '', SW_HIDE, ewWaitUntilTerminated, Code);
end;

{ A tarefa diária, o servidor MCP e os ícones de um app (configurar.ps1). }
procedure Configure(const App: String);
var
  Params: String;
  Code: Integer;
begin
  Params := '-NoProfile -ExecutionPolicy Bypass -File "' + ExpandConstant('{app}\configurar.ps1') + '" -App ' + App;
  if WizardIsTaskSelected('claude') then
    Params := Params + ' -Claude';
  if not Exec('powershell.exe', Params, '', SW_HIDE, ewWaitUntilTerminated, Code) or (Code <> 0) then
    SuppressibleMsgBox('O ' + App + ' foi instalado, mas parte da configuração falhou (atualização diária ou Claude Desktop). Os detalhes estão em ' + ExpandConstant('{%TEMP}\configurar-') + Lowercase(App) + '.log.', mbInformation, MB_OK, IDOK);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep <> ssPostInstall then
    Exit;
  if WizardIsComponentSelected('loloshop') then
    Configure('Loloshop');
  if WizardIsComponentSelected('illostrator') then
    Configure('Illostrator');
end;

function InitializeUninstall: Boolean;
var
  Code: Integer;
begin
  Result := True;
  if Exec('powershell.exe', '-NoProfile -Command "if (Get-Process -Name Loloshop,Illostrator -ErrorAction SilentlyContinue) { exit 1 }"', '', SW_HIDE, ewWaitUntilTerminated, Code) and (Code = 1) then
  begin
    MsgBox('Feche o Loloshop e o Illostrator (salve o que estiver aberto) e tente de novo.', mbError, MB_OK);
    Result := False;
  end;
end;
