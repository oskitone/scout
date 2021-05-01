/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/basic_shapes.scad>;
use <../../poly555/openscad/lib/engraving.scad>;

ENCLOSURE_ENGRAVING_DEPTH = 1.2;

module enclosure_engraving(
    string,
    size,
    bleed = .1,
    center = true,
    position = [0, 0],
    font = "Orbitron:style=Black",

    placard = undef,

    bottom = false,

    // TODO: de-arg
    quick_preview = true,
    enclosure_height = 0
) {
    e = .0835;

    translate([
        position.x,
        position.y,
        bottom
            ? -e
            : enclosure_height - ENCLOSURE_ENGRAVING_DEPTH
    ]) {
        mirror([bottom ? 1 : 0, 0, 0]) {
            difference() {
                if (placard) {
                    translate(
                        center
                            ? [placard.x / -2, placard.y / -2]
                            : [placard.x, placard.y, 0]
                    ) {
                        cube([placard.x, placard.y, ENCLOSURE_ENGRAVING_DEPTH]);
                    }
                }

                translate(placard ? [0, 0, -e] : [0, 0, 0]) {
                    engraving(
                        string = string,
                        svg = undef,
                        font = font,
                        size = size,
                        bleed = quick_preview ? 0 : bleed,
                        height = placard
                            ? ENCLOSURE_ENGRAVING_DEPTH + e * 2
                            : ENCLOSURE_ENGRAVING_DEPTH + e,
                        center = center,
                        chamfer =  quick_preview ? 0 : (placard ? 0 : .1)
                    );
                }
            }
        }
    }
}

sizes = [3.2, 3.4, 3.6, 3.8];
bleeds = [-.1, 0];

plot_width = 22;
plot_length = 7;

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
                placard = [plot_width - 2, plot_length - 2],
                enclosure_height = 2,
                quick_preview = false // $preview
            );
        }
    }
}
