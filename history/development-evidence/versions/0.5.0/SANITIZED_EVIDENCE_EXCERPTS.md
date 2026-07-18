# 0.5.0 Sanitized Evidence Excerpts

## 0.5.0_BOOT_FAILURE_ANALYSIS.md

- SHA-256: `4FD5A153DEFA46EFF0CEF0F8A994C9A5CEB929A4528C8932DB9C74A0F809C0BF`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.0 Boot Failure Analysis

0.5.0_BOOT_RESULT=FAIL

0.5.0_FAILURE_STAGE=B42_SCRIPT_LOAD

0.5.0_ROOT_CAUSE=CharacterTraitDefinition references unresolved CharacterTrait

0.5.0_RUNTIME_LUA_NOT_REACHED=YES

0.5.0_STAMINA_SYSTEM_NOT_TESTED=YES

## Console Evidence

鐢ㄦ埛鎻愪緵鐨勬渶鏂?console.txt 鍏抽敭鏃ュ織锛?
```text
loading XNP_PZ_DistanceRunnerTrait
[XNP DISTANCE RUNNER] load version=0.5.0 build=XNP_PZ_DISTANCE_TRAIT_050_STAMINA_METABOLIC_A
[character_trait_definition] removing script due to load error = XNPDistanceRunnerTrait:XNPDistanceRunner
java.lang.NullPointerException:
Cannot invoke "zombie.scripting.objects.CharacterTrait.getName()"
because "this.characterTraitType" is null
ScriptBucket.LoadScripts> Exception thrown
java.io.IOException: Script load errors
GameThread exited.
```

## Static Cause

0.5.0 鐨?`42/media/scripts/XNPDistanceRunnerTraits.txt` 澹版槑锛?
```text
CharacterTrait = XNPDistanceRunnerTrait:XNPDistanceRunner
```

浣?0.5.0 鐨?`42/media/registries.lua` 鍙褰曟棩蹇楋細

```text
TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION
```

瀹冩病鏈夋仮澶?0.4.19 涓凡楠岃瘉鐨勶細

```lua
CharacterTrait.register("XNPDistanceRunnerTrait:XNPDistanceRunner")
```

鍥犳 B42 鍦ㄥ姞杞?`character_trait_definition` 鏃舵壘涓嶅埌宸叉敞鍐岀殑 CharacterTrait 瀵硅薄锛宍characterTraitType` 涓?null銆?
## 0.5.1 Fix

0.5.1 鐩存帴浠?0.4.19 鎭㈠ trait 瀹氫箟閾剧浉鍏虫枃浠讹紝涓嶉噸鏂板彂鏄?CharacterTraitDefinition 鏍煎紡銆?
CHARACTER_TRAIT_SCRIPT_SOURCE=0.4.19_RESTORED

CHARACTER_TRAIT_DEFINITION_NULL_RISK=FIXED

```

## 0.4_BRANCH_REAL_GAME_CONCLUSION.md

- SHA-256: `20D958ADB94DB617CF43BEF992EB3B0E8F8D8C0738E8FB9F467B93EC99731FB9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4 Branch Real Game Conclusion

0.4 鍒嗘敮瀹炴満缁撹宸插喕缁撳埌鏈閲嶆瀯锛?
- 鐗硅川瀹氫箟銆佷汉鐗╁垱寤哄垪琛ㄣ€侀粍鑹?F 鍥炬爣銆佷腑鏂囩炕璇戙€佺帺瀹剁壒璐ㄦ娴嬫垚绔嬨€?- 0.4.19 鐨勮偩涓婅吅绱犺Е鍙戝彲浠ュ湪瀹炴満鏃ュ織涓繘鍏?ACTIVE/FADING/READY銆?- 0.4.19 鐨勭洿鎺ヨ€愬姏鎭㈠璺緞鍙啓鍏ヨ€愬姏锛屼絾杩囧己锛屽鏄撳舰鎴愭帴杩戞弧鑰愬姏閿佸畾銆?- 0.4 鍒嗘敮鐨勭洿鎺ョЩ鍔ㄩ€熷害灏濊瘯娌℃湁褰㈡垚鍙潬鐜╂硶缁撹銆?- 0.4 鍒嗘敮鐨勭姸鎬佸浘鏍囧潗鏍囧皾璇曟樉绀轰綅缃敊璇紝涓嶈兘浣滀负姝ｅ紡鐘舵€佸浘鏍囧疄鐜般€?- 0.4 鍒嗘敮鐨勬帹鎾炶矾绾垮叧闂紝涓嶈繘鍏?0.5.0銆?
0.5.0 缁ф壙鐨勭ǔ瀹氶儴鍒嗭細

- TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION
- 榛勮壊 F 鍥炬爣浠嶄綔涓?character trait 鍥炬爣浣跨敤銆?- 鐜╁鏄惁鎷ユ湁 XNPDistanceRunnerTrait:XNPDistanceRunner 浠嶇敱鍘熺敓鐗硅川妫€娴嬪垽鏂€?
0.5.0 鏀惧純鐨勯儴鍒嗭細

- MOVEMENT_SPEED_MODIFICATION_METHOD=NONE
- RUNNING_SHOVE_STATUS=DISABLED
- 鍧愭爣鍐欏叆=NO
- 鏃堕棿閫熷害淇敼=NO
- 閿欒鍧愭爣鐘舵€佸浘鏍?NO

```

