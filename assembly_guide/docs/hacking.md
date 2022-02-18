---
id: hacking
title: Hacking
description: Hack, hack, hack, hack, hack, hack.
sidebar_label: Hacking
image: /img/scout-10-838-032.gif
slug: /hacking
---

:::info
This section is optional!
:::

## Required equipment

To keep the Scout's price more accessible, it doesn't come with a built-in USB controller chip, so, out of the box, you can't easily hook it up to your computer as-is.

Thankfully, that USB chip is readily available as a cable, which you can connect between your Scout and your computer.

These cables have been tested and confirmed to work with the Scout:

- [FTDI Serial TTL-232 USB Cable](https://www.adafruit.com/product/70) from Adafruit
- [USB Serial Cable](https://cornfieldelectronics.com/cfe/products/buy.php?productId=usbcable&PHPSESSID=oos5v81hlitjvb0grhgolsrq96) from Cornfield Electronics

:::note
Successfully use a different brand of cable? [Contact me](https://www.oskitone.com/contact) and I can add it to the list.
:::

## Change the Arduino code

Ready to experiment and get your hands dirty with some code?

1. Install the [Arduino IDE](https://www.arduino.cc/en/software) and follow their instructions to install whatever drivers you'd need for an Arduino Uno.
2. With the Scout's power off, use an [FTDI Serial TTL-232 cable](https://www.adafruit.com/product/70) to connect the Scout's UART header to your computer.
   1. The Scout's UART header has "B" and "G" labels on its sides to match the cables Black and Green wires.
   2. The cable provides power to the Scout, so it should now be on and working normally
   3. **Double check that the power switch is OFF!** Leaving it on can permanently damage the microcontroller or batteries!
3. In the IDE, under "Tools->Board", select "Arduino Uno". Under "Tools->Port" select your new cable; its exact name will depend on the brand. If you're not sure which it is, try unplugging and restarting the IDE -- whichever it was will no longer be listed, so you'll know which it is when reconnecting and restarting.
4. Download the code from this repo and load `arduino/scout.ino` in the Arduino IDE. You'll also need the `CircularBuffer` and `Keypad` libraries, so open up "Tools->Manage libraries" and search for those to install them.
   1. Try uploading this to the Scout by going to "Sketch->Upload". If it works, after 10 seconds or so, it will blink just like it does when you switch its power on. If it doesn't work, the IDE will print out an error that you can google to find out how to fix.
   2. Experiment with the `octave` and `glide` values at the top of `scout.ino` and observe how your Scout has changed its sound.
5. "Blink"
   1. The Arduino IDE has a default program called "Blink" (available in "File->Examples->Basics->Blink").
   2. After uploading, the Scout won't be playable anymore but one of the colors on the RGB LED should blink off and on.
   3. Try changing the delay values in the example to make it blink faster or slower.
   4. Follow the steps above to bring the original Scout code back.

Once you're comfortable with the Arduino code and really want to expand on what the Scout can do, take a look at the unpopulated HACK header on the PCB. It exposes all the unused pins on the ATmega328 that are safe to use for whatever you'd like:

| HACK         | ATmega pins | Description                                         |
| ------------ | ----------- | --------------------------------------------------- |
| VCC          | n/a         | Voltage from batteries or USB                       |
| A0-A5        | 23-28       | Analog pins                                         |
| D12          | 18          | There's only one unused digital pin, and this is it |
| SWC, SW1-SW3 | 16; 6,11,12 | Unused spots in the key matrix                      |
| GND          | n/a         | Ground                                              |

## Community hacks

- **[arpeggio_hack](https://github.com/shamlian/scout/tree/arpeggio_hack) from [Steven Shamlian](https://github.com/shamlian):** Adds polyphony by arpeggiating through the held notes. The full hack requires diodes on the switches to prevent key ghosting, but otherwise the Arduino code can work w/o any hardware changes... provided you only play certain chords or don't mind the occasional wrong note. Pretty interesting!
- **[MozziScout](https://github.com/todbot/MozziScout) from [todbot](https://todbot.com/):** With some careful pin swapping on the ATmega328, the Scout can use [Mozzi](https://sensorium.github.io/Mozzi/), the popular sound synthesis library for Arduino. For this hack, it's a good idea to plug into an amplifier &mdash; the new sounds your Scout will make are much richer than what its built-in speaker is capable!

:::note
Got a hack you want to share? [Contact me](https://www.oskitone.com/contact) and I can add it to the list.
:::

## Other ideas

- For extra stability, add ruber feet to the bottom of your Scout.
