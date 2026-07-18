# 0.5.45 Sanitized Evidence Excerpts

## 0.5.45_DRAG_CLAMP_EDGE_STATE_MACHINE.md

- SHA-256: `EDBD22D82667315EFB81C702F0987399DC4C6F39691DA930C8849068E12D4201`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.45 Drag Clamp Edge State Machine

State fields:

- `lastClampActive`
- `lastClampReason`
- `lastClampX`
- `lastClampY`
- `lastViewportWidth`
- `lastViewportHeight`

Entrypoint:

`DraggableStatusIcon.LogClampEdgeOnce(state, context)`

Allowed edge logs:

1. First transition from legal position to out-of-bounds.
2. Viewport resolution change while the position is actually corrected.
3. A new out-of-bounds edge after returning to a legal region.

Forbidden logging:

- Continuous per-frame logging while `lastClampActive=true`.
- Repeated logs for identical input position, viewport, and corrected result.
- Missing-config fallback print.
- Debug=true per-tick clamp print.
- Business path direct `print(...)` for clamp events.

Observed implementation:

- Legal region resets `lastClampActive=false`.
- Clamped region sets active state and last viewport/corrected coordinates.
- Log emission only occurs on edge entry or viewport change.
- Log emission uses `Core.LogThrottle.Event(...)`, not direct `print(...)` in the drag module.

Static result:

- `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=0`
- `STATUS_ICON_DRAG_CLAMP_HOLD_LOG_REACHABLE=0`
- `STATUS_ICON_DRAG_CLAMP_DIRECT_PRINT_CALLS=0`
- `STATUS_ICON_DRAG_CLAMP_EDGE_LOG_REACHABLE=1`
- `STATUS_ICON_DRAG_CLAMP_EDGE_LOG_CALLS<=1_PER_EDGE`


```

## 0.5.45_DRAG_CLAMP_LOG_REACHABILITY.md

- SHA-256: `61F694FB712F8C6CE4A85D717F881D658ACBDFF865F6228AEA578FDB069AA148`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.45 Drag Clamp Log Reachability

Before:

`STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=1`

Reason:

0.5.44 used `shouldLog = key ~= lastLayoutLogKey or clamped`, so a continuously clamped saved/session coordinate could keep logging every layout tick.

After:

`STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=0`

Static checks:

- `print("[XNP STATUS ICON DRAG] ... full_screen_clamp ...")` hits: `0`
- `print("[XNP STATUS ICON DRAG] ... clamp ...")` hits: `0`
- Clamp edge logging entrypoint: `DraggableStatusIcon.LogClampEdgeOnce`
- Direct clamp print calls: `0`
- Edge log path: `Core.LogThrottle.Event(...)`

Config:

- `ICON_STATE_HOLD_LOG_SUMMARY_ONLY=true`
- `STATUS_ICON_HOLD_DIRECT_PRINT=false`
- `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT=false`
- `STATUS_ICON_DRAG_CLAMP_EDGE_LOG=true`

Missing config fallback:

`MISSING_CONFIG_FALLBACK_SILENT=true`

Rationale:

If `STATUS_ICON_DRAG_CLAMP_EDGE_LOG` is missing or not true, no clamp edge log is emitted. If `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT` is true, the repair still refuses repeat logging.

Result:

`STATUS_ICON_LOG_STATUS=PASS_STATIC`


```

## 0.5.45_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `2C2AF94265A864713EFF96959E5094E6FE19684BE20B94BE8372C14105224479`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.45 Gameplay Preserve Report

Preserved from 0.5.44:

- Authority seven legacy non-food write sites still route through `CanWriteNonFoodStats`.
- Food client direct endurance / hunger write remains `0`.
- Normal MP client non-food write remains statically blocked by Authority.
- PreBite absolute 0.30 gate remains inactive.
- Blue / Yellow / Red PreBite band access remains allowed.
- Green remains blocked for PreBite.
- CentralWorldQuery remains the only local world scan owner.
- Business module direct world scan remains `0`.
- Scheduler calls `CentralWorldQuery.BuildPlayerFrame(...)` once.
- Global zombie list usage remains `false`.
- Tiered Food remains one food writer through Authority.
- Blue food pulse remains `0.005` food for `0.015` endurance per 2 seconds.
- Yellow / Red food pulse remains `0.010` food for `0.020` endurance per 2 seconds.
- Reserve floor remains `0.40`.
- PreBite remains before fatal / bite commit by design.
- PreBite max targets remains `3`.
- Third target remains stagger-only / contact route.
- Emergency floor remains `0.05`.
- Vehicle 0.5.37 equivalence values remain preserved.
- Precollision final default remains `0.0120`.
- Vehicle final default remains `0.0180`.
- Zombie impact multiplier remains `0.24`.
- Coordinate write remains `0`.
- No bite rollback.
- No infection rollback.
- No heal.
- Mod ID remains `XNP_PZ_DistanceRunnerTrait`.

