# 0.5.40 Sanitized Evidence Excerpts

## 0.5.40_0537_IMPACT_PATH_EXACT_DIFF.md

- SHA-256: `D7DE2ADB34DB8AFED4D6542AA486FEC2F181BC1684BEEFC17AB3897C42A0B37D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 0.5.37 Impact Path Exact Diff

Behavior baseline: `XNP_PZ_DistanceRunnerTrait_0.5.37_B42_RELEASE_BALANCE_WORKSHOP_PREP_SOURCE`.

`LEGACY_VERIFIED_0537_PATH` preserves evaluator values:

| Parameter | 0.5.37 | 0.5.40 |
|---|---:|---:|
| Precollision min/max distance | 1.05 / 2.05 | 1.05 / 2.05 |
| Precollision front dot | 0.68 | 0.68 |
| Precollision closing frames/delta | 2 / 0.015 | 2 / 0.015 |
| Precollision sprint speed | 3.25 | 3.25 |
| Vehicle min/max distance | 0.50 / 1.80 | 0.50 / 1.80 |
| Vehicle dot/closing frames | 0.60 / 1 | 0.60 / 1 |
| Vehicle sprint speed | 3.50 | 3.50 |
| Wall count | 3 | 3 |
| Quota targets/interval | 1 / 0.30 | 1 / 0.30 |
| Light kill targets | 2 | 2 |
| Light/wall base costs | 0.075 / 0.160 | 0.075 / 0.160 |

The central shared snapshot supplies bounded candidates, which the command explicitly permits. Evaluation, dot-then-distance ordering, mode selection, quota fallback and action effects use the legacy evaluator. `XNP_DR_ZombieVehicleImpact.lua` is byte-for-byte identical to 0.5.37.

- `SPRINT_PRECOLLISION_0537_EQUIVALENT=YES`
- `SPRINT_VEHICLE_0537_EQUIVALENT=YES`
- `WALL_IMPACT_0537_EQUIVALENT=YES`
- `TARGET_FILTER_0537_EQUIVALENT=YES`
- `RADIUS_0537_EQUIVALENT=YES`
- `DOT_0537_EQUIVALENT=YES`
- `SPEED_0537_EQUIVALENT=YES`
- `QUOTA_0537_EQUIVALENT=YES`
- `COOLDOWN_0537_EQUIVALENT=YES`
- `EFFECT_0537_EQUIVALENT=YES`
- `COST_ROUTE_0537_EQUIVALENT=YES`

No unverified collision event fast path is claimed. Sprint threat snapshots refresh every 50 ms.

```

## 0.5.40_COORDINATE_WRITE_REMOVAL.md

- SHA-256: `1C38CF87CBEDA597FB930E7CD9A43423ED3EDAD162B7C41190B6B5B9BE719998`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 Coordinate Write Removal

0.5.39 had two zombie coordinate writes in Breakout micro-nudge. The unused nudge implementation was removed; visible control continues through verified stagger/knockdown/hit reaction.

- `PLAYER_COORD_WRITE_COUNT=0`
- `ZOMBIE_COORD_WRITE_COUNT=0`
- `NPC_COORD_WRITE_COUNT=0`
- `ANY_MOVING_OBJECT_COORD_WRITE_COUNT=0`

Static grep covered method and plain-call forms of `setX`, `setY`, and `setZ` in all active Lua.

```

## 0.5.40_COST_CONSUMER_CONTRACT.md

- SHA-256: `B6A6F5E236D262D61CE0936F2C59D7951A57622C0E73C6B58B978E4E44F25EA8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 Cost Consumer Contract

Definitions:

- `SPRINT_PRECOLLISION_BASE_COST=0.0500`
- `SPRINT_VEHICLE_ZOMBIE_BASE_COST=0.0750`
- `ZOMBIE_IMPACT_DEFAULT=0.24`
- global multiplier default `1.00`
- route multiplier default `1.00`

Default calculations:

- SprintPrecollision: `0.0500 * 1.00 * 0.24 * 1.00 = 0.0120`.
- SprintVehicle zombie: `0.0750 * 1.00 * 0.24 * 1.00 = 0.0180`.

Real consumers:

- `XNP_DR_BreakoutPush.costForTrigger(SPRINT_PRECOLLISION)` passes the explicit base to `CostTuning.ComputeFinalCost`.
- `XNP_DR_SprintVehicleImpact.charge(LIGHT)` passes the explicit vehicle base to the same CostTuning route.

Wall Impact is fixed-baseline with `zombie=false`. NativeTrip and ControlledEscape also have `zombie=false`. Skill costs notify LongMigration so they are excluded from locomotion refund. Multipliers are applied once in `CostTuning.GetDetails`.

`DEFAULT_COST_CONTRACT_VALID=YES`

`DOUBLE_MULTIPLIER=NO`

```

## 0.5.40_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `D807A9ADA90CCDCE64574F634DCB239EBDA893F569B6C175AF3BBC9955F70A7B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 Gameplay Preserve Report

