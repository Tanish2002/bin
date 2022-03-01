{
  description = "A flake for installing these scripts";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs, ... }: {

    defaultPackage.x86_64-linux = with import nixpkgs {
      system = "x86_64-linux";
      overlays = [
        (final: prev: {
          colorpicker-ym1234 = prev.colorpicker.overrideAttrs (o: {
            src = prev.fetchFromGitHub {
              owner = "ym1234";
              repo = "colorpicker";
              rev = "3b5076f5bb3392830e7d1d97fa86621ca19c4d1a";
              sha256 = "lt8l387Kc3RGCTEcE+zIf0sXdLrmVVu3L6qhhSlEQ2Q=";
            };
          });
          # Imagemagick package is kinda broken :(
          imagemagick-patch = prev.imagemagick.overrideAttrs
            (o: { nativeBuildInputs = o.nativeBuildInputs ++ [ prev.curl ]; });
        })
      ];
    };
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
          for file in *
          do
            wrapProgram $out/bin/$(basename $file) \
              --prefix PATH : ${
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
                  file
                  maim
                  colorpicker-ym1234
                  imagemagick-patch
                ]
              }
          done
        '';
      };
  };
}