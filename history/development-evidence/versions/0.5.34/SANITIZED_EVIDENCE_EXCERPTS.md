# 0.5.34 Sanitized Evidence Excerpts

## 0.5.34_NON_GREEN_SHAKE_RESTORE.md

- SHA-256: `5323678D85EF979D54F130C84CA735E50A6222F710420FCAE179ADA3D994D570`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.34 Non-Green Shake Restore

GREEN_SHAKE=OFF
BLUE_SHAKE=LOW
YELLOW_SHAKE=MEDIUM
RED_SHAKE=HIGH

Shake profile:

- GREEN_READY: disabled, amplitude=0
- BLUE_STAMINA_SUPPORT: amplitude_x=1.0, amplitude_y=0.6, speed=0.12
- YELLOW_LOW_STAMINA_SUPPORT: amplitude_x=1.8, amplitude_y=1.2, speed=0.18
- RED_EXHAUSTED_SUPPORT: amplitude_x=2.8, amplitude_y=2.0, speed=0.26

Danger and skill flash overrides keep higher priority than stamina-band shake.

RESOURCE_LOCK_PRESERVES_COLOR_AND_SHAKE=YES


```

## 0.5.34_PRESERVE_0.5.33_CONTRACT_FIX.md

- SHA-256: `59A18C96999768F6751A478C4BB27E55054CC3C12974B96BC509A2659BF0C271`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.34 Preserve 0.5.33 Contract Fix

BASELINE=0.5.33

Preserved contract fixes:

- explicit `stateChangedThisTick`
- explicit stable commit from candidate state
- candidate clear after commit
- no same-tick recreate
- icon source remains `ENDURANCE_BAND`
- active old `ENDURANCE_CAPABILITY` color selector residue remains removed
- White visual override remains disabled
- neutral `resource_gate_*` names remain active
- resource lock preserves color
- resource lock cancels refund and hunger write

CORE_MECHANICS_PRESERVED=YES


```

## 0.5.34_REAL_GAME_TUNING_FROM_0.5.32.md

- SHA-256: `51950B61378A98F1B22D0A18DC224F7809CB2084338F852F9AFF8DD8AFE4745A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.34 Real Game Tuning From 0.5.32

BASELINE=0.5.33
SOURCE_BASELINE_FIXES=0.5.33 second pass risk-test-allowed contract.

0.5.34 replaces the earlier debug stamina feel with a release hand-feel curve:

- TEST_CURVE_DISABLED=YES
- RELEASE_CURVE_ENABLED=YES
- CORE_MECHANICS_PRESERVED=YES
- NO_INFINITE_STAMINA=YES
- NO_INFINITE_SPRINT=YES

The curve is value-only endurance band logic. Capability and movement diagnostics remain diagnostics only and do not select icon color.

Resource lock still cancels refund and hunger conversion, but it does not override the current endurance color or the non-green shake state.


```

## 0.5.34_RELEASE_STAMINA_CURVE.md

- SHA-256: `25223DD4B01998A839DD94F56A67CB825F60BD6A5D0A59C87A0FE0DF2ECE1BC2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.34 Release Stamina Curve

BASELINE=0.5.33
RELEASE_CURVE_ENABLED=YES
TEST_CURVE_DISABLED=YES

Release band thresholds:

- GREEN enter: 0.76
- GREEN exit / BLUE upper cap: 0.70
- BLUE lower / YELLOW upper cap: 0.36
- YELLOW lower / RED upper cap: 0.14

Release refund and hunger conversion:

- GREEN: drain=1.00 refund=0.00 hunger_ratio=0.00
- BLUE: drain=0.82 refund=0.18 hunger_ratio=0.25
- YELLOW: drain=0.62 refund=0.38 hunger_ratio=0.60
- RED: drain=0.45 refund=0.55 hunger_ratio=1.00

The runtime uses `stamina_curve_profile="RELEASE_HAND_FEEL"` and `stamina_curve_debug_test_profile=false`.

ACTION_COST_REFUND=NO
NO_INFINITE_STAMINA=YES
NO_INFINITE_SPRINT=YES
RESOURCE_LOCK_PRESERVES_COLOR_AND_SHAKE=YES


```

## 0.5.34_SHAKE_DRAG_POSITION_SAFETY.md

