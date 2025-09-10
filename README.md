# Multi-host Nix Flake

# HP
### Machine settings
- Install Nixos with Gnome Desktop from https://nixos.org/download/#nix-install-linux
- Run git:
  ```
    nix-shell -p git
  ```
- Clone the repo and switch to nixos directory:
  ```
    git clone https://github.com/vpletea/nix-flake.git
    cd nix-flake
  ```
- Install the flake:
  ```
  sudo nixos-rebuild switch --impure --flake .#hp
- To update the flake run the following command:
  ```
  nix flake update
  ```
### Dotfiles setup
- Run chezmoi init:
  ```
  chezmoi init https://github.com/vpletea/dotfiles.git
  ```
- Apply the configuration:
  ```
  chezmoi apply
  ```
# F2 Terramaster NAS
### Machine settings
- Install Nixos without the GUI
- Run git:
  ```
    nix-shell -p git
  ```
- Clone the repo and switch to nixos directory:
  ```
    git clone https://github.com/vpletea/nix-flake.git
    cd nix-flake
  ```
- Install the flake:
  ```
  sudo nixos-rebuild switch --impure --flake .#f2
- To update the flake run the following command:
  ```
  nix flake update
  ```
