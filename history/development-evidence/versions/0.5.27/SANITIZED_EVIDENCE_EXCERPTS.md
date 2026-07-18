# 0.5.27 Sanitized Evidence Excerpts

## 0.5.27_LONG_MIGRATION_STAMINA_ASSIST_DESIGN.md

- SHA-256: `A8FFFA46B833BA65C91E7C2A4A92924424784D64C42AF414862EC88015E025E9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.27 Long Migration Stamina Assist Design

Runtime module:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist.lua`

Public functions:

- `GetEndurance(player)`
- `SetEnduranceSafe(player, value, reason)`
- `GetHunger(player)`
- `SetHungerSafe(player, value, reason)`
- `GetFatigue(player)`
- `GetRunningState(player)`
- `GetStatus(player)`
- `Tick(player)`
- `Cleanup(reason)`

State model:

- `GREEN_READY`: high endurance, no hunger conversion.
- `BLUE_CRUISE`: jogging/moving with medium endurance, small endurance support.
- `YELLOW_METABOLIC`: low endurance with available food reserve, capped hunger-to-endurance conversion.
- `RED_GUARD`: very low endurance or hunger guard, conversion reduced or stopped.
- `METABOLIC_RESERVE_ACTIVE`: represented by `YELLOW_METABOLIC` with `metabolicActive=true`.
- `METABOLIC_STARVATION_GUARD`: represented by `RED_GUARD` with `guard=true`.

Safety rules:

- Every endurance and hunger write is wrapped by pcall via safe stat helpers.
- The module never writes player coordinates.
- The module never clears fatigue, pain, wounds, bites, infections, or damage.
- The module never restores full stamina directly.
- The module skips support during attacks, aiming, vehicle state, dead state, or missing trait.
- Sprint support is limited by `SPRINT_ASSIST_ONLY_ABOVE_ENDURANCE`.

Tick budget:

- `LONG_MIGRATION_TICK_INTERVAL_FRAMES=15`
- No per-frame endurance or hunger writes.
- Summary log interval defaults to 120 frames.

```

## 0.5.27_METABOLIC_RESERVE_DESIGN.md

- SHA-256: `446FA4500DE15B4F23F172007D476113EF68648BD144A290C353A988B4B65B7E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.27 Metabolic Reserve Design

Goal:

Use hunger as a capped reserve for small endurance support during long movement, without starvation abuse or damage rollback.

Configuration:

- `METABOLIC_RESERVE_ENABLED=true`
- `METABOLIC_TRIGGER_ENDURANCE=0.35`
- `METABOLIC_STRONG_TRIGGER_ENDURANCE=0.20`
- `METABOLIC_ENDURANCE_RESTORE_PER_TICK=0.0035`
- `METABOLIC_ENDURANCE_RESTORE_PER_TICK_STRONG=0.0050`
- `METABOLIC_HUNGER_COST_PER_TICK=0.0018`
- `METABOLIC_HUNGER_COST_PER_TICK_STRONG=0.0028`
- `METABOLIC_MAX_HUNGER_COST_PER_MINUTE=0.08`
- `METABOLIC_SOFT_GUARD_HUNGER=0.62`
- `METABOLIC_STARVATION_GUARD_HUNGER=0.78`

Guard behavior:

- Above soft guard, conversion is reduced.
- Above starvation guard, conversion stops.
- If the per-minute hunger cap is reached, conversion stops.
- Low endurance is allowed to remain low; no infinite sprint or full reset is provided.

Runtime logging:

- `[XNP METABOLIC RESERVE] active=true`
- `[XNP METABOLIC RESERVE] guard=true`
- `[XNP STAMINA ASSIST SUMMARY] ...`

Explicit non-goals:

- No healing.
- No bite rollback.
- No infection rollback.
- No fatigue or pain clearing.
- No direct body damage writes.

```

## 0.5.27_PERFORMANCE_CLEANUP.md

- SHA-256: `5FAEC40822AD53BA06C97362F43C1165301F87AB6B4BD7716E0A37B43D1C09E7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.27 Performance Cleanup

Added modules:

- `XNP_DR_Log.lua`
- `XNP_DR_PerformanceBudget.lua`
- `XNP_DR_NearbyZombieCache.lua`

Runtime behavior:

- Performance budget updates once per player update.
- Long migration stamina assist runs every 15 frames.
- Stamina icon colors are state driven and avoid per-frame state spam.
- Nearby zombie cache scans every 10 frames and keeps a 12-frame TTL.
- Long migration stamina assist does not scan zombies.

