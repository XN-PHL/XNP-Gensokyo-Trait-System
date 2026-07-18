# 0.5.20 Sanitized Evidence Excerpts

## 0.5.20_LOG_THROTTLE_CLEANUP.md

- SHA-256: `C52F54E34B19998D53E4A208AFB360B2A03B2A6FCFDD775CF614E2A34B68FFCC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.20 Log Throttle Cleanup

Changed:

- Warning-only dragdown block logs are summarized.
- Assist auto-dragdown block logs are summarized.
- ActionBus cooldown blocks are summarized.
- Sprint too-late logs are summarized.
- Emergency held input has summary output.

Summary logs:

- `[XNP DRAGDOWN BLOCK SUMMARY] warning_no_auto=... assist_needs_input=... cooldown=...`
- `[XNP ACTION BUS SUMMARY] blocked_window=... blocked_recent_target=... allow_followup=...`
- `[XNP SPRINT FAIL SUMMARY] too_late=... fell_after_stagger=...`
- `[XNP EMERGENCY HELD SUMMARY] held_accept=... blocked_not_controlled=...`

Not throttled:

- Actual trigger logs.
- Cost logs.
- Player cancel result logs.
- True failure logs.

```

## 0.5.20_PRESERVE_JOG_AND_GRAB_SUCCESS.md

- SHA-256: `AB7C2E15E8951E8773F7467BA69C366810EF8D4AE87CC971A64C999EFF0A9505`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.20 Preserve Jog And Grab Success

Preserved:

- JOG_STATUS=PRESERVE_CURRENT_GOOD_FEEL
- GRAB_ESCAPE_STATUS=PRESERVE_AND_ADD_COST

Jog/contact:

- Contact gate is not rewritten.
- Contact cost remains 0.025.
- Contact remains stagger/push style, not a normal automatic hard knockdown route.

Grab/dragdown/emergency:

- Existing 0.5.19 route is preserved.
- Escape remains available.
- Cost is increased.
- ActionBus still blocks duplicate same-window actions.

Balance preserved:

- normal movement plus close two-zombie warning does not auto hard-trigger.
- single close zombie normal shove/contact does not become hard knockdown.
- warning-only and assist classifications remain separated from true emergency.

```

## 0.5.20_REAL_GAME_TUNING_ANALYSIS_FROM_0.5.19.md

- SHA-256: `A124B40888CBA48B7184D4D7A594BD30BBBC709EAFAD23BC30D0F78F71A19FC1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.20 Real Game Tuning Analysis From 0.5.19

Baseline:

- 0.5.19 restored activation, runtime update, trait active state and recovered status icon.
- Jog/contact behavior was reported as reasonable.
- Grab/dragdown escape was reported as working.
- Full sprint still fell too often.
- Status icon still needed stabilization.
- Skill use needed higher endurance cost.

0.5.20 scope:

- Preserve activation and trait diagnostics.
- Preserve jog/contact feel.
- Preserve grab escape and dragdown/emergency route.
- Tune sprint fall probability, not full invincibility.
- Stabilize the existing recovered status icon route.
- Increase skill cost with single-charge ActionBus handling.

Status:

- SPRINT_STATUS=TUNE_FALL_PROBABILITY_NOT_FULL_INVINCIBLE
- JOG_STATUS=PRESERVE_CURRENT_GOOD_FEEL
- GRAB_ESCAPE_STATUS=PRESERVE_AND_ADD_COST
- ICON_FEATURE_STATUS=KEEP_0519_RECOVERED_ROUTE_SINGLE_STATUS_TUNE

```

## 0.5.20_SKILL_COST_REBALANCE.md

- SHA-256: `CBAF3B818E0ACFE744AADA912A5A786B8DB30EDCB38E7894217442CEBF2A69DA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.20 Skill Cost Rebalance

Cost goals:

- Keep jog/contact cost low.
- Increase full sprint precontact cost.
- Add extra sprint trip cancel cost.
- Increase emergency/dragdown costs.
- Do not charge blocked actions.
- Do not double charge within one accepted action.

Configured costs:

- contact_cost=0.025
- sprint_precollision_cost=0.050
- sprint_trip_cancel_cost=0.080
- emergency_assist_cost=0.070
- emergency_breakout_base_cost=0.120
- dragdown_true_emergency_cost=0.140
- fatal_surrounded_cost=0.160

Low stamina:

- Low stamina multiplier: 1.5.
- Critical stamina multiplier: 2.0.
- Sprint trip cancel can add endurance debt.

Safety:

- no_bite=true
- no_infection=true
- no_heal=true
- no_damage_rollback=true

Expected logs:

