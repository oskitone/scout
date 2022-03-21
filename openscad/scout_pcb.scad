/* TODO: extract into common parts repo */
use <../../apc/openscad/pcb.scad>;

include <headphone_jack.scad>;
include <switch.scad>;

PCB_WIDTH = 177.292 - 32.004;
PCB_LENGTH = 124.968 - 80.518;
PCB_HEIGHT = 1.6;

PCB_KEY_PLOT = 2.54 * 3;

function _(xy, nudge = [0, 0]) = (
    [(xy.x + nudge.x - 32.004), -(xy.y - 123.444) + nudge.y]
);

// It's easier to magically nudge things around than reconcile KiCad's
// awkward non-zero-origin positioning.
MAGIC = .28;

PCB_BUTTON_POSITIONS = [
    _([170.942 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([163.322 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([155.702 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([148.082 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([140.462 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([125.222 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([117.602 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([109.982 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([102.362 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([94.742 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([87.122 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([79.502 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([64.262 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([56.642 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([49.022 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([41.402 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
    _([33.782 + 2.54 * .9, 121.92], [0, 2.54 * 1.9]),
];

PCB_HOLE_DIAMETER = 3.2;
PCB_HOLE_POSITIONS = [
    _([65.066, 107.696], [0, 2.54 / 2 + MAGIC]),
    _([78.26, 107.696], [0, 2.54 / 2 + MAGIC]),
    _([104.648, 107.696], [0, 2.54 / 2 + MAGIC]),
    _([131.036, 107.696], [0, 2.54 / 2 + MAGIC]),
    _([144.23, 107.696], [0, 2.54 / 2 + MAGIC]),
];

PCB_RELIEF_HOLE_DIAMETER = 3.5;
PCB_RELIEF_HOLE_POSITIONS = [
    _([74.168, 122.555], [0, 2.54 / 2 + MAGIC]),
    _([135.128, 122.555], [0, 2.54 / 2 + MAGIC]),
];

PCB_LED_Z = 3; // RGB LED pin footprint prevents it from resting directly on PCB
PCB_LED_POSITION = _([156.474, 86.706], [-2.54, 2.54 - MAGIC]);
PCB_POT_POSITION = _([172.824, 97.796], [-2.54, 7 + 2.54 / 2 + MAGIC]);
PCB_SWITCH_POSITION = _([34.544, 91.98], [0, -2.54]);

// https://www.digikey.com/en/products/detail/adam-tech/PH1RB-06-UA/9830592
PCB_UART_HEADER_POSITION = _([42.926, 88.773], [2.54 / -2, 2.54 / 2]);
PCB_UART_HEADER_WIDTH = 2.54 * 6;
PCB_UART_HEADER_HEIGHT = 2.5;
UART_HEADER_PIN_SIZE = .8;

PCB_HEADPHONE_JACK_POSITION = _(
    [138.176, 84.11],
    [HEADPHONE_JACK_WIDTH / -2, HEADPHONE_JACK_LENGTH / -2 - MAGIC]
);

LED_DIAMETER = 5.9;
LED_HEIGHT = 8.6;

PTV09A_POT_BASE_WIDTH = 10;
PTV09A_POT_BASE_HEIGHT = 6.8;
PTV09A_POT_ACTUATOR_DIAMETER = 6;
PTV09A_POT_ACTUATOR_BASE_DIAMETER = 6.9;
PTV09A_POT_ACTUATOR_BASE_HEIGHT = 2;
PTV09A_POT_ACTUATOR_HEIGHT = 20 - PTV09A_POT_BASE_HEIGHT;
PTV09A_POT_ACTUATOR_D_SHAFT_HEIGHT = 7;
PTV09A_POT_ACTUATOR_D_SHAFT_DEPTH = PTV09A_POT_ACTUATOR_DIAMETER - 4.5;

BUTTON_DIAMETER = 6;
BUTTON_HEIGHT = 6;

PCB_CIRCUITRY_CLEARANCE = 12;
PCB_PIN_CLEARANCE = 2;
PCB_FRONT_PIN_Y = 2;

module scout_pcb_holes(
    y,
    height = PCB_HEIGHT,
    diameter = PCB_HOLE_DIAMETER,
    diameter_bleed = 0,
    positions = PCB_HOLE_POSITIONS,
    include_relief_holes = true
) {
    e = .0343;

    for (xy = positions) {
        translate([xy.x, y != undef ? y : xy.y, -e]) {
            cylinder(
                d = diameter + diameter_bleed * 2,
                h = height + e * 2 + 3,
                $fn = 12
            );
        }
    }

    if (include_relief_holes) {
        scout_pcb_holes(
            y = y,
            height = height,
            diameter = PCB_RELIEF_HOLE_DIAMETER,
            diameter_bleed = diameter_bleed,
            positions = PCB_RELIEF_HOLE_POSITIONS,
            include_relief_holes = false
        );
    }
}

module scout_pcb(
    show_board = true,
    show_buttons = true,
    show_silkscreen = true,
    show_led = true,
    show_pot = true,
    show_switch = true,
    show_pcb_uart_header = true,
    show_headphone_jack = true,
    show_circuitry_clearance = true,

    switch_position = 0
) {
    e = .0143;
    silkscreen_height = e;

    if (show_board) {
        difference() {
            union() {
                color("purple") cube([PCB_WIDTH, PCB_LENGTH, PCB_HEIGHT]);

                if (show_silkscreen) {
                    translate([0, 0, PCB_HEIGHT - e]) {
                        linear_extrude(silkscreen_height + e) {
                            offset(.1) {
                                import("../kicad/scout/scout-brd.svg");
                            }
                        }
                    }
                }
            }

            scout_pcb_holes();

            translate([9.4, 40.4, -e]) cube([15.8, 10, PCB_HEIGHT + e * 2]);
            translate([103.2, 43.4, -e]) cube([6, 10, PCB_HEIGHT + e * 2]);
        }
    }

    if (show_buttons) {
        for (xy = PCB_BUTTON_POSITIONS) {
            translate([xy.x, xy.y, PCB_HEIGHT - e]) {
                % cylinder(
                    h = BUTTON_HEIGHT + e,
                    d = BUTTON_DIAMETER
                );
            }
        }
    }

    module _translate(position, z = PCB_HEIGHT - e) {
        translate([position.x, position.y, z]) {
            children();
        }
    }

    if (show_led) {
        _translate(PCB_LED_POSITION, PCB_LED_Z) {
            % cylinder(
                d = LED_DIAMETER,
                h = LED_HEIGHT + e,
                $fn = 12
            );
        }
    }

    if (show_pot) {
        _translate(PCB_POT_POSITION) {
            % pot();
        }
    }

    if (show_switch) {
        _translate(PCB_SWITCH_POSITION) {
            % switch(switch_position);
        }
    }

    if (show_pcb_uart_header) {
        x = 2.54 / 2 - UART_HEADER_PIN_SIZE / 2;
        z = PCB_UART_HEADER_HEIGHT / 2 - UART_HEADER_PIN_SIZE / 2;

        _translate(PCB_UART_HEADER_POSITION) {
            translate([0, 1.8, 0]) {
                % cube([
                    PCB_UART_HEADER_WIDTH,
                    PCB_UART_HEADER_HEIGHT,
                    PCB_UART_HEADER_HEIGHT
                ]);
            }

            for (i = [0 : 5]) {
                translate([x + i * 2.54, 0, z]) {
                    % cube([UART_HEADER_PIN_SIZE, 10.25, UART_HEADER_PIN_SIZE]);
                }
            }
        }
    }

    if (show_headphone_jack) {
        _translate(PCB_HEADPHONE_JACK_POSITION) {
            % headphone_jack();
        }
    }

    if (show_circuitry_clearance) {
        length = PCB_LENGTH - PCB_HOLE_POSITIONS[0].y - KEYS_MOUNT_LENGTH / 2;

        translate([0, PCB_LENGTH - length, PCB_HEIGHT - e]) {
            % cube([PCB_WIDTH, length, PCB_CIRCUITRY_CLEARANCE + e]);
        }

        translate([0, PCB_FRONT_PIN_Y, -PCB_PIN_CLEARANCE]) {
            % cube([
                PCB_WIDTH,
                PCB_LENGTH - PCB_FRONT_PIN_Y,
                PCB_PIN_CLEARANCE + e
            ]);
        }

    }
}
