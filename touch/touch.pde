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

GenerateThread generate;

// define some constants

int maxBlob = 0; // highest blob ID we've hit
int movementThreshold = 300, blurRadius = 5, minBlobSize = 400; // for tracking purposes

Flob flob;

ArrayList<ABlob> blobs = new ArrayList<ABlob>();
ArrayList<ABlob> prevblobs = new ArrayList<ABlob>();

int arraySize = 100;
BlockingQueue<Integer> times = new ArrayBlockingQueue<Integer>(arraySize);
BlockingQueue<PGraphics> frames = new ArrayBlockingQueue<PGraphics>(arraySize);

int w, h, ledAngle;
int frame = 0;
sendTUIO broadcaster = new sendTUIO();

boolean pulse = false;
//Blob[] blobsArray=null; 

void setup() {
  w = 36;
  h = 24;
  ledAngle = 80;
  size(1080, 720, P2D);
  //bg = createImage(1080, 720, RGB);

  //myPort = new Serial(this, Serial.list()[1], 115200);
  //myPort.bufferUntil('\n');

  //listener = new Listener(board, myPort);

  board = new Board(w, h, ledAngle);
  board.pulse = pulse;
  simulateBoard();
  //testBoard();

  buffer = createGraphics(width, height, P2D);

  displayScale = 30; // 80*10 = 800
  img = createImage(width, height, RGB);
  
  // set up tracking
  flob = new Flob(this, img);
  flob.setOm(10).setMinNumPixels(minBlobSize).setMaxNumPixels(3000).setTresh(1).setFade(0).setBlur(0);
  stroke(255);
  background(255, 255, 255);
  rectMode(CENTER);
 
  frameRate(60);
  
  generate = new GenerateThread(board, displayScale, buffer, frames);
  generate.setPriority(Thread.NORM_PRIORITY);
  generate.start();
}


void draw() {
  //println(millis() + " time rendered");
  // serial implementation
//  board.update(); // do the computations
//    buffer.beginDraw();
//board.draw(buffer, displayScale); // draw the lines from the board object
// buffer.endDraw();
//   frames.offer(buffer);
//    curFrame = frames.poll();
//    image(curFrame, 0,0);
//    findBlobs();
//    int timeAdded;
//    // parallel
 if(frames.size() > 1) {
    curFrame = frames.poll();
    int timeAdded = (int)times.poll();
    println("delay: " + (millis() - timeAdded));
    //image(curFrame, 0,0);
    findBlobs(curFrame);
	broadcaster.broadcastBlobs(blobs, frame);
	frame++;
    
 }
 else {
   println("empty");
 }
 

  println(frameRate);
  //delay(1000);
}

void findBlobs(PGraphics b) {
  boolean stop = false;  
  image(b, 0,0);
  PImage im = get();
  //PImage im = b.get(0,0,width, height);
  fastBlur(im, 4);
  //image(im,0,0);
  im.filter(THRESHOLD, .4);
  //image(im, 0,0);
  blobs = flob.calc(im); // get the blobs
  //image(flob.getImage(),0,0);
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
    ABlob ab = (ABlob)blobs.get(i); 
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
    prevblobs.add((ABlob)blobs.get(i));
  }
  
  //if(stop) noLoop();
  
    
    
}


// simplistic algorithm to persist blob IDs across frames
// almost certainly a better way to do this, but this was easiest to implement
// of all the schemes I came up with
void assignIds(ArrayList<ABlob> b, ArrayList<ABlob> pb) {
  //println(b.size() + " previous: " + pb.size());
  int i, j, minId=-1, minIndex = -1;
  int maxId=b.size();
  float minDist, curDist;
  ABlob cur, old;

  for (i=0; i<b.size(); i++) { // loop through all current blobs
    minId = -1; // id of minimum distance blob 
    minDist = 10000000; // distance away of min distance (because it's intensive to compute)
    cur = b.get(i);

    for (j=0; j<pb.size(); j++) { // loop through all the old blobs 
      old = pb.get(j);
      curDist = sqrt( pow(cur.cx-old.cx, 2) + pow(cur.cy-old.cy, 2) ); // compute distance
      if (curDist < minDist) { // find the closest, store its info
        minId = old.id; // could just store this
        minIndex=j; // but we'll keep everything for easy access
        minDist = curDist;
      }
    }

    // set the current blobs id to the nearest old one
    // (they're the same)
    if (minId == -1 || minDist > movementThreshold) { // if we ran out of old ones
      cur.id = maxBlob; // set to new id
      maxBlob++; // make next max id
      //println("adding id");
    }
    else {
      //println("setting " + cur.id + " to " + minId);
      cur.id = minId;
      pb.remove(minIndex); // remove it so we don't give it to two, and to get to n*log n runtime 
    }
  }

  if (pb.size() > 0) {
    pb.clear(); // clear previous blobs to store next frames
  }
}

void mouseClicked() {
  //synchronized(board.obstructions) {

  // causes concurrency errors!
  board.addObstruction(.4, mouseX/displayScale, mouseY/displayScale);

  //}

}

void keyPressed() {
  if (key == UP) {

    board.clearObstructions();
  }
}

void serialEvent(Serial p) {
  String instring = (myPort.readString());
  //println(instring);
  board.parseString(instring);
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
//  board.addObstruction(.4, 10, 1);
//  board.addObstruction(.4, 1, 1);
//  board.addObstruction(.4, 10, 10);
//  board.addObstruction(.4, 5, 5);
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
  int cur;
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
      cur = (p & 0xff0000)>>16;
      rsum += cur;
    }
    for (x = 0; x < w; x++) {

      r[yi] = dv[rsum];

      if (y == 0) {
        vmin[x] = min(x + radius + 1, wm);
        vmax[x] = max(x - radius, 0);
      }
      p1 = pix[yw + vmin[x]];
      p2 = pix[yw + vmax[x]];

      rsum += ((p1 & 0xff0000) - (p2 & 0xff0000))>>16;
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
      yp += w;
    }
    yi = x;
    for (y = 0; y < h; y++) {
      pix[yi] = 0xff000000 | (dv[rsum]<<16) | (dv[rsum]<<8) | dv[rsum];
      if (x == 0) {
        vmin[y] = min(y + radius + 1, hm)*w;
        vmax[y] = max(y - radius, 0)*w;
      }
      p1 = x + vmin[y];
      p2 = x + vmax[y];

      rsum += r[p1] - r[p2];

      yi += w;
    }
  }
}
void delay(int ms) {
  int current_time = millis();
  while (millis () - current_time < ms);
}

