# PLACEHOLDER — DO NOT USE AS-IS ON A REAL MACHINE
#
# Generate the real hardware configuration on the target NixOS machine:
#   sudo nixos-generate-config --show-hardware-config > hosts/nixos-btw/hardware-configuration.nix
# (or copy from /etc/nixos/hardware-configuration.nix after running nixos-generate-config)
#
# VERIFY CAREFULLY:
# - Root filesystem device/UUID and type
# - EFI System Partition (ESP) device/UUID, mount point, and that it is the correct ESP
# - Dual-boot/Windows: do not format or repurpose Windows partitions/ESP
# - Swap/ZRAM/LUKS if used
# - Kernel modules needed for this hardware (e.g. NVMe, Intel VMD, Wi-Fi)
#
# This placeholder intentionally declares no filesystems so an accidental rebuild
# fails loudly instead of applying guessed disk settings.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Define these on the target machine (generated file will replace them):
  # fileSystems."/" = { ... };
  # fileSystems."/boot" = { ... };  # or /boot/efi, depending on your setup
  # swapDevices = [ ... ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