## 0.5.0_VS_0.4.19_TRAIT_DEFINITION_DIFF.md

- SHA-256: `B7D5404937709CFB4E00F84EFDA08DFBC02832E75286A7B7FB203DAA1CEB3805`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.0 vs 0.4.19 Trait Definition Diff

Compared sources:

- 0.5.0: `[LOCAL_PATH_REDACTED]`
- 0.4.19: `[LOCAL_PATH_REDACTED]`

## Compared Files

- `42/media/scripts/XNPDistanceRunnerTraits.txt`
- `42/media/registries.lua`
- `42/mod.info`
- `mod.info`
- `42/media/lua/shared/translate/EN/UI.json`
- `42/media/lua/shared/translate/CN/UI.json`
- `42/media/ui/Traits/trait_xnpdistancerunner.png`

## Critical Difference

0.4.19 `42/media/registries.lua` registers the native trait before the script definition is resolved:

```lua
CharacterTrait.register("XNPDistanceRunnerTrait:XNPDistanceRunner")
```

0.5.0 `42/media/registries.lua` only logged the selected definition method and did not register the CharacterTrait object.

## Direct Answer

1. 0.5.0 瀵艰嚧 `CharacterTraitDefinition.characterTraitType` 涓?null 鐨勬枃浠讹細
   - `42/media/registries.lua`
   - 鍘熷洜锛氱己灏?`CharacterTrait.register("XNPDistanceRunnerTrait:XNPDistanceRunner")`銆?
2. 0.4.19 鑳藉惎鍔ㄧ殑鍘熷洜锛?   - 瀹冨湪 registries.lua 涓皟鐢?B42 鍘熺敓 `CharacterTrait.register`銆?   - `XNPDistanceRunnerTraits.txt` 涓殑 `CharacterTrait = XNPDistanceRunnerTrait:XNPDistanceRunner` 鑳借В鏋愬埌宸叉敞鍐屽璞°€?
3. 0.5.1 鎭㈠鐨勬枃浠讹細
   - `42/media/scripts/XNPDistanceRunnerTraits.txt`
   - `42/media/registries.lua`
   - `42/media/lua/shared/translate/CN/UI.json`
   - `42/media/lua/shared/translate/EN/UI.json`
   - `42/media/ui/Traits/trait_xnpdistancerunner.png`

4. Trait full ID 鏄惁淇濇寔涓嶅彉锛?   - YES
   - `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 0.5.1 Decision

BOOT_FIRST priority applies. 0.5.1 restores the proven 0.4.19 trait definition route and keeps gameplay Lua away from CharacterTraitDefinition creation.

```

## CHANGELOG.md

