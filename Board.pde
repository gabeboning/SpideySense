class Board {

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

	void print() {
		//println(sources.get(24).paths.size());
		//println(sources.get(0).paths);
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
	int i = 0;
	void draw(PGraphics buffer, float scaling) {
		
		buffer.stroke(0,0,0);
		buffer.strokeWeight(1);
		for(Source s : sources) {
			s.draw(buffer, scaling);
			//image(buffer, 0,0,width,height);
			//delay(100);
		}
		/*sources.get(i).draw(buffer, scaling);
		
		sources.get(i).drawSensors(buffer, scaling);*/
		buffer.fill(255,0,0);
		buffer.stroke(255,0,0);
		for(Source s : sources) {
			buffer.ellipse(s.location.x * scaling, s.location.y * scaling, 5,5);
		}

		buffer.stroke(255,0,0);
		buffer.strokeWeight(1);
		buffer.noFill();
		if( i == sources.size() -1 ) {
			i = 0;
		}
		else {
			i++;
		}
	}
}
