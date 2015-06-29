

PVector wind; // tracks the vector effect of wind. Wind function is globally available so its values should be too.
int oscillator;
boolean up;

Node testNode;
Node testTree;

float att, med = 50, loAl, hiAl, loBe, hiBe, loGam, hiGam, thet, delt, s=100;
float attEase=50, medEase=50;

void setup() {
  size(1200, 375);
  smooth();
  noStroke();
  mwInit();
  wind = new PVector(0, 0);
  oscillator = 0;
  testNode = new Node(11, 1, width/2, height/2, -PI/2);
  testTree = new Node(20, 1, width/2, height, -PI/2);
}

void draw() {
  blow();
  attEase += (att-attEase)*0.1*sin(map(abs(att-attEase), 0, 100, 0, PI/2));
  medEase += (med-medEase)*0.1*sin(map(abs(med-medEase), 0, 100, 0, PI/2));
  fill(color(0, 50));
  rect(0, 0, width, height);
  pushMatrix();
  translate(width/2, height/2);
  rotate(map(attEase, 0, 100, 0, TWO_PI));
  fill(color(0, 200, 0));
  leaf();
  popMatrix();
  //println(testTree.junction.pos.x);
  fill(color(255, 0));
  ellipse(width/2, height, 50, 50);

  //testNode.fireFlyRun();
  testTree.treeShow();
}

void mouseClicked() {
  testTree = new Node(15, 1, mouseX, mouseY, -PI/2);
}

void leaf() {
  beginShape();
  vertex(0, 0);
  bezierVertex(-15, -10, -15, -10, -25, -25);
  bezierVertex(-15, -120, -15, -120, 0, -160);
  bezierVertex(15, -120, 15, -120, 25, -25);
  endShape(CLOSE);
}

void mwEvent(int a, int m, int la, int ha, int lb, int hb, int lg, int hg, int d, int t) {
  //println(v);
  att = a;
  med = m;
  loAl = la % 360;
  loBe = lb % 360;
  loGam = lg % 360;
  hiAl = ha % 256;
  hiBe = hb % 256;
  hiGam = hg % 256;
  delt = d;
  thet = t;
}

void mwBlinkEvent(int bs) {
  s = bs;
}

class Mover {
  PVector pos, vel, accel;  
  int weight, tall, fat;
  boolean tethered;

  Mover(float xPos, float yPos, float xStart, float yStart, int w) {
    pos = new PVector (xPos, yPos);
    vel = new PVector(xStart, yStart);
    accel = new PVector(0, 0);
    weight = w;
  }

  void show () {
    ellipse(pos.x, pos.y, 10, 10);
  }

  void update () {
    vel.add(accel);    
    accel.set(0, 0);
    pos.add(vel);
  }   

  void edgeCollide () {
    if ((pos.x<0 && vel.x<0)||(pos.x>width && vel.x>0)) {
      vel.x=vel.x*-1;
    }

    if ((pos.y<0 && vel.y<0)||(pos.y>height && vel.y>0)) {
      vel.y=vel.y*-1;
    }
  }

  void applyForce (PVector force) {
    accel.x += (force.x/weight); 
    accel.y += (force.y/weight);
  }

  float heading (PVector target) {
    PVector h = new PVector (target.x - pos.x, target.y - pos.y);
    float angle = atan(h.y/h.x);

    if (h.x<0) {
      angle += PI;
    }

    return angle;
  }

  void tetherUpdate(Mover master, float rad) {
    PVector hold = new PVector(pos.x, pos.y);
    PVector oldVel = new PVector(vel.x, vel.y);
    vel.add (accel);
    accel.set (0, 0);
    float distAround = (vel.x*cos(heading(master.pos)-PI/2))+(vel.y*sin(heading(master.pos)-PI/2));
    float newAngle = heading(master.pos)+(distAround/rad);
    pos.set(master.pos.x-(rad*cos(newAngle)), master.pos.y-(rad*sin(newAngle)));
    vel.set(pos.x-hold.x, pos.y-hold.y);
    oldVel.sub(vel);
    oldVel.mult(2);
    strokeWeight(5);
    stroke(255, 0, 0);
    noStroke();
    point(hold.x+oldVel.x, hold.y+oldVel.y);
    master.applyForce(oldVel);
    //vel.set(distAround*cos(newAngle-PI/2), distAround*sin(newAngle-PI/2));
  }

