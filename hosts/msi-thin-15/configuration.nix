{ config, pkgs, lib, username, ... }:

{
  imports = [
    # IMPORTANT: Replace this placeholder with the real file generated on the target machine:
    #   sudo nixos-generate-config --show-hardware-config > /etc/nixos-or-repo/hosts/msi-thin-15/hardware-configuration.nix
    # Verify disk/ESP/boot settings carefully (dual-boot / UEFI / Windows).
    ./hardware-configuration.nix
  ];

  # --- Nix / flakes ---------------------------------------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # MSI/NVIDIA hardware may need unfree firmware/drivers; adjust as needed.

  # --- Boot (VERIFY on target machine before switching) ---------------------
  # This is a safe default for UEFI systems. Confirm your ESP mount point and
  # that it does NOT conflict with Windows boot management.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # If you prefer GRUB or have a specific dual-boot setup, change this after
  # inspecting `lsblk -f` and `efibootmgr -v` on the target machine.

  # --- Basics ---------------------------------------------------------------
  networking.hostName = "msi-thin-15"; # keep in sync with flake host name
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles"; # CHANGE ME
  i18n.defaultLocale = "en_US.UTF-8";

  # --- User -----------------------------------------------------------------
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.bash;
  };

  # --- Packages (minimal, as requested) -------------------------------------
  environment.systemPackages = with pkgs; [
    git
    neovim
    opencode # If this attribute name differs on your nixpkgs revision, run: nix search nixpkgs opencode
    wget
    curl
  ];

  # Optional but handy when using flakes from a fresh system.
  programs.git.enable = true;

  # Keep the system minimal. Add SSH/audio/graphical services on the target
  # machine only if/when you need them.

  # Set this to the NixOS release you first installed on the target machine.
  # Do NOT change casually after installation.
  system.stateVersion = "24.11"; # CHANGE ME if your initial install differs
}
