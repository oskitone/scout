KEYSTONE_181_HEIGHT = 7;
KEYSTONE_181_CONTACT_X = KEYSTONE_181_HEIGHT / 2;
KEYSTONE_181_CADENCE = 10.5;
KEYSTONE_181_WIDTH = KEYSTONE_181_CADENCE + KEYSTONE_181_CONTACT_X * 2;
KEYSTONE_181_DIAMETER = .5;

KEYSTONE_181_SPRING_LENGTH = 7.2;
KEYSTONE_181_SPRING_COMPRESSED_LENGTH = KEYSTONE_181_SPRING_LENGTH * .5;

KEYSTONE_181_BUTTON_LENGTH = 1.4;

KEYSTONE_181_GUTTER = 0; // TODO: measure or derive

module keystone_181_dual_battery_contact(
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

    module _contact(contact_length, x) {
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

    translate([0, 0, flip ? KEYSTONE_181_HEIGHT / -2 : KEYSTONE_181_HEIGHT / 2]) {
        rotate(flip ? [0, 0, 90] : [0, 180, -90]) {
            _contact(
                compressed ? spring_compressed_length : spring_length, contact_x
            );
            _contact(button_length, width - contact_x);
            _connector();
        }
    }
}
