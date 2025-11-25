// =======================================================
//  ExampleSketch.pde
// =======================================================

ControlPanel ui;

void setup() {
  size(1500, 1000, P3D);

  // Attach a custom renderer for the screen
  ui = new ControlPanel(this, new ScreenRenderer() {
    public void drawScreen(PGraphics pg) {

      // ---- Developer's personal animation ----
      pg.smooth();
      pg.stroke(255);
      pg.strokeWeight(2);

      // Example: draw a line controlled by XY pad
      float x = map(ui.getPadX(), -75, 75, 0, ui.screenW);
      float y = map(ui.getPadY(), -75, 75, 0, ui.screenH);
      pg.line(0, 0, x, y);

      // Example: show encoder values
      pg.fill(255);
      pg.text("Left Enc: " + nf(ui.getLeftEncoder(),1,2), 20, 20);
      pg.text("Right Enc: " + nf(ui.getRightEncoder(),1,2), 20, 40);
    }
  });
}

void draw() {
  ui.draw();
}

// Forward mouse input to UI
void mousePressed()  { ui.mousePressed(); }
void mouseDragged()  { ui.mouseDragged(); }
void mouseReleased() { ui.mouseReleased(); }
