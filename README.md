# Dotfiles for Guix (i3 + connman + nonguix)

Guix System + Guix Home configuration for a laptop with Intel WiFi (AX200/AX211),
hybrid Intel + NVIDIA graphics, and an i3 desktop.

The two configs are **single files with no local modules**, so there is no
`GUILE_LOAD_PATH` to set and no "unbound variable" / "no code for module" games.
Packages are looked up with `specification->package`, so we also do not depend
on guessing which `(gnu packages ...)` module defines each package.

## Layout

```
dotfiles/
  README.md
  guix/
    channels.scm        -> copy to ~/.config/guix/channels.scm
    system/
      config.scm        -> the whole operating-system
    home/
      config.scm        -> the whole home-environment
```

The old `modules/` folders are left in the repo for reference, but the configs
do not use them anymore.

## 1) Setup channels (nonguix)

```bash
mkdir -p ~/.config/guix
cp ~/dotfiles/guix/channels.scm ~/.config/guix/channels.scm
guix pull
```

`guix pull` takes a while. Let it finish.

If you want the nonguix substitute server later, follow the nonguix README
(signing key instructions). It is not required to boot.

## 2) Check the system config

Everything lives in `guix/system/config.scm`. The values already set are:

| Setting | Value |
| --- | --- |
| hostname | `guix-btw` |
| timezone | `America/Los_Angeles` |
| locale | `en_US.utf8` |
| user | `arctan` (groups: wheel, netdev, audio, video, input) |
| shell | zsh |
| root partition | `/dev/nvme0n1p8` (ext4) |
| EFI partition | `/dev/nvme0n1p6` (vfat, mounted at `/boot/efi`) |
| bootloader | GRUB **EFI**, target `/boot/efi` |

If any of that changes, edit the matching `define` in that file.

**BIOS vs UEFI:** the config assumes UEFI because you have `/boot/efi`. If the
machine actually boots in BIOS/legacy mode, change:

```scheme
(bootloader grub-efi-bootloader)
(targets '("/boot/efi"))
```

to:

```scheme
(bootloader grub-bootloader)
(targets '("/dev/nvme0n1"))
```

**Partition paths:** raw paths work, but UUIDs survive hardware changes better.
If you prefer UUIDs, replace `(device "/dev/nvme0n1p8")` with
`(device (uuid "YOUR-UUID" 'ext4))`, etc.

**Filesystem type:** the root filesystem is assumed to be `ext4`. If `lsblk -f`
shows something else, change `(type "ext4")` in the root `file-system` entry
before reconfiguring.

## 3) Touchpad fix (already included)

The `xorg-configuration` in `guix/system/config.scm` forces libinput with:

- `Tapping "on"` (tap to click)
- `TappingDrag "on"`
- `ClickMethod "clickfinger"` (good for clickpads)
- `ScrollMethod "twofinger"`
- `DisableWhileTyping "on"`
- `MiddleEmulation "on"`

If the physical buttons behave oddly, change `ClickMethod` from
`"clickfinger"` to `"buttonareas"` and reconfigure.

To debug in a running session:

```bash
xinput list
xinput list-props <touchpad-id>
```

## 4) Install / reconfigure

System (no load path needed):

```bash
sudo guix system reconfigure ~/dotfiles/guix/system/config.scm
```

Home (no load path needed):

```bash
guix home reconfigure ~/dotfiles/guix/home/config.scm
```

After applying the home config you get these zsh aliases:

```bash
sysre    # sudo guix system reconfigure ~/dotfiles/guix/system/config.scm
homere   # guix home reconfigure ~/dotfiles/guix/home/config.scm
```

## 5) First boot notes

- **WiFi**: Intel AX200/AX210/AX211 firmware comes from `linux-firmware`.
  Connect with `connmanctl`:

  ```bash
  connmanctl
  > enable wifi
  > scan wifi
  > services
  > agent on
  > connect wifi_<hash>_<ssid>_managed_psk
  ```

  Your user is in the `netdev` group.
- **Brightness**: `brightnessctl`. The i3 config binds the brightness keys.
  Manual test: `brightnessctl set +10%`.
- **Audio**: ALSA only (`alsa-utils`). The i3 volume keys use `amixer`.
  Manual test: `alsamixer`.
- **Editor**: `nvim` with a small `init.lua` (line numbers, 4 spaces).
- **Window manager**: i3. `Mod4+d` = dmenu, `Mod4+Return` = xterm.
- **Shell**: zsh is the login shell.
- **Intel + NVIDIA hybrid**: this config installs the Intel and nouveau Xorg
  drivers and lets Xorg pick the right one. For the proprietary NVIDIA driver
  use the nonguix `nonguix-transformation-nvidia` helper. Ask before enabling
  it.
- **Intel VMD**: handled by the kernel; no extra configuration here.
- **WM session**: slim is configured with `auto-login-session "i3"`, so it
  starts i3 even if no i3 `.desktop` session file is installed. Log in as
  `arctan`; you do not need to pick a session manually.
- **X resources**: the home config installs `~/.Xresources` and the i3 config
  runs `xrdb -merge ~/.Xresources` on startup/reload.

## Checks before rebooting

- `sudo guix system build ~/dotfiles/guix/system/config.scm` should finish
  without errors. If it fails, the error names the exact file/field.
- `guix home build ~/dotfiles/guix/home/config.scm` should also finish.
- Keep the previous system generation in GRUB. If the new one misbehaves,
  pick the old generation at boot.

## Tips

- If `guix system reconfigure` complains about `nongnu` modules, run
  `guix pull` again with `~/.config/guix/channels.scm` in place.
- If a `specification->package` name is wrong, the error names the missing
  package. Add/remove the string in the package list.
- If the touchpad still misbehaves, paste `xinput list-props` output and the
  `ClickMethod` can be adjusted.
