// ============================================================
// KLASA za jedan postavljeni objekt u gradu
// ============================================================

HashMap<String, PShape> modelCache = new HashMap<String, PShape>();
HashMap<String, PShape> previewCache = new HashMap<String, PShape>();

// ============================================================
// MODELI (preview i postavljeni)
// ============================================================

void setupModele() {
  modelCache.put("Lowpoly_tree_sample.obj", loadShape("Lowpoly_tree_sample.obj"));
  modelCache.put("Car.obj", loadShape("Car.obj"));
  modelCache.put("Cyprys_House.obj", loadShape("Cyprys_House.obj"));
  modelCache.put("CartoonTree.obj", loadShape("CartoonTree.obj"));
  modelCache.put("Swing.obj", loadShape("Swing.obj"));
  modelCache.put("bench.obj", loadShape("bench.obj"));
  modelCache.put("building_04.obj", loadShape("building_04.obj"));
  modelCache.put("Bambo_House.obj", loadShape("Bambo_House.obj"));
  
  // Preview modeli — isti fileovi ali disableStyle
  for (String key : modelCache.keySet()) {
    PShape preview = loadShape(key);
    preview.disableStyle();
    previewCache.put(key, preview);
  }
}

PShape getPreviewModel(String objFile) {
  return previewCache.get(objFile);
}

PShape getModel(String objFile) {
  return modelCache.get(objFile);
}

// ============================================================
// KLASA ZA OBJEKTE
// ============================================================

class PlacedObject {
  int typeIndex;
  float x, z;
  float rotation;
  int gridX, gridZ;

  PlacedObject(int typeIndex, float x, float z) {
    this.typeIndex = typeIndex;
    this.x = x;
    this.z = z;
    this.rotation = 0;
    this.gridX = 0;
    this.gridZ = 0;
  }

  void draw() {
    if (typeIndex < 0 || typeIndex >= allItems.size()) return; // zaštita
    InventoryItem item = allItems.get(typeIndex);
    PShape model = getModel(item.objFile);
    if (model == null) return;

    pushMatrix();
    translate(x, 0, z);
    rotateY(rotation);
    scale(item.skala);
    translate(0, -item.yOffset, 0);
    shape(model);
    popMatrix();
  }
}
