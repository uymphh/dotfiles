(use-modules (gnu home)
             (gnu packages)
             ((guix home modules packages) #:select (%my-home-packages))
             ((guix home modules shell-zsh) #:select (%my-zsh-service))
             ((guix home modules wm-i3) #:select (%my-i3-service))
             ((guix home modules nvim) #:select (%my-nvim-service))
             ((guix home modules xresources) #:select (%my-xresources-service)))

(home-environment
 (packages %my-home-packages)
 (services (list
            %my-zsh-service
            %my-i3-service
            %my-nvim-service
            %my-xresources-service)))
