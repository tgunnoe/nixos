{ lib, fetchFromGitLab, gcc11Stdenv, cmake, ... }:

gcc11Stdenv.mkDerivation rec {
  pname = "orgtoinvoice";
  version = "unstable";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "samwise_i";
    repo = "orgtoinvoice";
    rev = "39e4898f5f3d3f845381ac06a84da9796985cb37";
    sha256 = "sha256-8UKaI77hI9ir/U+bRngcV0hJMpg4u/aihqwgD/gIC+A=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
  ];

  meta = with lib; {
    homepage = "https://github.com/coelckers/gzdoom";
    description =
      "A command line utility to convert Org files to customizable LaTeX invoice and work logs.";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ tgunnoe ];
  };
}
