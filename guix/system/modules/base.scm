(define-module (guix system modules base)
  #:use-module (guix system modules firmware-kernel)
  #:use-module (guix system modules boot)
  #:use-module (guix system modules hardware)
  #:use-module (guix system modules networking)
  #:use-module (guix system modules packages)
  #:use-module (guix system modules services)
  #:use-module (guix system modules users)
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
