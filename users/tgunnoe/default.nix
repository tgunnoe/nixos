{ hmUsers, config, self, lib, pkgs, ... }:
let
  inherit (builtins) toFile readFile;
  inherit (lib) fileContents mkForce;

  name = "Taylor";

in
{
  age.secrets.tgunnoe.file = "${self}/secrets/tgunnoe.age";
  age.secrets.salusa.file = "${self}/secrets/salusa.age";
  users.groups.media.members = [ "tgunnoe" ];
  users.users.tgunnoe = {
    uid = 1000;
    passwordFile = "/run/agenix/tgunnoe";
    description = name;
    shell = pkgs.zsh;
    isNormalUser = true;
    group = "tgunnoe";
    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
      "libvirtd"
      "video"
      "taskd"
      "docker"
    ];
    openssh = {
      authorizedKeys = {
        keyFiles = [ ./pubkey ];
      };
    };
  };
  # services.openvpn.servers = let
  #   config = pkgs.substituteAll {
  #     src = ./private/linode/linode.ovpn;
  #     name = "config";
  #     key = ./private/linode/linode.key;
  #     pkcs12 = ./private/linode/linode.p12;
  #   };
  # in
  #   {
  #     officeVPN  = {
  #       config = '' ${builtins.readFile config} '';
  #       authUserPass = {
  #         username = "${builtins.readFile ./private/linode/user}";
  #         password = "${builtins.readFile ./private/linode/pass}";
  #       };
  #     };
  #   };
  home-manager.users.tgunnoe = { suites, lib, nur, ... }: {
    imports = suites.graphics;
    home = {
      stateVersion = "18.09";
      file = {
        #".zshrc".text = "#";
        ".gnupg/gpg-agent.conf".text = ''
          pinentry-program ${pkgs.pinentry_curses}/bin/pinentry-curses
        '';
      };
    };

    programs = {
      mpv = {
        enable = true;
        config = {
          ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
          hwdec = "auto";
          vo = "gpu";
        };
      };

      git = {
        userName = name;
        userEmail = "tgunnoe@gnu.lv";
        # signing = {
        #   key = "8985725DB5B0C122";
        #   signByDefault = true;
        # };
      };
      firefox = {
        enable = true;
      };
      ssh = {
        enable = true;
        hashKnownHosts = true;
        matchBlocks = {
          "gnu.lv" = {
            host = "${config.networking.hostName}";
            identityFile = "/run/agenix/salusa";
            extraOptions = { AddKeysToAgent = "yes"; };
          };
        };
      };
      nix-index = {
        enable = true;
      };
    };
    services.gammastep = {
      enable = true;
      dawnTime = "6:00-7:45";
      duskTime = "18:35-20:15";
    };
  };
  location = {
    latitude = 38.0;
    longitude = -80.0;
  };
  time.timeZone = "America/New_York";
  # systemd.services.protonvpn-autoconnect = {
  #     wantedBy = [ "multi-user.target" ];
  #     description = "ProtonVPN-CLI auto-connect";
  #     wants = [ "network-online.target" ];
  #     path = with pkgs;
  #       with pkgs.python3Packages; [
  #         protonvpn-cli
  #         dialog
  #         iproute
  #         iptables
  #         openvpn
  #         procps
  #         which
  #       ];
  #     serviceConfig = {
  #       Type = "forking";
  #       Environment =
  #         [ "PVPN_WAIT=300" "PVPN_DEBUG=1" "SUDO_USER=tgunnoe" ];
  #       ExecStart =
  #         "${pkgs.protonvpn-cli}/bin/protonvpn c --p2p";
  #     };
  #   };


}
