# Mario Kart 64 Nix Build Instructions

This guide explains how to build Mario Kart 64 using Nix.

## Prerequisites

1. Install Nix: https://nixos.org/download.html
2. Enable flakes if you haven't already:
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

## Building with Nix

### Option 1: Development Shell (Recommended)

Enter a development shell with all dependencies:

```bash
cd /path/to/mk64
nix develop
```

This will:
- Install Python and other dependencies
- Build the required tools
- Guide you on placing the baserom file
- Guide you on installing the MIPS toolchain

### Option 2: Direct Build

You can also build directly using:

```bash
cd /path/to/mk64
nix build
```

## Building the ROM

Once in the development shell, you need to:

1. **Place your baserom**: Copy your Mario Kart 64 ROM to the project root as:
   - `baserom.us.z64` (for US version)
   - `baserom.eu.v10.z64` (for EU 1.0 version)
   - `baserom.eu.v11.z64` (for EU 1.1 version)

2. **Build the ROM**:
   ```bash
   make VERSION=us      # Build US version
   # or
   make VERSION=eu.v11  # Build EU 1.1 version
   ```

## Notes

- The EU 1.1 ROM should have SHA1 hash: `f6b5f519dd57ea59e9f013cc64816e9d273b2329`
- The US ROM should have SHA1 hash: `579c48e211ae952530ffc8738709f078d5dd215e`
- The build process will extract assets and compile the game
- You need to install the MIPS toolchain separately (the flake will guide you)

## Troubleshooting

If you get errors about missing tools, make sure to run `make -C tools` first to build the required tools.

## Optional Dependencies

For full functionality, you might want to add:
- `blender` - for model extraction
- `mupen64plus` - for testing the ROM

You can add these to your environment by modifying the flake.nix file.
