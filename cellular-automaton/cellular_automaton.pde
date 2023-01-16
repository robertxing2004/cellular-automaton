// global variables and important stuff DO NOT CHANGE unless otherwise indicated
int n = 100;
float cellSize;
float frames = 5; // frame rate control, can be changed, but keep below 15 for best results
int offset = 50;

color[][] cells = new color[n][n];
color[][] nextGen = new color[n][n];

color glacier = color(175, 215, 230);
color terrain = color(0, 175, 45);
color water = color(0, 100, 255);
color ice1 = color(255); // white, aerated icebergs
color ice2 = color(200, 255, 250); // blue, dense icebergs

float calvingProb = 0.003; // can be changed, but keep between 0.001 and 0.01 to ensure proper model functionality
float meltingProb = 0.015; // can be changed, values between 0.01 and 0.03 for best results

void setup() {
  size(800, 800);
  cellSize = (width-2*offset)/n;
  firstGen();
}

void draw() {
  frameRate(frames);
  background(255);
  for(int i=0; i<n; i++) {
    float y = offset + i*cellSize;
    for(int j = 0; j<n; j++) {
      float x = offset + j*cellSize;
      fill(cells[i][j]);
      square(x, y, cellSize);
    }
  }
  setNextGen();
  newCells();
}

void firstGen() {
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
      if(i <= 20) // makes the first 20 layers of cells (from the top) glaciers
        if(i == 20) { 
          int a  = int(random(1,10)); // this makes a rough, uneven edge. without this, the edge of the glacier would be a straight line
          if(a < 3)
            cells[i][j] = water;
          else
            cells[i][j] = glacier;
          }
        else {
          cells[i][j] = glacier;
        }
      else
        cells[i][j] = water;
    }
  }
}

void setNextGen() { // prepares the new generation of cells
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
      int numWater = 0;
      int numGlacier = 0;
      for(int a = -1; a <= 1; a++) {  //a=-1, a = 0, a = 1
        for(int b = -1; b <= 1; b++) {  //b=-1, b=0,   b=1
          try {
            if(cells[i+a][j+b] == water && !(a==0 && b==0)) // counts number of neighbouring water cells, to be used in the calving probability calculations
              numWater++;      
            else if(cells[i+a][j+b] == glacier && !(a==0 && b==0)) // counts number of neighbouring glacier cells, to be used
              numGlacier++;
          }
          catch( Exception e ) {
          }
        }
      }
      if(cells[i][j] == glacier) {
        if(numWater >= 2) {
          float a = random(0,1);
          if(a < (calvingProb + (numGlacier/1000))) // calculates calving probability
            if(numGlacier >= 5) {
              nextGen[i][j] = ice2;
              nextGen[i][j-1] = ice2; // creates blue glaciers that are two cells wide if breaking off from a dense part of the glacier
            }
            else
              nextGen[i][j] = ice1; // creates white single-cell glaciers if breaking off from an unstable part of the glacier
          else
            nextGen[i][j] = glacier;
        }
        else
          nextGen[i][j] = glacier;
      }
      else if(cells[i][j] == ice1 || cells[i][j] == ice2) // ensures iceberg movement
        nextGen[i][j] = water;
      else if(cells[i][j] == water)
        if(cells[i-1][j] == ice2) { // checks if cell above any given cell is a dense iceberg
          float a = random(0,1);
          if(a < ((i/10)*meltingProb)) // calculates the melting probability for a dense iceberg
            nextGen[i][j] = water; // if the iceberg melts, then the cell remains as an ocean cell
          else
            nextGen[i][j] = cells[i-1][j]; // if the cell does not melt, it takes on the same colour as the iceberg above it
        }
        else if(cells[i-1][j] == ice1) { // checks if cell above any given cell is an aerated iceberg
          float a = random(0,1);
          if(a < ((i/5)*meltingProb)) // calculates the melting probability for an aerated iceberg
            nextGen[i][j] = water; // if the iceberg melts, then the cell remains as an ocean cell
          else
            nextGen[i][j] = cells[i-1][j]; // if the cell does not melt, it takes on the same colour as the iceberg above it
        }
        else
          nextGen[i][j] = water; // if there are no icebergs above it, the ocean stays as it is
    }
  }
}

void newCells() { // overwrites the cell values
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
      cells[i][j] = nextGen[i][j];
    }
  }
}
