#!/bin/bash

{

# Exit on error
set -o errexit
set -o errtrace

avrdude_folder="$HOME/Library/Arduino15/packages/arduino"
avrdude="$avrdude_folder/tools/avrdude/6.3.0-arduino17/bin/avrdude"
avrdude_config="$avrdude_folder/tools/avrdude/6.3.0-arduino17/etc/avrdude.conf"

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
        -U"flash:w:$avrdude_folder/hardware/avr/1.8.3/bootloaders/optiboot/optiboot_atmega328.hex:i" \
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
        -Uflash:w:/var/folders/br/87phc45d2szgdhd23089g7m40000gn/T/arduino_build_95463/scout.ino.hex:i
}

function pause() {
    read -n1 -rs
}

while true; do
    burn_bootloader_using_programmer
    upload_program_using_uart_with_adafruit_cable

    echo
    echo "Done! Press any key to burn another chip or CTRL+C to quit."
    pause

    echo
done

}
