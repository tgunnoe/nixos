final: prev: {
  sources = prev.callPackage (import ./_sources/generated.nix) { };

  faforever = prev.callPackage ./games/faforever { };

  taforever = prev.callPackage ./games/taforever { };

  orgtoinvoice = prev.callPackage ./misc/orgtoinvoice { };

  i3-swallow = prev.python3Packages.callPackage ./misc/i3-swallow { };

  kickoff = prev.callPackage ./wayland/kickoff { };

  spring = prev.callPackage ./games/spring { };

  swaykbdd = prev.callPackage ./wayland/swaykbdd { };

  tdm = prev.callPackage ./games/tdm { };

  vcmi = prev.callPackage ./games/vcmi { };

  steamcompmgr = prev.callPackage ./applications/window-managers/steam { };
}
