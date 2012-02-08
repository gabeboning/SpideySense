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

int totalModules;
int maxBlob = 0; // highest blob ID we've hit
int movementThreshold = 300, blurRadius = 5, minBlobSize = 400; // for tracking purposes

Flob flob;

ArrayList<trackedBlob> blobs = new ArrayList<trackedBlob>();
ArrayList<trackedBlob> prevblobs = new ArrayList<trackedBlob>();

BlockingQueue<PGraphics> frames = new ArrayBlockingQueue<PGraphics>(100);

int w, h, ledAngle;

boolean pulse = false;
//Blob[] blobsArray=null; 

void setup() {
  w = 36;
  h = 24;
  ledAngle = 80;
  size(1080, 720, P2D);
  //bg = createImaue(1080, 720, RGB);

  myPort = new Serial(this, Serial.list()[1], 115200);
  myPort.bufferUntil('\n');

  //listener = new Listener(board, myPort);

  board = new Board(w, h, ledAngle);
  board.pulse = pulse;
  simulateBoard();
	byte[] inBuffer = new byte[3];
	inBuffer[0] = 8;
	inBuffer[1] = 30;
	inBuffer[2] = 18;
  board.parseBytes(inBuffer);
  //testBoard();

  buffer = createGraphics(width, height, P2D);

  displayScale = 30; // 80*10 = 800
  img = createImage(width, height, RGB);
  
  // set up tracking
  flob = new Flob(this, img);
  flob.setOm(0).setMinNumPixels(minBlobSize).setMaxNumPixels(3000);

  stroke(255);
  background(255, 255, 255);
  rectMode(CENTER);
 
	noLoop();
 // thread("makeFrames");
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
    
    // parallel
 if(frames.size() > 0) {
    curFrame = frames.remove();
    image(curFrame, 0,0,width,height);
    findBlobs();
 }
 else {
   println("empty");
 }

//
//  if (pulse) {
//    //    delay(100);
//  }

  println(frameRate);
  //delay(1000);
}

void makeFrames() {
  PGraphics thisFrame = createGraphics(width, height, P2D);
  float myDisplayScale = displayScale;
  while (true) {
    board.update(); // do the computations
    thisFrame.beginDraw();
    board.draw(thisFrame, myDisplayScale); // draw the lines from the board object
    thisFrame.endDraw();
    try {
      frames.put(thisFrame);
    }
    catch(Exception e) {
      println("problem?");
    }
  }

  //println("making frame");
}


void findBlobs() {
  boolean stop = false;  
  

  blobs = flob.tracksimple(get()); // get the blobs
  //blobs = flob.tracksimple(img);
  if(blobs.size() > 30) {
    stop = true;
    //save("failed.png");
  }
  assignIds(blobs, prevblobs); // match ids to existing ones 

    prevblobs.clear();
  //image(flob.getImage(), 0, 0, width, height);

  for (int i = 0; i < blobs.size(); i++) {
    //    //println("----");
    trackedBlob ab = (trackedBlob)blobs.get(i); 
    //    
    //    //box
        fill(0,0,255,100);

        rect(ab.cx,ab.cy,ab.dimx,ab.dimy);
    //    //centroid
    //    fill(0,0,0,220);
    //    rect(ab.cx,ab.cy, 2, 2);
    fill(255, 0, 0);
    text(ab.id, ab.cx-8, ab.cy);
    //
    prevblobs.add((trackedBlob)blobs.get(i));
  }
  
  //if(stop) noLoop();
  
    
    
}


// simplistic algorithm to persist blob IDs across frames
// almost certainly a better way to do this, but this was easiest to implement
// of all the schemes I came up with
void assignIds(ArrayList<trackedBlob> b, ArrayList<trackedBlob> pb) {
  //println(b.size() + " previous: " + pb.size());
  int i, j, minId=-1, minIndex = -1;
  int maxId=b.size();
  float minDist, curDist;
  trackedBlob cur, old;

  for (i=0; i<b.size(); i++) { // loop through all current blobs
    minId = -1;
    minDist = 10000000;
    cur = b.get(i);

    for (j=0; j<pb.size(); j++) { // loop through all the old blobs 
      old = pb.get(j);
      curDist = sqrt( pow(cur.cx-old.cx, 2) + pow(cur.cy-old.cy, 2) ); // compute distance
      if (curDist < minDist) { // find the closest, store it's info
        minId = old.id;
        minIndex=j;
        minDist = curDist;
      }
    }

    // set the current blobs id to the nearest old one
    // (they're the same)
    if (minId == -1 || minDist > movementThreshold) { // if we ran out of old ones
      cur.id = maxBlob;
      maxBlob++;
      //println("adding id");
    }
    else {
      //println("setting " + cur.id + " to " + minId);
      cur.id = minId;
      pb.remove(minIndex); // remove it so we don't give it to two, and to get to O(n log n)
    }
  }

  if (pb.size() > 0) {
    pb.clear();
  }
}

void mouseClicked() {
  //synchronized(board.obstructions) {

  // causes concurrency errors!
  board.addObstruction(.4, mouseX/displayScale, mouseY/displayScale);

  //}


  //println("adding");
}

void keyPressed() {
  if (key == UP) {

    board.clearObstructions();
  }
}

