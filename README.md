# XNP Gensokyo Trait System

> Current channel: V2 test
> Current version: `2.1.0-test.1`
> Build Marker: `XNP_V2_210_TEST1_IMPROVEMENTS_A`
> Test Workshop ID: `3762431102`
> Stable release: separate release chain, not updated by this publication

**The current `SOURCE/` tree is a test build, not the stable release.**

[中文说明](README_CN.md) | [English README](README_EN.md) | [Test Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3762431102)

## Current Source

`SOURCE/` directly contains the installable Project Zomboid mod tree:

```text
SOURCE/
├─ mod.info
├─ poster.png
└─ 42/
   ├─ mod.info
   ├─ poster.png
   └─ media/
```

The repository keeps the older `src/`, `history/`, and `docs/` development archive. Those records are not replaced by the current test source.

## Four-Trait System

- Yellow: Distance Runner movement, stamina, and emergency breakout behavior.
- Red: Guardian and crafting feedback systems.
- Green: projectile and combat utility systems.
- Purple: Phoenix recovery and independent Life Stock inheritance systems.

## Test Build Additions

- Alt-triggered yellow crowd breakout with zero direct damage and no duplicate world scan.
- Bounded red crafting sweat, temperature, exertion, and fatigue feedback.
- One-summary purple footwear repair feedback.
- Disabled-by-default developer tools for XNP-owned damaged test items.
- Unified authoritative Sandbox tuning for the new options.
- Phoenix protection checks that restore only when an actual leak is detected.

## Evidence Status

| Area | Status | Boundary |
| --- | --- | --- |
| Yellow Alt breakout | PARTIAL | Offline checks pass; exact Build 42 grab/bite interruption still needs a real-game test. |
| Red crafting feedback | PASS | Static and offline harness pass. |
| Purple repair summary | PASS | Static and offline harness pass. |
| Developer test tools | PASS | Static and offline harness pass; disabled by default. |
| Sandbox authority | PASS | Raw/effective option drift is zero in offline checks. |
| Phoenix leak optimization | PASS | Offline regression checks pass. |
| Combined test-build runtime | NOT_TESTED | No complete real-game matrix has been recorded for this exact package. |

Offline verification completed with 130/130 Kahlua syntax checks and all recorded regression harness groups passing. Offline evidence is not a substitute for Build 42 runtime evidence.

## Installation From Source

Copy the contents of `SOURCE/` into a local Project Zomboid mod folder named `XNP_PZ_DistanceRunnerTrait`, then enable the mod for Build 42. The Workshop test item is the recommended route for ordinary testing.

## Known Limits

- Build 42.20 compatibility is not yet tested.
- Multiplayer behavior is not fully validated.
- Bandits2 is optional compatibility, not a hard dependency.
- Exact yellow strong-control interruption remains runtime-partial.

## History And License

- [Current test status](docs/CURRENT_STATUS.md)
- [Archived baseline status](docs/BASELINE_STATUS.md)
- [Development history](history/)
- [License status](LICENSE_STATUS.md)

No open-source license has been selected. **All rights reserved.**
