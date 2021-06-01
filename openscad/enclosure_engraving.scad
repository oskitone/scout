/* TODO: extract into common parts repo */
use <../../poly555/openscad/lib/basic_shapes.scad>;
use <../../poly555/openscad/lib/engraving.scad>;

ENCLOSURE_ENGRAVING_DEPTH = 1.2;
OSKITONE_LENGTH_WIDTH_RATIO = 4.6 / 28; // TODO: extract

function get_branding_model_length(
    gutter = 0,
    make_to_model_ratio = .5,
    available_length = 10
) = (
    (available_length - gutter) * (1 - make_to_model_ratio)
);
function get_branding_make_width(
    gutter = 0,
    make_to_model_ratio = .5,
    available_length = 10
) = (
    get_branding_make_length(gutter, make_to_model_ratio, available_length)
    / OSKITONE_LENGTH_WIDTH_RATIO
);
function get_branding_make_length(
    gutter = 0,
    make_to_model_ratio = .5,
    available_length = 10
) = (
    (available_length - gutter) * make_to_model_ratio
);

module enclosure_engraving(
    string,
    size,
    bleed = -.1,
    chamfer = .4,
    center = true,
    position = [0, 0],
    font = "Orbitron:style=Black",

    placard = undef,

    bottom = false,

    quick_preview = true,
    enclosure_height = 0
) {
    e = .0135;

    translate([
        position.x,
        position.y,
        bottom
            ? ENCLOSURE_ENGRAVING_DEPTH
            : enclosure_height - ENCLOSURE_ENGRAVING_DEPTH
    ]) {
        rotate([0, bottom ? 180 : 0, 0]) {
            difference() {
                if (placard) {
                    translate(
                        center
                            ? [placard.x / -2, placard.y / -2]
                            : [placard.x, placard.y, 0]
                    ) {
                        cube([
                            placard.x,
                            placard.y,
                            ENCLOSURE_ENGRAVING_DEPTH + e
                        ]);
                    }
                }

                translate(placard ? [0, 0, -e] : [0, 0, 0]) {
                    engraving(
                        string = string ? string : undef,
                        svg = string ? undef : "../../branding.svg",
                        font = font,
                        size = string ? size : undef,
                        resize = string
                            ? undef
                            : [size / OSKITONE_LENGTH_WIDTH_RATIO, size],
                        bleed = quick_preview ? 0 : bleed,
                        height = placard
                            ? ENCLOSURE_ENGRAVING_DEPTH + e * 2
                            : ENCLOSURE_ENGRAVING_DEPTH + e,
                        center = center,
                        chamfer =  quick_preview ? 0 : (placard ? 0 : chamfer)
                    );
                }
            }
        }
    }
}

/* // All of these are fine but -.1 bleed and .4 chamfer seems to look best
// .2 chamfer could also be fine if .4 isn't defined enough
bleeds = [-.1];
chamfers = [.2, .3, .4, .6];

bottom_engraving_length = 8;

gutter = 1;
plot_width = 50;
plot_length = 9;

difference() {
    cube([
        plot_width * len(bleeds) + gutter * 2,
        plot_length * len(chamfers) + gutter * 2,
        2
    ]);

    for (i = [0 : len(bleeds) - 1]) {
        for (ii = [0 : len(chamfers) - 1]) {
            translate([0, 0, -.01]) {
                enclosure_engraving(
                    size = bottom_engraving_length,
                    bleed = bleeds[i],
                    chamfer = chamfers[ii],
                    center = true,
                    position = [
                        gutter + plot_width * i + plot_width / 2,
                        gutter + plot_length * ii + plot_length / 2
                    ],
                    bottom = true,
                    enclosure_height = 2,
                    reduced_test_case = false,
                    quick_preview = false // $preview
                );
            }
        }
    }
} */
