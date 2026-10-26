# Dotfiles for Guix (i3 + IceCat + kitty)

Guix System + Guix Home configuration for a laptop with Intel WiFi (AX200/AX211),
hybrid Intel + NVIDIA graphics, and a riced i3 desktop.

The two configs are **single files with no local modules**, so there is no
`GUILE_LOAD_PATH` to set and no "unbound variable" / "no code for module" games.
Packages are looked up with `specification->package`, so we also do not depend
on guessing which `(gnu packages ...)` module defines each package.

## Layout

```
dotfiles/
  README.md
  wallpapers/
    guix-dark.png       -> installed as ~/.local/share/wallpapers/guix-dark.png
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

The first reconfigure downloads a lot, including IceCat. After applying the
home config you get these zsh aliases:

```bash
sysre    # sudo guix system reconfigure ~/dotfiles/guix/system/config.scm
homere   # guix home reconfigure ~/dotfiles/guix/home/config.scm
```

## 5) The rice

The desktop is built around:

| Purpose | Program | Notes |
| --- | --- | --- |
| browser | `icecat` | GNU IceCat, a free-software Firefox derivative |
| terminal | `kitty` | GPU terminal, Catppuccin-ish palette |
| launcher | `rofi` | `rofi -show drun`, dmenu kept as fallback |
| compositor | `picom` | shadows/fading, starts from i3 |
| wallpaper | `feh` | `wallpapers/guix-dark.png` |
| notifications | `dunst` | started from i3 inside a D-Bus session |

The apps are installed in both the system profile and the home profile. The
system copy makes sure the i3 session can always find them even if the home
profile PATH is not loaded for some reason.

Installed config files:

```text
~/.config/i3/config
~/.config/i3status/config
~/.config/kitty/kitty.conf
~/.config/rofi/config.rasi
~/.config/picom/picom.conf
~/.config/dunst/dunstrc
~/.config/icecat/user.js
~/.config/mimeapps.list
~/.config/gtk-3.0/settings.ini
~/.Xresources
~/.xsession
~/.local/share/applications/icecat.desktop
~/.local/share/wallpapers/guix-dark.png
```

### Keybindings

| Keys | Action |
| --- | --- |
| `Mod4+Return` | kitty |
| `Mod4+Shift+Return` | xterm fallback |
| `Mod4+Shift+B` | IceCat |
| `Mod4+D` | rofi application launcher |
| `Mod4+Shift+D` | dmenu fallback |
| `Mod4+R` | resize mode (`h/j/k/l`, then `Return` or `Escape`) |
| `Mod4+Shift+C` | reload i3 |
| `Mod4+Shift+R` | restart i3 |
| `Mod4+Shift+Q` | close window |
| `Mod4+Shift+E` | exit i3 (confirmation) |

The i3 config uses gaps (`inner 8`, `outer 4`), pixel borders, Catppuccin-ish
colors, and an i3bar with battery, CPU, memory, disk, load, and clock modules.

### Browser and terminal details

- IceCat uses a dedicated profile at `~/.config/icecat` so its `user.js`
  privacy defaults apply without touching another Firefox/IceCat profile.
- The user-level `icecat.desktop` starts that same profile, so links opened
  from rofi, `xdg-open`, or other apps use the privacy settings too. It
  contains the literal path `/home/arctan`; update it if your home path is
  different.
- `~/.config/mimeapps.list` makes IceCat the default handler for HTTP, HTTPS,
  and HTML, which is what `xdg-open` and desktop files use.
- Kitty is configured with DejaVu Sans Mono, 10 px padding, 0.92 background
  opacity, 10k scrollback, and a dark 16-color palette.
- Rofi gets its colors from `~/.Xresources`; i3 runs `xrdb -merge` on startup
  and reload.

### D-Bus session and `.xsession`

Slim starts `~/.xsession` if it exists. The home activation service creates it
with:

```sh
#!/bin/sh
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_TYPE=x11
export MOZ_ENABLE_WAYLAND=0
exec dbus-run-session -- i3
```

That gives i3 and its children a session bus, which dunst and browser desktop
integration need. If this causes trouble on your machine, comment out the
`dbus-session` service in `guix/home/config.scm` and remove `~/.xsession`; slim
will fall back to starting `i3` directly.

## 6) First boot notes

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
- **Window manager**: i3. See the keybinding table above.
- **Shell**: zsh is the login shell.
- **Intel + NVIDIA hybrid**: this config installs the Intel and nouveau Xorg
  drivers and lets Xorg pick the right one. For the proprietary NVIDIA driver
  use the nonguix `nonguix-transformation-nvidia` helper. Ask before enabling
  it.
- **Intel VMD**: handled by the kernel; no extra configuration here.
- **WM session**: slim is configured with `auto-login-session "i3"`, and the
  home config installs `~/.xsession`, which starts i3 inside `dbus-run-session`.
  Log in as `arctan`; you do not need to pick a session manually.
- **X resources**: the home config installs `~/.Xresources`; i3 runs
  `xrdb -merge` on startup/reload.

## Checks before rebooting

- `sudo guix system build ~/dotfiles/guix/system/config.scm` should finish
  without errors. If it fails, the error names the exact file/field.
- `guix home build ~/dotfiles/guix/home/config.scm` should also finish.
- Keep the previous system generation in GRUB. If the new one misbehaves,
  pick the old generation at boot.

## Troubleshooting

- **Kitty will not start**: try `Mod4+Shift+Return` for xterm, then run `kitty`
  from a terminal to see the error. GPU/driver issues are the usual cause.
- **No wallpaper**: run
  `feh --bg-fill ~/.local/share/wallpapers/guix-dark.png` manually.
- **No shadows/transparency**: run
  `picom --config ~/.config/picom/picom.conf` manually and read the output.
  If picom fails, comment out its `exec` line in the i3 config; i3 still works.
- **No notifications**: check that `dunst` is running (`pgrep dunst`) and that
  `~/.xsession` exists and is executable. Test with
  `notify-send 'test' 'hello'`.
- **Rofi is unthemed**: make sure `xrdb -merge ~/.Xresources` ran; log out/in or
  reload i3 (`Mod4+Shift+C`).
- **If `guix system reconfigure` complains about `nongnu` modules**, run
  `guix pull` again with `~/.config/guix/channels.scm` in place.
- **If a `specification->package` name is wrong**, the error names the missing
  package. Add/remove the string in the package list.
- **If the touchpad still misbehaves**, paste `xinput list-props` output and the
  `ClickMethod` can be adjusted.
