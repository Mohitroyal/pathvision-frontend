<#
Run Flutter tasks: pub get, analyze (save output), then run in Chrome.

Usage:
  .\scripts\ci_run.ps1           # runs pub get, analyze, then flutter run -d chrome
  .\scripts\ci_run.ps1 -NoRun   # runs pub get and analyze only
#  .\scripts\ci_run.ps1 -NoRun   # runs pub get and analyze only
#>
param(
    [switch]$NoRun
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $root

Write-Host "Running: flutter pub get"
flutter pub get

Write-Host "Running: flutter analyze (saving to analyze.txt)"
$analyzeFile = Join-Path $root 'analyze.txt'
flutter analyze 2>&1 | Tee-Object -FilePath $analyzeFile

# Count issues
$errors = (Select-String -Path $analyzeFile -Pattern '^\s*error -' -SimpleMatch -Quiet) -as [int]
if ($errors -eq $null) { $errors = 0 }
$warnings = (Select-String -Path $analyzeFile -Pattern '^\s*warning -' -SimpleMatch -Quiet) -as [int]
if ($warnings -eq $null) { $warnings = 0 }
$infos = (Select-String -Path $analyzeFile -Pattern '^\s*info -' -SimpleMatch -Quiet) -as [int]
if ($infos -eq $null) { $infos = 0 }

Write-Host "Analyzer output saved to: $analyzeFile"
Write-Host "(Note: open the file to inspect details.)"

if (-not $NoRun) {
    Write-Host "Starting app in Chrome... (Ctrl+C to stop)"
    flutter run -d chrome
}

Pop-Location
