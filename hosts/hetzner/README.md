# Hetzner NixOS Installation Guide

This guide covers installing NixOS on Hetzner Cloud servers using the NixOS ISO.

## Prerequisites

1. **Mount NixOS ISO**
   - Go to your Hetzner Cloud Console
   - Select your server → ISO Images → Mount ISO
   - Choose a NixOS ISO (latest stable recommended)
   - Restart your server

2. **Access the installer**
   - **Option A (Console)**: Use the Hetzner Console from the web interface
   - **Option B (SSH)**: 
     - Open console first, run `passwd` to set password for `nixos` user
     - SSH to your server IP as `nixos` user with the password you set

3. **Boot selection**
   - Select either "NixOS Linux LTS" or "NixOS Linux x.xx" from the boot menu

## Partitioning

Create an MBR partition table and three partitions:

```bash
# Create partition table
parted /dev/sda --script mklabel msdos

# Create 512MB boot partition with ext4
parted /dev/sda --script mkpart primary ext4 1MiB 513MiB
parted /dev/sda --script set 1 boot on
mkfs.ext4 -L boot /dev/sda1

# Create swap partition (8GB example - adjust for your server size)
parted /dev/sda --script mkpart primary linux-swap 513MiB 8577MiB
mkswap -L swap /dev/sda2
swapon /dev/sda2

# Create root partition using remaining disk space
parted /dev/sda --script mkpart primary ext4 8577MiB 100%
mkfs.ext4 -L nixos /dev/sda3
```

## Mount Filesystems

Mount the partitions (required for NixOS installer):

```bash
# Mount root and boot partitions
mount /dev/disk/by-label/nixos /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

## Install NixOS

Install directly from the GitHub repository:

```bash
sudo nixos-install --flake github:riadloukili/nixos-config#hetzner-<machine-id>
```

Replace `<machine-id>` with your machine identifier (e.g., `eu-lite-nix-1`).

## Post-Installation

1. **Reboot** into your new NixOS system
2. **Unmount the ISO** in Hetzner Console
3. **SSH into your server** using your configured SSH key
4. **Use the rebuild alias** for future updates:
   ```bash
   rebuild
   ```