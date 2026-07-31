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

[Files]
Source: "release\FolkTool-Windows-Release\FolkTool.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "release\FolkTool-Windows-Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "release\FolkTool-Windows-Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "release\FolkTool-Windows-Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "kp_versions\*"; DestDir: "{app}\kp_versions"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\FolkTool"; Filename: "{app}\FolkTool.exe"
Name: "{group}\{cm:UninstallProgram,FolkTool}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\FolkTool"; Filename: "{app}\FolkTool.exe"

[Run]
Filename: "{app}\FolkTool.exe"; Description: "{cm:LaunchProgram,FolkTool}"; Flags: nowait postinstall skipifsilent
