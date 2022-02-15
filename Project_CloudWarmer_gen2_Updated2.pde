/*
-added working tabs
 -made it so that once an option is selected, you can't keep selecting it
 --Keep the tabs at the bottom on all windows (so you can change between them)
 
 --fix moving globe at the top
 --fix sizing of the word(example Frequency and Power Control
 --fix glitch switching back to the frequency tab
 --fix when setting frequency to only send it once (not a billion times)----------------------------------------------------
 */



import processing.serial.*;
tStar[] tstars= new tStar[800];
titleGlobe globe;
int r=int(random(0, 255));
int g=int(random(0, 255));
int b=int(random(0, 255));
PImage fullTitle;
PImage title;
PShape Interface;
PShape TitleGlobe;
PImage texture;
int initTimer = 60;
float starSpeed=.25;
int timer;
///Button Variables\\\\\

int leftside_X=100;
int rightside_X;
boolean fil_Toggle=false;// True = on /False = off
boolean plate_Toggle=false;// True = on /False = off
boolean comSelected = false;//find the Arduino
Serial[] autoSerial= new Serial[3];
Serial myPort;
String state;
boolean rightTabHover=false;
boolean leftTabHover=false;
String inBuffer;
int c=0;
int globeSize=25;
boolean Switch=false;
String recievedBack="";
int LF=10;//line feed
boolean skip=false;
int backspaceStart=40;
int backspaceTimer=backspaceStart;
String input ="";
PFont font;
int holdTimerStart=2;
int holdTimer=holdTimerStart;//timer for holding down Backspace
String jerryInput = "";
String jerryTransfer="";
int arcspacing=4;
int maxnum=8;//maximum number you can enter as a frequency
int frequencyTimerinitial=120;
int frequencyTimer=frequencyTimerinitial;//timer for sending the frequency to the arduino
void settings()
{
  fullScreen(P3D);
  //size(1000, 1000, P3D);
  PJOGL.setIcon("Hen Logo.png");
}
void setup()
{
  //fullScreen(P3D);
  //size(100, 100, P3D);
  background(0);
  texture= loadImage("interfaceTexture.png");
  fullTitle = loadImage("Blue_Hen_Electromagnetics.png");
  for (int i=0; i< tstars.length; i++)
  {
    tstars[i] = new tStar();
  }
  sphereDetail(40);
  noStroke();
  Interface = createShape(SPHERE, globeSize);
  Interface.setTexture(texture);
  TitleGlobe = createShape(SPHERE, globeSize);
  TitleGlobe.setTexture(texture);
  rightside_X=width-400;
  font=loadFont("font.vlw");
  title= loadImage("BlueHenelectromagnetics.png");
  state="Power";
  try {
   myPort = new Serial(this, "COM30", 9600);//comment this to turn of the serial messages
   }
   catch(RuntimeException e)
   {
   state="not_found";
   }
  if (myPort!=null)
  {
    myPort.bufferUntil(LF);
  }
  timer=initTimer;
  globe= new titleGlobe(width/2, 100, (width/2)-450);
  /*
  //printArray(Serial.list());
   
   //autoSerial=Serial.list();
   for (int i=0; i<3; i++)
   {
   println("______________________________\n the Value if i is "+i);
   try
   {
   autoSerial[i] = new Serial(this, Serial.list()[i], 9600);
   //autoSerial[i].write("JerryFind");
   } 
   catch (RuntimeException e)
   {
   println("["+i+"]"+" "+autoSerial[i]+" Is Busy");
   skip=true;
   }
   //println("["+i+"]"+" "+autoSerial[i]);
   if(skip==false)
   {
   println("AAAAAA");
   try
   {
   autoSerial[2].write("JerryFind");
   serialEvent(autoSerial[i]);
   println("We Recieved "+recievedBack);
   }catch(NullPointerException e)
   {
   
   }
   }
   //println(inBuffer+" agaga");
   if (skip)
   {
   try
   {
   //autoSerial[i].write("JerryFind");
   println(inBuffer+" agaga");
   autoSerial[i].stop();
   } 
   catch (RuntimeException e)
   {
   //Nothing is supposed to be here
   }
   }
   skip=false;
   }
   */

  /////////////////////////////////////
  // Fill the tables
  sinLUT=new float[SINCOS_LENGTH];
  cosLUT=new float[SINCOS_LENGTH];
  for (int i = 0; i < SINCOS_LENGTH; i++) {
    sinLUT[i]= (float)Math.sin(i*DEG_TO_RAD*SINCOS_PRECISION);
    cosLUT[i]= (float)Math.cos(i*DEG_TO_RAD*SINCOS_PRECISION);
  }

  numarc = 150;
  pt = new float[6*numarc]; // rotx, roty, deg, rad, w, speed
  style = new int[2*numarc]; // color, render style

  // Set up arc shapes
  int index=0;
  float prob;
  for (int i=0; i<numarc; i++) {
    pt[index++] = random(PI*2); // Random X axis rotation
    pt[index++] = random(PI*2); // Random Y axis rotation

    pt[index++] = random(60, 80); // Short to quarter-circle arcs
    if (random(100)>90) pt[index]=(int)random(8, 27)*10;

    pt[index++] = int(random(2, 50)*arcspacing); // Radius. Space them out nicely

    pt[index++] = random(4, 15); // Width of band
    if (random(100)>90) pt[index]=random(40, 60); // Width of band

    pt[index++] = radians(random(5, 30))/10; // Speed of rotation

    // get colors
    prob = random(100);
    if (prob<30) style[i*2]=colorBlended(random(1), 229, 223, 16, 0, 0, 0, 210);
    else if (prob<70) style[i*2]=colorBlended(random(1), 229, 223, 16, 0, 0, 0, 210);
    else if (prob<90) style[i*2]=colorBlended(random(1), 16, 138, 229, 0, 0, 0, 210);
    else style[i*2]=color(255, 255, 255, 220);

    if (prob<50) style[i*2]=colorBlended(random(1), 229, 205, 16, 0, 0, 0, 210);
    else if (prob<90) style[i*2]=colorBlended(random(1), 16, 188, 229, 0, 0, 0, 210);
    else style[i*2]=color(255, 255, 255, 220);

    style[i*2+1]=(int)(random(100))%3;
  }
}


