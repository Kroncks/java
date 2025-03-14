import processing.serial.*;

Serial myPort; // Déclare la communication série

void setup() {
  size(600, 400);
  printArray(Serial.list()); // Affiche les ports disponibles dans la console
  myPort = new Serial(this, Serial.list()[4], 9600); // Se connecte a l'arduino 
}

void draw() {
  background(200);
  
  if (mousePressed) {
    myPort.write('1'); // Allume la LED si on clique
    fill(255, 0, 0);
  } else {
    myPort.write('0'); // Éteint la LED si on relâche
    fill(0);
  }

  ellipse(width / 2, height / 2, 100, 100);
}
