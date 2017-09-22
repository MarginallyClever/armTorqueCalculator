// 
//
// # Robot Arm Torque Calculator #
// 
//
// This app draws a 6DOF serial manipulator robot arm in 2D and calculates the linear and torque forces on each joint.
// The robot's mass and dimensions are set in the robotArm constructor. 
//
// Written 2017-09-05 in Processsing 3.3.5 by Dan Royer (dan@marginallyclever.com) 
//
// Default unit of measurement is centimeters, kilograms, celcius, radians.
// 
//
// ## controls ##
// 
// Spacebar toggles the clock pause.
// When the mouse cursor is near a planar joint that joint will become highlighted.
// Click and hold the left mouse button to make a highlighted joint into a selected joint.
// Q/E will rotate a selected joint if the clock is not paused.
// 1 will toggle display of torque at each joint.
// 2 will toggle display of angle at each joint.
// 
//
// ## output ##
//
// Bottom left of screen shows total seconds of unpaused clock time.  red is paused.  green is unpaused.
// Arm is on the top of the screen becase Y=0 is top of Processing window and Y+ is downwards.
// Robot arm linkages are in dark blue.
// Robot linear forces (gravity) are in green.
// Most robot joints are in yellow.
// Highlighted robot joints have an orange box around them.
// Selected joints are red and have a line leading to the mouse cursor.
// Each robot joint displays the current angle (θ) in degrees and the torque force (T) in Newtons.
// 


final static float SCALE   = 4;      // for rendering
final static float GRAVITY = -9.80665; // m/s/s


RobotArm   arm;
Clock      clock;


void setup() {
  clock = new Clock();
  arm = new RobotArm();
  arm.joints[0].posAbs.x = (width/2)/SCALE;

  size(600,600);  // window size
}



void draw() {
  animate();

  drawBackground();
  
  arm.draw();
  clock.draw();
}


void drawBackground() {
  // erase everything
  background(127,127,127);
  // dark portion at bottom of view
  fill(64,64,64);
  noStroke();
  rect(0,height-216,width,height);
}


void animate() {
  clock.update();
  
  if(!clock.paused) {
    arm.animateAbsPosition();
    arm.animateForces();
  }
}


void keyPressed() {
  //println("Pressed "+key+" aka "+keyCode);

  switch(key) {
    case 'q':  arm.rotateSelectedJoint(-1);  break;
    case 'e':  arm.rotateSelectedJoint(1);  break;
    default: break;
  }
}


void keyReleased() {
  //println("Released "+key+" aka "+keyCode);
  switch(key) {
    case 'q':  arm.rotateSelectedJoint(0);  break;
    case 'e':  arm.rotateSelectedJoint(0);  break;
    case '1':  arm.drawTorques = !arm.drawTorques;  break;
    case '2':  arm.drawAngles  = !arm.drawAngles;   break;  
    case ' ':  clock.togglePaused();  break;
    default: break;
  }
}

void mousePressed() {
  Vector mouse = new Vector(mouseX,mouseY);
  arm.activeJoint = arm.findNearestJoint(mouse,JOINT_SELECTION_LIMIT);
  //arm.rotateSelectedJointTowards(mouse);
}

void mouseReleased() {
  arm.activeJoint = -1;
}