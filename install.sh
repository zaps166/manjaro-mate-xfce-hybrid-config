#!/usr/bin/env bash

configurePacman() {
    echo "Configuring pacman"
    sudo sed -i "s/#Color/Color/g" /etc/pacman.conf
    sudo sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" /etc/pacman.conf
    sudo sed -i "s/#ParallelDownloads/ParallelDownloads/g" /etc/pacman.conf
    sudo pacman -Sy
}

installPackages() {
    echo "Installing packages"
    yay -Q $PACKAGES > /dev/null 2> /dev/null
    sudo pacman -S --needed base-devel cmake git bash-completion yay mc kvantum kvantum-theme-matcha htop matcha-gtk-theme xfce4-settings xfwm4 xfce4-panel xfce4-battery-plugin xfce4-clipman-plugin xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-netload-plugin xfce4-notes-plugin xfce4-sensors-plugin xfce4-systemload-plugin xfce4-weather-plugin xfce4-whiskermenu-plugin ttf-dejavu oxygen kate || exit
}

configureUserData() {
    echo "Configuring user data"
    install -D -m 644 "data/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
    mkdir -p "$HOME/.config/autostart" && install -D -m 644 "data/autostart/"* "$HOME/.config/autostart"
    install -D -m 644 "/usr/share/applications/xfce-settings-manager.desktop" "$HOME/.local/share/applications/xfce-settings-manager.desktop"
    install -D -m 644 "/usr/share/applications/org.kde.kate.desktop" "$HOME/.local/share/applications/org.kde.kate.desktop"
    sed -i 's/OnlyShowIn=XFCE;/OnlyShowIn=XFCE;MATE;/g' "$HOME/.local/share/applications/xfce-settings-manager.desktop" # Display Xfce4 settings in menu
    sed -i 's/StartupNotify=true/StartupNotify=false/g' "$HOME/.local/share/applications/org.kde.kate.desktop" # Prevent long busy cursor when adding files to existing Kate instance
    chmod 444 "$HOME/.local/share/applications/org.kde.kate.desktop" # Prevent file modification by Kate
    if [[ -f "$HOME/.profile" ]]; then
        sed -i '/QT_QPA_PLATFORMTHEME/d' "$HOME/.profile" # We don't use it
        sed -i '/EDITOR/d' "$HOME/.profile" # We have EDITOR in /etc/environment
    fi
    sed -i "s/; (gtk_accel_path \"<Actions>\/DirViewActions\/Redo\" \"<Primary>y\")/(gtk_accel_path \"<Actions>\/DirViewActions\/Redo\" \"\")/g" "$HOME/.config/caja/accels" # Disable Redo hotkey
    sed -i "s/; (gtk_accel_path \"<Actions>\/DirViewActions\/Undo\" \"<Primary>z\")/(gtk_accel_path \"<Actions>\/DirViewActions\/Undo\" \"\")/g" "$HOME/.config/caja/accels" # Disable Undo hotkey
    sed -i "s/; (gtk_accel_path \"<Actions>\/ExtensionsMenuGroup\/CajaOpenTerminal::open_terminal\" \"\")/(gtk_accel_path \"<Actions>\/ExtensionsMenuGroup\/CajaOpenTerminal::open_terminal\" \"F4\")/g" "$HOME/.config/caja/accels" # Enable F4 for terminal

    grep "getGitBranch" "$HOME/.bashrc" > /dev/null
    if [[ $? != 0 ]]; then
        echo -n "Do you want to set git info in bash prompt? [y/N] "
        read response
        if [[ $response == 'y' || $response == 'Y' ]]; then
            cat "data/git.bashrc" >> "$HOME/.bashrc"
        fi
    fi

    echo -n "Do you want to load Kvantum configuration? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        cp -r "data/Kvantum" "$HOME/.config"
    fi
}

