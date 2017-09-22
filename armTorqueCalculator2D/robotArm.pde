// Torque = orhogonal force * distance from center
// T = F * L

final static int NUM_JOINTS = 7;
final static float JOINT_SELECTION_LIMIT = 40.0;
final static int FONT_HEIGHT = 12;
final static int LINE_HEIGHT = FONT_HEIGHT+2;
final static float JOINT_DIAMETER = 12;


enum RotationType {
  NONE,
  AXIAL,
  PLANAR,
};


class RobotJoint {
  float        mass;  // kg
  Vector       posAbs;
  Vector       posOriginalRel;
  Vector       posParentRel;
  float        angleRel;
  float        angleAbs;
  Vector       cumulativeX, cumulativeY;
  Vector       force;
  float        torque;
  float        maxTorque;
  RotationType rotationType;
  float        turnSpeed;
  
  RobotJoint() {
    posAbs = new Vector();
    posOriginalRel = new Vector();
    posParentRel = new Vector();
    cumulativeX = new Vector();
    cumulativeY = new Vector();
    force = new Vector();
    turnSpeed = 1;
  }
};


class RobotArm {
  RobotJoint [] joints;
  int activeJoint;
  int activeJointDirection;
  boolean drawAngles;
  boolean drawTorques;
  
  RobotArm() {
    joints = new RobotJoint[NUM_JOINTS];
    activeJoint=-1;
    activeJointDirection=0;
    
    int i;
    for(i=0;i<NUM_JOINTS;++i) {
      joints[i] = new RobotJoint();
      joints[i].angleRel=0;
    }
    
    // j0 - shoulder
    // 1x 47:1 NEMA23 motor, 2300g ea     https://www.omc-stepperonline.com/geared-stepper-motor/nema-23-stepper-motor-bipolar-l76mm-w-gear-raio-471-planetary-gearbox-23hs30-2804s-pg47.html?mfp=57-motor-nema-size%5BNema%2023%5D
    // 2x 70-110-20 bearing, 576.0623g ea http://www.vxb.com/6014-2RS1-Bore-Dia-70mm-OD-110mm-Width-20mm-p/6014-2rs1.htm
    joints[0].posOriginalRel.set(0, 0);
    joints[0].mass=4.235;
    joints[0].rotationType=RotationType.AXIAL;
    joints[0].maxTorque = 4000;  //Ncm
    // j1 - bicep
    // same motor as j1    
    // 2x 60-78-10 bearing , 81.64663g ea http://www.vxb.com/61812-2RZ-Bore-Dia-60mm-OD-78mm-Width-10mm-p/61812-2rz.htm
    joints[1].posOriginalRel.set(0,10);
    joints[1].mass=4.442;
    joints[1].rotationType=RotationType.PLANAR;
    joints[1].maxTorque = 4000;
    // j2 - elbow
    // 1x 15:1 NEMA17 motor, 680g ea        https://www.omc-stepperonline.com/geared-stepper-motor/nema-17-stepper-motor-l39mm-gear-raio-151-high-precision-planetary-gearbox-17hs15-1684s-hg15.html
    // 2x 45-58-7 bearing  ,  40.82331g ea  https://www.vxb.com/61809-2RZ-Double-Bore-Dia-45mm-OD-58mm-Width-7mm-p/61809-2rz.htm 
    joints[2].posOriginalRel.set(0,25);
    joints[2].mass=0.184 + 2.553;
    joints[2].rotationType=RotationType.PLANAR;
    joints[2].maxTorque = 3500;
    // j3 - roll wrist
    // 1x 15:1 NEMA17 motor, 680g ea        https://www.omc-stepperonline.com/geared-stepper-motor/nema-17-stepper-motor-l39mm-gear-raio-151-high-precision-planetary-gearbox-17hs15-1684s-hg15.html
    // 2x 45-58-7 bearing  ,  40.82331g ea  https://www.vxb.com/61809-2RZ-Double-Bore-Dia-45mm-OD-58mm-Width-7mm-p/61809-2rz.htm 
    joints[3].posOriginalRel.set(0,10);
    joints[3].mass=1.106;
    joints[3].rotationType=RotationType.AXIAL;
    joints[3].maxTorque = 3500;
    // j4 - tilt wrist
    // 1x 15:1 NEMA14 motor, 320g ea        https://www.omc-stepperonline.com/geared-stepper-motor/nema-14-stepper-motor-bipolar-l33mm-w-gear-raio-191-planetary-gearbox-14hs13-0804s-pg19.html
    joints[4].posOriginalRel.set(0,10);
    joints[4].mass=0.338;
    joints[4].rotationType=RotationType.PLANAR;
    joints[4].maxTorque = 3000;
    // j5 - roll hand
    // 1x 90:1 NEMA8  motor, 130g ea        https://www.omc-stepperonline.com/geared-stepper-motor/nema-8-stepper-motor-bipolar-l38mm-w-gear-raio-901-planetary-gearbox-8hs15-0604s-pg90.html?mfp=57-motor-nema-size%5BNema%208%5D
    joints[5].posOriginalRel.set(0, 5);
    joints[5].mass=0.059;
    joints[5].rotationType=RotationType.AXIAL;
    joints[4].maxTorque = 900;
    // j6 - tool
    // max mass 2kg
    joints[6].posOriginalRel.set(0, 5);
    joints[6].mass=2.000;
    joints[6].rotationType=RotationType.NONE;
    
    // set initial position
    joints[1].angleRel=PI/2;
  }

  
  int findNearestJoint(Vector p,float maxDistance) {
    int i;
    int iMin=-1;
    float dMin=width;
    
    for(i=0;i<NUM_JOINTS;++i) {
      if(this.joints[i].rotationType != RotationType.PLANAR) continue;
      
      Vector dp = vectorSubtract(vectorScale(this.joints[i].posAbs,SCALE),p);
      float d = vectorLength(dp);
      if( dMin > d ) {
        dMin = d;
        iMin = i;
      }
    }
    if(dMin<maxDistance) {
      //println(iMin+" @ "+dMin);
      return iMin;
    }
    else return -1;
  }
  
  
  void draw() {
    int i;
    
    // linkages
    stroke(0,0,255);
    noFill();
    for(i=0;i<NUM_JOINTS-1;++i) {
      line(this.joints[i].posAbs.x*SCALE,
           this.joints[i].posAbs.y*SCALE,
           this.joints[i+1].posAbs.x*SCALE,
           this.joints[i+1].posAbs.y*SCALE);
    }
    
    // decorate joints
    for(i=0;i<NUM_JOINTS;++i) {
      if(this.joints[i].rotationType!=RotationType.PLANAR) continue;
      
      if(activeJoint==i) {
        fill(255,0,0);
      } else {
        fill(255,255,0);
      }
      noStroke();
      ellipse(this.joints[i].posAbs.x*SCALE,
              this.joints[i].posAbs.y*SCALE,
              JOINT_DIAMETER,
              JOINT_DIAMETER);
        stroke(0,255,0);
        ellipse(this.joints[i].posAbs.x*SCALE,
                this.joints[i].posAbs.y*SCALE,
                JOINT_DIAMETER,
                JOINT_DIAMETER);
        stroke(255,0,0);
        arc(this.joints[i].posAbs.x*SCALE,
            this.joints[i].posAbs.y*SCALE,
            JOINT_DIAMETER,
            JOINT_DIAMETER,
            0,
            2 * PI * this.joints[i].torque / this.joints[i].maxTorque );
    }
    if(activeJoint==-1) {
      int highlightJoint = this.findNearestJoint(new Vector(mouseX,mouseY),JOINT_SELECTION_LIMIT);
      if(highlightJoint!=-1) {
        stroke(255,128,0);
        noFill();
        ellipse(this.joints[highlightJoint].posAbs.x*SCALE,
                this.joints[highlightJoint].posAbs.y*SCALE,
                JOINT_DIAMETER,
                JOINT_DIAMETER);
      }
    }
  
    // force
    stroke(255,255,0);
    noFill();
    for(i=0;i<NUM_JOINTS;++i) {
      line(this.joints[i].posAbs.x*SCALE,
           this.joints[i].posAbs.y*SCALE,
           this.joints[i].posAbs.x*SCALE + this.joints[i].force.x,
           this.joints[i].posAbs.y*SCALE + this.joints[i].force.y);
    }
    
    // active force
    if(activeJoint>=0) {
      stroke(255,127,127);
      noFill();
      Vector p = vectorScale(this.joints[activeJoint].posAbs,SCALE);
      line(mouseX,mouseY,p.x,p.y);
    }
    
  
    // torque
    noStroke();
    textSize(FONT_HEIGHT);
    for(i=0;i<NUM_JOINTS;++i) {
      int x=0,y=height-LINE_HEIGHT*((i+1)*2+0);
      String jointName = " "+i; 
      String torque = this.joints[i].torque+"Ncm";
      String maxTorque = "/ "+ this.joints[i].maxTorque+"Ncm";
      String angle = "θ="+degrees(this.joints[i].angleRel);
      String mass = this.joints[i].mass+"kg";
      String len = vectorLength(this.joints[i].posOriginalRel)+"cm";
      String rtName = this.joints[i].rotationType==RotationType.PLANAR?"PLANAR":"AXIAL";
      fill(255,255,255);  text(jointName, x, y);  x+=24;
      fill(255,255,255);  text(rtName   , x, y);  x+=70;
      fill(255,255,255);  text(mass     , x, y);  x+=60;
      fill(255,255,255);  text(len      , x, y);  x+=60;
      fill(255,255,127);  text(angle    , x, y);  x+=100;
      fill(255,0,0);      text(torque   , x, y);  x+=100;
      fill(0,255,0);      text(maxTorque, x, y);  x+=100;

      if(drawTorques) {
        fill(255,255,255);
        text(this.joints[i].torque+"Ncm",
             this.joints[i].posAbs.x*SCALE,
             this.joints[i].posAbs.y*SCALE);
      }
      if(drawAngles) {
        fill(255,255,127);
        text(i+"θ="+degrees(this.joints[i].angleRel),
             this.joints[i].posAbs.x*SCALE,
             this.joints[i].posAbs.y*SCALE-LINE_HEIGHT);
      }
    }
  }
  
  
  void animateAbsPosition() {
    if(activeJoint!=-1 && this.joints[activeJoint].rotationType == RotationType.PLANAR) {
      this.joints[activeJoint].angleRel -= clock.dtSeconds * this.activeJointDirection * this.joints[activeJoint].turnSpeed;
    }
      
    int i;
    for(i=0;i<NUM_JOINTS;++i) {
      RobotJoint joint = this.joints[i];
      if(i==0) {
        joint.angleAbs = joint.angleRel;
      } else {
        RobotJoint previousJoint = this.joints[i-1];
        joint.angleAbs = previousJoint.angleAbs + joint.angleRel;
      }
      
      float c = cos(this.joints[i].angleAbs);
      float s = sin(this.joints[i].angleAbs);

      this.joints[i].cumulativeX.x = c;
      this.joints[i].cumulativeX.y = -s;
      this.joints[i].cumulativeY.x = s;
      this.joints[i].cumulativeY.y = c;
      
      if(i<NUM_JOINTS-1) {
        RobotJoint nextJoint = this.joints[i+1];
        // b.p' = a.p' + b.p.x * a.cumulativeX + b.p.y * a.cumulativeY;
        nextJoint.posParentRel.x = nextJoint.posOriginalRel.x * joint.cumulativeX.x + nextJoint.posOriginalRel.y * joint.cumulativeY.x;
        nextJoint.posParentRel.y = nextJoint.posOriginalRel.x * joint.cumulativeX.y + nextJoint.posOriginalRel.y * joint.cumulativeY.y;
        
        nextJoint.posAbs.x = joint.posAbs.x + nextJoint.posParentRel.x; 
        nextJoint.posAbs.y = joint.posAbs.y + nextJoint.posParentRel.y;
      }
    }
  }
  
  
  void animateForces() {
    int i;
    for(i=NUM_JOINTS-1;i>=0;--i) {
      this.joints[i].force.set(0,this.joints[i].mass*GRAVITY);
    }
  
    for(i=NUM_JOINTS-1;i>=0;--i) {
      recursivelyCalculateTorque(i);
    }
    
    if(activeJoint!=-1) {
      Vector p = vectorScale(this.joints[activeJoint].posAbs,SCALE);
      Vector mouse = new Vector(mouseX,mouseY);
      Vector mousePull = vectorScale(vectorSubtract(mouse,p),20.0/SCALE);
      this.joints[activeJoint].force = vectorAdd( this.joints[activeJoint].force, mousePull ); 
    }
  }
  
  
  void recursivelyCalculateTorque(int arg0) {
    Vector p = this.joints[arg0].posAbs;
    float T = 0;
    
    int i;
    for(i=NUM_JOINTS-1;i>arg0;--i) {
      // F = T * L where L is length of vector A-B and T is orthogonal to A-B
      Vector v = vectorSubtract(this.joints[i].posAbs,p);
      float L = vectorLength(v);  // cm
      Vector vNormal = vectorScale(v,1.0/L);
      Vector vOrtho = new Vector(vNormal.y,vNormal.x);
      Vector fOrtho = vectorDot(vOrtho,this.joints[i].force);
      float F = vectorLength(fOrtho);
      if(L>=0.01) {  // ignore joints of zero length
        T += F * L;
      }
      //println(i+"\t"+L+"\t"+F);
    }
    
    this.joints[arg0].torque = T;
  }
  
  // tell joint to rotate in direct arg0.
  // @param arg9 -1 for negative, 1 for positive.
  void rotateSelectedJoint(int arg0) {
    activeJointDirection = arg0;
  }
};