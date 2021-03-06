{ lib
, stdenv
, fetchurl
, fetchpatch
, cmake
, wxGTK30
, openal
, pkg-config
, curl
, libtorrent-rasterbar
, libpng
, libX11
, gettext
, boost
, libnotify
, gtk2
, doxygen
, spring
, makeWrapper
, glib
, minizip
, alure
, pcre
, jsoncpp
}:

stdenv.mkDerivation rec {
  pname = "springlobby";
  version = "0.271";

  src = fetchurl {
    url = "https://springlobby.springrts.com/dl/stable/springlobby-${version}.tar.bz2";
    sha256 = "sha256-/0Qn2RsItzpPiQBVGZ5jNuiyWGTpFfQd5uOOjYjLZio=";
  };

  nativeBuildInputs = [ cmake pkg-config gettext doxygen makeWrapper ];
  buildInputs = [
    wxGTK30
    openal
    curl
    libtorrent-rasterbar
    pcre
    jsoncpp
    boost
    libpng
    libX11
    libnotify
    gtk2
    glib
    minizip
    alure
    spring
  ];

  patches = [
    ./revert_58b423e.patch # Allows springLobby to continue using system installed spring until #707 is fixed
    ./fix-certs.patch
  ];

  postInstall = ''
    wrapProgram $out/bin/springlobby \
      --prefix PATH : "${spring}/bin" \
      --set SPRING_BUNDLE_DIR "${spring}/lib"
  '';

  meta = with lib; {
    homepage = "https://springlobby.info/";
    repositories.git = "git://github.com/springlobby/springlobby.git";
    description = "Cross-platform lobby client for the Spring RTS project";
    license = licenses.gpl2;
    maintainers = with maintainers; [ phreedom qknight domenkozar ];
    platforms = platforms.linux;
  };
}
