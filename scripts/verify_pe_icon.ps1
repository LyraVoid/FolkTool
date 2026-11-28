param(
  [Parameter(Mandatory = $true)]
  [string]$BinaryPath,
  [string]$IconPath = "assets\icons\icon.ico"
)

$ErrorActionPreference = "Stop"

$icoBytes = [IO.File]::ReadAllBytes((Resolve-Path $IconPath))
$iconCount = [BitConverter]::ToUInt16($icoBytes, 4)
if ($iconCount -lt 5) {
  throw "$IconPath contains only $iconCount image(s); expected multi-resolution icon (16, 32, 48, 64, 256+)."
}

$sha = [System.Security.Cryptography.SHA256]::Create()
$expectedEntries = @()
for ($i = 0; $i -lt $iconCount; $i++) {
  $dirOff = 6 + ($i * 16)
  $w = $icoBytes[$dirOff]
  if ($w -eq 0) { $w = 256 }
  $h = $icoBytes[$dirOff + 1]
  if ($h -eq 0) { $h = 256 }
  $payloadSize = [BitConverter]::ToUInt32($icoBytes, $dirOff + 8)
  $payloadOffset = [BitConverter]::ToUInt32($icoBytes, $dirOff + 12)
  $payload = New-Object byte[] $payloadSize
  [Array]::Copy($icoBytes, $payloadOffset, $payload, 0, $payloadSize)
  $hash = ([BitConverter]::ToString($sha.ComputeHash($payload))).Replace("-", "").ToLowerInvariant()
  $expectedEntries += [PSCustomObject]@{ Size = "${w}x${h}"; Width = $w; Hash = $hash }
}

$presentWidths = $expectedEntries.Width
foreach ($req in @(16, 32, 48, 64, 256)) {
  if ($presentWidths -notcontains $req) {
    throw "$IconPath is missing required resolution ${req}x${req}."
  }
}

Add-Type @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Security.Cryptography;

public class PeIconAudit {
  private delegate bool EnumResNameDelegate(IntPtr hModule, IntPtr lpszType, IntPtr lpszName, IntPtr lParam);
  [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
  private static extern IntPtr LoadLibraryExW(string lpFileName, IntPtr hFile, uint dwFlags);
  [DllImport("kernel32.dll", SetLastError = true)]
  private static extern bool FreeLibrary(IntPtr hModule);
  [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
  private static extern bool EnumResourceNamesW(IntPtr hModule, IntPtr lpType, EnumResNameDelegate lpEnumFunc, IntPtr lParam);
  [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
  private static extern IntPtr FindResourceW(IntPtr hModule, IntPtr lpName, IntPtr lpType);
  [DllImport("kernel32.dll", SetLastError = true)]
  private static extern IntPtr LoadResource(IntPtr hModule, IntPtr hResInfo);
  [DllImport("kernel32.dll")]
  private static extern IntPtr LockResource(IntPtr hResData);
  [DllImport("kernel32.dll", SetLastError = true)]
  private static extern uint SizeofResource(IntPtr hModule, IntPtr hResInfo);

  public static List<string> GetRtIconHashes(string exePath) {
    var hashes = new List<string>();
    IntPtr hMod = LoadLibraryExW(exePath, IntPtr.Zero, 0x00000002);
    if (hMod == IntPtr.Zero) throw new InvalidOperationException("LoadLibraryExW failed: " + Marshal.GetLastWin32Error());
    try {
      IntPtr rtIcon = new IntPtr(3);
      EnumResNameDelegate cb = (h, t, name, lParam) => {
        IntPtr hRes = FindResourceW(h, name, rtIcon);
        if (hRes != IntPtr.Zero) {
          uint size = SizeofResource(h, hRes);
          IntPtr hData = LoadResource(h, hRes);
          IntPtr pData = LockResource(hData);
          if (pData != IntPtr.Zero && size > 0) {
            byte[] bytes = new byte[size];
            Marshal.Copy(pData, bytes, 0, (int)size);
            using (var sha = SHA256.Create()) {
              hashes.Add(BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant());
            }
          }
        }
        return true;
      };
      EnumResourceNamesW(hMod, rtIcon, cb, IntPtr.Zero);
      GC.KeepAlive(cb);
    } finally {
      FreeLibrary(hMod);
    }
    return hashes;
  }
}
"@

$fullBinary = (Resolve-Path $BinaryPath).Path
$iconHashes = [PeIconAudit]::GetRtIconHashes($fullBinary)
Write-Host "$BinaryPath RT_ICON SHA-256s ($($iconHashes.Count) frames): $($iconHashes -join ', ')"
$missing = @()
foreach ($entry in $expectedEntries) {
  if ($iconHashes -notcontains $entry.Hash) {
    $missing += "$($entry.Size) ($($entry.Hash))"
  }
}
if ($missing.Count -gt 0) {
  throw "$BinaryPath is missing embedded icon frame(s) from ${IconPath}: $($missing -join ', ')"
}
Write-Host "Verified $BinaryPath embeds all $($expectedEntries.Count) canonical resolutions from $IconPath ($($expectedEntries.Size -join ', '))"