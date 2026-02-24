// ============================================================
// STANJA IGRE
// 0 = glavni izbornik
// 1 = gradnja
// 2 = mini igrica (za kasnije)
// ============================================================
int gameState = 0;
int coins = 1000;
float placingCenterScreenX, placingCenterScreenY;
float placingStartAngle;

void setup() {
  size(1200, 800, P3D);
  perspective(PI/3.0, float(width)/float(height), 1, 10000);
  setupCamera();
  setupInventar();
  setupModele();
}

void draw() {
  background(135, 206, 235);
  switch(gameState) {
    case 0: drawMenu(); break;
    case 1: drawGradnja(); break;
    case 2: drawIgrica(); break;
  }
}

void mousePressed() {
  if (gameState == 0) mouseMenu();
  if (gameState == 1) {
    if (inventoryOpen) {
      clickedInventory(mouseX, mouseY);
      return;
    }
    if (mouseButton == RIGHT) {
      rightMouseHeld = true;
      prevMouseX = mouseX;
      prevMouseY = mouseY;
    }
    if (mouseButton == LEFT) {
      if (!clickedInventory(mouseX, mouseY)) {
        if (selectedObjectIndex >= 0 || selectedPlacedIndex >= 0) {
          InventoryItem item = getSelectedItem();
          if (item != null && lastGridValid) {
            placingDrag = true;
            if (item != null && lastGridValid) {
              placingDrag = true;
              placingStartRotation = previewRotation;
            }
          }
        } else {
          mouseGradnja(); // free hand — klikni na objekt da ga podigneš
        }
      }
    }
  }
}

void mouseMoved() {}

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
  if (gameState == 1) {
    if (inventoryOpen) inventoryScroll(event.getCount());
    else {
      camY += event.getCount() * 10;
      camY = constrain(camY, 800, 2000);
    }
  }
}

void keyPressed() {
  if (gameState == 1) {
    if (key == 'e' || key == 'E') {
      inventoryOpen = !inventoryOpen;
      if (inventoryOpen) rightMouseHeld = false;
      return;
    }
    if (key == 'r' || key == 'R') {
      if (selectedObjectIndex >= 0 || selectedPlacedIndex >= 0) {
        previewRotation += radians(30);
      }
    }
    if (keyCode == ESC) {
      selectedPlacedIndex = -1;
      previewRotation = 0;
      key = 0;
    }
    if (!inventoryOpen) keyPressedKamera();
  }
}

void keyReleased() {
  if (gameState == 1) keyReleasedKamera();
}
