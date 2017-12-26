//containeri jossa kontrolliviivat elää
controlLineSystem line_storage;

//containeri jossa intersektiot elää
intersectionSystem intersection_storage;

//tänne tallennetaan jokaisen janan risteyspisteet KORVATAAN kohta
PVector[][] intersection_list = new PVector[100][100];

//piirretäänkö alku- vai päätepistettä
int draw_state = 0;

//tilapäinen hiirennapsauskoordinaattitallete
float[] mouse_clicks = new float[4];

ArrayList<intersectionObject> polycoords;


void setup() {
  size(1024, 768);
  background(124);

  line_storage = new controlLineSystem();
  intersection_storage = new intersectionSystem();

}

void draw() {
  //tyhjennä ruutu
  //background(124);

  //piirretään viivat
  line_storage.run();
  intersection_storage.run();
  
  if (intersection_storage.objects.size() > 0) {
    draw_polygon(intersection_storage.objects.get(0));
  }
}

void mouseReleased() {  

  if (draw_state == 0) {

    //lisätään alkupiste arrayyn
    mouse_clicks[0] = mouseX;
    mouse_clicks[1] = mouseY;    

    draw_state = 1;
  } else if (draw_state == 1) {

    //lisätään päätepiste arrayyn
    mouse_clicks[2] = mouseX;
    mouse_clicks[3] = mouseY;    

    draw_state = 0;

    //luodaan hiirennapsausten perusteella uusi kontrolliviivaobjekti ja intersektio-objektit päätyjen perusteella
    line_storage.addObject();    
    intersection_storage.addObject(mouse_clicks[0], mouse_clicks[1], line_storage.objects.size()-1, line_storage.objects.size()-1, true, false);
    intersection_storage.addObject(mouse_clicks[2], mouse_clicks[3], line_storage.objects.size()-1, line_storage.objects.size()-1, false, true);

    // Tässä ajetaan looppi joka tsekkaa risteykset ja lisää ne intersection_listiin
    for (int  a = 0; a < line_storage.objects.size(); a++) {
      for (int b = a+1; b < line_storage.objects.size(); b++) {

        float[] intersection_array = new float[3];
        PVector intersection_vector = new PVector();

        // Ajetaan funktio joka tunnistaa ja hakee intersektiot
        intersection_array = intersect(
          line_storage.objects.get(a).start.x, 
          line_storage.objects.get(a).start.y, 
          line_storage.objects.get(a).end.x, 
          line_storage.objects.get(a).end.y, 
          line_storage.objects.get(b).start.x, 
          line_storage.objects.get(b).start.y, 
          line_storage.objects.get(b).end.x, 
          line_storage.objects.get(b).end.y
          );

        intersection_vector.x = intersection_array[0];
        intersection_vector.y = intersection_array[1];          

        // JOS intersektio löytyy, luodaan intersektio-objekti
        if (intersection_array[2] == 1) {
          intersection_storage.addObject(intersection_vector.x, intersection_vector.y, a, b, false, false);  
        }
      }
    }
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
    stroke(255, 0, 0);
    line(start.x, start.y, end.x, end.y);
  }
} 

// Intersektio-objekti

class intersectionObject { 
  PVector coords = new PVector();
  int parent_a, parent_b;
  boolean startpoint;
  boolean endpoint;
  
  intersectionObject () {  //default constructor for empty instances
  }

  intersectionObject ( float x, float y, int a, int b, boolean s, boolean e) {  
    coords.x = x;
    coords.y = y;
    parent_a = a;
    parent_b = b;
    startpoint = s;
    endpoint = e;
  } 

  void run() {
    update();
    display();
  }

  void update() {
  }

  void display() {
    stroke(0);
    fill(255);
    ellipse(coords.x, coords.y, 10, 10);
    textSize(24);
    text(parent_a, coords.x+20, coords.y);
    text(parent_b, coords.x+50, coords.y);
  }
} 


//systeemi viivaobjekteille

class controlLineSystem {
  ArrayList<controlLine> objects;

  controlLineSystem() {
    objects = new ArrayList<controlLine>();
  }

  void addObject() {
    objects.add(new controlLine(mouse_clicks[0], mouse_clicks[1], mouse_clicks[2], mouse_clicks[3]));
  }

  void run() {
    for (int i = objects.size()-1; i >= 0; i--) {
      controlLine x = objects.get(i);
      x.run();
    }
  }
}

//systeemi intersektioille

class intersectionSystem {
  ArrayList<intersectionObject> objects;

  intersectionSystem() {
    objects = new ArrayList<intersectionObject>();
  }

  void addObject(float x, float y, int a, int b, boolean s, boolean e) {
    objects.add(new intersectionObject(x, y, a, b, s, e));
  }

  void run() {
    for (int i = objects.size()-1; i >= 0; i--) {
      intersectionObject x = objects.get(i);
      x.run();
    }
  }
}

// Intersektion etsintä (pöllitty koodi)

