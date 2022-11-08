{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    style = (builtins.readFile ./waybar.css);
    systemd.enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        output = [
          "eDP-1"
          "HDMI-A-1"
          "DP-2"
          "DP-1"
          "Monoprice.Inc 43305 0000000000000"
          "DP-4"
        ];
        modules-left = [
          "custom/distro-icon"
          "custom/linux"
          "custom/dulP"
          "custom/ddrT"
          "sway/workspaces"
          "sway/mode"
          "custom/dulT"
        ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "custom/durS"
          "network"
          "custom/ddlS"
          "custom/durT"
          "pulseaudio"
          "custom/ddlT"
          "clock"
        ];
        modules = {
          "custom/linux" = {
            format = "{}";
            exec = "${pkgs.coreutils}/bin/uname -r | ${pkgs.coreutils}/bin/cut -d- -f1";
            interval = 999999999;
          };
          "custom/distro-icon" = {
            format = "";
          };

          "sway/window" = { max-length = 50; };
          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              "10" = "";
            };
          };
          "custom/separator" = {
            format = "/";
            interval = "once";
            tooltip = false;
          };

          "custom/dulP" = {
            format = "";
            tooltip = false;
          };
          "custom/durP" = {
            format = "";
            tooltip = false;
          };
          "custom/durS" = {
            format = "";
            tooltip = false;
          };
          "custom/ddlP" = {
            format = "";
            tooltip = false;
          };
          "custom/ddlS" = {
            format = "";
            tooltip = false;
          };
          "custom/dulS" = {
            format = "";
            tooltip = false;
          };
          "custom/ddrT" = {
            format = "";
            tooltip = false;
          };
          "custom/dulT" = {
            format = "";
            tooltip = false;
          };
          "custom/durT" = {
            format = "";
            tooltip = false;
          };
          "custom/ddlT" = {
            format = "";
            tooltip = false;
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };
          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };
          pulseaudio = {
            #scroll-step = 1, # %, can be a float
            format = "{icon}  {volume}%   {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "    {volume}%";
            format-source-muted = "  ";
            format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
          };
          battery = {
            format = " {capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-icons = [ "" "" "" "" "" ];
          };

          clock = {
            format = "{:%a %b %d  %H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d-%H:%M}";
          };

          #   "sway/workspaces" = {
          #     disable-scroll = true;
          #     all-outputs = true;
          #   };
          #   "custom/hello-from-waybar" = {
          #     format = "hello {}";
          #     max-length = 40;
          #     interval = "once";
          #     exec = pkgs.writeShellScript "hello-from-waybar" ''
          #     echo "from within waybar"
          #   '';
          #   };
        };
      }
      {
        layer = "top";
        position = "bottom";
        modules-left = [ "custom/quit" ];
        modules-center = [ "tray" ];
        modules-right = [
          "sway/language"
          "custom/ddrS"
          "cpu"
          "temperature"
          "custom/dulS"
          "custom/ddrT"
          "memory"
          "custom/dulT"
          "custom/ddrP"
          "battery"
        ];
        modules = {
          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };
          memory = {
            format = "{}% ";
          };
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = " {capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            # format-good = ""; # An empty format will hide the module
            # format-full = "";
            format-icons = [ "" "" "" "" "" ];
          };
          tray = {
            icon-size = 21;
            spacing = 10;
          };
          "sway/language" = {
            format = "{variant}";
          };
          "custom/ddrS" = {
            format = "";
          };
          "custom/dulS" = {
            format = "";
          };
          "custom/ddrT" = {
            format = "";
          };
          "custom/dulT" = {
            format = "";
          };
          "custom/ddrP" = {
            format = "";
          };
          "custom/quit" = {
            format = "";
            on-click = "swaynag -f 'Terminus (TTF)'  -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";
          };
        };
      }
    ];
  };
}
