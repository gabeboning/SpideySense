class Board {
  /*ArrayList<Path> paths = new ArrayList<Path>();
  ArrayList<PVector> sources = new ArrayList<PVector>();
  ArrayList<PVector> sensors = new ArrayList<PVector>();*/
  ArrayList<Obstruction> obstructions = new ArrayList<Obstruction>();

	ArrayList<Source> sources = new ArrayList<Source>();
	ArrayList<Sensor> sensors = new ArrayList<Sensor>();
  
  Board() {
  }
  
  void addObstruction(float r, float x, float y) {
    obstructions.add(new Obstruction(r,x,y));
  }
  
  void clearObstructions() {
    //obstructions.clear();
  }
  
  void findBlockedPaths() {
    for(Source s : sources) {
		/*for(Path p : s.paths ) {
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
	    }*/
	}	
  }

	void addSource(float x, float y) {
		sources.add(new Source(x, y));
	}
	
	void addSensor(int i, float x, float y) {
		
		sensors.add(new Sensor(x, y));
		for( Source s : sources ) {
			s.addSensor(i, sensors.get(sensors.size() - 1) );
		}
	}
  
  /*void addPath(int from, int to) {
    paths.add(new Path(sources.get(from), sensors.get(to)));
  }*/
  
  void draw(PGraphics buffer, float scaling) {
    for(Source s : sources) {
      s.draw();
    }
    
    buffer.stroke(255,0,0);
    buffer.strokeWeight(1);
     buffer.noFill();
    /*for(Obstruction o : obstructions) {
      buffer.ellipse((o.location.x)*scaling, (o.location.y)*scaling, (o.r*2)*scaling, o.r*2*scaling);
    }*/
  }
}
