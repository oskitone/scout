#!/usr/bin/env bash

{

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

# TODO: get dynamic device location

arduino-cli compile --fqbn arduino:avr:uno arduino/scout && \
    arduino-cli upload -p /dev/cu.usbmodem142201 --fqbn arduino:avr:uno arduino/scout

}
