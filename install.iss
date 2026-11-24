; Parameterized wrapper around installer.iss for staged release builds.
#ifndef MyAppVersion
  #define MyAppVersion "1.7.0"
#endif
#define SourceDir "release\FolkTool-Windows-Release"
#define OutputDir "release"
#define OutputBaseFilename "FolkTool-Setup-v" + MyAppVersion
#define DefaultInstallDir "{autopf}\FolkTool"
#define CompressionAlgo "lzma2"

#include "installer.iss"
