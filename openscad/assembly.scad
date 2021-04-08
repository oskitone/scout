include <enclosure_bottom.scad>;
include <keyboard_matrix_pcb.scad>;
include <keys.scad>;
include <mounting_rail.scad>;
include <utils.scad>;

side_width = 1.2;
front_lip_length = side_width;

PCB_X = side_width + offset / 2 + key_gutter;
PCB_Y = key_length - PCB_LENGTH + mount_length + front_lip_length + key_gutter;
PCB_Z = 4; // TODO: derive

ENCLOSURE_WIDTH = PCB_X * 2 + PCB_WIDTH;
ENCLOSURE_LENGTH = front_lip_length + key_gutter + key_length + mount_length;

DEFAULT_TOLERANCE = .1;

module assembly(
    show_keys = true,
    show_mounting_rail = true,
    show_pcb = true,
    show_enclosure_bottom = true,

    tolerance = 0,
    quick_preview = true
) {
    if (show_keys) {
        keys_with_nut_locking_mount(
            tolerance = tolerance,
            quick_preview = quick_preview
        );
    }

    if (show_pcb) {
        e_translate([PCB_X, PCB_Y, PCB_Z]) {
            keyboard_matrix_pcb();
        }
    }

    if (show_enclosure_bottom) {
        enclosure_bottom();
    }

    if (show_mounting_rail) {
        mounting_rail_with_header_cavity();
    }
}

assembly(
    show_keys = true,
    show_mounting_rail = true,
    show_pcb = true,
    show_enclosure_bottom = true,

    tolerance = DEFAULT_TOLERANCE,
    quick_preview = $preview
);
