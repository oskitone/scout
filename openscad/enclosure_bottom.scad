/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/supportless_screw_cavity.scad>;

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

    module _plate() {
        screw_head_cavity_diameter = SCREW_HEAD_DIAMETER + DEFAULT_TOLERANCE * 2;
        screw_hole_diameter = PCB_HOLE_DIAMTER + DEFAULT_TOLERANCE * 2;

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

        module _screw_head_exposures() {
            height = SCREW_HEAD_HEIGHT + exposed_screw_head_clearance;

            for (xy = PCB_HOLE_POSITIONS) {
                translate([PCB_X + xy.x, PCB_Y + xy.y, -e]) {
                    cylinder(
                        d = screw_head_cavity_diameter,
                        h = height + e,
                        $fn = 12
                    );

                    translate([0, 0, height]) {
                        supportless_screw_cavity(
                            span = screw_head_cavity_diameter,
                            diameter = screw_hole_diameter
                        );
                    }
                }
            }
        }

        difference() {
            union() {
                _bottom_mounting_rail();
                cube([ENCLOSURE_WIDTH, ENCLOSURE_LENGTH, ENCLOSURE_FLOOR_CEILING]);
            }

            _screw_head_exposures();
        }
    }

    _stool();
    _plate();

    /* TODO: extend back plate for arduino/breadboard */
    /* TODO: PCB registration/aligners */
    /* TODO: key endstop */
    /* TODO: key hitch */
}
