(define-module (system modules firmware-kernel)
  #:use-module (gnu system)
  #:use-module (gnu packages linux)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (srfi srfi-1)
  #:export (%my-kernel
            %my-initrd
            %my-kernel-arguments
            %my-firmware))

(define %my-kernel
  linux)

(define %my-initrd
  microcode-initrd)

(define %my-kernel-arguments
  '("quiet"
    "loglevel=3"
    "mitigations=auto"))

(define %my-firmware
  (list linux-firmware))
