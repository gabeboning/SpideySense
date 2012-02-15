class Source {
  PVector location;
  //ArrayList<Path> paths = new ArrayList<Path>();
  //ArrayList<Sensor> sensors = new ArrayList<Sensor>();

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
    }
  }

  void makePaths() {
  }

  // path is the ID of the sensor
  // connected is TRUE if we want the path to be drawn
  void setPath(int path, boolean connected) {
    Path p = (Path)paths.get(path);

    if (p == null) return; // when simulating, we hit issues because of simulating LED angle
    p.setVisible(connected);
    //println(p.blocked);
  }

  void draw(PGraphics buffer, float scale) {
    Path p;
    //buffer.stroke(255,255,255);
    for ( Map.Entry entry: paths.entrySet() ) { 
      p = (Path)entry.getValue();
      //println(p.to);
      //println(location.x + " " + p.to.location.x);
      //println(p.blocked);
      if (!p.blocked) {
				buffer.stroke(0,0,0);
        buffer.line(location.x * scale, location.y * scale, p.to.location.x * scale, p.to.location.y * scale);
      }
    }
  }
}

