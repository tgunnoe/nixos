{
  imports = [ ../../profiles/develop ];

  users.users.nixos = {
    uid = 1000;
    password = "nixos";
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # to avoid zsh startup message
  home-manager.users.nrd.home.file.".zshrc" = ''
    #
  '';
}
