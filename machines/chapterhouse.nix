{ lib, pkgs, modulesPath, self, suites, ... }:
{
  ### root password is empty by default ###
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ suites.play;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/91d1dfd6-bf33-46ad-8fc7-3ff39ba826ff";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/2EB0-BB29";
      fsType = "vfat";
    };
 # fileSystems."/data" =
 #   {
 #     device = "/dev/disk/by-uuid/0a782a06-91e8-40ae-88fa-6ebe18b7ea74";
 #     fsType = "ext4";
 #   };
  fileSystems."/tmp" =
    {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "nosuid" "nodev" "relatime" "size=32G"];
    };


  swapDevices =
    [{ device = "/dev/disk/by-uuid/04983f36-41ad-4dea-9227-6a3f06fbbb11"; }];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
  hardware.bluetooth.enable = true;

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    extraModulePackages = [ ];
    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-amd" ];
    kernelPatches = [
      # {
      #   name = "trackpoint-ii-support";
      #   patch = ./0001-Add-support-for-ThinkPad-TrackPoint-Keyboard-II.patch;
      #   extraConfig = ''
      #     DEBUG_INFO_BTF n
      #   '';
      # }
      # {
      #   name = "trackpoint-ii-sync-button-press";
      #   patch = ./0002-Sync-Fn-lock-state-on-button-press-for-Compact-and-T.patch;
      #   extraConfig = ''
      #     DEBUG_INFO_BTF n
      #   '';
      # }
    ];

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        device = "nodev";
        version = 2;
        efiSupport = true;
        enableCryptodisk = true;
      };
    };
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
      secrets = {
        "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
      luks.devices = {
        root = {
          name = "root";
          device = "/dev/disk/by-uuid/6e57d03c-999a-47e1-a38c-aca0e55b4013"; # UUID for /dev/nvme01np2
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
        };
      };
    };
    supportedFilesystems = [ "ntfs" ];
  };
  home-manager.users.tgunnoe.wayland.windowManager.sway.config = {
    gaps = {
      inner = 20;
      outer = 5;
    };
    output = {
      "Unknown 34CHR 0x00000000" = {
        bg = "${self}/artwork/background.jpg fill";
        resolution = "3440x1440@144hz";
        position = "0 0";
        scale = "1";
      };
      "Ancor Communications Inc ASUS MG28U 0x00001BF4" = {
        bg = "${self}/artwork/background.jpg fill";
        resolution = "3840x2160@60hz";
        position = "3440 0";
        scale = "1.5";
        #transform = "270";
      };
    };

  };

  networking = {
    hostId = "e53dd769";
    hostName = "chapterhouse";
    firewall.allowedTCPPorts = [ 8000 ];
    enableIPv6 = false;
    useDHCP = false;
    interfaces = {
      enp37s0 = {
        useDHCP = true;
        # ipv4 = {
        #   addresses = [
        #     {
        #       address = "192.168.0.5";
        #       prefixLength = 25;
        #     }
        #   ];
        # };
      };
    };
  };
  services.openssh.openFirewall = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "20.03";

}
