# 0.5.12 Sanitized Evidence Excerpts

## BUILD_MARKER.txt

- SHA-256: `35794448ABA88556B45CCB74557A82C0B1998486FB6769371EDA4767EA79E473`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0512_PRECOLLISION_BREAKOUT_A

```

## FINAL_REPORT.md

- SHA-256: `CD80A1E4E14D396EF5C2F03F244708AAF1D2EF901B06DD23C6C66A96349381E4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.12

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Identity

- VERSION=0.5.12
- INTERNAL_VERSION=0.5.12-b42-precollision-breakout-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0512_PRECOLLISION_BREAKOUT_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.12 Precollision Breakout Fix
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

## Required Implementation

- Precollision Predictor: IMPLEMENTED
- Player Outcome Watchdog: IMPLEMENTED
- Zombie Recovery Watchdog: IMPLEMENTED

## Classification Fixes

- SPRINT speed=0.x: BLOCKED_BY_SPEED_FLOOR
- CROWD zombies=1: BLOCKED_BY_MIN_ZOMBIES_2
- CONTACT low dot: BAD_DOT skip
- Not closing: NOT_CLOSING skip
- visible=true success: REJECTED

## Safety

- Started Project Zomboid: NO
- Started Steam: NO
- Wrote user mods: NO
- Wrote saves: NO
- Wrote Workshop: NO
- Wrote game directory: NO
- Modified old SOURCE after correction: NO
- Packaged mod: NO

## Static Check

- Forbidden route grep: PASS
- Player coordinate write grep: PASS_NOT_FOUND
- Runtime route: `Core.BreakoutPush.Update(player)`
- VanillaImpact status: no-op and not called by Runtime
- JSON parse: PASS
- Text BOM/NULL scan: PASS
- Lua execution syntax check: NOT_VERIFIABLE_NO_LUA_INTERPRETER

## Counts

- Total files: 26
- Lua files: 15
- Lua total lines: 2040
- Markdown documents: 4

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.12_SOURCE_READY_FOR_PRECOLLISION_BREAKOUT_TEST

```

## PRECOLLISION_BREAKOUT_DESIGN_0.5.12.md

- SHA-256: `CCDABC6B3A4A11EDF70484B2E8D309F77F04912C5D240832E76644E9746BCC6E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Precollision Breakout Design 0.5.12

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Identity

- VERSION=0.5.12
- INTERNAL_VERSION=0.5.12-b42-precollision-breakout-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0512_PRECOLLISION_BREAKOUT_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.12 Precollision Breakout Fix

## Required Changes

- Precollision Predictor: implemented.
- Player Outcome Watchdog: implemented.
- Zombie Recovery Watchdog: implemented.

## Precollision Predictor

The sprint route no longer treats pure distance plus dot as contact. The predictor requires:

- continuous closing frames;
- decreasing zombie distance;
- player speed;
- front-sector dotForward;
- candidate distance inside the precontact band.

SPRINT_PRECOLLISION requires speed at least `1.00`, so a low `0.x` speed sample cannot be classified as sprint.

## Outcome Semantics

`visible=true` only means a visible zombie-side reaction was attempted or observed. It is not success.

Success is recorded only when the player remains up through the 0.35 second player outcome window:

- `[XNP BREAKOUT OUTCOME] result=PLAYER_STAYED_UP`

Failure is recorded when the player falls, trips, or is knocked down after a trigger:

- `[XNP BREAKOUT FAIL] reason=PLAYER_FELL_AFTER_PUSH`

## Zombie Recovery Watchdog

Each pushed zombie is registered for a recovery check. If it appears stuck after the recovery window, the module logs:

- `[XNP BREAKOUT FAIL] reason=ZOMBIE_AI_STUCK_AFTER_PUSH`

Recovery attempts are limited to clearing the temporary stagger/reaction flags. The module does not permanently freeze zombies, disable AI, or clear targets.

## Classification Guards

- CONTACT with low dotForward logs BAD_DOT and skips.
- Not-closing candidates log NOT_CLOSING and skip.
- CROWD requires at least 2 very close zombies.
- CROWD selects at most 2 zombies.
- Range-only trigger remains disabled.

## Summary Fields

The summary includes:

- success_player_stayed_up
- fail_player_fell_after_push
- fail_zombie_ai_stuck
- sprint_precollision
- contact
- grab
- crowd
- blocked_not_closing
- blocked_bad_dot

