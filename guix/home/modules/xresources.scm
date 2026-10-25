(define-module (home modules xresources)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:export (%my-xresources-service))

(define %my-xresources-service
  (simple-service
   'xresources
   home-files-service-type
   (list
    `(".Xresources"
      ,(plain-file
        "Xresources"
        "xterm*faceName: monospace
xterm*faceSize: 10
xterm*scrollBar: false
")))))
