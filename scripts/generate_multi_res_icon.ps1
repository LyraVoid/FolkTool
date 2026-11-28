param(
  [string]$IconPath = "assets\icons\icon.ico"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$fullPath = (Resolve-Path -LiteralPath $IconPath).Path
$bytes = [IO.File]::ReadAllBytes($fullPath)
if ($bytes.Length -lt 22) {
  throw "Invalid ICO file: $fullPath"
}

$count = [BitConverter]::ToUInt16($bytes, 4)
$existingSizes = New-Object System.Collections.Generic.List[int]
$bestIdx = 0
$bestWidth = 0
for ($i = 0; $i -lt $count; $i++) {
  $off = 6 + ($i * 16)
  $w = [int]$bytes[$off]
  if ($w -eq 0) { $w = 256 }
  $existingSizes.Add($w)
  if ($w -gt $bestWidth) {
    $bestWidth = $w
    $bestIdx = $i
  }
}

$required = @(16, 32, 48, 64, 256)
$hasAll = $true
foreach ($req in $required) {
  if (-not $existingSizes.Contains($req)) {
    $hasAll = $false
    break
  }
}

if ($hasAll) {
  Write-Host "Icon $IconPath already contains required resolutions ($($existingSizes -join ', '))."
  exit 0
}

$bestOff = 6 + ($bestIdx * 16)
$srcSize = [BitConverter]::ToUInt32($bytes, $bestOff + 8)
$srcOffset = [BitConverter]::ToUInt32($bytes, $bestOff + 12)
$srcPayload = New-Object byte[] $srcSize
[Array]::Copy($bytes, $srcOffset, $srcPayload, 0, $srcSize)

$ms = New-Object System.IO.MemoryStream(, $srcPayload)
$srcBmp = $null
try {
  $srcImg = [System.Drawing.Image]::FromStream($ms)
  $srcBmp = New-Object System.Drawing.Bitmap($srcImg)
  $srcImg.Dispose()
} catch {
  $ms.Dispose()
  $tmpIco = New-Object System.IO.MemoryStream(, $bytes)
  $icoObj = New-Object System.Drawing.Icon($tmpIco, 256, 256)
  $srcBmp = $icoObj.ToBitmap()
  $icoObj.Dispose()
  $tmpIco.Dispose()
} finally {
  if ($ms) { $ms.Dispose() }
}

function New-IcoDibFrameBytes([System.Drawing.Bitmap]$bmp) {
  $w = $bmp.Width
  $h = $bmp.Height
  $xorBytes = New-Object byte[] ($w * $h * 4)
  $maskStride = [int]([Math]::Ceiling($w / 32.0) * 4)
  $andBytes = New-Object byte[] ($maskStride * $h)

  for ($y = 0; $y -lt $h; $y++) {
    $bottomUpY = $h - 1 - $y
    for ($x = 0; $x -lt $w; $x++) {
      $c = $bmp.GetPixel($x, $y)
      $idx = ($bottomUpY * $w + $x) * 4
      $xorBytes[$idx + 0] = $c.B
      $xorBytes[$idx + 1] = $c.G
      $xorBytes[$idx + 2] = $c.R
      $xorBytes[$idx + 3] = $c.A
      if ($c.A -lt 128) {
        $maskByteIdx = ($bottomUpY * $maskStride) + [int][Math]::Floor($x / 8)
        $andBytes[$maskByteIdx] = $andBytes[$maskByteIdx] -bor (0x80 -shr ($x % 8))
      }
    }
  }

  $outMs = New-Object System.IO.MemoryStream
  $bw = New-Object System.IO.BinaryWriter($outMs)
  $bw.Write([uint32]40)
  $bw.Write([int32]$w)
  $bw.Write([int32]($h * 2))
  $bw.Write([uint16]1)
  $bw.Write([uint16]32)
  $bw.Write([uint32]0)
  $bw.Write([uint32]($xorBytes.Length + $andBytes.Length))
  $bw.Write([int32]0)
  $bw.Write([int32]0)
  $bw.Write([uint32]0)
  $bw.Write([uint32]0)
  $bw.Flush()
  $outMs.Write($xorBytes, 0, $xorBytes.Length)
  $outMs.Write($andBytes, 0, $andBytes.Length)
  [byte[]]$res = $outMs.ToArray()
  $bw.Dispose()
  $outMs.Dispose()
  # Unary comma keeps byte[] intact without PowerShell pipeline unrolling into Object[].
  return ,$res
}

$targetSizes = @(16, 24, 32, 48, 64, 128, 256)
$frames = @()

foreach ($sz in $targetSizes) {
  $resized = New-Object System.Drawing.Bitmap($sz, $sz, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($resized)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.DrawImage($srcBmp, 0, 0, $sz, $sz)
  $g.Dispose()

  [byte[]]$payload = $null
  if ($sz -eq 256) {
    $pngMs = New-Object System.IO.MemoryStream
    $resized.Save($pngMs, [System.Drawing.Imaging.ImageFormat]::Png)
    $payload = $pngMs.ToArray()
    $pngMs.Dispose()
  } else {
    $payload = New-IcoDibFrameBytes $resized
  }
  $resized.Dispose()
  $frames += [PSCustomObject]@{ Size = $sz; Payload = $payload }
}

$srcBmp.Dispose()

$outStream = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.BinaryWriter($outStream)
$writer.Write([uint16]0)
$writer.Write([uint16]1)
$writer.Write([uint16]$frames.Count)

$offset = 6 + (16 * $frames.Count)
foreach ($frame in $frames) {
  $dim = if ($frame.Size -eq 256) { [byte]0 } else { [byte]$frame.Size }
  $writer.Write($dim)
  $writer.Write($dim)
  $writer.Write([byte]0)
  $writer.Write([byte]0)
  $writer.Write([uint16]1)
  $writer.Write([uint16]32)
  $writer.Write([uint32]$frame.Payload.Length)
  $writer.Write([uint32]$offset)
  $offset += $frame.Payload.Length
}
$writer.Flush()
foreach ($frame in $frames) {
  [byte[]]$buf = $frame.Payload
  $outStream.Write($buf, 0, $buf.Length)
}
[byte[]]$finalBytes = $outStream.ToArray()
[IO.File]::WriteAllBytes($fullPath, $finalBytes)
$writer.Dispose()
$outStream.Dispose()

# Sanity-check every frame header (BITMAPINFOHEADER=40 or PNG signature).
for ($i = 0; $i -lt $frames.Count; $i++) {
  $dirOff = 6 + ($i * 16)
  $imgOff = [BitConverter]::ToUInt32($finalBytes, $dirOff + 12)
  $magic = [BitConverter]::ToUInt32($finalBytes, $imgOff)
  if ($magic -ne 40 -and $magic -ne 0x474E5089) {
    throw "Generated ICO frame $i has invalid magic header 0x$($magic.ToString('X8')) at offset $imgOff"
  }
}

Write-Host "Generated multi-resolution icon at $IconPath ($($targetSizes -join ', '), $($finalBytes.Length) bytes)."