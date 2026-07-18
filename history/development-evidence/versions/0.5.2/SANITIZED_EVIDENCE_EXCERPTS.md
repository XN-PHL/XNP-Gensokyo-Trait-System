# 0.5.2 Sanitized Evidence Excerpts

## 0.5.2_BASELINE_RESET_REPORT.md

- SHA-256: `852A402E622E85802102AFD17D9069BEADC43AEB0B24DE89AE86F87A8185C8E1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.2 Baseline Reset Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH_LABEL=0.4.19

RUNTIME_BASE=0.4.19_RESTORED

TRAIT_DETECTION_SOURCE=0.4.19_RESTORED

## Reset Reason

0.5.0 failed before runtime because CharacterTraitDefinition referenced an unresolved CharacterTrait.

0.5.1 entered the world but failed every update because it used `player:hasTrait(string)`.

0.5.2 therefore discards the 0.5.0/0.5.1 runtime direction and rebuilds from 0.4.19, which had already proven these items in real game:

- game boot
- trait recognition
- target trait true output
- ACTIVE/FADING/READY state transitions
- CharacterStat.ENDURANCE read/write
- no `player:hasTrait(string)` runtime failure

## Minimal 0.5.2 Additions

Only one new gameplay module is added:

- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_StaminaDrain.lua`

This module uses:

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

It does not refill endurance to full and does not implement infinite endurance.

## Deferred Features

- METABOLIC_COST_METHOD=DEBT_ONLY_DISABLED_FOR_0.5.2
- MELEE_BONUS_METHOD=DISABLED_FOR_0.5.2
- SANDBOX_OPTIONS_METHOD=DEFERRED_CONFIG_ONLY
- STATUS_MOODLE_METHOD=NOT_CONFIRMED
- STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT
- MOVEMENT_SPEED_MODIFICATION_METHOD=NONE
- RUNNING_SHOVE_STATUS=DISABLED

```

## 0.5.2_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `BF7067D9981D11C0AA79E6CB0711F01B4FA2920613BFAB3C0703C94BF4EF852D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.2 Real Game Result Summary

0.5.2_TRAIT_RESULT=PASS

0.5.2_STAMINA_RESULT=PASS_BUT_WEAK_FEEL

0.5.2_ADRENALINE_RESULT=PASS

0.5.2_STATUS_ICON_RESULT=DISABLED_AS_EXPECTED

## Evidence

Trait detection succeeded:

```text
[XNP TRAIT] detector_method=RESTORED_FROM_0.4.19
[XNP TRAIT] player has target trait=true
```

Stamina drain reduction triggered:

```text
[XNP STAMINA] method=POST_DRAIN_PARTIAL_REFUND
[XNP STAMINA] first_refund raw=0.000984 refund=0.000345 multiplier=0.650
```

Adrenaline state triggered:

```text
[XNP ADRENALINE] state=ACTIVE
[XNP ADRENALINE] trigger_zombie_distance=2.279
[XNP ADRENALINE] state=FADING
[XNP ADRENALINE] state=READY
```

## 0.5.3 Decision

The 0.5.2 mechanism works, but the user could not clearly feel the effect. 0.5.3 keeps the same stable route and increases test strength:

- READY_STAMINA_DRAIN_MULTIPLIER=0.40
- ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10
- STAMINA_SUMMARY_LOG_INTERVAL=10.0

No movement speed, right-top icon, shove, melee, calories, or sandbox route is restored.

```

## FINAL_REPORT.md

- SHA-256: `3893F19D38FC886AB3FCB131C1551975DABB08BDDC74FE5EB1CD5EA60EF49045`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=0.4.19

VERSION=0.5.2

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_052_0419_BASE_STAMINA_DRAIN_A

0.5.1_RUNTIME_RESULT=FAIL

0.5.1_ROOT_CAUSE=INVALID_TRAIT_QUERY_METHOD

INVALID_METHOD=player:hasTrait(string)

TRAIT_DETECTION_SOURCE=0.4.19_RESTORED

TRAIT_DETECTION_METHOD=RESTORED_FROM_0.4.19

TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

HAS_PLAYER_HAS_TRAIT_STRING_CALL=NO

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

READY_STAMINA_DRAIN_MULTIPLIER=0.65

ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.25

MIN_ENDURANCE_FLOOR=0.05

ADRENALINE_TRIGGER_METHOD=LIMITED_NEARBY_GRID_SQUARE_SCAN_LIVE_ZOMBIE_DISTANCE

THREAT_TRIGGER_RADIUS=4.0

ADRENALINE_MEMORY_DURATION=20.0

METABOLIC_COST_METHOD=DEBT_ONLY_DISABLED_FOR_0.5.2

MELEE_BONUS_METHOD=DISABLED_FOR_0.5.2

STATUS_MOODLE_METHOD=NOT_CONFIRMED

STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT

SANDBOX_OPTIONS_METHOD=DEFERRED_CONFIG_ONLY

MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

RUNNING_SHOVE_STATUS=DISABLED

OLD_SOURCE_MODIFIED=NO

GAME_LAUNCHED=NO

USER_MODS_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

LUA_FILE_COUNT=9

LUA_TOTAL_LINES=888

MARKDOWN_FILE_COUNT=69

TOTAL_FILE_COUNT=86

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

NOT_VERIFIABLE_BY_STATIC_AUDIT:

- Project Zomboid real boot result.
- Lua 5.1 execution syntax check.
- Real endurance drain feel and balance.
- CharacterStat.ENDURANCE runtime exposure in the user's enabled mod set.

Final marker:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.2_SOURCE_READY_FOR_STABLE_STAMINA_DRAIN_TEST

```

