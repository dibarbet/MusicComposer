import ddf.minim.analysis.*;
import java.util.ArrayList;

import processing.core.*;
import ddf.minim.*;
import ddf.minim.ugens.*;



 
  
  public int curOctave;
  public int curInstrument;
  
  public float nStartX, nStartY;
  public float nEndX, nEndY;
  public Boolean started, completed;
  
  public int NUMOCTAVES = 4;
  public int NUMINSTRUMENTS = 4;
  
  
  
  //Timings
  public int TIME1;
  public int TIME2;
  public int TIME3;
  public int TIME4;
  int[] times;
  
  int[] numLoops;
  
  
  //Screen resolution, not garunteed to work optimally if changed (kinda works at 1280/720)
  public int RESOLUTION_X = 1920;
  public int RESOLUTION_Y = 1080;
  
  
  //Center position of instrument
  public float CENTER_X;
  public float CENTER_Y;
  
  //Corresponds to the 0 pitch
  //public float BASE_RADIUS = 45f;
  public float BASE_RADIUS = RESOLUTION_Y / 24f;
  public float MAX_RADIUS = BASE_RADIUS*12f;
  
  //Loop start position
  public float LOOPSTART_X;
  public float LOOPSTART_Y;
  public vec LOOPSTART;
  public int LOOPCOUNT = 10;
  
  //Note options
  public int chordColor;
  public Boolean snapNotes;
  public float snapLevel = 1f;
  public Boolean doChord;
  public Chord chordType;
  //Average or root is note
  public Boolean doRoot;
  //Equitempered chord or just chord
  public Boolean doEqui;
  
  
  int MAJOR_COLOR = color(0,0,255,255);
  int MINOR_COLOR = color(0,0,125,255);
  int DIMINISHED_COLOR = color(125, 125,0,255);
  int AUGMENTED_COLOR = color(255,255,0,255);
  int SUSPENDED_2ND_COLOR = color(125,0,125,255);
  int SUSPENDED_4TH_COLOR = color(255,0,255,255);
  
  
  
  //Base freq for conversion
  public static float BaseFrequency = 220;
  public Minim m = new Minim(this);
  public AudioOutput ao;
  public Boolean playing = false;
  
  public float M_2PI = (float)Math.PI * 2;
  
  public float zoom = 1f;
  public Boolean zoomed;
  
  public Boolean spacePressed = false;
  public Boolean editStart = true;
  public int editIndex;
  
  ArrayList<Float> Intervals = new ArrayList<Float>();
  float NUM_PARTITIONS_PER_BEAT = 2;
  
  
  //Note data
  public Instrument[][] DATA;
  
  public void settings()
  {
    //Eclipse requires this here
    size(RESOLUTION_X, RESOLUTION_Y);
  }
  
  public void setup()
  {
    //Set starting octaves
    curOctave = 0;
    curInstrument = 0;
    
    //Nothing from mouse yet
    started = false;
    completed = false;
    
    //Set center point for circle
    CENTER_X = RESOLUTION_X / 2f;
    CENTER_Y = RESOLUTION_Y / 2f;
    
    //Set start point to 90 deg up
    LOOPSTART_X = CENTER_X;
    LOOPSTART_Y = CENTER_Y - (RESOLUTION_Y / 3);
    LOOPSTART = V(P(CENTER_X, CENTER_Y), P(LOOPSTART_X, LOOPSTART_Y));
    
    //some menu options
    doChord = false;
    chordColor = color(0,0,0);
    snapNotes = true;
    chordType = Chord.MAJOR;
    doRoot = true;
    doEqui = true;
    
    
    
    zoomed = false;
    
    
    
    bRightPX = new float[SMOOTH_BUFFER_SIZE];
    for(int i = 0; i < SMOOTH_BUFFER_SIZE;i++)
    {
      bRightPX[i] = 0f;
    }
    bLeftPX = new float[SMOOTH_BUFFER_SIZE];
    for(int i = 0; i < SMOOTH_BUFFER_SIZE;i++)
    {
      bLeftPX[i] = 0f;
    }
    tRightPX = new float[SMOOTH_BUFFER_SIZE];
    for(int i = 0; i < SMOOTH_BUFFER_SIZE;i++)
    {
      tRightPX[i] = 0f;
    }
    tLeftPX = new float[SMOOTH_BUFFER_SIZE];
    for(int i = 0; i < SMOOTH_BUFFER_SIZE;i++)
    {
      tLeftPX[i] = 0f;
    }
    index = 0;
    
    uiPts = new pt[7];
    pt topPt = P(CENTER_X, CENTER_Y);
    topPt.add(0, -RESOLUTION_Y/3);
    pt botPt = P(CENTER_X, CENTER_Y);
    botPt.add(0, RESOLUTION_Y/3);
    pt leftPt = P(CENTER_X, CENTER_Y);
    leftPt.add(-RESOLUTION_X/3, 0);
    pt rightPt = P(CENTER_X, CENTER_Y);
    rightPt.add(RESOLUTION_X/3, 0);
    
    pt topRight = P(CENTER_X, CENTER_Y);
    topRight.add(RESOLUTION_X/4, -RESOLUTION_Y/4);
    pt botRight = P(CENTER_X, CENTER_Y);
    botRight.add(RESOLUTION_X/4, RESOLUTION_Y/4);
    
    pt topLeft = P(CENTER_X, CENTER_Y);
    topLeft.add(-RESOLUTION_X/4, -RESOLUTION_Y/4);
    pt botLeft = P(CENTER_X, CENTER_Y);
    botLeft.add(-RESOLUTION_X/4, RESOLUTION_Y/4);
    
    uiPts[0] = P(CENTER_X, CENTER_Y);
    uiPts[1] = leftPt;
    uiPts[2] = rightPt;
    uiPts[3] = topLeft;
    uiPts[4] = botLeft;
    uiPts[5] = topRight;
    uiPts[6] = botRight;
    
    //Set background
    background(255);
    loadHappyBirthday();
    //loadDefault();
  }
  
  private void loadDefault()
  {
    //TIMINGS
    TIME1 = 4;
    TIME2 = 2;
    TIME3 = 6;
    TIME3 = 8;
    
    numLoops = new int[]
    {
      5,5,5,5
    };
    times = new int[]
    {
      TIME1,TIME2,TIME3,TIME4
    };
    //Create our data holder
    //rows correspond to octaves
    //columns correspond to instruments within an octave
    DATA = new Instrument[NUMOCTAVES][];
    for(int i = 0; i < NUMOCTAVES; i++)
    {
      DATA[i] = new Instrument[NUMINSTRUMENTS];
      for(int j = 0; j < NUMINSTRUMENTS; j++)
      {
        DATA[i][j] = new Instrument(times[j],numLoops[j], InstrumentType.DEFAULTINSTRUMENT);
      }
    }
  }
  
  private void loadHappyBirthday()
  {
    //TIMINGS
    TIME1 = 27;
    TIME2 = 27;
    TIME3 = 2;
    TIME3 = 4;
    
    numLoops = new int[]
    {
      2,2,2,2
    };
    times = new int[]
    {
      TIME1,TIME2,TIME3,TIME4
    };
    DATA = new Instrument[NUMOCTAVES][];
    for(int i = 0; i < NUMOCTAVES; i++)
    {
      DATA[i] = new Instrument[NUMINSTRUMENTS];
      for(int j = 0; j < NUMINSTRUMENTS; j++)
      {
        DATA[i][j] = new Instrument(times[j],numLoops[j], InstrumentType.DEFAULTINSTRUMENT);
      }
    }
    ArrayList<Note> ns = new ArrayList<Note>();
    ArrayList<Note> ns2 = new ArrayList<Note>();
    ArrayList<Note> ns3 = new ArrayList<Note>();
    ns.add( new Note(7, 2, 0.5, curOctave));
    ns.add( new Note(7, 2.5, 0.5f, curOctave));
    ns3.add(new Note(0, 3, 3, curOctave+1, Chord.MAJOR, true, true));
    ns.add( new Note(9, 3, 1, curOctave));
    ns.add( new Note(7, 4, 1, curOctave));
    ns2.add( new Note(0, 5, 1, curOctave+1));
    ns3.add(new Note(7, 6, 3, curOctave+1, Chord.MAJOR, true, true));
    ns.add( new Note(11, 6, 2, curOctave));
    ns.add( new Note(7, 8, 0.5, curOctave));
    ns.add( new Note(7, 8.5, 0.5, curOctave));
    //ns3.add(new Note(7, 0, 3, curOctave, Chord.MAJOR, true, true));
    ns.add( new Note(9, 9, 1, curOctave));
    ns.add( new Note(7, 10, 1, curOctave));
    ns2.add( new Note(2, 11, 1, curOctave+1));
    ns3.add(new Note(0, 12, 3, curOctave+1, Chord.MAJOR, true, true));
    ns2.add( new Note(0, 12, 2, curOctave+1));
    ns.add( new Note(7, 14, 0.5, curOctave));
    ns.add( new Note(7, 14.5, 0.5, curOctave));
    ns3.add(new Note(0, 15, 3, curOctave+1, Chord.MAJOR, true, true));
    ns2.add( new Note(7, 15, 1, curOctave+1));
    ns2.add( new Note(4, 16, 1, curOctave+1));
    ns2.add( new Note(0, 17, 1, curOctave+1));
    ns3.add(new Note(5, 18, 3, curOctave+1, Chord.MAJOR, true, true));
    ns.add( new Note(11, 18, 1, curOctave));
    ns.add( new Note(9, 19, 1, curOctave));
    ns2.add( new Note(5, 20, 0.5, curOctave+1));
    ns2.add( new Note(5, 20.5, 0.5, curOctave+1));
    ns3.add(new Note(7, 21, 3, curOctave+1, Chord.MAJOR, true, true));
    ns2.add( new Note(4, 21, 1, curOctave+1));
    ns2.add( new Note(0, 22, 1, curOctave+1));
    ns2.add( new Note(2, 23, 1, curOctave+1));
    ns3.add(new Note(0, 24, 3, curOctave+1, Chord.MAJOR, true, true));
    ns2.add( new Note(0, 24, 2, curOctave+1));
    DATA[curOctave][curInstrument].notes = ns;
    DATA[curOctave+1][curInstrument].notes = ns2;
    DATA[curOctave+1][curInstrument+1].notes = ns3;
  }
  
  float[] bRightPX;
  float[] bLeftPX;
  float[] tRightPX;
  float[] tLeftPX;
  int SMOOTH_BUFFER_SIZE = 10;
  int index;
  pt[] uiPts;

  float max1 = -Float.MAX_VALUE;
  float min1 = Float.MAX_VALUE;
  
  public void draw()
  {
    if (!playing)
    {
      stroke(255);
      fill(255);
      rect(0,0,RESOLUTION_X, RESOLUTION_Y);
      //pushMatrix();
      if(zoomed)
      {
        translate(mouseX, mouseY);
        scale(zoom);
        translate(-mouseX, -mouseY);
      }
      
      //popMatrix();
      stroke(0);
      drawUIInfo();
      drawStaticUI();
      getNoteData();
      drawNoteData();
    }
    else
    {
      fill(0);
      noStroke();
      rect(0,0,RESOLUTION_X, RESOLUTION_Y);
      //ao.sampleRate()
      FFT fft = new FFT(ao.mix.size(), ao.sampleRate()/16);
      fft.forward(ao.mix);    
      /*
      stroke(125,125,125,50);
      for (int i = 0; i < fft.specSize(); i++)
      //for (int i = 0; i < 4; i++)
       {
         // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
         line(i, height, i, height - fft.getBand(i) * 4);
         
         //println(fft.getBand(i));
       }*/
      int[] freqs = new int[] {0, 0, 0, 0};
      //float bSize = ao.sampleRate() / 8;
      float bSize = fft.specSize() / 8;
      //for(int i =0; i < ao.sampleRate()/2; i++)
      float avgAmp = 0;
      for(int i =0; i < fft.specSize(); i++)
      {
        float amp2 = fft.getBand(i) * 4;
        avgAmp += fft.getBand(i);
        if (amp2 >  200)
        {
          /*
          if (i > 350)
          {
            freqs[2] += 1;
            freqs[3] += 1;
          }
          if (i <= 350)
          {
            freqs[0]+= 1;
            freqs[1]+= 1;
          }*/
          
          if (i > 350 && i <= 800)
          {
            freqs[2] += 1;
          }
          if (i > 800)
          {
            freqs[3] += 2;
          }
          
          if (i <= 200)
          {
            freqs[0] += 1;
          }
          if (i <= 350)
          {
            freqs[1] += 1;
          }
          
        }
      }
      avgAmp = avgAmp / fft.specSize();
      float sum = freqs[0] + freqs[1] + freqs[2] + freqs[3];
      //prevent NaN
      if (sum == 0) sum = 1;
      //println("freqs: " + freqs[0] + ", " + freqs[1] + ", " + freqs[2] + ", " + freqs[3]);
       
      stroke(255);
      
      index = index % SMOOTH_BUFFER_SIZE;
      float bRightFrac  = freqs[0] / sum;
      float smoother = averageSmoothing(index, bRightPX);
      float factor = 0.5;
      if (freqs[0] > freqs[3]) factor = 0.8;
      float bRightAmt = smoother*RESOLUTION_Y*factor;
      
      bRightPX[index] = bRightFrac;
      float bLeftFrac = freqs[1] / sum;
      smoother = averageSmoothing(index, bLeftPX);
      factor = 0.5;
      if (freqs[1]/2f > freqs[2]) factor = 0.8;
      float bLeftAmt = smoother*RESOLUTION_Y*factor;
      bLeftPX[index] = bLeftFrac;
      float tRightFrac = freqs[2] / sum;
      smoother = averageSmoothing(index, tRightPX);
      factor = 0.5;
      if (freqs[2] > freqs[1]/2f) factor = 0.8;
      float tRightAmt = smoother*RESOLUTION_Y*factor;
      tRightPX[index] = tRightFrac;
      float tLeftFrac = freqs[3] / sum;
      smoother = averageSmoothing(index, tLeftPX);
      factor = 0.5;
      if (freqs[3] > freqs[0]/2f) factor = 0.8;
      float tLeftAmt = smoother*RESOLUTION_Y*factor;
      tLeftPX[index] = tLeftFrac;
      
      
      index++;
      
      //pt topPt = uiPts[0];
      pt centerPt = uiPts[0];
      pt leftPt = uiPts[1];
      pt rightPt = uiPts[2];
      
      //println(bRightAmt);
      //println(smoother);
      pt topRightUI = uiPts[5];
      vec tR = V(P(RESOLUTION_X, 0), P(CENTER_X, CENTER_Y)).normalize();
      tR = S(-tRightAmt, tR);
      pt topRight = P(topRightUI, tR);
      //if (topRight.x > RESOLUTION_X) topRight.x = RESOLUTION_X;
      //if (topRight.y < 0) topRight.y = 0;
      //uiPts[6] = topRight;
      pt botRightUI = uiPts[6];
      vec bR = V(P(RESOLUTION_X, RESOLUTION_Y), P(CENTER_X, CENTER_Y)).normalize();
      bR = S(-bRightAmt, bR);
      pt botRight = P(botRightUI, bR);
      //if (botRight.x > RESOLUTION_X) botRight.x = RESOLUTION_X;
      //if (botRight.y > RESOLUTION_Y) botRight.y = RESOLUTION_Y;
      //uiPts[7] = botRight;
      
      pt topLeftUI = uiPts[3];
      vec tL = V(P(0,0), P(CENTER_X, CENTER_Y)).normalize();
      tL = S(-tLeftAmt, tL);
      pt topLeft = P(topLeftUI, tL);
      //if (topLeft.x < 0) topLeft.x = 0;
      //if (topLeft.y < 0) topLeft.y = 0;
      //uiPts[4] = topLeft;
      pt botLeftUI = uiPts[4];
      vec bL = V(P(0, RESOLUTION_Y), P(CENTER_X, CENTER_Y)).normalize();
      bL = S(-bLeftAmt, bL);
      pt botLeft = P(botLeftUI, bL);
      //if (botLeft.x < 0) botLeft.x = 0;
      //if (botLeft.y > RESOLUTION_Y) botLeft.y = RESOLUTION_Y;
      //uiPts[5] = botLeft;
      
      //println(botLeft.x);
      float lct = tLeftFrac * 10;
      float lcb = bLeftFrac * 10;
      int leftColorTop = color(255, 0, 0, lct);
      int leftColorBot = color(0, 0, lcb);
      
      float rct = tRightFrac * 10;
      float rcb = bRightFrac * 10;
      int rightColorTop = color(255, 0, 0, rct);
      int rightColorBot = color(0, 0, 255, rcb);
      
      int red = color(255,0,0,255);
      int blue = color(0,0,255,255);
      
      avgAmp = avgAmp / 2 + 0.25f;
      
      for(float i = 0; i <= 1; i += 0.0001)
      {
        pt p = N(0, centerPt, 0.25f, botLeft, .5f, leftPt, .75f, topLeft, 1, centerPt, i);
        pt p2 = N(0, centerPt, 0.25f, botRight, .5f, rightPt, .75f, topRight, 1, centerPt, i);
        
        /*
        pt p = N(0, centerPt, 1/3f, botLeft, 2/3f, topLeft, 1, centerPt, i);
        pt p2 = N(0, centerPt, 1/3f, botRight, 2/3f, topRight, 1, centerPt, i);
        */
        /*
        pt p = N(0, leftPt, 0.25f, botLeft, .5f, centerPt, .75f, topRight, 1, rightPt, i);
        pt p2 = N(0, leftPt, 0.25f, topLeft, .5f, centerPt, .75f, botRight, 1, rightPt, i);
        */
        
        int colorLeft = lerpColor(leftColorBot, leftColorTop, i);
        int colorRight = lerpColor(rightColorBot, rightColorTop, i);
        drawPt(p, 2f, colorLeft);
        drawPt(p2, 2f, colorRight);
      }
      int white = color(255,255,255,255);
      
      drawPt(centerPt, 10, white);
      drawPt(topRight, 10, white);
      drawPt(botRight, 10, white);
      drawPt(topLeft, 10, white);
      drawPt(botLeft, 10, white);
      drawPt(leftPt, 10, white);
      drawPt(rightPt, 10, white);
      
    }
  }
  
  public float FreqToPitch(float freq)
  {
    Newton Newton = new Newton();
    return 12*(float)Newton.log2(freq/BaseFrequency);
  }
  
  void drawPt(pt p, float radius, int c)
  {
    noStroke();
    fill(c);
    ellipseMode(RADIUS);
    ellipse(p.x,p.y, radius, radius);
  }
  
  private float averageSmoothing(int index, float[] px)
  {
    float tot = 0;
    float w = 0.5f;
    for(int i = 0; i < px.length;i++)
    {
      w = 1-Math.abs((index-i))/px.length;
      tot += (px[i]*w);
    }
    return tot / px.length;
  }
  
  private pt N(float a, pt A, float b, pt B, float t) {
        return P(A.x+(t-a)/(b-a)*(B.x-A.x), A.y+(t-a)/(b-a)*(B.y-A.y));
    }

    private pt N(float a, pt A, float b, pt B, float c, pt C, float t) {
        return N(a, N(a, A, b, B, t), c, N(b, B, c, C, t), t);
    }
    
    private pt N(float a, pt A, float b, pt B, float c, pt C, float d, pt D, float t) {
        return N(a, N(a, A, b, B, c, C, t), d, N(b, B, c, C, d, D, t), t);
    }
    
    private pt N(float a, pt A, float b, pt B, float c, pt C, float d, pt D, float e, pt E, float t) {
        return N(a, N(a, A, b, B, c, C, d, D, t), e, N(b, B, c, C, d, D, e, E, t), t);
    }
  
  private void playNotes()
  {
    ao.pauseNotes();
    for(int i = 0; i < NUMOCTAVES; i++)
    {
      for(int j = 0; j < NUMINSTRUMENTS; j++)
      {
        PlayInstrument(DATA[i][j]);
      }
    }
    ao.resumeNotes();
  }
  
  private void PlayInstrument(Instrument i)
  {
    if (i != null && i.notes.size()>0)
    {
      i.PlayNotes(ao);
    }
    
  }
  
  
  
  private void drawStaticUI()
  {
    //Get the current instrument + loop time
    int tNum = 0;
    if (curInstrument == 0)
    {
      tNum = TIME1;
    }
    else if (curInstrument == 1)
    {
      tNum = TIME2;
    }
    else if (curInstrument == 2)
    {
      tNum = TIME3;
    }
    else if (curInstrument == 3)
    {
      tNum = TIME4;
    }
    //Draw instrument with loop time at center
    drawCircle(CENTER_X, CENTER_Y,BASE_RADIUS, tNum);
    /*
    pushMatrix();
    stroke(0);
    strokeWeight(2);
    fill(0);
    vec scaled = S(BASE_RADIUS*12f, LOOPSTART);
    line(CENTER_X, CENTER_Y, scaled.x, scaled.y);
    popMatrix();*/
    //draw time lines
    drawTimeSnaps();
    drawLoopTime(CENTER_X, CENTER_Y, BASE_RADIUS, tNum);
    popMatrix();

  }
  
  private void drawLoopTime(float xCenter, float yCenter, float radius, int circleNum)
  {
    //draw number at center of circle
    strokeWeight(1);
    stroke(100,100,100,50);
    fill(255);
    ellipse(xCenter, yCenter, radius, radius);
    fill(0);
    int tSize = 32;
    textSize(tSize);
    text(circleNum, xCenter-(tSize/2.5f), yCenter+(tSize/2.5f));
  }
  
  /**
   * Draws an instrument, has loop time written in middle
   * Circles radiating outwards correspond to semitones
   * @param xCenter; center of the circles
   * @param yCenter; center of the circles
   * @param radius; radius of the main circle
   * @param circleNum; timeloop for the circle
   */
  private void drawCircle(float xCenter, float yCenter, float radius, int circleNum)
  {
    pushMatrix();
    ellipseMode(RADIUS);
    
    for(int i = 12; i > 0; i--)
    {
      noFill();
      strokeWeight(1);
      stroke(100,100,100,50);
      float nRadius = radius*(i);
      //erase previous stuff
      ellipse(xCenter, yCenter, nRadius, nRadius);
      /**
       * Testing adding more circles doesn't work atm
       */
      if (zoom > 2.0 && zoomed)
      {
        float incRadius = Math.abs(nRadius -(radius*(i-1)))/10;
        float tenRadius = nRadius - incRadius;
        for(int j = 0; j < 9; j++)
        {
          pushMatrix();
          strokeWeight(0.5f);
          stroke(50,50,50,20);
          noFill();
          ellipse(xCenter, yCenter, tenRadius, tenRadius);
          tenRadius -= incRadius;
          popMatrix();
        }
      }
      //*/
      
    }
  }
  
  
  private void drawUIInfo()
  {
    pushMatrix();
    scale(RESOLUTION_X / 1920f);
    stroke(0);
    int tSize = 32;
    textSize(tSize);
    fill(255);
    rect(25,55,380,560);
    String instructions = "Variable(Keys): Value";
    textSize(24);
    fill(0);
    text(instructions, 30, 50);
    String instrument = "Instrument(1,2,3,4): " + (curInstrument+1);
    String octave = "Octave(UP/DOWN): " + (curOctave + 1);
    String snap = "Semitone-snap(n/N-all): " + snapNotes.toString();
    String snap2 = "Semitone-snap level([]): " + snapLevel;
    String chord1 = "Do Chord(c): " + doChord;
    String chord2 = "Do Chord all(C): N/A";
    String chord3 = "Chord(M,m,a,d,s,S): ";
    String chord4 = " "+ chordType;
    String chord5 = "Just Chord(j): " + !doEqui;
    String chord6 = "Root has pitch(r): " + doRoot;
    String plays = "Play/Play all/Stop(p/P/q): N/A";
    String erase = "Erase current(e): N/A";
    String undo = "Undo last placed(z): N/A";
    String zoom1 = "Zoom(+/- + rightclick-toggle): ";
    String zoom2 = " " + zoomed + "; " + zoom;
    String intervalSnap = "Snap to times(I/i): N/A";
    String quit = "Quit sketch(q): N/A";
    text(instrument, 30, 80);
    text(octave, 30, 110);
    text(snap, 30, 140);
    text(snap2, 30, 170);
    text(chord1, 30, 200);
    text(chord2, 30, 230);
    text(chord3, 30, 260);
    text(chord4, 30, 290);
    text(chord5, 30, 320);
    text(chord6, 30, 350);
    text(plays, 30, 380);
    text(erase, 30, 410);
    text(undo, 30, 440);
    text(zoom1, 30, 470);
    text(zoom2, 30, 500);
    text(intervalSnap, 30, 530);
    text(quit, 30, 560);
    popMatrix();
    
    pushMatrix();
    translate(RESOLUTION_X - RESOLUTION_X/6f, 80f);
    scale(RESOLUTION_X / 1920f);
    fill(255);
    rect(-5,-25,300, 200);
    fill(0);
    String majorS = "Major Color: ";
    String minorS = "Minor Color: ";
    String dimS = "Diminished Color: ";
    String augS = "Augmented Color: ";
    String sus2S = "Susp. 2nd Color: ";
    String sus4S = "Susp. 4th Color: ";
    text(majorS, 0, 0);
    text(minorS, 0, 30);
    text(dimS, 0, 60);
    text(augS, 0, 90);
    text(sus2S, 0, 120);
    text(sus4S, 0, 150);
    noStroke();
    fill(MAJOR_COLOR);
    rect(250, -20, 20, 20);
    fill(MINOR_COLOR);
    rect(250, 10, 20, 20);
    fill(DIMINISHED_COLOR);
    rect(250, 40, 20, 20);
    fill(AUGMENTED_COLOR);
    rect(250, 70, 20, 20);
    fill(SUSPENDED_2ND_COLOR);
    rect(250, 100, 20, 20);
    fill(SUSPENDED_4TH_COLOR);
    rect(250, 130, 20, 20);
    popMatrix();
    //popMatrix();
  }
  
  void drawNoteData()
  {
    pushMatrix();
    ArrayList<Note> ns = DATA[curOctave][curInstrument].notes;
    float timing = DATA[curOctave][curInstrument].loopTime;
    strokeWeight(4);
    noFill();
    for(int i = 0; i < ns.size(); i++)
    {
      Note n = ns.get(i);
      if (n != null)
      {
        if (n.isChord)
        {
          if (n.chord == Chord.MAJOR)
          {
            chordColor = MAJOR_COLOR;
          }
          else if (n.chord == Chord.MINOR)
          {
            chordColor = MINOR_COLOR;
          }
          else if (n.chord == Chord.DIMINISHED)
          {
            chordColor = DIMINISHED_COLOR;
          }
          else if (n.chord == Chord.AUGMENTED)
          {
            chordColor = AUGMENTED_COLOR;
          }
          else if (n.chord == Chord.SUSPENDED_2)
          {
            chordColor = SUSPENDED_2ND_COLOR;
          }
          else if (n.chord == Chord.SUSPENDED_4)
          {
            chordColor = SUSPENDED_4TH_COLOR;
          }
          
          if (!n.doEqui)
          {
            //just, do something
            if (!n.doRoot)
            {
              fill(255,0,0, 40);
            }
            else
            {
              fill(0,255,0,40);
            }
          }
          else
          {
            if (!n.doRoot)
            {
              fill(0,0,255,40);
            }
            else
            {
              noFill();
            }
          }
        }
        else
        {
          chordColor = color(0,0,0,255);
        }
        
        //Convert base pitch back to radius
        float rBasePitch = n.basePitch - (12*curOctave);
        float pR = (rBasePitch+1) * BASE_RADIUS;
        //float pR = (n.basePitch+1) * BASE_RADIUS;
        //println(pR);
        float startT = n.startTime;
        float endT = n.startTime + n.duration;
        
        //float nAngle = (startT / timing)*M_2PI - ((float)Math.PI / 2);
        float nAngle = getAngleFromTime(startT, timing);
        //float nAngle2 = (endT / timing) *M_2PI - ((float)Math.PI / 2);
        float nAngle2 = getAngleFromTime(endT, timing);
        stroke(chordColor);
        arc(CENTER_X, CENTER_Y, pR, pR, nAngle, nAngle2);
      }
      
      
    }
    popMatrix();
  }
  
  private void drawTimeSnaps()
  {
    float loopTime = DATA[curOctave][curInstrument].loopTime;
    strokeWeight(1);
    for(int i =0; i <= loopTime*NUM_PARTITIONS_PER_BEAT; i++)
    {
      pushMatrix();
      float time = i/(float)NUM_PARTITIONS_PER_BEAT;
      Intervals.add(time / loopTime);
      //float angle = getAngleFromTime(time, loopTime);
      float angle = (time / loopTime)*M_2PI;
      //println("time: " + time + "; angle: " + angle);
      vec tDraw = V(P(CENTER_X, CENTER_Y), P(CENTER_X, 0));
      //println("tdraw: " + tDraw.x + ", " + tDraw.y);
      tDraw = R(tDraw, angle);
      //vec tDraw = R(LOOPSTART, angle);
      //rotate((time / loopTime)*M_2PI);
      pt endPt = P(CENTER_X, CENTER_Y);
      endPt.add(tDraw);
      //println("p2: " + endPt.x + ", " + endPt.y);
      line(CENTER_X, CENTER_Y, endPt.x, endPt.y);
      popMatrix();
    }
  }
  
  private float getAngleFromTime(float time, float loopTime)
  {
    return (time / loopTime)*M_2PI - ((float)Math.PI / 2);
  }
  
  void getNoteData()
  {
    if (started && completed)
    {
      float rad = dist(CENTER_X, CENTER_Y, nStartX, nStartY);
      float pitch = NormalizeToPitch(rad, MAX_RADIUS, BASE_RADIUS);
      //get angle between loop start, startpos
      vec lStart = V(P(CENTER_X, CENTER_Y), P(LOOPSTART_X, LOOPSTART_Y));
      vec tStart = V(P(CENTER_X, CENTER_Y), P(nStartX, nStartY));
      float angle = angle(lStart,tStart);
      if (angle < 0) angle += M_2PI;
      float timeStartPos = (angle / M_2PI)*DATA[curOctave][curInstrument].loopTime;
      //get angle between loop start, endpos
      vec tEnd = V(P(CENTER_X, CENTER_Y), P(nEndX, nEndY));
      float angleStartEnd = angle(lStart,tEnd);
      if (angleStartEnd < 0) angleStartEnd += M_2PI;
      float timeEndPos = (angleStartEnd / M_2PI)*DATA[curOctave][curInstrument].loopTime;
      float duration = timeEndPos - timeStartPos;
      //create note from duration.
      //If duration is negative, user drew the arc backwards, so reverse.
      if (duration > 0)
      {
        //println("NN: " + pitch + ", " + timeStartPos + ", " + duration);
        DATA[curOctave][curInstrument].AddNote(pitch, timeStartPos, duration, curOctave, doChord, chordType, doRoot, doEqui, snapNotes, snapLevel);
      }
      else
      {
        //println("NN2: " + pitch + ", " + timeEndPos + ", " + Math.abs(duration));
        DATA[curOctave][curInstrument].AddNote(pitch, timeEndPos, Math.abs(duration), curOctave, doChord, chordType, doRoot, doEqui, snapNotes, snapLevel);
      }
      started = false;
    }
  }
  
  /**
   * Computes a pitch from a radius
   * @param cRad; the current radius to compute pitch for
   * @param maxRad; the maximum radius of pitch
   * @param minRad; the minimum radius of pitch
   * @return; a pitch in the range [0-11]
   */
  float NormalizeToPitch(float cRad, float maxRad, float minRad)
  {
    float range = maxRad - minRad;
    float nPitch = ((cRad-minRad) / range)*11f;
    if (nPitch > 11) nPitch = 11f;
    else if (nPitch < 0) nPitch = 0f;
    return nPitch;
  }
  
  Boolean isPressed = false;
  int ptInd = 0;
  
  public void mouseDragged()
  {
    if (isPressed)
    {
      uiPts[ptInd].x = mouseX;
      uiPts[ptInd].y = mouseY;
    }
    
  }
  
  public void mouseMoved()
  {
    if (spacePressed && !playing)
    {
      if (editStart)
      {
        Note editNote = DATA[curOctave][curInstrument].notes.get(editIndex);
        float rad = dist(CENTER_X, CENTER_Y, mouseX, mouseY);
        float pitch = NormalizeToPitch(rad, MAX_RADIUS, BASE_RADIUS);
        //get angle between loop start, startpos
        vec lStart = V(P(CENTER_X, CENTER_Y), P(LOOPSTART_X, LOOPSTART_Y));
        vec tStart = V(P(CENTER_X, CENTER_Y), P(mouseX, mouseY));
        float angle = angle(lStart,tStart);
        if (angle < 0) angle += M_2PI;
        float timeStartPos = (angle / M_2PI)*DATA[curOctave][curInstrument].loopTime;
        float duration = (editNote.duration+editNote.startTime) - timeStartPos;
        //create note from duration.
        //If duration is negative, user drew the arc backwards, so reverse.
        if (duration > 0)
        {
          println("NNEDIT: " + pitch + ", " + timeStartPos + ", " + duration);
          if (doChord) editNote = new Note(pitch, timeStartPos, duration, curOctave, chordType, doRoot, doEqui);
          else editNote = new Note(pitch, timeStartPos, duration, curOctave);
          if (snapNotes) editNote.NormalizeNote(snapLevel);
          DATA[curOctave][curInstrument].notes.set(editIndex, editNote);
        }
        else
        {
          //println("NN2EDIT: " + pitch + ", " + (editNote.startTime+editNote.duration) + ", " + Math.abs(duration));
          if (doChord) editNote = new Note(pitch, editNote.startTime+editNote.duration, Math.abs(duration), curOctave, chordType, doRoot, doEqui);
          else editNote = new Note(pitch, editNote.startTime+editNote.duration, Math.abs(duration), curOctave);
          if (snapNotes) editNote.NormalizeNote(snapLevel);
          DATA[curOctave][curInstrument].notes.set(editIndex, editNote);
        }
      }
      else
      {
        Note editNote = DATA[curOctave][curInstrument].notes.get(editIndex);
        //get angle between loop start, startpos
        vec lStart = V(P(CENTER_X, CENTER_Y), P(LOOPSTART_X, LOOPSTART_Y));
        vec tStart = V(P(CENTER_X, CENTER_Y), P(mouseX, mouseY));
        float angle = angle(lStart,tStart);
        if (angle < 0) angle += M_2PI;
        float timeEndPos = (angle / M_2PI)*DATA[curOctave][curInstrument].loopTime;
        float duration =  timeEndPos - editNote.startTime;
        if (duration > 0)
        {
          //println("NNEDITEND: " + editNote.basePitch + ", " + timeEndPos + ", " + duration);
          if (doChord) editNote = new Note(editNote.basePitch, editNote.startTime, duration, curOctave, chordType, doRoot, doEqui);
          else editNote = new Note(editNote.basePitch, editNote.startTime, duration, curOctave);
          if (snapNotes) editNote.NormalizeNote(snapLevel);
          DATA[curOctave][curInstrument].notes.set(editIndex, editNote);
        }
        else
        {
          //editNote.startTime+editNote.duration
        }
      }
    }
  }
  
  public void mousePressed()
  {
    if (mouseButton == LEFT && !playing)
    {
      started = true;
      completed = false;
      nStartX = mouseX;
      nStartY = mouseY;
    }
    else if (mouseButton == LEFT)
    {
      isPressed = true;
      float dist = Float.MAX_VALUE;
      int ind = 0;
      for(int i =0; i < uiPts.length; i++)
      {
        pt cur = uiPts[i];
        float ndist = dist(mouseX, mouseY, cur.x, cur.y);
        if (ndist < dist)
        {
          ind = i;
          dist = ndist;
        }
      }
      ptInd = ind;
    }
    else if (mouseButton == RIGHT)
    {
      zoomed = !zoomed;
    }
    
  }
  
  public void mouseReleased()
  {
    if (mouseButton == LEFT && !playing)
    {
      completed = true;
      nEndX = mouseX;
      nEndY = mouseY;
    }
    else if (mouseButton == LEFT)
    {
      isPressed = false;
    }
  }
  
  public void keyPressed()
  {
    if (key == '1')
    {
      curInstrument = 0;
    }
    else if (key == '2')
    {
      curInstrument = 1;
    }
    else if (key == '3')
    {
      curInstrument = 2;
    }
    else if (key == '4')
    {
      curInstrument = 3;
    }
    else if (key == 'N')
    {
      for(int i = 0; i < DATA[curOctave][curInstrument].notes.size(); i++)
      {
        Note n = DATA[curOctave][curInstrument].notes.get(i);
        if (n != null) n.NormalizeNote(snapLevel);
      }
    }
    else if (key == 'n')
    {
      snapNotes = !snapNotes;
    }
    else if (key == 'c')
    {
      doChord = !doChord;
    }
    else if (key == 'C')
    {
      for(int i = 0; i < DATA[curOctave][curInstrument].notes.size(); i++)
      {
        Note n = DATA[curOctave][curInstrument].notes.get(i);
        if (n != null) n.CreateChord(chordType, doRoot, doEqui);
      }
    }
    else if (key == 'M')
    {
      chordType = Chord.MAJOR;
    }
    else if (key == 'm')
    {
      chordType = Chord.MINOR;
    }
    else if (key == 'a')
    {
      chordType = Chord.AUGMENTED;
    }
    else if (key == 'd')
    {
      chordType = Chord.DIMINISHED;
    }
    else if (key == 's')
    {
      chordType = Chord.SUSPENDED_2;
    }
    else if (key == 'S')
    {
      chordType = Chord.SUSPENDED_4;
    }
    else if (key == 'P')
    {
      if (!playing)
      {
        playing = true;
        ao = m.getLineOut(Minim.MONO,1024*16);
        playNotes();
      }
    }
    else if (key == 'p')
    {
      if (!playing)
      {
        playing = true;
        ao = m.getLineOut(Minim.MONO,1024*16);
        ao.pauseNotes();
        PlayInstrument(DATA[curOctave][curInstrument]);
        ao.resumeNotes();
      }
    }
    else if (key == 'e')
    {
      DATA[curOctave][curInstrument].notes = new ArrayList<Note>();
    }
    else if (key == 'z')
    {
      ArrayList<Note> ns = DATA[curOctave][curInstrument].notes;
      int nSize = ns.size() - 1;
      if (nSize >= 0) DATA[curOctave][curInstrument].notes = new ArrayList<Note>(ns.subList(0, nSize));
    }
    else if (key == 'j')
    {
      doEqui = !doEqui;
    }
    else if (key == '+')
    {
      zoom += 0.3f;
    }
    else if (key == '-')
    {
      zoom -= 0.3f;
    }
    else if (key == '[')
    {
      snapLevel = snapLevel / 10;
    }
    else if (key == ']')
    {
      snapLevel = snapLevel * 10;
    }
    else if (key == 'q')
    {
      playing = false;
      ao.pauseNotes();
      ao.close();
    }
    else if (key == 'Q')
    {
      exit();
    }
    else if (key == 'I')
    {
      //Snap to begin times
      ArrayList<Note> ns = DATA[curOctave][curInstrument].notes;
      for(int i = 0; i < ns.size(); i++)
      {
        int minIndex = 0;
        float minDist = Float.MAX_VALUE;
        Note n = ns.get(i);
        float endTime = n.startTime + n.duration;
        float loop = DATA[curOctave][curInstrument].loopTime;
        for(int j = 0; j < Intervals.size(); j++)
        {
          float dist = ns.get(i).startTime - loop*Intervals.get(j);
          if ((Math.abs(dist)) < minDist)
          {
            minIndex = j;
            minDist = Math.abs(dist);
          }
        }
        if (minDist > 0.001)
        {
          n.startTime = loop*Intervals.get(minIndex);
          n.duration = endTime - n.startTime;
        }
        
      }
    }
    else if (key == 'i')
    {
      //Snap end to times
      ArrayList<Note> ns = DATA[curOctave][curInstrument].notes;
      for(int i = 0; i < ns.size(); i++)
      {
        int minIndex = 0;
        float minDist = Float.MAX_VALUE;
        Note n = ns.get(i);
        float endTime = n.startTime + n.duration;
        float loop = DATA[curOctave][curInstrument].loopTime;
        for(int j = 0; j < Intervals.size(); j++)
        {
          float dist = loop*Intervals.get(j) - endTime;
          if ((Math.abs(dist)) < minDist)
          {
            minIndex = j;
            minDist = Math.abs(dist);
          }
        }
        //account for error
        if(minDist > 0.001)
        {
          endTime = loop*Intervals.get(minIndex);
          n.duration = endTime - n.startTime;
        }
        
      }
    }
    else if (key == ' ')
    {
      if (!spacePressed)
      {
        spacePressed = true;
        ArrayList<Note> ns = DATA[curOctave][curInstrument].notes;
        float timing = DATA[curOctave][curInstrument].loopTime;
        float minDist = Float.MAX_VALUE;
        Note editNote = null;
        for(int i = 0; i < ns.size(); i++)
        {
          Note n = ns.get(i);
          float angle = getAngleFromTime(n.startTime, timing) + PI/2;
          float endAngle = getAngleFromTime(n.startTime+n.duration, timing)+PI/2;
          vec upV = V(P(CENTER_X, CENTER_Y), P(CENTER_X, 0));
          vec startV = R(upV, angle);
          vec endV = R(upV, endAngle);
          pt endPt = P(P(CENTER_X, CENTER_Y), endV);
          pt startPt = P(P(CENTER_X, CENTER_Y), startV);
          
          //drawPt(endPt, 5, color(255,0,0));
          //drawPt(endPt, 5, color(255,0,0));
          
          float d1 = dist(mouseX, mouseY, startPt.x, startPt.y);
          float d2 = dist(mouseX, mouseY, endPt.x, endPt.y);
          
          if (d1 < minDist || d2 < minDist)
          {
            minDist = d1 < d2 ? d1 : d2;
            editIndex = i;
            editStart = d1 < d2 ? true: false;
          }
          
          //line(CENTER_X, CENTER_Y, startPt.x, startPt.y);
          //line(CENTER_X, CENTER_Y, endPt.x, endPt.y);
        }
        if (ns.get(editIndex) == null) spacePressed = false;
      }
    }
    else if (key == 'r')
    {
      doRoot = !doRoot;
    }
    if (key == CODED)
    {
      if (keyCode == UP)
      {
        IncrementOctave();
      }
      else if (keyCode == DOWN)
      {
        DecrementOctave();
      }
    }
  }
  
  public void keyReleased()
  {
    if (key == ' ')
    {
      spacePressed = false;
    }
  }
  
  private void IncrementOctave()
  {
    curOctave++;
    if (curOctave >= NUMOCTAVES)
    {
      curOctave = 0;
    }
    println("Inc octave: " + curOctave);
  }
  private void DecrementOctave()
  {
    curOctave--;
    if (curOctave < 0)
    {
      curOctave = NUMOCTAVES - 1;
    }
    println("Dec octave: " + curOctave);
  }
  
  
  
  
  
  
  
  //*****************************************************************************
  // TITLE:         GEOMETRY UTILITIES IN 2D  
  // DESCRIPTION:   Classes and functions for manipulating points, vectors, edges, triangles, quads, frames, and circular arcs  
  // AUTHOR:        Prof Jarek Rossignac
  // DATE CREATED:  September 2009
  // EDITS:         Revised July 2011
  //*****************************************************************************
  //************************************************************************
  //**** POINT CLASS
  //************************************************************************
  class pt { float x=0,y=0; 
    // CREATE
    pt () {}
    pt (float px, float py) {x = px; y = py;};

    // MODIFY
    pt setTo(float px, float py) {x = px; y = py; return this;};  
    pt setTo(pt P) {x = P.x; y = P.y; return this;}; 
    pt setToMouse() { x = mouseX; y = mouseY;  return this;}; 
    pt add(float u, float v) {x += u; y += v; return this;}                       // P.add(u,v): P+=<u,v>
    pt add(pt P) {x += P.x; y += P.y; return this;};                              // incorrect notation, but useful for computing weighted averages
    pt add(float s, pt P)   {x += s*P.x; y += s*P.y; return this;};               // adds s*P
    pt add(vec V) {x += V.x; y += V.y; return this;}                              // P.add(V): P+=V
    pt add(float s, vec V) {x += s*V.x; y += s*V.y; return this;}                 // P.add(s,V): P+=sV
    pt translateTowards(float s, pt P) {x+=s*(P.x-x);  y+=s*(P.y-y);  return this;};  // transalte by ratio s towards P
    pt scale(float u, float v) {x*=u; y*=v; return this;};
    pt scale(float s) {x*=s; y*=s; return this;}                                  // P.scale(s): P*=s
    pt scale(float s, pt C) {x*=C.x+s*(x-C.x); y*=C.y+s*(y-C.y); return this;}    // P.scale(s,C): scales wrt C: P=L(C,P,s);
    pt rotate(float a) {float dx=x, dy=y, c=cos(a), s=sin(a); x=c*dx+s*dy; y=-s*dx+c*dy; return this;};     // P.rotate(a): rotate P around origin by angle a in radians
    pt rotate(float a, pt G) {float dx=x-G.x, dy=y-G.y, c=cos(a), s=sin(a); x=G.x+c*dx+s*dy; y=G.y-s*dx+c*dy; return this;};   // P.rotate(a,G): rotate P around G by angle a in radians
    pt rotate(float s, float t, pt G) {float dx=x-G.x, dy=y-G.y; dx-=dy*t; dy+=dx*s; dx-=dy*t; x=G.x+dx; y=G.y+dy;  return this;};   // fast rotate s=sin(a); t=tan(a/2); 
    pt moveWithMouse() { x += mouseX-pmouseX; y += mouseY-pmouseY;  return this;}; 
       
    // DRAW , WRITE
    pt write() {print("("+x+","+y+")"); return this;};  // writes point coordinates in text window
    pt v() {vertex(x,y); return this;};  // used for drawing polygons between beginShape(); and endShape();
    pt show(float r) {ellipse(x, y, 2*r, 2*r); return this;}; // shows point as disk of radius r
    pt show() {show(3); return this;}; // shows point as small dot
    
    // COPY
    public pt copy() {pt N = new pt(); N.setTo(this); return N; }
    } // end of pt class

  //************************************************************************
  //**** VECTOR CLASS
  //************************************************************************
  class vec { float x=0,y=0; 
   // CREATE
    vec () {};
    vec (float px, float py) {x = px; y = py;};
   
   // MODIFY
    vec setTo(float px, float py) {x = px; y = py; return this;}; 
    vec setTo(vec V) {x = V.x; y = V.y; return this;}; 
    vec zero() {x=0; y=0; return this;}
    vec scaleBy(float u, float v) {x*=u; y*=v; return this;};
    vec scaleBy(float f) {x*=f; y*=f; return this;};
    vec reverse() {x=-x; y=-y; return this;};
    vec divideBy(float f) {x/=f; y/=f; return this;};
    vec normalize() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;}; return this;};
    vec add(float u, float v) {x += u; y += v; return this;};
    vec add(vec V) {x += V.x; y += V.y; return this;};   
    vec add(float s, vec V) {x += s*V.x; y += s*V.y; return this;};   
    vec rotateBy(float a) {float xx=x, yy=y; x=xx*cos(a)-yy*sin(a); y=xx*sin(a)+yy*cos(a); return this;};
    vec left() {float m=x; x=-y; y=m; return this;};
   
    // OUTPUT VEC
    protected vec clone() {return(new vec(x,y));}; 

    // OUTPUT TEST MEASURE
    float norm() {return(sqrt(sq(x)+sq(y)));}
    boolean isNull() {return((abs(x)+abs(y)<0.000001));}
    float angle() {return(atan2(y,x)); }

    // DRAW, PRINT
    void write() {println("<"+x+","+y+">");};
    void showAt (pt P) {line(P.x,P.y,P.x+x,P.y+y); }; 
    void showArrowAt (pt P) {line(P.x,P.y,P.x+x,P.y+y); 
        float n=Math.min(this.norm()/10.f,height/50.f); 
        pt Q=P(P,this); 
        vec U = S(-n,U(this));
        vec W = S(.3f,R(U)); 
        beginShape(); Q.add(U).add(W).v(); Q.v(); Q.add(U).add(M(W)).v(); endShape(CLOSE); }; 
    } // end vec class

  //************************************************************************
  //**** POINTS FUNCTIONS
  //************************************************************************
  // create 
  pt P() {return P(0,0); };                                                                            // make point (0,0)
  pt P(float x, float y) {return new pt(x,y); };                                                       // make point (x,y)
  pt P(pt P) {return P(P.x,P.y); };                                                                    // make copy of point A
  pt Mouse() {return P(mouseX,mouseY);};                                                                 // returns point at current mouse location
  pt Pmouse() {return P(pmouseX,pmouseY);};                                                              // returns point at previous mouse location
  pt ScreenCenter() {return P(width/2,height/2);}                                                        //  point in center of  canvas

  // transform 
  pt R(pt Q, float a) {float dx=Q.x, dy=Q.y, c=cos(a), s=sin(a); return new pt(c*dx+s*dy,-s*dx+c*dy); };  // Q rotated by angle a around the origin
  pt R(pt Q, float a, pt C) {float dx=Q.x-C.x, dy=Q.y-C.y, c=cos(a), s=sin(a); return P(C.x+c*dx-s*dy, C.y+s*dx+c*dy); };  // Q rotated by angle a around point P
  pt P(pt P, vec V) {return P(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vector V)
  pt P(pt P, float s, vec V) {return P(P,W(s,V)); }                                                    //  P+sV (P transalted by sV)
  pt MoveByDistanceTowards(pt P, float d, pt Q) { return P(P,d,U(V(P,Q))); };                          //  P+dU(PQ) (transLAted P by *distance* s towards Q)!!!

  // average 
  pt P(pt A, pt B) {return P((A.x+B.x)/2.0f,(A.y+B.y)/2.0f); };                                          // (A+B)/2 (average)
  pt P(pt A, pt B, pt C) {return P((A.x+B.x+C.x)/3.0f,(A.y+B.y+C.y)/3.0f); };                            // (A+B+C)/3 (average)
  pt P(pt A, pt B, pt C, pt D) {return P(P(A,B),P(C,D)); };                                            // (A+B+C+D)/4 (average)

  // weighted average 
  pt P(float a, pt A) {return P(a*A.x,a*A.y);}                                                      // aA  
  pt P(float a, pt A, float b, pt B) {return P(a*A.x+b*B.x,a*A.y+b*B.y);}                              // aA+bB, (a+b=1) 
  pt P(float a, pt A, float b, pt B, float c, pt C) {return P(a*A.x+b*B.x+c*C.x,a*A.y+b*B.y+c*C.y);}   // aA+bB+cC 
  pt P(float a, pt A, float b, pt B, float c, pt C, float d, pt D){return P(a*A.x+b*B.x+c*C.x+d*D.x,a*A.y+b*B.y+c*C.y+d*D.y);} // aA+bB+cC+dD 

  // LERP
  pt L(pt A, pt B, float t) {return P(A.x+t*(B.x-A.x),A.y+t*(B.y-A.y));}
      
  // measure 
  boolean isSame(pt A, pt B) {return (A.x==B.x)&&(A.y==B.y) ;}                                         // A==B
  boolean isSame(pt A, pt B, float e) {return ((abs(A.x-B.x)<e)&&(abs(A.y-B.y)<e));}                   // ||A-B||<e
  float d(pt P, pt Q) {return sqrt(d2(P,Q));  };                                                       // ||AB|| (Distance)
  float d2(pt P, pt Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // AB*AB (Distance squared)

  //************************************************************************
  //**** VECTOR FUNCTIONS
  //************************************************************************
  // create 
  vec V(vec V) {return new vec(V.x,V.y); };                                                             // make copy of vector V
  vec V(pt P) {return new vec(P.x,P.y); };                                                              // make vector from origin to P
  vec V(float x, float y) {return new vec(x,y); };                                                      // make vector (x,y)
  vec V(pt P, pt Q) {return new vec(Q.x-P.x,Q.y-P.y);};                                                 // PQ (make vector Q-P from P to Q
  vec U(vec V) {float n = n(V); if (n==0) return new vec(0,0); else return new vec(V.x/n,V.y/n);};      // V/||V|| (Unit vector : normalized version of V)
  vec U(pt P, pt Q) {return U(V(P,Q));};                                                                // PQ/||PQ| (Unit vector : from P towards Q)
  vec MouseDrag() {return new vec(mouseX-pmouseX,mouseY-pmouseY);};                                      // vector representing recent mouse displacement

  // weighted sum 
  vec W(float s,vec V) {return V(s*V.x,s*V.y);}                                                      // sV
  vec W(vec U, vec V) {return V(U.x+V.x,U.y+V.y);}                                                   // U+V 
  vec W(vec U,float s,vec V) {return W(U,S(s,V));}                                                   // U+sV
  vec W(float u, vec U, float v, vec V) {return W(S(u,U),S(v,V));}                                   // uU+vV ( Linear combination)

  // transformed 
  vec R(vec V) {return new vec(-V.y,V.x);};                                                             // V turned right 90 degrees (as seen on screen)
  vec R(vec V, float a) {float c=cos(a), s=sin(a); return(new vec(V.x*c-V.y*s,V.x*s+V.y*c)); };                                     // V rotated by a radians
  vec S(float s,vec V) {return new vec(s*V.x,s*V.y);};                                                  // sV
  vec Reflection(vec V, vec N) { return W(V,-2.f*dot(V,N),N);};                                          // reflection
  vec M(vec V) { return V(-V.x,-V.y); }                                                                  // -V

  // Interpolation 
  vec L(vec U, vec V, float s) {return new vec(U.x+s*(V.x-U.x),U.y+s*(V.y-U.y));};                      // (1-s)U+sV (Linear interpolation between vectors)
  vec S(vec U, vec V, float s) {float a = angle(U,V); vec W = R(U,s*a); float u = n(U), v=n(V); return W(pow(v/u,s),W); } // steady interpolation from U to V

  // measure 
  float dot(vec U, vec V) {return U.x*V.x+U.y*V.y; }                                                     // dot(U,V): U*V (dot product U*V)
  float det(vec U, vec V) {return dot(R(U),V); }                                                         // det | U V | = scalar cross UxV 
  float n(vec V) {return sqrt(dot(V,V));};                                                               // n(V): ||V|| (norm: length of V)
  float n2(vec V) {return sq(V.x)+sq(V.y);};                                                             // n2(V): V*V (norm squared)
  boolean parallel (vec U, vec V) {return dot(U,R(V))==0; }; 

  float angle (vec U, vec V) {return atan2(det(U,V),dot(U,V)); };                                   // angle <U,V> (between -PI and PI)
  float angle(vec V) {return(atan2(V.y,V.x)); };                                                       // angle between <1,0> and V (between -PI and PI)
  float angle(pt A, pt B, pt C) {return  angle(V(B,A),V(B,C)); }                                       // angle <BA,BC>
  float turnAngle(pt A, pt B, pt C) {return  angle(V(A,B),V(B,C)); }                                   // angle <AB,BC> (positive when right turn as seen on screen)
  int toDeg(float a) {return (int)(a*180/PI);}                                                           // convert radians to degrees
  float toRad(float a) {return(a*PI/180);}                                                             // convert degrees to radians 
  float positive(float a) { if(a<0) return a+TWO_PI; else return a;}                                   // adds 2PI to make angle positive

  // SLERP
  vec slerp(vec U, float t, vec V) {float a = angle(U,V); float b=(float)Math.sin((1.f-t)*a),c=(float)Math.sin(t*a),d=sin(a); return W(b/d,U,c/d,V); } // UNIT vectors ONLY!

  //************************************************************************
  //**** DISPLAY
  //************************************************************************
  // point / polygon
                                               // show sV as arrow from P 