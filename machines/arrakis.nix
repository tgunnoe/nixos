{ lib, pkgs, modulesPath, suites, ... }:
{
  age.secrets.salusa.file = "${self}/secrets/salusa.age";
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ suites.mobile;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/03b6cd8f-da8d-49c3-9348-4bd040c60110";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/09C4-B9D5";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/0f97c900-e2f2-4ca1-bd4b-7fb4277e6260"; }];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
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
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ "dm-snapshot" ];
      secrets = {
        "/keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
      luks.devices = {
        root = {
          name = "root";
          device = "/dev/disk/by-uuid/f33695e2-5719-44e7-bf2b-58b28eeca5ae";
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
        };
      };
    };
    supportedFilesystems = [ "ntfs" ];
  };
  console = {
    keyMap = "dvorak";
    earlySetup = true;
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
  services.tlp.enable = true;
  services.logind.extraConfig = "HandlePowerKey=ignore";
  services.thermald.enable = true;
  services.hdapsd.enable = true;
  networking = {
    hostId = "1e0adfe3";
    hostName = "arrakis";
    firewall.allowedTCPPorts = [ 8000 30000 ];
    firewall.allowedUDPPorts = [ 30000 ];
    useDHCP = false;
    interfaces.wlp58s0.useDHCP = true;
    networkmanager.enable = true;
  };
  #programs.steam.enable = true;

  services.openssh.openFirewall = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  system.stateVersion = "20.09";
}
