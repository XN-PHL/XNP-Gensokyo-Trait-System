# 0.5.17 Sanitized Evidence Excerpts

## 0.5.17_REAL_GAME_FAILURE_ANALYSIS_FROM_0.5.16.md

- SHA-256: `AC3B2435E35FF6CB9F9D505FB6A3DD3B1A3D4C1868658E7017D9B9F0A1CD129D`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.17 Real Game Failure Analysis From 0.5.16

0.5.16 failed in two confirmed areas:

- The right-top indicator was a text overlay, not a recovered icon route. It reported UI overlay creation with no texture and fallback text.
- Emergency breakout input stayed edge-only in practice. Repeated frames logged no input edge even when sprint input was held.
- Dragdown/fatal surrounded windows were not covered. Multiple close zombies can kill or lock the player before ordinary emergency input succeeds.

0.5.17 response:

- Recovered icon route is active through ISPanel, moodle background texture, outline border, trait texture, slot sorting, and danger shake.
- Emergency input accepts held input, recent press, state-enter-held, and auto dragdown danger.
- DragdownDangerBreakout detects close multi-zombie danger and automatically applies zombie-side verified stagger control.

ICON_FEATURE_STATUS=ACTIVE_RECOVERED_ICON_ROUTE
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN
TEXT_FALLBACK_STATUS=DEBUG_ONLY_NOT_MAIN_UI

```

## 0.5.17_BALANCE_NEAR_INVINCIBLE_NOT_OBVIOUS.md

- SHA-256: `4C04AA1A2491C3D51DB72F183EF7FFE299BE1F30F34F9B57002237BF8EDB25B1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.17 Balance Near Invincible Not Obvious

0.5.17 is intentionally strong around dragdown and emergency recovery, but still consumes endurance and keeps cooldowns.

Costs:

- Normal emergency breakout uses `EMERGENCY_BREAKOUT_BASE_COST`.
- Low stamina increases cooldown.
- Critical stamina increases cooldown further.
- Dragdown danger uses emergency cost and its own short cooldown.

Not enabled:

- No healing.
- No bite rollback.
- No time manipulation.
- No player coordinate reposition.
- No formal invincibility flag.

The test goal is practical survival from crowd dragdown, not a finished balanced public release.

```

## 0.5.17_DRAGDOWN_DANGER_BREAKOUT_DESIGN.md

- SHA-256: `F889B6511EC7DA6007AC0F9DAC95D9079E12F6FF8E1705AFE01C615034F06D1D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.17 Dragdown Danger Breakout Design

Module:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout.lua`

Purpose:

- Detect the surrounded/dragdown fatal window before or during control loss.
- Trigger automatically when multiple zombies are extremely close.
- Apply effects to zombies, not to player movement coordinates.

Detection:

- `DRAGDOWN_DANGER`: at least 2 zombies inside 1.20, or at least 3 inside 1.65, or controlled/getup state with close zombie.
- `FATAL_SURROUNDED`: at least 3 zombies inside 1.20, or at least 4 inside 1.65.
- Auto trigger after 2 danger frames, or immediately for fatal surrounded.

Action:

- Uses `VerifiedStaggerControl.Apply(..., "SPRINT_PRECOLLISION", ...)`.
- Maximum targets: 8 normal, 10 critical.
- Applies emergency cost.
- Attempts safe player getup/cancel APIs only when present.
- Does not heal, rollback damage, write player coordinates, or modify time.

Expected logs:

- `[XNP DRAGDOWN DANGER] method=SURROUNDED_FATAL_WINDOW_BREAKOUT`
- `[XNP DRAGDOWN DANGER] level=DRAGDOWN_DANGER`
- `[XNP DRAGDOWN DANGER] level=FATAL_SURROUNDED auto_trigger=true`
- `[XNP DRAGDOWN TARGET]`
- `[XNP DRAGDOWN BREAKOUT]`

```

## 0.5.17_EMERGENCY_INPUT_FIX_DESIGN.md

- SHA-256: `DC54ADFCEFDC84EF1D7EB988F57EC5807599BB2CF202E60ADC271532A5830EBF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.17 Emergency Input Fix Design

Module:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput.lua`

