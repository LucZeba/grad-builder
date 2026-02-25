// ============================================================
// UI - glavni izbornik, HUD overlay, upute
// ============================================================

PImage menuBg;
boolean showHowToPlay = false;

void setupUI() {
  menuBg = loadImage("city.png");
}

// ============================================================
// GLAVNI IZBORNIK
// ============================================================

void drawMenu() {
  camera();
  image(menuBg, 0, 0, width, height);

  if (showHowToPlay) { drawHowToPlay(); return; }

  int boxW = 420, boxH = 320;
  int boxX = width/2 - boxW/2;
  int boxY = height/2 - boxH/2 - 20;

  // Sjena + panel
  fill(0, 0, 0, 35);  noStroke();
  rect(boxX + 5, boxY + 6, boxW, boxH, 20);
  fill(235, 238, 242, 230);
  stroke(195, 205, 218, 160);  strokeWeight(1);
  rect(boxX, boxY, boxW, boxH, 20);  noStroke();

  // Naslov
  fill(55, 75, 110);
  textAlign(CENTER, CENTER);
  textSize(42);
  text("GRAD BUILDER", width/2, boxY + 80);

  // Separator
  fill(175, 190, 210, 140);
  rect(boxX + 40, boxY + 115, boxW - 80, 2, 1);

  // Gumbi
  drawMenuButton("▶  Igraj",    width/2, boxY + 170, 200, 44, true);
  drawMenuButton("?  Upute",    width/2, boxY + 228, 200, 36, false);
  drawMenuButton("X  Zatvori",  width/2, boxY + 278, 200, 36, false);
}

void drawMenuButton(String label, int cx, int cy, int w, int h, boolean primary) {
  int bx = cx - w/2, by = cy - h/2;
  boolean hover = mouseX >= bx && mouseX <= bx + w && mouseY >= by && mouseY <= by + h;

  if (primary) {
    fill(hover ? color(75, 105, 155, 240) : color(65, 90, 135, 220));
    stroke(100, 130, 175, 180);
  } else {
    fill(hover ? color(215, 222, 232, 210) : color(225, 230, 238, 170));
    stroke(185, 195, 212, 140);
  }
  strokeWeight(1);
  rect(bx, by, w, h, 10);  noStroke();

  fill(primary ? color(240, 243, 248) : color(65, 80, 105));
  textAlign(CENTER, CENTER);
  textSize(primary ? 16 : 14);
  text(label, cx, cy);
}

// ============================================================
// UPUTE PANEL
// ============================================================

void drawHowToPlay() {
  int boxW = 560, boxH = 400;
  int boxX = width/2 - boxW/2;
  int boxY = height/2 - boxH/2 - 20;

  fill(0, 0, 0, 35);  noStroke();
  rect(boxX + 5, boxY + 6, boxW, boxH, 20);
  fill(235, 238, 242, 235);
  stroke(195, 205, 218, 160);  strokeWeight(1);
  rect(boxX, boxY, boxW, boxH, 20);  noStroke();

  fill(55, 75, 110);
  textAlign(CENTER, TOP);
  textSize(24);
  text("Kako se igra?", width/2, boxY + 24);

  fill(175, 190, 210, 140);
  rect(boxX + 30, boxY + 60, boxW - 60, 2, 1);

  int tx = boxX + 40;
  int ty = boxY + 76;
  int lh = 26;

  drawControlLine("WASD",                tx, ty, 80,  "— kretanje kamerom");       ty += lh;
  drawControlLine("Desni klik + povlači", tx, ty, 160, "— rotacija kamere");        ty += lh;
  drawControlLine("Scroll",              tx, ty, 80,  "— zoom in/out");             ty += lh;
  drawControlLine("E",                   tx, ty, 80,  "— otvori/zatvori inventory"); ty += lh;
  drawControlLine("Lijevi klik (drži)",  tx, ty, 140, "— rotiraj objekt i postavi"); ty += lh;
  drawControlLine("ESC",                 tx, ty, 80,  "— otpusti odabrani objekt");  ty += lh;

  fill(175, 190, 210, 140);
  rect(boxX + 30, ty, boxW - 60, 2, 1);
  ty += 14;

  fill(120, 135, 155);
  textAlign(LEFT, TOP);
  textSize(12);
  text("Povuci objekte iz inventara (E) u slotove dolje.", tx, ty); ty += lh;
  text("Odaberi slot i klikni na tlo da postaviš objekt.", tx, ty); ty += lh;
  text("Klikni na postavljeni objekt da ga premjestiš.",   tx, ty);

  int btnW = 120, btnH = 36;
  int btnX = boxX + 24;
  int btnY = boxY + boxH - btnH - 16;
  boolean hover = mouseX >= btnX && mouseX <= btnX + btnW &&
                  mouseY >= btnY && mouseY <= btnY + btnH;
  fill(hover ? color(215, 222, 232, 210) : color(225, 230, 238, 170));
  stroke(185, 195, 212, 140);  strokeWeight(1);
  rect(btnX, btnY, btnW, btnH, 10);  noStroke();
  fill(65, 80, 105);
  textAlign(CENTER, CENTER);
  textSize(13);
  text("← Izađi", btnX + btnW/2, btnY + btnH/2);
}

