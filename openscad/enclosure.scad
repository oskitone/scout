// TODO: extract parts to common repo
use <../../poly555/openscad/lib/basic_shapes.scad>;
use <../../poly555/openscad/lib/enclosure.scad>;
use <../../poly555/openscad/lib/pencil_stand.scad>;
use <../../poly555/openscad/lib/switch.scad>;

use <../../apc/openscad/floating_hole_cavity.scad>;

include <enclosure_engraving.scad>;
include <enclosure_screw_cavities.scad>;
include <key_lip_endstop.scad>;
include <keys.scad>;
include <pcb_fixtures.scad>;

/*
 * NOTES ON ENCLOSURE_WALL:
    * The PCB's knob-to-key distance assumes a 2.4 wall. See commit ff765d34d7
      for a compromise to do anything else, like...
    * 3 works well enough and feels very sturdy.
    * 4 is so thick that the lips don't have enough "give" to bend into place,
      hurting assembly -- may be fixable w/ a much looser tolerance fit.
    * I wonder if tight fits cause the bottom to concave bend as its sides are
      pushed down and in by the top.
    * No thickness seems to fix the issue where the grooved half is bigger than
      the lipped half. Could be a tolerance fit issue?
 */

/* TODO: extract */
ENCLOSURE_WALL = 2.4;
ENCLOSURE_FLOOR_CEILING = 1.8;
ENCLOSURE_INNER_WALL = 1.2;

ENCLOSURE_SIDE_OVEREXPOSURE = 1;

ENCLOSURE_FILLET = 2;
ENCLOSURE_INNER_FILLET = 1.25;

