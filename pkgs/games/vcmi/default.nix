{ lib, boost, stdenv, fetchFromGitHub, cmake, makeWrapper, openal, fluidsynth
, soundfont-fluid, libGL, SDL2, SDL2_image, SDL2_mixer, SDL2_ttf, tbb, bzip2, zlib, ffmpeg
, pkg-config, copyDesktopItems, makeDesktopItem, libsForQt5, lua, luajit, minizip }:

let
  gzdoom = stdenv.mkDerivation rec {
    pname = "vcmi";
    version = "unstable-2022-04-17";

    src = fetchFromGitHub {
      owner = "vcmi";
      repo = "vcmi";
      rev = "56a1984aa8a0139ad334c5e39bac72116b749b4d";
      sha256 = "sha256-4AM4+52ZZOR1XV3lo9R4oH6nen2AE7k0eKjDYviDGvo=";
      fetchSubmodules = true;
    };
    dontWrapQtApps = true;
    nativeBuildInputs = [ cmake makeWrapper pkg-config copyDesktopItems ];
    buildInputs = [
      boost
      ffmpeg
      SDL2
      SDL2_image
      SDL2_mixer
      SDL2_ttf
      minizip
      lua
      luajit
      tbb
      libsForQt5.qt5.qtbase
      libGL
      openal
      fluidsynth
      bzip2
      zlib
    ];
    cmakeFlags = [
      "-DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=ON"
      "-DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON"
      "-DPREFER_STATIC_LIBS:BOOL=OFF"
      "-DENABLE_TEST=OFF"
      "-DCMAKE_BUILD_TYPE='Release'"
    ];

    #NIX_CFLAGS_LINK = "-lopenal -lfluidsynth";

    desktopItems = [
      (makeDesktopItem {
        name = "vcmi";
        exec = "vcmi";
        desktopName = "VCMI";
        categories = [ "Game" ];
      })
    ];

    # installPhase = ''
    #   runHook preInstall

    #   install -Dm755 gzdoom "$out/lib/gzdoom/gzdoom"
    #   for i in *.pk3; do
    #     install -Dm644 "$i" "$out/lib/gzdoom/$i"
    #   done
    #   for i in fm_banks/*; do
    #     install -Dm644 "$i" "$out/lib/gzdoom/$i"
    #   done
    #   for i in soundfonts/*; do
    #     install -Dm644 "$i" "$out/lib/gzdoom/$i"
    #   done
    #   mkdir $out/bin
    #   makeWrapper $out/lib/gzdoom/gzdoom $out/bin/gzdoom

    #   runHook postInstall
    # '';

    meta = with lib; {
      homepage = "https://github.com/coelckers/gzdoom";
      description =
        "A Doom source port based on ZDoom. It features an OpenGL renderer and lots of new features";
      license = licenses.gpl3;
      platforms = [ "x86_64-linux" ];
      maintainers = with maintainers; [ lassulus ];
    };
  };

in gzdoom
