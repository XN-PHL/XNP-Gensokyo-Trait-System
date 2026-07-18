# 0.5.4 Sanitized Evidence Excerpts

## 0.5.4_VISUAL_FEEDBACK_FAILURE_SUMMARY.md

- SHA-256: `D6F70003409ABD4A1D7C337CFC172AC0AF14A4D22935B5FB3D4EFE0139194DAB`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.4 Visual Feedback Failure Summary

HALO_TEXT_HELPER_TRIGGERED=YES

HALO_TEXT_HELPER_USER_RESULT=LETTER_ONLY

HALO_TEXT_HELPER_RELEASE_STATUS=DISABLED

## Result

0.5.4 confirmed that head text feedback can trigger, but the user saw only a character-like letter over the player instead of a usable status label.

This is not acceptable for a stable release candidate.

## 0.5.5 Decision

ENABLE_VISUAL_FEEDBACK=false

VISUAL_FEEDBACK_METHOD=DISABLED_AFTER_HALO_FAILURE

Active Lua no longer calls:

- HaloTextHelper.addText
- HaloTextHelper.addTextWithArrow
- player:Say
- player:SayWhisper
- AddLineChatElement

Runtime keeps log-only feedback:

```text
[XNP FEEDBACK] method=DISABLED_AFTER_HALO_FAILURE
```

```

## 0.5.4_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `D58E11917375465D5C44DADCC425BD4599D20062C2079DDA060ECBC822B30AFD`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.4 Real Game Result Summary

0.5.4_TRAIT_RESULT=PASS

0.5.4_STAMINA_RESULT=PASS

0.5.4_ADRENALINE_RESULT=PASS

0.5.4_METABOLIC_DEBT_RESULT=PASS

0.5.4_VISUAL_FEEDBACK_RESULT=FAIL_NOT_ACCEPTABLE

0.5.4_RIGHT_TOP_ICON_RESULT=DISABLED_BY_DESIGN

## Evidence

Load:

```text
[XNP DistanceRunner] loaded version=0.5.4 internal=0.5.4-b42-stamina-feedback-metabolic-a build=XNP_PZ_DISTANCE_TRAIT_054_STAMINA_FEEDBACK_METABOLIC_A
```

Trait:

```text
[XNP TRAIT] detector_method=RESTORED_FROM_0.4.19
[XNP TRAIT] CharacterTrait resolved
[XNP TRAIT] player has target trait=true
```

Stamina:

```text
[XNP STAMINA] method=POST_DRAIN_PARTIAL_REFUND
[XNP STAMINA] first_refund raw=0.001231 refund=0.000738 multiplier=0.400
```

Debt:

```text
[XNP STAMINA SUMMARY] state=READY raw_total=0.046027 refund_total=0.027616 debt_total=0.027616 multiplier=0.400
[XNP STAMINA SUMMARY] state=ACTIVE raw_total=0.147681 refund_total=0.116594 debt_total=0.116594 multiplier=0.100
```

Adrenaline:

```text
[XNP ADRENALINE] state=ACTIVE
[XNP ADRENALINE] trigger_zombie_distance=2.743
[XNP ADRENALINE] state=FADING
```

Conclusion:

- CORE_MECHANIC_RESULT=PASS
- METABOLIC_DEBT_RESULT=PASS
- HALO_TEXT_FEEDBACK_RESULT=FAIL_NOT_ACCEPTABLE
- RIGHT_TOP_ICON_RESULT=DISABLED_BY_DESIGN

```

## FINAL_REPORT.md

- SHA-256: `D24F4021BDB26FBC8912990A443C42EEE9F3BCCD69A789EFBFC100A1624FAA01`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=0.5.3

VERSION=0.5.4

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_054_STAMINA_FEEDBACK_METABOLIC_A

0.5.3_TRAIT_RESULT=PASS

0.5.3_STAMINA_RESULT=PASS_VISIBLE

0.5.3_ADRENALINE_RESULT=PASS

0.5.3_VISUAL_FEEDBACK_RESULT=TRIGGERED_TEXT_FAIL_ONLY_T

0.5.3_RIGHT_TOP_ICON_RESULT=DISABLED_AS_EXPECTED

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

READY_STAMINA_DRAIN_MULTIPLIER=0.40

ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10

MIN_ENDURANCE_FLOOR=0.05

ENDURANCE_SAMPLE_INTERVAL=0.10

METABOLIC_COST_METHOD=DEBT_ONLY

METABOLIC_COST_MULTIPLIER=1.0

METABOLIC_APPLICATION_STATUS=NO_DIRECT_PLAYER_STAT_WRITE

