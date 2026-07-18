# 0.5.24 Sanitized Evidence Excerpts

## 0.5.24_DIRECT_DRAG_COORDINATE_MODE_FIX.md

- SHA-256: `150FB00F0F5FD15D598BF30D087BFE46B2F6C4F279D97ED2D7D8BD7D5A4E2CDF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.24 Direct Drag Coordinate Mode Fix

DIRECT_DRAG_STATUS=NO_MODIFIER_ABSOLUTE_OR_DELTA_COORDS

Config:
- icon_drag_requires_modifier=false
- icon_drag_modifier=NONE
- icon_drag_mode=DIRECT_LEFT_DRAG
- icon_drag_coordinate_mode=DELTA_FROM_DRAG_START

Implementation:
- XNP_DR_DraggableStatusIcon.lua records icon_start_x/y and mouse_start_x/y.
- Movement uses absolute mouse APIs when available.
- If absolute mouse APIs are unavailable, movement falls back to panel absolute/local offset and delta from drag start.
- User-placed position has priority over anchor placement.
- Full-screen clamp is applied during layout and move.
- Save, load, reset, red flash, shake, and color behavior are preserved.

Required logs implemented:
- [XNP STATUS ICON DRAG] coordinate_mode=DELTA_FROM_DRAG_START
- [XNP STATUS ICON DRAG] begin icon_start=... mouse_start=...
- [XNP STATUS ICON DRAG] move mouse_abs=... delta=... new=... clamp=FULL_SCREEN
- [XNP STATUS ICON DRAG] anchor_override_blocked=true reason=USER_PLACED
- [XNP STATUS ICON DRAG] full_screen_clamp=true screen=...

```

## 0.5.24_FALL_RECOVERY_RADIUS_LOCK.md

- SHA-256: `59D0AB204F47B5FE3ED29419A5345F41C45C8528AD31148E51829C898AD99A36`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.24 Fall Recovery Radius Lock

FALL_RECOVERY_STATUS=LOCAL_RADIUS_LOCKED

Implementation:
- XNP_DR_FallRecoveryInput.lua no longer calls Core.EmergencyBreakout.Update(player).
- Fall recovery uses a local selector with effect radius locked at <= 1.35.
- Maximum fall recovery targets locked at <= 3.
- Candidate scanning may look slightly wider only to reject outside targets and log large_scan_no_effect.
- The selected locked list is passed directly to recovery effects.

Required logs implemented:
- [XNP FALL RECOVERY TARGET] selector=LOCAL_LOCKED_RADIUS radius=1.35
- [XNP FALL RECOVERY TARGET] accepted zombie=... dist=... reason=CONTROLLED_OR_TOUCHING
- [XNP FALL RECOVERY TARGET] rejected zombie=... dist=... reason=OUTSIDE_RECOVERY_RADIUS
- [XNP FALL RECOVERY] old_emergency_radius=false

```

## 0.5.24_LARGE_RADIUS_EFFECT_CLEANUP.md

- SHA-256: `919061E383194653452574CBAF9DC1B6F067368D07023CB8C8ED533B36D4A486`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.24 Large Radius Effect Cleanup

RADIUS_STATUS=EFFECT_RADIUS_REDUCED

Effect radius rules:
- jog_effect_radius <= 1.35
- jog_fall_shockwave_radius <= 1.35
- fall_recovery_radius <= 1.35
- sprint_vehicle_dist_max <= 1.80
- sprint_vehicle_wall_radius <= 1.55
- skill_active_effect_radius <= 1.35

Config values in this source:
- JOG_EFFECT_RADIUS=1.25
- JOG_FALL_SHOCKWAVE_RADIUS=1.35
- FALL_RECOVERY_RADIUS=1.35
- SPRINT_VEHICLE_DIST_MAX=1.80
- SPRINT_VEHICLE_WALL_RADIUS=1.55
- SKILL_ACTIVE_EFFECT_RADIUS=1.35

Large scan policy:
- Larger values may be used only for scan/candidate detection.
- Large scan does not directly apply knockdown/shockwave/recovery effect.

Required logs implemented:
- [XNP RADIUS] mode=FALL_RECOVERY scan_radius=... effect_radius=1.35
- [XNP RADIUS] mode=JOG_FALL_SHOCKWAVE scan_radius=1.35 effect_radius=1.35
- [XNP RADIUS] large_scan_no_effect=true

```

## 0.5.24_SKILL_ACTIVE_QUOTA_RUNTIME_INTEGRATION.md

- SHA-256: `F3051E2F2A2C19069528BA574DCF77992B3DE388DECFF2020C4305E1142FE069`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.24 Skill Active Quota Runtime Integration

