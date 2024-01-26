{
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    nixpkgs-master = { url = "github:nixos/nixpkgs/master"; };
    nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    nixpkgs-23_11 = { url = "github:nixos/nixpkgs/release-23.11"; };
    nixpkgs-lib = { url = "github:nixos/nixpkgs/nixos-unstable?dir=lib"; };
    nixpkgs-master-lib = { url = "github:nixos/nixpkgs/master?dir=lib"; };
    nixpkgs-unstable-lib = {
      url = "github:nixos/nixpkgs/nixos-unstable?dir=lib";
    };
    nixpkgs-23_11-lib = { url = "github:NixOS/nixpkgs/release-23.11?dir=lib"; };
    nixos = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    impermanence = { url = "github:nix-community/impermanence"; };
    chaotic = { url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; };
    hardware = { url = "github:nixos/nixos-hardware"; };
    nur = { url = "github:nix-community/NUR"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
    flake-utils-plus = { url = "github:gytis-ivaskevicius/flake-utils-plus"; };
    devshell = { url = "github:numtide/devshell"; };
    nix-direnv = { url = "github:nix-community/nix-direnv"; };
    flake-parts = { url = "github:hercules-ci/flake-parts"; };
    git-fat = { url = "github:hurricanehrndz/git-fat"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix = {
      url = "github:nixos/nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-regression.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discord = {
      url = "github:InternetUnexplorer/discord-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-marketplace = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatpaks = {
      url = "github:GermanBread/declarative-flatpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-master";
    };
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    with inputs;
    let
      forAllSystems = function:
        systems nixpkgs.lib.genAttrs systems
        (system: function nixpkgs.legacyPackages.${system});
      mkNixosConfiguration =
        { system ? "x86_64-linux", hostname, username, args ? { }, modules }:
        let specialArgs = argDefaults // { inherit hostname username; } // args;
        in lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            (configurationDefaults specialArgs)
            home-manager.nixosModules.home-manager
            ({ ... }: {
              nixpkgs.overlays = [
                # use old nixpkgs
                (final: _: {
                  nixpkgs-23_11 = import inputs.nixpkgs-23_11 {
                    inherit system;
                    config = defaultNixpkgs.config;
                  };
                })
                # selectively import from NUR
                (final: prev:
                  let
                    _nur = import nur {
                      pkgs = import nixpkgs { inherit system; };
                      nurpkgs = import nixpkgs { inherit system; };
                    };
                  in { cmix = _nur.repos.milahu.cmix; })
              ];
            })
          ] ++ modules;
        };
      isNotInArray = str: arr:
        !(builtins.elemAt arr
          (builtins.genList (i: str == builtins.elemAt arr i)));
      lib = nixpkgs.lib // home-manager.lib;
      argDefaults = {
        channels = inputs;
        inherit inputs self;
      } // inputs;
      allowEverything = {
        allowUnfree = true;
        allowNonSource = true;
        allowUnfreePredicate = (_: true);
        allowNonSourcePredicate = (_: true);
        allowInsecurePredicate = (_: true);
      };
      acceptAllLicenses =
        { # grep -iRE 'acceptLicense|acceptLicenseAgreement|accept_license' .
          android_sdk.accept_license = true;
          neoload.accept_license = true;
          sc2-headless.accept_license = true;
          oraclejdk.accept_license = true;

          dyalog.acceptLicense = true;
          joypixels.acceptLicense = true;
          input-fonts.acceptLicense = true;
          nvidia.acceptLicense = true;
          xxe-pe.acceptLicense = true;
          segger-jlink.acceptLicense = true;

          dfinitySdk.acceptLicenseAgreement = true;
          dfx.acceptLicenseAgreement = true;
        };
      nixpkgsFeatures = {
        cudaSupport = true;
        rocmSupport = true;
        allowAliases = true;
      };
      nixpkgsConfig = { } // allowEverything // acceptAllLicenses
        // nixpkgsFeatures;
      nixpkgsWithConfig = with inputs; rec {
        config = nixpkgsConfig;
        overlays = [ ];
      };
      defaultNixpkgs = nixpkgsWithConfig;
      configurationDefaults = args: {
        nixpkgs = defaultNixpkgs;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
        system.stateVersion = stateVersion;
      };

      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      stateVersion = "24.05";
    in {
      nixosConfigurations.nixos = mkNixosConfiguration {
        hostname = "nixos";
        username = "nixos"; # FIXME: replace with your own username!
        modules = [
          impermanence.nixosModules.impermanence
          nixos-wsl.nixosModules.wsl
          nur.nixosModules.nur
          ./test.nix
        ];
      };
    };

  nixConfig = {
    extra-substituters = [ "https://nyx.chaotic.cx/" ];
    extra-trusted-public-keys = [
      "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    ];
  };
}

#       inputsWithOverlays = [ "nur" ];
#      overlays = let
#        readyOverlays = lib.attrsets.filterAttrs
#          (name: _: lib.lists.any (el: el == name) inputsWithOverlays) inputs;
#        withoutReadyOverlays = lib.attrsets.filterAttrs
#          (name: _: !(lib.lists.any (el: el == name) array)) inputs;
#       in [
#
#] ++ readyOverlays ++ lib.attrsets.mapAttrs (name: value: (_final: prev: )) attrs;

#overlays = [
#  (self: super: {
#    allPackages = lib.mapAttrs (name: drv:
#      drv.overrideAttrs
#      (g: if g ? acceptLicense then { acceptLicense = trudss; } else { }))
#      super.allPackages;
#  })
#];

#systemd.tmpfiles.rules = [
#  "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
#  "L+ /lib64/ld-linux-x86-64.so.2 - - - - ${pkgs.stdenv.glibc}/lib64/ld-linux-x86-64.so.2"
#];

