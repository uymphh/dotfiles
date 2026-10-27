;; dotfiles/guix/system/config.scm - single file, no local modules

(use-modules (gnu)
             (gnu system)
             (gnu system file-systems)
             (gnu system shadow)
             (gnu bootloader)
             (gnu bootloader grub)
             (gnu services)
             (gnu services base)
             (gnu services dbus)
             (gnu services xorg)
             (gnu services desktop)
             (gnu services networking)
             (gnu system keyboard)
             (gnu packages)
             (gnu packages bash)
             (guix gexp)
             (nongnu packages linux)
             (nongnu system linux-initrd))

;; ---------------------------------------------------------------
;; kernel and firmware (nonguix)
;; ---------------------------------------------------------------

(define %my-kernel
  linux)

(define %my-initrd
  microcode-initrd)

(define %my-kernel-arguments
  '("quiet"
    "loglevel=3"))

(define %my-firmware
  (list linux-firmware))

;; ---------------------------------------------------------------
;; boot
;; ---------------------------------------------------------------

(define %my-bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets '("/boot/efi"))))

(define %my-file-systems
  (list (file-system
         (mount-point "/")
         (device "/dev/nvme0n1p8")
         (type "ext4"))
        (file-system
         (mount-point "/boot/efi")
         (device "/dev/nvme0n1p6")
         (type "vfat"))))

;; ---------------------------------------------------------------
;; packages
;;
;; specification->package looks packages up by name, so we do not
;; need to guess which (gnu packages ...) module each one lives in.
;; ---------------------------------------------------------------

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
          "font-dejavu"
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
          "connman"
          "dbus"
          "adwaita-icon-theme"
          "icecat"
          "kitty"
          "rofi"
          "feh"
          "picom"
          "dunst"
          "libnotify"
          "xdg-utils"))
   %base-packages))

;; ---------------------------------------------------------------
;; touchpad
;; ---------------------------------------------------------------

(define %my-touchpad-xorg-configuration
  (xorg-configuration
   (keyboard-layout (keyboard-layout "us"))
   (fonts (cons (specification->package "font-dejavu")
                %default-xorg-fonts))
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

;; ---------------------------------------------------------------
;; services
;; ---------------------------------------------------------------

(define %my-services
  (append
   (list
    ;; display manager
    (service slim-service-type
             (slim-configuration
              (default-user "arctan")
              (auto-login? #f)
              (auto-login-session "i3")
              (xorg-configuration %my-touchpad-xorg-configuration)))

    ;; seat / power management
    (service elogind-service-type)

    ;; system bus and authorization
    (service dbus-root-service-type)
    (service polkit-service-type)

    ;; wireless: ConnMan 2.x talks to wpa_supplicant over D-Bus, so the
    ;; supplicant has to be up before connman starts.  Without this,
    ;; "connmanctl enable wifi" works but "scan wifi" fails.
    (service wpa-supplicant-service-type)
    (service connman-service-type
             (connman-configuration
              (shepherd-requirement '(wpa-supplicant))
              (general-configuration
               (connman-general-configuration
                (background-scanning? #t)
                (regulatory-domain-follows-timezone? #t))))))
   ;; Add brightnessctl's udev rule so the media keys work without root.
   (modify-services %base-services
     (udev-service-type config =>
       (udev-configuration
        (inherit config)
        (rules (cons (specification->package "brightnessctl")
                     (udev-configuration-rules config))))))))

;; ---------------------------------------------------------------
;; users
;; ---------------------------------------------------------------

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

;; ---------------------------------------------------------------
;; operating system
;; ---------------------------------------------------------------

(operating-system
  (host-name "guix-btw")
  (timezone "America/Los_Angeles")
  (locale "en_US.utf8")
  (keyboard-layout (keyboard-layout "us"))

  (kernel %my-kernel)
  (initrd %my-initrd)
  (kernel-arguments %my-kernel-arguments)
  (firmware %my-firmware)

  (bootloader %my-bootloader)
  (file-systems %my-file-systems)

  (users %my-users)
  (packages %my-system-packages)
  (services %my-services))
