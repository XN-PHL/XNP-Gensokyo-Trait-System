# Current Test Status

## Identity

```text
CHANNEL=V2_TEST
VERSION=2.1.0-test.1
INTERNAL_VERSION=2.1.0-test.1-pz-improvements-a
BUILD_MARKER=XNP_V2_210_TEST1_IMPROVEMENTS_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
TEST_WORKSHOP_ID=3762431102
STABLE_WORKSHOP_UPDATED=false
```

## Evidence

```text
SOURCE_WORKSHOP_RUNTIME_DIFF=0
KAHLUA_SYNTAX=130/130 PASS
NEW_FEATURE_HARNESS=19/19 PASS
CORE_REGRESSION_HARNESS=28/28 PASS
FOOTWEAR_REGRESSION=22/22 PASS
RANGED_INVULNERABILITY_REGRESSION=49/49 PASS
PHOENIX_ROLE_REGRESSION=33/33 PASS
STATIC_AUDIT=46/46 PASS
```

## Feature Matrix

| Feature | Status | Evidence boundary |
| --- | --- | --- |
| Yellow Alt crowd breakout | PARTIAL | Offline pass; real-game grab/bite interruption is not confirmed. |
| Red crafting feedback | PASS | Static and offline harness. |
| Purple repair summary | PASS | Static and offline harness. |
| Developer test tools | PASS | Static and offline harness; default disabled. |
| Sandbox authority | PASS | Offline raw/effective drift count is zero. |
| Phoenix leak-only restore | PASS | Offline regression harness. |
| Full Build 42.19 combined test | NOT_TESTED | No result recorded for this exact package. |
| Build 42.20 | NOT_TESTED | No runtime evidence. |
| Multiplayer | NOT_TESTED | Not fully validated. |

`visible in source`, `static pass`, and `offline pass` are not treated as proof of real-game behavior.

## Repository Boundary

The current installable test source is under `SOURCE/`. Existing `src/`, `history/`, and earlier `docs/` material remains preserved as development history. No stable release or stable Workshop project is changed by this publication.
