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
	
	void makePaths() {
		
	}
	
	void draw() {
		
	}
	
	
	
}