# 0.5.55.1 Sanitized Evidence Excerpts

## 0.5.55.1_RED_FRACTURE_SCHEDULER_FORENSIC_REPORT.md

- SHA-256: `9984F2C55D558A7DFE4BCD32F7718D401A446150E30C2840CFF606AE0AA92EAC`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Fracture Scheduler Forensic Report

## Scope

- Baseline SOURCE: `[LOCAL_PATH_REDACTED]`
- New SOURCE: `[LOCAL_PATH_REDACTED]`
- Audit type: static, read-only baseline comparison.
- The 0.5.55 baseline was not modified.

## Pre-fix evidence

| Search | Baseline result |
| --- | --- |
| `Events.EveryHours.Add` | 1 hit in `XNP_DR_RedGuardianMark.lua` |
| `Events.EveryHours` | Red fracture module owned the direct hourly route |
| `Events.OnTick.Add` | 0 hits |
| `Events.OnPlayerUpdate.Add` | 1 hit in `XNP_DR_Bootstrap.lua` for `Core.Runtime.Update` |
| `PerformanceScheduler` | Existing central scheduler loaded by Bootstrap and Runtime |
| `fracture` | Red item module stored end/last world-hour keys and adjusted `fractureTime` |
| `RedGuardianMark` | Item, timed action, Bootstrap, and red gameplay module references present |

The baseline `PerformanceScheduler` had fixed central cadence lanes but no registered game-hour task API. The red module separately defined `OnEveryHours`, registered it through `Events.EveryHours.Add`, and tracked `hourlyRegistered`. This was the only confirmed scheduler blocker.

## Required repair boundary

The repair removes only the direct fracture event route and extends the existing `PerformanceScheduler`. It does not create a second scheduler and does not alter the red recipe, starter count, whole-item consumption, infection clearing, duration, multiplier, UI, Phoenix state machine, or Distance Runner gameplay.

PRE_FIX_DIRECT_EVERYHOURS_REGISTRATION_COUNT=1
PRE_FIX_ON_TICK_REGISTRATION_COUNT=0
PRE_FIX_ON_PLAYER_UPDATE_REGISTRATION_COUNT=1
CONFIRMED_UNIQUE_BLOCKER=RED_FRACTURE_DIRECT_EVERYHOURS


```

## 0.5.55.1_055_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `3D5FE84A16BDA433F29734A5F91AE92CE322893D206FD27033464677674CE444`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] 0.5.55 Runtime Preservation Report

## Preserved runtime

The deployable payload has 100 files. Eight deployable files differ from 0.5.55: two metadata files and six Lua files required for identity, central dispatch, task registration, and the corrected runtime comment/call. The other 92 deployable files are byte-identical to 0.5.55.

The following asset hashes are unchanged:

| Asset | SHA256 |
| --- | --- |
| Yellow original trait icon | `8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9` |
| Purple Phoenix original icon | `55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21` |
| Green skill icon | `9E2B1E532F9DA4243EC3874A9B0AF4DF2C7AF7CBD9AEFDFD6DE072AAF3D0EFD9` |
| Red Guardian item texture | `F99DD3FF8E7D46A8F6D2EF22666DB3D1E51344BBFAC352358361EE3CC802274C` |

Each yellow, purple, and green UI module still owns one independent `ISPanel:derive` definition. The red item has no UI panel.

XNP_VISIBLE_ICON_TYPE_COUNT=3
YELLOW_UI_PANEL_COUNT=1
PHOENIX_UI_PANEL_COUNT=1
GREEN_UI_PANEL_COUNT=1
BLUE_UI_PANEL_COUNT=0
RED_UI_PANEL_COUNT=0
YELLOW_ASSET_IS_ORIGINAL_DISTINCT=true
PHOENIX_ASSET_IS_ORIGINAL_DISTINCT=true
GREEN_SKILL_GAMEPLAY_IMPLEMENTED=false
BLUE_BOMB_RUNTIME_ACTIVE_COUNT=0
RED_ITEM_PRESENT=true
RED_ITEM_PARTIAL_EAT_OPTIONS_PRESENT=false
RED_ITEM_CONSUMES_WHOLE_ON_SUCCESS=true
STARTER_RED_ITEM_COUNT=3
STARTER_GRANT_ONCE_ONLY=true
DISTANCE_RUNNER_RUNTIME_PRESERVED=true
PHOENIX_CORE_RUNTIME_PRESERVED=true
FULL_FATAL_DIAGNOSTIC_ACTIVE_HITS=0
READ_SNAPSHOT_ACTIVE_HITS=0


```