- SHA-256: `1B812EF6D38BB46CD8D50B73BA594D2C9E0B52D6EC7223D96CCFCABEFD7BDCDC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

## 0.5.0

- 鏂板缓鐙珛 SOURCE锛歑NP_PZ_DistanceRunnerTrait_0.5.0_B42_STAMINA_METABOLIC_CORE_SOURCE銆?- 淇濈暀 Mod ID銆乀rait full ID銆丅42 鍘熺敓鐗硅川瀹氫箟銆佷汉鐗╁垱寤烘垚鏈€佷腑鏂囩炕璇戙€侀粍鑹?F 鍥炬爣銆佺帺瀹跺師鐢熺壒璐ㄦ娴嬨€?- 绉婚櫎 0.4 鍒嗘敮鐨勯€熷害鍐欏叆銆佸潗鏍囧啓鍏ャ€佹椂闂翠慨鏀广€佹帹鎾炪€佷腑蹇?HUD銆侀敊璇潗鏍囩姸鎬佸浘鏍囧拰 XP 閫掑綊濂栧姳閫昏緫銆?- 鏂板鑰愬姏娑堣€楀悗缃儴鍒嗚繑杩樸€?- 鏂板娲讳綋鍍靛案鍗婂緞瑙﹀彂鑲句笂鑵虹礌鐘舵€併€?- 鏂板 calories 浠ｈ阿鍋胯繕銆?- 鏂板婊¤€愬姏杩戞垬浼ゅ鍔犳垚锛岄檺瀹氱帺瀹舵湁鐩爣鐗硅川銆佽繎鎴樻鍣ㄣ€佺洰鏍囦负鍍靛案銆佽€愬姏杈惧埌闃堝€笺€?- 鐘舵€佸浘鏍囬粯璁ょ鐢紝绛夊緟鐪?Moodle 娉ㄥ唽閾惧疄鏈虹‘璁ゃ€?
```

## FINAL_REPORT.md

- SHA-256: `3FB9262BC48D79D64853066D2D523397735F888ADB7B38835664F3F98D04571F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.0

INTERNAL_VERSION=0.5.0-b42-stamina-metabolic-core-a

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_050_STAMINA_METABOLIC_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.0 Stamina Metabolic Core

MOD_ID=XNP_PZ_DistanceRunnerTrait

TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

ADRENALINE_TRIGGER_METHOD=LIVE_ZOMBIE_RADIUS_MEMORY

METABOLIC_COST_METHOD=CALORIES

STATUS_MOODLE_METHOD=NOT_CONFIRMED

STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT

SANDBOX_OPTIONS_METHOD=FALLBACK_CONFIG_LUA

MELEE_BONUS_METHOD=ON_MELEE_HIT_DAMAGE_MULTIPLIER

MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

RUNNING_SHOVE_STATUS=DISABLED

RUN_SPEED_SUPPORT_METHOD=REDUCED_STAMINA_DRAIN_ONLY

## Numeric Defaults

- ENABLE_READY_DRAIN_REDUCTION=true
- NORMAL_STAMINA_DRAIN_MULTIPLIER=0.65
- ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.25
- MIN_ENDURANCE_FLOOR=0.05
- ENDURANCE_SAMPLE_INTERVAL=0.10
- THREAT_TRIGGER_RADIUS=4.0
- THREAT_SCAN_INTERVAL=0.50
- ADRENALINE_MEMORY_DURATION=20.0
- METABOLIC_COST_MULTIPLIER=1.0
- METABOLIC_APPLY_INTERVAL=1.0
- ENABLE_FULL_STAMINA_MELEE_BONUS=true
- FULL_STAMINA_THRESHOLD=0.95
- FULL_STAMINA_MELEE_DAMAGE_MULTIPLIER=1.25
- ENABLE_EXPERIMENTAL_STATUS_ICON=false

## Runtime Behavior

- 淇敼鐜╁鍧愭爣=NO
- 淇敼娓告垙鏃堕棿=NO
- 褰卞搷鏃犵洰鏍囩壒璐ㄨ鑹?NO
- 閫愬抚鍒锋棩蹇?NO
- 鍚姩娓告垙=NO
- 鍚姩 Steam=NO
- 鍐欑敤鎴?mods 鐩綍=NO
- 鍐欏瓨妗ｇ洰褰?NO
- 鍐?Workshop 鐩綍=NO
- 鍐欐父鎴忓畨瑁呯洰褰?NO
- 淇敼鏃?SOURCE=NO

## Implemented Files

- Lua 鏂囦欢鏁伴噺=10
- Lua 鎬昏鏁?549
- Markdown 鏂囨。鏁伴噺=11
- mod.info 鏁伴噺=2
- JSON 缈昏瘧鏂囦欢鏁伴噺=2
- trait script 鏂囦欢鏁伴噺=1
- PNG 鍥炬爣鏂囦欢鏁伴噺=1
- 鎬绘枃浠舵暟閲?27

## Public Modules

- XNP_DR_Config.lua: config defaults, optional SandboxVars read, method constants.
- XNP_DR_Trait.lua: player native trait detection.
- XNP_DR_Adrenaline.lua: live zombie radius scan and READY/ACTIVE/FADING state.
- XNP_DR_StaminaDrain.lua: post-drain partial endurance refund.
- XNP_DR_MetabolicCost.lua: calories application from refund debt.
- XNP_DR_MeleeBonus.lua: full endurance melee damage multiplier.
- XNP_DR_StatusMoodle.lua: disabled default status feature declaration.
- XNP_DR_Runtime.lua: event registration, module isolation, update calls.

## Static Result

STATIC_AUDIT_RESULT=PASS_WITH_REAL_GAME_TEST_REQUIRED

NOT_VERIFIABLE_BY_STATIC_AUDIT:

- Lua 5.1 execution syntax check, no local interpreter found.
- CharacterStat.ENDURANCE exposure in Lua.
- Nutrition calories methods exposure in Lua.
- OnWeaponHitCharacter Lua event parameter order.
- True Moodle registration and texture binding.
- Game balance of refund/calories values.

## Required Real Game Test

REAL_GAME_TEST_REQUIRED=YES

Test guide:

- STAMINA_METABOLIC_CORE_TEST_0.5.0.md

Final marker:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.0_SOURCE_READY_FOR_STAMINA_METABOLIC_CORE_TEST

```

