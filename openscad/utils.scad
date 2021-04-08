module e_translate(
    p = [0, 0, 0],
    direction = [1, 1, 1],
    e = .00678
) {
    position = $preview
        ? [p.x + e * direction.x, p.y + e * direction.y, p.z + e * direction.z]
        : p;

    translate(position) {
        children();
    }
}
