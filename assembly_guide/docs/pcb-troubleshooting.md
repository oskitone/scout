---
id: pcb-troubleshooting
title: PCB troubleshooting
description: Common problems that come up when soldering the Scout PCB.
sidebar_label: PCB troubleshooting
image: /img/scout_assembly-16-420-8-128.gif
slug: /pcb-troubleshooting
---

## General tips

Any of these problems can cause a variety of "just not working right" errors in a circuit. Familiarize yourself with these troubleshooting checks and do them regularly.

- Turn the PCB over and check all solder joints. A majority of problems are caused by insufficient or errant soldering. Familiarize yourself with what a good joint looks like in the [Adafruit Guide To Excellent Soldering](https://learn.adafruit.com/adafruit-guide-excellent-soldering).
- Are all chips in the right orientation? Each has a notch/dimple that should match the footprint outline on the PCB.
- Do the batteries have enough power? The three batteries should have a total voltage of 3.6 to 4.5 volts. If the Scout seems like it's restarting a lot as you play it, that's a good sign the batteries need replacing.

## Specific issues

- If there’s buzzing, check for any metal scraps stuck to the speaker’s magnet.
- If some keys are touchy or behaving weird, check to see that their switches are inserted all the way and perfectly flat against the PCB. (See also: the "Key problems" section in [Assembly troubleshooting](assembly-troubleshooting.md))
- If multiple keys seem to be tied to the same note, there's probably a short (an accidental connection between soldering points) somewhere. Check all joints as described above, then try cleaning the bottom of the PCB with isopropyl alcohol. Leftover flux and resin from the soldering process _can_ be conductive!
- If you're hearing an unwanted hum from the speaker when the Scout isn't being played, verify all .1uF caps are soldered well. It may also be from noise added by long wires, so do use the recommended wire lengths in this guide.
