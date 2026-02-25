// ============================================================
// OKOLINA - tlo, sunce, nebo
// ============================================================

void drawGround() {
  pushMatrix();
  translate(0, 0, 0);  // tlo na y=0
  fill(100, 150, 100);
  noStroke();
  box(8000, 2, 8000);
  popMatrix();

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

void drawSun(float x, float y, float z) {
  pushMatrix();
  translate(x, y, z);

  fill(255, 230, 0);
  noStroke();
  sphere(5000);

  popMatrix();
}