## STABLE_STAMINA_DRAIN_TEST_0.5.2.md

- SHA-256: `09045C18B605C0EB90F96179313287955EE5B36033BEACBC72BF60948832B7EE`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.2 Stable Stamina Drain Test

1. 绂佺敤 0.5.0 鍜?0.5.1銆?2. 鍙惎鐢?0.5.2 鍜?B42Trans_CN銆?3. 瀹屽叏閫€鍑烘父鎴忓苟閲嶅惎銆?4. 杩涘叆涓栫晫銆?5. 鎵撳紑浜虹墿淇℃伅闈㈡澘锛岀‘璁ら粍鑹?F 鐗硅川瀛樺湪銆?6. 鏌ョ湅 console 鏄惁鏈夛細
   - `[XNP TRAIT] detector_method=RESTORED_FROM_0.4.19`
   - `[XNP TRAIT] player has target trait=true`
7. 杩滅鍍靛案璺戞锛岀‘璁よ€愬姏浼氫笅闄嶄絾涓嬮檷鍙樻參銆?8. 闈犺繎鍍靛案 4 鏍煎唴锛岀‘璁?ACTIVE 鍚庤€愬姏涓嬮檷鏇存參銆?9. 绂诲紑鍍靛案锛岀‘璁?FADING 鍚庡洖 READY銆?10. 纭娌℃湁 `player:hasTrait` 閿欒銆?11. 纭娌℃湁鍙充笂瑙掑亣鍥炬爣銆?12. 纭娌℃湁绉诲姩閫熷害鍔犳垚銆?13. 纭娌℃湁鎾炴帹銆?14. 鎶?console.txt 浜ゅ洖銆?
Expected result:

- game boots
- world loads
- trait detector logs once
- no per-frame errors
- endurance still drains
- partial refund logs once on first real refund

```

## STATIC_AUDIT.md

- SHA-256: `1A50C534C46B5B314E65C6B0BB3973A9C2631C41415064A3F79F5F331C7E3CE3`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=0.4.19

## Required Confirmations

- 0.5.2 copied from 0.4.19: PASS
- Trait full ID unchanged: PASS
- CharacterTrait script source from 0.4.19: PASS
- registries.lua source from 0.4.19: PASS
- trait detection source restored from 0.4.19 object path: PASS
- active Lua contains `player:hasTrait(string)`: NO
- active Lua contains unprotected trait detection: NO
- active Lua contains CharacterTraitDefinition call: NO
- active Lua contains TraitFactory call: NO
- active Lua contains setFastMoveCheat: NO
- active Lua contains setSpeedMod: NO
- active Lua contains setMoveSpeed: NO
- active Lua contains setPathSpeed: NO
- active Lua contains setCombatSpeed: NO
- active Lua contains player coordinate write: NO
- active Lua contains zombie coordinate write: NO
- active Lua contains GameTime:setMultiplier: NO
- active Lua contains old running shove code: NO
- active Lua contains BumpedState: NO
- active Lua contains right-top coordinate icon code: NO
- active Lua contains intended per-frame log path: NO

## Counts

LUA_FILE_COUNT=9

LUA_TOTAL_LINES=888

MARKDOWN_FILE_COUNT=69

TOTAL_FILE_COUNT=86

## JSON

CN UI.json parse: PASS

EN UI.json parse: PASS

## Lua Syntax Execution

No reliable local Lua 5.1 interpreter was found.

LUA_5_1_EXECUTION_CHECK=NOT_VERIFIABLE_BY_STATIC_AUDIT

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

```
