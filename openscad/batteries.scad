AAA_BATTERY_DIAMETER = 10.5;
AAA_BATTERY_LENGTH = 44.5;

AAA_BATTERY_POSITIVE_CONTACT_MIN_LENGTH = .8;
AAA_BATTERY_POSITIVE_CONTACT_MAX_DIAMETER = 3.8;

AAA_BATTERY_TOTAL_LENGTH = AAA_BATTERY_LENGTH +
    AAA_BATTERY_POSITIVE_CONTACT_MIN_LENGTH;

module battery(
    reverse = false,
    $fn = 24
) {
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
