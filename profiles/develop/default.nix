{ pkgs, ... }:

{

  imports = [ ./zsh ./tmux ./rust ./python ];

  environment.shellAliases = { v = "$EDITOR"; pass = "gopass"; };

  environment.sessionVariables = {
    PAGER = "less";
    LESS = "-iFJMRWX -z-4 -x4";
    LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    EDITOR = "emacsclient -nw";
    VISUAL = "emacsclient -nw";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_CURRENT_DESKTOP = "sway";
  };

  environment.systemPackages = with pkgs; [
    adoptopenjdk-icedtea-web
    deploy-rs.deploy-rs
    libbitcoin-explorer
    wf-recorder
    boost175
    bottom
    clang
    cmake
    encfs
    file
    gparted
    parted
    gcc
    git-crypt
    gnumake
    gnupg
    go
    gopass
    less
    ncdu
    neofetch
    nix-serve
    nixpkgs-review
    nodejs
    pandoc
    pkgconfig
    rubber
    sqlite
    tig
    tokei
    viu
    wget
    youtubeDL
    #lmms
    #fluidsynth
    #audacity
    obs-studio
    #platformio
    #obs-wlrobs
  ];

  fonts =
    let
      nerdfonts = pkgs.nerdfonts.override {
        fonts = [ "DejaVuSansMono" ];
      };
    in
    {
      fonts = [ nerdfonts ];
      fontconfig.defaultFonts.monospace =
        [ "DejaVu Sans Mono Nerd Font Complete Mono" ];
    };
  services.udev.packages = [
    # pkgs.platformio #
  ];
  documentation.dev.enable = true;

  programs.thefuck.enable = true;
  programs.firejail.enable = true;
  programs.mtr.enable = true;
  programs.sysdig.enable = true;
  security.audit.enable = true;
}
