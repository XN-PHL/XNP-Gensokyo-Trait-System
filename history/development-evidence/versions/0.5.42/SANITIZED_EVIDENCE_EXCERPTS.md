# 0.5.42 Sanitized Evidence Excerpts

## 0.5.42_0537_END_TO_END_TARGET_SET_PROOF.md

- SHA-256: `6BCDAC5D64D00D1C2DA9C71CD5EF1BBBA8E36CCF464755C6CC7B4CB70BB0A9C1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 0.5.37 End-to-End Target Set Proof

## Source Completeness

The shared raw scan covers 2.05 tiles, a superset of the 0.5.37 Vehicle 1.80 bound. It has no pre-ranking count cap and deduplicates object references. Therefore every local object the 0.5.37 Vehicle scan could inspect is available.

## Route Equivalence

Before any Vehicle history mutation, the evaluator applies the same inclusive 0.50/1.80 distance window. It then calculates dot, updates the same closing relation with delta 0.015, requires dot 0.60 and closing 1, and ranks dot descending then distance ascending.

The first ranked target alone enters ActionBus and quota, matching 0.5.37. LIGHT still affects at most two ranked targets; WALL count remains 3.

## Frozen Values

- speed: 3.50
- distance: 0.50 to 1.80
- dot: 0.60
- closing frames: 1
- closing delta: 0.015
- wall count: 3
- quota: 1 per 0.30 seconds
- LIGHT effect targets: 2

RAW_SOURCE_CONTAINS_ALL_0537_TARGETS=true
NO_PRE_RANK_TARGET_LOSS=true
HISTORY_ADMISSION_0537_EQUIVALENT=true
ELIGIBILITY_0537_EQUIVALENT=true
COMPARATOR_0537_EQUIVALENT=true
ACTIONBUS_ADMISSION_0537_EQUIVALENT=true
QUOTA_0537_EQUIVALENT=true
EFFECT_0537_EQUIVALENT=true
COST_0537_EQUIVALENT=true
END_TO_END_TARGET_SET_0537_EQUIVALENT=YES_STATIC
RUNTIME_RESULT=NOT_VERIFIABLE_BY_STATIC_AUDIT


```

## 0.5.42_0537_VEHICLE_PIPELINE_ORDER.md

- SHA-256: `1EBFCBCD3BE69E27E19FA03D5824DDCEECF857C8D8C3C9555E8E73B1A1B00427`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 0.5.37 Vehicle Pipeline Order

The evaluator executes this indivisible order:

1. Apply the 0.5.37 config/trait/speed/isSprinting run gate.
2. Apply MovementIntentGate and NativeTripWindow checks.
3. Claim the same-tick RawLocalImpactCandidates pool.
4. Deduplicate by object reference.
5. Filter type/alive/basic validity.
6. Calculate distance.
7. Admit only 0.50 through 1.80.
8. Calculate dot.
9. Read/write closing history only for the distance-admitted set.
10. Require dot >= 0.60 and closing >= 1.
11. Rank dot descending, then distance ascending.
12. Select mode and first target.
13. Submit only the first target to ActionBus.
14. Apply quota to the first target.
15. Resolve LIGHT or WALL mode.
16. Apply the unchanged effect.
17. Apply the unchanged cost route.

DISTANCE_FILTER_BEFORE_HISTORY=true
HISTORY_BEFORE_CLOSING_FILTER=true
RANK_BEFORE_ACTIONBUS=true
ACTIONBUS_BEFORE_QUOTA=true
QUOTA_BEFORE_EFFECT_AND_COST=true
VALIDATE_EXACT_ORDER_API=true


```

## 0.5.42_0537_VEHICLE_RUN_GATE_DIFF.md

- SHA-256: `76CED0CA89ABDE958BA8740EDD1AC860A3A1FF7CFDE140BF77CF1827635C159F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 0.5.37 Vehicle Run Gate Diff

| Condition | 0.5.37 | 0.5.41 | 0.5.42 | Equivalent |
|---|---|---|---|---|
| Feature enabled, valid trait player | Vehicle Update | Vehicle Update | Evaluator.ShouldRun | Yes |
| Vehicle-local coordinate speed sample | playerSpeed | playerSpeed | evaluator playerSpeed | Yes |
| Speed >= 3.50 | required | required | required | Yes |
| isSprinting == true | required | required; also incorrectly used as shared raw-build-only gate | required by Vehicle only | Yes |
| MovementIntentGate.CanSprintVehicle | after speed/sprint | after speed/sprint | after speed/sprint | Yes |
| NativeTripWindow inactive | after movement gate | after movement gate | after movement gate | Yes |
| Candidate collection | after all gates | shared snapshot | evaluator claims same-tick raw pool after all gates | Yes |

Evidence:

