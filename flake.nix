{
  description = "Multi machine flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = inputs @ { nixpkgs, ...}:

  let
    nixos-username = "valentin";
    nixos-hostname = "nixos";
  in

  {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs nixos-username nixos-hostname; };
    modules = [
      ./host.nix
      ];
    };
  };
}
