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
| shell | bash |
| root partition | `/dev/nvme0n1p8` (ext4) |
| EFI partition | `/dev/nvme0n1p6` (vfat, mounted at `/boot/efi`) |
| bootloader | GRUB **EFI**, target `/boot/efi` |
| WiFi | ConnMan + `wpa_supplicant` (D-Bus mode) |

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

Build first. This catches syntax errors and bad package names without touching
the running system:

```bash
sudo guix system build ~/dotfiles/guix/system/config.scm
guix home build ~/dotfiles/guix/home/config.scm
```

Then apply the system config (no load path needed):

```bash
sudo guix system reconfigure ~/dotfiles/guix/system/config.scm
```

Home (no load path needed):

```bash
guix home reconfigure ~/dotfiles/guix/home/config.scm
```

If Guix Home reports that `~/.bashrc` or `~/.bash_profile` already exists and
is not managed by Guix Home, move the old file aside once
(`mv ~/.bashrc ~/.bashrc.bak`) and rerun. Guix Home only manages files it
created itself.

The first reconfigure downloads a lot, including IceCat. After applying the
home config you get these bash aliases:

```bash
sysre    # sudo guix system reconfigure ~/dotfiles/guix/system/config.scm
homere   # guix home reconfigure ~/dotfiles/guix/home/config.scm
```

## 5) The rice

The desktop is built around:

| Purpose | Program | Notes |
| --- | --- | --- |
| browser | `icecat` | GNU IceCat, a free-software Firefox derivative |
| terminal | `kitty` | GPU terminal, Catppuccin-ish palette, powerline tabs |
| launcher | `dmenu` | riced `dmenu_run` on `Mod4+D`/`Mod4+P`; rofi is the extra |
| compositor | `picom` | shadows/fading, starts from i3 |
| wallpaper | `feh` | `wallpapers/guix-dark.png` |
| notifications | `dunst` | started from i3 inside a D-Bus session |

The apps are installed in both the system profile and the home profile. The
system copy makes sure the i3 session can always find them even if the home
profile PATH is not loaded for some reason.

Installed config files:

```text
~/.bashrc
~/.bash_profile
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
| `Mod4+D` | riced `dmenu_run` launcher |
| `Mod4+P` | riced `dmenu_run` launcher |
| `Mod4+Shift+D` | rofi application launcher |
| `Mod4+R` | resize mode (`h/j/k/l`, then `Return` or `Escape`) |
| `Mod4+Shift+C` | reload i3 |
| `Mod4+Shift+R` | restart i3 |
| `Mod4+Shift+Q` | close window |
| `Mod4+Shift+E` | exit i3 (confirmation) |
| `XF86AudioRaiseVolume` / `LowerVolume` | `amixer` master volume |
| `XF86AudioMute` / `XF86AudioMicMute` | mute output / microphone |
| `XF86MonBrightnessUp` / `Down` | `brightnessctl` |

The i3 config uses gaps (`inner 8`, `outer 4`), pixel borders, Catppuccin-ish
colors, and an i3bar fed by `i3status` with wireless, battery, CPU, memory,
disk, and clock modules. The bar is 28 px tall with the same palette.

dmenu is themed on the command line (`-nb/-nf/-sb/-sf/-fn`), so it matches the
bar and windows without an extra config file. rofi is still installed and
themed, but it is no longer the primary launcher.

### Browser and terminal details

- IceCat uses a dedicated profile at `~/.config/icecat` so its `user.js`
  privacy defaults apply without touching another Firefox/IceCat profile.
- The user-level `icecat.desktop` starts that same profile, so links opened
  from rofi, `xdg-open`, or other apps use the privacy settings too. It
  contains the literal path `/home/arctan`; update it if your home path is
  different.
- `~/.config/mimeapps.list` makes IceCat the default handler for HTTP, HTTPS,
  and HTML, which is what `xdg-open` and desktop files use.
- Kitty is configured with DejaVu Sans Mono, 12px window padding, 0.92
  background opacity, a beam cursor, 10k scrollback, powerline tabs, and a dark
  16-color palette.
- dmenu is styled inline from the i3 config (Catppuccin background, blue
  selection, DejaVu Sans Mono 11). Edit the `bindsym` lines to change it.
- Rofi is themed in `~/.config/rofi/config.rasi` (Catppuccin-ish colors,
  rounded border, icon rows). Rofi 2.0 no longer reads Xresources, so
  `~/.Xresources` is only used for xterm and Xft settings.

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

### Shell and PATH (bash)

The login shell is **bash**. Guix Home installs `~/.bashrc` plus a generated
`~/.bash_profile` that sources `~/.profile` and then `~/.bashrc`. The `.bashrc`
sets an explicit PATH:

```sh
/run/privileged/bin
$HOME/.local/bin
$HOME/.guix-home/profile/bin
$HOME/.guix-profile/bin
/run/current-system/profile/bin
/run/current-system/profile/sbin
```

That matters because SLIM starts the desktop by running `~/.xsession` through
the login shell. If the login shell loses those directories, the whole i3
session loses `sudo`, `herd`, `reboot`, and friends, not just the terminal.

`sudo` is in `/run/privileged/bin`; the Shepherd clients (`herd`, `reboot`,
`shutdown`) come from the system profile. They need root, so `sudo herd status`
is the correct form. Shepherd's `shutdown` is not the SysV `shutdown -h now`;
use `sudo reboot` or `loginctl poweroff` for normal power control.

## 6) First boot notes

- **WiFi**: Intel AX200/AX210/AX211 firmware comes from `linux-firmware`.
  ConnMan 2.x does not drive the card itself: it talks to `wpa_supplicant`
  over D-Bus. The system config therefore starts
  `(service wpa-supplicant-service-type)` and makes ConnMan depend on
  `'(wpa-supplicant)`. `iwd` is deliberately not used.

  Connect with `connmanctl` (interactive or one command at a time):

  ```bash
  connmanctl
  > enable wifi
  > scan wifi
  > services
  > agent on
  > connect wifi_<hash>_<ssid>_managed_psk
  ```

  Your user is in the `netdev` group.

  If `enable wifi` works but `scan wifi` errors, check the daemons and the
  radio before touching the config:

  ```bash
  sudo herd status wpa-supplicant
  sudo herd status connman
  connmanctl technologies
  rfkill list
  dmesg | grep -i -E 'firmware|iwlwifi'
  ```

  Both status lines should say `running`. If `wpa-supplicant` is not running,
  the ConnMan WiFi plugin has nothing to scan with; reconfigure the system and
  check the order in `guix/system/config.scm`. If `rfkill` shows the device
  soft-blocked, run `sudo rfkill unblock wifi`.
