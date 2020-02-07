#!/bin/bash

img=0

# set -x
# $1 = filename
# $2 = crop arguments
compare_current_screen () {
    rm $HOME/temp.png 2> /dev/null
    import -screen -window root "$HOME/temp.png"
    sudo cp -f "$HOME/temp.png" "$DEBUG_IMAGES/temp_uncropped.png"
    mogrify -crop $2 "$HOME/temp.png"
    sudo cp -f "$HOME/temp.png" "$DEBUG_IMAGES/temp_cropped.png"
    compare_out=$(compare -metric PSNR "$HOME/temp.png" $1 /dev/null 2>&1)
    echo "Compare current screen at $2 to $1: $compare_out"
    #rm $HOME/temp.png
    if [ "$compare_out" = "0" ]; then
        return 0
    else
        return 1
    fi
}

# $1 = filename
# $2 = crop arguments
# $3 = max_iters
wait_until_screen_matches () {
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
    xsel -b -i < "$HOME/description.txt"
elif [ -z "$PDX_DESCRIPTION" ] || [ "$PDX_DESCRIPTION" = "" ]; then
    echo "PDX_DESCRIPTION env variable is not set, using default"
    export PDX_DESCRIPTION="Uploaded automatically"
    echo "$PDX_DESCRIPTION" | xsel -b -i
else
    echo "$PDX_DESCRIPTION" | xsel -b -i
fi

sleep 1

echo "Starting script..."

wait_until_screen_matches "$HOME/image_specimens/steam_eula_500_460_390_130.png" "500x460+390+130" '3600'
echo "Accept Steam EULA..."
xdotool mousemove 660 555
xdotool click 1 mousemove 0 0

i=0
while sleep 2
do
    if compare_current_screen "$HOME/image_specimens/update_135_60_805_427.png" "135x60+805+427"; then
        echo "Accept update..."
        xdotool mousemove 840 470
        xdotool click 1 mousemove 0 0
    elif compare_current_screen "$HOME/image_specimens/get_started_152_15_563_476.png" "152x15+563+476"; then
        echo "Get Started..."
        xdotool mousemove 640 480
        xdotool click 1 mousemove 0 0
        break
    elif [ "$i" = '3600' ]; then
        echo "Saving current screen to $DEBUG_IMAGES/debug_screen_$img.png"
        sudo import -screen -window root $DEBUG_IMAGES/debug_screen_$img.png
        img=$((img+1))
        echo "Maximum amount of iterations reached, moving onto next step..."
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

echo "Skip username generation..."
xdotool mousemove 1083 656
xdotool click 1 mousemove 0 0

wait_until_screen_matches "$HOME/image_specimens/pdx_eula_280_26_500_140.png" "280x26+500+140" '5'

echo "Accept PDX EULA..."
xdotool mousemove 645 545
xdotool click 1 mousemove 0 0

wait_until_screen_matches "$HOME/image_specimens/play_45_15_618_272.png" "45x15+618+272" '5'

echo "Click on Mods..."
xdotool mousemove 610 396
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
    elif [ "$i" = 13 ]; then
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