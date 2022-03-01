{
  description = "A flake for installing these scripts";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation {
        name = "scripts";
        src = ./scripts;

        buildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          substituteInPlace matrix_upload \
          --replace '#!/usr/bin/env -S python3 -u' '${pkgs.python3} -u'        

          mkdir -p $out/bin
          cp * $out/bin/
        '';
        postFixup = ''
          for file in scripts/*
          do
            wrapProgram $out/bin/$file \
              ---prefix PATH : ${
                with pkgs;
                lib.makeBinPath [
                  coreutils
                  curl
                  youtube-dl
                  mpv
                  netcat
                  procps
                  libnotify
                  slop
                  ffmpeg
                  xdotool
                  cpufrequtils
                  timg
                  rofi
                  jq
                ]
              }
          done
        '';
      };
  };
}
