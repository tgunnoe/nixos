{ pkgs, ... }:
let inherit (builtins) readFile;
in
{
  imports = [ ../develop ../network ./im ./bitcoin ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = false;

  boot = {
    tmpOnTmpfs = true;

    kernel.sysctl."kernel.sysrq" = 1;

  };

  environment = {

    etc = {
      "xdg/gtk-3.0/settings.ini" = {
        text = ''
          [Settings]
          gtk-icon-theme-name=Papirus
          gtk-theme-name=Adapta
          gtk-cursor-theme-name=Adwaita
        '';
        mode = "444";
      };
    };

    sessionVariables = {
      # Theme settings
      QT_QPA_PLATFORMTHEME = "gtk2";

      GTK2_RC_FILES =
        let
          gtk = ''
            gtk-icon-theme-name="Papirus"
            gtk-cursor-theme-name="Adwaita"
          '';
        in
        [
          ("${pkgs.writeText "iconrc" "${gtk}"}")
          "${pkgs.adapta-gtk-theme}/share/themes/Adapta/gtk-2.0/gtkrc"
          "${pkgs.gnome3.gnome-themes-extra}/share/themes/Adwaita/gtk-2.0/gtkrc"
        ];
    };

    systemPackages = with pkgs; [
      #discord
      #foxitreader
      firefox-wayland
      glxinfo
      imv
      ffmpeg-full
      imagemagick
      librsvg
      libreoffice
      libsForQt5.qtstyleplugins
      man-pages
      pulsemixer
      pavucontrol
      qt5.qtgraphicaleffects
      stdmanpages
      gimp
      inkscape
      chromium
      nomacs
      #tor-browser-bundle-bin
      nyxt
      pcmanfm
      mupdf
      # video pkgs
      gnome3.adwaita-icon-theme
      vlc
      untrunc

    ];
  };
  services.flatpak.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.tor.enable = true;
  services.tor.client.enable = true;
  services.greetd = {
    enable = false;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
        user = "tgunnoe";
      };
    };
  };
  # services.xserver.displayManager.gdm = {
  #   enable = true;
  # };
}
