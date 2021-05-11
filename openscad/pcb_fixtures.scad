module pcb_fixtures(
    pcb_position = [0, 0, 0],
    screw_head_clearance = 0,
    wall = ENCLOSURE_INNER_WALL,
    corner_clearance = DEFAULT_TOLERANCE + .2,
    tolerance = DEFAULT_TOLERANCE
) {
    e = .09876;

    z = ENCLOSURE_FLOOR_CEILING - e;

    module _corners(size = 6) {
        height = pcb_position.z + PCB_HEIGHT - z;

        difference() {
            for (x = [
                pcb_position.x - wall - corner_clearance,
                pcb_position.x + PCB_WIDTH - size + wall + corner_clearance
            ]) {
                for (y = [
                    pcb_position.y - wall - corner_clearance,
                    pcb_position.y + PCB_LENGTH - size + wall + corner_clearance
                ]) {
                    translate([x, y, z]) {
                        cube([size, size, height]);
                    }
                }
            }

            translate([
                pcb_position.x - corner_clearance,
                pcb_position.y - corner_clearance,
                z - e
            ]) {
                cube([
                    PCB_WIDTH + corner_clearance * 2,
                    PCB_LENGTH + corner_clearance * 2,
                    height + e * 2
                ]);
            }
        }
    }

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

    _corners();
    _back_stools();
    _button_rail();
    _mounting_columns();
}
