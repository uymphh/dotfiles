(define-module (system modules services)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  #:use-module (gnu services xorg)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu system keyboard)
  #:use-module (system modules xorg-touchpad)
  #:use-module (srfi srfi-1)
  #:export (%my-desktop-services))

(define %my-desktop-services
  (append
   (list
    (service slim-service-type
             (slim-configuration
              (default-user "arctan")
              (auto-login? #f)
              (xorg-configuration %my-touchpad-xorg-configuration)))
    (service elogind-service-type)
    (service dbus-root-service-type))
   %base-services))
