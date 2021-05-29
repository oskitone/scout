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

module pcb_enclosure_top_fixture(
    pcb_position = [0, 0, 0],
    enclosure_dimensions = [0, 0, 0],

    coverage = 2,

    // NOTE: these are eyeballed, and that's okay!
    xs = [PCB_WIDTH * .4, PCB_WIDTH * .6],

    wall = ENCLOSURE_INNER_WALL,
    clearance = PCB_FIXTURE_CLEARANCE,
    tolerance = DEFAULT_TOLERANCE
) {
    e = .0876;

    end_y = enclosure_dimensions.y - ENCLOSURE_WALL + e;
    y = pcb_position.y + PCB_LENGTH - coverage;
    z = pcb_position.z;

    length = end_y - y;
    height = enclosure_dimensions.z - ENCLOSURE_FLOOR_CEILING + e - z;

    difference() {
        for (x = xs) {
            translate([pcb_position.x + x - wall / 2, y, z]) {
                cube([wall, length, height]);
            }
        }

        _fixture_pcb_difference(pcb_position);
    }
}

module pcb_fixtures(
    pcb_position = [0, 0, 0],
    screw_head_clearance = 0,
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

    _back_stools();
    _button_rail();
    _mounting_columns();
}