  PVector tension(float toX, float toY, int gentle, float lim) {
    PVector back = new PVector(toX-pos.x, toY-pos.y);
    stroke(0, 255, 255);
    strokeWeight(3);
    line(pos.x, pos.y, toX, toY);
    noStroke();
    float ease = sin(map(back.mag(), 0, lim, 0, PI/2)); 


    back.mult(4*ease);


    return back;
  }

  PVector air() {
    PVector airPower = new PVector(wind.x-vel.x, 0);
    return airPower;
  }
}

void blow() {
  wind.x = (100-medEase)/10;

  if (oscillator>60) {
    up = false;
  } else if (oscillator<0) {
    up = true;
  }

  if (up) {
    oscillator ++;
  } else {
    oscillator --;
  }

  wind.mult(oscillator/10);
}

class Node {
  Node [] children;
  Node parent;
  Mover junction;
  int sc;
  int track;
  boolean recurse;
  boolean dad;
  float ang;
  PVector orig; //relative to parent

  Node (int startScale, int stopScale, float startX, float startY, float angle) {
    sc = startScale;
    ang = angle;
    junction = new Mover(startX, startY, 0, 0, startScale);
    track = int(2.5-noise(startX, startY));
    println(noise(startX, startY));

    if (startScale>stopScale) {
      recurse = true;
      children = new Node [track];

      if (track == 2) {
        int kidScale = int(random(2,sc-2));
        float dist = sc*4;
        float kidAng = ang+PI/4*(0.3-(pow(noise(400*startX*startY),(startScale-kidScale))));//angle-PI/3+(2*PI/3*((i+1.0)/(track+1)))+(PI/3)*(0.5-noise(startX*startY));
        float additive = 2*dist*(0.5-noise(startX*startY)); //for a 'kick' that doesn't change angle
        float passX = (dist*cos(kidAng))+sin(kidAng)*additive;
        float passY = (dist*sin(kidAng))+cos(kidAng)*additive;
        children[1] = new Node(kidScale, stopScale, startX+passX, startY+passY, kidAng);
        children[1].parent = this;
        children[1].dad = true;
        children[1].orig = new PVector(passX, passY);
        sc -= int(kidScale/2);
      }

      int kidScale = sc-1;
      float dist = sc*3;
      float kidAng = ang+(startScale-kidScale)*PI/30*(0.3-noise(-400*startX*startY));//angle-PI/3+(2*PI/3*((i+1.0)/(track+1)))+(PI/3)*(0.5-noise(startX*startY));
      float additive = 2*dist*(0.5-noise(startX*startY)); //for a 'kick' that doesn't change angle
      float passX = (dist*cos(kidAng))+sin(kidAng)*additive;
      float passY = (dist*sin(kidAng))+cos(kidAng)*additive;
      children[0] = new Node(kidScale, stopScale, startX+passX, startY+passY, kidAng);
      children[0].parent = this;
      children[0].dad = true;
      children[0].orig = new PVector(passX, passY);
      sc = startScale;
    }
    
  }

void treeShow() {
  fill(color(255, 255, 255));
  pushMatrix();
  translate(junction.pos.x, junction.pos.y);
  ellipse(0, 0, sc, sc);
  popMatrix();
  if (recurse) {
    for (int i = 0; i<children.length; i++) {
      children[i].treeShow();
    }
  }
}

void fireFlyRun() {
  fill(color(255, 255, 0));
  junction.edgeCollide();
  if (dad) {
    junction.tetherUpdate(parent.junction, 40);
  } else {
    junction.update();
  }
  junction.show();
  if (recurse) {
    for (int i = 0; i<children.length; i++) {
      children[i].fireFlyRun();
    }
  }
  fill(color(0, 255, 0));
}


}