Startup logs:

- `[XNP PERFORMANCE] mode=RELEASE verbose=false`
- `[XNP PERFORMANCE] per_frame_print=false`
- `[XNP PERFORMANCE] stamina_tick_interval=15 ui_tick_interval=10 zombie_cache_ttl=12`
- `[XNP NEARBY CACHE] enabled=true ttl_frames=12 shared=true`
- `[XNP LOG] summary_interval_frames=120`

Known scope:

The shared cache is now available and warmed by Runtime. Existing 0.5.26 combat modules keep their original logic for behavior preservation.

```

## 0.5.27_PRESERVE_0.5.26_CORE_MECHANICS.md

- SHA-256: `C794781266FCE325A8BEF3A26FBC0DFC361299572EED917FC93458C21FF6DA8D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.27 Preserve 0.5.26 Core Mechanics

Preserved modules:

- `XNP_DR_MovementIntentGate.lua`
- `XNP_DR_JogBumpLaunch.lua`
- `XNP_DR_SprintVehicleImpact.lua`
- `XNP_DR_FallRecoveryInput.lua`
- `XNP_DR_DragdownDangerBreakout.lua`
- `XNP_DR_EmergencyBreakout.lua`
- `XNP_DR_StatusIconUI.lua`
- `XNP_DR_DraggableStatusIcon.lua`

Preserved config:

- `WALK_NO_IMPACT_ENABLED=true`
- `WALK_BLOCKS_CONTACT=true`
- `WALK_BLOCKS_JOG_BUMP=true`
- `WALK_BLOCKS_BREAKOUT_CONTACT=true`
- `WALK_BLOCKS_VEHICLE_IMPACT=true`
- `CONTROLLED_ESCAPE_ENABLED=true`
- `CONTROLLED_ESCAPE_REQUIRES_RUN_OR_SPRINT_INPUT=true`
- `PRESERVE_JOG_BUMP_WHEN_JOGGING=true`
- `PRESERVE_SPRINT_VEHICLE_IMPACT=true`
- `PRESERVE_NATIVE_TRIP_WINDOW=true`
- `PRESERVE_DRAG_CAPTURE_ICON=true`

Explicitly not added:

- No coordinate writes.
- No time multiplier.
- No player bumped variable writes.
- No `player:hasTrait(string)`.
- No damage rollback or healing.
- No infection or bite rollback.

```

## 0.5.27_REAL_GAME_TUNING_FROM_0.5.26.md

- SHA-256: `F0123C0D74681E2C21EFB498F7F85969CDE07E6E8FE48BD354B1691015140A7E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.27 Real Game Tuning From 0.5.26

0.5.27 keeps the 0.5.26 gameplay baseline and adds long migration stamina assist only.

Preserved 0.5.26 results:

- Walking does not trigger active impact routes.
- Controlled jog escape remains available when grabbed or controlled.
- Jog bump behavior remains active only for jog/run intent.
- Sprint vehicle impact remains active.
- Native trip window and sprint consequence remain active.
- Drag capture icon, tooltip, red flash, shake, and color priority remain active.
- No bite, infection, wound, damage rollback, or healing route is added.

0.5.27 tuning target:

- Improve long migration comfort without infinite stamina.
- Convert a capped hunger reserve into small endurance support only when endurance is low.
- Preserve red danger icon priority and draggable icon behavior.
- Reduce log and scan pressure for release testing.

Build marker:

`XNP_PZ_DISTANCE_TRAIT_0527_LONG_MIGRATION_STAMINA_ASSIST_A`

```

## 0.5.27_STAMINA_ICON_COLOR_STATES.md

- SHA-256: `1A71FA228475F3472765EAD40F28A33D689B9BB680C5F631BA1102968F0BA14C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.27 Stamina Icon Color States

Icon priority:

1. Existing danger, emergency, sprint impact, and red flash states.
2. `STAMINA_RED_GUARD`
3. `STAMINA_YELLOW_METABOLIC`
4. `STAMINA_BLUE_CRUISE`
5. `STAMINA_GREEN_READY`
6. Existing default ready state.

Color logs:

- `[XNP STAMINA ICON] state=GREEN_READY color=green reason=ENDURANCE_HIGH`
- `[XNP STAMINA ICON] state=BLUE_CRUISE color=blue reason=JOG_ASSIST`
- `[XNP STAMINA ICON] state=YELLOW_METABOLIC color=yellow reason=HUNGER_TO_ENDURANCE`
- `[XNP STAMINA ICON] state=RED_GUARD color=red reason=LOW_RESERVE_OR_LOW_ENDURANCE`
- `[XNP STATUS ICON] stamina_color_preserved=true dragged_position=true`

