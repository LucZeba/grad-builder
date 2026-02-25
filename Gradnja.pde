// ============================================================
// GRADNJA - grid sustav, postavljanje i premještanje objekata
// ============================================================
import java.util.HashSet;

// --- Stanje gradnje ---
HashSet<String> zauzetiGridovi = new HashSet<String>();
ArrayList<PlacedObject> placedObjects = new ArrayList<PlacedObject>();
int selectedObjectIndex = -1;   // koji hotbar slot je odabran (-1 = free hand)
int selectedPlacedIndex = -1;   // koji postavljeni objekt je podignut (-1 = nijedan)

int GRID_SIZE = 60;

int lastGridX = 0;
int lastGridZ = 0;
boolean lastGridValid = false;

float previewRotation = 0;
boolean placingDrag = false;

// ============================================================
// GRID POMOĆNE FUNKCIJE
// ============================================================

// Ključ za HashSet — "gx_gz"
String gridKey(int gx, int gz) {
  return gx + "_" + gz;
}

// Provjeri je li blok size×size slobodan od pozicije (gx, gz)
boolean jeslobodno(int gx, int gz, int size) {
  for (int dx = 0; dx < size; dx++)
    for (int dz = 0; dz < size; dz++)
      if (zauzetiGridovi.contains(gridKey(gx + dx, gz + dz))) return false;
  return true;
}

// Zauzmi blok size×size
void zauzimiGrid(int gx, int gz, int size) {
  for (int dx = 0; dx < size; dx++)
    for (int dz = 0; dz < size; dz++)
      zauzetiGridovi.add(gridKey(gx + dx, gz + dz));
}

// Oslobodi blok size×size
void oslobodiGrid(int gx, int gz, int size) {
  for (int dx = 0; dx < size; dx++)
    for (int dz = 0; dz < size; dz++)
      zauzetiGridovi.remove(gridKey(gx + dx, gz + dz));
}

// ============================================================
// RAYCASTING — miš → world pozicija na tlu (y=0)
// ============================================================

// Zajednička logika raycastinga — vraća {worldX, worldZ} ili null
float[] raycastGround() {
  PMatrix3D mv = new PMatrix3D();
  getMatrix(mv);

  float fov = PI / 3.0;
  float aspect = float(width) / float(height);
  float near = 1, far = 10000;
  float f = 1.0 / tan(fov / 2.0);

  PMatrix3D proj = new PMatrix3D();
  proj.set(
    f/aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (far+near)/(near-far), (2*far*near)/(near-far),
    0, 0, -1, 0
  );

  PMatrix3D mvp = new PMatrix3D();
  mvp.set(proj);
  mvp.apply(mv);
  mvp.invert();

  float ndcX = (2.0 * mouseX / width) - 1.0;
  float ndcY = (2.0 * mouseY / height) - 1.0;

  float[] near3 = mult4(mvp, ndcX, ndcY, -1, 1);
  float[] far3  = mult4(mvp, ndcX, ndcY,  1, 1);
  if (near3 == null || far3 == null) return null;

  float dy = far3[1] - near3[1];
  if (abs(dy) < 0.0001) return null;

  float t = -near3[1] / dy;  // groundY = 0
  if (t < 0 || t > 1) return null;

  return new float[]{
    near3[0] + t * (far3[0] - near3[0]),
    near3[2] + t * (far3[2] - near3[2])
  };
}

// Vraća grid koordinate pod mišem (snap na grid)
int[] getGridUnderMouse() {
  float[] world = raycastGround();
  if (world == null) return null;
  return new int[]{
    (int) Math.floor(world[0] / GRID_SIZE),
    (int) Math.floor(world[1] / GRID_SIZE)
  };
}

// Vraća precizne world koordinate pod mišem (za glatku rotaciju)
float[] getWorldUnderMouse() {
  return raycastGround();
}

// Množenje matrice 4×4 s vektorom — perspektivna divizija
float[] mult4(PMatrix3D m, float x, float y, float z, float w) {
  float[] out = new float[4];
  out[0] = m.m00*x + m.m01*y + m.m02*z + m.m03*w;
  out[1] = m.m10*x + m.m11*y + m.m12*z + m.m13*w;
  out[2] = m.m20*x + m.m21*y + m.m22*z + m.m23*w;
  out[3] = m.m30*x + m.m31*y + m.m32*z + m.m33*w;
  if (out[3] == 0) return null;
  out[0] /= out[3];
  out[1] /= out[3];
  out[2] /= out[3];
  return out;
}

