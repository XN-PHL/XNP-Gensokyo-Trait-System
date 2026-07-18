# 0.5.55.2 Sanitized Evidence Excerpts

## 0.5.55.2_RED_FRACTURE_FINAL_INTERVAL_FORENSIC_REPORT.md

- SHA-256: `2BD13025CEC3EAA4A9D584463DEDFE1E1221BC2BB1BF55F6E68FE542C90509AF`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Fracture Final-Interval Forensic Report

## Baseline

- Baseline SOURCE: `[LOCAL_PATH_REDACTED]`
- New SOURCE: `[LOCAL_PATH_REDACTED]`
- The baseline was read only and was not modified.

## Confirmed [IP_REDACTED] blocker

The baseline red update read `buffEnd` and returned when `buffEnd <= now` before calculating the clamped settlement endpoint and elapsed game time. A scheduler callback at or beyond expiry therefore discarded the final active interval.

Examples affected in [IP_REDACTED]:

- Exact expiry: `last=33`, `end=34`, `now=34` lost one active game hour.
- Time acceleration: `last=33`, `end=34`, `now=36` lost the final hour.
- Save/load: `last=31.5`, `end=34`, `now=40` lost 2.5 valid hours.

BASELINE_BLOCKER=EXPIRY_RETURN_BEFORE_FINAL_INTERVAL_SETTLEMENT
BASELINE_TIME_ACCELERATION_SAFE=false
BASELINE_FINAL_INTERVAL_SAVELOAD_SAFE=false

## Repair boundary

Only the red final-interval calculation, Buff start metadata, version identity, and reports changed. The existing central scheduler registration design was retained. No UI, assets, recipe, starter-item behavior, whole-item consumption, Distance Runner gameplay, or Phoenix gameplay was changed.


```

## 0.5.55.2_0551_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `AB9A538AB25151E708E3B37B9353BAD7D3BB7E2CDE6152F98FEC4A77F00F1F2D`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] [IP_REDACTED] Runtime Preservation Report

## Deployable difference scope

Six deployable files differ from [IP_REDACTED]:

- `42/mod.info`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RedGuardianMark.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `mod.info`

The scheduler, Bootstrap, all UI modules, all gameplay modules outside the red final interval, scripts, translations, and assets are byte-identical to [IP_REDACTED].

## Asset hashes

| Asset | SHA256 | Same as [IP_REDACTED] |
| --- | --- | --- |
| Yellow icon | `8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9` | true |
| Purple Phoenix icon | `55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21` | true |
| Green icon | `9E2B1E532F9DA4243EC3874A9B0AF4DF2C7AF7CBD9AEFDFD6DE072AAF3D0EFD9` | true |
| Red item texture | `F99DD3FF8E7D46A8F6D2EF22666DB3D1E51344BBFAC352358361EE3CC802274C` | true |

XNP_VISIBLE_ICON_TYPE_COUNT=3
YELLOW_UI_PANEL_COUNT=1
PHOENIX_UI_PANEL_COUNT=1
GREEN_UI_PANEL_COUNT=1
BLUE_UI_PANEL_COUNT=0
RED_UI_PANEL_COUNT=0

YELLOW_ASSET_IS_ORIGINAL_DISTINCT=true
YELLOW_RUNTIME_TINTING=false
YELLOW_FULL_TEXTURE_VISIBLE=true
YELLOW_PANEL_CLIPPING=false

PHOENIX_ASSET_IS_ORIGINAL_DISTINCT=true
PHOENIX_RUNTIME_TINTING=false
PHOENIX_FULL_TEXTURE_VISIBLE=true
PHOENIX_PANEL_CLIPPING=false
PHOENIX_TRIGGERED_HIDDEN=true
PHOENIX_COOLDOWN_HIDDEN=true
PHOENIX_REAPPEARS_WHEN_READY=true

GREEN_SKILL_GAMEPLAY_IMPLEMENTED=false
GREEN_CONTINUOUS_EVENT_HANDLER_COUNT=0
BLUE_BOMB_RUNTIME_ACTIVE_COUNT=0
OLD_RED_FOOD_POLL_HANDLER_COUNT=0

RED_ITEM_PRESENT=true
RED_ITEM_PARTIAL_EAT_OPTIONS_PRESENT=false
RED_ITEM_CONSUMES_WHOLE_ON_SUCCESS=true
STARTER_RED_ITEM_COUNT=3
STARTER_GRANT_ONCE_ONLY=true

DISTANCE_RUNNER_RUNTIME_PRESERVED=true
PHOENIX_CORE_RUNTIME_PRESERVED=true
FULL_FATAL_DIAGNOSTIC_ACTIVE_HITS=0
READ_SNAPSHOT_ACTIVE_HITS=0

Console evidence: 3 XNP lines, 0 XNP error lines, and 3,490 WarThunder lines. WarThunder samples identify `MOD:WarThunderVehicleLibrary` and `HeliSoundUpdate.lua:69`.

WARTHUNDER_ERROR_OWNERSHIP=THIRD_PARTY


```