```

## PRECOLLISION_BREAKOUT_TEST_0.5.12.md

- SHA-256: `C9562E6100D18FE978AA2CA79DE92264CE59AC5C9C31D436C36340CA0391B373`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Precollision Breakout Test 0.5.12

## Manual Test

1. Enable only the 0.5.12 source and required translation mod.
2. Restart the game manually.
3. Confirm console contains `XNP_PZ_DISTANCE_TRAIT_0512_PRECOLLISION_BREAKOUT_A`.
4. Confirm Config loaded appears.
5. Sprint straight toward one zombie.
6. Expected: `trigger type=SPRINT_PRECOLLISION` appears before the old player fall sequence.
7. Confirm the sprint log speed is not `0.x`.
8. Confirm the player outcome log appears:
   - success: `[XNP BREAKOUT OUTCOME] result=PLAYER_STAYED_UP`
   - failure: `[XNP BREAKOUT FAIL] reason=PLAYER_FELL_AFTER_PUSH`
9. Jog or walk into close front contact.
10. Expected: CONTACT only when dotForward is high enough and the distance is closing.
11. Try a side approach.
12. Expected: BAD_DOT skip, not a false contact.
13. Let two or more zombies crowd the player at very close range while movement is stalled.
14. Expected: CROWD can trigger, with selected zombie count capped at 2.
15. Let one zombie grab or attack-windup at close range.
16. Expected: GRAB can trigger if the player is not already down.
17. Watch for zombie recovery logs after each push.

## Pass Criteria

- Precollision trigger occurs before the normal sprint trip/fall tail.
- Visible zombie reaction is not counted as success by itself.
- Player outcome watchdog reports stayed-up or fell-after-push.
- Zombie recovery watchdog logs stuck recovery failures if they occur.
- CROWD never triggers with one zombie.
- CONTACT skips low-dot approaches.

## Fail Criteria

- SPRINT_PRECOLLISION logs speed below 1.00.
- CONTACT triggers with a low dotForward.
- CROWD logs zombies=1.
- `visible=true` is reported as success.
- No player outcome log appears after a trigger.
- No zombie recovery registration/check happens after reaction or nudge.

```

## 0.5.12_INFORMATION_SYNC_AND_AUDIT.md

- SHA-256: `8094D39ADF239046A9A6EF63AEEE8D60B5A2FC394D75A13D93425345ED0C7766`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.12 Information Sync And Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## 1. Current Sync State

- Current SOURCE: `[LOCAL_PATH_REDACTED]`
- Current version: `0.5.12`
- Current build marker: `XNP_PZ_DISTANCE_TRAIT_0512_PRECOLLISION_BREAKOUT_A`
- Current goal: `Precollision Breakout Fix`
- Current source exists: PASS
- Active Lua old 0511 marker grep: PASS_NOT_FOUND
- Active Lua old ready status grep: PASS_NOT_FOUND
- Runtime loads `XNP_DR_BreakoutPush.lua`: PASS
- Runtime calls `Core.BreakoutPush.Update(player)`: PASS
- `XNP_DR_VanillaImpact.lua` remains no-op and is not called from Runtime: PASS

## 2. 0.5.11 Real-Game Failure Sync

Accepted 0.5.11 result:

- 0.5.11 loaded.
- 0.5.11 could trigger BREAKOUT.
- `visible=true` did not prove success.
- The player could still be tripped / sent OnFloor by zombies.
- Zombies could sometimes get stuck after the push stack.
- Classification pollution was observed:
  - SPRINT with speed near `0.7510`.
  - CROWD with `zombies=1`.
  - CONTACT with low dot.

Audit target for 0.5.12:

- Verify whether precollision triggers before the vanilla player fall tail.
- Verify whether success is judged by player outcome, not visible reaction.
- Verify whether zombie recovery watchdog exists.
- Verify whether classification pollution is actually fixed.

## 3. Precollision Predictor Audit

Status: RISK

Evidence from `XNP_DR_BreakoutPush.lua`:

