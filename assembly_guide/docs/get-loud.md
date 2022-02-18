---
id: get-loud
title: Get loud
description: How to solder the Scout's amp to, you guessed it!, get loud.
sidebar_label: Get loud
image: /img/pcb_assembly/060500@0.5x.jpg
slug: /get-loud
---

## Steps

1. Solder capacitors **C5** (220uF) and **C6** (.1uF, marked 104) and resistor **R4** (1m, Brown Black Green; resistor body may be blue in your kit).
   - Make sure **C5**'s polariy matches its footprint, just like **C1**.
2. Wire speaker to **LS1**.
   1. Thread remaining ribbon cable through hole.
      ![060201@0.5x.jpg](/img/pcb_assembly/060201@0.5x.jpg)
   2. Strip insulation and solder to **LS1**.
   3. Strip and solder the other ends to the speaker, matching the "+" and "-" sides.
3. Solder socket **U2**. Match its dimple to the footprint, just like **U1**.
4. With the power off, carefully insert **LM386** chip, again making sure its inserted the correct way.

## Test

Power on, unplug your headphones, and press the switch. It should be playing out of the speaker now. Power off.

![060500@0.5x.jpg](/img/pcb_assembly/060500@0.5x.jpg)

Not working as expected? Check the [PCB troubleshooting](pcb-troubleshooting.md) section. Otherwise, continue to the next step.
