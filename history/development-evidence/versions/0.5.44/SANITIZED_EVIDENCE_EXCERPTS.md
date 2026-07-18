# 0.5.44 Sanitized Evidence Excerpts

## 0.5.44_CENTRAL_WORLD_QUERY_FRAME_CONTRACT.md

- SHA-256: `7F0DF561AA8837B5C2CA77E1E3AC52A7DA55B607E33D0E5960BA4579A5DB00EE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 Central World Query Frame Contract

CentralWorldQuery API:

- `CentralWorldQuery.BuildPlayerFrame(player, frame)`
- `CentralWorldQuery.GetThreatCandidates()`
- `CentralWorldQuery.GetImpactCandidates()`
- `CentralWorldQuery.GetPlayerEnvironment()`
- `CentralWorldQuery.GetFrame()`
- `CentralWorldQuery.Clear()`

Contract:

- Only `XNP_DR_PerformanceScheduler.lua` calls `BuildPlayerFrame`.
- The scheduler calls it once after `PlayerSnapshot.RefreshLight` assigns the player frame.
- If called twice with the same frame, it returns `ALREADY_BUILT_THIS_FRAME`.
- Player/impact/threat consumers must not scan world objects directly.
- Render/UI modules must not consume central query.

Low-FPS behavior:

- Consumers use the frame built by the scheduler.
- `ImpactCandidateSnapshot.BuildNow` rejects stale central frames.
- This preserves same-tick impact evaluation and avoids cross-tick local scan reuse.


```

## 0.5.44_ENDURANCE_WRITE_AUTHORITY_MATRIX.md

- SHA-256: `E090315958584036F3431B4CDA9DDDD9539784A269185F49E6BDC422E093135A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 Endurance Write Authority Matrix

FOOD_CLIENT_DIRECT_ENDURANCE_WRITE=0
FOOD_CLIENT_DIRECT_HUNGER_WRITE=0
NORMAL_MP_CLIENT_NON_FOOD_ENDURANCE_WRITE_REACHABLE=0
NORMAL_MP_CLIENT_NON_FOOD_HUNGER_WRITE_REACHABLE=0

LEGACY_NON_FOOD_STATIC_WRITE_SITE_COUNT=7
NEW_NON_FOOD_WRITE_SITE_COUNT=0
FOOD_WRITE_SITE_MIXED_INTO_LEGACY=false
NORMAL_MP_CLIENT_WRITE_REACHABLE=false

| File | Function | Purpose | Source | SP | Host | Dedicated | Normal MP Client | Authority facade | Class |
|---|---|---|---|---|---|---|---|---|---|
| `XNP_DR_LongMigrationStaminaAssist.lua` | `Assist.SetEnduranceSafe` | locomotion refund | legacy non-Food | allowed | allowed | allowed | blocked | `CanWriteNonFoodStats` | locomotion refund |
| `XNP_DR_BreakoutPush.lua` | `BreakoutPush.ApplyCost` | breakout/contact/grab/crowd cost | legacy non-Food | allowed | allowed | allowed | blocked | `CanWriteNonFoodStats` | skill cost |
| `XNP_DR_FallRecoveryInput.lua` | `applyCost` | recovery cost | legacy non-Food | allowed | allowed | allowed | blocked | `CanWriteNonFoodStats` | skill cost |
| `XNP_DR_JogBumpLaunch.lua` | `applyCost` | jog bump cost | legacy non-Food | allowed | allowed | allowed | blocked | `CanWriteNonFoodStats` | skill cost |
| `XNP_DR_EmergencyBreakoutCost.lua` | `EmergencyBreakoutCost.Apply` | emergency floor cost | legacy non-Food | allowed | allowed | allowed | blocked | `CanWriteNonFoodStats` | emergency floor |
| `XNP_DR_SprintTripImmunity.lua` | `applyCost` | sprint trip cancel cost | legacy non-Food | allowed | allowed | allowed | blocked | `CanWriteNonFoodStats` | skill cost |
| `XNP_DR_VehicleLegacy0537Evaluator.lua` | `charge` | vehicle impact cost | legacy non-Food | allowed | allowed | allowed | blocked | `CanWriteNonFoodStats` | skill cost |

Food writer status:

- Tiered food remains in `XNP_DR_Authority.ApplyTieredFoodPulse`.
- Old hunger conversion cost remains inactive.
- Client-side food stat write is rejected by `ValidateFoodWritePath`.


```