Changed:

- Drag clamp log repeat path only.
- Version identity advanced to 0.5.45.

GAMEPLAY_PRESERVE_STATUS=PASS_STATIC


```

## 0.5.45_STATUS_ICON_BEHAVIOR_PRESERVE.md

- SHA-256: `F0715B84A9F0FBFE5E5001FD1A7EEFF2AF29E129B8881B3C072744FF5C911906`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.45 Status Icon Behavior Preserve

Preserved:

- Clamp functionality remains enabled.
- Drag behavior remains direct-left-drag.
- Position save behavior remains player moddata based.
- Position restore behavior remains unchanged.
- Resolution clamp behavior remains unchanged.
- Color, shake, and drag interaction behavior remain unchanged.
- No render world scan was added.
- No render print path was added.

Changed:

- Clamp repeat logging was replaced by edge-only logging.

Not changed:

- Icon position calculation.
- Drag capture.
- Mouse-up release behavior.
- Saved X/Y fields.
- Default status icon placement.
- Tooltip behavior.

Status:

`STATUS_ICON_BEHAVIOR_PRESERVED=true`


```

## BUILD_MARKER.txt

- SHA-256: `01687811E8E3FAC78DB4C729FC14D7FAA013BDA752A1235FF904FCFBBA8E750E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0545_DRAG_CLAMP_LOG_SILENCE_REPAIR_A

```

## FINAL_REPORT.md

- SHA-256: `F1B41AAF0B6B22C172EFB6E9FDC5CCDF1CA3D1FD2FBC8172C92279E1D784E9DC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE:

`[LOCAL_PATH_REDACTED]`

DIRECT_INSTALL:

`[LOCAL_PATH_REDACTED]`

Version:

`0.5.45`

Build marker:

`XNP_PZ_DISTANCE_TRAIT_0545_DRAG_CLAMP_LOG_SILENCE_REPAIR_A`

Display name:

`XNP Distance Runner Trait 0.5.45 Drag Clamp Log Silence Repair`

Mod ID:

`XNP_PZ_DistanceRunnerTrait`

Changed files:

- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DraggableStatusIcon.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_VehicleLegacy0537Evaluator.lua`
- `mod.info`
- `42/mod.info`
- `BUILD_MARKER.txt`

Clamp repeat print:

- before: `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=1`
- after: `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=0`

Edge state machine:

- `lastClampActive`
- `lastClampReason`
- `lastClampX`
- `lastClampY`
- `lastViewportWidth`
- `lastViewportHeight`
- `DraggableStatusIcon.LogClampEdgeOnce(state, context)`

Missing config fallback:

`MISSING_CONFIG_FALLBACK_SILENT=true`

Direct install tree:

```text
XNP_PZ_DistanceRunnerTrait
鈹溾攢 42
鈹溾攢 mod.info
鈹斺攢 poster.png
```

DIRECT_INSTALL validation:

- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`
- `DEV_DOC_COUNT=0`
- `CACHE_ARTIFACT_COUNT_EXCLUDING_RUNTIME_MODULE=0`
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`

Hashes:

- `SOURCE_RUNTIME_42_COMBINED_SHA256=B661E95AED425FDAEE2EDF5CF75841D8A8AF8CBE64D650F1A8B331C4F1D5C4A1`
- `DIRECT_RUNTIME_42_COMBINED_SHA256=B661E95AED425FDAEE2EDF5CF75841D8A8AF8CBE64D650F1A8B331C4F1D5C4A1`
- `DIRECT_FULL_COMBINED_SHA256=5A75F0E9A21B8EB60C3F09944E23D3BA201247C53BEB6106247C888E499E0329`

Did modify old SOURCE:

`false`

Started PZ / Steam:

`false`

Wrote user mods / saves / Workshop / game directory:

`false`

Blocker:

`NONE_STATIC`

Final status:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.45_SOURCE_READY_FOR_DIRECT_INSTALL_TEST