SKILL_ACTIVE_QUOTA_STATUS=RUNTIME_INTEGRATED

Runtime integration points:
- XNP_DR_EmergencyBreakout.lua calls Core.ImpactQuotaMeter.TrySkillActive("EMERGENCY", target.zombie, actionId) after BreakoutActionBus.Accept and before each target knockdown effect.
- XNP_DR_DragdownDangerBreakout.lua calls Core.ImpactQuotaMeter.TrySkillActive("DRAGDOWN", target.zombie, actionId) after BreakoutActionBus.Accept and before TRUE_EMERGENCY / FATAL_SURROUNDED target effects.
- XNP_DR_FallRecoveryInput.lua calls Core.ImpactQuotaMeter.TrySkillActive("FALL_RECOVERY", target.zombie, actionId) after BreakoutActionBus.Accept and before recovery effects.
- XNP_DR_JogFallShockwave.lua uses JOG_BUMP quota, not SKILL_ACTIVE, to avoid double-counting jog overflow.

Quota behavior:
- Window: 1.00 second.
- Quota: 2 SKILL_ACTIVE knockdown-class targets.
- Duplicate target: logged and not counted again.
- Blocked ActionBus action: logged as blocked_action_not_counted.
- Over quota: downgraded from KNOCKDOWN to STAGGER_ONLY / CONTACT path.

Required logs implemented:
- [XNP IMPACT QUOTA] mode=SKILL_ACTIVE source=EMERGENCY ...
- [XNP IMPACT QUOTA] mode=SKILL_ACTIVE source=DRAGDOWN ...
- [XNP IMPACT QUOTA] mode=SKILL_ACTIVE source=FALL_RECOVERY ...
- [XNP SKILL ACTIVE QUOTA] downgrade target=... from=KNOCKDOWN to=STAGGER_ONLY reason=QUOTA_EXCEEDED
- [XNP SKILL ACTIVE QUOTA] duplicate_target_skip target=...
- [XNP SKILL ACTIVE QUOTA] blocked_action_not_counted action_id=...

```

## 0.5.24_TEST_PLAN.md

- SHA-256: `D0F06FA42EFCF6DD29744E9EF227795633199968A763885741458D9C3A3B88EE`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.24 Test Plan

Install manually by copying this SOURCE to the user's test mods location. Do not overwrite old versions.

Required checks:
1. Confirm console contains XNP_PZ_DISTANCE_TRAIT_0524_SKILL_QUOTA_DRAG_RECOVERY_FIX_A.
2. Confirm Config loaded log appears.
3. Trigger EmergencyBreakout against more than two close zombies. Expected: first two SKILL_ACTIVE knockdowns allowed, later targets downgraded with SKILL_ACTIVE_QUOTA logs.
4. Trigger DragdownDangerBreakout TRUE_EMERGENCY / FATAL_SURROUNDED. Expected: DRAGDOWN quota logs and no unlimited knockdown burst.
5. Trigger FallRecovery input after jog overflow or wall crash. Expected: LOCAL_LOCKED_RADIUS selector, max 3 targets, old_emergency_radius=false.
6. Drag the status icon without Ctrl/Alt. Expected: begin/move/end logs with coordinate_mode=DELTA_FROM_DRAG_START and full-screen clamp.
7. Verify icon red flash, shake, and color remain visible.
8. Verify jog behavior remains no-kill, quota-limited, overflow trip capable.
9. Verify sprint vehicle light/wall behavior remains quota and wall-threshold based.

Failure indicators:
- SKILL_ACTIVE knockdown count exceeds 2 in 1 second.
- FallRecovery logs old EmergencyBreakout selection or affects remote zombies beyond 1.35.
- Drag requires Ctrl/Alt.
- User-placed icon snaps back to anchor.
- Any write to player coordinate, GameTime multiplier, HaloTextHelper, or player:Say route appears.

```

## BUILD_MARKER.txt

- SHA-256: `409D1CE6F5CBB8EEACE545EEA130FF81F721B5C8A21ECCA03AA4C86A293BBFED`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0524_SKILL_QUOTA_DRAG_RECOVERY_FIX_A

```

## FINAL_REPORT.md

- SHA-256: `F73758DFF453822F07DE1C7201C7F2681F1FB3EA925ED2032029FA23AC25FE0F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.24 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.24
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0524_SKILL_QUOTA_DRAG_RECOVERY_FIX_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.24 Skill Quota Drag Recovery Fix

Created as independent SOURCE under [LOCAL_PATH_REDACTED]

File counts:
- Lua files: 34
- Lua total lines: 7095
- Markdown files: 8
- Total files: 49

