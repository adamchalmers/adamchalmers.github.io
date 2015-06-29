
float x=0, y=0, z=0, tx=50, ty=50, s=100;
int cr=255, cg=0, cb=0;
PShape leaf;

void setup() {
  size(1200, 340, P2D);
  mwInit();
  leaf = createShape();
  leaf.beginShape();
  leaf.vertex(0,0);
  leaf.vertex(-25,-25);
  leaf.vertex(0, -160);
  leaf.vertex(25, -25);
  leaf.endShape(CLOSE);
  leaf.setFill(color(0,200,0,100));
}

void draw() {
  pushMatrix();
  fill(color(255, 50));
  rect(0,0,width,height);
  translate(width/2, height/2);
  rotate(map(tx,0,100,-PI,PI));
  shape(leaf, 0, 0);
  popMatrix();
}

void mwEvent(int a, int m, int la, int ha, int lb, int hb, int lg, int hg, int d, int t) {
  //println(v);
  tx = a;
  ty = m;
  x = la % 360;
  y = lb % 360;
  z = lg % 360;
  cr = ha % 256;
  cg = hb % 256;
  cb = hg % 256;
}

void mwBlinkEvent(int bs) {
  s = bs;
}


