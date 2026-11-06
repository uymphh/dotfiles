{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # User packages (minimal). git/nvim/opencode are also installed system-wide in
  # the host config; keeping them here is fine and makes the Home Manager config
  # usable on its own later if you want.
  home.packages = with pkgs; [
    git
    neovim
    opencode # Verify attribute name on target: nix search nixpkgs opencode
  ];

  programs.git.enable = true;

  # Simple Neovim config hook (optional). Expand on the target machine.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Bash defaults (Home Manager manages ~/.bashrc/profile when enabled).
  programs.bash.enable = true;

  # Leave this at the Home Manager release you first use; don't change casually.
  home.stateVersion = "24.11"; # CHANGE ME if needed
  programs.home-manager.enable = true;
}