function mateSettings() {
    echo "Configuring MATE"

    # Blueman
    dconf write /org/blueman/plugins/powermanager/auto-power-on false

    dconf write /org/mate/desktop/applications/calculator/exec "'qalculate-gtk'"

    # Caja desktop
    dconf write /org/mate/caja/desktop/computer-icon-visible false
    dconf write /org/mate/caja/desktop/font "'DejaVu Sans 10'"
    dconf write /org/mate/caja/desktop/trash-icon-visible false
    dconf write /org/mate/caja/desktop/volumes-visible false

    # Caja
    dconf write /org/mate/caja/preferences/always-use-location-entry true
    dconf write /org/mate/caja/preferences/preview-sound "'never'"
    dconf write /org/mate/caja/preferences/show-icon-text "'never'"
    dconf write /org/mate/caja/preferences/thumbnail-limit 104857600
    dconf write /org/mate/caja/preferences/use-iec-units true

    # Font rendering
    dconf write /org/mate/desktop/font-rendering/antialiasing "'grayscale'"
    dconf write /org/mate/desktop/font-rendering/hinting "'slight'"

    # Desktop interface
    dconf write /org/mate/desktop/interface/document-font-name "'DejaVu Sans 10'"
    dconf write /org/mate/desktop/interface/font-name "'DejaVu Sans 10'"
    dconf write /org/mate/desktop/interface/enable-animations false
    dconf write /org/mate/desktop/interface/gtk-enable-animations false
    dconf write /org/mate/desktop/interface/gtk-enable-primary-paste false
    dconf write /org/mate/desktop/interface/gtk-theme "'Matcha-dark-azul'"
    dconf write /org/mate/desktop/interface/icon-theme "'Papirus-Dark'"
    dconf write /org/mate/desktop/interface/monospace-font-name "'DejaVu Sans Mono 10'"
    dconf write /org/mate/desktop/interface/window-scaling-factor-qt-sync false

    # Desktop background
    dconf write /org/mate/desktop/background/show-desktop-icons true

    # Desktop media
    dconf write /org/mate/desktop/media-handling/automount false
    dconf write /org/mate/desktop/media-handling/automount-open false
    dconf write /org/mate/desktop/media-handling/autorun-never true

    # Desktop peripherals
    dconf write /org/mate/desktop/peripherals/keyboard/delay 275
    dconf write /org/mate/desktop/peripherals/keyboard/numlock-state "'unknown'"
    dconf write /org/mate/desktop/peripherals/mouse/middle-button-enabled false
    dconf write /org/mate/desktop/peripherals/mouse/cursor-theme "'Oxygen_Zion'"
    dconf write /org/mate/desktop/peripherals/touchpad/horizontal-two-finger-scrolling true
    dconf write /org/mate/desktop/peripherals/touchpad/three-finger-click 2
    dconf write /org/mate/desktop/peripherals/touchpad/two-finger-click 3
    dconf write /org/mate/desktop/peripherals/touchpad/vertical-edge-scrolling false

    # Desktop session
    dconf write /org/mate/desktop/session/logout-timeout 20
    dconf write /org/mate/desktop/session/required-components-list "['filemanager']"
    dconf write /org/mate/desktop/session/auto-save-session false

    # Desktop sound
    dconf write /org/mate/desktop/sound/event-sounds false

    # Notification daemon
    dconf write /org/mate/notification-daemon/popup-location "'top_right'"
    dconf write /org/mate/notification-daemon/theme "'slider'"

    # Power manager
    dconf write /org/mate/power-manager/action-critical-battery "'nothing'"
    dconf write /org/mate/power-manager/backlight-battery-reduce false
    dconf write /org/mate/power-manager/backlight-enable false
    dconf write /org/mate/power-manager/button-lid-ac "'nothing'"
    dconf write /org/mate/power-manager/idle-dim-battery false
    dconf write /org/mate/power-manager/kbd-backlight-battery-reduce false

    # Settings daemon
    dconf write /org/mate/settings-daemon/plugins/clipboard/active false
    dconf write /org/mate/settings-daemon/plugins/xrandr/show-notification-icon true

    # Screensaver
    dconf write /org/mate/screensaver/idle-activation-enabled false
    dconf write /org/mate/screensaver/lock-enabled false

    # Terminal
    dconf write /org/mate/terminal/global/use-menu-accelerators false
    dconf write /org/mate/terminal/keybindings/reset "'disabled'"
    dconf write /org/mate/terminal/keybindings/reset-and-clear "'<Primary><Shift>k'"
    dconf write /org/mate/terminal/profiles/default/use-theme-colors false
    dconf write /org/mate/terminal/profiles/default/scrollback-unlimited true
    dconf write /org/mate/terminal/profiles/default/scroll-on-keystroke true
    dconf write /org/mate/terminal/profiles/default/scroll-on-output false
    dconf write /org/mate/terminal/profiles/default/silent-bell true
    dconf write /org/mate/terminal/profiles/default/use-custom-default-size true
    dconf write /org/mate/terminal/profiles/default/default-size-columns 170
    dconf write /org/mate/terminal/profiles/default/default-size-rows 50
    dconf write /org/mate/terminal/profiles/default/cursor-blink-mode '"off"'
    dconf write /org/mate/terminal/profiles/default/cursor-shape '"block"'
    dconf write /org/mate/terminal/profiles/default/background-color "'#000000000000'"
    dconf write /org/mate/terminal/profiles/default/bold-color-same-as-fg true
    dconf write /org/mate/terminal/profiles/default/foreground-color "'#AAAAAAAAAAAA'"
    dconf write /org/mate/terminal/profiles/default/palette '"#000000000000:#AAAA00000000:#0000AAAA0000:#AAAA55540000:#22212221AAAA:#AAAA0000AAAA:#0000AAAAAAAA:#AAAAAAAAAAAA:#555455545554:#FFFF55545554:#5554FFFF5554:#FFFFFFFF5554:#55545554FFFF:#FFFF5554FFFF:#5554FFFFFFFF:#FFFFFFFFFFFF"'

    echo -n "Do you want to load Mate key bindings? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        dconf load /org/mate/desktop/keybindings/ < data/org.mate.desktop.keybindings.conf
    fi
}

