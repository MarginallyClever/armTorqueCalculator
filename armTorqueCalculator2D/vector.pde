

class Vector {
  float x,y;
  
  Vector() {
    x=0;
    y=0;
  }
  
  Vector(float arg0,float arg1) {
    x = arg0;
    y = arg1;
  }
  
  void set(float arg0,float arg1) {
    x = arg0;
    y = arg1;
  }
};


// return a-b
Vector vectorSubtract(Vector a,Vector b) {
  float x=a.x-b.x;
  float y=a.y-b.y;
  return new Vector(x,y);  
}

// return a+b
Vector vectorAdd(Vector a,Vector b) {
  float x=a.x+b.x;
  float y=a.y+b.y;
  return new Vector(x,y);  
}

// return length of vector
float vectorLength(Vector a) {
  return sqrt( a.x*a.x + a.y*a.y );
}


// return a*b
Vector vectorScale(Vector a,float b) {
  float x=a.x*b;
  float y=a.y*b;
  return new Vector(x,y);  
}


// return a dot product b
Vector vectorDot(Vector a,Vector b) {
  float x=a.x*b.x;
  float y=a.y*b.y;
  return new Vector(x,y);  
}