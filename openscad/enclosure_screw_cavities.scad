use <../../poly555/openscad/lib/screw_head_exposures.scad>;

module enclosure_screw_cavities(
    screw_head_clearance = 0,

    pcb_position = [0, 0, 0],
    pcb_screw_hole_positions = [],

    tolerance = 0,

    pcb_hole_diameter = 3.2, // PCB_HOLE_DIAMETER

    show_dfm = false,

    quick_preview = true
) {
    e = .0539;

    for (p = pcb_screw_hole_positions) {
        translate([pcb_position.x + p.x, pcb_position.y + p.y, 0]) {
            screw_head_exposure(
                tolerance = tolerance,
                clearance = screw_head_clearance,
                show_dfm = show_dfm
            );

            translate([0, 0, -e]) {
                cylinder(
                    d = pcb_hole_diameter,
                    h = pcb_position.z + e * 2,
                    $fn = quick_preview ? undef : 120
                );
            }
        }
    }
}
