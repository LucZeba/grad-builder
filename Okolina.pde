// ============================================================
// OKOLINA - tlo, sunce, nebo
// ============================================================

void drawGround() {
  pushMatrix();
  translate(0, 0, 0);
  fill(100, 150, 100);
  noStroke();
  box(8000, 2, 8000);
  popMatrix();

  // Grid linije samo u gradnja modu
  if (buildMode == 0) {
    stroke(80, 120, 80);
    strokeWeight(1);
    int gridSize = 60;
    int gridCount = 4000 / gridSize;
    for (int i = -gridCount; i <= gridCount; i++) {
      float pos = i * gridSize;
      line(-4000, 1, pos, 4000, 1, pos);
      line(pos, 1, -4000, pos, 1, 4000);
    }
    noStroke();
  }
}

void drawSun(float x, float y, float z) {
  pushMatrix();
  translate(x, y, z);

  fill(255, 230, 0);
  noStroke();
  sphere(5000);

  popMatrix();
}

// ============================================================
// OBLACI
// ============================================================
int NUM_CLOUDS = 70;
float[][] clouds;

void setupOblake() {
  clouds = new float[NUM_CLOUDS][6];
  for (int i = 0; i < NUM_CLOUDS; i++) {
    clouds[i][0] = random(-6000, 6000);   // x
    clouds[i][2] = random(-6000, 6000);   // z
    clouds[i][3] = random(1000, 2000);    // širina (duplo)
    clouds[i][4] = random(80, 180);       // visina
    clouds[i][5] = random(600, 1200);     // dubina (duplo)

    // Ako je izvan trave (±4000), može biti niže
    boolean izvanTrave = abs(clouds[i][0]) > 4000 || abs(clouds[i][2]) > 4000;
    if (izvanTrave) {
      clouds[i][1] = random(600, 2300);   // niže do više
    } else {
      clouds[i][1] = random(2200, 2500);  // iznad build kamere
    }
  }
}

void drawOblake() {
  noStroke();
  for (int i = 0; i < NUM_CLOUDS; i++) {
    float cx = clouds[i][0];
    float cy = clouds[i][1];
    float cz = clouds[i][2];
    float cw = clouds[i][3];
    float ch = clouds[i][4];
    float cd = clouds[i][5];

    fill(255, 255, 255, 55);
    pushMatrix();
    translate(cx, cy, cz);
    box(cw, ch, cd);
    popMatrix();

    fill(255, 255, 255, 45);
    pushMatrix();
    translate(cx - cw * 0.35, cy - ch * 0.3, cz + cd * 0.1);
    box(cw * 0.6, ch * 0.8, cd * 0.55);
    popMatrix();

    fill(255, 255, 255, 40);
    pushMatrix();
    translate(cx + cw * 0.3, cy + ch * 0.2, cz - cd * 0.15);
    box(cw * 0.5, ch * 0.7, cd * 0.5);
    popMatrix();
  }
}
