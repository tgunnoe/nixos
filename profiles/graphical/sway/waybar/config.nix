{ lib, pkgs }:
let
  # systemd service checker for waybar
  waycheck = pkgs.writeShellScriptBin "waycheck"
    ''
      set -e
      sanity() {
        if [ $# -lt 1 ]; then
          echo "ERR: No service name provided"
          exit 1
        fi
      }

      slurp() {
        ${pkgs.jq}/bin/jq -Mc --slurp --raw-input \
          'split("\n")
              | map(select(. != "")
              | split("=")
          {"key = .[0], "value = (.[1:] | join("="))});;
              | from_entries'
      }

      sanity $@
      SVC=''${1}
      STATE=$(${pkgs.systemd}/bin/systemctl show --no-page $SVC \
              | ${pkgs.gnugrep}/bin/grep -E '^ActiveState|^SubState' \
              | slurp)
      ACT=$(echo $STATE | ${pkgs.jq}/bin/jq -Mcr '.ActiveState')
      SUB=$(echo $STATE | ${pkgs.jq}/bin/jq -Mcr '.SubState')

      # '{xt = "$text", "tooltip = "$tooltip", "class = "$class"}';;;
      if [[  $ACT == "active" && $SUB == "running" ]]; then
          export CLASS="active"
      elif [[  $ACT == "active" && $SUB == "dead" ]]; then
          export CLASS="inactive"
      else
          export CLASS="disabled"
      fi

      ${pkgs.coreutils}/bin/printf \
      "text=%s\ntooltip=%s\nclass=%s" "" "$ACT: $SUB" "$CLASS" \
      | slurp
    '';

  baseConfig = [
    {
      layer = "top";
      position = "top";
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

    } # top bar

    {
      # bottom bar
      layer = "top";
      position = "bottom";
      modules-left = [ "custom/quit" ];
      modules-right = [
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
    } # bottom bar
  ];


  # workConfig = {
  #   modules-right = ["custom/openvpn"] ++ baseModulesRight;
  #   "custom/openvpn" = {
  #       format = "{}";
  #       max-length = 40;
  #       interval = 10;
  #       return-type = "json";
  #       exec = "${waycheck}/bin/waycheck openvpn-moo";
  #       on-click = ''
  #         ${pkgs.sudo}/bin/sudo ${pkgs.systemd}/bin/systemctl start openvpn-moo
  #       '';
  #       on-click-right = ''
  #         ${pkgs.sudo}/bin/sudo ${pkgs.systemd}/bin/systemctl stop openvpn-moo
  #       '';
  #   };
  # };

in
baseConfig
