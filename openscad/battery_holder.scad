/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/basic_shapes.scad>;

include <batteries.scad>;
include <battery_contacts.scad>;

BATTERY_HOLDER_NUB_FIXTURE_WIDTH = 10;
BATTERY_HOLDER_NUB_FIXTURE_DEPTH = .6;
BATTERY_HOLDER_NUB_FIXTURE_HEIGHT = 1;
BATTERY_HOLDER_NUB_FIXTURE_Z = AAA_BATTERY_DIAMETER;

function get_battery_holder_cavity_width(
    tolerance = 0
) = (
    AAA_BATTERY_TOTAL_LENGTH
        + KEYSTONE_181_SPRING_COMPRESSED_LENGTH
        + KEYSTONE_181_BUTTON_LENGTH
        + tolerance * 2
);

function get_battery_holder_width(
    tolerance = 0,
    wall = ENCLOSURE_INNER_WALL
) = (
    get_battery_holder_cavity_width(tolerance)
    + wall * 2
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

function get_battery_holder_length(
    tolerance = 0,
    wall = ENCLOSURE_INNER_WALL
) = (
    get_battery_holder_cavity_length(3, tolerance)
    + wall * 2
);

module battery_contact_fixture(
    height = KEYSTONE_181_HEIGHT,
    tolerance = 0,
    contact_z = undef,

    flip = false,
    floor_cavity_height,

    diameter = KEYSTONE_181_HEIGHT,
    depth = max(KEYSTONE_5204_5226_FULL_LENGTH, KEYSTONE_181_DIAMETER),
    back_shunt = 0,

    wall = 2,
    contact_wall = .8,

    include_wire_contact_fins = false
) {
    e = .048;

    contact_z = contact_z != undef
        ? contact_z
        : height - AAA_BATTERY_DIAMETER / 2;
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

    module _wire_contact_fin(_length = outer_length, clearance = 1) {
        _width = KEYSTONE_181_CADENCE - KEYSTONE_181_CONTACT_X - clearance * 2;
        _height = KEYSTONE_181_HEIGHT / 2 - KEYSTONE_181_DIAMETER;

        translate([outer_width/ 2, outer_length - _length, contact_z]) {
            flat_top_rectangular_pyramid(
                top_width = _width,
                top_length = _length + e,
                bottom_width = 0,
                bottom_length = _length + e,
                height = _height
            );
        }
    }

    module _floor_cavity() {
        translate([wall, contact_wall, -floor_cavity_height]) {
            cube([cavity_width, cavity_depth + e, floor_cavity_height + e]);
        }
    }

    module _output() {
        difference() {
            cube([outer_width, outer_length, height]);

            translate([wall, contact_wall, cavity_z]) {
                cube([
                    cavity_width,
                    cavity_depth - back_shunt + e,
                    cavity_height
                ]);
            }

            translate([wall + contact_wall, -e, exposure_z]) {
                cube([exposure_width, contact_wall + e * 2, exposure_height]);
            }
        }

        if (include_wire_contact_fins) {
            _wire_contact_fin();
        }
    }

    translate(flip ? [outer_length, y, 0] : [-outer_length, y + outer_width, 0]) {
        rotate(flip ? [0, 0, 90] : [0, 0, -90]) {
            if (floor_cavity_height) {
                _floor_cavity();
            } else {
                _output();
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
                + AAA_BATTERY_LENGTH * .25 * (contact_i ? -1 : 1);
            y = battery_i * (AAA_BATTERY_DIAMETER + gutter) - tolerance
                + AAA_BATTERY_DIAMETER / 2;

            translate([x, y, -(z + e)]) {
                enclosure_engraving(
                    string = get_label(battery_i, contact_i),
                    size = AAA_BATTERY_DIAMETER * .75,
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
    floor_cavity_height,
    start_on_right = false,
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

            if (i <= count - 2 && !floor_cavity_height) {
                x = is_even
                    ? start_on_right ? right_x : left_x
                    : start_on_right ? left_x : right_x;

                translate([x, get_y(KEYSTONE_181_WIDTH, i, true), 0]) {
                    battery_contact_fixture(
                        flip = start_on_right ? !is_even : is_even,
                        diameter = KEYSTONE_181_WIDTH,
                        back_shunt = KEYSTONE_5204_5226_FULL_LENGTH
                            - KEYSTONE_181_DIAMETER,
                        tolerance = tolerance,
                        height = height - e,
                        include_wire_contact_fins = true
                    );
                }
            }

            if (i == 0) {
                x = start_on_right ? left_x : right_x;

                translate([x, get_y(KEYSTONE_5204_5226_WIDTH, i), 0]) {
                    battery_contact_fixture(
                        flip = start_on_right,
                        floor_cavity_height = floor_cavity_height,
                        diameter = KEYSTONE_5204_5226_WIDTH,
                        wall = tab_contact_fixture_wall,
                        tolerance = tolerance,
                        contact_z = 0,
                        height = height - e
                    );
                }
            } else if (i == count - 1) {
                x = start_on_right ? right_x : left_x;

                translate([x, get_y(KEYSTONE_5204_5226_WIDTH, i), 0]) {
                    battery_contact_fixture(
                        flip = !start_on_right,
                        floor_cavity_height = floor_cavity_height,
                        diameter = KEYSTONE_5204_5226_WIDTH,
                        wall = tab_contact_fixture_wall,
                        tolerance = tolerance,
                        contact_z = 0,
                        height = height - e
                    );
                }
            }
        }
    }
}

module battery_holder(
    wall = ENCLOSURE_INNER_WALL,
    wall_height_extension = 0,
    floor = 0,
    tolerance = 0,
    count = 3,

    fillet = ENCLOSURE_INNER_FILLET,
    gutter = KEYSTONE_181_GUTTER,
    contact_tab_width = KEYSTONE_5204_5226_TAB_WIDTH,
    contact_tab_cavity_length =
        KEYSTONE_5204_5226_LENGTH + KEYSTONE_5204_5226_DIMPLE_LENGTH,
    end_terminal_bottom_right = true,

    outer_color = undef,
    cavity_color = undef,

    back_hitch_length = 0,
    back_hitch_height = 0,

    quick_preview = true
) {
    e = .0837;

    cavity_width = get_battery_holder_cavity_width(tolerance);
    cavity_length = get_battery_holder_cavity_length(count, tolerance, gutter);

    width = get_battery_holder_width(tolerance, wall);
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

    module _contact_tab_cavities(start_on_right = !end_terminal_bottom_right) {
        x = -(wall + tolerance);

        _width = wall + contact_tab_cavity_length;
        _length = contact_tab_width + tolerance * 2;
        _height = floor + height * .25;

        left_x = -(wall + tolerance) - e;
        right_x = width - _width + x + e;

        for (xy = [
            [
                start_on_right ? left_x : right_x,
                (AAA_BATTERY_DIAMETER + gutter) * (count - 1)
                    + AAA_BATTERY_DIAMETER / 2
            ],
            [
                start_on_right ? right_x : left_x,
                AAA_BATTERY_DIAMETER / 2
            ]
        ]) {
            translate([xy.x, xy.y - _length / 2, -(e + floor)]) {
                cube([_width, _length, _height]);
            }
        }
    }

    module _nub_fixture_cavity(clearance = .1) {
        _width = BATTERY_HOLDER_NUB_FIXTURE_WIDTH + (clearance + tolerance) * 2;
        _length = wall + e * 2;
        _height = BATTERY_HOLDER_NUB_FIXTURE_HEIGHT
            + (clearance + tolerance) * 2;

        x = wall_xy + (width - _width) / 2;
        y = wall_xy - e;
        z = BATTERY_HOLDER_NUB_FIXTURE_Z - (clearance + tolerance) - floor;

        translate([x, y, z]) {
            cube([_width, _length + e, _height]);
        }
    }

    module _wire_relief_hitches(
        _width = 3,
        end_gutter = wall,
        hole_diameter = 2 + tolerance * 2
    ) {
        for (x = [
            wall_xy + end_gutter,
            wall_xy + width - _width - end_gutter
        ]) {
            translate([x, length + wall_xy, -floor]) {
                difference() {
                    cube([_width, back_hitch_length, back_hitch_height]);

                    translate([-e, hole_diameter / 2, back_hitch_height / 2]) {
                        rotate([0, 90, 0]) {
                            cylinder(
                                d = hole_diameter,
                                h = _width + e * 2,
                                $fn = quick_preview ? undef : LOFI_ROUNDING
                            );
                        }
                    }
                }
            }
        }
    }

    difference() {
        color(outer_color) {
            union() {
                battery_contact_fixtures(
                    tolerance = tolerance,
                    gutter = gutter,
                    height = height - floor,
                    start_on_right = end_terminal_bottom_right,
                    count = count
                );

                difference() {
                    translate([wall_xy, wall_xy, -floor]) {
                        rounded_cube(
                            [width, length, height],
                            radius = fillet,
                            $fn = quick_preview ? undef : DEFAULT_ROUNDING
                        );
                    }

                    translate([-tolerance, -tolerance, 0]) {
                        cube([
                            cavity_width,
                            cavity_length,
                            AAA_BATTERY_DIAMETER + wall_height_extension + e * 2
                        ]);
                    }
                }

                _alignment_rails();

                _wire_relief_hitches();
            }
        }

        color(cavity_color) {
            if (floor > 0) {
                battery_contact_fixtures(
                    tolerance = tolerance,
                    gutter = gutter,
                    floor_cavity_height = KEYSTONE_5204_5226_CONTACT_Z
                        - (AAA_BATTERY_DIAMETER / 2),
                    start_on_right = end_terminal_bottom_right,
                    count = count
                );

                _contact_tab_cavities();

                battery_direction_engravings(
                    tolerance = tolerance,
                    z = floor
                );
            }

            _nub_fixture_cavity();
        }
    }
}

* translate([0, -40, 0]) {
    # % battery_array();
    battery_holder(wall = 3, tolerance = .3, floor = 1, end_terminal_bottom_right = 1);
    % battery_contacts(tolerance = .3, end_terminal_bottom_right = 1);
}
