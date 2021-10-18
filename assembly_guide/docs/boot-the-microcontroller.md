---
id: boot-the-microcontroller
title: Boot the microcontroller
sidebar_label: Boot the microcontroller
slug: /boot-the-microcontroller
---

## Steps

1. Solder capacitors **C1** (220uF) and **C2** (.1uF, marked 104), oscillator **Y1**, and resistors **R2** (220, Red Red Brown) and **R5** (10k, Brown Black Orange).
   - **C1** has polarity. Match its white side to the white side of its footprint.
2. Solder **U1** socket. It will have a dimple at one end, which should match the footprint on the PCB.
3. With the power off, carefully insert **ATmega328**. It will have a dimple (and/or a small dot in a corner), which should match the socket.

## Test

Turn the power switch back on, and the LED should blink a new, different color a couple times. This lets you know that the ATmega is booted up and ready. Power off.\_

![030400@0.5x.jpg](../../images/pcb_assembly/030400@0.5x.jpg)
