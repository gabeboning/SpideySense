class Source {
  PVector location;

  Map<Integer, Path> paths = new HashMap<Integer, Path>();

  Source(float x, float y) {
    location = new PVector(x, y);
  }

  Source(PVector l) {
    location = l;
  }

  void addSensor(int i, Sensor s) {
    paths.put(i, new Path(this, s));
  }

  void addSensor(int i, float x, float y) {
    paths.put(i, new Path(this, new Sensor(x, y)));
  }

  void drawSensors(PGraphics buffer, float scale) {
    buffer.stroke(0, 0, 255);
    buffer.fill(0, 0, 255);
    Path p;
    for ( Map.Entry entry: paths.entrySet() ) { 

      p = (Path)entry.getValue();
      buffer.ellipse(p.to.location.x * scale, p.to.location.y * scale, 5, 5);
      buffer.text("" + entry.getKey(), p.to.location.x * scale, p.to.location.y * scale + 10);
    }
  }

  void makePaths() {
  }

  void setPath(int path, boolean sensorValue) {
    if (!paths.containsKey(path)) return;
    Path p = (Path)paths.get(path);
    p.blocked = !sensorValue;
  }

  void draw(PGraphics buffer, float scale) {
    Path p;

    buffer.stroke(0, 0, 0);
    for ( Map.Entry entry: paths.entrySet() ) { 
      p = (Path)entry.getValue();

      if (!p.blocked) {
        buffer.line(location.x * scale, location.y * scale, p.to.location.x * scale, p.to.location.y * scale);
      }
    }
    buffer.fill(255, 0, 0);
  }
}

