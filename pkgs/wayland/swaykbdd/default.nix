{ lib, stdenv, fetchFromGitHub
, meson, ninja, pkg-config, cmake
, json_c
}:

stdenv.mkDerivation rec {
  pname = "swaykbdd";
  version = "4a7586f3ffb7cb09f40dc3b06be859d3c2d609f2";

  src = fetchFromGitHub {
    owner = "artemsen";
    repo = "swaykbdd";
    rev = "${version}";
    sha256 = "96fUkj0W1DdQq8ZcNHfm5VE1zABnyhqUJ7SV6c00RQE=";
  };

  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [ meson ninja cmake ];
  buildInputs = [ json_c ];

  mesonFlags = [
    "-Dman-pages=enabled"
  ];

  meta = with lib; {
    description = "Keyboard layout switcher for Sway ";
    longDescription = ''
      The swaykbdd utility can be used to automatically change the keyboard layout
      on a per-window basis.
    '';
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ tgunnoe ];
  };
}
