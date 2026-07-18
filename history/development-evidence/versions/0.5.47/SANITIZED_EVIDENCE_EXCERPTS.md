# 0.5.47 Sanitized Evidence Excerpts

## 0.5.47_EXTERNAL_MOD_ERROR_SEPARATION.md

- SHA-256: `8F29E40CE0A5194CB79978A3AB4C1F6CBF0B280216A9236D710EC1BB9FA81A69`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 External Mod Error Separation

The console(9) evidence contains large non-XNP error/warning groups. They are not treated as Distance Runner failures.

- Bandits2 / BanditsWeekOne animation, behavior, map, and Sandbox overrides.
- `IsoGameCharacter.doDeferredMovement` path warnings, about 5572 lines.
- `Lua((MOD:Bandits)).AddZombiesInOutfit` warnings, about 831 lines.
- Missing clothing XML, including `Barbara-black.xml`, `Test.xml`, `Keqing-1.xml`, `Uranus Queen2.xml`, `Cheshire1.xml`, and `Cheshire2.xml`.
- ImportedSkeleton missing Cube / Camera / Light / Body bones.
- Missing vehicle/tank templates including TankTrack, TankMachinegun, Turrent, and TruckWaterTank.
- `FirearmUseDamageChance` passing boolean `true` to an IntegerConfigOption.
- Randomized World item blacklist messages.
- Other non-XNP require/warn output.

0.5.47 does not modify or attempt to repair those external mods.

```

## 0.5.47_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `A624E438C864C3457EB3277FD745E8F8B78C5A9F3DB4D012BFBAB99ACF84A00F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 Gameplay Preserve Report

Master ON preserves the 0.5.46 behavior contract:

- Authority old write sites preserved.
- Food client direct writes remain blocked.
- PreBite band gate preserved.
- CentralWorldQuery remains the only gameplay world scan owner.
- Scheduler count remains 1.
- Tiered Food remains Blue 0.5 to 1.5 / 2 sec, Yellow/Red 1 to 2 / 2 sec, reserve floor 40%.
- PreBite 3 targets, third target stagger-only.
- Emergency floor 5%.
- Vehicle exact 0.5.37 equivalence preserved.
- Precollision 0.012, Vehicle 0.018, ZombieImpact 0.24.
- SP melee preserved, MP melee disabled.
- Coordinate write remains 0.
- No bite/infection rollback.
- No heal.
- Drag clamp repeat print remains 0.
- Draggable icon preserved.
- CN/EN text route preserved.
- Mod ID remains `XNP_PZ_DistanceRunnerTrait`.

```

## 0.5.47_MASTER_DISABLED_EFFECT_MATRIX.md

- SHA-256: `23ACA16EB232E14D3125761E2B132DB02C903A470668392D98989F75BEFDE175`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 Master Disabled Effect Matrix

When Master is OFF, Runtime updates only minimum UI and MasterEffectState, then returns before `PerformanceScheduler.Begin`.

Disabled while OFF:

- LongMigrationStaminaAssist
- TieredFoodRecovery
- FoodReserveConversion
- Sprint/Jog/Vehicle impact
- Walk/Jog/controlled escape effect
- PreBiteJogRescue
- Dragdown/Emergency/Breakout
- SprintTripImmunity
- NativeTrip correction/consequence from XNP
- Melee power bonus
- ImpactQuota effect
- Zombie stagger/knockdown/interrupt from XNP
- XNP endurance/hunger writes
- XNP skill costs
- XNP target selection and ActionBus submissions
- XNP gameplay world query

Still active while OFF:

- Trait registration
- Mod loading
- Icon display
- Icon drag
- Right-click re-enable
- State persistence

Central result:

- `MASTER_DISABLED_SCHEDULER_EARLY_EXIT=true`
- `MASTER_DISABLED_CENTRAL_WORLD_QUERY_CALLS=0`
- `MASTER_DISABLED_BUSINESS_MODULE_TICKS=0`
- `MASTER_DISABLED_UI_INPUT_REMAINS=true`

```

## 0.5.47_MASTER_EFFECT_STATE_CONTRACT.md

- SHA-256: `9E1DA02AC3E763D642CA67B3F47C7F17363B671F2CBBFB530E2CE8C636234D81`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 Master Effect State Contract

- Module: `XNP_DR_MasterEffectState.lua`
- Storage: player modData key `XNPDistanceRunner_MasterEnabled`
- Default for old saves: `true`
- Per-player state: yes
- Single source of truth: yes

API:

- `IsEnabled(player)`
- `SetEnabled(player, enabled, source)`
- `Toggle(player, source)`
- `Load(player)`
- `Save(player, enabled)`
- `ResetTransientState(player, reason)`
- `GetUiState(player)`

OFF gates:

- `OFF_XNP_ENDURANCE_WRITE=0`
- `OFF_XNP_HUNGER_WRITE=0`
- `OFF_XNP_ZOMBIE_EFFECT=0`
- `OFF_XNP_PLAYER_EFFECT=0`
- `OFF_XNP_SKILL_COST=0`
- `OFF_XNP_ACTIONBUS_SUBMIT=0`
- `OFF_XNP_WORLD_QUERY_BUILD=0`
- `OFF_XNP_MELEE_MULTIPLIER=1.0`

