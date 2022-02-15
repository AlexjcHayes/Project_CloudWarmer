class titleGlobe
{
  int speed=10;
  float x;
  float y;
  float initX;
  titleGlobe(float x, float y, float initX)
  {
    this.x=x;
    this.y=y;
    this.initX=initX;
  }

  void display()
  {
    pushMatrix();
    translate(x, y);
    pushMatrix();
    rotateY(PI * frameCount / -4000);//Speed of the rotation of the Planet
    rotateX(radians(20));
    shape(TitleGlobe);
    popMatrix();
    popMatrix();
    //text(str(Switch),x,y+20);
  }
  void move()
  {

    if(Switch)
    {
      
    }else
    {
      globeSize=1;
    }
     x+=-speed;
    if ((x<initX-1))
    {
      speed=-speed;
      Switch=true;
    }
    if (((x>=initX+900)))
    {
      speed=-speed;
      Switch=false;
      //x+=-speed;
    }
  }
}