0.5.16 failed because edge-only input could miss held sprint/run input after the player entered getup/control states.

0.5.17 accepts:

- edge input when present;
- held input;
- recent press within 0.60 seconds;
- state-enter-held input;
- automatic dragdown danger trigger.

It avoids per-frame no-edge spam by reporting window summaries:

`[XNP EMERGENCY INPUT SUMMARY]`

Configured behavior:

- `EMERGENCY_INPUT_EDGE_REQUIRED=false`
- `EMERGENCY_INPUT_ALLOW_HELD=true`
- `EMERGENCY_INPUT_ALLOW_RECENT_PRESS=true`
- `EMERGENCY_INPUT_RECENT_PRESS_WINDOW=0.60`
- `EMERGENCY_INPUT_ALLOW_STATE_ENTER_HELD=true`
- `EMERGENCY_INPUT_ALLOW_AUTO_DRAGDOWN=true`

```

## 0.5.17_RECOVERED_STATUS_ICON_DESIGN.md

- SHA-256: `81D2F888C96B8EAE5F197A6980E6253F8CBAB305ACFA4DCB447F34D11D18245E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.17 Recovered Status Icon Design

Module:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua`

Design:

- Uses `ISPanel`.
- Loads moodle background and outline textures.
- Loads `media/ui/Traits/trait_xnpdistancerunner.png`.
- Sorts into the right-top moodle slot stack.
- Draws a colored border/background state.
- Shakes when dragdown danger is active.

States:

- `EMERGENCY_READY`
- `DRAGDOWN_DANGER`
- `LOW_STAMINA`
- `EMERGENCY_COOLDOWN`
- `SPRINT`

Expected logs:

- `[XNP STATUS ICON] method=RECOVERED_ICON_ROUTE`
- `[XNP STATUS ICON] old_route=FOUND source=0.4.18_ACTIVE_STATUS_ICON`
- `[XNP STATUS ICON] texture=media/ui/Traits/trait_xnpdistancerunner.png loaded=true`
- `[XNP STATUS ICON] border=true`
- `[XNP STATUS ICON] shake=true`
- `[XNP STATUS ICON] slot_sort=true`

TEXT_FALLBACK_STATUS=DEBUG_ONLY_NOT_MAIN_UI

```

## 0.5.17_SPRINT_ROUTE_PRESERVATION.md

- SHA-256: `9FD10F9D5531F772CB837CF936874679934955B6C33B75E708AC6A56CA52CB86`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.17 Sprint Route Preservation

0.5.17 keeps the 0.5.14/0.5.15 verified stagger route for sprint/contact control.

Expected startup logs:

- `[XNP SPRINT ROUTE] preserved_verified_stagger=true`
- `[XNP SPRINT ROUTE] source=0.5.14/0.5.15`
- `[XNP SPRINT ROUTE] first_wave_knockdown_capable=true`

The sprint route remains zombie-side and does not restore the failed player collision route from 0.5.10.

```

## 0.5.17_SURROUNDED_FATAL_WINDOW_ANALYSIS.md

- SHA-256: `B1EA5E028E7E355C506C3EE3B16001481E967C550FCE406704286E096915D0BC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.17 Surrounded Fatal Window Analysis

Project Zomboid can resolve surrounded zombie contact faster than a normal manual input chain can react.

0.5.17 therefore treats close multi-zombie pressure as a separate danger state:

- One close zombie is not fatal surrounded.
- Two very close zombies are dragdown danger.
- Three very close zombies are fatal surrounded.
- Four zombies in outer close range are fatal surrounded.

The module does not wait for ordinary range-only contact. It requires close zombie counts and player control/getup state context.

Range-only trigger remains rejected for sprint/contact breakout. Dragdown breakout is a separate safety route for surrounded fatal windows.

