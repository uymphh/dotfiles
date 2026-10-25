(add-to-load-path (dirname (current-filename)))
(use-modules (gnu home)
             (gnu packages)
             (home modules packages)
             (home modules shell-zsh)
             (home modules wm-i3)
             (home modules nvim)
             (home modules xresources))

(home-environment
 (packages %my-home-packages)
 (services (list
            %my-zsh-service
            %my-i3-service
            %my-nvim-service
            %my-xresources-service)))
