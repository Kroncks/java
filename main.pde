import java.util.ArrayList;

import processing.serial.*;

Serial arduinoPort;
float incomingFreq =-1.0;

final float ECART = 0.1; 
final float RAYON = 0.25;
final float TAILLE = 0.2; 
final float VITESSE = 0.012;

final int FPS = 30;

int fin = 1;
int joue = 0;

//                     do      re     mi     fa    sol     la     si     do
float[] frequences = {257.7, 289.4, 330.0, 353.1, 392.2, 441.5, 495.5, 523.2};


class Note {
  int num;
  int actif = 0;
  float x, y, dist, taille, angle;
  color col;

  Note(int num, float angle, color col) {
    this.num = num;
    this.angle = angle;
    this.col = col;
    this.x = width / 2;
    this.y = height / 2;
  }
  
  void play() {
    if (actif == 0) {
      taille = 1;
      dist = y;
      actif = 1;
    }
  }
  
  void refresh() {
    if (actif != 0) {
      dist -= dist * VITESSE;
      
      if (actif == 1 && dist * (1 + taille * TAILLE) < y) {
        actif = 2;

        if (joue + 1 != partition.length) { 
          joue++;
          if (fin == 0) {
            if (partition[joue]==0){
              Silence newSilence = new Silence();
              silences.add(newSilence);
              newSilence.play();
              while (joue + 1 < partition.length && newSilence.num == partition[joue + 1]) {
                newSilence.taille++;
                joue++;
              }
            }else{
              Note newNote = new Note(partition[joue], PI * (partition[joue]-1) / 4, couleurs[partition[joue]-1]);
              notes.add(newNote);
              newNote.play();
              
              while (joue + 1 < partition.length && newNote.num == partition[joue + 1]) {
                newNote.taille++;
                joue++;
              }
            }
          }
        }
        return;
      }
      
      if (actif == 2 && dist < y * RAYON) {
        actif = 3;
        return;
      }
      
      if (actif == 3 && dist * (1 + taille * TAILLE) < y * RAYON) {
        actif = 0;
        if (joue + 1 == partition.length) fin = 1;
      }
    }
  }

  void display() {
    if (actif != 0) {
      float x1, y1, x2, y2, x3, y3, x4, y4;
      
      x1 = sqrt(17/16.0) * dist * cos(angle + atan(ECART));
      y1 = sqrt(17/16.0) * dist * sin(angle + atan(ECART));
      x2 = sqrt(17/16.0) * dist * cos(angle - atan(ECART));
      y2 = sqrt(17/16.0) * dist * sin(angle - atan(ECART));
      
      x3 = sqrt(17/16.0) * dist * (1 + taille * TAILLE) * cos(angle - atan(ECART));
      y3 = sqrt(17/16.0) * dist * (1 + taille * TAILLE) * sin(angle - atan(ECART));
      x4 = sqrt(17/16.0) * dist * (1 + taille * TAILLE) * cos(angle + atan(ECART));
      y4 = sqrt(17/16.0) * dist * (1 + taille * TAILLE) * sin(angle + atan(ECART));
      
      x1 += x; x2 += x; x3 += x; x4 += x;
      y1 += y; y2 += y; y3 += y; y4 += y;

      fill(col, 100);
      stroke(col);
      strokeWeight(15 * dist * 0.01);
      strokeJoin(ROUND);
      quad(x1, y1, x2, y2, x3, y3, x4, y4);

      fill(col);
      stroke(255, 255, 255);
      strokeWeight(7 * dist * 0.01);
      strokeJoin(ROUND);
      quad(x1, y1, x2, y2, x3, y3, x4, y4);
    }
  }

  void touche() {
    if (actif == 3) {
        if(abs(incomingFreq-frequences[num-1])<25){
          fill(col);
          stroke(255);
          strokeWeight(1);
          ellipse(x + cos(angle) * y * RAYON * 0.85, y + sin(angle) * y * RAYON * 0.85, y * RAYON * 0.65, y * RAYON * 0.65);
          ellipse(x, y, y * RAYON * 0.75, y * RAYON * 0.75);
      }
    }
  }
}


class Silence {
  int num;
  int actif = 0;
  float x, y, dist, taille;


  Silence() {
    this.x = width / 2;
    this.y = height / 2;
  }
  
  void play() {
    if (actif == 0) {
      taille = 1;
      dist = y;
      actif = 1;
    }
  }
  
