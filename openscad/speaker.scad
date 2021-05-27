use <../../poly555/openscad/lib/basic_shapes.scad>;

SPEAKER_DIAMETER = 39.7;
SPEAKER_HEIGHT = 5.4;

module speaker() {
    cylinder(
        d = SPEAKER_DIAMETER,
        h = SPEAKER_HEIGHT
    );
}
