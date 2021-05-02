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
    gutter = 0
) {
    plot = AAA_BATTERY_DIAMETER + gutter;

    for (i = [0 : count - 1]) {
        translate([0, i * plot, 0]) {
            battery(reverse = i % 2 == 1);
        }
    }
}

module battery_fixture(
    wall = 2,
    floor = 0,
    tolerance = 0,
    count = 3,
    gutter = 0
) {
    e = .0837;

    batteries_width = AAA_BATTERY_TOTAL_LENGTH + tolerance * 2;
    batteries_length = AAA_BATTERY_DIAMETER * count
        + gutter * (count - 1)
        + tolerance * 2;

    width = batteries_width + wall * 2;
    length = batteries_length + wall * 2;
    height = AAA_BATTERY_DIAMETER + floor;

    // TODO: inner alignment rails
    // TODO: fixtures for contacts

    difference() {
        translate([-(wall + tolerance), -(wall + tolerance), -floor]) {
            cube([width, length, height]);
        }

        translate([-tolerance, -tolerance, -e]) {
            cube([batteries_width, batteries_length, AAA_BATTERY_DIAMETER + e * 2]);
        }
    }
}
