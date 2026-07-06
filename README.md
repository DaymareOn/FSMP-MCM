# FSMP-MCM — splash-only branch

![Build Status](https://github.com/DaymareOn/FSMP-MCM/actions/workflows/build.yml/badge.svg)

The save-preserving stub of the former Faster Skinned Mesh Physics Mod Configuration Menu for Skyrim.

## Overview

FSMP 4 moved all configuration to the SKSE Menu Framework menu built into [Faster HDT-SMP](https://www.nexusmods.com/skyrimspecialedition/mods/57339), and the SkyUI MCM was retired. But Skyrim destroys a save-game when an esp it references is removed, so players updating mid-playthrough from FSMP 3.x need to keep `FSMPM - The FSMP MCM.esp` alive.

This branch is that lifeline: the esp is unchanged (existing saves keep their plugin reference), and the menu is reduced to a single splash page showing the FSMP logo and the pointer "Use SKSE Menu Framework for the new menu". Nothing is configured here, and the runtime dependencies of the full MCM (JContainers, PapyrusUtil, ConsoleUtil) are no longer required. On saves updating from the full MCM, the stub releases the JContainers map the full MCM kept in the co-save.

The [hdtSMP64](https://github.com/DaymareOn/hdtSMP64) continuous integration fetches this branch — and only this branch — to package the stub as an optional install in the FSMP FOMOD, for players who update mid-game.

The full 3.x MCM lives in this repository's history on the `main` branch.

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
