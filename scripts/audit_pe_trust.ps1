param(
  [Parameter(Mandatory = $true)]
  [string[]]$Targets,
  [switch]$RequireValidSignature,
  [string]$SigntoolPath = ""
)

$ErrorActionPreference = "Stop"

if ($RequireValidSignature -and [string]::IsNullOrWhiteSpace($SigntoolPath)) {
  $SigntoolPath = Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe" -ErrorAction SilentlyContinue |
    Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
  if (-not $SigntoolPath) {
    throw "signtool.exe not found while -RequireValidSignature was requested."
  }
}

$now = Get-Date
foreach ($target in $Targets) {
  if (-not (Test-Path -LiteralPath $target)) {
    throw "Audit target not found: $target"
  }

  $sig = Get-AuthenticodeSignature -LiteralPath $target
  $subject = if ($sig.SignerCertificate) { $sig.SignerCertificate.Subject } else { "<none>" }
  $issuer = if ($sig.SignerCertificate) { $sig.SignerCertificate.Issuer } else { "<none>" }
  $notAfter = if ($sig.SignerCertificate) { $sig.SignerCertificate.NotAfter.ToString("u") } else { "<n/a>" }
  $tsIssuer = if ($sig.TimeStamperCertificate) { $sig.TimeStamperCertificate.Subject } else { "<none>" }

  Write-Host ("PE Trust Audit | {0} | Status={1} | Subject={2} | Issuer={3} | Expires={4} | Timestamp={5}" -f `
    $target, $sig.Status, $subject, $issuer, $notAfter, $tsIssuer)

  if ($RequireValidSignature) {
    if ($sig.Status -ne "Valid") {
      throw "Signature status for $target is $($sig.Status), expected Valid."
    }
    if (-not $sig.TimeStamperCertificate) {
      throw "Missing RFC 3161 timestamp certificate on $target."
    }
    if ($sig.SignerCertificate.NotAfter -le $now) {
      throw "Signing certificate on $target is expired ($notAfter)."
    }
    & $SigntoolPath verify /pa /v $target | Out-Host
    if ($LASTEXITCODE -ne 0) {
      throw "signtool verify /pa failed for $target with exit code $LASTEXITCODE."
    }
  }
}