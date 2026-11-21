param([Parameter(Mandatory=$true)][string]$Source)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$mediaPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Media'
$sourceImage = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $Source).Path)
$iconSize = 32
while ($iconSize -lt [Math]::Max($sourceImage.Width,$sourceImage.Height) -and $iconSize -lt 256) { $iconSize *= 2 }
$icon = [System.Drawing.Bitmap]::new($iconSize,$iconSize,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($icon)
try {
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $scale = [Math]::Min($iconSize / $sourceImage.Width,$iconSize / $sourceImage.Height)
    $iconWidth = [int][Math]::Round($sourceImage.Width * $scale)
    $iconHeight = [int][Math]::Round($sourceImage.Height * $scale)
    $graphics.DrawImage($sourceImage,[int](($iconSize-$iconWidth)/2),[int](($iconSize-$iconHeight)/2),$iconWidth,$iconHeight)
    $icon.Save((Join-Path $mediaPath 'Icon.png'),[System.Drawing.Imaging.ImageFormat]::Png)
    $writer = [System.IO.BinaryWriter]::new([System.IO.File]::Create((Join-Path $mediaPath 'Icon.tga')))
    try {
        $header = [byte[]]::new(18)
        $header[2]=2; $header[16]=32; $header[17]=8
        [BitConverter]::GetBytes([uint16]$iconSize).CopyTo($header,12)
        [BitConverter]::GetBytes([uint16]$iconSize).CopyTo($header,14)
        $writer.Write($header)
        for ($row=$iconSize-1; $row -ge 0; $row--) {
            for ($column=0; $column -lt $iconSize; $column++) {
                $pixel=$icon.GetPixel($column,$row)
                $writer.Write([byte]$pixel.B); $writer.Write([byte]$pixel.G)
                $writer.Write([byte]$pixel.R); $writer.Write([byte]$pixel.A)
            }
        }
    } finally { $writer.Dispose() }
} finally { $graphics.Dispose(); $icon.Dispose(); $sourceImage.Dispose() }
Write-Output "Created Media/Icon.tga and Media/Icon.png ($($iconSize)x$($iconSize))."
