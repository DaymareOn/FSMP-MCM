# setup_ci.ps1 - Prepare CI environment for FSMP-MCM build
#
# All script dependencies (base game, SKSE, SkyUI SDK, mod libraries) are
# provided in-repo under Dependencies/Stubs/ and Dependencies/SkyUI-Community/
# Only the Caprica compiler needs to be downloaded.

$ErrorActionPreference = "Stop"
$rootDir = Split-Path -Path $PSScriptRoot -Parent
$toolDir = Join-Path $rootDir "ci_tools"

if (!(Test-Path $toolDir)) { New-Item -ItemType Directory -Path $toolDir }

function Invoke-DownloadAndExtract {
    param (
        [string]$Url,
        [string]$Name,
        [string]$ExtractSubPath = ""
    )
    Write-Host "Downloading $Name from $Url ..."
    $zipFile = Join-Path $env:TEMP "$Name.zip"
    $outDir = Join-Path $env:TEMP "$Name-extracted"
    
    Invoke-WebRequest -Uri $Url -OutFile $zipFile -UseBasicParsing
    if (Test-Path $outDir) { Remove-Item -Recurse -Force $outDir }
    Expand-Archive -Path $zipFile -DestinationPath $outDir
    
    $sourcePath = if ($ExtractSubPath) { Join-Path $outDir $ExtractSubPath } else { $outDir }
    return $sourcePath
}

# ── Download Caprica compiler ─────────────────────────────────────────────────

$capricaPath = Invoke-DownloadAndExtract "https://github.com/KrisV-777/Caprica/releases/download/0.3.0a/Caprica.zip" "Caprica"
Get-ChildItem -Path $capricaPath -Filter "Caprica.exe" -Recurse | Select-Object -First 1 | Copy-Item -Destination (Join-Path $toolDir "Caprica.exe")
Write-Host "Caprica installed."

# ── Done ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "CI setup complete."
Write-Host "  Tools:     $toolDir"
Write-Host "  Stubs:     Dependencies/Stubs/ (in repo)"
Write-Host "  SkyUI SDK: Dependencies/SkyUI-Community/ (Git Submodule)"
