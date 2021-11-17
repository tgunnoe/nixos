{ lib, config, options, pkgs, ... }:
let
  inherit (builtins) readFile;

  inherit (config.hardware) pulseaudio;
in
{
  #imports = [ ../qutebrowser ];

  sound.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';

    extraPackages = with pkgs;
      options.programs.sway.extraPackages.default ++ [
        swayidle # idle handling
        swaylock # screen locking
        grim # screen image capture
        slurp # screen are selection tool
        mako # notification daemon
        kanshi # dynamic display configuration helper
        imv # image viewer
        wf-recorder # screen recorder
        wl-clipboard # wayland vers of xclip

        xdg_utils # for xdg_open
        xwayland # for X apps
        libnl # waybar wifi
        libpulseaudio # waybar audio

        autotiling
        flashfocus
        i3-swallow

        swaybg # required by sway for controlling desktop wallpaper
        clipman
        i3status-rust # simpler bar written in Rust
        drm_info
        gebaar-libinput # libinput gestures utility
        #glpaper          # GL shaders as wallpaper
        #oguri            # animated background utility
        #redshift-wayland # patched to work with wayland gamma protocol
        #rootbar
        swaylock-fancy
        waypipe # network transparency for Wayland
        wdisplays
        wlr-randr
        #wlay
        wofi
        #wtype            # xdotool, but for wayland
        #wlogout
        #wldash

        # TODO: more steps required to use this?
        #xdg-desktop-portal-wlr # xdg-desktop-portal backend for wlroots
        dmenu-wayland
        #fuzzel
        qt5.qtwayland
        #alacritty
        kitty
        volnoti

        (waybar.override { pulseSupport = pulseaudio.enable; })

      ];
  };

  environment.etc = {
    "sway/config".text =
      let
        background = ../background.jpg;
      in
      ''
        set $mixer "${pkgs.alsaUtils}/bin/amixer -q set Master"

        # set background
        output * bg ${background} fill

        ${readFile ./config}
      '';

    "xdg/waybar/config".text = builtins.toJSON (
      import ./waybar/config.nix {
        #inherit (config.networking) hostName;
        inherit pkgs;
        inherit lib;
      }
    );
    "xdg/waybar/style.css" = {
      text = (builtins.readFile ./waybar/style.css);
    };
    "xdg/mako/config" = {
      text = (builtins.readFile ./mako/config);
    };

  };

  environment.systemPackages = with pkgs; [
    (
      pkgs.writeTextFile {
        name = "startsway";
        destination = "/bin/startsway";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash

          # first import environment variables from the login manager
          systemctl --user import-environment
          # then start the service
          exec systemctl --user start sway.service
        '';
      }
    )
  ];
  programs.tmux.extraConfig = lib.mkBefore ''
    set -g @override_copy_command 'wl-copy'
  '';

  services.redshift = {
    enable = true;
    temperature.night = 3200;
    package = pkgs.redshift-wlr;
  };

  systemd.user.targets.sway-session = {
    enable = true;
    description = "sway compositor session";
    documentation = [ "man:systemd.special(7)" ];

    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    requiredBy = [ "graphical-session.target" "graphical-session-pre.target" ];
  };

  systemd.user.services.volnoti = {
    enable = true;
    description = "volnoti volume notification";
    documentation = [ "volnoti --help" ];
    wantedBy = [ "sway-session.target" ];

    script = "${pkgs.volnoti}/bin/volnoti -n";

    serviceConfig = {
      Restart = "always";
      RestartSec = 3;
    };
  };

  systemd.user.services.sway = {
    description = "Sway - Wayland window manager";
    documentation = [ "man:sway(5)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    # We explicitly unset PATH here, as we want it to be set by
    # systemctl --user import-environment in startsway
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

}
