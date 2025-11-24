import oscP5.*;
import netP5.*;

// OSC
OscP5 OSC;
NetAddress remote;
float[] CV = new float[8];

void setup() {
  size(400, 200);

  // Ask user for IP
  String ip = promptForIP();   // e.g., "192.168.1.10" or leave blank for localhost
  if (ip.equals("")) ip = "127.0.0.1";

  // OSC setup
  OSC = new OscP5(this, 7000);           // local port
  remote = new NetAddress(ip, 7001);     // target port

  // Initialize CV values
  for (int i = 0; i < 8; i++) CV[i] = 0;
}

void draw() {
  // Call each CV output function
  CV1Out();
  CV2Out();
  CV3Out();
  CV4Out();
  CV5Out();
  CV6Out();
  CV7Out();
  CV8Out();
}

// CV output functions
void CV1Out() { assignCV(0, random(-5, 5)); }
void CV2Out() { assignCV(1, random(-5, 5)); }
void CV3Out() { assignCV(2, random(-5, 5)); }
void CV4Out() { assignCV(3, random(-5, 5)); }
void CV5Out() { assignCV(4, random(-5, 5)); }
void CV6Out() { assignCV(5, random(-5, 5)); }
void CV7Out() { assignCV(6, random(-5, 5)); }
void CV8Out() { assignCV(7, random(-5, 5)); }

// Assign CV, print, and send OSC
void assignCV(int index, float voltage) {
  CV[index] = voltage;
  println("CV" + (index+1) + " Out: " + voltage);

  OscMessage msg = new OscMessage("/ch/" + (index+1));
  msg.add(voltage);
  OSC.send(msg, remote);
}

// Helper function to prompt for IP
String promptForIP() {
  return javax.swing.JOptionPane.showInputDialog("Enter target IP (leave blank for localhost):");
}
