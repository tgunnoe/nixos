{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    acpi
    libinput
    lm_sensors
    wirelesstools
    pciutils
    usbutils
    fwupd
  ];
  #networking.wireless.iwd.enable = true;
  #networking.wireless.enable = true;
  hardware.bluetooth.enable = true;

  # to enable brightness keys 'keys' value may need updating per device
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -A 5";
      }
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -U 5";
      }
    ];
  };

  sound.mediaKeys = lib.mkIf (!config.hardware.pulseaudio.enable) {
    enable = true;
    volumeStep = "1dB";
  };

  # better timesync for unstable internet connections
  services.chrony.enable = true;
  services.timesyncd.enable = false;

  # power management features

  powerManagement.enable = true;
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_HWP_ON_AC = "performance";
  };

  services.logind.extraConfig = "HandlePowerKey=ignore";
  services.logind.lidSwitch = "suspend";

  services.thermald.enable = true;
  services.hdapsd.enable = true;

  services.fwupd.enable = true;

  nixpkgs.overlays =
    let
      light_ov = self: super: {
        light = super.light.overrideAttrs (o: {
          src = self.fetchFromGitHub {
            owner = "haikarainen";
            repo = "light";
            rev = "ae7a6ebb45a712e5293c7961eed8cceaa4ebf0b6";
            sha256 = "00z9bxrkjpfmfhz9fbf6mjbfqvixx6857mvgmiv01fvvs0lr371n";
          };
        });
      };
    in
    [ light_ov ];
}
