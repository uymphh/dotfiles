;; dotfiles/guix/system/config.scm - SINGLE FILE, NO MODULES
(use-modules (gnu system)
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
             (gnu packages admin)
             (gnu packages base)
             (gnu packages bash)
             (gnu packages file)
             (gnu packages linux)
             (gnu packages pciutils)
             (gnu packages usbutils)
             (gnu packages vim)
             (gnu packages xorg)
             (gnu packages wm)
             (gnu packages brightnessctl)
             (gnu packages connman)
             (gnu packages shells)
             (gnu packages xdisorg)
             (srfi srfi-1)
             (nongnu packages linux)
             (nongnu system linux-initrd))

;; KERNEL & FIRMWARE
(define %my-kernel linux)
(define %my-initrd microcode-initrd)
(define %my-kernel-arguments '("quiet" "loglevel=3" "mitigations=auto"))
(define %my-firmware (list linux-firmware))

;; BOOT
(define %my-bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (targets '("/dev/nvme0n1"))))

(define %my-file-systems
  (list (file-system (mount-point "/") (device "/dev/nvme0n1p8") (type "ext4"))
        (file-system (mount-point "/boot/efi") (device "/dev/nvme0n1p6") (type "vfat"))))

;; HARDWARE
(define %my-hardware-services (list (service udev-service-type)))

;; NETWORKING
(define %my-networking-services (list (service connman-service-type)))

;; PACKAGES
(define %my-system-packages
  (append (list coreutils grep sed gawk findutils util-linux iproute pciutils usbutils file
                which wget curl git zsh xorg-server xf86-video-intel xf86-video-nouveau
                xf86-input-libinput libinput xinput i3-wm i3status dmenu xinit xterm
                brightnessctl neovim connman)
          %base-packages))

;; TOUCHPAD XORG CONFIG
(define %my-touchpad-xorg-configuration
  (xorg-configuration
   (modules (cons* xf86-input-libinput %default-xorg-modules))
   (extra-config (list "
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
    Option \"PalmDetection\" \"on\"
EndSection
"))))

;; SERVICES
(define %my-desktop-services
  (append (list (service slim-service-type
                         (slim-configuration
                          (default-user "arctan")
                          (auto-login? #f)
                          (xorg-configuration %my-touchpad-xorg-configuration)))
                (service elogind-service-type)
                (service dbus-root-service-type))
          %base-services))

;; USERS
(define %my-users
  (append (list (user-account
                 (name "arctan")
                 (group "users")
                 (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
                 (home-directory "/home/arctan")
                 (shell "/run/current-system/profile/bin/zsh")))
          %base-user-accounts))

;; OPERATING SYSTEM
(operating-system
 (host-name "guix-btw")
 (timezone "America/Los_Angeles")
 (locale "en_US.utf8")

 (kernel %my-kernel)
 (initrd %my-initrd)
 (kernel-arguments %my-kernel-arguments)
 (firmware %my-firmware)

 (bootloader %my-bootloader)
 (file-systems %my-file-systems)

 (users %my-users)
 (packages %my-system-packages)
 (services %my-desktop-services))