- 0.5.37 `XNP_DR_SprintVehicleImpact.lua:208-234`
- 0.5.42 `XNP_DR_VehicleLegacy0537Evaluator.lua:142-157,269-294`

The 0.5.37 **Vehicle** gate is genuinely speed >= 3.50 **and** `isSprinting`. The 0.5.41 blocker concerned using strict `isSprinting` as the shared raw-pool gate, which also starved Precollision/Contact paths. In 0.5.42, the raw pool uses `BreakoutPush.HasMovementIntent` with a speed/sprint fallback; Vehicle still applies its exact stricter route gate internally.

VEHICLE_RUN_GATE_0537_EQUIVALENT=YES
STRICT_ISSPRINTING_ONLY=false
STRICT_ISSPRINTING_ONLY_FOR_SHARED_RAW_POOL=false
VEHICLE_ROUTE_REQUIRES_ISSPRINTING=true_0537_EXACT


```

## 0.5.42_ACTIONBUS_LIGHT_ADMISSION_EQUIVALENCE.md

- SHA-256: `8F91092F3F960052243D8D8C5EB936CFEB9C0380337588CE58A923479A16E403`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 ActionBus LIGHT Admission Equivalence

0.5.37 determines mode from the complete eligible/ranked Vehicle set, selects `targets[1]`, and calls ActionBus with exactly `{ selected.zombie }`. Quota is attempted only after ActionBus accepts that first target.

0.5.42 restores the same sequence:

1. complete Vehicle eligibility;
2. dot/distance ranking;
3. mode selection;
4. first-target selection;
5. ActionBus CanStart with first target only;
6. ActionBus Accept with first target only;
7. quota Try with first target;
8. LIGHT/WALL resolution;
9. effect;
10. cost notification.

The LIGHT effect still applies to at most two ranked targets, as in 0.5.37. The ActionBus admission set is intentionally one target, also as in 0.5.37.

ACTIONBUS_SOURCE=SPRINT_VEHICLE
ACTIONBUS_EFFECT=KNOCKDOWN
ACTIONBUS_LIGHT_TARGET_COUNT=1
RAW_SNAPSHOT_DIRECT_ADMISSION=false
SAME_TARGET_ORDER_0537_EQUIVALENT=true
RECENTLY_KNOCKED_ORDER_0537_EQUIVALENT=true
QUOTA_ORDER_0537_EQUIVALENT=true
EFFECT_ORDER_0537_EQUIVALENT=true
COST_NOTIFICATION_0537_EQUIVALENT=true


```

## 0.5.42_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `32F4A4035BEB2ED4F1190E438A3FC6485B77A7D72603234B9A3EF105FCD7AC93`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 Gameplay Preserve Report

All runtime files outside the declared identity and Impact integration scope are byte-identical to 0.5.41. Unexpected non-scope runtime differences: 0.

Preserved:

- uncapped dedicated Impact raw snapshot;
- generic ThreatSnapshot cap16;
- identity dedupe and same-tick freshness;
- Food authority-only 30-to-40/floor40/1:1/1-percent-real-second behavior;
- verified SP Melee and disabled MP Melee settlement;
- Precollision final cost 0.0120;
- Vehicle final cost 0.0180;
- ZombieImpact 0.24;
- no double multiplier;
- Render print/world scan zero;
- coordinate writes zero;
- critical-window bounds;
- Sandbox CN/EN;
- Blue30, Yellow38, Red55;
- colors, shake, drag;
- Walk No Impact, Controlled Escape, JogBump, NativeTrip;
- non-Vehicle ActionBus routes and ImpactQuota;
- no bite, infection, or heal writes.

GAMEPLAY_PRESERVE_STATUS=PASS_STATIC
RUNTIME_GAMEPLAY_RESULT=NOT_VERIFIABLE_BY_STATIC_AUDIT


```

## 0.5.42_PERFORMANCE_PRESERVE_REPORT.md

- SHA-256: `7131A4A95FB20AEB520A15F7D69D975F1F4AD0D415C3CF8371C6B37D620DA57E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 Performance Preserve Report

- Raw local scan maximum radius remains 2.05.
- No loaded/global zombie list is used.
- No 200+ loaded-zombie full scan or sort exists.
- Only `PlayerSnapshot` and `ImpactCandidateSnapshot` query grid squares.
- The Vehicle evaluator has no world query.
- `PerformanceScheduler.RunVehicleEvaluator` is the evaluator's only execution call site.
- Impact raw construction is at most once per frame and uses the existing 0.05-second cadence.
- Vehicle history contains only targets admitted through the 0.50-to-1.80 window.
- Render performs no world scan.
- Blocked paths use throttled logging; direct blocked print count is zero.
- Debug remains false by default.

