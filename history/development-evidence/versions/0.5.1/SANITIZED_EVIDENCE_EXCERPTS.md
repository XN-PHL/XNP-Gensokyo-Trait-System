# 0.5.1 Sanitized Evidence Excerpts

## 0.5.1_RUNTIME_FAILURE_ANALYSIS.md

- SHA-256: `6AB588198E8C8E310E4723BCF3FCF4F872125D9A532DFBFFDB2F0BCE6EE67496`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.1 Runtime Failure Analysis

0.5.1_BOOT_RESULT=PASS

0.5.1_RUNTIME_RESULT=FAIL

0.5.1_ROOT_CAUSE=INVALID_TRAIT_QUERY_METHOD

INVALID_METHOD=player:hasTrait(string)

0.5.1_EFFECT_RESULT=NO_EFFECT_BECAUSE_RUNTIME_ERRORS_EVERY_UPDATE

## Console Evidence

User-provided latest console result:

```text
No implementation found for function:
hasTrait(class zombie.characters.IsoPlayer, class java.lang.String XNPDistanceRunnerTrait:XNPDistanceRunner)
```

Reported failing locations:

- XNP_DR_Trait.lua:20
- XNP_DR_Trait.lua:40
- XNP_DR_Runtime.lua:43

## Conclusion

Build 42.19 Lua binding does not expose a valid `IsoPlayer.hasTrait(String)` call for the full trait id string.

0.5.1 implemented the wrong trait query path. Because Runtime called that path on update, the game could enter the world but produced repeated runtime errors and the stamina effect did not run.

## 0.5.2 Correction

0.5.2 is rebuilt from the last real-game-successful 0.4.19 source, not from 0.5.1.

TRAIT_DETECTION_SOURCE=0.4.19_RESTORED

TRAIT_DETECTION_METHOD=RESTORED_FROM_0.4.19

HAS_PLAYER_HAS_TRAIT_STRING_CALL=NO

```

## BOOT_AND_STAMINA_CORE_TEST_0.5.1.md

- SHA-256: `AC5B7C89A6F8B7068E0886660EE9454C0B1287E0611313159220CB5456672D5D`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.1 鍚姩涓庤€愬姏鏍稿績娴嬭瘯

1. 绉诲嚭鎴栫鐢?0.5.0銆?2. 鍙惎鐢?0.5.1銆?3. 瀹屽叏閫€鍑烘父鎴忓苟閲嶅惎銆?4. 鍏堝彧纭鑳戒笉鑳借繘鍏ヤ富鑿滃崟銆?5. 鑳借繘鍏ヤ富鑿滃崟鍚庯紝鍐嶈繘鍏ュ凡鏈夆€滆窛绂昏窇鑰呪€濊鑹插瓨妗ｃ€?6. 鎵撳紑浜虹墿淇℃伅闈㈡澘锛岀‘璁ら粍鑹?F 鐗硅川瀛樺湪銆?7. 杩滅鍍靛案璺戞锛岀‘璁よ€愬姏浼氫笅闄嶏紝浣嗕笅闄嶅彉鎱€?8. 闈犺繎鍍靛案锛岀‘璁ゆ棩蹇楀嚭鐜?ACTIVE/FADING 鐘舵€併€?9. 妫€鏌?console 鏄惁杩樺瓨鍦?`character_trait_definition load error`銆?10. 濡傛灉浠嶇劧杩涗笉浜嗘父鎴忥紝绔嬪嵆鍋滄娴嬭瘯锛屾妸 console.txt 浜ゅ洖銆?
棰勬湡锛?
- 涓昏彍鍗曞彲杩涘叆銆?- 瀛樻。鍙繘鍏ャ€?- 涓嶅啀鍑虹幇 CharacterTraitDefinition 绌哄紩鐢ㄥ穿婧冦€?- 涓嶆樉绀哄彸涓婅鑷粯 F 鐘舵€佸浘鏍囥€?- 涓嶆祴璇曡繎鎴樺姞鎴愩€?
```

## CHANGELOG.md