## 0.5.55.2_GAME_TIME_ACCOUNTING_REPORT.md

- SHA-256: `562F8C7AC1B0431DD50593F627A9EB9CCE4167FE1F87F163C9F1E8775907534C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Game-Time Accounting Report

## Clock and cursor

- Clock: `getGameTime():getWorldAgeHours()`.
- New consumption stores start, end, and last processed time.
- Duration remains `24.0` game hours.
- Existing 0.5.55/[IP_REDACTED] saves retain compatibility through unchanged end and last keys.
- A missing start key is reconstructed as `end - 24.0`.
- The settlement cursor is clamped to the Buff end and never advanced to post-expiry `now`.

## Safety properties

- FPS independence: recovery uses elapsed world hours, not frame count.
- Pause safety: world age does not advance while paused.
- Time acceleration: skipped scheduler buckets settle as one clamped delta.
- Save/load: persisted last/end values settle through expiry on the first eligible callback.
- Duplicate prevention: after final settlement, Buff metadata is cleared; an already-settled cursor also produces `elapsed <= 0` and no recovery write.
- Negative delta: never applied.

USES_GAME_TIME_DELTA=true
FPS_INDEPENDENT=true
PAUSE_SAFE=true
TIME_ACCELERATION_SAFE=true
NO_DUPLICATE_SAME_HOUR_TICK=true
SAVELOAD_SAFE=true
FINAL_INTERVAL_SAVELOAD_SAFE=true
FINAL_INTERVAL_TIME_ACCELERATION_SAFE=true
POST_EXPIRY_TIME_NOT_APPLIED=true

FRACTURE_BUFF_DURATION_GAME_HOURS=24
FRACTURE_BUFF_MULTIPLIER=3
FRACTURE_BUFF_STACKS_MULTIPLICATIVELY=false
FRACTURE_BUFF_REFRESHES_DURATION=true
FRACTURE_BUFF_PER_FRAME_HANDLER=false
NO_BUFF_NO_WRITE=true
NO_FRACTURE_NO_BODY_PART_WRITE=true


```

## 0.5.55.2_RED_FRACTURE_FINAL_INTERVAL_FIX_REPORT.md

- SHA-256: `4E7C3A2725750ED630CAE0882B4DBEDF353D2866728C96C5F1DB1C2E27630125`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Fracture Final-Interval Fix Report

## Corrected control flow

`XNP_DR_RedGuardianMark.lua` now performs settlement in this order:

1. Read world time, Buff end, Buff start, and last processed game time.
2. Calculate `effectiveNow = math.min(now, buffEnd)`.
3. Calculate `elapsed = effectiveNow - last`.
4. Skip recovery only when `elapsed <= 0` or body-part access is unavailable.
5. Apply extra fracture recovery only to parts with positive fracture time.
6. Write the last processed cursor as `effectiveNow`.
7. If `effectiveNow >= buffEnd`, clear Buff start/end/last metadata.

