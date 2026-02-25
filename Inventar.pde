// ============================================================
// INVENTAR
// ============================================================

ArrayList<InventoryItem> allItems  = new ArrayList<InventoryItem>();

int   HOTBAR_SLOTS = 8;
int[] hotbarSlots  = new int[HOTBAR_SLOTS];

boolean inventoryOpen    = false;
int     inventoryScrollY = 0;

PImage trashIcon;
PImage handIcon;

int     draggingFromInventory = -1;
int     draggingFromHotbar    = -1;
int     dragMouseX, dragMouseY;
boolean isDragging = false;

void setupInventar() {
  for (int i = 0; i < HOTBAR_SLOTS; i++) hotbarSlots[i] = -1;
  trashIcon = loadImage("trash.png");
  handIcon = loadImage("hand.png");
  allItems.add(new InventoryItem("Auto crveni", 50, "Car.obj", 25, 0.0, 2, 0));
  allItems.add(new InventoryItem("Bonsai", 30, "Lowpoly_tree_sample.obj", 6, 0.74, 2, 5));
  allItems.add(new InventoryItem("Velika kuća", 30, "Cyprys_House.obj", 25, 0.0, 6, 3));
  allItems.add(new InventoryItem("Bor", 30, "CartoonTree.obj", 15, 0.0, 2, 5));
  allItems.add(new InventoryItem("Ljuljacka", 20, "Swing.obj", 0.5, 0.0, 2, 4));
  allItems.add(new InventoryItem("Klupa", 30, "bench.obj", 0.3, 0.0, 1, 2));
  allItems.add(new InventoryItem("Bamboo kuća", 30, "Bambo_House.obj", 20, 0.0, 5, 3));
  allItems.add(new InventoryItem("Zgrada", 30, "building_04.obj", 70, -0.5, 8, 3));
}

class InventoryItem {
  String naziv;
  int cijena;
  String objFile;
  float skala, yOffset;
  int gridVelicina;
  int kategorija;

  InventoryItem(String naziv, int cijena, String objFile,
                float skala, float yOffset, int gridVelicina, int kategorija) {
    this.naziv = naziv;
    this.cijena = cijena;
    this.objFile = objFile;
    this.skala = skala;
    this.yOffset = yOffset;
    this.gridVelicina = gridVelicina;
    this.kategorija = kategorija;
  }
}

// -------------------------------------------------------
// Dimenzije hotbara
// -------------------------------------------------------
final int SLOT_W   = 76;
final int SLOT_H   = 76;
final int SLOT_PAD = 6;

int hotbarTotalW() { return HOTBAR_SLOTS * (SLOT_W + SLOT_PAD) - SLOT_PAD; }
int hotbarX()      { return width/2 - hotbarTotalW()/2; }
int hotbarY()      { return height - SLOT_H - 14; }