Preserved behavior:

- Drag capture continues through mouse-up.
- Tooltip remains hover-based.
- Red flash and dragdown danger stay above stamina colors.
- Stamina color only applies when no higher-priority danger state is active.

```

## 0.5.27_TEST_PLAN.md

- SHA-256: `2755143CE17DFDD6389D91732BFFB8310567561E51047022A0F596BFDCFF3BFB`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.27 Test Plan

Preparation:

1. Copy this SOURCE manually to the Project Zomboid mods location.
2. Start Build 42.19.0 manually.
3. Create or load a character with trait `XNPDistanceRunnerTrait:XNPDistanceRunner`.
4. Confirm console shows `XNP_PZ_DISTANCE_TRAIT_0527_LONG_MIGRATION_STAMINA_ASSIST_A`.

Core preservation checks:

1. Walk into zombies: no active jog/contact/vehicle impact route should trigger.
2. Jog into one zombie: 0.5.26 jog bump feel should remain.
3. Sprint into a crowd/vehicle-like impact case: 0.5.26 sprint vehicle impact route should remain.
4. Let zombies control/grab the player while holding run/sprint input: controlled jog escape should remain.
5. Drag the icon and release outside the original icon rectangle: capture should persist until mouse-up.

Stamina assist checks:

1. High endurance movement should log `GREEN_READY` and show green when no danger state overrides it.
2. Medium endurance jog should log `BLUE_CRUISE`.
3. Low endurance with food reserve should log `YELLOW_METABOLIC` and `[XNP METABOLIC RESERVE] active=true`.
4. Very low endurance or high hunger should log `RED_GUARD` and stop/reduce conversion.
5. Confirm hunger rises slowly and never exceeds the per-minute cap.
6. Confirm endurance is not fully restored and low stamina still matters.

Failure checks:

- No console spam every frame.
- No player coordinate movement by this module.
- No healing, bite rollback, infection rollback, or damage rollback.
- No effect on players without the trait.

```

## BUILD_MARKER.txt

- SHA-256: `3942E277124F44B52BA50F46962895EE2CB1C47D27D900E15F55C8B02F537DEE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0527_LONG_MIGRATION_STAMINA_ASSIST_A

```

## FINAL_REPORT.md

- SHA-256: `E7FF5CB5D7E2C8F96688BDC56F23707B1CD6D0259D7B2FB0F7019B3E5E3F6928`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.27

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0527_LONG_MIGRATION_STAMINA_ASSIST_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.27 Long Migration Stamina Assist

Baseline copied from:

`[LOCAL_PATH_REDACTED]`

Main changes:

- Added long migration stamina assist.
- Added capped metabolic reserve conversion.
- Added green/blue/yellow/red stamina icon state integration.
- Added release-oriented performance budget.
- Added shared nearby zombie cache.
- Preserved 0.5.26 walk no impact and controlled jog escape mechanics.

Files changed or added:

- `mod.info`
- `42/mod.info`
- `BUILD_MARKER.txt`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Log.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_PerformanceBudget.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_NearbyZombieCache.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist.lua`
- 0.5.27 design/test/audit markdown files.

Runtime guarantees:

- No Project Zomboid launch.
- No Steam launch.
- No user mods write.
- No saves write.
- No Workshop write.
- No game directory write.
- No old SOURCE modification.
- No packaging/install.

Counts:

- Lua files: 40
- Lua total lines: 8613
- Root document/text files: 10

0.5.26 preserve:

- walk no impact: PRESERVED.
- controlled jog escape: PRESERVED.
- jog bump: PRESERVED.
- sprint vehicle impact: PRESERVED.
- drag capture icon: PRESERVED.

LongMigrationStaminaAssist:

- runtime: PRESENT and called from `Core.LongMigrationStaminaAssist.Tick(player)`.
- tick interval: 15 frames.
- jog endurance assist: PRESENT.
- sprint low endurance no full restore: PRESENT.
- metabolic reserve: PRESENT.
- starvation guard: PRESENT.

Icon color:

- green / blue / yellow / red: PRESENT.
- danger red flash priority: PRESERVED.
- dragged position: PRESERVED.

Performance:

- release verbose false: PRESENT.
- per-frame print disabled: PRESENT by config and summary logging.
- stamina tick throttled: PRESENT.
- UI state logging throttled by state change/summary behavior.
- zombie cache/shared scan: PRESENT, 10-frame scan interval, 12-frame TTL.

Safety:

- no infinite stamina: PASS by capped per-tick restore and state caps.
- no infinite sprint: PASS by sprint low-endurance guard.
- low hunger guard: PASS by soft/starvation guard.
- no heal/no bite rollback/no infection rollback: PASS for 0.5.27 module; existing preserved modules only log no-bite/no-infection/no-heal or keep pre-existing minor scrape cost.
- walk impact still blocked: PASS by preserved MovementIntentGate config.

Forbidden grep summary:

- Strict blocked route strings abse
[EXCERPT_TRUNCATED]
```