## 0.5.44_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `4108F5D043B71C06BA9EEC2A20CC9A7B394F5DA5C0C22BB3CC3488C1397776D8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 Gameplay Preserve Report

Preserved from 0.5.42 / 0.5.43:

- Vehicle exact 0.5.37 pipeline.
- Vehicle history admission 0.50 to 1.80.
- Raw scan radius separation 2.05.
- Run gate and LIGHT equivalence route.
- No pre-rank cap.
- Identity dedupe and same-tick freshness.
- Precollision 0.0120 and Vehicle 0.0180 effective defaults.
- ZombieImpact 0.24.
- Blue30 / Yellow38 / Red55.
- SP melee verified, MP melee disabled.
- Tiered Food: 2s pulse, Green false, Blue -0.005/+0.015, Yellow/Red -0.010/+0.020.
- Pre-Bite 3 target route, with only the absolute 30% gate removed.
- Emergency 5% floor.
- Colors, shake, drag, walk no impact, controlled escape, jog bump, native trip, impact quota.
- coordinate write=0.
- no bite rollback, no infection rollback, no heal.

0.5.44 changes are scoped to authority boundary, committed band gate, central query ownership, and silent UI hold logging.


```

## 0.5.44_PREBITE_BAND_GATE.md

- SHA-256: `D1F4122BD43C86CD5F217F7403C0CB52370EEFAA60802469D95D704E819079F3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 Pre-Bite Band Gate

PREBITE_ABSOLUTE_ENDURANCE_MIN_GATE=false
PREBITE_ALLOWED_BLUE=true
PREBITE_ALLOWED_YELLOW=true
PREBITE_ALLOWED_RED=true
PREBITE_ALLOWED_GREEN=false
PREBITE_USES_COMMITTED_BAND=true

Implementation:

- `XNP_DR_PreBiteJogRescue.lua` reads `Core.EnduranceBandState.GetStableState(player)`.
- `GREEN_READY` returns false.
- Any non-green committed/stable band can proceed if trait, alive-state, movement intent, target, cooldown, and too-late bite checks pass.
- The former absolute 30% endurance gate is removed from Pre-Bite.
- If endurance is already below the emergency floor, the action can still trigger and the applied cost can be zero.

Preserved:

- RUN_OR_SPRINT intent.
- `strict isSprinting-only=false`.
- `hitreaction-bite` and `bite` remain too-late only.
- Max targets remains 3.
- First two targets use verified stagger/knockdown route.
- Third target remains stagger-only/contact style and does not consume ordinary knockdown quota.


```

## 0.5.44_STATUS_ICON_LOG_REACHABILITY.md

- SHA-256: `1AF38C0C9E19BBBB002F49E3CCE3D28329DB14B156FFC83AA5ABA97EA129BBC6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 Status Icon Log Reachability

ICON_STATE_HOLD_LOG_SUMMARY_ONLY=true
STATUS_ICON_HOLD_DIRECT_PRINT=false
STATUS_ICON_STATE_HOLD_DIRECT_PRINT=0
STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT=0

Implementation:

- `XNP_DR_Config.lua` defines `ICON_STATE_HOLD_LOG_SUMMARY_ONLY=true`.
- `XNP_DR_Config.lua` defines `STATUS_ICON_HOLD_DIRECT_PRINT=false`.
- `XNP_DR_StatusIconUI.lua` no longer has a direct hold-print branch.
- Hold suppression increments summary counters only.
- Missing config fallback is silent because direct print is no longer reachable.

Allowed logs:

- One edge log for real state changes.
- Clamp log only when screen key changes or actual correction occurs.
- Summary logs at the existing summary cadence.


```

## 0.5.44_TRUE_DIRECT_INSTALL_TREE.md

- SHA-256: `BCB5CABE7D9C6F4700A37327304FEF233E83049B6F00B4CF339D7CD8611D4992`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 True Direct Install Tree

DIRECT_INSTALL:
`[LOCAL_PATH_REDACTED]`

First layer:

```text
XNP_PZ_DistanceRunnerTrait
|-- 42
|-- mod.info
`-- poster.png
```

Validation:

- NO_EXTRA_WRAPPER=true
- NESTED_SAME_NAME_FOLDER_COUNT=0
- TOP_LEVEL_42_EXISTS=true
- TOP_LEVEL_MOD_INFO_EXISTS=true
- TOP_LEVEL_POSTER_EXISTS=true
- TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0

Notes:

- `.md` docs are not copied into DIRECT_INSTALL.
- `XNP_DR_NearbyZombieCache.lua` is a runtime module name and is not a cache artifact.


