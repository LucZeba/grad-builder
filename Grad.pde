// ============================================================
// SETUPOVI I EVENTI
// ============================================================
int gameState = 0;
int coins = 1000;
int buildMode = 0; // 0 = gradnja, 1 = pješački
boolean novciciActive = false;
boolean novciciTriggerReady = true;
boolean tetrisActive = false;
boolean tetrisTriggerReady = true;
boolean canStartNovcici = false;
boolean canStartTetris = false;
boolean arkanoidActive = false;
boolean arkanoidTriggerReady = true;
boolean canStartArkanoid = false;
PImage buildIcon, walkIcon;
SoundFile bgMusic, openInventory, closeInventory, toggleMode, placementSound, errorSound;

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
  setupNovcici();
  setupTetris();
  bgMusic = new SoundFile(this, "elevator_music.mp3");
  openInventory = new SoundFile(this, "inventory_open.mp3");
  closeInventory = new SoundFile(this, "inventory_close.mp3");
  toggleMode = new SoundFile(this, "toggle_mode.mp3");
  placementSound = new SoundFile(this, "placement.mp3");
  errorSound = new SoundFile(this, "error.mp3");
  bgMusic.loop();
  bgMusic.amp(0.05);
}

void draw() {
  lights();
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
      if (!toggleMode.isPlaying()) {
        toggleMode.play();
        toggleMode.amp(0.05);
      }
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
      
    if (novciciActive) {
      //if (keyCode == LEFT || keyCode == RIGHT) keyPressed2();
      keyPressed2();
      if (keyCode == ESC) {
        novciciActive = false;
        resetCameraMovementKeys();
        loop();
      }
      return;
    }
    if (tetrisActive) {
      //if (keyCode == UP || keyCode == LEFT || keyCode == RIGHT || key == ' ' || keyCode == DOWN) keyPressed3();
      keyPressed3();
      if (keyCode == ESC) {
        tetrisActive = false;
        resetCameraMovementKeys();
        loop();
      }
      return;
    }
    if (arkanoidActive) {
      keyPressed4();
      if (keyCode == ESC) {
        arkanoidActive = false;
        resetCameraMovementKeys();
        loop();
      }
      return;
    }

    if (buildMode == 0) {
      if (key == 'e' || key == 'E') {
        inventoryOpen = !inventoryOpen;
        if (inventoryOpen) {
          rightMouseHeld = false;
          if (!openInventory.isPlaying()) {
            openInventory.play();
            openInventory.amp(0.05);
          }
        }
        if (!closeInventory.isPlaying()) {
          closeInventory.play();
          closeInventory.amp(0.05);
        }
        return;
      }
      if (keyCode == ESC) {
        selectedPlacedIndex = -1;
        previewRotation = 0;
        key = 0;
      }
    }else{
      //kad se približi rudniku/ljuljačkoj za početak igre
      if (key == 'p' || key == 'P') {
        if (canStartNovcici && novciciTriggerReady) {
          novciciActive = true;
          setupNovcici();
          novciciTriggerReady = false;
        }
      
        if (canStartTetris && tetrisTriggerReady) {
          tetrisActive = true;
          setupTetris();
          tetrisTriggerReady = false;
        }
        
        if (canStartArkanoid && arkanoidTriggerReady) {
          arkanoidActive = true;
          setupArkanoid();
          arkanoidTriggerReady = false;
        }
      }  
    }  
    if (!inventoryOpen) keyPressedKamera();
  }
}

void keyReleased() {
  if (gameState == 1) {
    if (novciciActive || tetrisActive) return;
    keyReleasedKamera();
  }
}
