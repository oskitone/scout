#!/bin/bash

{

# Exit on error
set -o errexit
set -o errtrace

avrdude_folder="$HOME/Library/Arduino15/packages/arduino"
avrdude="$avrdude_folder/tools/avrdude/6.3.0-arduino17/bin/avrdude"
avrdude_config="$avrdude_folder/tools/avrdude/6.3.0-arduino17/etc/avrdude.conf"

optiboot="$avrdude_folder/hardware/avr/1.8.3/bootloaders/optiboot/optiboot_atmega328.hex"
scout_hex="build/scout.ino.hex"

function burn_bootloader_using_programmer() {
    $avrdude \
        -C"$avrdude_config" \
        -v \
        -patmega328p \
        -cusbtiny \
        -e \
        -Ulock:w:0x3F:m \
        -Uefuse:w:0xFD:m \
        -Uhfuse:w:0xDE:m \
        -Ulfuse:w:0xFF:m

    $avrdude \
        -C"$avrdude_config" \
        -v \
        -patmega328p \
        -cusbtiny \
        -U"flash:w:$optiboot:i" \
        -Ulock:w:0x0F:m
}

function upload_program_using_uart_with_adafruit_cable() {
    $avrdude \
        -C"$avrdude_config" \
        -v \
        -patmega328p \
        -carduino \
        -P/dev/cu.usbserial-AB0LJLX7 \
        -b115200 \
        -D \
        -U"flash:w:$scout_hex:i"
}

function pause() {
    read -n1 -rs
}

function very_file_exists() {
    if [ ! -f "$1" ]; then
        echo "ERROR: $1 does not exist"
        exit 1
    fi
}

function compile_hex() {
    mkdir -pv build

    arduino-cli compile \
        --fqbn arduino:avr:uno \
        --build-path=$PWD/build \
        arduino/scout
}

compile_hex

very_file_exists "$optiboot"
very_file_exists "$scout_hex"

while true; do
    burn_bootloader_using_programmer
    upload_program_using_uart_with_adafruit_cable

    echo
    echo "Done! Press any key to burn another chip or CTRL+C to quit."
    pause

    echo
done

}
