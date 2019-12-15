{ nix, nixpkgs, flake, ... }:
let
  utils = import ../lib/utils.nix { lib = nixpkgs.lib; };

  inherit (utils)
    reqImport
    vimport
    ;


  config = self:
    nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      modules = let
        core = ../profiles/core.nix;

        global = {
          _module.args.utils = utils;
          networking.hostName = self;
          nix.package = nix.defaultPackage."${system}";
          system.configurationRevision = flake.rev;
        };

        local = vimport ./. "${self}.nix";
      in
        [
          core
          global
          local
        ];

    };
in
reqImport { dir = ./.; _import = config; }
