import java.util.ArrayList;
/**
 * @author David
 *
 */
public class Instrument
{
  float loopTime;
  ArrayList<Note> notes;
  InstrumentType iT;
  int numLoops;
  
  public Instrument(float looptime, int numLoops, InstrumentType iT)
  {
    this.loopTime = looptime;
    notes = new ArrayList<Note>();
    this.iT = iT;
    this.numLoops = numLoops;
  }
  /**
   * Add note to this instrument
   * @param basePitch; the pitch from the UI
   * @param normalize; do we want to map to int pitches
   */
  public void AddNote(float basePitch, float start, float duration, float octave, Boolean normalize, float lvl)
  {
    float nPitch = basePitch;
    
    //TODO- chord conversion
    if (normalize)
    {
      nPitch = (float)Math.round(basePitch*lvl)/lvl;
    }
    Note n = new Note(nPitch, start, duration, octave);
    notes.add(n);
  }
  
  public void AddNote(float basePitch, float start, float duration, float octave, Boolean doChord, Chord type, Boolean doRoot, Boolean doEqui, Boolean normalize, float lvl)
  {
    if (!doChord)
    {
      AddNote(basePitch, start, duration, octave, normalize, lvl);
    }
    else
    {
      float nPitch = basePitch;
      if (normalize)
      {
        nPitch = (float)Math.round(basePitch*lvl)/lvl;
      }
      Note n = new Note(nPitch, start, duration, octave, type, doRoot, doEqui);
      notes.add(n);
    }
    
  }
  
  public void PlayNotes(AudioOutput ao)
  {
    //int number = (int)(Math.random()*10);
    int number = numLoops;
    for(int c = 0; c < number; c++)
    {
      for(int i = 0; i < notes.size(); i++)
      {
        Note n = notes.get(i);
        n.PlayNote(ao, c*loopTime, iT);
      }
    }
  }
  
  
}