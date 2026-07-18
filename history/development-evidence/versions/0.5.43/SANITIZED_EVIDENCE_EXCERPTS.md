# 0.5.43 Sanitized Evidence Excerpts

## 0.5.43_ACTIONBUS_PREBITE_PRIORITY.md

- SHA-256: `9572BDF227939A9368FB7E80BE395A97F54CF181125E6122528F7D50DDCE5025`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 ActionBus Pre-Bite Priority

New source:

`PRE_BITE_JOG_RESCUE`

Priority intent:

`PRE_BITE_JOG_RESCUE > FATAL_SURROUNDED > DRAGDOWN > GRAB > ordinary LIGHT`

Implementation:

- Pre-Bite runs before Dragdown and Emergency modules in `Runtime.updateCritical`.
- It uses `BreakoutActionBus.CanStart` before applying effects.
- It calls `BreakoutActionBus.Accept` once per accepted window.
- It uses a local 0.75 s cooldown to prevent persistent state from submitting every tick.
- It keys handled windows by danger reason and close-ring counts.
- Same-target repeat blocking remains owned by `BreakoutActionBus`.
- Vehicle LIGHT admission is untouched and remains isolated in `VehicleLegacy0537Evaluator`.

Status:

- `PREBITE_ACTIONBUS_SOURCE=PRE_BITE_JOG_RESCUE`
- `VEHICLE_LIGHT_ROUTE_UNCHANGED=true`
- `PERSISTENT_TRUE_RESUBMIT_EVERY_TICK=false`

```

## 0.5.43_EMERGENCY_ENDURANCE_FLOOR.md

- SHA-256: `15CC4EC1026D6156773D18F74CDB8C51658298541ED6B0A529570EC0CC1319F5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Emergency Endurance Floor

Runtime module:
`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost.lua`

Floor:

`EMERGENCY_ENDURANCE_FLOOR=0.05`

Cost formula:

`appliedCost = min(nominalCost, max(0, currentEndurance - 0.05))`

Affected routes:

- `PRE_BITE_JOG_RESCUE`
- `DRAGDOWN`
- `FATAL_SURROUNDED`
- `GRAB`
- `EMERGENCY_BREAKOUT`
- `CONTROLLED_ESCAPE` where routed through the emergency cost module.

Preserved routes:

- Wall Impact unchanged.
- Vehicle zombie impact unchanged.
- NativeTrip unchanged.
- Ordinary locomotion costs unchanged.

Safety:

- Does not restore endurance that is already below 5%.
- Does not heal.
- Does not remove wounds.
- Does not roll back bites or infection.
- Same `ActionBus` action charges once.
- A successful Pre-Bite charge suppresses later emergency duplicate charge in the same short danger window.

Required logs:

- `[XNP EMERGENCY COST FLOOR] nominal=... before=... applied=... after=...`
- `[XNP EMERGENCY COST FLOOR] floor=0.0500`
- `[XNP EMERGENCY COST FLOOR] duplicate_charge_same_window=false`

```

## 0.5.43_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `042E269B4DEDB60A25A5A688C3E841CDB18812E7C3EC15ECDD249B4355FAA5E4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Gameplay Preserve Report

Preserved from 0.5.42:

- Vehicle exact 0.5.37 pipeline order.
- Vehicle 0.50-1.80 history admission.
- Raw 2.05 scan separation.
- Vehicle run gate equivalence.
- ActionBus LIGHT admission equivalence.
- Vehicle history cleanup behavior.
- No pre-rank cap in impact snapshot.
- Object identity dedupe.
- Same-tick freshness.
- Precollision 0.0120 consumer.
- Vehicle 0.0180 consumer.
- ZombieImpact 0.24.
- No double multiplier.
- SP melee verified route.
- MP melee disabled route.
- Coordinate writes remain 0.
- Critical window remains bounded.
- Sandbox CN/EN route preserved.
- Blue30 / Yellow38 / Red55 locomotion refund preserved.
- Colors, shake, and drag preserved.
- Walk No Impact preserved.
- Controlled Escape preserved.
- JogBump preserved.
- NativeTrip preserved.
- ImpactQuota preserved.
- No bite rollback.
- No infection rollback.
- No healing.
- Stable Mod ID preserved.

