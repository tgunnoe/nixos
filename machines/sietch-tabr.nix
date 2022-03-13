{ self, lib, config, pkgs, suites, ... }:

let
  pi4 = fetchTarball {
    url = "https://github.com/NixOS/nixos-hardware/archive/8f1bf828d8606fe38a02df312cf14546ae200a72.tar.gz";
    sha256 = "sha256:11milap153g3f63fcrcv4777vd64f7wlfkk9p3kpxi6dqd2sxvh4";
  };
in
{
  imports = ["${pi4}/raspberry-pi/4" ] ++ suites.graphics;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
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

  environment.systemPackages = with pkgs; [
    emacs-nox
    git
  ];

  services.openssh.enable = true;

  #hardware.raspberry-pi.4.fkms-3d.enable = true;

  #hardware.pulseaudio.enable = true;
}
