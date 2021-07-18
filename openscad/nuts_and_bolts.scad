/* TODO: extract into common parts repo */
SCREW_HEAD_DIAMETER = 6;
SCREW_HEAD_HEIGHT = 2.1;
NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

SCREW_LENGTH = 3/4 * 25.4;

FLATHEAD_SCREWDRIVER_POINT = .8;

module nuts(
    pcb_position = [],
    positions = [],
    y = 0,
    z = 0,
    diameter = NUT_DIAMETER,
    height = NUT_HEIGHT
) {
    e = .019;

    for (xy = positions) {
        translate([
            pcb_position.x + xy.x - diameter / 2,
            y + pcb_position.y + xy.y - diameter / 2,
            z
        ]) {
            cube([diameter, diameter, height]);
        }
    }
}

module screws(
    positions = PCB_HOLE_POSITIONS,
    pcb_position = [],
    diameter = PCB_HOLE_DIAMETER - .2,
    length = SCREW_LENGTH,
    z = 0
) {
    e = .03;

    for (xy = positions) {
        translate([
            pcb_position.x + xy.x,
            pcb_position.y + xy.y,
            z
        ]) {
            cylinder(
                d = SCREW_HEAD_DIAMETER,
                h = SCREW_HEAD_HEIGHT
            );

            translate([0, 0, SCREW_HEAD_HEIGHT - e]) {
                cylinder(
                    d = diameter,
                    h = length + e
                );
            }
        }
    }
}
