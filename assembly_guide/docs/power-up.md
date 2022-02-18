---
id: power-up
title: Power up
description: Getting power to Scout's PCB and toggling an LED.
sidebar_label: Power up
image: /img/pcb_assembly/020400@0.5x.jpg
slug: /power-up
---

## Steps

1. Solder LED at **D1**
   1. The LED has four pins for three different colors plus ground. The longest one is to ground and it goes to the hole that has a line coming out of it.
      ![020101@0.5x.jpg](/img/pcb_assembly/020101@0.5x.jpg)
   2. Get the LED as vertically close to the PCB as reasonable; it doesn't have to be flat against PCB but does need to be straight up and down -- no leaning!
      ![020102@0.5x.jpg](/img/pcb_assembly/020102@0.5x.jpg)
2. Solder sliding toggle switch **SW1** and resistor **R1** (220, Red Red Brown).
   - Make sure the switch is flat against the PCB and its actuator is pointing left, away from the PCB.
   - You can use a bit of tape or "Blu-Tack" adhesive to hold the switch in place as you solder.
3. Wire battery pack to **BT1**
   1. Thread the other side of the ribbon cable connected to the battery pack up through the hole near **BT1**, then strip and solder in place. Make sure the "+" and "-" wires are going to the right places.

## Test

Add the batteries back. Toggling **SW1** should now light one color of the LED! Yes, it is bright!! Power off before continuing soldering.

![020400@0.5x.jpg](/img/pcb_assembly/020400@0.5x.jpg)

Not working as expected? Check the [PCB troubleshooting](pcb-troubleshooting.md) section. Otherwise, continue to the next step.
