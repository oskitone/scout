KEYSTONE_181_HEIGHT = 7;
KEYSTONE_181_CONTACT_X = KEYSTONE_181_HEIGHT / 2;
KEYSTONE_181_CADENCE = 10.5;
KEYSTONE_181_WIDTH = KEYSTONE_181_CADENCE + KEYSTONE_181_CONTACT_X * 2;
KEYSTONE_181_DIAMETER = .5;

KEYSTONE_181_SPRING_LENGTH = 7.2;
KEYSTONE_181_SPRING_COMPRESSED_LENGTH = KEYSTONE_181_SPRING_LENGTH * .25;

KEYSTONE_181_BUTTON_LENGTH = 1.4;

KEYSTONE_181_GUTTER = 0;

KEYSTONE_180_CUT_LEAD_HEIGHT = 5;

// 5204: NEGATIVE SPRING WITH TAB
// 5226: POSITIVE BUTTON WITH TAB
KEYSTONE_5204_5226_WIDTH = 9.2;
KEYSTONE_5204_5226_LENGTH = .51;
KEYSTONE_5204_5226_FULL_LENGTH = 1; // includes lil tabs
KEYSTONE_5204_5226_HEIGHT = 10.4;
KEYSTONE_5204_5226_CONTACT_Z = 5.5;
KEYSTONE_5204_5226_TAB_WIDTH = 3;
KEYSTONE_5204_5226_TAB_HEIGHT = 17 - KEYSTONE_5204_5226_HEIGHT;
KEYSTONE_5204_5226_DIMPLE_LENGTH = 1;

DUAL = "dual";
BUTTON = "button";
SPRING = "spring";

module keystone_wire_contact(
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

module keystone_tabbed_contact(
    type = BUTTON,
    flip = false,
    show_tab = true,

    width = KEYSTONE_5204_5226_WIDTH,
    length = KEYSTONE_5204_5226_LENGTH,
    height = KEYSTONE_5204_5226_HEIGHT,

    contact_diameter = 6,
    contact_button_length = 1,
    contact_spring_length = KEYSTONE_181_SPRING_COMPRESSED_LENGTH,
    contact_z = KEYSTONE_5204_5226_CONTACT_Z,

    tab_width = KEYSTONE_5204_5226_TAB_WIDTH,
    tab_height = KEYSTONE_5204_5226_TAB_HEIGHT
) {
    e = .072;

    module _output() {
        cube([width, length, height]);

        if (show_tab) {
            translate([(width - tab_width) / 2, 0, -tab_height]) {
                cube([tab_width, length, tab_height + e]);
            }
        }

        translate([width / 2, length - e, contact_z]) {
            rotate([-90, 0, 0]) {
                cylinder(
                    d1 = contact_diameter,
                    d2 = contact_diameter * .67,
                    h = type == SPRING
                        ? contact_spring_length + e
                        : contact_button_length + e
                );
            }
        }
    }

    if (flip) {
        translate([0, 0, -contact_z]) {
            rotate([0, 0, 90]) {
                _output();
            }
        }
    } else {
        translate([0, width, -contact_z]) {
            rotate([0, 0, -90]) {
                _output();
            }
        }
    }
}

module battery_contacts(
    tolerance = 0,
    show_tabs = true,
    gutter = KEYSTONE_181_GUTTER,
    count = 3,
    end_terminal_bottom_right = true
) {
    e = .091;

    cavity_width = get_battery_holder_cavity_width(tolerance);
    start_on_right = end_terminal_bottom_right;

    function get_y(contact_width, i, is_dual = false) = (
        (AAA_BATTERY_DIAMETER + gutter) * i
        + (AAA_BATTERY_DIAMETER * (is_dual ? 2 : 1) - contact_width) / 2
    );

    if (floor(count) > 1) {
        for (i = [0 : floor(count)]) {
            is_even = i % 2 == 0;

            left_x = e;
            right_x = cavity_width - tolerance * 2 - e;

            z = AAA_BATTERY_DIAMETER / 2;

            if (i <= count - 2) {
                x = is_even
                    ? start_on_right ? right_x : left_x
                    : start_on_right ? left_x : right_x;

                translate([x, get_y(KEYSTONE_181_WIDTH, i, true), z]) {
                    keystone_wire_contact(
                        flip = start_on_right ? is_even : !is_even
                    );
                }
            }

            if (i == 0) {
                x = start_on_right ? left_x : right_x;

                translate([x, get_y(KEYSTONE_5204_5226_WIDTH, i), z]) {
                    keystone_tabbed_contact(
                        flip = !start_on_right,
                        type = BUTTON,
                        show_tab = show_tabs
                    );
                }
            } else if (i == count - 1) {
                x = start_on_right ? right_x : left_x;

                translate([x, get_y(KEYSTONE_5204_5226_WIDTH, i), z]) {
                    keystone_tabbed_contact(
                        flip = start_on_right,
                        type = SPRING,
                        show_tab = show_tabs
                    );
                }
            }
        }
    }
}
