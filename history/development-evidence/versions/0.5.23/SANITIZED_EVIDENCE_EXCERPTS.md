# 0.5.23 Sanitized Evidence Excerpts

## 0.5.23_AREA_RADIUS_REDUCTION.md

- SHA-256: `B88CC637EC422FEE03CB1D94C9E7ADE9FE99C9780EC6CF21C06312027170C19F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Area Radius Reduction

Radius values:

- jog_effect_radius=1.25
- jog_fall_shockwave_radius=1.35
- sprint_vehicle_dist_max=1.80
- sprint_vehicle_wall_radius=1.55
- fall_recovery_radius=1.35
- emergency_control_radius=1.35

Primary kill/knockdown radii no longer use 2.10 / 2.35 / 1.75.

```

## 0.5.23_DIRECT_MOUSE_DRAG_ICON_DESIGN.md

- SHA-256: `365EAE6E529142FC163D090057ED33812184411DF416BF1564565AE6926F4C5A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Direct Mouse Drag Icon Design

Module:

- XNP_DR_DraggableStatusIcon.lua

Rules:

- Direct left mouse drag on the icon rectangle.
- No Ctrl.
- No Alt.
- No long-press fallback.
- User position takes priority over anchor/slot layout.
- Full-screen clamp: `0 <= x <= screenW-iconW`, `0 <= y <= screenH-iconH`.
- Position saves to player moddata.
- Right click resets to default.

Preserved:

- texture
- border
- shake
- color
- red skill flash
- single status icon
- fallback text main UI disabled

Expected logs:

- [XNP STATUS ICON DRAG] enabled=true input=DIRECT_LEFT_DRAG
- [XNP STATUS ICON DRAG] hit_test=true
- [XNP STATUS ICON DRAG] begin
- [XNP STATUS ICON DRAG] move clamp=FULL_SCREEN
- [XNP STATUS ICON DRAG] end
- [XNP STATUS ICON DRAG] loaded
- [XNP STATUS ICON DRAG] reset_to_default
- [XNP STATUS ICON DRAG] user_position_priority=true
- [XNP STATUS ICON DRAG] anchor_override_blocked=true reason=USER_PLACED

```

## 0.5.23_FALL_RECOVERY_AFTER_OVERFLOW.md

- SHA-256: `70985AE8AD5B0BD167DEEF11C2BE2FF2431CFE807D0F20672F2E4B901B71CB90`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Fall Recovery After Overflow

Module:

- XNP_DR_FallRecoveryInput.lua

Classes:

- JOG_OVERFLOW_TRIP: cancel_allowed=false, recovery_input=true.
- SPRINT_OVERFLOW_WALL_CRASH: cancel_allowed=false, recovery_input=true.
- CONTROLLED_AFTER_FALL: cancel_allowed=true, recovery_input=true.

Rules:

- Design falls are not immediately cancelled by SprintTripCancel.
- If controlled after fall, RUN_OR_SPRINT can trigger recovery.
- Recovery does not heal or roll back damage.

Expected logs:

- [XNP FALL CLASSIFY] type=JOG_OVERFLOW_TRIP cancel_allowed=false recovery_input=true
- [XNP FALL CLASSIFY] type=SPRINT_OVERFLOW_WALL_CRASH cancel_allowed=false recovery_input=true
- [XNP FALL RECOVERY] input=RUN_OR_SPRINT result=BREAKOUT_APPLIED
- [XNP FALL RECOVERY COST] cost=...

```

## 0.5.23_IMPACT_QUOTA_METER_DESIGN.md

- SHA-256: `8C095AAE2124976E3CD15114749243890EDFA845C865CAD2E77A5EC4E789523D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Impact Quota Meter Design

Module:

- XNP_DR_ImpactQuotaMeter.lua

Modes:

- SKILL_ACTIVE: 2 knockdowns per 1 second.
- JOG_BUMP: 3 impacts per 1 second, then overflow trip.
- SPRINT_VEHICLE: 1 target per 0.30 seconds, then wall crash.

Rules:

- Counts only after ActionBus accepted.
- Same zombie key is not counted twice inside the same window.
- Plain movement does not enter quota.

Expected logs:

- [XNP IMPACT QUOTA] mode=SKILL_ACTIVE
- [XNP IMPACT QUOTA] mode=JOG_BUMP
- [XNP IMPACT QUOTA] mode=SPRINT_VEHICLE
- [XNP IMPACT QUOTA SUMMARY]

```

## 0.5.23_JOG_BUMP_OVERFLOW_TRIP_AND_SHOCKWAVE.md

- SHA-256: `E5ED9F6FC69A9F7DCC163EBCB35B1F7DDC3A1777B4348ADED8D19AF51D1A6EA9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Jog Bump Overflow Trip And Shockwave