MODULE_LOCAL_WORLD_SCAN_COUNT=0
CENTRAL_SCHEDULER_COUNT=1
IMPACT_GLOBAL_LIST=false
RAW_LOCAL_SCAN_RADIUS=2.05
FULL_SORT_200_PLUS=false
RENDER_WORLD_SCAN_COUNT=0
BLOCKED_DIRECT_PRINT_COUNT=0
DEBUG_DEFAULT=false
PERFORMANCE_PRESERVE_STATUS=PASS_STATIC


```

## 0.5.42_TARGET_SET_SEPARATION.md

- SHA-256: `19979F7D6F1B250047E817FA477FB481910CDD870602DCC4CF5C28A2BAFE7C61`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 Target Set Separation

## Sets

- `RawLocalImpactCandidates`: deduplicated live-zombie raw pool scanned inside the maximum 2.05 local bound.
- `VehicleHistoryCandidates`: raw candidates that passed Vehicle 0.50-to-1.80 distance admission.
- `VehicleEligibleCandidates`: VehicleHistoryCandidates that passed 0.5.37 dot and closing checks, ranked by the 0.5.37 comparator.
- `PrecollisionEligibleCandidates`: candidates recorded only after the independent precollision evaluator accepts them.
- `ActionBusLightCandidates`: only the selected first Vehicle target when mode is LIGHT.

The raw set is never passed directly to Vehicle ActionBus, quota, effects, or costs.

RAW_SCAN_RADIUS_2_05_ONLY_BOUNDING=true
VEHICLE_HISTORY_SET_EQUALS_0537=true
VEHICLE_ELIGIBLE_SET_EQUALS_0537=true
ACTIONBUS_LIGHT_SET_EQUALS_0537=true
SHARED_RAW_SET_NOT_DIRECTLY_ADMITTED=true
VEHICLE_HISTORY_MIN=0.50
VEHICLE_HISTORY_MAX=1.80
RAW_ONLY_BAND=1.80_TO_2.05
RAW_ONLY_BAND_UPDATES_HISTORY=false


```

## 0.5.42_VEHICLE_HISTORY_NAMESPACE_AND_CLEANUP.md

- SHA-256: `B5550C7BECB583F99B87648E2761A1CD6EB7C64277E5EAD57553CE9591BF7D81`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 Vehicle History Namespace And Cleanup

Vehicle history is owned exclusively by `VehicleLegacy0537Evaluator`.

- Namespace: `0.5.42`
- Key: zombie object identity
- Initial table: a fresh module-local table
- Old `SprintVehicleImpact.history`: absent from the compatibility facade and never reused
- Admission: only after live/type validity and the inclusive 0.50-to-1.80 distance window
- Outside-window behavior: no history creation, write, refresh, or closing-delta update
- Invalid/dead behavior: removed while the evaluator performs history maintenance

The 0.5.37 source has no explicit time-based Vehicle history TTL. Therefore 0.5.42 does not invent a TTL that would alter re-entry behavior. A valid history entry may remain while temporarily outside the window, but it is not refreshed or mutated there. The fresh namespace prevents any 0.5.41 polluted entry from carrying into this version.

VEHICLE_HISTORY_NAMESPACE=0.5.42
OLD_RUNTIME_TABLE_REUSED=false
OBJECT_IDENTITY_KEY=true
COORDINATE_IDENTITY=false
OUT_OF_WINDOW_ADMISSION=false
OUT_OF_WINDOW_HISTORY_REFRESH=false
INVALID_TARGET_CLEANUP=true
REFERENCE_0537_EXPLICIT_TTL=NONE


```

## BUILD_MARKER.txt

- SHA-256: `1A05FB00EB11410673D493EFD301AB8781A156D29422E2C6E424E8CF243B6098`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0542_EXACT_VEHICLE_ADMISSION_EQUIVALENCE_A

```

## FINAL_REPORT.md

- SHA-256: `7572CB04A216C8D85B602F2FB6D804AAD8FFA7B6003009DE969BC915FC9D5167`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DIRECT_INSTALL_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.42
INTERNAL_VERSION=0.5.42-b42-exact-vehicle-admission-equivalence-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0542_EXACT_VEHICLE_ADMISSION_EQUIVALENCE_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.42 Exact Vehicle Admission Equivalence
MOD_ID=XNP_PZ_DistanceRunnerTrait

VEHICLE_DISTANCE_FILTER_BEFORE_HISTORY=true
VEHICLE_HISTORY_ADMISSION=0.50_TO_1.80_ONLY
RAW_SCAN_RADIUS=2.05_BOUNDING_ONLY
VEHICLE_RUN_GATE_0537_EQUIVALENT=YES
STRICT_ISSPRINTING_ONLY=false_for_shared_raw_pool
ACTIONBUS_LIGHT_SET_EQUALS_0537=true
HISTORY_NAMESPACE=0.5.42
OLD_HISTORY_REUSED=false
END_TO_END_TARGET_SET_0537_EQUIVALENT=YES_STATIC

