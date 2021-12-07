{ pkgs, ... }: {
  imports = [ ./networkmanager /*./adblocking ./stubby*/ ];


  environment.systemPackages = with pkgs; [

    protonvpn-cli
    transmission-gtk
  ];

}
