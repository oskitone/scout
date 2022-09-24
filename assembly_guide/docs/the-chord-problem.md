---
id: the-chord-problem
title: The chord problem
description: Sometimes playing specific chords
sidebar_label: The chord problem
image: /img/scout-10-838-032.gif
slug: /the-chord-problem
---

The Scout is monophonic; it can only play one note at a time. If you try to hold multiple notes simultaneously, it tries to do what's called "last note priority" and only plays the most recently held key's note.

But sometimes, specific chords or sets of keys seem to add a note that you hadn't anticipated.

## Reproduce the issue

1. Play the first three white keys individually in succession. **C**, then **D**, then **E**. They should sound exactly as you'd expect.
2. Now, play them together. **C** _and_ **D** _and_ **E**.
3. Notice that it plays a totally different note at the end there instead of **E**. If you continue playing keys up individually, you'll discover that we got an **F#** at the end instead of the E we were expecting.
4. Now play the same run of those first three white keys but in the reverse order. **E** _and_ **D** _and_ **C**.
5. Again, notice that the third note at the end is **F#**.

Super weird, right? Why is this happening?

## Debugging

Before going any deeper, let's do a little debugging to confirm the microcontroller is correctly seeing the keys we're pressing.

### Keys list

The Scout has 17 keys. In code, we order lists starting at 0 instead of 1, so the indexes of the list go from 0 to 16, not 1 to 17.

| Index | Note | Color |
| ----- | ---- | ----- |
| 0     | C    | White |
| 1     | C#   | Black |
| 2     | D    | White |
| 3     | D#   | Black |
| 4     | E    | White |
| 5     | F    | White |
| 6     | F#   | Black |
| 7     | G    | White |
| 8     | G#   | Black |
| 9     | A    | White |
| 10    | A#   | Black |
| 11    | B    | White |
| 12    | C    | White |
| 13    | C#   | Black |
| 14    | D    | White |
| 15    | D#   | Black |
| 16    | E    | White |

Note the indexes of the notes we're playing: 0, 2, 4, and (somehow!) 6.

### Confirming with the serial monitor

If we [log out the indexes of the buttons](change-the-arduino-code.md#serial-debugging) being pressed and play **C**, **D**, **E** individually it looks like this:

[![Screengrab of the Arduino serial monitor while playing C, D, and E individually](/img/hack/chord-individual.png)](/img/hack/chord-individual.png)

Makes sense. **C** is **0**, **D** is **2**, **E** is **4**. That's good!

But holding them together looks like this:

[![Screengrab of the Arduino serial monitor while playing C, D, and E together](/img/hack/chord-cde.png)](/img/hack/chord-cde.png)

The **0**, **2**, **4** are in there (reverse ordered but that's irrelevant) but we also see a fourth index, **6**. That's the index of the **F#** key.

Playing and holding **E**+**D**+**C** is the same with a different order:

[![Screengrab of the Arduino serial monitor while playing E, D, and C together](/img/hack/chord-edc.png)](/img/hack/chord-edc.png)

That doesn't solve our problem, but it does tell us that the microcontroller is indeed interpreting that the **C**, **D**, and **E** keys are being pressed but, for some reason, incorrectly _adding_ the **F#**.

## Checking the schematic

The Scout has 17 keys but they only take up 9 pins on the ATmega328. It does this by convincing the microcontroller that the 17 keys are arranged in a matrix of rows and columns: 4 rows \* 5 columns = 20 possible keys.

- **Note 1:** The ATmega328 only has 14 digital input/output pins, which wouldn't be enough for all the keys if they were wired individually.
- **Note 2:** the 3 remaining, unused matrix spots are available for use on the ["HACK" header](change-the-arduino-code.md#pins).

Looking at the schematic for the matrix, we can see that **C** is **R1C1** (Row 1, column 1), **D** is **R3C1**, and **E** is **R1C2**.

[![Matrix schematic with C, D, and E matrix points highlighted](/img/hack/matrix-schematic.png)](/img/hack/matrix-schematic.png)

When you press all three together, it also looks to the microcontroller like you're also pressing **F#** at **R3C2** so it just throws it in there.

TODO: Matrix schematic with C, D, E, and now F# thrown in there too

So that's why it's happening!

## Is this a bug?

Issues like this "chord problem" are normally avoided on more complex matrix circuits with diodes along the switches, but these were ommitted on the Scout to cut down on kit cost and assembly time, and the Scout's monophony was an intentional limitation to deter encountering it. After all, _it is supposed to be simple instrument_!

So it's _kind of_ a bug but _more_ like a "known issue" and a cost to be paid for the simplicity of the Scout's assembly.

### Homework

Looking at the matrix schematic, can you find other key combinations that will have the "chord problem"?