PRE_RANK_DISTANCE_TRUNCATION=false
IDENTITY_DEDUPE_BEFORE_SORT_AND_QUOTA=true
IMPACT_SAMPLE_AND_EVALUATE_SAME_TICK=true
IMPACT_CROSS_TICK_CANDIDATE_REUSE=false
GENERIC_THREAT_CAP_16_PRESERVED=true
MODULE_LOCAL_WORLD_SCAN_COUNT=0
CENTRAL_SCHEDULER_COUNT=1

SPRINT_PRECOLLISION_DEFAULT_FINAL=0.0120
SPRINT_VEHICLE_DEFAULT_FINAL=0.0180
ZOMBIE_IMPACT_DEFAULT=0.24

OLD_SOURCE_MODIFIED=NO
PROJECT_ZOMBOID_STARTED=NO
STEAM_STARTED=NO
USER_MODS_WRITTEN=NO
SAVES_WRITTEN=NO
WORKSHOP_WRITTEN=NO
GAME_DIRECTORY_WRITTEN=NO
PACKAGED=NO
INSTALLED=NO
DIRECT_INSTALL_FILE_COUNT=73
DIRECT_INSTALL_SHA256_MISMATCH_COUNT=0
DIRECT_INSTALL_VALIDATION=PASS

LUA_5_1_EXECUTION=NOT_VERIFIABLE_BY_STATIC_AUDIT
PROJECT_ZOMBOID_RUNTIME=NOT_VERIFIABLE_BY_STATIC_AUDIT
MULTIPLAYER_RUNTIME=NOT_VERIFIABLE_BY_STATIC_AUDIT
BLOCKER=NONE_FOUND_BY_STATIC_AUDIT

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.42_SOURCE_READY_FOR_DIRECT_INSTALL_TEST

```

## 0.5.42_DIRECT_INSTALL_VALIDATION.md

- SHA-256: `0DA9011FF7677538758BC50AA89E07122B351441D987281D372D51EA334575AC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 Direct Install Validation

Expected target:

`[LOCAL_PATH_REDACTED]`

Allowed top-level entries are only:

- `42`
- `mod.info`
- `poster.png`

The final validation must compare every runtime file against SOURCE by SHA256 and reject Markdown, audit reports, Workshop files, preview assets, Contents wrappers, console logs, generated caches, backups, old-version residue, and absolute-path documentation.

DIRECT_INSTALL_FILE_COUNT=73
SOURCE_RUNTIME_FILE_COUNT=73
SHA256_MISMATCH_COUNT=0
FORBIDDEN_CONTENT_COUNT=0
OLD_VERSION_FILE_COUNT=0
ABSOLUTE_PATH_LEAK_COUNT=0
TOP_LEVEL_ENTRIES=42,mod.info,poster.png
DIRECT_INSTALL_VALIDATION=PASS

PACKAGED=NO
INSTALLED=NO
USER_MODS_WRITTEN=NO
GAME_DIRECTORY_WRITTEN=NO

```

## 0.5.42_FIX_FROM_0.5.41_AUDIT.md

- SHA-256: `2616DA6172EC5DC46B9374EEF484560E11C133EA9942ECB9A82AD701BF4C6C02`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.42 Fix From 0.5.41 Audit

0.5.42 repairs the four blockers identified by the 0.5.41 second-pass audit without retuning gameplay.

## Repairs

1. Vehicle candidates now pass the 0.50-to-1.80 distance window before any history read or write.
2. The shared 2.05 local snapshot is only a raw object pool. Vehicle history and eligibility sets are route-specific.
3. The shared Impact build gate uses the preserved Breakout movement-intent gate, while the Vehicle evaluator independently applies the exact 0.5.37 Vehicle gate.
4. Vehicle ActionBus admission again submits only the selected first target, before quota, exactly as 0.5.37.

## Runtime Ownership

The new `XNP_DR_VehicleLegacy0537Evaluator.lua` owns Vehicle speed sampling, history, filtering, ranking, ActionBus admission, quota, effects, and costs. `PerformanceScheduler.RunVehicleEvaluator` is its only execution call site. The old `XNP_DR_SprintVehicleImpact.lua` is a stateless no-op compatibility facade.

BLOCKER_0541_HISTORY_ORDER=FIXED
BLOCKER_0541_SHARED_RADIUS_HISTORY_POLLUTION=FIXED
BLOCKER_0541_SHARED_STRICT_SPRINT_GATE=FIXED
BLOCKER_0541_ACTIONBUS_LIGHT_SET=FIXED


```