LOFI_ROUNDING = 12;
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
    bottom_height,
    top_height,

    pcb_position = [],
    pcb_screw_hole_positions = [],
    pcb_post_hole_positions = [],

    keys_cavity_height,
    keys_position = [],
    key_gutter,
    keys_full_width,
    key_width,
    key_length,

    cantilver_mount_height = 0,

    branding_position = [],
    branding_make_to_model_ratio = .4,

    label_distance,

    knob_radius,
    knob_dimple_y = 0,
    knob_position = [],
    knob_vertical_clearance = 0,

    speaker_position = [],

    battery_holder_wall = ENCLOSURE_INNER_WALL,
    battery_holder_floor = 0,
    batteries_position = [],

    pencil_stand_position = [],
    pencil_stand_angle_x,
    pencil_stand_angle_y,
    pencil_stand_depth,

    label_text_size = 3.2,
    label_length = 5,

    lip_height,

    fillet = ENCLOSURE_FILLET,
    key_exposure_lip_fillet = ENCLOSURE_FILLET,

    screw_top_clearance = 0,
    screw_head_clearance = 0,
    nut_lock_floor = 0,

    switch_clutch_web_length_extension = 0,

    show_dfm = false,
    brim_height = DEFAULT_DFM_LAYER_HEIGHT,

    tolerance = 0,

    outer_color = undef,
    cavity_color = undef,

    quick_preview = true
) {
    e = .0345;

    branding_available_width = dimensions.x
        - branding_position.x
        - knob_radius * 2
        - default_gutter * 2;
    branding_available_length = dimensions.y - branding_position.y
        - default_gutter;
    branding_gutter = label_distance;

    switch_clutch_length_with_travel = get_switch_clutch_length_with_travel(
        switch_clutch_web_length_extension
    );

    module _half(
        _height,
        lip,
        quick_preview = quick_preview
    ) {
        enclosure_half(
            width = dimensions.x,
            length = dimensions.y,
            height = _height,
            wall = ENCLOSURE_WALL,
            floor_ceiling = ENCLOSURE_FLOOR_CEILING,
            add_lip = lip,
            remove_lip = !lip,
            lip_height = lip_height,
            fillet = quick_preview ? 0 : fillet,
            include_tongue_and_groove = true,
            tongue_and_groove_snap = [.3, .9], // eyeballed vs placard labels
            tongue_and_groove_pull = tolerance,
            tolerance = tolerance * 1.5, // intentionally kinda loose
            outer_color = outer_color,
            cavity_color = cavity_color,
            $fn = quick_preview ? undef : DEFAULT_ROUNDING
        );
    }

    module _keys_exposure(
        y_tolerance_against_enclosure = 0, // intentionally snug
        brim_radius = key_length * .5
    ) {
        width = keys_full_width + key_gutter * 2 - e * 2;

        x = keys_position.x - key_gutter + e;
        z = dimensions.z - keys_cavity_height;

        module _brims() {
            for (_x = [x, dimensions.x - x]) {
                translate([_x, 0, dimensions.z - brim_height]) {
                    scale([1, .5, 1]) {
                        cylinder(r = brim_radius, h = brim_height + e);
                    }
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
                _brims();
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
        wall = BREAKAWAY_SUPPORT_DEPTH,
        brim_depth = 2
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

        if (show_dfm) {
            translate([x - brim_depth, -brim_depth, dimensions.z - brim_height]) {
                cube([
                    width + brim_depth * 2,
                    connection_length + brim_depth * 2,
                    brim_height
                ]);
            }
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
    ) {
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
                tolerance = tolerance,
                quick_preview = quick_preview
            );
        }
    }

    module _assembly_valley_cavity(
        x = -e,
        y = dimensions.y - ENCLOSURE_WALL - e,
        top_z = 0,
        width = ENCLOSURE_WALL + e * 2,
        length = ENCLOSURE_WALL + e * 2
    ) {
        height = top_z - bottom_height + lip_height + e;

        translate([x, y, top_z - height]) {
            cube([width, length, height]);
        }
    }

    module _side_engraving(
        x = undef,
        y = undef,
        string,
        width = SIDE_ENGRAVING_DEFAULT_WIDTH,
        z = (dimensions.z - SWITCH_CLUTCH_GRIP_HEIGHT - label_length) / 2
            - 1,
        placard = true
    ) {
        is_left = y != undef;

        translate([
            is_left ? -e : x,
            is_left ? y : dimensions.y + e,
            z
        ]) {
            rotate([90, 0, is_left ? 90 : 0]) {
                enclosure_engraving(
                    string = string,
                    size = label_text_size,
                    depth = ENCLOSURE_ENGRAVING_DEPTH,
                    placard = placard ? [width, label_length] : undef,
                    chamfer_placard_top = true,
                    bottom = true,
                    quick_preview = quick_preview,
                    enclosure_height = dimensions.z
                );
            }
        }
    }

    module _pow_engraving_lip_reinforcement(cavity) {
        width = cavity ? ENCLOSURE_WALL : ENCLOSURE_WALL - e * 2;
        length = cavity
            ? SIDE_ENGRAVING_DEFAULT_WIDTH + e * 2 + tolerance * 4
            : SIDE_ENGRAVING_DEFAULT_WIDTH + e * 2;
        height = lip_height;

        translate([
            e,
            get_switch_peripheral_y(length),
            bottom_height - height - e
        ]) {
            cube([width, length, height + e]);
        }
    }

    module _uart_header_exposure(
        just_assembly_valley = false,
        x_bleed = 1,
        min_height = 4
    ) {
        pin_center_z = pcb_position.z + PCB_HEIGHT + PCB_UART_HEADER_HEIGHT / 2;
        label_top_z = dimensions.z / 2 + label_text_size / 2;
        height = max(min_height, abs(pin_center_z - label_top_z) * 2);

        x = pcb_position.x + PCB_UART_HEADER_POSITION.x - x_bleed;
        z = pin_center_z - height / 2;

        width = PCB_UART_HEADER_WIDTH + x_bleed * 2 + tolerance * 2;

        if (just_assembly_valley) {
            _assembly_valley_cavity(
                x = x,
                top_z = z,
                width = width
            );
        } else {
            translate([x, dimensions.y - ENCLOSURE_WALL - e, z - tolerance]) {
                cube([
                    width,
                    ENCLOSURE_WALL + e * 2,
                    height + tolerance * 2
                ]);
            }

            _side_engraving(
                x = x + width / 2,
                string = "UART",
                width = width
            );

            _side_engraving(
                x = x + width / 2,
                string = "G               B",
                placard = false,
                z = dimensions.z / 2
            );
        }
    }

    module _keys_mount_alignment_fixture(top) {
        keys_to_enclosure_distance =
            get_keys_to_enclosure_distance(tolerance, key_gutter);

        z = top
            ? bottom_height - lip_height
            : ENCLOSURE_FLOOR_CEILING - e;
        height = top
            ? keys_position.z - z + cantilver_mount_height
            : bottom_height - z - lip_height;

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
        just_assembly_valley = false,
        cavity_diameter = HEADPHONE_JACK_BARREL_DIAMETER + tolerance * 2,
        plug_clearance_depth = ENCLOSURE_ENGRAVING_DEPTH,
        plug_clearance_diameter = 10 + tolerance * 2,
        engraving_width = 16
    ) {
        x = pcb_position.x + PCB_HEADPHONE_JACK_POSITION.x
            + HEADPHONE_JACK_WIDTH / 2;
        z = pcb_position.z + PCB_HEIGHT + HEADPHONE_JACK_BARREL_Z;

        module _c(diameter, depth) {
            translate([x, dimensions.y + e, z]) {
                rotate([90, 0, 0]) {
                    cylinder(
                        d = diameter,
                        h = depth + e * 2,
                        $fn = quick_preview ? undef : DEFAULT_ROUNDING
                    );
                }
            }
        }

        if (just_assembly_valley) {
            _assembly_valley_cavity(
                x = x - cavity_diameter / 2,
                top_z = z,
                width = cavity_diameter
            );
        } else {
            _c(cavity_diameter, ENCLOSURE_WALL);
            _c(plug_clearance_diameter, plug_clearance_depth);

            _side_engraving(
                x = x,
                width = engraving_width,
                string = "LINE"
            );
        }
    }

    function get_switch_peripheral_y(length = 0) = (
        pcb_position.y + PCB_SWITCH_POSITION.y
            - SWITCH_ORIGIN.y
            + SWITCH_BASE_LENGTH / 2
            - length / 2
    );

    module _switch_exposure(
        just_assembly_valley = false,
        length_clearance = .2 // intentionally loose
    ) {
        length = SWITCH_CLUTCH_GRIP_LENGTH + SWITCH_ACTUATOR_TRAVEL
            + tolerance * 4 + length_clearance * 2;
        height = SWITCH_CLUTCH_GRIP_HEIGHT + tolerance * 4;

        y = get_switch_peripheral_y(length);
        z = (dimensions.z - height) / 2;

        if (just_assembly_valley) {
            _assembly_valley_cavity(
                y = y,
                top_z = z + e,
                length = length
            );
        } else {
            translate([-e, y, z]) {
                cube([ENCLOSURE_WALL + e * 2, length, height]);
            }

            _side_engraving(
                string = "POW",
                y = y + length / 2
            );

            _side_engraving(
                string = "1            0",
                y = y + length / 2,
                placard = false,
                z = dimensions.z / 2
            );
        }
    }

    module _switch_clutch_aligners(
        bottom = false,
        width = ENCLOSURE_INNER_WALL,
        height = 2
    ) {
        x = pcb_position.x;
        y = get_switch_peripheral_y(switch_clutch_length_with_travel);
        z = bottom
            ? ENCLOSURE_FLOOR_CEILING - e
            : dimensions.z - ENCLOSURE_FLOOR_CEILING - height;

        translate([x, y, z]) {
            cube([width, switch_clutch_length_with_travel, height + e]);
        }
    }

    module _keys_mount_nut_lock_rail(
        nut_cavity_size = NUT_DIAMETER + tolerance * 2,
        nut_cavity_height = NUT_HEIGHT
    ) {
        z = keys_position.z + cantilver_mount_height;
        height = dimensions.z - z - ENCLOSURE_FLOOR_CEILING + e;

        module _nuts(entry) {
            e_translate() {
                nuts(
                    pcb_position = pcb_position,
                    positions = pcb_screw_hole_positions,
                    y = entry ? nut_cavity_size - e * 2 : 0,
                    z = entry
                        ? z + nut_lock_floor + nut_cavity_height
                        : z + nut_lock_floor,
                    diameter = entry
                        ? nut_cavity_size + e * 2
                        : nut_cavity_size,
                    height = entry ? screw_top_clearance : nut_cavity_height
                );
            }
        }

        module _nut_entry_paths() {
            _nuts(entry = true);
        }

        module _nut_locks() {
            _nuts(entry = false);

            if (show_dfm) {
                dfm_length = PCB_HOLE_DIAMETER;

                for (xy = pcb_screw_hole_positions) {
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
            union() {
                translate([keys_position.x, keys_position.y, z]) {
                    keys_mount_rail(
                        height = height,
                        key_width = key_width,
                        key_length = key_length,
                        key_gutter = key_gutter,
                        include_alignment_fixture = false,
                        pcb_screw_hole_positions = pcb_screw_hole_positions,
                        tolerance = -e
                    );
                }

                _nut_entry_paths();
            }

            _nut_locks();
        }
    }

    module _pencil_stand(
        cavity,

        x = pencil_stand_position.x,
        y = pencil_stand_position.y
    ) {
        if (cavity) {
            translate([x, y, -e]) {
                pencil_stand_cavity(
                    wall = ENCLOSURE_INNER_WALL,
                    depth = pencil_stand_depth + e,
                    angle_x = pencil_stand_angle_x,
                    angle_y = pencil_stand_angle_y,
                    add_tightening_webs = true,
                    chamfer = .6
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
        chamfer_shroud_wall = 3,
        chamfer_shroud_height = 6,
        shade_depth = DEFAULT_DFM_LAYER_HEIGHT * 4,
        led_clearance = .4,
        wall = ENCLOSURE_INNER_WALL,
        $fn = quick_preview ? undef : DEFAULT_ROUNDING
    ) {
        cavity_diameter = LED_DIAMETER + tolerance * 2 + led_clearance * 2;

        x = pcb_position.x + PCB_LED_POSITION.x;
        y = pcb_position.y + PCB_LED_POSITION.y;
        z = pcb_position.z + PCB_HEIGHT;

        cavity_depth = dimensions.z - z;
        shroud_z = dimensions.z - ENCLOSURE_FLOOR_CEILING
            - chamfer_shroud_height;

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
                    d2 = wall_diameter + chamfer_shroud_wall * 2,
                    h = chamfer_shroud_height + e
                );
            }
        }
    }

    module _battery_holder_fixtures(top) {
        battery_holder_width =
            get_battery_holder_width(tolerance, battery_holder_wall);
        battery_holder_length =
            get_battery_holder_length(tolerance, battery_holder_wall);

        function get_center_x(width) = (
            batteries_position.x
            + -(battery_holder_wall + tolerance)
            + (battery_holder_width - width) / 2
        );

        module _nub(y) {
            _width = BATTERY_HOLDER_NUB_FIXTURE_WIDTH - tolerance * 2;
            _length = BATTERY_HOLDER_NUB_FIXTURE_DEPTH;
            _height = BATTERY_HOLDER_NUB_FIXTURE_HEIGHT - tolerance * 2;

            x = get_center_x(_width);
            z = ENCLOSURE_FLOOR_CEILING + BATTERY_HOLDER_NUB_FIXTURE_Z
                + tolerance;

            translate([x, y - e, z]) {
                cube([_width, _length + e, _height]);
            }
        }

        module _side_aligners(
            width = ENCLOSURE_INNER_WALL,
            clearance = .2
        ) {
            length = battery_holder_wall
                + (AAA_BATTERY_DIAMETER - KEYSTONE_5204_5226_TAB_WIDTH) / 2;
            height = length;

            for (x = [
                -width - clearance - tolerance,
                 clearance + battery_holder_width
            ]) {
                x = x + batteries_position.x - battery_holder_wall - tolerance;

                translate([x, ENCLOSURE_WALL - e, ENCLOSURE_FLOOR_CEILING - e]) {
                    flat_top_rectangular_pyramid(
                        top_width = width,
                        top_length = 0,
                        bottom_width = width,
                        bottom_length = length + e,
                        height = height + e,
                        top_weight_y = 0
                    );
                }
            }
        }

        module _back_hitch(
            width = AAA_BATTERY_LENGTH / 2,
            web_width = ENCLOSURE_INNER_WALL
        ) {
            back_y = batteries_position.y - (battery_holder_wall + tolerance)
                + get_battery_holder_length(tolerance, battery_holder_wall);
            length = pcb_position.y - back_y
                - tolerance - PCB_FIXTURE_CLEARANCE;

            z = ENCLOSURE_FLOOR_CEILING;

            height = battery_holder_floor + AAA_BATTERY_DIAMETER;
            web_height = pcb_position.z - z - PCB_PIN_CLEARANCE;

            endstop_x = get_center_x(width);
            endstop_y = batteries_position.y - (battery_holder_wall + tolerance)
                + tolerance * 0 // intentionally snug
                + battery_holder_length;

            web_length =
                (pcb_position.y + PCB_BUTTON_POSITIONS[0].y -
                    PCB_FIXTURE_BUTTON_RAIL_LENGTH / 2)
                - (endstop_y + length);

            translate([endstop_x, endstop_y, z - e]) {
                cube([width, length, height + e]);
            }

            _nub(endstop_y - BATTERY_HOLDER_NUB_FIXTURE_DEPTH + e);

            for (x = [endstop_x, endstop_x + width - web_width]) {
                translate([x, endstop_y + length - e, z - e]) {
                    cube([web_width, web_length + e * 2, web_height + e]);
                }
            }
        }

        if (top) {
            _nub(batteries_position.y - battery_holder_wall - tolerance * 2);
        } else {
            _side_aligners();
            _back_hitch();
        }
    }

    module _disassembly_wedge_cavity(
        width = 10,
        height = FLATHEAD_SCREWDRIVER_POINT
    ) {
        translate([
            knob_position.x - width / 2,
            dimensions.y - ENCLOSURE_WALL - e,
            bottom_height - height
        ]) {
            cube([width, ENCLOSURE_WALL + e * 2, height + e]);
        }
    }

    module _back_corner_reinforcements(clearance = 1) {
        width = pcb_position.x - ENCLOSURE_WALL - clearance;
        length = dimensions.y
            - get_switch_peripheral_y(switch_clutch_length_with_travel)
            - ENCLOSURE_WALL - switch_clutch_length_with_travel - clearance;

        y = dimensions.y - ENCLOSURE_WALL - length;
        z = bottom_height - lip_height;

        height = dimensions.z - z - ENCLOSURE_FLOOR_CEILING;

        for (x = [
            ENCLOSURE_WALL - e,
            dimensions.x - ENCLOSURE_WALL - width
        ]) {
            translate([x, y, z]) {
                cube([width + e, length + e, height + e]);
            }
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
                    difference() {
                        _half(bottom_height, lip = false);

                        color(cavity_color) {
                            _disassembly_wedge_cavity();
                        }
                    }

                    color(outer_color) {
                        difference() {
                            pcb_bottom_fixtures(
                                pcb_position = pcb_position,
                                pcb_screw_hole_positions =
                                    pcb_screw_hole_positions,
                                pcb_post_hole_positions =
                                    pcb_post_hole_positions,
                                screw_head_clearance = screw_head_clearance,
                                quick_preview = quick_preview
                            );

                            translate([
                                speaker_position.x,
                                speaker_position.y,
                                ENCLOSURE_FLOOR_CEILING - e
                            ]) {
                                cylinder(
                                    d = SPEAKER_DIAMETER + tolerance * 2,
                                    h = bottom_height,
                                    $fn = quick_preview ? undef : HIDEF_ROUNDING
                                );
                            }
                        }
                        _keys_mount_alignment_fixture(top = false);
                        _speaker_fixture();
                        _pencil_stand(false);
                        _battery_holder_fixtures(top = false);
                        _switch_clutch_aligners(bottom = true);
                        _pow_engraving_lip_reinforcement(cavity = false);
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
                            _uart_header_exposure(just_assembly_valley = true);
                            _headphone_jack_cavity(just_assembly_valley = true);
                            _switch_exposure(just_assembly_valley = true);
                            _pow_engraving_lip_reinforcement(cavity = true);
                        }
                    }

                    color(outer_color) {
                        _knob_exposure(false);
                        _keys_mount_alignment_fixture(top = true);
                        _keys_mount_nut_lock_rail();
                        key_lip_endstop(
                            keys_cavity_height_z
                                = dimensions.z - keys_cavity_height,
                            keys_full_width = keys_full_width,
                            key_gutter = key_gutter
                        );
                        _led_exposure(cavity = false);
                        pcb_enclosure_top_fixtures(
                            pcb_position = pcb_position,
                            enclosure_dimensions = dimensions
                        );
                        _battery_holder_fixtures(top = true);
                        _switch_clutch_aligners(bottom = false);
                        _back_corner_reinforcements();
                    }
                }
            }

            color(cavity_color) {
                _keys_exposure();
                _branding();
                _knob_exposure(true);
                _bottom_engraving();
                _uart_header_exposure();
                _headphone_jack_cavity();
                _pencil_stand(true);
                _led_exposure(cavity = true);
                _switch_exposure();

                enclosure_screw_cavities(
                    screw_head_clearance = screw_head_clearance,
                    pcb_position = pcb_position,
                    pcb_screw_hole_positions = pcb_screw_hole_positions,
                    tolerance = tolerance,
                    pcb_hole_diameter = PCB_HOLE_DIAMETER,
                    show_dfm = show_dfm,
                    quick_preview = quick_preview
                );
            }
        }
    }
}
