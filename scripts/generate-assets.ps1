$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$iconDir = Join-Path $root "assets\icons"
$storeDir = Join-Path $root "store-assets"

New-Item -ItemType Directory -Force -Path $iconDir | Out-Null
New-Item -ItemType Directory -Force -Path $storeDir | Out-Null

function New-Brush($hex) {
  [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-RoundPen($hex, $width) {
  $pen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $pen
}

function New-RoundedPath($x, $y, $width, $height, $radius) {
  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $diameter = $radius * 2
  $path.AddArc($x, $y, $diameter, $diameter, 180, 90)
  $path.AddArc($x + $width - $diameter, $y, $diameter, $diameter, 270, 90)
  $path.AddArc($x + $width - $diameter, $y + $height - $diameter, $diameter, $diameter, 0, 90)
  $path.AddArc($x, $y + $height - $diameter, $diameter, $diameter, 90, 90)
  $path.CloseFigure()
  $path
}

function Draw-Text($graphics, $text, $font, $brush, $rect, $align, $lineAlign) {
  $format = [System.Drawing.StringFormat]::new()
  $format.Alignment = [Enum]::Parse([System.Drawing.StringAlignment], $align)
  $format.LineAlignment = [Enum]::Parse([System.Drawing.StringAlignment], $lineAlign)
  $format.Trimming = [System.Drawing.StringTrimming]::EllipsisCharacter
  $graphics.DrawString($text, $font, $brush, $rect, $format)
  $format.Dispose()
}

function Save-Png($bitmap, $targetPath) {
  $bitmap.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
}

function New-Icon($size, $targetPath) {
  $bitmap = [System.Drawing.Bitmap]::new($size, $size)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  $graphics.Clear([System.Drawing.Color]::Transparent)
  $graphics.ScaleTransform($size / 128.0, $size / 128.0)

  $blue = "#08AEEA"
  $linePen = New-RoundPen $blue 8
  $finePen = New-RoundPen $blue 5
  $fill = New-Brush $blue

  $body = New-RoundedPath 12 42 72 50 12
  $graphics.DrawPath($linePen, $body)

  $graphics.DrawLine($linePen, 33, 42, 24, 29)
  $graphics.DrawLine($linePen, 56, 42, 68, 29)
  $graphics.DrawLine($linePen, 29, 92, 29, 99)
  $graphics.DrawLine($linePen, 67, 92, 67, 99)

  $graphics.DrawLine($linePen, 28, 61, 43, 58)
  $graphics.DrawLine($linePen, 58, 58, 73, 61)

  $mouth = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $mouth.AddBezier(39, 75, 43, 84, 50, 84, 53, 75)
  $mouth.AddBezier(53, 75, 57, 84, 64, 84, 68, 75)
  $graphics.DrawPath($finePen, $mouth)

  $graphics.DrawLine($linePen, 101, 21, 94, 74)
  $graphics.DrawLine($linePen, 87, 79, 100, 81)
  $graphics.DrawLine($linePen, 86, 88, 99, 91)

  $broom = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $broom.StartFigure()
  $broom.AddBezier(87, 84, 80, 86, 77, 99, 72, 103)
  $broom.AddBezier(72, 103, 80, 108, 94, 109, 103, 106)
  $broom.AddBezier(103, 106, 102, 99, 105, 93, 108, 88)
  $graphics.DrawPath($linePen, $broom)
  $graphics.DrawLine($finePen, 88, 101, 92, 92)
  $graphics.DrawLine($finePen, 99, 104, 101, 96)

  foreach ($center in @(@(113, 61, 9), @(116, 82, 7))) {
    $cx = $center[0]
    $cy = $center[1]
    $r = $center[2]
    $star = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $star.AddPolygon(@(
      [System.Drawing.PointF]::new($cx, $cy - $r),
      [System.Drawing.PointF]::new($cx + ($r * 0.28), $cy - ($r * 0.28)),
      [System.Drawing.PointF]::new($cx + $r, $cy),
      [System.Drawing.PointF]::new($cx + ($r * 0.28), $cy + ($r * 0.28)),
      [System.Drawing.PointF]::new($cx, $cy + $r),
      [System.Drawing.PointF]::new($cx - ($r * 0.28), $cy + ($r * 0.28)),
      [System.Drawing.PointF]::new($cx - $r, $cy),
      [System.Drawing.PointF]::new($cx - ($r * 0.28), $cy - ($r * 0.28))
    ))
    $graphics.FillPath($fill, $star)
    $star.Dispose()
  }

  Save-Png $bitmap $targetPath

  $broom.Dispose()
  $mouth.Dispose()
  $body.Dispose()
  $fill.Dispose()
  $finePen.Dispose()
  $linePen.Dispose()
  $graphics.Dispose()
  $bitmap.Dispose()
}

function New-StoreScreenshot($targetPath) {
  $bitmap = [System.Drawing.Bitmap]::new(1280, 800)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml("#F6F8FB"))

  $dark = New-Brush "#172026"
  $muted = New-Brush "#53616C"
  $white = New-Brush "#FFFFFF"
  $blue = New-Brush "#00A6D6"
  $green = New-Brush "#18B57B"
  $borderPen = New-RoundPen "#D8E0E7" 2
  $arrowPen = New-RoundPen "#18B57B" 10

  $titleFont = [System.Drawing.Font]::new("Segoe UI", 52, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $subtitleFont = [System.Drawing.Font]::new("Segoe UI", 25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $labelFont = [System.Drawing.Font]::new("Segoe UI", 22, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $bodyFont = [System.Drawing.Font]::new("Segoe UI", 24, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $monoFont = [System.Drawing.Font]::new("Consolas", 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

  Draw-Text $graphics "Bili Share Link Cleaner" $titleFont $dark ([System.Drawing.RectangleF]::new(80, 76, 780, 70)) "Near" "Near"
  Draw-Text $graphics "Copy from Bilibili. Paste a clean video link." $subtitleFont $muted ([System.Drawing.RectangleF]::new(82, 156, 760, 38)) "Near" "Near"

  $icon = [System.Drawing.Image]::FromFile((Join-Path $iconDir "icon128.png"))
  $graphics.DrawImage($icon, 1050, 70, 128, 128)
  $icon.Dispose()

  $beforeRect = [System.Drawing.RectangleF]::new(80, 265, 470, 310)
  $afterRect = [System.Drawing.RectangleF]::new(730, 265, 470, 310)

  foreach ($rect in @($beforeRect, $afterRect)) {
    $card = New-RoundedPath $rect.X $rect.Y $rect.Width $rect.Height 20
    $graphics.FillPath($white, $card)
    $graphics.DrawPath($borderPen, $card)
    $card.Dispose()
  }

  Draw-Text $graphics "Before" $labelFont $blue ([System.Drawing.RectangleF]::new(112, 300, 200, 34)) "Near" "Near"
  Draw-Text $graphics "After" $labelFont $green ([System.Drawing.RectangleF]::new(762, 300, 200, 34)) "Near" "Near"
  Draw-Text $graphics "Video title" $bodyFont $dark ([System.Drawing.RectangleF]::new(112, 365, 390, 38)) "Near" "Near"
  Draw-Text $graphics "https://www.bilibili.com/video/BV1CC5R6aEV7/?share_source=copy_web&vd_source=..." $monoFont $muted ([System.Drawing.RectangleF]::new(112, 424, 392, 96)) "Near" "Near"
  Draw-Text $graphics "https://www.bilibili.com/video/BV1CC5R6aEV7/" $monoFont $dark ([System.Drawing.RectangleF]::new(762, 405, 420, 96)) "Near" "Near"

  $arrowHead = [System.Drawing.Drawing2D.AdjustableArrowCap]::new(7, 9)
  $arrowPen.CustomEndCap = $arrowHead
  $graphics.DrawLine($arrowPen, 590, 420, 690, 420)

  $popupRect = [System.Drawing.RectangleF]::new(390, 628, 500, 88)
  $popupCard = New-RoundedPath $popupRect.X $popupRect.Y $popupRect.Width $popupRect.Height 18
  $graphics.FillPath($white, $popupCard)
  $graphics.DrawPath($borderPen, $popupCard)
  Draw-Text $graphics "Local only. No data collection." $subtitleFont $muted ([System.Drawing.RectangleF]::new(430, 654, 430, 34)) "Near" "Near"

  Save-Png $bitmap $targetPath

  $popupCard.Dispose()
  $arrowHead.Dispose()
  $arrowPen.Dispose()
  $borderPen.Dispose()
  $green.Dispose()
  $blue.Dispose()
  $white.Dispose()
  $muted.Dispose()
  $dark.Dispose()
  $monoFont.Dispose()
  $bodyFont.Dispose()
  $labelFont.Dispose()
  $subtitleFont.Dispose()
  $titleFont.Dispose()
  $graphics.Dispose()
  $bitmap.Dispose()
}

function New-PromoTile($targetPath, $width, $height, $large) {
  $bitmap = [System.Drawing.Bitmap]::new($width, $height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  $rect = [System.Drawing.RectangleF]::new(0, 0, $width, $height)
  $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, [System.Drawing.ColorTranslator]::FromHtml("#F6F8FB"), [System.Drawing.ColorTranslator]::FromHtml("#E6FBF6"), 25)
  $graphics.FillRectangle($bg, $rect)

  $titleBrush = New-Brush "#172026"
  $bodyBrush = New-Brush "#53616C"
  $titleSize = if ($large) { 54 } else { 27 }
  $bodySize = if ($large) { 28 } else { 15 }
  $titleFont = [System.Drawing.Font]::new("Segoe UI", $titleSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $bodyFont = [System.Drawing.Font]::new("Segoe UI", $bodySize, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $iconSize = if ($large) { 156 } else { 82 }
  $iconX = if ($large) { 120 } else { 38 }
  $iconY = [Math]::Round(($height - $iconSize) / 2)
  $textX = if ($large) { 330 } else { 145 }
  $titleHeight = if ($large) { 75 } else { 42 }
  $bodyTop = if ($large) { 92 } else { 50 }
  $bodyHeight = if ($large) { 44 } else { 28 }
  $titleText = if ($large) { "Bili Share Link Cleaner" } else { "Bili Link Cleaner" }
  $bodyText = if ($large) { "Clean Bilibili video URLs when copied" } else { "Clean Bilibili video URLs" }

  $icon = [System.Drawing.Image]::FromFile((Join-Path $iconDir "icon128.png"))
  $graphics.DrawImage($icon, $iconX, $iconY, $iconSize, $iconSize)
  $icon.Dispose()

  Draw-Text $graphics $titleText $titleFont $titleBrush ([System.Drawing.RectangleF]::new($textX, $iconY + 10, $width - $textX - 50, $titleHeight)) "Near" "Near"
  Draw-Text $graphics $bodyText $bodyFont $bodyBrush ([System.Drawing.RectangleF]::new($textX, $iconY + $bodyTop, $width - $textX - 50, $bodyHeight)) "Near" "Near"

  Save-Png $bitmap $targetPath

  $bodyFont.Dispose()
  $titleFont.Dispose()
  $bodyBrush.Dispose()
  $titleBrush.Dispose()
  $bg.Dispose()
  $graphics.Dispose()
  $bitmap.Dispose()
}

foreach ($size in @(16, 32, 48, 128)) {
  New-Icon $size (Join-Path $iconDir "icon$size.png")
}

Copy-Item -LiteralPath (Join-Path $iconDir "icon128.png") -Destination (Join-Path $storeDir "store-icon-128.png") -Force
New-StoreScreenshot (Join-Path $storeDir "screenshot-1280x800.png")
New-PromoTile (Join-Path $storeDir "promo-small-440x280.png") 440 280 $false
New-PromoTile (Join-Path $storeDir "promo-marquee-1400x560.png") 1400 560 $true

Write-Host "Generated extension icons and Chrome Web Store assets."