Toggle edge logs:

- `[XNP MASTER TOGGLE] enabled=false source=STATUS_ICON_RIGHT_CLICK`
- `[XNP MASTER TOGGLE] enabled=true source=STATUS_ICON_RIGHT_CLICK`

```

## 0.5.47_MP_AUTHORITY_CONTRACT.md

- SHA-256: `4A1D36262B869935FC8E47DC104CD366E528A1DA9E46FF841EBB847CBB20C6C3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 MP Authority Contract

Single player:

- Right-click toggles immediately.
- State is stored on player modData key `XNPDistanceRunner_MasterEnabled`.

Multiplayer:

- No reliable generic ModData network sync route is implemented in this source.
- Normal client toggles are blocked with `SAFE_SERVER_AUTHORITY_REQUIRED`.
- Normal clients must not directly change authoritative gameplay state.
- Server-side food and melee handlers also check MasterEffectState.

Status:

- `SAFE_SERVER_AUTHORITY_REQUIRED`
- `MULTIPLAYER_NOT_VALIDATED`
- `SP_FULLY_USABLE`

```

## 0.5.47_REAL_GAME_EVIDENCE_CONSOLE9.md

- SHA-256: `CC6C6AA3B0C3D02557AEA5153915BD00319B9B63633AD4FB82A92389EB14EC86`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.47 Real Game Evidence From console(9)

## Accepted 0.5.46 Evidence

- `loading XNP_PZ_DistanceRunnerTrait` appeared.
- Native CharacterTrait registration succeeded.
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0546_TRANSLATION_VERSION_RESIDUE_CLEANUP_A` appeared.
- `loaded version=0.5.46` appeared.
- StatusIconUI, DraggableStatusIcon, PreBiteJogRescue, CentralWorldQuery, PerformanceScheduler, TieredFoodRecovery, and related modules reported `loaded=true`.

## Runtime Architecture Evidence

- `central_gameplay_scheduler_count=1`
- `direct_world_scan_owner=XNP_DR_CentralWorldQuery`
- `frame_contract=ONE_BUILD_PER_PLAYER_FRAME`
- `loaded_zombie_list_used=false`
- stamina tick interval: 15 frames
- UI tick interval: 10 frames
- zombie cache TTL: 12 frames

## XNP Error Status

- No XNP Lua ERROR was identified.
- No XNP exception stack was identified.
- No XNP require failure was identified.

## Log Noise Finding

- Full log: about 14576 lines.
- XNP log lines: about 1302 lines.
- `XNP STAMINA MULTIPLIER SUMMARY` and `XNP STAMINA SMOOTH SUMMARY` each appeared about 145 times.
- Startup still showed `summary_interval_frames=120`.

0.5.47 addresses this by using `SUMMARY_INTERVAL_REAL_MS=10000`, merging stamina summaries, and skipping periodic gameplay summaries while Master is OFF.

## Scope

This evidence proves the 0.5.46 architecture loaded and ran. It does not prove FPS improvement.

```

## 0.5.47_RIGHT_CLICK_EVENT_PROOF.md

- SHA-256: `3E8B7A7D812BF824B3720B745C590AEABABAD1C2EB53A0538F8490C95AFC850A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 Right Click Event Proof

- UI target: `XNP_DR_StatusIconUI.lua`
- Existing right-click route before 0.5.47: `Panel:onRightMouseUp` reset icon position.
- 0.5.47 route:
  - `Panel:onRightMouseDown(x, y)` records whether the press began inside the icon panel.
  - `Panel:onRightMouseUp(x, y)` toggles only when press and release are both inside the icon panel.
  - Toggle source is `STATUS_ICON_RIGHT_CLICK`.
  - `TOGGLE_DEBOUNCE_MS=250`.

Assertions:

- `RIGHT_CLICK_EVENT_VERIFIED=true`
- `RIGHT_CLICK_SINGLE_TOGGLE_PER_CLICK=true`
- `RIGHT_CLICK_WORLD_CONTEXT_PASSTHROUGH=false`
- `LEFT_DRAG_PRESERVED=true`
- Right-click no longer calls `DraggableStatusIcon.Reset`.

```

## 0.5.47_TOGGLE_TRANSIENT_CLEANUP.md

- SHA-256: `B45C9679675AEF19157228F6E1E5EA323586E037FE575037CD88B12AE4D0A1C1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 Toggle Transient Cleanup

ON to OFF cleanup clears transient XNP state only:

- ActionBus windows and accepted action state.
- pending PreBite state.
- impact candidate snapshot.
- CentralWorldQuery frame cache.
- NearbyZombieCache.
- ImpactQuota transient state.
- pending food pulse `nextDue`.
- stamina refund/debt accumulator.
- skill flash/shake transient UI state is superseded by white OFF state.
- pending zombie recovery/outcome watchdogs.
- old danger-window transient state.

Not performed:

- No cost refund.
- No heal.
- No bite or infection rollback.
- No wound modification.
- No endurance/hunger restore.
- No player or zombie coordinate edit.

