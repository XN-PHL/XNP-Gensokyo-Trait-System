# 0.5.3 Sanitized Evidence Excerpts

## 0.5.3_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `8AACCF40F7DDFE479A9755C9C63465DDD8AB738F7ACCFC5148022E35BA14346A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.3 Real Game Result Summary

0.5.3_TRAIT_RESULT=PASS

0.5.3_STAMINA_RESULT=PASS_VISIBLE

0.5.3_ADRENALINE_RESULT=PASS

0.5.3_VISUAL_FEEDBACK_RESULT=TRIGGERED_TEXT_FAIL_ONLY_T

0.5.3_RIGHT_TOP_ICON_RESULT=DISABLED_AS_EXPECTED

## Evidence

Load:

```text
[XNP DistanceRunner] loaded version=0.5.3 internal=0.5.3-b42-visible-stamina-drain-test-a build=XNP_PZ_DISTANCE_TRAIT_053_VISIBLE_STAMINA_DRAIN_A
```

Trait:

```text
[XNP TRAIT] detector_method=RESTORED_FROM_0.4.19
[XNP TRAIT] CharacterTrait resolved
[XNP TRAIT] player has target trait=true
```

READY stamina:

```text
[XNP STAMINA] method=POST_DRAIN_PARTIAL_REFUND
[XNP STAMINA] first_refund raw=0.001231 refund=0.000738 multiplier=0.400
[XNP STAMINA SUMMARY] state=READY raw_total=0.001231 refund_total=0.000738 multiplier=0.400
```

ACTIVE/FADING stamina:

```text
[XNP ADRENALINE] state=ACTIVE
[XNP ADRENALINE] trigger_zombie_distance=2.151
[XNP STAMINA SUMMARY] state=ACTIVE raw_total=0.147682 refund_total=0.098947 multiplier=0.100
[XNP STAMINA SUMMARY] state=FADING raw_total=0.148174 refund_total=0.133356 multiplier=0.100
```

User report:

- stamina felt more available
- character halo text triggered
- halo text showed only a T/t-like fragment
- no right-top F icon, expected

## 0.5.4 Decision

Keep the proven stamina multipliers and state system. Fix feedback text by using short ASCII English strings and the simplest HaloTextHelper call. Add debt-only metabolic accounting to summary logs.

```

## FINAL_REPORT.md

- SHA-256: `0D9901424855D139ED1BA32654DA7BFAE442D22448281F8867E5D6C6F84F7EE4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=0.5.2

VERSION=0.5.3

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_053_VISIBLE_STAMINA_DRAIN_A

0.5.2_TRAIT_RESULT=PASS

0.5.2_STAMINA_RESULT=PASS_BUT_WEAK_FEEL

0.5.2_ADRENALINE_RESULT=PASS

0.5.2_STATUS_ICON_RESULT=DISABLED_AS_EXPECTED

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

READY_STAMINA_DRAIN_MULTIPLIER=0.40

ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10

MIN_ENDURANCE_FLOOR=0.05

ENDURANCE_SAMPLE_INTERVAL=0.10

VISUAL_FEEDBACK_METHOD=HALO_TEXT_HELPER

STAMINA_SUMMARY_LOG_INTERVAL=10.0

STATUS_MOODLE_METHOD=NOT_CONFIRMED

STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT

METABOLIC_COST_METHOD=DEBT_ONLY_DISABLED_FOR_0.5.2

MELEE_BONUS_METHOD=DISABLED_FOR_0.5.2

SANDBOX_OPTIONS_METHOD=DEFERRED_CONFIG_ONLY

MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

RUNNING_SHOVE_STATUS=DISABLED

OLD_SOURCE_MODIFIED=NO

GAME_LAUNCHED=NO

USER_MODS_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

LUA_FILE_COUNT=10

LUA_TOTAL_LINES=976

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

NOT_VERIFIABLE_BY_STATIC_AUDIT:

- Project Zomboid real boot result for 0.5.3.
- Lua 5.1 execution syntax check.
- HaloTextHelper global exposure in Lua.
- Real visible strength and stamina feel.