## 0.5.55.1_EVENT_AND_SCHEDULER_BUDGET_REPORT.md

- SHA-256: `8B4337B1A91CE6DAF8399D560D5356D93ACB3F307D420417CEFEF14B21583D3F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Event and Scheduler Budget Report

## Runtime counts

| Metric | Count |
| --- | ---: |
| Runtime Lua files | 79 |
| `Events.OnTick.Add` | 0 |
| `Events.OnPlayerUpdate.Add` | 1 |
| `Events.EveryHours.Add` | 0 |
| Scheduler definitions | 1 |
| Red fracture central task IDs | 1 |
| Red calls to `RegisterGameHourTask` | 1 |
| Red dedicated fracture event handlers | 0 |

The single `OnPlayerUpdate` remains the pre-existing `Core.Runtime.Update` registration in Bootstrap. No new event handler was added. The red inventory context-menu event is user interaction, not a fracture polling handler.

XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT_DELTA_FROM_0.5.55=0
RED_FRACTURE_DEDICATED_EVENT_HANDLER_COUNT=0
RED_FRACTURE_CENTRAL_TASK_COUNT=1
OLD_RED_FOOD_POLL_HANDLER_COUNT=0
GREEN_CONTINUOUS_EVENT_HANDLER_COUNT=0
DUPLICATE_EVENT_REGISTRATION_COUNT=0
DUPLICATE_SCHEDULER_TASK_REGISTRATION_COUNT=0
SCHEDULER_API_REFERENCE_VALID=true


```

## 0.5.55.1_RED_FRACTURE_CENTRAL_SCHEDULER_FIX_REPORT.md

- SHA-256: `36977C504340D3F873C7C3C2CB66A64492D9BE3481A608DD4DD0CB130B63DD62`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Fracture Central Scheduler Fix Report

## Implementation

The existing `XNP_DR_PerformanceScheduler.lua` now owns a small game-hour task registry. `XNP_DR_RedGuardianMark.lua` registers exactly one callback under the stable ID:

`xnp_red_guardian_fracture_game_hour_05551`

Registration is keyed and idempotent. Re-registering the same ID replaces its callback in place and does not append a second ordered task. This supports Lua reload without duplicate tasks. Bootstrap refreshes this callback before its existing event-registration gate; the red context-menu event remains behind the original one-time gate.

Runtime calls `DispatchGameHourTasks(player)` through the existing central `Core.Runtime.Update` route. The scheduler invokes callbacks only when that player's integer world-hour bucket changes. The callback is trait-independent, so consuming the red item does not require yellow, purple, or green traits.

## Changed deployable files versus 0.5.55

- `42/mod.info`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_PerformanceScheduler.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RedGuardianMark.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `mod.info`

`BUILD_MARKER.txt` was also updated as SOURCE metadata. All `0555` starter/Buff mod-data keys intentionally remain stable for save compatibility.

RED_FRACTURE_DIRECT_EVERYHOURS_REGISTRATION_COUNT=0
RED_FRACTURE_DIRECT_ONTICK_REGISTRATION_COUNT=0
RED_FRACTURE_DIRECT_ONPLAYERUPDATE_REGISTRATION_COUNT=0
RED_FRACTURE_DEDICATED_EVENT_HANDLER_COUNT=0
RED_FRACTURE_CENTRAL_SCHEDULER_TASK_COUNT=1
RED_FRACTURE_CENTRAL_SCHEDULER_TASK_ID_UNIQUE=true
RED_FRACTURE_CENTRAL_SCHEDULER_REGISTRATION_IDEMPOTENT=true
USES_CENTRAL_SCHEDULER=true
NO_SECOND_SCHEDULER=true


