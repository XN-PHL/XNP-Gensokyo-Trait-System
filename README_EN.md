# XNP Gensokyo Trait System V2 Test

```text
Channel: V2 test
Version: 2.1.0-test.1
Build Marker: XNP_V2_210_TEST1_IMPROVEMENTS_A
Test Workshop ID: 3762431102
Stable release updated by this publication: no
```

The current `SOURCE/` tree is a test build, not the stable release.

## What Is Included

The mod combines four independent trait systems:

- Yellow: Distance Runner movement and emergency breakout.
- Red: Guardian and crafting feedback.
- Green: projectile and combat utility.
- Purple: Phoenix recovery and independent Life Stock inheritance.

Version `2.1.0-test.1` adds the yellow Alt crowd breakout, bounded red crafting feedback, a single purple repair summary, disabled-by-default developer item tools, synchronized Sandbox options, and a Phoenix leak-only restore optimization.

## Verification Status

- Yellow Alt breakout: `PARTIAL`. Offline checks pass; exact Build 42 grab/bite interruption still requires a real-game test.
- Red crafting feedback: `PASS` in static and offline checks.
- Purple repair summary: `PASS` in static and offline checks.
- Developer tools: `PASS` in static and offline checks, disabled by default.
- Sandbox authority: `PASS` in offline checks.
- Phoenix leak optimization: `PASS` in offline regression checks.
- Full combined runtime matrix for this exact test package: `NOT_TESTED`.

Kahlua syntax passed 130/130 files. All recorded offline regression harness groups passed. These results do not claim complete real-game or multiplayer validation.

## Install

Copy the contents of `SOURCE/` into a local Project Zomboid mod folder named `XNP_PZ_DistanceRunnerTrait`, or subscribe to the [test Workshop item](https://steamcommunity.com/sharedfiles/filedetails/?id=3762431102).

The older `src/`, `history/`, and `docs/` trees remain available as development records.

No open-source license has been selected. **All rights reserved.**
