# Scout

**Work-In-Progress!** PCBs are done (I hope!), but enclosure is still baking and I need to write up proper documentation. Stay tuned.

---

![Scout](scout_render.png)

**scout** (_/skout/_):

1. _One sent to obtain information_
2. _Jean Louise “Scout” Finch, of Atticus Finch_
3. _The first synth from Oskitone to venture into the big ol' world of microcontrollers_

The Scout is:

- **Hackable:** Powered by an ATmega328 and can be re-programmed just like an Arduino Uno using an [FTDI Serial TTL-232 cable](https://www.adafruit.com/product/70). And fully open source!
- **3D-Printable:** Besides the electronics and some common nuts and bolts, all parts can be 3D-printed. And with a width of ~160mm (about 6.3"), the Scout can fit on smaller, "mini" print beds.
- **Minimally featured:** Monophonic square wave with fixed glide and octave. 1.5 octaves of keys, a volume knob, on/off switch, headphone jack. No MIDI/CV or other IO.
- **Beginner-friendly:** All through-hole components for soldering and assembles in about 45min. Standalone, battery-powered, doesn't need a computer or external speakers to work. Fun!

## Goals

In addition to the Scout being the first microcontroller-controlled instrument from Oskitone, it would also make a fine first DIY instrument for the budding electronics hobbyist.

As such, its design is guided by a metric I'm calling "Time-to-Noise" (TTN): the time it takes from starting the kit to making music with it. The lower the better.

- Minimum number of components for reduced assembly time
- Able to print on "mini" (18x18x18cm) sized 3D printers
- Built-in speaker
- Minimum number of notes
- Volume control

~Any secondary features should be optional; circuit must function w/o them:~

- ~Line-out jack~ _Eh, easier said than done_
- ~Octave control~ _Removed!_

## Detailed Assembly Steps

### PCB Soldering Instructions

(Not your first electronics kit? Skip to the BOM below! :) )

**Required tools:** soldering iron and solder for electronics, wire stripper or cutters, 3 AAA batteries
**Recommended:** multimeter for debugging, PCB vice or “helping hands” holder, “Solder sucker” or desoldering braid, headphones

Each group of steps in the Scout's assembly has a test at the end to make sure everything is working as expected. If it doesn't work, don't fret! Look over the troubleshooting tips below. Don't move on in the instructions until you've got it working.

1. **Assemble battery pack**
   1. Insert tabbed battery contact terminals
      1. The springed contact goes to the spot with a "-".
      2. The flat, button contact goes near "+". Its button should face inward towards where the battery will be.
      3. Fold their tabs over to hold them in place.
   2. Insert wire dual contacts
      1. Again, springs go to "-" and buttons to "+"
   3. Add wire
      1. Thread the 7" ribbon cable through battery holder's hitches. Your ribbon cable will probably have different colors, and that's okay! A common convention is to use the darker color for "-" and the lighter one for "+".
      2. Strip 1/4" of insulation off the wires and solder to the battery contacts.
      3. Strip the other ends of the wires.
   4. Insert three AAA batteries, matching their "+" and "-" sides to the battery holder's labels.
   5. _Using a multimeter, measure the total voltage on those two wires. It should measure the sum of the three indivual batteries' voltages._
2. **Power up**
   1. Solder LED at **D1**
      1. The LED has four pins for three different colors plus ground. The longest one is to ground and it goes to the hole that has a line coming out of it.
      2. Get the LED as vertically close to the PCB as reasonable; it doesn't have to be flat against PCB but does need to be straight up and down -- no leaning!
   2. Solder sliding toggle switch **SW1** and resistor **R1**
   3. Wire battery pack to **BT1**
      1. Thread the other side of the ribbon cable connected to the battery pack up through the hole near **BT1**, then strip and solder in place. Make sure the "+" and "-" wires are going where they should!
   4. _Toggling **SW1** should now light one color of the LED! Power off before continuing soldering._
3. **Boot the microcontroller**
   1. Solder capacitors **C1** and **C2**, oscillator **Y1**, and resistor **R5**.
      1. **C1** has polarity. Match its white side to the white side of its footprint.
   2. Solder resistor **R2**.
   3. Solder **U1** socket. It will have a dimple at one end, which should match the footprint on the PCB.
   4. Carefully insert ATmega328. It will have a dimple (and/or a small dot in a corner), which should match the socket.
   5. _Turn the power switch back on, and the LED should blink a new, different color a couple times. This lets you know that the ATmega is booted up and ready. Power off._
4. **Get logical**
   1. Solder an SPST switch to **SW2**.
   2. _With power on, press the switch. The LED should light just like it does on boot! Power off._
5. **Make some noise**
   1. Solder volume pot **RV1**, resistor **R3**, and headphone jack **J1**.
      1. Make sure **RV1** and **J1** are pushed all the way into PCB before soldering all the way.
   2. Connect your headphones into the headphone jack. Push firmly until it clicks in all the way.
   3. _With power on, press **SW2**. You should hear a tone from the headphones, and the volume potentiometer should adjust its volume. Power off._
6. **Get loud**
   1. Solder amp capacitors **C6** and **C5**.
      1. Make sure **C5**'s polariy matches its footprint, just like **C1**.
   2. Wire speaker to **LS1**.
      1. Thread remaining ribbon cable through hole.
      2. Strip insulation and solder to **LS1**.
      3. Strip and solder the other ends to the speaker, matching the "+" and "-" sides.
   3. Solder socket **U2**. Match its dimple to the footprint, just like **U1**.
   4. Insert LM386 chip, again making sure its inserted the correct way.
   5. _Power on, unplug your headphones, and press the switch. It should be playing out of the speaker now. Power off._
7. **More notes**
   1. Solder the remaining tactile 16 switches, **SW3** through **SW18**.
   2. _Power on and press each. They should all play different notes out of the speaker. Power off._
8. **Get louder (Optional. Skip if it's already loud enough for you!)**
   1. Solder cap **C3**.
      1. Match polarity.
   2. _Power on, unplug your headphones, and press the switch. The speaker should now be much louder now! Power off._

#### Troubleshooting

- Turn the PCB over and check all solder joints. A majority of problems are caused by insufficient or errant soldering. Familiarize yourself with what a good joint looks like in the [Adafruit Guide To Excellent Soldering](https://learn.adafruit.com/adafruit-guide-excellent-soldering).
- Are all chips in the right orientation? Each has a notch/dimple that should match the footprint outline on the PCB.
- Do the batteries have enough power? The three batteries should have a total voltage of 3.6 to 4.5 volts.
- If there’s buzzing, check for any metal scraps stuck to the speaker’s magnet.

<!-- ### Final Assembly -->

<!-- TODO! -->

## Annotated BOM

Based on KiCad board BOM, with non-essential footprints removed and usages explained.

| Designator | Designation        | Quantity | Marking            | Usage                                                                                 |
| ---------- | ------------------ | -------- | ------------------ | ------------------------------------------------------------------------------------- |
| BT1        | 4.5v               | 1        | n/a                | Power; wires to 3\*AAA battery pack                                                   |
| C1,C5      | 220uF              | 1        | n/a                | Big bypass cap, Amp output                                                            |
| C3         | 1uF                | 1        | n/a                | Amp gain                                                                              |
| C2,C4,C6   | .1uF               | 3        | 104                | Bypass caps, RESET pin cap (C4)                                                       |
| D1         | LED_CRGB           | 1        | n/a                | On/off+playing indicators                                                             |
| J1         | AudioJack2_SwitchT | 1        | n/a                | Line out headphone jack                                                               |
| J2         | Conn_01x06_Male    | 1        | n/a                | Programming header                                                                    |
| LS1        | Speaker            | 1        | n/a                | Wires to output speaker                                                               |
| R1,R2,R3   | 220                | 3        | Red Red Brown      | LED current limiters                                                                  |
| R4,R6      | 10k                | 1        | Brown Black Orange | Brings volume closer to ear-safe level for line out, "pull up" resistor for RESET pin |
| R5         | 1m                 | 1        | Brown Black Green  | Drops volume even more before amp                                                     |
| RV1        | 10k Log            | 1        | n/a                | Volume control                                                                        |
| SW1        | SW_SPST            | 1        | n/a                | On/off power switch                                                                   |
| SW2-SW18   | SPST               | 17       | n/a                | Key buttons                                                                           |
| U1         | ATmega328P-PU      | 1        | n/a                | Microcontroller chip                                                                  |
| U2         | LM386              | 1        | n/a                | Amplifier chip                                                                        |
| Y1         | 16.00MHz           | 1        | 160B               | Ceramic oscillator for microcontroller                                                |

Also:

- 10" wire
  - BT1 7"
  - LS1 4"
- Battery terminal contacts for BT1
- 2 dual spring+button wire contacts
  - 1 tabbed spring contact
  - 1 tabbed button contact
- 2 sockets
  - 1 28 pin for U1
  - 1 8 pin for U2

## License

Designed by Oskitone. Please support future synth projects by purchasing from [Oskitone](https://www.oskitone.com/).

Creative Commons Attribution/Share-Alike, all text above must be included in any redistribution. See license.txt for additional details.
