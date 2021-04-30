// TODO: extract parts to common repo
use <../../poly555/openscad/lib/enclosure.scad>;

use <enclosure_engraving.scad>;

/* TODO: extract */
ENCLOSURE_WALL = 2.4;
ENCLOSURE_FLOOR_CEILING = 1.8;
ENCLOSURE_INNER_WALL = 1.2;

ENCLOSURE_TO_PCB_CLEARANCE = 2;

ENCLOSURE_FILLET = 2;

DEFAULT_ROUNDING = $preview ? undef : 24;

module enclosure(
    show_top = true,
    show_bottom = true,

    dimensions = [],

    keys_cavity_height,
    keys_position = [],
    key_gutter,
    keys_full_width,

    branding_length,
    branding_position = [],

    label_distance,

    lightpipe_position = [],
    lightpipe_dimensions = [],

    knob_radius,
    knob_position,

    pot_label_text_size = 3.2,
    pot_label_length = 5,

    tolerance = 0,

    outer_color = "#FF69B4",
    cavity_color = "#cc5490",

    quick_preview = true
) {
    e = .0345;

    vertical_clearance = 1;
    xy_clearance = 1;

    top_height = dimensions.z / 2;
    bottom_height = dimensions.z / 2;

    module _half(
        _height,
        lip,
        quick_preview = true
    ) {
        enclosure_half(
            width = dimensions.x,
            length = dimensions.y,
            height = _height,
            wall = ENCLOSURE_WALL,
            floor_ceiling = ENCLOSURE_FLOOR_CEILING,
            add_lip = lip,
            remove_lip = !lip,
            fillet = ENCLOSURE_FILLET,
            tolerance = DEFAULT_TOLERANCE,
            $fn = DEFAULT_ROUNDING
        );
    }

    module _keys_exposure() {
        translate([
            keys_position.x - key_gutter,
            -e,
            dimensions.z - keys_cavity_height
        ]) {
            cube([
                keys_full_width + key_gutter * 2,
                keys_position.y + key_length + tolerance * 2,
                keys_cavity_height + e
            ]);
        }
    }

    module _branding() {
        enclosure_engraving(
            string = "SCOUT",
            size = branding_length / 2,
            position = [
                branding_position.x,
                branding_position.y
            ],
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        // TODO: swap for proper branding
        enclosure_engraving(
            string = "OSKITONE",
            font = "Work Sans:style=Black",
            size = branding_length / 2 - label_distance,
            position = [
                branding_position.x,
                branding_position.y + branding_length / 2 + label_distance
            ],
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );
    }

    module _lightpipe_exposure() {
        translate([
            lightpipe_position.x - tolerance,
            lightpipe_position.y,
            dimensions.z - ENCLOSURE_FLOOR_CEILING - e
        ]) {
            cube([
                lightpipe_dimensions.x + tolerance * 2,
                lightpipe_dimensions.y,
                ENCLOSURE_FLOOR_CEILING + e * 2
            ]);
        }
    }

    module _knob_exposure() {
        translate([knob_position.x, knob_position.y, 0]) {
            translate([0, 0, knob_position.z - vertical_clearance]) {
                cylinder(
                    r = knob_radius + xy_clearance + tolerance,
                    h = dimensions.z
                );
            }

            enclosure_engraving(
                string = "VOL",
                size = pot_label_text_size,
                center = true,
                position = [
                    0,
                    -knob_radius - pot_label_length / 2 - label_distance
                ],
                placard = [knob_radius * 2, pot_label_length],
                quick_preview = quick_preview,
                enclosure_height = dimensions.z
            );
        }
    }

    if (show_top || show_bottom) {
        difference() {
            color(outer_color) {
                if (show_bottom) {
                    _half(top_height, lip = true);
                }

                if (show_top) {
                    translate([0, 0, dimensions.z]) {
                        mirror([0, 0, 1]) {
                            _half(bottom_height, lip = false);
                        }
                    }
                }
            }

            color(cavity_color) {
                _keys_exposure();
                _branding();
                _lightpipe_exposure();
                _knob_exposure();
            }
        }
    }
}
