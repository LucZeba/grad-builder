PImage backgroundImg3;

int cols = 10;
int rows = 10;
Brick[][] bricks;

float paddleW = 100;
float paddleH = 14;
float paddleX;
float paddleY;

float ballX;
float ballY;
float ballR = 10; //radijus lopte
float ballDX; //brzina
float ballDY;


int coins4;
boolean gameOver4;
boolean gameWin;

void setupArkanoid() {
  size(1200, 800);
  backgroundImg3 = loadImage("bolnicaImg.png");
  backgroundImg3.resize(width, height);
  resetGame();
}

void drawArkanoid() {
  noLights();
  image(backgroundImg3, 0, 0);
  
  fill(240);
  textSize(16);
  textAlign(LEFT, CENTER);
  text("Coins: " + coins4, 20, 18);
  drawBricks();
  drawPaddle();
  drawBall();

  if (!gameOver4 && !gameWin) {
    updateBall();
    checkCollisions();
  } else {
    drawEndMessage();
  }
  
  fill(0);
  textSize(30);
  textAlign(LEFT);
  text("Coins: " + coins4, 20, 40);
  textSize(14);
  text("Upute: pomičite miš lijevo/desno", 20, 80);
}

void resetGame() {
  paddleX = width / 2 - paddleW / 2;
  paddleY = height - 40;
  ballX = width / 2;
  ballY = height - 60;
  ballDX = 4.5;
  ballDY = -4.5;
  coins4 = 0;
  gameOver4 = false;
  gameWin = false;
  initBricks();
}

void initBricks() {
  bricks = new Brick[rows][cols];
  float brickW = (width - 80) / cols;
  float brickH = 20;
  for (int row = 0; row < rows; row++) {
    color fillColor = color(random(80, 255), random(80, 255), random(80, 255));
    for (int col = 0; col < cols; col++) {
      float x = 40 + col * brickW;
      float y = 40 + row * (brickH + 8);
      bricks[row][col] = new Brick(x, y, brickW - 6, brickH, fillColor);
    }
  }
}

void drawBricks() {
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      bricks[row][col].show();
    }
  }
}

void drawPaddle() {
  paddleX = constrain(mouseX - paddleW / 2, 20, width - 20 - paddleW);
  fill(0);
  noStroke();
  rect(paddleX, paddleY, paddleW, paddleH, 8);
}

void drawBall() {
  fill(255, 0, 0);
  noStroke();
  ellipse(ballX, ballY, ballR * 2, ballR * 2);
}

void updateBall() {
  ballX += ballDX;
  ballY += ballDY;
  
  //lijevo/desno prozor - odbija se
  if (ballX - ballR <= 0 || ballX + ballR >= width) {
    ballDX *= -1;
    ballX = constrain(ballX, ballR, width - ballR);
  }
  //odbije se gore o prozor
  if (ballY - ballR <= 0) {
    ballDY *= -1;
    ballY = ballR;
  }
  if (ballY - ballR > height) {
    gameOver4 = true;
  }
}

void checkCollisions() {
  if (ballY + ballR >= paddleY && ballY + ballR <= paddleY + paddleH && ballX >= paddleX && ballX <= paddleX + paddleW && ballDY > 0) {
    float hitPos = (ballX - paddleX) / paddleW - 0.5;
    ballDY *= -1;
    ballDX += hitPos * 2;
    ballDX = constrain(ballDX, -7, 7);
    ballY = paddleY - ballR;
  }

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      Brick brick = bricks[row][col];
      if (brick.active && brick.hits(ballX, ballY, ballR)) {
        brick.active = false;
        coins4 += 10;
        if (abs(ballX - brick.x) < brick.w / 2 && (ballY < brick.y || ballY > brick.y + brick.h)) {
          ballDY *= -1;
        } else {
          ballDX *= -1;
        }
        if (allBricksCleared()) {
          gameWin = true;
        }
      }
    }
  }
}

boolean allBricksCleared() {
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      if (bricks[row][col].active) {
        return false;
      }
    }
  }
  return true;
}

void resetBall() {
  ballX = width / 2;
  ballY = height - 60;
  ballDX = 4.5 * (random(1) > 0.5 ? 1 : -1);
  ballDY = -4.5;
}

void drawEndMessage() {
  textAlign(CENTER, CENTER);
  fill(255, 0, 0);
  textSize(60);
  if (gameWin) {
    text("Pobijedili ste!", width / 2, height / 2 - 20);
  } else {
    text("GAME OVER", width/2, height/2 - 40);
  }
  
  fill(0);
  textSize(20);
  text("Pritisnite ENTER za povratak", width/2, height/2 + 30);
}

void keyPressed4() {
  if (gameOver4) {
    // Enter za nazad u igricu
    if (keyCode == ENTER) {
      coins += coins4;
      arkanoidActive = false;
      resetCameraMovementKeys();
      objects.clear();
      loop();
    }
    return;
  }
}

class Brick {
  float x, y, w, h;
  color fillColor;
  boolean active;

  Brick(float x_, float y_, float w_, float h_, color fillColor_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    fillColor = fillColor_;
    active = true;
  }

  void show() {
    if (!active) return;
    stroke(255, 220);
    strokeWeight(1);
    fill(fillColor);
    rect(x, y, w, h, 6);
  }

  boolean hits(float bx, float by, float br) {
    if (!active) return false;
    float closestX = constrain(bx, x, x + w);
    float closestY = constrain(by, y, y + h);
    float distance = dist(bx, by, closestX, closestY);
    return distance <= br;
  }
}