Modules:

- XNP_DR_JogBumpLaunch.lua
- XNP_DR_JogFallShockwave.lua
- XNP_DR_FallRecoveryInput.lua

Rules:

- Jog can stagger, knockdown, or launch zombies.
- Jog never kills zombies.
- Jog quota is 3 targets per 1 second.
- Overflow causes JOG_OVERFLOW_TRIP.
- Overflow trip triggers shockwave with radius 1.35.
- Shockwave uses knockdown/stun style control and does not kill.
- Recovery input is RUN_OR_SPRINT.

Radius:

- jog_effect_radius=1.25
- jog_fall_shockwave_radius=1.35

Expected logs:

- [XNP JOG BUMP] trigger
- [XNP JOG BUMP] effect=STAGGER_ONLY/JOG_KNOCKDOWN/JOG_LAUNCH
- [XNP JOG OVERFLOW] result=PLAYER_TRIP reason=QUOTA_EXCEEDED
- [XNP JOG FALL SHOCKWAVE] targets=... radius=1.35 effect=KNOCKDOWN_STUN
- [XNP JOG RECOVERY] input=RUN_OR_SPRINT result=CONTROL_BREAKOUT_APPLIED

```

## 0.5.23_MINOR_SCRAPE_NON_ARTERY_SAFETY.md

- SHA-256: `5A4BB258594FA7D3AB029A213FEC721F0DF9B160D1D69BF1DF8671FF2818AAB2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Minor Scrape Non-Artery Safety

Module:

- XNP_DR_MinorScrapeCost.lua

Rules:

- Only minor scrape.
- Only safe non-artery parts are attempted.
- No Neck.
- No Head.
- No Groin.
- No UpperLeg.
- No bite.
- No infection.
- No heal.
- No rollback.
- No deep wound.
- No fracture.
- No heavy bleeding.
- pcall protected.
- fallback skip if API is unavailable.

Expected logs:

- [XNP SCRAPE] type=MINOR_SCRAPE source=VEHICLE_WALL_CRASH body_part=... no_artery=true result=APPLIED
- [XNP SCRAPE] no_bite=true no_infection=true no_heal=true
- [XNP SCRAPE FAIL] reason=NO_SAFE_BODY_PART_API fallback=SKIP

```

## 0.5.23_SPRINT_VEHICLE_IMPACT_QUOTA_WALL_CRASH.md

- SHA-256: `3195A1C6DDAAB1F07E5E9B7E8CBE22635BC5BBAB743FC00586369E0393425C74`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Sprint Vehicle Impact Quota Wall Crash

Modules:

- XNP_DR_SprintVehicleImpact.lua
- XNP_DR_ZombieVehicleImpact.lua
- XNP_DR_ImpactQuotaMeter.lua
- XNP_DR_MinorScrapeCost.lua
- XNP_DR_FallRecoveryInput.lua

Rules:

- Requires full sprint.
- Requires speed >= 3.50.
- Requires front arc, distance, dot, and closing frames.
- dist_max=1.80.
- dot_min=0.60.
- primary_dot_min=0.72.
- Light mode handles 1-2 front blockers.
- Wall crash handles 3+ front blockers or sprint quota overflow.
- Light mode kills up to 2 targets and player stays up.
- Wall crash kills up to 5 blockers, forces player fall, and applies 100% minor scrape attempt.
- No remote kill.
- No full-screen kill.

Expected logs:

- [XNP VEHICLE IMPACT] mode=LIGHT blocker_count=... result=APPLIED
- [XNP VEHICLE IMPACT] mode=WALL_CRASH blocker_count=3 result=APPLIED
- [XNP VEHICLE IMPACT ZOMBIE] death_result=ok/fallback_knockdown method=...
- [XNP VEHICLE IMPACT PLAYER] result=STAY_UP mode=LIGHT
- [XNP VEHICLE IMPACT PLAYER] result=FORCED_FALL mode=WALL_CRASH
- [XNP FALL CLASSIFY] type=SPRINT_OVERFLOW_WALL_CRASH cancel_allowed=false recovery_input=true
- [XNP VEHICLE IMPACT COST] type=LIGHT/WALL_CRASH

```

## 0.5.23_TEST_PLAN.md

- SHA-256: `CD45CCC14462169C00423266E9266FA6A6627621F76DDDCE132B42A749B9F196`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.23 Test Plan

1. Confirm marker:
   - XNP_PZ_DISTANCE_TRAIT_0523_DIRECT_DRAG_IMPACT_QUOTA_A

2. Direct drag:
   - Left-drag the status icon with no modifier key.
   - Confirm free movement across screen.
   - Release and confirm save.
   - Re-enter and confirm load.
   - Right-click and confirm reset.
   - Confirm red flash, shake, color, border, and texture remain.

