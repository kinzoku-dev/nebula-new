{
  inputs,
  overlays,
  ...
}: {
  mkNixosSystem = system: hostname: flake-packages:
    inputs.nixpkgs.lib.mkNixosSystem {
      inherit system;
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues overlays;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
      specialArgs = {inherit inputs;};
      modules = [
        {
          nixpkgs.hostPlatform = system;
          _module.args = {
            inherit inputs flake-packages;
          };
        }
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        {
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
              inputs.catppuccin.homeManagerModules.catppuccin
            ];
            extraSpecialArgs = {
              inherit inputs hostname flake-packages;
            };
            users.kinzoku = ../. + "/homes/kinzoku";
          };
        }
        ../modules/nixos
        ../hosts/${hostname}
      ];
    };
}
