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

function Get-ProjectConfiguration {
    param ([string]$ppjFile)
    
    if (-not (Test-Path $ppjFile)) {
        throw "Project file '$ppjFile' not found."
    }
    
    [xml]$ppj = Get-Content $ppjFile
    
    $flags = $ppj.PapyrusProject.Flags
    $imports = @($ppj.PapyrusProject.Imports.Import) | ForEach-Object { $_ }
    $variables = @{}
    
    if ($ppj.PapyrusProject.Variables) {
        foreach ($var in $ppj.PapyrusProject.Variables.Variable) {
            $variables[$var.Name] = $var.Value
        }
    }

    # Resolve variables in paths (e.g. $(ModWorkingFolder))
    $resolvedFlags = $flags
    $resolvedImports = @()
    
    foreach ($vName in $variables.Keys) {
        if ($resolvedFlags) { $resolvedFlags = $resolvedFlags.Replace("`$($vName)", $variables[$vName]) }
    }
    
    foreach ($imp in $imports) {
        $rImp = $imp
        foreach ($vName in $variables.Keys) {
            if ($rImp) { $rImp = $rImp.Replace("`$($vName)", $variables[$vName]) }
        }
        $resolvedImports += $rImp
    }

    return @{
        Flags = $resolvedFlags
        Imports = ($resolvedImports -join ";")
        Output = $ppj.PapyrusProject.Output
    }
}

$CapricaDir = "Caprica"
$CapricaExe = "$CapricaDir/Caprica.exe"

if (-not (Test-Path $CapricaExe)) {
    if (-not (Install-Caprica -DestDir $CapricaDir)) {
        Write-Error "Caprica compiler not found and auto-download failed."
        Pop-Location
        exit 1
    }
}

$PPJ = if ($Mode -eq "Dev") { "skyrimse.dev.ppj" } else { "skyrimse_ci.ppj" }

Write-Host "--- BUILD MODE: $Mode (Using Project: $PPJ) ---"

try {
    $Config = Get-ProjectConfiguration -ppjFile $PPJ
    $FlagsFile = $Config.Flags
    $Imports = $Config.Imports
    $OutputDir = $Config.Output
} catch {
    Write-Error $_
    Pop-Location
    exit 1
}

# Clean stale binaries and ensure output directory exists
if (Test-Path $OutputDir) {
    Remove-Item (Join-Path $OutputDir "*.pex") -Force -ErrorAction SilentlyContinue
} else {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
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

Pop-Location
