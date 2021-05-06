KEYSTONE_5213_WIDTH = 21;
KEYSTONE_5213_LENGTH = .51;
KEYSTONE_5213_TOTAL_HEIGHT = 11;

KEYSTONE_5213_BOTTOM_TAB_HEIGHT = 1.5;
KEYSTONE_5213_BOTTOM_TAB_WIDTH = 4.5;

KEYSTONE_5213_VALLEY_WIDTH = 1.78;
KEYSTONE_5213_VALLEY_HEIGHT = 7.01; // includes bottom_tab

KEYSTONE_5213_CONTACT_CADENCE = 11.5;
KEYSTONE_5213_CONTACT_Z = 7.5;

KEYSTONE_5213_SPRING_LENGTH = 7; // TODO: measure
KEYSTONE_5213_SPRING_COMPRESSED_LENGTH = KEYSTONE_5213_SPRING_LENGTH / 2;
KEYSTONE_5213_SPRING_DIAMETER = 5;

KEYSTONE_5213_BUTTON_LENGTH = 1; // TODO: measure
KEYSTONE_5213_BUTTON_DIAMETER = 3.2;

module keystone_5213_dual_battery_contact(
    width = KEYSTONE_5213_WIDTH,
    length = KEYSTONE_5213_LENGTH,
    total_height = KEYSTONE_5213_TOTAL_HEIGHT,

    bottom_tab_height = KEYSTONE_5213_BOTTOM_TAB_HEIGHT,
    bottom_tab_width = KEYSTONE_5213_BOTTOM_TAB_WIDTH,

    valley_width = KEYSTONE_5213_VALLEY_WIDTH,
    valley_height = KEYSTONE_5213_VALLEY_HEIGHT,

    contact_z = KEYSTONE_5213_CONTACT_Z,

    spring_length = KEYSTONE_5213_SPRING_LENGTH,
    spring_compressed_length = KEYSTONE_5213_SPRING_COMPRESSED_LENGTH,
    spring_diameter = KEYSTONE_5213_SPRING_DIAMETER,

    button_length = KEYSTONE_5213_BUTTON_LENGTH,
    button_diameter = KEYSTONE_5213_BUTTON_DIAMETER,

    flip = false,
    compressed = true
) {
    e = .01;

    side_width = (width - valley_width) / 2;

    module _plate() {
        difference() {
            translate([0, 0, bottom_tab_height]) {
                cube([width, length, total_height - bottom_tab_height]);
            }

            translate([side_width, -e, -e]) {
                cube([valley_width, length + e * 2, valley_height + e]);
            }
        }
    }

    module _bottom_tabs() {
        for (x = [
            (side_width - bottom_tab_width) / 2,
            side_width + valley_width + (side_width - bottom_tab_width) / 2
        ]) {
            translate([x, 0, 0]) {
                cube([bottom_tab_width, length, bottom_tab_height + e]);
            }
        }
    }

    module _contacts() {
        translate([side_width / 2, e, contact_z]) {
            rotate([90,0,0]) {
                cylinder(
                    d1 = spring_diameter,
                    d2 = spring_diameter * .67,
                    h = compressed ? spring_compressed_length : spring_length
                        + e,
                    $fn = 12
                );
            }
        }

        translate([side_width + valley_width + side_width / 2, e, contact_z]) {
            rotate([90,0,0]) {
                cylinder(
                    d1 = button_diameter,
                    d2 = button_diameter * .67,
                    h = button_length + e,
                    $fn = 12
                );
            }
        }
    }

    translate(flip ? [-length, 0, contact_z * 2] : [length, 0, 0]) {
        rotate(flip ? [180, 0, 90] : [0, 0, 90]) {
            _plate();
            _bottom_tabs();
            _contacts();
        }
    }
}