```

## 0.5.17_TEST_PLAN.md

- SHA-256: `F953A9F939C7956B8AD19B2DFE30AB86F38F770F5A4FBE6AD0A3337BBDC36A65`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.17 Test Plan

1. Confirm console startup:
   - `XNP_PZ_DISTANCE_TRAIT_0517_ICON_RECOVERY_DRAGDOWN_BREAKOUT_A`
   - `[XNP CONFIG] loaded`
   - `[XNP STATUS ICON] method=RECOVERED_ICON_ROUTE`
   - `[XNP SPRINT ROUTE] preserved_verified_stagger=true`

2. Right-top icon:
   - Confirm an icon appears, not yellow fallback text.
   - Confirm dragdown danger state shakes.
   - Confirm no main UI log reports no texture with text fallback.

3. Emergency held input:
   - Hold sprint/run while entering getup/control state.
   - Expected accepted reason: `HELD`, `RECENT_PRESS`, or `STATE_ENTER_HELD`.
   - It must not fail only because there is no input edge.

4. Dragdown danger:
   - Let 2 to 4 zombies get very close.
   - Expected logs: `DRAGDOWN_DANGER`, `FATAL_SURROUNDED`, and `DRAGDOWN BREAKOUT`.
   - Confirm more than one zombie can be selected.

5. Sprint route regression:
   - Full sprint contact should still use verified stagger route.
   - This test is not a full sprint immunity rewrite.

6. Forbidden behavior:
   - Do not see failed old text icon route as main UI.
   - Do not see old player-side collision route errors.
   - Do not see game time changes, player coordinate writes, or trait runtime registration errors.

```

## BUILD_MARKER.txt

- SHA-256: `84C39FDD1D7A72FB357B24736098621C9F47EEECAF0E72E5ECEE03510281B558`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0517_ICON_RECOVERY_DRAGDOWN_BREAKOUT_A

```

## FINAL_REPORT.md

- SHA-256: `73E852E8C955534794920EE4AA4A5B6AE35C489648781D0B1416D572306DA1EA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.17

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.17
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0517_ICON_RECOVERY_DRAGDOWN_BREAKOUT_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.17 Icon Recovery Dragdown Breakout

## Changed File List

- `BUILD_MARKER.txt`
- `mod.info`
- `42/mod.info`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakout.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ShoulderImpact.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_VanillaImpact.lua`
- 0.5.17 design/audit/test markdown files

## 0.5.16 Failure Fix Status

- Text overlay icon route replaced: YES
- Recovered old icon route implemented: YES
- Edge-only emergency input removed: YES
- Held/recent/state-enter/auto-dragdown input added: YES
- Dragdown/fatal surrounded breakout added: YES
- Multiple zombie target support added: YES

## Old Icon Route Audit

- Old route source: `0.4.18_B42_MOODLE_BEHAVIOR_ADRENALINE_SOURCE`
- Evidence found: ISPanel, moodle textures, outline border, trait texture, slot sorting, overlap prevention, shake/pulse.
- 0.5.17 route: recovered and active in `XNP_DR_StatusIconUI.lua`.

## Right-Top Icon

- Method: `RECOVERED_ICON_ROUTE`
- Texture: `media/ui/Traits/trait_xnpdistancerunner.png`
- Border: enabled through moodle outline texture
- Slot sort: enabled
- Shake: enabled for dragdown danger
- Main text fallback: disabled as normal path; debug-only status recorded

## Emergency Input

- `EMERGENCY_INPUT_EDGE_REQUIRED=false`
- Held input accepted
- Recent press window: 0.60s
- State-enter-held accepted
- Auto dragdown danger accepted
- Summary logging replaces repeated no-edge spam

## Dragdown Breakout

- Module: `XNP_DR_DragdownDangerBreakout.lua`
- Danger threshold: 2 inner or 3 outer zombies
- Fatal surrounded threshold: 3 inner or 4 outer zombies
- Targets: up to 8 normal, up to 10 critical
- Uses zombie-side verified stagger control
- Applies cost and cooldown
- Does not write player coordinates
- Does not heal or rollback damage

## Sprint Route Preservation

- `[XNP SPRINT ROUTE] preserved_verified_stagger=true`
- `[XNP SPRINT ROUTE] source=0.5.14/0.5.15`
- `[XNP SPRINT ROUTE] first_wave_knockdown_capable=true`

## Static Check

- Lua files: 22
- Lua total lines: 4483
- Markdown docs: 11
- Forbidden grep: PASS
- Old active/failure route grep: PASS
- Lua execution syntax check: NOT_VERIFIABLE_STATIC_ENV_NO_LUA
- Runtime test: NOT_RUN_BY_USER_
[EXCERPT_TRUNCATED]
```

