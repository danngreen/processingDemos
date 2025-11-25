// =======================================================
//  ControlPanel.pde  (Reusable Interface Module)
// =======================================================

interface ScreenRenderer {
  void drawScreen(PGraphics pg);
}

class ControlPanel {

  PApplet p;
  ScreenRenderer renderer;

  // ----- Screen buffer -----
  PGraphics screen;
  int screenW = 960;
  int screenH = 400;

  // ----- UI layout -----
  int buttonSize = 75;
  int encoderSize = 150;
  int padSize = 150;
  int padIndicatorSize = 20;
  int cubeSize = 80;

  // ----- Encoder state -----
  float leftEncAngle = -HALF_PI;
  float rightEncAngle = -HALF_PI;
  float leftEncTarget = leftEncAngle;
  float rightEncTarget = rightEncAngle;
  int draggingEncoder = -1;
  float lastMouseAngle = 0;
  int[] lastClickTime = {0,0};
  boolean[] encoderPressed = {false,false};
  int encoderPressDuration = 200;

  // ----- Buttons -----
  boolean[] buttonPressed = new boolean[4];

  // ----- XY Pad -----
  PVector padIndicator = new PVector(0,0);
  boolean draggingPad = false;

  // ----- Cube -----
  float cubeRotX = 0;
  float cubeRotY = 0;
  boolean draggingCube = false;
  float lastCubeMouseX, lastCubeMouseY;

  // ----- Constructor -----
  ControlPanel(PApplet parent, ScreenRenderer renderer) {
    this.p = parent;
    this.renderer = renderer;
    screen = parent.createGraphics(screenW, screenH);
  }

  // ==========================================================
  // DRAW
  // ==========================================================
  void draw() {
    p.background(255);

    float cx = p.width / 2.0f;
    float cy = p.height / 2.0f;
    float panelW = screenW + 150;
    float panelH = screenH + 440;

    // Panel BG
    p.fill(32);
    p.rectMode(PConstants.CENTER);
    p.rect(cx, cy, panelW, panelH, 25);

    // Screen position
    float screenY = cy - panelH/2 + 50 + screenH/2;

    // Draw developer screen
    drawUserScreen(cx, screenY);

    // Buttons
    drawButtons(cx, screenY);

    // Encoders
    float encY = screenY + screenH/2 + 70 + 150;
    drawEncoders(cx, encY);

    // XY Pad
    drawXYPad(cx, encY);

    // Cube
    drawCube();
  }

  // ==========================================================
  // USER SCREEN RENDERING
  // ==========================================================
  void drawUserScreen(float cx, float screenY) {
    // Render into PGraphics
    screen.beginDraw();
    screen.background(0);
    renderer.drawScreen(screen);
    screen.endDraw();

    // Draw it inside UI frame
    p.imageMode(PConstants.CENTER);
    p.image(screen, cx, screenY);

    // Screen bezel
    p.noFill();
    p.stroke(0);
    p.rect(cx, screenY, screenW, screenH, 8);
    p.noStroke();
  }

  // ==========================================================
  // BUTTONS
  // ==========================================================
  void drawButtons(float cx, float screenY) {
    float buttonRowY = screenY + screenH/2 + 70;
    float spacing = screenW / 5.0f;
    float firstButtonX = cx - screenW/2 + spacing;

    p.colorMode(PConstants.RGB);
    
    int[] baseColors = {
      p.color(220, 50, 50),
      p.color(140),
      p.color(180),
      p.color(180)
    };

    for (int i = 0; i < 4; i++) {
      p.fill(buttonPressed[i] ? p.lerpColor(baseColors[i], p.color(0), 0.25f) : baseColors[i]);
      p.ellipse(firstButtonX + i*spacing, buttonRowY, buttonSize, buttonSize);

      p.noFill();
      p.stroke(0, 30);
      p.strokeWeight(4);
      p.ellipse(firstButtonX + i*spacing, buttonRowY, buttonSize*0.9f, buttonSize*0.9f);
      p.noStroke();
    }
  }

