include <battery_contacts.scad>;

AAA_BATTERY_DIAMETER = 10.5;
AAA_BATTERY_LENGTH = 44.5;

AAA_BATTERY_POSITIVE_CONTACT_MIN_LENGTH = .8;
AAA_BATTERY_POSITIVE_CONTACT_MAX_DIAMETER = 3.8;

AAA_BATTERY_TOTAL_LENGTH = AAA_BATTERY_LENGTH +
    AAA_BATTERY_POSITIVE_CONTACT_MIN_LENGTH;

module battery(reverse = false) {
    module _output() {
        translate([0, AAA_BATTERY_DIAMETER / 2, AAA_BATTERY_DIAMETER / 2]) {
            rotate([0, 90, 0]) {
                cylinder(
                    d = AAA_BATTERY_DIAMETER,
                    h = AAA_BATTERY_LENGTH
                );

                translate([0, 0, AAA_BATTERY_LENGTH]) {
                    cylinder(
                        d = AAA_BATTERY_POSITIVE_CONTACT_MAX_DIAMETER,
                        h = AAA_BATTERY_POSITIVE_CONTACT_MIN_LENGTH
                    );
                }
            }
        }
    }

    if (reverse) {
        translate([AAA_BATTERY_TOTAL_LENGTH, 0, 0]) {
            mirror([1, 0, 0]) {
                _output();
            }
        }
    } else {
        _output();
    }
}

module battery_array(
    count = 3,
    gutter = KEYSTONE_181_GUTTER,

    positive_x = KEYSTONE_181_BUTTON_LENGTH,
    negative_x = KEYSTONE_181_SPRING_COMPRESSED_LENGTH
) {
    plot = AAA_BATTERY_DIAMETER + gutter;

    for (i = [0 : count - 1]) {
        is_odd = i % 2 == 1;

        translate([is_odd ? positive_x : negative_x, i * plot, 0]) {
            battery(reverse = is_odd);
        }
    }
}

function get_battery_fixture_cavity_width(
    tolerance = 0
) = (
    AAA_BATTERY_TOTAL_LENGTH
        + KEYSTONE_181_SPRING_COMPRESSED_LENGTH
        + KEYSTONE_181_BUTTON_LENGTH
        + tolerance * 2
);

function get_battery_fixture_cavity_length(
    count,
    tolerance,
    gutter = KEYSTONE_181_GUTTER
) = (
    AAA_BATTERY_DIAMETER * count
        + gutter * (count - 1)
        + tolerance * 2
);

module battery_fixture_contacts(
    tolerance = 0,
    gutter = KEYSTONE_181_GUTTER,
    count = 3
) {
    e = .091;

    cavity_width = get_battery_fixture_cavity_width(tolerance);

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

module battery_fixture(
    wall = 2,
    wall_height_extension = 0,
    floor = 0,
    tolerance = 0,
    count = 3,
    gutter = KEYSTONE_181_GUTTER
) {
    e = .0837;

    cavity_width = get_battery_fixture_cavity_width(tolerance);
    cavity_length = get_battery_fixture_cavity_length(count, tolerance, gutter);

    width = cavity_width + wall * 2;
    length = cavity_length + wall * 2;
    height = AAA_BATTERY_DIAMETER + floor + wall_height_extension;

    // TODO: inner alignment rails

    difference() {
        translate([-(wall + tolerance), -(wall + tolerance), -floor]) {
            cube([width, length, height]);
        }

        translate([-tolerance, -tolerance, -e]) {
            cube([
                cavity_width,
                cavity_length,
                AAA_BATTERY_DIAMETER + wall_height_extension + e * 2
            ]);
        }
    }
}
