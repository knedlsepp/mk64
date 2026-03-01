{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    self.submodules = true;
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        crossSystem = {
          config = "mips-linux-gnu"; # prefix expected by scripts in tools/
          system = "mips64-elf";
          gcc.arch = "vr4300";
          gcc.tune = "vr4300";
          gcc.abi = "32";
        };
        pkgs = import nixpkgs { inherit system; };
        pkgsCross = import nixpkgs { inherit system crossSystem; };
        baseRomUS = pkgs.requireFile {
          name = "mk64.us.z64";
          message = ''
            ==== MISSING BASE ROM =======================================================

            Please rename your ROM to mk64.us.z64 and add it to the Nix store using
                nix-store --add-fixed sha256 mk64.us.z64
            then rerun nix-shell.
          '';
          sha256 = "1nm52yxbcgzq7k9fr6j77q7c7lvfh4r7svl5nbn3409zss6m7f6n";
        };
        baseRomEU = pkgs.requireFile {
          name = "mk64.eu.v11.z64";
          message = ''
            ==== MISSING BASE ROM =======================================================

            Please rename your ROM to mk64.eu.v11.z64 and add it to the Nix store using
                nix-store --add-fixed sha256 mk64.eu.v11.z64
            then rerun nix-shell.
          '';
          sha256 = "0vffw5v41bi1p0zjw2cc0bhlj7ccv6v83cna00i53sf5pdl2m7cd";
        };
      in {
        devShells.default = pkgsCross.mkShell {
          name = "devshell";
          packages = with pkgs; [
            ninja # needed for ninja -t compdb in run, as n2 doesn't support it
            n2 # same as ninja, but with prettier output
            zlib
            libyaml
            python3
            python3Packages.virtualenv
            ccache
            git
            iconv
            pkgsCross.gcc # for n64crc
            pkgs.gcc
            cmake
          ];
          shellHook = ''
            cp ${baseRomUS} ./baserom.us.z64
            cp ${baseRomEU} ./baserom.eu.v11.z64
          '';
        };

        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "mk64-rom";
          src = self;
          nativeBuildInputs = with pkgs; [
            ninja
            n2
            zlib
            libyaml
            python3
            python3Packages.virtualenv
            ccache
            git
            iconv
            pkgsCross.gcc
            gcc
            cmake
            gnumake
          ];
          dontUseCmakeConfigure = true;
          buildPhase = ''
            # Copy base ROMs
            cp ${baseRomUS} ./baserom.us.z64
            cp ${baseRomEU} ./baserom.eu.v11.z64
            
            # Build tools
            make -C tools -j$(nproc)
            
            # Extract assets
            make assets -j$(nproc)
            
            # Build ROM
            make -j$(nproc)
          '';
          installPhase = ''
            mkdir -p $out
            cp build/us/mk64.us.z64 $out/mk64.us.z64
          '';
        };
      }
    );
}