VISUAL_FEEDBACK_METHOD=HALO_TEXT_HELPER_SAFE

VISUAL_FEEDBACK_TEXT_LANGUAGE=SHORT_ENGLISH_SAFE

VISUAL_FEEDBACK_EXPECTED_TEXTS=XNP Runner | Runner Ready | Stamina Saved

RIGHT_TOP_ICON_STATUS=DISABLED_INTENTIONALLY

RIGHT_TOP_ICON_REASON=OLD_COORDINATE_ICON_FAILED_LEFT_SIDE

STATUS_MOODLE_METHOD=NOT_CONFIRMED

STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT

MELEE_BONUS_METHOD=DISABLED_FOR_0.5.2

SANDBOX_OPTIONS_METHOD=DEFERRED_CONFIG_ONLY

MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

RUNNING_SHOVE_STATUS=DISABLED

OLD_SOURCE_MODIFIED=NO

GAME_LAUNCHED=NO

USER_MODS_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

LUA_FILE_COUNT=10

LUA_TOTAL_LINES=1005

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

NOT_VERIFIABLE_BY_STATIC_AUDIT:

- Project Zomboid real boot result for 0.5.4.
- Lua 5.1 execution syntax check.
- Whether short English HaloTextHelper text fully fixes the T/t display issue.
- Real user feel of debt-only metabolic tracking.

Final marker:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.4_SOURCE_READY_FOR_STAMINA_FEEDBACK_METABOLIC_TEST

```

## STAMINA_FEEDBACK_METABOLIC_TEST_0.5.4.md

- SHA-256: `B0A52FCFF1098E811CE15D29B2267C6EA3D2C597E9F718631F8E3D8A7C0CC33B`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.4 Stamina Feedback Metabolic Test

1. 绂佺敤 0.5.3 鍜屾墍鏈夋棫鐗堟湰銆?2. 鍙惎鐢?0.5.4 鍜?B42Trans_CN銆?3. 瀹屽叏閲嶅惎娓告垙銆?4. 杩涘叆鏈夆€滈暱閫斿琚€呪€濈殑瑙掕壊銆?5. 鎵撳紑浜虹墿淇℃伅闈㈡澘纭榛勮壊 F 鐗硅川瀛樺湪銆?6. 涓嶈鏈熷緟鍙充笂瑙?F銆?7. 杩滅鍍靛案璺戞锛岀‘璁よ€愬姏涓嬮檷鏄庢樉鍙樻參銆?8. 鏌ョ湅鏄惁鏈?`[XNP STAMINA SUMMARY]`銆?9. 纭 summary 閲屾湁 `debt_total`銆?10. 闈犺繎鍍靛案锛岀‘璁?ACTIVE 鍚庤€愬姏涓嬮檷鏇存參銆?11. 瑙傚療澶撮《鏂囧瓧鏄惁涓嶅啀鏄崟鐙?T/t銆?12. 濡傛灉鍑虹幇 `XNP Runner` / `Runner Ready` / `Stamina Saved`锛屽弽棣堜慨澶嶆垚鍔熴€?13. 濡傛灉浠嶇劧鍙樉绀?T/t锛屽弽棣堝け璐ワ紝涓嬬増鍏抽棴 HaloTextHelper銆?14. 纭娌℃湁 hasTrait 閿欒銆?15. 纭娌℃湁鍙充笂瑙掑亣鍥炬爣銆?16. 纭娌℃湁绉诲姩閫熷害鍔犳垚銆?17. 纭娌℃湁鎾炴帹銆?
Expected summary format:

```text
[XNP STAMINA SUMMARY] state=ACTIVE raw_total=<n> refund_total=<n> debt_total=<n> multiplier=<n>
```

```

## STATIC_AUDIT.md

- SHA-256: `AA50E6C720F21DB0808B5F87687E5E5634A805C297259A204375A9D38DD99E8E`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=0.5.3

## Checks

- Trait full ID unchanged: PASS
- trait detection route from 0.5.3 / 0.4.19 restored route: PASS
- player:hasTrait(string): ABSENT
- TraitFactory: ABSENT
- CharacterTraitDefinition runtime call: ABSENT
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
- direct write Calories: ABSENT
- direct write Hunger: ABSENT
- direct write Fatigue: ABSENT
- direct write Pain: ABSENT
- direct write Stress: ABSENT

RIGHT_TOP_ICON_STATUS=DISABLED_INTENTIONALLY

RIGHT_TOP_ICON_REASON=OLD_COORDINATE_ICON_FAILED_LEFT_SIDE

## Counts

LUA_FILE_COUNT=10

LUA_TOTAL_LINES=1005

TOTAL_FILE_COUNT=93

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

```
