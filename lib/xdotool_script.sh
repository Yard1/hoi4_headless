#!/bin/bash

img=0

set -x
# $1 = filename
# $2 = crop arguments
compare_current_screen () {
    rm $HOME/temp.png 2> /dev/null
    import -screen -window root "$HOME/temp.png"
    sudo cp -f "$HOME/temp.png" "$DEBUG_IMAGES/temp_uncropped.png"
    mogrify -crop $2 "$HOME/temp.png"
    sudo cp -f "$HOME/temp.png" "$DEBUG_IMAGES/temp_cropped.png"
    compare_out=$(compare -metric AE "$HOME/temp.png" $1 /dev/null 2>&1)
    echo "Compare current screen at $2 to $1: $compare_out"
    #rm $HOME/temp.png
    if [ "$compare_out" = "0" ] || [ "$compare_out" = "1" ] || [ "$compare_out" = "2" ] || [ "$compare_out" = "inf" ]; then
        return 0
    else
        return 1
    fi
}

# $1 = filename
# $2 = crop arguments
# $3 = max_iters
wait_until_screen_matches () {
    echo "Saving current screen to $DEBUG_IMAGES/debug_screen_$img.png"
    sudo import -screen -window root $DEBUG_IMAGES/debug_screen_$img.png
    img=$((img+1))
    i=0
    while sleep 2
    do
        echo "wait_until_screen_matches $i $1 $2"
        if compare_current_screen "$1" "$2"; then
            sleep 1
            break
        elif [ "$i" = $3 ]; then
        #    echo "Maximum amount of iterations reached, exiting with a non-zero exit code..."
            echo "Saving current screen to $DEBUG_IMAGES/debug_screen_$img.png"
            sudo import -screen -window root $DEBUG_IMAGES/debug_screen_$img.png
            img=$((img+1))
            echo "Maximum amount of iterations reached, moving onto next step..."
            break
        #    exit 1
        fi
        import -screen -window root $HOME/debug_screen.png
        i=$((i+1))
    done
}

sleep 2

if [ -f "$HOME/description.txt" ]; then
    echo "$HOME/description.txt exists, using as PDX_DESCRIPTION"
    export PDX_DESCRIPTION=$(<$HOME/description.txt)
fi
if [ -z "$PDX_DESCRIPTION" ] || [ "$PDX_DESCRIPTION" = "" ]; then
    echo "PDX_DESCRIPTION env variable is not set or empty, using default"
    export PDX_DESCRIPTION="Uploaded automatically"
fi

echo "$PDX_DESCRIPTION" | sed 's/\r$//g' | xsel -b -i

sleep 5

echo "Debug images path: $DEBUG_IMAGES"
echo "Starting script..."

i=0
while sleep 2
do
    if compare_current_screen "$HOME/image_specimens/steam_guard_238_24_321_203.png" "238x24+321+203"; then
        echo "Get Steam Guard code..."
        if [ ! -z "$POP3_NO_SSL" ] && [ "$POP3_NO_SSL" != 0 ]; then
            POP3_NO_SSL="--no-ssl"
        else
            POP3_NO_SSL=""
        fi
        set +x
        STEAM_GUARD_CODE=$(timeout 610 python3 -u /home/steam/get_steam_guard.py "$POP3_ADDRESS" "$POP3_USER" "$POP3_PASSWORD" "$TIME_START" --port "$POP3_PORT" $POP3_NO_SSL)
        if [ "$?" = "0" ]; then
            xdotool mousemove 500 370
            xdotool click 1 mousemove 0 0
            xdotool type "$STEAM_GUARD_CODE"
            sleep 0.5
            xdotool key Return
            sleep 1
            break
        fi
        set -x
    elif [ "$i" = '60' ]; then
        echo "Saving current screen to $DEBUG_IMAGES/debug_screen_$img.png"
        sudo import -screen -window root $DEBUG_IMAGES/debug_screen_$img.png
        img=$((img+1))
        echo "Maximum amount of iterations reached. Could't login, so stopping."
        exit 1
    fi
    i=$((i+1))
done

i=0
while sleep 2
do
    if compare_current_screen "$HOME/image_specimens/steam_eula_92_24_674_524.png" "92x24+674+524"; then
        echo "Accept Steam EULA..."
        xdotool mousemove 715 535
        xdotool click 1 mousemove 0 0
        break
    elif [ "$i" = '15' ]; then
        echo "Saving current screen to $DEBUG_IMAGES/debug_screen_$img.png"
        sudo import -screen -window root $DEBUG_IMAGES/debug_screen_$img.png
        img=$((img+1))
        echo "Maximum amount of iterations reached, moving onto next step..."
        xdotool mousemove 715 535
        xdotool click 1 mousemove 0 0
        break
    fi
    i=$((i+1))
done

sleep 5

