module tray_fixtures(
    enclosure_dimensions = [],
    tray_dimensions = [],

    tray_z = 0,
    bleed = 0,

    endstop_length = 3,
    z_clearance = DEFAULT_DFM_LAYER_HEIGHT,
    height = 1
) {
    e = .021;

    z = tray_z + tray_dimensions.z / 2;
    extension = tray_dimensions.z / 2 + bleed * 2;

    module _ridge(width, length) {
        height = width ? width + bleed * 2 : length + bleed * 2;
        rotation = width ? [0, 90, 0] : [-90, 0, 0];

        rotate(rotation) {
            translate([0, 0, -bleed]) {
                cylinder(
                    h = height,
                    d = extension * 2,
                    $fn = 4
                );
            }
        }
    }

    module _front(width = 30) {
        x = (enclosure_dimensions.x - width) / 2;

        translate([x, ENCLOSURE_WALL - e, z]) {
            _ridge(width = width);
        }
    }

    module _sides(length = 15) {
        y = TRAY_XY + tray_dimensions.y - length - endstop_length;

        for (x = [
            ENCLOSURE_WALL - e,
            enclosure_dimensions.x - ENCLOSURE_WALL
        ]) {
            translate([x, y, z]) {
                _ridge(length = length);
            }
        }
    }

    _front();
    _sides();
}
