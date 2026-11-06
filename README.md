# NixOS dotfiles (minimal baseline)

Minimal, working NixOS flake for getting started on the target machine:

- **nixpkgs-unstable** (flake input)
- **Flakes** enabled (`nix-command` + `flakes`)
- **Home Manager** integrated as a NixOS module
- **git**, **neovim**, **opencode** included (verify the `opencode` attribute name on your nixpkgs revision)

> This repo was reset from a Guix config to a simple NixOS baseline so you can continue configuring on the machine being installed.

## Before you switch (important)

These values are **placeholders until verified on the target machine**:

1. **Hardware config**: replace `hosts/nixos-btw/hardware-configuration.nix` with the real one:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/nixos-btw/hardware-configuration.nix
   ```
   Verify filesystems, ESP mount point, swap, and kernel modules. **Do not guess disk devices** on a dual-boot/UEFI system.
2. **Bootloader / dual-boot**: confirm `lsblk -f` and `efibootmgr -v`. The config enables `systemd-boot` by default; adjust if your setup uses GRUB or a specific Windows/UEFI layout.
3. **Username/hostname**: update `username`/`hostname` in `flake.nix`, user/home paths, `networking.hostName`, and `home/arctan/` directory name if needed.
4. **Timezone / locale / state versions**: adjust in `hosts/nixos-btw/configuration.nix` and `home/arctan/home.nix`.
5. **opencode package**: confirm it exists/evaluates:
   ```bash
   nix search nixpkgs opencode
   # or
   nix eval nixpkgs#opencode.name
   ```
   If the attribute differs, update `environment.systemPackages` and/or `home.packages`.

## First build on the target machine

From the repo root (after fixing hardware/boot/user settings):

```bash
# Optional: create/update the lock file intentionally
nix flake lock

# Check evaluation/build
sudo nixos-rebuild build --flake .#nixos-btw

# Switch when ready
sudo nixos-rebuild switch --flake .#nixos-btw
```

## Layout

```text
.
├── flake.nix
├── OPENCODE.md
├── hosts/
│   └── nixos-btw/
│       ├── configuration.nix
│       └── hardware-configuration.nix   # replace with generated file
├── home/
│   └── arctan/
│       └── home.nix
└── README.md
```

## Notes

- `flake.lock` is not committed from this environment. Generate/update it on the target machine with `nix flake lock` (or during rebuild) and commit it for reproducibility.
- Keep changes declarative. Avoid `nix-env`/imperative installs.
- Expand modules/services/packages incrementally once the baseline boots and rebuilds cleanly.
