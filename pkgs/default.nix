final: prev: {
  sources = prev.callPackage (import ./_sources/generated.nix) { };

  faforever = prev.callPackage ./games/faforever { };

  orgtoinvoice = prev.callPackage ./misc/orgtoinvoice { };

  i3-swallow = prev.python3Packages.callPackage ./misc/i3-swallow { };

  kickoff = prev.callPackage ./wayland/kickoff { };

  swaykbdd = prev.callPackage ./wayland/swaykbdd { };
}
