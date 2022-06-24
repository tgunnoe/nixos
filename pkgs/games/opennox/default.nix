{ buildGo118Module, fetchFromGitHub, gcc, lib, SDL2, openal, pkg-config }:
let
  version = "1.8.10";
in
buildGo118Module {
  pname = "opennox";
  version = version;
  src = fetchFromGitHub {
    owner = "noxworld-dev";
    repo = "opennox";
    rev = "v${version}";
    sha256 = "0sbwzvbrb8yrm4c4r8gr4h9fyx4wv75yy8c1saa8qq5slmc2hv7s";
  };

  vendorSha256 = "sha256-Za7bOer68APzM0GjhNEEHhrBLi2xsWPdn59dpaI8J/o=";

  nativeBuildInputs = [
    gcc
    pkg-config
  ];
  buildInputs = [
    gcc
    SDL2
    openal
  ];

  modRoot = "src";

  proxyVendor = true;

  buildPhase = ''
    runHook preBuild
    set +x
    cd $src/src
    go run ./internal/noxbuild
    runHook postBuild
  '';

  meta = with lib; {
    description = "An open-source community collaboration project extending the Nox engine.";
    homepage = "https://github.com/noxworld-dev/opennox";
    license = licenses.gpl3;
    maintainers = with maintainers; [ tgunnoe ];
  };
}
