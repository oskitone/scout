// TODO: extract parts to common repo
use <../../poly555/openscad/lib/basic_shapes.scad>;
use <../../poly555/openscad/lib/enclosure.scad>;
use <../../poly555/openscad/lib/pencil_stand.scad>;
use <../../poly555/openscad/lib/screw_head_exposures.scad>;
use <../../poly555/openscad/lib/switch.scad>;

use <../../apc/openscad/floating_hole_cavity.scad>;

include <enclosure_engraving.scad>;
include <key_lip_endstop.scad>;
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

DEFAULT_DFM_LAYER_HEIGHT = .2; // TODO: extract
BREAKAWAY_SUPPORT_DISTANCE = 10;
BREAKAWAY_SUPPORT_DEPTH = .6;

module enclosure(
    show_top = true,
    show_bottom = true,

    default_gutter = 0,

    dimensions = [],

    pcb_position = [],

    keys_cavity_height,
    keys_position = [],
    key_gutter,
    keys_full_width,

    branding_position = [],
    branding_make_to_model_ratio = .4,

    label_distance,

    knob_radius,
    knob_position = [],
    knob_vertical_clearance = 0,

    speaker_position = [],

    pencil_stand_position = [],
    pencil_stand_angle_x,
    pencil_stand_angle_y,
    pencil_stand_depth,

    label_text_size = 3.2,
    label_length = 5,

    fillet = ENCLOSURE_FILLET,
    key_exposure_lip_fillet = ENCLOSURE_FILLET,

    screw_head_clearance = 0,
    nut_lock_floor = 0,

    show_dfm = false,

    tolerance = 0,

    outer_color = undef,
    cavity_color = undef,

    quick_preview = true
) {
    e = .0345;

    bottom_height = ENCLOSURE_FLOOR_CEILING + LIP_BOX_DEFAULT_LIP_HEIGHT;
    top_height = dimensions.z - bottom_height;

    branding_available_length = dimensions.y - branding_position.y
        - default_gutter;
    branding_gutter = label_distance;

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
            outer_color = outer_color,
            cavity_color = cavity_color,
            $fn = DEFAULT_ROUNDING
        );
    }

    module _keys_exposure(
        y_tolerance_against_enclosure = 0, // intentionally snug

        raft_radius = key_length * .25,
        raft_height = DEFAULT_DFM_LAYER_HEIGHT
    ) {
        width = keys_full_width + key_gutter * 2 - e * 2;

        x = keys_position.x - key_gutter + e;
        z = dimensions.z - keys_cavity_height;

        module _rafts() {
            for (_x = [x, dimensions.x - x]) {
                translate([_x, raft_radius, dimensions.z - raft_height]) {
                    cylinder(
                        r = raft_radius,
                        h = raft_height + e
                    );
                }
            }
        }

        difference() {
            translate([x, -e, z]) {
                cube([
                    width,
                    keys_position.y + key_length + y_tolerance_against_enclosure,
                    keys_cavity_height + e
                ]);
            }

            if (show_dfm) {
                _rafts();
            }
        }

        translate([x, key_exposure_lip_fillet, z - key_exposure_lip_fillet]) {
            rotate([0, 90, 0]) {
                rounded_corner_cutoff(
                    height = width,
                    radius = key_exposure_lip_fillet,
                    angle = 180,
                    $fn = DEFAULT_ROUNDING
                );
            }
        }
    }

    module key_exposure_lip_support(
        wall = BREAKAWAY_SUPPORT_DEPTH
    ) {
        print_bed_length = BREAKAWAY_SUPPORT_DEPTH;
        connection_length = ENCLOSURE_WALL;
        connection_gap = DEFAULT_DFM_LAYER_HEIGHT;

        width = keys_full_width + key_gutter * 2
            - BREAKAWAY_SUPPORT_DISTANCE * 2;

        x = (dimensions.x - width) / 2;
        z = dimensions.z - keys_cavity_height - key_exposure_lip_fillet;
        inner_cavity_z = z + key_exposure_lip_fillet + connection_gap
            + DEFAULT_DFM_LAYER_HEIGHT;

        module _hull(
            height = dimensions.z - z,

            bottom_length = connection_length,
            bottom_height = key_exposure_lip_fillet,

            top_length = print_bed_length,

            x_bleed = 0
        ) {
            top_y = (top_length - bottom_length) / -2;

            hull() {
                translate([-x_bleed, 0, 0]) {
                    cube([width + x_bleed * 2, bottom_length, bottom_height]);
                }

                translate([-x_bleed, top_y, height - e]) {
                    cube([width + x_bleed * 2, top_length, e]);
                }
            }
        }

        module _inner_cavity() {
            _hull(
                height = dimensions.z - inner_cavity_z - wall * 2,
                bottom_length = connection_length - wall * 2,
                bottom_height = e,
                top_length = e,
                x_bleed = e
            );
        }

        difference() {
            translate([x, 0, z]) {
                _hull();
            }

            translate([x, wall, inner_cavity_z]) {
                _inner_cavity();
            }

            translate([x - e, key_exposure_lip_fillet, z]) {
                cube([
                    width + e * 2,
                    connection_length / 2 + connection_gap,
                    key_exposure_lip_fillet + connection_gap
                ]);
            }

            translate([x - e, key_exposure_lip_fillet, z]) {
                rotate([0, 90, 0]) {
                    cylinder(
                        h = width + e * 2,
                        r = key_exposure_lip_fillet + connection_gap,
                        $fn = DEFAULT_ROUNDING
                    );
                }
            }
        }
    }

    module _branding(debug = false) {
        model_length = get_branding_model_length(
            branding_gutter,
            branding_make_to_model_ratio,
            branding_available_length
        );
        make_length = get_branding_make_length(
            branding_gutter,
            branding_make_to_model_ratio,
            branding_available_length
        );
        make_width = get_branding_make_width(
            branding_gutter,
            branding_make_to_model_ratio,
            branding_available_length
        );

        enclosure_engraving(
            string = "SCOUT",
            size = model_length,
            center = false,
            position = [
                branding_position.x - model_length * .075, // HACK: fix alignment
                branding_position.y
            ],
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        enclosure_engraving(
            size = make_length,
            center = false,
            position = [
                branding_position.x,
                branding_position.y + model_length + branding_gutter
            ],
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        if (debug) {
            width = dimensions.x
                - branding_position.x
                - knob_radius * 2
                - default_gutter * 2;

            translate([
                branding_position.x,
                branding_position.y,
                dimensions.z - ENCLOSURE_FLOOR_CEILING
            ]) {
                # cube([
                    width,
                    branding_available_length,
                    ENCLOSURE_FLOOR_CEILING + 1
                ]);
            }
        }
    }

    module _knob_exposure(
        cavity,
        well_clearance = 1,
        shaft_clearance = .5
    ) {
        cavity_z = knob_position.z - knob_vertical_clearance;
        cavity_height = dimensions.z - cavity_z + e;
        cavity_diameter = (knob_radius + well_clearance + tolerance) * 2;

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
                diameter = PTV09A_POT_ACTUATOR_DIAMETER
                    + tolerance * 2
                    + shaft_clearance * 2;

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
                        h = ENCLOSURE_FLOOR_CEILING + e * 2,
                        $fn = DEFAULT_ROUNDING
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

    module _bottom_engraving(
        bottom_engraving_length = 8,
        bottom_engraving_corner = 10
    ) {
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
                wall = ENCLOSURE_INNER_WALL,
                tolerance = tolerance
            );
        }
    }

    module _speaker_fixture_cavity() {
        z = bottom_height - LIP_BOX_DEFAULT_LIP_HEIGHT - e;
        height = speaker_position.z + SPEAKER_HEIGHT - z + e;
        diameter = get_speaker_fixture_diameter(ENCLOSURE_INNER_WALL, tolerance)
            + tolerance * 2;

        translate([speaker_position.x, speaker_position.y, z]) {
            cylinder(
                d = diameter,
                h = height
            );
        }
    }

    module _ftdi_header_exposure(
        x_bleed = 1,
        height = 8
    ) {
        pin_z = pcb_position.z + PCB_HEIGHT + 6;
        x = pcb_position.x + PCB_FTDI_HEADER_POSITION.x - x_bleed;
        width = PCB_FTDI_HEADER_WIDTH + x_bleed * 2;

        translate([ x, dimensions.y - ENCLOSURE_WALL - e, pin_z - height / 2]) {
            cube([
                width,
                ENCLOSURE_WALL + e * 2,
                height
            ]);
        }

        _side_engraving(
            x = x + width / 2,
            string = "FTDI"
        );

        _side_engraving(
            x = x + width / 2,
            string = "G               B",
            placard = false,
            z = pin_z
        );
    }

    module _keys_mount_alignment_fixture() {
        keys_to_enclosure_distance = get_keys_to_enclosure_distance(tolerance);
        z = bottom_height - LIP_BOX_DEFAULT_LIP_HEIGHT;
        height = keys_position.z - z + cantilever_height;

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
        x = pcb_position.x + PCB_HEADPHONE_JACK_POSITION.x
            + HEADPHONE_JACK_WIDTH / 2;
        z = pcb_position.z + PCB_HEIGHT + HEADPHONE_JACK_BARREL_Z;

        translate([x, dimensions.y - ENCLOSURE_WALL - e, z]) {
            rotate([-90, 0, 0]) {
                cylinder(
                    d = plug_diameter + tolerance * 2,
                    h = ENCLOSURE_WALL + e * 2
                );
            }
        }

        _side_engraving(
            x = x,
            string = "LINE"
        );
    }

    module _side_engraving(
        x,
        string,
        width = 15,
        z = bottom_height + label_length / 2 - e,
        placard = true
    ) {
        translate([
            x,
            dimensions.y,
            z
        ]) {
            // TODO: support sides in enclosure_engraving
            rotate([90, 0, 0]) {
                enclosure_engraving(
                    string = string,
                    size = label_text_size,
                    placard = placard ? [width, label_length] : undef,
                    bottom = true,
                    quick_preview = quick_preview,
                    enclosure_height = dimensions.z
                );
            }
        }
    }

    // TODO: change when PCB has this kind of switch
    module _right_angle_switch_cavity_stub() {
        width = 10;
        height = 6;

        x = 13;
        z = pcb_position.z;

        _side_engraving(
            x = x + width / 2,
            string = "POW"
        );

        translate([
            x,
            dimensions.y - ENCLOSURE_WALL - e,
            z
        ]) {
            cube([
                width,
                ENCLOSURE_WALL + e * 2,
                height
            ]);
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

    module _led_exposure(
        cavity = true,

        shade_depth = DEFAULT_DFM_LAYER_HEIGHT * 2,

        // TODO: when PCB has LED in the right place...
        // dimensions.z - (pcb_position.z + PCB_HEIGHT)
        depth = LED_HEIGHT + 1,
        wall = ENCLOSURE_INNER_WALL
    ) {
        z = cavity
            ? dimensions.z - depth - e
            : dimensions.z - depth;

        // intentionally snug!
        // TODO: loosen when LED is PCB-mounted again
        cavity_width = LED_DIAMETER;

        width = cavity ? cavity_width : cavity_width + wall * 2;
        height = cavity
            ? dimensions.z - z - shade_depth
            : dimensions.z - z - ENCLOSURE_FLOOR_CEILING + e;

        // TODO: ditch when PCB has LED in the right place
        make_length = get_branding_make_length(
            branding_gutter,
            branding_make_to_model_ratio,
            branding_available_length
        );
        make_width = get_branding_make_width(
            branding_gutter,
            branding_make_to_model_ratio,
            branding_available_length
        );
        model_length = get_branding_model_length(
            branding_gutter,
            branding_make_to_model_ratio,
            branding_available_length
        );

        led_x = branding_position.x + make_width + cavity_width / 2
            + label_distance;
        led_y = branding_position.y + model_length + label_distance
            + cavity_width / 2;

        translate([led_x, led_y, z]) {
            cylinder(d = width, h = height, $fn = DEFAULT_ROUNDING);
        }
    }

    if (show_top || show_bottom) {
        if (show_top && show_dfm) {
            color(outer_color) {
                key_exposure_lip_support();
            }
        }

        difference() {
            union() {
                if (show_bottom) {
                    _half(bottom_height, lip = false);

                    color(outer_color) {
                        pcb_fixtures(
                            pcb_position = pcb_position,
                            screw_head_clearance = screw_head_clearance
                        );
                        _speaker_fixture();
                        _pencil_stand(false);
                    }
                }

                if (show_top) {
                    difference() {
                        translate([0, 0, dimensions.z]) {
                            mirror([0, 0, 1]) {
                                _half(top_height, lip = true);
                            }
                        }

                        color(cavity_color) {
                            _speaker_fixture_cavity();
                        }
                    }

                    color(outer_color) {
                        _knob_exposure(false);
                        _keys_mount_alignment_fixture();
                        _keys_mount_nut_lock_rail();
                        key_lip_endstop(dimensions.z - keys_cavity_height);
                        _led_exposure(cavity = false);
                        pcb_enclosure_top_fixture(
                            pcb_position = pcb_position,
                            enclosure_dimensions = dimensions
                        );
                    }
                }
            }

            color(cavity_color) {
                _keys_exposure();
                _branding();
                _knob_exposure(true);
                _bottom_engraving();
                _screw_cavities();
                _ftdi_header_exposure();
                _headphone_jack_cavity();
                _pencil_stand(true);
                _led_exposure(cavity = true);
                _right_angle_switch_cavity_stub();
            }
        }
    }
}
