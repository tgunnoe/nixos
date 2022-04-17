{ lib, stdenv, fetchurl, makeWrapper, adoptopenjdk-jre-hotspot-bin-15, gtk3, zlib, libX11, libXext, libXi, libXrender, libXtst, libGL, alsa-lib, cairo, freetype, pango, gdk-pixbuf, glib }:

with lib;

stdenv.mkDerivation rec {
  pname = "taforever";
  version = "0.14.13";

  src = fetchurl {
    name = "tafclient_unix_1_4_3-taf-${versions.major version}_${versions.minor version}_${versions.patch version}.tar.gz";
    url = "https://github.com/ta-forever/downlords-taf-client/releases/download/v1.4.3-taf-0.14.13/tafclient_unix_1_4_3-taf-${versions.major version}_${versions.minor version}_${versions.patch version}.tar.gz";
    sha256 = "0llwlw69pw3r74fisvndjp4smd17zccr1qxkcqrh3vim0zj01zhz";
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
    mv $out/share/java/downlords-taf-client-1.4.3-taf-0.14.13 $out/share/java/${pname}

    makeWrapper $out/share/java/${pname}/taf-java-client $out/bin/${pname} \
      --set INSTALL4J_JAVA_HOME "${adoptopenjdk-jre-hotspot-bin-15}" \
      --set JAVA_HOME ${adoptopenjdk-jre-hotspot-bin-15} \
      --add-flags '-Djava.library.path=${systemLibPaths}' \
      --prefix LD_LIBRARY_PATH : '${systemLibPaths}' \
      --run "pushd $out/share/java/taforever"
  '';

  meta = {
    description = "Forged Alliance Forever - Lobby Client. Community-driven client system for Supreme Commander: Forged Alliance. Downlord's Java client reimplementation.";
    homepage = "http://www.faforever.com/";
    maintainers = with maintainers; [ fusion809 ];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