Final marker:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.3_SOURCE_READY_FOR_VISIBLE_STAMINA_DRAIN_TEST

```

## VISIBLE_STAMINA_DRAIN_TEST_0.5.3.md

- SHA-256: `4EA9B811B0ABFADA09F4F539B8889FB8A173FA20CE7B5686900D871C766D8643`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.3 Visible Stamina Drain Test

1. 绂佺敤 0.5.2 鍜屾墍鏈夋棫鐗堟湰銆?2. 鍙惎鐢?0.5.3 鍜?B42Trans_CN銆?3. 瀹屽叏閲嶅惎娓告垙銆?4. 杩涘叆鏈夆€滈暱閫斿琚€呪€濈殑瑙掕壊銆?5. 纭浜虹墿淇℃伅闈㈡澘榛勮壊 F 瀛樺湪銆?6. 涓嶈鏈熷緟鍙充笂瑙?F锛?.5.3 浠嶇劧鍏抽棴璇ヨ矾绾裤€?7. 杩滅鍍靛案璺戞 1 鍒嗛挓銆?8. 瑙傚療鑰愬姏涓嬮檷鏄惁鏄庢樉鎱簬鍘熺増銆?9. 鏌ョ湅鏄惁鍑虹幇 `[XNP STAMINA SUMMARY]`銆?10. 闈犺繎鍍靛案 4 鏍煎唴銆?11. 瑙傚療 ACTIVE 鍚庤€愬姏涓嬮檷鏄惁杩涗竴姝ユ槑鏄惧彉鎱€?12. 濡傛灉鍙鍙嶉鍚敤锛屽簲鐪嬪埌鈥滈暱閫斿琚€咃細搴旀縺鈥濄€?13. 绂诲紑鍍靛案鍚庤繘鍏?FADING銆?14. 绾?20 绉掑悗鍥?READY銆?15. 纭娌℃湁 hasTrait 閿欒銆佹病鏈夊彸涓婅鍋囧浘鏍囥€佹病鏈夌Щ鍔ㄩ€熷害鍔犳垚銆佹病鏈夋挒鎺ㄣ€?
Expected logs:

```text
[XNP TRAIT] detector_method=RESTORED_FROM_0.4.19
[XNP TRAIT] player has target trait=true
[XNP STAMINA] first_refund raw=<n> refund=<n> multiplier=<n>
[XNP STAMINA SUMMARY] state=<READY/ACTIVE/FADING> raw_total=<n> refund_total=<n> multiplier=<n>
```

```

## STATIC_AUDIT.md

- SHA-256: `5F8C6C0044EA52543FC2828640C46D1EBB4B72FEDB9C93C5EA73BDB4A531ECE7`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=0.5.2

## Checks

- Trait full ID unchanged: PASS
- Trait detection route from 0.5.2 / 0.4.19 restored route: PASS
- player:hasTrait(string): ABSENT
- TraitFactory: ABSENT
- CharacterTraitDefinition call: ABSENT
- setFastMoveCheat: ABSENT
- setSpeedMod: ABSENT
- setMoveSpeed: ABSENT
- setPathSpeed: ABSENT
- setCombatSpeed: ABSENT
- player coordinate write: ABSENT
- zombie coordinate write: ABSENT
- GameTime:setMultiplier: ABSENT
- RunningShove: ABSENT
- BumpedState: ABSENT
- right-top coordinate icon code: ABSENT
- 8 second probe: ABSENT
- intended per-frame log: ABSENT

## 0.5.3 Changes

- READY_STAMINA_DRAIN_MULTIPLIER=0.40
- ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10
- STAMINA_SUMMARY_LOG_INTERVAL=10.0
- VISUAL_FEEDBACK_METHOD=HALO_TEXT_HELPER

## Counts

LUA_FILE_COUNT=10

LUA_TOTAL_LINES=976

TOTAL_FILE_COUNT=90

## Lua Execution

No reliable local Lua 5.1 interpreter was found.

LUA_5_1_EXECUTION_CHECK=NOT_VERIFIABLE_BY_STATIC_AUDIT

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

```
