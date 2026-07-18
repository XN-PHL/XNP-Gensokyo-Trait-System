# 0.5.13 Sanitized Evidence Excerpts

## 0.5.13_BLOCKER_FIX_DESIGN.md

- SHA-256: `D240227F2A2767B7482B1B64757411E4E9D49A657ABD179091427850A22BB0AB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.13 Blocker Fix Design

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Identity

- VERSION=0.5.13
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0513_PRECOLLISION_BLOCKER_FIX_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.13 Precollision Blocker Fix
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

## Fixed Blockers

- BLOCKER_UNSAFE_REACTION_NUDGE_INTERRUPT_STACK: fixed by profile-based push strategy.
- BLOCKER_REQUIRED_LOAD_LOGS_MISSING: fixed by runtime load logs in `XNP_DR_BreakoutPush.lua`.
- BLOCKER_REQUIRED_ZOMBIE_RECOVERY_LOG_MISSING: fixed by runtime recovery registration and result logs.
- BLOCKER_SUMMARY_FIELDS_NOT_RUNTIME: fixed by runtime summary counters.

## Deferred UI Status

- ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
- MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
- HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET

## Safety

- No player coordinate writes.
- No game time writes.
- No permanent AI disable / freeze / target clear.
- Zombie coordinate writes are limited to zombie-side micro nudge.

```

## 0.5.13_PLAYER_OUTCOME_WATCHDOG_RUNTIME.md

- SHA-256: `03768666109D939C4A217610E96BC580C497E111E2221E8B7E7B863C7F8AC3A5`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.13 Player Outcome Watchdog Runtime

## Runtime Path

- Each trigger gets `trigger_id`.
- `RegisterPlayerOutcomeWatchdog(trigger_id, type, time)` creates a pending record.
- Runtime logs `[XNP BREAKOUT OUTCOME] registered trigger_id=... type=... window=0.35`.
- `UpdatePlayerOutcomeWatchdogs` checks pending records every update.

## Success And Failure

- `visible=true` is not success.
- Success requires the player to stay up through the outcome window.
- Success log: `[XNP BREAKOUT OUTCOME] result=PLAYER_STAYED_UP trigger_id=... type=...`
- Failure log: `[XNP BREAKOUT FAIL] reason=PLAYER_FELL_AFTER_PUSH trigger_id=... type=...`

## Summary Fields

- success_player_stayed_up
- fail_player_fell_after_push

## Notes

State reads are guarded through safe wrappers. Missing APIs should not crash the module.

```

## 0.5.13_PUSH_PROFILE_STRATEGY.md

- SHA-256: `EEF9DD57324ABBC386E999D14BC3FB495FB1777C43A5A74D5B30898EB23EE2C4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.13 Push Profile Strategy

The push route is profile based. Runtime logs `[XNP BREAKOUT PROFILE]` for each triggered push.

## Profiles

- SPRINT_PRECOLLISION: reaction only by default; nudge only if reaction is unavailable or fails; interrupt disabled.
- CONTACT: light reaction only; nudge disabled; interrupt disabled.
- GRAB: reaction plus micro nudge plus short-pulse interrupt.
- CROWD: reaction plus optional micro nudge; interrupt disabled by default.

## Runtime Evidence

- `BuildPushProfile(triggerType, reactionAvailable)` decides reaction/nudge/interrupt.
- `ApplyPushProfile(...)` applies only the selected profile.
- `[XNP BREAKOUT PROFILE] type=... reaction=... nudge=... interrupt=...` proves the route is not an unconditional three-part stack.

## Forbidden

- No fixed reaction+nudge+interrupt for every trigger.
- No `setTarget(nil)`.
- No permanent disable AI / freeze / clear target.
- No random push direction.
- No player coordinate writes.

```

## 0.5.13_SPEED_THRESHOLD_RATIONALE.md

- SHA-256: `EE6351C42B72257F8536C254CC836B6B90AFC31FA5DD0D4456C74A0CED2BB97C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.13 Speed Threshold Rationale

## Problem

The prior sprint threshold of `1.00` was too low to defend statically because ordinary/contact movement had been observed around `1.8584` and `2.0377`, while full sprint reference was around `6.7759`.

## 0.5.13 Change

- `PRECOLLISION_SPRINT_MIN_SPEED=3.25`
- `CONTACT_MIN_PLAYER_SPEED=0.60`
- `CONTACT_MAX_PLAYER_SPEED=3.24`
- `PRECOLLISION_FRONT_DOT_MIN=0.70`
- `CONTACT_TRIGGER_FRONT_DOT_MIN=0.55`

