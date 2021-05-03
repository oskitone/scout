// TODO: extract parts to common repo
use <../../poly555/openscad/lib/enclosure.scad>;
use <../../poly555/openscad/lib/screw_head_exposures.scad>;
use <../../poly555/openscad/lib/switch.scad>;

use <../../apc/openscad/floating_hole_cavity.scad>;

use <enclosure_engraving.scad>;
include <keys.scad>;
include <pcb_fixtures.scad>;

/* TODO: extract */
ENCLOSURE_WALL = 2.4;
ENCLOSURE_FLOOR_CEILING = 1.8;
ENCLOSURE_INNER_WALL = 1.2;
LIP_BOX_DEFAULT_LIP_HEIGHT = 3;

ENCLOSURE_TO_PCB_CLEARANCE = 2;

ENCLOSURE_FILLET = 2;

DEFAULT_ROUNDING = $preview ? undef : 24;
HIDEF_ROUNDING = $preview ? undef : 120;

module enclosure(
    show_top = true,
    show_bottom = true,

    dimensions = [],

    pcb_position = [],

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
    knob_position = [],
    knob_vertical_clearance = 0,

    speaker_position = [],

    batteries_position = [],

    label_text_size = 3.2,
    label_length = 5,

    tolerance = 0,

    outer_color = "#FF69B4",
    cavity_color = "#cc5490",

    quick_preview = true
) {
    e = .0345;

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
            keys_position.x - key_gutter + e,
            -e,
            dimensions.z - keys_cavity_height
        ]) {
            cube([
                keys_full_width + key_gutter * 2 - e * 2,
                keys_position.y + key_length + tolerance * 2,
                keys_cavity_height + e
            ]);
        }
    }

    module _branding() {
        enclosure_engraving(
            string = "SCOUT",
            size = branding_length / 2,
            center = false,
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
            center = false,
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

    module _knob_exposure(
        cavity,
        xy_clearance = 1
    ) {
        cavity_z = knob_position.z - knob_vertical_clearance;
        cavity_height = dimensions.z - cavity_z + e;
        cavity_diameter = (knob_radius + xy_clearance + tolerance) * 2;

        well_z = cavity_z - ENCLOSURE_FLOOR_CEILING;
        well_height = dimensions.z - well_z - ENCLOSURE_FLOOR_CEILING + e;
        well_diameter = cavity_diameter + ENCLOSURE_INNER_WALL;

        translate([knob_position.x, knob_position.y, 0]) {
            translate([0, 0, cavity ? cavity_z : well_z]) {
                cylinder(
                    d = cavity ? cavity_diameter : well_diameter,
                    h = cavity ? cavity_height : well_height
                );
            }

            if (cavity) {
                diameter = PTV09A_POT_ACTUATOR_DIAMETER + tolerance * 2;

                translate([0, 0, well_z + ENCLOSURE_FLOOR_CEILING]) {
                    floating_hole_cavity(
                        diameter,
                        cavity_diameter
                    );
                }

                translate([0, 0, well_z - e]) {
                    cylinder(
                        d = diameter,
                        h = ENCLOSURE_FLOOR_CEILING + e * 2
                    );
                }

                enclosure_engraving(
                    string = "VOL",
                    size = label_text_size,
                    position = [
                        0,
                        -knob_radius - label_length / 2 - label_distance
                    ],
                    placard = [knob_radius * 2, label_length],
                    quick_preview = quick_preview,
                    enclosure_height = dimensions.z
                );
            }
        }
    }

    module _switch_exposure(cavity = false) {
        exposure_height = pcb_position.z - SWITCH_BASE_HEIGHT;

        if (cavity) {
            enclosure_engraving(
                string = "POW",
                size = label_text_size,
                position = [
                    pcb_position.x + PCB_SWITCH_POSITION.x,
                    pcb_position.y + PCB_SWITCH_POSITION.y
                        - label_length / 2
                        - (SWITCH_BASE_LENGTH - SWITCH_ORIGIN.y)
                        - exposure_height
                        - label_distance
                ],
                placard = [
                    exposure_height * 2 + SWITCH_BASE_WIDTH,
                    label_length
                ],
                bottom = true,
                quick_preview = quick_preview,
                enclosure_height = dimensions.z
            );
        }

        translate([
            pcb_position.x + PCB_SWITCH_POSITION.x,
            pcb_position.y + PCB_SWITCH_POSITION.y
                - SWITCH_BASE_LENGTH + SWITCH_ORIGIN.y * 2, // TODO: really?
            cavity ? 0 : e
        ]) {
            switch_exposure(
                exposure_height = exposure_height,
                xy_bleed = cavity ? tolerance : ENCLOSURE_INNER_WALL,
                include_switch_cavity = true,
                z_bleed = cavity ? e * 2 : 0
            );
        }
    }

    module _screw_cavities() {
        for (p = PCB_HOLE_POSITIONS) {
            translate([pcb_position.x + p.x, pcb_position.y + p.y, 0]) {
                screw_head_exposure(
                    tolerance = tolerance,
                    clearance = 0
                );

                translate([0, 0, -e]) {
                    cylinder(
                        d = PCB_HOLE_DIAMTER,
                        h = pcb_position.z + e * 2,
                        $fn = HIDEF_ROUNDING
                    );
                }
            }
        }
    }

    module _speaker_fixture() {
        translate([
            speaker_position.x,
            speaker_position.y,
            ENCLOSURE_FLOOR_CEILING - e
        ]) {
            speaker_fixture(
                height = speaker_position.z + SPEAKER_HEIGHT
                    - ENCLOSURE_FLOOR_CEILING + e,
                tolerance = tolerance
            );
        }
    }

    module _battery_fixture() {
        translate(batteries_position) {
            battery_fixture(
                wall = ENCLOSURE_INNER_WALL,
                tolerance = tolerance + e
            );
        }
    }

    module _ftdi_header_exposure(
        x_bleed = 1,
        z_clearance = 1,
        height = 2.54
    ) {
        translate([
            pcb_position.x + PCB_FTDI_HEADER_POSITION.x - x_bleed,
            dimensions.y - ENCLOSURE_WALL - e,
            pcb_position.z + PCB_HEIGHT + 2.54 / 2
                - height / 2
                - z_clearance
        ]) {
            cube([
                PCB_FTDI_HEADER_WIDTH + x_bleed * 2,
                ENCLOSURE_WALL + e * 2,
                height + z_clearance * 2
            ]);
        }
    }

    module _keys_mount_alignment_fixture(bottom) {
        keys_to_enclosure_distance = get_keys_to_enclosure_distance(tolerance);
        z = bottom
            ? ENCLOSURE_FLOOR_CEILING - e
            : bottom_height + LIP_BOX_DEFAULT_LIP_HEIGHT;
        height = bottom
            ? bottom_height + LIP_BOX_DEFAULT_LIP_HEIGHT - z
            : keys_position.z - z + cantilever_height;

        translate([
            keys_position.x - keys_to_enclosure_distance,
            keys_position.y + key_length,
            z
        ]) {
            keys_mount_alignment_fixture(
                height,
                cavity = false,
                tolerance = tolerance
            );
        }
    }

    if (show_top || show_bottom) {
        difference() {
            color(outer_color) {
                if (show_bottom) {
                    _half(top_height, lip = true);

                    _switch_exposure(false);
                    pcb_fixtures(pcb_position = pcb_position);
                    _speaker_fixture();
                    _battery_fixture();
                    _keys_mount_alignment_fixture(true);
                }

                if (show_top) {
                    translate([0, 0, dimensions.z]) {
                        mirror([0, 0, 1]) {
                            _half(bottom_height, lip = false);
                        }
                    }

                    _knob_exposure(false);
                    _keys_mount_alignment_fixture(false);
                }
            }

            color(cavity_color) {
                _keys_exposure();
                _branding();
                _lightpipe_exposure();
                _knob_exposure(true);
                _switch_exposure(true);
                _screw_cavities();
                _ftdi_header_exposure();
            }
        }
    }
}
