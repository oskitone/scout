PCB_FIXTURE_CLEARANCE = .3;

PCB_STOOL_DIAMETER = 4;
PCB_STOOL_CHAMFER = 2;

PCB_FIXTURE_BUTTON_RAIL_LENGTH = 3;

module _fixture_pcb_difference(
    pcb_position = [0, 0, 0],
    z = undef,
    height = PCB_HEIGHT,
    clearance = PCB_FIXTURE_CLEARANCE,
    tolerance = DEFAULT_TOLERANCE
) {
    e = .031;
    offset = clearance + tolerance;

    translate([
        pcb_position.x - offset,
        pcb_position.y - offset,
        (z != undef ? z : pcb_position.z) - e
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

    // NOTE: these are eyeballed, and that's okay!
    positions = [
        [PCB_WIDTH * .07, PCB_LENGTH * .7],
        [PCB_WIDTH * .5, PCB_LENGTH * .8],
    ]
) {
    e = .0876;

    z = pcb_position.z + PCB_HEIGHT;
    height = enclosure_dimensions.z - ENCLOSURE_FLOOR_CEILING - z;

    for (position = positions) {
        translate([
            pcb_position.x + position.x,
            pcb_position.y + position.y,
            z
        ]) {
            translate([0, 0, height + e]) mirror([0, 0, 1]) {
                pcb_stool(
                    height = height + e,
                    registration_nub = false
                );
            }
        }
    }
}

module pcb_stool(
    height,

    diameter = PCB_STOOL_DIAMETER,
    chamfer = PCB_STOOL_CHAMFER,

    support_web_count = 3,
    support_web_width = ENCLOSURE_INNER_WALL,

    registration_nub = false,
    registration_nub_height = PCB_HEIGHT,
    registration_nub_clearance = .2,

    tolerance = 0,

    quick_preview = false
) {
    e = .0524;

    cylinder(d = diameter, h = height);

    cylinder(
        d1 = diameter + chamfer * 2,
        d2 = diameter,
        h = chamfer
    );

    overlap = diameter / 6;
    for (i = [0 : support_web_count - 1]) {
        rotate([0, 0, 360 / support_web_count * i]) {
            translate([support_web_width / -2, diameter / 2 - overlap, 0]) {
                flat_top_rectangular_pyramid(
                    top_width = support_web_width,
                    top_length = 0,
                    bottom_width = support_web_width,
                    bottom_length = overlap + chamfer,
                    height = height - e,
                    top_weight_y = 0
                );
            }
        }
    }

    if (registration_nub) {
        translate([0, 0, height - e]) {
            cylinder(
                d = PCB_HOLE_DIAMETER
                    - tolerance * 2
                    - registration_nub_clearance * 2,
                h = registration_nub_height + e,
                $fn = quick_preview ? 12 : HIDEF_ROUNDING
            );
        }
    }
}

module pcb_bottom_fixtures(
    pcb_position = [0, 0, 0],
    pcb_screw_hole_positions = [],
    pcb_post_hole_positions = [],
    screw_head_clearance = 0,

    corner_coverage = 3, // eyeballed to not collide w/ switch_clutch
    corner_fixture_wall = 2,
    mounting_column_wall = ENCLOSURE_INNER_WALL,

    clearance = PCB_FIXTURE_CLEARANCE,
    tolerance = DEFAULT_TOLERANCE,

    quick_preview = true
) {
    e = .09876;
    offset = clearance + tolerance;

    z = ENCLOSURE_FLOOR_CEILING - e;

    module _back_stools(size = PCB_STOOL_DIAMETER) {
        corner_inset = size / 2 + PCB_STOOL_CHAMFER;
        y = PCB_LENGTH - corner_inset;

        for (position = [[corner_inset, y], [PCB_WIDTH - corner_inset, y]]) {
            translate([
                pcb_position.x + position.x,
                pcb_position.y + position.y,
                z
            ]) {
                pcb_stool(height = pcb_position.z - z);
            }
        }
    }

    module _button_rail(length = PCB_FIXTURE_BUTTON_RAIL_LENGTH) {
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

        module _column(p, screw = false, post = false) {
            x = pcb_position.x + p.x;
            y = pcb_position.y + p.y;

            if (screw) {
                translate([x, y, head_column_z]) {
                    cylinder(
                        h = head_column_height - head_column_z,
                        d = SCREW_HEAD_DIAMETER
                            + tolerance * 2 + mounting_column_wall * 2
                    );
                }

                translate([x, y, shaft_column_z]) {
                    cylinder(
                        h = pcb_position.z - shaft_column_z,
                        d = PCB_HOLE_DIAMETER
                            + tolerance * 2 + mounting_column_wall * 2
                    );
                }
            } else {
                translate([x, y, z]) {
                    pcb_stool(
                        height = pcb_position.z - z,
                        registration_nub = true,
                        tolerance = tolerance,
                        quick_preview = quick_preview
                    );
                }
            }
        }

        for (p = pcb_screw_hole_positions) {
            _column(p, screw = true);
        }

        for (p = pcb_post_hole_positions) {
            _column(p, post = true);
        }
    }

    module _corners(
        wall = corner_fixture_wall,
        height_extension = 1
    ) {
        offset = wall + tolerance;

        corner_size = offset + corner_coverage;
        corner_xs = [-offset, PCB_WIDTH + offset - corner_size];
        corner_ys = [-offset];

        z = ENCLOSURE_FLOOR_CEILING - e;

        height = pcb_position.z - z + PCB_HEIGHT + height_extension;

        difference() {
            for (x = corner_xs, y = corner_ys) {
                translate([pcb_position.x + x, pcb_position.y + y, z]) {
                    cube([corner_size, corner_size, height]);
                }
            }

            _fixture_pcb_difference(
                pcb_position,
                z = z,
                height = height
            );
        }
    }

    _back_stools();
    _button_rail();
    _mounting_columns();
    _corners();
}
