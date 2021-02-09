include <keyboard_matrix_pcb.scad>;
include <keys.scad>;
include <mounting_rail.scad>;

side_width = 5;

PCB_X = side_width + offset / 2 + key_gutter;
PCB_Y = key_length - PCB_LENGTH + mount_length;
PCB_Z = 4;

module assembly(
    tolerance = 0,
    quick_preview = true
) {
    mounting_rails(
        side_width = side_width,
        tolerance = tolerance
    );

    translate([PCB_X, PCB_Y, PCB_Z]) {
        keys(
            tolerance = tolerance,
            quick_preview = quick_preview
        );
        keyboard_matrix_pcb();
    }
}

assembly(
    tolerance = .1,
    quick_preview = true
);