```

## 0.5.44_WORLD_SCAN_OWNERSHIP_MAP.md

- SHA-256: `2FA64B7BAA1C1C9F5422F461188BA2698E383BA289994F943BF9EB59C26C57A9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 World Scan Ownership Map

DIRECT_WORLD_SCAN_MODULE_COUNT=1
DIRECT_WORLD_SCAN_ALLOWED_MODULE=XNP_DR_CentralWorldQuery.lua
PLAYER_SNAPSHOT_DIRECT_WORLD_SCAN=0
IMPACT_SNAPSHOT_DIRECT_WORLD_SCAN=0
THREAT_SNAPSHOT_DIRECT_WORLD_SCAN=0
PREBITE_DIRECT_WORLD_SCAN=0
MODULE_LOCAL_WORLD_SCAN_COUNT=0
CENTRAL_SCHEDULER_COUNT=1
GLOBAL_ZOMBIE_LIST_USED=false

Ownership:

- `XNP_DR_CentralWorldQuery.lua`: only module allowed to call local square/moving-object APIs.
- `XNP_DR_PerformanceScheduler.lua`: only caller of `CentralWorldQuery.BuildPlayerFrame`.
- `XNP_DR_PlayerSnapshot.lua`: consumes central threat entries.
- `XNP_DR_ImpactCandidateSnapshot.lua`: consumes central impact candidates.
- `XNP_DR_PreBiteJogRescue.lua`: consumes `Core.ThreatSnapshot` only.

Preserved behavior:

- Impact radius remains 2.05.
- Threat cap remains 16.
- Vehicle history admission 0.50 to 1.80 remains preserved.
- Same-tick freshness and object identity dedupe remain preserved.
- Loaded/global zombie list remains unused.


```

## BUILD_MARKER.txt

- SHA-256: `DCB46DC5F0163B6280825F562F34E3A0977086A7DB91069EA8D4D4FEE2F7035B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0544_AUTHORITY_BAND_CENTRAL_SCAN_REPAIR_A

```

## FINAL_REPORT.md

- SHA-256: `53C8A59DA87A72C7B52F09C73326ECA5161C49A55C6C60B9D71BBC25EB180110`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

DIRECT_INSTALL_PATH=`[LOCAL_PATH_REDACTED]`

VERSION=`0.5.44`

INTERNAL_VERSION=`0.5.44-b42-authority-band-central-scan-repair-a`

BUILD_MARKER=`XNP_PZ_DISTANCE_TRAIT_0544_AUTHORITY_BAND_CENTRAL_SCAN_REPAIR_A`

DISPLAY_NAME=`XNP Distance Runner Trait 0.5.44 Authority Band Central Scan Repair`

Changed runtime files:

- `XNP_DR_Constants.lua`
- `XNP_DR_Config.lua`
- `XNP_DR_Authority.lua`
- `XNP_DR_CentralWorldQuery.lua`
- `XNP_DR_PlayerSnapshot.lua`
- `XNP_DR_ImpactCandidateSnapshot.lua`
- `XNP_DR_PerformanceScheduler.lua`
- `XNP_DR_PreBiteJogRescue.lua`
- `XNP_DR_StatusIconUI.lua`
- `XNP_DR_Bootstrap.lua`
- `XNP_DR_Runtime.lua`
- seven legacy non-Food endurance cost/refund modules gated by Authority.

Authority matrix:

- LEGACY_NON_FOOD_STATIC_WRITE_SITE_COUNT=7
- NEW_NON_FOOD_WRITE_SITE_COUNT=0
- FOOD_CLIENT_DIRECT_ENDURANCE_WRITE=0
- FOOD_CLIENT_DIRECT_HUNGER_WRITE=0
- NORMAL_MP_CLIENT_WRITE_REACHABLE=false

Pre-Bite band gate:

- PREBITE_ABSOLUTE_ENDURANCE_MIN_GATE=false
- PREBITE_ALLOWED_BLUE=true
- PREBITE_ALLOWED_YELLOW=true
- PREBITE_ALLOWED_RED=true
- PREBITE_ALLOWED_GREEN=false
- PREBITE_USES_COMMITTED_BAND=true

CentralWorldQuery ownership:

- DIRECT_WORLD_SCAN_MODULE_COUNT=1
- DIRECT_WORLD_SCAN_ALLOWED_MODULE=`XNP_DR_CentralWorldQuery.lua`
- PLAYER_SNAPSHOT_DIRECT_WORLD_SCAN=0
- IMPACT_SNAPSHOT_DIRECT_WORLD_SCAN=0
- PREBITE_DIRECT_WORLD_SCAN=0

Status icon:

- ICON_STATE_HOLD_LOG_SUMMARY_ONLY=true
- STATUS_ICON_HOLD_DIRECT_PRINT=false
- STATUS_ICON_STATE_HOLD_DIRECT_PRINT=0

Preserved:

- Tiered Food values and authority-only food writer.
- Pre-Bite/Emergency target quota and 5% floor.
- Vehicle 0.5.37 exact equivalence route.
- No coordinate writes, no bite/infection rollback, no heal.

Hashes:

- SOURCE_RUNTIME_42_COMBINED_SHA256=`25D8079C47A4A0997137A9440F51638409B92834212FB1612836D5EB57B63155`
- DIRECT_RUNTIME_42_COMBINED_SHA256=`25D8079C47A4A0997137A9440F51638409B92834212FB1612836D5EB57B63155`
- DIRECT_FULL_COMBINED_SHA256=`FE689258F0BEE4510E477D2521DA5D37BF90C1E65E1372B61113FB4D20D756B2`

Environment actions:

- Modified old SOURCE=false
- Launched Project Zomboid=false
- Launched Steam=false
- Wrote user mods/saves/Workshop/game dir=false
- Installed mod=false

Final status:

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.44_SOURCE_READY_FOR_DIRECT_INSTALL_TEST`


