// ============================================================
// SETUPOVI I EVENTI
// ============================================================
int gameState = 0;
int coins = 1000;
int buildMode = 0; // 0 = gradnja, 1 = pješački
PImage buildIcon, walkIcon;

void setup() {
  size(1200, 800, P3D);
  perspective(PI/3.0, float(width)/float(height), 1, 5000000);
  buildIcon = loadImage("build.png");
  walkIcon = loadImage("walk.png");
  setupCamera();
  setupInventar();
  setupModele();
  setupUI();
  setupOblake();
}

void draw() {
  background(135, 206, 235);
  switch(gameState) {
    case 0: drawMenu(); break;
    case 1: drawGradnja(); break;
  }
}

void mousePressed() {
  if (gameState == 0) mouseMenu();
  if (gameState == 1) {
    int mbW = 80, mbH = 34, mbX = width - mbW - 14, mbY = 14;
    if (mouseX >= mbX && mouseX <= mbX + mbW &&
        mouseY >= mbY && mouseY <= mbY + mbH) {
      gameState = 0;
      selectedObjectIndex = -1;
      selectedPlacedIndex = -1;
      previewRotation = 0;
      placingDrag = false;
      return;
    }
    int modeBtnSize = 40;
    int modeBtnX = 14;
    int modeBtnY = 62;
    if (mouseX >= modeBtnX && mouseX <= modeBtnX + modeBtnSize &&
        mouseY >= modeBtnY && mouseY <= modeBtnY + modeBtnSize) {
      if (buildMode == 0) {
        // Prebaci u pješački
        buildMode = 1;
        selectedObjectIndex = -1;
        selectedPlacedIndex = -1;
        previewRotation = 0;
        placingDrag = false;
        inventoryOpen = false;
        camY = 80;
        camAngleV = 0.3;
      } else {
        buildMode = 0;
        camY = 940;
        camAngleV = 0.1;
      }
      return;
    }
    if (inventoryOpen) {
      clickedInventory(mouseX, mouseY);
      return;
    }
    if (mouseButton == RIGHT) {
      rightMouseHeld = true;
      prevMouseX = mouseX;
      prevMouseY = mouseY;
    }
    if (mouseButton == LEFT && buildMode == 0) {
      if (!clickedInventory(mouseX, mouseY)) {
        if (selectedObjectIndex >= 0 || selectedPlacedIndex >= 0) {
          InventoryItem item = getSelectedItem();
          if (item != null && lastGridValid) {
            placingDrag = true;
          }
        } else {
          mouseGradnja();
        }
      }
    }
  }
}

void mouseReleased() {
  if (gameState == 1) {
    inventoryMouseReleased(mouseX, mouseY);
    if (mouseButton == LEFT && placingDrag) {
      placingDrag = false;
      mouseGradnja();
      return;
    }
    if (!inventoryOpen) mouseReleasedKamera();
  }
}

void mouseDragged() {
  if (gameState == 1) {
    if (inventoryOpen) {
      inventoryMouseDragged(mouseX, mouseY);
      return;
    }
    if (mouseButton == LEFT && placingDrag) {
      return; // samo blokiraj kameru, rotaciju računamo u draw()
    }
    mouseDraggedKamera();
  }
}

void mouseWheel(MouseEvent event) {
  if (gameState == 1 && buildMode == 0) {
    if (inventoryOpen) inventoryScroll(event.getCount());
    else {
      camY += event.getCount() * 10;
      camY = constrain(camY, 800, 2000);
    }
  }
}

void keyPressed() {
  if (gameState == 1) {
    if (buildMode == 0) {
      if (key == 'e' || key == 'E') {
        inventoryOpen = !inventoryOpen;
        if (inventoryOpen) rightMouseHeld = false;
        return;
      }
      if (keyCode == ESC) {
        selectedPlacedIndex = -1;
        previewRotation = 0;
        key = 0;
      }
    }
    if (!inventoryOpen) keyPressedKamera();
  }
}

void keyReleased() {
  if (gameState == 1) keyReleasedKamera();
}
