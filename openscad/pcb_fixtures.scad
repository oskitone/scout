include <pcb_mounting_columns.scad>;
include <pcb_stool.scad>;

PCB_FIXTURE_CLEARANCE = .3;

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
                pcb_stool(height = height + e);
            }
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
    _corners();

    pcb_mounting_columns(
        pcb_position = pcb_position,

        screw_head_clearance = screw_head_clearance,
        wall = mounting_column_wall,

        pcb_screw_hole_positions = pcb_screw_hole_positions,
        pcb_post_hole_positions = pcb_post_hole_positions,

        tolerance = tolerance,

        enclosure_floor_ceiling = ENCLOSURE_FLOOR_CEILING,
        screw_head_diameter = SCREW_HEAD_DIAMETER,
        pcb_hole_diameter = PCB_HOLE_DIAMETER,

        quick_preview = quick_preview
    );
}