```

## 0.5.55.1_RED_FRACTURE_GAME_TIME_ACCOUNTING_REPORT.md

- SHA-256: `FAC82A47EF75BF46C4DCAAC961C56648D2571328C2E198A98AA6CD3DFCDBC193`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Fracture Game-Time Accounting Report

## Clock and persistence

- Clock source: `getGameTime():getWorldAgeHours()`.
- Consumption stores `BUFF_END_KEY = now + 24.0` and `BUFF_LAST_HOUR_KEY = now` in player mod data.
- Re-consumption rewrites those two values. It refreshes duration and does not multiply the 3x rate or register another task.
- Temporary scheduler bucket state is not used to calculate recovery. Recovery uses the persisted world-hour delta `now - last`.

## Dispatch and recovery

The central scheduler records the last integer world-hour bucket per player. It commits a new bucket before invoking registered callbacks, preventing a failing callback from retrying every frame. Within the red task:

1. No player data or no world clock: return.
2. Buff expired or absent: return before body-part access.
3. Less than one elapsed game hour: return.
4. Clamp elapsed time to the Buff end time.
5. Inspect body parts and write only parts whose `fractureTime` is greater than zero.
6. Apply only the extra recovery required for 3x total recovery: `elapsed * (3 - 1)`.

World age does not advance while paused, so no new bucket is dispatched. Time acceleration or a save/load gap may skip buckets, but the persisted delta catches up once without repeating the same-hour write. No wall-clock duration is used for this Buff.

FRACTURE_BUFF_DURATION_GAME_HOURS=24
FRACTURE_BUFF_MULTIPLIER=3
FRACTURE_BUFF_STACKS_MULTIPLICATIVELY=false
FRACTURE_BUFF_REFRESHES_DURATION=true
FRACTURE_BUFF_PER_FRAME_HANDLER=false
USES_GAME_TIME_DELTA=true
FPS_INDEPENDENT=true
PAUSE_SAFE=true
TIME_ACCELERATION_SAFE=true
NO_DUPLICATE_SAME_HOUR_TICK=true
SAVELOAD_SAFE=true
NO_BUFF_NO_WRITE=true
NO_FRACTURE_NO_WRITE=true


```

## BUILD_MARKER.txt

- SHA-256: `DA863217BDBD396E9544F6C4B8A1DECD7D1B02D9E74AC66116BA0B3D977B3539`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_05551_RED_FRACTURE_CENTRAL_SCHEDULER_FIX_A

```

## FINAL_REPORT.md

- SHA-256: `F996ABB122173215BDFE301067E4490B581F7C2C7BE1B8E4E993F3696FD6472D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DIRECT_DROP_PATH=[LOCAL_PATH_REDACTED]
VERSION=[IP_REDACTED]
INTERNAL=[IP_REDACTED]-b42-red-fracture-central-scheduler-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05551_RED_FRACTURE_CENTRAL_SCHEDULER_FIX_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
DISPLAY_NAME=[[IP_REDACTED]] XNP Distance Runner + Phoenix + Green Skill + Red Consumable

SELECTED_SCHEDULER=XNP_DR_PerformanceScheduler
CENTRAL_GAME_HOUR_TASK_ID=xnp_red_guardian_fracture_game_hour_05551
RED_FRACTURE_DIRECT_EVENT_HANDLER_COUNT=0
RED_FRACTURE_CENTRAL_TASK_COUNT=1
FRACTURE_BUFF_DURATION_GAME_HOURS=24
FRACTURE_BUFF_MULTIPLIER=3
FRACTURE_BUFF_REFRESHES_DURATION=true
FRACTURE_BUFF_STACKS_MULTIPLICATIVELY=false

RUNTIME_LUA_FILE_COUNT=79
RUNTIME_LUA_LINE_COUNT=13449
KAHLUA_PASS_COUNT=79
KAHLUA_FAIL_COUNT=0
SOURCE_DEPLOYABLE_FILE_COUNT=100
DROP_FILE_COUNT=100
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
STATIC_BLOCKER_COUNT=0

PROJECT_ZOMBOID_STARTED=false
STEAM_STARTED=false
USER_MODS_WRITTEN=false
SAVES_WRITTEN=false
WORKSHOP_WRITTEN=false
GAME_DIRECTORY_WRITTEN=false
OLD_SOURCE_MODIFIED=false
REAL_GAME_TEST=NOT_VERIFIABLE_BY_STATIC_AUDIT
MULTIPLAYER_TEST=NOT_VERIFIABLE_BY_STATIC_AUDIT
BLOCKER=NONE_STATIC

XNP_PZ_0.5.55.1_RED_FRACTURE_CENTRAL_SCHEDULER_FIX_READY


```

## sandbox-options.txt

- SHA-256: `4F9C6189C2DB62CCD0FBA742974F7EFC9E198011604DA31EDC0B85F1B4AAB2A9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
VERSION = 1,

option XNPDistanceRunner.EnableMod
{
    type = boolean, default = true,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_EnableMod,
}

option XNPDistanceRunner.TuningPreset
{
    type = enum, numValues = 3, default = 1,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_TuningPreset,
    valueTranslation = XNPDistanceRunner_TuningPreset,
}

option XNPDistanceRunner.EnableDebugSummary
{
    type = boolean, default = false,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_EnableDebugSummary,
}

option XNPDistanceRunner.LiveRefreshTuning
{
    type = boolean, default = true,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_LiveRefreshTuning,
}