## README_CN.md

- SHA-256: `4C09D13B85690C254AD792FA5C3AF1DCE6B50DA91976711395CADA8CF6FBFF22`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.0 Stamina Metabolic Core

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

鐗堟湰锛?.5.0

鍐呴儴鐗堟湰锛?.5.0-b42-stamina-metabolic-core-a

鏋勫缓鏍囪瘑锛歑NP_PZ_DISTANCE_TRAIT_050_STAMINA_METABOLIC_A

鏈増鏈槸涓€娆″畬鏁撮噸鏋勶細涓嶅啀灏濊瘯鐩存帴鎻愰珮涓栫晫绉诲姩閫熷害锛屼笉鍐嶅啓鐜╁鍧愭爣锛屼笉鍐嶄慨鏀规椂闂撮€熷害锛屼笉鍐嶄繚鐣欐帹鎾炴祴璇曢€昏緫銆傛牳蹇冩敼涓猴細

- 闄嶄綆鑰愬姏娑堣€楋細STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND
- 濞佽儊瑙﹀彂鑲句笂鑵虹礌锛欰DRENALINE_TRIGGER_METHOD=LIVE_ZOMBIE_RADIUS_MEMORY
- 浠ｈ阿鍋胯繕锛歁ETABOLIC_COST_METHOD=CALORIES
- 閰嶇疆鍥為€€锛歋ANDBOX_OPTIONS_METHOD=FALLBACK_CONFIG_LUA
- 姝ｅ紡鐘舵€佸浘鏍囨殏涓嶅惎鐢細STATUS_MOODLE_METHOD=NOT_CONFIRMED
- 绉诲姩閫熷害淇敼鍏抽棴锛歁OVEMENT_SPEED_MODIFICATION_METHOD=NONE
- 濂旇窇鎺ㄦ挒鍏抽棴锛歊UNNING_SHOVE_STATUS=DISABLED

瀹夎娴嬭瘯鏂瑰紡锛氬鍒舵湰 SOURCE 鍒?Project Zomboid mods 娴嬭瘯浣嶇疆鍚庯紝鍦ㄦ父鎴忓唴鎵嬪姩鍚敤銆傚綋鍓?SOURCE 娌℃湁鑷姩鍐欏叆鐢ㄦ埛 mods銆佸瓨妗ｃ€乄orkshop 鎴栨父鎴忓畨瑁呯洰褰曘€?
榛樿鏁板€硷細

- NORMAL_STAMINA_DRAIN_MULTIPLIER=0.65
- ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.25
- MIN_ENDURANCE_FLOOR=0.05
- ENDURANCE_SAMPLE_INTERVAL=0.10
- THREAT_TRIGGER_RADIUS=4.0
- THREAT_SCAN_INTERVAL=0.50
- ADRENALINE_MEMORY_DURATION=20.0
- METABOLIC_COST_MULTIPLIER=1.0
- METABOLIC_APPLY_INTERVAL=1.0
- FULL_STAMINA_THRESHOLD=0.95
- FULL_STAMINA_MELEE_DAMAGE_MULTIPLIER=1.25