3. Jog:
   - Jog into front zombies.
   - Confirm up to 3 per second.
   - Confirm overflow trip and shockwave.
   - Confirm no zombie death.
   - Confirm RUN_OR_SPRINT recovery.

4. Sprint:
   - Sprint into 1-2 blockers.
   - Confirm light vehicle impact, zombie death/fallback, player stay up.
   - Sprint into 3+ blockers.
   - Confirm wall crash, forced fall, blocker death/fallback, minor scrape.

5. Safety:
   - Confirm no remote kill.
   - Confirm no player coordinate write.
   - Confirm no healing or rollback.

```

## BUILD_MARKER.txt

- SHA-256: `2100436DA768E9F4CEEE02D2549D773D90533218FD25EA98A440B9A6348A8FD8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0523_DIRECT_DRAG_IMPACT_QUOTA_A

```

## FINAL_REPORT.md

- SHA-256: `0E9C63E58546B462A5A6AC37834BE71EEEEA5DE48F40CB415C5B8175F3159B4D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.23
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0523_DIRECT_DRAG_IMPACT_QUOTA_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.23 Direct Drag Impact Quota

Changed files:

- BUILD_MARKER.txt
- mod.info
- 42/mod.info
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintTripImmunity.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DraggableStatusIcon.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_JogBumpLaunch.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_JogFallShockwave.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintVehicleImpact.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ZombieVehicleImpact.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_MinorScrapeCost.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput.lua
- 0.5.23 documentation set
- STATIC_AUDIT.md
- FINAL_REPORT.md

0.5.22 audit blocker fixes:

- old active residue: FIXED
- vehicle ActionBus: FIXED
- per-target cooldown: FIXED
- long-press fallback: REMOVED_BY_CONFIG

Direct Drag Icon:

- direct mouse drag: YES
- requires Ctrl/Alt: NO
- full screen clamp: YES
- save/load: YES
- reset: YES
- red flash/shake/color: YES

Impact Quota:

- runtime: YES
- skill 2/sec: YES
- jog 3/sec: YES
- sprint 0.3 sec/target: YES
- overflow fall: YES

Jog:

- no zombie kill: YES
- overflow shockwave: YES
- player fall recovery: YES
- radius: jog_effect_radius=1.25, jog_fall_shockwave_radius=1.35

Sprint Vehicle:

- light kills: YES_WITH_RUNTIME_API_RISK
- wall threshold 3: YES
- wall kills blockers: YES_WITH_RUNTIME_API_RISK
- forced fall: YES
- minor scrape: YES_WITH_RUNTIME_API_RISK
- no remote kill: YES
- full sprint required: YES

Minor Scrape:

- non-artery safe parts: YES
- no bite/no infection/no heal: YES
- pcall/fallback: YES

Radius values:

- jog_effect_radius=1.25
- jog_fall_shockwave_radius=1.35
- sprint_vehicle_dist_max=1.80
- sprint_vehicle_wall_radius=1.55
- fall_recovery_radius=1.35
- emergency_control_radius=1.35

Forbidden grep:

- exact forbidden hits: 0
- old active version residue: 0
- player coordinate write: 0
- BodyDamage/Scratch write scope: XNP_DR_MinorScrapeCost.lua only

Safety:

- old SOURCE modified: NO
- Project Zomboid launched: NO
- Steam launched: NO
- user mods written: NO
- saves written: NO
- Workshop written: NO
- game directory written: NO
- packaging/install action: NO

BLOCKER=NONE_STATIC

XNP_PZ_D
[EXCERPT_TRUNCATED]
```

## 0.5.23_REAL_GAME_DESIGN_UPDATE_FROM_0.5.22_AUDIT.md

- SHA-256: `88F2D8073F94D4CC9D0A121F6D106EB0B1C6C89D25006BDF4801180A9444A1D8`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Real Game Design Update From 0.5.22 Audit

VERSION=0.5.23
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0523_DIRECT_DRAG_IMPACT_QUOTA_A

0.5.22 audit blockers addressed in this SOURCE:

- old active residue: fixed in active Lua strings.
- vehicle ActionBus: SprintVehicleImpact calls BreakoutActionBus CanStart and Accept.
- per-target cooldown: ZombieVehicleImpact has RegisterVehicleHitCooldown and OnCooldown.
- long-press fallback: disabled; direct mouse drag is the only supported mode.

Feature status:

- ICON_FEATURE_STATUS=DIRECT_MOUSE_DRAG_PERSISTENT_POSITION
- ICON_RED_FLASH_STATUS=PRESERVED
- ICON_SHAKE_STATUS=PRESERVED
- ICON_COLOR_STATUS=PRESERVED
- JOG_STATUS=QUOTA_3_PER_SECOND_OVERFLOW_TRIP_SHOCKWAVE
- SPRINT_STATUS=VEHICLE_IMPACT_0_3_SECOND_QUOTA_WALL_CRASH
- SCRAPE_STATUS=NON_ARTERY_MINOR_SCRAPE_ONLY
- GRAB_ESCAPE_STATUS=PRESERVED
- NO_BITE_NO_INFECTION_NO_HEAL=PRESERVED

Runtime validation remains required by user.

```

