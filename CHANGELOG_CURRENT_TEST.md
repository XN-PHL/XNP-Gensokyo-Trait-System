# Changelog: 2.1.0-test.1

Build Marker: `XNP_V2_210_TEST1_IMPROVEMENTS_A`

## Added

- Alt-triggered yellow crowd breakout using one edge-triggered scan.
- Configurable yellow endurance and cooldown costs.
- Bounded red crafting sweat, temperature, exertion, and fatigue feedback.
- A single purple footwear repair result summary.
- Disabled-by-default developer tools for damaged XNP-owned test items.
- Fourteen synchronized Sandbox options for the new behavior.

## Changed

- Phoenix protection now checks integrity every 100 ms and performs a full restore only after a real protection leak.
- Test-channel identity is separated from the `2.0.0` stable release chain.

## Verification

- Kahlua syntax: 130/130 PASS.
- New-feature harness: 19/19 PASS.
- Core regression harness: 28/28 PASS.
- Footwear regression: 22/22 PASS.
- Ranged invulnerability regression: 49/49 PASS.
- Phoenix role regression: 33/33 PASS.
- Static audit: 46/46 PASS.

## Runtime Boundary

Yellow strong-control interruption is `PARTIAL` until confirmed in Build 42 gameplay. The complete real-game and multiplayer matrix for this exact package is `NOT_TESTED`.
