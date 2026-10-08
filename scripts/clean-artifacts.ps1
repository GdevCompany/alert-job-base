# Удалить артефакты локальной сборки (не коммитятся в git)
$ErrorActionPreference = "SilentlyContinue"
$base = Split-Path $PSScriptRoot -Parent
$root = Split-Path $base -Parent
Get-ChildItem $root -Directory -Filter "alert-job*" | ForEach-Object {
  foreach ($name in @("node_modules", "target", "dist")) {
    Get-ChildItem $_.FullName -Recurse -Directory -Filter $name | Remove-Item -Recurse -Force
  }
  Get-ChildItem $_.FullName -Recurse -Filter ".flattened-pom.xml" | Remove-Item -Force
}
Write-Host "Cleaned under $root (sibling clones of alert-job-base)"
