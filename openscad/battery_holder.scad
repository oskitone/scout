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

    wall = 2,
    contact_wall = .8
) {
    e = .048;

    contact_z = contact_z ? contact_z : height - AAA_BATTERY_DIAMETER / 2;
    cavity_z = contact_z - KEYSTONE_181_HEIGHT / 2 - e;

    cavity_width = diameter + tolerance * 2;
    cavity_depth = depth + tolerance;
    cavity_height = height - cavity_z + e;

    exposure_width = cavity_width - contact_wall * 2;
    exposure_height = cavity_height - contact_wall;
    exposure_z = cavity_z + contact_wall;

    outer_width = cavity_width + wall * 2;
    outer_length = cavity_depth + contact_wall;

    y = -(tolerance + wall);

    translate(flip ? [outer_length, y, 0] : [-outer_length, y + outer_width, 0]) {
        rotate(flip ? [0, 0, 90] : [0, 0, -90]) {
            difference() {
                cube([outer_width, outer_length, height]);

                translate([wall, contact_wall, cavity_z]) {
                    cube([cavity_width, cavity_depth + e, cavity_height]);
                }

                translate([wall + contact_wall, -e, exposure_z]) {
                    cube([exposure_width, contact_wall + e * 2, exposure_height]);
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

    function get_y(contact_width, i, is_dual = false) = (
        (AAA_BATTERY_DIAMETER + gutter) * i
        + (AAA_BATTERY_DIAMETER * (is_dual ? 2 : 1) - contact_width) / 2
    );

    if (floor(count) > 1) {
        for (i = [0 : floor(count)]) {
            is_even = i % 2 == 0;

            left_x = -e - tolerance;
            right_x = cavity_width - tolerance + e;

            if (i <= count - 2) {
                x = is_even ? left_x : right_x;
                translate([x, get_y(KEYSTONE_181_WIDTH, i, true), 0]) {
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
                translate([right_x, get_y(KEYSTONE_5204_5226_WIDTH, i), 0]) {
                    battery_contact_fixture(
                        flip = false,
                        diameter = KEYSTONE_5204_5226_WIDTH,
                        depth = KEYSTONE_181_DIAMETER + e,
                        tolerance = tolerance,
                        height = height - e
                    );
                }
            } else if (i == count - 1) {
                translate([left_x, get_y(KEYSTONE_5204_5226_WIDTH, i), 0]) {
                    battery_contact_fixture(
                        flip = true,
                        diameter = KEYSTONE_5204_5226_WIDTH,
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
    floor = 1,
    tolerance = 0,
    count = 3,
    gutter = KEYSTONE_181_GUTTER,

    contact_width = KEYSTONE_5204_5226_WIDTH,
    contact_length = KEYSTONE_5204_5226_LENGTH,
    contact_z = KEYSTONE_5204_5226_CONTACT_Z,
    contact_tab_width = KEYSTONE_5204_5226_TAB_WIDTH,
    contact_tab_cavity_length =
        KEYSTONE_5204_5226_LENGTH + KEYSTONE_5204_5226_DIMPLE_LENGTH
) {
    e = .0837;

    cavity_width = get_battery_holder_cavity_width(tolerance);
    cavity_length = get_battery_holder_cavity_length(count, tolerance, gutter);

    width = cavity_width + wall * 2;
    length = cavity_length + wall * 2;
    height = AAA_BATTERY_DIAMETER + floor + wall_height_extension;

    // TODO: inner alignment rails

    // This is the worst!
    // TODO: rewrite if keeping
    module _contact_tab_cavities(
        _length = contact_tab_width + tolerance * 2
    ) {
        _width = wall + contact_tab_cavity_length;
        _height = floor + e * 2 + 2; // TODO: no!
        floor_cavity_height = (contact_z) - AAA_BATTERY_DIAMETER / 2;

        for (xy = [
            [
                -(wall + tolerance + e),
                (AAA_BATTERY_DIAMETER + gutter) * (count - 1)
                    + AAA_BATTERY_DIAMETER / 2
            ],
            [
                cavity_width - tolerance - contact_tab_cavity_length,
                AAA_BATTERY_DIAMETER / 2
            ]
        ]) {
            translate([xy.x, xy.y - _length / 2, -(floor + e)]) {
                cube([
                    _width + e,
                    _length,
                    _height + e
                ]);
            }
        }

        for (xy = [
            [
                0,
                (AAA_BATTERY_DIAMETER + gutter) * (count - 1)
                    + AAA_BATTERY_DIAMETER / 2
            ],
            [
                cavity_width - tolerance * 2 - contact_length - e * 2,
                AAA_BATTERY_DIAMETER / 2
            ]
        ]) {
            * translate([xy.x, xy.y - contact_width / 2, -floor_cavity_height]) {
                cube([
                    contact_length + e * 2,
                    contact_width,
                    floor_cavity_height
                ]);
            }
        }


    }

    difference() {
        union() {
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
            }
        }

        _contact_tab_cavities();
    }
}

translate([0, -40, 0]) {
    /* % battery_array(); */
    battery_holder(tolerance = .3);
    /* % battery_contacts(tolerance = .3); */
}
