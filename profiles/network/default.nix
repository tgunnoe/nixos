{ pkgs, ... }: {
  imports = [ ./networkmanager /*./adblocking ./stubby*/ ];


  environment.systemPackages = with pkgs; [

    protonvpn-cli
    transmission-gtk
  ];

  # services.openvpn = {
  #   servers = {
  #     linode = {
  #       config = ''
  #         dev tun
  #         persist-tun
  #         persist-key
  #         ncp-disable
  #         cipher AES-256-CBC
  #         auth SHA512
  #         tls-client
  #         client
  #         resolv-retry infinite
  #         remote 185.247.225.30 61194 udp4
  #         verify-x509-name "iLO-CA" name
  #         auth-user-pass
  #         pkcs12 ${builtins.path ./pfSense-UDP4-61194-UID29543.p12}
  #         tls-auth ${builtins.path ./pfSense-UDP4-61194-UID29543-tls.key} 1
  #         remote-cert-tls server
  #         explicit-exit-notify
  #       '';
  #     };
  #   };
  # };

}
