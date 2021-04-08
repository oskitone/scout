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

PCB_HOLE_DIAMTER = 3.2;
PCB_HOLE_POSITIONS = [
    [115.534, 24.765],
    [59.654, 24.765],
    [171.414, 24.765],
    [3.774, 24.765],
];

BUTTON_HEIGHT = 6;
BUTTON_Y_OFFSET = 6.5 / 2;

module keyboard_matrix_pcb() {
    e = .0943;
    silkscreen_height = e;

    difference() {
        union() {
            color("purple") cube([PCB_WIDTH, PCB_LENGTH, PCB_HEIGHT]);

            translate([0, 0, PCB_HEIGHT - e]) {
                linear_extrude(silkscreen_height + e) {
                    offset(e) {
                        import("../keyboard_matrix-brd.svg");
                    }
                }
            }
        }

        for (xy = PCB_HOLE_POSITIONS) {
            translate([xy.x, xy.y, -e]) {
                cylinder(
                    d = PCB_HOLE_DIAMTER,
                    h = PCB_HEIGHT + e * 2 + 3,
                    $fn = 12
                );
            }
        }
    }

    for (xy = PCB_BUTTON_POSITIONS) {
        translate([xy.x + 4.6 / 2, xy.y + BUTTON_Y_OFFSET, PCB_HEIGHT]) {
            color("black") cylinder(
                h = 6,
                d = BUTTON_HEIGHT
            );
        }
    }
}
