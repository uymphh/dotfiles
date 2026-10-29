;; dotfiles/guix/system/config.scm - simple with safe nonguix fallback
(use-modules (gnu)
             (gnu bootloader)
             (gnu bootloader grub)
             (gnu packages)
             (gnu packages bash)
             (gnu services)
             (gnu services base)
             (gnu services dbus)
             (gnu services desktop)
             (gnu services networking)
             (gnu services xorg)
             (gnu system)
             (gnu system file-systems)
             (gnu system keyboard)
             (gnu system linux-initrd)
             (gnu system shadow)
             (gnu packages linux)
             (guix gexp))

;; kernel
(define %my-kernel
  (catch #t
    (lambda ()
      (let ((mod (resolve-interface '(nongnu packages linux))))
        (module-ref mod 'linux)))
    (lambda _
      linux-libre)))

;; initrd
(define %my-initrd
  (catch #t
    (lambda ()
      (let ((mod (resolve-interface '(nongnu system linux-initrd))))
        (module-ref mod 'microcode-initrd)))
    (lambda _
      #f)))

(define %my-kernel-args '("quiet" "loglevel=3"))
(define %my-firmware (list linux-firmware))

;; boot
(define %my-bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets '("/boot/efi"))
   (timeout 5)))

;; filesystems
(define %my-file-systems
  (append
   (list
    (file-system
     (mount-point "/")
     (device "/dev/nvme0n1p8")
     (type "ext4"))
    (file-system
     (mount-point "/boot/efi")
     (device "/dev/nvme0n1p6")
     (type "vfat")))
   %base-file-systems))

;; packages
(define %my-system-packages
  (append
   (map specification->package
        '("coreutils"
          "grep"
          "sed"
          "gawk"
          "findutils"
          "util-linux"
          "iproute2"
          "pciutils"
          "file"
          "which"
          "wget"
          "curl"
          "git"
          "sudo"
          "alsa-utils"
          "font-jetbrains-mono"
          "xrandr"
          "xrdb"
          "xorg-server"
          "xf86-video-intel"
          "xf86-video-nouveau"
          "xf86-input-libinput"
          "libinput"
          "xinput"
          "i3-wm"
          "i3status"
          "dmenu"
          "xinit"
          "xterm"
          "brightnessctl"
          "neovim"
          "os-prober"
          "ntfs-3g"
          "connman"
          "dbus"
          "adwaita-icon-theme"
          "icecat"
          "kitty"
          "feh"
          "picom"
          "dunst"
          "libnotify"
          "xdg-utils"))
   %base-packages))

;; touchpad
(define %my-touchpad-xorg-configuration
  (xorg-configuration
   (keyboard-layout (keyboard-layout "us"))
   (extra-config
    (list "
Section \"InputClass\"
    Identifier \"libinput touchpad catchall\"
    MatchIsTouchpad \"on\"
    MatchDevicePath \"/dev/input/event*\"
    Driver \"libinput\"
    Option \"Tapping\" \"on\"
    Option \"TappingDrag\" \"on\"
    Option \"TappingButtonMap\" \"lrm\"
    Option \"ClickMethod\" \"clickfinger\"
    Option \"NaturalScrolling\" \"false\"
    Option \"ScrollMethod\" \"twofinger\"
    Option \"DisableWhileTyping\" \"on\"
    Option \"MiddleEmulation\" \"on\"
EndSection
"))))

;; services
(define %my-services
  (append
   (list
    (service slim-service-type
             (slim-configuration
              (default-user "arctan")
              (auto-login? #f)
              (auto-login-session "i3")
              (xorg-configuration %my-touchpad-xorg-configuration)))
    (service elogind-service-type)
    (service dbus-root-service-type)
    (service polkit-service-type)
    (service wpa-supplicant-service-type)
    (service connman-service-type
             (connman-configuration
              (shepherd-requirement '(wpa-supplicant))
              (general-configuration
               (connman-general-configuration
                (background-scanning? #t)
                (regulatory-domain-follows-timezone? #t))))))
   (modify-services %base-services
     (udev-service-type config =>
       (udev-configuration
        (inherit config)
        (rules (cons (specification->package "brightnessctl")
                     (udev-configuration-rules config)))))))

;; user
(define %my-users
  (append
   (list
    (user-account
     (name "arctan")
     (group "users")
     (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
     (home-directory "/home/arctan")
     (shell (file-append bash "/bin/bash"))))
   %base-user-accounts))

;; os
(operating-system
  (host-name "guix-btw")
  (timezone "America/Los_Angeles")
  (locale "en_US.utf8")
  (keyboard-layout (keyboard-layout "us"))

  (kernel %my-kernel)
  (initrd %my-initrd)
  (initrd-modules (cons* "vmd" (base-initrd-modules %my-kernel)))
  (kernel-arguments %my-kernel-args)
  (firmware %my-firmware)

  (bootloader %my-bootloader)
  (file-systems %my-file-systems)
  (users %my-users)
  (packages %my-system-packages)
  (services %my-services))
)
