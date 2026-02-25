// ============================================================
// UI - glavni izbornik, HUD overlay, upute
// ============================================================

PImage menuBg;
boolean showHowToPlay = false;

void setupUI() {
  menuBg = loadImage("city.png");
}

// ============================================================
// GLAVNI IZBORNIK — gameState == 0
// ============================================================

void drawMenu() {
  camera();
  image(menuBg, 0, 0, width, height);

  if (showHowToPlay) {
    drawHowToPlay();
    return;
  }

  int boxW = 420, boxH = 320;
  int boxX = width/2 - boxW/2;
  int boxY = height/2 - boxH/2 - 20;

  // Sjena + panel
  fill(0, 0, 0, 60);  noStroke();
  rect(boxX + 6, boxY + 8, boxW, boxH, 16);
  fill(10, 10, 20, 175);
  stroke(180, 160, 120, 120);  strokeWeight(1);
  rect(boxX, boxY, boxW, boxH, 16);  noStroke();

  // Naslov
  fill(255, 230, 150);
  textAlign(CENTER, CENTER);
  textSize(42);
  text("GRAD BUILDER", width/2, boxY + 80);

  // Separator
  fill(180, 160, 120, 100);
  rect(boxX + 40, boxY + 115, boxW - 80, 1);

  // Gumbi
  drawMenuButton("▶  Igraj", width/2, boxY + 170, 200, 44, true);
  drawMenuButton("?  Upute", width/2, boxY + 228, 200, 36, false);
  drawMenuButton("X  Zatvori", width/2, boxY + 278, 200, 36, false);
}

// Crtanje jednog gumba u izborniku (primary = žuti, inače bijeli)
void drawMenuButton(String label, int cx, int cy, int w, int h, boolean primary) {
  int bx = cx - w/2, by = cy - h/2;
  boolean hover = mouseX >= bx && mouseX <= bx + w && mouseY >= by && mouseY <= by + h;

  if (primary) {
    fill(hover ? color(220, 190, 80, 230) : color(190, 160, 60, 200));
    stroke(255, 220, 100, 150);
  } else {
    fill(hover ? color(255, 255, 255, 50) : color(255, 255, 255, 25));
    stroke(255, 255, 255, 60);
  }
  strokeWeight(1);
  rect(bx, by, w, h, 8);  noStroke();

  fill(primary ? color(30, 20, 0) : color(220, 220, 230));
  textAlign(CENTER, CENTER);
  textSize(primary ? 16 : 14);
  text(label, cx, cy);
}

// ============================================================
// UPUTE PANEL — "Kako se igra?"
// ============================================================

void drawHowToPlay() {
  int boxW = 560, boxH = 400;
  int boxX = width/2 - boxW/2;
  int boxY = height/2 - boxH/2 - 20;

  // Sjena + panel
  fill(0, 0, 0, 60);  noStroke();
  rect(boxX + 6, boxY + 8, boxW, boxH, 16);
  fill(10, 10, 20, 185);
  stroke(180, 160, 120, 120);  strokeWeight(1);
  rect(boxX, boxY, boxW, boxH, 16);  noStroke();

  // Naslov
  fill(255, 230, 150);
  textAlign(CENTER, TOP);
  textSize(24);
  text("Kako se igra?", width/2, boxY + 24);

  fill(180, 160, 120, 100);
  rect(boxX + 30, boxY + 60, boxW - 60, 1);

  // Upute — tipka + opis
  int tx = boxX + 40;
  int ty = boxY + 76;
  int lh = 26;

  drawControlLine("WASD", tx, ty, 80,  "— kretanje kamerom");       ty += lh;
  drawControlLine("Desni klik + povlači", tx, ty, 160, "— rotacija kamere");        ty += lh;
  drawControlLine("Scroll", tx, ty, 80,  "— zoom in/out");             ty += lh;
  drawControlLine("E", tx, ty, 80,  "— otvori/zatvori inventory"); ty += lh;
  drawControlLine("Lijevi klik (drži)", tx, ty, 140, "— rotiraj objekt i postavi"); ty += lh;
  drawControlLine("ESC", tx, ty, 80,  "— otpusti odabrani objekt");  ty += lh;

  // Separator
  fill(180, 160, 120, 150);
  rect(boxX + 30, ty, boxW - 60, 1);
  ty += 14;

  // Dodatne upute
  fill(190, 190, 200);
  textAlign(LEFT, TOP);
  textSize(12);
  text("Povuci objekte iz inventara (E) u slotove dolje.", tx, ty); ty += lh;
  text("Odaberi slot i klikni na tlo da postaviš objekt.", tx, ty); ty += lh;
  text("Klikni na postavljeni objekt da ga premjestiš.", tx, ty);

  // Gumb Izađi
  int btnW = 120, btnH = 36;
  int btnX = boxX + 24;
  int btnY = boxY + boxH - btnH - 16;
  boolean hover = mouseX >= btnX && mouseX <= btnX + btnW &&
                  mouseY >= btnY && mouseY <= btnY + btnH;
  fill(hover ? color(255, 255, 255, 50) : color(255, 255, 255, 20));
  stroke(255, 255, 255, 60);  strokeWeight(1);
  rect(btnX, btnY, btnW, btnH, 8);  noStroke();
  fill(220, 220, 230);
  textAlign(CENTER, CENTER);
  textSize(13);
  text("← Izađi", btnX + btnW/2, btnY + btnH/2);
}

