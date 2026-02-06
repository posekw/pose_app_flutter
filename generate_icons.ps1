
Add-Type -AssemblyName System.Drawing
$srcPath = "$PSScriptRoot\assets\images\icon_solid.png"
$destPath = "$PSScriptRoot\ios\Runner\Assets.xcassets\AppIcon.appiconset"

Write-Host "Source: $srcPath"
if (-not (Test-Path $srcPath)) {
    Write-Error "Source file not found!"
    exit 1
}

$src = [System.Drawing.Image]::FromFile($srcPath)
Write-Host "Source Loaded. Size: $($src.Width)x$($src.Height)"

if (-not (Test-Path $destPath)) {
    New-Item -ItemType Directory -Force -Path $destPath | Out-Null
}

function Resize-Image {
    param(
        [int]$w,
        [int]$h,
        [string]$name
    )
    $targetPath = Join-Path $destPath $name
    if ($src.Width -eq $w -and $src.Height -eq $h) {
       $src.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
       Write-Host "Saved Exact: $name"
       return
    }
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($src, 0, 0, $w, $h)
    $bmp.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Generated: $name"
}

Resize-Image -w 20 -h 20 -name 'Icon-App-20x20@1x.png'
Resize-Image -w 40 -h 40 -name 'Icon-App-20x20@2x.png'
Resize-Image -w 60 -h 60 -name 'Icon-App-20x20@3x.png'
Resize-Image -w 29 -h 29 -name 'Icon-App-29x29@1x.png'
Resize-Image -w 58 -h 58 -name 'Icon-App-29x29@2x.png'
Resize-Image -w 87 -h 87 -name 'Icon-App-29x29@3x.png'
Resize-Image -w 40 -h 40 -name 'Icon-App-40x40@1x.png'
Resize-Image -w 80 -h 80 -name 'Icon-App-40x40@2x.png'
Resize-Image -w 120 -h 120 -name 'Icon-App-40x40@3x.png'
Resize-Image -w 120 -h 120 -name 'Icon-App-60x60@2x.png'
Resize-Image -w 180 -h 180 -name 'Icon-App-60x60@3x.png'
Resize-Image -w 76 -h 76 -name 'Icon-App-76x76@1x.png'
Resize-Image -w 152 -h 152 -name 'Icon-App-76x76@2x.png'
Resize-Image -w 167 -h 167 -name 'Icon-App-83.5x83.5@2x.png'
Resize-Image -w 1024 -h 1024 -name 'Icon-App-1024x1024@1x.png'

$src.Dispose()
Write-Host "All icons generated successfully."