## Runtime Logs

- `[XNP SPEED SAMPLE] speed=... movement=... sprint_candidate=... contact_candidate=...`
- `[XNP BREAKOUT SKIP] reason=LOW_SPEED_FOR_SPRINT speed=... sprint_min=...`

## Result

- SPRINT speed=0.x is blocked.
- Ordinary/contact-speed movement is not classified as SPRINT_PRECOLLISION.
- Sprint threshold risk from 1.00 is resolved for the next real-game test.

```

## 0.5.13_TEST_PLAN.md

- SHA-256: `027F2367BEC5F57647478D3781E86CD3D7A17654CF290B42DFB2B81F3870B0E2`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.13 Test Plan

## Load Test

Confirm console contains:

- `[XNP DR] BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0513_PRECOLLISION_BLOCKER_FIX_A`
- `[XNP BREAKOUT] method=PRECOLLISION_ZOMBIE_SIDE_BREAKOUT_BLOCKER_FIX`
- `[XNP BREAKOUT] profile_push_strategy=true`
- `[XNP BREAKOUT] visible_is_not_success=true`
- `[XNP BREAKOUT] zombie_recovery_watchdog=true`

## Sprint Precollision

Sprint directly toward a zombie. Expected:

- `trigger type=SPRINT_PRECOLLISION`
- speed is at least `3.25`
- profile log shows reaction-focused profile, not unconditional reaction+nudge+interrupt
- outcome watchdog reports stayed-up or fell-after-push

## Contact

Jog or normal run into close front contact. Expected:

- CONTACT only inside contact speed range
- bad dot logs BAD_DOT

## Crowd

Use two or more very close zombies. Expected:

- CROWD requires at least two zombies
- at most two targets are affected

## Recovery

After every reaction/nudge/interrupt, expected:

- recovery registered log
- not_stuck / ok / suspicious / fail result log

```

## 0.5.13_ZOMBIE_RECOVERY_WATCHDOG_RUNTIME.md

- SHA-256: `D68380C869AB9484BD9FF317D5D5708145B9D7244B1DD052F0C8636F782730BA`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.13 Zombie Recovery Watchdog Runtime

## Runtime Records

Each affected zombie gets a recovery record with:

- trigger_id
- trigger_type
- zombie_key
- method_used
- used_reaction
- used_nudge
- used_interrupt
- start position
- last position
- check_count
- recovery deadline

## Required Runtime Logs

- `[XNP ZOMBIE RECOVERY] registered trigger_id=... zombie=... type=... reaction=... nudge=... interrupt=...`
- `[XNP ZOMBIE RECOVERY] result=not_stuck trigger_id=... zombie=...`
- `[XNP ZOMBIE RECOVERY] result=ok method=... trigger_id=... zombie=...`
- `[XNP ZOMBIE RECOVERY] suspicious_stuck trigger_id=... zombie=...`
- `[XNP BREAKOUT FAIL] reason=ZOMBIE_AI_STUCK_AFTER_PUSH trigger_id=... zombie=...`

## Recovery Policy

Recovery attempts only clear temporary reaction/stagger state set by this module path. There is no permanent AI disable, freeze, or target clear.

## Summary Fields

- recovery_registered
- recovery_not_stuck
- recovery_suspicious
- fail_zombie_ai_stuck

```

## BUILD_MARKER.txt

- SHA-256: `F0CF8F7822C7DB52BDABE9DAFEFC8D7ADD72306704F3245CCF13E49E0968B240`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0513_PRECOLLISION_BLOCKER_FIX_A

```

## FINAL_REPORT.md