```

## 0.5.44_DIRECT_INSTALL_VALIDATION.md

- SHA-256: `FC56330B587166C8A461BD75E87BFCD86E4D8676948086EA56D0FDB495996742`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 Direct Install Validation

DIRECT_INSTALL path:
`[LOCAL_PATH_REDACTED]`

Results:

- TOP_LEVEL_ENTRIES=`42, mod.info, poster.png`
- TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0
- NESTED_SAME_NAME_FOLDER_COUNT=0
- SOURCE_DIRECT_HASH_MISMATCH_COUNT=0
- DIRECT_RUNTIME_42_COMBINED_SHA256=`25D8079C47A4A0997137A9440F51638409B92834212FB1612836D5EB57B63155`
- DIRECT_FULL_COMBINED_SHA256=`FE689258F0BEE4510E477D2521DA5D37BF90C1E65E1372B61113FB4D20D756B2`
- WORKSHOP_TXT_ABSENT=true
- PREVIEW_ABSENT=true
- CONTENTS_ABSENT=true
- DEV_DOC_COUNT=0
- AUDIT_FILE_COUNT=0
- CONSOLE_COUNT=0
- ABSOLUTE_PATH_LEAK_COUNT=0

DIRECT_INSTALL_STATUS=PASS


```

## 0.5.44_FIX_FROM_0.5.43_AUDIT.md

- SHA-256: `946B86EA470A46411260870E203B395935CF0C230923C78FEB5C8A81A26A616D`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 Fix From 0.5.43 Audit

0.5.44 addresses the four blockers from `0.5.43_SECOND_PASS_AUDIT.md`.

- Authority boundary: existing non-Food endurance write sites remain static legacy sites, but each is now gated by `Core.Authority.CanWriteNonFoodStats`.
- Pre-Bite band gate: removed the absolute `PREBITE_JOG_RESCUE_MIN_ENDURANCE=0.30` gate. Green is disabled; committed/stable Blue, Yellow, and Red are allowed.
- Central scan ownership: local square/moving-object scans are moved into `XNP_DR_CentralWorldQuery.lua`.
- Silent UI repair: hold direct print is removed; nil or missing config falls back to summary-only behavior.

Preserved:

- 0.5.43 tiered food values and single-writer food path.
- Pre-Bite max 3 targets and stagger/knockdown split.
- Emergency 5% floor.
- 0.5.42/0.5.37 vehicle equivalence route.