// Koji item je trenutno odabran (iz hotbara ili podignut s tla)
InventoryItem getSelectedItem() {
  if (selectedPlacedIndex >= 0)
    return allItems.get(placedObjects.get(selectedPlacedIndex).typeIndex);
  if (selectedObjectIndex >= 0) {
    int idx = hotbarSlots[selectedObjectIndex];
    if (idx >= 0 && idx < allItems.size()) return allItems.get(idx);
  }
  return null;
}

// ============================================================
// CRTANJE GRADNJE — poziva se iz draw() kad je gameState == 1
// ============================================================

void drawGradnja() {
  updateCamera();
  applyCamera();
  drawSun(400, 7000, -10500);
  drawGround();
  drawPlacedObjects();

  if (!inventoryOpen) {
    // Ažuriraj grid pod mišem (samo kad ne dragamo — pozicija se fiksira na klik)
    if (!placingDrag) {
      int[] grid = getGridUnderMouse();
      if (grid != null) {
        lastGridX = grid[0];
        lastGridZ = grid[1];
        lastGridValid = true;
      } else {
        lastGridValid = false;
      }
    }

    // Rotacija prema mišu dok dragamo — atan2 u world-space
    if (placingDrag && lastGridValid) {
      float[] worldMouse = getWorldUnderMouse();
      if (worldMouse != null) {
        InventoryItem item = getSelectedItem();
        if (item != null) {
          float centerX = lastGridX * GRID_SIZE + (item.gridVelicina * GRID_SIZE) / 2.0;
          float centerZ = lastGridZ * GRID_SIZE + (item.gridVelicina * GRID_SIZE) / 2.0;
          previewRotation = atan2(worldMouse[0] - centerX, worldMouse[1] - centerZ);
        }
      }
    }

    drawPlacementPreview();
  }

  drawHUD();
  drawInventoryHUD();
}

// Crta sve postavljene objekte
void drawPlacedObjects() {
  for (PlacedObject obj : placedObjects) obj.draw();
}

// ============================================================
// PREVIEW — prikaz objekta prije postavljanja
// ============================================================

void drawPlacementPreview() {
  // Žuti grid na originalnoj poziciji podignutog objekta
  if (selectedPlacedIndex >= 0) {
    PlacedObject obj = placedObjects.get(selectedPlacedIndex);
    InventoryItem selItem = allItems.get(obj.typeIndex);
    noStroke();
    fill(255, 220, 0, 50);
    for (int dx = 0; dx < selItem.gridVelicina; dx++) {
      for (int dz = 0; dz < selItem.gridVelicina; dz++) {
        float px = (obj.gridX + dx) * GRID_SIZE + GRID_SIZE / 2.0;
        float pz = (obj.gridZ + dz) * GRID_SIZE + GRID_SIZE / 2.0;
        pushMatrix();
        translate(px, 2, pz);
        box(GRID_SIZE - 2, 3, GRID_SIZE - 2);
        popMatrix();
      }
    }
  }

  if (!lastGridValid) return;

  // Odredi koji item se previewira
  InventoryItem item = null;
  if (selectedPlacedIndex >= 0) {
    item = allItems.get(placedObjects.get(selectedPlacedIndex).typeIndex);
  } else if (selectedObjectIndex >= 0) {
    int allItemsIndex = hotbarSlots[selectedObjectIndex];
    if (allItemsIndex < 0 || allItemsIndex >= allItems.size()) return;
    item = allItems.get(allItemsIndex);
  } else {
    return;
  }

  // Zeleno/crveno osjenčanje — slobodno ili zauzeto
  boolean slobodno = jeslobodno(lastGridX, lastGridZ, item.gridVelicina);
  noStroke();
  fill(slobodno ? color(0, 255, 0, 50) : color(255, 0, 0, 50));
  for (int dx = 0; dx < item.gridVelicina; dx++) {
    for (int dz = 0; dz < item.gridVelicina; dz++) {
      float px = (lastGridX + dx) * GRID_SIZE + GRID_SIZE / 2.0;
      float pz = (lastGridZ + dz) * GRID_SIZE + GRID_SIZE / 2.0;
      pushMatrix();
      translate(px, 2, pz);
      box(GRID_SIZE - 2, 3, GRID_SIZE - 2);
      popMatrix();
    }
  }

  // Prozirni model na ciljanoj poziciji
  PShape model = getPreviewModel(item.objFile);
  if (model == null) return;

  float previewX = lastGridX * GRID_SIZE + (item.gridVelicina * GRID_SIZE) / 2.0;
  float previewZ = lastGridZ * GRID_SIZE + (item.gridVelicina * GRID_SIZE) / 2.0;

  pushMatrix();
  translate(previewX, 0, previewZ);
  rotateY(previewRotation);
  scale(item.skala);
  translate(0, -item.yOffset, 0);
  fill(180, 210, 255, 130);
  stroke(100, 160, 255, 160);
  strokeWeight(0.5);
  shape(model);
  noStroke();
  popMatrix();
}

