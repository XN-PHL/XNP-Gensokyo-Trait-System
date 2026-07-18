# 0.5.41 Sanitized Evidence Excerpts

## 0.5.41_0537_TARGET_SET_EQUIVALENCE.md

- SHA-256: `20A615FF12008D176BEA908B42B53C715A1D2837B70C2BA6E97985DA79BF4846`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 0.5.37 Target-Set Equivalence

## Verified Constants

The 0.5.41 configuration retains the 0.5.37 Impact values:

| Contract | Value |
|---|---:|
| Precollision scan radius | 2.05 |
| Precollision min/max distance | 1.05 / 2.05 |
| Precollision forward dot | 0.68 |
| Precollision closing frames | 2 |
| Precollision sprint min speed | 3.25 |
| Precollision min distance delta | 0.015 |
| Vehicle min/max distance | 0.50 / 1.80 |
| Vehicle forward dot | 0.60 |
| Vehicle closing frames | 1 |
| Vehicle sprint min speed | 3.50 |
| Wall count | 3 |
| Quota | 1 per 0.30 seconds |
| Light target limit | 2 |

## Comparator and Effects

- Sprint precollision retains the existing full-set dot-first candidate ordering.
- Sprint vehicle impact calls `LegacyVerified0537Path.InsertVehicleCandidate`, preserving dot descending and distance ascending.
- Quota and target limits remain after sorting.
- `XNP_DR_ZombieVehicleImpact.lua` is byte-for-byte identical to 0.5.40 and was already verified against the 0.5.37 reference.
- Cost inputs remain 0.0500 x 0.24 = 0.0120 and 0.0750 x 0.24 = 0.0180.

The repair restores target-set completeness before the frozen evaluator. It does not change eligibility thresholds, ranking semantics, effects, costs, cooldowns, or quota values.

TARGET_SET_PRECAP=NONE
0537_EVALUATOR_EQUIVALENCE=STATICALLY_CONFIRMED
0537_RUNTIME_OUTCOME=NOT_VERIFIABLE_BY_STATIC_AUDIT


```

## 0.5.41_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `59BAC5CAF01F9C115595061C992012E97AE45D115FFF31738D2A62558F5AF1DA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 Gameplay Preserve Report

## Byte-Identical 0.5.40 Systems

Static SHA256 comparison confirms no change to:

- Food reserve conversion and Food authority server;
- single-player Melee classifier/power and multiplayer guard;
- Sandbox tuning and CN/EN Sandbox translations;
- status icon rendering, position, and dragging;
- long-migration stamina support;
- shared Config and CostTuning;
- zombie vehicle-impact effect implementation.

## Preserved Contracts

- Food authority-only behavior, 30 to 40 percent floor, 1:1 conversion, and 1 percent per real second.
- SP Melee event contract and automatic MP Melee disable.
- ZombieImpact default 0.24 and Blue/Yellow/Red values 30/38/55.
- Walk No Impact, Controlled Escape, JogBump, NativeTrip, ActionBus, and ImpactQuota.
- No bite/infection/heal changes.
- No player or zombie coordinate writes were introduced.
- No Render scan or Render print route was introduced.
- Seven legacy endurance-write sites remain inventoried and unchanged.

Only the central Impact candidate acquisition path and its two consumers changed.

GAMEPLAY_PRESERVE_STATIC_RESULT=PASS
GAMEPLAY_PRESERVE_RUNTIME_RESULT=NOT_VERIFIABLE_BY_STATIC_AUDIT


```

## 0.5.41_IMPACT_IDENTITY_DEDUPE.md

- SHA-256: `D689D5D3D9B5D4D29A012B482573800BE4541E4681F4B4F173893A0CC63FEE2C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 Impact Identity Dedupe

## Identity Contract

The same-tick Java/Lua object reference is the identity key:

```lua
if seen[obj] then
    duplicates = duplicates + 1
else
    seen[obj] = true
    uniqueObjects[#uniqueObjects + 1] = obj
end
```

No coordinate string, outfit, display name, array index, or mutable position is used as zombie identity. Two distinct zombie objects remain distinct even when their coordinates overlap.

## Ordering

Deduplication occurs before:

