
class Clock {
  long    tLast;            // ms.  last frame time.
  long    tNow;             // ms.  current frame time.
  long    dt;               // ms since last frame
  float   dtSeconds;        // seconds since last frame.
  float   tSecondsRunning;  // seconds while not paused
  boolean paused;           // pause state
  
  Clock() {
    paused=false;
    tLast = millis();
    tSecondsRunning=0;
  }
 
  void update() {
    tNow = millis();
    dt = tNow - tLast;
    tLast = tNow;
    dtSeconds = (float)dt*0.001;
    
    if(!clock.paused) {
      tSecondsRunning += dtSeconds;
    }
  }
  
  void togglePaused() {
    paused = !paused;
  }
  
  void draw() {
    textSize(15);
    if(paused) fill(255,0,0);
    else       fill(128,255,128);
    text(tSecondsRunning,0,height-2);
  }
}