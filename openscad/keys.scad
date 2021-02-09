/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/keys.scad>;
use <../../poly555/openscad/lib/utils.scad>;

include <keyboard_matrix_pcb.scad>;

key_plot = 2.54 * 3;
key_gutter = 1;

key_width = key_plot * 2 - key_gutter;
key_length = 50;
key_height = 7;

mount_length = 8;

accidental_height = 2;

keys_count = 20;
starting_natural_key_index = 3;

mount_width = get_keys_total_width(
    count = keys_count,
    starting_note_index = 0,
    natural_width = key_width,
    gutter = key_gutter
);
offset = mount_width - PCB_WIDTH;
echo(offset);

module _mounted_keys(
    include_mount = false,
    include_natural = false,
    include_accidental = false,
    include_cantilevers = false,

    mount_height = key_height,

    tolerance = 0,

    quick_preview = true
) {
    y = PCB_LENGTH - key_length - mount_length;

    translate([offset / -2, y, PCB_HEIGHT + BUTTON_HEIGHT]) {
        mounted_keys(
            count = keys_count,
            starting_natural_key_index = starting_natural_key_index,

            natural_length = key_length,
            natural_width = key_plot * 2 - key_gutter,
            natural_height = key_height,

            accidental_width = key_plot * 2 * .5,
            accidental_length = key_length * 3/5,
            accidental_height = key_height + accidental_height,

            front_fillet = quick_preview ? 0 : 2,
            sides_fillet = quick_preview ? 0 : 1,

            gutter = key_gutter,

            include_mount = include_mount,
            include_natural = include_natural,
            include_accidental = include_accidental,
            include_cantilevers = include_cantilevers,

            mount_length = mount_length,
            mount_height = mount_height,
            mount_hole_diameter = 3.2 + tolerance * 2,
            mount_screw_head_diameter = 4,
            mount_hole_xs = [
                PCB_HOLE_POSITIONS[0][0] + key_plot / 2,
                PCB_HOLE_POSITIONS[1][0] + key_plot / 2,
                PCB_HOLE_POSITIONS[2][0] + key_plot / 2,
                PCB_HOLE_POSITIONS[3][0] + key_plot / 2,
            ],

            cantilever_length = 4,
            cantilever_height = 2,
            cantilever_recession = 4 - .1 * 2 // TODO: extract
        );
    }
}

module keys(
    tolerance = 0,
    quick_preview = true
) {
    color("black") _mounted_keys(
        include_mount = false,
        include_natural = false,
        include_accidental = true,
        include_cantilevers = false,
        tolerance = tolerance,
        quick_preview = quick_preview
    );

    color("white") _mounted_keys(
        include_mount = true,
        include_natural = true,
        include_accidental = false,
        include_cantilevers = true,
        tolerance = tolerance,
        quick_preview = quick_preview
    );
}