```

## STAMINA_METABOLIC_CORE_TEST_0.5.0.md

- SHA-256: `3AA1E1A0E6057138EC621A58378C3679F464FA660CBE671C87E8BA45218DAD1C`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Stamina Metabolic Core Test 0.5.0

娴嬭瘯鍓嶏細

1. 纭娓告垙鐗堟湰涓?Project Zomboid Build 42.19.0銆?2. 鎵嬪姩鎶?SOURCE 澶嶅埗鍒扮敤鎴?mods 娴嬭瘯鐩綍銆?3. 鍚敤 `XNP Distance Runner Trait 0.5.0 Stamina Metabolic Core`銆?4. 鏂板缓瑙掕壊骞堕€夋嫨鈥滆窛绂昏窇鑰呪€濄€?5. 涓嶅惎鐢ㄦ棫 0.4 鍒嗘敮鍚屽悕娴嬭瘯鐗堟湰銆?
娴嬭瘯姝ラ锛?
1. 杩涘叆涓栫晫鍚庣‘璁ゆ棩蹇楀嚭鐜?`loaded version=0.5.0`銆?2. 鎵撳紑浜虹墿淇℃伅锛岀‘璁ら粍鑹?F trait 鍥炬爣瀛樺湪銆?3. 涓嶉潬杩戝兊灏革紝鏅€氳璧版垨璺戝姩锛岃瀵熻€愬姏浠嶄細涓嬮檷銆?4. 瀵规瘮鏅€氳鑹诧紝纭鐩爣瑙掕壊 READY 鐘舵€佽€愬姏涓嬮檷杈冩參銆?5. 闈犺繎娲讳綋鍍靛案 4 鏍煎唴銆?6. 纭鏃ュ織鍑虹幇 `[XNP ADRENALINE] state=ACTIVE`銆?7. 纭鏃ュ織棣栨璁板綍 `trigger_zombie_distance=<n>`銆?8. 鍦?ACTIVE 鐘舵€佽窇鍔紝纭鑰愬姏涓嬮檷鏄庢樉鍙樻參锛屼絾涓嶆槸姘镐箙婊¤€愬姏銆?9. 绂诲紑鍍靛案锛岀瓑寰呯姸鎬佽繘鍏?FADING銆?10. 绛夊緟鐘舵€佸洖鍒?READY銆?11. 纭娌℃湁涓績 HUD銆佹病鏈夐《宸︽搷浣滄彁绀恒€佹病鏈夐敊璇綅缃?F 鐘舵€佸浘鏍囥€?12. 瑙傚療 calories 鎴栬惀鍏荤浉鍏冲彉鍖栵紝纭浠ｈ阿鍋胯繕鏈夎交寰垚鏈€?13. 纭鏃ュ織鍑虹幇 `[XNP METABOLIC] method=CALORIES`銆?14. 婊¤€愬姏鏃剁敤杩戞垬姝﹀櫒鏀诲嚮鍍靛案銆?15. 纭娌℃湁鏋銆佽溅杈嗐€佹姇鎺风墿瑙﹀彂杩戞垬鍔犳垚銆?16. 闄嶄綆鑰愬姏鍒?0.95 浠ヤ笅锛屽啀杩戞垬鏀诲嚮锛岀‘璁ゅ姞鎴愪笉搴旇Е鍙戙€?17. 鐢ㄦ棤鐩爣鐗硅川瑙掕壊閲嶅绉诲姩鍜屾垬鏂楋紝纭鏃犲奖鍝嶃€?18. 杩涘叆杞﹁締锛岀‘璁よ偩涓婅吅绱犵姸鎬佷笉缁х画瑙﹀彂銆?19. 姝讳骸鎴栬繑鍥炶彍鍗曞悗锛岀‘璁ゆ病鏈夋寔缁姤閿欍€?20. 鏀堕泦 `console.txt` 涓?XNP 鐩稿叧鏃ュ織锛屽洖浼犵敤浜庝笅涓€杞慨姝ｃ€?
楠屾敹閲嶇偣锛?
- 鑰愬姏搴斾笅闄嶏紝浣嗕笅闄嶉€熷害琚檷浣庛€?- 鑲句笂鑵虹礌鍙敱闄勮繎娲讳綋鍍靛案瑙﹀彂銆?- 涓嶄骇鐢熺洿鎺ョЩ鍔ㄩ€熷害鍙樺寲銆?- 涓嶄骇鐢熷璺戞帹鎾炪€?- 涓嶅啓鐜╁鍧愭爣銆?- 涓嶄慨鏀规父鎴忔椂闂淬€?
```

