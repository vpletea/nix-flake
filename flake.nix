{
  description = "Multi-host Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    inputs@{ nixpkgs, disko, ... }:

    {
      nixosConfigurations."hp" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hp/machine.nix
          inputs.disko.nixosModules.disko
        ];
      };
      nixosConfigurations."f2" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/terra-f2/machine.nix
          ./machines/terra-f2/services.nix
        ];
      };
      nixosConfigurations."f4" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./f4/machine.nix
          ./f4/services.nix
        ];
      };
    };
}
