# MusicComposer
4803 Final Project- A music composer for processing using circles.


## OVERVIEW


This system has four 'instruments' for each octave.  They can be switched between
using the controls in the next section.  Each instrument has a number in the middle
representing the number of seconds to loop for.  This can be changed in the code
using TIME1, TIME2, TIME3, TIME4 

The gray lines at normal zoom represent
the semitones corresponding to notes.  The outermost circle represents the 11th
semitone, while the innermost circle represents the 0th semitone.  The snapping
level determine what semitone to snap to (if at all).  You can snap between
semitones, as well as each 10th of a semitone.  The 1/10th lines will appear at
a high zoom level (> 2.0).

Single notes are represented by a black line.

Chords can be made manually, or using the chord controls provided.  The supported
chords are as follows:
	Major(Blue)
	Minor(Darker Blue)
	Augmented(Yellow)
	Diminished(Dark Yellow)
	Suspended 4th (Purple/Pink)
	Suspended 2nd (Dark Purple)
	
Below is the table of arc colors.  Arc colors correspond to just tunings or the
pitch construction of the chord.  With the root as the chord, a chord is 
constructed with the pitch as the root note.  With the average, the pitch selected
is used to attempt a reconstruction of a chord with that note as the average pitch.
This works O.k. for equi-tempered, but the just version needs work.

| Colors         | Root is chord | Avg is chord |
|:--------------:|:-------------:|:------------:|	
| Equi-tempered  | NO ARC COLOR  | BLUE         |
| Just tuning    | GREEN         | RED          |



## CONTROLS


### VIEW
	Switch between instruments/circles: 1 2 3 4
	Go up an octave: Arrow key up
	Go down an octave: Arrow key down
	Increment zoom: +
	Decrement zoom: -
	Toggle zooming: Mouse right click

### SNAP
	Snap next notes to semi-tone level: n
	Snap all notes to semi-tone level (cannot be undone): N
	Increment semitone round level (power of 10s): ]
	Decrement semitone round level (power of 10s): [
	#   Note that a pitch is rounded as follows-
	#   Math.round(pitch * semitone round level) / semitone round level

	Snap all note startimes to nearest interval: I
	Snap all note end times to nearest interval: i
	#   Note to change the times, change the Intervals[] array

### CHORDS
	Create next notes as chord: c
	Convert all notes to chords (cannot be undone): C
	Create next notes as just chords: j
	Create next chords using selected pitch as root or average: r

	#   Note that the chord is determine by the following chord types
	Major Chord: M
	Minor Chord: m
	Augmented Chord: a
	Diminished Chord: d
	Segmented Second: s
	Segmented Fourth: S
	#   End types

### PLAY
	Play all instruments + octaves: p
	Stop playback: q
	#   You must stop and restart playback to hear new notes.
	#   You must stop playing back before hitting play again.

### CLEAR
	Clear last placed: z
	Clear all on current instrument: e
	Exit application: Q


## TODO


Display
Save/load from file
Interactive drag/drop onto bars
Fix visualiztion