## B42_19_CUSTOM_SANDBOX_OPTIONS_AUDIT.md

- SHA-256: `4E4A69EDF5778D83169D4A3CF3BBE2D6184BC7007AB7A2EE0F63DB2C9BB224D4`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Custom Sandbox Options Audit

鏈満鏍搁獙璺緞锛?
- [LOCAL_PATH_REDACTED]

宸茬‘璁ょ被锛?
- zombie.sandbox.CustomSandboxOptions
- zombie.sandbox.CustomBooleanSandboxOption
- zombie.sandbox.CustomDoubleSandboxOption
- zombie.sandbox.SandboxOptions

宸茬‘璁ゆ柟娉曚笌闄愬埗锛?
- `CustomSandboxOptions.instance` 瀛樺湪銆?- `SandboxOptions.newCustomOption(CustomSandboxOption)` 瀛樺湪銆?- `SandboxOptions.getOptionByName(String)` 瀛樺湪銆?- 澶氫釜 CustomSandboxOption 鏋勯€犱笌 parse 鏂规硶鍦?Java 鍙鎬т笂涓嶉€傚悎浣滀负 Lua 绔ǔ瀹氬叆鍙ｇ洿鎺ュ亣璁俱€?
0.5.0 鍐崇瓥锛?
- SANDBOX_OPTIONS_METHOD=FALLBACK_CONFIG_LUA
- 涓婚厤缃枃浠讹細`42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- 濡傛灉杩愯鐜鎻愪緵 `SandboxVars.XNPDistanceRunner`锛岄厤缃鍙栦細浣跨敤璇ヨ〃锛涘惁鍒欎娇鐢?Lua 榛樿鍊笺€?
榛樿瀛楁锛?
- EnableReadyDrainReduction=true
- NormalStaminaDrainMultiplier=0.65
- AdrenalineStaminaDrainMultiplier=0.25
- MinEnduranceFloor=0.05
- ThreatRadius=4.0
- AdrenalineDuration=20.0
- MetabolicCostMultiplier=1.0
- EnableFullStaminaMeleeBonus=true
- FullStaminaMeleeDamageMultiplier=1.25
- EnableExperimentalStatusIcon=false

NOT_VERIFIABLE_BY_STATIC_AUDIT锛?
- 姝ｅ紡鑷畾涔夋矙鐩掗€夐」鏂囦欢鏍煎紡鍜?Lua 娉ㄥ唽鍏ュ彛浠嶉渶鍗曠嫭瀹炴満鏍搁獙銆?
```

## B42_19_MELEE_DAMAGE_EVENT_AUDIT.md

- SHA-256: `704985E9FA124E92748F4515E6E1335EC3818FAC4ABDCA406FE88375DD8C8991`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Melee Damage Event Audit

鏈満鏍搁獙璺緞锛?
- [LOCAL_PATH_REDACTED]

宸茬‘璁ょ被锛?
- zombie.characters.IsoGameCharacter
- zombie.characters.IsoZombie
- zombie.inventory.types.HandWeapon
- zombie.Lua.LuaEventManager
- zombie.CombatManager

宸茬‘璁や簨浠惰Е鍙戯細

- `OnWeaponHitCharacter`
- `OnWeaponHitXp`
- `OnWeaponSwingHitPoint`
- `OnWeaponHitTree`

`IsoGameCharacter` 鐨勫瓧鑺傜爜涓瓨鍦?`LuaEventManager.triggerEvent("OnWeaponHitCharacter", ...)` 璋冪敤銆備簨浠跺弬鏁伴潤鎬佹帹鏂负鏀诲嚮鑰呫€佺洰鏍囥€佹鍣ㄣ€佷激瀹冲€笺€?
宸茬‘璁ゆ鍣ㄦ柟娉曪細

