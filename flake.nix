{
  description = "A highly structured configuration database.";

  inputs =
    {
      nixos.url = "nixpkgs/nixos-unstable";
      latest.url = "nixpkgs";
      digga.url = "github:divnix/digga";

      ci-agent = {
        url = "github:hercules-ci/hercules-ci-agent";
        inputs = { nix-darwin.follows = "darwin"; nixos-20_09.follows = "nixos"; nixos-unstable.follows = "latest"; };
      };
      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "latest";
      home.url = "github:nix-community/home-manager";
      home.inputs.nixpkgs.follows = "nixos";
      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "latest";
      nixos-hardware.url = "github:nixos/nixos-hardware";

      pkgs.url = "path:./pkgs";
      pkgs.inputs.nixpkgs.follows = "nixos";
    };

  outputs = inputs@{ self, pkgs, digga, nixos, ci-agent, home, nixos-hardware, nur, ... }:
    digga.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos = {
          overlays =
            (digga.lib.importers.pathsIn ./overlays) ++
            [
              ./pkgs/default.nix
              pkgs.overlay # for `srcs`
              nur.overlay
            ];
        };
        latest = { };
      };

      lib = import ./lib { lib = digga.lib // nixos.lib; };

      sharedOverlays = [
        (final: prev: {
          ourlib = self.lib;
        })
      ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos";
          modules = ./modules/module-list.nix;
          externalModules = [
            { _module.args.ourlib = self.lib; }
            ci-agent.nixosModules.agent-profile
            home.nixosModules.home-manager
            ./modules/customBuilds.nix
          ];
        };

        imports = [ (digga.lib.importers.importHosts ./hosts) ];
        hosts = {
          /* set host specific properties here */
          NixOS = { };
        };
        profiles = [ ./profiles ./users ];
        suites = { profiles, users, ... }: with profiles; {
          base = [ core users.nixos users.root ];
        };
      };

      home = {
        modules = ./users/modules/module-list.nix;
        externalModules = [ ];
        profiles = [ ./users/profiles ];
        suites = { profiles, ... }: with profiles; {
          base = [ direnv git ];
        };
      };

      homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };

      #defaultTemplate = self.templates.flk;
      templates.flk.path = ./.;
      templates.flk.description = "flk template";

    }
  ;
}