```

## 0.5.45_DIRECT_INSTALL_VALIDATION.md

- SHA-256: `85077D6173E9C26C6967DCCB62D01C89BCF762A1C6776CD9CBD0A709E9CEA2D3`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.45 Direct Install Validation

DIRECT_INSTALL:

`[LOCAL_PATH_REDACTED]`

First-level entries:

- `42`
- `mod.info`
- `poster.png`

Validation:

- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_42_EXISTS=true`
- `TOP_LEVEL_MOD_INFO_EXISTS=true`
- `TOP_LEVEL_POSTER_EXISTS=true`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`
- `B42_STRUCTURE_VALID=true`
- `RUNTIME_FILES_COMPLETE=true`
- `DEV_DOC_COUNT=0`
- `AUDIT_FILE_COUNT=0`
- `CONSOLE_COUNT=0`
- `WORKSHOP_FILE_COUNT=0`
- `CACHE_ARTIFACT_COUNT_EXCLUDING_RUNTIME_MODULE=0`
- `OLD_VERSION_FILE_COUNT=0`
- `ABSOLUTE_PATH_LEAK_COUNT=0`
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`

Runtime counts:

- `SOURCE_42_FILE_COUNT=74`
- `DIRECT_42_FILE_COUNT=74`

Hashes:

- `SOURCE_RUNTIME_42_COMBINED_SHA256=B661E95AED425FDAEE2EDF5CF75841D8A8AF8CBE64D650F1A8B331C4F1D5C4A1`
- `DIRECT_RUNTIME_42_COMBINED_SHA256=B661E95AED425FDAEE2EDF5CF75841D8A8AF8CBE64D650F1A8B331C4F1D5C4A1`
- `DIRECT_FULL_COMBINED_SHA256=5A75F0E9A21B8EB60C3F09944E23D3BA201247C53BEB6106247C888E499E0329`

DIRECT_INSTALL_STATUS=PASS_STATIC

```

## 0.5.45_FIX_FROM_0.5.44_AUDIT.md

- SHA-256: `77F910CF582B5CC7DA601421868436E3743A36F2EAE6C295572739FB237CECDC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.45 Fix From 0.5.44 Audit

Baseline SOURCE:

`[LOCAL_PATH_REDACTED]`

New SOURCE:

`[LOCAL_PATH_REDACTED]`

0.5.44 second-pass blocker:

`STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=1`

0.5.45 repair target:

`STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=0`

Changed runtime files:

- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DraggableStatusIcon.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_VehicleLegacy0537Evaluator.lua`
- `mod.info`
- `42/mod.info`
- `BUILD_MARKER.txt`

Scope:

- Drag clamp repeat logging was repaired.
- Version and build marker were advanced to 0.5.45.
- Vehicle history namespace string was advanced from 0.5.44 to 0.5.45 to satisfy the active Lua identity rule.

No gameplay numeric tuning was changed.

0.5.44 old SOURCE modified:

`false`


```

## 0.5.45_SECOND_PASS_AUDIT.md

- SHA-256: `17836927FEE39C758B55ADC13280C829116CAF058EEA72E6D13996849422050D`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.45 Second Pass Audit

Audit mode:

`READ_ONLY_SECOND_PASS_AUDIT`

Allowed write performed:

`[LOCAL_PATH_REDACTED]`

No runtime code was modified. DIRECT_INSTALL was not rebuilt. Project Zomboid and Steam were not launched. User mods, saves, Workshop, and game install directories were not written.

## 1. Audit SOURCE

SOURCE:

`[LOCAL_PATH_REDACTED]`

SOURCE_EXISTS=true

BUILD_MARKER_OK=true

Observed marker:

`XNP_PZ_DISTANCE_TRAIT_0545_DRAG_CLAMP_LOG_SILENCE_REPAIR_A`

DISPLAY_NAME_OK=true

Observed display name:

`XNP Distance Runner Trait 0.5.45 Drag Clamp Log Silence Repair`

MOD_ID_STABLE=true

Observed Mod ID:

`XNP_PZ_DistanceRunnerTrait`

Version fields:

- `version=0.5.45`
- `modversion=0.5.45`

SOURCE_RUNTIME_COMPLETE=true

OLD_SOURCE_UNCHANGED=true

No 0.5.45 / 0545 / DRAG_CLAMP_LOG_SILENCE residue was found in the 0.5.44 reference SOURCE runtime Lua.

## 2. Audit DIRECT_INSTALL

DIRECT_INSTALL:

`[LOCAL_PATH_REDACTED]`

DIRECT_INSTALL_EXISTS=true

First-level entries:

```text
XNP_PZ_DistanceRunnerTrait
鈹溾攢 42
鈹溾攢 mod.info
鈹斺攢 poster.png
```