  // ==========================================================
  // ENCODERS
  // ==========================================================
  void drawEncoders(float cx, float encY) {
    float leftEncX  = cx - screenW/4;
    float rightEncX = cx + screenW/4;

    p.fill(encoderPressed[0] ? 40 : 45);
    p.ellipse(leftEncX, encY, encoderSize, encoderSize);

    p.fill(encoderPressed[1] ? 40 : 45);
    p.ellipse(rightEncX, encY, encoderSize, encoderSize);

    // Smooth animation
    leftEncAngle += (leftEncTarget - leftEncAngle) * 0.2;
    rightEncAngle += (rightEncTarget - rightEncAngle) * 0.2;

    // Draw knob indicators
    drawKnobIndicator(leftEncX, encY, leftEncAngle);
    drawKnobIndicator(rightEncX, encY, rightEncAngle);

    // Reset press flash
    for (int i=0; i<2; i++)
      if (encoderPressed[i] && p.millis() - lastClickTime[i] > encoderPressDuration)
        encoderPressed[i] = false;
  }

  void drawKnobIndicator(float x, float y, float angle) {
    p.stroke(255);
    p.strokeWeight(4);

    float r = encoderSize/2.0f;
    float len = r * 0.2f;
    float sx = x + p.cos(angle) * (r - len);
    float sy = y + p.sin(angle) * (r - len);
    float ex = x + p.cos(angle) * r;
    float ey = y + p.sin(angle) * r;
    p.line(sx, sy, ex, ey);

    p.noStroke();
  }

  // ==========================================================
  // XY PAD
  // ==========================================================
  void drawXYPad(float cx, float encY) {
    float padX = cx;
    float padY = encY + 10;

    p.pushMatrix();
    p.translate(padX, padY);
    p.rotate(p.radians(45));

    p.fill(65);
    p.rect(0, 0, padSize, padSize, 10);

    p.noFill();
    p.stroke(0, 0, 255);
    p.strokeWeight(3);
    p.ellipse(padIndicator.x, padIndicator.y, padIndicatorSize, padIndicatorSize);

    p.noStroke();
    p.popMatrix();
  }

  // ==========================================================
  // CUBE
  // ==========================================================
  void drawCube() {
    float margin = 50;
    p.pushMatrix();
    p.hint(PConstants.DISABLE_DEPTH_TEST);
    p.ortho();
    p.translate(p.width - margin - cubeSize/2, p.height - margin - cubeSize/2);
    p.rotateX(cubeRotX);
    p.rotateY(cubeRotY);

    // Axes
    p.strokeWeight(3);
    p.stroke(255, 0, 0);
    p.line(0,0,0, 50,0,0);
    p.stroke(0,255,0);
    p.line(0,0,0, 0,50,0);
    p.stroke(0,0,255);
    p.line(0,0,0, 0,0,50);

    p.noStroke();
    p.beginShape(PConstants.QUADS);

    // faces
    p.fill(240); // front
    face(-1,-1,1, 1,-1,1, 1,1,1, -1,1,1);

    p.fill(50); // back
    face(-1,-1,-1, -1,1,-1, 1,1,-1, 1,-1,-1);

    p.fill(180); // right
    face(1,-1,-1, 1,1,-1, 1,1,1, 1,-1,1);

    p.fill(120); // left
    face(-1,-1,-1, -1,-1,1, -1,1,1, -1,1,-1);

    p.fill(200); // top
    face(-1,-1,-1, 1,-1,-1, 1,-1,1, -1,-1,1);

    p.fill(80); // bottom
    face(-1,1,-1, -1,1,1, 1,1,1, 1,1,-1);

    p.endShape();
    p.popMatrix();

    // Label
    p.fill(0);
    p.textAlign(PConstants.CENTER);
    p.text("Accelerometer", p.width - margin - cubeSize/2, p.height - margin - cubeSize - 10);
  }

  void face(float x1,float y1,float z1, float x2,float y2,float z2,
            float x3,float y3,float z3, float x4,float y4,float z4) {
    float s = cubeSize/2;
    p.vertex(x1*s, y1*s, z1*s);
    p.vertex(x2*s, y2*s, z2*s);
    p.vertex(x3*s, y3*s, z3*s);
    p.vertex(x4*s, y4*s, z4*s);
  }

