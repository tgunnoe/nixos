{ lib, stdenv, fetchurl, makeWrapper, adoptopenjdk-jre-hotspot-bin-15, gtk3, zlib, libX11, libXext, libXi, libXrender, libXtst, libGL, alsa-lib, cairo, freetype, pango, gdk-pixbuf, glib }:

with lib;

stdenv.mkDerivation rec {
  pname = "faforever";
  version = "2021.11.0";

  src = fetchurl {
    name = "dfc_unix_${versions.major version}_${versions.minor version}_${versions.patch version}.tar.gz";
    url = "https://github.com/FAForever/downlords-faf-client/releases/download/v${version}/dfc_unix_${versions.major version}_${versions.minor version}_${versions.patch version}.tar.gz";
    sha256 = "04jq40rm3iip043n03rlmb6nvk5pjyj1lxj6d970j67js0p7qpss";
  };

  nativeBuildInputs = [ makeWrapper ];

  # unpackPhase = ''
  #   dpkg-deb -x $src opt
  # '';
  #vmoptsFile = optionalString (vmopts != null) (writeText vmoptsName vmopts);
  systemLibs = [ gtk3 zlib libX11 libXext libXi libXrender libXtst libGL alsa-lib cairo freetype pango gdk-pixbuf glib ];
  systemLibPaths = lib.makeLibraryPath systemLibs;

  installPhase = ''
    mkdir -p $out/bin $out/share/java $out/share/applications
    tar xfv $src -C $out/share/java
    mv $out/share/java/faf-client-${version} $out/share/java/${pname}

    makeWrapper $out/share/java/${pname}/faf-client $out/bin/${pname} \
      --set INSTALL4J_JAVA_HOME "${adoptopenjdk-jre-hotspot-bin-15}" \
      --set JAVA_HOME ${adoptopenjdk-jre-hotspot-bin-15} \
      --add-flags '-Djava.library.path=${systemLibPaths}' \
      --prefix LD_LIBRARY_PATH : '${systemLibPaths}' \
      --run "pushd $out/share/java/faforever"
  '';

  meta = {
    description = "Forged Alliance Forever - Lobby Client. Community-driven client system for Supreme Commander: Forged Alliance. Downlord's Java client reimplementation.";
    homepage = "http://www.faforever.com/";
    maintainers = with maintainers; [ fusion809 ];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
