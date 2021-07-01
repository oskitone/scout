/* TODO: extract into common parts repo */
use <../../apc/openscad/rib_cavities.scad>;

include <enclosure.scad>;
include <switch.scad>;

ACCESSORY_FILLET = 1;
DEFAULT_TOLERANCE = .1;

SWITCH_CLUTCH_GRIP_LENGTH = 10;
SWITCH_CLUTCH_GRIP_HEIGHT = 7;

module switch_clutch(
    position = 0,

    web_available_width = 2,
    web_length_extension = 1,

    switch_z = 0,
    enclosure_height = 0,
    vertical_clearance = DEFAULT_DFM_LAYER_HEIGHT,

    x_clearance = .2,

    grip_length = SWITCH_CLUTCH_GRIP_LENGTH,
    grip_height = SWITCH_CLUTCH_GRIP_HEIGHT,

    fillet = ACCESSORY_FILLET,
    side_overexposure = ENCLOSURE_SIDE_OVEREXPOSURE,
    tolerance = DEFAULT_TOLERANCE,

    outer_color = undef,
    cavity_color = undef,

    show_dfm = false,
    quick_preview = true
) {
    e = .0592;

    switch_center_z = switch_z + SWITCH_BASE_HEIGHT / 2;
    web_height_lower_extension = switch_center_z - grip_height / 2
        - ENCLOSURE_FLOOR_CEILING - vertical_clearance;
    web_height_upper_extension = enclosure_height - switch_center_z
        - ENCLOSURE_FLOOR_CEILING * 2
        - ENCLOSURE_FLOOR_CEILING - vertical_clearance;
    web_x_gap = tolerance * 2 + x_clearance;
    web_width = web_available_width - web_x_gap * 2;
    web_length = SWITCH_CLUTCH_GRIP_LENGTH + web_length_extension * 2;
    web_height = grip_height
        + web_height_lower_extension + web_height_upper_extension;

    exposed_grip_width = ENCLOSURE_WALL + side_overexposure
        + (web_available_width - web_width);

    dfm_support_x = -web_width - exposed_grip_width + fillet;
    dfm_support_y = (web_length - grip_length) / 2;

    module _exposed_grip() {
        x = -web_width - exposed_grip_width;
        y = (web_length - grip_length) / 2;

        translate([x, y, web_height_lower_extension]) {
            difference() {
                color(outer_color) {
                    rounded_cube(
                        [
                            exposed_grip_width + fillet + e,
                            grip_length,
                            grip_height
                        ],
                        quick_preview ? 0 : fillet,
                        $fn = LOFI_ROUNDING
                    );
                }

                color(cavity_color) {
                    rib_cavities(
                        length = grip_length,
                        height = grip_height
                    );
                }
            }
        }
    }

    module _web() {
        translate([-web_width, 0, 0]) {
            cube([web_width - tolerance, web_length, web_height]);
        }
    }

    module _actuator_cavity() {
        width = SWITCH_ACTUATOR_WIDTH - web_x_gap + tolerance;
        length = SWITCH_ACTUATOR_LENGTH + tolerance * 2;

        translate([-width, (web_length - length) / 2, -e]) {
            cube([width + e, length, web_height + e * 2]);
        }
    }

    module _dfm_support() {
        height = web_height_lower_extension - DEFAULT_DFM_LAYER_HEIGHT;

        translate([dfm_support_x, dfm_support_y, 0]) {
            cube([BREAKAWAY_SUPPORT_DEPTH, grip_length, height]);
        }
    }

    module _dfm_cavity() {
        x = dfm_support_x + BREAKAWAY_SUPPORT_DEPTH;
        y = dfm_support_y + BREAKAWAY_SUPPORT_DEPTH + fillet;
        z = web_height_lower_extension;

        width = exposed_grip_width - fillet - BREAKAWAY_SUPPORT_DEPTH + e;
        length = grip_length - BREAKAWAY_SUPPORT_DEPTH * 2 - fillet * 2;

        translate([x, y, z - e]) {
            cube([width, length, DEFAULT_DFM_LAYER_HEIGHT + e]);
        }
    }

    translate([
        -SWITCH_ORIGIN.x - web_x_gap,
        -SWITCH_ORIGIN.y
            + SWITCH_BASE_LENGTH / 2
            - grip_length / 2
            + SWITCH_ACTUATOR_TRAVEL / 2
            - (1 - position) * SWITCH_ACTUATOR_TRAVEL
            - web_length_extension,
        -web_height_lower_extension - (grip_height - SWITCH_BASE_HEIGHT) / 2
    ]) {
        difference() {
            union() {
                _exposed_grip();

                color(outer_color) {
                    _web();

                    if (show_dfm) {
                        _dfm_support();
                    }
                }
            }

            color(cavity_color) {
                _actuator_cavity();
            }

            if (show_dfm) {
                _dfm_cavity();
            }
        }
    }
}

* group() {
switch_clutch(abs($t - .5) * 2);
% switch(abs($t - .5) * 2);
}
