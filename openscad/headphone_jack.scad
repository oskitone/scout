HEADPHONE_JACK_WIDTH = 12;
HEADPHONE_JACK_LENGTH = 11;
HEADPHONE_JACK_HEIGHT = 5;
HEADPHONE_JACK_BARREL_LENGTH = 3;
HEADPHONE_JACK_BARREL_DIAMETER = 6;
HEADPHONE_JACK_BARREL_Z = HEADPHONE_JACK_BARREL_DIAMETER / 2;

module headphone_jack() {
    e = .0341;

    cube([
        HEADPHONE_JACK_WIDTH,
        HEADPHONE_JACK_LENGTH,
        HEADPHONE_JACK_HEIGHT
    ]);

    translate([
        HEADPHONE_JACK_WIDTH / 2,
        HEADPHONE_JACK_LENGTH - e,
        HEADPHONE_JACK_BARREL_Z
    ]) {
        rotate([-90, 0, 0]) {
            cylinder(
                d = HEADPHONE_JACK_BARREL_DIAMETER,
                h = HEADPHONE_JACK_BARREL_LENGTH + e
            );
        }
    }
}
