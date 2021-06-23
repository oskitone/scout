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

    pcb_position = [],

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
    batteries_position = [],

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

    show_dfm = false,
    raft_height = DEFAULT_DFM_LAYER_HEIGHT,

    tolerance = 0,

    outer_color = undef,
    cavity_color = undef,

    quick_preview = true
) {
    e = .0345;

    /* NOTES:
        * Top needs to be sturdy enough to enforce key_lip_endstop
        * Division cut should go through back/side cavities w/o looking too
          awkward or inhibiting assembly
        * Bottom matches to top of PCB, otherwise will need to account for
          corner fixtures' cavity on enclosure top
     */
    bottom_height = pcb_position.z + lip_height + PCB_HEIGHT;
    top_height = dimensions.z - bottom_height;

    branding_available_width = dimensions.x
        - branding_position.x
        - knob_radius * 2
        - default_gutter * 2;
    branding_available_length = dimensions.y - branding_position.y
        - default_gutter;
    branding_gutter = label_distance;

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
            tongue_and_groove_snap = [.75, .25],
            tolerance = tolerance,
            outer_color = outer_color,
            cavity_color = cavity_color,
            $fn = quick_preview ? undef : DEFAULT_ROUNDING
        );
    }

    module _keys_exposure(
        y_tolerance_against_enclosure = 0, // intentionally snug
        raft_radius = key_length * .5
    ) {
        width = keys_full_width + key_gutter * 2 - e * 2;

        x = keys_position.x - key_gutter + e;
        z = dimensions.z - keys_cavity_height;

        module _rafts() {
            for (_x = [x, dimensions.x - x]) {
                translate([_x, 0, dimensions.z - raft_height]) {
                    scale([1, .5, 1]) {
                        cylinder(r = raft_radius, h = raft_height + e);
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
        wall = BREAKAWAY_SUPPORT_DEPTH,
        raft_depth = 2
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
            translate([x - raft_depth, -raft_depth, dimensions.z - raft_height]) {
                cube([
                    width + raft_depth * 2,
                    connection_length + raft_depth * 2,
                    raft_height
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
        shaft_clearance = 2 // TODO: reduce when correct pots are in stock
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

    module _uart_header_exposure(
        just_assembly_valley = false,
        x_bleed = 1,
        height = 4
    ) {
        pin_z = pcb_position.z + PCB_HEIGHT + 2.54 / 2;

        x = pcb_position.x + PCB_UART_HEADER_POSITION.x - x_bleed;
        z = pin_z + UART_HEADER_PIN_SIZE / 2 - height / 2;

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
                z = pin_z
            );
        }
    }

    module _keys_mount_alignment_fixture() {
        keys_to_enclosure_distance =
            get_keys_to_enclosure_distance(tolerance, key_gutter);
        z = bottom_height - lip_height;
        height = keys_position.z - z + cantilver_mount_height;

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
        plug_diameter = 10,
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

    SIDE_ENGRAVING_DEFAULT_WIDTH = 15;
    module _side_engraving(
        x = undef,
        y = undef,
        string,
        width = SIDE_ENGRAVING_DEFAULT_WIDTH,
        z = pcb_position.z - label_length / 2,
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
                    placard = placard ? [width, label_length] : undef,
                    chamfer_placard = true,
                    bottom = true,
                    quick_preview = quick_preview,
                    enclosure_height = dimensions.z
                );
            }
        }
    }

    module _switch_exposure(
        just_assembly_valley = false,
        bleed = tolerance + .2 // intentionally loose
    ) {
        length = SWITCH_CLUTCH_GRIP_LENGTH + SWITCH_ACTUATOR_TRAVEL + bleed * 2;
        height = SWITCH_CLUTCH_GRIP_HEIGHT + bleed * 2;

        y = pcb_position.y + PCB_SWITCH_POSITION.y - SWITCH_BASE_LENGTH / 2;
        z = pcb_position.z + PCB_HEIGHT + SWITCH_BASE_HEIGHT / 2 - height / 2;

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
        }
    }

    module _keys_mount_nut_lock_rail(
        nut_cavity_size = NUT_DIAMETER + tolerance * 2,
        nut_cavity_height = NUT_HEIGHT
    ) {
        z = keys_position.z + cantilver_mount_height;
        height = dimensions.z - z - ENCLOSURE_FLOOR_CEILING + e;

        module _nut_locks() {
            nuts(
                pcb_position = pcb_position,
                z = keys_position.z + cantilver_mount_height + nut_lock_floor,
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
        if (cavity) {
            translate([x, y, -e]) {
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
        chamfer_shroud_wall = 3,
        chamfer_shroud_height = 6,
        shade_depth = DEFAULT_DFM_LAYER_HEIGHT * 3,
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

    module _battery_holder_arm_fixtures() {
        _width = BATTERY_HOLDER_ARM_FIXTURE_WIDTH - tolerance * 2;
        _length = BATTERY_HOLDER_ARM_FIXTURE_DEPTH - tolerance;
        _height = BATTERY_HOLDER_ARM_FIXTURE_DEPTH - tolerance * 2;

        battery_holder_width =
            get_battery_holder_width(tolerance, battery_holder_wall);
        battery_holder_length =
            get_battery_holder_length(tolerance, battery_holder_wall);

        x = batteries_position.x
            + -(battery_holder_wall + tolerance)
            + (battery_holder_width - _width) / 2;

        nib_z = ENCLOSURE_FLOOR_CEILING + BATTERY_HOLDER_ARM_FIXTURE_Z
            + tolerance;

        module _front_nib() {
            y = batteries_position.y - battery_holder_wall - tolerance - e;

            translate([x, y, nib_z]) {
                cube([_width, _length + e, _height]);
            }
        }

        module _arm(
            arm_length = ENCLOSURE_INNER_WALL,
            support_depth = BATTERY_HOLDER_ARM_FIXTURE_Z * 2
        ) {
            y_gap = tolerance * 2;
            y = batteries_position.y - battery_holder_wall - tolerance
                + y_gap + battery_holder_length;
            z = ENCLOSURE_FLOOR_CEILING - e;

            arm_height = nib_z - z + _height;
            nib_support = y_gap + _length + tolerance + e * 2;

            translate([x, y, z]) {
                cube([_width, arm_length, arm_height]);

                translate([0, e, arm_height - nib_support - _height + e]) {
                    flat_top_rectangular_pyramid(
                        top_width = _width,
                        top_length = nib_support,
                        bottom_width = _width,
                        bottom_length = 0,
                        height = nib_support,
                        top_weight_y = 1
                    );
                }

                translate([0, -_length - y_gap - tolerance - e, arm_height - _height]) {
                    cube([_width, _length + y_gap + e * 2 + tolerance, _height]);
                }

                for (x = [0, _width - ENCLOSURE_INNER_WALL]) {
                    translate([x, arm_length - e, 0]) {
                        flat_top_rectangular_pyramid(
                            top_width = ENCLOSURE_INNER_WALL,
                            top_length = 0,
                            bottom_width = ENCLOSURE_INNER_WALL,
                            bottom_length = support_depth + e,
                            height = arm_height,
                            top_weight_y = 0
                        );
                    }
                }
            }
        }

        _front_nib();
        _arm();
    }

    module _battery_holder_aligners(
        width = ENCLOSURE_INNER_WALL,
        length = 4,
        height = bottom_height - ENCLOSURE_FLOOR_CEILING - lip_height,
        clearance = .2
    ) {
        battery_holder_width =
            get_battery_holder_width(tolerance, battery_holder_wall);

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
                        difference() {
                            pcb_bottom_fixtures(
                                pcb_position = pcb_position,
                                screw_head_clearance = screw_head_clearance
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
                        _speaker_fixture();
                        _pencil_stand(false);
                        _battery_holder_arm_fixtures();
                        _battery_holder_aligners();
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
                        pcb_enclosure_top_fixtures(
                            pcb_position = pcb_position,
                            enclosure_dimensions = dimensions,
                            height_extension =
                                abs(bottom_height - lip_height - pcb_position.z)
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
                _switch_exposure();
            }
        }
    }
}
