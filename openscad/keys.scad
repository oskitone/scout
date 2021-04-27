/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/keys.scad>;
use <../../poly555/openscad/lib/utils.scad>;

include <utils.scad>;

key_plot = 2.54 * 3;
key_gutter = 1;

key_width = key_plot * 2 - key_gutter;
key_length = 50;

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

module keys(
    keys_count = keys_count,
    starting_natural_key_index = starting_natural_key_index,
    key_height = 7,
    tolerance = 0,
    cantilever_length = 0,
    cantilever_height = 0,
    quick_preview = true
) {
    e = .0234;

    module _keys(
        include_natural = false,
        include_accidental = false,
        include_cantilevers = false
    ) {
        y = PCB_LENGTH - key_length - mount_length;

        mounted_keys(
            count = keys_count,
            starting_natural_key_index = starting_natural_key_index,

            natural_length = key_length,
            natural_width = key_width,
            natural_height = key_height,

            accidental_width = key_plot * 2 * .5,
            accidental_length = key_length * 3/5,
            accidental_height = key_height + accidental_height,

            remove_empty_space = !quick_preview,
            // based on .2 SPEED PrusaSlicer settings
            wall = .8,
            ceiling = 1,
            bottom = .8,

            front_fillet = quick_preview ? 0 : 2,
            sides_fillet = quick_preview ? 0 : 1,

            gutter = key_gutter,

            include_mount = false,
            include_natural = include_natural,
            include_accidental = include_accidental,
            include_cantilevers = include_cantilevers,

            cantilever_length = cantilever_length,
            cantilever_height = cantilever_height,
            cantilever_recession = cantilever_length - .1 * 2 // TODO: extract
        );
    }

    e_translate(direction = [0, 1, -1]) {
        color("black") _keys(
            include_natural = false,
            include_accidental = true,
            include_cantilevers = true
        );
    }

    color("white") _keys(
        include_natural = true,
        include_accidental = false,
        include_cantilevers = true
    );
}
