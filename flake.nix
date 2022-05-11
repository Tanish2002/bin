{
  description = "A flake for installing these scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, unstable, nur, ... }: {

    defaultPackage.x86_64-linux = with import nixpkgs {
      system = "x86_64-linux";
      overlays = [
        (final: prev: {
          unstable = unstable.legacyPackages.x86_64-linux;
          colorpicker-ym1234 = prev.colorpicker.overrideAttrs (o: {
            src = prev.fetchFromGitHub {
              owner = "ym1234";
              repo = "colorpicker";
              rev = "3b5076f5bb3392830e7d1d97fa86621ca19c4d1a";
              sha256 = "lt8l387Kc3RGCTEcE+zIf0sXdLrmVVu3L6qhhSlEQ2Q=";
            };
          });
        })
        nur.overlay
      ];
    };
      stdenv.mkDerivation {
        name = "scripts";
        src = self;

        buildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          substituteInPlace scripts/matrix_upload \
          --replace '#!/usr/bin/env -S python3 -u' '${pkgs.python3} -u'        

          mkdir -p $out/bin
          cp scripts/* $out/bin/
          cp deps/* $out/bin
        '';
        postFixup = ''
          for file in scripts/*
          do
            wrapProgram $out/bin/$(basename $file) \
              --prefix PATH : ${
                with pkgs;
                lib.makeBinPath [
                  coreutils
                  curl
                  pkgs.unstable.yt-dlp-light
                  mpv
                  netcat
                  procps
                  libnotify
                  slop
                  ffmpeg
                  xdotool
                  cpufrequtils
                  timg
                  pkgs.nur.repos.kira-bruneau.rofi-wayland
                  jq
                  file
                  maim
                  colorpicker-ym1234
                  pkgs.unstable.imagemagick_light
                  mediainfo
                  lynx
                  ueberzug
                  gawk
                  bat
                  atool
                  unzip
                  ffmpegthumbnailer
                  poppler_utils
                  odt2txt
                  gnupg
                  bluez
                  util-linux
                ]
              }
          done
        '';
      };
  };
}
