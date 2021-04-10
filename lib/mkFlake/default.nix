{ dev, nixos, inputs, ... }:
let
  inherit (dev) os;
  inherit (inputs) utils deploy;
  evalFlakeArgs = dev.callLibs ./evalArgs.nix;
in

{ self, ... } @ args:
let

  cfg = (evalFlakeArgs { inherit args; }).config;

  multiPkgs = os.mkPkgs { inherit (cfg) extern overrides; };

  outputs = {
    nixosConfigurations = os.mkHosts {
      inherit self multiPkgs;
      inherit (cfg) extern suites overrides;
      dir = cfg.hosts;
    };

    homeConfigurations = os.mkHomeConfigurations;

    nixosModules = cfg.modules;

    homeModules = cfg.userModules;

    overlay = cfg.packages;
    inherit (cfg) overlays;

    deploy.nodes = os.mkNodes deploy self.nixosConfigurations;
  };

  systemOutputs = utils.lib.eachDefaultSystem (system:
    let
      pkgs = multiPkgs.${system};
      # all packages that are defined in ./pkgs
      legacyPackages = os.mkPackages { inherit pkgs; };
    in
    {
      checks =
        let
          tests = nixos.lib.optionalAttrs (system == "x86_64-linux")
            (import "${self}/tests" { inherit self pkgs; });
          deployHosts = nixos.lib.filterAttrs
            (n: _: self.nixosConfigurations.${n}.config.nixpkgs.system == system)
            self.deploy.nodes;
          deployChecks = deploy.lib.${system}.deployChecks { nodes = deployHosts; };
        in
        nixos.lib.recursiveUpdate tests deployChecks;

      inherit legacyPackages;
      packages = dev.filterPackages system legacyPackages;

      devShell = import "${self}/shell" {
        inherit self system;
      };
    });
in
outputs // systemOutputs

