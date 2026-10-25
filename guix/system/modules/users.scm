(define-module (dotfiles guix system modules users)
  #:use-module (gnu system)
  #:use-module (gnu system shadow)
  #:use-module (srfi srfi-1)
  #:export (%my-users))

(define %my-users
  (append
   (list
    (user-account
     (name "yourusername")
     (comment "Your Name")
     (group "users")
     (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
     (home-directory "/home/yourusername")
     (shell "/run/current-system/profile/bin/zsh")))
   %base-user-accounts))
