import s373.flob.*;
import processing.serial.*;
import java.util.*;
import java.util.concurrent.*;

float displayScale;

PGraphics buffer, curFrame;
PImage img;

PImage bg;

Board board;

Serial myPort;

// define some constants

int totalModules = 9;
int tossit = 0;
int maxBlob = 0; // highest blob ID we've hit
int movementThreshold = 300, blurRadius = 5, minBlobSize = 400; // for tracking purposes

Flob flob;

ArrayList<trackedBlob> blobs = new ArrayList<trackedBlob>();
ArrayList<trackedBlob> prevblobs = new ArrayList<trackedBlob>();

BlockingQueue<PGraphics> frames = new ArrayBlockingQueue<PGraphics>(20);

int w, h, ledAngle;

boolean pulse = false;
//Blob[] blobsArray=null; 

void setup() {
  w = 24;
  h = 6;
  ledAngle = 80;
  displayScale = 30; // 80*10 = 800
  size(totalModules*20*4 + 5, int(h*displayScale), P2D);
  //bg = createImaue(1080, 720, RGB);

  myPort = new Serial(this, Serial.list()[1], 38400);
  myPort.bufferUntil('\n');

  //listener = new Listener(board, myPort);

  board = new Board(w, h, ledAngle);
  board.pulse = pulse;
  dots();
  //fourbyfour();
  //testBoard();

  buffer = createGraphics(width, height, P2D);

  img = createImage(width, height, RGB);


	
  // set up tracking
  flob = new Flob(this, img);
  flob.setOm(0).setMinNumPixels(minBlobSize).setMaxNumPixels(3000);

  stroke(255);
  background(255, 255, 255);
  rectMode(CENTER);
  //byte[] inBuffer = new byte[4];
  //inBuffer[0] = 0;
  //inBuffer[1] = 10; 
  //inBuffer[2] = -128;
  //inBuffer[3] = -1;
  //board.parseBytes(inBuffer);
  //noLoop();
  //thread("makeFrames");
}


void draw() {
  // serial implementation
  //    board.update(); // do the computations
  //    buffer.beginDraw();
  //    board.draw(buffer, displayScale); // draw the lines from the board object
  //    buffer.endDraw();
  //    image(buffer, 0,0);
  //    curFrame = buffer;
  //    findBlobs();

  // paralle
//  PGraphics b = createGraphics(width, height, P2D);
//  makeAFrame(b);
  if (frames.size() > 0) {
    curFrame = frames.remove();
    image(curFrame, 0, 0, width, height);
    //findBlobs();
  }
  else {
    //println("empty");
  }
}

void serialEvent(Serial p) {
  PGraphics b = createGraphics(width, height, P2D);
  byte[] inBuffer = new byte[totalModules+1];
  int numRead = p.readBytes(inBuffer);
  //println("number of bytes read: " + numRead);	
  //inBuffer[numRead - 1] = 0;
  Byte cur;
  //println(inBuffer[0]);
  //println("id: " + int(char(inBuffer[0])));
	for(int i = 1; i < numRead-1; i++) {
          cur = inBuffer[i];
          for (int j=7; j >= 0; j--) { // loop through the bits we want
                // remember that 1 in a bit indicates the sensor ISN'T triggered
                // if a bit == 0, it's triggered, thus, the path is not connected
                boolean connected = ((cur & (1L << j)) == 0);// true is the sensor is triggered	
                // The bit was set
                print(int(connected));
                //println("sensor " + sensorID + connected); 
              }
	}
	//if(numRead != 6) return;
  println();
  
  //println("serial evented");
  board.parseBytes(inBuffer); // update board with the data
  if( inBuffer[0] - 48 == totalModules - 1 ) {
    makeAFrame(b);
  }
  //tossit++;
  //println(tossit);
}

void makeFrames() {
  PGraphics b = createGraphics(width, height, P2D);
  while (true) { // generate lots of frames 
	makeAFrame(b);
  }
}

// generate one frame and pop it into the queue
void makeAFrame(PGraphics thisFrame) {

	 	//board.update(); // do the computations
    thisFrame.beginDraw();
    board.draw(thisFrame, displayScale); // draw the lines from the board object
    thisFrame.endDraw();
    try {
      frames.put(thisFrame);
    }
    catch(Exception e) {
      println("problem?");
    }
}


void keyPressed() {
  if (key == UP) {
    board.clearObstructions();
  }
}


void dots() {
  for(int i = 0; i < totalModules*4; i++) {
  board.dots.add(false);
  }
}
