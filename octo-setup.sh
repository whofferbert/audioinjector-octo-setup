#!/bin/sh
# by William Hofferbert
# set up the audioinjector-octo better than the deb does.

DATE=$(date +%Y-%m-%d.%H.%M.%S)

getHomeUsers () {
    ls -1trd /home/* | grep -Po "[^/]+$"
}

configTxtSetup () {
    echo setting up /boot/config.txt
    config_BACKUP_FN=/boot/config.txt.$DATE
    echo backing up /boot/config.txt to $config_BACKUP_FN
    cp /boot/config.txt $config_BACKUP_FN
    # check the device tree overlay is setup correctly ...
    # firstly disable PWM audio
    sed -i "s/^\s*dtparam=audio/#dtparam=audio/" /boot/config.txt
    # remove any previous mentions of the octo overlay
    sed -i "/AudioInjector/d" /boot/config.txt
    sed -i "/audioinjector-addons/d" /boot/config.txt
    echo setting up /boot/config.txt
    # now check to see the correct device tree overlay is loaded ...
    echo '# enable the AudioInjector.net sound card
dtoverlay=audioinjector-addons' >> /boot/config.txt
}

rootConfSet () {
    ASOUNDRC_BACKUP_FN=/etc/asound.conf.$DATE
    echo backing up /etc/asound.conf to $ASOUNDRC_BACKUP_FN
    [ -f /etc/asound.conf ] && sudo mv /etc/asound.conf $ASOUNDRC_BACKUP_FN
}

userConfSet () {
    local user=$1
    local home=$(grep ^$user /etc/passwd | cut -d":" -f6)
    if [ -n "$home" ] ; then
	ASOUNDRC_BACKUP_FN=$home/.asoundrc.$DATE
	echo backing up $home/.asoundrc to $ASOUNDRC_BACKUP_FN
	[ -f $home/.asoundrc ] && mv $home/.asoundrc $ASOUNDRC_BACKUP_FN
        userAsoundConf > $home/.asoundrc
	if [ -e $home/.config/lxpanel/LXDE-pi/panels/panel ]; then
	    echo "$user: lxpanel's volume plugin is disfunctional, disabling it"
	    sed -i 's/\=volumealsa/\=REMOVEvolumealsa/' $home/.config/lxpanel/LXDE-pi/panels/panel
	fi
    fi
}


octoAsoundConf () {
    cat << EOF
pcm.!default {
#       type hw
#       card 0
        type plug
        slave.pcm "anyChannelCount"
}

ctl.!default {
        type hw
        card 0
}

pcm.anyChannelCount {
    type route
    slave.pcm "hw:0"
    slave.channels 8;
    ttable {
           0.0 1
           1.1 1
           2.2 1
           3.3 1
           4.4 1
           5.5 1
           6.6 1
           7.7 1
    }
}

ctl.anyChannelCount {
    type hw;
    card 0;
}
EOF
}


userAsoundConf () {
    cat << EOF
pcm.!default {
#       type hw
#       card 0
        type plug
        slave.pcm "anyChannelCount"
}

ctl.!default {
        type hw
        card 0
}
EOF
}


main () {
    configTxtSetup
    rootConfSet

    for user in root $(getHomeUsers) ; do
        userConfSet $user
    done
    
    octoAsoundConf > /tmp/asound.conf
    sudo mv /tmp/asound.conf /etc/asound.conf
    
    pulseCheck=$(dpkg -l | grep pulseaudio)
    if [ -n "$pulseCheck" ] ; then
        echo
        echo pulse gets in the way we suggest you remove it, please run the following manually :
        echo   sudo apt remove pulseaudio
    fi
}

main

