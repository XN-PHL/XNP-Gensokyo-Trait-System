# 0.5.22 Sanitized Evidence Excerpts

## 0.5.22_DRAGGABLE_STATUS_ICON_DESIGN.md

- SHA-256: `BEFFAAB639B825010D67B6AFD70F1299D8C317EA5FA3A0C790C72F80D1368363`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Draggable Status Icon Design

Module:

- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DraggableStatusIcon.lua

Runtime integration:

- XNP_DR_StatusIconUI requires XNP_DR_DraggableStatusIcon.
- StatusIconPosition still computes the default recovered route.
- DraggableStatusIcon.LayoutOverride replaces x/y only when user placement exists.

Controls:

- Alt + left mouse drag begins movement.
- Mouse release saves to player moddata.
- Right mouse release resets to configured default.

Storage keys:

- XNP_DR_StatusIcon_X
- XNP_DR_StatusIcon_Y
- XNP_DR_StatusIcon_UserPlaced

Required preservation:

- RECOVERED_ICON_ROUTE_0517_RESTORED: PRESERVED
- red flash: PRESERVED
- shake: PRESERVED
- color: PRESERVED
- border: PRESERVED
- slot_sort: PRESERVED
- single status icon: PRESERVED
- text fallback main UI: DISABLED

Expected logs:

- [XNP STATUS ICON DRAG] enabled=true input=ALT_LEFT_DRAG
- [XNP STATUS ICON DRAG] begin
- [XNP STATUS ICON DRAG] move
- [XNP STATUS ICON DRAG] end
- [XNP STATUS ICON DRAG] loaded
- [XNP STATUS ICON DRAG] reset_to_default
- [XNP STATUS ICON DRAG] clamp
- [XNP STATUS ICON] shake_preserved=true dragged_position=true
- [XNP STATUS ICON] color_preserved=true dragged_position=true

```

## 0.5.22_FALL_RECOVERY_INPUT_DESIGN.md

- SHA-256: `A9B5E9112892D8B3149A595F41C7DB728031676777BD2C2EB6E92E10DDC44929`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Fall Recovery Input Design

Module:

- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput.lua

Fall classes:

- VEHICLE_WALL_DESIGN_FALL: cancel_allowed=false, recovery_input=true
- JOG_RANDOM_TRIP: cancel_allowed=false, recovery_input=true
- CONTROLLED_AFTER_FALL: cancel_allowed=true, recovery_input=true

Input:

- Run or sprint intent is accepted through existing EmergencyInput.
- Recovery applies breakout logic through existing EmergencyBreakout where available.
- Recovery does not heal.
- Recovery does not roll back bite or infection.

Expected logs:

- [XNP FALL CLASSIFY] type=VEHICLE_WALL_DESIGN_FALL cancel_allowed=false recovery_input=true
- [XNP FALL CLASSIFY] type=JOG_RANDOM_TRIP cancel_allowed=false recovery_input=true
- [XNP FALL RECOVERY] input=RUN_OR_SPRINT result=BREAKOUT_APPLIED
- [XNP FALL RECOVERY COST]
- [XNP FALL RECOVERY] no_bite=true no_infection=true no_heal=true

```

## 0.5.22_JOG_BUMP_LAUNCH_BALANCE.md

- SHA-256: `EB324B9AEF9002E0296CD0DB2C5D88CDA12D0EAF0F2C1EE9B5C020B904705AC5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Jog Bump Launch Balance

Module:

- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_JogBumpLaunch.lua

Mechanism:

- JOG_BUMP_LAUNCH
- Only active in jog-speed range.
- Full sprint is excluded.
- Plain low-speed movement is excluded.
- Uses forward dot, distance, and closing frames.

Balance:

- jog_bump_stagger_chance=0.70
- jog_bump_knockdown_chance=0.22
- jog_bump_launch_chance=0.08
- jog_player_trip_chance=0.03
- jog_player_trip_chance_when_low_stamina=0.08
- jog does not kill zombies: YES
- fall recovery input: YES

Expected logs:

- [XNP JOG BUMP] trigger
- [XNP JOG BUMP] effect=STAGGER_ONLY
- [XNP JOG BUMP] effect=JOG_KNOCKDOWN
- [XNP JOG BUMP] effect=JOG_LAUNCH
- [XNP JOG BUMP] player_trip_roll
- [XNP JOG BUMP COST]
- [XNP JOG RECOVERY] enabled=true input=RUN_OR_SPRINT

```

