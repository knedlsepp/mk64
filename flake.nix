{
  description = "Mario Kart 64 decompilation project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python3
            python3Packages.pip
            python3Packages.setuptools
            python3Packages.wheel
            # For building tools
            gcc
            gnumake
            pkg-config
            # For texture conversion
            imagemagick
            # Optional: blender for model extraction
            # blender
            # For running the ROM
            # mupen64plus
          ];

          # Shell hook to set up the environment
          shellHook = ''
            echo "Setting up Mario Kart 64 build environment..."
            
            # Check for MIPS toolchain
            if ! command -v mips64-elf-gcc &> /dev/null; then
              echo ""
              echo "==================================================================="
              echo "MIPS toolchain not found!"
              echo "You need to install a MIPS64 ELF toolchain for N64 development."
              echo ""
              echo "On NixOS, you can install it with:"
              echo "  nix-env -iA nixpkgs.mips64-elf-toolchain"
              echo ""
              echo "Or manually install from:"
              echo "  https://github.com/n64decomp/toolchains"
              echo "==================================================================="
              echo ""
            fi
            
            # Check if baserom exists, if not, guide user to place it
            if [ ! -f "baserom.us.z64" ] && [ ! -f "baserom.eu.v10.z64" ] && [ ! -f "baserom.eu.v11.z64" ]; then
              echo ""
              echo "==================================================================="
              echo "No baserom file found!"
              echo "Please place your Mario Kart 64 ROM in the project root as:"
              echo "  baserom.us.z64      (for US version)"
              echo "  baserom.eu.v10.z64  (for EU 1.0 version)"
              echo "  baserom.eu.v11.z64  (for EU 1.1 version)"
              echo ""
              echo "The ROM should have the following SHA1 hashes:"
              echo "  US:  579c48e211ae952530ffc8738709f078d5dd215e"
              echo "  EU:  f6b5f519dd57ea59e9f013cc64816e9d273b2329 (v1.1)"
              echo "==================================================================="
              echo ""
            fi
            
            echo "Build environment ready!"
            echo "You can now run:"
            echo "  make VERSION=us      # Build US version"
            echo "  make VERSION=eu.v11  # Build EU 1.1 version"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          name = "mk64-build";
          src = ./.;
          nativeBuildInputs = with pkgs; [
            python3
            python3Packages.pip
            python3Packages.setuptools
            python3Packages.wheel
            gcc
            gnumake
            pkg-config
            imagemagick
          ];

          phases = "unpackPhase installPhase";

          installPhase = ''
            mkdir -p $out
            cp -r . $out/
            
            # Build the tools
            echo "Building tools..."
            make -C tools
            
            echo "Mario Kart 64 build environment installed to $out"
          '';
        };
      }
    );
}