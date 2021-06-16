/* Arndt AZ40R 1.6" */
/* https://www.jameco.com/Jameco/Products/ProdDS/2227516.pdf */

use <../../poly555/openscad/lib/basic_shapes.scad>;

SPEAKER_DIAMETER = 39.7;
SPEAKER_HEIGHT = 5.4;

module speaker() {
    cylinder(
        d = SPEAKER_DIAMETER,
        h = SPEAKER_HEIGHT
    );
}

function get_speaker_fixture_diameter(
    tolerance = 0,
    wall = ENCLOSURE_INNER_WALL,
    speaker_diameter = SPEAKER_DIAMETER
) = (
    SPEAKER_DIAMETER + wall * 2 + tolerance * 2
);

module speaker_fixture(
    height = SPEAKER_HEIGHT,
    wall = 1,
    tab_cavity_rotation = 90,
    tab_cavity_size = 15,
    tolerance = 0,
    quick_preview = true
) {
    e = .053;

    ring_z = height - SPEAKER_HEIGHT;
    diameter = get_speaker_fixture_diameter(tolerance, wall);

    difference() {
        ring(
            diameter = diameter,
            height = height,
            thickness = wall,
            $fn = quick_preview ? undef : HIDEF_ROUNDING
        );

        rotate([0, 0, tab_cavity_rotation]) {
            translate([tab_cavity_size / -2, 0, ring_z - e]) {
                cube([tab_cavity_size, diameter / 2, height + e * 2]);
            }
        }
    }
}