- SHA-256: `8EA13C46639E836C421F727B18BB8E55ACE415FAEDD9DA20B5CE7611B06927FC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.34 Shake Drag Position Safety

SHAKE_SUSPENDED_WHILE_DRAGGING=YES
SHAKE_RENDER_OFFSET_ONLY=YES
SAVED_POSITION_UNCHANGED=YES

Implementation notes:

- Shake is applied only to render-time draw offsets.
- The panel position remains driven by the existing layout and draggable position modules.
- Drag callbacks are not modified for shake behavior.
- While dragging, shake is suspended and logged.
- On release, shake resumes based on the current endurance-band state.

The runtime logs:

- `[XNP STATUS ICON SHAKE] suspended=true reason=DRAG_ACTIVE`
- `[XNP STATUS ICON SHAKE] resumed=true state=...`
- `[XNP STATUS ICON SHAKE] render_offset_only=true saved_position_unchanged=true`


```

## 0.5.34_SMOOTH_POST_DRAIN_REFUND.md

- SHA-256: `44C97372A61741511E47E227A1603054AE0E3537C2A1380A12419BD6307C07BF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.34 Smooth Post-Drain Refund

POST_DRAIN_REFUND_SMOOTHED=YES
ACTION_COST_REFUND=NO

Runtime sampling:

- `assist_sample_interval_frames=3`
- UI update remains 10 frames.
- Summary logs remain 120 frames.

Step caps:

- BLUE: 0.00045
- YELLOW: 0.00075
- RED: 0.00100

Refund debt:

- Excess locomotion-only refund can enter short `refundDebt`.
- Debt is released only while run/jog locomotion continues.
- Debt is cleared on NOT_LOCOMOTION.
- Debt is cleared on RESOURCE_LOCKED.
- Action/discrete cost never enters debt.

Band caps:

- BLUE refund cannot push endurance above 0.70.
- YELLOW refund cannot push endurance above 0.36.
- RED refund cannot push endurance above 0.14.

Required runtime logs are implemented with `[XNP STAMINA SMOOTH]` and `[XNP STAMINA SMOOTH SUMMARY]`.


```

## 0.5.34_TEST_PLAN.md

- SHA-256: `D3479C2E1AFAE2FF5219481587771F04AF76065F3A1DAC4F0D7519A2B1E2D798`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.34 Test Plan

Install manually into a test mods folder only after source review.

1. Confirm build marker:
   `XNP_PZ_DISTANCE_TRAIT_0534_RELEASE_STAMINA_CURVE_SHAKE_RESTORE_A`

2. Confirm stamina curve:
   - Above 0.70: green, no shake, no refund.
   - 0.36 to 0.70: blue support, low shake, small smooth refund.
   - 0.14 to 0.36: yellow support, medium shake, stronger smooth refund.
   - Below 0.14: red support, high shake, strongest smooth refund.

3. Confirm no action/discrete cost refund:
   - Trigger non-locomotion endurance loss.
   - Expect blocked `ACTION_OR_DISCRETE_COST` log.

4. Confirm resource lock:
   - Force low resource state.
   - Refund and hunger write stop.
   - Current color and shake remain endurance-band based.

5. Confirm drag safety:
   - Drag the icon during blue/yellow/red.
   - Shake suspends while dragging.
   - Saved position remains stable after release.

PROJECT_ZOMBOID_LAUNCHED_BY_CODEX=NO
STEAM_LAUNCHED_BY_CODEX=NO
USER_MODS_WRITTEN_BY_CODEX=NO


```

## BUILD_MARKER.txt

- SHA-256: `0C8821B6321F2427ACFB2DBFA314846F16EDE0D25E7600A951A797F52B3D8178`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0534_RELEASE_STAMINA_CURVE_SHAKE_RESTORE_A

```

## FINAL_REPORT.md

