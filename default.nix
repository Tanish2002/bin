{
  stdenvNoCC,
  python3,
  makeWrapper,
  lib,
  coreutils,
  curl,
  mpv,
  netcat,
  procps,
  libnotify,
  slop,
  ffmpeg,
  xdotool,
  cpufrequtils,
  timg,
  rofi,
  jq,
  file,
  maim,
  colorpicker-ym1234,
  imagemagick,
  mediainfo,
  lynx,
  ueberzug,
  gawk,
  bat,
  atool,
  unzip,
  ffmpegthumbnailer,
  poppler_utils,
  pulseaudio,
  odt2txt,
  gnupg,
  bluez,
  util-linux,
  gnused,
  graphicsmagick,
  self,
}:
stdenvNoCC.mkDerivation {
  name = "scripts";
  src = self;

  buildInputs = [makeWrapper];
  installPhase = ''
    substituteInPlace scripts/matrix_upload \
    --replace '#!/usr/bin/env -S python3 -u' '${python3} -u'

    mkdir -p $out/bin
    cp scripts/* $out/bin/
    cp deps/* $out/bin
  '';
  postFixup = ''
    for file in scripts/*
    do
      wrapProgram $out/bin/$(basename $file) \
        --prefix PATH : ${
      lib.makeBinPath [
        "$out" # so scripts can access each other
        coreutils
        gnused
        curl
        mpv
        netcat
        procps
        libnotify
        slop
        ffmpeg
        graphicsmagick
        xdotool
        cpufrequtils
        timg
        rofi
        jq
        file
        maim
        colorpicker-ym1234
        imagemagick
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
        pulseaudio
      ]
    }
    done
  '';
}
