KEYSTONE_181_HEIGHT = 7;
KEYSTONE_181_CONTACT_X = KEYSTONE_181_HEIGHT / 2;
KEYSTONE_181_CADENCE = 10.5;
KEYSTONE_181_WIDTH = KEYSTONE_181_CADENCE + KEYSTONE_181_CONTACT_X * 2;
KEYSTONE_181_DIAMETER = .5;

KEYSTONE_181_SPRING_LENGTH = 7.2;
KEYSTONE_181_SPRING_COMPRESSED_LENGTH = KEYSTONE_181_SPRING_LENGTH * .3;

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

module battery_contacts(
    tolerance = 0,
    gutter = KEYSTONE_181_GUTTER,
    count = 3
) {
    e = .091;

    cavity_width = get_battery_holder_cavity_width(tolerance);

    if (floor(count) > 1) {
        for (i = [0 : floor(count)]) {
            is_even = i % 2 == 0;

            left_x = e;
            right_x = cavity_width - tolerance * 2 - e;

            y = (AAA_BATTERY_DIAMETER + gutter) * i
                + (AAA_BATTERY_DIAMETER * 2 - KEYSTONE_181_WIDTH) / 2;
            z = AAA_BATTERY_DIAMETER / 2;

            if (i <= count - 2) {
                translate([is_even ? left_x : right_x, y, z]) {
                    keystone_181_dual_battery_contact(flip = !is_even);
                }
            }

            if (i == 0) {
                translate([right_x, 0, z]) {
                    keystone_181_dual_battery_contact(
                        flip = true,
                        type = BUTTON
                    );
                }
            } else if (i == count - 1) {
                translate([left_x, y, z]) {
                    keystone_181_dual_battery_contact(
                        flip = false,
                        type = SPRING
                    );
                }
            }
        }
    }
}