```

## 0.5.44_SECOND_PASS_AUDIT.md

- SHA-256: `A12D964ABD206E22B13992B4FB73739E0FB537C46FEAE6955BFBF0B930534356`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.44 Second Pass Audit

Audit mode: READ_ONLY_CODE_AUDIT

Allowed write performed:

- `[LOCAL_PATH_REDACTED]`

No code files were modified. DIRECT_INSTALL was not rebuilt. Project Zomboid and Steam were not launched. User mods, saves, Workshop, and game install directories were not written.

## 1. Audited Paths

SOURCE:

`[LOCAL_PATH_REDACTED]`

DIRECT_INSTALL:

`[LOCAL_PATH_REDACTED]`

Reference behavior source:

`[LOCAL_PATH_REDACTED]`

## 2. Version And Directory Audit

SOURCE_EXISTS=true

DIRECT_INSTALL_EXISTS=true

BUILD_MARKER_OK=true

Observed marker:

`XNP_PZ_DISTANCE_TRAIT_0544_AUTHORITY_BAND_CENTRAL_SCAN_REPAIR_A`

DISPLAY_NAME_OK=true

Observed display name:

`XNP Distance Runner Trait 0.5.44 Authority Band Central Scan Repair`

MOD_ID_STABLE=true

Observed Mod ID:

`XNP_PZ_DistanceRunnerTrait`

Version fields:

- `version=0.5.44`
- `modversion=0.5.44`

OLD_ACTIVE_RESIDUE=0

Search scope: active Lua runtime, `mod.info`, `42/mod.info`, and `BUILD_MARKER.txt`.

SOURCE_RUNTIME_COMPLETE=true

Lua file count:

`64`

Lua total line count:

`12216`

SOURCE_DIRECT_HASH_MISMATCH_COUNT=0

SOURCE_42_FILE_COUNT=74

DIRECT_INSTALL_42_FILE_COUNT=74

USER_DIR_NOT_WRITTEN=true

OLD_SOURCE_UNCHANGED=NOT_MODIFIED_BY_THIS_AUDIT

## 3. Authority Matrix

Source document checked:

`0.5.44_ENDURANCE_WRITE_AUTHORITY_MATRIX.md`

Confirmed values:

- `LEGACY_NON_FOOD_STATIC_WRITE_SITE_COUNT=7`
- `NEW_NON_FOOD_WRITE_SITE_COUNT=0`
- `FOOD_WRITE_SITE_MIXED_INTO_LEGACY=false`
- `FOOD_CLIENT_DIRECT_ENDURANCE_WRITE=0`
- `FOOD_CLIENT_DIRECT_HUNGER_WRITE=0`
- `NORMAL_MP_CLIENT_NON_FOOD_ENDURANCE_WRITE_REACHABLE=0`
- `NORMAL_MP_CLIENT_NON_FOOD_HUNGER_WRITE_REACHABLE=0`
- `SP_LOCAL_AUTHORITY_ALLOWED=true`
- `HOST_SERVER_AUTHORITY_ALLOWED=true`
- `DEDICATED_SERVER_AUTHORITY_ALLOWED=true`
- `NORMAL_CLIENT_AUTHORITY=false`
- `ALL_SEVEN_CLASSIFIED=true`
- `ALL_SEVEN_ORIGIN_RECORDED=true`
- `ALL_NEW_0543_WRITES_THROUGH_AUTHORITY=true`

Static code check:

Seven legacy non-food client endurance write sites are present and all are guarded by `Core.Authority.CanWriteNonFoodStats(...)`:

1. `XNP_DR_LongMigrationStaminaAssist.lua`
2. `XNP_DR_BreakoutPush.lua`
3. `XNP_DR_FallRecoveryInput.lua`
4. `XNP_DR_JogBumpLaunch.lua`
5. `XNP_DR_EmergencyBreakoutCost.lua`
6. `XNP_DR_SprintTripImmunity.lua`
7. `XNP_DR_VehicleLegacy0537Evaluator.lua`

Tiered Food writes through:

`Core.Authority.ApplyTieredFoodPulse(...)`

AUTHORITY_MATRIX_STATUS=PASS_STATIC

## 4. Food Client Write

FOOD_CLIENT_DIRECT_ENDURANCE_WRITE=0

FOOD_CLIENT_DIRECT_HUNGER_WRITE=0

Food authority path remains centralized in:

- `XNP_DR_Authority.lua`
- `XNP_DR_FoodAuthorityServer.lua`
- `XNP_DR_TieredFoodRecovery.lua`

FOOD_CLIENT_WRITE_STATUS=PASS_STATIC

## 5. Normal MP Client Reachability

NORMAL_MP_CLIENT_NON_FOOD_ENDURANCE_WRITE_REACHABLE=0

NORMAL_MP_CLIENT_NON_FOOD_HUNGER_WRITE_REACHABLE=0

The static write sites are not blockers by count alone because the seven known legacy sites use the authority facade.

NOR
[EXCERPT_TRUNCATED]
```
