# 0.5.39 Sanitized Evidence Excerpts

## 0.5.39_BLOCKED_PRINT_GREP_BEFORE_AFTER.md

- SHA-256: `3EFA2D95E441ED7A1580075A12AFF6F32EF083F13AB7843B6931CF81502744BD`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Blocked Print Grep Before/After

- Required audit baseline: `BLOCKED_DIRECT_PRINT_BEFORE=52`.
- Final active Lua grep for direct `print(...)` containing blocked, false, or same-state text: `0`.
- Final: `BLOCKED_DIRECT_PRINT_AFTER=0`.
- `DEBUG_DEFAULT=false`.

Blocked/false/same-state paths call `Core.LogThrottle.Blocked(category, reason)`. The counter summary interval is at least ten seconds and zero-count entries are omitted. State edges, actual successes, and actual errors may still produce one event log. Render handlers contain no print call.

Note: a broader baseline regex that also matched unrelated wording found more than 52 lines; the frozen command baseline of 52 is retained for the requested before/after metric.

```

## 0.5.39_AUTHORITY_WRITE_PATH.md

- SHA-256: `F3100829F5AF6C277477BBD59C1D3B740F964EFAA70D5015816DE34D668599D7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Authority Write Path

## Side Rules

- Single-player: `isClient()==false` and `isServer()==false`; local process is authoritative.
- Host/dedicated multiplayer: client sends `XNPDistanceRunner` commands; only server handler calls Authority writes.
- Ordinary client: `Authority.ValidateFoodWritePath()` returns `CLIENT_STAT_WRITE_FORBIDDEN`.

## Runtime Path

1. `XNP_DR_FoodReserveConversion.lua` sends `foodTick` or `foodApplyDiscreteCost` in MP.
2. `XNP_DR_FoodAuthorityServer.lua` receives `Events.OnClientCommand(module, command, player, args)`.
3. `XNP_DR_Authority.lua` validates side, trait, finite/clamped amounts, and stat availability.
4. Server validates `syncPlayerStats`, obtains masks with `SyncPlayerStatsPacket.getBitMaskForStat(CharacterStat.ENDURANCE/HUNGER)`, writes, then synchronizes both fields.
5. A failed second write or failed sync attempts rollback and reports a stable failure reason.

Local evidence:

- `[LOCAL_PATH_REDACTED]` defines `OnClientCommand(module, command, player, args)`.
- Vanilla server Farming writes endurance and calls `syncPlayerStats(player, 0x00000002)`.
- Local jar exposes `SyncPlayerStatsPacket.getBitMaskForStat(CharacterStat)` and `CharacterStat.ENDURANCE/HUNGER`.

Results:

- `FOOD_CLIENT_DIRECT_ENDURANCE_WRITE_COUNT=0` for Food conversion.
- `FOOD_CLIENT_DIRECT_HUNGER_WRITE_COUNT=0` for Food conversion and discrete Food costs.
- Other client endurance writes are pre-existing gameplay costs/refunds, not Food conversion writes.
- `FOOD_NETWORK_DOUBLE_SETTLEMENT=false` by construction.
- `FOOD_STAT_WRITE_SIDE=AUTHORITATIVE_ONLY`.

```

## 0.5.39_BEHAVIOR_EQUIVALENCE_MATRIX.md

- SHA-256: `03847A5EA4D524412C24EAC1715DC5282E4AF95D9254B6313E4869EDB0E7E4D1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Behavior Equivalence Matrix

| Feature | 0.5.37 condition/effect | 0.5.39 source | Static comparison |
|---|---|---|---|
| MovementGate | trait movement gate | Runtime/Scheduler | logic retained; cadence changed |
| JogBump | direct jog consumer, native trip overflow | JogBumpLaunch | thresholds/cost route retained |
| SprintPrecollision | `0.0120` consequence cost | Breakout/Sprint modules | value retained; snapshot timing changed |
| SprintVehicleImpact | `0.0180` player cost | SprintVehicleImpact | value and target route retained |
| Wall Impact | fixed baseline | SprintVehicleImpact | fixed baseline retained |
| Controlled Escape | gated escape | Emergency/Dragdown breakout | effect and gates retained |
| NativeTrip | native-trip-only fallback | NativeTripWindow | retained |
| SprintTripConsequence | consequence on trip | SprintTripConsequence | retained via shared snapshot |
| ActionBus | quota/state coordination | BreakoutActionBus | retained |
| ImpactQuota | target/action limits | ActionBus and consumers | retained |
| Danger classifier | nearby threat classification | shared snapshot consumers | condition intent retained; candidate source changed |
| Outcome watchdog | player/zombie outcome checks | BreakoutPush | retained |

Frozen values still present: ZombieImpact `0.24`, SprintPrecollision `0.0120`, SprintVehicle `0.0180`, Blue `30`, Yellow `38`, Red `55`, Food `30->40` at `1%/s` and `1:1`, Melee `80->95` up to `2.0`.

Cannot prove complete equivalence:

