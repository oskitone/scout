use <scout.scad>;

// HACK: obv, right?

$vpr = [90 - 10, 0, $t * 360];
$vpt = [0, 0, 76];
$vpd = 500;

translate([86.9 / 2, 38, 0])
rotate([19.4, 0, 0])
translate([0, 0, 158.2])
rotate([0, 90, 90])
scout(
    show_pcb = false,
    show_keys_mount_rail = false,
    show_dfm = false,
    quick_preview = false
);
