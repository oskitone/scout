/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/basic_shapes.scad>;
use <../../poly555/openscad/lib/engraving.scad>;

ENCLOSURE_ENGRAVING_DEPTH = 1.2;

module enclosure_engraving(
    string,
    size,
    bleed = .1,
    center = false,
    position = [0, 0],
    font = "Orbitron:style=Black",

    placard = undef,

    // TODO: de-arg
    quick_preview = true,
    enclosure_height = 0
) {
    e = .0835;

    translate([
        position.x,
        position.y,
        enclosure_height - ENCLOSURE_ENGRAVING_DEPTH
    ]) {
        difference() {
            if (placard) {
                translate(center ? [placard.x / -2, placard.y / -2] : placard) {
                    cube([placard.x, placard.y, ENCLOSURE_ENGRAVING_DEPTH + e]);
                }
            }

            engraving(
                string = string,
                svg = undef,
                font = font,
                size = size,
                bleed = quick_preview ? 0 : bleed,
                height = ENCLOSURE_ENGRAVING_DEPTH + e,
                center = center,
                chamfer =  quick_preview ? 0 : (placard ? 0 : .1)
            );
        }
    }
}

sizes = [3, 4, 5];
bleeds = [-.1, .1];

plot_width = 24;
plot_length = 8;

difference() {
    cube([
        plot_width * len(sizes),
        plot_length * len(bleeds),
        2
    ]);

    for (i = [0 : len(sizes) - 1]) {
        for (ii = [0 : len(bleeds) - 1]) {
            enclosure_engraving(
                string = "AB30",
                size = sizes[i],
                bleed = bleeds[ii],
                center = true,
                position = [
                    plot_width * i + plot_width / 2,
                    plot_length * ii + plot_length / 2
                ],
                enclosure_height = 2,
                quick_preview = $preview
            );
        }
    }
}

translate([0, plot_length * 2, 0]) {
    difference() {
        cube([
            plot_width * len(sizes),
            plot_length * len(bleeds),
            2
        ]);

        for (i = [0 : len(sizes) - 1]) {
            for (ii = [0 : len(bleeds) - 1]) {
                enclosure_engraving(
                    string = "AB30",
                    size = sizes[i],
                    bleed = bleeds[ii],
                    center = true,
                    position = [
                        plot_width * i + plot_width / 2,
                        plot_length * ii + plot_length / 2
                    ],
                    placard = [plot_width - 1, plot_length - 1],
                    enclosure_height = 2,
                    quick_preview = $preview
                );
            }
        }
    }
}
