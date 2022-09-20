#!/bin/bash

{

# Exit on error
set -o errexit
set -o errtrace

use_uart_for_upload=true

avrdude_folder="$HOME/Library/Arduino15/packages/arduino"
avrdude="$avrdude_folder/tools/avrdude/6.3.0-arduino17/bin/avrdude"
avrdude_config="$avrdude_folder/tools/avrdude/6.3.0-arduino17/etc/avrdude.conf"

optiboot="$avrdude_folder/hardware/avr/1.8.3/bootloaders/optiboot/optiboot_atmega328.hex"
scout_hex="build/scout.ino.hex"
scout_hex_with_bootloader="build/scout.ino.with_bootloader.hex"

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

function upload_program_with_bootloader_using_programmer() {
    $avrdude \
        -C"$avrdude_config" \
        -v \
        -patmega328p \
        -cusbtiny \
        -U"flash:w:$scout_hex_with_bootloader:i"
}

function upload_program_using_adafruit_cable() {
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

function wait_for_space_key() {
    read -s -d ' '
}

function verify_file_exists() {
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

verify_file_exists "$optiboot"
verify_file_exists "$scout_hex"

while true; do
    start=`date +%s`

    if $use_uart_for_upload; then
        burn_bootloader_using_programmer
        upload_program_using_adafruit_cable
    else
        upload_program_with_bootloader_using_programmer
    fi

    end=`date +%s`
    runtime=$((end-start))

    echo
    echo "Done! Finished in $runtime seconds."
    echo "Press SPACE to burn another chip or CTRL+C to quit."
    wait_for_space_key

    echo
done

}