- **Brightness**: `brightnessctl`. The i3 config binds the brightness keys.
  Manual test: `brightnessctl set +10%`.
- **Audio**: ALSA only (`alsa-utils`). The i3 volume keys use `amixer`.
  Manual test: `alsamixer`.
- **Editor**: `nvim` with a small `init.lua` (line numbers, 4 spaces).
- **Window manager**: i3. See the keybinding table above.
- **Shell**: bash is the login shell. Your prompt, PATH, and aliases come from
  `~/.bashrc`; `sysre`, `homere`, and `wifi` are defined there.
- **Intel + NVIDIA hybrid**: this config installs the Intel and nouveau Xorg
  drivers and lets Xorg pick the right one. It does **not** enable the
  proprietary NVIDIA driver. If you want that later, use nonguix's
  `nongnu/services/nvidia.scm` (`nvidia-service-type`) or its
  `etc/manifests/nonguix-nvidia` manifest; ask before enabling it.
- **Intel VMD**: if the NVMe drive sits behind Intel VMD, the `vmd` kernel
  module must be loaded before the root device appears, so it is prepended to
  `initrd-modules`. This is harmless on machines without VMD.
- **WM session**: slim is configured with `auto-login-session "i3"`, and the
  home config installs `~/.xsession`, which starts i3 inside `dbus-run-session`.
  Log in as `arctan`; you do not need to pick a session manually.
- **X resources**: the home config installs `~/.Xresources` (xterm font and Xft
  settings); i3 runs `xrdb -merge` on startup/reload. Rofi does not use it.

## Checks before rebooting

- `sudo guix system build ~/dotfiles/guix/system/config.scm` should finish
  without errors. If it fails, the error names the exact file/field.
- `guix home build ~/dotfiles/guix/home/config.scm` should also finish.
- Keep the previous system generation in GRUB. If the new one misbehaves,
  pick the old generation at boot.

## Troubleshooting

- **`sudo` / `herd` / `reboot` says "command not found"**: the shell is not
  getting the Guix PATH. Check `echo $PATH`; it must contain
  `/run/privileged/bin` and `/run/current-system/profile/sbin`. Run
  `source ~/.bashrc`, or start a fresh login shell with `bash --login`. If it
  persists, confirm the account really uses bash: `getent passwd arctan` should
  end in `/bin/bash`, and `~/.bash_profile` should exist. The desktop inherits
  this PATH because SLIM runs `~/.xsession` through the login shell.
- **`sudo: unable to allocate pty` / `sudo: no tty present`**: `/dev/pts` is
  not mounted. The system config must include `%base-file-systems` (it does
  now); reconfigure the system and reboot so `devpts` is mounted. Verify with
  `mount | grep devpts` afterwards.
- **`reboot` / `shutdown` errors**: these are root-only Shepherd clients, and
  Shepherd's `shutdown` does not accept `-h now`. Use `sudo reboot` or
  `loginctl poweroff`. `sudo herd status` is the right way to inspect services.
- **WiFi `scan wifi` fails**: run the `herd`/`connmanctl technologies`/`rfkill`
  checks in the WiFi first-boot notes. The usual cause is `wpa-supplicant` not
  running, or a soft-blocked radio.
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
- **Rofi looks wrong or will not start**: run `rofi -show drun` from a terminal
  and read the error. Theme problems point at `~/.config/rofi/config.rasi`;
  rename that file temporarily to fall back to the built-in theme.
- **If `guix system reconfigure` complains about `nongnu` modules**, run
  `guix pull` again with `~/.config/guix/channels.scm` in place.
- **If a `specification->package` name is wrong**, the error names the missing
  package. Add/remove the string in the package list.
- **If the touchpad still misbehaves**, paste `xinput list-props` output and the
  `ClickMethod` can be adjusted.