- `zombieHistory` exists.
- Per-zombie history stores `lastDistance`, `lastTime`, `closingFrames`, `lastDelta`, `lastDot`.
- `candidateIsClosing` requires `closingFrames >= PRECOLLISION_REQUIRED_CLOSING_FRAMES` and `lastDelta >= PRECOLLISION_MIN_DISTANCE_DELTA`.
- `DetectPrecollisionTrigger` requires distance band, closing history, dotForward, and speed.
- Pure range-only trigger is not used for SPRINT_PRECOLLISION.
- Pure dot-only trigger is not enough.
- Single-frame approach is not enough because closing frames are required.

Gaps:

- The requested explicit fields `currentDist`, `distDelta`, `framesClosing`, `dotForward`, `isFrontArc`, `isClosing`, and `isStableTarget` are not all represented by those exact runtime names.
- `RANGE_ONLY_REJECTED` log is not emitted.
- `LOW_SPEED_FOR_SPRINT` log is not emitted.
- `SPRINT_PRECOLLISION` uses `safeBool(player, "isSprinting") or speed >= PRECOLLISION_SPRINT_MIN_SPEED`, then also requires speed >= threshold.

Speed threshold audit:

- Current `PRECOLLISION_SPRINT_MIN_SPEED=1.00`.
- User-provided real-game data says full sprint reached about `6.7759`.
- User-provided real-game data says ordinary/contact movement can reach about `1.8584` and `2.0377`.
- Therefore `1.00` cannot be proven safe by static evidence.
- It may still classify ordinary movement or jog as SPRINT_PRECOLLISION.

Conclusion:

- `RISK_SPRINT_THRESHOLD_TOO_LOW`
- `RISK_SPRINT_CLASSIFICATION_BY_SPEED_ONLY`
- Recommended future split:
  - `jog_contact_speed_min`
  - `jog_contact_speed_max`
  - `sprint_precollision_speed_min`
  - `full_sprint_speed_reference`

##
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `1C73629256C94E2F219FE454F09D7D49EE8826C46A3D850500387FBB14557E3A`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.12

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Implemented Requirements

- Precollision Predictor: PASS
- Player Outcome Watchdog: PASS
- Zombie Recovery Watchdog: PASS
- SPRINT speed floor: PASS, `PRECOLLISION_SPRINT_MIN_SPEED=1.00`
- CROWD minimum zombies: PASS, `CROWD_BREAKOUT_MIN_ZOMBIES=2`
- CROWD maximum selected zombies: PASS, `CROWD_BREAKOUT_MAX_ZOMBIES=2`
- CONTACT low-dot skip: PASS, logs `BAD_DOT`
- Not-closing skip: PASS, logs `NOT_CLOSING`
- visible is not success: PASS
- Range-only trigger disabled: PASS

## Runtime Route

- Runtime main update: `Core.BreakoutPush.Update(player)`
- VanillaImpact: no-op and not called from Runtime
- Old player collision chain: not used
- Player coordinate writes: not found
- Zombie-side temporary nudge: present only in `XNP_DR_BreakoutPush.lua`

## Counts

- Total files: 26
- Lua files: 15
- Lua total lines: 2040
- Markdown documents: 4

## Required Logs

- `[XNP BREAKOUT] trigger type=SPRINT_PRECOLLISION`
- `[XNP BREAKOUT] trigger type=CONTACT`
- `[XNP BREAKOUT] trigger type=GRAB`
- `[XNP BREAKOUT] trigger type=CROWD`
- `[XNP BREAKOUT PUSH]`
- `[XNP BREAKOUT COST]`
- `[XNP BREAKOUT FAIL] reason=PLAYER_FELL_AFTER_PUSH`
- `[XNP BREAKOUT OUTCOME] result=PLAYER_STAYED_UP`
- `[XNP BREAKOUT FAIL] reason=ZOMBIE_AI_STUCK_AFTER_PUSH`
- `[XNP BREAKOUT SUMMARY]`

## Summary Fields

- success_player_stayed_up
- fail_player_fell_after_push
- fail_zombie_ai_stuck
- sprint_precollision
- contact
- grab
- crowd
- blocked_not_closing
- blocked_bad_dot

## Not Verifiable By Static Audit

- Real B42 runtime timing of the predictor before vanilla trip/fall.
- Real B42 zombie reaction method behavior.
- Real B42 zombie stuck detection accuracy.
- Lua bytecode syntax check if no Lua interpreter is installed.

STATIC_AUDIT_RESULT=PASS_WITH_RUNTIME_VERIFICATION_REQUIRED

```
