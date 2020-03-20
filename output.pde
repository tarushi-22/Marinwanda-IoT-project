import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import processing.serial.*; 
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import ddf.minim.*;
Minim minim;
AudioPlayer player;
import processing.serial.*; 

int numFish = 40;
float fishSize = 50;  // base fish length
float sizeVar = 0.5;  // factor to randomize fish length
float fishSpeed = 10;  // base fish swim speed
float speedVar = 0.5;  // factor to randomize speed
float fishVSpeed = .20;  // factor to determine fish vertical speed
float fishPace = 90000;  // milliseconds, base timin for one back-and-forth 
float colorVar = 50;  // maximum color variance (of 255)
float tankEdge = 1.5 * (1 + sizeVar) * fishSize;  // make the tank a little wider than the window
Fish[] fishes;  // array to hold all the fishies
PImage img;  // gradient image (jpg) for the background
PFont font;
Serial port,port2;  // Create object from Serial class
String val,val2;      // Data received from the serial port 

void setup() {
  smooth();
  size(1920, 1080);
  frameRate(30);
  noStroke();
  // generate the array of fishes
  fishes = new Fish[numFish];
  for (int i = 0; i < numFish; i++) {
    fishes[i] = new Fish();
  }
  // load the background image
  img = loadImage("gradient.jpg");
  font = loadFont("Gabriola-48.vlw");
  port = new Serial(this, "COM7", 9600); 
  port2= new Serial(this, "COM3", 9600);
  minim = new Minim(this);
  player = minim.loadFile("got.mp3");
}


void draw() {
  image(img, 0, 0, width, height);  // using a grdient image instead of "background()"
  for (int i = 0; i < numFish; i++) {
    fishes[i].swim();
    fishes[i].display();
  }
  if (0 < port.available() && port2.available() > 0) {  // If data is available to read,
    val = port.readStringUntil('\n');            // read it and store it in val
    val2 = port2.readStringUntil('\n');
    println(val);
    println(val2);
  }
  if ( player.isPlaying() )
  {
    player.play();
  }
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else //if ( player.position() == player.length() )
  {
    player.rewind();
    player.play();
  }
  textAlign(CENTER,TOP);
  textSize(100);
  fill(0,0,0);
  textFont(font, 100);
  text("MARINWANDA", 950, 43);
  text("_____________________________________", 950, 53);
  textAlign(TOP,LEFT);
  textSize(41);
  text(" STATUS OF TANK",380,210);
  text("_______________________________________",380,220);
  textSize(38);
  fill(256,0,0);
  text("Turbidity of water and Temperature of surrounding : ",380,260);
  text("pH of water :",380,360);
  fill(0,0,0);
  text("pH is a scale used to specify how acidic or basic \n a water-based solution is. For fishes pH should be \n around 4-8. Turbidity is a measure of the degree to \n which the waterloses its transparency due to the \n presence of suspended particulates. \n For clear water: turbidity<1 ",950,600);
  if(val!=null)
  {
    textAlign(TOP,LEFT);
    textSize(30);
    fill(0,0,0);
    textFont(font, 40);
    if(val.charAt(1)=='u')
    { String tur = val;
      text(tur,700, 300);
    }
    else
    {
    text(val,400, 300);
    text("Turbidity(avg of prev)= 0.31",700,300);
    }
  }
  else
  {
   fill(0,0,0);
   textSize(25);
   
   text("processing.....",400,300);
  }
  
  if(val2!=null)
  {
    textAlign(TOP,LEFT);
    textSize(30);
    fill(0,0,0);
    textFont(font, 40);
    text(val2,400,400);
  }
  else
  {
   fill(0,0,0);
   textSize(25);
   text("processing.....",400,400);
  }
  
}


class Fish {
  // class variables
  float fishL, fishH;  // fish size
  float ro, go, bo;  // fish base color rgb
  float r, g, b;  // instantaneous fish color rgb
  int cVar;  // fish color variance range
  float fishSpdX, fishSpdY;  // maximum fish speed
  float x, y, spdX, spdY;  // instantaneous fish position and speed
  float pace, offset;  // parameters to establish how quickly fish traverse sin wave and start point
  float spdRatio;  // parameter to determine relative speed of fish
  float dir;  // which direction is fish swimming (-1 or 1)
  