void draw()
{
  //println(autoSerial[0]);
  //println(myPort==null);
  background(0);
  if (state=="not_found")
   {
   interfaceBackground();
   arcinterface();
   fill(255,0,0);
   textSize(30);
   textAlign(CENTER);
   text("Arduino not found\n Please check the port and restart the program",width/2,height-100);
   //textAlign(CORNER);
   fill(255);
   }
  if (state=="Power")
  {
    interfaceBackground();
    arcinterface();
    powerButtons();
    textAlign(LEFT);//keeps it from glitching out when switching back to frequency (Just the way I coded it)
    hoverButtons();
    fill(255);
    //text(timer,width/2,height-50);
    if (timer>0)
    {
      timer--;
    }
    if (timer<=0)
    {
      timer=0;
    }
    fill(255);
    textAlign(CENTER);
    text(recievedBack, width/2, height-150);
    textAlign(CORNER);
  }
  if (state=="Frequency")
  {
    starbackground();
    rectMode(CORNER);
    textAlign(LEFT);
    textSize(20);
    hoverButtons();
    noFill();
    stroke(255);
    strokeWeight(4);
    rectMode(CENTER);
    rect(width/2, 600, 1000, 50);//text box
    //textFont(font);
    textAlign(CENTER, TOP);
    textSize(30);
    text(input, width/2, 580);//input position
    textSize(40);
    imageMode(CENTER);
    image(fullTitle, width/2, 250);
    imageMode(CORNER);
    text("Enter a Frequency", width/2, 500);
    if(frequencyTimer>0)
    {
     frequencyTimer--; 
    }
    if(frequencyTimer<=0)
    {
     frequencyTimer=0; 
    }
    if (jerryInput.contains(".")&&jerryInput.indexOf('.')<jerryInput.length()-1)
    {
    } else if (jerryInput.contains(".")&&jerryInput.indexOf('.')==jerryInput.length()-1)
    {
      jerryInput=jerryInput+"00";
    } else if (jerryInput=="")
    {
    } else
    {
      jerryInput=jerryInput+".00";
    }
    if (myPort!=null&&key==ENTER&&frequencyTimer==0)
    {
    myPort.write(jerryInput);
    key=BACKSPACE;
    frequencyTimer=frequencyTimerinitial;
    }
    //text(jerryInput+ "   "+ jerryInput.indexOf('.')+"  "+jerryInput.length(), 200, 100);//debug display
    if (timer>0)
    {
      timer--;
    }
    if (timer<=0)
    {
      timer=0;
    }
    if (input.length()>=maxnum)
    {
      fill(255, 0, 0);
      text("The number is too large", width/2, height-300);
      fill(255);
    }
    textAlign(CENTER);
    text(recievedBack, width/2, height-150);
    textAlign(CORNER);
    //text(tommyOutput, width/2, height-220);
    //text(input.length() + "    " + backspaceTimer + "   " + tommyInput.length(),50,50);
    if (keyPressed && key==BACKSPACE&& backspaceTimer>-1)
    {
      if (backspaceTimer!=0)
      {
        backspaceTimer--;
      } else
      {
        backSpace();
      }
    } else
    {
      backspaceTimer=backspaceStart;
    }
  }
}


