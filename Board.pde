class Board {
  ArrayList<Path> paths = new ArrayList<Path>();
  ArrayList<PVector> sources = new ArrayList<PVector>();
  ArrayList<PVector> sensors = new ArrayList<PVector>();
  ArrayList<Obstruction> obstructions = new ArrayList<Obstruction>();
  
  Board() {
  }
  
  void addObstruction(float r, float x, float y) {
    obstructions.add(new Obstruction(r,x,y));
  }
  
  void clearObstructions() {
    //obstructions.clear();
  }
  
  void findBlockedPaths() {
    for(Path p : paths) {
      p.blocked = false;
      for(Obstruction o : obstructions) {
        float a =  p.magnitude();
        float b = p.from.dist(o.location);
        float c = p.to.dist(o.location);
        float s = (a+b+c)/2;
        float tosquare = s*(s-a)*(s-b)*(s-c);
        
        double area = Math.sqrt(tosquare);
        
        double h = 2*area/a;
        
        if(h < o.r) {
          p.blocked = true;
        }
      }
    }
  }
  
  void addSource(float x, float y) {
    sources.add(new PVector(x,y));
  }
  
  void addSensor(float x, float y) {
    sensors.add(new PVector(x,y));
  }
  
  void makePaths() {
    for(PVector from : sources) {
      for(PVector to : sensors) {
        paths.add(new Path(from, to));
      }
    }
  }
  
  void blockPath(int i, boolean s) {
    paths.get(i).blocked = s;
  }
  
  void addPath(int from, int to) {
    paths.add(new Path(sources.get(from), sensors.get(to)));
  }
  
  void draw(PGraphics buffer, float scaling) {
    for(Path p : paths) {
      if(!p.blocked) {
        buffer.line(p.from.x * scaling, p.from.y * scaling, p.to.x * scaling, p.to.y * scaling);
      }
    }
    
    buffer.stroke(255,0,0);
    buffer.strokeWeight(1);
     buffer.noFill();
    /*for(Obstruction o : obstructions) {
      buffer.ellipse((o.location.x)*scaling, (o.location.y)*scaling, (o.r*2)*scaling, o.r*2*scaling);
    }*/
  }
}
