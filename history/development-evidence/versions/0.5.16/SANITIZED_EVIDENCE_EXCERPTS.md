# 0.5.16 Sanitized Evidence Excerpts

## 0.5.16_REAL_GAME_FAILURE_ANALYSIS_FROM_0.5.15.md

- SHA-256: `C81D202853E3BF187CC2089F2DF02A672600D75FB50319017D2E904D8542649E`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.16 Real Game Failure Analysis From 0.5.15

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.16
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0516_EMERGENCY_GETUP_BREAKOUT_ICON_A

## Accepted Runtime Result

- The previous sprint and contact systems loaded.
- Strict contact gate and verified stagger route should be retained.
- Sprint immunity showed active frames, but sweep and cancel counters could remain zero.
- BreakoutPush could be blocked after the player was on floor.
- The next priority is an explicit emergency breakout skill, not another sprint-only tuning pass.

## 0.5.16 Response

- Adds EmergencyBreakout as an independent runtime module.
- Adds EmergencyBreakoutCost for endurance cost and low-stamina fallback debt.
- Adds StatusIconUI as a real screen overlay/fallback text route.
- Throttles sprint active logs to summary windows.

ICON_FEATURE_STATUS=ACTIVE_UI_OVERLAY_RETRY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN


```

## 0.5.16_BALANCE_NOT_TOO_OBVIOUS_INVINCIBILITY.md

- SHA-256: `42620AFAB49F35447199C1840EFBD34FAE4B8553C08280150956801368B21CB3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.16 Balance Not Too Obvious Invincibility

## Design

- Emergency breakout can be used repeatedly, but not free.
- Endurance is consumed every trigger.
- Low endurance increases cost and records debt when safe minor wound API is not proven.
- Cooldown increases when endurance is low or critical.
- The effect is limited to nearby controlling zombies.
- The module reports partial success honestly when only zombies are cleared and player cancel is blocked.

## Non-Goals

- No healing.
- No bite rollback.
- No full-screen clear.
- No player teleport.
- No false success logs.

ICON_FEATURE_STATUS=ACTIVE_UI_OVERLAY_RETRY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN


```

## 0.5.16_EMERGENCY_GETUP_BREAKOUT_DESIGN.md

- SHA-256: `19FD3183F719F66D604FC49CC9E9CAFDD1A536A03A1B785E7C6151CE7A882DC9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.16 Emergency Getup Breakout Design

## Runtime Module

42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua

## Trigger Scope

- Trait player only.
- Input edge from run/sprint key or movement intent fallback.
- Valid states: on floor, getup/recovery, controlled/grab-like state, or surrounded by close zombies.
- Close zombie radius: 1.25.
- Crowd radius: 1.45.
- Max targets: 6.

## Effect

- Selects nearby controlling zombies.
- Applies verified zombie-side stagger/knockdown through Core.VerifiedStaggerControl.
- Attempts a player cancel only after targets were actually affected.
- Does not write player position.
- Does not heal or roll back damage.
- Does not clear the whole map.

## Logs

- [XNP EMERGENCY BREAKOUT] method=GETUP_CONTROL_BREAKOUT
- [XNP EMERGENCY BREAKOUT] trigger id=...
- [XNP EMERGENCY BREAKOUT TARGET]
- [XNP EMERGENCY BREAKOUT PUSH]
- [XNP EMERGENCY BREAKOUT OUTCOME]

ICON_FEATURE_STATUS=ACTIVE_UI_OVERLAY_RETRY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN


```

## 0.5.16_EMERGENCY_INPUT_DETECTION.md

- SHA-256: `DEA0387A9F8932763F0293CC4DEB1C59830AC48AC1D207D2139C7E9CB48425A0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.16 Emergency Input Detection

## Runtime Method

The module uses edge detection:

- current input down and previous input not down triggers one breakout attempt.
- direct keyboard route is attempted when keyboard constants are available.
- player state fallback is used otherwise.
- speed alone is not used because the player can be on floor with speed near zero.

## Logs

- [XNP EMERGENCY BREAKOUT INPUT] run_pressed=...
- [XNP EMERGENCY BREAKOUT INPUT] method=KEYBOARD_DIRECT
- [XNP EMERGENCY BREAKOUT INPUT] method=PLAYER_STATE_FALLBACK
- [XNP EMERGENCY BREAKOUT INPUT] blocked reason=NO_INPUT_EDGE

ICON_FEATURE_STATUS=ACTIVE_UI_OVERLAY_RETRY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN


```

## 0.5.16_STATUS_ICON_UI_DESIGN.md

- SHA-256: `D5FDE98920C3BC1C5BBA8EF0108214E8F034CFD8F32D2AB30E3D20DDAA21BF8C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.16 Status Icon UI Design

