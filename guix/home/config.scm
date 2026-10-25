(use-modules (gnu home)
             (gnu packages)
             (guix home modules packages)
             (guix home modules shell-zsh)
             (guix home modules wm-i3)
             (guix home modules nvim)
             (guix home modules xresources))

(home-environment
 (packages %my-home-packages)
 (services (list
            %my-zsh-service
            %my-i3-service
            %my-nvim-service
            %my-xresources-service)))
