final: prev: {
  sources = prev.callPackage (import ./_sources/generated.nix) { };

  faforever = prev.callPackage ./games/faforever { };

  i3-swallow = prev.python3Packages.callPackage ./misc/i3-swallow { };

  kickoff = prev.callPackage ./wayland/kickoff { };
}
