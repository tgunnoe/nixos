{ config, pkgs, ... }: {
  home-manager.sharedModules = [
    {
      home.sessionVariables = {
        inherit (config.environment.sessionVariables) NIX_PATH;
      };
      xdg.configFile."nix/registry.json".text =
        config.environment.etc."nix/registry.json".text;
    }
    pkgs.nur.repos.rycee.hmModules.emacs-init
#    pkgs.nur.repos.emmanuelrosa.protonvpn
  ];
}
