include <enclosure.scad>;
include <scout_pcb.scad>;

module lightpipe(
    dimensions = [],
    tolerance = 0,

    keys_mount_rail_and_nut_cavity_length = 0,
    keys_mount_rail_and_nut_cavity_height = 0,

    wall = ENCLOSURE_INNER_WALL
) {
    e = .0941;

    width = dimensions.x;
    length = dimensions.y;
    height = dimensions.z;

    module _top(z) {
        _width = width - (height - z) * 4;
        _length = length - (height - z) * 4;

        translate([(width - _width) / 2, (length - _length) / 2, z - e]) {
            cube([
                _width,
                _length,
                e
            ]);
        }
    }

    module _bottom(diameter) {
        translate([width / 2, length / 2, 0]) {
            cylinder(
                d = diameter,
                h = e
            );
        }
    }

    module _outer_walls() {
        hull() {
            _top(height);
            _bottom(LED_DIAMETER + tolerance * 2 + wall * 2);
        }
    }

    module _inner_cavity() {
        hull() {
            _top(height - 1);
            _bottom(LED_DIAMETER + tolerance * 2);
        }
    }

    module _keys_mount_rail_and_nut_cavity() {
        translate([-e, -e, 0]) {
            cube([
                width + e * 2,
                keys_mount_rail_and_nut_cavity_length + e,
                keys_mount_rail_and_nut_cavity_height
            ]);
        }
    }

    translate([width / -2, length / -2, 0]) {
        difference() {
            _outer_walls();

            _keys_mount_rail_and_nut_cavity();
            _inner_cavity();
        }
    }
}
