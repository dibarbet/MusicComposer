public class Note
{
  Boolean isChord;
  float basePitch;
  float startTime;
  float duration;
  Chord chord;
  //THESE ARE FREQUENCIES
  float[] chordNotes;
  Boolean doEqui;
  Boolean doRoot;
  float octave;
  
  
  public Note(float basePitch, float start, float duration, float octave)
  {
    this.octave = octave;
    this.basePitch = basePitch + (12*octave);
    //this.basePitch = basePitch;
    this.startTime = start;
    this.duration = duration;
    this.isChord = false;
  }
  
  public Note(float basePitch, float start, float duration, float octave, Chord type, Boolean doRoot, Boolean doEqui)
  {
    this.octave = octave;
    this.basePitch = basePitch + (12*octave);
    //this.basePitch = basePitch;
    this.startTime = start;
    this.duration = duration;
    this.isChord = true;
    this.doEqui = doEqui;
    this.doRoot = doRoot;
    chord = type;
    CreateChord(type, doRoot, doEqui);
  }
  
  public void NormalizeNote(float lvl)
  {
    basePitch = (float)Math.round(basePitch*lvl) / lvl;
  }
  
  public void CreateChord(Chord type, Boolean doRoot, Boolean doEqui)
  {
    if(doRoot)
    {
      if (doEqui)
      {
        CreateEquiRootChord(type);
      }
      else
      {
        CreateJustRootChord(type);
      }
      
    }
    else
    {
      if (doEqui)
      {
        CreateEquiAverageChord(type);
      }
      else
      {
        CreateJustAverageChord(type);
      }
    }
    //Do something here
  }
  
  /**
   * Hard, probably not working yet.  Average is in pitch, but ratios in freq..
   * TODO- figure our solution, solving log equations is hard, so used newtons method
   * code is probably not actually correct, but I attempted it
   * P(x)+P(y)+P(z)=3a
   * x*r1=y
   * y*r2=z
   * P(n) = 12log(f/f0)
   * 
   * solving for x i get...
   * x+24log(x)=constant
   * 
   * 
   * @param type
   */
  private void CreateJustAverageChord(Chord type)
  {
    float sumPitch = basePitch*3;
    float freq = PitchToFreq(basePitch);
    float r1, r2;
    if (type == Chord.MAJOR)
    {
      r1 = 5/4f;
      r2 = 6/5f;
    }
    else if (type == Chord.MINOR)
    {
      r1 = 12/10f;
      r2 = 15/12f;
    }
    else if (type == Chord.DIMINISHED)
    {
      r1 = 6/5f;
      r2 = 7/6f;
    }
    else if (type == Chord.AUGMENTED)
    {
      r1 = 20/16f;
      r2 = 25/20f;
    }
    else if (type == Chord.SUSPENDED_2)
    {
      r1 = 9/8f;
      r2 = 12/9f;
    }
    else
    {
      r1 = 8/6f;
      r2 = 9/8f;
    }
    //float x = sumPitch / (r1 + r1*r2 + 1);
    //float y = sumPitch / ((1/r1)+r2+1);
    //float z = sumPitch / ((1/(r1*r2))+(1/r2)+1);
    Newton Newton = new Newton();
    float b = BaseFrequency;
    double c_x = -sumPitch + 12*Newton.log2(r1/b) + 12*Newton.log2((r1*r2)/b);
    double x = Newton.NewtonsMethod(c_x);
    double c_y = -sumPitch + 12*Newton.log2(1/(r1*b)) + 12*Newton.log2(r2/b);
    double y = Newton.NewtonsMethod(c_y);
    double c_z = -sumPitch + 12*Newton.log2(1/(r1*r2*b)) + 12*Newton.log2(1/(r1*b));
    double z = Newton.NewtonsMethod(c_z);
    System.out.println("x: " + FreqToPitch((float)x));
    System.out.println("y: " + FreqToPitch((float)y));
    System.out.println("z: " + FreqToPitch((float)z));
    
    System.out.println("Pitch: " + basePitch + "; avg: " + ((FreqToPitch((float)x)+FreqToPitch((float)y)+FreqToPitch((float)z))/3));
    
    chordNotes = new float[] {(float)x, (float)y, (float)z};
  }
  
  /**
   * To solve this problem we have a system of equations.
   * n1+n2+n3 = 3*avgPitch
   * n2-n1 = a
   * n3-n2 = b
   * @param type; chord type
   */
  private void CreateEquiAverageChord(Chord type)
  {
    float sumPitch = basePitch * 3;
    float a, b;
    chordNotes = new float[3];
    if (type == Chord.MAJOR)
    {
      a = 4;
      b = 3;
    }
    else if (type == Chord.MINOR)
    {
      a = 3;
      b = 4;
    }
    else if (type == Chord.DIMINISHED)
    {
      a = 3;
      b = 3;
    }
    else if (type == Chord.AUGMENTED)
    {
      a = 4;
      b = 4;
    }
    else if (type == Chord.SUSPENDED_2)
    {
      a = 2;
      b = 5;
    }
    else
    {
      a = 5;
      b = 2;
    }
    chordNotes[0] = (sumPitch - a - b - a) /3f;
    chordNotes[1] = (sumPitch + a - b) /3f;
    chordNotes[2] = (sumPitch + b + a + b) / 3f;
    for(int j = 0; j < chordNotes.length; j++)
    {
      chordNotes[j] = PitchToFreq(chordNotes[j]);
    }
    
  }
  /**
   * Source: https://gist.github.com/endolith/3098720
   * @param type; the type of chord
   */
  private void CreateJustRootChord(Chord type)
  {
    if (type == Chord.MAJOR)
    {
      //System.out.println("base: " + basePitch);
      //RATIO 4:5:6
      float n2 = (5f/4f) * PitchToFreq(basePitch);
      float n3 = (6f/5f)*n2;
      //System.out.print("n1: " + PitchToFreq(basePitch) + "; n2: " + n2 + "; n3: " + n3);
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.MINOR)
    {
      //RATIO 10:12:15
      float n2 = (12f/10f) * PitchToFreq(basePitch);
      float n3 = (15f/12f) * n2;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.DIMINISHED)
    {
      //RATIO 5:6:7
      float n2 = (6f/5f)*PitchToFreq(basePitch);
      float n3 = (7f/6f)*n2;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.AUGMENTED)
    {
      //RATIO 16:20:25
      float n2 = (20f/16f)*PitchToFreq(basePitch);
      float n3 = (25f/20f)*n2;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.SUSPENDED_2)
    {
      //RATIO 8:9:12
      float n2 = (9f/8f)*PitchToFreq(basePitch);
      float n3 = (12f/9f)*n2;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.SUSPENDED_4)
    {
      //Ratio 6:8:9
      float n2 = (8f/6f)*PitchToFreq(basePitch);
      float n3 = (9f/8f)*n2;
      chordNotes = new float[] {basePitch, n2, n3};
    }
  }
  
  /**
   * Creates a chord with basePitch as root.
   * @param type; the type of chord to create
   */
  private void CreateEquiRootChord(Chord type)
  {
    if (type == Chord.MAJOR)
    {
      float n2 = basePitch + 4;
      float n3 = n2 + 3;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.MINOR)
    {
      float n2 = basePitch + 3;
      float n3 = n2 + 4;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.DIMINISHED)
    {
      float n2 = basePitch + 3;
      float n3 = n2 + 3;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.AUGMENTED)
    {
      float n2 = basePitch + 4;
      float n3 = n2 + 4;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.SUSPENDED_2)
    {
      float n2 = basePitch + 2;
      float n3 = n2 + 5;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    else if (type == Chord.SUSPENDED_4)
    {
      float n2 = basePitch + 5;
      float n3 = n2 + 2;
      chordNotes = new float[] {basePitch, n2, n3};
    }
    for(int j = 0; j < chordNotes.length; j++)
    {
      chordNotes[j] = PitchToFreq(chordNotes[j]);
    }
  }
  
  public void PlayNote(AudioOutput a, float pTime, InstrumentType i)
  {    
    if (!isChord)
    {
      ddf.minim.ugens.Instrument is;
      //ddf.minim.ugens.DefaultInstrument ds = new DefaultInstrument(PitchToFreq(basePitch), a);
      //is = ds;
      a.playNote(pTime+startTime, duration, PitchToFreq(basePitch));
    }
    else
    {
      //chordNotes already contains frequencies
      a.playNote(pTime+startTime, duration, chordNotes[0]);
      a.playNote(pTime+startTime, duration, chordNotes[1]);
      a.playNote(pTime+startTime, duration, chordNotes[2]);
;    }
  }
  
  
  /**
   * Converts a float semitone to a frequency for playing
   * @param semitone; the semitone to convert to frequency
   * @return; the frequency of the semitone
   */
  public float PitchToFreq(float semi)
  {
    return BaseFrequency*(float)Math.pow(2.f,semi/12);
  }
  
  public float FreqToPitch(float freq)
  {
    //processing is crap
    Newton Newton = new Newton();
    return 12*(float)Newton.log2(freq/BaseFrequency);
  }
}