- Food: 30 to 40, reserve floor 40, 1:1, 1 percent/real second, Authority-only.
- Melee: 80 to 95 linear scaling, maximum 2.0, verified SP only, MP disabled.
- ZombieImpact: 0.24.
- SprintPrecollision default cost: 0.0120 through a real consumer.
- SprintVehicle zombie default cost: 0.0180 through a real consumer.
- Blue/Yellow/Red refund defaults: 30/38/55.
- Colors, shake drawing, drag, and state commit remain.
- Smooth refund/resource gate remain; action costs notify the no-refund window.
- Walk No Impact, Controlled Escape, JogBump, SprintVehicleImpact, NativeTrip, ActionBus, ImpactQuota and wall fixed-baseline routes remain.
- NativeTrip-only, JogBump direct consumer and no-double multiplier contracts remain.
- Bite, infection and heal writes: 0.
- Coordinate writes: 0.
- Sandbox CN/EN keys remain paired.

The Vehicle-only zero-health fallback is intentionally restored from the required byte-identical 0.5.37 module; the SP Melee bonus itself never calls `setHealth(0)` and cannot force a kill.

`GAMEPLAY_PRESERVE_STATUS=PASS_STATIC`

```

## 0.5.40_LEGACY_ENDURANCE_WRITE_INVENTORY.md

- SHA-256: `15757B5208FFA69962C5870465729836EA71C43CF9B4E122F700CFBFE0F65DD8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 Legacy Endurance Write Inventory

| File / function | Purpose | Present in 0.5.37 | Side | Type |
|---|---|---|---|---|
| BreakoutPush / ApplyCost | contact/precollision/escape action cost | yes | client/SP local player | discrete skill cost |
| EmergencyBreakoutCost / charge | emergency breakout cost | yes | client/SP local player | discrete skill cost |
| FallRecoveryInput / charge | fall recovery cost | yes | client/SP local player | discrete skill cost |
| JogBumpLaunch / charge | jog bump cost | yes | client/SP local player | discrete skill cost |
| LongMigrationStaminaAssist / SetEnduranceSafe | locomotion drain refund | yes | client/SP local player | continuous refund |
| SprintTripImmunity / charge | sprint trip protection cost | yes | client/SP local player | discrete skill cost |
| SprintVehicleImpact / charge | light/wall impact cost | yes | client/SP local player | discrete skill cost |

- `LEGACY_NON_FOOD_CLIENT_WRITES_DEFERRED=YES`
- `LEGACY_NON_FOOD_CLIENT_WRITE_COUNT=7`
- `NEW_NON_FOOD_CLIENT_WRITES=0`
- `FOOD_CLIENT_DIRECT_HUNGER_WRITES=0`

Food conversion and discrete Food hunger costs remain Authority-only and are not mixed with these legacy endurance routes.

```

## 0.5.40_MP_MELEE_DISABLED_CONTRACT.md

- SHA-256: `A1E338BA76CF0A02F76812A37A80D580CF87E2A333763BCA4DA6AE000647F5F4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 MP Melee Disabled Contract

- Pure SP registers `OnWeaponHitXp`.
- `isClient()==true` or `isServer()==true` rejects registration/settlement.
- No melee client prediction, client command, server command, or guessed MP event exists.
- Client and server processes each guard their own load path and log at most once:

`[XNP MELEE POWER] disabled_in_multiplayer=true reason=NO_VERIFIED_SERVER_DAMAGE_EVENT`

- CN/EN Sandbox tooltip states that this test build enables the feature only in single-player and disables it automatically in multiplayer.

`MP_MELEE_BONUS_ENABLED=NO`

`MP_MELEE_UNVERIFIED_NETWORK_MESSAGES=0`

```

## 0.5.40_PERFORMANCE_PRESERVE_REPORT.md

- SHA-256: `4A8A686E4D861B6C62AAAC8D729107BD62D02594CADB0148F1DE7CAEE0C5BE1B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 Performance Preserve Report

- `MODULE_LOCAL_WORLD_SCAN_COUNT=0`
- `CENTRAL_SCHEDULER_COUNT=1`
- `SHARED_THREAT_SNAPSHOT=YES`
- `CANDIDATE_CAP=16`
- `FULL_ZOMBIE_SCAN_DEFAULT=NO`
- `FULL_SORT=NO` (Sandbox key hash sort is not a world candidate sort)
- `DISTANCE_SQUARED_PREFILTER=YES`
- `SPRINT_ACTIVE_THREAT_INTERVAL_MS=50`
- `CRITICAL_SINGLE_MS<=1000`
- `CRITICAL_MAX_TOTAL_MS<=2000`
- `CRITICAL_SELF_REFRESH_BLOCKED=YES`
- `BLOCKED_DIRECT_PRINT_COUNT=0`
- `DEBUG_DEFAULT=false`

