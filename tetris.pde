PImage backgroundImg2;

int COLS = 10;
int ROWS = 20;
int SIZE = 30;
int gridX, gridY;

int[][] grid = new int[ROWS][COLS];

Tetromino current;
Tetromino nextPiece;
int coins3 = 0;
int dropInterval;
int lastDropTime;
boolean gameOver = false;

color[] colors;


//klasa za objekt koji pada
class Tetromino {
  int x = 4, y = 0;
  int type;
  int[][] shape;

  Tetromino(int t) {
    type = t;
    shape = getShape(type);
  }

  void show() {
    fill(colors[type + 1]);
    stroke(30);
    strokeWeight(2);
    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) {
          rect(gridX + (x + c) * SIZE, gridY + (y + r) * SIZE, SIZE - 1, SIZE - 1, 6);
        }
      }
    }
  }

  int width() {
    return shape[0].length;
  }

  int height() {
    return shape.length;
  }

  int[][] rotated() {
    int h = shape.length;
    int w = shape[0].length;
    int[][] rotatedShape = new int[w][h];
    for (int r = 0; r < h; r++) {
      for (int c = 0; c < w; c++) {
        rotatedShape[c][h - 1 - r] = shape[r][c];
      }
    }
    return rotatedShape;
  }
}

void setupTetris() {
  // Samo prvi put
  if (colors == null) {
    backgroundImg2 = loadImage("mineImg.png");

    if (backgroundImg2 == null) {
      println("ERROR: mineImg.png not found!");
    } else {
      backgroundImg2.resize(width, height);
    }

    colors = new color[] {
      color(0),
      color(0, 240, 240),
      color(0, 0, 240),
      color(240, 160, 0),
      color(240, 240, 0),
      color(0, 240, 0),
      color(160, 0, 240),
      color(240, 0, 0)
    };

    gridX = width / 2 - COLS * SIZE / 2;
    gridY = height / 2 - ROWS * SIZE / 2;
  }

  // Reset game state each time tetris starts
  grid = new int[ROWS][COLS];
  coins3 = 0;
  gameOver = false;
  nextPiece = new Tetromino(int(random(7)));
  spawnPiece();
  dropInterval = 800;
  lastDropTime = millis();
}

void drawTetris() {
  // Reset graphics context from 3D to 2D
  resetMatrix();
  camera();
  perspective();
  
  if (backgroundImg2 != null) {
    image(backgroundImg2, 0, 0);
  } else {
    background(30);
  }

  drawGrid();
  drawInfo();

  if (!gameOver) {
    if (millis() - lastDropTime > dropInterval) {
      if (!moveDown()) {
        lockPiece();
      }
      lastDropTime = millis();
    }
    current.show();
    
  } else {
    gameOver2();
  }
}

void drawGrid() {
  fill(120, 200);
  noStroke();
  rect(gridX - 8, gridY - 8, COLS * SIZE + 16, ROWS * SIZE + 16, 18);

  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      int value = grid[r][c];
      if (value != 0) {
        fill(colors[value]);
      } else {
        fill(165, 179, 184);
      }
      stroke(120);
      strokeWeight(1);
      rect(gridX + c * SIZE, gridY + r * SIZE, SIZE - 1, SIZE - 1, 6);
    }
  }
}

void drawInfo() {
  fill(255);
  textAlign(LEFT, TOP);

  textSize(18);
  text("Coins: " + coins3, 40, 100);

  text("Sljedeća:", 40, 230);
  drawNextPiece();
  
  fill(255);
  textSize(14);
  text("Upute:", 40, 360);
  text("Lijevo: ←", 40, 380);
  text("Desno:  →", 40, 400);
  text("Rotiranje: ↑", 40, 420);
  text("Dolje: ↓", 40, 440);
  text("Trenutno spuštanje: Space", 40, 460);

}

void drawNextPiece() {
  int smallSize = SIZE / 2;
  int offsetX = 40;
  int offsetY = 270;
  int[][] shape = nextPiece.shape;
  for (int r = 0; r < shape.length; r++) {
    for (int c = 0; c < shape[r].length; c++) {
      if (shape[r][c] == 1) {
        fill(colors[nextPiece.type + 1]);
      } else {
        fill(100, 120, 130);
      }
      noStroke();
      rect(offsetX + c * smallSize, offsetY + r * smallSize, smallSize - 1, smallSize - 1, 4);
    }
  }
}

