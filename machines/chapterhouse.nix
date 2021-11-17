{ lib, pkgs, modulesPath, suites, ... }:
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
  fileSystems."/data" =
    {
      device = "/dev/disk/by-uuid/0a782a06-91e8-40ae-88fa-6ebe18b7ea74";
      fsType = "ext4";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/04983f36-41ad-4dea-9227-6a3f06fbbb11"; }];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
  hardware.bluetooth.enable = true;

  boot = {
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-amd" ];
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

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "20.03";

}
