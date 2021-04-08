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

module mounting_rail_with_header_cavity() {
    e = .0234;
    z = PCB_Z + PCB_HEIGHT;
    cavity_width = 25; // TODO: extract

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