float[] intersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {

  float a1, a2, b1, b2, c1, c2;
  float r1, r2, r3, r4;
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
  if ((r3 != 0) && (r4 != 0) && same_sign(r3, r4)) {
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
  if ((r1 != 0) && (r2 != 0) && (same_sign(r1, r2))) {
    //return DONT_INTERSECT;
    intersection_output[2] = 0;
    return intersection_output;
  }

  //Line segments intersect: compute intersection point.
  denom = (a1 * b2) - (a2 * b1);

  if (denom == 0) {
    //return COLLINEAR;
  }

  if (denom < 0) { 
    offset = -denom / 2;
  } else {
    offset = denom / 2 ;
  }

  // The denom/2 is to get rounding instead of truncating. It
  // is added or subtracted to the numerator, depending upon the
  // sign of the numerator.
  num = (b1 * c2) - (b2 * c1);
  if (num < 0) {
    intersect_x = (num - offset) / denom;
  } else {
    intersect_x = (num + offset) / denom;
  }

  num = (a2 * c1) - (a1 * c2);
  if (num < 0) {
    intersect_y = ( num - offset) / denom;
  } else {
    intersect_y = (num + offset) / denom;
  }

  // lines_intersect
  intersection_output[0] = intersect_x; 
  intersection_output[1] = intersect_y;
  intersection_output[2] = 1;
  return intersection_output;
}

boolean same_sign(float a, float b) {
  return (( a * b) >= 0);
}


//polygoninpiirtofunktio (tilapäinen, objektifisoitava)
void draw_polygon(intersectionObject point) {

intersectionObject temp_point = new intersectionObject();
temp_point = point;
polycoords = new ArrayList<intersectionObject>(); //en oo varma täst, huomioi tämä jos joku kusee

  //lisätään alkupiste listaan, etitään seuraava, ja loopataan kunnes pästään loppuun
  for(boolean i = true; i == true;) {
    polycoords.add(temp_point);
    
    temp_point = find_next(temp_point);
    if (temp_point == null) {
      i = false;
    } 
  }
  
  //test shape
  stroke(0,0,255);
  beginShape();
  for (int i = 0; i < polycoords.size(); i++) {
    vertex(polycoords.get(i).coords.x, polycoords.get(i).coords.y);
    print(polycoords.get(i).coords+" ");
  }
  endShape();

}

//kontrolliviivalla seuraavan pisteen etsintäfunktio
intersectionObject find_next(intersectionObject current_point) {
  println(current_point);  
  intersectionObject next_point = new intersectionObject(); next_point.coords.set(1000000,1000000); //<>//
  intersectionObject compare_point = new intersectionObject(); //<>//
  intersectionObject previous_point = new intersectionObject(); //<>//
   //<>//
  PVector current_coords = new PVector(current_point.coords.x, current_point.coords.y);  //<>//
  PVector next_coords = new PVector(1000000, 1000000);  
  PVector compare_coords = new PVector(); 
  PVector previous_coords = new PVector();
  int current_line; //<>//
  float curr_dist, comp_dist;

  //case 1. jos kontrolliviivan päätepiste, lopeta
  if (current_point.endpoint == true) {
    print("SHIT");
    return null;
  } 
   //<>//
  //case 2. TÄHÄN TARVITAAN VIELÄ KEISSI MISSÄ OLLAAN TULTU YMPYRÄ //<>//
   //<>//
  //case 3. jos polygonin eka piste //<>//
  if (polycoords.size() <= 1) {
    //etsitään kaikki kyseisen kontrolliviivan intersektiot
    for (int  i = 0; i < intersection_storage.objects.size(); i++) {
      if (intersection_storage.objects.get(i).parent_b == current_point.parent_a || intersection_storage.objects.get(i).parent_b == current_point.parent_a) { //<>//
        compare_point = intersection_storage.objects.get(i);
         //<>//
        comp_dist = dist(current_point.coords.x, current_point.coords.y, compare_point.coords.x, compare_point.coords.y); 
        curr_dist = dist(current_point.coords.x, current_point.coords.y, next_point.coords.x, next_point.coords.y); //<>//
        
        if (comp_dist < curr_dist && current_point.coords != compare_point.coords) {
          next_point = compare_point;
        } //<>//
      } //<>//
    }
  }
  
  //case 4. jos mikä tahansa muu piste
  else {
    
    previous_coords = polycoords.get(polycoords.size()-1).coords;   
    
    //katotaan ensin mikä on nykyinen viiva
    if (current_point.parent_a == polycoords.get(polycoords.size()-1).parent_a || current_point.parent_a == polycoords.get(polycoords.size()-1).parent_b) {
      current_line = current_point.parent_b;
    
      for (int  i = 0; i < intersection_storage.objects.size(); i++) {
        if (intersection_storage.objects.get(i).parent_b == current_line) {
          compare_point = intersection_storage.objects.get(i);
          
          comp_dist = dist(current_point.coords.x, current_point.coords.y, compare_point.coords.x, compare_point.coords.y); 
          curr_dist = dist(current_point.coords.x, current_point.coords.y, next_point.coords.x, next_point.coords.y);
          
         if (comp_dist < curr_dist && current_point.coords != compare_point.coords && detect_side(previous_point.coords, current_point.coords, compare_point.coords) > 0) {
            next_point = compare_point;
          }
        }
      }
    }
    else if (current_point.parent_b == polycoords.get(polycoords.size()-1).parent_a || current_point.parent_b == polycoords.get(polycoords.size()-1).parent_b) {
      current_line = current_point.parent_a;
    }
  }

  return next_point;
} //<>//


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