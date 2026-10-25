(define-module (system modules base)
  #:use-module (system modules firmware-kernel)
  #:use-module (system modules boot)
  #:use-module (system modules hardware)
  #:use-module (system modules networking)
  #:use-module (system modules packages)
  #:use-module (system modules services)
  #:use-module (system modules users)
  #:export (%my-operating-system))

(define %my-operating-system
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
   (services %my-desktop-services)))
