;; dotfiles/guix/home/config.scm - single file, no local modules

(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu services)
             (gnu packages)
             (guix gexp))

;; ---------------------------------------------------------------
;; shell
;; ---------------------------------------------------------------

(define %bashrc
  (plain-file
   "bashrc"
   "# ~/.bashrc - bash setup for the i3 rice.

# PATH: privileged helpers first, then local/home/system profiles.
export PATH=\"/run/privileged/bin:$HOME/.local/bin:$HOME/.guix-home/profile/bin:$HOME/.guix-profile/bin:/run/current-system/profile/bin:/run/current-system/profile/sbin:$PATH\"

# History.
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend checkwinsize

# Prompt: user@host in blue, directory in peach, then $ or #.
PS1='\\[\\e[1;38;5;117m\\]\\u@\\h\\[\\e[0m\\] \\[\\e[38;5;180m\\]\\w\\[\\e[0m\\] \\$ '

# Aliases.
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias sysre='sudo guix system reconfigure $HOME/dotfiles/guix/system/config.scm'
alias homere='guix home reconfigure $HOME/dotfiles/guix/home/config.scm'
alias wifi='connmanctl'

# Environment used by i3 children and terminal apps.
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=kitty
export BROWSER=icecat
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_TYPE=x11
export MOZ_ENABLE_WAYLAND=0
"))

;; ---------------------------------------------------------------
;; i3
;; ---------------------------------------------------------------

(define %i3-config
  (plain-file
   "i3config"
   "set $mod Mod4
set $term kitty
set $browser icecat

font pango:DejaVu Sans Mono 10

# X resources (xterm font, Xft)
exec_always --no-startup-id xrdb -merge ~/.Xresources

# wallpaper
exec_always --no-startup-id feh --bg-fill ~/.local/share/wallpapers/guix-dark.png

# compositor and notifications
exec --no-startup-id picom --config ~/.config/picom/picom.conf
exec --no-startup-id dunst

# launcher: dmenu is the main launcher, rofi is the extra
bindsym $mod+d exec --no-startup-id dmenu_run -i -nb '#1e1e2e' -nf '#cdd6f4' -sb '#89b4fa' -sf '#1e1e2e' -fn 'DejaVu Sans Mono:size=11' -p 'run:'
bindsym $mod+p exec --no-startup-id dmenu_run -i -nb '#1e1e2e' -nf '#cdd6f4' -sb '#89b4fa' -sf '#1e1e2e' -fn 'DejaVu Sans Mono:size=11' -p 'run:'
bindsym $mod+Shift+d exec --no-startup-id rofi -show drun

# terminal and browser
bindsym $mod+Return exec $term
bindsym $mod+Shift+Return exec xterm
bindsym $mod+Shift+b exec $browser --profile ~/.config/icecat

# brightness
bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl set +5%
bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl set 5%-

# volume (ALSA)
bindsym XF86AudioRaiseVolume exec --no-startup-id amixer -q sset Master 5%+
bindsym XF86AudioLowerVolume exec --no-startup-id amixer -q sset Master 5%-
bindsym XF86AudioMute exec --no-startup-id amixer -q sset Master toggle
bindsym XF86AudioMicMute exec --no-startup-id amixer -q sset Capture toggle

# windows
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'

# focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+a focus parent
bindsym $mod+space focus mode_toggle

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
bindsym $mod+Shift+f floating toggle
bindsym $mod+v split v
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# resize mode
bindsym $mod+r mode \"resize\"

# gaps, borders, focus
gaps inner 8
gaps outer 4
smart_gaps on
smart_borders on
default_border pixel 2
default_floating_border pixel 2
hide_edge_borders smart
focus_follows_mouse no
mouse_warping output
workspace_auto_back_and_forth yes

# colors
client.focused          #89b4fa #1e1e2e #cdd6f4 #89b4fa #89b4fa
client.focused_inactive #45475a #1e1e2e #cdd6f4 #45475a #45475a
client.unfocused        #45475a #1e1e2e #a6adc8 #45475a #45475a
client.urgent           #f38ba8 #1e1e2e #1e1e2e #f38ba8 #f38ba8
client.placeholder      #1e1e2e #1e1e2e #cdd6f4 #1e1e2e #1e1e2e
client.background       #1e1e2e

bar {
    status_command i3status -c ~/.config/i3status/config
    position top
    height 28
    tray_output none
    font pango:DejaVu Sans Mono 10
    colors {
        background #1e1e2e
        statusline #cdd6f4
        separator #45475a
        focused_workspace  #89b4fa #89b4fa #1e1e2e
        active_workspace   #45475a #45475a #cdd6f4
        inactive_workspace #1e1e2e #1e1e2e #a6adc8
        urgent_workspace   #f38ba8 #f38ba8 #1e1e2e
    }
}

mode \"resize\" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt
    bindsym Return mode \"default\"
    bindsym Escape mode \"default\"
}
"))

(define %i3status-config
  (plain-file
   "i3status.conf"
   "general {
    colors = true
    interval = 2
    color_good = \"#a6e3a1\"
    color_degraded = \"#f9e2af\"
    color_bad = \"#f38ba8\"
}

order += \"wireless _first_\"
order += \"battery all\"
order += \"cpu_usage\"
order += \"memory\"
order += \"disk /\"
order += \"tztime local\"

wireless _first_ {
    format_up = \"wifi %quality\"
    format_down = \"wifi off\"
}

battery all {
    format = \"batt %percentage\"
}

cpu_usage {
    format = \"cpu %usage\"
}

memory {
    format = \"mem %used\"
}

disk \"/\" {
    format = \"disk %avail\"
}

tztime local {
    format = \"%a %d %b  %H:%M\"
}
"))

;; ---------------------------------------------------------------
;; rice: kitty, rofi, picom, dunst, icecat
;; ---------------------------------------------------------------

(define %kitty-config
  (plain-file
   "kitty.conf"
   "font_family DejaVu Sans Mono
font_size 11
bold_font auto
italic_font auto

cursor_shape beam
cursor_blink_interval 0.5
cursor_text_color #1e1e2e
scrollback_lines 10000
enable_audio_bell no
mouse_hide_wait 2.0
window_padding_width 12
background_opacity 0.92

foreground #cdd6f4
background #1e1e2e
selection_foreground #1e1e2e
selection_background #89b4fa
cursor #f5e0dc
url_color #89b4fa

color0 #45475a
color8 #585b70
color1 #f38ba8
color9 #f38ba8
color2 #a6e3a1
color10 #a6e3a1
color3 #f9e2af
color11 #f9e2af
color4 #89b4fa
color12 #89b4fa
color5 #f5c2e7
color13 #f5c2e7
color6 #94e2d5
color14 #94e2d5
color7 #bac2de
color15 #a6adc8

active_border_color #89b4fa
inactive_border_color #45475a

tab_bar_style powerline
tab_powerline_style slanted
active_tab_background #89b4fa
active_tab_foreground #1e1e2e
inactive_tab_background #313244
inactive_tab_foreground #cdd6f4
tab_bar_background #1e1e2e
tab_bar_margin_width 0
tab_bar_edge top
tab_title_template {index}: {title}

copy_on_select no
"))

(define %rofi-config
  (plain-file
   "config.rasi"
   "configuration {
    font: \"DejaVu Sans Mono 11\";
    show-icons: true;
    icon-theme: \"Adwaita\";
    terminal: \"kitty\";
    drun-display-format: \"{name}\";
    display-drun: \"Apps\";
    case-sensitive: false;
}

/* Catppuccin Mocha-ish theme.  Rofi 2.0 ignores Xresources, so the
   colors live here instead of in ~/.Xresources. */
window {
    background-color: #1e1e2e;
    border: 2px;
    border-color: #89b4fa;
    border-radius: 8px;
    width: 40%;
    padding: 10px;
}

mainbox {
    spacing: 8px;
}

inputbar {
    background-color: #313244;
    border-radius: 6px;
    padding: 8px;
    spacing: 8px;
}

prompt {
    background-color: transparent;
    text-color: #89b4fa;
}

entry {
    background-color: transparent;
    text-color: #cdd6f4;
    placeholder: \"Search\";
    placeholder-color: #6c7086;
}

listview {
    background-color: transparent;
    lines: 8;
    columns: 1;
    spacing: 4px;
    scrollbar: false;
}

element {
    background-color: transparent;
    text-color: #cdd6f4;
    border-radius: 6px;
    padding: 6px 8px;
    spacing: 8px;
}

element-icon {
    size: 1.2em;
}

element selected {
    background-color: #89b4fa;
    text-color: #1e1e2e;
}
"))

(define %picom-config
  (plain-file
   "picom.conf"
   "backend = \"glx\";
vsync = true;
shadow = true;
shadow-radius = 8;
shadow-opacity = 0.35;
shadow-offset-x = -8;
shadow-offset-y = -8;
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;
inactive-opacity = 0.95;
frame-opacity = 0.90;
"))

(define %dunst-config
  (plain-file
   "dunstrc"
   "[global]
    font = DejaVu Sans Mono 10
    frame_width = 2
    frame_color = \"#89b4fa\"
    separator_color = frame
    corner_radius = 8
    background = \"#1e1e2e\"
    foreground = \"#cdd6f4\"
    timeout = 6
    width = 320
    height = 120
    origin = top-right
    offset = 12x40
    icon_position = left
    max_icon_size = 32x32
    markup = full
    format = \"<b>%s</b>\\n%b\"

[urgency_low]
    background = \"#1e1e2e\"
    foreground = \"#cdd6f4\"
    timeout = 5

[urgency_normal]
    background = \"#1e1e2e\"
    foreground = \"#cdd6f4\"
    timeout = 6

[urgency_critical]
    background = \"#f38ba8\"
    foreground = \"#1e1e2e\"
    frame_color = \"#f38ba8\"
    timeout = 0
"))

(define %icecat-user-js
  (plain-file
   "user.js"
   "// privacy defaults for the dedicated IceCat profile
user_pref(\"app.normandy.enabled\", false);
user_pref(\"app.shield.optoutstudies.enabled\", false);
user_pref(\"browser.contentblocking.category\", \"strict\");
user_pref(\"browser.newtabpage.activity-stream.feeds.telemetry\", false);
user_pref(\"browser.newtabpage.activity-stream.telemetry\", false);
user_pref(\"browser.newtabpage.enabled\", false);
user_pref(\"browser.ping-centre.telemetry\", false);
user_pref(\"browser.search.suggest.enabled\", false);
user_pref(\"browser.startup.homepage\", \"about:blank\");
user_pref(\"browser.startup.page\", 0);
user_pref(\"browser.tabs.warnOnClose\", false);
user_pref(\"browser.urlbar.suggest.searches\", false);
user_pref(\"datareporting.healthreport.uploadEnabled\", false);
user_pref(\"datareporting.policy.dataSubmissionEnabled\", false);
user_pref(\"network.cookie.cookieBehavior\", 1);
user_pref(\"privacy.donottrackheader.enabled\", true);
user_pref(\"privacy.trackingprotection.enabled\", true);
user_pref(\"privacy.trackingprotection.socialtracking.enabled\", true);
user_pref(\"toolkit.telemetry.archive.enabled\", false);
user_pref(\"toolkit.telemetry.enabled\", false);
user_pref(\"toolkit.telemetry.unified\", false);
"))

(define %icecat-desktop
  (plain-file
   "icecat.desktop"
   "[Desktop Entry]
Version=1.0
Name=GNU IceCat
GenericName=Web Browser
Comment=GNU IceCat with the riced profile
Exec=icecat --profile /home/arctan/.config/icecat %u
Icon=icecat
Terminal=false
Type=Application
StartupWMClass=Icecat
MimeType=text/html;text/xml;application/xhtml+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
X-MultipleArgs=false
Categories=Network;WebBrowser;
Encoding=UTF-8
"))

(define %mimeapps
  (plain-file
   "mimeapps.list"
   "[Default Applications]
text/html=icecat.desktop
text/xml=icecat.desktop
text/mml=icecat.desktop
application/xhtml+xml=icecat.desktop
x-scheme-handler/http=icecat.desktop
x-scheme-handler/https=icecat.desktop
x-scheme-handler/about=icecat.desktop
x-scheme-handler/unknown=icecat.desktop
"))

(define %gtk-settings
  (plain-file
   "settings.ini"
   "[Settings]
gtk-theme-name=Adwaita
gtk-icon-theme-name=Adwaita
gtk-font-name=DejaVu Sans 10
gtk-application-prefer-dark-theme=1
"))

(define %xresources
  (plain-file
   "Xresources"
   "Xft.antialias: true
Xft.hinting: true
Xft.rgba: rgb
xterm*faceName: DejaVu Sans Mono
xterm*faceSize: 11
xterm*scrollBar: false
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

;; Local file resolved relative to this config file.
(define %wallpaper
  (local-file "../../wallpapers/guix-dark.png"))

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
         "htop"
         "dbus"
         "adwaita-icon-theme"
         "icecat"
         "kitty"
         "rofi"
         "feh"
         "picom"
         "dunst"
         "libnotify"
         "xdg-utils")))
 (services
  (list
   ;; bash is the login shell.  /etc/profile already provides the Guix
   ;; defaults on Guix System, so we turn guix-defaults? off and keep
   ;; only our own .bashrc (the default one returns early for
   ;; non-interactive login shells, which is how the desktop starts).
   (service home-bash-service-type
            (home-bash-configuration
             (guix-defaults? #f)
             (bashrc (list %bashrc))
             (aliases '())))

   (service home-environment-variables-service-type
            `(("EDITOR" . "nvim")
              ("VISUAL" . "nvim")
              ("TERMINAL" . "kitty")
              ("BROWSER" . "icecat")))

   (simple-service
    'i3-config
    home-files-service-type
    (list `(".config/i3/config" ,%i3-config)
          `(".config/i3status/config" ,%i3status-config)))

   (simple-service
    'rice-config
    home-files-service-type
    (list `(".config/kitty/kitty.conf" ,%kitty-config)
          `(".config/rofi/config.rasi" ,%rofi-config)
          `(".config/picom/picom.conf" ,%picom-config)
          `(".config/dunst/dunstrc" ,%dunst-config)
          `(".config/icecat/user.js" ,%icecat-user-js)
          `(".config/mimeapps.list" ,%mimeapps)
          `(".config/gtk-3.0/settings.ini" ,%gtk-settings)
          `(".local/share/applications/icecat.desktop" ,%icecat-desktop)
          `(".local/share/wallpapers/guix-dark.png" ,%wallpaper)))

   (simple-service
    'nvim-config
    home-files-service-type
    (list `(".config/nvim/init.lua" ,%nvim-init)))

   (simple-service
    'xresources
    home-files-service-type
    (list `(".Xresources" ,%xresources)))

   ;; Start i3 inside a D-Bus session so dunst and browser integration work.
   (simple-service
    'dbus-session
    home-activation-service-type
    #~(begin
        (let ((file (string-append (getenv "HOME") "/.xsession")))
          (call-with-output-file file
            (lambda (port)
              (display "#!/bin/sh\n" port)
              (display "export XDG_CURRENT_DESKTOP=i3\n" port)
              (display "export XDG_SESSION_TYPE=x11\n" port)
              (display "export MOZ_ENABLE_WAYLAND=0\n" port)
              (display "exec dbus-run-session -- i3\n" port)))
          (chmod file #o755)))))))