The unused 0.5.39 immediate-refresh API was removed; no collision-event fast path is claimed.

```

## 0.5.40_RENDER_PRINT_REMOVAL.md

- SHA-256: `6949D57C2DEB05D4F2FBC4BF69C288DBE4423310FDC190069AA7269D11E1F776`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 Render Print Removal

- `RENDER_PRINT_BEFORE=4`
- `RENDER_PRINT_AFTER=0`

`Panel:render` no longer calls the potentially logging `loadTextures`; textures are loaded during UI creation and render checks cached handles. Render/prerender contain no world scan, SandboxVars read, stat write, melee calculation, or threat classification. Shake offsets and drawing behavior remain.

```

## 0.5.40_SP_MELEE_EVENT_ORDER_VERIFICATION.md

- SHA-256: `24D66F4396F7D2BAC5AD7B35FCA9A0DC6AC591FFE6F895CC33492AF0C28847B7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 SP Melee Event Order Verification

Evidence source: local B42.19.0 `projectzomboid.jar`, class `zombie.CombatManager`, inspected read-only with `javap`.

Verified sequence:

1. `applyRangeHitLocationDamage(...)` produces float `f34`.
2. `IsoMovingObject.Hit(weapon, attacker, f34, ...)` is called; its return is stored separately as `f39`.
3. Only when both `GameClient.client` and `GameServer.server` are false, `OnWeaponHitXp` is emitted.
4. Event arguments are `(attacker, HandWeapon, hitObject, f34, 1)`.

Contract used by 0.5.40:

- event: `OnWeaponHitXp`;
- side: pure single-player only;
- order: post-`Hit`;
- base input: engine-computed, range/location-adjusted `f34`, not the `Hit()` return and not claimed as a pre/post health delta;
- bonus: subtract only `(baseInput * (multiplier - 1))`, clamp target health to `0.0001`, and reject an already-dead target;
- classifier: trait player + living IsoZombie + verified non-ranged HandWeapon;
- token: SP side, attacker, target, weapon, hit count and 100 ms bucket; TTL 2 seconds.

`SP_MELEE_EVENT_ORDER_VERIFIED=YES`

`SP_MELEE_BASE_DAMAGE_SOURCE_VERIFIED=YES_ENGINE_COMPUTED_INPUT`

```

## BUILD_MARKER.txt

- SHA-256: `3E27F8CE0DC328E3CF030DD9E37BE101D02DB344D200AE15C3F9924C048B8801`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0540_SP_MELEE_EQUIVALENCE_REPAIR_A

```

## FINAL_REPORT.md

- SHA-256: `0C83567A5F7AA9D48910744B8173F52AE31878662DC62C8F4583DAD7FCD751D8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

1. SOURCE: `[LOCAL_PATH_REDACTED]`.
2. DIRECT_INSTALL: `[LOCAL_PATH_REDACTED]`.
3. SP Melee: verified post-Hit `OnWeaponHitXp`, engine-computed damage input, strict classifier, two-second token.
4. MP Melee: disabled on client/server processes, no prediction or network messages.
5. Impact: `LEGACY_VERIFIED_0537_PATH`; frozen thresholds match and ZombieVehicleImpact is byte-identical to 0.5.37.
6. Costs: real consumers produce 0.0120 and 0.0180 defaults through unified CostTuning.
7. Coordinates: 2 to 0 writes.
8. Render prints: 4 to 0; render uses cached textures and drawing-only state.
9. Legacy endurance: seven deferred non-Food client sites, zero new sites.
10. Performance: one scheduler, no local scans/full list/full sort, cap 16, sprint threat 50 ms, bounded CriticalWindow.
11. DIRECT_INSTALL: 71 runtime files, zero development artifacts, zero hash mismatches.
12. Old SOURCE modified: no.
13. PZ/Steam launched: no. User mods/saves/Workshop/game directory written: no.

`BLOCKER=NONE_STATIC`

Real-game SP behavior remains user-tested work; MP Melee is intentionally disabled by contract.

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.40_SOURCE_READY_FOR_DIRECT_INSTALL_TEST`

```

## 0.5.40_DIRECT_INSTALL_VALIDATION.md

- SHA-256: `0F9E5A2F8C69F91CC1C511645B2BF38CD3E2A0067CF264F54B60B3E49E6DE0B2`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.40 Direct Install Validation

Folder: `[LOCAL_PATH_REDACTED]`

- top level: `42`, `mod.info`, `poster.png`;
- runtime files: 71;
- SOURCE runtime SHA256 mismatches: 0;
- Markdown/development reports: 0;
- `workshop.txt`: 0;
- `preview.png`: 0;
- `Contents` wrapper: 0;
- console/cache/backup artifacts: 0;
- active old version residue: 0;
- absolute path leaks in runtime text: 0.

No installation or user/game-directory write was performed.

`DIRECT_INSTALL_STATUS=PASS_STATIC`

```
