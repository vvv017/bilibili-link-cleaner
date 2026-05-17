$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$manifestPath = Join-Path $root "manifest.json"
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$version = $manifest.version
$name = "bili-share-link-cleaner-$version.zip"
$dist = Join-Path $root "dist"
$staging = Join-Path $dist "extension"
$zipPath = Join-Path $dist $name

if (Test-Path $staging) {
  Remove-Item -LiteralPath $staging -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $staging | Out-Null

$items = @(
  "manifest.json",
  "popup.html",
  "popup.css",
  "src",
  "assets"
)

foreach ($item in $items) {
  $source = Join-Path $root $item
  if (-not (Test-Path $source)) {
    throw "Missing required package item: $item"
  }

  Copy-Item -LiteralPath $source -Destination $staging -Recurse -Force
}

if (Test-Path $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -CompressionLevel Optimal
Remove-Item -LiteralPath $staging -Recurse -Force

Write-Host "Created $zipPath"
