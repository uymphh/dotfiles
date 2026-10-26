(define-module (guix home modules packages)
  #:use-module (gnu packages)
  #:export (%my-home-packages))

;; specification->package looks packages up by name, so there is no
;; need to import the (gnu packages ...) module that defines each one.
(define %my-home-packages
  (map specification->package
       '("neovim"
         "git"
         "i3-wm"
         "i3status"
         "dmenu"
         "xterm"
         "brightnessctl"
         "alsa-utils"
         "htop")))
