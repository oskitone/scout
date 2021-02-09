include <keys.scad>;

module mounting_rail(tolerance = 0) {
    /* TODO: DRY button height 6 */
    translate([0, 0, -6]) {
        _mounted_keys(
            include_mount = true,
            mount_height = 6,
            tolerance = tolerance
        );
    }
}
