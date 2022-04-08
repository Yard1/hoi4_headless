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

if [ -z "$GOOGLE_API_CREDENTIALS" ] || [ "$GOOGLE_API_CREDENTIALS" = "" ]; then
    echo "GOOGLE_API_CREDENTIALS env variable needs to be set, use your Google API credentials as it!"
    exit 1
fi

if [ -z "$GOOGLE_CLIENT_SECRET" ] || [ "$GOOGLE_CLIENT_SECRET" = "" ]; then
    echo "GOOGLE_CLIENT_SECRET env variable needs to be set, use your gmail client secret as it!"
    exit 1
fi

echo "$GOOGLE_API_CREDENTIALS" | sudo tee -a /credential.json > /dev/null
echo "$GOOGLE_CLIENT_SECRET" | sudo tee -a /client_secret.json > /dev/null

if [ -z "$STEAM_SENTRY_FILE_HEX" ] || [ "$STEAM_SENTRY_FILE_HEX" = "" ] || [ -z "$STEAM_SENTRY_FILE_NAME" ] || [ "$STEAM_SENTRY_FILE_NAME" = "" ]; then
    sleep 0
else
    echo "Steam Sentry data found, using it..."
    echo "$STEAM_SENTRY_FILE_HEX" | xxd -p -r - "$HOME/.steam/steam/$STEAM_SENTRY_FILE_NAME"
fi
curl https://api.ipify.org
/opt/steamcmd_gmail +login "$STEAM_LOGIN" "$STEAM_PASSWORD" +quit || /opt/steamcmd/steamcmd.sh +login "$STEAM_LOGIN" "$STEAM_PASSWORD" +quit
sudo pkill Xvfb
sleep 1
sudo Xvfb $DISPLAY -screen 0 1280x720x24 -ac +extension RANDR +render -noreset &
if [ -n "$VNC_PASSWORD" ]; then sudo x11vnc -passwd "$VNC_PASSWORD" -display $DISPLAY -N -forever; fi &
/usr/games/steam -login "$STEAM_LOGIN" "$STEAM_PASSWORD" -no-browser -applaunch "$STEAM_APP_ID" >> /dev/null &
/home/steam/xdotool_script.sh