## 0.5.22_REAL_GAME_TUNING_ANALYSIS_FROM_0.5.21.md

- SHA-256: `2954AD09639E885C82684FF6C914AE2B41A510F67430B06BBACA043B2F9A4F38`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Real Game Tuning Analysis From 0.5.21

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
BASELINE_SOURCE=[LOCAL_PATH_REDACTED]
VERSION=0.5.22
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0522_DRAGGABLE_ICON_VEHICLE_IMPACT_A

Accepted 0.5.21 feedback:

- Main activation chain: PRESERVED.
- Recovered status icon route: PRESERVED.
- Dynamic color, shake, border, slot sort, single status icon: PRESERVED.
- Red skill flash: PRESERVED.
- Sprint trip cancel route: PRESERVED.
- Sprint sweep had visible effect and is now replaced by explicit vehicle-impact rules.

0.5.22 changes:

- ICON_FEATURE_STATUS=DRAGGABLE_KEEP_DYNAMIC_EFFECTS
- ICON_RED_FLASH_STATUS=PRESERVED
- ICON_SHAKE_STATUS=PRESERVED
- ICON_COLOR_STATUS=PRESERVED
- ICON_POSITION_STATUS=USER_DRAGGABLE
- MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
- HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- TEXT_FALLBACK_STATUS=DEBUG_ONLY_NOT_MAIN_UI
- JOG_STATUS=KEEP_BUMP_LAUNCH_SMALL_PLAYER_TRIP_RISK
- SPRINT_STATUS=VEHICLE_IMPACT_LIGHT_KILLS_WALL_CRASH_FALL
- WALL_CRASH_STATUS=THREE_FRONT_ZOMBIES_FORCE_FALL_KILL_BLOCKERS_MINOR_SCRAPE
- GRAB_ESCAPE_STATUS=PRESERVED
- NO_BITE_NO_INFECTION_NO_HEAL=PRESERVED

Real game status:

- Static source is prepared.
- Runtime behavior is NOT_VERIFIABLE_BY_STATIC_AUDIT.
- User must copy and test manually.

```

## 0.5.22_SPRINT_VEHICLE_IMPACT_DESIGN.md

- SHA-256: `ABE16F2150BBBE76AA15021B15F946813C19BA9075D0539E84A2B3652404E980`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Sprint Vehicle Impact Design

Modules:

- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintVehicleImpact.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ZombieVehicleImpact.lua

Mechanism:

- SPRINT_VEHICLE_IMPACT
- Requires full sprint.
- Requires front arc, near distance, and closing frames.
- Does not affect rear, side-rear, distant, or passive radius-only targets.

Light impact:

- 1-2 blockers.
- Zombies receive launch / knockdown / death route.
- Player stays up.
- Cost: 0.075 endurance.

Wall crash:

- 3+ front blockers.
- Front blockers use vehicle death route.
- Player receives design fall.
- Minor scrape route is attempted.
- Cost: 0.160 endurance.

Required static markers:

- full sprint required: YES
- no remote clear: YES
- light mode max blockers: 2
- wall crash threshold: 3
- zombie kill route: scoped to SprintVehicleImpact and ZombieVehicleImpact
- player forced fall in wall mode: YES
- player stay up in light mode: YES

```

## 0.5.22_TEST_PLAN.md

- SHA-256: `C37705720AEC724869BD98C3AE1346BD9BB9BC5F31918A23F867099F73D3BC17`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.22 Test Plan

Do not install automatically from Codex. User copies manually.

Test 1: draggable icon

