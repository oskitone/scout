/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/basic_shapes.scad>;

include <batteries.scad>;
include <scout_pcb.scad>;
include <enclosure.scad>;
include <keys.scad>;
include <speaker.scad>;
use <utils.scad>;

/* TODO: extract into common parts repo */
SCREW_HEAD_DIAMETER = 6;
SCREW_HEAD_HEIGHT = 2.1;
NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

DEFAULT_TOLERANCE = .1;

/* TODO: extract into common parts repo */
/* https://www.ckswitches.com/media/1428/os.pdf */
SWITCH_BASE_WIDTH = 4.4;
SWITCH_BASE_LENGTH = 8.7;
SWITCH_BASE_HEIGHT = 4.5;
SWITCH_ACTUATOR_WIDTH = 2;
SWITCH_ACTUATOR_LENGTH = 2.1;
SWITCH_ACTUATOR_HEIGHT = 3.8;
SWITCH_ACTUATOR_TRAVEL = 1.5;
SWITCH_ORIGIN = [SWITCH_BASE_WIDTH / 2, 6.36];

module scout(
    show_keys = true,
    show_pcb = true,
    show_accoutrements = true,
    show_enclosure_top = true,
    show_enclosure_bottom = true,

    accidental_key_recession = 2,
    key_lip_exposure = 4, // should be comfortably over ~2 travel

    knob_top_exposure = 10,
    knob_radius = 10,
    knob_vertical_clearance = 1,

    lightpipe_recession = 2,
    exposed_switch_clearance = 1,

    tolerance = 0,
    quick_preview = true
) {
    e = .0432;

    pcb_key_mount_y = PCB_HOLE_POSITIONS[0][1] - keys_mount_length / 2;

    keys_x = ENCLOSURE_WALL + key_gutter;
    default_gutter = keys_x;

    pcb_x = keys_x + key_to_pcb_x_offset;
    pcb_y = ENCLOSURE_WALL + key_gutter + key_length - pcb_key_mount_y;
    pcb_z = SWITCH_BASE_HEIGHT + SWITCH_ACTUATOR_HEIGHT
        + exposed_switch_clearance;

    keys_y = pcb_y - key_length + pcb_key_mount_y;
    keys_z = pcb_z + PCB_HEIGHT + BUTTON_HEIGHT;

    key_min_height = 4;

    enclosure_width = default_gutter * 2 + keys_full_width;
    enclosure_length = max(
        keys_y + key_length
            + PCB_LENGTH - pcb_key_mount_y
            + ENCLOSURE_TO_PCB_CLEARANCE
            + ENCLOSURE_WALL,
        pcb_y + PCB_POT_POSITION.y + knob_radius + default_gutter
    );
    enclosure_height = max(
        keys_z + key_min_height + accidental_height + accidental_key_recession,
        pcb_z + PCB_HEIGHT + PTV09A_POT_BASE_HEIGHT + PTV09A_POT_ACTUATOR_HEIGHT
            - knob_top_exposure
    );

    key_height = enclosure_height - keys_z - accidental_height
        - accidental_key_recession;

    knob_z = pcb_z + PCB_HEIGHT
        + PTV09A_POT_BASE_HEIGHT + PTV09A_POT_ACTUATOR_BASE_HEIGHT
        + knob_vertical_clearance + ENCLOSURE_FLOOR_CEILING;
    knob_height = enclosure_height - knob_z + knob_top_exposure;

    lightpipe_width = (pcb_x + PCB_LED_POSITION.x - default_gutter) * 2;
    lightpipe_x = default_gutter;

    branding_x = default_gutter * 2 + lightpipe_width;
    branding_y = keys_y + key_length + default_gutter;
    branding_length = enclosure_length - branding_y - default_gutter;

    speaker_x = pcb_x + PCB_WIDTH - SPEAKER_DIAMETER / 2;
    speaker_y = ENCLOSURE_WALL + SPEAKER_DIAMETER / 2 + tolerance;
    speaker_z = pcb_z - SPEAKER_HEIGHT - PCB_PIN_CLEARANCE;

    batteries_x = pcb_x;
    batteries_y = ENCLOSURE_WALL + tolerance;
    batteries_z = ENCLOSURE_FLOOR_CEILING;

    echo("Enclosure", [enclosure_width, enclosure_length, enclosure_height]);
    echo("Knob", [knob_radius * 2, knob_height]);

    module _accoutrements() {
        lightpipe_z = pcb_z + PCB_HEIGHT;

        translate([
            lightpipe_x + tolerance,
            branding_y + tolerance,
            pcb_z + PCB_HEIGHT
        ]) {
            color([0, 1, round($t)]) {
                cube([
                    lightpipe_width - tolerance * 2,
                    branding_length - tolerance * 2,
                    enclosure_height - lightpipe_z - lightpipe_recession
                ]);
            }
        }

        translate([
            pcb_x + PCB_POT_POSITION.x,
            pcb_y + PCB_POT_POSITION.y,
            knob_z
        ]) {
            # cylinder(
                r = knob_radius,
                h = knob_height
            );
        }

        translate([speaker_x, speaker_y, speaker_z - e]) {
            % speaker();
        }

        translate([batteries_x, batteries_y, batteries_z + e]) {
            % battery_array();
        }
    }

    if (show_keys) {
        e_translate([keys_x, keys_y, keys_z], [0, 0, -1]) {
            keys(
                key_height = key_height,
                tolerance = tolerance,

                cantilever_length = key_height - cantilever_height,
                cantilever_height = cantilever_height,

                quick_preview = quick_preview
            );
        }
    }

    if (show_pcb) {
        e_translate([pcb_x, pcb_y, pcb_z]) {
            scout_pcb();
        }
    }

    if (show_enclosure_top || show_enclosure_bottom) {
        enclosure(
            show_top = show_enclosure_top,
            show_bottom = show_enclosure_bottom,

            dimensions = [
                enclosure_width,
                enclosure_length,
                enclosure_height
            ],

            pcb_position = [pcb_x, pcb_y, pcb_z],

            keys_cavity_height = min(
                accidental_key_recession + accidental_height + key_lip_exposure,
                enclosure_height - keys_z
            ),
            keys_position = [keys_x, keys_y, keys_z],
            key_gutter = key_gutter,
            keys_full_width = keys_full_width,

            branding_length = branding_length,
            branding_position = [branding_x, branding_y],

            label_distance = default_gutter / 2,

            lightpipe_position = [lightpipe_x, branding_y],
            lightpipe_dimensions = [lightpipe_width, branding_length],

            knob_radius = knob_radius,
            knob_position = [
                pcb_x + PCB_POT_POSITION.x,
                pcb_y + PCB_POT_POSITION.y,
                knob_z
            ],
            knob_vertical_clearance = knob_vertical_clearance,

            speaker_position = [
                speaker_x,
                speaker_y,
                speaker_z
            ],

            batteries_position = [
                batteries_x,
                batteries_y,
                batteries_z
            ],

            tolerance = tolerance,

            quick_preview = quick_preview
        );
    }

    if (show_accoutrements) {
        _accoutrements();
    }
}

SHOW_KEYS = true;
SHOW_PCB = true;
SHOW_ACCOUTREMENTS = true;
SHOW_ENCLOSURE_TOP = true;
SHOW_ENCLOSURE_BOTTOM = true;

intersection() {
    scout(
        show_keys = SHOW_KEYS,
        show_pcb = SHOW_PCB,
        show_accoutrements = SHOW_ACCOUTREMENTS,
        show_enclosure_top = SHOW_ENCLOSURE_TOP,
        show_enclosure_bottom = SHOW_ENCLOSURE_BOTTOM,

        tolerance = DEFAULT_TOLERANCE,
        quick_preview = $preview
    );

    // switch and batteries
    /* translate([18.5, -10, -10]) { cube([200, 100, 100]); } */

    // screw mount
    /* translate([44, -10, -10]) { cube([200, 100, 100]); } */

    // speaker
    /* translate([130, -10, -10]) { cube([200, 100, 100]); } */

    // knob
    /* translate([-10, -10, -10]) { cube([155, 100, 100]); } */
}
