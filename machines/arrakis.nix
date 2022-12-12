{ self, lib, pkgs, modulesPath, suites, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ suites.goPlay;

  fileSystems."/" =
    {
      device = "rpool/encrypted/local/root";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/5163-575B";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    {
      device = "rpool/encrypted/local/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "rpool/encrypted/safe/home";
      fsType = "zfs";
    };

  fileSystems."/persist" =
    {
      device = "rpool/encrypted/safe/persist";
      fsType = "zfs";
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" "g_ether" ];

    # source: https://grahamc.com/blog/nixos-on-zfs
    kernelParams = [ "elevator=none" ];

    extraModulePackages = [ ];

    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        #efiSysMountPoint = "/boot/efi";
      };
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "dm-snapshot" ];

      # source: https://grahamc.com/blog/erase-your-darlings
      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r rpool/encrypted/local/root@blank
      '';
    };
  };
  console = {
    keyMap = "dvorak";
    earlySetup = true;
  };
  home-manager.users.tgunnoe.wayland.windowManager.sway.config = {
    gaps = {
      inner = 20;
      outer = 5;
    };
    output = {
      eDP-1 = {
        bg = "${self}/artwork/background.jpg fill";
        resolution = "2256x1504@60hz";
        scale = "1.5";
        position = "3440 2508";
      };
      "Ancor Communications Inc ASUS MG28U 0x00001BF4" = {
        bg = "${self}/artwork/background.jpg fill";
        resolution = "2560x1440@60hz";
        scale = "1";
        position = "4944 590";
        transform = "270";
      };
      "Optoma Corporation OPTOMA 1080P A7EH9220010" = {
        resolution = "1920x1080@60hz";
      };
      # "Beihai Century Joint Innovation Technology Co.,Ltd 34CHR Unknown" = {
      DP-4 = {
        bg = "${self}/artwork/background.jpg fill";
        resolution = "3440x1440@144hz";
        position = "1159 1068";
        scale = "1";
      };

    };
    input = {
      "1:1:AT_Translated_Set_2_keyboard" = {
        xkb_layout = "dvorak,us";
        xkb_options = "ctrl:nocaps,grp:rctrl_toggle";
      };
      "2362:628:PIXA3854:00_093A:0274_Touchpad" = {
        tap = "enabled";
        middle_emulation = "enabled";
        natural_scroll = "disabled";
        dwt = "enabled";

      };
    };
  };
  i18n.defaultLocale = "en_US.UTF-8";

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
  services.tlp.enable = true;
  services.logind.extraConfig = "HandlePowerKey=ignore";
  services.thermald.enable = true;
  services.hdapsd.enable = true;
  services.fstrim.enable = true;
  networking = {
    hostId = "e7ce15ef";
    hostName = "arrakis";
    firewall.allowedTCPPorts = [ 8000 30000 ];
    firewall.allowedUDPPorts = [ 30000 ];
    useDHCP = false;
    #    interfaces.wlp170s0.useDHCP = true;
    networkmanager.enable = true;
  };
  services.openssh = {
    hostKeys =
      [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    openFirewall = true;
  };

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  #hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "22.11";

}