- Load game with trait.
- Confirm build marker.
- Confirm Config loaded.
- Hold Alt and left-drag status icon.
- Release and confirm saved log.
- Re-enter game and confirm loaded position.
- Verify red flash, shake, color, border, slot sort still work.

Test 2: jog bump

- Jog into one front zombie.
- Expect mostly stagger.
- Sometimes knockdown or launch.
- Rare player trip.
- Confirm jog does not kill zombies.
- If controlled after fall, press run or sprint to recover.

Test 3: full sprint light vehicle impact

- Full sprint into 1-2 front zombies.
- Expect vehicle-style zombie launch / knockdown / death.
- Player should stay up.
- No remote clear.

Test 4: full sprint wall crash

- Full sprint into 3+ front zombies.
- Expect WALL_CRASH.
- Front blockers die or fallback knockdown.
- Player design fall.
- Minor scrape attempted.
- SprintTripCancel must not immediately cancel design fall.
- Recovery input can still break control after falling.

Required final READY marker:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.22_SOURCE_READY_FOR_DRAGGABLE_ICON_VEHICLE_IMPACT_TEST

```

## 0.5.22_WALL_CRASH_PLAYER_FALL_AND_SCRAPE.md

- SHA-256: `EA9DA740D113785D83920EF83CD19E107F30E5D471546645C60C59C7B8E707CC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Wall Crash Player Fall And Scrape

Wall crash rules:

- Trigger requires full sprint and at least 3 valid front blockers.
- Player design fall is intentional.
- SprintTripCancel is blocked from immediately cancelling this design fall.
- Recovery input remains available after fall if the player is controlled.

Minor scrape:

- Implemented only in XNP_DR_MinorScrapeCost.lua.
- Allowed sources:
  - SPRINT_VEHICLE_WALL_CRASH
  - LOW_STAMINA_EMERGENCY_FALLBACK

Prohibited effects:

- no bite
- no infection
- no heal
- no heavy wound route
- no damage rollback

Expected logs:

- [XNP FALL CLASSIFY] type=VEHICLE_WALL_DESIGN_FALL cancel_allowed=false recovery_input=true
- [XNP SPRINT TRIP CANCEL] blocked reason=VEHICLE_WALL_DESIGN_FALL
- [XNP SCRAPE] type=MINOR_SCRAPE source=VEHICLE_WALL_CRASH
- [XNP SCRAPE] no_bite=true no_infection=true no_heal=true

```

## 0.5.22_ZOMBIE_VEHICLE_DEATH_ROUTE.md

- SHA-256: `C9CED4234C4B78E9AC110006C41880E7AF8C06652F7DFE79F6FC9C03ADA5BE27`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Zombie Vehicle Death Route

Module:

- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ZombieVehicleImpact.lua

Scope:

- Only called by full sprint vehicle impact.
- Only applies to selected front near blockers.
- No remote clear.
- No full-screen clear.
- No passive aura.

Route order:

- Visible stagger / knockdown first.
- Small zombie-side nudge.
- Safe death API attempt by pcall.
- Fallback to knockdown if no safe death route is available.

Expected logs:

- [XNP VEHICLE IMPACT ZOMBIE] id
- [XNP VEHICLE IMPACT ZOMBIE] effect=LAUNCH_KNOCKDOWN_DEATH
- [XNP VEHICLE IMPACT ZOMBIE] death_result=ok
- [XNP VEHICLE IMPACT ZOMBIE] death_result=fallback_knockdown reason=NO_SAFE_KILL_API

Risk:

- Exact zombie death method is NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Fallback route is present.

```

## BUILD_MARKER.txt

- SHA-256: `5C2EA6D5CD7F0DE58AA575FBE88B96795BC87D98C7CDFFFD677E531492204C93`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0522_DRAGGABLE_ICON_VEHICLE_IMPACT_A

```

## FINAL_REPORT.md

- SHA-256: `F9DEE83C6F3B53634DD70E89E086B4FDA01F9894091A82A671E4098CC070FCD3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.22
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0522_DRAGGABLE_ICON_VEHICLE_IMPACT_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.22 Draggable Icon Vehicle Impact

