import processing.sound.*;

PImage backgroundImg;
PImage coinImg;
PImage bombImg;
PImage basketImg;
PImage basketImg2;
PImage moneyImg;

SoundFile boomSound;

int basketX, basketY;
int basketW = 160, basketH = 100; //veličina košare

// lista objekata
ArrayList<FallingObject> objects;

int coins2 = 0;

boolean explosion = false;
int explosionTimer = 0;

boolean gameOverN = false;


//klasa za padajuće objekte
class FallingObject {
  float x, y;
  PImage img;
  float speed;
  float vx;
  float angle;
  float rotationSpeed;
  boolean bounced;
  int type;

  FallingObject(float x, float y, PImage img, float speed, float vx, int type) {
    this.x = x;
    this.y = y;
    this.img = img;
    this.speed = speed;
    this.vx = vx;
    this.type = type;
    this.angle = 0;
    this.rotationSpeed = random(-0.1, 0.1);
    this.bounced = false;
  }

  void update() {
    vx *= 0.99;
    x += vx;
    if (bounced) {
      speed += 0.2;
    }
    y += speed;
    angle += rotationSpeed;
  }

  void show() {
    pushMatrix();
    translate(x + img.width/2, y + img.height/2);
    rotate(angle);
    imageMode(CENTER);
    image(img, 0, 0);
    imageMode(CORNER);
    popMatrix();
  }
}

void setupNovcici(){
  
  backgroundImg = loadImage("backgroundImg.png");
  backgroundImg.resize(width, height);
  
  basketImg = loadImage("basketImg.png");
  basketImg.resize(basketW, basketH);
  basketImg2 = loadImage("basketImg2.png");
  basketImg2.resize(basketW, basketH);
  basketX = width/2 - basketW/2;
  basketY = height - basketH - 20;
  
  coinImg = loadImage("coinImg.png");
  coinImg.resize(70, 70);

  bombImg = loadImage("bombImg.png");
  bombImg.resize(60, 60);

  moneyImg = loadImage("moneyImg.png");
  moneyImg.resize(70, 70);
  
  objects = new ArrayList<FallingObject>();
  
  boomSound = new SoundFile(this, "boom.mp3");
  
  gameOverN = false;
  coins2 = 0;
  
}

void drawNovcici(){
  // Reset graphics context from 3D to 2D
  resetMatrix();
  camera();
  perspective();
  
  image(backgroundImg, 0, 0);
    
  if (gameOverN) {
    gameOver();
    return;
  }

  float shakeX = 0;
  float shakeY = 0;
  //za game over da se rotira kosara
  if (explosion) {
    shakeX = random(-8, 8);
    shakeY = random(-4, 4);
  }
  
  image(basketImg, basketX + shakeX, basketY + shakeY);
  
  
  // spawn random objekata
  if (random(1) < 0.03) {
    spawnObject();
  }

  // update + crtanje objekata
  for (int i = objects.size() - 1; i >= 0; i--) {
    FallingObject o = objects.get(i);
    o.update();
    o.show();
    
    if(o.type != 1){
      boolean insideBasket = o.x > basketX && o.x < basketX + basketW - 70 &&
        o.y > basketY - 30 && o.y < basketY + 10;

      if (insideBasket) {
        if (o.img == coinImg) {
          coins2 += 1;
        } 
        else if (o.img == moneyImg) {
          coins2 += 10;
        }
        objects.remove(i);
      }
      else if(o.x > basketX + basketW - 70 && o.x < basketX + basketW && 
        o.y > basketY - 30 && o.y < basketY + 10){
        
        o.speed = -abs(o.speed) * 0.7;
        o.vx = random(-2, 2);
        o.rotationSpeed = random(-0.25, 0.25);
        o.bounced = true;
        o.y = basketY - 72;
        
      }else if(o.x > basketX - 70 && o.x < basketX && 
        o.y > basketY - 30 && o.y < basketY + 10){
        
        o.speed = -abs(o.speed) * 0.7;
        o.vx = random(-2, 2);
        o.rotationSpeed = random(-0.25, 0.25);
        o.bounced = true;
        o.y = basketY - 72;
        
      }
    }else{
      if (o.x > basketX && o.x < basketX + basketW - 60 &&
        o.y > basketY - 30 && o.y < basketY + 10) {
          explosion = true;
          explosionTimer = 20;
          boomSound.play();
          boomSound.amp(0.05);
          objects.remove(i);
      }
    }

    // ukloni ako padne van ekrana
    if (o.y > height) {
      objects.remove(i);
    }
  }
  
  image(basketImg2, basketX + shakeX, basketY + shakeY);


  if (explosion) {
    fill(255, 0, 0, 80);
    rect(0, 0, width, height);
  
    explosionTimer--;
  
    if (explosionTimer <= 0) {
      explosion = false;
      gameOver();
    }
  }
  
  fill(0);
  textSize(30);
  textAlign(LEFT);
  text("Coins: " + coins2, 20, 40);
  textSize(14);
  text("Upute:", 20, 80);
  text("Kretanje: ← i →", 20, 100);
}



void spawnObject() {
  int x = (int) random(width);
  int type = (int) random(3); // 0 novcic, 1 bomba, 2 novacica
  int sp = (int) random(4); // brzina
  if (type == 0) {
    objects.add(new FallingObject(x, 0, coinImg, sp+2, 0, 0));
  } 
  else if (type == 1) {
    objects.add(new FallingObject(x, 0, bombImg, sp+2, 0, 1));
  } 
  else {
    objects.add(new FallingObject(x, 0, moneyImg, sp+2, random(-1, 1), 2));
  }
}

void gameOver() {

  fill(255, 0, 0);
  textSize(60);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/2 - 40);

  fill(255);
  textSize(20);
  text("Pritisni ENTER za povratak", width/2, height/2 + 30);

  explosion = false;
  explosionTimer = 0;
  
  gameOverN = true;
  
  resetCameraMovementKeys();
  
}

void keyPressed2() {
  
  if (gameOverN) {
    // Enter za nazad u igricu
    if (keyCode == ENTER) {
      coins += coins2;
      novciciActive = false;
      resetCameraMovementKeys();
      objects.clear();
      loop();
    }
    return;
  }

  if (keyCode == LEFT)
    basketX -= 50;

  if (keyCode == RIGHT)
    basketX += 50;

  basketX = constrain(basketX, 0, width - basketW );
}