## 0.5.17_OLD_ICON_ROUTE_RECOVERY_AUDIT.md

- SHA-256: `6AEDCDF043304B93A22C7107AC292FA6DC0BAED22E0208257435ABFC270254BB`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.17 Old Icon Route Recovery Audit

Recovered source inspected:

`[LOCAL_PATH_REDACTED]`

Old route evidence found:

- `ISPanel:derive`
- `drawTextureScaled`
- moodle solid background texture
- moodle outline border texture
- trait icon texture
- `layoutForSlot`
- visible vanilla moodle collection
- selected slot logging
- conflict/overlap prevention
- pulse/shake animation

0.5.17 recovery target:

- `XNP_DR_StatusIconUI.lua` now uses the recovered icon route instead of text overlay.
- Texture path is `media/ui/Traits/trait_xnpdistancerunner.png`.
- Main UI requires texture. Text fallback is debug-only and not the normal path.

OLD_ICON_ROUTE_FOUND=YES
RECOVERED_ROUTE_IMPLEMENTED=YES
TEXT_OVERLAY_ROUTE_REJECTED_AS_MAIN_UI=YES

```

## STATIC_AUDIT.md

- SHA-256: `D71A71974F55227B9FCC4CB7F8BAF36D7A41D606997439807BB576E9713AF6AF`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.17

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.17
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0517_ICON_RECOVERY_DRAGDOWN_BREAKOUT_A

## File Counts

- Lua files: 22
- Lua total lines: 4483
- Markdown docs: 11
- Empty files: none
- NULL bytes: none in Lua/docs; PNG icon is binary and contains expected binary bytes

## Implemented Files

- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakout.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`

## Required Route Checks

- Build marker present: PASS
- Recovered icon route present: PASS
- Old icon route audit: FOUND
- Emergency input module required by Bootstrap/Runtime: PASS
- Dragdown danger module required by Bootstrap/Runtime: PASS
- Runtime calls `Core.DragdownDangerBreakout.Update(player)`: PASS
- Runtime calls `Core.EmergencyBreakout.Update(player)`: PASS
- Runtime calls `Core.StatusIconUI.Update(player)`: PASS
- Sprint route preservation logs present: PASS

## Removed Failure Route Checks

- Old text-overlay method log: PASS, no match
- Old no-texture fallback log: PASS, no match
- Old edge-only blocked reason log: PASS, no match
- Old numeric build marker suffix: PASS, no match
- old display name: PASS, no match

## Forbidden Fixed-String Grep

No matches for:

- setVariable bumped literal patterns
- legacy direct string trait call
- old trait factory/runtime registration names
- old running shove/player collision state names
- game time multiplier route
- text/halo route helpers
- player coordinate writes
- direct body-damage/muscle-strain route names

## Coordinate / Game State Writes

- Player X/Y/Z coordinate writes: none
- Zombie micro nudge helper exists in inherited BreakoutPush but remains controlled by config and does not write player coordinates
- Player getup cancel APIs are present in emergency/sprint/dragdown recovery paths
- Game time writes: none
- Healing/rollback: none

## Syntax

- Lua interpreter/luac availability: NOT_VERIFIABLE_STATIC_ENV_NO_LUA
- Text balance scan: no empty Lua files; quote counts did not show unterminated obvious string literals
- Runtime execution: NOT_RUN_BY_USER_RULE

## Status Constants

ICON_FEATURE_STATUS=ACTIVE_RECOVERED_ICON_ROUTE
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
PLAYER_SAY_STATUS=FORBIDDEN
TEXT_FALLBACK_STATUS=DEBUG_ONLY_NOT_MAIN_UI

## Restrictions

- Project Zomboid launched: NO
- Steam launched
[EXCERPT_TRUNCATED]
```