// -------------------------------------------------------
// CRTANJE HOTBARA
// -------------------------------------------------------
void drawInventoryHUD() {
  camera();
  hint(DISABLE_DEPTH_TEST);

  int hx = hotbarX();
  int hy = hotbarY();
  int tw = hotbarTotalW();

  // Pozadina hotbara
  noStroke();
  fill(240, 240, 245, 55);
  rect(hx - 12, hy - 10, tw + 24, SLOT_H + 20, 12);

  // Tanka bijela linija na vrhu
  fill(255, 255, 255, 40);
  rect(hx - 12, hy - 10, tw + 24, 1, 1);

  // ---------- Hotbar slotovi ----------
  for (int i = 0; i < HOTBAR_SLOTS; i++) {
    int sx = hx + i * (SLOT_W + SLOT_PAD);
    boolean selected = (selectedObjectIndex == i && hotbarSlots[i] != -1);

    if (selected) {
      stroke(255, 210, 80, 220);
      strokeWeight(2);
      fill(255, 200, 60, 60);
    } else {
      stroke(255, 255, 255, 50);
      strokeWeight(1);
      fill(200, 210, 220, 35);
    }
    rect(sx, hy, SLOT_W, SLOT_H, 8);
    noStroke();

    if (hotbarSlots[i] != -1) {
      InventoryItem item = allItems.get(hotbarSlots[i]);

      // Ikona pozadina
      fill(selected ? color(255, 200, 60, 50) : color(255, 255, 255, 25));
      rect(sx + 8, hy + 8, SLOT_W - 16, SLOT_H - 34, 5);

      // Naziv
      fill(selected ? color(255, 230, 100) : color(240, 240, 250));
      textAlign(CENTER, CENTER);
      textSize(11);
      text(item.naziv, sx + SLOT_W/2, hy + SLOT_H - 22);

      // Cijena
      fill(selected ? color(255, 200, 60) : color(200, 190, 150));
      textSize(10);
      text(item.cijena + " $", sx + SLOT_W/2, hy + SLOT_H - 10);

      // Koš za brisanje iz slota — samo kad je inventory otvoren
      if (inventoryOpen) {
        int iconSize = 20;
        int iconX = sx + SLOT_W - iconSize - 4;
        int iconY = hy + 4;

        boolean hoverTrash = (mouseX >= iconX && mouseX <= iconX + iconSize &&
                              mouseY >= iconY && mouseY <= iconY + iconSize);

        if (hoverTrash) {
          fill(255, 80, 80, 60);
          noStroke();
          rect(iconX - 2, iconY - 2, iconSize + 4, iconSize + 4, 4);
        }

        tint(255, 255, 255, hoverTrash ? 255 : 140);
        image(trashIcon, iconX, iconY, iconSize, iconSize);
        noTint();
      }

    } else {
      fill(255, 255, 255, 35);
      textAlign(CENTER, CENTER);
      textSize(20);
      text("+", sx + SLOT_W/2, hy + SLOT_H/2 + 2);
    }

    // Broj slota
    fill(255, 255, 255, 55);
    textAlign(LEFT, TOP);
    textSize(9);
    text(i + 1, sx + 5, hy + 4);
  }

  // ---------- Free hand gumb — lijevo od hotbara ----------
  int fhSize = 52;
  int fhX = hx - fhSize - 18;
  int fhY = hy + SLOT_H/2 - fhSize/2;
  boolean freeHand = (selectedObjectIndex == -1 && selectedPlacedIndex < 0);

  if (freeHand) {
    fill(100, 200, 120, 80);
    stroke(120, 210, 130, 180);
  } else {
    fill(200, 200, 210, 50);
    stroke(180, 180, 195, 100);
  }
  strokeWeight(2);
  rect(fhX, fhY, fhSize, fhSize, 10);
  noStroke();
  
  tint(255, 255, 255, freeHand ? 255 : 160);
  image(handIcon, fhX + 8, fhY + 8, fhSize - 16, fhSize - 16);
  noTint();

  // ---------- Koš za brisanje postavljenog objekta — desno od hotbara ----------
  if (selectedPlacedIndex >= 0) {
    int trashSize = 52;
    int trashX = hx + tw + 18;
    int trashY = hy + SLOT_H/2 - trashSize/2;

    boolean trashHover = (mouseX >= trashX && mouseX <= trashX + trashSize &&
                          mouseY >= trashY && mouseY <= trashY + trashSize);

    if (trashHover) {
      fill(255, 80, 80, 80);
      stroke(255, 100, 100, 180);
    } else {
      fill(200, 200, 210, 50);
      stroke(180, 180, 195, 100);
    }
    strokeWeight(2);
    rect(trashX, trashY, trashSize, trashSize, 10);
    noStroke();

    tint(255, 255, 255, trashHover ? 255 : 160);
    image(trashIcon, trashX + 8, trashY + 8, trashSize - 16, trashSize - 16);
    noTint();
  }

  // ---------- Drag preview ----------
  if (isDragging) {
    InventoryItem item = null;
    if (draggingFromInventory != -1) item = allItems.get(draggingFromInventory);
    else if (draggingFromHotbar != -1 && hotbarSlots[draggingFromHotbar] != -1)
      item = allItems.get(hotbarSlots[draggingFromHotbar]);

    if (item != null) {
      fill(240, 240, 255, 200);
      stroke(255, 210, 80, 200);
      strokeWeight(1.5);
      rect(dragMouseX - SLOT_W/2, dragMouseY - SLOT_H/2, SLOT_W, SLOT_H, 8);
      noStroke();
      fill(30, 30, 40);
      textAlign(CENTER, CENTER);
      textSize(11);
      text(item.naziv, dragMouseX, dragMouseY - 4);
      fill(180, 140, 30);
      textSize(10);
      text(item.cijena + " $", dragMouseX, dragMouseY + 10);
    }
  }

  hint(ENABLE_DEPTH_TEST);
  perspective(PI/3.0, float(width)/float(height), 1, 10000);

  if (inventoryOpen) drawInventoryPanel();
}

