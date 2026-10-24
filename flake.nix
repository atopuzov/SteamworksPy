{
  description = "A simple flake for a C++ and Python project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      steamworksSrc = pkgs.fetchzip {
        url = "https://web.archive.org/web/20250527013243/https://partner.steamgames.com/downloads/steamworks_sdk_160.zip";
        hash = "sha256-cLuil05SzEkujngecI/xfhOLq5Q4shSgoKWYm+Quph4=";
        stripRoot = false;
      };

      steamworks-sdk = pkgs.stdenv.mkDerivation rec {
        pname = "steamworks-sdk";
        version = "1.60";
        src = steamworksSrc;
        installPhase = ''
          mkdir -p $out/include
          cp -r sdk/public/steam $out/include/
          mkdir -p $out/lib
          cp sdk/redistributable_bin/linux64/libsteam_api.so $out/lib/
        '';
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.gcc
          pkgs.python3
          steamworks-sdk
        ];
        shellHook = ''
          export LD_LIBRARY_PATH="${steamworks-sdk}/lib:${pkgs.stdenv.cc.cc.lib}/lib"
        '';
      };
    };
}
