final: prev: {
  # keep sources this first
  sources = prev.callPackage (import ./_sources/generated.nix) { };
  # then, call packages with `final.callPackage`
  i3-swallow = prev.python3Packages.callPackage ./misc/i3-swallow { };

  kickoff = prev.callPackage ./wayland/kickoff { };
}
