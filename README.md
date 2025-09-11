# Multi-host Nix Flake

# My Machines:
- HP - HP Probook 440 G6 Laptop
- F2 - Terramaster F2-221 2-Bay NAS
- F4 - Terramaster F4-223 4-Bay NAS

# Nixos Installation from flake
### Partitioning
- Clone the repository and cd into your machine dir
- Partition the disk using disko:
```
sudo nix --experimental-features "nix-command flakes" \
run github:nix-community/disko/latest -- \
--mode destroy,format,mount ./disko.nix
```
### Installation
- Cd into the flake dir
- Install Nixos:
  ```
  sudo nixos-install --flake .#hp --no-root-passwd
  ```
### Finalization
  - Set a root password after installation is done
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

### Original install instructions: https://github.com/MatthiasBenaets/nix-config/tree/master
## To do:
  - Modularize the configuration
  - Use disko for partitioning
  - Add sops-nix for secrets management
  - Add k3s cluster setup
