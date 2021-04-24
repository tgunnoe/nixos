{ lib }:

{ nixos, args }:
let
  argOpts = with lib; { config, ... }:
    let
      inherit (lib) os;

      inherit (config) self;

      maybeImport = obj:
        if (builtins.typeOf obj == "path") || (builtins.typeOf obj == "string") then
          import obj
        else
          obj;

      /* Custom types needed for arguments */

      moduleType = with types; pathTo (anything // {
        inherit (submodule { }) check;
        description = "valid module";
      });
      overlayType = pathTo (types.anything // {
        check = builtins.isFunction;
        description = "valid Nixpkgs overlay";
      });
      systemType = types.enum config.supportedSystems;
      flakeType = with types; (addCheck attrs lib.isStorePath) // {
        description = "nix flake";
      };

      # Apply maybeImport during merge and before check
      # To simplify apply keys and improve type checking
      pathTo = elemType: with types; coercedTo path maybeImport elemType;

      # Accepts single item or a list
      # apply keys end up with a list
      # This should not be used if expecting a nested list
      # all lists will get flattened by this
      coercedListOf = elemType:
        let coerceToList = x: flatten (singleton x); in
        with types; coercedTo elemType coerceToList (listOf elemType);

      pathToListOf = x: pathTo (coercedListOf x);

      /* Submodules needed for API containers */

      channelsModule = {
        options = with types; {
          input = mkOption {
            type = flakeType;
            default = nixos;
            description = ''
              nixpkgs flake input to use for this channel
            '';
          };
          overlays = mkOption {
            type = pathToListOf overlayType;
            default = [ ];
            description = ''
              overlays to apply to this channel
              these will get exported under the 'overlays' flake output as <channel>/<name>
            '';
          };
          externalOverlays = mkOption {
            type = pathToListOf overlayType;
            default = [ ];
            description = ''
              overlays to apply to the channel that don't get exported to the flake output
              useful to include overlays from inputs
            '';
          };
          config = mkOption {
            type = pathTo attrs;
            default = { };
            description = ''
              nixpkgs config for this channel
            '';
          };
        };
      };

      hostModule = {
        options = with types; {
          system = mkOption {
            type = systemType;
            default = "x86_64-linux";
            description = ''
              system for this host
            '';
          };
          channelName = mkOption {
            type = types.enum (builtins.attrValues config.channels);
            default = "nixpkgs";
            description = ''
              Channel this host should follow
            '';
          };

        };
      };

      # This is only needed for hostDefaults
      # modules in each host don't get exported
      externalModulesModule = {
        options = {
          externalModules = mkOption {
            type = pathToListOf moduleType;
            default = [ ];
            description = ''
              The configuration for this host
            '';
          };
        };
      };

      modulesModule = {
        options = {
          modules = mkOption {
            type = pathToListOf moduleType;
            default = [ ];
            description = ''
              modules to include
            '';
          };
        };
      };

      # Home-manager's configs get exported automatically from nixos.hosts
      # So there is no need for a host options in the home namespace
      # This is only needed for nixos
      includeHostsModule = { name, ... }: {
        options = with types; {
          hostDefaults = mkOption {
            type = submodule [ hostModule externalModulesModule modulesModule ];
            default = { };
            description = ''
              Defaults for all hosts.
              the modules passed under hostDefaults will be exported
              to the '${name}Modules' flake output.
              They will also be added to all hosts.
            '';
          };
          hosts = mkOption {
            type = attrsOf (submodule [ hostModule modulesModule ]);
            default = { };
            description = ''
              configurations to include in the ${name}Configurations output
            '';
          };
        };
      };

      # profiles and suites - which are profile collections
      profilesModule = { name, ... }: {
        options = with types; {
          profiles = mkOption {
            type = coercedListOf path;
            default = [ ];
            apply = list:
              # Merge a list of profiles to one set
              let profileList = map (x: os.mkProfileAttrs (toString x)) list; in
              foldl (a: b: a // b) { } profileList;
            description = "path to profiles folder that can be collected into suites";
          };
          suites = mkOption {
            type = pathTo (functionTo attrs);
            default = _: { };
            apply = suites: os.mkSuites {
              inherit suites;
              inherit (config) profiles;
            };
            description = ''
              Function with the input of 'profiles' that returns an attribute set
              with the suites for this config system.
              These can be accessed through the 'suites' special argument.
            '';
          };
        };
      };
    in
    {
      options = with types; {
        self = mkOption {
          type = flakeType;
          description = "The flake to create the devos outputs for";
        };
        supportedSystems = mkOption {
          type = listOf str;
          default = lib.defaultSystems;
          description = ''
            The systems supported by this flake
          '';
        };
        channels =
          let
            default = {
              nixpkgs = {
                input = nixos;
              };
            };
          in
          mkOption {
            type = attrsOf (submodule channelsModule);
            inherit default;
            apply = x: default // x;
            description = ''
              nixpkgs channels to create
            '';
          };
        os = mkOption {
          type = submodule [ includeHostsModule profilesModule ];
          default = { };
          description = ''
            hosts, modules, suites, and profiles for nixos
          '';
        };
        home = mkOption {
          type = submodule [ profilesModule modulesModule ];
          default = { };
          description = ''
            hosts, modules, suites, and profiles for home-manager
          '';
        };
      };
    };
in
lib.evalModules {
  modules = [ argOpts args ];
}
