#ifndef MyAppName
  #define MyAppName "FolkTool"
#endif
#ifndef MyAppVersion
  #define MyAppVersion "1.7.0"
#endif
#ifndef MyAppPublisher
  #define MyAppPublisher "FolkTool"
#endif
#ifndef MyAppRepoUrl
  #define MyAppRepoUrl "https://github.com/LyraVoid/FolkTool"
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
AppPublisherURL={#MyAppRepoUrl}
AppSupportURL={#MyAppRepoUrl}/issues
AppUpdatesURL={#MyAppRepoUrl}/releases
AppCopyright=Copyright (C) 2026 Matsuzaka Yuki (GPL-3.0)
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} Windows Setup
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}
VersionInfoCopyright=Copyright (C) 2026 Matsuzaka Yuki (GPL-3.0)
DefaultDirName={#DefaultInstallDir}
DisableDirPage=no
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=no
DisableWelcomePage=no
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
UninstallDisplayName={#MyAppName}
CloseApplications=yes
CloseApplicationsFilter=FolkTool.exe,adb.exe,fastboot.exe,kptools.exe
RestartApplications=no
#ifdef EnableSigning
SignedUninstaller=yes
SignTool=folktool_sign
#endif

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
Name: "{group}\{cm:UninstallProgram,{#StringChange(MyAppName, '&', '&&')}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[UninstallDelete]
Type: files; Name: "{app}\BUILD_INFO.txt"

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "{cm:VCRedistInstalling}"; Flags: waituntilterminated; Check: VCRedistNeedsInstallAndFileExists
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent unchecked

[Code]
const
  UninstallRegKey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{A1B2C3D4-E5F6-4789-A0B1-C2D3E4F5A6B7}_is1';

var
  DownloadPage: TDownloadWizardPage;
  InstallModePage: TInputOptionWizardPage;
  ResetSettingsCheckBox: TNewCheckBox;
  ExistingInstallFound: Boolean;
  ExistingInstallDir: String;
  ExistingInstallVer: String;

function HasCmdSwitch(const SwitchName: String): Boolean;
var
  I: Integer;
  Target: String;
begin
  Result := False;
  Target := Uppercase(SwitchName);
  for I := 1 to ParamCount do
  begin
    if Uppercase(ParamStr(I)) = Target then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function EscapePsSingleQuoted(const Value: String): String;
begin
  Result := Value;
  StringChange(Result, '''', '''''');
end;

function QueryExistingInstallation(var VersionOut, DirOut: String): Boolean;
var
  Ver, Loc: String;
begin
  Result := False;
  VersionOut := '';
  DirOut := '';

  if RegQueryStringValue(HKLM64, UninstallRegKey, 'InstallLocation', Loc) or
     RegQueryStringValue(HKLM64, UninstallRegKey, 'Inno Setup: App Path', Loc) then
  begin
    RegQueryStringValue(HKLM64, UninstallRegKey, 'DisplayVersion', Ver);
    VersionOut := Ver;
    DirOut := RemoveBackslashUnlessRoot(Loc);
    Result := True;
    Exit;
  end;

  if RegQueryStringValue(HKCU, UninstallRegKey, 'InstallLocation', Loc) or
     RegQueryStringValue(HKCU, UninstallRegKey, 'Inno Setup: App Path', Loc) then
  begin
    RegQueryStringValue(HKCU, UninstallRegKey, 'DisplayVersion', Ver);
    VersionOut := Ver;
    DirOut := RemoveBackslashUnlessRoot(Loc);
    Result := True;
  end;
end;

function StopAppScopedProcesses(const AppDir: String): Boolean;
var
  NormalizedDir, PsCommand: String;
  ResultCode: Integer;
begin
  Result := True;
  NormalizedDir := RemoveBackslashUnlessRoot(Trim(AppDir));
  if NormalizedDir = '' then Exit;

  // Terminate only app/helper processes executing out of FolkTool's install directory,
  // excluding the Inno Setup uninstaller stub itself and external system tools.
  PsCommand :=
    '-NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "' +
    '$dir = ''' + EscapePsSingleQuoted(NormalizedDir) + '''.TrimEnd(''\'') + ''\''; ' +
    '$procs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($dir, [System.StringComparison]::OrdinalIgnoreCase) -and ($_.Name -notlike ''unins*.exe'') }; ' +
    'foreach ($p in $procs) { try { $proc = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue; if ($proc) { $null = $proc.CloseMainWindow() } } catch {} }; ' +
    'Start-Sleep -Milliseconds 1500; ' +
    '$remain = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($dir, [System.StringComparison]::OrdinalIgnoreCase) -and ($_.Name -notlike ''unins*.exe'') }; ' +
    'foreach ($p in $remain) { try { Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue } catch {} }; ' +
    'Start-Sleep -Milliseconds 500; ' +
    '$still = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($dir, [System.StringComparison]::OrdinalIgnoreCase) -and ($_.Name -notlike ''unins*.exe'') }; ' +
    'if ($still) { exit 1 } else { exit 0 }"';

  if Exec('powershell.exe', PsCommand, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    Result := (ResultCode = 0);
end;

function BackupSettingsIfPresent: String;
var
  PrefsFile, BackupDir, Stamp, DestFile: String;
begin
  Result := '';
  PrefsFile := ExpandConstant('{userappdata}\FolkTool\FolkTool\shared_preferences.json');
  if not FileExists(PrefsFile) then Exit;

  BackupDir := ExpandConstant('{userdocs}\FolkTool\backup');
  if not DirExists(BackupDir) then
    ForceDirectories(BackupDir);

  Stamp := GetDateTimeString('yyyymmdd_hhnnss', '-', '-');
  DestFile := BackupDir + '\settings_backup_' + Stamp + '.json';
  if FileCopy(PrefsFile, DestFile, False) then
    Result := DestFile;
end;

procedure PurgeFolkToolAppData(const DeleteLogs: Boolean);
var
  LogsDir, DocsRoot: String;
  FindRec: TFindRec;
begin
  DelTree(ExpandConstant('{userappdata}\FolkTool'), True, True, True);
  DelTree(ExpandConstant('{localappdata}\FolkTool'), True, True, True);
  DelTree(ExpandConstant('{userdocs}\FolkTool\drivers'), True, True, True);

  if DeleteLogs then
  begin
    LogsDir := ExpandConstant('{userdocs}\FolkTool\logs');
    if DirExists(LogsDir) then
    begin
      if FindFirst(LogsDir + '\*', FindRec) then
      begin
        try
          repeat
            if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
            begin
              if (Uppercase(ExtractFileExt(FindRec.Name)) = '.TXT') or
                 (Uppercase(ExtractFileExt(FindRec.Name)) = '.LOG') then
              begin
                DeleteFile(LogsDir + '\' + FindRec.Name);
              end;
            end;
          until not FindNext(FindRec);
        finally
          FindClose(FindRec);
        end;
      end;
      RemoveDir(LogsDir);
    end;
  end;

  DocsRoot := ExpandConstant('{userdocs}\FolkTool');
  RemoveDir(DocsRoot); // Succeeds only if empty; preserves patched/ and backup/.
end;

function TryRemoveAppSubDir(const DirNorm, Name: String; var ErrorDetail: String): Boolean;
var
  SubDirPath: String;
begin
  Result := True;
  SubDirPath := DirNorm + '\' + Name;
  if DirExists(SubDirPath) then
  begin
    if not DelTree(SubDirPath, True, True, True) then
    begin
      Result := False;
      ErrorDetail := SubDirPath;
    end;
  end;
end;

function TryRemoveAppRootFile(const DirNorm, Name: String; var ErrorDetail: String): Boolean;
var
  RootFilePath: String;
begin
  Result := True;
  RootFilePath := DirNorm + '\' + Name;
  if FileExists(RootFilePath) then
  begin
    if not DeleteFile(RootFilePath) then
    begin
      Result := False;
      ErrorDetail := RootFilePath;
    end;
  end;
end;

function RemoveAppOwnedFilesForCleanInstall(const TargetDir: String; var ErrorDetail: String): Boolean;
var
  DirNorm: String;
begin
  Result := True;
  ErrorDetail := '';
  DirNorm := RemoveBackslashUnlessRoot(TargetDir);
  if (DirNorm = '') or (not DirExists(DirNorm)) then Exit;

  if (not TryRemoveAppSubDir(DirNorm, 'data', ErrorDetail)) or
     (not TryRemoveAppSubDir(DirNorm, 'bin', ErrorDetail)) or
     (not TryRemoveAppSubDir(DirNorm, 'apk', ErrorDetail)) or
     (not TryRemoveAppSubDir(DirNorm, 'assets', ErrorDetail)) or
     (not TryRemoveAppSubDir(DirNorm, 'kp_versions', ErrorDetail)) or
     (not TryRemoveAppSubDir(DirNorm, 'redist', ErrorDetail)) or
     (not TryRemoveAppRootFile(DirNorm, 'FolkTool.exe', ErrorDetail)) or
     (not TryRemoveAppRootFile(DirNorm, 'flutter_windows.dll', ErrorDetail)) or
     (not TryRemoveAppRootFile(DirNorm, 'url_launcher_windows_plugin.dll', ErrorDetail)) or
     (not TryRemoveAppRootFile(DirNorm, 'msvcp140.dll', ErrorDetail)) or
     (not TryRemoveAppRootFile(DirNorm, 'vcruntime140.dll', ErrorDetail)) or
     (not TryRemoveAppRootFile(DirNorm, 'vcruntime140_1.dll', ErrorDetail)) or
     (not TryRemoveAppRootFile(DirNorm, 'icudtl.dat', ErrorDetail)) or
     (not TryRemoveAppRootFile(DirNorm, 'BUILD_INFO.txt', ErrorDetail)) then
  begin
    Result := False;
  end;
end;

function VCRedistNeedsInstall: Boolean;
var
  Installed: Cardinal;
  VerStr: String;
begin
  if FileExists(ExpandConstant('{sys}\msvcp140.dll')) and
     FileExists(ExpandConstant('{sys}\vcruntime140_1.dll')) and
     FileExists(ExpandConstant('{sys}\vcruntime140.dll')) then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
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
    '"$s = Get-AuthenticodeSignature -LiteralPath ''' + EscapePsSingleQuoted(FilePath) + '''; ' +
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

procedure UpdateResetCheckBoxState(Sender: TObject);
var
  IsCleanSelected: Boolean;
begin
  if ResetSettingsCheckBox = nil then Exit;
  IsCleanSelected := (InstallModePage.SelectedValueIndex = 1);
  ResetSettingsCheckBox.Enabled := IsCleanSelected;
  if not IsCleanSelected then
    ResetSettingsCheckBox.Checked := False;
end;

procedure InitializeWizard;
var
  InstalledNote: String;
begin
  ExistingInstallFound := QueryExistingInstallation(ExistingInstallVer, ExistingInstallDir);

  if ExistingInstallFound then
  begin
    if ExistingInstallVer <> '' then
      InstalledNote := 'Detected existing FolkTool v' + ExistingInstallVer + ' at ' + ExistingInstallDir + '.'
    else
      InstalledNote := 'Detected existing FolkTool installation at ' + ExistingInstallDir + '.';
  end
  else
    InstalledNote := 'Choose how you want to install FolkTool.';

  InstallModePage := CreateInputOptionPage(
    wpWelcome,
    'Installation Mode',
    'Upgrade, Repair, or Clean Install',
    InstalledNote + #13#10 +
    'Upgrade/Repair preserves your preferences, logs, backups, and patched images.',
    True,
    False
  );
  InstallModePage.Add('Upgrade or Repair existing installation (Recommended - keeps settings & user data)');
  InstallModePage.Add('Clean Installation - replace application binaries and bundled tools cleanly');
  InstallModePage.SelectedValueIndex := 0;
  InstallModePage.CheckListBox.Height := ScaleY(88);
  InstallModePage.CheckListBox.OnClickCheck := @UpdateResetCheckBoxState;

  ResetSettingsCheckBox := TNewCheckBox.Create(InstallModePage);
  ResetSettingsCheckBox.Parent := InstallModePage.Surface;
  ResetSettingsCheckBox.Top := InstallModePage.CheckListBox.Top + InstallModePage.CheckListBox.Height + ScaleY(10);
  ResetSettingsCheckBox.Left := InstallModePage.CheckListBox.Left;
  ResetSettingsCheckBox.Width := InstallModePage.SurfaceWidth - ScaleX(8);
  ResetSettingsCheckBox.Height := ScaleY(36);
  ResetSettingsCheckBox.Caption := 'Also reset app preferences & driver cache in AppData (creates a backup in Documents\FolkTool\backup first)';
  ResetSettingsCheckBox.Checked := False;
  ResetSettingsCheckBox.Enabled := False;

  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  if (InstallModePage <> nil) and (PageID = InstallModePage.ID) then
  begin
    Result := not ExistingInstallFound;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  VCRedistUrl: String;
  Answer: Integer;
begin
  Result := True;

  if (InstallModePage <> nil) and (CurPageID = InstallModePage.ID) then
  begin
    if (InstallModePage.SelectedValueIndex = 1) and ResetSettingsCheckBox.Checked then
    begin
      Answer := MsgBox(
        'Clean Installation with Settings Reset:' + #13#10#13#10 +
        '* Application binaries, DLLs, and bundled tools under the install folder will be replaced.' + #13#10 +
        '* App preferences (%APPDATA%\FolkTool) and extracted driver installers will be cleared (a backup of settings will be saved to Documents\FolkTool\backup).' + #13#10 +
        '* Your boot images, backups, patched outputs, and logs will NOT be deleted.' + #13#10#13#10 +
        'Proceed with resetting FolkTool settings?',
        mbConfirmation, MB_YESNO or MB_DEFBUTTON2);
      if Answer <> IDYES then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;

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

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  TargetDir: String;
begin
  Result := '';
  TargetDir := ExpandConstant('{app}');

  if CheckForMutexes('Local\FolkToolRunningMutex') and (not WizardSilent) then
  begin
    if MsgBox(
      'FolkTool is currently running.' + #13#10#13#10 +
      'Setup needs to close FolkTool and any tools running from its install folder before continuing. Close FolkTool now?',
      mbConfirmation, MB_YESNO) <> IDYES then
    begin
      Result := 'Installation cancelled because FolkTool is currently running.';
      Exit;
    end;
  end;

  if not StopAppScopedProcesses(TargetDir) then
  begin
    Result := 'FolkTool or one of its bundled tools in "' + TargetDir + '" is still running and could not be closed. Please close it and retry.';
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  TargetDir, FailedItem, BackupFile: String;
  IsCleanInstall, ShouldResetData: Boolean;
begin
  if CurStep = ssInstall then
  begin
    TargetDir := ExpandConstant('{app}');

    // Always ensure FolkTool processes inside the install folder are closed before replacing files.
    if not StopAppScopedProcesses(TargetDir) then
    begin
      RaiseException('FolkTool or one of its bundled tools in "' + TargetDir + '" is still running and could not be closed. Please close it and retry.');
    end;

    IsCleanInstall := HasCmdSwitch('/CLEANINSTALL') or
                      ((InstallModePage <> nil) and (InstallModePage.SelectedValueIndex = 1));
    ShouldResetData := HasCmdSwitch('/PURGEAPPDATA') or
                       ((ResetSettingsCheckBox <> nil) and ResetSettingsCheckBox.Checked);

    if IsCleanInstall then
    begin
      if ExistingInstallFound and (ExistingInstallDir <> '') and
         (Uppercase(ExistingInstallDir) <> Uppercase(RemoveBackslashUnlessRoot(TargetDir))) then
      begin
        StopAppScopedProcesses(ExistingInstallDir);
        if not RemoveAppOwnedFilesForCleanInstall(ExistingInstallDir, FailedItem) then
          RaiseException('Clean install failed while removing previous application files: ' + FailedItem);
      end;

      if not RemoveAppOwnedFilesForCleanInstall(TargetDir, FailedItem) then
        RaiseException('Clean install failed because an application file is locked or protected: ' + FailedItem);

      if ShouldResetData then
      begin
        BackupFile := BackupSettingsIfPresent;
        if BackupFile <> '' then
          Log('Backed up FolkTool settings before reset to: ' + BackupFile);
        PurgeFolkToolAppData(False);
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  PurgeData: Boolean;
  AppDir: String;
  RemainingFiles: String;
begin
  Log('CurUninstallStepChanged phase=' + IntToStr(Ord(CurUninstallStep)));
  if CurUninstallStep = usUninstall then
  begin
    AppDir := ExpandConstant('{app}');
    Log('Uninstall stopping app-scoped processes in: ' + AppDir);
    if not StopAppScopedProcesses(AppDir) then
    begin
      Log('Warning: one or more FolkTool processes remained active prior to uninstall.');
    end;

    PurgeData := False;
    if UninstallSilent then
    begin
      PurgeData := HasCmdSwitch('/PURGEAPPDATA');
    end
    else
    begin
      PurgeData := (MsgBox(
        'Do you also want to remove FolkTool settings, driver cache, and saved log files?' + #13#10#13#10 +
        'Will remove:' + #13#10 +
        '  * App settings (%APPDATA%\FolkTool and %LOCALAPPDATA%\FolkTool)' + #13#10 +
        '  * Extracted driver cache (Documents\FolkTool\drivers)' + #13#10 +
        '  * Log files (.txt / .log in Documents\FolkTool\logs)' + #13#10#13#10 +
        'Will NEVER remove:' + #13#10 +
        '  * Boot images, backups (Documents\FolkTool\backup), or patched files (Documents\FolkTool\patched)' + #13#10 +
        '  * Shared Windows USB/ADB system drivers',
        mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES);
    end;

    if PurgeData then
    begin
      Log('Uninstall PurgeData=true');
      PurgeFolkToolAppData(True);
    end
    else
      Log('Uninstall PurgeData=false');
  end
  else if CurUninstallStep = usPostUninstall then
  begin
    AppDir := ExpandConstant('{app}');
    Log('PostUninstall checking directory: ' + AppDir);
    if AppDir <> '' then
      RemoveDir(AppDir); // Clean empty root directory if no user-created files remain.

    RemainingFiles := '';
    if FileExists(AppDir + '\FolkTool.exe') then
      RemainingFiles := RemainingFiles + AppDir + '\FolkTool.exe' + #13#10;
    if FileExists(AppDir + '\flutter_windows.dll') then
      RemainingFiles := RemainingFiles + AppDir + '\flutter_windows.dll' + #13#10;

    if RemainingFiles <> '' then
    begin
      Log('Incomplete uninstallation detected; locked files remain:' + #13#10 + RemainingFiles);
      if not UninstallSilent then
      begin
        MsgBox(
          'Some FolkTool application files could not be removed immediately because they were in use:' + #13#10#13#10 +
          RemainingFiles + #13#10 +
          'Please close any remaining tools and restart Windows to complete removal.',
          mbError, MB_OK);
      end;
    end;
  end;
end;