// ============================================================
// POSTAVLJANJE / PREMJEŠTANJE OBJEKATA — poziva se na klik
// ============================================================

void mouseGradnja() {
  // 1) Podignut objekt — postavi ga na novu poziciju
  if (selectedPlacedIndex >= 0) {
    if (!lastGridValid) return;
    int gx = lastGridX, gz = lastGridZ;
    PlacedObject obj = placedObjects.get(selectedPlacedIndex);
    InventoryItem item = allItems.get(obj.typeIndex);

    if (gx * GRID_SIZE < -4000 || (gx + item.gridVelicina) * GRID_SIZE > 4000) return;
    if (gz * GRID_SIZE < -4000 || (gz + item.gridVelicina) * GRID_SIZE > 4000) return;
    if (!jeslobodno(gx, gz, item.gridVelicina)) return;

    oslobodiGrid(obj.gridX, obj.gridZ, item.gridVelicina);
    zauzimiGrid(gx, gz, item.gridVelicina);
    obj.x = gx * GRID_SIZE + (item.gridVelicina * GRID_SIZE) / 2.0;
    obj.z = gz * GRID_SIZE + (item.gridVelicina * GRID_SIZE) / 2.0;
    obj.gridX = gx;
    obj.gridZ = gz;
    obj.rotation = previewRotation;
    previewRotation = 0;
    selectedPlacedIndex = -1;
    return;
  }

  // 2) Free hand mod — klikni na postojeći objekt da ga podigneš
  if (selectedObjectIndex < 0) {
    if (!lastGridValid) return;
    for (int i = 0; i < placedObjects.size(); i++) {
      PlacedObject obj = placedObjects.get(i);
      InventoryItem item = allItems.get(obj.typeIndex);
      if (lastGridX >= obj.gridX && lastGridX < obj.gridX + item.gridVelicina &&
          lastGridZ >= obj.gridZ && lastGridZ < obj.gridZ + item.gridVelicina) {
        selectedPlacedIndex = i;
        previewRotation = obj.rotation;
        return;
      }
    }
    return;
  }

  // 3) Normalno postavljanje novog objekta iz hotbara
  if (!lastGridValid) return;
  int gx = lastGridX, gz = lastGridZ;
  int allItemsIndex = hotbarSlots[selectedObjectIndex];
  if (allItemsIndex < 0 || allItemsIndex >= allItems.size()) return;

  InventoryItem item = allItems.get(allItemsIndex);
  if (gx * GRID_SIZE < -4000 || (gx + item.gridVelicina) * GRID_SIZE > 4000) return;
  if (gz * GRID_SIZE < -4000 || (gz + item.gridVelicina) * GRID_SIZE > 4000) return;
  if (!jeslobodno(gx, gz, item.gridVelicina)) return;

  if (coins >= item.cijena) {
    coins -= item.cijena;
    zauzimiGrid(gx, gz, item.gridVelicina);
    float worldX = gx * GRID_SIZE + (item.gridVelicina * GRID_SIZE) / 2.0;
    float worldZ = gz * GRID_SIZE + (item.gridVelicina * GRID_SIZE) / 2.0;
    PlacedObject newObj = new PlacedObject(allItemsIndex, worldX, worldZ);
    newObj.gridX = gx;
    newObj.gridZ = gz;
    newObj.rotation = previewRotation;
    previewRotation = 0;
    placedObjects.add(newObj);
  }
}
