# Function success record

## User-confirmed result

`USER_CONFIRMED_REQUIRED_FUNCTIONS_PRESENT=true`

The user confirmed that this build contains the required functions. Evidence role: `USER_CONFIRMED_RUNTIME_RESULT`. This statement is intentionally not labeled as an automated or exhaustive runtime test.

## Statically verified implementation

- Corrected per-player world-to-screen projection is present.
- Inflight drawing is gated by a valid texture/draw path.
- Impact requires successful draw proof, at least 500 ms, and at least two drawn frames.
- Failed proof prevents damage and refunds cooldown.
- Local outline target discovery is bounded and does not enumerate a global zombie list.
- NPC/Bandit damage and player immunity remain represented in the impact path.
- Purple cooldown remains three seconds.
- Green no-cooldown and inflight diagnostic border are wired through sandbox options and default to `true` for this test build.
- All 101 Lua files pass the Kahlua syntax check in both the source tree and supplied Workshop mirror.

## Publication conclusion

The evidence is sufficient to preserve a public development record and prepare the development branch. It is not sufficient to label the build stable: test defaults are still enabled and no license has been selected.

