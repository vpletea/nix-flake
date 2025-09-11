# Multi-host Nix Flake

# My Machines:
- HP - HP Probook 440 G6 Laptop
- F2 - Terramaster F2-221 2-Bay NAS
- F4 - Terramaster F4-223 4-Bay NAS

# Nixos Installation from flake

### Partitioning
- Clone the repository and cd to your machine directory
- Partition the disk using disko:
```
sudo nix --experimental-features "nix-command flakes" \
run github:nix-community/disko/latest -- \
--mode destroy,format,mount ./disko.nix
```
### Installation
- Go to the flake root directory
- Install Nixos:
  ```
  sudo nixos-install --flake .#hp --no-root-passwd
  ```

### Finalization
  - Reboot without liveCD

### Dotfiles setup
- Run chezmoi init:
  ```
  chezmoi init https://github.com/vpletea/dotfiles.git 
  ```
- Apply the configuration:
  ```
  chezmoi apply
  ```

### Useful flake commands:
- Apply the flake after Nixos installation:
```
sudo nixos-rebuild switch --impure --flake .#hp
```
- Update the flake:
```
nix flake update
```

# To do:
  - Add k3s cluster setup
  - Modularize the configuration
  - Add sops-nix for secrets management