- `HandWeapon.isRanged()`
- `HandWeapon.isAimedFirearm()`

0.5.0 鍐崇瓥锛?
- MELEE_BONUS_METHOD=ON_MELEE_HIT_DAMAGE_MULTIPLIER
- 浜嬩欢锛欵vents.OnWeaponHitCharacter
- 杩囨护鏉′欢锛?  - 鏀诲嚮鑰呭繀椤绘嫢鏈夌洰鏍囩壒璐ㄣ€?  - 鐩爣蹇呴』涓?IsoZombie銆?  - 姝﹀櫒蹇呴』瀛樺湪銆?  - 鎺掗櫎 ranged 鍜?aimed firearm銆?  - 鏀诲嚮鑰?endurance >= FULL_STAMINA_THRESHOLD銆?  - 鍙拷鍔?`damage * (multiplier - 1.0)` 鐨勯澶栦激瀹炽€?
NOT_VERIFIABLE_BY_STATIC_AUDIT锛?
- Lua 浜嬩欢鍙傛暟椤哄簭蹇呴』瀹炴満楠岃瘉銆?- `target:setHealth()` 杩藉姞浼ゅ涓庡師鐢熷嚮鏉€娴佺▼銆佺粡楠屾祦绋嬬殑浜や簰蹇呴』瀹炴満楠岃瘉銆?
```

## B42_19_METABOLIC_COST_METHOD_AUDIT.md

- SHA-256: `0ABABB51EB31F2C383210126F4BD253F9697978E6008B3BCC0CF078AE60FE35E`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Metabolic Cost Method Audit

鏈満鏍搁獙璺緞锛?
- [LOCAL_PATH_REDACTED]

宸茬‘璁ょ被锛?
- zombie.characters.BodyDamage.Nutrition
- zombie.characters.IsoPlayer

宸茬‘璁ゆ柟娉曪細

- `public zombie.characters.BodyDamage.Nutrition zombie.characters.IsoPlayer.getNutrition();`
- `public float zombie.characters.BodyDamage.Nutrition.getCalories();`
- `public void zombie.characters.BodyDamage.Nutrition.setCalories(float);`

閲囩敤鏂瑰紡锛?
- METABOLIC_COST_METHOD=CALORIES
- 姣忔鑰愬姏 refund > 0 鏃剁疮绉細`metabolicDebt += refund * METABOLIC_COST_MULTIPLIER`
- 姣?1.0 绉掑簲鐢ㄤ竴娆★紝涓嶉€愬抚鍐欏叆銆?- 搴旂敤鏂瑰紡锛氳鍙?calories锛屽啓鍥?`calories - applied`銆?
鏈噰鐢ㄦ柟寮忥細

- 涓嶄慨鏀?GameTime銆?- 涓嶄慨鏀?fatigue銆乸ain銆乮njury銆?- 涓嶇敤鍛ㄦ湡浠诲姟寮哄埗鎯╃綒銆?- 涓嶅奖鍝嶆棤鐩爣鐗硅川瑙掕壊銆?
NOT_VERIFIABLE_BY_STATIC_AUDIT锛?
- calories 鐨?UI 鍙嶉骞呭害鍜岄暱鏈熷钩琛″繀椤诲疄鏈烘祴璇曘€?- Lua 涓?Nutrition 鏂规硶鏆撮湶鎯呭喌蹇呴』瀹炴満娴嬭瘯纭銆?
```

## B42_19_STAMINA_STAT_AUDIT.md

- SHA-256: `70BF796407A553C0B988C07AF5B66DDB9A9437E00A103DEA873ED3F7D9D757B2`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Stamina Stat Audit

鏈満鏍搁獙璺緞锛?
- [LOCAL_PATH_REDACTED]

鏍搁獙鍛戒护鍩轰簬 `jar tf` 涓?`javap` 闈欐€佽鍙栵紝娌℃湁鍚姩娓告垙銆?
宸茬‘璁ょ被锛?
- zombie.characters.Stats
- zombie.characters.CharacterStat
- zombie.characters.IsoPlayer

宸茬‘璁ゆ柟娉曪細

- `public float zombie.characters.Stats.get(zombie.characters.CharacterStat);`
- `public boolean zombie.characters.Stats.set(zombie.characters.CharacterStat, float);`
- `public boolean zombie.characters.Stats.add(zombie.characters.CharacterStat, float);`
- `public static final zombie.characters.CharacterStat ENDURANCE;`
- `public zombie.characters.Stats zombie.characters.IsoPlayer.getStats();`