- live-zombie filtering;
- distance/dot calculation;
- comparator insertion;
- quota;
- ActionBus acceptance;
- effect, kill, and cost settlement.

The Impact snapshot admits each object reference once. ActionBus receives the actual target set, and ImpactQuota receives the selected target only after ranking, preventing one object from occupying a route twice.

IDENTITY_MODE=OBJECT_REFERENCE_OR_VERIFIED_ID
DEDUPE_BEFORE_SORT=true
DEDUPE_BEFORE_QUOTA=true
COORDINATE_IDENTITY=false
DUPLICATE_EFFECT=false
DUPLICATE_COST=false


```

## 0.5.41_IMPACT_PIPELINE_ORDER_DIFF.md

- SHA-256: `D0F4C6084EADADFF497537A0937084A5EF671AE0DDE39C5591A629188A7DB0A3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 Impact Pipeline Order Diff

## Before: 0.5.40

1. Central generic ThreatSnapshot scanned local moving objects.
2. Generic nearest-distance ordering and cap 16 were applied.
3. Impact consumers received the already truncated list.
4. The 0.5.37 Impact dot/distance comparator ran only on survivors.
5. Quota and target limits ran afterward.

This allowed a nearer but poorly aligned object to occupy the generic cap while a better forward collision candidate was discarded before Impact ranking.

## After: 0.5.41

1. The central scheduler scans only local grid squares inside the maximum configured Impact radius.
2. Raw object references are deduplicated.
3. Live `IsoZombie` filtering is applied.
4. Every eligible local candidate reaches the consumer without a count cap.
5. The existing 0.5.37 distance, dot, and movement-relation calculations run for the complete eligible set.
6. The existing 0.5.37 dot-descending, then distance-ascending comparator ranks the set.
7. Existing quota and target limits run after ranking.
8. Existing effect and cost routes execute.

PRE_RANK_DISTANCE_TRUNCATION=false
RANK_BEFORE_QUOTA=true
0537_COMPARATOR_REUSED=true
0537_FILTER_ORDER_REUSED=true
GENERIC_THREAT_CAP_16_PRESERVED=true


```

## 0.5.41_IMPACT_SAME_TICK_FRESHNESS.md

- SHA-256: `D9EDEC4E666076225367F43BDAD0D3861FF7643167889FCCF78000F28AC64564`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 Impact Same-Tick Freshness

## Contract

Impact freshness is frame based, not wall-clock-age based:

- `BuildNow` records the current `PlayerSnapshot.frame`.
- A second build request in the same frame reuses that same-frame build only.
- `ValidateFreshSameTick` accepts candidates only when sample frame equals current frame.
- `ClaimEvaluation(route)` permits one evaluation claim per route and sample frame.
- `GetCandidates` returns an empty list for stale frames.
- The next eligible scheduler frame rebuilds from current local moving objects.

No Impact candidate list, position, dot, or distance snapshot is reused across frames. The existing 0.5.37 closing-history relation remains evaluator state needed to detect consecutive approach; it is not a cached candidate set and does not bypass same-frame sampling.

At low FPS the contract remains frame-correct: the evaluator uses the frame actually sampled and does not invent intermediate movement.

IMPACT_SAMPLE_AND_EVALUATE_SAME_TICK=YES
IMPACT_CROSS_TICK_CACHE_REUSE=NO
LOW_FPS_CONTRACT=FRAME_CORRECT
WALL_CLOCK_50MS_PROMISE=REMOVED


```

## 0.5.41_PERFORMANCE_BOUNDARY.md

- SHA-256: `C2A1574114D62C56781050F93B12C01B2FCE837B151C49B67374BF097A30A775`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 Performance Boundary

## Bounded Work

- Impact construction runs only while the trait player is sprinting.
- It is requested only by the single central PerformanceScheduler.
- The requested cadence is 0.05 seconds, with a maximum of one build in a `PlayerSnapshot.frame`.
- The scan covers local grid squares intersecting the maximum Impact radius, currently 2.05 tiles.
- It reads each square's moving-object collection.
- It never reads a global loaded-zombie list.
- It ranks only local, deduplicated, live zombie candidates.
- Render code performs no scan.