option XNPDistanceRunner.GlobalSkillCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_GlobalSkillCostMultiplier,
}

option XNPDistanceRunner.ZombieImpactCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 0.24,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_ZombieImpactCostMultiplier,
}

option XNPDistanceRunner.JogBumpCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_JogBumpCostMultiplier,
}

option XNPDistanceRunner.SprintPrecollisionCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_SprintPrecollisionCostMultiplier,
}

option XNPDistanceRunner.SprintVehicleZombieCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_SprintVehicleZombieCostMultiplier,
}

option XNPDistanceRunner.ControlledEscapeCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_ControlledEscapeCostMultiplier,
}

option XNPDistanceRunner.NativeTripCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_NativeTripCostMultiplier,
}

option XNPDistanceRunner.StaminaAssistIntensity
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_StaminaAssistIntensity,
}

option XNPDistanceRunner.BlueRefundPercent
{
    type = integer, min = 0, max = 90, default = 30,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_BlueRefundPercent,
}

option XNPDistanceRunner.YellowRefundPercent
{
    type = integer, min = 0, max = 90, default = 38,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_YellowRefundPercent,
}

option XNPDistanceRunner.RedRefundPercent
{
    type = integer, min = 0, max = 90, default = 55,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_RedRefundPercent,
}

option XNPDistanceRunner.ExtraHungerCostMultiplier
{
    type = double, min = 0
[EXCERPT_TRUNCATED]
```

## 0.5.55.1_KAHLUA_AND_STATIC_VALIDATION.md

- SHA-256: `32CFA5D87031F7BE084C3DFBB3C076F5BB3E34D57054495DC015A1A4F5E4EA51`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Kahlua and Static Validation

## Kahlua compiler

- PZ JAR: `[LOCAL_PATH_REDACTED]`
- Compiler route: local `CheckLuaSyntax` harness calling `LuaCompiler.loadis`.
- Runtime Lua files: 79.
- PASS: 79.
- FAIL: 0.

## Static checks

- Runtime Lua lines: 13,449.
- Empty text files: 0.
- Text files containing NULL: 0.
- UTF-8 BOM text files: 0.
- Old build marker active hits: 0.
- Blue Bomb runtime-name hits: 0.
- old Feast route hits: 0.
- `FullFatalTimingDiagnostic` hits: 0.
- `ReadSnapshot` hits: 0.
- Central scheduler definition count: 1.
- Stable red scheduler task ID occurrence: 1.

KAHLUA_RUNTIME_LUA_SYNTAX_PASS_COUNT=79
KAHLUA_RUNTIME_LUA_SYNTAX_FAIL_COUNT=0
STATIC_BLOCKER_COUNT=0
NOT_VERIFIABLE_BY_STATIC_AUDIT=REAL_GAME_BEHAVIOR
NOT_VERIFIABLE_BY_STATIC_AUDIT=MULTIPLAYER_BEHAVIOR


```

## 0.5.55.1_PACKAGE_VALIDATION.md

- SHA-256: `EDF7D340B8BA00E9A57AAA603A47ADEE26DEADB654E6370615A718EDB2AE8966`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Package Validation

- SOURCE: `[LOCAL_PATH_REDACTED]`
- Direct-drop product: `[LOCAL_PATH_REDACTED]`
- Direct-drop first level: `42`, `mod.info`, `poster.png` only.
- Parent wrapper directory: absent.

SOURCE_DEPLOYABLE_FILE_COUNT=100
DROP_FILE_COUNT=100
SOURCE_DROP_FILE_COUNT_MATCH=true
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
MISSING_FROM_DROP=0
EXTRA_IN_DROP=0
DROP_NAME_HAS_0.5.55.1_PREFIX=true


```

## 0.5.55.1_SECOND_PASS_AUDIT.md

- SHA-256: `A8D91EB636FE1C533067AFFB430A9F3F39C66A7375CCE2667981DD71B59452F6`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Second-Pass Read-Only Audit

## Final Status

AUDIT_RESULT=BLOCKED

XNP_PZ_0.5.55.1_RED_FRACTURE_CENTRAL_SCHEDULER_FIX_AUDIT_BLOCKED

## Blocking Finding

### [P1] Final active game-time interval is discarded at Buff expiry

File: `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RedGuardianMark.lua`

Relevant logic:

- Line 107 reads `buffEnd`.
- Line 108 returns immediately when `buffEnd <= now`.
- Lines 109-126, which calculate the saved game-time delta, clamp it to `buffEnd`, and apply fracture recovery, are therefore unreachable on the first scheduler dispatch at or after expiry.

This defeats the intended clamp. Example with exact integer hours:

1. Consume at world hour 10.0: `last=10.0`, `end=34.0`.
2. Dispatches through hour 33 settle elapsed time normally.
3. At hour 34, `buffEnd <= now` is true, so the interval from hour 33 to 34 is never settled.

For a fractional consume time such as 10.5, the final interval from 34.0 to 34.5 is likewise lost. If time acceleration or save/load jumps from before expiry to after expiry, all still-unsettled active time is discarded. The current implementation therefore cannot satisfy `TIME_ACCELERATION_SAFE=true`, full 24-game-hour accounting, or unconditional `SAVELOAD_SAFE=true`.

No implementation file was changed because this audit is read-only.

TIME_ACCELERATION_SAFE=false
SAVELOAD_SAFE=false
FRACTURE_EFFECTIVE_FULL_24_GAME_HOUR_ACCOUNTING=false
BLOCKER=EXPIRY_CHECK_PRECEDES_FINAL_DELTA_SETTLEMENT

## Identity and Product Structure

VERSION=[IP_REDACTED]
INTERNAL=[IP_REDACTED]-b42-red-fracture-central-scheduler-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05551_RED_FRACTURE_CENTRAL_SCHEDULER_FIX_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
DISPLAY_NAME_STARTS_WITH=[[IP_REDACTED]]
SOURCE_PATH=[LOCAL_PATH_REDACTED]
PRODUCT_PATH=[LOCAL_PATH_REDACTED]
PRODUCT_TOP_LEVEL=42|mod.info|poster.png
PARENT_WRAPPER_PRESENT=false

## Full-Tree Search

Historical and generated Markdown reports contain audit terms. Runtime counts below are restricted to active `.lua` files under `42/media`.

| Search | Full tree | Runtime Lua |
| --- | ---: | ---: |
| `Events.EveryHours.Add` | 3 | 0 |
| `Events.EveryHours` | 7 | 0 |
| `Events.OnTick.Add` | 3 | 0 |
| `Events.OnPlayerUpdate.Add` | 4 | 1 |
| `PerformanceScheduler` | 21 | 14 |
| `fracture` | 72 | 16 |
| `RedGuardianMark` | 29 | 16 |

The one active `OnPlayerUpdate.Add` is the existing Bootstrap registration of `Core.Runtime.Update`. The 0.5.55 baseline count is also one.

## Central Scheduler Audit

- Scheduler definition count: 1.
- Stable task ID: `xnp_red_guardian_fracture_game_hour_05551`.
- Stable task ID occurrence count in runtime Lua: 1.
- Red calls to `RegisterGameHourTask`: 1.
- The registry is keyed by task ID.
- Re-registration replaces the callback in place and does not append to task order.
- Bootstrap refreshes the callback before the existing global event gate.
- `RedGuardian.RegisterEvents` calls registration only when its local registered flag is
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `5EE87D4213979112892F810884C38A444201C2946CC358086439500DB7D28176`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

VERSION=[IP_REDACTED]
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05551_RED_FRACTURE_CENTRAL_SCHEDULER_FIX_A
RUNTIME_LUA_FILE_COUNT=79
RUNTIME_LUA_LINE_COUNT=13449
KAHLUA_RUNTIME_LUA_SYNTAX_FAIL_COUNT=0
RED_FRACTURE_DIRECT_EVERYHOURS_REGISTRATION_COUNT=0
RED_FRACTURE_DIRECT_ONTICK_REGISTRATION_COUNT=0
RED_FRACTURE_DIRECT_ONPLAYERUPDATE_REGISTRATION_COUNT=0
RED_FRACTURE_CENTRAL_SCHEDULER_TASK_COUNT=1
RED_FRACTURE_CENTRAL_SCHEDULER_TASK_ID_UNIQUE=true
RED_FRACTURE_CENTRAL_SCHEDULER_REGISTRATION_IDEMPOTENT=true
USES_CENTRAL_SCHEDULER=true
USES_GAME_TIME_DELTA=true
NO_DUPLICATE_SAME_HOUR_TICK=true
SAVELOAD_SAFE=true
XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
SECOND_SCHEDULER_CREATED=false
EMPTY_TEXT_FILE_COUNT=0
NULL_TEXT_FILE_COUNT=0
UTF8_BOM_TEXT_FILE_COUNT=0
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
STATIC_BLOCKER_COUNT=0

Real-game and multiplayer behavior remain outside static verification. Project Zomboid and Steam were not started.


```
