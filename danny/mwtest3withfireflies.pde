

PVector wind; // tracks the vector effect of wind. Wind function is globally available so its values should be too.
int oscillator;
boolean up;

Mover testMover;
Mover tetherTest;

Node testNode;

float att, med = 50, loAl, hiAl, loBe, hiBe, loGam, hiGam, thet, delt, s=100;
float attEase=50, medEase=50;

void setup() {
  size(1200,340);
  smooth();
  noStroke();
  mwInit();
  wind = new PVector(0,0);
  oscillator = 0;
  testMover = new Mover(width/2, height/2, 4, 4, 500);
  tetherTest = new Mover(width/2, height/2, 4, -4, 500);
  testNode = new Node(6,1);
}

void draw() {
  blow();
  attEase += (att-attEase)*0.1*sin(map(abs(att-attEase), 0, 100, 0, PI/2));
  medEase += (med-medEase)*0.1*sin(map(abs(med-medEase), 0, 100, 0, PI/2));
  fill(color(0,50));
  rect(0,0,width,height);
  pushMatrix();
  translate(width/2, height/2);
  rotate(map(attEase,0,100, 0, TWO_PI));
  fill(color(0,200,0));
  leaf();
  popMatrix();
  testMover.applyForce(testMover.air());
  testMover.edgeCollide();
  testMover.update();
  testMover.show();
  tetherTest.applyForce(tetherTest.air());
  tetherTest.edgeCollide();
  tetherTest.tetherUpdate(testMover, 50);
  tetherTest.show();
  //println(oscillator);
  
  testNode.fireFlyRun();
}

void leaf(){
  beginShape();
  vertex(0,0);
  bezierVertex(-15,-10,-15,-10,-25,-25);
  bezierVertex(-15,-120,-15,-120,0, -160);
  bezierVertex(15,-120,15,-120, 25, -25);
  endShape(CLOSE);
}

