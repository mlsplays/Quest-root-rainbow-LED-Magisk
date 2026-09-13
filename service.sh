#!/system/bin/sh

# I dont know why this exsists 

RED_LED="/sys/class/leds/red/brightness"
GREEN_LED="/sys/class/leds/green/brightness"
BLUE_LED="/sys/class/leds/blue/brightness"

set_rgb() {
    echo "$1" > "$RED_LED" 2>/dev/null
    echo "$2" > "$GREEN_LED" 2>/dev/null
    echo "$3" > "$BLUE_LED" 2>/dev/null
}

clamp() {
    if [ "$1" -lt 0 ]; then echo 0
    elif [ "$1" -gt 255 ]; then echo 255
    else echo "$1"
    fi
}


is_awake() {
    dumpsys power 2>/dev/null | grep -q "mWakefulness=Awake"
}


rgb_cycle() {
    while is_awake; do
        for i in $(seq 0 5 255); do
            set_rgb $(clamp $((255 - i))) $(clamp $i) 0    # Red to Green
            sleep 0.005
        done
        is_awake || break

        for i in $(seq 0 5 255); do
            set_rgb 0 $(clamp $((255 - i))) $(clamp $i)    # Green to Blue
            sleep 0.005
        done
        is_awake || break

        for i in $(seq 0 5 255); do
            set_rgb $(clamp $i) 0 $(clamp $((255 - i)))    # Blue to Red
            sleep 0.005
        done
    done
}

main_loop() {
 
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done

    while true; do
        if is_awake; then
            rgb_cycle
            set_rgb 0 0 0
        fi
        sleep 1
    done
}


main_loop &
