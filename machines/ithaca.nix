{ config, self, lib, inputs, pkgs, modulesPath, suites, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "pine64-pinephone";
    })
  ] ++ suites.user;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.self.overlay ];
  environment.systemPackages = [
    pkgs.chatty
    pkgs.megapixels
  ];

  hardware.firmware = [ config.mobile.device.firmware ];

  hardware.sensor.iio.enable = true;
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.openFirewall = true;

  boot.kernelParams = [
    "fbcon=rotate:3"
  ];
  users.users = {
    tgunnoe = {
      uid = 1000;
      password = "tagpass";
      isNormalUser = true;
      group = "tgunnoe";
      extraGroups = [
        "wheel"
        "input"
        "networkmanager"
        "libvirtd"
        "video"
        "feedbackd"
        "dialout"
      ];
    };
    geoclue.extraGroups = [ "networkmanager" ];
  };
  powerManagement.enable = true;
  hardware.opengl.enable = true;
  networking.wireless.enable = false;
  # networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;

  # # FIXME : configure usb rndis through networkmanager in the future.
  # # Currently this relies on stage-1 having configured it.
  # networking.networkmanager.unmanaged = [ "rndis0" "usb0" ];

  mobile.boot.stage-1.networking.enable = lib.mkDefault true;
  hardware.bluetooth.enable = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  programs.calls.enable = true;
  services.geoclue2.enable = true;

  system.stateVersion = "21.11";
}
