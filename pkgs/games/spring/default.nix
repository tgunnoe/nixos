{ lib
, stdenv
, fetchFromGitHub
, cmake
, xz
, boost
, libdevil
, zlib
, p7zip
, openal
, libvorbis
, glew
, freetype
, xorg
, SDL2
, libGLU
, libGL
, asciidoc
, docbook_xsl
, docbook_xsl_ns
, curl
, makeWrapper
, jdk ? null
, python ? null
, systemd
, libunwind
, which
, minizip
, srcs
, withAI ? true # support for AI Interfaces and Skirmish AIs
}:
let
  barData = fetchFromGitHub {
    owner = "beyond-all-reason";
    repo = "Beyond-All-Reason";
    rev = "23bca51494640a8a1a1fc2c4f1ab259291d8bcb4";
    sha256 = "sha256-DJDef4YM31DzSYiXdskQxpyGlIKaMysObSBvQUbPNmA=";
  };
  barChobby = fetchFromGitHub {
    owner = "beyond-all-reason";
    repo = "BYAR-Chobby";
    rev = "aa64e8d040f96001c97d55c283cae93c75d2ebeb";
    sha256 = "sha256-DJDef4YM31DzSYiXdskQxpyGlIKaMysObSBvQUbPNmA=";
  };
in
stdenv.mkDerivation rec {
  pname = "spring";
  version = "105.1.1-${buildId}-g${shortRev}";
  #inherit (spring) version;
  rev = "34d2eb7a14fa8f316b308a6c6945ae8fcb00f9ce";
  shortRev = builtins.substring 0 7 rev;
  buildId = "902";

  # taken from https://github.com/spring/spring/commits/maintenance
  src = fetchFromGitHub {
    owner = "beyond-all-reason";
    repo = pname;
    inherit rev;
    sha256 = "sha256-OUiniYrTDUnMQkeb6BsqtUIMKMwC9JwR3WdXnB9qmxY=";
    fetchSubmodules = true;
  };

  # The cmake included module correcly finds nix's glew, however
  # it has to be the bundled FindGLEW for headless or dedicated builds
  prePatch = ''
    substituteInPlace ./rts/build/cmake/FindAsciiDoc.cmake \
      --replace "PATHS /usr /usr/share /usr/local /usr/local/share" "PATHS ${docbook_xsl}"\
      --replace "xsl/docbook/manpages" "share/xml/docbook-xsl/manpages"
    substituteInPlace ./rts/Rendering/GL/myGL.cpp \
      --replace "static constexpr const GLubyte* qcriProcName" "static const GLubyte* qcriProcName"
    patchShebangs .
    rm rts/build/cmake/FindGLEW.cmake
    echo "${version} maintenance" > VERSION
  '';
  cmakeFlags = [
    "-DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=ON"
    "-DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON"
    "-DPREFER_STATIC_LIBS:BOOL=OFF"
  ];

  nativeBuildInputs = [ cmake makeWrapper docbook_xsl docbook_xsl_ns asciidoc ];
  buildInputs = [
    xz
    boost
    libdevil
    zlib
    p7zip
    openal
    libvorbis
    freetype
    SDL2
    xorg.libX11
    xorg.libXcursor
    libGLU
    libGL
    glew
    curl
    systemd
    libunwind
    which
    minizip
  ]
  ++ lib.optional withAI jdk
  ++ lib.optional withAI python;

  NIX_CFLAGS_COMPILE = "-fpermissive"; # GL header minor incompatibility

  postInstall = ''
    wrapProgram "$out/bin/spring" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc systemd ]}"
    ln -s ${barData} $out/share/games/BAR.sdd
    ln -s ${barChobby} $out/share/games/BYAR-Chobby.sdd
  '';

  meta = with lib; {
    homepage = "https://springrts.com/";
    description = "A powerful real-time strategy (RTS) game engine";
    license = licenses.gpl2;
    maintainers = with maintainers; [ phreedom qknight domenkozar sorki ];
    platforms = platforms.linux;
    # error: 'snprintf' was not declared in this scope
  };
}
