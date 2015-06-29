ArrayList trees;
ArrayList flowers;

Flower testFlower;

PVector wind; // tracks the vector effect of wind. Wind function is globally available so its values should be too.
int oscillator;
boolean up;

Node testTree;
int sizer;
int counter;
int grower;
boolean inUse;

float att=80, med = 50, loAl, hiAl, loBe, hiBe, loGam, hiGam, thet, delt, s=100;
float attEase=50, medEase=50;

Node[] grasses;

Node [] flies;

Leaves greens;

void setup() {
  size(1920, 375);
  background(0);
  smooth();
  noStroke();
  mwInit();
  wind = new PVector(0, 0);
  oscillator = 0;

  flies = new Node[4];
  for(int i = 0; i<flies.length; i++){
    flies[i] = new Node(16, 7, random(0,width), random(0,height), -PI/2, 1);
    flies[i].firefly(3);
  }

  trees = new ArrayList;
  flowers = new ArrayList;

  testTree = new Node(20, 7, width/2, height, -PI/2, 200);
  sizer = 20;

  grasses = new Node[400];

  for (int i = 0; i<grasses.length; i++) {
    grasses[i] = new Node(9, 8, int(random(0, width)), height, -PI/2+random(-PI/4, PI/4), random(40, 1));
  }
  
  greens = new Leaves();

  testFlower = new Flower(testTree.children[0], int(random(0,300)));
}

void draw() {
  sun();
  //  translate(0, -50);
  blow();
  attEase += (att-attEase)*0.1*sin(map(abs(att-attEase), 0, 100, 0, PI/2));
  medEase += (med-medEase)*0.1*sin(map(abs(med-medEase), 0, 100, 0, PI/2));
  fill(color(0, 40));
  rect(0, 0, width, height);
  for(int i = 0; i<flies.length; i++){
    flies[i].fireFlyRun();
  }
  //println((wind.x));

  pushMatrix();
  translate(3*width/4, height/2);
  testFlower.show();
  popMatrix();

  testTree.sway();
  testTree.treeShow();

  println("trees size "+ trees.size());

  for(int i = 0; i<trees.size(); i++){
    Node t = (Node) trees.get(i);
    t.sway();
    t.treeShow();
  }

  for (int i = 0; i<grasses.length; i++) {
    grasses[i].sway();
    grasses[i].grassShow();
  }

  greens.update();

  watch();  
  println(grower);
}

void watch(){
  if(s>50){
    if(inUse == false){
      inUse = true;
      trees.add(new Node(10, 7, random(20, width/2), height, -PI/2, 200));
    }
    counter = 1200;
  }else{
    counter--;
  }

  if(counter<0){
    inUse = false;
  }

  if(attEase>50){
    grower ++;
  }

  if(grower>8){
    Node t = (Node) trees.get(trees.size()-1);
    int position = int(t.junction.pos.x);
    int newSc = t.sc+1;
    trees.set(trees.size()-1, new Node(newSc, 7, position, height, -PI/2, 200));
    grower = 0;
  }
}

void mouseClicked() {
  sizer --;
  testTree = new Node(sizer, 7, width/2, height, -PI/2, 1000);
}

void keyPressed() {
  sizer ++;
  testTree = new Node(sizer, 7, width/2, height, -PI/2, 1000);
}

void leaf() {
  beginShape();
  vertex(0, 30);
  bezierVertex(-15, 20, -15, 20, -25, 5);
  bezierVertex(-15, -90, -15, -90, 0, -130);
  bezierVertex(15, -90, 15, -90, 25, 5);
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
    stroke(color(255,220,50));
    strokeWeight(1);
    fill(color(255,150));
    ellipse(pos.x, pos.y, 3, 3);
    ellipse(pos.x, pos.y, 1,1);
    noStroke();
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
    oldVel.mult(1);
    strokeWeight(5);
    stroke(color(255, 0, 0));
    noStroke();
    point(hold.x+oldVel.x, hold.y+oldVel.y);
    master.applyForce(oldVel);
    //vel.set(distAround*cos(newAngle-PI/2), distAround*sin(newAngle-PI/2));
  }

  PVector tension(float toX, float toY, float lim, int force) {
    //    stroke(color(0, 0, 200));
    //    line(pos.x, pos.y, toX, toY);
    //    noStroke();
    PVector back = new PVector(toX-pos.x, toY-pos.y);
    float ease = sin(map(back.mag(), 0, lim, 0, PI/2)); 


    back.mult(sq(force*ease));


    return back;
  }

  PVector air() {
    PVector airPower = new PVector(wind.x-vel.x, 0);
    return airPower;
  }
}

void sun(){
  pushMatrix();
  translate(100,80);
  strokeWeight(2);
  for(float i = 400; i>0; i--){
    fill(color(300-i,300-i,255-i,3*attEase-i));
    ellipse(0,0,i,i);
  }
  ellipse(0,0,7,7);
  noStroke();
  popMatrix();
}
  