void serialEvent(Serial found)//recieves the data back through the serial port
{
  recievedBack=found.readString();
  //println(recievedBack);//prints the recieved text to the console
}


void starbackground()
{
  float x2=width/2;
  float y2=height/2;
  pushMatrix();
  translate(x2, y2);
  for (int i=0; i< tstars.length; i++)
  {
    tstars[i].update();
    tstars[i].show();
  }
  popMatrix();
}

void arcinterface()
{
  pushMatrix();
  int index=0;
  translate(width/2, height/2, 0);
  rotateX(PI/6);
  rotateY(PI/6);
  for (int i = 0; i < numarc; i++) {
    pushMatrix();

    rotateX(pt[index++]);
    rotateY(pt[index++]);

    if (style[i*2+1]==0) {
      stroke(style[i*2]);
      noFill();
      strokeWeight(1);
      arcLine(0, 0, pt[index++], pt[index++], pt[index++]);
    } else if (style[i*2+1]==1) {
      fill(style[i*2]);
      noStroke();
      arcLineBars(0, 0, pt[index++], pt[index++], pt[index++]);
    } else {
      fill(style[i*2]);
      noStroke();
      arc(0, 0, pt[index++], pt[index++], pt[index++]);
    }

    // increase rotation
    pt[index-5]+=pt[index]/10;
    pt[index-4]+=pt[index++]/20;

    popMatrix();
  }
  popMatrix();
}
void comFind()
{
}

void backSpace()
{
  if (keyPressed && key== BACKSPACE && input.length()>0)
  {

    if (holdTimer>0)
    {
      holdTimer--;
    }
    if (holdTimer==0)
    {
      input= input.substring(0, input.length()-1);
      holdTimer=holdTimerStart;
    }
    //background(0);
  }
}
void keyPressed()
{
  if (key== BACKSPACE && keyPressed && input.length()>0)
  {
    input= input.substring(0, input.length()-1);
    //background(0);
  } else if (key == ENTER && input.length()>0)
  {
    jerryTransfer=input.toUpperCase();
    jerryInput=trim(jerryTransfer);
    //if (jerryInput.contains(".")&&jerryInput.indexOf('.')<jerryInput.length()-1)
    //{

    //} else if(jerryInput.contains("."))
    //{
    //  jerryInput=jerryInput+"00";
    //}else
    //{
    //  jerryInput=jerryInput+".00";
    //}
    input ="";
    //displayTime= "";
  }
  if (key != BACKSPACE && key != ENTER && keyCode !=16 && input.length()<maxnum)
  {
    input = input + key;
  }
}
void interfaceBackground()
{
  starbackground();
  noFill();
  rectMode(CENTER);
  //rect(width/2,100,800,150);
  fill(255);
  rectMode(CORNER);
  imageMode(CENTER);
  image(title, width/2, 115);
  //interfaceGlobe(250, 150);//top left
  //interfaceGlobe(width-250, 150);//top right
  //interfaceGlobe(250, height-150);//bottom left
  //interfaceGlobe(width-250, height-150);//bottom right
}




