/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/keys.scad>;

PCB_WIDTH = 175.26;
PCB_LENGTH = 28.575;
PCB_HEIGHT = 1.6;

PCB_BUTTON_POSITIONS = [
    [153.924, 2.54],
    [146.304, 7.62],
    [138.684, 2.54],
    [131.064, 7.62],
    [123.444, 2.54],
    [115.824, 7.62],
    [169.164, 2.54],
    [108.204, 2.54],
    [92.964, 2.54],
    [85.344, 7.62],
    [77.724, 2.54],
    [70.104, 7.62],
    [62.484, 2.54],
    [47.244, 2.54],
    [39.624, 7.62],
    [32.004, 2.54],
    [24.384, 7.62],
    [16.764, 2.54],
    [9.144, 7.62],
    [1.524, 2.54],
];

PCB_HOLE_POSITIONS = [
    [115.534, 24.765],
    [59.654, 24.765],
    [171.414, 24.765],
    [3.774, 24.765],
];

module assembly(
    quick_preview = true,
    tolerance = .1
) {
    key_plot = 2.54 * 3;
    key_gutter = 1;

    key_length = 50;
    key_height = 7;
    accidental_height = 2;

    mount_length = 8;

    e = .009;

    module _mounted_keys(
        include_mount = false,
        include_natural = false,
        include_accidental = false,
        include_cantilevers = false,

        mount_height = key_height
    ) {
        y = PCB_LENGTH - key_length - mount_length;

        translate([key_plot / -2, y, 1.6 + 6]) {
            mounted_keys(
                count = 20,
                starting_natural_key_index = 3,

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
        silkscreen_height = e;

        difference() {
            union() {
                color("purple") cube([PCB_WIDTH, PCB_LENGTH, PCB_HEIGHT]);

                translate([0, 0, PCB_HEIGHT - e]) {
                    linear_extrude(silkscreen_height + e) {
                        import("../keyboard_matrix-brd.svg");
                    }
                }
            }

            for (xy = PCB_HOLE_POSITIONS) {
                translate([xy.x, xy.y, -e]) {
                    cylinder(
                        d = 3.2,
                        h = PCB_HEIGHT + e * 2 + 3
                    );
                }
            }
        }

        for (xy = PCB_BUTTON_POSITIONS) {
            translate([xy.x + 4.6 / 2, xy.y + 6.5 / 2, PCB_HEIGHT]) {
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
