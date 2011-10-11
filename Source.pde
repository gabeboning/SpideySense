class Source {
	PVector location;
	//ArrayList<Path> paths = new ArrayList<Path>();
	//ArrayList<Sensor> sensors = new ArrayList<Sensor>();
	
	Map<Integer, Path> paths = new HashMap<Integer, Path>();
	
	Source(float x, float y) {
		location = new PVector(x,y);
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
		buffer.stroke(0,0,255);
		buffer.fill(0,0,255);
		Path p;
		for( Map.Entry entry: paths.entrySet() ) { 
			p = (Path)entry.getValue();
			//println(p.to);
			println(location.x + " " + p.to.location.x);
			buffer.ellipse(p.to.location.x * scale, p.to.location.y * scale, 5,5);
		}
		
	}
	
	void makePaths() {
		
	}
	
	void draw(PGraphics buffer, float scale) {
		Path p;
		for( Map.Entry entry: paths.entrySet() ) { 
			p = (Path)entry.getValue();
			//println(p.to);
			println(location.x + " " + p.to.location.x);
			buffer.line(location.x * scale, location.y * scale, p.to.location.x * scale, p.to.location.y * scale);
		}
	}
	
	
	
}