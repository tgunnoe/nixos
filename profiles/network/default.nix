{ pkgs, ... }: {
  imports = [ ./networkmanager /*./adblocking ./stubby*/ ];


  environment.systemPackages = with pkgs; [
    iproute2
    protonvpn-cli
    transmission-gtk
  ];

}
