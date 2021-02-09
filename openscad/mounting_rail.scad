include <keys.scad>;

module mounting_rails(
    side_width = side_width,
    tolerance = 0
) {
    e = .05321;

    total_width = side_width * 2 + key_gutter * 2 + mount_width;
    length = key_length + mount_length
        + .1 * 2; // TODO: extract
    height = PCB_Z + PCB_HEIGHT + BUTTON_HEIGHT;

    module _sides() {
        for (x = [0, total_width - side_width]) {
            translate([x, 0, 0]) {
                cube([side_width, length, height]);
            }
        }
    }

    module _mount_rails() {
        header_cavity_width = PCB_WIDTH / 3 - 10;

        difference() {
            translate([e, length - mount_length, PCB_Z + PCB_HEIGHT]) {
                cube([
                    mount_width + side_width * 2 + key_gutter * 2 - e * 2,
                    mount_length,
                    BUTTON_HEIGHT
                ]);
            }

            translate([
                (total_width - header_cavity_width) / 2,
                length - mount_length - e,
                PCB_Z + PCB_HEIGHT - e
            ]) {
                cube([
                    header_cavity_width,
                    mount_length + e * 2,
                    BUTTON_HEIGHT + e * 2
                ]);
            }

            for (xy = PCB_HOLE_POSITIONS) {
                translate([PCB_X + xy.x, PCB_Y + xy.y, -e]) {
                    cylinder(
                        d = 3.2 + tolerance * 2,
                        h = 100
                    );
                }
            }
        }
    }

    _mount_rails();

    _sides();
}
