KEYSTONE_181_HEIGHT = 7;
KEYSTONE_181_CONTACT_X = KEYSTONE_181_HEIGHT / 2;
KEYSTONE_181_CADENCE = 10.5;
KEYSTONE_181_WIDTH = KEYSTONE_181_CADENCE + KEYSTONE_181_CONTACT_X * 2;
KEYSTONE_181_DIAMETER = .5;

KEYSTONE_181_SPRING_LENGTH = 7.2;
KEYSTONE_181_SPRING_COMPRESSED_LENGTH = KEYSTONE_181_SPRING_LENGTH * .5;

KEYSTONE_181_BUTTON_LENGTH = 1.4;

KEYSTONE_181_GUTTER = 0; // TODO: measure or derive

KEYSTONE_180_CUT_LEAD_HEIGHT = 5;

DUAL = "dual";
BUTTON = "button";
SPRING = "spring";

module keystone_181_dual_battery_contact(
    type = DUAL,
    flip = false,

    compressed = true,

    height = KEYSTONE_181_HEIGHT,
    contact_x = KEYSTONE_181_CONTACT_X,
    cadence = KEYSTONE_181_CADENCE,
    width = KEYSTONE_181_WIDTH,
    diameter = KEYSTONE_181_DIAMETER,

    spring_length = KEYSTONE_181_SPRING_LENGTH,
    spring_compressed_length = KEYSTONE_181_SPRING_COMPRESSED_LENGTH,

    button_length = KEYSTONE_181_BUTTON_LENGTH
) {
    e = .094;

    module _contact(
        contact_length,
        x = 0,
        $fn = 12
    ) {
        translate([x, 0, height / 2]) {
            rotate([270, 0, 0]) {
                cylinder(
                    d = height,
                    h = diameter + e
                );

                translate([0, 0, diameter]) {
                    cylinder(
                        d1 = height,
                        d2 = height * .67,
                        h = contact_length - diameter
                    );
                }
            }
        }
    }

    module _connector() {
        translate([contact_x, diameter / 2, height - diameter / 2]) {
            rotate([0, 90, 0]) {
                cylinder(
                    d = diameter,
                    h = cadence
                );
            }
        }
    }

    module arrange(z = 0) {
        y = flip ? KEYSTONE_181_HEIGHT / -2 : KEYSTONE_181_HEIGHT / 2;

        translate([0, z, y]) {
            rotate(flip ? [0, 0, 90] : [0, 180, -90]) {
                children();
            }
        }
    }

    module _spring() {
        _contact(
            compressed ? spring_compressed_length : spring_length, contact_x
        );
    }

    module _button(x = 0) {
        _contact(button_length, x);
    }

    module _dual_contacts() {
        arrange() {
            _spring();
            _button(width - contact_x);
            _connector();
        }
    }

    if (type == DUAL) {
        _dual_contacts();
    } else if (type == BUTTON) {
        arrange(AAA_BATTERY_DIAMETER / 2) {
            _button();

            translate([0, 0, height - e]) {
                cylinder(
                    d = diameter,
                    h = KEYSTONE_180_CUT_LEAD_HEIGHT + e
                );
            }
        }
    } else if (type == SPRING) {
        arrange() {
            _spring();

            translate([height / 2, 0, e - KEYSTONE_180_CUT_LEAD_HEIGHT]) {
                cylinder(
                    d = diameter,
                    h = KEYSTONE_180_CUT_LEAD_HEIGHT + e
                );
            }
        }
    }
}

module battery_contact_fixture(
    height = KEYSTONE_181_HEIGHT,
    tolerance = 0,
    contact_z = undef,

    flip = false,

    diameter = KEYSTONE_181_HEIGHT,
    depth = KEYSTONE_181_DIAMETER,
    wall = 1
) {
    e = .048;

    contact_z = contact_z ? contact_z : height - AAA_BATTERY_DIAMETER / 2;
    cavity_z = contact_z - KEYSTONE_181_HEIGHT / 2 - e;

    cavity_width = diameter + tolerance * 2;
    cavity_depth = depth + tolerance;
    cavity_height = height - cavity_z + e;

    exposure_width = cavity_width - wall * 2;
    exposure_height = cavity_height - wall;
    exposure_z = cavity_z + wall;

    outer_width = cavity_width + wall * 2;
    outer_length = cavity_depth + wall;

    y = -(tolerance + wall);

    translate(flip ? [outer_length, y, 0] : [-outer_length, y + outer_width, 0]) {
        rotate(flip ? [0, 0, 90] : [0, 0, -90]) {
            difference() {
                cube([outer_width, outer_length, height]);

                translate([wall, wall, cavity_z]) {
                    cube([cavity_width, cavity_depth + e, cavity_height]);
                }

                translate([wall * 2, -e, exposure_z]) {
                    cube([exposure_width, wall + e * 2, exposure_height]);
                }
            }
        }
    }
}
