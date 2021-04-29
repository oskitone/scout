/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/basic_shapes.scad>;

include <scout_pcb.scad>;
use <enclosure_engraving.scad>;
include <keys.scad>;
use <utils.scad>;

/* TODO: extract */
ENCLOSURE_WALL = 2.4;
ENCLOSURE_FLOOR_CEILING = 1.8;
ENCLOSURE_INNER_WALL = 1.2;

ENCLOSURE_TO_PCB_CLEARANCE = 2;

/* TODO: extract into common parts repo */
SCREW_HEAD_DIAMETER = 6;
SCREW_HEAD_HEIGHT = 2.1;
NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

DEFAULT_TOLERANCE = .1;

module scout(
    show_keys = true,
    show_pcb = true,
    show_accoutrements = true,
    show_enclosure_stub = true,

    pot_label_text_size = 3.2,
    pot_label_length = 5,

    accidental_key_recession = 2,
    key_lip_exposure = 4, // should be comfortably over ~2 travel

    knob_top_exposure = 10,
    knob_radius = 10,

    lightpipe_recession = 2,

    tolerance = 0,
    quick_preview = true
) {
    e = .0432;

    keys_mount_length = 5;
    key_to_pcb_x_offset = ((key_width - 6) / 2 - key_gutter);
    pcb_key_mount_y = PCB_HOLE_POSITIONS[0][1] - keys_mount_length / 2;

    pcb_x = ENCLOSURE_WALL + key_to_pcb_x_offset + key_gutter;
    pcb_y = ENCLOSURE_WALL + key_gutter + key_length - pcb_key_mount_y; // key_length - PCB_LENGTH + mount_length + ENCLOSURE_WALL + key_gutter;
    pcb_z = ENCLOSURE_FLOOR_CEILING + ENCLOSURE_TO_PCB_CLEARANCE;

    keys_x = pcb_x - key_to_pcb_x_offset;
    keys_y = pcb_y - key_length + pcb_key_mount_y;
    keys_z = pcb_z + PCB_HEIGHT + BUTTON_HEIGHT;

    label_distance = keys_x / 2;

    keys_full_width = (
        10 * key_width // TODO: derive natural key count
        + 9 * key_gutter // TODO: derive natural key count - 1
    );
    key_min_height = 4;

    // TODO: confirm label size, then remove
    pot_nudge = (
        (keys_y + key_length) - (pcb_y + PCB_POT_POSITION.y - knob_radius)
        + label_distance
        + pot_label_length
        + keys_x
    );
    echo("pot_nudge", pot_nudge);

    echo(
        (branding_y + branding_length / 2) -
        (pcb_y + PCB_LED_POSITION.y)
    );

    enclosure_width = (
        keys_x * 2 + keys_full_width
    );
    enclosure_length = max(
        keys_y + key_length
            + PCB_LENGTH - pcb_key_mount_y
            + ENCLOSURE_TO_PCB_CLEARANCE
            + ENCLOSURE_WALL,
        pcb_y + PCB_POT_POSITION.y + knob_radius + keys_x
    );
    enclosure_height = max(
        keys_z + key_min_height + accidental_height + accidental_key_recession,
        pcb_z + PCB_HEIGHT + PTV09A_POT_BASE_HEIGHT + PTV09A_POT_ACTUATOR_HEIGHT
            - knob_top_exposure
    );

    key_height = enclosure_height - keys_z - accidental_height
        - accidental_key_recession;

    knob_z = pcb_z + PCB_HEIGHT + PTV09A_POT_BASE_HEIGHT;
    knob_height = enclosure_height - knob_z + knob_top_exposure;

    lightpipe_width = (pcb_x + PCB_LED_POSITION.x - keys_x) * 2;
    lightpipe_x = keys_x;

    branding_x = keys_x * 2 + lightpipe_width;
    branding_y = keys_y + key_length + keys_x;
    branding_length = enclosure_length - branding_y - keys_x;

    echo("Enclosure", [enclosure_width, enclosure_length, enclosure_height]);
    echo("Knob", [knob_radius * 2, knob_height]);

    module _enclosure_stub() {
        keys_cavity_height = min(
            accidental_key_recession + accidental_height + key_lip_exposure,
            enclosure_height - keys_z
        );

        vertical_clearance = 1;
        xy_clearance = 1;

        difference() {
            color("#FF69B4") {
                rounded_cube(
                    [enclosure_width, enclosure_length, enclosure_height],
                    radius = quick_preview ? 0 : 2,
                    $fn = 24
                );
            }

            color("#cc5490") {
                translate([
                    keys_x - key_gutter,
                    -e,
                    enclosure_height - keys_cavity_height
                ]) {
                    cube([
                        keys_full_width + key_gutter * 2,
                        keys_y + key_length + tolerance * 2,
                        keys_cavity_height + e
                    ]);
                }

                enclosure_engraving(
                    string = "SCOUT",
                    size = branding_length / 2,
                    position = [
                        branding_x,
                        branding_y
                    ],
                    quick_preview = quick_preview,
                    enclosure_height = enclosure_height
                );

                // TODO: swap for proper branding
                translate([0, , 0]) {
                    enclosure_engraving(
                        string = "OSKITONE",
                        font = "Work Sans:style=Black",
                        size = branding_length / 2 - label_distance,
                        position = [
                            branding_x,
                            branding_y + branding_length / 2 + label_distance
                        ],
                        quick_preview = quick_preview,
                        enclosure_height = enclosure_height
                    );
                }

                translate([
                    lightpipe_x - tolerance,
                    branding_y,
                    pcb_z + PCB_HEIGHT - e
                ]) {
                    cube([
                        lightpipe_width + tolerance * 2,
                        branding_length,
                        enclosure_height
                    ]);
                }

                translate([
                    pcb_x + PCB_POT_POSITION.x,
                    pcb_y + PCB_POT_POSITION.y,
                    0
                ]) {
                    translate([0, 0, knob_z - vertical_clearance]) {
                        cylinder(
                            r = knob_radius, // TODO: xy_clearance + tolerance,
                            h = enclosure_height
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
                        enclosure_height = enclosure_height
                    );
                }

                translate([
                    ENCLOSURE_WALL, ENCLOSURE_WALL, ENCLOSURE_FLOOR_CEILING
                ]) {
                    cube([
                        enclosure_width - ENCLOSURE_WALL * 2,
                        enclosure_length - ENCLOSURE_WALL * 2,
                        enclosure_height - ENCLOSURE_FLOOR_CEILING * 2
                    ]);
                }
            }
        }
    }

    module _accoutrements() {
        lightpipe_z = pcb_z + PCB_HEIGHT;

        translate([
            lightpipe_x + tolerance,
            branding_y + tolerance,
            pcb_z + PCB_HEIGHT
        ]) {
            # cube([
                lightpipe_width - tolerance * 2,
                branding_length - tolerance * 2,
                enclosure_height - lightpipe_z - lightpipe_recession
            ]);
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
    }

    if (show_keys) {
        e_translate([keys_x, keys_y, keys_z], [0, 0, -1]) {
            keys(
                keys_count = 17,
                starting_natural_key_index = 0,
                key_height = key_height,
                tolerance = tolerance,
                quick_preview = quick_preview
            );
        }
    }

    if (show_pcb) {
        e_translate([pcb_x, pcb_y, pcb_z]) {
            scout_pcb();
        }
    }

    if (show_enclosure_stub) {
        _enclosure_stub();
    }

    if (show_accoutrements) {
        _accoutrements();
    }
}

SHOW_KEYS = true;
SHOW_PCB = true;

scout(
    show_keys = SHOW_KEYS,
    show_pcb = SHOW_PCB,
    show_accoutrements = true,
    show_enclosure_stub = true,

    tolerance = DEFAULT_TOLERANCE,
    quick_preview = $preview
);