0.5.43 gameplay additions:

- Tiered food recovery replaces the old direct 1:1 FoodReserve tick.
- Pre-Bite Jog Rescue attempts an earlier active defensive push before committed bite reaction.
- Emergency skill costs use a 5% endurance floor.

Status:

`GAMEPLAY_PRESERVE_STATUS=PASS`

```

## 0.5.43_LOG_THROTTLE_FROM_REAL_GAME.md

- SHA-256: `8634126105837041EA23C7ED014C5C56157C597F2A09E240FF57363EF87F66B0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Log Throttle From Real Game

Real-game log pressure showed repeated status icon, drag clamp, dragdown danger, and emergency input lines.

Changes:

- `StatusIconUI` already uses `ICON_STATE_HOLD_LOG_SUMMARY_ONLY=true`, so `state_hold` is counted instead of printed by default.
- `DraggableStatusIcon` now prints `full_screen_clamp=true` only when the layout key changes or an actual clamp correction occurs.
- `EmergencyInput` prints accepted input only when the accepted reason/state/movement key changes.
- `DragdownDangerBreakout` prints auto-trigger danger entry only when level/ring key changes.
- `TieredFoodRecovery` does not print every pulse unless `Config.DEBUG=true`.

Preserved:

- Startup logs still identify loaded modules.
- Summary logs remain available.
- Debug remains false by default.

Status:

- `DEBUG_DEFAULT=false`
- `TIERED_FOOD_PULSE_PER_PULSE_PRINT_DEFAULT=false`
- `SUMMARY_INTERVAL_REAL_SECONDS>=10`
- `RENDER_WORLD_SCAN_COUNT=0`

```

## 0.5.43_PERFORMANCE_PRESERVE_REPORT.md

- SHA-256: `AEDD50079801949B03442CDF498D7916A02F82055862F7E125B2F4FF5C3065C3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Performance Preserve Report

Preserved from 0.5.42:

- Central scheduler count remains 1.
- Shared threat snapshot remains the owner of local zombie scanning.
- Pre-Bite uses `ThreatSnapshot.GetThreatEntries`.
- Tiered food performs no world scan.
- No global zombie list was introduced.
- No module-local world scan was introduced for Pre-Bite.
- Vehicle raw pool and 0.50-1.80 history admission remain isolated.
- Generic threat cap 16 is preserved.
- Same-tick impact freshness is preserved.
- Render path does not scan world, read sandbox, write stats, or print new per-frame diagnostics.

0.5.43 additions:

- Pre-Bite target selection consumes the existing shared snapshot.
- Tiered food recovery is timer/stat-only.
- Log throttling reduces repeated real-game spam.

Status:

- `MODULE_LOCAL_WORLD_SCAN_COUNT=0 for new modules`
- `CENTRAL_SCHEDULER_COUNT=1`
- `FULL_ZOMBIE_SCAN_DEFAULT=false`
- `PERFORMANCE_STATUS=PASS`

```

## 0.5.43_PREBITE_JOG_RESCUE_EVENT_ORDER.md

- SHA-256: `DE2B0B85F0E2419B7F09A95C4EDF122F096EF8D3F9E20B7B6FF27C14D05F14EC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Pre-Bite Jog Rescue Event Order

Runtime module:
`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_PreBiteJogRescue.lua`

Runtime call position:

1. `PerformanceScheduler.Begin`
2. Vehicle route
3. NativeTrip update
4. Sprint immunity
5. Dragdown danger classifier
6. `PreBiteJogRescue.Update(player, danger)`
7. ActionBus update
8. MovementIntentGate summary
9. Dragdown danger breakout
10. Emergency breakout

Timing contract:

- Runs before `DragdownDangerBreakout` and `EmergencyBreakout`.
- Rejects `hitreaction-bite` or any player movement text containing `bite` as `TOO_LATE_BITE_ALREADY_COMMITTED`.
- Does not roll back bite, infection, wound, or healing state.
- Uses `MovementIntentGate.GetIntent`, not `isSprinting()` alone.
- Uses `ThreatSnapshot.GetThreatEntries`, not a local world scan.

