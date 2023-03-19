#!/bin/sh
export DISPLAY=:98

if [ -n "$(find "/home/steam/.local/share/Paradox Interactive/Hearts of Iron IV/mod" -prune -empty 2>/dev/null)" ]; then
    echo "'/home/steam/.local/share/Paradox Interactive/Hearts of Iron IV/mod' is empty!"
    exit 1
fi

if [ -z "$STEAM_LOGIN" ] || [ "$STEAM_LOGIN" = "" ]; then
    echo "STEAM_LOGIN env variable needs to be set!"
    exit 1
fi

if [ -z "$STEAM_PASSWORD" ] || [ "$STEAM_PASSWORD" = "" ]; then
    echo "STEAM_PASSWORD env variable needs to be set!"
    exit 1
fi

if [ -z "$STEAM_APP_ID" ] || [ "$STEAM_APP_ID" = "" ]; then
    echo "STEAM_APP_ID env variable needs to be set!"
    exit 1
fi

if [ -z "$PDX_LOGIN" ] || [ "$PDX_LOGIN" = "" ]; then
    echo "PDX_LOGIN env variable needs to be set!"
    exit 1
fi

if [ -z "$PDX_PASSWORD" ] || [ "$PDX_PASSWORD" = "" ]; then
    echo "PDX_PASSWORD env variable needs to be set!"
    exit 1
fi

if [ -z "$POP3_ADDRESS" ] || [ "$POP3_ADDRESS" = "" ]; then
    echo "POP3_ADDRESS env variable needs to be set!"
    exit 1
fi

if [ -z "$POP3_USER" ] || [ "$POP3_USER" = "" ]; then
    echo "POP3_USER env variable needs to be set!"
    exit 1
fi

if [ -z "$POP3_PASSWORD" ] || [ "$POP3_PASSWORD" = "" ]; then
    echo "POP3_PASSWORD env variable needs to be set!"
    exit 1
fi

if [ -z "$STEAM_SENTRY_FILE_HEX" ] || [ "$STEAM_SENTRY_FILE_HEX" = "" ] || [ -z "$STEAM_SENTRY_FILE_NAME" ] || [ "$STEAM_SENTRY_FILE_NAME" = "" ] || [ -z "$STEAM_CONFIG_VDF_HEX" ] || [ "$STEAM_CONFIG_VDF_HEX" = "" ]; then
    sleep 0
else
    echo "Steam Sentry data found, using it..."
    rm -f "$HOME/.steam/steam/ssfn*"
    echo "$STEAM_SENTRY_FILE_HEX" | xxd -p -r - "$HOME/.steam/steam/$STEAM_SENTRY_FILE_NAME"
    rm -f "$HOME/.steam/steam/config/config.vdf"
    echo "$STEAM_CONFIG_VDF_HEX" | xxd -p -r - "$HOME/.steam/steam/config/config.vdf"
fi
curl https://api.ipify.org
# echo "Starting steamcmd"
# /opt/steamcmd_gmail +login "$STEAM_LOGIN" "$STEAM_PASSWORD" +quit || /opt/steamcmd/steamcmd.sh +login "$STEAM_LOGIN" "$STEAM_PASSWORD" +quit
sudo pkill Xvfb
sleep 1
sudo Xvfb $DISPLAY -screen 0 1280x720x24 -ac +extension RANDR +render -noreset &
sleep 1
if [ -n "$VNC_PASSWORD" ]; then sudo x11vnc -passwd "$VNC_PASSWORD" -display $DISPLAY -N -forever; fi &
echo "Starting steam"
export TIME_START=$(date +%s)
sleep 5
/usr/games/steam -login "$STEAM_LOGIN" "$STEAM_PASSWORD" -applaunch "$STEAM_APP_ID" -windowed -nobigpicture -nointro -vrdisable -inhibitbootstrap -nobootstrapperupdate -nodircheck -norepairfiles -noverifyfiles -nocrashmonitor -skipstreamingdrivers -no-cef-sandbox -nochatui -nofriendsui -silent &
/home/steam/xdotool_script.sh
