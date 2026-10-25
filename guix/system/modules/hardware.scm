(define-module (system modules hardware)
  #:use-module (gnu system)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services udev)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages linux)
  #:export (%my-hardware-services))

(define %my-hardware-services
  (list
   (service udev-service-type)))
