---
description: Build the FSMP MCM Papyrus scripts using Caprica
---

# Build FSMP MCM

Compiles the Papyrus source scripts (`.psc`) into compiled Papyrus executables (`.pex`) using the Caprica compiler. This project uses in-repo stubs for all dependencies, making it easy to build without external setup.

## Prerequisites

- **Caprica Compiler**: `Caprica/Caprica.exe` must be present. 
  - If missing, download version 0.3.0a from [KrisV-777/Caprica Releases](https://github.com/KrisV-777/Caprica/releases/tag/0.3.0a).
- **PowerShell**: Used to run the build script.

## Build Command

1. Run the compilation script from the repository root:

```powershell
# Default Release mode (uses stubs)
./dev-scripts/compile.ps1

# Dev mode (uses your real local scripts)
./dev-scripts/compile.ps1 -Mode Dev
```

The compiled `.pex` files will be placed in the `Scripts/` directory.

## Alternative: Papyrus Project (.ppj)

You can also use the `skyrimse.ppj` file with any Papyrus project runner (like `Pypro` or `Caprica` directly if your version supports it).

```powershell
./Caprica/Caprica.exe skyrimse.ppj
```

## Notes

- The build script uses the `--ignorecwd` flag to prevent Caprica from auto-adding the CWD to imports, avoiding namespace conflicts.
- It also uses `--game skyrim` for Skyrim-specific compatibility.
- Warning `W4007` about `loadConfigDone` being unused is expected and harmless.