// -------------------------------------------------------
// INVENTORY PANEL
// -------------------------------------------------------

// Kategorije
final String[] KATEGORIJE = {
  "Vozila", "Ceste", "Urbano", "Građevine", "Parkovi", "Priroda", "Jezera", "Mini igre"
};
int activeCategory = 0;

// Dimenzije panela
final int INV_W      = 700;
final int INV_H      = 440;
final int INV_ITEM_W = 120;
final int INV_ITEM_H = 105;
final int INV_COLS   = 5;
final int INV_PAD    = 12;
final int TAB_H      = 36;

void drawInventoryPanel() {
  fill(0, 0, 0, 50);
  noStroke();
  rect(0, 0, width, height);

  int px = width/2 - INV_W/2;
  int py = height/2 - INV_H/2 - 50;

  // Sjena + panel
  fill(0, 0, 0, 25);
  rect(px + 5, py + 6, INV_W, INV_H, 20);
  fill(235, 238, 242, 245);
  stroke(195, 205, 218, 160);  strokeWeight(1);
  rect(px, py, INV_W, INV_H, 18);  noStroke();

  // Naslov
  fill(55, 75, 110);
  textAlign(LEFT, CENTER);
  textSize(18);
  text("Inventar", px + 20, py + 24);

  fill(150, 165, 185);
  textAlign(RIGHT, CENTER);
  textSize(11);
  text("E — zatvori", px + INV_W - 16, py + 24);

  // Separator
  fill(175, 190, 210, 120);
  rect(px + 14, py + 46, INV_W - 28, 2, 1);

  // ---------- Tabovi ----------
  int tabY = py + 54;
  int tabX = px + 14;

  for (int i = 0; i < KATEGORIJE.length; i++) {
    textSize(11);
    int tw = (int) textWidth(KATEGORIJE[i]) + 24;
    boolean hover = (mouseX >= tabX && mouseX <= tabX + tw &&
                     mouseY >= tabY && mouseY <= tabY + TAB_H);
    boolean active = (i == activeCategory);

    if (active) {
      fill(65, 90, 135, 220);
      stroke(85, 115, 165, 180);
    } else if (hover) {
      fill(210, 218, 230, 200);
      stroke(185, 195, 215, 150);
    } else {
      fill(225, 230, 238, 160);
      stroke(200, 210, 222, 120);
    }
    strokeWeight(1);
    rect(tabX, tabY, tw, TAB_H, 8);  noStroke();

    fill(active ? color(240, 243, 248) : color(70, 85, 110));
    textAlign(CENTER, CENTER);
    textSize(11);
    text(KATEGORIJE[i], tabX + tw/2, tabY + TAB_H/2);

    tabX += tw + 6;
  }

  // ---------- Stavke ----------
  int contentY = tabY + TAB_H + 14;
  int contentH = py + INV_H - contentY - 40;

  ArrayList<Integer> filtered = new ArrayList<Integer>();
  for (int i = 0; i < allItems.size(); i++) {
    if (allItems.get(i).kategorija == activeCategory) filtered.add(i);
  }

  if (filtered.size() == 0) {
    fill(150, 165, 185);
    textAlign(CENTER, CENTER);
    textSize(13);
    text("Uskoro dolazi!", px + INV_W/2, contentY + contentH/2);
  }

  for (int fi = 0; fi < filtered.size(); fi++) {
    int itemIdx = filtered.get(fi);
    int col = fi % INV_COLS;
    int row = fi / INV_COLS;
    int ix = px + INV_PAD + col * (INV_ITEM_W + INV_PAD);
    int iy = contentY + INV_PAD + row * (INV_ITEM_H + INV_PAD) - inventoryScrollY;

    if (iy + INV_ITEM_H < contentY || iy > contentY + contentH) continue;

    boolean hover = (mouseX >= ix && mouseX <= ix + INV_ITEM_W &&
                     mouseY >= iy && mouseY <= iy + INV_ITEM_H);
    fill(hover ? color(215, 222, 235, 230) : color(245, 247, 250, 210));
    stroke(hover ? color(85, 115, 165, 160) : color(200, 210, 222, 130));
    strokeWeight(1);
    rect(ix, iy, INV_ITEM_W, INV_ITEM_H, 10);  noStroke();

    // Ikona zona
    fill(220, 228, 238, 130);
    rect(ix + 10, iy + 10, INV_ITEM_W - 20, INV_ITEM_H - 44, 6);

    InventoryItem item = allItems.get(itemIdx);

    // Naziv
    fill(55, 70, 95);
    textAlign(CENTER, CENTER);
    textSize(11);
    text(item.naziv, ix + INV_ITEM_W/2, iy + INV_ITEM_H - 24);

    // Cijena
    fill(170, 140, 55);
    textSize(10);
    text(item.cijena + " $", ix + INV_ITEM_W/2, iy + INV_ITEM_H - 10);
  }

  fill(155, 168, 185);
  textAlign(CENTER, BOTTOM);
  textSize(10);
  text("Povuci objekt u slot dolje  •  klikni slot za odabir", px + INV_W/2, py + INV_H - 8);
}