  // ==========================================================
  // MOUSE HANDLING (forwarded from main sketch)
  // ==========================================================
  void mousePressed() {
    float cx = p.width/2f;
    float cy = p.height/2f;
    float panelH = screenH + 440;
    float screenY = cy - panelH/2 + 50 + screenH/2;
    float buttonRowY = screenY + screenH/2 + 70;
    float encY = buttonRowY + 150;

    // Buttons
    float spacing = screenW / 5.0f;
    float firstButtonX = cx - screenW/2 + spacing;
    for (int i = 0; i < 4; i++)
      if (p.dist(p.mouseX, p.mouseY, firstButtonX + i * spacing, buttonRowY) < buttonSize/2)
        buttonPressed[i] = true;

    // Encoders
    for (int i=0; i<2; i++) {
      float encX = (i == 0) ? cx - screenW/4 : cx + screenW/4;
      if (p.dist(p.mouseX, p.mouseY, encX, encY) < encoderSize/2) {
        int now = p.millis();
        if (now - lastClickTime[i] < 400) encoderPressed[i] = true;
        lastClickTime[i] = now;
        draggingEncoder = i;
        lastMouseAngle = PApplet.atan2(p.mouseY - encY, p.mouseX - encX);
      }
    }

    // XY Pad
    float padXc = cx;
    float padYc = encY + 10;
    float relX = rotateXRel(p.mouseX - padXc, p.mouseY - padYc);
    float relY = rotateYRel(p.mouseX - padXc, p.mouseY - padYc);
    float maxPos = padSize/2 - padIndicatorSize/2;

    if (PApplet.abs(relX) <= padSize/2 && PApplet.abs(relY) <= padSize/2) {
      draggingPad = true;
      padIndicator.x = PApplet.constrain(relX, -maxPos, maxPos);
      padIndicator.y = PApplet.constrain(relY, -maxPos, maxPos);
    }

    // Cube
    float margin = 50;
    if (p.mouseX > p.width-margin-cubeSize && p.mouseX < p.width-margin &&
        p.mouseY > p.height-margin-cubeSize && p.mouseY < p.height-margin) {
      draggingCube = true;
      lastCubeMouseX = p.mouseX;
      lastCubeMouseY = p.mouseY;
    }
  }

  void mouseDragged() {
    float cx = p.width/2f;
    float cy = p.height/2f;
    float panelH = screenH + 440;
    float screenY = cy - panelH/2 + 50 + screenH/2;
    float buttonRowY = screenY + screenH/2 + 70;
    float encY = buttonRowY + 150;

    // Encoders
    if (draggingEncoder != -1) {
      float encX = (draggingEncoder == 0) ? cx - screenW/4 : cx + screenW/4;
      float currentAngle = PApplet.atan2(p.mouseY - encY, p.mouseX - encX);
      float delta = currentAngle - lastMouseAngle;
      if (delta > PConstants.PI) delta -= PConstants.TWO_PI;
      if (delta < -PConstants.PI) delta += PConstants.TWO_PI;

      if (draggingEncoder == 0) leftEncTarget += delta;
      else rightEncTarget += delta;

      lastMouseAngle = currentAngle;
    }

    // XY Pad
    if (draggingPad) {
      float padXc = cx;
      float padYc = encY + 10;
      float relX = rotateXRel(p.mouseX - padXc, p.mouseY - padYc);
      float relY = rotateYRel(p.mouseX - padXc, p.mouseY - padYc);
      float maxPos = padSize/2 - padIndicatorSize/2;
      padIndicator.x = PApplet.constrain(relX, -maxPos, maxPos);
      padIndicator.y = PApplet.constrain(relY, -maxPos, maxPos);
    }

    // Cube
    if (draggingCube) {
      cubeRotY += (p.mouseX - lastCubeMouseX)*0.01;
      cubeRotX += (p.mouseY - lastCubeMouseY)*0.01;
      lastCubeMouseX = p.mouseX;
      lastCubeMouseY = p.mouseY;
    }
  }

  void mouseReleased() {
    draggingEncoder = -1;
    draggingPad = false;
    draggingCube = false;
    for (int i=0; i<4; i++) buttonPressed[i] = false;
  }

  // ==========================================================
  // Utility (rotate XY pad coords)
  // ==========================================================
  float rotateXRel(float x, float y) {
    float a = p.radians(-45);
    return x*p.cos(a) - y*p.sin(a);
  }
  float rotateYRel(float x, float y) {
    float a = p.radians(-45);
    return x*p.sin(a) + y*p.cos(a);
  }

  // ==========================================================
  // PUBLIC GETTERS
  // ==========================================================
  float getLeftEncoder()  { return leftEncAngle; }
  float getRightEncoder() { return rightEncAngle; }
  float getPadX() { return padIndicator.x; }
  float getPadY() { return padIndicator.y; }
  boolean getButton(int i) { return buttonPressed[i]; }
  float getCubeRotX() { return cubeRotX; }
  float getCubeRotY() { return cubeRotY; }
}
