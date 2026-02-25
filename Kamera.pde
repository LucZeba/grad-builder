float camX = -80;
float camZ = 1000;
float camY = 940;
float camAngleH = radians(155);
float camAngleV = 0.1; // pozitivno = gleda prema dolje

float moveSpeed = 8;
float mouseSensitivity = 0.005;

boolean wPressed, sPressed, aPressed, dPressed = false;
boolean rightMouseHeld = false;
int prevMouseX, prevMouseY;

void setupCamera() {}

void applyCamera() {
  float dirX = sin(camAngleH);
  float dirZ = -cos(camAngleH);

  float lookX = camX + dirX * 100;
  float lookY = camY - camAngleV * 100;
  float lookZ = camZ - dirZ * 100;

  camera(camX, camY, camZ, lookX, lookY, lookZ, 0, -1, 0);
}

void updateCamera() {
  float fw_x = sin(camAngleH);
  float fw_z = cos(camAngleH);

  if (wPressed) { camX += fw_x * moveSpeed; camZ += fw_z * moveSpeed; }
  if (sPressed) { camX -= fw_x * moveSpeed; camZ -= fw_z * moveSpeed; }
  if (aPressed) { camX -= fw_z * moveSpeed; camZ += fw_x * moveSpeed; }
  if (dPressed) { camX += fw_z * moveSpeed; camZ -= fw_x * moveSpeed; }

  camX = constrain(camX, -4200, 4200);
  camZ = constrain(camZ, -4200, 4200);

  // U pješačkom modu fiksna visina
  if (buildMode == 1) {
    camY = 40;
  }
}

void mouseDraggedKamera() {
  if (rightMouseHeld) {
    float dx = mouseX - prevMouseX;
    float dy = mouseY - prevMouseY;
    camAngleH += dx * mouseSensitivity;
    camAngleV += dy * mouseSensitivity * 0.5;
    camAngleV = constrain(camAngleV, -1.5, 1.5);
    prevMouseX = mouseX;
    prevMouseY = mouseY;
  }
}

void mouseReleasedKamera() {
  if (mouseButton == RIGHT) rightMouseHeld = false;
}

void keyPressedKamera() {
  if (key == 'w' || key == 'W') wPressed = true;
  if (key == 's' || key == 'S') sPressed = true;
  if (key == 'a' || key == 'A') aPressed = true;
  if (key == 'd' || key == 'D') dPressed = true;
}

void keyReleasedKamera() {
  if (key == 'w' || key == 'W') wPressed = false;
  if (key == 's' || key == 'S') sPressed = false;
  if (key == 'a' || key == 'A') aPressed = false;
  if (key == 'd' || key == 'D') dPressed = false;
}