- SHA-256: `36C54D889C204D31A8A6927D370F1D2AA4B0845F46C9DF48AD5FFD6DDFF2BB9D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.34
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0534_RELEASE_STAMINA_CURVE_SHAKE_RESTORE_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.34 Release Stamina Curve Shake Restore

Implemented:

- BASELINE=0.5.33
- TEST_CURVE_DISABLED=YES
- RELEASE_CURVE_ENABLED=YES
- POST_DRAIN_REFUND_SMOOTHED=YES
- ACTION_COST_REFUND=NO
- GREEN_SHAKE=OFF
- BLUE_SHAKE=LOW
- YELLOW_SHAKE=MEDIUM
- RED_SHAKE=HIGH
- SHAKE_SUSPENDED_WHILE_DRAGGING=YES
- SHAKE_RENDER_OFFSET_ONLY=YES
- SAVED_POSITION_UNCHANGED=YES
- RESOURCE_LOCK_PRESERVES_COLOR_AND_SHAKE=YES
- NO_INFINITE_STAMINA=YES
- NO_INFINITE_SPRINT=YES
- CORE_MECHANICS_PRESERVED=YES

Safety:

- Project Zomboid launched by Codex: NO
- Steam launched by Codex: NO
- User mods written by Codex: NO
- Saves written by Codex: NO
- Workshop written by Codex: NO
- Game directory written by Codex: NO
- Old SOURCE modified for 0.5.34: NO

Final status is valid only with the static checks reported by the assistant response.

Changed files for 0.5.34:

- BUILD_MARKER.txt
- mod.info
- 42/mod.info
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceCapabilityState.lua
- 0.5.34_REAL_GAME_TUNING_FROM_0.5.32.md
- 0.5.34_RELEASE_STAMINA_CURVE.md
- 0.5.34_SMOOTH_POST_DRAIN_REFUND.md
- 0.5.34_NON_GREEN_SHAKE_RESTORE.md
- 0.5.34_SHAKE_DRAG_POSITION_SAFETY.md
- 0.5.34_PRESERVE_0.5.33_CONTRACT_FIX.md
- 0.5.34_TEST_PLAN.md
- STATIC_AUDIT.md
- FINAL_REPORT.md

Static results:

- Lua files: 46
- Lua total lines: 9595
- Markdown files: 9
- Total files: 62
- Exact forbidden runtime patterns: PASS
- Old active version residue 0.5.20-0.5.32 / 0520-0532: PASS
- Active endurance capability color selector residue: PASS
- Per-sample endurance band source/endurance logs: PASS
- Core drag/collision/trip/escape modules compared with 0.5.33 by SHA256: unchanged
- Lua interpreter syntax execution: NOT_VERIFIABLE_NO_LOCAL_LUA_OR_LUAC

BLOCKER=NONE_STATIC
XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.34_SOURCE_READY_FOR_RELEASE_CURVE_SHAKE_TEST

```

## 0.5.34_SECOND_PASS_AUDIT.md