void serialEvent(Serial p) {
	byte[] inBuffer = new byte[totalModules+1];
	int numRead = p.readBytes(inBuffer);
	println("number of bytes read: " + numRead);	
//println(instring);
  board.parseBytes(inBuffer);
}

void testBoard() {
  int sensorPerModule = 2;

  board.addSource(w/2, 0);
  board.addSource(w/2, h);
  board.addSensor(0, w/2-1.125, 0);
  board.addSensor(1, w/2+1.125, 0);
  board.addSensor(8, w/2-1.125, h);
  board.addSensor(9, w/2+1.125, h);
  board.addObstruction(.4, 7, 5);
}

void simulateBoard() {
  int modulesX = w/3;
  int modulesY = h/3;
	totalModules = modulesX+modulesY;
  int sensorPerModule = 4;

  float sensorSpacing = .75;
  float ledSpacing = 3;

  float ledOffset = 1.5;
  float sensorOffset = .375;

  int i;
  // add sources before sensors
  for (i=0; i < modulesX; i++) {
    board.addSource(i*ledSpacing+ledOffset, 0);
  }  

  for (i=0; i < modulesY; i++) {
    board.addSource(w, i*ledSpacing+ledOffset);
  }

  for (i=0; i < modulesX; i++) {
    board.addSource(i*ledSpacing+ledOffset, h);
    //println((w-i)*xSpacing+xOffset);
  }  

  for (i=0; i < modulesY; i++) {
    board.addSource(0, i*ledSpacing+ledOffset);
  }


  // add sensors
  for (i=0; i < modulesX * sensorPerModule; i++) {
    board.addSensor(i, i*sensorSpacing+sensorOffset, 0);
  }  

  for (i=0; i < modulesY * sensorPerModule; i++) {
    board.addSensor(i + modulesX * sensorPerModule, w, i*sensorSpacing+sensorOffset);
  }
 
  for (i=0; i < modulesX * sensorPerModule; i++) {
    board.addSensor(i + modulesX * sensorPerModule + modulesY * sensorPerModule, i*sensorSpacing+sensorOffset, h);
  }  

  for (i=0; i < modulesY * sensorPerModule; i++) {
    board.addSensor(i + modulesX * sensorPerModule *2 + modulesY * sensorPerModule, 0, i*sensorSpacing+sensorOffset);
  }

  board.addObstruction(.4, 7, 5);
  board.addObstruction(.4, 10, 1);
  board.addObstruction(.4, 1, 1);
  //board.addObstruction(.5, 8, 11);
  /*board.addObstruction(.25, 20, 10);
   board.addObstruction(.25, 10, 10);
   board.addObstruction(.25, 2, 11);
   board.addObstruction(.25, 15, 2);
   board.addObstruction(.25, 4, 6);
   board.addObstruction(.25, 11, 20);*/
  //board.addObstruction(.25, 7, 6);
}


// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann <http://incubator.quasimondo.com>
// ==================================================
void fastBlur(PImage img, int radius) {

  if (radius < 1) {
    return;
  }
  int w = img.width;
  int h = img.height;
  int wm = w - 1;
  int hm = h - 1;
  int wh = w*h;
  int div = radius + radius + 1;
  int r[] = new int[wh];
  int g[] = new int[wh];
  int b[] = new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];

  int[] pix = img.pixels;
  int dv[] = new int[256*div];
  for (i = 0; i < 256*div; i++) {
    dv[i] = (i / div);
  }

  yw = yi = 0;

  for (y = 0; y < h; y++) {
    rsum = gsum = bsum = 0;
    for (i = -radius; i <= radius; i++) {
      p = pix[yi + min(wm, max(i, 0))];
      rsum += (p & 0xff0000)>>16;
      gsum += (p & 0x00ff00)>>8;
      bsum += p & 0x0000ff;
    }
    for (x = 0; x < w; x++) {

      r[yi] = dv[rsum];
      g[yi] = dv[gsum];
      b[yi] = dv[bsum];

      if (y == 0) {
        vmin[x] = min(x + radius + 1, wm);
        vmax[x] = max(x - radius, 0);
      }
      p1 = pix[yw + vmin[x]];
      p2 = pix[yw + vmax[x]];

      rsum += ((p1 & 0xff0000) - (p2 & 0xff0000))>>16;
      gsum += ((p1 & 0x00ff00) - (p2 & 0x00ff00))>>8;
      bsum += (p1 & 0x0000ff) - (p2 & 0x0000ff);
      yi++;
    }
    yw += w;
  }

  for (x = 0; x < w; x++) {
    rsum = gsum = bsum = 0;
    yp =- radius*w;
    for (i = -radius; i <= radius; i++) {
      yi = max(0, yp) + x;
      rsum += r[yi];
      gsum += g[yi];
      bsum += b[yi];
      yp += w;
    }
    yi = x;
    for (y = 0; y < h; y++) {
      pix[yi] = 0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x == 0) {
        vmin[y] = min(y + radius + 1, hm)*w;
        vmax[y] = max(y - radius, 0)*w;
      }
      p1 = x + vmin[y];
      p2 = x + vmax[y];

      rsum += r[p1] - r[p2];
      gsum += g[p1] - g[p2];
      bsum += b[p1] - b[p2];

      yi += w;
    }
  }
}
void delay(int ms) {
  int current_time = millis();
  while (millis () - current_time < ms);
}

