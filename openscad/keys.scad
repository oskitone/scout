/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/keys.scad>;
use <../../poly555/openscad/lib/utils.scad>;

include <nuts_and_bolts.scad>;
include <utils.scad>;

// NOTE: this is knowingly less than NUT_DIAMETER
keys_mount_length = 5;

key_plot = 2.54 * 3;
key_gutter = 1;

accidental_height = 2;

cantilever_height = 2;

function get_key_to_pcb_x_offset(
    key_width,
    key_gutter = key_gutter
) = ((key_width - 6) / 2 - key_gutter);

function get_keys_full_width(
    key_width,
    key_gutter = key_gutter
) = (
    10 * key_width // TODO: derive natural key count
    + 9 * key_gutter // TODO: derive natural key count - 1
);

function get_keys_to_enclosure_distance(tolerance = 0) = (
    key_gutter - tolerance * 2
);

function get_keys_mount_rail_width(tolerance, key_width) = (
    get_keys_full_width(key_width)
    + get_keys_to_enclosure_distance(tolerance) * 2
);

module keys_mount_alignment_fixture(
    height,
    cavity,
    key_width,
    tolerance = 0,

    fixture_width = 1,
    fixture_length = 2
) {
    e = .0825;

    x_bleed = cavity ? 0 : tolerance + e;

    fixture_width = cavity
        ? fixture_width + tolerance
        : fixture_width + x_bleed - tolerance;
    fixture_length = cavity
        ? fixture_length + tolerance
        : fixture_length - tolerance * 2;

    xs = [
        -e - x_bleed,
        get_keys_mount_rail_width(tolerance, key_width)
            - fixture_width + x_bleed
    ];

    for (x = xs) {
        y = (keys_mount_length - fixture_length) / 2;
        translate([x, y, -e]) {
            cube([fixture_width + e, fixture_length, height + e * 2]);
        }
    }
}

module keys_mount_rail(
    height,
    key_width,
    key_length,
    front_y_bleed = 0,
    include_alignment_fixture = true,
    tolerance = 0
) {
    keys_to_enclosure_distance = get_keys_to_enclosure_distance(tolerance);

    translate([-keys_to_enclosure_distance, key_length - front_y_bleed, 0]) {
        difference() {
            cube([
                get_keys_mount_rail_width(tolerance, key_width),
                keys_mount_length + front_y_bleed,
                height
            ]);

            translate([
                get_key_to_pcb_x_offset(key_width) + keys_to_enclosure_distance,
                keys_mount_length / 2 + front_y_bleed,
                0
            ]) {
                scout_pcb_holes(
                    y = 0,
                    height = height
                );
            }

            if (include_alignment_fixture) {
                translate([0, front_y_bleed, 0]) {
                    keys_mount_alignment_fixture(
                        height = height,
                        key_width = key_width,
                        cavity = true,
                        tolerance = tolerance
                    );
                }
            }
        }
    }
}

module keys(
    key_height = 7,
    tolerance = 0,

    cantilever_length = 0,
    cantilever_height = 0,
    nut_lock_floor = 0,

    keys_count = 17,
    starting_natural_key_index = 0,

    keys_position = [],
    pcb_position = [],

    keys_cavity_height_z,
    key_width,
    key_length,
    travel = 0,

    accidental_color = "#444",
    natural_color = "#fff",
    natural_color_cavity = "#eee",

    quick_preview = true,
    show_clearance = false
) {
    e = .0234;

    module _keys(
        include_natural = false,
        include_accidental = false,
        include_cantilevers = false
    ) {
        mounted_keys(
            count = keys_count,
            starting_natural_key_index = starting_natural_key_index,

            natural_length = key_length,
            natural_width = key_width,
            natural_height = key_height,

            accidental_width = key_plot * 2 * .5,
            accidental_length = key_length * 3/5,
            accidental_height = key_height + accidental_height,

            front_fillet = quick_preview ? 0 : 1.5,
            sides_fillet = quick_preview ? 0 : 1,

            gutter = key_gutter,

            include_mount = false,
            include_natural = include_natural,
            include_accidental = include_accidental,
            include_cantilevers = include_cantilevers,

            cantilever_length = cantilever_length,
            cantilever_height = cantilever_height,
            cantilever_recession = cantilever_length
        );
    }

    difference() {
        union() {
            e_translate(keys_position, [0, 1, -1]) {
                color(accidental_color) {
                    _keys(
                        include_natural = false,
                        include_accidental = true,
                        include_cantilevers = true
                    );
                }
            }

            color(natural_color) {
                translate(keys_position) {
                    _keys(
                        include_natural = true,
                        include_accidental = false,
                        include_cantilevers = true
                    );

                    keys_mount_rail(
                        height = cantilever_height,
                        key_width = key_width,
                        key_length = key_length,
                        front_y_bleed = e,
                        tolerance = tolerance
                    );
                }
            }
        }

        color(natural_color_cavity) {
            nuts(
                pcb_position = pcb_position,
                z = keys_position.z + cantilever_height + nut_lock_floor,
                diameter = NUT_DIAMETER + tolerance * 2,
                height = NUT_HEIGHT,
                chamfer_top = true
            );

            key_lip_endstop(
                keys_cavity_height_z,
                keys_full_width = get_keys_full_width(key_width),
                distance_into_keys_bleed = tolerance * 4,
                travel = travel
            );
        }
    }

    if (show_clearance) {
        translate([
            keys_position.x,
            keys_position.y,
            keys_position.z - travel
        ]) {
            % cube([
                get_keys_full_width(key_width),
                key_length + e,
                travel + e
            ]);
        }
    }
}