i=0
while sleep 2
do
    if compare_current_screen "$HOME/image_specimens/update_135_60_805_427.png" "135x60+805+427"; then
        echo "Accept update..."
        xdotool mousemove 840 470
        xdotool click 1 mousemove 0 0
    elif compare_current_screen "$HOME/image_specimens/update_135_60_805_427.png" "135x60+805+451"; then
        echo "Accept update..."
        xdotool mousemove 840 500
        xdotool click 1 mousemove 0 0
    elif compare_current_screen "$HOME/image_specimens/pending_cloud_uploads_220_23_660_463.png" "220x23+660+463"; then
        echo "Ignore pending cloud uploads..."
        xdotool mousemove 750 470
        xdotool click 1 mousemove 0 0
    elif compare_current_screen "$HOME/image_specimens/get_started_152_15_563_476.png" "152x15+563+476"; then
        echo "Get Started..."
        xdotool mousemove 640 480
        xdotool click 1 mousemove 0 0
        break
    elif [ "$i" = '600' ]; then
        echo "Saving current screen to $DEBUG_IMAGES/debug_screen_$img.png"
        sudo import -screen -window root $DEBUG_IMAGES/debug_screen_$img.png
        img=$((img+1))
        echo "Maximum amount of iterations reached, moving onto next step..."
        xdotool mousemove 640 480
        xdotool click 1 mousemove 0 0
        break
    fi
    i=$((i+1))
done

wait_until_screen_matches "$HOME/image_specimens/login_144_38_692_441.png" "144x38+692+441" '5'

echo "Login..."
xdotool mousemove 560 350
xdotool click 1 mousemove 0 0
xdotool type "$PDX_LOGIN"
sleep 0.5

echo "Password..."
xdotool key Tab sleep 0.1
xdotool type "$PDX_PASSWORD"
sleep 0.5
xdotool key Return

sleep 7

echo "Saving current screen to $DEBUG_IMAGES/debug_screen_$img.png"
sudo import -screen -window root $DEBUG_IMAGES/debug_screen_$img.png
img=$((img+1))

echo "Skip username generation..."
xdotool mousemove 1083 656
xdotool click 1 mousemove 0 0

xdotool mousemove 1122 80
xdotool click 1 mousemove 0 0

wait_until_screen_matches "$HOME/image_specimens/pdx_eula_280_26_500_140.png" "280x26+500+140" '5'

echo "Accept PDX EULA..."
xdotool mousemove 645 545
xdotool click 1 mousemove 0 0

wait_until_screen_matches "$HOME/image_specimens/play_45_15_618_272.png" "45x15+618+272" '5'

echo "Click on Mods..."
xdotool mousemove 618 396
sleep 0.1
xdotool click 1
sleep 0.1
xdotool mousemove 0 0

sleep 2

echo "Click on Mod Tools..."
i=0
ycoord=220
while sleep 2
do
    echo "wait_until_screen_matches $i "$HOME/image_specimens/create_mod_90_22_537_102.png" 90x22+537+102"
    if compare_current_screen "$HOME/image_specimens/create_mod_90_22_537_102.png" "90x22+537+102"; then
        sleep 2
        break
    elif [ "$i" = 20 ]; then
        echo "Maximum amount of iterations reached, moving onto next step..."
        break
    fi
    echo "xdotool mousemove 461 $ycoord click 1"
    xdotool mousemove 461 $ycoord click 1
    i=$((i+1))
    ycoord=$((ycoord+20))
done

echo "Click on Upload Mod..."
xdotool mousemove 700 107
xdotool click 1 mousemove 0 0

wait_until_screen_matches "$HOME/image_specimens/upload_a_mod_95_22_647_102.png" "95x22+647+102" '5'

xdotool mousemove 610 210
xdotool click 1 sleep 0.5 click 1 mousemove 0 0 sleep 0.5

echo "Click on Steam Workshop..."
xdotool mousemove 770 322
xdotool click 1 mousemove 0 0
sleep 0.5

echo "Type Description..."
xdotool mousemove 480 400
xdotool click 1 mousemove 0 0
xdotool type -- "$(xsel -bo | tr \\n \\r | sed s/\\r*\$//)"
sleep 1

echo "Click on Upload Mod..."
xdotool mousemove 485 615
xdotool click 1 mousemove 0 0

while sleep 5
do
    if compare_current_screen "$HOME/image_specimens/mod_upload_in_progress_26_26_626_130.png" "26x26+626+130"; then
        echo "Upload in progress..."
    elif compare_current_screen "$HOME/image_specimens/mod_upload_success_28_28_626_138.png" "28x28+626+138"; then
        echo "Mod upload success! Exiting..."
        sleep 1
        exit 0
    else
        echo "Unexpected screen doing mod upload, exiting with a non-zero exit code..."
        echo "Saving current screen to $DEBUG_IMAGES/debug_screen_$img.png"
        sudo import -screen -window root $DEBUG_IMAGES/debug_screen_$img.png
        img=$((img+1))
        sleep 1
        exit 1
    fi
done
