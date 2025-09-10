{
  description = "Multi-host Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = inputs @ { nixpkgs, ...}:


  {
    nixosConfigurations."hp" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./hp/host.nix
      ];
    };
  };
}