- `[XNP COST] rebalance=0.5.20`
- `[XNP COST] type=SPRINT_PRECOLLISION`
- `[XNP COST] type=SPRINT_TRIP_CANCEL`
- `[XNP COST] type=EMERGENCY_ASSIST`
- `[XNP COST] type=TRUE_EMERGENCY`
- `[XNP COST] type=FATAL_SURROUNDED`

```

## 0.5.20_SPRINT_FALL_REDUCTION_DESIGN.md

- SHA-256: `2F186E92CA9AAC64D52E07FD004B8A926FF705B7E343BBCC63DA7E14F15C7327`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.20 Sprint Fall Reduction Design

Goal:

- Reduce full-sprint fall probability compared with 0.5.19.
- Keep sprint risk present.
- Keep the first impact feeling strong.
- Do not change jog/contact gate behavior.

Tuning:

- Sprint scan distance: 1.05 to 2.05.
- Preferred precontact band: 1.35 to 1.75.
- Required closing frames: 2.
- Forward dot: 0.68.
- Too-late distance: 0.90.
- Minimum sprint speed: 3.25.

Runtime route:

- `XNP_DR_SprintTripImmunity.lua` runs during the existing Runtime update.
- It scans front grid squares, tracks closing frames per zombie and applies a sweep before direct contact.
- It registers outcome checks and may run a tightly limited trip cancel if the player falls immediately after recent sprint collision.

Expected logs:

- `[XNP SPRINT IMMUNITY SWEEP] enabled=true`
- `[XNP SPRINT IMMUNITY SWEEP] trigger_id=...`
- `[XNP SPRINT IMMUNITY OUTCOME] result=PLAYER_STAYED_UP`
- `[XNP SPRINT IMMUNITY OUTCOME] result=TRIP_CANCELLED_AND_STAYED_UP`
- `[XNP SPRINT FAIL SUMMARY] too_late=...`

```

## 0.5.20_SPRINT_IMMUNITY_SWEEP_AND_CANCEL_RUNTIME.md

- SHA-256: `63B6F7C4E3DE5E03D63879E518985151306E9635648725FEF1D5BDCAD9A2037B`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.20 Sprint Immunity Sweep And Cancel Runtime

Runtime connection:

- Runtime already calls SprintTripImmunity before and after BreakoutPush.
- 0.5.20 keeps that path and makes the sweep path use local grid squares instead of relying on a broad object-list path.

Sweep:

- Requires full sprint.
- Requires front-sector target and closing frames.
- Uses zombie-side verified stagger control.
- Increments `sprintImmunitySweep`.
- Registers outcome watchdog.

Trip cancel:

- Only runs after recent sprint collision.
- Uses the already audited safe player cancel method.
- Has its own cooldown.
- Charges additional endurance cost.
- Does not write player position.
- Does not heal or roll back injury.

ActionBus:

- Sprint sweep is accepted as a sprint immunity action.
- Trip cancel is allowed as a follow-up in the same sprint window.
- True emergency can override after sprint fall without duplicate same-target clearing.

Expected logs:

- `[XNP ACTION BUS] allow_followup source=SPRINT_IMMUNITY_CANCEL reason=SAME_SPRINT_WINDOW`
- `[XNP ACTION BUS] emergency_override=true reason=PLAYER_FELL_AFTER_SPRINT`
- `[XNP COST] type=SPRINT_TRIP_CANCEL`

```

## 0.5.20_STATUS_ICON_SINGLE_STATE_PRIORITY.md

- SHA-256: `C0A572FA4CC9F6E2A5E12BBC1FC17BB4F4ED40206EE09D9C30DA6863F91A3F77`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.20 Status Icon Single State Priority

Status:

- ICON_FEATURE_STATUS=KEEP_0519_RECOVERED_ROUTE_SINGLE_STATUS_TUNE
- MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
- HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- TEXT_FALLBACK_STATUS=DEBUG_ONLY_NOT_MAIN_UI

Route:

- Keeps the recovered 0.5.19 texture/panel route.
- Keeps border, shake, slot sorting and texture load behavior.
- Uses a single status icon with color and shake changes.

Priority:

- DRAGDOWN_DANGER
- EMERGENCY_COOLDOWN
- SPRINT
- LOW_STAMINA
- EMERGENCY_READY

Stability:

- State minimum hold: 30 frames.
- Selected slot logs only on change.
- Position has configurable offset.
- Shake is limited to true emergency danger.

Expected logs:

- `[XNP STATUS ICON] mode=SINGLE_STATUS_ICON`
- `[XNP STATUS ICON] state_priority=...`
- `[XNP STATUS ICON] selected_state=...`
- `[XNP STATUS ICON] state_hold active=...`

```

## 0.5.20_TEST_PLAN.md

- SHA-256: `E137D1B9A87F6F71A23ABD934EB0C17C67FE329767B390658C32FDE8B39162BC`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.20 Test Plan

Load:

