# Add custom PATH
PATH=$PATH:/opt/arcOS/bin

# Remove CDROM repo
if [ -f /etc/apt/sources.list ]; then
    sudo rm /etc/apt/sources.list
fi

# Set timezone
sudo timedatectl set-timezone UTC

# Set login/logout sounds
gsettings set org.cinnamon.sounds login-file "/usr/share/sounds/hi.ogg"
gsettings set org.cinnamon.sounds logout-file "/usr/share/sounds/73.ogg"

# Set system icon for system reports
gsettings set org.cinnamon system-icon "computer-symbolic"

# Default screensaver settings
gsettings set org.cinnamon.desktop.screensaver use-custom-format true
gsettings set org.cinnamon.desktop.screensaver time-format '%H:%M %Z'
gsettings set org.cinnamon.desktop.screensaver date-format ' %a, %B %d'

# Set favorite applications in main menu
gsettings set org.cinnamon favorite-apps '["station-setup.desktop","update-modules.desktop","org.gnome.Terminal.desktop","io.github.Hexchat.desktop"]'

# Customize panel applets
gsettings set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org:0', 'panel1:left:1:separator@cinnamon.org:1', 'panel1:left:2:grouped-window-list@cinnamon.org:2', 'panel1:right:0:workspace-switcher@cinnamon.org:3', 'panel1:right:0:systray@cinnamon.org:4', 'panel1:right:1:xapp-status@cinnamon.org:5', 'panel1:right:2:notifications@cinnamon.org:6', 'panel1:right:3:printers@cinnamon.org:7', 'panel1:right:4:removable-drives@cinnamon.org:8', 'panel1:right:5:keyboard@cinnamon.org:9', 'panel1:right:6:favorites@cinnamon.org:10', 'panel1:right:7:network@cinnamon.org:11', 'panel1:right:8:sound@cinnamon.org:12', 'panel1:right:9:power@cinnamon.org:13', 'panel1:right:10:calendar@cinnamon.org:14']"

# Set number of workspaces
gsettings set org.cinnamon.desktop.wm.preferences num-workspaces 2

# Set Cinnamon/GNOME theme
gsettings set org.cinnamon.desktop.interface gtk-theme "Mint-Y-Grey"
gsettings set org.gnome.desktop.interface gtk-theme "Mint-Y-Grey"
gsettings set org.cinnamon.theme name "Mint-Y-Dark-Grey"

# Enable transparent panels
gsettings set org.cinnamon enabled-extensions "['transparent-panels@germanfr']"

# Default fonts
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "Ubuntu Bold 10"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Ubuntu Bold 10"
gsettings set org.nemo.desktop font "Ubuntu Bold 10"
gsettings set org.gnome.desktop.interface monospace-font-name "Ubuntu Mono 10"
gsettings set org.cinnamon.desktop.interface font-name "Ubuntu Bold 10"
gsettings set org.gnome.desktop.interface font-name "Ubuntu Bold 10"

# Reduce network notifications
gsettings set org.gnome.nm-applet disable-connected-notifications true
gsettings set org.gnome.nm-applet disable-disconnected-notifications true
gsettings set org.gnome.nm-applet suppress-wireless-networks-available true

# Set Warpinator options
gsettings set org.x.warpinator.preferences group-code 'arcOS'
gsettings set org.x.warpinator.preferences receiving-folder 'file:///home/user/Downloads'
gsettings set org.x.warpinator.preferences use-compression true
gsettings set org.x.warpinator.preferences use-tray-icon true

# Set laptop lid actions
gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action blank
gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-battery-action blank

# Disbale keybindings for logout/suspend/hibernate
gsettings set org.cinnamon.desktop.keybindings.media-keys logout "[]"
gsettings set org.cinnamon.desktop.keybindings.media-keys suspend "[]"
gsettings set org.cinnamon.desktop.keybindings.media-keys hibernate "[]"

# Disable remembering recent files
gsettings set org.cinnamon.desktop.privacy remember-recent-files false

# Disable auto-open of external media
gsettings set org.cinnamon.desktop.media-handling automount-open false

# Text editor preferences
gsettings set org.x.editor.preferences.editor scheme 'oblivion'
gsettings set org.x.editor.preferences.editor display-line-numbers true
gsettings set org.x.editor.preferences.editor insert-spaces false
gsettings set org.x.editor.preferences.editor auto-indent true
gsettings set org.x.editor.plugins active-plugins "['modelines', 'time', 'sort', 'open-uri-context-menu', 'filebrowser', 'textsize', 'spell', 'docinfo', 'joinlines']"

# Terminal preferences
LEGACY_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar "false"
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${LEGACY_PROFILE}/ use-theme-colors 'false'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${LEGACY_PROFILE}/ foreground-color '#FFFFFF'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${LEGACY_PROFILE}/ background-color '#000000'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${LEGACY_PROFILE}/ use-theme-transparency 'false'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${LEGACY_PROFILE}/ use-transparent-background 'true'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${LEGACY_PROFILE}/ background-transparency-percent '15'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${LEGACY_PROFILE}/ scrollbar-policy 'always'

# Sticky notes
gsettings set org.x.sticky autostart true
gsettings set org.x.sticky autostart-notes-visible false
gsettings set org.x.sticky default-position 'center-center'
gsettings set org.x.sticky show-in-tray true
gsettings set org.x.sticky show-manager false
gsettings set org.x.sticky inline-spell-check false
gsettings set org.x.sticky automatic-backups true

# Disable user switching
gsettings set org.cinnamon.desktop.lockdown disable-user-switching true
gsettings set org.gnome.desktop.lockdown disable-user-switching true

# Custom keybindings
dconf load /org/cinnamon/desktop/keybindings/ < /opt/arcOS/configs/cinnamon/keybindings.conf

# Import ISO signing key
gpg --import /opt/arcOS/configs/gnupg/arcOS-ISO-Signing-Key_PUBLIC.asc > /dev/null 2>&1