void drawControlLine(String key, int x, int y, int offset, String desc) {
  fill(55, 75, 110);
  textAlign(LEFT, TOP);
  textSize(13);
  text(key, x, y);
  fill(120, 135, 155);
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
// HUD — novčići + menu gumb
// ============================================================

void drawHUD() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  noStroke();

  // Novčići
  fill(235, 238, 242, 200);
  stroke(195, 205, 218, 140);  strokeWeight(1);
  rect(14, 14, 140, 40, 12);  noStroke();

  fill(200, 170, 60);
  ellipse(38, 34, 22, 22);
  fill(160, 130, 40);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("$", 38, 33);

  fill(55, 70, 95);
  textAlign(LEFT, CENTER);
  textSize(17);
  text("" + coins, 56, 33);

  // Mode gumb — ispod novčića
  int modeBtnSize = 40;
  int modeBtnX = 14;
  int modeBtnY = 62;
  boolean modeHover = (mouseX >= modeBtnX && mouseX <= modeBtnX + modeBtnSize &&
                       mouseY >= modeBtnY && mouseY <= modeBtnY + modeBtnSize);

  fill(modeHover ? color(75, 105, 155, 200) : color(235, 238, 242, 200));
  stroke(195, 205, 218, 140);  strokeWeight(1);
  rect(modeBtnX, modeBtnY, modeBtnSize, modeBtnSize, 10);  noStroke();

  // Prikaži ikonu suprotnog moda (ono u što ćeš se prebaciti)
  PImage modeIcon = (buildMode == 0) ? walkIcon : buildIcon;
  tint(255, 255, 255, modeHover ? 255 : 180);
  image(modeIcon, modeBtnX + 6, modeBtnY + 6, modeBtnSize - 12, modeBtnSize - 12);
  noTint();

  // Menu gumb — gore desno
  int mbW = 80, mbH = 34;
  int mbX = width - mbW - 14, mbY = 14;
  boolean menuHover = (mouseX >= mbX && mouseX <= mbX + mbW &&
                       mouseY >= mbY && mouseY <= mbY + mbH);

  fill(menuHover ? color(75, 105, 155, 220) : color(235, 238, 242, 200));
  stroke(195, 205, 218, 140);  strokeWeight(1);
  rect(mbX, mbY, mbW, mbH, 12);  noStroke();

  fill(menuHover ? color(240, 243, 248) : color(65, 80, 105));
  textAlign(CENTER, CENTER);
  textSize(14);
  text("Menu", mbX + mbW/2, mbY + mbH/2);

  hint(ENABLE_DEPTH_TEST);
  perspective(PI/3.0, float(width)/float(height), 1, 10000);
}
