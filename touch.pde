import cc.arduino.*;

import hypermedia.video.*;
import processing.serial.*;
import Blobscanner.*;
import java.util.*;
import processing.opengl.*;

float displayScale;

Serial myPort;
Arduino arduino;

PGraphics buffer;

Detector bd;

Board board;

void setup() {
	size(600, 600, P2D);

	println(Serial.list());
	//myPort = new Serial(this, Serial.list()[1], 9600);

	bd = new Detector( this, 0, 0, width, height, 255 );
	board = new Board();
	generateBoard();

	buffer = createGraphics(width, height, P2D);

	displayScale = 60; // 80*10 = 800
	stroke(255);
	background(255, 255, 255);
} 

void draw() {

  background(255,255,255);
  int i = 0;
  
  //println(arduino.digitalRead(3));

  buffer.beginDraw();
  updateBoard(); // do the computations
  board.draw(buffer, displayScale); // draw the lines from the board object
  findBlobs();
  image(buffer,0,0,width,height);

  //println(frameRate);
}

void findBlobs() {
  
  //image(buffer,0,0,width,height);
  buffer.endDraw();
  PImage img = buffer.get(); // get the PImage
  fastBlur(img, 20); //blur it to fill in the gaps
  //image(img, 0,0,width,height);
  img.filter(THRESHOLD); // threshold
 //image(img, 0, 0, width, height); // paint the lines onto the screen
  
  bd.imageFindBlobs(img);
  bd.loadBlobsFeatures();
  bd.drawContours(color(255,0,0),1);

  //bd.weightBlobs(false);
  //bd.findCentroids(true, true);
  //for each blob in the image..
  /*for (int i = 0; i < bd.getBlobsNumber(); i++) {
    //computes and prints the mass.
    if (bd.getBlobWeight(i) > 250) {
      println("   The mass of blob #" + (i+1) + " is " + bd.getBlobWeight(i) + " pixels.");
      bd.drawBlobContour(i, color(255, 0, 0), 2);
    }
  }*/
}

void updateBoard() {
  buffer.background(255, 255, 255);
  buffer.stroke(0);
  buffer.strokeWeight(1);
  board.obstructions.get(0).location.x = mouseX/displayScale;
  board.obstructions.get(0).location.y = mouseY/displayScale;
  //println(board.obstructions.get(0).location);
  board.findBlockedPaths();
}

/*void generateBoard() { // make six vertical lines
  int i;
  float w = 10;
  float h = 10;
  float numX = 4;
  float numY = 10;

  float xSpacing = w/numX;
  float ySpacing = h/numY;

  float xOffset = w / (numX * 2);
  float yOffset = h / (numY * 2);
  for (i=0; i < numX; i++) {
    board.addSource(i*xSpacing+xOffset, 0);
    //board.addSensor(i*xSpacing+xOffset/2, 0);
  }  

  for (i=0; i < numX; i++) {
    //board.addSource(i*xSpacing+xOffset, h);
    board.addSensor(i*xSpacing+xOffset/2, h);
    board.addPath(i,i);
  }  


  board.addObstruction(.5, 7, 5);
  //board.addObstruction(0, 1, 2);
  //board.makePaths();
}*/

void generateBoard() {
	int i;
	float w = 10;
	float h = 10;
	int numX = 10;
	int numY = 10;

	float xSpacing = w/numX;
	float ySpacing = h/numY;

	float xOffset = w / (numX * 2);
	float yOffset = h / (numY * 2);

	// add sources before sensors
	for (i=0; i < numX; i++) {
		board.addSource(i*xSpacing+xOffset, 0);

	}  

	for (i=0; i < numY; i++) {
		board.addSource(w, i*ySpacing+yOffset);

	}

	for (i=0; i < numX; i++) {
		board.addSource(i*xSpacing+xOffset, h);

	}  

	for (i=0; i < numY; i++) {
		board.addSource(0, i*ySpacing+yOffset);

	}

	// add sensors
	for (i=0; i < numX; i++) {
		board.addSensor(i, i*xSpacing+xSpacing/3, 0);
	}  

	for (i=0; i < numY; i++) {
		board.addSensor(i + numX, w, i*ySpacing+ySpacing/3);
	}

	for (i=0; i < numX; i++) {
		board.addSensor(i + numX + numY, i*xSpacing+xSpacing/3, h);
	}  

	for (i=0; i < numY; i++) {
		board.addSensor(i + numX*2 + numY, 0, i*ySpacing+ySpacing/3);
	}

	board.addObstruction(.5, 7, 5);
	board.addObstruction(.5, 1, 2);
	//board.print();
	//board.makePaths();
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

