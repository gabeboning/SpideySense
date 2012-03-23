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

  void isConnected() {
    this.blocked = false;
  }

  void isBlocked() {
    this.blocked = true;
  }

  void setVisible(boolean isVisible) {
    this.blocked = !isVisible;
  }
}

