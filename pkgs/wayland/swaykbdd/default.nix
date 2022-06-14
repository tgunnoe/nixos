{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, cmake
, json_c
}:

stdenv.mkDerivation rec {
  pname = "swaykbdd";
  version = "9c4d78f2a2e4270dd605681c9eca8b0bc735fdbc";

  src = fetchFromGitHub {
    owner = "artemsen";
    repo = "swaykbdd";
    rev = "${version}";
    sha256 = "sha256-umYPVkkYeu6TyVkjDsVBsRZLYh8WyseCPdih85kTz6A=";
  };

  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [ meson ninja cmake ];
  buildInputs = [ json_c ];

  mesonFlags = [
    #    "-Dman-pages=enabled"
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
