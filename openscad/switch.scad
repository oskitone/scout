// https://www.ckswitches.com/media/1428/os.pdf
// OS102011MA1QN1

SWITCH_BASE_WIDTH = 4.4;
SWITCH_BASE_LENGTH = 8.6;
SWITCH_BASE_HEIGHT = 4.7;
SWITCH_ACTUATOR_WIDTH = 4;
SWITCH_ACTUATOR_LENGTH = 2;
SWITCH_ACTUATOR_HEIGHT = 2; // TODO: measure
SWITCH_ACTUATOR_TRAVEL = 2;
SWITCH_ORIGIN = [SWITCH_BASE_WIDTH / 2, 6.36];

// Assumes inside of SWITCH_ORIGIN
function get_switch_actuator_y(position = 0) = (
    (SWITCH_BASE_LENGTH - SWITCH_ACTUATOR_LENGTH) / 2
    - SWITCH_ACTUATOR_TRAVEL / 2
    + SWITCH_ACTUATOR_TRAVEL * position
);

module switch(position = 0) {
    e = .05234;

    translate([-SWITCH_ORIGIN.x, -SWITCH_ORIGIN.y, 0]) {
        cube([
            SWITCH_BASE_WIDTH,
            SWITCH_BASE_LENGTH,
            SWITCH_BASE_HEIGHT
        ]);

        translate([
            -SWITCH_ACTUATOR_WIDTH,
            get_switch_actuator_y(position),
            (SWITCH_BASE_HEIGHT - SWITCH_ACTUATOR_HEIGHT) / 2
        ]) {
            cube([
                SWITCH_ACTUATOR_WIDTH + e,
                SWITCH_ACTUATOR_LENGTH,
                SWITCH_ACTUATOR_HEIGHT + e
            ]);
        }
    }
}