The old `buffEnd <= now` expiry return is absent. The old `elapsed < 1.0` skip is also absent, allowing fractional final intervals to settle. Existing 0.5.55 Buff state remains compatible because missing start metadata is derived as `buffEnd - 24` and the established end/last keys remain unchanged.

FINAL_INTERVAL_APPLIED_BEFORE_CLEANUP=true
LAST_PROCESSED_CLAMPED_TO_BUFF_END=true
POST_EXPIRY_TIME_NOT_APPLIED=true
DUPLICATE_FINAL_INTERVAL_APPLY=false
NEGATIVE_ELAPSED_BLOCKED=true
EARLY_RETURN_BEFORE_EFFECTIVE_NOW_CALC=false
EARLY_RETURN_BEFORE_FINAL_INTERVAL_APPLY=false
BUFF_CLEANUP_BEFORE_FINAL_INTERVAL_APPLY=false

## Scheduler preservation

The task ID remains `xnp_red_guardian_fracture_game_hour_05551`. The scheduler file is byte-identical to [IP_REDACTED].

RED_FRACTURE_DIRECT_EVERYHOURS_REGISTRATION_COUNT=0
RED_FRACTURE_DIRECT_ONTICK_REGISTRATION_COUNT=0
RED_FRACTURE_DIRECT_ONPLAYERUPDATE_REGISTRATION_COUNT=0
RED_FRACTURE_DEDICATED_EVENT_HANDLER_COUNT=0
RED_FRACTURE_CENTRAL_SCHEDULER_TASK_COUNT=1
RED_FRACTURE_CENTRAL_SCHEDULER_TASK_ID_UNIQUE=true
RED_FRACTURE_CENTRAL_SCHEDULER_REGISTRATION_IDEMPOTENT=true
USES_CENTRAL_SCHEDULER=true
SECOND_SCHEDULER_CREATED=false


```

## 0.5.55.2_RED_FRACTURE_FINAL_INTERVAL_TEST_MATRIX.md

- SHA-256: `0859572342B4B63B158644BA5C32284FB9BA73DCB78C1E1CC23537BEDDD94897`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Red Fracture Final-Interval Test Matrix

The matrix statically evaluates the implemented equations:

`effectiveNow = min(now, end)`

`elapsed = effectiveNow - last`

Recovery applies only when `elapsed > 0`. Cleanup follows settlement when the clamped endpoint reaches the Buff end.

| Case | Last | End | Now | Effective now | Elapsed | Apply | Cleanup | Overrun ignored | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- | ---: | --- |
| A: exact expiry | 33 | 34 | 34 | 34 | 1 | yes | yes | 0 | PASS |
| B: callback crosses expiry | 33 | 34 | 36 | 34 | 1 | yes | yes | 2 | PASS |
| C: load crosses expiry | 31.5 | 34 | 40 | 34 | 2.5 | yes | yes | 6 | PASS |
| D: already settled | 34 | 34 | 35 | 34 | 0 | no | yes | 1 | PASS |
| E: invalid/backward cursor | 35 | 34 | 35 | 34 | -1 | no | yes | 1 | PASS |
| F: active before expiry | 20 | 34 | 21 | 21 | 1 | yes | no | 0 | PASS |

CASE_A_PASS=true
CASE_B_PASS=true
CASE_C_PASS=true
CASE_D_PASS=true
CASE_E_PASS=true
CASE_F_PASS=true
FINAL_INTERVAL_TEST_MATRIX_PASS_COUNT=6
FINAL_INTERVAL_TEST_MATRIX_FAIL_COUNT=0

This matrix is a static control-flow test. Real-game timing remains user validation work.


```

## BUILD_MARKER.txt

- SHA-256: `F8DC60296CDD40A053D836C44347FB7D4A906D1F1FF7D14949AB13A669FB47AB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_05552_RED_FRACTURE_FINAL_INTERVAL_FIX_A

```

## FINAL_REPORT.md