- SHA-256: `6E66CD5B2BF24BFF85834C338DAE699753EFF2AE47791C9B040D53CB2E1620C2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

## 0.5.1

- 鏂板缓鐙珛 SOURCE锛歑NP_PZ_DistanceRunnerTrait_0.5.1_B42_BOOT_TRAIT_FIX_SOURCE銆?- 淇 0.5.0 B42 鑴氭湰鍔犺浇闃舵 CharacterTraitDefinition 绌哄紩鐢ㄥ穿婧冦€?- 浠?0.4.19 鎭㈠ `42/media/registries.lua`銆?- 浠?0.4.19 鎭㈠ `42/media/scripts/XNPDistanceRunnerTraits.txt`銆?- 浠?0.4.19 鎭㈠涓嫳鏂囩炕璇戝拰榛勮壊 F trait 鍥炬爣銆?- 淇濈暀 0.5.0 鐨勮€愬姏娑堣€楀€嶇巼銆佽偩涓婅吅绱犲拰浠ｈ阿鍋胯繕浠ｇ爜銆?- 榛樿鍏抽棴婊¤€愬姏杩戞垬鍔犳垚锛屼笉娉ㄥ唽杩戞垬鍛戒腑浜嬩欢銆?- 缁х画绂佺敤鐘舵€佸浘鏍囪嚜缁樸€侀€熷害鍐欏叆銆佸潗鏍囧啓鍏ャ€佹椂闂翠慨鏀瑰拰濂旇窇鎺ㄦ挒銆?
```

## FINAL_REPORT.md

- SHA-256: `4C009AAF00AC7098DCD8C1F30BC45A48A138CEB443FA18E39E2CEB2E8AEB434E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.1

INTERNAL_VERSION=0.5.1-b42-boot-trait-fix-a

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_051_BOOT_TRAIT_FIX_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.1 Boot Trait Fix

## 0.5.0 Failure

0.5.0_BOOT_RESULT=FAIL

0.5.0_FAILURE_STAGE=B42_SCRIPT_LOAD

0.5.0_ROOT_CAUSE=CharacterTraitDefinition references unresolved CharacterTrait

0.5.0_RUNTIME_LUA_NOT_REACHED=YES

0.5.0_STAMINA_SYSTEM_NOT_TESTED=YES

## 0.5.1 Trait Fix

CHARACTER_TRAIT_SCRIPT_SOURCE=0.4.19_RESTORED

TRAIT_DEFINITION_METHOD=B42_NATIVE_CHARACTER_TRAIT_REGISTER_PLUS_SCRIPT_DEFINITION

TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

CHARACTER_TRAIT_DEFINITION_NULL_RISK=FIXED

EXPECTED_BOOT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

## Gameplay State

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

METABOLIC_COST_METHOD=CALORIES

MELEE_BONUS_DEFAULT_ENABLED=false

STATUS_MOODLE_METHOD=NOT_CONFIRMED

STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT

MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

RUNNING_SHOVE_STATUS=DISABLED

## Safety

OLD_SOURCE_MODIFIED=NO

GAME_LAUNCHED=NO

STEAM_LAUNCHED=NO

USER_MODS_WRITTEN=NO

USER_SAVES_WRITTEN=NO

WORKSHOP_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

PLAYER_COORDINATES_MODIFIED=NO

ZOMBIE_COORDINATES_MODIFIED=NO

GAME_TIME_MODIFIED=NO

## Counts

LUA_FILE_COUNT=10

LUA_TOTAL_LINES=567

MARKDOWN_FILE_COUNT=15

TOTAL_FILE_COUNT=31

## Static Result

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

NOT_VERIFIABLE_BY_STATIC_AUDIT:

- Project Zomboid real boot result.
- Lua 5.1 execution syntax check, no reliable local interpreter found.
- Final CharacterTrait.register result in real B42 script load order.
- CharacterStat.ENDURANCE Lua exposure.
- Nutrition calories Lua exposure.

Final marker:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.1_SOURCE_READY_FOR_BOOT_AND_STAMINA_CORE_TEST

```

## README_CN.md

- SHA-256: `2B03244B14AA102B9E59C69997DA2B1CA05031D2C11A498324B5259CD6A207E2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.1 Boot Trait Fix

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

鐗堟湰锛?.5.1

鍐呴儴鐗堟湰锛?.5.1-b42-boot-trait-fix-a

鏋勫缓鏍囪瘑锛歑NP_PZ_DISTANCE_TRAIT_051_BOOT_TRAIT_FIX_A

鏈増鏈彧淇 0.5.0 鍦?B42 鑴氭湰鍔犺浇闃舵宕╂簝鐨勯棶棰樸€備紭鍏堢骇鏄?BOOT_FIRST锛氭父鎴忓繀椤诲厛鑳借繘鍏ヤ富鑿滃崟鍜屽瓨妗ｃ€?
淇绛栫暐锛?
- 浠?0.4.19 宸插疄鏈烘垚鍔?SOURCE 鎭㈠ trait 瀹氫箟閾俱€?- 淇濈暀 0.5.0 鐨勮€愬姏娑堣€楀€嶇巼銆佽偩涓婅吅绱犵姸鎬佸拰浠ｈ阿鍋胯繕鏂囦欢銆?- 榛樿鍏抽棴婊¤€愬姏杩戞垬鍔犳垚銆?- 榛樿涓嶆樉绀哄彸涓婅鐘舵€?F銆?- 涓嶅啓鐜╁鍧愭爣锛屼笉鏀规父鎴忔椂闂达紝涓嶆仮澶嶆棫閫熷害娴嬭瘯璺嚎銆?
鍏抽敭鐘舵€侊細

- CHARACTER_TRAIT_SCRIPT_SOURCE=0.4.19_RESTORED
- CHARACTER_TRAIT_DEFINITION_NULL_RISK=FIXED
- EXPECTED_BOOT_RESULT=PASS_REAL_GAME_TEST_REQUIRED
- STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND
- METABOLIC_COST_METHOD=CALORIES
- MELEE_BONUS_DEFAULT_ENABLED=false

```