Changed runtime files:
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakout.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_JogFallShockwave.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DraggableStatusIcon.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintTripImmunity.lua

Status:
- SKILL_ACTIVE_QUOTA_STATUS=RUNTIME_INTEGRATED
- DIRECT_DRAG_STATUS=NO_MODIFIER_ABSOLUTE_OR_DELTA_COORDS
- FALL_RECOVERY_STATUS=LOCAL_RADIUS_LOCKED
- RADIUS_STATUS=EFFECT_RADIUS_REDUCED
- ICON_RED_FLASH_STATUS=PRESERVED
- JOG_STATUS=PRESERVED
- SPRINT_STATUS=PRESERVED
- NO_BITE_NO_INFECTION_NO_HEAL=PRESERVED

Not performed:
- Project Zomboid not launched
- Steam not launched
- User mods not written
- Saves not written
- Workshop not written
- Game install directory not written
- Old SOURCE directories not modified
- No package/install step

NOT_VERIFIABLE_BY_STATIC_AUDIT:
- Lua interpreter syntax execution: NOT_VERIFIABLE, no local lua/luac command available
- Real-game quota timing and zombie animation outcome
- Real-game icon drag exact mouse coordinate behavior
- Real-game fall recovery feel and target selection

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.24_SOURCE_READY_FOR_SKILL_QUOTA_FIX_TEST

```

## 0.5.24_REAL_GAME_AUDIT_FIX_FROM_0.5.23.md

- SHA-256: `EC5984679B97C6E9F7CE82EEABC2EE8EE87A0E98711342170BCB94B64B25ED6B`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.24 Real Game Audit Fix From 0.5.23

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.24
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0524_SKILL_QUOTA_DRAG_RECOVERY_FIX_A

0.5.23 blocker fixed in this source:
- SKILL_ACTIVE_QUOTA_NOT_INTEGRATED
- Direct drag coordinate ambiguity
- FallRecovery old emergency radius reuse
- Large effect radius cleanup

Status:
- SKILL_ACTIVE_QUOTA_STATUS=RUNTIME_INTEGRATED
- DIRECT_DRAG_STATUS=NO_MODIFIER_ABSOLUTE_OR_DELTA_COORDS
- FALL_RECOVERY_STATUS=LOCAL_RADIUS_LOCKED
- RADIUS_STATUS=EFFECT_RADIUS_REDUCED
- ICON_RED_FLASH_STATUS=PRESERVED
- JOG_STATUS=PRESERVED
- SPRINT_STATUS=PRESERVED
- NO_BITE_NO_INFECTION_NO_HEAL=PRESERVED

No game launch, no Steam launch, no user mods write, no save write, no Workshop write, no old SOURCE modification.

```

## 0.5.24_SECOND_PASS_AUDIT.md

- SHA-256: `D39F3072C79E7283A469C01E0067740C5769FBBD0FECC550B92A2A396A48DAD3`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.24 Second Pass Audit

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]
AUDIT_MODE=READ_ONLY_RUNTIME_SOURCE_AUDIT
AUDIT_FILE_WRITTEN=0.5.24_SECOND_PASS_AUDIT.md

Restrictions observed:
- Project Zomboid not launched.
- Steam not launched.
- User mods, saves, Workshop, and game directory not written.
- Old SOURCE directories not modified.
- No package/install step.
- No runtime code changes made during this second pass audit.

## 1. Version And File Count

SOURCE_EXISTS=YES
BUILD_MARKER_OK=YES
DISPLAY_NAME_OK=YES
READY_MARKER_PRESENT=YES
VERSION_FILE_STATUS=PASS

Expected:
- VERSION=0.5.24
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0524_SKILL_QUOTA_DRAG_RECOVERY_FIX_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.24 Skill Quota Drag Recovery Fix
- READY=XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.24_SOURCE_READY_FOR_SKILL_QUOTA_FIX_TEST

Observed:
- BUILD_MARKER.txt contains expected marker.
- mod.info contains expected name and version.
- 42\mod.info contains expected name and version.
- Active Lua contains expected 0.5.24 build marker in XNP_DR_Constants.lua.

OLD_ACTIVE_RESIDUE=PASS
- No active Lua / mod.info / BUILD_MARKER residue found for 0.5.20/0520, 0.5.21/0521, 0.5.22/0522, 0.5.23/0523, or DIRECT_DRAG_IMPACT_QUOTA.
- 0.5.23 appears only in Markdown audit-history text.

FILE_COUNT_0523=53
FILE_COUNT_0524=49
LUA_COUNT_0524=34
LUA_LINES_0524=7095
MARKDOWN_COUNT_0524=9
LARGE_COPY_DETECTED=NO

