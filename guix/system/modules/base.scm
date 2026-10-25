(define-module (dotfiles guix system modules base)
  #:use-module (dotfiles guix system modules firmware-kernel)
  #:use-module (dotfiles guix system modules boot)
  #:use-module (dotfiles guix system modules hardware)
  #:use-module (dotfiles guix system modules networking)
  #:use-module (dotfiles guix system modules packages)
  #:use-module (dotfiles guix system modules services)
  #:use-module (dotfiles guix system modules users)
  #:export (%my-operating-system))

(define %my-operating-system
  (operating-system
   (host-name "guixbox")
   (timezone "Etc/UTC")
   (locale "en_US.utf8")

   (kernel %my-kernel)
   (initrd %my-initrd)
   (kernel-arguments %my-kernel-arguments)
   (firmware %my-firmware)

   (bootloader %my-bootloader)
   (file-systems %my-file-systems)

   (users %my-users)
   (packages %my-system-packages)
   (services %my-desktop-services)))
