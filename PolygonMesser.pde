//tänne tallennetaan viivojen datat OBS
int[][] control_line = new int[4][100];

//systeemi jossa kontrolliviivat elää
controlLineSystem line_storage;

//viivojen määrä
int control_line_count = 0;

//piirretäänkö alku- vai päätepistettä
int draw_state = 0;

//tilapäinen hiirennapsauskoordinaattitallete
float[] mouse_clicks = new float[4];

//tänne tallennetaan jokaisen janan risteyspisteet
PVector[][] intersection_list = new PVector[100][100];

void setup() {
  size(1024, 768);
  background(124);
  
  line_storage = new controlLineSystem();
}

void draw() {
  //tyhjennä ruutu
  //background(124);
  
  //piirretään viivat
   line_storage.run();
    
}

void mouseReleased() {  

  if (draw_state == 0) {
    
    //lisätään alkupiste arrayyn
    mouse_clicks[0] = mouseX;
    mouse_clicks[1] = mouseY;    

    draw_state = 1;
  } 
  
  else if (draw_state == 1) {
    
    //lisätään päätepiste arrayyn
    mouse_clicks[2] = mouseX;
    mouse_clicks[3] = mouseY;    

    draw_state = 0;
    
    //luodaan hiirennapsausten perusteella uusi kontrolliviivaobjekti
    line_storage.addLine();    
    
    // Tässä ajetaan looppi joka tsekkaa risteykset ja lisää ne intersection_listiin
    for (int  a = 0; a < line_storage.line_list.size(); a++) {
      for (int b = 0; b < line_storage.line_list.size(); b++) {
        if (a != b) {
          
          float[] intersection_array = new float[3];
          PVector intersection_vector = new PVector();
          
          // Ajetaan funktio joka tunnistaa ja hakee intersektiot
          intersection_array = intersect(
          line_storage.line_list.get(a).start.x,
          line_storage.line_list.get(a).start.y,
          line_storage.line_list.get(a).end.x,
          line_storage.line_list.get(a).end.y,
          line_storage.line_list.get(b).start.x,
          line_storage.line_list.get(b).start.y,
          line_storage.line_list.get(b).end.x,
          line_storage.line_list.get(b).end.y
          );
          
          intersection_vector.x = intersection_array[0];
          intersection_vector.y = intersection_array[1];          
          
          // JOS intersektio löytyy, tungetaan se listaan
          if (intersection_array[2] == 1) {
            intersection_list[b][a] = intersection_vector;
            
            // testi
            fill(255);
            ellipse(intersection_list[b][a].x, intersection_list[b][a].y, 10, 10);
            print(intersection_list[b][a].x, intersection_list[b][a].y, " - ");
          }
        }
      }    
    }
    
    //kasvatetaan viivojen määrälukua
    control_line_count++;
  }
  
}


/* FUNCTIONS AND CLASSES */


// Kontrolliviivaobjekti
// Viivalla on alku- ja loppupisteet (mahd myöh numero jos tarve)

class controlLine { 
  PVector start = new PVector();
  PVector end = new PVector();
  
  controlLine ( float s_x, float s_y, float e_x, float e_y) {  
    start.x = s_x; 
    start.y = s_y;
    end.x = e_x;
    end.y = e_y;
  } 
  
  void run() {
    update();
    display();
  }
  
  void update() { 
  }
  
  void display() {
    stroke(255,0,0);
    line(start.x, start.y, end.x, end.y);
  }
} 

//systeemi viivaobjekteille

class controlLineSystem {
  ArrayList<controlLine> line_list;

  controlLineSystem() {
    line_list = new ArrayList<controlLine>();
  }

  void addLine() {
    line_list.add(new controlLine(mouse_clicks[0], mouse_clicks[1], mouse_clicks[2], mouse_clicks[3]));
  }
  
  void run() {
    for (int i = line_list.size()-1; i >= 0; i--) {
      controlLine x = line_list.get(i);
      x.run();
    }
  }
}


// Intersektion etsintä (pöllitty koodi)

float[] intersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4){

  float a1, a2, b1, b2, c1, c2;
  float r1, r2 , r3, r4;
  float denom, offset, num;
  float intersect_x, intersect_y;
  float[] intersection_output = new float[3];

  // Compute a1, b1, c1, where line joining points 1 and 2
  // is "a1 x + b1 y + c1 = 0".
  a1 = y2 - y1;
  b1 = x1 - x2;
  c1 = (x2 * y1) - (x1 * y2);

  // Compute r3 and r4.
  r3 = ((a1 * x3) + (b1 * y3) + c1);
  r4 = ((a1 * x4) + (b1 * y4) + c1);

  // Check signs of r3 and r4. If both point 3 and point 4 lie on
  // same side of line 1, the line segments do not intersect.
  if ((r3 != 0) && (r4 != 0) && same_sign(r3, r4)){
    //return DONT_INTERSECT;
    intersection_output[2] = 0;
    return intersection_output;
  }

  // Compute a2, b2, c2
  a2 = y4 - y3;
  b2 = x3 - x4;
  c2 = (x4 * y3) - (x3 * y4);

  // Compute r1 and r2
  r1 = (a2 * x1) + (b2 * y1) + c2;
  r2 = (a2 * x2) + (b2 * y2) + c2;

  // Check signs of r1 and r2. If both point 1 and point 2 lie
  // on same side of second line segment, the line segments do
  // not intersect.
  if ((r1 != 0) && (r2 != 0) && (same_sign(r1, r2))){
    //return DONT_INTERSECT;
    intersection_output[2] = 0;
    return intersection_output;
  }

  //Line segments intersect: compute intersection point.
  denom = (a1 * b2) - (a2 * b1);

  if (denom == 0) {
    //return COLLINEAR;
  }

  if (denom < 0){ 
    offset = -denom / 2; 
  } 
  else {
    offset = denom / 2 ;
  }

  // The denom/2 is to get rounding instead of truncating. It
  // is added or subtracted to the numerator, depending upon the
  // sign of the numerator.
  num = (b1 * c2) - (b2 * c1);
  if (num < 0){
    intersect_x = (num - offset) / denom;
  } 
  else {
    intersect_x = (num + offset) / denom;
  }

  num = (a2 * c1) - (a1 * c2);
  if (num < 0){
    intersect_y = ( num - offset) / denom;
  } 
  else {
    intersect_y = (num + offset) / denom;
  }

  // lines_intersect
  intersection_output[0] = intersect_x; 
  intersection_output[1] = intersect_y;
  intersection_output[2] = 1;
  return intersection_output;
}

boolean same_sign(float a, float b){
  return (( a * b) >= 0);
}


// Funktio joka tsekkaa kummalla puolella piste on viivaan nähden 

float detect_side(PVector p1, PVector p2, PVector p) {
    PVector diff = new PVector();
    PVector perp = new PVector();
    PVector diff2 = new PVector();
  
    diff.x = (p2.x - p1.x);
    diff.y = (p2.y - p1.y);
    diff2.x = (p.x - p1.x);
    diff2.y = (p.y - p1.y);
    
    perp.set(-diff.y, diff.x);
    
    //float d = dot(p - p1, perp);
    float d = diff2.dot(perp);
    
    return d;
}