Param(
    [ValidateSet("Release", "Dev")]
    [String]$Mode = "Release"
)

# Compilation Script for FSMP MCM Papyrus Scripts
# Requires Caprica/Caprica.exe to be present.

# Resolve the root directory (parent of this script's directory)
$RootDir = Split-Path -Path $PSScriptRoot -Parent
Push-Location $RootDir

function Install-Caprica {
    param ([string]$DestDir)
    
    $CapricaUrl = "https://github.com/KrisV-777/Caprica/releases/download/0.3.0a/Caprica.zip"
    $Name = "Caprica-AutoInstall"
    
    Write-Host "Caprica not found. Attempting to auto-download..."
    
    try {
        if (-not (Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir -Force }
        
        $zipFile = Join-Path $env:TEMP "$Name.zip"
        $outDir = Join-Path $env:TEMP "$Name-extracted"
        
        # Provenance: https://github.com/KrisV-777/Caprica/releases/tag/0.3.0a
        $ExpectedHash = "8bb87175ecf685fb40b07b8805415062157714109bab0925bc0bb0933e4f549c"
        
        Write-Host "  Downloading from $CapricaUrl..."
        Invoke-WebRequest -Uri $CapricaUrl -OutFile $zipFile -UseBasicParsing
        
        Write-Host "  Verifying SHA-256 integrity..."
        # To manually verify: Get-FileHash -Path "$Name.zip" -Algorithm SHA256
        $ActualHash = (Get-FileHash -Path $zipFile -Algorithm SHA256).Hash
        if ($ActualHash -ne $ExpectedHash) {
            throw "SHA-256 mismatch! Expected $ExpectedHash but got $ActualHash. The download may be corrupted or compromised."
        }
        
        if (Test-Path $outDir) { Remove-Item -Recurse -Force $outDir }
        Write-Host "  Extracting..."
        Expand-Archive -Path $zipFile -DestinationPath $outDir -Force
        
        $exePath = Get-ChildItem -Path $outDir -Filter "Caprica.exe" -Recurse | Select-Object -First 1
        if ($exePath) {
            Copy-Item -Path $exePath.FullName -Destination (Join-Path $DestDir "Caprica.exe") -Force
            Write-Host "  Successfully installed Caprica to $DestDir"
            return $true
        } else {
            Write-Warning "  Could not find Caprica.exe in the downloaded archive."
            return $false
        }
    } catch {
        Write-Warning "  Auto-download failed: $($_.Exception.Message)"
        return $false
    } finally {
        if (Test-Path $zipFile) { Remove-Item $zipFile -ErrorAction SilentlyContinue }
        if (Test-Path $outDir) { Remove-Item -Recurse $outDir -ErrorAction SilentlyContinue }
    }
}

$CapricaDir = "Caprica"
$CapricaExe = "$CapricaDir/Caprica.exe"

if (-not (Test-Path $CapricaExe)) {
    if (-not (Install-Caprica -DestDir $CapricaDir)) {
        Write-Error "Caprica compiler not found and auto-download failed."
        Write-Host "Please manually download Caprica.exe and place it in the Caprica/ folder."
        Write-Host "Download from: https://github.com/KrisV-777/Caprica/releases"
        Pop-Location
        exit 1
    }
}

$OutputDir = "Scripts"
$FlagsFile = "Source/Scripts/Stubs/BaseGame/TESV_Papyrus_Flags.flg"

if ($Mode -eq "Release") {
    Write-Host "--- RELEASE BUILD (Using Stubs) ---"
    $Imports = @(
        "Source/Scripts",
        "Source/Scripts/SkyUI_SDK",
        "Source/Scripts/Stubs/BaseGame",
        "Source/Scripts/Stubs/SKSE",
        "Source/Scripts/Stubs/JContainers",
        "Source/Scripts/Stubs/PapyrusUtil",
        "Source/Scripts/Stubs/ConsoleUtil"
    ) -join ";"
} else {
    Write-Host "--- DEV BUILD (Using Local Scripts) ---"
    # --- ADJUST THESE PATHS TO MATCH YOUR LOCAL ENVIRONMENT ---
    # These should stay in sync with your skyrimse.dev.ppj
    $FlagsFile = "C:\Games\Skyrim Special Edition\Data\Source\Scripts\TESV_Papyrus_Flags.flg"
    $Imports = @(
        "Source/Scripts",
        "C:\Dev\SkyrimMods\SKSE64\Data\Scripts\Source",
        "C:\Games\Skyrim Special Edition\Data\Source\Scripts",
        "Source/Scripts/SkyUI_SDK", 
        "C:\Dev\SkyrimMods\PapyrusUtil\Source\Scripts",
        "C:\Dev\SkyrimMods\ConsoleUtilSSE\Scripts\Source",
        "C:\Dev\SkyrimMods\JContainers\scripts\source"
    ) -join ";"
}

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force
}

$SourceFiles = Get-ChildItem "Source/Scripts/*.psc" -Exclude "FSMPM_AutoBindings.psc"

foreach ($file in $SourceFiles) {
    Write-Host "Compiling $($file.Name)..."
    & $CapricaExe --game skyrim --flags $FlagsFile --import $Imports --output $OutputDir --ignorecwd "$($file.FullName)"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to compile $($file.Name)"
        Pop-Location
        exit 1
    }
}

Write-Host "All scripts compiled successfully."

# Optional: Run local deployment if in Dev mode and successful
if ($Mode -eq "Dev") {
    Write-Host "Running local deployment..."
    # ADJUST THESE TO YOUR MOD MANAGER OR GAME DATA FOLDER
    $DeployPaths = @(
        "C:\Games\Skyrim Special Edition\Data\",
        "C:\Modding\FSMPM_Dev_Instance\"
    )
    
    foreach ($dest in $DeployPaths) {
        if (Test-Path $dest) {
            Write-Host "  Copying to $dest"
            xcopy "Scripts" "$($dest)Scripts\" /E/Y/Q
            xcopy "SKSE" "$($dest)SKSE\" /E/Y/Q
            xcopy "Source" "$($dest)Source\" /E/Y/Q
        } else {
            Write-Verbose "  Skip: $dest not found"
        }
    }
}

Pop-Location
