use <enclosure_engraving.scad>;

/* TODO: extract */
ENCLOSURE_WALL = 2.4;
ENCLOSURE_FLOOR_CEILING = 1.8;
ENCLOSURE_INNER_WALL = 1.2;

ENCLOSURE_TO_PCB_CLEARANCE = 2;

module _enclosure_stub(
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

    width = dimensions.x;
    length = dimensions.y;
    height = dimensions.z;

    module _keys_exposure() {
        translate([
            keys_position.x - key_gutter,
            -e,
            height - keys_cavity_height
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
            enclosure_height = height
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
            enclosure_height = height
        );
    }

    module _lightpipe_exposure() {
        translate([
            lightpipe_position.x - tolerance,
            lightpipe_position.y,
            height - ENCLOSURE_FLOOR_CEILING - e
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
                    h = height
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
                enclosure_height = height
            );
        }
    }

    difference() {
        color(outer_color) {
            rounded_cube(
                [width, length, height],
                radius = quick_preview ? 0 : 2,
                $fn = 24
            );
        }

        color(cavity_color) {
            _keys_exposure();
            _branding();
            _lightpipe_exposure();
            _knob_exposure();

            translate([
                ENCLOSURE_WALL, ENCLOSURE_WALL, ENCLOSURE_FLOOR_CEILING
            ]) {
                cube([
                    width - ENCLOSURE_WALL * 2,
                    length - ENCLOSURE_WALL * 2,
                    height - ENCLOSURE_FLOOR_CEILING * 2
                ]);
            }
        }
    }
}
