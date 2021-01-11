/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/keys.scad>;

module assembly(
    tolerance = .1
) {
    key_plot = 2.54 * 3;

    e = .009;

    module _keys() {
        gutter = 1;

        length = 50;
        height = 7;
        accidental_height = 2;

        mount_length = 6;

        module _mounted_keys(include_accidental, include_natural) {
            mounted_keys(
                count = 13,

                natural_length = length,
                natural_width = key_plot * 2 - gutter,
                natural_height = height,

                accidental_width = key_plot * 2 * .5,
                accidental_length = length * 3/5,
                accidental_height = height + accidental_height,

                gutter = gutter,

                include_accidental = include_accidental,
                include_natural = include_natural,

                mount_length = mount_length,
                mount_height = height,
                mount_hole_diameter = 3.2 + tolerance * 2,
                mount_screw_head_diameter = 4,
                mount_hole_xs = [key_plot, key_plot * 8, key_plot * 15],

                cantilever_length = 4,
                cantilever_height = 2,
                cantilever_recession = 4 - tolerance * 2
            );
        }

        // TODO: DRY PCB holes Y
        y = key_plot * 2.5 - length - mount_length / 2;

        translate([key_plot / -2, y, 1.6 + 6]) {
            color("black") _mounted_keys(true, false);
            translate([e, e, -e]) color("white") _mounted_keys(false, true);
        }
    }

    module _pcb() {
        height = 1.6;
        offset = key_plot / 2;

        color("purple") difference() {
            cube([key_plot * 15, 40, height]);

            for (
                x = [0 + offset, 7 * key_plot + offset, 14 * key_plot + offset],
                y = [offset, key_plot * 2.5]
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
            translate([key_plot * i - offset, key_plot * 1.5, height]) {
                color("black") cylinder(
                    h = 6,
                    d = 6
                );
            }
        }
    }

    _keys();
    _pcb();
}

assembly();