## Preserved Generic Path

Non-Impact systems continue using the bounded generic ThreatSnapshot cap of 16. No module-local world scan was added to the 13 previously audited consumers.

IMPACT_LOCAL_QUERY_ONLY=true
IMPACT_RUNS_ONLY_WHEN_SPRINT=true
IMPACT_GLOBAL_LIST=false
GENERIC_THREAT_CAP_16_PRESERVED=true
MODULE_LOCAL_WORLD_SCAN_COUNT=0
CENTRAL_SCHEDULER_COUNT=1


```

## BUILD_MARKER.txt

- SHA-256: `80C352C474BB50D783669D65956BBF2B2F8C26084C8B5F8126A57F36E70CF8A0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0541_EXACT_IMPACT_TARGET_EQUIVALENCE_A

```

## FINAL_REPORT.md

- SHA-256: `F76E6E297201E429D06988DC7FBBBFE4D0C9A0FDBDDB69A986A37B41896317E1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DIRECT_INSTALL_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.41
INTERNAL_VERSION=0.5.41-b42-exact-impact-target-equivalence-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0541_EXACT_IMPACT_TARGET_EQUIVALENCE_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.41 Exact Impact Target Equivalence
MOD_ID=XNP_PZ_DistanceRunnerTrait

PRE_RANK_DISTANCE_TRUNCATION=false
IMPACT_IDENTITY_DEDUPE=OBJECT_REFERENCE_OR_VERIFIED_ID
IMPACT_SAMPLE_AND_EVALUATE_SAME_TICK=YES
IMPACT_CROSS_TICK_CACHE_REUSE=NO
0537_FILTER_ORDER_REUSED=true
0537_COMPARATOR_REUSED=true
RANK_BEFORE_QUOTA=true
IMPACT_LOCAL_QUERY_ONLY=true
IMPACT_RUNS_ONLY_WHEN_SPRINT=true
IMPACT_GLOBAL_LIST=false
GENERIC_THREAT_CAP_16_PRESERVED=true
MODULE_LOCAL_WORLD_SCAN_COUNT=0
CENTRAL_SCHEDULER_COUNT=1

SPRINT_PRECOLLISION_BASE=0.0500
SPRINT_PRECOLLISION_DEFAULT_FINAL=0.0120
SPRINT_VEHICLE_BASE=0.0750
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
DIRECT_INSTALL_FILE_COUNT=72
DIRECT_INSTALL_SHA256_MISMATCH_COUNT=0
DIRECT_INSTALL_VALIDATION=PASS

LUA_RUNTIME_SYNTAX_EXECUTION=NOT_VERIFIABLE_BY_STATIC_AUDIT
PROJECT_ZOMBOID_RUNTIME=NOT_VERIFIABLE_BY_STATIC_AUDIT
MULTIPLAYER_RUNTIME=NOT_VERIFIABLE_BY_STATIC_AUDIT
BLOCKER=NONE_FOUND_BY_STATIC_AUDIT

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.41_SOURCE_READY_FOR_DIRECT_INSTALL_TEST

```

## 0.5.41_DIRECT_INSTALL_VALIDATION.md

- SHA-256: `C550DE00C8321C183F02F1B483E622046FF2147F39F076E53DA5A4C66B4E7926`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 Direct Install Validation

The direct-install folder is generated only after the SOURCE runtime passes static checks.

Expected folder:

`[LOCAL_PATH_REDACTED]`

Allowed top-level entries:

- `mod.info`
- `poster.png`
- `42`

Forbidden content:

- Markdown/audit/command files;
- `workshop.txt`, `preview.png`, or `Contents`;
- caches, backups, console logs, or old-version trees;
- absolute-path documentation.

Validation requires every direct-install runtime file to match the corresponding SOURCE runtime file by SHA256.

DIRECT_INSTALL_FILE_COUNT=72
SOURCE_RUNTIME_FILE_COUNT=72
SHA256_MISMATCH_COUNT=0
STRICT_FORBIDDEN_CONTENT_COUNT=0
TOP_LEVEL_ENTRIES=42,mod.info,poster.png
DIRECT_INSTALL_VALIDATION=PASS

PACKAGED=NO
INSTALLED=NO
USER_MODS_WRITTEN=NO
GAME_DIRECTORY_WRITTEN=NO

```