Validation:

- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_42_EXISTS=true`
- `TOP_LEVEL_MOD_INFO_EXISTS=true`
- `TOP_LEVEL_POSTER_EXISTS=true`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`
- `B42_STRUCTURE_VALID=true`
- `RUNTIME_FILES_COMPLETE=true`
- `DEV_DOC_COUNT=0`
- `AUDIT_FILE_COUNT=0`
- `CONSOLE_COUNT=0`
- `WORKSHOP_FILE_COUNT=0`
- `ABSOLUTE_PATH_LEAK_COUNT=0`

Hash validation:

- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`
- `SOURCE_RUNTIME_42_COMBINED_SHA256=B661E95AED425FDAEE2EDF5CF75841D8A8AF8CBE64D650F1A8B331C4F1D5C4A1`
- `DIRECT_RUNTIME_42_COMBINED_SHA256=B661E95AED425FDAEE2EDF5CF75841D8A8AF8CBE64D650F1A8B331C4F1D5C4A1`
- `DIRECT_FULL_COMBINED_SHA256=5A75F0E9A21B8EB60C3F09944E23D3BA201247C53BEB6106247C888E499E0329`

## 3. Repeat Print Reachability

Target file:

`42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DraggableStatusIcon.lua`

Observed:

- `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=0`
- `STATUS_ICON_DRAG_CLAMP_HOLD_LOG_REACHABLE=0`
- `STATUS_ICON_DRAG_CLAMP_DIRECT_PRINT_CALLS=0`
- `STATUS_ICON_DRAG_CLAMP_EDGE_LOG_REACHABLE=1`
- `STATUS_ICON_DRAG_CLAMP_EDGE_LOG_CALLS<=1_PER_EDGE`
- `MISSING_CONFIG_FALLBACK_SILENT=true`

Direct clamp print grep:

`0`

Direct `full_screen_clamp` print grep:

`0`

## 4. Edge State Machine

State fields found:

- `lastClampActive`
- `lastClampReason`
- `lastClampX`
- `lastClampY`
- `lastViewportWidth`
- `lastViewportHeight`

Entrypoint found:

`DraggableStatusIcon.LogClampEdgeOnce(state, context)`

Static proof:

1. Continuous `clampActive` does not repeat print because `shouldLog = enteringClamp or viewportChanged`.
2. Same position / viewport / clamped result cannot repeat print because `enteringClamp=false` and `viewportChanged=false`.
3. First entry into clamp edge logs at most once because `enteringClamp=true` only before `lastClampActive` is set true.
4. Leaving the legal region resets `lastClampActive=false`; a 
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `E4B2C05021A35025C6762C65FC9A3200C5D1F82E2368021772A3083F27697EB6`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

Version:

`0.5.45`

Build marker:

`XNP_PZ_DISTANCE_TRAIT_0545_DRAG_CLAMP_LOG_SILENCE_REPAIR_A`

Lua files:

`64`

Lua total lines:

`12268`

Active Lua old identity residue:

`0`

Forbidden grep:

- `coordinate_write=0`
- `player:hasTrait=0`
- `TraitFactory=0`
- `CharacterTraitDefinition=0`
- `RunningShove=0`
- `BumpedState=0`
- `GameTime:setMultiplier=0`
- `HaloTextHelper=0`
- `player:Say=0`
- `setVariable("bumped")=0`
- `getZombieList=0`
- `state_hold active=0`
- `PREBITE_JOG_RESCUE_MIN_ENDURANCE=0`
- `PreBite 0.30 active gate=0`
- `direct clamp print=0`

Central world query:

- direct scan modules: `1`
- allowed module: `XNP_DR_CentralWorldQuery.lua`
- scheduler call sites: `1`

Clamp audit:

- `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=0`
- `STATUS_ICON_DRAG_CLAMP_HOLD_LOG_REACHABLE=0`
- `STATUS_ICON_DRAG_CLAMP_DIRECT_PRINT_CALLS=0`
- `STATUS_ICON_DRAG_CLAMP_EDGE_LOG_REACHABLE=1`
- `MISSING_CONFIG_FALLBACK_SILENT=true`

Lua interpreter / luac:

`NOT_AVAILABLE_IN_CURRENT_SHELL`

Lua execution syntax check:

`NOT_VERIFIABLE_BY_STATIC_AUDIT`

STATIC_AUDIT_STATUS=PASS_STATIC_WITH_LUA_EXEC_NOT_VERIFIABLE


```
