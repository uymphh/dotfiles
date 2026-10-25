(define-module (home modules packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages git)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages brightnessctl)
  #:use-module (srfi srfi-1)
  #:export (%my-home-packages))

(define %my-home-packages
  (list
   neovim
   git
   i3-wm
   dmenu
   brightnessctl
   htop))
