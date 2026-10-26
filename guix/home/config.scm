;; dotfiles/guix/home/config.scm - single file, no local modules

(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu services)
             (gnu packages)
             (guix gexp))

;; ---------------------------------------------------------------
;; files
;; ---------------------------------------------------------------

(define %zshrc
  (plain-file
   "zshrc"
   "export PATH=$HOME/.local/bin:$PATH
alias ll='ls -la'
alias vim='nvim'
alias sysre='sudo guix system reconfigure $HOME/dotfiles/guix/system/config.scm'
alias homere='guix home reconfigure $HOME/dotfiles/guix/home/config.scm'
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
"))

(define %i3-config
  (plain-file
   "i3config"
   "set $mod Mod4
font pango:monospace 8

# load X resources
exec_always --no-startup-id xrdb -merge ~/.Xresources

# launcher
bindsym $mod+d exec dmenu_run

# brightness
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-

# volume (ALSA)
bindsym XF86AudioRaiseVolume exec amixer -q sset Master 5%+
bindsym XF86AudioLowerVolume exec amixer -q sset Master 5%-
bindsym XF86AudioMute exec amixer -q sset Master toggle

# windows
bindsym $mod+Return exec xterm
bindsym $mod+Shift+q kill
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exit

# focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# move
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# workspaces
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+6 workspace 6
bindsym $mod+7 workspace 7
bindsym $mod+8 workspace 8
bindsym $mod+9 workspace 9
bindsym $mod+0 workspace 10

bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5
bindsym $mod+Shift+6 move container to workspace 6
bindsym $mod+Shift+7 move container to workspace 7
bindsym $mod+Shift+8 move container to workspace 8
bindsym $mod+Shift+9 move container to workspace 9
bindsym $mod+Shift+0 move container to workspace 10

# layout
bindsym $mod+f fullscreen toggle
bindsym $mod+v split v
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

bar {
    status_command i3status
}
"))

(define %i3status-config
  (plain-file
   "i3status.conf"
   "general {
    colors = true
    interval = 5
}

order += \"disk /\"
order += \"load\"
order += \"clock\"

disk \"/\" {
    format = \"/ %avail\"
}

load {
    format = \"%1min\"
}

clock {
    format = \"%Y-%m-%d %H:%M\"
}
"))

(define %nvim-init
  (plain-file
   "init.lua"
   "-- minimal nvim config
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = false
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
"))

(define %xresources
  (plain-file
   "Xresources"
   "xterm*faceName: monospace
xterm*faceSize: 10
xterm*scrollBar: false
"))

;; ---------------------------------------------------------------
;; home environment
;; ---------------------------------------------------------------

(home-environment
 (packages
  (map specification->package
       '("neovim"
         "git"
         "i3-wm"
         "i3status"
         "dmenu"
         "xterm"
         "xrdb"
         "brightnessctl"
         "alsa-utils"
         "htop")))
 (services
  (list
   (service home-zsh-service-type
            (home-zsh-configuration
             (zshrc (list %zshrc))))

   (simple-service
    'i3-config
    home-files-service-type
    (list `(".config/i3/config" ,%i3-config)
          `(".config/i3status/config" ,%i3status-config)))

   (simple-service
    'nvim-config
    home-files-service-type
    (list `(".config/nvim/init.lua" ,%nvim-init)))

   (simple-service
    'xresources
    home-files-service-type
    (list `(".Xresources" ,%xresources))))))
