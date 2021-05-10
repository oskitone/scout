include <batteries.scad>;
include <battery_contacts.scad>;

function get_battery_holder_cavity_width(
    tolerance = 0
) = (
    AAA_BATTERY_TOTAL_LENGTH
        + KEYSTONE_181_SPRING_COMPRESSED_LENGTH
        + KEYSTONE_181_BUTTON_LENGTH
        + tolerance * 2
);

function get_battery_holder_cavity_length(
    count,
    tolerance,
    gutter = KEYSTONE_181_GUTTER
) = (
    AAA_BATTERY_DIAMETER * count
        + gutter * (count - 1)
        + tolerance * 2
);

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

module battery_contact_fixtures(
    tolerance = 0,
    gutter = KEYSTONE_181_GUTTER,
    height = AAA_BATTERY_DIAMETER,
    count = 3
) {
    e = .091;

    cavity_width = get_battery_holder_cavity_width(tolerance);

    if (floor(count) > 1) {
        for (i = [0 : floor(count)]) {
            is_even = i % 2 == 0;

            left_x = -e - tolerance;
            right_x = cavity_width - tolerance + e;

            y = (AAA_BATTERY_DIAMETER + gutter) * i
                + (AAA_BATTERY_DIAMETER * 2 - KEYSTONE_181_WIDTH) / 2;

            if (i <= count - 2) {
                translate([is_even ? left_x : right_x, y, 0]) {
                    battery_contact_fixture(
                        flip = is_even,
                        diameter = KEYSTONE_181_WIDTH,
                        depth = KEYSTONE_181_DIAMETER + e,
                        tolerance = tolerance,
                        height = height - e
                    );
                }
            }

            if (i == 0) {
                translate([right_x, y, 0]) {
                    battery_contact_fixture(
                        flip = false,
                        diameter = KEYSTONE_181_HEIGHT,
                        depth = KEYSTONE_181_DIAMETER + e,
                        tolerance = tolerance,
                        height = height - e
                    );
                }
            } else if (i == count - 1) {
                translate([left_x, y, 0]) {
                    battery_contact_fixture(
                        flip = true,
                        depth = KEYSTONE_181_DIAMETER + e,
                        tolerance = tolerance,
                        height = height - e
                    );
                }
            }
        }
    }
}

module battery_holder(
    wall = 2,
    wall_height_extension = 0,
    floor = 0,
    tolerance = 0,
    count = 3,
    gutter = KEYSTONE_181_GUTTER
) {
    e = .0837;

    cavity_width = get_battery_holder_cavity_width(tolerance);
    cavity_length = get_battery_holder_cavity_length(count, tolerance, gutter);

    width = cavity_width + wall * 2;
    length = cavity_length + wall * 2;
    height = AAA_BATTERY_DIAMETER + floor + wall_height_extension;

    // TODO: inner alignment rails

    module _output_pin_cavities(
        _length = KEYSTONE_181_DIAMETER + tolerance * 2
    ) {
        _height = (height - KEYSTONE_181_HEIGHT) / 2;
        z = height - _height;

        for (xy = [
            [
                -(wall + tolerance + e),
                (AAA_BATTERY_DIAMETER + gutter) * (count - 1)
                    + (AAA_BATTERY_DIAMETER - _length) / 2
            ],
            [
                cavity_width - tolerance - e,
                (AAA_BATTERY_DIAMETER - _length) / 2
            ]
        ]) {
            translate([xy.x, xy.y, z]) {
                cube([
                    wall + e * 2,
                    _length,
                    _height + e
                ]);
            }
        }
    }

    battery_contact_fixtures(
        tolerance = tolerance,
        gutter = gutter,
        height = height - floor,
        count = count
    );

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

        _output_pin_cavities();
    }
}

/* translate([0, -40, 0]) {
    % battery_array();
    battery_holder(tolerance = .3);
    % battery_contacts(tolerance = .3);
} */
