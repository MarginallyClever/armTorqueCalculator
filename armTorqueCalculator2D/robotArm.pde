// Torque = orhogonal force * distance from center
// T = F * L

final static int NUM_JOINTS = 7;
final static float JOINT_SELECTION_LIMIT = 40.0;


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
    
    joints[0].posOriginalRel.set(0,0.00);  joints[0].mass=0.500;  joints[0].rotationType=RotationType.AXIAL;
    joints[1].posOriginalRel.set(0,0.10);  joints[1].mass=0.300;  joints[1].rotationType=RotationType.PLANAR;
    joints[2].posOriginalRel.set(0,0.25);  joints[2].mass=0.400;  joints[2].rotationType=RotationType.PLANAR;
    joints[3].posOriginalRel.set(0,0.12);  joints[3].mass=0.200;  joints[3].rotationType=RotationType.AXIAL;
    joints[4].posOriginalRel.set(0,0.12);  joints[4].mass=0.100;  joints[4].rotationType=RotationType.PLANAR;
    joints[5].posOriginalRel.set(0,0.00);  joints[5].mass=0.500;  joints[5].rotationType=RotationType.AXIAL;
    joints[6].posOriginalRel.set(0,0.10);  joints[6].mass=2.000;  joints[6].rotationType=RotationType.NONE;
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
      rect(this.joints[i].posAbs.x*SCALE-2,
           this.joints[i].posAbs.y*SCALE-2,
           4,
           4);
    }
    if(activeJoint==-1) {
      int highlightJoint = this.findNearestJoint(new Vector(mouseX,mouseY),JOINT_SELECTION_LIMIT);
      if(highlightJoint!=-1) {
        stroke(255,128,0);
        noFill();
        rect(this.joints[highlightJoint].posAbs.x*SCALE-4,
             this.joints[highlightJoint].posAbs.y*SCALE-4,
             8,
             8);
      }
    }
  
    // force
    stroke(0,255,0);
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
    int fontSize = 12;
    int lineHeight = fontSize+2; 
    fill(255,255,255);
    noStroke();
    textSize(fontSize);
    for(i=0;i<NUM_JOINTS;++i) {
      int x=0,y=height-lineHeight*((i+1)*2+0);
      String torque = i+" T="+this.joints[i].torque;
      String angle = "θ="+degrees(this.joints[i].angleRel);
      String mass = this.joints[i].mass+"kg";
      String rtName = this.joints[i].rotationType==RotationType.PLANAR?"PLANAR":"AXIAL";
      fill(255,255,255);  text(torque , x, y);  x+=100;
      fill(255,255,127);  text(angle  , x, y);  x+=100;
      fill(255,255,255);  text(mass   , x, y);  x+=100;
      fill(255,255,255);  text(rtName , x, y);  x+=100;

      if(drawTorques) {
        fill(255,255,255);
        text(i+"T="+this.joints[i].torque,
             this.joints[i].posAbs.x*SCALE,
             this.joints[i].posAbs.y*SCALE);
      }
      if(drawAngles) {
        fill(255,255,127);
        text(i+"θ="+degrees(this.joints[i].angleRel),
             this.joints[i].posAbs.x*SCALE,
             this.joints[i].posAbs.y*SCALE-lineHeight);
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