void mwEvent(int a,int m,int la,int ha,int lb,int hb,int lg,int hg,int d,int t) {
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

class Mover{
  PVector pos, vel, accel;  
  int weight, tall, fat;
  boolean tethered;
  
  Mover(float xPos, float yPos, float xStart, float yStart, int w){
    pos = new PVector (xPos, yPos);
    vel = new PVector(xStart, yStart);
    accel = new PVector(0,0);
    weight = w;    
  }
  
  void show () {
    ellipse(pos.x, pos.y, 10, 10);
  }
  
  void update () {
    vel.add(accel);    
    accel.set(0,0);
    pos.add(vel);
  }   
 
  void edgeCollide () {
    if((pos.x<0 && vel.x<0)||(pos.x>width && vel.x>0)){
      vel.x=vel.x*-1;
    }
    
    if((pos.y<0 && vel.y<0)||(pos.y>height && vel.y>0)){
      vel.y=vel.y*-1;
    }
  }
 
  void applyForce (PVector force){
    accel.x += (force.x/weight); 
    accel.y += (force.y/weight);
  }
  
  float heading (PVector target) {
    PVector h = new PVector (target.x - pos.x, target.y - pos.y);
    float angle = atan(h.y/h.x);
    
    if(h.x<0){
      angle += PI;
    }
    
    return angle;
  }
  
  void tetherUpdate(Mover master, float rad){
    PVector hold = new PVector(pos.x, pos.y);
    PVector oldVel = new PVector(vel.x, vel.y);
    vel.add (accel);
    accel.set (0,0);
    float distAround = (vel.x*cos(heading(master.pos)-PI/2))+(vel.y*sin(heading(master.pos)-PI/2));
    float newAngle = heading(master.pos)+(distAround/rad);
    pos.set(master.pos.x-(rad*cos(newAngle)), master.pos.y-(rad*sin(newAngle)));
    vel.set(pos.x-hold.x, pos.y-hold.y);
    oldVel.sub(vel);
    strokeWeight(5);
    stroke(255,0,0);
    noStroke();
    point(hold.x+oldVel.x, hold.y+oldVel.y);
    master.applyForce(oldVel);
    //vel.set(distAround*cos(newAngle-PI/2), distAround*sin(newAngle-PI/2));
  }
  
  PVector tension(float toX, float toY, int gentle, float lim){
    PVector back = new PVector(toX-pos.x, toY-pos.y);
    stroke(0, 255, 255);
    strokeWeight(3);
    line(pos.x, pos.y, toX, toY);
    noStroke();
    float ease = sin(map(back.mag(), 0, lim, 0, PI/2)); 
    
    
    back.mult(4*ease);
    
    
    return back;
  }
  
  PVector air(){
    PVector airPower = new PVector(wind.x-vel.x, 0);
    return airPower;
  }
    
}

void blow(){
  wind.x = (100-medEase)/100;
  
  if(oscillator>60){
    up = false;
  }else if(oscillator<0){
    up = true;
  }
  
  if(up){
    oscillator ++;
  }else{
    oscillator --;
  }
  
  wind.mult(oscillator/10);
}

class Node{
  Node [] children;
  Node parent;
  Mover junction;
  int scale;
  int track;
  boolean recurse;
  boolean dad;
  
  Node (int startScale, int stopScale){
    scale = startScale;
    junction = new Mover(random(0,width), random(0,height), random(1,5), random(1,5), int(random(10,200)));
    track = 1+int(random(0,3));
    
    if(startScale>stopScale){
      recurse = true;
      children = new Node [track];
      for(int i = 0; i<children.length; i++){
        children[i] = new Node(scale-1-int(noise(i*400)*track*2), stopScale);
        children[i].parent = this;
        children[i].dad = true;
      }
    }
  }
    
  
  void fireFlyRun(){
    fill(255,255,0);
    junction.edgeCollide();
    if(dad){
      junction.tetherUpdate(parent.junction, 40);
    }else{
      junction.update();
    }
    junction.show();
    if(recurse){
      for (int i = 0; i<children.length; i++) {
        children[i].fireFlyRun();
      }
    }
   fill(0,255,0);
  }
    
}

//class Node{
//  Node [] children;
//  Node parent;
//  PVector limb;
//  Mover junction;
//  float scale;
//  int track;
//  
//  Node (int startScale, int stopScale, int d, float bassStartX, float bassStartY, float radz, int num){
//    scale = startScale;
//    angle = radz;
//    junction = new Mover(bassStartX, bassStartY, 0, 0, d);
//    track = num;
//    limb = new PVector(bassStartX, bassStartY);
// 
//    if(startscale>stopScale){
//      children = new Node [num];
//      for(int i = 0; i<num; i++){
//        float kidAng = angle-PI/3+(2*PI/3*((i+1.0)/(num+1)));
//        float additive = 2*scale*(0.5-noise((bassStartX)*3000)); //randomly gives the child branch a 'kick' in the middle
//        float dist = -scale*2.5; //distance the new branch is away
//        float xAdd = cos(kidAng)*dist+sin(kidAng)*additive;
//        float yAdd = sin(kidAng)*dist+cos(kidAng)*additive;
//        children[i] = new Node(scale-1-int(noise(yAdd*400)*num*2), stopScale, xAdd, yAdd, kidAng, 1+int(noise(yAdd*400)*3));
//        children[i].parent = this;
//        println(int(noise(yAdd*400)*1.5));
//      }
//    }
//  }
//    
//  void sway(boolean tree){
//    if(tree){
//      leaf.setFill(color(0,0,255));
//      fill(0,0,255);
//    }else{
//      leaf.setFill(color(115,255,255,150));
//      fill(107,255,255,150);
//    }
//    
//    //println(l);
//    if(l>0){
//      show();
//
//      for (int i = 0; i<track; i++) {
//        //children[0].junction.applyForce(gravity);
//        children[i].junction.applyForce(children[i].junction.air());
//        children[i].junction.applyForce(children[i].junction.tension(junction.pos.x+branches[i].x, junction.pos.y+branches[i].y, 1, 2*branches[i].mag()));
//        children[i].junction.tetherUpdate(junction.pos, branches[i].mag());
//        //children[0].show();
//        pushMatrix();
//        translate(junction.pos.x, junction.pos.y);
//        rotate(PI/2+junction.heading(children[i].junction.pos));
//        scale(scale/60);
//        shape(leaf, 0, 0);
//        scale(-0.75);
//        shape(leaf, 0, branches[i].mag()*90/scale);
//        popMatrix(); 
//        children[i].sway(tree);
//      }
//            
//  }
//  if(l<4 && tree){    
//      pushMatrix();
//      translate(junction.pos.x, junction.pos.y);
//      rotate(-angle-PI/3);
//      scale(0.2);
//      greens.display();
//      popMatrix();
//    }
//  }
//
// void show (){
//   pushMatrix();
//   translate(junction.pos.x, junction.pos.y);
//   //rotate(angle);
//   ellipse(0, 0, (scale-1)*1.1, (scale-1)*1.1);
//   //shape(leaf,0,0);
//   popMatrix();
// }   
//    
//}

