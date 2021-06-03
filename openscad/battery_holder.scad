/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/basic_shapes.scad>;

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
    depth = max(KEYSTONE_5204_5226_FULL_LENGTH, KEYSTONE_181_DIAMETER),

    wall = 2,
    contact_wall = .8,

    include_wire_tabs = false
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

    module _wire_tabs(
        _width = 2,
        _length = 1.5,
        _height = 1.25
    ) {
        for (z = [
            height - exposure_height + KEYSTONE_181_DIAMETER,
            height - _height
        ]) {
            translate([(outer_width - _width) / 2, outer_length - _length, z]) {
                cube([_width, _length + e, _height]);
            }
        }
    }

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

            if (include_wire_tabs) {
                _wire_tabs();
            }
        }
    }
}

module battery_direction_engravings(
    tolerance = 0,
    z = 0,
    gutter = KEYSTONE_181_GUTTER,
    height = AAA_BATTERY_DIAMETER,
    count = 3
) {
    e = .0351;

    function get_label(battery_i, contact_i) = (
        battery_i % 2
            ? contact_i ? "-" : "+"
            : contact_i ? "+" : "-"
    );

    for (battery_i = [0 : count - 1]) {
        for (contact_i = [0 : 1]) {
            x = get_battery_holder_cavity_width(tolerance) / 2 - tolerance
                + AAA_BATTERY_LENGTH * .33 * (contact_i ? -1 : 1);
            y = battery_i * (AAA_BATTERY_DIAMETER + gutter) - tolerance
                + AAA_BATTERY_DIAMETER / 2;

            translate([x, y, -(z + e)]) {
                enclosure_engraving(
                    string = get_label(battery_i, contact_i),
                    size = AAA_BATTERY_DIAMETER * .5,
                    bottom = true,
                    enclosure_height = z,
                    quick_preview = false
                );
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
    tab_contact_fixture_wall = AAA_BATTERY_DIAMETER - KEYSTONE_5204_5226_WIDTH;

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
                        tolerance = tolerance,
                        height = height - e,
                        include_wire_tabs = true
                    );
                }
            }

            if (i == 0) {
                translate([right_x, get_y(KEYSTONE_5204_5226_WIDTH, i), 0]) {
                    battery_contact_fixture(
                        flip = false,
                        diameter = KEYSTONE_5204_5226_WIDTH,
                        wall = tab_contact_fixture_wall,
                        tolerance = tolerance,
                        height = height - e
                    );
                }
            } else if (i == count - 1) {
                translate([left_x, get_y(KEYSTONE_5204_5226_WIDTH, i), 0]) {
                    battery_contact_fixture(
                        flip = true,
                        diameter = KEYSTONE_5204_5226_WIDTH,
                        wall = tab_contact_fixture_wall,
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
    gutter = KEYSTONE_181_GUTTER,
    contact_tab_width = KEYSTONE_5204_5226_TAB_WIDTH,
    contact_tab_cavity_length =
        KEYSTONE_5204_5226_LENGTH + KEYSTONE_5204_5226_DIMPLE_LENGTH,
    quick_preview = true
) {
    e = .0837;

    cavity_width = get_battery_holder_cavity_width(tolerance);
    cavity_length = get_battery_holder_cavity_length(count, tolerance, gutter);

    width = cavity_width + wall * 2;
    length = cavity_length + wall * 2;
    height = AAA_BATTERY_DIAMETER + floor + wall_height_extension;

    wall_xy = -(wall + tolerance);

    module _alignment_rails(
        _width = AAA_BATTERY_LENGTH * .33,
        _length = ENCLOSURE_INNER_WALL,
        _height = AAA_BATTERY_DIAMETER * .25
    ) {
        x = (cavity_width - _width) / 2 - tolerance;

        for (i = [1 : count - 1]) {
            y = i * (AAA_BATTERY_DIAMETER + gutter) - _length / 2;

            translate([x, y, -e]) {
                cube([_width, _length, _height + e]);
            }
        }
    }

    module _contact_tab_cavities(
        _length = contact_tab_width + tolerance * 2,
        _height = floor + height * .25
    ) {
        _width = wall + contact_tab_cavity_length;

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
            translate([xy.x, xy.y - _length / 2, -(e + floor)]) {
                cube([_width + e, _length, _height + e]);
            }
        }
    }

    module _wire_relief_holes(
        diameter = 4 + tolerance * 2,
        gutter = 8
    ) {
        center_x = width / 2 + wall_xy;
        y = wall_xy + length - wall - e;
        z = diameter / 2 + e;

        for (x = [center_x - gutter, center_x, center_x + gutter]) {
            translate([x, y, z]) {
                rotate([-90, 0, 0]) {
                    cylinder(
                        d = diameter,
                        h = wall + e * 2,
                        $fn = quick_preview ? 0 : LOFI_ROUNDING
                    );
                }
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
                translate([wall_xy, wall_xy, -floor]) {
                    rounded_cube(
                        [width, length, height],
                        radius = ENCLOSURE_INNER_FILLET,
                        $fn = quick_preview ? undef : LOFI_ROUNDING
                    );
                }

                translate([-tolerance, -tolerance, -e]) {
                    cube([
                        cavity_width,
                        cavity_length,
                        AAA_BATTERY_DIAMETER + wall_height_extension + e * 2
                    ]);
                }
            }

            _alignment_rails();
        }

        if (floor > 0) {
            _contact_tab_cavities();

            _wire_relief_holes();

            battery_direction_engravings(
                tolerance = tolerance,
                z = floor
            );
        }
    }
}

* translate([0, -40, 0]) {
    % battery_array();
    battery_holder(tolerance = .3, floor = 1);
    % battery_contacts(tolerance = .3);
}
