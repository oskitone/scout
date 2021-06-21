include <enclosure.scad>;
include <switch.scad>;

ACCESSORY_FILLET = 1;
DEFAULT_TOLERANCE = .1;

SWITCH_CLUTCH_GRIP_LENGTH = 10;
SWITCH_CLUTCH_GRIP_HEIGHT = 7;

module switch_clutch(
    position = 0,

    grip_length = SWITCH_CLUTCH_GRIP_LENGTH,
    grip_height = SWITCH_CLUTCH_GRIP_HEIGHT,

    web_available_width = 2,
    web_length_extension = 1,
    web_height_lower_extension = 5,
    web_height_upper_extension = 2,

    x_clearance = .2,

    fillet = ACCESSORY_FILLET,
    side_overexposure = ENCLOSURE_SIDE_OVEREXPOSURE,
    tolerance = DEFAULT_TOLERANCE,
    floor_ceiling = ENCLOSURE_FLOOR_CEILING,

    show_dfm = true // TODO: use
) {
    e = .0592;

    web_gap = tolerance * 2 + x_clearance;

    web_width = web_available_width - web_gap * 2;
    web_length = SWITCH_BASE_LENGTH
        + web_length_extension * 2 + SWITCH_ACTUATOR_TRAVEL;
    web_height = grip_height
        + web_height_lower_extension + web_height_upper_extension;

    // TODO: fillet and rib
    module _exposed_grip() {
        width = ENCLOSURE_WALL + side_overexposure
            + (web_available_width - web_width);
        x = -web_width - width;
        y = (web_length - grip_length) / 2;

        translate([x, y, web_height_lower_extension]) {
            cube([width + e, grip_length, grip_height]);
        }
    }

    module _web() {
        translate([-web_width, 0, 0]) {
            cube([web_width - tolerance, web_length, web_height]);
        }
    }

    module _actuator_cavity() {
        width = SWITCH_ACTUATOR_WIDTH + tolerance;
        length = SWITCH_ACTUATOR_LENGTH + tolerance * 2;

        translate([-width, (web_length - length) / 2, -e]) {
            cube([width + e, length, web_height + e * 2]);
        }
    }

    // TODO
    module _skirt() {}

    translate([
        -SWITCH_ORIGIN.x - web_gap,
        -SWITCH_ORIGIN.y - SWITCH_ACTUATOR_LENGTH
            + position * SWITCH_ACTUATOR_TRAVEL
            - web_length_extension,
        -web_height_lower_extension - (grip_height - SWITCH_BASE_HEIGHT) / 2
    ]) {
        difference() {
            union() {
                _exposed_grip();
                _web();
            }

            _actuator_cavity();
        }
    }
}

* group() {
switch_clutch(abs($t - .5) * 2);
% switch(abs($t - .5) * 2);
}