- Central scheduling replaces several per-frame/local scans with cached bounded snapshots, so event timing and candidate availability are not mathematically identical.
- Vehicle Impact retains `Kill`, `DoDeath`, then knockdown fallback, but the 0.5.37 `setHealth(0)` fallback cannot be restored because this command explicitly forbids it.
- Collision-driven snapshot age/equivalence cannot be verified without a real-game run.

`BEHAVIOR_EQUIVALENCE=NOT_PROVEN`; mandatory BLOCKED.

```

## 0.5.39_CRITICAL_WINDOW_BOUND.md

- SHA-256: `C5B9EA7976CBDA40495E24FF4FDE87611D3EE8A0A70F83378629A0247F8CD39D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Critical Window Bound

`XNP_DR_CriticalWindow.lua` provides `Enter`, `Extend`, `IsActive`, and `Exit`.

- A single requested duration is clamped to at most 1000 ms.
- Total lifetime from entry is clamped to at most 2000 ms.
- Expiry automatically exits.
- Danger clear and sprint stop exit immediately through the scheduler.
- Persistent boolean state cannot extend the window every tick.
- Entry/extension is limited to verified evidence or state edges: sprint edge, nearby-count rise, on-floor edge, or explicit verified-event notification.
- Critical scheduler interval is no faster than 50 ms (20 Hz).

Results: `CRITICAL_UNBOUNDED=false`, `CRITICAL_SELF_REFRESH_BLOCKED=true`, `CRITICAL_MAX_TOTAL_MS=2000`.

```

## 0.5.39_FOOD_NORMALIZATION.md

- SHA-256: `10EDB40824E330043CBA8FBB335E83E16DD8AFFBEB35ABBD04E201D04C28F96A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Food Normalization

Frozen defaults:

- Trigger: 30 percent.
- Target: 40 percent.
- Minimum reserve: 40 percent.
- Rate: 1 percent endurance per real second.
- Ratio: 1:1 endurance to food reserve.

Runtime invariants:

- `0 < trigger < target <= 1`.
- `0.40 <= reserveFloor <= 0.95`.
- `rate > 0` and `ratio > 0`.
- Endurance is capped at target.
- Food reserve cannot cross below reserve floor.
- Elapsed real time is used; each stalled tick catches up at most two seconds and then advances `lastTick`.
- A discrete gameplay hunger cost records a delay so conversion cannot offset it in the same interval.
- Invalid Sandbox values are clamped/fallback-normalized and warnings use throttled counters.

Sandbox `MinimumFoodReservePercent`: min `40`, max `95`, default `40`.

```

## 0.5.39_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `6622A30A3BE220D398227E36595C9A7FCF3436CF45B9C456068DBA9652DB67A7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Gameplay Preserve Report

Preserved in active runtime/config:

- Food 30 to 40, 1:1, 1 percent per real second.
- Melee 80 to 95, maximum 2.0, zombie-only classifier.
- ZombieImpact 0.24; SprintPrecollision 0.0120; SprintVehicle 0.0180.
- Blue 30, Yellow 38, Red 55.
- Existing colors, shake, drag, state commit, smooth refund/resource gate.
- Walk No Impact, Controlled Escape, JogBump, SprintVehicleImpact, NativeTrip, ActionBus, ImpactQuota.
- Wall fixed baseline, NativeTrip-only fallback, JogBump direct consumer, no-double multiplier.
- No bite/infection/heal mutation and no GameTime multiplier.
- Server-authoritative Sandbox and `client override=false` behavior.

Position audit: no player coordinate write exists. Breakout retains an existing zombie-only micro-nudge guarded by a destination passability check.

Static preservation does not prove exact in-game timing/effect equivalence after scheduler refactoring. See the behavior matrix; status remains BLOCKED.

```

## 0.5.39_MELEE_CLASSIFICATION.md

- SHA-256: `385AEC032EC4F4886DADB60AB349135F1799989C0CBF277050C3161674C583A3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Melee Classification

Accepted only when all conditions hold:

- attacker is `IsoPlayer`, not NPC, not in a vehicle, and has the Distance Runner trait;
- target is a living `IsoZombie`;
- weapon is a B42 `HandWeapon`;
- `weapon:isRanged()` is explicitly false;
- attack is not shove/stomp/grapple;
- weapon is not BareHands, a physics/thrown object, or an aimed firearm.

This excludes ranged, firearm, projectile/thrown, vehicle/running impact, push/shove, stomp, unarmed, trap, fire, explosion, and environmental routes. Classification relies on runtime type/method checks wrapped by protected calls, not weapon-name blacklists.

Frozen tuning: endurance 80 percent to 95 percent, linear multiplier up to 2.0, zombie target only.

