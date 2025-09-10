# Multi-host Nix Flake

# My Machines:
- HP - HP Probook 440 G6 Laptop
- F2 - Terramaster F2-221 2-Bay NAS
- F4 - Terramaster F4-223 4-Bay NAS

# Nixos Installation from flake
### Partitioning
- Partition Labels:
  - Boot = "boot"
  - Home = "nixos"
- Partition Size:
  - Boot = 512MiB
  - Home = Rest
```
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB -8GiB
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 2 esp
mkfs.ext4 -L nixos /dev/sda1
mkfs.fat -F 32 -n boot /dev/sda2
```
### Installation
- Mount the partitions:
  ```
  mount /dev/disk/by-label/nixos /mnt
  mkdir -p /mnt/boot
  mount /dev/disk/by-label/boot /mnt/boot
  ```
- Generate the configuration:
  ```
  nixos-generate-config --root /mnt
  ```
- Install Nixos:
  ```
  nixos-install --flake https://github.com/vpletea/nix-flake.git#hp --impure
  nixos-install --flake https://github.com/vpletea/nix-flake.git#f2 --impure
  nixos-install --flake https://github.com/vpletea/nix-flake.git#f4 --impure
  ```
### Finalization
  - Set a root password after installation is done
  - Reboot without liveCD
  - If initial password is not set use TTY via "Ctrl - Alt - F1" to login as root the use "passwd"
```
passwd user
```
  - Go back to the graphical interface by using "Ctrl - Alt - F7" then login as user

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
