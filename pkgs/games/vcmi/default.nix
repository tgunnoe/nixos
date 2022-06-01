{ lib
, boost
, stdenv
, fetchFromGitHub
, cmake
, makeWrapper
, openal
, fluidsynth
, soundfont-fluid
, libGL
, SDL2
, SDL2_image
, SDL2_mixer
, SDL2_ttf
, tbb
, bzip2
, zlib
, ffmpeg
, pkg-config
, copyDesktopItems
, makeDesktopItem
, libsForQt5
, lua
, luajit
, minizip
}:

let
  gzdoom = stdenv.mkDerivation rec {
    pname = "vcmi";
    version = "unstable-2022-04-17";

    src = fetchFromGitHub {
      owner = "vcmi";
      repo = "vcmi";
      rev = "1a6ee0d69778d5343926db02b8bf89e935b8f69a";
      sha256 = "sha256-c8lebufsEvvYn+D+QpN3inLw++RBNJ02aqry5UNVI/M=";
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
      "-DENABLE_TEST=OFF"
      "-DTBB_DIR:STRING=${tbb}"
      "-DCMAKE_BUILD_TYPE='Release'"
      "-DCMAKE_CXX_FLAGS=-std=c++17"
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

in
gzdoom