Required logs:

- `[XNP PREBITE RESCUE] trigger=PRE_BITE_JOG_RESCUE`
- `[XNP PREBITE RESCUE] movement_intent=RUN_OR_SPRINT`
- `[XNP PREBITE RESCUE] targets=... max_targets=3`
- `[XNP PREBITE RESCUE] third_target_stagger_only=true`
- `[XNP PREBITE RESCUE] bite_rollback=false infection_rollback=false heal=false`

```

## 0.5.43_PREBITE_TARGET_AND_QUOTA.md

- SHA-256: `33FCEE5FCBDAC9837F85598E37C466482F276B43AB319F290B1914D4AED310F2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Pre-Bite Target And Quota

Pre-Bite Jog Rescue selects targets from the shared threat snapshot only.

Target rules:

- Maximum selected targets: 3.
- Candidate radius: `<=1.05`.
- Object identity dedupe is used.
- Dead/fake-dead zombies are rejected.
- Non-zombie objects are rejected.
- Player/NPC/Bandits/animals are rejected by `instanceof(obj, "IsoZombie")`.
- No coordinate writes are performed.
- No forced kill is performed.

Sort order:

1. Attacking/grab/bite state first.
2. Distance ascending.
3. Dot descending.
4. Closing frames descending.

Effect rules:

- Target 1 and 2: verified stagger/knockdown route is allowed.
- Target 3: stagger-only route via `CONTACT`; it does not consume ordinary knockdown quota.
- Target 4 and farther are ignored.
- Vehicle, JogBump, Dragdown, and global quota are not widened.

Status:

- `PREBITE_MAX_TARGETS=3`
- `THIRD_TARGET_STAGGER_ONLY=true`
- `LOCAL_WORLD_SCAN=false`

```

## 0.5.43_REAL_GAME_EVIDENCE.md

- SHA-256: `FD7B83EA147C8546093C48D10B23CB8FA81D60CCF9BAF06E1461BFF45DBAD21A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Real Game Evidence

Frozen evidence from the latest user console notes:

- 0.5.42 was recognized and loaded by the game:
  - `loading XNP_PZ_DistanceRunnerTrait`
  - `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0542_EXACT_VEHICLE_ADMISSION_EQUIVALENCE_A`
  - `loaded version=0.5.42`
  - `OnPlayerUpdate` registered successfully
  - `FoodReserveConversion`, `PerformanceScheduler`, and `SprintVehicleImpact` loaded successfully.
- Current direct Food conversion was still 1:1:
  - `endurance_delta=0.0102`
  - `food_reserve_delta=-0.0102`
- Blue locomotion hunger conversion still emitted `ratio=0.25`; this is the old refund-hunger route and must not double-charge with the 0.5.43 tiered pulse.
- Death chain evidence:
  - `f12585 endurance_before=0.1383 FATAL_SURROUNDED cost=0.2400` dropped endurance to 0.
  - `f12723 endurance_before=0.0712 FATAL_SURROUNDED cost=0.3200` dropped endurance to 0 again.
  - Multiple frames showed `movement=hitreaction-bite`.
  - The skill knocked/staggered 2 targets, but near-ring pressure showed 3+ threats.
  - `close_1_20` reached 3 and `close_1_65` reached 6.
  - Final reset included `window_reset reason=player_death`.
- No bite rollback, infection rollback, or healing was confirmed. Once `hitreaction-bite` begins, rescue is too late and must not undo damage.
- External load was high:
  - Bandits around 23-1.
  - Zombies around 451-130 while target count displayed 50.
  - Many Bandits spawn, `WalkTowardState`, item blacklist, and other-mod warnings.

Conclusion: 0.5.43 must reduce log pressure and avoid new scans. The new fixes focus on tiered food recovery, pre-bite jog rescue, emergency cost floor, and direct install structure.

```

## 0.5.43_SINGLE_FOOD_WRITER_CONTRACT.md

- SHA-256: `87290C3017BA54A685D1E254E584EF28704E2ABCD7ECD9B4C7A33ACED72C7F8D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Single Food Writer Contract

