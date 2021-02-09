/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/keys.scad>;

include <keyboard_matrix_pcb.scad>;
include <keys.scad>;
include <mounting_rail.scad>;

module assembly(
    tolerance = 0,
    quick_preview = true
) {
    keys(
        tolerance = tolerance,
        quick_preview = quick_preview
    );
    mounting_rail(tolerance = tolerance);
    keyboard_matrix_pcb();
}

assembly(
    tolerance = .1,
    quick_preview = true
);