void titleGlobe(float x, float y, float initX)
{
  int speed=10;

  pushMatrix();
  translate(x, y);
  pushMatrix();
  rotateY(PI * frameCount / -4000);//Speed of the rotation of the Planet
  rotateX(radians(20));
  shape(TitleGlobe);
  popMatrix();
  popMatrix();
  x+=speed;
  //moving\\\\
  if ((x<initX+100)&&(!(x<initX)))
  {
    x+=speed;
  } else
  {
    x+=-speed;
  }
}



void interfaceGlobe(float x, float y)
{
  pushMatrix();
  translate(x, y);
  pushMatrix();
  rotateY(PI * frameCount / -4000);//Speed of the rotation of the Planet
  rotateX(radians(20));
  shape(Interface);
  popMatrix();
  popMatrix();
}



void powerButtons()
{
  if (fil_Toggle==true)
  {
    fill(0, 255, 0, 135);
  } else
  {
    fill(255, 0, 0, 135);
  }
  stroke(255, 255, 255, 255);
  strokeWeight(3);
  rect(leftside_X, (height/2)-200, 300, 100, 10, 10, 10, 10);//top left
  textSize(40);
  fill(0);
  //textMode(CENTER);(Not supported by 3D rendering)
  text("Filament On", 140, (height/2)-130);
  if (fil_Toggle==false)
  {
    fill(0, 255, 0, 135);
  } else
  {
    fill(255, 0, 0, 135);
  }
  rect(leftside_X, (height/2)+100, 300, 100, 10, 10, 10, 10);//bottom left
  fill(0);
  text("Filament Off", 140, (height/2)+170);
  if (plate_Toggle==true)
  {
    fill(0, 255, 0, 135);
  } else
  {
    fill(255, 0, 0, 135);
  }
  rect(rightside_X, (height/2)-200, 300, 100, 10, 10, 10, 10);//top Right
  fill(0);
  text("Plate On", width-330, (height/2)-130);
  if (plate_Toggle==false)
  {
    fill(0, 255, 0, 135);
  } else
  {
    fill(255, 0, 0, 135);
  }
  rect(rightside_X, (height/2)+100, 300, 100, 10, 10, 10, 10);//bottom Right
  fill(0);
  text("Plate Off", width-330, (height/2)+170);

  //INTERACTION\\\\\\\\\

  if ((dist(mouseX, mouseY, leftside_X, (height/2)-200)<300)&&(mouseX>=leftside_X)&&(mouseY>=(height/2)-200)&&(mouseY<=((height/2)-200)+100)&&mousePressed&&timer<=0&&fil_Toggle==false)//top Left
  {
    fil_Toggle=true;
    if (myPort!=null)
    {
      myPort.write("filament=on");
    }
    timer=initTimer;
  }
  if ((dist(mouseX, mouseY, leftside_X, (height/2)+100)<300)&&(mouseX>=leftside_X)&&(mouseY>=(height/2)+100)&&(mouseY<=((height/2)+100)+100)&&mousePressed&&timer<=0&&fil_Toggle==true)//bottom Left
  {
    fil_Toggle=false;
    plate_Toggle= false;
    if (myPort!=null)
    {
      myPort.write("machine=off");
    }
    timer=initTimer;
  }
  if ((dist(mouseX, mouseY, rightside_X, (height/2)-200)<300)&&(mouseX>=rightside_X)&&(mouseY>=(height/2)-200)&&(mouseY<=((height/2)-200)+100)&&mousePressed&&timer<=0&&plate_Toggle==false)//top Right
  {
    plate_Toggle= true;
    fil_Toggle=true;
    if (myPort!=null)
    {
      myPort.write("plate=on");
    }
    timer=initTimer;
  }
  if ((dist(mouseX, mouseY, rightside_X, (height/2)+100)<300)&&(mouseX>=rightside_X)&&(mouseY>=(height/2)+100)&&(mouseY<=((height/2)+100)+100)&&mousePressed&&timer<=0&&plate_Toggle==true)//bottom Right
  {
    plate_Toggle= false;
    if (myPort!=null)
    {
      myPort.write("plate=off");
    }
    timer=initTimer;
  }
}
void hoverButtons()
{
  ///////////////////////////////////////Bottom Tabs\\\\\\\\\\\\\\\\\\\\\\\\\\


  if (rightTabHover==true)
  {
    fill(13, 138, 219, 100);
    stroke(50);
    strokeWeight(5);
  } else {
    fill(13, 138, 219, 255);
    stroke(50);
    strokeWeight(5);
  }
  rect(width/2, height-100, 300, 100, 0, 1000, 0, 0);// bottom Right Tab
  if (rightTabHover==true)
  {
    fill(255, 255, 255, 150);
  } else
  {
    fill(255, 255, 255, 255);
  }
  textSize(40);
  text("Power Control", (width/2)+5, height-40);
  if (leftTabHover==true)
  {
    fill(13, 138, 219, 100);
    stroke(50);
    strokeWeight(5);
  } else {
    fill(13, 138, 219, 255);
    stroke(50);
    strokeWeight(5);
  }
  rect(width/2, height-100, -300, 100, 1000, 0, 0, 0);// bottom Left Tab
  if (leftTabHover==true)
  {
    fill(255, 255, 255, 150);
  } else
  {
    fill(255, 255, 255, 255);
  }
  text("Frequency", (width/2)-250, height-40);
  if ((dist(mouseX, mouseY, width/2, (height-100))<300)&&(mouseX>=width/2)&&(mouseY>=height-100)&&(mouseY<=height)&&timer<=0)//Hovering Bottom Right Tab
  {
    rightTabHover=true;
  } else
  {
    rightTabHover=false;
  }
  if ((dist(mouseX, mouseY, width/2, (height-100))<300)&&(mouseX<=width/2)&&(mouseY>=height-100)&&(mouseY<=height)&&timer<=0)//Hovering Bottom Left Tab
  {
    leftTabHover=true;
  } else
  {
    leftTabHover=false;
  }
  if ((dist(mouseX, mouseY, width/2, (height-100))<300)&&(mouseX>=width/2)&&(mouseY>=height-100)&&(mouseY<=height)&&mousePressed&&timer<=0)//Clicking Bottom Right Tab
  {
    state="Power";
    timer=initTimer;
  }
  if ((dist(mouseX, mouseY, width/2, (height-100))<300)&&(mouseX<=width/2)&&(mouseY>=height-100)&&(mouseY<=height)&&mousePressed&&timer<=0)//Clicking Bottom Left Tab
  {
    state="Frequency";
    timer=initTimer;
  }
  fill(255, 255, 255, 255);//keeps it from interfering with the brightness of anything else
}
void cambigGEY()
{
  r=int(random(0, 255));
  g=int(random(0, 255));
  b=int(random(0, 255));
  fill(r, g, b);
  textSize(100);
  pushMatrix();
  textMode(CENTER);
  textAlign(CENTER);
  text("Cam is BIg GEY", width/2, height/2);
  textMode(CORNER);
  textAlign(CORNER);
  popMatrix();
}
