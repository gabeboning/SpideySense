class GenerateThread extends Thread {

  long previousTime;
  boolean isActive=true;
  double interval;

  Board b; 
  float scaling;
  PGraphics frame;
  BlockingQueue<PGraphics> frames;


  GenerateThread(touch.Board b, float scaling, PGraphics frame, BlockingQueue<PGraphics> frames) {
    this.b = b;
    this.scaling = scaling;
    this.frame = frame;
    this.frames = frames;
  }

  void run() {
  }

  void demorun() {
    float myDisplayScale = displayScale;
    int i = 0, thisMillis;
    boolean added;
    while (true) {


      if (frames.size()<100) {
        board.update(); // do the computations
        frame.beginDraw();
        board.draw(frame, myDisplayScale); // draw the lines from the board object
        //println("next line");
        frame.endDraw();
        try { 
          frames.put(frame);  
          times.put(millis());
        }
        catch(Exception E) {
        }
      }
      else {
        println("full");
      }
    }
  }
} 

