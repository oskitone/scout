PCB_FIXTURE_CLEARANCE = .3;
PCB_FIXTURE_VERTICAL_ALLOWANCE = PCB_PIN_CLEARANCE;

function get_mounting_column_top_diameter(tolerance = 0) = (
    SCREW_HEAD_DIAMETER
        + tolerance * 2
        + ENCLOSURE_INNER_WALL * 2
);

module _fixture_pcb_difference(
    pcb_position = [0, 0, 0],

    height = PCB_HEIGHT,
    wall = ENCLOSURE_INNER_WALL,
    clearance = PCB_FIXTURE_CLEARANCE,
    bottom_bleed = 0,
    top_bleed = 0,
    tolerance = DEFAULT_TOLERANCE
) {
    e = .031;
    offset = clearance + tolerance;

    translate([
        pcb_position.x - offset,
        pcb_position.y - offset,
        pcb_position.z - bottom_bleed - e
    ]) {
        cube([
            PCB_WIDTH + offset * 2,
            PCB_LENGTH + offset * 2,
            height + bottom_bleed + top_bleed + e * 2
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
    z = pcb_position.z - PCB_FIXTURE_VERTICAL_ALLOWANCE;

    length = end_y - y;
    height = enclosure_dimensions.z - ENCLOSURE_FLOOR_CEILING
        + e - z;

    difference() {
        for (x = xs) {
            translate([pcb_position.x + x - wall / 2, y, z]) {
                cube([wall, length, height]);
            }
        }

        _fixture_pcb_difference(
            pcb_position,
            bottom_bleed = PCB_FIXTURE_VERTICAL_ALLOWANCE
        );
    }
}

module pcb_fixtures(
    pcb_position = [0, 0, 0],
    screw_head_clearance = 0,
    button_rail_length,
    wall = ENCLOSURE_INNER_WALL,
    clearance = PCB_FIXTURE_CLEARANCE,
    tolerance = DEFAULT_TOLERANCE
) {
    e = .09876;
    offset = clearance + tolerance;

    z = ENCLOSURE_FLOOR_CEILING - e;

    module _button_rail(length = button_rail_length) {
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
                        d = get_mounting_column_top_diameter(tolerance)
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

    _button_rail();
    _mounting_columns();
}
