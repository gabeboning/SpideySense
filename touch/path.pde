class Path {
  Sensor to;
  Source from;
  boolean blocked;

  Path(Source from, Sensor to) {
    this.from = from;
    this.blocked = false;
    this.to = to;
  }

  float magnitude() {
    return PVector.sub(from.location, to.location).mag();
  }
}

