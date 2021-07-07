/* TODO: extract into common parts repo */
use <../../apc/openscad/wheels.scad>;
use <../../poly555/openscad/lib/basic_shapes.scad>;
use <../../poly555/openscad/lib/pencil_stand.scad>;

include <batteries.scad>;
include <battery_holder.scad>;
include <scout_pcb.scad>;
include <enclosure.scad>;
include <keys.scad>;
include <nuts_and_bolts.scad>;
include <speaker.scad>;
include <switch_clutch.scad>;
use <utils.scad>;

DEFAULT_TOLERANCE = .1;

module scout(
    show_enclosure_bottom = true,
    show_battery_holder = true,
    show_pcb = true,
    show_keys_mount_rail = true,
    show_keys = true,
    show_switch_clutch = true,
    show_enclosure_top = true,
    show_accoutrements = true,
    show_knob = true,

    show_dfm = false,
    show_clearances = true,

    cantilever_height = 2,
    cantilver_mount_height = 2,
    accidental_height = 2,
    accidental_key_recession = 0,
    key_lip_exposure = 3,
    key_travel = 3,
    key_gutter = 1,

    knob_top_exposure = 7,
    knob_radius = 10,
    knob_vertical_clearance = DEFAULT_DFM_LAYER_HEIGHT * 2,

    exposed_switch_clearance = 1,
    switch_clutch_web_length_extension = 2.1, // NOTE: eyeballed!

    enclosure_outer_color = "#FF69B4",
    enclosure_cavity_color = "#cc5490",

    battery_holder_wall = ENCLOSURE_INNER_WALL,
    battery_holder_floor = 1,

    min_screw_bottom_clearance = DEFAULT_DFM_LAYER_HEIGHT,
    min_screw_top_clearance = .8,
    nut_lock_floor = ENCLOSURE_FLOOR_CEILING,

    enclosure_lip_height = 3,

    switch_position = 1,

    tolerance = 0,
    quick_preview = true,

    flip_vertically = false,
    center = false
) {
    e = .0432;

    pcb_key_mount_y = PCB_HOLE_POSITIONS[0][1] - KEYS_MOUNT_LENGTH / 2;

    keys_x = ENCLOSURE_WALL + key_gutter;
    default_gutter = keys_x;

    key_width = PCB_KEY_PLOT * 2 - key_gutter;
    key_length = 50;
    key_min_height = 4;

    enclosure_width = default_gutter * 2
        + get_keys_full_width(key_width, key_gutter);

    speaker_x = enclosure_width - ENCLOSURE_WALL
        - tolerance - SPEAKER_DIAMETER / 2;
    speaker_y = ENCLOSURE_WALL + SPEAKER_DIAMETER / 2 + tolerance;
    speaker_z = ENCLOSURE_FLOOR_CEILING;

    pcb_x = keys_x + get_key_to_pcb_x_offset(key_width, key_gutter);
    pcb_y = ENCLOSURE_WALL + key_gutter + key_length - pcb_key_mount_y;
    pcb_z = max(
        ENCLOSURE_FLOOR_CEILING + battery_holder_floor + AAA_BATTERY_DIAMETER
            + key_travel - PCB_HEIGHT - BUTTON_HEIGHT,
        min_screw_bottom_clearance + SCREW_HEAD_HEIGHT
            + ENCLOSURE_FLOOR_CEILING + PCB_PIN_CLEARANCE,
        speaker_z + SPEAKER_HEIGHT + PCB_PIN_CLEARANCE
    );

    keys_y = pcb_y - key_length + pcb_key_mount_y;
    keys_z = pcb_z + PCB_HEIGHT + BUTTON_HEIGHT;

    enclosure_length = max(
        keys_y + key_length
            + PCB_LENGTH - pcb_key_mount_y
            + ENCLOSURE_WALL,
        pcb_y + PCB_POT_POSITION.y + knob_radius + default_gutter
    );
    enclosure_height = max(
        keys_z + key_min_height + accidental_height + accidental_key_recession,
        keys_z + cantilver_mount_height + nut_lock_floor + NUT_HEIGHT
            + min_screw_top_clearance + ENCLOSURE_FLOOR_CEILING,
        pcb_z + PCB_HEIGHT + PCB_CIRCUITRY_CLEARANCE + ENCLOSURE_FLOOR_CEILING,
        SCREW_LENGTH + min_screw_top_clearance + min_screw_bottom_clearance
            + ENCLOSURE_FLOOR_CEILING * 2
    );

    key_height = enclosure_height - keys_z - accidental_height
        - accidental_key_recession;

    knob_z = pcb_z + PCB_HEIGHT
        + PTV09A_POT_BASE_HEIGHT + PTV09A_POT_ACTUATOR_BASE_HEIGHT
        + knob_vertical_clearance + ENCLOSURE_FLOOR_CEILING;
    knob_height = enclosure_height - knob_z + knob_top_exposure;
    knob_dimple_y = knob_radius / 2;

    branding_x = default_gutter;
    branding_y = keys_y + key_length + default_gutter;

    // NOTE: these are eyeballed instead of derived and that's okay!!
    pencil_stand_x = 20;
    pencil_stand_y = ENCLOSURE_WALL + (pcb_y - ENCLOSURE_WALL) / 2;
    pencil_stand_angle_x = -52;
    pencil_stand_angle_y = 10;
    pencil_stand_depth = 12.8;

    batteries_x = pcb_x
        + PCB_RELIEF_HOLE_POSITIONS[0].x
        + (PCB_RELIEF_HOLE_POSITIONS[1].x - PCB_RELIEF_HOLE_POSITIONS[0].x) / 2
        + (tolerance + battery_holder_wall)
        - get_battery_holder_width(tolerance, battery_holder_wall) / 2;
    batteries_y = ENCLOSURE_WALL + ENCLOSURE_INNER_WALL + tolerance * 2;
    batteries_z = ENCLOSURE_FLOOR_CEILING + battery_holder_floor;

    nut_z = keys_z + cantilver_mount_height + nut_lock_floor;
    screw_top_clearance = enclosure_height
        - ENCLOSURE_FLOOR_CEILING - (nut_z + NUT_HEIGHT);
    screw_head_clearance = max(
        min_screw_bottom_clearance,
        nut_z - SCREW_HEAD_HEIGHT - SCREW_LENGTH + NUT_HEIGHT
            + screw_top_clearance / 2
    );

    keys_cavity_height = min(
        accidental_key_recession + accidental_height + key_lip_exposure,
        enclosure_height - keys_z
    );


    /* NOTES:
        * Top needs to be sturdy enough to enforce key_lip_endstop
        * Division cut should go through back/side cavities w/o looking too
          awkward or inhibiting assembly
          * And cavity engraving/reach depths must not be so deep as to get
            messed up by tongue/groove
        * Bottom matches to top of PCB, otherwise will need to account for
          corner fixtures' cavity on enclosure top
     */
    enclosure_bottom_height = pcb_z + enclosure_lip_height + PCB_HEIGHT;
    enclosure_top_height = enclosure_height - enclosure_bottom_height;

    echo(
        "Enclosure",
        [enclosure_width, enclosure_length, enclosure_height],
        [enclosure_bottom_height, enclosure_top_height]
    );
    echo("Keys", [key_width, key_length, key_height]);
    echo("Knob", [knob_radius * 2, knob_height]);
    echo("Screw clearance", screw_top_clearance, screw_head_clearance);

    module _knob() {
        top_of_knob = (knob_z + knob_height);
        top_of_pot_actuator = pcb_z + PCB_HEIGHT
            + PTV09A_POT_BASE_HEIGHT + PTV09A_POT_ACTUATOR_HEIGHT;

        translate([
            pcb_x + PCB_POT_POSITION.x,
            pcb_y + PCB_POT_POSITION.y,
            knob_z
        ]) {
            wheel(
                diameter = knob_radius * 2,
                height = knob_height,
                hub_ceiling = top_of_knob - top_of_pot_actuator,
                spokes_count = 0,
                brodie_knob_count = 0,
                dimple_count = 1,
                dimple_depth = ENCLOSURE_ENGRAVING_DEPTH,
                dimple_y = knob_dimple_y,
                color = "#fff",
                cavity_color = "#eee",
                tolerance = tolerance,
                $fn = quick_preview ? undef : DEFAULT_ROUNDING
            );
        }
    }

    module _accoutrements() {
        translate([speaker_x, speaker_y, speaker_z - e]) {
            % speaker();
        }

        translate([batteries_x, batteries_y, batteries_z + e]) {
            % battery_array();
            % # battery_contacts(
                tolerance = tolerance,
                show_tabs = false,
                end_terminal_bottom_right = false
            );
        }

        % nuts(
            pcb_position = [pcb_x, pcb_y, pcb_z],
            z = nut_z
        );

        % screws(
            pcb_position = [pcb_x, pcb_y, pcb_z],
            z = screw_head_clearance
        );

        translate([pencil_stand_x, pencil_stand_y, 0]) {
            * % pencil_stand_pencil(
                wall = ENCLOSURE_INNER_WALL,
                depth = pencil_stand_depth,
                angle_x = pencil_stand_angle_x,
                angle_y = pencil_stand_angle_y
            );
        }
    }

    module _switch_clutch() {
        x = pcb_x + PCB_SWITCH_POSITION.x;
        y = pcb_y + PCB_SWITCH_POSITION.y;

        translate([x, y]) {
            switch_clutch(
                position = switch_position,

                web_available_width = pcb_x - ENCLOSURE_WALL,
                web_length_extension = switch_clutch_web_length_extension,
                enclosure_height = enclosure_height,

                tolerance = tolerance,

                outer_color = "#fff",
                cavity_color = "#eee",

                show_dfm = show_dfm,
                quick_preview = quick_preview
            );
        }
    }

    module _battery_holder(
        outer_color = enclosure_outer_color,
        cavity_color = enclosure_cavity_color
    ) {
        difference() {
            e_translate([batteries_x, batteries_y, batteries_z]) {
                battery_holder(
                    wall = battery_holder_wall,
                    floor = battery_holder_floor,
                    fillet = quick_preview ? 0 : ENCLOSURE_INNER_FILLET,
                    tolerance = tolerance + e,
                    end_terminal_bottom_right = false,
                    outer_color = outer_color,
                    cavity_color = cavity_color,
                    back_hitch_length = 4, // TODO: derive
                    back_hitch_height =
                        pcb_z - ENCLOSURE_FLOOR_CEILING + PCB_HEIGHT - e,
                    quick_preview = quick_preview
                );
            }

            color(cavity_color) {
                _fixture_pcb_difference(pcb_position = [pcb_x, pcb_y, pcb_z]);
            }
        }
    }

    module _output() {
        if (show_keys) {
            // TODO: experiment with arbitrary lengths:
            POLY555_CANTILEVER_LENGTH = 3;
            20_KEY_MATRIX_CANTILEVER_LENGTH = 4;
            unexposed_cantilever_length = key_height - cantilver_mount_height;
            cantilever_length = unexposed_cantilever_length;

            keys(
                key_height = key_height,
                accidental_height = accidental_height,
                tolerance = tolerance,

                cantilever_length = cantilever_length,
                cantilever_height = cantilever_height,
                cantilver_mount_height = cantilver_mount_height,
                nut_lock_floor = nut_lock_floor,

                keys_position = [keys_x, keys_y, keys_z],
                pcb_position = [pcb_x, pcb_y, pcb_z],

                keys_cavity_height_z = enclosure_height - keys_cavity_height,
                key_width = key_width,
                key_length = key_length,
                travel = key_travel,
                key_gutter = key_gutter,

                quick_preview = quick_preview,
                show_clearance = show_clearances
            );
        }

        if (show_pcb) {
            e_translate([pcb_x, pcb_y, pcb_z]) {
                scout_pcb(
                    show_circuitry_clearance = show_clearances,
                    switch_position = switch_position
                );
            }
        }

        if (show_keys_mount_rail) {
            translate([keys_x, keys_y, pcb_z + PCB_HEIGHT]) {
                color(enclosure_outer_color) {
                    keys_mount_rail(
                        height = BUTTON_HEIGHT,
                        key_width = key_width,
                        key_length = key_length,
                        key_gutter = key_gutter,
                        front_y_bleed = 0,
                        tolerance = tolerance
                    );
                }
            }
        }

        if (show_enclosure_top || show_enclosure_bottom) {
            enclosure(
                show_top = show_enclosure_top,
                show_bottom = show_enclosure_bottom,

                default_gutter = default_gutter,

                dimensions = [
                    enclosure_width,
                    enclosure_length,
                    enclosure_height
                ],
                bottom_height = enclosure_bottom_height,
                top_height = enclosure_top_height,

                pcb_position = [pcb_x, pcb_y, pcb_z],

                keys_cavity_height = keys_cavity_height,
                keys_position = [keys_x, keys_y, keys_z],
                key_gutter = key_gutter,
                keys_full_width = get_keys_full_width(key_width, key_gutter),
                key_width = key_width,
                key_length = key_length,

                cantilver_mount_height = cantilver_mount_height,

                branding_position = [branding_x, branding_y],

                label_distance = default_gutter / 2,

                knob_radius = knob_radius,
                knob_dimple_y = knob_dimple_y,
                knob_position = [
                    pcb_x + PCB_POT_POSITION.x,
                    pcb_y + PCB_POT_POSITION.y,
                    knob_z
                ],
                knob_vertical_clearance = knob_vertical_clearance,

                speaker_position = [speaker_x, speaker_y, speaker_z],

                battery_holder_wall = battery_holder_wall,
                battery_holder_floor = battery_holder_floor,
                batteries_position = [batteries_x, batteries_y, batteries_z],

                pencil_stand_position = [pencil_stand_x, pencil_stand_y],
                pencil_stand_angle_x = pencil_stand_angle_x,
                pencil_stand_angle_y = pencil_stand_angle_y,
                pencil_stand_depth = pencil_stand_depth,

                lip_height = enclosure_lip_height,

                screw_head_clearance = screw_head_clearance,
                nut_lock_floor = nut_lock_floor,

                switch_clutch_web_length_extension
                    = switch_clutch_web_length_extension,

                show_dfm = show_dfm,

                tolerance = tolerance,

                outer_color = enclosure_outer_color,
                cavity_color = enclosure_cavity_color,

                quick_preview = quick_preview
            );
        }

        if (show_battery_holder) {
            _battery_holder();
        }

        if (show_accoutrements) {
            _accoutrements();
        }

        if (show_knob) {
            _knob();
        }

        if (show_switch_clutch) {
            _switch_clutch();
        }
    }

    rotation = FLIP_VERTICALLY ? [0, 180, 0] : [0, 0, 0];
    position = center
        ? [enclosure_width / -2, enclosure_length / -2, enclosure_height / -2]
        : [0, 0, 0];

    rotate(rotation) translate(position) {
        _output();
    }
}

