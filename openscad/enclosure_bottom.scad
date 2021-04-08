/* TODO: extract */
ENCLOSURE_FLOOR_CEILING = 2;
ENCLOSURE_INNER_WALL = 1.2;

/* TODO: extract into common parts repo */
SCREW_HEAD_DIAMETER = 6;
SCREW_HEAD_HEIGHT = 2.1;
NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

module enclosure_bottom(
    exposed_screw_head_clearance = .4
) {
    e = .0432;

    module _stool(length = ENCLOSURE_INNER_WALL) {
        y = PCB_Y + PCB_BUTTON_POSITIONS[0][1] + BUTTON_Y_OFFSET - length / 2;

        translate([PCB_X, y, ENCLOSURE_FLOOR_CEILING - e]) {
            cube([
                PCB_WIDTH,
                length,
                PCB_Z - ENCLOSURE_FLOOR_CEILING + e
            ]);
        }
    }

    module _bottom_mounting_rail(pcb_clearance = 1) {
        difference() {
            mounting_rail(
                height = PCB_Z - ENCLOSURE_FLOOR_CEILING + PCB_HEIGHT + e,
                z = ENCLOSURE_FLOOR_CEILING - e
            );

            translate([
                PCB_X - pcb_clearance,
                PCB_Y + PCB_LENGTH - mount_length - e,
                PCB_Z
            ]) {
                cube([
                    PCB_WIDTH + pcb_clearance * 2,
                    mount_length + e * 2,
                    PCB_HEIGHT + e
                ]);
            }
        }
    }

    module _screw_holes() {
        for (xy = PCB_HOLE_POSITIONS) {
            translate([PCB_X + xy.x, PCB_Y + xy.y, -e]) {
                cylinder(
                    d = SCREW_HEAD_DIAMETER + DEFAULT_TOLERANCE * 2,
                    h = SCREW_HEAD_HEIGHT + exposed_screw_head_clearance + e,
                    $fn = 12
                );
            }
        }
    }

    _stool();

    difference() {
        union() {
            _bottom_mounting_rail();
            cube([ENCLOSURE_WIDTH, ENCLOSURE_LENGTH, ENCLOSURE_FLOOR_CEILING]);
        }

        _screw_holes();
    }
}
