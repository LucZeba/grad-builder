// ============================================================
// UI - izbornik, HUD, prelazi između stanja
// ============================================================

void drawMenu() {
  camera();
  background(30, 30, 50);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(52);
  text("GRAD BUILDER", width/2, height/3);
  textSize(26);
  fill(200, 200, 200);
  text("Klikni za početak", width/2, height/2 + 20);
  textSize(18);
  fill(150, 150, 150);
  text("Mini igrica (uskoro)", width/2, height/2 + 70);
}

void mouseMenu() {
  if (mouseX > width/2 - 150 && mouseX < width/2 + 150 &&
      mouseY > height/2 && mouseY < height/2 + 50) {
    gameState = 1;
  }
}

void drawHUD() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  noStroke();

  // Novčići
  fill(0, 0, 0, 130);
  rect(10, 10, 160, 36, 6);
  fill(255, 220, 0);
  textAlign(LEFT, TOP);
  textSize(20);
  text("$ " + coins, 20, 14);

  // Upute
  fill(0, 0, 0, 130);
  rect(10, 55, 280, 90, 6);
  fill(255);
  textSize(13);
  text("WASD - kretanje", 18, 62);
  text("Desni klik + povlači - rotacija", 18, 78);
  text("Scroll - zoom", 18, 94);
  text("Lijevi klik drzanje i puštanje - postavi i rotiraj objekt", 18, 110);
  text("\"E\" - otvori inventory", 18, 110);

  // Koordinate i smjer
  fill(0, 0, 0, 130);
  rect(10, 155, 280, 50, 6);
  fill(255);
  textSize(11);
  text("X: " + nf(camX, 0, 0) + "  Y: " + nf(camY, 0, 0) + "  Z: " + nf(camZ, 0, 0), 18, 160);
  text("Smjer: " + getSmjer(), 18, 178);
  text(debugGrid, 18, 196);

  hint(ENABLE_DEPTH_TEST);
  perspective(PI/3.0, float(width)/float(height), 1, 10000);
}

void drawIgrica() {
  camera();
  background(20, 20, 20);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Mini igrica - uskoro!", width/2, height/2);
}

String getSmjer() {
  float deg = degrees(camAngleH) % 360;
  if (deg < 0) deg += 360;
  return nf(deg, 0, 0) + "°";
}
