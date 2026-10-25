(define-module (home modules shell-zsh)
  #:use-module (gnu home services shells)
  #:use-module (gnu packages shells)
  #:use-module (srfi srfi-1)
  #:export (%my-zsh-service))

(define %my-zsh-service
  (service home-zsh-service-type
           (home-zsh-configuration
            (zshrc
             (list
              (plain-file
               "zshrc"
               "export PATH=$HOME/.local/bin:$PATH
alias ll='ls -la'
alias vim='nvim'
alias sysre='sudo GUILE_LOAD_PATH=$HOME/dotfiles/guix guix system reconfigure $HOME/dotfiles/guix/system/config.scm'
alias homere='GUILE_LOAD_PATH=$HOME/dotfiles/guix guix home reconfigure $HOME/dotfiles/guix/home/config.scm'
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
"))))))
