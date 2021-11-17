{ self, lib, pkgs, modulesPath, suites, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ suites.goPlay;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/92e0372a-9d8a-4ccf-bfec-ab7ad9049e0f";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/58A5-0F2C";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/e19f6a23-35e3-42fe-b071-acc1eda63975"; }];

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod;
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
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "dm-snapshot" ];

      secrets = {
        "/keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
      luks.devices = {
        root = {
          name = "root";
          device = "/dev/disk/by-uuid/aa2774ab-8c38-48e6-8f54-d48f8173e4dc";
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
        };
      };
    };
  };
  console = {
    keyMap = "dvorak";
    earlySetup = true;
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
  networking = {
    hostId = "2448721d";
    hostName = "rakis";
    firewall.allowedTCPPorts = [ 8000 30000 ];
    firewall.allowedUDPPorts = [ 30000 ];
    useDHCP = false;
    interfaces.wlp170s0.useDHCP = true;
    networkmanager.enable = true;
  };

  services.openssh.openFirewall = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  system.stateVersion = "21.05";
}
