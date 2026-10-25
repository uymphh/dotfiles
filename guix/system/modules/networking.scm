(define-module (guix system modules networking)
  #:use-module (gnu services)
  #:use-module (gnu services networking)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages linux)
  #:export (%my-networking-services))

(define %my-networking-services
  (list
   (service connman-service-type)))
