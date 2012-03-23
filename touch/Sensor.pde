class Sensor {
	PVector location;
	Sensor(float x, float y) {
		location = new PVector(x,y);
	}
	
	Sensor(PVector p) {
		location = p;
	}
}