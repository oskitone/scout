/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/basic_shapes.scad>;

PCB_STOOL_DIAMETER = 4;
PCB_STOOL_CHAMFER = 2;

module pcb_stool(
    height,

    diameter = PCB_STOOL_DIAMETER,
    chamfer = PCB_STOOL_CHAMFER,

    support_web_count = 3,
    support_web_width = 1.2, // ENCLOSURE_INNER_WALL
    support_web_length = undef,

    registration_nub = false,
    registration_nub_height = 1.6, // PCB_HEIGHT
    registration_nub_hole_diameter = 3.2, // PCB_HOLE_DIAMETER
    registration_nub_clearance = .2,

    tolerance = 0,

    hidef_rounding = 120, // HIDEF_ROUNDING

    quick_preview = false
) {
    e = .0524;

    cylinder(d = diameter, h = height);

    cylinder(
        d1 = diameter + chamfer * 2,
        d2 = diameter,
        h = chamfer
    );

    overlap = diameter / 6;
    for (i = [0 : support_web_count - 1]) {
        rotate([0, 0, 360 / support_web_count * i]) {
            translate([support_web_width / -2, diameter / 2 - overlap, 0]) {
                flat_top_rectangular_pyramid(
                    top_width = support_web_width,
                    top_length = 0,
                    bottom_width = support_web_width,
                    bottom_length = support_web_length
                        ? support_web_length
                        : overlap + chamfer,
                    height = height - e,
                    top_weight_y = 0
                );
            }
        }
    }

    if (registration_nub) {
        translate([0, 0, height - e]) {
            cylinder(
                d = registration_nub_hole_diameter
                    - tolerance * 2
                    - registration_nub_clearance * 2,
                h = registration_nub_height + e,
                $fn = quick_preview ? 12 : hidef_rounding
            );
        }
    }
}