## Runtime Module

42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_StatusIconUI.lua

## Route

- Uses UI draw events when available.
- Draws fixed top-right fallback text.
- Does not follow world coordinates.
- Does not use legacy halo route.
- Does not use player speech.
- Does not write player position.

## States

- DISABLED
- SPRINT
- EMERGENCY_READY
- EMERGENCY_COOLDOWN
- LOW_STAMINA

## Logs

- [XNP STATUS ICON] method=UI_OVERLAY
- [XNP STATUS ICON] created=true
- [XNP STATUS ICON] texture=none fallback_text=true
- [XNP STATUS ICON] state=...
- [XNP STATUS ICON FAIL] reason=UI_API_NOT_AVAILABLE

ICON_FEATURE_STATUS=ACTIVE_UI_OVERLAY_RETRY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN


```

## 0.5.16_TEST_PLAN.md

- SHA-256: `07A89AB056E52D607A10A1206887A187A819424BBA4D233280F08D8C95D5354A`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.16 Test Plan

## Load

Confirm:

- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0516_EMERGENCY_GETUP_BREAKOUT_ICON_A
- [XNP EMERGENCY BREAKOUT] method=GETUP_CONTROL_BREAKOUT
- [XNP STATUS ICON] method=UI_OVERLAY
- [XNP STATUS ICON] state=...
- [XNP EMERGENCY BREAKOUT INPUT] method=...

## Tests

1. Confirm top-right overlay or fallback text appears and changes state.
2. While on floor, press run/sprint and confirm emergency breakout attempts.
3. While getup/recovery is visible, press run/sprint and confirm nearby controlling zombies are affected.
4. While grabbed or surrounded, press run/sprint and confirm multiple nearby zombies are staggered/knocked down.
5. Repeat at low endurance and confirm cost/debt logs.
6. Confirm no healing, no bite rollback, no world-coordinate fake icon, and no legacy player speech route.

ICON_FEATURE_STATUS=ACTIVE_UI_OVERLAY_RETRY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN


```

## BUILD_MARKER.txt

- SHA-256: `AADF8D27C12B80B1612B0A0F5AC2D74FEDDA5E6F42EA2DD7DC341861B848C0E5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0516_EMERGENCY_GETUP_BREAKOUT_ICON_A

```

## FINAL_REPORT.md

- SHA-256: `EBFEFF4BFFD460977CA65B9C44D16267B315798CEB8186E208202F4B25FA6F1D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.16

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.16
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0516_EMERGENCY_GETUP_BREAKOUT_ICON_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.16 Emergency Getup Breakout Icon

## Changed Files

- BUILD_MARKER.txt
- mod.info
- 42\mod.info
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Config.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_SprintTripImmunity.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakoutCost.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_StatusIconUI.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_VanillaImpact.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ShoulderImpact.lua
- 0.5.16_REAL_GAME_FAILURE_ANALYSIS_FROM_0.5.15.md
- 0.5.16_EMERGENCY_GETUP_BREAKOUT_DESIGN.md
- 0.5.16_EMERGENCY_INPUT_DETECTION.md
- 0.5.16_LOW_STAMINA_WOUND_COST_API_AUDIT.md
- 0.5.16_STATUS_ICON_UI_DESIGN.md
- 0.5.16_BALANCE_NOT_TOO_OBVIOUS_INVINCIBILITY.md
- 0.5.16_TEST_PLAN.md
- STATIC_AUDIT.md
- FINAL_REPORT.md

## 0.5.15 Real-Game Issues

- Sprint first wave effective but follow-up unstable: RETAINED, not primary target this round.
- Jog push efficient but still can fall: RETAINED, not primary target this round.
- Sweep/cancel summary stayed zero: EXPLAINED; emergency breakout is separate from sprint sweep.
- Active sprint log spam: FIXED.

## Emergency Getup Breakout

- Runtime attached: YES.
- Run/sprint input edge detection: YES.
- On-floor state can trigger: YES.
- Getup state can trigger: YES.
- Controlled/grab-like state can trigger: YES.
- Multiple controlling zombies handled: YES.
- Max targets: 6.
- Uses verified stagger/knockdown: YES.
- Writes player coordinates: NO.
- Heals damage or rolls back bite: NO.

## Low Stamina Cost

- Endurance cost implemented: YES.
- Low stamina debt implemented: YES.
- Minor wound cost implemented: FALLBACK_ONLY.
- Wound API safety: RISK / NOT_PROVEN_BY_STATIC_AUDIT.
- no bite / no infection guarantee: YES by implementation path, no unsafe direct wound write.

## Top Right Icon

- UI overlay attached: YES.
- Uses legacy halo helper: NO.
- Uses player speech: NO.
- Uses world coordinate fake icon: NO.
- Fallback text implemented: YES.

## Safety

- Forbidden grep: PASS_NO_HITS.
- Old active marker grep: PASS_NO_HITS.
- Old source modified: NO.
- Project Zomboid launched: NO.
- Steam launched: NO.
- User mods / saves / Workshop / game directory written: NO.

## Final Status

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.16_SOURCE_READY_FOR_EMERGENCY_BREAKOUT_TEST


```

