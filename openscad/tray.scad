include <battery_holder.scad>;
include <keys.scad>;
include <scout_pcb.scad>;
include <tray_fixtures.scad>;

DEFAULT_TOLERANCE = .1;

TRAY_TO_COMPONENT_CLEARANCE = 1;
TRAY_XY = ENCLOSURE_WALL + DEFAULT_TOLERANCE * 2;

function get_speaker_fixture_diameter(
    wall = 1,
    tolerance = 0,
    speaker_diameter = SPEAKER_DIAMETER
) = (
    SPEAKER_DIAMETER + wall * 2 + tolerance * 2
);

function get_tray_width(enclosure_dimensions = []) = (
    enclosure_dimensions.x - TRAY_XY * 2
);

function get_tray_length(
    pcb_position = [],

    tolerance = DEFAULT_TOLERANCE,
    y = TRAY_XY,
    include_keys_mount_rail = false
) = (
    include_keys_mount_rail
        ? pcb_position.y + PCB_HOLE_POSITIONS[0].y
            - keys_mount_length / 2
            - y // TODO: + e if keeping
        : pcb_position.y + PCB_BUTTON_POSITIONS[0].y
            - BUTTON_DIAMETER / 2
            - (tolerance + TRAY_TO_COMPONENT_CLEARANCE)
            - y
);

module tray(
    height,
    enclosure_dimensions = [],
    keys_position = [],
    pcb_position = [],
    speaker_position = [],
    batteries_position = [],
    speaker_rim_height,
    speaker_rim_depth,
    wall = ENCLOSURE_INNER_WALL,
    key_width,
    key_length,
    key_travel = 0,
    tolerance = 0,

    include_keys_mount_rail = false
) {
    e = .0398;

    z = pcb_position.z + PCB_HEIGHT;

    width = get_tray_width(enclosure_dimensions);
    length = get_tray_length(pcb_position);

    module _keys_mount_rail() {
        translate([
            keys_position.x,
            keys_position.y,
            pcb_position.z + PCB_HEIGHT
        ]) {
            keys_mount_rail(
                height = BUTTON_HEIGHT,
                key_width = key_width,
                key_length = key_length,
                front_y_bleed = 0,
                tolerance = tolerance
            );
        }
    }


    module _plate() {
        translate([TRAY_XY, TRAY_XY, z]) {
            cube([width, length, height]);
        }
    }

    module _button_cavities() {
        button_x = pcb_position.x
            + PCB_BUTTON_POSITIONS[len(PCB_BUTTON_POSITIONS) - 1].x
            - BUTTON_DIAMETER / 2
            - (tolerance + TRAY_TO_COMPONENT_CLEARANCE);

        translate([
            button_x,
            pcb_position.y + PCB_BUTTON_POSITIONS[0].y
                - BUTTON_DIAMETER / 2
                - (tolerance + TRAY_TO_COMPONENT_CLEARANCE),
            z - e
        ]) {
            cube([
                enclosure_dimensions.x - button_x * 2,
                BUTTON_DIAMETER + (tolerance + TRAY_TO_COMPONENT_CLEARANCE) * 2,
                height + e * 2
            ]);
        }
    }

    module _speaker_wall(
        tab_cavity_rotation = 90,
        tab_cavity_size = 15
    ) {
        wall_height = SPEAKER_HEIGHT - (height - speaker_rim_height);
        height = wall_height + e;

        diameter = SPEAKER_DIAMETER + tolerance * 2 + wall * 2;

        translate([speaker_position.x, speaker_position.y, z - wall_height]) {
            difference() {
                cylinder(
                    d = diameter,
                    h = height
                );

                rotate([0, 0, tab_cavity_rotation]) {
                    translate([tab_cavity_size / -2, 0, -e]) {
                        cube([
                            tab_cavity_size,
                            diameter / 2 + e,
                            height + e * 2
                        ]);
                    }
                }
            }
        }
    }

    module _speaker_cavity() {
        translate([speaker_position.x, speaker_position.y, z]) {
            translate([0, 0, (height - speaker_rim_height) - SPEAKER_HEIGHT - e]) {
                cylinder(
                    d = SPEAKER_DIAMETER + tolerance * 2,
                    h = SPEAKER_HEIGHT + e,
                    $fn = $preview ? undef : 120
                );
            }

            translate([0, 0, (height - speaker_rim_height) - e]) {
                cylinder(
                    d = SPEAKER_DIAMETER - speaker_rim_depth * 2,
                    h = speaker_rim_height + e * 2
                );
            }
        }
    }

    module _battery_well_cavity(bleed = tolerance + e) {
        width = get_battery_holder_cavity_width(0) + bleed * 2;
        length = get_battery_holder_cavity_length(3, tolerance) + bleed * 2;

        translate([
            batteries_position.x - bleed,
            batteries_position.y - bleed,
            z - e
        ]) {
            cube([width, length, height - speaker_rim_height + e]);
        }
    }

    module _battery_holder_walls() {
            translate([
                batteries_position.x,
                batteries_position.y,
                batteries_position.z + AAA_BATTERY_DIAMETER
            ]) {
                mirror([0, 0, 1]) {
                    battery_holder(
                        wall = ENCLOSURE_INNER_WALL,
                        tolerance = tolerance + e
                    );
                }
            }
    }

    module _pcb_buttresses(
        width = 10,
        length = 5,
        wall = ENCLOSURE_INNER_WALL,
        height = PCB_HEIGHT + PCB_FIXTURE_VERTICAL_ALLOWANCE,
        clearance = PCB_FIXTURE_CLEARANCE
    ) {
        offset = wall + clearance + tolerance;
        y = pcb_position.y - offset;

        difference() {
            for (x = [
                pcb_position.x - offset,
                pcb_position.x + PCB_WIDTH - width + offset
            ]) {
                translate([x, y, z - height]) {
                    cube([width, length, height + e]);
                }
            }

            _fixture_pcb_difference(
                pcb_position = pcb_position,
                clearance = clearance,
                tolerance = tolerance,
                bottom_bleed = PCB_FIXTURE_VERTICAL_ALLOWANCE
            );
        }
    }

    if (include_keys_mount_rail) {
        _keys_mount_rail();
    }

    _battery_holder_walls();
    _pcb_buttresses();

    difference() {
        union() {
            _plate();
            _speaker_wall();
        }

        _button_cavities();
        translate(pcb_position) {
            scout_pcb_holes(
                height = height,
                diameter_bleed = tolerance + TRAY_TO_COMPONENT_CLEARANCE,
                include_relief_holes = true
            );
        }
        _speaker_cavity();
        _battery_well_cavity();

        tray_fixtures(
            enclosure_dimensions = enclosure_dimensions,
            tray_dimensions = [width, length, height],
            tray_z = z,
            bleed = tolerance * 2
        );
    }
}