OFF to ON:

- Food pulse timing restarts from a fresh future due time.
- Old targets and old danger windows are not reused.
- No missed pulse, refund, cost, target effect, or zombie effect catches up.

```

## 0.5.47_WHITE_OFF_ICON_PRIORITY.md

- SHA-256: `04D09C74B5DF529B5F056711F10893C827CD1E522D5B85383E5961FD90FC98E2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 White OFF Icon Priority

OFF state:

- State name: `MASTER_DISABLED_WHITE`
- RGBA: `1.0, 1.0, 1.0, 1.0`
- Priority: above band color, skill flash, warning flash, and shake color.

Behavior:

- OFF icon remains visible.
- OFF icon remains draggable.
- OFF icon remains right-clickable.
- OFF icon does not flash red.
- OFF icon does not use green, blue, yellow, or red band colors.
- OFF icon does not shake.

Tooltip text:

- CN: `璺濈璺戣€呮晥鏋滐細宸插叧闂紙鍙抽敭閲嶆柊鍚敤锛塦
- EN: `Distance Runner effects: OFF (right-click to enable)`
- ON CN: `璺濈璺戣€呮晥鏋滐細宸插惎鐢紙鍙抽敭鍏抽棴锛塦
- ON EN: `Distance Runner effects: ON (right-click to disable)`

```

## BUILD_MARKER.txt

- SHA-256: `16F14AE70BB61BEA424F4E529C5F78B67D8DE68FB251A24828166DEDE7AD1CEA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0547_MASTER_ICON_TOGGLE_WHITE_OFF_A

```

## FINAL_REPORT.md

- SHA-256: `8002BC6FCF073C3012DE2ABA8437E4DC5482B2BC57AB13577C305F9C570DBF5E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.47

SOURCE:

`[LOCAL_PATH_REDACTED]`

DIRECT_INSTALL:

`[LOCAL_PATH_REDACTED]`

## Build

- Version: `0.5.47`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_0547_MASTER_ICON_TOGGLE_WHITE_OFF_A`
- Display name: `XNP Distance Runner Trait 0.5.47 Right-Click Master Toggle`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`

## Implemented

- Added `XNP_DR_MasterEffectState.lua`.
- Added persistent per-player modData key `XNPDistanceRunner_MasterEnabled`.
- Added right-click status icon ON/OFF toggle.
- OFF icon is pure white and remains visible, draggable, and right-clickable.
- Runtime exits before scheduler/world query/business modules when Master is OFF.
- ON to OFF clears transient XNP state without refund, heal, wound rollback, or coordinate writes.
- OFF to ON resumes from fresh runtime state without catch-up.
- Server food and melee paths include Master defensive gates.
- Stamina summaries are merged and real-time throttled.

## Changed Files

- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_MasterEffectState.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Log.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist.lua`
- `42/media/lua/server/XNP_PZ_DistanceRunner/XNP_DR_FoodAuthorityServer.lua`
- `42/media/lua/server/XNP_PZ_DistanceRunner/XNP_DR_MeleePower.lua`
- runtime summary text cleanup in BreakoutPush, Dragdown, EmergencyInput, SprintTripImmunity, VehicleLegacy evaluator
- CN/EN sandbox tooltip cleanup

## External Error Attribution

console(9) non-XNP groups are separated in `0.5.47_EXTERNAL_MOD_ERROR_SEPARATION.md`, including Bandits/BanditsWeekOne, deferred movement warnings, outfit warnings, missing XML, skeleton, vehicle template, config parse, and blacklist messages.

## Static Result

- Lua files: 66
- Lua lines: 12560
- Forbidden grep count: 0
- Old runtime residue count: 0
- Source/direct hash mismatch count: 0
- Direct install layer: PASS
- Lua syntax risk scan: PASS

## Environment

- Project Zomboid not launched.
- Steam not launched.
- User mods directory not written.
- Saves not written.
- Workshop not written.
- Game install directory not written.
- Old SOURCE directories not modified.

Final status:

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.47_SOURCE_READY_FOR_DIRECT_INSTALL_TEST`

```

## 0.5.47_DIRECT_INSTALL_VALIDATION.md

- SHA-256: `0A0CB7F8524DA639322077070F41B1CFC8D03DD6F7714027C9B209DED43656ED`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.47 Direct Install Validation

DIRECT_INSTALL path:

`[LOCAL_PATH_REDACTED]`

Top-level structure:

```text
XNP_PZ_DistanceRunnerTrait
鈹溾攢 42
鈹溾攢 mod.info
鈹斺攢 poster.png
```

Validation:

- Single-layer direct install: PASS
- Nested `42\42`: PASS, not present
- Development documents in DIRECT_INSTALL: PASS, not present
- Console logs in DIRECT_INSTALL: PASS, not present
- Workshop files in DIRECT_INSTALL: PASS, not present
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`
- `OLD_VERSION_FILE_COUNT=0` for runtime files

User test action:

- Copy the `XNP_PZ_DistanceRunnerTrait` folder from the DIRECT_INSTALL path into the user mods folder manually.

```