## 0.5.41_FIX_FROM_0.5.40_AUDIT.md

- SHA-256: `407C1697CFDC236BDA99FE846B4768A9EBEC9540B2CFDE16723EED1BFC6956B9`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 Fix From 0.5.40 Audit

## Scope

0.5.41 is a single-purpose repair built from the 0.5.40 runtime. It fixes the three blockers found in the 0.5.40 second-pass audit:

1. Impact candidates were previously inherited from the generic ThreatSnapshot, whose nearest-first cap of 16 could discard a better forward/dot candidate before the 0.5.37 comparator ran.
2. The Impact route had no explicit identity deduplication before ranking and quota.
3. A wall-clock cache-age promise could not guarantee freshness at low FPS.

## Runtime Fix

- Added `XNP_DR_ImpactCandidateSnapshot.lua`.
- The central scheduler builds one local Impact snapshot for the current `PlayerSnapshot.frame`.
- Impact candidates have no pre-ranking count cap.
- Raw moving-object references are deduplicated before zombie filtering, ranking, quota, effect, and cost.
- Consumers must claim evaluation against the same frame that produced the sample.
- Sprint precollision and sprint vehicle-zombie routes consume the dedicated snapshot.
- Generic ThreatSnapshot and its cap of 16 remain unchanged for non-Impact systems.

## Frozen Behavior

Food, Melee, Sandbox settings, UI color/state, shake, drag, stamina support, NativeTrip, ControlledEscape, JogBump, ActionBus, ImpactQuota, effect strengths, costs, thresholds, cooldowns, and target limits were not retuned.

STATIC_FIX_COMPLETE=YES
RUNTIME_GAME_TEST_REQUIRED=YES


```

## 0.5.41_SECOND_PASS_AUDIT.md

- SHA-256: `398E2F6790D9FD6F4BFE1CC8A1507FBD91727A3EA3F979F3CF54D3AAB6083903`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.41 Second Pass Read-Only Audit

Audit date: 2026-07-12

This was a read-only audit of the 0.5.41 SOURCE, DIRECT_INSTALL, and 0.5.37 behavior reference. This report is the only file created. No runtime code or existing report was changed; DIRECT_INSTALL was not rebuilt; Project Zomboid and Steam were not started; no user mods, saves, Workshop, or game directory was written.

## 1. Version

- `SOURCE_EXISTS=true`
- `DIRECT_INSTALL_EXISTS=true`
- `BUILD_MARKER_OK=true`
- `DISPLAY_NAME_OK=true`
- `MOD_ID_STABLE=true`
- `OLD_SOURCE_UNCHANGED=true_by_audit_operation_scope` (historical pre-audit hashes are unavailable)
- `OLD_ACTIVE_RESIDUE=0`
- `WORKSHOP_FILES_ABSENT=true`
- `USER_DIR_NOT_WRITTEN=true`

Verified identity:

- version: `0.5.41`
- marker: `XNP_PZ_DISTANCE_TRAIT_0541_EXACT_IMPACT_TARGET_EQUIVALENCE_A`
- display name: `XNP Distance Runner Trait 0.5.41 Exact Impact Target Equivalence`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`

## 2. Impact Dedicated Candidate Pipeline

- `IMPACT_SNAPSHOT_MODULE_PRESENT=true`
- `IMPACT_LOCAL_QUERY_ONLY=true`
- `IMPACT_RUNS_ONLY_WHEN_SPRINT=true_strict_isSprinting_gate`
- `IMPACT_LOADED_ZOMBIE_LIST_USED=false`
- `IMPACT_GENERIC_THREAT_CAP_APPLIED=false`
- `IMPACT_PREFILTER_CAP=NONE`
- `IMPACT_CROSS_TICK_REUSE=false_for_candidate_snapshot`
- `GENERIC_THREAT_CAP_16_PRESERVED=true`
- `IMPACT_PIPELINE_STATUS=PASS_DEDICATED_UNCAPPED_LOCAL_SNAPSHOT`

