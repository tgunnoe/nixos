{ stdenv, lib, buildPythonApplication, i3ipc, fetchPypi, sources }:

buildPythonApplication rec {
  pname = "i3-swallow";
  version = "1.0.0";
  #inherit (sources.i3-swallow) version src;

  src = fetchPypi {
    inherit pname version;
    sha256 = "44e1c7a7acb1eeb8e403a1b6fa350b5ba56fe60878097cb55873ccfcf56976b8";
  };
  propagatedBuildInputs = [ i3ipc ];

  doCheck = false;
  pythonImportsCheck = [ "i3_swallow" ];

  meta = with lib; {
    homepage = "https://github.com/jamesofarrell/i3-swallow";
    description = "Simple i3/sway swallow window script";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ tgunnoe ];
  };
}
