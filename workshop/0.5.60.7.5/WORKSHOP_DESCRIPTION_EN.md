# XNP Gensokyo Trait System 0.5.60.7.5 Runtime Test

This build tests corrected Green inflight visibility, fail-closed draw proof, and bounded local outline scanning.

- Every render frame projects authoritative floating-point world coordinates with the selected player's camera, zoom, and viewport.
- Even a nearby target requires at least 500 ms and two in-viewport center/glow draw frames.
- Impact damage is rejected and cooldown refunded when inflight draw proof is missing.
- A bright diagnostic border defaults on for this test and must be disabled before stable release.
- Outline pulses scan only local squares inside the default 4-tile lock area.
- Zombies, Bandits, and confirmed human NPCs can be damaged according to Sandbox settings.
- Players and ambiguous humanoids remain immune.
- Runtime-test no-cooldown is enabled by default; the formal Green cooldown remains 5 seconds.

This is a `RUNTIME_TEST`. Inflight pixel visibility still requires user in-game validation.
