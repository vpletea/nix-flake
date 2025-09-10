{
  description = "Multi-host Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    inputs@{ nixpkgs, ... }:

    {
      nixosConfigurations."hp" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hp/machine.nix
        ];
      };
      nixosConfigurations."f2" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./f2/machine.nix
          ./f2/services.nix
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
