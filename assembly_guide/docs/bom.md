---
id: bom
title: Annotated BOM
description: Bill of Materials, annotated.
sidebar_label: Annotated BOM
image: /img/scout_assembly-16-420-8-128.gif
slug: /bom
hide_table_of_contents: true
---

| Designator | Designation                   | Quantity | Marking            | Usage                                                                                 |
| ---------- | ----------------------------- | -------- | ------------------ | ------------------------------------------------------------------------------------- |
| BT1        | 3.6v-4.5v                     | 1        | n/a                | Power; wires to 3\*AAA battery pack                                                   |
| C1,C5      | 220uF                         | 2        | n/a                | Big bypass cap, Amp output                                                            |
| C3         | 1uF                           | 1        | n/a                | Amp gain                                                                              |
| C2,C4,C6   | .1uF                          | 3        | 104                | Bypass caps, RESET pin cap (C4)                                                       |
| D1         | LED_CRGB                      | 1        | n/a                | On/off+playing indicators                                                             |
| J1         | AudioJack2_SwitchT            | 1        | n/a                | Line out headphone jack                                                               |
| J2         | Conn_01x06_Male               | 1        | n/a                | Programming header                                                                    |
| LS1        | Speaker, AZ40R 40mm x 5mm     | 1        | n/a                | Wires to output speaker                                                               |
| R1,R2      | 220                           | 2        | Red Red Brown      | LED current limiters                                                                  |
| R3,R5      | 10k                           | 2        | Brown Black Orange | Brings volume closer to ear-safe level for line out, "pull up" resistor for RESET pin |
| R4         | 1m                            | 1        | Brown Black Green  | Drops volume even more before amp                                                     |
| RV1        | 10k Log, RV09AF-40-20K-A10K   | 1        | n/a                | Volume control                                                                        |
| SW1        | SPDT, OS102011MA1QN1          | 1        | n/a                | On/off power switch                                                                   |
| SW2-SW18   | SPST, 6mm tall                | 17       | n/a                | Key buttons                                                                           |
| U1         | ATmega328P-PU with bootloader | 1        | n/a                | Microcontroller chip                                                                  |
| U2         | LM386                         | 1        | n/a                | Amplifier chip                                                                        |
| Y1         | 16.00MHz                      | 1        | n/a                | Ceramic oscillator for microcontroller                                                |

Also:

- 2 2-wire ribbon cables (or similar small gauge, stranded wire)
  - 1 7" for BT1
  - 1 3" for LS1
- 4 battery terminal contacts for BT1
  - 2 dual spring+button wire contacts (Keystone 181)
  - 1 tabbed spring contact (Keystone 5204)
  - 1 tabbed button contact (Keystone 5226)
- 2 DIP sockets
  - 1 28 pin for U1
  - 1 8 pin for U2
- 4 nuts and bolts
  - 2 4/40 square nuts
  - 2 4/40 3/4" machine screws

Alternate speakers for the AZ40R:

- PSR-40N08A05-JQ
- AS04008MR-21-R
- CMS-4051-058SP

Any circular 8ohm speaker that matches the dimensions will probably work, thought you may find you need a bit of hot glue to hold it in place.