- SHA-256: `3EF85CE5369BB505BD78441844573407706C508E39721B3F2FA0516B91433ED9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.13

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Identity

- VERSION=0.5.13
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0513_PRECOLLISION_BLOCKER_FIX_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.13 Precollision Blocker Fix
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

## Blockers

- BLOCKER_UNSAFE_REACTION_NUDGE_INTERRUPT_STACK=FIXED
- BLOCKER_REQUIRED_LOAD_LOGS_MISSING=FIXED
- BLOCKER_REQUIRED_ZOMBIE_RECOVERY_LOG_MISSING=FIXED
- BLOCKER_SUMMARY_FIELDS_NOT_RUNTIME=FIXED

## Mechanisms

- Precollision Predictor=PASS
- Player Outcome Watchdog=PASS
- Zombie Recovery Watchdog=PASS

## Speed Threshold

- PRECOLLISION_SPRINT_MIN_SPEED=3.25
- RISK_SPRINT_THRESHOLD_TOO_LOW=NO

## Safety

- Started Project Zomboid: NO
- Started Steam: NO
- Wrote user mods: NO
- Wrote saves: NO
- Wrote Workshop: NO
- Wrote game directory: NO
- Modified old SOURCE: NO
- Packaged mod: NO

## Static Audit

- Active Lua forbidden route grep: PASS_NOT_FOUND
- Player coordinate write grep: PASS_NOT_FOUND
- Zombie coordinate write grep: FOUND_ALLOWED_MICRO_NUDGE_ONLY
- setTarget grep: PASS_NOT_FOUND
- Active Lua old marker grep: PASS_NOT_FOUND
- JSON parse: PASS
- Text BOM/NULL scan: PASS
- Lua execution syntax check: NOT_VERIFIABLE_NO_LUA_INTERPRETER

## Counts

- Total files: 30
- Lua files: 15
- Lua total lines: 2156
- Markdown documents: 8

## Final Status

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.13_SOURCE_READY_FOR_PRECOLLISION_BLOCKER_FIX_TEST

```

## STATIC_AUDIT.md

- SHA-256: `87314DC8679A829936E06DCE56C5007221DC96543DE58644081774D3FE21323F`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.13

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Required Source

- New independent SOURCE exists: PASS
- Old SOURCE modified: NO
- Active build marker: `XNP_PZ_DISTANCE_TRAIT_0513_PRECOLLISION_BLOCKER_FIX_A`
- Runtime loads `XNP_DR_BreakoutPush.lua`: PASS

## Counts

- Total files: 30
- Lua files: 15
- Lua total lines: 2156
- Markdown documents: 8
- Lua execution syntax check: NOT_VERIFIABLE_NO_LUA_INTERPRETER

## Blocker Fix Audit

- BLOCKER_UNSAFE_REACTION_NUDGE_INTERRUPT_STACK: FIXED
- BLOCKER_REQUIRED_LOAD_LOGS_MISSING: FIXED
- BLOCKER_REQUIRED_ZOMBIE_RECOVERY_LOG_MISSING: FIXED
- BLOCKER_SUMMARY_FIELDS_NOT_RUNTIME: FIXED

## Runtime Load Logs

- build marker log: PASS
- method log: PASS
- range_only_trigger=false: PASS
- success_requires_player_stayed_up=true: PASS
- zombie_recovery_watchdog=true: PASS
- profile_push_strategy=true: PASS
- visible_is_not_success=true: PASS
- sprint_speed_min: PASS
- contact_dot_min: PASS
- crowd_min_zombies=2: PASS
- outcome_watch_window: PASS

## Runtime Summary Fields

Runtime summary includes:

- attempts
- triggered
- visible
- success_player_stayed_up
- fail_player_fell_after_push
- fail_zombie_ai_stuck
- sprint_precollision
- contact
- grab
- crowd
- blocked_distance
- blocked_no_contact
- blocked_no_movement_intent
- blocked_not_closing
- blocked_bad_dot
- blocked_low_speed_for_sprint
- blocked_endurance
- blocked_player_down
- recovery_registered
- recovery_not_stuck
- recovery_suspicious
- disabled

## Grep Results

- active Lua forbidden route grep: PASS_NOT_FOUND
- player coordinate write grep: PASS_NOT_FOUND
- zombie coordinate write grep: FOUND_ALLOWED_MICRO_NUDGE_ONLY
- setTarget grep: PASS_NOT_FOUND
- active Lua old marker grep: PASS_NOT_FOUND
- JSON parse: PASS
- Text BOM/NULL scan: PASS

## Classification

- `PRECOLLISION_SPRINT_MIN_SPEED=3.25`: PASS
- `CONTACT_MIN_PLAYER_SPEED=0.60`: PASS
- `CONTACT_MAX_PLAYER_SPEED=3.24`: PASS
- `CROWD_BREAKOUT_MIN_ZOMBIES=2`: PASS
- `CROWD_BREAKOUT_MAX_ZOMBIES=2`: PASS
- CONTACT bad dot skip: PASS

## Not Verifiable

- Real-game timing before vanilla fall/trip tail.
- Real-game zombie reaction and recovery behavior.
- Lua bytecode syntax check if no Lua interpreter is available.

STATIC_AUDIT_RESULT=PASS_WITH_REAL_GAME_TEST_REQUIRED

```