- Confirm build marker.
- Confirm activation active.
- Confirm status icon recovered route.
- Confirm single status icon mode.

Jog:

- Jog into a zombie.
- Expected: existing push feel remains reasonable.
- Expected: no normal movement automatic hard knockdown.

Grab / dragdown:

- Let zombies control or drag down the player.
- Expected: escape route still works.
- Expected: endurance cost is higher than 0.5.19.
- Expected: no injury rollback.

Full sprint:

- Sprint into front zombies repeatedly.
- Expected: less falling than 0.5.19.
- Expected: sweep counter increases.
- Expected: trip cancel attempts occur only after recent sprint collision.
- Expected: successful cancel logs stayed-up result.

Icon:

- Observe right-top icon.
- Expected: texture icon remains visible.
- Expected: state changes are stable.
- Expected: true danger shakes.
- Expected: slot logs are not repeated every frame.

Cost:

- Confirm sprint precontact cost around 0.050.
- Confirm emergency/dragdown cost around 0.120 to 0.160.
- Confirm blocked actions do not charge.

```

## BUILD_MARKER.txt

- SHA-256: `2696293693F3E90D878B279E42DEB76462AEF912DBE1DB24E1B745A0DB017983`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0520_SPRINT_FALL_TUNE_ICON_COST_A

```

## FINAL_REPORT.md

- SHA-256: `42620B6C26191D61111101F7F6B30D8C63BD678B3EBA6E62130150C032D99954`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.20 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.20
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0520_SPRINT_FALL_TUNE_ICON_COST_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.20 Sprint Fall Tune Icon Cost

0.5.19 feedback handling:

- jog behavior: PRESERVED
- grab escape: PRESERVED
- full sprint fall risk: FIXED_STATIC_RISK_REAL_GAME_REQUIRED
- right-top icon: FIXED_STATIC_RISK_REAL_GAME_REQUIRED
- skill endurance cost increase: YES

Sprint tuning:

- sprint_immunity_sweep runtime: YES
- trip_cancel runtime: YES
- trip_cancel limited to recent sprint collision: YES
- precontact window adjusted: YES
- too_late throttled: YES

Icon:

- recovered route preserved: YES
- single status mode: YES
- state priority: YES
- selected_slot log on change only: YES
- fallback text main UI: NO

Cost:

- contact_cost=0.025
- sprint_precollision_cost=0.050
- sprint_trip_cancel_cost=0.080
- emergency_assist_cost=0.070
- true_emergency_cost=0.140
- fatal_surrounded_cost=0.160
- action bus single charge: YES
- no bite / no infection / no heal: YES

Counts:

- Total files: 42
- Lua files: 25
- Lua total lines: 5763
- Markdown files: 10

Preserve checks:

- jog/contact preserved: YES
- grab escape preserved: YES
- normal movement plus close two warning no hard auto trigger: YES
- single zombie normal shove no hard auto trigger: YES

Safety:

- Project Zomboid launched: NO
- Steam launched: NO
- user mods written: NO
- saves written: NO
- Workshop written: NO
- game directory written: NO
- old SOURCE modified: NO
- package/install action: NO

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.20_SOURCE_READY_FOR_SPRINT_TUNE_TEST

```

## STATIC_AUDIT.md

- SHA-256: `52C002D83BA7AE49E40E7064DE6C983F31D7AEFC342C6B161922F011AE7A0595`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.20 Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.20
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0520_SPRINT_FALL_TUNE_ICON_COST_A

Baseline:

- 0.5.19 baseline confirmed.
- Old SOURCE modification: NO.
- Large file pollution: NO.

File counts:

- Total files: 42
- Lua files: 25
- Lua total lines: 5763
- Markdown files: 10

Required audit:

- forbidden route grep: PASS
- player coordinate writer grep: PASS
- game-time writer grep: PASS
- text/halo UI helper grep: PASS
- activation active logs preserved grep: PASS
- status icon recovered route grep: PASS
- icon single state priority grep: PASS
- SprintTripImmunity sweep runtime grep: PASS
- sprint trip cancel runtime grep: PASS
- sprintImmunitySweep counter increment grep: PASS
- sprintImmunityTripCancelAttempt counter increment grep: PASS
- sprintImmunitySuccess counter increment grep: PASS
- ActionBus follow-up allow grep: PASS
- cost rebalance grep: PASS
- cost single-charge grep: PASS
- no_bite / no_infection / no_heal grep: PASS
- jog/contact preserve grep: PASS
- grab escape preserve grep: PASS
- warning-only no-auto behavior grep: PASS
- single-zombie no hard-trigger behavior grep: PASS
- log throttle grep: PASS

Runtime verification:

- Not run by policy.
- Real game sprint fall probability remains REAL_GAME_TEST_REQUIRED.

BLOCKER=NONE_STATIC

```
