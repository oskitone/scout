include <enclosure.scad>;
include <switch.scad>;

ACCESSORY_FILLET = 1;
DEFAULT_TOLERANCE = .1;

module switch_clutch(
    position = 0,

    grip_length = SWITCH_BASE_LENGTH,

    web_width = 2,
    web_length_extension = 2,

    fillet = ACCESSORY_FILLET,
    side_overexposure = ENCLOSURE_SIDE_OVEREXPOSURE,
    tolerance = DEFAULT_TOLERANCE,
    floor_ceiling = ENCLOSURE_FLOOR_CEILING,
    show_dfm = true
) {
    e = .0592;

    web_length = SWITCH_BASE_LENGTH
        + web_length_extension * 2 + SWITCH_ACTUATOR_TRAVEL;
    height = SWITCH_BASE_HEIGHT;

    // TODO: fillet and rib
    module _exposed_grip() {
        width = ENCLOSURE_WALL + side_overexposure;
        x = -web_width - width;
        y = SWITCH_ACTUATOR_TRAVEL / -2;

        translate([x, y, 0]) {
            cube([width + e, grip_length, height]);
        }
    }

    module _web() {
        y = -(web_length_extension + SWITCH_ACTUATOR_TRAVEL);

        translate([-web_width, y, 0]) {
            cube([web_width - tolerance, web_length, height]);
        }
    }

    // TODO: parameterize top vs bottom
    module _actuator_cavity() {
        width = SWITCH_ACTUATOR_WIDTH + tolerance;
        length = SWITCH_ACTUATOR_LENGTH + tolerance * 2;

        x = -width;
        y = (SWITCH_BASE_LENGTH - SWITCH_ACTUATOR_LENGTH) / 2
            - SWITCH_ACTUATOR_TRAVEL / 2 - tolerance;
        z = (SWITCH_BASE_HEIGHT - SWITCH_ACTUATOR_HEIGHT) / 2 - e;

        translate([x, y, z]) {
            cube([width + e, length, height - z + e]);
        }
    }

    // TODO
    module _skirt() {}

    translate([
        -SWITCH_ORIGIN.x,
        -SWITCH_ORIGIN.y + position * SWITCH_ACTUATOR_TRAVEL,
        0
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

/* switch_clutch(abs($t - .5) * 2);
% switch(abs($t - .5) * 2); */
