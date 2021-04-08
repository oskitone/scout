include <keyboard_matrix_pcb.scad>;
include <keys.scad>;
include <mounting_rail.scad>;

side_width = 1.2;
front_lip_length = side_width;

PCB_X = side_width + offset / 2 + key_gutter;
PCB_Y = key_length - PCB_LENGTH + mount_length + front_lip_length + key_gutter;
PCB_Z = 4; // TODO: derive

ENCLOSURE_WIDTH = PCB_X * 2 + PCB_WIDTH;
ENCLOSURE_LENGTH = front_lip_length + key_gutter + key_length + mount_length;

DEFAULT_TOLERANCE = .1;

/* TODO: extract into common parts repo */
SCREW_HEAD_DIAMETER = 6;
SCREW_HEAD_HEIGHT = 2.1;
NUT_DIAMETER = 6.4;
NUT_HEIGHT = 2.4;

module mounting_rail(
    height,
    x_bleed = PCB_X,
    z = 0,
    length = mount_length
) {
    e = 0.0542;

    difference() {
        translate([
            PCB_X - x_bleed,
            PCB_Y + PCB_LENGTH - length,
            z
        ]) {
            cube([PCB_WIDTH + x_bleed * 2, length, height]);
        }

        for (xy = PCB_HOLE_POSITIONS) {
            translate([PCB_X + xy.x, PCB_Y + xy.y, z - e]) {
                cylinder(
                    d = PCB_HOLE_DIAMTER + DEFAULT_TOLERANCE * 2,
                    h = height + e * 2,
                    $fn = 12
                );
            }
        }
    }
}

module enclosure_bottom(
    exposed_screw_head_clearance = 0 // .4
) {
    e = .0432;

    ENCLOSURE_FLOOR_CEILING = 2;
    ENCLOSURE_INNER_WALL = 1.2;

    module _stool(length = ENCLOSURE_INNER_WALL) { // TODO: extract
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

    module _plate() {
        difference() {
            cube([ENCLOSURE_WIDTH, ENCLOSURE_LENGTH, ENCLOSURE_FLOOR_CEILING]);
            // TODO: extra walls around screw holes

            for (xy = PCB_HOLE_POSITIONS) {
                translate([PCB_X + xy.x, PCB_Y + xy.y, -e]) {
                    cylinder(
                        d = SCREW_HEAD_DIAMETER + DEFAULT_TOLERANCE * 2,
                        h = SCREW_HEAD_HEIGHT + exposed_screw_head_clearance
                            + e,
                        $fn = 12
                    );
                }
            }
        }
    }

    _stool();
    _bottom_mounting_rail();
    _plate();
}

module _keys(
    cantilever_height = 2,
    tolerance = 0,
    quick_preview = false
) {
    e = .06789;
    z = PCB_Z + PCB_HEIGHT + BUTTON_HEIGHT;

    nut_lock_width = NUT_DIAMETER + DEFAULT_TOLERANCE * 2;
    nut_lock_length = mount_length + e * 2;

    // TODO: fix, make non-magic
    translate([PCB_X, PCB_Y, PCB_Z]) {
        keys(
            tolerance = tolerance,
            quick_preview = quick_preview,
            cantilever_length = 5, // TODO: derive or obviate (_extension?)
            cantilever_height = cantilever_height
        );
    }

    difference() {
        mounting_rail(
            height = cantilever_height + NUT_HEIGHT,
            x_bleed = PCB_X,
            z = z,
            length = mount_length
        );

        for (xy = PCB_HOLE_POSITIONS) {
            translate([
                PCB_X + xy.x + nut_lock_width / -2,
                PCB_Y + xy.y + nut_lock_length / -2,
                z + cantilever_height
            ]) {
                cube([
                    nut_lock_width,
                    nut_lock_length,
                    NUT_HEIGHT + e
                ]);
            }
        }
    }
}

module _mounting_rail() {
    e = .0234;
    z = PCB_Z + PCB_HEIGHT;
    cavity_width = 40;

    difference() {
        mounting_rail(
            height = BUTTON_HEIGHT,
            z = z
        );

        translate([
            PCB_X + PCB_WIDTH / 2 - cavity_width / 2,
            PCB_Y + PCB_LENGTH - mount_length - e,
            z - e
        ]) {
            cube([cavity_width, mount_length + e * 2, BUTTON_HEIGHT + e * 2]);
        }
    }
}

module assembly(
    tolerance = 0,
    quick_preview = true
) {
    _keys(
        tolerance = tolerance,
        quick_preview = quick_preview
    );

    translate([PCB_X, PCB_Y, PCB_Z]) {
        keyboard_matrix_pcb();
    }

    enclosure_bottom();
    _mounting_rail();
}

assembly(
    tolerance = DEFAULT_TOLERANCE,
    quick_preview = true
);