Changed files:

- BUILD_MARKER.txt
- mod.info
- 42/mod.info
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintTripImmunity.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DraggableStatusIcon.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_JogBumpLaunch.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ZombieVehicleImpact.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintVehicleImpact.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_MinorScrapeCost.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput.lua
- 0.5.22_REAL_GAME_TUNING_ANALYSIS_FROM_0.5.21.md
- 0.5.22_DRAGGABLE_STATUS_ICON_DESIGN.md
- 0.5.22_ICON_EFFECT_PRESERVE_AUDIT.md
- 0.5.22_JOG_BUMP_LAUNCH_BALANCE.md
- 0.5.22_SPRINT_VEHICLE_IMPACT_DESIGN.md
- 0.5.22_WALL_CRASH_PLAYER_FALL_AND_SCRAPE.md
- 0.5.22_ZOMBIE_VEHICLE_DEATH_ROUTE.md
- 0.5.22_FALL_RECOVERY_INPUT_DESIGN.md
- 0.5.22_TEST_PLAN.md
- STATIC_AUDIT.md
- FINAL_REPORT.md

0.5.21 feedback handling:

- effect is good: PRESERVED
- icon coordinate still wrong: FIXED_BY_DRAGGABLE
- drag keeps shake: YES
- drag keeps color changes: YES
- drag keeps red flash: YES
- jog bump launch chance preserved: YES
- jog small player trip chance: YES
- post-fall control breakout: YES
- sprint vehicle-style zombie kill: YES
- 3+ wall crash player fall: YES
- wall crash zombie death: YES
- player minor scrape: YES

Draggable Icon:

- runtime integration: YES
- drag input: ALT_LEFT_DRAG
- save/load: player_moddata with session fallback
- clamp: YES
- reset: YES
- shake preserved: YES
- color preserved: YES
- red flash preserved: YES
- fallback text main UI: NO

Jog Bump:

- jog_bump_stagger_chance: 0.70
- jog_bump_knockdown_chance: 0.22
- jog_bump_launch_chance: 0.08
- jog_player_trip_chance: 0.03
- jog does not kill zombies: YES
- fall recovery input: YES

Sprint Vehicle Impact:

- light mode max blockers: 2
- wall crash threshold: 3
- zombie kill route: YES
- launch/knockdown route: YES
- player stay up in light mode: YES
- player forced fall in wall mode: YES
- minor scrape route: YES
- no remote clear: YES
- full sprint required: YES

Fall Recovery:

- vehicle wall design fall cancel_allowed: false
- jog random trip recovery: YES
- controlled after fall breakout: YES
- no bite/no infection/no heal: YES

Log throttle:

- drag logs throttled: YES
- icon state_hold summary-only: YES
- dragdown blocked summary-only: YES
- auto dragdown summary-only: YE
[EXCERPT_TRUNCATED]
```

## 0.5.22_ICON_EFFECT_PRESERVE_AUDIT.md

- SHA-256: `157B66033125DF18D8AEC66326CD3FA3CAE1DBC42E1E0BCE711E467C2406CBD6`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Icon Effect Preserve Audit

Preserved from 0.5.21:

- Texture loading path.
- Moodle border texture route.
- Dynamic state color.
- Dragdown danger shake.
- Sprint color.
- Red skill flash.
- State hold summary log.
- Single status icon mode.

Changed:

- Fixed coordinate guessing is replaced by user draggable placement.
- User placement is stored in player moddata when available.
- Session fallback is used if moddata cannot be read.

Static result:

- icon drag runtime: IMPLEMENTED
- drag save: IMPLEMENTED
- drag load: IMPLEMENTED
- clamp to screen: IMPLEMENTED
- reset to default: IMPLEMENTED
- red flash after drag: PRESERVED
- shake after drag: PRESERVED
- color after drag: PRESERVED

Risk:

- Exact mouse callback names are PZ UI runtime dependent and require in-game validation.

```