// -------------------------------------------------------
// INPUT
// -------------------------------------------------------
boolean clickedInventory(int mx, int my) {
  
  // Koš za brisanje postavljenog objekta
  if (selectedPlacedIndex >= 0) {
    int trashSize = 52;
    int trashX = hotbarX() + hotbarTotalW() + 18;
    int trashY = hotbarY() + SLOT_H/2 - trashSize/2;
    if (mx >= trashX && mx <= trashX + trashSize &&
        my >= trashY && my <= trashY + trashSize) {
      PlacedObject obj = placedObjects.get(selectedPlacedIndex);
      InventoryItem item = allItems.get(obj.typeIndex);
      coins += item.cijena;
      oslobodiGrid(obj.gridX, obj.gridZ, item.gridVelicina);
      placedObjects.remove(selectedPlacedIndex);
      selectedPlacedIndex = -1;
      previewRotation = 0;
      return true;
    }
  }
  
  if (inventoryOpen) {
    int hx = hotbarX();
    int hy = hotbarY();
    
    // Provjeri trash klik na hotbar slotovima (gore desno, 20px)
    for (int i = 0; i < HOTBAR_SLOTS; i++) {
      if (hotbarSlots[i] == -1) continue;
      int sx = hx + i * (SLOT_W + SLOT_PAD);
      int iconSize = 20;
      int iconX = sx + SLOT_W - iconSize - 4;
      int iconY = hy + 4;
      if (mx >= iconX && mx <= iconX + iconSize &&
          my >= iconY && my <= iconY + iconSize) {
        hotbarSlots[i] = -1;
        if (selectedObjectIndex == i) selectedObjectIndex = -1;
        return true;
      }
    }
    
    // Klik na kategoriju tab
    int tabY = (height/2 - INV_H/2 - 50) + 54;
    int tabX = (width/2 - INV_W/2) + 14;
    if (my >= tabY && my <= tabY + TAB_H) {
      int tx = tabX;
      for (int i = 0; i < KATEGORIJE.length; i++) {
        textSize(11);
        int tw = (int) textWidth(KATEGORIJE[i]) + 24;
        if (mx >= tx && mx <= tx + tw) {
          activeCategory = i;
          inventoryScrollY = 0;
          return true;
        }
        tx += tw + 6;
      }
    }
    
    // Provjeri drag s hotbar slota
    for (int i = 0; i < HOTBAR_SLOTS; i++) {
      if (hotbarSlots[i] == -1) continue;
      int sx = hx + i * (SLOT_W + SLOT_PAD);
      if (mx >= sx && mx <= sx + SLOT_W && my >= hy && my <= hy + SLOT_H) {
        draggingFromHotbar    = i;
        draggingFromInventory = -1;
        isDragging            = true;
        dragMouseX = mx;
        dragMouseY = my;
        return true;
      }
    }
    
    // Klik na inventory panel item
    int px = width/2 - INV_W/2;
    int py = height/2 - INV_H/2 - 50;
    int contentY = py + 54 + TAB_H + 14;
    
    ArrayList<Integer> filtered = new ArrayList<Integer>();
    for (int i = 0; i < allItems.size(); i++) {
      if (allItems.get(i).kategorija == activeCategory) filtered.add(i);
    }
    
    for (int fi = 0; fi < filtered.size(); fi++) {
      int itemIdx = filtered.get(fi);
      int col = fi % INV_COLS;
      int row = fi / INV_COLS;
      int ix = px + INV_PAD + col * (INV_ITEM_W + INV_PAD);
      int iy = contentY + INV_PAD + row * (INV_ITEM_H + INV_PAD) - inventoryScrollY;
      if (mx >= ix && mx <= ix + INV_ITEM_W && my >= iy && my <= iy + INV_ITEM_H) {
        draggingFromInventory = itemIdx;
        draggingFromHotbar    = -1;
        isDragging            = true;
        dragMouseX = mx;
        dragMouseY = my;
        return true;
      }
    }
    
    // Blokiraj sve ostale klikove dok je inventory otvoren
    return true;
  }
  
  // Hotbar klik (samo kad je inventory zatvoren)
  int hx = hotbarX();
  int hy = hotbarY();
  for (int i = 0; i < HOTBAR_SLOTS; i++) {
    int sx = hx + i * (SLOT_W + SLOT_PAD);
    if (mx >= sx && mx <= sx + SLOT_W && my >= hy && my <= hy + SLOT_H) {
      if (hotbarSlots[i] != -1) {
        selectedObjectIndex = (selectedObjectIndex == i) ? -1 : i;
      }
      return true;
    }
  }
  
  // Free hand gumb
  int fhSize = 52;
  int fhX = hotbarX() - fhSize - 18;
  int fhY = hotbarY() + SLOT_H/2 - fhSize/2;
  if (mx >= fhX && mx <= fhX + fhSize && my >= fhY && my <= fhY + fhSize) {
    selectedObjectIndex = -1;
    return true;
  }
  
  return false;
}

