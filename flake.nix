{
  description = "Dune universe";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = "https://nrdxp.cachix.org https://nix-community.cachix.org https://hydra.iohk.io";
    extra-trusted-public-keys = "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=";
    trusted-substituters = "http://hydra.nixos.org";
    allow-import-from-derivation = true;
  };
  inputs =
    {
      nixos.url = "github:nixos/nixpkgs/nixos-unstable";
      latest.url = "github:nixos/nixpkgs/nixos-unstable";

      digga.url = "github:divnix/digga";
      digga.inputs.nixpkgs.follows = "nixos";
      digga.inputs.nixlib.follows = "nixos";
      digga.inputs.home-manager.follows = "home";

      home.url = "github:nix-community/home-manager";
      home.inputs.nixpkgs.follows = "nixos";

      extra-container.url = "github:erikarvstedt/extra-container";
      extra-container.inputs.nixpkgs.follows = "nixos";
      extra-container.inputs.flake-utils.follows = "digga/flake-utils-plus/flake-utils";

      emacs.url = "github:nix-community/emacs-overlay/334ba8c610cf5e41dfe130507030e5587e3551b4";
      emacs.inputs.flake-utils.follows = "digga/flake-utils-plus/flake-utils";

      nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
      nixpkgs-wayland.inputs.nixpkgs.follows = "nixos";

      deploy.follows = "digga/deploy";

      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "latest";

      mobile-nixos.url = "github:zhaofengli/mobile-nixos/pp-keyboard";
      mobile-nixos.flake = false;

      nur.url = "github:nix-community/nur";

      nvfetcher.url = "github:berberman/nvfetcher";
      nvfetcher.inputs.nixpkgs.follows = "latest";
      nvfetcher.inputs.flake-compat.follows = "digga/deploy/flake-compat";
      nvfetcher.inputs.flake-utils.follows = "digga/flake-utils-plus/flake-utils";

      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "latest";

      nixos-hardware.url = "github:nixos/nixos-hardware";
    };

  outputs =
    { self
    , digga
    , nixos
    , home
    , extra-container
    , nixos-hardware
    , nur
    , agenix
    , nvfetcher
    , deploy
    , emacs
    , nixpkgs-wayland
    , ...
    } @ inputs:
    digga.lib.mkFlake
      {
        inherit self inputs;

        channelsConfig = { allowUnfree = true; };

        channels = {
          nixos = {
            imports = [ (digga.lib.importOverlays ./overlays) ];
            overlays = [
              #digga.overlays.patchedNix
              nur.overlay
              agenix.overlay
              nvfetcher.overlay
              deploy.overlay
              emacs.overlay
              nixpkgs-wayland.overlay
              ./pkgs/default.nix
            ];
          };
          latest = {
            overlays = [
              deploy.overlay
            ];
          };
        };

        lib = import ./lib { lib = digga.lib // nixos.lib; };

        sharedOverlays = [
          (final: prev: {
            __dontExport = true;
            lib = prev.lib.extend (lfinal: lprev: {
              our = self.lib;
            });
          })
        ];

        nixos = {
          hostDefaults = {
            system = "x86_64-linux";
            channelName = "nixos";
            imports = [ (digga.lib.importExportableModules ./modules) ];
            modules = [
              { lib.our = self.lib; }
              digga.nixosModules.bootstrapIso
              digga.nixosModules.nixConfig
              home.nixosModules.home-manager
              # extra-container.nixosModule
              agenix.nixosModules.age
              #bud.nixosModules.bud
              #repos.emmanuelrosa.modules.protonvpn
              ({ pkgs, ... }:
                let
                  nur-no-pkgs = import nur {
                    nurpkgs = import nixos { system = "x86_64-linux"; };
                  };
                in
                {
                  imports = [
                    # nur-no-pkgs.repos.emmanuelrosa.modules.protonvpn
                  ];
                })
            ];
          };

          imports = [ (digga.lib.importHosts ./machines) ];
          hosts = {
            /* set host specific properties here */
            NixOS = { };
            ithaca = {
              system = "x86_64-linux";
              modules = [
                #mobile-nixos.nixosModules.pine64-pinephone
              ];
            };
            sietch-tabr = {
              system = "x86_64-linux";
              modules = [
              ];
            };

          };
          importables = rec {
            profiles = digga.lib.rakeLeaves ./profiles // {
              users = digga.lib.rakeLeaves ./users;
            };
            suites = with profiles; rec {
              base = [ core users.tgunnoe users.root ];
              workstation = [ develop ssh virt base ];
              shell = [ core develop ssh virt users.root ];
              graphics = workstation ++ [ graphical ];
              mobile = graphics ++ [ laptop ];
              play = graphics ++ [
                games
                #misc.disable-mitigations
              ];
              goPlay = play ++ [ laptop ];
            };
          };
        };

        home = {
          imports = [ (digga.lib.importExportableModules ./users/modules) ];
          modules = [ ];
          importables = rec {
            profiles = digga.lib.rakeLeaves ./users/profiles;
            suites = with profiles; rec {
              base = [ direnv git ];
              develop = base ++ [
                profiles.emacs
                profiles.zsh
              ];
              noemacs = base ++ [ profiles.zsh ];
              graphics = develop ++ [ kitty sway ];
            };
          };
          users = {
            nixos = { suites, ... }: { imports = suites.base; };
            tgunnoe = { suites, ... }: {
              imports = suites.graphics;
            };
          }; # digga.lib.importers.rakeLeaves ./users/hm;
        };

        devshell = ./shell;

        homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

        deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };

        # defaultTemplate = self.templates.bud;
        # templates.bud.path = ./.;
        # templates.bud.description = "bud template";

      }
    //
    {
      #      budModules = { devos = import ./bud; };
    }
  ;
}
