// ============================================================
// GRADNJA - postavljanje objekata klikom na tlo
// ============================================================
import java.util.HashSet;

HashSet<String> zauzetiGridovi = new HashSet<String>();
ArrayList<PlacedObject> placedObjects = new ArrayList<PlacedObject>();
int selectedObjectIndex = -1;
String debugGrid = "";

int GRID_SIZE = 60; // veličina jednog kvadratića u Processing jedinicama

int lastGridX = 0;
int lastGridZ = 0;
boolean lastGridValid = false;

float previewRotation = 0;
boolean placingDrag = false;
int placingStartX = 0;
float placingStartRotation = 0;

// -------------------------------------------------------
// Grid pomoćne funkcije
// -------------------------------------------------------

String gridKey(int gx, int gz) {
  return gx + "_" + gz;
}

boolean jeslobodno(int gx, int gz, int size) {
  for (int dx = 0; dx < size; dx++) {
    for (int dz = 0; dz < size; dz++) {
      if (zauzetiGridovi.contains(gridKey(gx + dx, gz + dz))) return false;
    }
  }
  return true;
}

void zauzimiGrid(int gx, int gz, int size) {
  for (int dx = 0; dx < size; dx++) {
    for (int dz = 0; dz < size; dz++) {
      zauzetiGridovi.add(gridKey(gx + dx, gz + dz));
    }
  }
}

// Koji grid kvadratić je miš trenutno iznad
int[] getGridUnderMouse() {
  float groundY = 0;
  
  PMatrix3D mv = new PMatrix3D();
  getMatrix(mv);
  
  PMatrix3D proj = new PMatrix3D();
  // Ručno postavi projekcijsku matricu
  float fov = PI / 3.0;
  float aspect = float(width) / float(height);
  float near = 1;
  float far = 10000;
  float f = 1.0 / tan(fov / 2.0);
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
  float[] far3   = mult4(mvp, ndcX, ndcY,  1, 1);
  
  if (near3 == null || far3 == null) return null;
  
  float dy = far3[1] - near3[1];
  if (abs(dy) < 0.0001) return null;
  
  float t = (groundY - near3[1]) / dy;
  if (t < 0 || t > 1) return null;
  
  float worldX = near3[0] + t * (far3[0] - near3[0]);
  float worldZ = near3[2] + t * (far3[2] - near3[2]);
  
  int gx = (int) Math.floor(worldX / GRID_SIZE);
  int gz = (int) Math.floor(worldZ / GRID_SIZE);
  return new int[]{gx, gz};
}

float[] getWorldUnderMouse() {
  float groundY = 0;
  
  PMatrix3D mv = new PMatrix3D();
  getMatrix(mv);
  
  PMatrix3D proj = new PMatrix3D();
  float fov = PI / 3.0;
  float aspect = float(width) / float(height);
  float near = 1;
  float far = 10000;
  float f = 1.0 / tan(fov / 2.0);
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
  float[] far3   = mult4(mvp, ndcX, ndcY,  1, 1);
  
  if (near3 == null || far3 == null) return null;
  
  float dy = far3[1] - near3[1];
  if (abs(dy) < 0.0001) return null;
  
  float t = (groundY - near3[1]) / dy;
  if (t < 0 || t > 1) return null;
  
  float worldX = near3[0] + t * (far3[0] - near3[0]);
  float worldZ = near3[2] + t * (far3[2] - near3[2]);
  
  return new float[]{worldX, worldZ};
}

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

InventoryItem getSelectedItem() {
  if (selectedPlacedIndex >= 0) {
    return allItems.get(placedObjects.get(selectedPlacedIndex).typeIndex);
  }
  if (selectedObjectIndex >= 0) {
    int idx = hotbarSlots[selectedObjectIndex];
    if (idx >= 0 && idx < allItems.size()) return allItems.get(idx);
  }
  return null;
}

// -------------------------------------------------------
// Crtanje
// -------------------------------------------------------

void drawGradnja() {
  updateCamera();
  applyCamera();
  drawSun(400, 1800, -2000);
  drawGround();
  drawPlacedObjects();

  if (!inventoryOpen) {
    if (!placingDrag) {
      int[] grid = getGridUnderMouse();
      if (grid != null) {
        debugGrid = "Grid: " + grid[0] + ", " + grid[1];
        lastGridX = grid[0];
        lastGridZ = grid[1];
        lastGridValid = true;
      } else {
        debugGrid = "Grid: null";
        lastGridValid = false;
      }
    }

    // Rotacija prema mišu dok dragamo — kamera je već postavljena
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

void drawPlacedObjects() {
  for (PlacedObject obj : placedObjects) {
    obj.draw();
  }
}

void drawPlacementPreview() {
  if (!lastGridValid) return;

  InventoryItem item = null;

  if (selectedPlacedIndex >= 0) {
    PlacedObject obj = placedObjects.get(selectedPlacedIndex);
    item = allItems.get(obj.typeIndex);
  } else if (selectedObjectIndex >= 0) {
    int allItemsIndex = hotbarSlots[selectedObjectIndex];
    if (allItemsIndex < 0 || allItemsIndex >= allItems.size()) return;
    item = allItems.get(allItemsIndex);
  } else {
    return;
  }

  boolean slobodno = jeslobodno(lastGridX, lastGridZ, item.gridVelicina);

  // Grid osjenčanje
  noStroke();
  fill(slobodno ? color(0, 255, 0, 100) : color(255, 0, 0, 100));
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

  // Model preview
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

// -------------------------------------------------------
// Postavljanje klikom
// -------------------------------------------------------

int selectedPlacedIndex = -1;

void mouseGradnja() {

  // Ako imamo podignut objekt — postavi ga
  if (selectedPlacedIndex >= 0) {
    if (!lastGridValid) return;

    int gx = lastGridX;
    int gz = lastGridZ;
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

  // Provjeri klik na postavljeni objekt (samo u free hand modu)
  if (selectedObjectIndex < 0) {
    if (!lastGridValid) return;
    for (int i = 0; i < placedObjects.size(); i++) {
      PlacedObject obj = placedObjects.get(i);
      InventoryItem item = allItems.get(obj.typeIndex);
      if (lastGridX >= obj.gridX && lastGridX < obj.gridX + item.gridVelicina &&
          lastGridZ >= obj.gridZ && lastGridZ < obj.gridZ + item.gridVelicina) {
        selectedPlacedIndex = i;
        previewRotation = obj.rotation; // nastavi s trenutnom rotacijom
        return;
      }
    }
    return;
  }

  // Normalno postavljanje novog objekta
  if (!lastGridValid) return;

  int gx = lastGridX;
  int gz = lastGridZ;
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

void oslobodiGrid(int gx, int gz, int size) {
  for (int dx = 0; dx < size; dx++) {
    for (int dz = 0; dz < size; dz++) {
      zauzetiGridovi.remove(gridKey(gx + dx, gz + dz));
    }
  }
}
