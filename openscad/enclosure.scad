// TODO: extract parts to common repo
use <../../poly555/openscad/lib/enclosure.scad>;
use <../../poly555/openscad/lib/pencil_stand.scad>;
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

    pencil_stand_position = [],
    pencil_stand_angle_x,
    pencil_stand_angle_y,
    pencil_stand_depth,

    batteries_position = [],

    label_text_size = 3.2,
    label_length = 5,

    screw_head_clearance = 0,
    nut_lock_floor = 0,

    show_dfm = false,

    tolerance = 0,

    outer_color = undef,
    cavity_color = undef,

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

    module _branding(
        make_to_model_ration = .25,
        gutter = label_distance,
        debug = false
    ) {
        make_length = (branding_length - gutter) * (1 - make_to_model_ration);
        model_length = branding_length - make_length - gutter;

        enclosure_engraving(
            string = "SCOUT",
            size = make_length,
            center = false,
            position = [
                branding_position.x - make_length * .075, // HACK: fix alignment
                branding_position.y
            ],
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        enclosure_engraving(
            size = model_length,
            center = false,
            position = [
                branding_position.x,
                branding_position.y + make_length + gutter
            ],
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        if (debug) {
            width = dimensions.x
                - branding_position.x
                - knob_radius * 2
                - 3.4 * 2; // TODO: expose default_gutter

            translate([
                branding_position.x,
                branding_position.y,
                dimensions.z - ENCLOSURE_FLOOR_CEILING
            ]) {
                # cube([width, branding_length, ENCLOSURE_FLOOR_CEILING + 1]);
            }
        }
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

                if (show_dfm) {
                    translate([0, 0, well_z + ENCLOSURE_FLOOR_CEILING]) {
                        floating_hole_cavity(
                            diameter,
                            cavity_diameter
                        );
                    }
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

    module _switch_exposure(
        cavity = false,

        bottom_engraving_length = 8,
        bottom_engraving_corner = 10
    ) {
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

            enclosure_engraving(
                size = bottom_engraving_length,
                center = false,
                position = [
                    dimensions.x - bottom_engraving_corner,
                    bottom_engraving_corner
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
                    clearance = screw_head_clearance,
                    show_dfm = show_dfm
                );

                translate([0, 0, -e]) {
                    cylinder(
                        d = PCB_HOLE_DIAMETER,
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

    module _headphone_jack_cavity(
        plug_diameter = 10
    ) {
        translate([
            pcb_position.x + PCB_HEADPHONE_JACK_POSITION.x
                + HEADPHONE_JACK_WIDTH / 2,
            dimensions.y - ENCLOSURE_WALL - e,
            pcb_position.z + PCB_HEIGHT + HEADPHONE_JACK_BARREL_Z
        ]) {
            rotate([-90, 0, 0]) {
                cylinder(
                    d = plug_diameter + tolerance * 2,
                    h = ENCLOSURE_WALL + e * 2
                );
            }
        }
    }

    module _keys_mount_nut_lock_rail(
        nut_cavity_size = NUT_DIAMETER + tolerance * 2,
        nut_cavity_height = NUT_HEIGHT
    ) {
        z = keys_position.z + cantilever_height;
        height = dimensions.z - z - ENCLOSURE_FLOOR_CEILING + e;

        module _nut_locks() {
            nuts(
                pcb_position = pcb_position,
                z = keys_position.z + cantilever_height + nut_lock_floor,
                diameter = nut_cavity_size,
                height = nut_cavity_height
            );

            if (show_dfm) {
                DEFAULT_DFM_LAYER_HEIGHT = .2; // TODO: extract
                dfm_length = PCB_HOLE_DIAMETER;

                for (xy = PCB_HOLE_POSITIONS) {
                    translate([
                        pcb_position.x + xy.x - nut_cavity_size / 2,
                        pcb_position.y + xy.y - nut_cavity_size / 2,
                        z + nut_lock_floor
                    ]) {
                        translate([
                            0,
                            (nut_cavity_size - dfm_length) / 2,
                            -DEFAULT_DFM_LAYER_HEIGHT
                        ]) {
                            cube([
                                nut_cavity_size,
                                dfm_length,
                                DEFAULT_DFM_LAYER_HEIGHT + e
                            ]);
                        }
                    }
                }
            }
        }

        difference() {
            translate([keys_position.x, keys_position.y, z]) {
                keys_mount_rail(
                    height = height,
                    include_alignment_fixture = false,
                    tolerance = -e
                );
            }

            _nut_locks();
        }
    }

    module _pencil_stand(
        cavity,

        x = pencil_stand_position.x,
        y = pencil_stand_position.y
    ) {
        e = .17; // HACK: prevent it from sticking out of enclosure w/ low $fn

        if (cavity) {
            translate([x, y, 0]) {
                pencil_stand_cavity(
                    wall = ENCLOSURE_INNER_WALL,
                    depth = pencil_stand_depth + e,
                    angle_x = pencil_stand_angle_x,
                    angle_y = pencil_stand_angle_y
                );
            }
        } else {
            translate([x, y, e]) {
                pencil_stand(
                    wall = ENCLOSURE_INNER_WALL,
                    depth = pencil_stand_depth,
                    angle_x = pencil_stand_angle_x,
                    angle_y = pencil_stand_angle_y
                );
            }
        }
    }

    if (show_top || show_bottom) {
        difference() {
            color(outer_color) {
                if (show_bottom) {
                    _half(top_height, lip = true);

                    _switch_exposure(false);
                    pcb_fixtures(
                        pcb_position = pcb_position,
                        screw_head_clearance = screw_head_clearance
                    );
                    _speaker_fixture();
                    _battery_fixture();
                    _keys_mount_alignment_fixture(true);
                    _pencil_stand(false);
                }

                if (show_top) {
                    translate([0, 0, dimensions.z]) {
                        mirror([0, 0, 1]) {
                            _half(bottom_height, lip = false);
                        }
                    }

                    _knob_exposure(false);
                    _keys_mount_alignment_fixture(false);
                    _keys_mount_nut_lock_rail();
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
                _headphone_jack_cavity();
                _pencil_stand(true);
            }
        }
    }
}