## BOOT_SAFETY_AUDIT.md

- SHA-256: `6796BD2F7FAD35FA025F532B9AE67D379021E9AD7BC469E89E595A8FC7DC56A2`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Boot Safety Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

CHARACTER_TRAIT_SCRIPT_SOURCE=0.4.19_RESTORED

CHARACTER_TRAIT_DEFINITION_NULL_RISK=FIXED

EXPECTED_BOOT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

## Layout

- Root contains `mod.info` and `42`.
- `42` contains `mod.info` and `media`.
- B42 Lua is only under `42/media/lua`.
- No root `media/lua` directory exists.
- No nested `XNP...\XNP...\mod.info` layout was generated.

## Trait Chain

- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- Trait short ID: `XNPDistanceRunner`
- Script file: `42/media/scripts/XNPDistanceRunnerTraits.txt`
- Registry file: `42/media/registries.lua`
- Registry source: 0.4.19 restored.
- Trait icon path: `media/ui/Traits/trait_xnpdistancerunner.png`

## Runtime Safety

- Gameplay Lua does not create CharacterTraitDefinition.
- Gameplay Lua does not call TraitFactory.
- Gameplay Lua does not modify CharacterTraitDefinition.
- Runtime only reads whether the loaded player has the target trait.
- If runtime trait detection fails, runtime feature paths stay inactive and should not stop boot.

## High Risk Features

- Full stamina melee bonus default: false.
- Status icon fallback: disabled by default.
- Movement speed modification: none.
- Running shove: disabled.
- Coordinates writes: none.
- Game time modification: none.

BOOT_SAFETY_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

```

## STATIC_AUDIT.md

- SHA-256: `E0F19484F65F0A3E86F3D7FDE5F2D11CF20164F2CBF9912B7C2042D6DF379867`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

Audit date: 2026-07-07

## Boot First Checks

- CHARACTER_TRAIT_SCRIPT_SOURCE=0.4.19_RESTORED
- CHARACTER_TRAIT_DEFINITION_NULL_RISK=FIXED
- EXPECTED_BOOT_RESULT=PASS_REAL_GAME_TEST_REQUIRED
- Trait full ID remains `XNPDistanceRunnerTrait:XNPDistanceRunner`.
- `42/media/registries.lua` restored from 0.4.19 and contains `CharacterTrait.register(XNP_DR_TRAIT_FULL_ID)`.
- `42/media/scripts/XNPDistanceRunnerTraits.txt` restored from 0.4.19.

## Layout Checks

- Root `mod.info`: present.
- Root `42`: present.
- `42/mod.info`: present.
- `42/media`: present.
- B42 Lua under `42/media/lua`: present.
- Root `media/lua`: absent.
- Nested duplicate mod root: absent by path review.

## Runtime Checks

- Gameplay Lua creates CharacterTraitDefinition: NO
- Gameplay Lua calls TraitFactory: NO
- Gameplay Lua modifies CharacterTraitDefinition: NO
- Full stamina melee bonus default enabled: false
- Status icon default: disabled
- Movement speed modification: none
- Running shove: disabled

## Static Text Checks

- Empty file check: PASS
- Text NULL byte check: PASS
- JSON parse check: PASS
- Lua file count: 10
- Lua total line count: 567
- Markdown document count: 15
- Total file count: 31
- Lua parentheses balance text scan: PASS
- Repeated function definition scan: PASS
- Active Lua old speed method scan: PASS
- Active Lua coordinate write scan: PASS
- Active Lua game time modification scan: PASS
- Root media/lua scan: PASS

## Lua Execution Check

No reliable local Lua 5.1 interpreter was found.

Result: NOT_VERIFIABLE_BY_STATIC_AUDIT.

## Real Game Required

Static checks cannot prove Project Zomboid boot success. The next required step is user-side boot test using `BOOT_AND_STAMINA_CORE_TEST_0.5.1.md`.

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

```
