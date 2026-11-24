#define MyAppName "FolkTool"
#define MyAppVersion "1.7.0"
#define MyAppPublisher "FolkTool"
#define MyAppExeName "FolkTool.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-4789-A0B1-C2D3E4F5A6B7}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={commonpf}\FolkTool
DisableDirPage=no
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=no
OutputDir=installer
OutputBaseFilename=FolkTool-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
VCRedistInstalling=Installing Microsoft Visual C++ 2015-2022 Redistributable (x64)...
VCRedistDownloading=Downloading Microsoft Visual C++ 2015-2022 Redistributable (x64)...
VCRedistDownloadFailed=Failed to download Microsoft Visual C++ 2015-2022 Redistributable (x64).%n%nPlease install it manually from:%n%1%n%nDo you want to continue the installation anyway?

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\FolkTool.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "assets\icons"
Source: "kp_versions\*"; DestDir: "{app}\kp_versions"; Flags: ignoreversion recursesubdirs createallsubdirs

; Optional direct Visual C++ runtime DLLs if bundled in release or redist
Source: "build\windows\x64\runner\Release\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "build\windows\x64\runner\Release\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "build\windows\x64\runner\Release\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "redist\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "redist\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "redist\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

; Optional bundled Visual C++ Redistributable installer
Source: "redist\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: ignoreversion skipifsourcedoesntexist

[Dirs]
Name: "{app}\installer"; Flags: deleteafterinstall

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "{cm:VCRedistInstalling}"; Flags: waituntilterminated; Check: VCRedistNeedsInstallAndFileExists
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
var
  DownloadPage: TDownloadWizardPage;

function VCRedistNeedsInstall: Boolean;
var
  Installed: Cardinal;
  VerStr: String;
begin
  // Check if runtime DLLs already exist in Windows System directory
  if FileExists(ExpandConstant('{sys}\msvcp140.dll')) and
     FileExists(ExpandConstant('{sys}\vcruntime140_1.dll')) and
     FileExists(ExpandConstant('{sys}\vcruntime140.dll')) then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
  // Check 64-bit native registry for VC++ 2015-2022 (v14) x64 runtime
  if RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) then
  begin
    if Installed = 1 then
    begin
      Result := False;
      Exit;
    end;
  end;
  if RegQueryStringValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', VerStr) then
  begin
    if VerStr <> '' then
    begin
      Result := False;
      Exit;
    end;
  end;
  // Check 32-bit registry hive as fallback
  if RegQueryDWordValue(HKLM32, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) then
  begin
    if Installed = 1 then
    begin
      Result := False;
      Exit;
    end;
  end;
  if RegQueryStringValue(HKLM32, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', VerStr) then
  begin
    if VerStr <> '' then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function VCRedistNeedsInstallAndFileExists: Boolean;
begin
  Result := VCRedistNeedsInstall and FileExists(ExpandConstant('{tmp}\vc_redist.x64.exe'));
end;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  VCRedistUrl: String;
begin
  Result := True;
  if CurPageID = wpReady then
  begin
    if VCRedistNeedsInstall and not FileExists(ExpandConstant('{tmp}\vc_redist.x64.exe')) then
    begin
      VCRedistUrl := 'https://aka.ms/vs/17/release/vc_redist.x64.exe';
      DownloadPage.Clear;
      DownloadPage.Add(VCRedistUrl, 'vc_redist.x64.exe', '');
      DownloadPage.Show;
      try
        try
          DownloadPage.Download;
        except
          if SuppressibleMsgBox(
            FmtMessage(CustomMessage('VCRedistDownloadFailed'), [VCRedistUrl]),
            mbConfirmation, MB_YESNO, IDYES) = IDNO then
          begin
            Result := False;
            Exit;
          end;
        end;
      finally
        DownloadPage.Hide;
      end;
    end;
  end;
end;
