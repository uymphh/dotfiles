(define (check-module path)
  (display "Checking: ") (display path) (newline)
  (if (file-exists? path)
      (display "  EXISTS\n")
      (display "  MISSING\n")))

(for-each check-module
  "guix/system/modules/base.scm"
  "guix/system/modules/firmware-kernel.scm"
  "guix/system/modules/boot.scm"
  "guix/system/modules/hardware.scm"
  "guix/system/modules/networking.scm"
  "guix/system/modules/packages.scm"
  "guix/system/modules/services.scm"
  "guix/system/modules/users.scm"
  "guix/system/modules/xorg-touchpad.scm"
  "guix/system/config.scm"
  "guix/home/config.scm"
  "guix/home/modules/packages.scm"
  "guix/home/modules/shell-zsh.scm"
  "guix/home/modules/wm-i3.scm"
  "guix/home/modules/nvim.scm"
  "guix/home/modules/xresources.scm")