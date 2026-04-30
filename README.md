# FSMP-MCM

![Build Status](https://github.com/DaymareOn/FSMP-MCM/actions/workflows/build.yml/badge.svg)

The Faster Skinned Mesh Physics Mod Configuration Menu for Skyrim.

## Overview

FSMP-MCM is a SkyUI Mod Configuration Menu (MCM) designed for the [Faster HDT-SMP](https://www.nexusmods.com/skyrimspecialedition/mods/57339) (FSMP) physics engine plugin. It enables players to intuitively control and fine-tune physics settings directly from within the game.

## Features

Instead of direct memory injection, this MCM dynamically recompiles and overwrites the FSMP `configs.xml` on the fly, immediately followed by an `smp reset` console command so the backend picks up the changes seamlessly.

Key features broken down by menu pages:
- **Master Switch & Commands:** Easily toggle SMP globally, or trigger debug console commands like `smp list`, `smp detail`, and `smp dumptree` without manually typing them.
- **Simplification (Culling):** Save performance by disabling 1st-person physics, turning off SMP hair when wigs are equipped, or auto-adjusting the maximum active SMP skeletons based on allowed frame time.
- **Simulation Quality:** Dial in physics precision by tweaking iterations, substeps and ERP toggles. Includes rotation limits to prevent physics explosions on sharp turns.
- **Wind Parameters:** Enable and manipulate FSMP-native wind by setting wind strength scales and establishing distance cutoffs for wind calculation.
- **Logging & Presets:** Quickly adjust the hdtSMP64 log level (Fatal to Debug) or swap between saved XML presets in-game.

## Development & Building

Local builds have been simplified to match the CI environment. All necessary Papyrus dependencies are provided as "stubs" within the repository, so you don't need to install external mods to compile the source.

### Prerequisites

1.  **Caprica Compiler**: This project uses the [Caprica](https://github.com/KrisV-777/Caprica) compiler for fast, strict Papyrus compilation.
    *   **Auto-Download**: The build script (`./dev-scripts/compile.ps1`) will automatically attempt to download and install `Caprica.exe` to the `Caprica/` folder if it is missing.
    *   **Manual Install**: If the auto-download fails, you can download it manually from the [KrisV-777/Caprica Releases](https://github.com/KrisV-777/Caprica/releases) and place it in the `Caprica/` directory.
2.  **PowerShell**: Required to run the build script.

### Build Instructions

The build process supports two modes:

*   **Release Mode** (Default): Uses in-repo stubs. Requires no setup other than having Caprica.
*   **Dev Mode**: Uses your real local Skyrim script sources. Ideal for development when you need full script visibility.

#### Using the Compilation Script

1.  Open a PowerShell terminal in the repository root.
2.  Run the desired mode:
    ```powershell
    # Release mode (default)
    ./dev-scripts/compile.ps1 -Mode Release

    # Dev mode (uses generic local paths by default)
    ./dev-scripts/compile.ps1 -Mode Dev
    ```

The compiled `.pex` files will be placed in the `Scripts/` directory.

#### Using Papyrus Project (.ppj) Files

Two project files are provided:
*   **`skyrimse.ppj`**: Portable Release version (stubs).
*   **`skyrimse.dev.ppj`**: Local Development version. **Edit this file** to point to your machine-specific Skyrim and mod source paths. It contains generic placeholders to get you started. (This file is ignored by Git).

You can run Caprica directly against them:
```powershell
./Caprica/Caprica.exe skyrimse.ppj
./Caprica/Caprica.exe skyrimse.dev.ppj
```

## License

See the [LICENSE](LICENSE) file for more details.
