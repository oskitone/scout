#!/usr/bin/env bash

{

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

arduino-cli compile --fqbn arduino:avr:uno scout && \
    arduino-cli upload -p /dev/cu.usbmodem1441201 --fqbn arduino:avr:uno scout

}
