/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/speaker.scad>;

include <enclosure_bottom.scad>;
include <keyboard_matrix_pcb.scad>;
include <keys.scad>;
include <mounting_rail.scad>;
include <utils.scad>;

peripheral_clearance = 5;

PCB_X = ENCLOSURE_WALL + offset / 2 + key_gutter;
PCB_Y = key_length - PCB_LENGTH + mount_length + ENCLOSURE_WALL + key_gutter;
PCB_Z = ENCLOSURE_FLOOR_CEILING + 2;

BREADBOARD_WIDTH = 35;
BREADBOARD_LENGTH = 50;

ARDUINO_WIDTH = 2.1 * 25.4;
ARDUINO_LENGTH = 2.7 * 25.4;

// https://www.taydaelectronics.com/loud-speaker-8-ohm-3w.html
SPEAKER_DIAMETER = 41.1;
SPEAKER_HEIGHT = 20;
SPEAKER_LENGTH = 71;

peripheral_length = max(BREADBOARD_LENGTH, ARDUINO_LENGTH, SPEAKER_LENGTH);

ENCLOSURE_WIDTH = PCB_X * 2 + PCB_WIDTH;
ENCLOSURE_LENGTH =
    ENCLOSURE_WALL + key_gutter + key_length + mount_length
    + peripheral_length + peripheral_clearance * 2;

DEFAULT_TOLERANCE = .1;

module keyboard_matrix_playground(
    show_keys = true,
    show_mounting_rail = true,
    show_pcb = true,
    show_peripherals = true,
    show_enclosure_bottom = true,

    tolerance = 0,
    quick_preview = true
) {
    if (show_keys) {
        keys_with_nut_locking_mount(
            tolerance = tolerance,
            quick_preview = quick_preview
        );
    }

    if (show_pcb) {
        e_translate([PCB_X, PCB_Y, PCB_Z]) {
            keyboard_matrix_pcb();
        }
    }

    if (show_enclosure_bottom) {
        enclosure_bottom();
    }

    if (show_mounting_rail) {
        mounting_rail_with_header_cavity();
    }

    if (show_peripherals) {
        y = PCB_Y + PCB_LENGTH - mount_length + mount_length
            + peripheral_clearance;
        z = ENCLOSURE_FLOOR_CEILING;

        height = 20;

        e_translate([peripheral_clearance, y, z]) {
            % cube([ARDUINO_WIDTH, ARDUINO_LENGTH, height]);
        }

        e_translate([peripheral_clearance * 2 + ARDUINO_WIDTH, y, z]) {
            % cube([BREADBOARD_WIDTH, BREADBOARD_LENGTH, height]);
        }

        translate([
            ENCLOSURE_WIDTH - SPEAKER_DIAMETER / 2 - ENCLOSURE_WALL,
            ENCLOSURE_LENGTH - peripheral_length / 2 - peripheral_clearance,
            z
        ]) {
            % speaker(SPEAKER_HEIGHT);
        }
    }
}

SHOW_KEYS = true;
SHOW_MOUNTING_RAIL = true;
SHOW_PCB = true;
SHOW_PERIPHERALS = true;
SHOW_ENCLOSURE_BOTTOM = true;

keyboard_matrix_playground(
    show_keys = SHOW_KEYS,
    show_mounting_rail = SHOW_MOUNTING_RAIL,
    show_pcb = SHOW_PCB,
    show_peripherals = SHOW_PERIPHERALS,
    show_enclosure_bottom = SHOW_ENCLOSURE_BOTTOM,

    tolerance = DEFAULT_TOLERANCE,
    quick_preview = $preview
);
