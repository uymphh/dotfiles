(define-module (dotfiles guix system modules boot)
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
   (targets '("/dev/sdX"))))

(define %my-file-systems
  (list (file-system
         (mount-point "/")
         (device (uuid "PUT-YOUR-ROOT-UUID-HERE" 'ext4))
         (type "ext4"))
        (file-system
         (mount-point "/boot/efi")
         (device (uuid "PUT-YOUR-EFI-UUID-HERE" 'fat32))
         (type "vfat"))))