```

## 0.5.39_MELEE_EVENT_CONTRACT_VERIFICATION.md

- SHA-256: `7E66560CD117EFB5C4457712FA3F008965AC4E430D3368FBEB5392CA54AE5C19`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Melee Event Contract Verification

Verified local build: Project Zomboid B42.19.0, `projectzomboid.jar` and shipped Lua read-only.

## Event And Signature

- Vanilla `media/lua/server/XpSystem/XpUpdate.lua` uses `OnWeaponHitXp(owner, weapon, hitObject, damage, hitCount)`.
- `CombatManager` bytecode supplies attacker, HandWeapon, hit object, computed damage float, and hit-count integer.
- The event occurs after damage calculation but its suitability as a final authoritative bonus-damage settlement point is not proven for every melee route.

## Authority Finding

`CombatManager` bytecode branches around `OnWeaponHitXp` when `GameClient.client` is true and also when `GameServer.server` is true. Therefore the event is single-player only in this build. It is not an MP server-authority event and cannot satisfy the requested multiplayer contract.

## Result

- Actual event name/signature: verified for single-player.
- Base damage argument: computed hit damage is supplied, but final settlement ordering is not fully proven.
- MP authority: unavailable on this event.
- Client/server duplicate behavior: event is skipped in MP rather than authoritatively emitted once.

`MELEE_EVENT_MP_AUTHORITY=NOT_AVAILABLE`

This is a mandatory blocker. No guessed replacement event was added.

```

## 0.5.39_MELEE_MP_DUPLICATE_GUARD.md

- SHA-256: `86F6CE529B28A59808980547BE2445EFE2FF3894492CC96C22D967DEFA8EEBF9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Melee MP Duplicate Guard

Implemented single-player hit token fields:

- authority side (`SP_AUTHORITY`);
- attacker identity;
- target identity;
- weapon identity;
- verified event hit count;
- 100 ms time bucket.

Token TTL is two seconds, expired entries are removed, and duplicate tokens are rejected before extra damage. Dead/non-zombie targets and non-melee routes are rejected. The implementation does not repeat XP, kill calls, attack animations, or modify global weapon templates. It never uses `target:setHealth(0)`.

The guard is structurally present, but MP correctness cannot be claimed because the verified event does not run on the MP server. `MP_DUPLICATE_GUARD_END_TO_END=NOT_VERIFIABLE_WITH_SELECTED_EVENT`.

```

## 0.5.39_MODULE_SCAN_REMOVAL_MAP.md

- SHA-256: `AB145573D843FD76C0744B9654731E44A82541DC1FC955C2FD9DA66436C955D9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Module Scan Removal Map

All gameplay consumers now read `Core.ThreatSnapshot`/`Core.PlayerSnapshot`. Mapping:

| Requested area | Snapshot consumer |
|---|---|
| MovementGate / ControlledCheck | PerformanceScheduler light snapshot |
| DragdownDanger / AutoDragdown | Dragdown classifiers and breakout modules |
| JogBump | JogBumpLaunch |
| SprintPrecollision / ContactGate | BreakoutPush |
| SprintVehicleImpact | SprintVehicleImpact |
| Breakout / EmergencyHeld | Breakout and emergency modules |
| ImpactQuota | Shared selected target identities |
| SprintImmunity | SprintTripImmunity |
| OutcomeWatchdog | Shared tracked targets/state |

Static results:

- Baseline broad world-query lines: 28 across independent modules.
- `MODULE_LOCAL_WORLD_SCAN_COUNT=0` in 0.5.39 candidate consumers.
- `CENTRAL_GAMEPLAY_SCHEDULER_COUNT=1` (`Events.OnPlayerUpdate.Add(Core.Runtime.Update)`).
- `FULL_ZOMBIE_SCAN_DEFAULT=NO`.
- `CANDIDATE_CAP=16`.
- `FULL_SORT=false`; the remaining `table.sort` sorts Sandbox keys for a config hash, not world candidates.
- `DISTANCE_SQUARED_PREFILTER=true`.

The one Breakout `getGridSquare` outside PlayerSnapshot validates a single zombie micro-nudge destination. It does not enumerate or rebuild candidates and is not a local world scan.

```

## 0.5.39_SANDBOX_CN_SYNTAX_REPAIR.md

- SHA-256: `71E31D31F508D20189273566DDCE56FB6AB6033EA05F1B6E7B94AAB2E5149D8B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.39 Sandbox CN Syntax Repair

UTF-8 static validation results:

- `ORIGINAL_ODD_QUOTE_LINES=35` (frozen audit baseline).
- `FINAL_ODD_QUOTE_LINES=0`.
- `SMART_QUOTE_HITS=0`.
- `MALFORMED_LINES=0` (excluding the required `Sandbox_CN = {` table header).
- `DUPLICATE_KEYS=0`.
- `CN_ONLY_KEYS=0`.
- `EN_ONLY_KEYS=0`.
- `EMPTY_KEYS=0`.
- `EMPTY_VALUES=0`.

CN and EN each contain 83 parsed assignment keys. Values use paired ASCII double quotes. No hard-coded Chinese Lua fallback or duplicate translation tree was added.

```

## BUILD_MARKER.txt

- SHA-256: `56BFE60F00BB33EE32BA6FD0E124CD07E75CD56FE0284F93242439652542F728`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0539_AUTHORITY_SCHEDULER_RUNTIME_REPAIR_A

```
