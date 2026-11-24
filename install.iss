[Setup]
AppId={{A1B2C3D4-5E6F-7890-ABCD-EF1234567890}
AppName=FolkTool
AppVersion=1.7.0
AppVerName=FolkTool 1.7.0
AppPublisher=FolkTool
DefaultDirName={autopf}\FolkTool
DefaultGroupName=FolkTool
AllowNoIcons=yes
LicenseFile=
OutputDir=release
OutputBaseFilename=FolkTool-Setup-v1.7.0
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\FolkTool.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
VCRedistInstalling=Installing Microsoft Visual C++ 2015-2022 Redistributable (x64)...
VCRedistDownloading=Downloading Microsoft Visual C++ 2015-2022 Redistributable (x64)...
VCRedistDownloadFailed=Failed to download Microsoft Visual C++ 2015-2022 Redistributable (x64).%n%nPlease install it manually from:%n%1%n%nDo you want to continue the installation anyway?

[Files]
Source: "release\FolkTool-Windows-Release\FolkTool.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "release\FolkTool-Windows-Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "release\FolkTool-Windows-Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "release\FolkTool-Windows-Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "assets\icons"
Source: "kp_versions\*"; DestDir: "{app}\kp_versions"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "redist\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: ignoreversion skipifsourcedoesntexist

[Icons]
Name: "{group}\FolkTool"; Filename: "{app}\FolkTool.exe"
Name: "{group}\{cm:UninstallProgram,FolkTool}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\FolkTool"; Filename: "{app}\FolkTool.exe"

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "{cm:VCRedistInstalling}"; Flags: waituntilterminated; Check: VCRedistNeedsInstallAndFileExists
Filename: "{app}\FolkTool.exe"; Description: "{cm:LaunchProgram,FolkTool}"; Flags: nowait postinstall skipifsilent

[Code]
var
  DownloadPage: TDownloadWizardPage;

function VCRedistNeedsInstall: Boolean;
var
  Installed: Cardinal;
begin
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
  // Check 32-bit registry hive as fallback
  if RegQueryDWordValue(HKLM32, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) then
  begin
    if Installed = 1 then
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
