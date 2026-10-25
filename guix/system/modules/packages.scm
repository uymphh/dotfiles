(define-module (dotfiles guix system modules packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages file)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages usbutils)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages brightnessctl)
  #:use-module (gnu packages connman)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages xdisorg)
  #:use-module (srfi srfi-1)
  #:export (%my-system-packages))

(define %my-system-packages
  (append
   (list
    coreutils
    grep
    sed
    gawk
    findutils
    util-linux
    iproute
    pciutils
    usbutils
    file
    which
    wget
    curl
    git
    zsh
    xorg-server
    xf86-video-intel
    xf86-video-nouveau
    xf86-input-libinput
    libinput
    i3-wm
    i3status
    dmenu
    xinit
    xterm
    brightnessctl
    neovim
    connman)
   %base-packages))
