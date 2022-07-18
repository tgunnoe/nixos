{ pkgs, ... }:

{

  imports = [ ./zsh ./tmux ./rust ./python ];

  #environment.shellAliases = { ssh = "kitty +kitten ssh"; };

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
    appimage-run
    adoptopenjdk-icedtea-web
    deploy-rs.deploy-rs
    #libbitcoin-explorer
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
    git-filter-repo
    gnumake
    gnupg

    go
    gopls
    gopass
    go-2fa

    less
    ncdu
    neofetch

    #Nix-related
    cachix
    nix-serve
    nixpkgs-review

    nodejs
    yarn
    libusb1
    pkg-config

    texlive.combined.scheme-full
    pandoc
    #orgtoinvoice

    pkgconfig
    rubber
    sqlite
    tig
    tokei
    viu
    wget
    youtube-dl
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
      fonts = [ # nerdfonts
              ];
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
  programs.extra-container.enable = true;
  #  programs.sysdig.enable = true;
  security.audit.enable = true;
  security.polkit.enable = true;
}
