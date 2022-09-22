channels: final: prev: {

  __dontExport = true; # overrides clutter up actual creations

  inherit (channels.latest)
    cachix
    dhall
    #discord
    element-desktop
    rage
    nixpkgs-fmt
    qutebrowser
    signal-desktop
    #starship
    deploy-rs
    ;

  # steam = prev.steam.override {
  #   nativeOnly = true;
  # };
  haskellPackages = prev.haskellPackages.override
    (old: {
      overrides = prev.lib.composeExtensions (old.overrides or (_: _: { })) (hfinal: hprev:
        let version = prev.lib.replaceChars [ "." ] [ "" ] prev.ghc.version;
        in
        {
          # same for haskell packages, matching ghc versions
          inherit (channels.latest.haskell.packages."ghc${version}")
            haskell-language-server;
        });
    });
  factorio = prev.factorio.override {
    username = "veleiro";
    token = "88a2d1512d4e65c2fb1e53a2997ba9";
  };
  # This doesn't apply when using the nixpkgs-overlay..
  sway = prev.sway.overrideAttrs (old: {
    patches = prev.sway.patches ++ [
      (
        prev.fetchpatch {
          name = "fix-segfault.patch";
          url = "https://github.com/swaywm/sway/pull/6484.patch";
          sha256 = "iUl8pBpj+vE6gq+WZJTD96/jGU0qNdDZD4WndYZtDUg=";
        }
      )
    ];
  });
}
