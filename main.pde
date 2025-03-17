import java.util.ArrayList;

final float ECART = 0.25; // Constante
final float RAYON = 0.25; // rapport hauteur rayon
final float VITESSE = 0.02;
int fin=0;
int joue=0;

class Note {
  int num;
  int actif=0;
  float x=width/2, y=height/2;
  float dist, taille, angle;
  color col;

  Note(int num,float angle, color col) {
    this.num=num;
    this.angle = angle;
    this.col = col;
  }
  
  void play() {
    if (actif==0){
      taille=1;
      dist =y;
      actif=1;
    }
  }
  
  void refresh() {
    if (actif!=0){
      dist -= dist * VITESSE;
      
      if (actif == 1 && dist*(1+taille) < y){
        actif=2;
        if (joue+1!=partition.length)
          joue++;
        return;
      }
      
      if (actif == 2 && dist < y * RAYON ){
        actif=3;
        return;
      }
      
      if (actif == 3 && dist*(1+taille) < y * RAYON){
        actif=0;
        if (joue+1==partition.length)
          fin=1;
        return;
      }
    }
  }

  void display() {
    if (actif!=0){
      float x1, y1, x2, y2, x3, y3, x4, y4;
      
      x1 = sqrt(17/16.0) * dist * cos(angle + atan(ECART));
      y1 = sqrt(17/16.0) * dist * sin(angle + atan(ECART));
      x2 = sqrt(17/16.0) * dist * cos(angle - atan(ECART));
      y2 = sqrt(17/16.0) * dist * sin(angle - atan(ECART));
      
      x3 = sqrt(17/16.0) * dist * (1 + taille) * cos(angle - atan(ECART));
      y3 = sqrt(17/16.0) * dist * (1 + taille) * sin(angle - atan(ECART));
      x4 = sqrt(17/16.0) * dist * (1 + taille) * cos(angle + atan(ECART));
      y4 = sqrt(17/16.0) * dist * (1 + taille) * sin(angle + atan(ECART));
      
      x1 += x; x2 += x; x3 += x; x4 += x;
      y1 += y; y2 += y; y3 += y; y4 += y;
  
      // Ombre floue
      fill(col, 100);
      stroke(col);
      strokeWeight(15*dist*0.01);
      strokeJoin(ROUND);
      quad(x1, y1, x2, y2, x3, y3, x4, y4);
  
      // Forme principale
      fill(col);
      stroke(255, 255, 255);
      strokeWeight(7*dist*0.01);
      strokeJoin(ROUND);
      quad(x1, y1, x2, y2, x3, y3, x4, y4);
    }
  }
  void touche(){
    if (actif==3){
      fill(col);
      stroke(255);
      strokeWeight(1);
      ellipse(x+cos(angle)*y*RAYON*0.85, y+sin(angle)*y*RAYON*0.85, y*RAYON*0.65, y*RAYON*0.65);
    } else {
      fill(lerpColor(col, color(0, 0, 0), 0.3));
      noStroke();
      ellipse(x+cos(angle)*y*RAYON*0.75, y+sin(angle)*y*RAYON*0.75, y*RAYON*0.55, y*RAYON*0.55);
    }
  }
}
// ----- silence -------

class Silence {
  int actif=0;
  float x=width/2, y=height/2;
  float dist, taille;
  
  void play() {
    if (actif==0){
      dist =y;
      actif=1;
    }
  }
  
  void refresh() {
    if (actif!=0){
      dist -= dist * VITESSE;
      
      if (actif == 1 && dist*(1+taille) < y){
        actif=2;
        if (joue+1!=partition.length)
          joue++;
        return;
      }
      
      if (actif == 2 && dist < y * RAYON ){
        actif=3;
        return;
      }
      
      if (actif == 3 && dist*(1+taille) < y * RAYON){
        actif=0;
        if (joue+1==partition.length)
          fin=1;
        return;
      }
    }
  }
}





ArrayList<Note> notes;
color[] couleurs = {color(0, 0, 255), color(255, 0, 255), color(255, 0, 0), color(255, 150, 0),color(255, 255, 0), color(200, 225, 0), color(0, 255, 0), color(100, 255, 255)};
int[] partition = {1,2,3,3,3,4,5,6,7,8,0,1,2,1,0,1,1,1,2,3,4,5,6,7,8};
Silence silence;

void setup() {
  //size(800, 600);
  //ou
  fullScreen();
  background(255);
  
  notes = new ArrayList<Note>();
  silence = new Silence();


  for (int i=0;i<8;i++){
    notes.add(new Note(i+1, PI * i / 4, couleurs[i]));
  }
}

void draw() {
  background(0);
  float x = width/2;
  float y = height/2;
 
  // Arrière-plan (cercle en dégradé)
  int diametre = height;
  for (int j = 0; j < 10; j++) {
    fill(50 - 5 * j);
    noStroke();
    ellipse(x, y, diametre, diametre);
    diametre = diametre * 8 / 9;
  }

  for (Note n : notes) {
    if ( n.num == partition[joue]){
      if (fin==0)
        n.play();
      while (joue+1<partition.length && n.num == partition[joue+1]){
        n.taille++; //on incremente la variable hentai
        joue++;
      }
    }
    n.refresh();
    n.display();
  }
  if (partition[joue]==0){ // verif les silences
    if (fin==0)
      silence.play();
    while (joue+1<partition.length && partition[joue+1] == 0){
      silence.taille++; //on incremente la variable hentai
      joue++;
    }
    
  }
  silence.refresh();
  
  // Cercle central
  fill(80);
  noStroke();
  ellipse(x, y, height*RAYON, height*RAYON);
  
  for (Note n : notes) {
    n.touche();
  }
}