void inventoryMouseDragged(int mx, int my) {
  if (isDragging) { dragMouseX = mx; dragMouseY = my; }
}

void inventoryMouseReleased(int mx, int my) {
  if (!isDragging) return;

  // Pusti na hotbar slot
  int hx = hotbarX();
  int hy = hotbarY();
  for (int i = 0; i < HOTBAR_SLOTS; i++) {
    int sx = hx + i * (SLOT_W + SLOT_PAD);
    if (mx >= sx && mx <= sx + SLOT_W && my >= hy && my <= hy + SLOT_H) {
      if (draggingFromInventory != -1) {
        hotbarSlots[i] = draggingFromInventory;
      } else if (draggingFromHotbar != -1) {
        int tmp = hotbarSlots[i];
        hotbarSlots[i]               = hotbarSlots[draggingFromHotbar];
        hotbarSlots[draggingFromHotbar] = tmp;
      }
      break;
    }
  }

  isDragging            = false;
  draggingFromInventory = -1;
  draggingFromHotbar    = -1;
}

void inventoryScroll(float amount) {
  if (!inventoryOpen) return;
  inventoryScrollY += (int)(amount * 30);

  // Prebroj stavke u aktivnoj kategoriji
  int count = 0;
  for (int i = 0; i < allItems.size(); i++) {
    if (allItems.get(i).kategorija == activeCategory) count++;
  }
  int rows = (int) ceil(float(count) / INV_COLS);
  int contentH = INV_H - (54 + TAB_H + 14) - 40; // vidljivi prostor za stavke
  int totalH = rows * (INV_ITEM_H + INV_PAD);
  int maxScroll = max(0, totalH - contentH);
  inventoryScrollY = constrain(inventoryScrollY, 0, maxScroll);
}