  void refresh() {
    if (actif != 0) {
      dist -= dist * VITESSE;
      
      if (actif == 1 && dist * (1 + taille * TAILLE) < y) {
        actif = 2;

        if (joue + 1 != partition.length) { 
          joue++;
          if (fin == 0) {
            Note newNote = new Note(partition[joue], PI * (partition[joue]-1) / 4, couleurs[partition[joue]-1]);
            notes.add(newNote);
            newNote.play();
            
            while (joue + 1 < partition.length && newNote.num == partition[joue + 1]) {
              newNote.taille++;
              joue++;
            }
          }
        }
        return;
      }
      
      if (actif == 2 && dist < y * RAYON) {
        actif = 3;
        return;
      }
      
      if (actif == 3 && dist * (1 + taille * TAILLE) < y * RAYON) {
        actif = 0;
        if (joue + 1 == partition.length) fin = 1;
      }
    }
  }
}



ArrayList<Note> notes;
ArrayList<Silence> silences;
color[] couleurs = {color(0, 0, 255), color(255, 0, 255), color(255, 0, 0), color(255, 150, 0), color(255, 255, 0), color(200, 225, 0), color(0, 255, 0), color(100, 255, 255)};
//                /                       /                       /                       /                       /                       /                       /
int[] partition = {0, 0, 3, 3, 0, 6, 6, 0, 3, 3, 3, 3, 0, 1, 0, 4, 0, 3, 3, 0, 1, 1, 0, 0, 3, 3, 0, 6, 6, 0, 3, 3, 3, 3, 0, 1, 0, 4, 0, 3, 3, 0, 1, 1, 0, 0, 3, 3, 0, 6, 6, 0, 3, 3, 3, 3, 0, 1, 0, 4, 0, 3, 3, 0, 1, 1};

void setup() {
  frameRate(FPS);
  fullScreen();
  background(255);
  noCursor();
  notes = new ArrayList<Note>();
  silences = new ArrayList<Silence>();
  // Connexion :
  printArray(Serial.list()); // Liste les ports
  arduinoPort = new Serial(this, Serial.list()[0], 9600); 
  arduinoPort.bufferUntil('\n'); 
}

void draw() {
  background(45);
  float x = width / 2;
  float y = height / 2;

  if (fin == 1 && mousePressed) {
    joue = 0;
    fin = 0;
    if (partition[joue]==0){
      Silence newSilence = new Silence();
      silences.add(newSilence);
      newSilence.play();
      while (joue + 1 < partition.length && newSilence.num == partition[joue + 1]) {
        newSilence.taille++;
        joue++;
      }
    }else{
      Note newNote = new Note(partition[joue], PI * (partition[joue]-1) / 4, couleurs[(partition[joue]-1)]);
      notes.add(newNote);
      newNote.play();
      while (joue + 1 < partition.length && newNote.num == partition[joue + 1]) {
        newNote.taille++;
        joue++;
      }
    }
  }

  int diametre = height;
  for (int j = 0; j < 10; j++) {
    fill(50 - 5 * j);
    noStroke();
    ellipse(x, y, diametre, diametre);
    diametre = diametre * 8 / 9;
  }

  for (int i = notes.size() - 1; i >= 0; i--) {
    Note n = notes.get(i);
    n.refresh();
    n.display();
    if (n.actif == 0) {
      notes.remove(i); // Suppression propre
    }
  }
  
  for (int i = silences.size() - 1; i >= 0; i--) {
    Silence s = silences.get(i);
    s.refresh();
    if (s.actif == 0) {
      silences.remove(i); // Suppression propre
    }
  }

  fill(80);
  noStroke();
  ellipse(x, y, height * RAYON, height * RAYON);
  fill(50);
  ellipse(x, y, y * RAYON * 0.75, y * RAYON * 0.75);
  
  for (int i=0; i<8; i++){
      fill(lerpColor(couleurs[i], color(0, 0, 0), 0.3));
      noStroke();
      ellipse(x + cos(PI*i/ 4) * y * RAYON * 0.75, y + sin(PI*i/ 4) * y * RAYON * 0.75, y * RAYON * 0.55, y * RAYON * 0.55);
  }

  for (Note n : notes) {
    n.touche();
  }
}

void serialEvent(Serial port) {
  String line = port.readStringUntil('\n');
  if (line != null) {
    incomingFreq = Float.parseFloat(trim(line)); // Enlève les retours à la ligne
  }
}
