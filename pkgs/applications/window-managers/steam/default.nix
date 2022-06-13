{ stdenv
, lib
, fetchFromGitHub
, udev
, SDL
, SDL_image
, libXdamage
, libXcomposite
, libXrender
, libXext
, libXxf86vm
, pkgconfig
, autoreconfHook
, gnumake
}:

stdenv.mkDerivation {
  name = "steamcompmgr";
  src = fetchFromGitHub {
    owner = "gamer-os";
    repo = "steamos-compositor-plus";
    rev = "7c0011cf91e87c30c2a630fee915ead58ef9dcf5";
    hash = "sha256-7RVyjbBZ4svHXKJV9Ljh6Lf5+Ry/VUUcChwEvk4oVK4=";
  };

  buildInputs = [
    udev
    SDL
    SDL_image
    libXdamage
    libXcomposite
    libXrender
    libXext
    libXxf86vm
    pkgconfig
    autoreconfHook
    gnumake
  ];

  meta = {
    description = "SteamOS Compositor";
    homepage = "https://github.com/steamos-compositor-plus";
    maintainers = [ ];
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
  };
}
