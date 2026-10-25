# Dotfiles for Guix (i3 + connman + nonguix)

This folder contains a simple, modular Guix System + Home configuration built to be readable (no fancy macros). It is set up for a laptop with Intel integrated graphics + NVIDIA (hybrid), Intel WiFi (AX200/AX211 style), and touchpad click/tap issues addressed.

## Layout

```
dotfiles/
  README.md
  guix/
    channels.scm        -> put in ~/.config/guix/channels.scm
    system/
      config.scm
      modules/
        base.scm
        boot.scm
        firmware-kernel.scm
        hardware.scm
        networking.scm
        packages.scm
        services.scm
        users.scm
        xorg-touchpad.scm  (touchpad fix)
    home/
      config.scm
      modules/
        packages.scm
        shell-zsh.scm
        wm-i3.scm
        nvim.scm
        xresources.scm
```

## 1) Setup channels (nonguix)

Put `guix/channels.scm` into `~/.config/guix/channels.scm`.

Then pull:

```bash
guix pull
```

If you want to use nonguix substitutes later, see the nonguix README (has signing key instructions). You don't need them to get started.

## 2) Edit system configuration

Before reconfiguring, edit the following files:

### `guix/system/modules/boot.scm`
- Replace `/dev/sdX` with your boot disk (e.g. `/dev/nvme0n1` or `/dev/sda`)
- Replace `PUT-YOUR-ROOT-UUID-HERE` with the UUID of your root partition (`blkid` or `lsblk -f`)
- Replace `PUT-YOUR-EFI-UUID-HERE` with the UUID of your EFI partition (if using UEFI)

### `guix/system/modules/base.scm`
- `host-name` - change to your hostname
- `timezone` - change to your timezone (e.g. `America/Los_Angeles`, `Europe/London`)
- `locale` - change to your locale (e.g. `en_US.utf8`)

### `guix/system/modules/users.scm`
- Change `yourusername` to your actual username
- Change the comment to your name
- The shell is set to `zsh` (we install it in packages)

### `guix/system/modules/services.scm`
- Change `default-user` under slim to your username

## 3) Touchpad fix (already included)

The fix is in `guix/system/modules/xorg-touchpad.scm`. It forces libinput with:
- `Tapping "on"` (tap to click)
- `TappingDrag "on"`
- `ClickMethod "clickfinger"` (good for clickpads)
- `ScrollMethod "twofinger"`
- `DisableWhileTyping "on"`
- `MiddleEmulation "on"`
- `PalmDetection "on"`

If physical buttons still don't work properly, change `ClickMethod` from `"clickfinger"` to `"buttonareas"` in that file and reconfigure.

If you want to debug in a live session: `xinput list` then `xinput list-props <touchpad-id>`. Paste the output if something is still broken and I can tweak it more.

## 4) Reconfigure

Make sure `dotfiles/` is in your home directory or somewhere accessible. Run from that location.

### Aliases (added)
Once you apply your home config, you get these aliases:

```bash
sysre   # sudo guix system reconfigure $HOME/dotfiles/guix/system/config.scm
homere  # GUILE_LOAD_PATH=$HOME/dotfiles guix home reconfigure $HOME/dotfiles/guix/home/config.scm
```

### Manual commands
```bash
sudo guix system reconfigure $HOME/dotfiles/guix/system/config.scm
GUILE_LOAD_PATH=$HOME/dotfiles guix home reconfigure $HOME/dotfiles/guix/home/config.scm
```

## 5) First boot notes

- **WiFi**: Intel AX200/AX210/AX211 are covered by `linux-firmware`. Use `connmanctl` to connect. Example:
  ```bash
  connmanctl
  > enable wifi
  > scan wifi
  > services
  > agent on
  > connect wifi_<hash>_<ssid>_managed_psk
  ```
  Your user needs to be in `netdev` group (already added in users.scm).
- **Brightness**: Use `brightnessctl`. In i3, `XF86MonBrightnessUp`/`XF86MonBrightnessDown` are bound. If your keys don't work, try `brightnessctl set +10%` manually.
- **Editor**: `nvim` with a very basic config (line numbers, 4 spaces). Edit `~/.config/nvim/init.lua` to extend it.
- **Window manager**: i3 with `Mod4+d` for dmenu, `Mod4+Return` for xterm. Edit `~/.config/i3/config`.
- **Shell**: `zsh` is installed. After first login you can change it with `chsh -s $(which zsh)`.
- **Intel+NVIDIA hybrid**: This config uses modesetting/xf86-video-intel + nouveau. If you want the proprietary NVIDIA driver, use `nonguix-transformation-nvidia`. I can help set that up, but it needs extra care.
- **vmd/Intel Volume Management Device**: Usually handled by the kernel. No extra config is needed here.
- **Debugging touchpad**: `xinput list` and `xinput list-props` are available (xinput added to packages).

## Tips
- Keep this modular. If you want to add something, make a new module in `modules/` and import it.
- This is intentionally KISS - no unnecessary abstractions.
- If reconfigure fails, read the error. Most of the time it's wrong UUIDs or username mismatches.
