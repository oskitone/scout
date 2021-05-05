/* TODO: extract into common parts repo */
SCREW_HEAD_DIAMETER = 6;
SCREW_HEAD_HEIGHT = 2.1;
NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

module nuts(
    pcb_position = [],
    z = 0,
    diameter = NUT_DIAMETER,
    height = NUT_HEIGHT
) {
    for (xy = PCB_HOLE_POSITIONS) {
        translate([
            pcb_position.x + xy.x - diameter / 2,
            pcb_position.y + xy.y - diameter / 2,
            z + nut_lock_floor
        ]) {
            cube([diameter, diameter, height]);
        }
    }
}
