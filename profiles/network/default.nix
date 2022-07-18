{ pkgs, ... }: {
  imports = [ ./networkmanager /*./adblocking ./stubby*/ ];


  environment.systemPackages = with pkgs; [
    iproute2
    protonvpn-cli_2
    transmission-gtk
  ];

}