function xfce4Settings()
{
    echo "Configuring Xfce4"

    WINDOW_SCALING_FACTOR=$(dconf read /org/mate/desktop/interface/window-scaling-factor)

    p=$(ps -x)
    echo $p | grep xfwm4 > /dev/null
    if [ $? != 0 ]; then
        echo "Starting Xfwm4..."
        xfwm4 --replace &
        sleep 2
    fi
    unset p

    xfconf-query -c xfwm4 -p /general/workspace_count -s 2

    # Xfwm4 settings
    if [[ $WINDOW_SCALING_FACTOR == 2 ]]; then
        xfconf-query -c xfwm4 -p /general/theme -s "Matcha-dark-azul-hdpi"
    else
        xfconf-query -c xfwm4 -p /general/theme -s "Matcha-dark-azul"
    fi
    xfconf-query -c xfwm4 -p /general/title_font -s "DejaVu Sans Bold 9"
    xfconf-query -c xfwm4 -p /general/title_alignment -s "center"
    xfconf-query -c xfwm4 -p /general/button_layout -s "CHM|O"

    xfconf-query -c xfwm4 -p /general/click_to_focus -s true
    xfconf-query -c xfwm4 -p /general/focus_new -s true
    xfconf-query -c xfwm4 -p /general/raise_on_focus -s true
    xfconf-query -c xfwm4 -p /general/raise_on_click -s true

    xfconf-query -c xfwm4 -p /general/snap_to_border -s true
    xfconf-query -c xfwm4 -p /general/snap_to_windows -s true
    xfconf-query -c xfwm4 -p /general/snap_width -s 9
    xfconf-query -c xfwm4 -p /general/wrap_workspaces -s false
    xfconf-query -c xfwm4 -p /general/wrap_windows -s false
    xfconf-query -c xfwm4 -p /general/box_move -s false
    xfconf-query -c xfwm4 -p /general/box_resize -s false
    xfconf-query -c xfwm4 -p /general/double_click_action -s "maximize"

    # Xfwm4 tweaks
    xfconf-query -c xfwm4 -p /general/cycle_minimum -s true
    xfconf-query -c xfwm4 -p /general/cycle_minimized -s false
    xfconf-query -c xfwm4 -p /general/cycle_hidden -s true
    xfconf-query -c xfwm4 -p /general/cycle_workspaces -s false
    xfconf-query -c xfwm4 -p /general/cycle_draw_frame -s true
    xfconf-query -c xfwm4 -p /general/cycle_raise -s false
    xfconf-query -c xfwm4 -p /general/cycle_tabwin_mode -s 1

    xfconf-query -c xfwm4 -p /general/prevent_focus_stealing -s false
    xfconf-query -c xfwm4 -p /general/focus_hint -s true
    xfconf-query -c xfwm4 -p /general/activate_action -s "switch"

    xfconf-query -c xfwm4 -p /general/easy_click -s "Mod4"
    xfconf-query -c xfwm4 -p /general/raise_with_any_button -s false
    xfconf-query -c xfwm4 -p /general/borderless_maximize -s true
    xfconf-query -c xfwm4 -p /general/titleless_maximize -s false
    xfconf-query -c xfwm4 -p /general/tile_on_move -s true
    xfconf-query -c xfwm4 -p /general/snap_resist -s true
    xfconf-query -c xfwm4 -p /general/mousewheel_rollup -s false
    xfconf-query -c xfwm4 -p /general/urgent_blink -s false

    xfconf-query -c xfwm4 -p /general/scroll_workspaces -s false
    xfconf-query -c xfwm4 -p /general/toggle_workspaces -s false
    xfconf-query -c xfwm4 -p /general/wrap_layout -s false
    xfconf-query -c xfwm4 -p /general/wrap_cycle -s false

    xfconf-query -c xfwm4 -p /general/placement_mode -s "center"
    xfconf-query -c xfwm4 -p /general/placement_ratio -s 20

    xfconf-query -c xfwm4 -p /general/use_compositing -s false

    # Xfwm4 key bindings
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_1" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_2" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_3" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_4" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_5" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_6" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_7" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_8" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>KP_9" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>Up" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Up" -n -t string -s "tile_up_key"
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>Down" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Down" -n -t string -s "tile_down_key"
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>Left" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Left" -n -t string -s "tile_left_key"
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>Right" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Right" -n -t string -s "tile_right_key"
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Alt>d" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>d" -n -t string -s "show_desktop_key"
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Insert" -r
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Delete" -r

    echo -n "Do you want to set xfce4-panel? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        echo "Loading xfce4-panel config"
        install -D -m 644 "data/xfce4-panel.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
    fi
}