## 0.5.23_SECOND_PASS_AUDIT.md

- SHA-256: `A77CB07EFBB72044331F2D54A0B9B05CA82D5EA58C855E0F4E0CD9947D218FEA`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.23 Second Pass Audit

## 1. Executive Summary

Audited SOURCE:

`[LOCAL_PATH_REDACTED]`

This was an audit pass only. No runtime code was modified. Project Zomboid, Steam, user mods, saves, Workshop, and game install directories were not touched.

Final status:

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.23_SECOND_PASS_AUDIT_BLOCKED_NOT_READY`

Primary reason:

- BLOCKER: `SKILL_ACTIVE` quota is defined in `XNP_DR_ImpactQuotaMeter.lua` and config, but no active runtime module calls `ImpactQuotaMeter.Try("SKILL_ACTIVE", ...)`. The 2/sec skill-active quota is therefore not integrated.

Secondary risks:

- Direct drag uses panel-local mouse coordinates. Free full-screen movement is plausible but not statically proven.
- Fall recovery delegates to existing `EmergencyBreakout`, which still uses old 1.45 / 1.75 radius settings in active code.
- Zombie death and minor scrape APIs remain runtime-verification risks, though both are pcall/fallback protected.

## 2. Version / File Count Audit

- SOURCE_EXISTS: YES
- BUILD_MARKER_OK: YES
- DISPLAY_NAME_OK: YES
- OLD_ACTIVE_RESIDUE: PASS
- VERSION_FILE_STATUS: PASS

Counts:

- FILE_COUNT_0521: 43
- FILE_COUNT_0522: 51
- FILE_COUNT_0523: 52
- LUA_COUNT_0523: 34
- MARKDOWN_COUNT_0523: 12 after this audit report
- RESOURCE_COUNT_0523: 1
- LARGE_COPY_DETECTED: NO

Active runtime marker checks:

- Expected marker found in active Lua: YES
- `0.5.20` active residue: 0
- `0.5.21` active residue: 0
- `0.5.22` active residue: 0
- `0520` active residue: 0
- `0521` active residue: 0
- `0522` active residue: 0

## 3. Forbidden Route Audit

- FORBIDDEN_SCAN: PASS
- PLAYER_COORD_WRITE: PASS
- HEAL_ROLLBACK_ROUTE: PASS
- BODYDAMAGE_SCOPE: PASS_WITH_RUNTIME_RISK

Exact forbidden active-route findings:

- bumped variable route: none.
- direct string trait check route: none.
- old trait factory route: none.
- old bumped state route: none.
- game-time multiplier route: none.
- halo/player speech route: none.
- player coordinate write route: none.
- all-zombie/full-map kill route: none.

Notes:

- The phrase `remote kill` appears only in documentation/report lines describing a prohibition, not in active Lua logic.
- `BodyDamage` and scratch application are active only in `XNP_DR_MinorScrapeCost.lua`.
- Bite/infection/heal strings appear in logging and detection text, not in healing or rollback routes.

## 4. Direct Drag Icon Audit

- DIRECT_DRAG_RUNTIME: YES
- REQUIRES_CTRL_ALT: NO
- HIT_TEST_ICON_ONLY: YES, mouse handlers are on the icon panel.
- FULL_SCREEN_CLAMP: YES
- USER_POSITION_PRIORITY: YES
- SAVE_LOAD: YES
- RESET: YES
- RED_FLASH_PRESERVED: YES
- SHAKE_COLOR_PRESERVED: YES
- DRAGGABLE_ICON_STATUS: RISK

Evidence:

- `XNP_DR_DraggableStatusIcon.lua` exists.
- `XNP_DR_StatusIconUI.lua` requires it and calls `LayoutOverride`.
- Panel handlers exist: `onMouseDown`, `onMouseMove`, `onMouseUp`, `onRightMouseUp`.
- Config has:
  - `ICON_DRAG_MODE = "DIRECT_LEFT_DRAG"`
  - `ICON_DRAG_REQUIRES_MODIFIER = false`
  - `ICON_DRAG_MODI
[EXCERPT_TRUNCATED]
```
