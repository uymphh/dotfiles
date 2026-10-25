(use-modules (gnu home)
             (gnu packages)
             (dotfiles guix home modules packages)
             (dotfiles guix home modules shell-zsh)
             (dotfiles guix home modules wm-i3)
             (dotfiles guix home modules nvim)
             (dotfiles guix home modules xresources))

(home-environment
 (packages %my-home-packages)
 (services (list
            %my-zsh-service
            %my-i3-service
            %my-nvim-service
            %my-xresources-service)))