## 0.5.27_SECOND_PASS_AUDIT.md

- SHA-256: `E1C2A8B4530D55C926FDD12C10BD68B710018BACE03C286B267C3873A6F23275`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.27 Second Pass Audit

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]

WRITE_TARGET=0.5.27_SECOND_PASS_AUDIT.md

GAME_STARTED=NO

STEAM_STARTED=NO

USER_MODS_WRITTEN=NO

SAVES_WRITTEN=NO

WORKSHOP_WRITTEN=NO

GAME_DIR_WRITTEN=NO

PACKAGED=NO

## 1. Version And File Count

- SOURCE_EXISTS=PASS
- BUILD_MARKER_OK=PASS: `XNP_PZ_DISTANCE_TRAIT_0527_LONG_MIGRATION_STAMINA_ASSIST_A`
- DISPLAY_NAME_OK=PASS: `XNP Distance Runner Trait 0.5.27 Long Migration Stamina Assist`
- OLD_ACTIVE_RESIDUE=PASS: runtime Lua grep for 0.5.20/0520 through 0.5.26/0526 returned 0 hits.
- FILE_COUNT_0526=54
- FILE_COUNT_0527=57
- LUA_COUNT_0527=40
- LARGE_COPY_DETECTED=NO: increase is 3 files over 0.5.26 baseline, not 1000+ pollution.

## 2. LongMigrationStaminaAssist Audit

- STAMINA_ASSIST_FILE=PASS: `XNP_DR_LongMigrationStaminaAssist.lua` exists.
- STAMINA_ASSIST_RUNTIME=PASS: Runtime requires module and calls `Core.LongMigrationStaminaAssist.Tick(player)`.
- STAMINA_ASSIST_CONFIG=PASS: config includes `long_migration_stamina_enabled`, `long_migration_tick_interval_frames=15`, `metabolic_reserve_enabled`, `metabolic_starvation_guard_hunger`, `metabolic_max_hunger_cost_per_minute`.
- SAFE_WRAPPERS=PASS: `GetEndurance`, `SetEnduranceSafe`, `GetHunger`, `SetHungerSafe`, `GetStatus`, `Tick` present; stat reads/writes use pcall helpers.
- TICK_THROTTLED=PASS: `Core.PerformanceBudget.ShouldRun("long_migration_stamina", interval)` gates stamina assist.
- WALK_NOT_ASSIST_IMPACT=PASS: stamina module does not write impact state or zombie/player collision state; 0.5.26 walk block config remains present.
- STAMINA_ASSIST_STATUS=PASS.

## 3. Metabolic Reserve Audit

- METABOLIC_RUNTIME=PASS: runtime tick applies reserve only through LongMigrationStaminaAssist.
- LOW_ENDURANCE_TRIGGER=PASS: conversion begins below `METABOLIC_TRIGGER_ENDURANCE`.
- HUNGER_COST=PASS: conversion calls `SetHungerSafe(player, hunger + cost, reason)`.
- STARVATION_GUARD=PASS: conversion blocks when hunger is nil or >= `METABOLIC_STARVATION_GUARD_HUNGER`.
- MINUTE_CAP=PASS: `minuteBudgetAvailable(cost)` enforces `METABOLIC_MAX_HUNGER_COST_PER_MINUTE`.
- NO_INFINITE_STAMINA=PASS: restore is capped by `targetCap`, never direct full restore.
- NO_INFINITE_SPRINT=PASS: sprint assist is blocked below `SPRINT_ASSIST_ONLY_ABOVE_ENDURANCE`.
- NO_HEAL_ROLLBACK=PASS: required log exists, and stamina assist does not call body damage, bite, wound, or infection rollback APIs.
- Required strings present: enabled=true, active=true, guard=true, capped=true, no_heal/no_bite_rollback/no_infection_rollback.
- METABOLIC_STATUS=PASS.