## 0.5.16_LOW_STAMINA_WOUND_COST_API_AUDIT.md

- SHA-256: `43E6DE4A411C0ACBC6EAE196913E077632A751740C869DFDD23033F44C8C443D`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.16 Low Stamina Wound Cost API Audit

## Runtime Module

42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakoutCost.lua

## Audit Result

- Safe direct minor wound API: NOT_PROVEN_BY_STATIC_AUDIT.
- Direct bite creation: FORBIDDEN.
- Infection creation: FORBIDDEN.
- Healing: FORBIDDEN.
- Damage rollback: FORBIDDEN.
- Fallback: endurance cost plus debt.

## Behavior

- High endurance: normal endurance cost.
- Low endurance: larger endurance cost and wound roll log.
- If a safe minor wound API is not proven, the module records fallback debt instead of writing unsafe injury data.

## Logs

- [XNP EMERGENCY COST] endurance_before=...
- [XNP EMERGENCY COST] low_stamina=true
- [XNP EMERGENCY COST] wound_result=fallback_debt
- [XNP EMERGENCY COST] no_bite=true no_infection=true no_heal=true

ICON_FEATURE_STATUS=ACTIVE_UI_OVERLAY_RETRY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN


```

## STATIC_AUDIT.md

- SHA-256: `D8BF5E6AEF8AEE0550E6F595AECA204D665AD5F4781F0ED04B6EC086527B37B8`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.16

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.16
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0516_EMERGENCY_GETUP_BREAKOUT_ICON_A

## Source Safety

- New source path confirmed.
- Old sources were not edited.
- Project Zomboid was not launched.
- Steam was not launched.
- User mods / saves / Workshop / game directory were not written.

## Old Active Marker Grep

- 0511 / 0.5.11 active Lua grep: PASS_NO_HITS.
- 0512 / 0.5.12 active Lua grep: PASS_NO_HITS.
- 0513 / 0.5.13 active Lua grep: PASS_NO_HITS.
- 0514 / 0.5.14 active Lua grep: PASS_NO_HITS.
- 0515 / 0.5.15 active Lua grep: PASS_NO_HITS.

## Forbidden Route Grep

- Forbidden player collision / legacy UI route grep: PASS_NO_HITS.
- Player coordinate write grep: PASS_NO_HITS.
- GameTime grep: PASS_NO_HITS.
- Legacy speech route grep: PASS_NO_HITS.
- Legacy halo helper grep: PASS_NO_HITS.

## Runtime Modules

- EmergencyBreakout runtime grep: PASS.
- Emergency input edge detection grep: PASS.
- Emergency controlling zombie selection grep: PASS.
- Emergency verified stagger / knockdown route grep: PASS.
- Emergency player cancel attempt grep: PASS.
- EmergencyBreakoutCost runtime grep: PASS.
- StatusIconUI runtime grep: PASS.
- VanillaImpact no-op: PASS.
- ShoulderImpact no-op: PASS.

## Special Cost Scope

- Low-stamina injury-related words appear only in XNP_DR_EmergencyBreakoutCost.lua.
- Current cost module does not hard-write unsafe injury state.
- Minor injury cost is FALLBACK_ONLY until a safe API is proven.
- Endurance cost and debt fallback are implemented.

## UI Scope

- UI route uses screen overlay draw events when available.
- Fallback text is fixed to top-right screen coordinates.
- It is not a world object and does not follow player world position.

## Sprint Log Noise

- Per-frame sprint active log was replaced by [XNP SPRINT IMMUNITY ACTIVE SUMMARY].
- Trigger / fail / cancel logs remain immediate.

## Counts

- Lua files: 20.
- Lua lines before final report: 3480.
- Markdown docs before final report: 7.
- Lua interpreter: NOT_VERIFIABLE_NO_LOCAL_INTERPRETER.
- Real-game behavior: NOT_VERIFIABLE_BY_STATIC_AUDIT.

ICON_FEATURE_STATUS=ACTIVE_UI_OVERLAY_RETRY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.16_SOURCE_READY_FOR_EMERGENCY_BREAKOUT_TEST


```