// Pomoćna — ispisuje "tipka — opis" u uputama
void drawControlLine(String key, int x, int y, int offset, String desc) {
  fill(220, 220, 230);
  textAlign(LEFT, TOP);
  textSize(13);
  text(key, x, y);
  fill(150, 150, 170);
  text(desc, x + offset, y);
}

// ============================================================
// KLIKOVI NA IZBORNIKU
// ============================================================

void mouseMenu() {
  if (showHowToPlay) {
    int boxW = 560, boxX = width/2 - boxW/2, boxY = height/2 - 220;
    int btnX = boxX + 24, btnY = boxY + 400 - 36 - 16;
    if (mouseX >= btnX && mouseX <= btnX + 120 &&
        mouseY >= btnY && mouseY <= btnY + 36) {
      showHowToPlay = false;
    }
    return;
  }

  int boxY = height/2 - 180;
  if (mouseX >= width/2 - 100 && mouseX <= width/2 + 100) {
    if (mouseY >= boxY + 148 && mouseY <= boxY + 192) { gameState = 1; return; }
    if (mouseY >= boxY + 210 && mouseY <= boxY + 246) { showHowToPlay = true; return; }
    if (mouseY >= boxY + 260 && mouseY <= boxY + 296) { exit(); }
  }
}

// ============================================================
// HUD — overlay tijekom igre (novčići + kompas)
// ============================================================

void drawHUD() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  noStroke();

  // Novčići — gore lijevo
  fill(0, 0, 0, 140);
  rect(14, 14, 150, 40, 10);

  // Ikona novčića
  fill(255, 210, 50);
  ellipse(38, 34, 22, 22);
  fill(200, 160, 30);
  textAlign(CENTER, CENTER);
  textSize(13);
  text("$", 38, 33);

  // Iznos
  fill(255, 245, 220);
  textAlign(LEFT, CENTER);
  textSize(18);
  text("" + coins, 56, 33);
  
  // Gumb "Menu" — gore desno
  int mbW = 60, mbH = 34;
  int mbX = width - mbW - 14;
  int mbY = 14;
  boolean menuHover = (mouseX >= mbX && mouseX <= mbX + mbW &&
                       mouseY >= mbY && mouseY <= mbY + mbH);

  fill(menuHover ? color(255, 255, 255, 60) : color(0, 0, 0, 140));
  stroke(255, 255, 255, menuHover ? 120 : 50);
  strokeWeight(1);
  rect(mbX, mbY, mbW, mbH, 10);
  noStroke();

  fill(menuHover ? color(255, 255, 255) : color(200, 200, 210));
  textAlign(CENTER, CENTER);
  textSize(15);
  text("Menu", mbX + mbW/2, mbY + mbH/2);

  hint(ENABLE_DEPTH_TEST);
  perspective(PI/3.0, float(width)/float(height), 1, 10000);
}