`XNP_DR_ImpactCandidateSnapshot.lua` scans local grid-square moving-object collections inside the maximum Impact radius, explicitly deduplicates object references, then retains live zombies. It does not call a global loaded-zombie list and contains no candidate-count truncation. Generic `PlayerSnapshot` still uses `PERFORMANCE_MAX_NEARBY_CANDIDATES=16` for non-Impact systems.

The Impact routes are not affected by the generic cap16. This former 0.5.40 blocker is repaired.

## 3. Processing Order Versus 0.5.37

- `0537_RAW_CANDIDATE_SOURCE_EQUIVALENT=false_strict_vehicle_radius_source_is_shared_2.05_instead_of_route_local_1.80`
- `IDENTITY_DEDUPE_BEFORE_FILTER_OR_RANK=true`
- `0537_VALIDITY_FILTER_ORDER_EQUIVALENT=false_vehicle_history_updated_before_distance_validity`
- `0537_DISTANCE_DOT_CALC_EQUIVALENT=true_formula_only`
- `0537_COMPARATOR_EQUIVALENT=true_dot_desc_then_distance_asc`
- `PRE_RANK_DISTANCE_TRUNCATION=false`
- `RANK_BEFORE_QUOTA=true`
- `0537_QUOTA_EQUIVALENT=true_core_selected_target_call_and_values`
- `0537_TARGET_LIMIT_EQUIVALENT=true_effect_limit_two`
- `0537_EFFECT_EQUIVALENT=true_effect_module_hash_and_calls`
- `0537_COST_EQUIVALENT=true_final_route_values`
- `PIPELINE_ORDER_STATUS=FAIL_BLOCKED_FILTER_HISTORY_ORDER`

### Blocking order difference

0.5.37 SprintVehicle performs this order:

1. local 1.80-radius square scan;
2. live-zombie check;
3. calculate distance;
4. require `0.50 <= distance <= 1.80`;
5. calculate dot;
6. update closing history;
7. require dot and closing frames;
8. rank dot descending, then distance ascending;
9. apply mode/
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `8B056A4A2951274AFD3A2495447E63D76C44D27713AE1E14B26658B981366540`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

## Identity

- Version: 0.5.41
- Internal version: 0.5.41-b42-exact-impact-target-equivalence-a
- Build marker: XNP_PZ_DISTANCE_TRAIT_0541_EXACT_IMPACT_TARGET_EQUIVALENCE_A
- Mod ID: XNP_PZ_DistanceRunnerTrait

## Results

| Check | Result |
|---|---|
| Lua files | 61 |
| Lua lines | 11,436 before documentation-only work |
| Empty files | 0 |
| UTF-8 BOM | 0 |
| NULL in text files | 0 |
| Active Lua 0.5.40/0540 residue | 0 |
| OnPlayerUpdate registrations | 1 |
| Raw (), {}, [] delimiter counts | Balanced |
| Missing internal require targets | 0 |
| Player/zombie coordinate writes | 0 |
| GameTime multiplier writes | 0 |
| HaloTextHelper use | 0 |
| Global loaded-zombie list use | 0 |
| Module-local Impact world scans | 0 |
| Central local Impact scan implementations | 1 |
| Generic ThreatSnapshot cap 16 | Preserved |
| Impact pre-ranking cap | None |
| Explicit identity dedupe | Present |
| Same-frame validation | Present |
| Cross-frame candidate reuse | Rejected |
| Food/Melee/Sandbox/UI preservation hashes | Match 0.5.40 |
| DIRECT_INSTALL runtime SHA256 mismatches | 0 of 72 |

## Syntax Review

Static delimiter, quote/comment-risk, require-route, identity-residue, forbidden-call, and empty-file scans found no blocking issue. No reliable Project Zomboid B42 Lua runtime was executed.

LUA_RUNTIME_SYNTAX_EXECUTION=NOT_VERIFIABLE_BY_STATIC_AUDIT
PROJECT_ZOMBOID_RUNTIME=NOT_VERIFIABLE_BY_STATIC_AUDIT
MULTIPLAYER_RUNTIME=NOT_VERIFIABLE_BY_STATIC_AUDIT
BLOCKER=NONE_FOUND_BY_STATIC_AUDIT

```