SHOW_ENCLOSURE_BOTTOM = true;
SHOW_BATTERY_HOLDER = true;
SHOW_PCB = true;
SHOW_KEYS_MOUNT_RAIL = true;
SHOW_KEYS = true;
SHOW_SWITCH_CLUTCH = true;
SHOW_ENCLOSURE_TOP = true;
SHOW_ACCOUTREMENTS = true;
SHOW_KNOB = true;

SHOW_DFM = false;
SHOW_CLEARANCES = true;

CENTER = false;
FLIP_VERTICALLY = false;
QUICK_PREVIEW = $preview;

intersection() {
    scout(
        show_enclosure_bottom = SHOW_ENCLOSURE_BOTTOM,
        show_battery_holder = SHOW_BATTERY_HOLDER,
        show_pcb = SHOW_PCB,
        show_keys_mount_rail = SHOW_KEYS_MOUNT_RAIL,
        show_keys = SHOW_KEYS,
        show_enclosure_top = SHOW_ENCLOSURE_TOP,
        show_accoutrements = SHOW_ACCOUTREMENTS,
        show_knob = SHOW_KNOB,
        show_switch_clutch = SHOW_SWITCH_CLUTCH,

        show_dfm = SHOW_DFM,
        show_clearances = SHOW_CLEARANCES,

        tolerance = DEFAULT_TOLERANCE,
        quick_preview = QUICK_PREVIEW,

        flip_vertically = FLIP_VERTICALLY,
        center = CENTER
    );

    // LED
    /* translate([-10, -10, -10]) { cube([138.4, 120, 100]); } */

    // switch
    /* translate([18.5, -10, -10]) { cube([200, 120, 100]); } */

    // batteries
    /* translate([80, -10, -10]) { cube([200, 120, 100]); } */

    // screw mount
    /* translate([10.3, -10, -10]) { cube([200, 120, 100]); } */

    // speaker
    /* translate([130, -10, -10]) { cube([200, 120, 100]); } */

    // knob
    /* translate([-10, -10, -10]) { cube([155, 120, 100]); } */

    // line out
    /* translate([-10, -10, -10]) { cube([122, 120, 100]); } */

    // pencil stand
    /* translate([-10, 20, -10]) { cube([200, 120, 100]); } */

    // switch_clutch
    /* translate([-10, 65, -10]) { cube([200, 120, 100]); } */
}