## 2. SKILL_ACTIVE Quota

SKILL_ACTIVE_CONFIG=PASS
- SKILL_ACTIVE_QUOTA_WINDOW=1.00
- SKILL_ACTIVE_KNOCKDOWN_QUOTA=2
- skill_active_quota_window=1.00
- skill_active_knockdown_quota=2

SKILL_ACTIVE_METER=PASS
- XNP_DR_ImpactQuotaMeter.lua defines SKILL_ACTIVE window state via ensure("SKILL_ACTIVE", window).
- TrySkillActive(source, zombie, actionId) exists.
- Logs include [XNP IMPACT QUOTA] mode=SKILL_ACTIVE with source, used, quota, window, target, result.

SKILL_ACTIVE_RUNTIME_CALLER=PASS
CALLER_FILES:
- XNP_DR_EmergencyBreakout.lua
- XNP_DR_DragdownDangerBreakout.lua
- XNP_DR_FallRecoveryInput.lua

EMERGENCY_QUOTA=PASS
- Core.ImpactQuotaMeter.TrySkillActive("EMERGENCY", target.zombie, actionId) is called after BreakoutActionBus.Accept and before VerifiedStaggerControl.Apply.

DRAGDOWN_QUOTA=PASS
- Core.ImpactQuotaMeter.TrySkillActive("DRAGDOWN", target.zombie, actionId) is called after BreakoutActionBus.Accept and before VerifiedStaggerControl.Apply.

FALL_RECOVERY_QUOTA=PASS
- Core.ImpactQuotaMeter.TrySkillActive("FALL_RECOVERY", target.zombie, actionId) is called after BreakoutActionBus.Accept and before VerifiedStaggerControl.Apply.

ACTION_ACCEPTED_ONLY=PASS
- TrySkillActive refuses nil/false actionId and logs blocked_action_not_counted.
- FallRecovery logs blocked_action_not_counted when ActionBus rejects.
- Emergency and Dragdown return before quota when CanStart rejects.

DUPLICATE_TARGET_PROTECTION=PASS
- TrySkillActive checks data.keys[targetKey] and logs duplicate_target_skip.
- Duplicate target returns without incrementing used.

OVER_QUOTA_DOWNGRADE=PASS
- Over quota
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `1C4A871F6D4EEFAE64BFB3B0F5BFB0088E1A872AE1DD217D4F53D8409FF80846`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.24 Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.24
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0524_SKILL_QUOTA_DRAG_RECOVERY_FIX_A

Static audit scope:
- Lua source text scan
- mod.info identity scan
- required runtime call-site scan
- large radius configuration scan
- forbidden route scan

File counts:
- Lua files: 34
- Lua total lines: 7095
- Markdown files: 8
- Total files: 49

Implemented checks:
- SKILL_ACTIVE_QUOTA_STATUS=RUNTIME_INTEGRATED
- DIRECT_DRAG_STATUS=NO_MODIFIER_ABSOLUTE_OR_DELTA_COORDS
- FALL_RECOVERY_STATUS=LOCAL_RADIUS_LOCKED
- RADIUS_STATUS=EFFECT_RADIUS_REDUCED
- ICON_RED_FLASH_STATUS=PRESERVED
- JOG_STATUS=PRESERVED
- SPRINT_STATUS=PRESERVED
- NO_BITE_NO_INFECTION_NO_HEAL=PRESERVED

Forbidden route status:
- player coordinate write: PASS for player-side writes. Zombie-side setX/setY remains only in BreakoutPush micro-nudge fallback.
- GameTime:setMultiplier: PASS
- HaloTextHelper: PASS
- player:Say: PASS
- player:hasTrait: PASS
- TraitFactory: PASS
- CharacterTraitDefinition: PASS
- RunningShove: PASS
- BumpedState: PASS

Runtime call-site status:
- EmergencyBreakout SKILL_ACTIVE quota: PRESENT
- DragdownDangerBreakout SKILL_ACTIVE quota: PRESENT
- FallRecoveryInput SKILL_ACTIVE quota: PRESENT
- JogFallShockwave JOG_BUMP quota: PRESENT
- Direct drag coordinate mode log: PRESENT
- FallRecovery local locked selector log: PRESENT

NOT_VERIFIABLE_BY_STATIC_AUDIT:
- Lua interpreter syntax execution: NOT_VERIFIABLE, no local lua/luac command available
- In-game zombie reaction success
- In-game drag coordinate API exact mouse source
- Player feel / balance
- Multiplayer behavior

BLOCKER=NONE_STATIC

```
