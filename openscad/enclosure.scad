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
include <tray_fixtures.scad>;

/* TODO: extract */
ENCLOSURE_WALL = 2.4;
ENCLOSURE_FLOOR_CEILING = 1.8;
ENCLOSURE_INNER_WALL = 1.2;

ENCLOSURE_TO_PCB_CLEARANCE = 2;

ENCLOSURE_FILLET = 2;

DEFAULT_ROUNDING = 24;
HIDEF_ROUNDING = 120;

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
    key_width,
    key_length,

    cantilever_height = 0,

    branding_position = [],
    branding_make_to_model_ratio = .4,

    label_distance,

    knob_radius,
    knob_dimple_y = 0,
    knob_position = [],
    knob_vertical_clearance = 0,

    speaker_position = [],

    pencil_stand_position = [],
    pencil_stand_angle_x,
    pencil_stand_angle_y,
    pencil_stand_depth,

    label_text_size = 3.2,
    label_length = 5,

    lip_height = 3,

    fillet = ENCLOSURE_FILLET,
    key_exposure_lip_fillet = ENCLOSURE_FILLET,

    screw_head_clearance = 0,
    nut_lock_floor = 0,

    tray_height,
    tray_z,

    show_dfm = false,

    tolerance = 0,

    outer_color = undef,
    cavity_color = undef,

    quick_preview = true
) {
    e = .0345;

    bottom_height = pcb_position.z + lip_height
        - max(PCB_FIXTURE_VERTICAL_ALLOWANCE, PCB_PIN_CLEARANCE);
    top_height = dimensions.z - bottom_height;

    branding_available_width = dimensions.x
        - branding_position.x
        - knob_radius * 2
        - default_gutter * 2;
    branding_available_length = dimensions.y - branding_position.y
        - default_gutter;
    branding_gutter = label_distance;

    button_rail_length = 3;

    module _half(
        _height,
        lip,
        quick_preview = quick_preview
    ) {
        enclosure_half(
            include_tongue_and_groove = true,
            tongue_and_groove_endstop_height = bottom_height
                - lip_height - ENCLOSURE_FLOOR_CEILING,
            side_tongue_and_groove_entry = true,

            width = dimensions.x,
            length = dimensions.y,
            height = _height,
            wall = ENCLOSURE_WALL,
            floor_ceiling = ENCLOSURE_FLOOR_CEILING,
            add_lip = lip,
            remove_lip = !lip,
            lip_height = lip_height,
            fillet = quick_preview ? 0 : fillet,
            tolerance = DEFAULT_TOLERANCE * 2, // intentionally loose
            outer_color = outer_color,
            cavity_color = cavity_color,
            $fn = quick_preview ? undef : DEFAULT_ROUNDING
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
                    $fn = quick_preview ? undef : DEFAULT_ROUNDING
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
                        $fn = quick_preview ? undef : DEFAULT_ROUNDING
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
            translate([
                branding_position.x,
                branding_position.y,
                dimensions.z - ENCLOSURE_FLOOR_CEILING
            ]) {
                # cube([
                    branding_available_width,
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
                        $fn = quick_preview ? undef : DEFAULT_ROUNDING
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
        brand_length = 8,
        brand_corner = 10,

        battery_label_string = "AAA*3",
        battery_label_size = label_text_size
    ) {
        brand_width = brand_length / OSKITONE_LENGTH_WIDTH_RATIO;

        battery_label_width = battery_label_size
            * len(battery_label_string) + label_distance * 2;
        battery_label_length = label_length;

        enclosure_engraving(
            size = brand_length,
            center = false,
            position = [
                dimensions.x - brand_corner,
                brand_corner
            ],
            bottom = true,
            quick_preview = quick_preview,
            enclosure_height = dimensions.z
        );

        enclosure_engraving(
            string = battery_label_string,
            size = battery_label_size,
            position = [
                brand_corner + battery_label_width / 2,
                brand_corner + battery_label_length / 2
            ],
            placard = [battery_label_width, battery_label_length],
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
                        $fn = quick_preview ? undef : HIDEF_ROUNDING
                    );
                }
            }
        }
    }

    module _uart_header_exposure(
        x_bleed = 1,
        height = 8
    ) {
        pin_z = pcb_position.z + PCB_HEIGHT + 6;

        x = pcb_position.x + PCB_UART_HEADER_POSITION.x - x_bleed;
        z = pin_z - height / 2;

        width = PCB_UART_HEADER_WIDTH + x_bleed * 2;

        translate([x, dimensions.y - ENCLOSURE_WALL - e, z]) {
            cube([
                width,
                ENCLOSURE_WALL + e * 2,
                height
            ]);
        }

        _side_engraving(
            x = x + width / 2,
            string = "UART",
            width = width,
            z = bottom_height + label_length / 2
                - (label_length - label_text_size) / 2
                + e
        );

        _side_engraving(
            x = x + width / 2,
            string = "G               B",
            placard = false,
            z = pin_z
        );
    }

    module _keys_mount_alignment_fixture() {
        keys_to_enclosure_distance =
            get_keys_to_enclosure_distance(tolerance, key_gutter);
        z = bottom_height + lip_height;
        height = keys_position.z - z + cantilever_height;

        translate([
            keys_position.x - keys_to_enclosure_distance,
            keys_position.y + key_length,
            z
        ]) {
            keys_mount_alignment_fixture(
                height,
                key_width = key_width,
                key_gutter = key_gutter,
                cavity = false,
                tolerance = tolerance
            );
        }
    }

    module _headphone_jack_cavity(
        plug_diameter = 10,
        engraving_width = 16
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
            x = x + engraving_width / 2 + plug_diameter / 2 - 1,
            width = engraving_width,
            string = "LINE",
            z = z
        );
    }

    module _side_engraving(
        x,
        string,
        width = 15,
        z = pcb_position.z - label_length / 2 - e,
        placard = true
    ) {
        translate([
            x,
            dimensions.y + e,
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
        height = 6 + lip_height;

        x = 13;
        z = pcb_position.z - lip_height;

        _side_engraving(
            x = x + width / 2,
            z = z + height + label_length / 2 - e,
            string = "POW"
        );

        translate([
            x,
            dimensions.y - ENCLOSURE_WALL - e,
            z - e
        ]) {
            cube([
                width,
                ENCLOSURE_WALL + e * 2,
                height + e
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
                    key_width = key_width,
                    key_length = key_length,
                    key_gutter = key_gutter,
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
        // TODO: ditch or integrate with tray

        if (cavity) {
            * translate([x, y, -e]) {
                pencil_stand_cavity(
                    wall = ENCLOSURE_INNER_WALL,
                    depth = pencil_stand_depth + e,
                    angle_x = pencil_stand_angle_x,
                    angle_y = pencil_stand_angle_y
                );
            }
        } else {
            * translate([x, y, e]) {
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

        chamfer_shroud = 2,

        recession = ENCLOSURE_ENGRAVING_DEPTH,
        shade_depth = DEFAULT_DFM_LAYER_HEIGHT * 2,

        // intentionally snug!
        // TODO: loosen when LED is PCB-mounted again
        cavity_diameter = LED_DIAMETER,

        // TODO: rewrite when PCB has LED in the right place...
        cavity_depth = LED_HEIGHT + 2,
        wall = ENCLOSURE_INNER_WALL,

        $fn = quick_preview ? undef : DEFAULT_ROUNDING
    ) {
        x = branding_position.x + branding_available_width
            - cavity_diameter / 2;
        y = knob_position.y + knob_dimple_y;
        z = dimensions.z - recession - cavity_depth;
        shroud_z = dimensions.z - ENCLOSURE_FLOOR_CEILING - chamfer_shroud;

        wall_diameter = cavity_diameter + wall * 2;

        diameter = cavity ? cavity_diameter : wall_diameter;
        wall_height = dimensions.z - z - ENCLOSURE_FLOOR_CEILING + e;

        if (cavity) {
            translate([x, y, z - e]) {
                cylinder(
                    d = cavity_diameter,
                    h = cavity_depth - shade_depth + e
                );
            }

            translate([x, y, dimensions.z - recession]) {
                cylinder(
                    d = cavity_diameter,
                    h = recession + e
                );
            }
        } else {
            translate([x, y, z]) {
                cylinder(
                    d = wall_diameter,
                    h = wall_height
                );
            }

            translate([x, y, shroud_z]) {
                cylinder(
                    d1 = wall_diameter,
                    d2 = wall_diameter + chamfer_shroud * 2,
                    h = chamfer_shroud + e
                );
            }
        }
    }

    module _pcb_fixture_lip_cavity(clearance = 1) {
        y = pcb_position.y + PCB_BUTTON_POSITIONS[0].y
            - button_rail_length / 2
            - (tolerance + clearance);

        length = PCB_HOLE_POSITIONS[0].y - PCB_BUTTON_POSITIONS[0].y
            + button_rail_length / 2
            + get_mounting_column_top_diameter(tolerance) / 2
            + (tolerance + clearance) * 2;

        translate([-e, y, bottom_height - lip_height - e]) {
            cube([
                ENCLOSURE_WALL + e * 2,
                length,
                lip_height + e * 2
            ]);
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
                            screw_head_clearance = screw_head_clearance,
                            button_rail_length = button_rail_length
                        );
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
                            _pcb_fixture_lip_cavity();
                        }
                    }

                    color(outer_color) {
                        _knob_exposure(false);
                        _keys_mount_alignment_fixture();
                        _keys_mount_nut_lock_rail();
                        key_lip_endstop(
                            keys_cavity_height_z
                                = dimensions.z - keys_cavity_height,
                            keys_full_width = keys_full_width,
                            key_gutter = key_gutter
                        );
                        _led_exposure(cavity = false);
                        pcb_enclosure_top_fixture(
                            pcb_position = pcb_position,
                            enclosure_dimensions = dimensions
                        );
                        tray_fixtures(
                            enclosure_dimensions = dimensions,
                            tray_dimensions = [
                                get_tray_width(dimensions),
                                get_tray_length(pcb_position),
                                tray_height,
                            ],
                            tray_z = tray_z
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
                _uart_header_exposure();
                _headphone_jack_cavity();
                _pencil_stand(true);
                _led_exposure(cavity = true);
                _right_angle_switch_cavity_stub();
            }
        }
    }
}
