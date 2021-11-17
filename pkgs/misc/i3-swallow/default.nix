{ stdenv, lib, python3, fetchFromGitHub, sources }:

stdenv.mkDerivation rec {
  pname = "i3-swallow";

  inherit (sources.i3-swallow) version src;

  propagatedBuildInputs = [ python3.pkgs.i3ipc ];

  #  postBuild
  installPhase = ''
    mkdir -p $out/bin
    cp swallow.py $out/bin/swallow
  '';
  buildPhase = ''

  '';
  pythonPath = with python3.pkgs; [ i3ipc ];
  # Tests require access to a X session
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/jamesofarrell/i3-swallow";
    description = "Simple i3/sway swallow window script";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ tgunnoe ];
  };
}