- SHA-256: `511B5FC5F21A5C646938AD38D6763024EE3D17C8ACCC7F1B5BF0DE5E0121B1DC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ Distance Runner Trait 0.5.34 Second Pass Audit

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]
EXPECTED_VERSION=0.5.34
EXPECTED_MARKER=XNP_PZ_DISTANCE_TRAIT_0534_RELEASE_STAMINA_CURVE_SHAKE_RESTORE_A
EXPECTED_DISPLAY_NAME=XNP Distance Runner Trait 0.5.34 Release Stamina Curve Shake Restore

AUDIT_ONLY=YES
CODE_MODIFIED=NO
PZ_LAUNCHED=NO
STEAM_LAUNCHED=NO
USER_MODS_WRITTEN=NO
SAVES_WRITTEN=NO
WORKSHOP_WRITTEN=NO
GAME_DIR_WRITTEN=NO
PACKAGE_BUILT=NO
INSTALLED=NO

## 1. Version And Files

SOURCE_EXISTS=PASS
BUILD_MARKER_OK=PASS
DISPLAY_NAME_OK=PASS

FILE_COUNT_0533=62
FILE_COUNT_0534_BEFORE_AUDIT_REPORT=62
FILE_COUNT_0534_AFTER_AUDIT_REPORT=63
LUA_COUNT_0534=46
LUA_TOTAL_LINES_0534=9593

OLD_ACTIVE_RESIDUE=PASS

- Active Lua scan under `42/media/lua` found no `0.5.20` through `0.5.33` or `0520` through `0533` version markers.
- `BUILD_MARKER.txt`, `mod.info`, `42/mod.info`, and `XNP_DR_Constants.lua` use the 0.5.34 marker/display identity.

LARGE_COPY_DETECTED=NO_BLOCKER

- 0.5.34 is intentionally based on 0.5.33.
- File count stayed aligned with 0.5.33 before this audit report.
- No 1000+ file pollution detected.

## 2. Release Stamina Curve

RELEASE_PROFILE=PASS

- `stamina_curve_profile = "RELEASE_HAND_FEEL"`

TEST_PROFILE_DISABLED=PASS

- `stamina_curve_debug_test_profile = false`

THRESHOLDS_CENTRALIZED=PASS

- `release_green_enter = 0.76`
- `release_green_exit = 0.70`
- `release_blue_lower = 0.36`
- `release_yellow_lower = 0.14`
- Runtime endurance thresholds mirror these release values.

GREEN_PROFILE=PASS

- drain multiplier 1.00 by `green_refund_fraction = 0.00`
- hunger conversion `hunger_conversion_green = 0.00`
- Green active refund is not enabled.

BLUE_PROFILE=PASS

- drain multiplier 0.82 by `blue_refund_fraction = 0.18`
- hunger ratio `hunger_conversion_blue = 0.25`

YELLOW_PROFILE=PASS

- drain multiplier 0.62 by `yellow_refund_fraction = 0.38`
- hunger ratio `hunger_conversion_yellow = 0.60`

RED_PROFILE=PASS

- drain multiplier 0.45 by `red_refund_fraction = 0.55`
- hunger ratio `hunger_conversion_red = 1.00`
- Red threshold is `0.14`, not the old debug-style `~0.46`.
- Yellow threshold is `0.36`, not the old debug-style `~0.55`.

COLOR_SOURCE_ENDURANCE_BAND=PASS

- Status icon selected-state logs use `source=ENDURANCE_BAND`.
- Capability and movement diagnostics do not select color.

WHITE_VISUAL_DISABLED=PASS_DISABLED_ONLY

- `WHITE_VISUAL_STATE_ENABLED = false`
- `WHITE_VISUAL_STATE_ENABLED_UPPER = false`
- Resource lock preserves color and does not switch to a white state.

CURVE_STATUS=PASS

## 3. Smooth Refund

SMOOTH_REFUND_RUNTIME=PASS

- Runtime uses `refundDebt`.
- Refund is computed after drain from observed endurance loss.
- Refund write reason remains `LOCOMOTION_BAND_REFUND`.

SAMPLE_INTERVAL=PASS

- `assist_sample_interval_frames = 3`
- Runtime interval reads `Config.assist_sample_interval_frames`.

BLUE_STEP_CAP=PASS

- `blue_refund_step_cap = 0.00045`

YELLOW_STEP_CAP=PASS

- `yellow_refund_step_cap = 0.00075`

RED_S
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `C53D59B28C75F9EB41447B7BF39868CA9AABE581F82EF096B82AAF40A02650C0`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

VERSION=0.5.34
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0534_RELEASE_STAMINA_CURVE_SHAKE_RESTORE_A
BASELINE=0.5.33

Runtime intent:

- TEST_CURVE_DISABLED=YES
- RELEASE_CURVE_ENABLED=YES
- POST_DRAIN_REFUND_SMOOTHED=YES
- GREEN_SHAKE=OFF
- BLUE_SHAKE=LOW
- YELLOW_SHAKE=MEDIUM
- RED_SHAKE=HIGH
- SHAKE_SUSPENDED_WHILE_DRAGGING=YES
- SHAKE_RENDER_OFFSET_ONLY=YES
- SAVED_POSITION_UNCHANGED=YES
- ACTION_COST_REFUND=NO
- RESOURCE_LOCK_PRESERVES_COLOR_AND_SHAKE=YES
- NO_INFINITE_STAMINA=YES
- NO_INFINITE_SPRINT=YES
- CORE_MECHANICS_PRESERVED=YES

Static grep and file counts are recorded in `FINAL_REPORT.md`.

Counts:

- Lua files: 46
- Lua total lines: 9595
- Markdown files: 9
- Total files: 62

Static checks:

- Exact forbidden runtime patterns: PASS
- Active Lua old version identity 0.5.20-0.5.32 / 0520-0532: PASS
- Active endurance capability color selector residue: PASS
- Per-sample `[XNP ENDURANCE BAND] source=` and endurance log residue: PASS
- Empty files: PASS
- UTF-8 BOM scan: PASS
- NULL byte text scan: PASS except binary trait PNG expected binary content
- Lua interpreter syntax execution: NOT_VERIFIABLE_NO_LOCAL_LUA_OR_LUAC

Context-only grep notes:

- Some preserved modules still log `no_infection=true` / `no_heal=true` as safety statements. They are not infection rollback or healing code.
- Vanilla moodle names include `PAIN`, `STRESS`, and `BLEEDING` as display slot names. They are not body-damage writes.
- `LongMigrationStaminaAssist` reads fatigue for status reporting. It does not write fatigue.

Preserved 0.5.33 modules unchanged by SHA256:

- XNP_DR_DraggableStatusIcon.lua
- XNP_DR_StatusIconInputBindingGuard.lua
- XNP_DR_JogBumpLaunch.lua
- XNP_DR_SprintVehicleImpact.lua
- XNP_DR_NativeTripWindow.lua
- XNP_DR_SprintTripConsequence.lua
- XNP_DR_FallRecoveryInput.lua
- XNP_DR_BreakoutActionBus.lua
- XNP_DR_ImpactQuotaMeter.lua
- XNP_DR_MovementIntentGate.lua

BLOCKER=NONE_STATIC

```
