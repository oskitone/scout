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

## Debugging with the serial monitor

If we [log out the indexes of the buttons](change-the-arduino-code.md#serial-debugging) being pressed and play **C**, **D**, **E** individually it looks like this:

[![Screengrab of the Arduino serial monitor while playing C, D, and E individually](/img/hack/chord-individual.png)](/img/hack/chord-individual.png)

Makes sense. **0** is **C**, **2** is **D**, and **4** is **E**. That's just what we expected! (In code, we order lists starting at 0 instead of 1, so the indexes of the list of 17 keys go from 0 to 16, not 1 to 17.)

But holding them together looks like this:

[![Screengrab of the Arduino serial monitor while playing C, D, and E together](/img/hack/chord-cde.png)](/img/hack/chord-cde.png)

The **0**, **2**, **4** are in there (reverse ordered but that's irrelevant) but we also see a fourth index, **6**. That's the index of the **F#** key.

Playing and holding **E**, **D**, **C** is the same with a different order:

[![Screengrab of the Arduino serial monitor while playing E, D, and C together](/img/hack/chord-edc.png)](/img/hack/chord-edc.png)

That doesn't solve our problem, but it does tell us that the microcontroller is indeed interpreting that the **C**, **D**, and **E** keys are being pressed but, for some reason, incorrectly _adding_ the **F#**.

## Checking the schematic

### A matrix of keys

The Scout has 17 keys but they only take up 9 pins on the ATmega328. It does this by convincing the microcontroller that the 17 keys are arranged in a matrix of rows and columns: 4 rows \* 5 columns = 20 possible keys.

When a key is pressed and its switch closes, the pins for its row and column connect.

The matrix of rows and columns with the notes labelled, read from top to bottom and _then_ left to right:

[![Matrix schematic with switches labelled to their corresponding notes](/img/hack/matrix.png)](/img/hack/matrix.png)

- **Note 1:** The ATmega328 only has 14 digital input/output (IO) pins, which wouldn't be enough for all the keys if they were wired individually. There are other ways besides a matrix to get more IO out of our chip but they all require soldering more components.
- **Note 2:** The 3 remaining, unused matrix spots in the bottom right are available for use on the ["HACK" header](change-the-arduino-code.md#pins).
- **Note 3:** Awkwardly, the hardware components for the notes are indexed from SW2 to SW18, because only the code uses zero-indexing and the on/off switch was SW1. Thankfully, at least they are still in linear order!

### Connecting rows and columns

We can see that **C** is **R1C1** (Row 1, column 1), **D** is **R3C1**, and **E** is **R1C2**.

[![Matrix schematic with C, D, and E matrix points highlighted](/img/hack/matrix-trio.png)](/img/hack/matrix-trio.png)

But to the microcontroller, it also sure looks like you're pressing **F#** at **R3C2**. I mean, how could it know you're not? So it just throws it in there.

[![Matrix schematic with C, D, and E matrix points highlighted](/img/hack/matrix-f_sharp.png)](/img/hack/matrix-f_sharp.png)

That's the culprit!!

## Is it a bug?

Issues like this "chord problem" are normally avoided on more complex matrix circuits like your computer keyboard with diodes along the switches, but these were ommitted on the Scout to cut down on kit cost and assembly time. The Scout's monophony was an intentional limitation to deter encountering it. After all, _it is supposed to be simple instrument_!

So it's _kind of_ a bug but _more_ like a "known issue" and a cost to be paid for the simplicity of the Scout's assembly.

### Homework

Looking at the matrix schematic, can you find other key combinations that will have the "chord problem"?
