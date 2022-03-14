{ self, lib, config, pkgs, suites, inputs, ... }:

let
  pi4 = fetchTarball {
    url = "https://github.com/NixOS/nixos-hardware/archive/8f1bf828d8606fe38a02df312cf14546ae200a72.tar.gz";
    sha256 = "sha256:11milap153g3f63fcrcv4777vd64f7wlfkk9p3kpxi6dqd2sxvh4";
  };
in
{
  imports = [
    "${pi4}/raspberry-pi/4"
  ] ++ suites.graphics;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # Some gui programs need this
        "cma=128M"
    ];
    loader.raspberryPi.firmwareConfig = ''
      dtparam=audio=on
    '';
  };
  networking = {
    hostName = "sietch-tabr";
    firewall.allowedTCPPorts = [ 8000 30000 ];
    firewall.allowedUDPPorts = [ 30000 ];
    useDHCP = false;
    # wireless = {
    #   enable = true;
    #   #interfaces.wlan0.useDHCP = true;
    # };
    networkmanager.enable = true;
  };
  environment.systemPackages = [
    pkgs.openmw
  ];
  console = {
    keyMap = "dvorak";
    earlySetup = true;
  };
  sound.enable = true;
  services.openssh.enable = true;
  services.openssh.openFirewall = true;

  hardware.raspberry-pi."4".fkms-3d.enable = true;
  hardware.enableRedistributableFirmware = true;

  #hardware.pulseaudio.enable = true;
  home-manager.users.tgunnoe.wayland.windowManager.sway.config = {
    gaps = {
      inner = 20;
      outer = 5;
    };
    output = {
      "*" = {
        bg = "${self}/artwork/background.jpg fill";
      };
      "Unknown 34CHR 0x00000000" = {
        resolution = "3440x1440@144hz";
      };
      "Ancor Communications Inc ASUS MG28U 0x00001BF4" = {
        resolution = "3840x2160@60hz";
        scale = "1.5";
        position = "2880 0";
      };
    };
    input = {
      "1:1:AT_Translated_Set_2_keyboard" = {
        xkb_layout = "dvorak,us";
        xkb_options = "ctrl:nocaps";
      };
    };
  };
  i18n.defaultLocale = "en_US.UTF-8";
  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };
  nixpkgs.config = {
    allowUnfree = true;
  };
  powerManagement.cpuFreqGovernor = "ondemand";
  system.stateVersion = "21.11";
}
