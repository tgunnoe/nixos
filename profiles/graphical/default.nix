{ config, pkgs, ... }:
let inherit (builtins) readFile;
in {
  imports = [ ./sway ../develop ./xmonad ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = false;

  environment = {
    etc = {
      "xdg/gtk-3.0/settings.ini" = {
        text = ''
            [ Settings ]
            gtk-icon-theme-name=Papirus-Adapta
          gtk-theme-name=Adapta
          gtk-cursor-theme-name=Adwaita
        '';
        mode = "444";
      };
    };

    sessionVariables = {
      # Theme settings
      QT_QPA_PLATFORMTHEME = "gtk2";
      GTK2_RC_FILES = let
        gtk = ''
          gtk-icon-theme-name="Papirus-Adapta"
          gtk-cursor-theme-name="Adwaita"
        '';
      in [
        ("${pkgs.writeText "iconrc" "${gtk}"}")
        "${pkgs.adapta-gtk-theme}/share/themes/Adapta/gtk-2.0/gtkrc"
        "${pkgs.gnome3.gnome-themes-extra}/share/themes/Adwaita/gtk-2.0/gtkrc"
      ];
    };

    systemPackages = with pkgs; [
      adapta-gtk-theme
      cursor
      dzen2
      feh
      ffmpeg-full
      firefox
      gnome3.adwaita-icon-theme
      gnome-themes-extra
      imagemagick
      imlib2
      librsvg
      libsForQt5.qtstyleplugins
      papirus-icon-theme
      sddm-chili
      zathura
      xsel
    ];
  };

  services.xbanish.enable = true;

  services.xserver = {
    enable = true;

    desktopManager.plasma5.enable = true;

    libinput.enable = true;

    displayManager.sddm = {
      enable = true;
      theme = "chili";
    };
  };
}