## 4. Stamina Icon Color Audit

- GREEN_STATE=PASS
- BLUE_STATE=PASS
- YELLOW_STATE=PASS
- RED_STATE=PASS
- DANGER_PRIORITY_PRESERVED=PASS: `SKILL_TRIGGERED_FLASH`, `DRAGDOWN_DANGER`, emergency cooldown, and sprint are checked before stamina color states.
- DRAG_POSITION_PRESERVED=PASS: `DraggableStatusIcon` remains loaded and used; drag summary log exists.
- UI_UPDATE_THROTTLED=PASS_WITH_NOTE: UI is still 
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `9B7EADAC841C1B19D22189C450F4C00D4DBC279BEEF9AF85B140383060F03E12`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.27

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0527_LONG_MIGRATION_STAMINA_ASSIST_A

Old SOURCE modified: NO.

Game directory write: NO.

User mods write: NO.

Package/install: NO.

File counts:

- Lua files: 40
- Lua total lines: 8613
- Root document/text files: 10
- Empty files: none
- BOM: none detected
- NULL: only binary trait PNG contains NULL bytes; text files not affected.

Runtime additions:

- `XNP_DR_Log.lua`
- `XNP_DR_PerformanceBudget.lua`
- `XNP_DR_NearbyZombieCache.lua`
- `XNP_DR_LongMigrationStaminaAssist.lua`

Required implementation checks:

- LongMigrationStaminaAssist runtime module: PRESENT.
- Safe wrappers `GetEndurance`, `SetEnduranceSafe`, `GetHunger`, `SetHungerSafe`, `GetFatigue`, `GetRunningState`, `GetStatus`, `Tick`: PRESENT.
- Metabolic starvation guard: PRESENT.
- No infinite stamina: enforced by capped restore targets and hunger guard.
- Tick interval: `LONG_MIGRATION_TICK_INTERVAL_FRAMES=15`.
- No per-frame endurance/hunger write: PASS by PerformanceBudget tick gate.
- No per-frame zombie scan in new cache: PASS, scan interval 10 frames and TTL 12 frames.
- LongMigrationStaminaAssist scans zombies: NO.
- Icon states green/blue/yellow/red: PRESENT.
- Danger red flash priority preserved: PASS; stamina states are below flash/dragdown/emergency/sprint.
- Drag capture preserved: PASS; DraggableStatusIcon remains loaded and called.
- MovementIntentGate preserved: PASS.
- Walk no impact preserved: PASS by unchanged config flags.
- Controlled jog escape preserved: PASS by unchanged config flags.
- No heal/no bite/no infection rollback in new module: PASS.
- Performance budget: PRESENT.
- Nearby zombie cache: PRESENT.

Forbidden route grep target:

- `setVariable("bumped"`: NOT PRESENT in runtime Lua.
- `setVariable('bumped'`: NOT PRESENT in runtime Lua.
- `player:hasTrait(`: NOT PRESENT in runtime Lua.
- `TraitFactory`: NOT PRESENT in runtime Lua.
- `CharacterTraitDefinition`: NOT PRESENT in runtime Lua.
- `RunningShove`: NOT PRESENT in runtime Lua.
- `BumpedState`: NOT PRESENT in runtime Lua.
- `GameTime:setMultiplier`: NOT PRESENT in runtime Lua.
- `HaloTextHelper`: NOT PRESENT in runtime Lua.
- `player:Say`: NOT PRESENT in runtime Lua.
- `player:setX/setY/setZ`: NOT PRESENT in runtime Lua.
- `BodyDamage`: PRESENT only in preserved 0.5.26 `XNP_DR_MinorScrapeCost.lua` read/access path for minor scrape cost; not added by 0.5.27 stamina assist.
- `Bleeding`: PRESENT only in vanilla moodle display ordering string in `XNP_DR_StatusIconUI.lua`; not a damage write route.
- `Infection`: PRESENT in no-infection config/log strings and 0.5.27 `STAMINA_ASSIST_NO_INFECTION_ROLLBACK`; not an infection write route.

Old active residue grep:

- old 0.5.26 build marker literal: NOT PRESENT.
- old 0.5.26 display-name literal: NOT PRESENT.
- old 0.5.26 modinfo version literal: NOT PRESENT.

Lua syntax execution:

- NOT_VERIFIABLE: no reliable Lua 5.1 interpreter found in the cu
[EXCERPT_TRUNCATED]
```