  // constructor
  Fish() {
    // randomize fish size
    fishL = fishSize * random(1 - sizeVar, 1 + sizeVar);
    fishH = fishL * random (0.2, 0.80);
    // base fish color
    cVar = int(random(0.5 * colorVar, colorVar));  // color range for this fish
    int i = int(random(6));
    ro = red(chooseColor(i, cVar));
    go = green(chooseColor(i, cVar));
    bo = blue(chooseColor(i, cVar));  
    // initial position, speed, and pace
    x = random(width);
    y = random(0.75 * fishH, height - 0.75 * fishH);
    fishSpdX = fishSpeed * random(1 - speedVar, 1 + speedVar);  // random maximum speed for this fish
    fishSpdY = fishSpdX * random(0.5 * fishVSpeed, fishVSpeed);  // random maximum vertical speed for this fish
    pace = random(0.5 * fishPace, fishPace);  // milliseconds
    offset = random(pace);  // offset initial speed
  }
  
  void swim() {
    // update fish speed using param() to generate smooth speed profile
    spdX = fishSpdX * param(offset, pace);
    spdY = fishSpdY * param(2 * offset, 1.5 * pace);  // adjust vertical swim at a different pace than horizontal
    spdRatio = abs(spdX / fishSpdX);  
    dir = spdX / abs(spdX);  // which direction is fish swimming (-1 or 1)
    // calculate new position
    x += spdX;
    y += spdY;
    // check if at edge of tank
    if ((x + fishL/2 > width + tankEdge) || (x - fishL/2) < 0 - tankEdge) {
      fishSpdX *= -1;
    }
    if ((y + fishH/2 > height + tankEdge) || (y - fishH/2) < 0 - tankEdge) {
      fishSpdY *= -1;
    }
  }
  
  void display(){
    // vary the fish color over time
    r = ro + param(offset, 0.5 * pace) * cVar;
    g = go + param(offset * 1.5, 0.5 * pace) * cVar;
    b = bo + param(offset * 3, 0.5 * pace) * cVar;
    fill(r, g, b);
    /* adjust apparent fish width to indicate reverse in direction
      as fish slows down to turn, make body shorter. */
    float showFishL = fishL;
    if (spdRatio <= 0.33) {
      showFishL = map(spdRatio, 0, 0.33, 0.33, 1.0) * fishL;
    }
    // display the fish body
    ellipse(x, y, showFishL, fishH);
    // display the fish tail, which also shifts as fish slows and turns
    float tailL = 0.65 * fishL * dir;
    if (spdRatio <= 0.33) {
      tailL *= map(spdRatio, 0, 0.33, 0.20, 1.0);
    }
    triangle(x - tailL, y + fishH / 2, x - tailL, y - fishH / 2, x - 0.6 * tailL, y);
    // ... and the fish eyes! Eyes shift around as fish slows and turns
    fill(0);
    float eyeSize = 0.20 * fishH;
    if (spdRatio > 0.33) {
      // eye in default position normally
      ellipse(x + dir * showFishL / 4, y - fishH / 6, eyeSize * showFishL/fishL, eyeSize);
    } else {
      // eye shifts and narrows as fish turns
      float eyeMax = fishL / 4;
      float eyeMin = 0.33 * fishL / 2;
      float eyeSpc = map(spdRatio, 0, 0.33, -eyeMin, eyeMax);
      ellipse(x + dir * eyeSpc, y - fishH / 6, eyeSize * showFishL/fishL, eyeSize);
    }
  }
  
}


/* function to return a sinusoidal varying parameter over a time period
    "extent" controls the time for the entire wavelength to occur
    "shift" sets a random start position on sin wave (so every fish doesn't 
    change at same rate) 
    
    The param function lets the fish change speed, color, etc. smoothly */
float param(float shift, float extent) {
  float t = (millis() + shift) % extent;
  float a = map (t, 0, extent, 0, TWO_PI);
  return sin(a);
}
    

/* funtion used by Fish class constructor to choose fish colors.
  This function contrains the color combinations to the 6 permutations of 
  (0, 255, random) so as to generate brighter colors (or avoid drab ones).
  The "c" argument offsets the color selected slightly to allow a buffer for
  the color to vary. */
color chooseColor(int i, int c) {
  float r = 0;
  float g = 0;
  float b = 0;
  switch(i) {
    case 0:
      r = c;
      g = 255 - c;
      b = random(c, 256 - c);
      break; 
    case 1:
      r = c;
      g = random(c, 256 - c);
      b = 255 - c;
      break;   
    case 2:
      r = 255 - c;
      g = c;
      b = random(c, 256 - c);
      break;   
    case 3:
      r = random(c, 256 - c);
      g = c;
      b = 255 - c;
      break;   
    case 4:
      r = 255 - c;
      g = random(c, 256 - c);
      b = c;
      break;   
    case 5:
      r = random(c, 256 - c);
      g = 255 - c;
      b = c;
      break; 
  }
  return color(r, g, b);
}  