void blow() {
  wind.x = (100-medEase)*oscillator/1000;

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
  float d; //from parent

  Node (int startScale, int stopScale, float startX, float startY, float angle, float dense) {
    sc = startScale;
    ang = angle;
    junction = new Mover(startX, startY, 0, 0, int(startScale*dense));
    track = int(2.7-noise(startX, startY));
    //    println(noise(startX, startY));

    if (startScale>stopScale) {
      recurse = true;
      children = new Node [track];

      if (track == 2) {
        int kidScale = int(random(2, sc-2));
        float dist = kidScale*4;
        float kidAng = ang+PI/4*(0.3-(pow(noise(400*startX*startY), (startScale-kidScale))));//angle-PI/3+(2*PI/3*((i+1.0)/(track+1)))+(PI/3)*(0.5-noise(startX*startY));
        float additive = dist*(0.5-noise(startX*startY)); //for a 'kick' that doesn't change angle
        float passX = (dist*cos(kidAng))+sin(kidAng)*additive;
        float passY = (dist*sin(kidAng))+cos(kidAng)*additive;
        children[1] = new Node(kidScale, stopScale, startX+passX, startY+passY, kidAng, dense);
        children[1].parent = this;
        children[1].dad = true;
        children[1].orig = new PVector(children[1].junction.pos.x-startX, children[1].junction.pos.y-startY);
        //println(children[1].junction.pos.x-startX-children[1].orig.x);
        children[1].d = dist;
        sc -= int(kidScale/2);
      }
      
      int kidScale = sc-3;
      if(kidScale<1){
        kidScale = 1;
      }
      float dist = sc*3;
      float kidAng = ang+(startScale-kidScale)*PI/30*(0.3-noise(startX*startY));//angle-PI/3+(2*PI/3*((i+1.0)/(track+1)))+(PI/3)*(0.5-noise(startX*startY));
      float additive = 0;//2*dist*(0.5-noise(startX*startY)); //for a 'kick' that doesn't change angle
      float passX = (dist*cos(kidAng))+sin(kidAng)*additive;
      float passY = (dist*sin(kidAng))+cos(kidAng)*additive;
      children[0] = new Node(kidScale, stopScale, startX+passX, startY+passY, kidAng, dense);
      children[0].parent = this;
      children[0].dad = true;
      children[0].orig = new PVector(children[0].junction.pos.x-startX, children[0].junction.pos.y-startY);
      //println(children[0].junction.pos.x-startX-children[0].orig.x);
      children[0].d = dist;
      sc = startScale;
    }
  }

  void treeShow() {
    if (sc>0) {
      fill(color(255, 150));
      pushMatrix();
      translate(junction.pos.x, junction.pos.y);
      scale(0.02);
      if (recurse) {

        for (int i = 0; i<children.length; i++) {
          pushMatrix();
          scale(children[i].sc);
          rotate(PI/2+junction.heading(children[i].junction.pos));
          leaf();
          stroke(color(255, 150));
          strokeWeight(15+300/sc);
          line(0, 0, 0, -150);
          noStroke();
          popMatrix();
        }
      } else {
        //      fill(color(255, 0, 0));
        pushMatrix();
        scale(sc*2);
        rotate(PI/2+ang);
        greens.display();
        leaf();
        popMatrix();
        //      fill(color(255, 150));
      }
      
      if(sc<10){
        pushMatrix();
        scale(sc);
        rotate(PI/2+ang);
        greens.display();
        popMatrix();
      }
      
      if (dad) {
        pushMatrix();
        scale(sc);
        rotate(PI/2+junction.heading(parent.junction.pos));
        leaf();
        popMatrix();
      } else {
        pushMatrix();
        scale(50);
        ellipse(0, 0, sc, sc);
        popMatrix();
      }
      popMatrix();

      if (recurse) {
        for (int i = 0; i<children.length; i++) {
          children[i].treeShow();
        }
      }
    }
  }

  void sway() {
    if (dad) {
      //      stroke(0, 0, 255);
      //      strokeWeight(3);
      //      line(junction.pos.x, junction.pos.y, parent.junction.pos.x+orig.x, parent.junction.pos.y+orig.y);
      //      point(parent.junction.pos.x+orig.x, parent.junction.pos.y+orig.y);
      //      noStroke();
    }
    if (dad) {
      PVector pass = new PVector(wind.x-junction.vel.x, 0);
      junction.applyForce(pass);
      junction.applyForce(junction.tension(parent.junction.pos.x+orig.x, parent.junction.pos.y+orig.y, 2*d, sc));
      junction.tension(parent.junction.pos.x+orig.x, parent.junction.pos.y+orig.y, 2*d, sc);
      //      parent.junction.applyForce(junction.tension(parent.junction.pos.x+orig.x, parent.junction.pos.y+orig.y, 2*d, sc));
      junction.tetherUpdate(parent.junction, d);
    } 
    if (recurse) {
      for (int i = 0; i<children.length; i++) {
        children[i].sway();
      }
    }
  }

  void firefly(int weigh) {
    //println("my scale is " + sc);
    junction.weight = weigh;
    junction.vel.x = 2;
    junction.vel.y = random(-2, 2);
    if (recurse) {
      for (int i = 0; i<children.length; i++) {
        children[i].firefly(weigh);
      }
    }
  }

  void fireFlyRun() {
    if (sc>0) {
      fill(color(255, 255, 0));
      junction.edgeCollide();
      if (dad) {
        junction.tetherUpdate(parent.junction, 20);
      } else {
        junction.update();
        if(junction.vel.mag()<1){
          junction.vel.x += random(-2,2);
          junction.vel.y += random(-2,2);
        }
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


  void grassShow () {
    fill(150, 240, 210, 170);
    //      ellipse(junction.pos.x, junction.pos.y, sc, sc);
    if (dad) {
      fill(150, 240, 210, 170);//
      beginShape();
      vertex(parent.junction.pos.x-sc/3, height);//bottom left hand corner of the triangle
      bezierVertex(parent.junction.pos.x-(sc/3)+orig.x/3, height-d/3, junction.pos.x, height-2*d/3, junction.pos.x, junction.pos.y);
      bezierVertex(junction.pos.x, height-2*d/3, parent.junction.pos.x+(sc/3)+orig.x/3, height-d/3, parent.junction.pos.x+(sc/3), height);//bottom right hand corner of the triangle
      endShape(CLOSE);
    }
    if (recurse) {
      for (int i = 0; i<children.length; i++) {
        children[i].grassShow();
      }
    }
  }
}

class Leaves{
  Mover[] ends;
  PVector[] branches;
  Mover nowhere;
  
  Leaves(){
    ends = new Mover[6];
    branches = new PVector [6];
    float angle = -PI*2/3;
    nowhere = new Mover(0,0,0,0,20);
    
    for(int i = 0; i<ends.length; i++){
      angle += PI/180*random(30,45);
      branches[i] = PVector.fromAngle(angle);
      branches[i].setMag(50);
      ends[i] = new Mover(branches[i].x, branches[i].y, 0, 0, 5);
    }
  }
    
  void update (){
    
    for(int i = 0; i<ends.length; i++){
      //ends[i].applyForce(gravity);
      ends[i].applyForce(ends[i].air());
      ends[i].applyForce(ends[i].tension(0+branches[i].x, 0+branches[i].y, 2*branches[i].mag(), 1));
      ends[i].tetherUpdate(nowhere, branches[i].mag());
    }
  }
  
  void display(){
    
    for(int i = 0; i<ends.length; i++){
      pushMatrix();
      rotate(PI+ends[i].heading(nowhere.pos));
      pushMatrix();
      //leaf.setFill(color(33,100,70));
      fill(color(230,170,80,150));
      scale(0.4, 1);
      leaf();
      popMatrix();
      pushMatrix();
      scale(2, 1);
      translate(0,-60);
      fill(color(100,215,100,100));
      leaf();
      popMatrix();
      popMatrix();  
    }
  }

  void floral (Node upon, float sizey, int seed, int red, int green, int blue){
    for(int i = 0; i<ends.length; i++){
      pushMatrix();
      rotate(PI+ends[i].heading(nowhere.pos));
      pushMatrix();
      fill(color(red,green,blue, 150)); //150 50 255 //120 255 40 //255 255 50 //20 255 255 //255 255 255 //50 50 255 //255 50 255
      translate(0, seed%13);
      scale(0.2+seed%3, 0.2+(seed%7)/4);
      leaf();
      popMatrix();
      pushMatrix();
      scale(0.5+seed%2, 1+(seed%10)/10);
      translate(0, -seed%50);
      fill(color(green, blue, red, 150));
      leaf();
      popMatrix();
      popMatrix();  
    }
  }
}

class Flower{
  int c1, c2, c3;
  int s;
  Node target;
  int theSeed;
  
  Flower(Node where, int seed){
    target = where;
    
    if(seed%5 == 0){
      c1 = 250;
    }else if(seed%7 == 0){
      c1 = 150;
    }else{
      c1 = 50;
    }
    
    if(seed%9 == 0){
      c2 = 250;
    }else if(seed%3 == 0){
      c2 = 150;
    }else{
      c2 = 50;
    }
    
    if(seed%8 == 0){
      c3 = 250;
    }else if(seed%2 == 0 || c2<100 && c1<100){
      c3 = 150;
    }else{
      c3 = 50;
    }
    
    s = 1;
    theSeed = seed;
  }
  
  void show (){
    pushMatrix();
    //translate(target.junction.pos.x, target.junction.pos.y);
    //scale(s*0.02);
    greens.floral(target, s, theSeed, c1, c2, c3);
    rotate(PI);
    greens.floral(target, s, theSeed, c1, c2, c3);
    popMatrix();    
  }
}