## 0.5.22_SECOND_PASS_AUDIT.md

- SHA-256: `274B0679C89B02F08EC934168A3D886A3FF920F935CA0ADAB3FA8B26BA2D6AA7`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.22 Second Pass Audit

## 1. Executive Summary

Audited SOURCE:

`[LOCAL_PATH_REDACTED]`

This was a read-only second pass audit. No runtime code was modified. Project Zomboid, Steam, user mods, saves, Workshop, and game install directories were not touched.

Result:

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.22_SECOND_PASS_AUDIT_BLOCKED_NOT_READY`

Reason:

- BLOCKER: active Lua still contains old active version strings from 0.5.20 / 0.5.21.
- RISK: vehicle impact death route is present, but safe zombie kill API cannot be proven by static audit.
- RISK: vehicle impact does not enter BreakoutActionBus, so same-target coordination is incomplete.
- RISK: draggable icon has Alt+left drag runtime and save/load, but long-press fallback is configured and not implemented.

## 2. SOURCE / Version Check

- SOURCE_EXISTS: YES
- BUILD_MARKER_OK: YES
- DISPLAY_NAME_OK: YES
- OLD_ACTIVE_MARKER_RESIDUE: FAIL
- VERSION_MISMATCH: YES, active Lua contains old version log strings.

Required files/directories:

- BUILD_MARKER.txt: YES
- mod.info: YES
- 42/mod.info: YES
- 42/media/lua/client/XNP_PZ_DistanceRunner/: YES
- 42/media/lua/shared/XNP_PZ_DistanceRunner/: YES
- FINAL_REPORT.md: YES
- STATIC_AUDIT.md: YES

Expected build marker:

- XNP_PZ_DISTANCE_TRAIT_0522_DRAGGABLE_ICON_VEHICLE_IMPACT_A: found.

Active runtime old-version residue:

- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua:234`
  - `tune=0.5.21`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost.lua:17`
  - `rebalance=0.5.20`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintTripImmunity.lua:126`
  - `FULL_SPRINT_TRIP_IMMUNITY_0.5.20`

This violates the audit rule that active Lua / mod.info must not retain old active 0.5.19 / 0.5.20 / 0.5.21 identity strings.

## 3. File Count / Copy Scope Audit

- FILE_COUNT_0521: 43
- FILE_COUNT_0522: 50
- LUA_COUNT_0522: 32
- MARKDOWN_COUNT_0522: 12 after this audit report
- RESOURCE_COUNT_0522: 1
- LARGE_COPY_DETECTED: NO
- UNEXPECTED_FILES: NONE
- FILE_COUNT_STATUS: PASS

Added expected modules:

- XNP_DR_DraggableStatusIcon.lua: YES
- XNP_DR_ZombieVehicleImpact.lua: YES
- XNP_DR_SprintVehicleImpact.lua: YES
- XNP_DR_JogBumpLaunch.lua: YES
- XNP_DR_MinorScrapeCost.lua: YES
- XNP_DR_FallRecoveryInput.lua: YES

No 150+ file spike, no 300+ file spike, no 1000+ file pollution.

## 4. Forbidden Route Audit

- FORBIDDEN_SCAN: PASS for exact forbidden strings.
- PLAYER_COORD_WRITE: PASS, no player coordinate write calls found.
- GAMETIME_ROUTE: PASS.
- HALO_PLAYER_SAY_ROUTE: PASS.
- HEAL_ROLLBACK_ROUTE: PASS for active healing/removal routes.
- BODYDAMAGE_SCOPE: RISK.

Forbidden exact string hits:

- setVariable bumped route: none.
- direct string trait check route: none.
- old trait factory route: none.
- old bumped state route: none.
- game time multiplier route: none.
- halo/player speech route: none.
- player coordinate write route: none.

Body/scrape scope notes:

- Actual BodyDamage/Scratched calls are in `XNP_DR_
[EXCERPT_TRUNCATED]
```
