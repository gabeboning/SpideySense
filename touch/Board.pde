class Board {
	ArrayList<Obstruction> obstructions = new ArrayList<Obstruction>();
	ArrayList<Source> sources = new ArrayList<Source>();
	ArrayList<Sensor> sensors = new ArrayList<Sensor>();
	int w,h,ledAngle;
	
	boolean pulse;
    boolean drawObstructions = false;
  
	Board(int w, int h, int ledAngle) {
          this.w = w;
          this.h = h;
          this.ledAngle = ledAngle;
	}

	void addObstruction(float r, float x, float y) {
		obstructions.add(new Obstruction(r,x,y));
	}

	void clearObstructions() {
		obstructions.clear();
	}

	void parseBytes(byte[] inBytes) {
		int led = int(inBytes[0]);
                println("LED id: " + led);
                //println("length of bytes: " + inBytes.length);
		//int sensorID = (inBytes.length-2)*8-1;
                int sensorID = sensors.size() - 1;
                
		int i = 0, j=0;
		byte cur;
		Source s; 
		// loop through the bytes
		s = (Source)sources.get(led);
		for (i=1; i<inBytes.length - 1; i++) {
			cur = inBytes[i];
			for (j=7; j >= 0; j--) { // loop through the bits we want
				// remember that 1 in a bit indicates the sensor ISN'T triggered
				// if a bit == 0, it's triggered, thus, the path is not connected
				boolean connected = ((cur & (1L << j)) == 0);// true is the sensor is triggered	
				//System.out.print(int(connected));
				//println("sensor " + sensorID + connected); 
				s.setPath(sensorID, connected);
				// The bit was set
				sensorID--;
			}
		}
		//println();
	}	
	
	// takes a string of the data from the arduino and sets the paths accordingly
	void parseString(String s) {
		int openBracket = s.indexOf("{");
		int closeBracket = s.indexOf("}");
		
		if(openBracket < 0 || closeBracket < 0) return;
		
		//println(s);
		
		int sourcenum = int(s.substring(0,openBracket));
		Source source = (Source)sources.get(sourcenum);
		
		String sensors_temp = s.substring(openBracket+1, closeBracket);
		String[] sensors = sensors_temp.split(",");
		for( String sensor : sensors ){
			String[] split = sensor.split(":");
			//println("Setting path from LED " + sourcenum + " to sensor " + split[0] + " to " + int(split[1]));
			source.setPath(int(split[0]), boolean(int(split[1])));
		}
	}
	
	void update() {
		obstructions.get(0).location.x = mouseX/displayScale;
		obstructions.get(0).location.y = mouseY/displayScale; 
		this.findBlockedPaths();
	}

	void print() {
		//println(sources.get(24).paths.size());
		//println(sources.get(0).paths);
	}
	
	// in simulation, turns off paths that go through an obstruction
	void findBlockedPaths() {
		Path p;
		Iterator it;
		for(Source source : sources) {
			it = source.paths.entrySet().iterator();

			while( it.hasNext() ) { 
				Map.Entry pairs = (Map.Entry)it.next();

				p = (Path)pairs.getValue();
				p.blocked = false;

				for(Obstruction o : obstructions) {
					float a =  p.magnitude();
					float b = p.from.location.dist(o.location);
					float c = p.to.location.dist(o.location);
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
	}

	void addSource(float x, float y) {
		sources.add(new Source(x, y));
	}
	
	// returns a perpendicular vector given a source
	PVector findPerp(Source s) {
          
          if(s.location.x == 0) {
            return new PVector(-1,0); 
          }
          else if(s.location.x == w) {
            return new PVector(1,0);
          }
          else if(s.location.y == 0) {
            return new PVector(0,-1);
          }
          else if(s.location.y == h) {
            return new PVector(0,1);
          }
          return new PVector(0,0);
         
	}
        
	void addSensor(int i, float x, float y) {
		// add the sensor
		sensors.add(new Sensor(x, y));
		PVector connection = new PVector();
		PVector perpV = new PVector();
		float angle;
		for( Source s : sources ) { // link it to every source we have
			connection.set(s.location.x - x, s.location.y - y,0); // set the vector of hte connected path
			perpV = findPerp(s); // get the perpendicular vector from the LED

			angle = PVector.angleBetween(connection, perpV);
			angle = angle*360/(2*PI);
                        
			s.addSensor(i, sensors.get(sensors.size() - 1) );
		}
	}
	
	
	// a sensor number i at location (x,y) to the source
	void addSensorToSource(int i, float x, float y, int source) {
		sensors.add(new Sensor(x, y));
		sources.get(source).addSensor(i, sensors.get(sensors.size()-1));
	}

	/*void addPath(int from, int to) {
	paths.add(new Path(sources.get(from), sensors.get(to)));
	}*/
	
	void draw(PGraphics b, float scaling) {
		//save(i + ".png");
		int i = 0;
		b.background(255,255,255);
		b.stroke(0,0,0);
		b.strokeWeight(1);

		for(Source s : sources) {
			i++;
			s.draw(b, scaling);
			//s.drawSensors(b, scaling);
			//image(b, 0,0,width,height);
		}
			
		for(i = 0; i < sources.size(); i++) {
                      Source s = (Source)sources.get(i);
			b.fill(255,0,0);
			b.noStroke();
			b.ellipse(s.location.x * scaling, s.location.y * scaling, 5,5);
                        b.text(i, s.location.x*scaling, s.location.y*scaling);
		}
		//b.strokeWeight(2);
		//b.stroke(0,255,0);
		//b.noFill();
        if(drawObstructions) {
    		for(Obstruction o : obstructions) {
				b.ellipse(o.location.x * scaling, o.location.y * scaling, o.r * 2 * scaling, o.r * 2 * scaling);
    		}
        }
	}

}