閲囩敤鏂瑰紡锛?
- STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND
- 璇诲彇锛歚player:getStats():get(CharacterStat.ENDURANCE)`
- 鍐欏叆锛歚player:getStats():set(CharacterStat.ENDURANCE, newEndurance)`

鍏紡锛?
- rawDrain = previousEndurance - currentEndurance
- allowedDrain = rawDrain * staminaDrainMultiplier
- refund = rawDrain - allowedDrain
- newEndurance = currentEndurance + refund

瀹夊叏闄愬埗锛?
- rawDrain <= 0 鏃朵笉鍐欏叆銆?- currentEndurance <= MIN_ENDURANCE_FLOOR 鏃朵笉鍐欏叆銆?- newEndurance 涓嶈秴杩?1.00銆?- newEndurance 涓嶄綆浜?currentEndurance銆?- 涓嶄娇鐢?unlimited endurance銆?- 涓嶆案涔呴攣婊¤€愬姏銆?
NOT_VERIFIABLE_BY_STATIC_AUDIT锛?
- 瀹炴満涓?CharacterStat.ENDURANCE 鍦?Lua 鐜涓殑鍛藉悕鏄惁瀹屽叏鏆撮湶銆?- 姣?0.10 绉掗噰鏍锋椂涓庢父鎴忓師鐢熻€愬姏鏇存柊椤哄簭鐨勭簿纭氦浜掋€?
```

## B42_19_TRUE_STATUS_MOODLE_REGISTRATION_AUDIT.md

- SHA-256: `E38459FDCA133F0C155E93D048F362C4C2274182FDF613B23256CB51B0922A3E`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 True Status Moodle Registration Audit

鏈満鏍搁獙璺緞锛?
- [LOCAL_PATH_REDACTED]

宸茬‘璁ょ被锛?
- zombie.scripting.objects.MoodleType
- zombie.characters.Moodles.MoodleStat
- zombie.characters.Moodles.Moodles
- zombie.ui.MoodlesUI
- zombie.ui.MoodleTextureSet

宸茬‘璁ゆ柟娉曪細

- `public static zombie.scripting.objects.MoodleType zombie.scripting.objects.MoodleType.register(java.lang.String);`
- `public static zombie.characters.Moodles.MoodleStat zombie.characters.Moodles.MoodleStat.register(MoodleType, float, float, float, float, float);`
- `public int zombie.characters.Moodles.Moodles.getMoodleLevel(MoodleType);`
- `public void zombie.ui.MoodlesUI.render();`
- `public static zombie.ui.MoodlesUI zombie.ui.MoodlesUI.getInstance();`

缁撹锛?
- Java 渚у瓨鍦?MoodleType 鍜?MoodleStat 娉ㄥ唽鏂规硶銆?- 浠呴潬闈欐€佽鍙栦笉鑳界‘璁?Lua mod 鐜鑳藉畨鍏ㄥ畬鎴愬畬鏁存敞鍐屻€佽创鍥剧粦瀹氥€佹枃瀛楃粦瀹氥€佺瓑绾ф洿鏂板拰鍙充晶 Moodle UI 娓叉煋銆?- 0.4 鍒嗘敮鐨勮嚜缁?F 鍥炬爣鍧愭爣閿欒锛屼笉鑳戒綔涓烘寮忓疄鐜般€?
0.5.0 鍐崇瓥锛?
- STATUS_MOODLE_METHOD=NOT_CONFIRMED
- STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT
- ENABLE_EXPERIMENTAL_STATUS_ICON=false

瀹炵幇瑕佹眰锛?
- 榛樿涓嶇粯鍒堕敊璇潗鏍囧浘鏍囥€?- 榛樿浠呬繚鐣欎汉鐗╁垱寤?瑙掕壊淇℃伅涓殑榛勮壊 F trait 鍥炬爣銆?
NOT_VERIFIABLE_BY_STATIC_AUDIT锛?
- Lua 涓湡 Moodle 娉ㄥ唽閾炬槸鍚﹀畬鏁存毚闇层€?- 鑷畾涔?Moodle 璐村浘璧勬簮鎸傛帴璺緞銆?
```