- SHA-256: `AFBBE036EAEDADA0675AE1B0951B6F621B66667F34150DD443B055688594CABF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DIRECT_DROP_PATH=[LOCAL_PATH_REDACTED]
VERSION=[IP_REDACTED]
INTERNAL=[IP_REDACTED]-b42-red-fracture-final-interval-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05552_RED_FRACTURE_FINAL_INTERVAL_FIX_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
DISPLAY_NAME=[[IP_REDACTED]] XNP Distance Runner + Phoenix + Green Skill + Red Consumable

FINAL_INTERVAL_FIX_IMPLEMENTED=true
FINAL_INTERVAL_APPLIED_BEFORE_CLEANUP=true
LAST_PROCESSED_CLAMPED_TO_BUFF_END=true
POST_EXPIRY_TIME_NOT_APPLIED=true
FINAL_INTERVAL_SAVELOAD_SAFE=true
FINAL_INTERVAL_TIME_ACCELERATION_SAFE=true

CENTRAL_SCHEDULER_PRESERVED=true
CENTRAL_TASK_ID=xnp_red_guardian_fracture_game_hour_05551
RED_FRACTURE_DIRECT_EVENT_HANDLER_COUNT=0
SECOND_SCHEDULER_CREATED=false

FRACTURE_BUFF_DURATION_GAME_HOURS=24
FRACTURE_BUFF_MULTIPLIER=3
FRACTURE_BUFF_REFRESHES_DURATION=true
FRACTURE_BUFF_STACKS_MULTIPLICATIVELY=false

RUNTIME_LUA_FILE_COUNT=79
RUNTIME_LUA_LINE_COUNT=13469
KAHLUA_PASS_COUNT=79
KAHLUA_FAIL_COUNT=0
SOURCE_RUNTIME_FILE_COUNT=100
DROP_RUNTIME_FILE_COUNT=100
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
STATIC_BLOCKER_COUNT=0

PROJECT_ZOMBOID_STARTED=false
STEAM_STARTED=false
USER_MODS_WRITTEN=false
WORKSHOP_WRITTEN=false
SAVES_WRITTEN=false
GAME_DIRECTORY_WRITTEN=false
BASELINE_SOURCE_MODIFIED=false
REAL_GAME_TEST=NOT_VERIFIABLE_BY_STATIC_AUDIT
MULTIPLAYER_TEST=NOT_VERIFIABLE_BY_STATIC_AUDIT
BLOCKER=NONE_STATIC

XNP_PZ_0.5.55.2_RED_FRACTURE_FINAL_INTERVAL_FIX_READY


```

## 0.5.55.2_KAHLUA_AND_CONTROL_FLOW_VALIDATION.md

- SHA-256: `6B995F8E7EBB6D3BA0EB82921A1558645B412FE5138480281E2510D5F2BCB272`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Kahlua and Control-Flow Validation

## Kahlua

- JAR: `[LOCAL_PATH_REDACTED]`.
- Compiler route: local checker invoking `LuaCompiler.loadis`.
- Runtime Lua files enumerated: 79.
- Runtime Lua lines: 13,469.
- PASS: 79.
- FAIL: 0.

ALL_RUNTIME_LUA_ENUMERATED=true
KAHLUA_RUNTIME_LUA_SYNTAX_FAIL_COUNT=0

## Control flow

- Old `buffEnd <= now` immediate return count: 0.
- `effectiveNow = math.min(now, buffEnd)` count: 1.
- `elapsed = effectiveNow - last` count: 1.
- Update-path last cursor assignment to `effectiveNow` count: 1.
- Final cleanup appears after body-part settlement and cursor update.
- Post-expiry overrun is excluded by the clamped endpoint.
- Negative or zero elapsed time returns without recovery.

EARLY_RETURN_BEFORE_EFFECTIVE_NOW_CALC=false
EARLY_RETURN_BEFORE_FINAL_INTERVAL_APPLY=false
BUFF_CLEANUP_BEFORE_FINAL_INTERVAL_APPLY=false
FINAL_INTERVAL_APPLIED_BEFORE_CLEANUP=true
LAST_PROCESSED_CLAMPED_TO_BUFF_END=true
POST_EXPIRY_TIME_NOT_APPLIED=true
DUPLICATE_FINAL_INTERVAL_APPLY=false
NEGATIVE_ELAPSED_BLOCKED=true

