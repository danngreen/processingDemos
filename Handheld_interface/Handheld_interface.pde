void drawHandheldScreen() {
  rectMode(CORNER);
  ellipseMode(CORNER);
  fill(255,0,0);
  ellipse(-50, -50, 300, 300);
  fill(0,255,0);
  ellipse(310, 10, 300, 500);
  fill(0,0,255);
  ellipse(700 + padIndicator.x, padIndicator.y, 300, 500);
  
    for (int i = 0; i < 16; i++) {
    level[i] = amps[i].analyze();

    float x = level[i] * width;

    stroke(255);
    line(0, 25 + i * 22, x, 25 + i * 22);

    fill(180);
    text("CH " + (i + 1) + ": " + nf(level[i], 1, 4), 10, 20 + i * 22);
  }

}
