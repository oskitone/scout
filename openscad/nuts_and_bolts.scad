/* TODO: extract into common parts repo */
SCREW_HEAD_DIAMETER = 6;
SCREW_HEAD_HEIGHT = 2.1;
NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

module nuts(
    pcb_position = [],
    z = 0,
    diameter = NUT_DIAMETER,
    height = NUT_HEIGHT,
    chamfer_top = false
) {
    e = .019;

    for (xy = PCB_HOLE_POSITIONS) {
        translate([
            pcb_position.x + xy.x - diameter / 2,
            pcb_position.y + xy.y - diameter / 2,
            z + nut_lock_floor
        ]) {
            cube([diameter, diameter, height]);

            if (chamfer_top) {
                translate([diameter / 2, diameter / 2, height - e]) {
                    rotate([0, 0, 45]) {
                        cylinder(
                            d1 = sqrt(pow(diameter, 2) * 2),
                            d2 = 0,
                            h = diameter / 2 + e,
                            $fn = 4
                        );
                    }
                }
            }
        }
    }
}
