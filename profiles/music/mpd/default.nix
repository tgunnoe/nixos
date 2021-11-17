{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpc_cli
    mpd
  ];
  services.mpd = {
    enable = true;
  };
}
