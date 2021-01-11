/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/keys.scad>;

module assembly(
    quick_preview = true,
    tolerance = .1
) {
    key_plot = 2.54 * 3;
    key_gutter = 1;

    key_length = 50;
    key_height = 7;
    accidental_height = 2;

    mount_length = 6;

    e = .009;

    module _mounted_keys(
        include_mount = false,
        include_natural = false,
        include_accidental = false,
        include_cantilevers = false,

        mount_height = key_height
    ) {
        y = 22.1 - key_length - mount_length / 2;

        translate([key_plot / -2, y, 1.6 + 6]) {
            mounted_keys(
                count = 13,

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
                mount_hole_xs = [key_plot, key_plot * 8, key_plot * 15],
                /* mount_hole_xs = [3.9, 57.7, 110.6], */

                cantilever_length = 4,
                cantilever_height = 2,
                cantilever_recession = 4 - tolerance * 2
            );
        }
    }

    module _keys() {
        color("black") _mounted_keys(
            include_mount = false,
            include_natural = false,
            include_accidental = true,
            include_cantilevers = false
        );
        color("white") _mounted_keys(
            include_mount = true,
            include_natural = true,
            include_accidental = false,
            include_cantilevers = true
        );
    }

    module _pcb() {
        height = 1.6;
        offset = 3.8; // key_plot / 2;

        color("purple") difference() {
            cube([key_plot * 15, 40, height]);

            for (
                x = [0 + offset, 7 * key_plot + offset, 14 * key_plot + offset],
                y = [offset, 22.1]
            ) {
                translate([x, y, -e]) {
                    # cylinder(
                        d = 3.2,
                        h = height + e * 2
                    );
                }
            }
        }

        for (i = [1,2,3,4,5,7,8,9,10,11,12,13,15]) {
            translate([key_plot * i - offset, 10.1, height]) {
                color("black") cylinder(
                    h = 6,
                    d = 6
                );
            }
        }
    }

    module _mounting_rail() {
        /* TODO: DRY button height 6 */
        translate([0, 0, -6]) {
            _mounted_keys(
                include_mount = true,
                mount_height = 6
            );
        }
    }

    _keys();
    _mounting_rail();
    _pcb();
}

assembly();
