(define-module (system modules boot)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (srfi srfi-1)
  #:export (%my-bootloader
            %my-file-systems))

(define %my-bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (targets '("/dev/nvme0n1"))))

(define %my-file-systems
  (list (file-system
         (mount-point "/")
         (device "/dev/nvme0n1p8")
         (type "ext4"))
        (file-system
         (mount-point "/boot/efi")
         (device "/dev/nvme0n1p6")
         (type "vfat"))))
