#!/bin/zsh

PATH=/usr/X11/bin:/usr/bin:/usr/local/bin
HOST="$(hostname | cut -d '.' -f 1)"
DEVNODE=

if [ "${HOST}" = "bnsf" ]; then
    # GTK 3.x scaling
    GDK_DPI_SCALE=0.5
    GDK_SCALE=2
    export GDK_DPI_SCALE GDK_SCALE

    # Griffin PowerMate knob for volume control
    DEVNODE=/dev/powermate
elif [ "${HOST}" = "awvr" ]; then
    # Ensure the audio nonsense is set to reasonable defaults
    pactl set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
    pactl set-default-source alsa_input.usb-Logitech_USB_Headset_Logitech_USB_Headset-00.mono-fallback

    # Griffin PowerMate knob for volume control
    DEVNODE=/dev/input/powermate
fi

# Run input event handler if devnode defined
if [ -r "${DEVNODE}" ]; then
    powermate --help >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        POWERMATE_PID=$(pgrep powermate)
        [ -z "${POWERMATE_PID}" ] && powermate -d
    else
        EVROUTER_PID=$(pgrep evrouter)
        XBINDKEYS_PID=$(pgrep xbindkeys)

        if [ -z "${EVROUTER_PID}" ]; then
            rm -f /tmp/.evrouter*
            evrouter ${DEVNODE}
        fi

        if [ -z "${XBINDKEYS_PID}" ]; then
            xbindkeys
        fi
    fi
fi

# Set audio input and output
if pactl --help >/dev/null 2>&1 ; then
    pactl list short sinks | grep alsa | while read -r num shortname stuff ; do
        echo "${shortname}" | grep -q -i headset >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            # input from the USB headset
            pactl set-default-source "${shortname}"
        else
            # output to regular headphones
            pactl set-default-sink "${shortname}"
        fi
    done
fi

# desktop environment
exec startxfce4