SCHEDULER_API_REFERENCE_VALID=true
DUPLICATE_EVENT_REGISTRATION_COUNT=0
DUPLICATE_SCHEDULER_TASK_REGISTRATION_COUNT=0

EMPTY_TEXT_FILE_COUNT=0
NULL_TEXT_FILE_COUNT=0
UTF8_BOM_TEXT_FILE_COUNT=0


```

## 0.5.55.2_PACKAGE_VALIDATION.md

- SHA-256: `A84B88414211680DCCC4A510578891A5E3C448CE2A6459EF8BA8607AE2C99476`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Package Validation

- SOURCE: `[LOCAL_PATH_REDACTED]`
- Direct-drop product: `[LOCAL_PATH_REDACTED]`
- Product first level: `42`, `mod.info`, `poster.png` only.
- Parent wrapper: absent.

SOURCE_RUNTIME_FILE_COUNT=100
DROP_RUNTIME_FILE_COUNT=100
SOURCE_DROP_FILE_COUNT_MATCH=true
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
MISSING_FROM_DROP=0
EXTRA_IN_DROP=0
PRODUCT_NAME_HAS_0.5.55.2_PREFIX=true


```

## 0.5.55.2_SECOND_PASS_AUDIT.md

- SHA-256: `32FB36A8244EC23F9BD65FBC34B95D23C0B4BD8A47EDCC5ECEDEF8F04223FFFC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Second-Pass Read-Only Audit

## Final Status

AUDIT_RESULT=PASS

XNP_PZ_0.5.55.2_RED_FRACTURE_FINAL_INTERVAL_FIX_AUDIT_PASS

## Audit Scope

- SOURCE: `[LOCAL_PATH_REDACTED]`
- Product: `[LOCAL_PATH_REDACTED]`
- Baseline: `[LOCAL_PATH_REDACTED]`
- Audit mode: read only except for this permitted report.

No blocking finding was identified.

## Version and Structure

VERSION=[IP_REDACTED]
INTERNAL=[IP_REDACTED]-b42-red-fracture-final-interval-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05552_RED_FRACTURE_FINAL_INTERVAL_FIX_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
DISPLAY_NAME_STARTS_WITH=[[IP_REDACTED]]
PRODUCT_TOP_LEVEL=42|mod.info|poster.png
PARENT_WRAPPER_PRESENT=false

## Final-Interval Control Flow

Target: `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RedGuardianMark.lua`

Observed order in `RedGuardian.Update`:

1. Read player data and world age.
2. Return only when no valid Buff end state exists.
3. Read/derive Buff start and read the persisted last processed cursor.
4. Calculate `effectiveNow = math.min(now, buffEnd)`.
5. Calculate `elapsed = effectiveNow - last`.
6. Block zero or negative elapsed before body-part recovery.
7. Apply recovery only to body parts whose fracture time is positive.
8. Write the cursor as `effectiveNow`.
9. Clear Buff metadata only after settlement and cursor update when expiry was reached.

The no-Buff return at `buffEnd <= 0` is a lightweight no-state guard. There is no `buffEnd <= now` expiry return before final-interval calculation.

OLD_EXPIRY_EARLY_RETURN_COUNT=0
EFFECTIVE_NOW_CALC_COUNT=1
ELAPSED_FROM_EFFECTIVE_NOW_COUNT=1
ELAPSED_LESS_THAN_ONE_SKIP_COUNT=0
UPDATE_PATH_LAST_SET_TO_EFFECTIVE_NOW_COUNT=1

EARLY_RETURN_BEFORE_EFFECTIVE_NOW_CALC=false
EARLY_RETURN_BEFORE_FINAL_INTERVAL_APPLY=false
BUFF_CLEANUP_BEFORE_FINAL_INTERVAL_APPLY=false
FINAL_INTERVAL_APPLIED_BEFORE_CLEANUP=true
LAST_PROCESSED_CLAMPED_TO_BUFF_END=true
POST_EXPIRY_TIME_NOT_APPLIED=true
DUPLICATE_FINAL_INTERVAL_APPLY=false
NEGATIVE_ELAPSED_BLOCKED=true

## Independent A-F Matrix

| Case | Last | End | Now | Effective now | Raw elapsed | Applied elapsed | Apply | Cleanup | Overrun ignored | Result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | ---: | --- |
| A | 33 | 34 | 34 | 34 | 1 | 1 | yes | yes | 0 | PASS |
| B | 33 | 34 | 36 | 34 | 1 | 1 | yes | yes | 2 | PASS |
| C | 31.5 | 34 | 40 | 34 | 2.5 | 2.5 | yes | yes | 6 | PASS |
| D | 34 | 34 | 35 | 34 | 0 | 0 | no | yes | 1 | PASS |
| E | 35 | 34 | 35 | 34 | -1 | 0 | no | yes | 1 | PASS |
| F | 20 | 34 | 21 | 21 | 1 | 1 | yes | no | 0 | PASS |

Case E necessarily produces a negative raw subtraction for the specified `last > effectiveNow` input. The required `elapsed <= 0` guard converts this into no recovery operation: applied elapsed is zero and no negative value reaches `setFractureTime`.

CASE_A_PASS=true
CASE_B_PASS=true
CASE_C_PASS=true
CASE_D_PASS=true
CASE_E_PASS=true
CASE_F_PASS=true
FINAL_INTERVAL_TEST_MATRIX_PASS_COUNT=6
FINAL_INTERVAL_TEST_MATRIX_F
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `EC77E84C7F094450D4F29FE9AC0C231DD9C91BAABD084601E19580B1384DB58D`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

VERSION=[IP_REDACTED]
INTERNAL=[IP_REDACTED]-b42-red-fracture-final-interval-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05552_RED_FRACTURE_FINAL_INTERVAL_FIX_A
RUNTIME_LUA_FILE_COUNT=79
RUNTIME_LUA_LINE_COUNT=13469
KAHLUA_RUNTIME_LUA_SYNTAX_FAIL_COUNT=0

EARLY_RETURN_BEFORE_EFFECTIVE_NOW_CALC=false
EARLY_RETURN_BEFORE_FINAL_INTERVAL_APPLY=false
BUFF_CLEANUP_BEFORE_FINAL_INTERVAL_APPLY=false
FINAL_INTERVAL_APPLIED_BEFORE_CLEANUP=true
LAST_PROCESSED_CLAMPED_TO_BUFF_END=true
POST_EXPIRY_TIME_NOT_APPLIED=true
DUPLICATE_FINAL_INTERVAL_APPLY=false
NEGATIVE_ELAPSED_BLOCKED=true

RED_FRACTURE_DIRECT_EVERYHOURS_REGISTRATION_COUNT=0
RED_FRACTURE_DIRECT_ONTICK_REGISTRATION_COUNT=0
RED_FRACTURE_DIRECT_ONPLAYERUPDATE_REGISTRATION_COUNT=0
RED_FRACTURE_CENTRAL_SCHEDULER_TASK_COUNT=1
SECOND_SCHEDULER_CREATED=false

USES_GAME_TIME_DELTA=true
FPS_INDEPENDENT=true
PAUSE_SAFE=true
TIME_ACCELERATION_SAFE=true
NO_DUPLICATE_SAME_HOUR_TICK=true
SAVELOAD_SAFE=true
FINAL_INTERVAL_SAVELOAD_SAFE=true
FINAL_INTERVAL_TIME_ACCELERATION_SAFE=true

SOURCE_DROP_SHA256_MISMATCH_COUNT=0
STATIC_BLOCKER_COUNT=0
REAL_GAME_BEHAVIOR=NOT_VERIFIABLE_BY_STATIC_AUDIT
MULTIPLAYER_BEHAVIOR=NOT_VERIFIABLE_BY_STATIC_AUDIT


```
