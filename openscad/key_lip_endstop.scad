module key_lip_endstop(
    keys_cavity_height_z,
    keys_full_width,

    distance_into_keys_bleed = 0,
    travel = 0,

    key_gutter,

    // HEY! These values are eyeballed and that's okay, I guess. What we want
    // is for the keys to have a good bottom lip and for their fillets to not
    // get messed up too much.
    distance_from_cavity_z = 1.5,
    distance_into_keys = .6
) {
    e = .038;

    length = distance_into_keys + distance_into_keys_bleed + key_gutter + e;
    width = keys_full_width + key_gutter * 2 + e * 2;

    z = keys_cavity_height_z - distance_from_cavity_z;

    module _endstop(_z) {
        translate([ENCLOSURE_WALL - e, ENCLOSURE_WALL, _z]) {
            rotate([0, 90, 0]) {
                cylinder(
                    d = length * 2,
                    h = width,
                    $fn = 4
                );
            }
        }
    }

    hull() {
        _endstop(z);

        if (travel > 0) {
            _endstop(z + travel);
        }
    }
}
