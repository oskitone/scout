use <../../poly555/openscad/lib/basic_shapes.scad>;

// TODO: measure
SPEAKER_DIAMETER = 40;
SPEAKER_HEIGHT = 5;

module speaker() {
    cylinder(
        d = SPEAKER_DIAMETER,
        h = SPEAKER_HEIGHT
    );
}

module speaker_fixture(
    height = SPEAKER_HEIGHT,
    tolerance = 0
) {
    e = .053;

    // TODO: add cavity for solder tabs
    // TODO: ensure mounting rail doesn't obstruct speaker
    // TODO: experiment with extra height speaker enclosure on sound

    ring(
        diameter = SPEAKER_DIAMETER + ENCLOSURE_INNER_WALL * 2 + tolerance * 2,
        height = height,
        thickness = ENCLOSURE_INNER_WALL
    );

    ring(
        diameter = SPEAKER_DIAMETER + tolerance * 2 + e * 2,
        height = height - SPEAKER_HEIGHT,
        thickness = ENCLOSURE_INNER_WALL + e * 2
    );
}
