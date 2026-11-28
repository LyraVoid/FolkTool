#ifndef MyAppName
  #define MyAppName "FolkTool"
#endif
#ifndef MyAppVersion
  #define MyAppVersion "1.7.0"
#endif
#ifndef MyAppPublisher
  #define MyAppPublisher "FolkTool"
#endif
#ifndef MyAppExeName
  #define MyAppExeName "FolkTool.exe"
#endif
#ifndef SourceDir
  #define SourceDir "build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "installer"
#endif
#ifndef OutputBaseFilename
  #define OutputBaseFilename "FolkTool-Setup"
#endif
#ifndef DefaultInstallDir
  #define DefaultInstallDir "{autopf}\FolkTool"
#endif
#ifndef CompressionAlgo
  #define CompressionAlgo "lzma2"
#endif

[Setup]
AppId={{A1B2C3D4-E5F6-4789-A0B1-C2D3E4F5A6B7}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL=https://github.com/LyraVoid/FolkTool
AppSupportURL=https://github.com/LyraVoid/FolkTool/issues
AppUpdatesURL=https://github.com/LyraVoid/FolkTool/releases
DefaultDirName={#DefaultInstallDir}
DisableDirPage=no
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=no
OutputDir={#OutputDir}
OutputBaseFilename={#OutputBaseFilename}
Compression={#CompressionAlgo}
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
SetupIconFile=assets\icons\icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
VCRedistInstalling=Installing Microsoft Visual C++ 2015-2022 Redistributable (x64)...
VCRedistDownloading=Downloading Microsoft Visual C++ 2015-2022 Redistributable (x64)...
VCRedistDownloadFailed=Failed to download Microsoft Visual C++ 2015-2022 Redistributable (x64).%n%nPlease install it manually from:%n%1%n%nDo you want to continue the installation anyway?

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\FolkTool.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "apk\*"; DestDir: "{app}\apk"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "assets\icons"
Source: "kp_versions\*"; DestDir: "{app}\kp_versions"; Flags: ignoreversion recursesubdirs createallsubdirs

; Optional direct Visual C++ runtime DLLs if bundled in release or redist
Source: "{#SourceDir}\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "redist\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "redist\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "redist\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

; Optional bundled Visual C++ Redistributable installer
Source: "redist\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: ignoreversion skipifsourcedoesntexist

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

function VerifyMicrosoftSignature(const FilePath: String): Boolean;
var
  ResultCode: Integer;
  PsArgs: String;
begin
  Result := False;
  if not FileExists(FilePath) then Exit;
  PsArgs := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ' +
    '"$s = Get-AuthenticodeSignature -LiteralPath ''' + FilePath + '''; ' +
    'if ($s.Status -eq ''Valid'' -and $s.SignerCertificate.Subject -like ''*Microsoft*'') { exit 0 } else { exit 1 }"';
  if Exec('powershell.exe', PsArgs, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    Result := (ResultCode = 0);
end;

function VCRedistNeedsInstallAndFileExists: Boolean;
var
  VCRedistPath: String;
begin
  VCRedistPath := ExpandConstant('{tmp}\vc_redist.x64.exe');
  Result := VCRedistNeedsInstall and FileExists(VCRedistPath) and VerifyMicrosoftSignature(VCRedistPath);
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