0.5.43 uses one active food-spend writer:

`TieredFoodRecovery -> Authority.ApplyTieredFoodPulse`

Compatibility retained:

- `FoodReserveConversion.NotifyDiscreteCost` remains available for skill-cost protection windows.
- `FoodReserveConversion.ApplyDiscreteCost` remains available for explicit discrete hunger costs.
- `FoodReserveConversion.Tick` returns false while `ENABLE_TIERED_FOOD_RECOVERY=true`, so the old 1:1 direct transfer is not active.
- `LongMigrationStaminaAssist` keeps locomotion endurance refund behavior but `applyHungerCost` returns 0 unless `OLD_HUNGER_CONVERSION_COST_ACTIVE=true`.

Contract values:

- `ACTIVE_FOOD_SPEND_WRITER_COUNT=1`
- `OLD_HUNGER_CONVERSION_COST_ACTIVE=false`
- `TIERED_FOOD_RECOVERY_ACTIVE=true`
- `CLIENT_DIRECT_HUNGER_WRITE=0 for the tiered food path`
- `CLIENT_DIRECT_ENDURANCE_WRITE=0 for the tiered food path`

The preserved locomotion refund route is not a food-spend writer in 0.5.43.

```

## 0.5.43_TIERED_FOOD_RECOVERY_SPEC.md

- SHA-256: `D5D0FDABA43BE2F7D3C1FDB4B8DFE82DC134EBBF07CCDECF4E96BE662B13DC58`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 Tiered Food Recovery Spec

Runtime module:
`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_TieredFoodRecovery.lua`

Authority write path:
`XNP_DR_Authority.ApplyTieredFoodPulse`

Rules implemented:

- Pulse interval uses real time: `FOOD_RECOVERY_PULSE_SECONDS=2.0`.
- At most one pulse is applied per scheduler tick. No low-FPS catch-up burst.
- After a pulse, `nextDue = now + pulseSeconds`.
- Green state stops direct conversion and does not emit a delayed catch-up pulse.
- Blue pulse: food reserve `-0.005`, endurance `+0.015`.
- Yellow pulse: food reserve `-0.010`, endurance `+0.020`.
- Red pulse: food reserve `-0.010`, endurance `+0.020`.
- Minimum food reserve is clamped to `>=0.40`.
- Endurance is clamped to `<=1.00`.
- Final partial pulse scales food and endurance together, preserving each band's ratio.
- Discrete skill-cost window blocks food pulse for 1000 ms.
- Debug pulse logs are disabled unless `Config.DEBUG=true`.

Status:

- `TIERED_FOOD_RECOVERY_ACTIVE=true`
- `ACTIVE_FOOD_SPEND_WRITER_COUNT=1`
- `OLD_HUNGER_CONVERSION_COST_ACTIVE=false`
- `DOUBLE_FOOD_CHARGE=false`
- `DOUBLE_ENDURANCE_REFUND=false`

```

## 0.5.43_TRUE_DIRECT_INSTALL_TREE.md

- SHA-256: `FC87B8C8F6504822E4A3EF424558847A0BD7694C10035CA7A54894901832122E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.43 True Direct Install Tree

User drag folder:

`[LOCAL_PATH_REDACTED]`

Expected first layer:

```text
XNP_PZ_DistanceRunnerTrait
|-- 42
|-- mod.info
`-- poster.png
```

Validation:

- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_42_EXISTS=true`
- `TOP_LEVEL_MOD_INFO_EXISTS=true`
- `TOP_LEVEL_POSTER_EXISTS=true`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`

DIRECT_INSTALL is built from runtime files only. Development markdown, audit reports, commands, console logs, cache, backup files, Workshop files, preview files, and absolute-path documentation are not copied into the direct install folder.

```

## BUILD_MARKER.txt

- SHA-256: `49866C62865086E03741ABA21B1B6B5A2052E2A7FE4FAD8BB5CFB010FEA33084`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0543_TIERED_FOOD_PREBITE_DIRECT_INSTALL_A

```