function installMateXfceTool
{
    echo -n "Do you want to install mate-xfce-tool? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        git clone https://github.com/zaps166/mate-xfce-tool.git || return
        mkdir -p "mate-xfce-tool/build" || return
        pushd "mate-xfce-tool/build" || return
        cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr || popd || return
        make || popd || return
        sudo make install/strip
        popd
    fi
}

function configureSystem()
{
    echo "Setting MAKEFLAGS"
    printf "export MAKEFLAGS=-j\$((\$(nproc)))\n" | sudo tee /etc/profile.d/makeflags.sh > /dev/null

    echo "Setting 'nice' limits"
    sudo install -D -m 644 "data/limits-99-nice.conf" "/etc/security/limits.d/99-nice.conf"

    echo -n "Do you want to configure systemd? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        echo "Disabling coredump"
        sudo mkdir -p /etc/systemd/coredump.conf.d
        printf "[Coredump]\nStorage=none\nCompress=no\n" | sudo tee /etc/systemd/coredump.conf.d/custom.conf > /dev/null

        echo "Disabling man-db service and man-db timer"
        sudo systemctl mask man-db.service man-db.timer

        echo "Disabling /tmp tmpfs"
        sudo systemctl mask tmp.mount
    fi

    echo -n "Do you want to load sysctl config? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        echo "Loading sysctl config"
        sudo install -D -m 644 "data/sysctl.conf" "/etc/sysctl.d/50-default.conf"
    fi

    echo -n "Do you want to load environment config? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        echo "Loading environment config"
        sudo install -D -m 644 "data/environment" "/etc/environment"
    fi

    echo -n "Do you want to set realtime for pipewire? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        echo "Loading pipewire config"
        sudo install -D -m 644 "data/pipewire-client-rt.conf" "/etc/pipewire/client.conf.d/client-rt.conf"
    fi
}

function installOtherPackages
{
    echo -n "Do you want to install pipewire? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        yes | sudo pacman -S --needed wireplumber manjaro-pipewire rtkit realtime-privileges pipewire-v4l2 pipewire-pulse pipewire-jack lib32-pipewire
        yes | sudo pacman -R pulseaudio-alsa
    fi

    echo -n "Do you want to install VA-API and Vulkan opensource drivers? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        yes | sudo pacman -S --needed vulkan-intel lib32-vulkan-intel vulkan-radeon vulkan-mesa-layers lib32-vulkan-radeon lib32-vulkan-mesa-layers libva-mesa-driver libva-intel-driver intel-media-driver libva-utils
    fi

    echo -n "Do you want to install other packages? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        yes | sudo pacman -S --needed mesa-utils vulkan-tools pavucontrol helvum seahorse qalculate-gtk ksysguard spectacle kimageformats kcolorchooser okteta kolourpaint kwrite thunar easyeffects remmina lib32-libpulse
    fi

    echo -n "Do you want to install xfce4-mate-applet-loader-plugin? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        yes | yay -S xfce4-mate-applet-loader-plugin-git
    fi

    echo -n "Do you want to install QDRE Compositor? [y/N] "
    read response
    if [[ $response == 'y' || $response == 'Y' ]]; then
        yes | yay -S --needed qdre-compositor-git qdre-compositor-autostart
        dconf write /org/qdre/compositor/prevent-window-transparency-exceptions "['Mozilla Firefox$', 'Chromium$']"
    fi
}

export LANG=C # Needed for "yes"

configurePacman
installPackages
configureUserData
mateSettings
xfce4Settings
installMateXfceTool
installOtherPackages
configureSystem

echo "Reboot the computer!"
