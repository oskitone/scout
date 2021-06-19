PCB_FIXTURE_CLEARANCE = .3;

module _fixture_pcb_difference(
    pcb_position = [0, 0, 0],

    height = PCB_HEIGHT,
    wall = ENCLOSURE_INNER_WALL,
    clearance = PCB_FIXTURE_CLEARANCE,
    tolerance = DEFAULT_TOLERANCE
) {
    e = .031;
    offset = clearance + tolerance;

    translate([
        pcb_position.x - offset,
        pcb_position.y - offset,
        pcb_position.z - e
    ]) {
        cube([
            PCB_WIDTH + offset * 2,
            PCB_LENGTH + offset * 2,
            height + e * 2
        ]);
    }
}

module pcb_enclosure_top_fixtures(
    pcb_position = [0, 0, 0],
    enclosure_dimensions = [0, 0, 0],

    back_coverage = 4,
    height_extension = 2,

    // NOTE: these are eyeballed, and that's okay!
    xs = [PCB_WIDTH * .24, PCB_WIDTH * .5, PCB_WIDTH * .79],

    wall = ENCLOSURE_INNER_WALL,
    clearance = PCB_FIXTURE_CLEARANCE,
    tolerance = DEFAULT_TOLERANCE
) {
    e = .0876;

    z = pcb_position.z - height_extension;

    height = enclosure_dimensions.z - ENCLOSURE_FLOOR_CEILING + e - z;

    difference() {
        for (x = xs) {
            y = pcb_position.y + PCB_LENGTH - back_coverage;
            end_y = enclosure_dimensions.y - ENCLOSURE_WALL + e;
            length = end_y - y;

            translate([pcb_position.x + x - wall / 2, y, z]) {
                cube([wall, length, height]);
            }
        }

        translate([0, 0, -height_extension - e]) {
            _fixture_pcb_difference(
                pcb_position,
                height = PCB_HEIGHT + height_extension + e * 2
            );
        }
    }
}

module pcb_bottom_fixtures(
    pcb_position = [0, 0, 0],
    screw_head_clearance = 0,

    corner_coverage = 1,

    wall = ENCLOSURE_INNER_WALL,
    clearance = PCB_FIXTURE_CLEARANCE,
    tolerance = DEFAULT_TOLERANCE
) {
    e = .09876;
    offset = clearance + tolerance;

    z = ENCLOSURE_FLOOR_CEILING - e;

    module _back_stools(size = 4) {
        x_offset = 15; // NOTE: this is eye-balled!
        y = PCB_LENGTH - size / 2;

        for (position = [[x_offset, y], [PCB_WIDTH - x_offset, y]]) {
            translate([
                pcb_position.x + position.x,
                pcb_position.y + position.y,
                z
            ]) {
                cylinder(
                    d = size,
                    h = pcb_position.z - z
                );
            }
        }
    }

    module _button_rail(length = 3) {
        translate([
            pcb_position.x,
            pcb_position.y + PCB_BUTTON_POSITIONS[0].y - length / 2,
            z
        ]) {
            cube([PCB_WIDTH, length, pcb_position.z - z]);
        }
    }

    module _mounting_columns() {
        head_column_height = SCREW_HEAD_HEIGHT + ENCLOSURE_FLOOR_CEILING
            + screw_head_clearance;
        head_column_z = z;

        shaft_column_height = pcb_position.z - head_column_height;
        shaft_column_z = head_column_height - e;

        for (p = PCB_HOLE_POSITIONS) {
            translate([pcb_position.x + p.x, pcb_position.y + p.y, 0]) {
                translate([0, 0, head_column_z]) {
                    cylinder(
                        h = head_column_height - head_column_z,
                        d = SCREW_HEAD_DIAMETER
                            + tolerance * 2
                            + ENCLOSURE_INNER_WALL * 2
                    );
                }

                translate([0, 0, shaft_column_z]) {
                    cylinder(
                        h = pcb_position.z - shaft_column_z,
                        d = PCB_HOLE_DIAMETER
                            + tolerance * 2
                            + ENCLOSURE_INNER_WALL * 2
                    );
                }
            }
        }
    }

    module _back_corners() {
        corner_size = pcb_position.x + corner_coverage - (ENCLOSURE_WALL - e);
        corner_xs = [-wall, PCB_WIDTH + wall - corner_size];

        y = PCB_LENGTH + pcb_position.y + wall - corner_size;
        z = ENCLOSURE_FLOOR_CEILING - e;

        height = pcb_position.z - z + PCB_HEIGHT;

        difference() {
            for (x = corner_xs) {
                translate([pcb_position.x + x, y, z]) {
                    cube([corner_size, corner_size, height]);
                }
            }

            _fixture_pcb_difference(pcb_position);
        }
    }

    _back_stools();
    _button_rail();
    _mounting_columns();
    _back_corners();
}
