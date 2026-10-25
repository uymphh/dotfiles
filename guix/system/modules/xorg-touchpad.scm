(define-module (system modules xorg-touchpad)
  #:use-module (gnu services xorg)
  #:use-module (gnu packages xorg)
  #:export (%my-touchpad-xorg-configuration))

(define %my-touchpad-xorg-configuration
  (xorg-configuration
   (modules (cons* xf86-input-libinput %default-xorg-modules))
   (extra-config
    (list "
Section \"InputClass\"
    Identifier \"libinput touchpad catchall\"
    MatchIsTouchpad \"on\"
    MatchDevicePath \"/dev/input/event*\"
    Driver \"libinput\"
    Option \"Tapping\" \"on\"
    Option \"TappingDrag\" \"on\"
    Option \"TappingButtonMap\" \"lrm\"
    Option \"ClickMethod\" \"clickfinger\"
    Option \"NaturalScrolling\" \"false\"
    Option \"ScrollMethod\" \"twofinger\"
    Option \"DisableWhileTyping\" \"on\"
    Option \"MiddleEmulation\" \"on\"
    Option \"PalmDetection\" \"on\"
EndSection
"))))
