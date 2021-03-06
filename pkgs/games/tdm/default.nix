{ stdenv
, fetchurl
, binutils-unwrapped
, sconsPackages
, gnum4
, p7zip
, glibc_multi
, mesa
, xorg
, libGLU
, libGL
, openal
, lib
, makeWrapper
, makeDesktopItem
}:

let
  pname = "tdm";
  version = "2.10";

  # desktop = makeDesktopItem {
  #   desktopName = pname;
  #   name = pname;
  #   exec = "@out@/bin/${pname}";
  #   icon = pname;
  #   terminal = "false";
  #   comment = "The Dark Mod - stealth FPS inspired by the Thief series";
  #   type = "Application";
  #   categories = "Game;";
  #   genericName = pname;
  #   fileValidation = false;
  # };
in
stdenv.mkDerivation {
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://www.thedarkmod.com/sources/thedarkmod.${version}.src.7z";
    sha256 = "sha256-c6qXRjUpPmygc5a+GZATVfgiRje9885zQEuO73QUihw=";
  };
  nativeBuildInputs = [
    p7zip
    sconsPackages.scons_3_1_2
    gnum4
    makeWrapper
  ];
  buildInputs = [
    glibc_multi
    mesa.dev
    xorg.libX11.dev
    openal
    xorg.libXext.dev
    xorg.libXxf86vm.dev
    libGL
    libGLU
  ];
  unpackPhase = ''
    7z x $src
  '';

  # I'm pretty sure there's a better way to build 2 targets than a random hook
  preBuild = ''
    pushd tdm_update
    scons BUILD=release TARGET_ARCH=x64
    install -Dm755 bin/tdm_update.linux64 $out/share/libexec/tdm_update.linux
    popd
  '';

  # why oh why can it find ld but not strip?
  postPatch = ''
    sed -i 's!strip \$!${binutils-unwrapped}/bin/strip $!' tdm_update/SConstruct
    # This adds math.h needed for math::floor
    sed -i 's|#include "Util.h"|#include "Util.h"\n#include <math.h>|' tdm_update/ConsoleUpdater.cpp
  '';

  installPhase = ''
        runHook preInstall

        substituteInPlace $out/share/applications/${pname}.desktop --subst-var out
        install -Dm755 thedarkmod.x64 $out/share/libexec/tdm
        # The package doesn't install assets, these get installed by running tdm_update.linux
        # Provide a script that runs tdm_update.linux on first launch
        install -Dm755 <(cat <<'EOF'
    #!/bin/sh
    set -e
    DIR="$HOME/.local/share/tdm"
    mkdir -p "$DIR"
    cd "$DIR"
    exec "PKGDIR/share/libexec/tdm_update.linux" --noselfupdate
    EOF
        ) $out/bin/tdm_update
        install -Dm755 <(cat <<'EOF'
    #!/bin/sh
    set -e
    DIR="$HOME/.local/share/tdm"
    if [ ! -d "$DIR" ]; then
      echo "Please run tdm_update to (re)download game data"
    else
      cd "$DIR"
      exec "PKGDIR/share/libexec/tdm"
    fi
    EOF
        ) $out/bin/tdm
        sed -i "s!PKGDIR!$out!g" $out/bin/tdm_update
        sed -i "s!PKGDIR!$out!g" $out/bin/tdm
        runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/tdm --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL libGLU ]}
  '';

  enableParallelBuilding = true;
  sconsFlags = [ "BUILD=release" "TARGET_ARCH=x64" ];
  NIX_CFLAGS_COMPILE = "-Wno-error=format-security";
  # meta = with stdenv.lib; {
  #   description = "The Dark Mod - stealth FPS inspired by the Thief series";
  #   homepage = "http://www.thedarkmod.com";
  #   license = licenses.gpl3;
  #   maintainers = with maintainers; [ cizra ];
  #   platforms = with platforms; [ "x86_64-linux" ];  # tdm also supports x86, but I don't have a x86 install at hand to test.
  # };
}