void keyPressed3() {
  if (gameOver) {
    // ENTER za povratak u glavnu igru
    if (keyCode == ENTER) {
      coins += coins3;
      tetrisActive = false;
      resetCameraMovementKeys();
      loop();
      return;
    }
    return;
  }

  if (keyCode == LEFT) {
    moveCurrent(-1, 0);
  } else if (keyCode == RIGHT) {
    moveCurrent(1, 0);
  } else if (keyCode == DOWN) {
    if (!moveDown()) {
      lockPiece();
    }
    lastDropTime = millis();
  } else if (keyCode == UP) {
    rotateCurrent();
  } else if (key == ' ') {
    while (moveDown()) {}
    lockPiece();
    lastDropTime = millis();
  }
}

//pomicanje
void moveCurrent(int dx, int dy) {
  if (!collides(current.x + dx, current.y + dy, current.shape)) {
    current.x += dx;
    current.y += dy;
  }
}

//provjera može li se spustiti prema dolje
boolean moveDown() {
  if (!collides(current.x, current.y + 1, current.shape)) {
    current.y++;
    return true;
  }
  return false;
}

//rotiranje oblika
void rotateCurrent() {
  int[][] rotated = current.rotated();
  if (!collides(current.x, current.y, rotated)) {
    current.shape = rotated;
  }
}

//provjera može li se pomaknuti, preklapa li se
boolean collides(int x, int y, int[][] shape) {
  for (int r = 0; r < shape.length; r++) {
    for (int c = 0; c < shape[r].length; c++) {
      if (shape[r][c] == 1) {
        int gridXPos = x + c;
        int gridYPos = y + r;
        if (gridXPos < 0 || gridXPos >= COLS || gridYPos >= ROWS) {
          return true;
        }
        if (gridYPos >= 0 && grid[gridYPos][gridXPos] != 0) {
          return true;
        }
      }
    }
  }
  return false;
}


//spremanje na mjesto
void lockPiece() {
  for (int r = 0; r < current.shape.length; r++) {
    for (int c = 0; c < current.shape[r].length; c++) {
      if (current.shape[r][c] == 1) {
        int gridXPos = current.x + c;
        int gridYPos = current.y + r;
        if (gridYPos >= 0 && gridYPos < ROWS && gridXPos >= 0 && gridXPos < COLS) {
          grid[gridYPos][gridXPos] = current.type + 1;
        }
      }
    }
  }
  clearLines();
  if (!gameOver) {
    spawnPiece();
  }
}

void clearLines() {
  int removed = 0; //više redova odjednom kad se briše da dobije novca više
  int[][] newGrid = new int[ROWS][COLS];
  int writeRow = ROWS - 1;

  for (int r = ROWS - 1; r >= 0; r--) {
    boolean full = true;
    for (int c = 0; c < COLS; c++) {
      if (grid[r][c] == 0) {
        full = false;
        break;
      }
    }
    if (!full) {
      for (int c = 0; c < COLS; c++) {
        newGrid[writeRow][c] = grid[r][c];
      }
      writeRow--;
    } else {
      removed++;
    }
  }

  grid = newGrid;

  if (removed > 0) {
    coins3 += 100 * removed * removed;
    dropInterval = max(200, dropInterval - 15 * removed);
  }
}


//novi oblik 
void spawnPiece() {
  current = nextPiece;
  current.x = COLS / 2 - current.width() / 2;
  current.y = 0;
  nextPiece = new Tetromino(int(random(7)));
  if (collides(current.x, current.y, current.shape)) {

    int r = 1; // samo drugi red oblika
  
    if (r < current.shape.length) {
      for (int c = 0; c < current.shape[r].length; c++) {
        if (current.shape[r][c] == 1) {
  
          int gridXPos = current.x + c;
          int gridYPos = 0; // uvijek najgornji red
  
          if (gridXPos >= 0 && gridXPos < COLS) {
            grid[gridYPos][gridXPos] = current.type + 1;
          }
        }
      }
    }
    
     gameOver = true;
  }
}

int[][] getShape(int t) {
  if (t == 0)
    return new int[][]{{1, 1, 1, 1}}; //1x4
  if (t == 1)
    return new int[][]{{1, 1}, {1, 1}}; //2x2
  if (t == 2)
    return new int[][]{{0, 1, 0}, {1, 1, 1}}; //T
  if (t == 3)
    return new int[][]{{1, 0, 0}, {1, 1, 1}}; //L
  if (t == 4)
    return new int[][]{{0, 0, 1}, {1, 1, 1}}; //L
  if (t == 5)
    return new int[][]{{1, 1, 0}, {0, 1, 1}}; //Z
  return new int[][]{{0, 1, 1}, {1, 1, 0}}; //Z
}

void gameOver2() {
  // Draw translucent overlay
  fill(0, 0, 0, 160);
  rect(0, 0, width, height);

  fill(255, 0, 0);
  textSize(60);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/2 - 40);

  fill(255);
  textSize(20);
  text("Pritisni ENTER za povratak.", width/2, height/2 + 30);

  resetCameraMovementKeys();
}
