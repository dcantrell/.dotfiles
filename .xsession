#!/bin/zsh

PATH=/usr/X11/bin:/usr/bin
HOST="$(hostname | cut -d '.' -f 1)"

if [ "${HOST}" = "bnsf" ]; then
    # GTK 3.x scaling
    GDK_DPI_SCALE=0.5
    GDK_SCALE=2
    export GDK_DPI_SCALE GDK_SCALE

    # Griffin PowerMate knob for volume control
    DEVNODE=/dev/powermate

    if [ -r "${DEVNODE}" ]; then
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

# desktop environment
exec startxfce4
