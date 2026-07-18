# 0.4.19 Sanitized Evidence Excerpts

## ADRENALINE_STAMINA_CORE_TEST_0.4.19.md

- SHA-256: `7C71024FBB5D8F19B1C9DC54FE1680494563176B97E514BC04F5137D5C4E4801`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# ADRENALINE_STAMINA_CORE_TEST_0.4.19

1. 鍙惎鐢?0.4.19銆?2. 绂佺敤鎵€鏈夋棫鐗堟湰銆?3. 瀹屽叏閲嶅惎娓告垙銆?4. 杩涘叆宸叉湁闀块€斿琚€呰鑹层€?5. 鍓?8 绉掕瀵熷彸涓婅鏄惁鍑虹幇甯﹂珮瀵规瘮杈规鐨?F 鎺㈤拡銆?6. 濡傛灉鐪嬩笉鍒帮紝璁板綍鎴浘鍜?console銆?7. 杩滅鍍靛案锛屽湪 READY 鐘舵€佷笅鎸佺画璺戞锛岀‘璁よ€愬姏鍙互姝ｅ父娑堣€椼€?8. 鎶婅€愬姏娑堣€楀埌杈冧綆銆?9. 寮曚竴鍙椿鍍靛案杩涘叆绾?4 鏍煎唴銆?10. 纭杩涘叆 ACTIVE銆?11. 纭鑰愬姏鎭㈠鍒版帴杩戞弧鍊笺€?12. 绂诲紑鍍靛案锛岀‘璁よ繘鍏?FADING銆?13. 20 绉掑唴娌℃湁鏂板兊灏告帴杩戝悗鍥炲埌 READY銆?14. 鍥炲埌 READY 鍚庡啀娆¤窇姝ワ紝纭鑰愬姏鍙堜細鑷劧娑堣€椼€?15. 妫€鏌ユ病鏈夌Щ鍔ㄩ€熷害鍔犳垚銆佹挒鎺ㄣ€佷腑澶枃瀛楀拰 Lua 閿欒銆?
Expected marker:

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.19_SOURCE_READY_FOR_ADRENALINE_STAMINA_CORE_TEST`

```

## BUILD_MARKER.txt

- SHA-256: `24ECD59830095C2696CBAA0650D6FD6E0F3D2C02CCAEDDEF5DFB9276F82B0604`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0419_ADRENALINE_STAMINA_A

```

## CHANGELOG.md

- SHA-256: `E528C07CD1E3789F61A9A08A3F7DBF10463DC9C511D5C52D9AAEBAC4328B9B7F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

## 0.4.19-b42-adrenaline-stamina-core-a

- Created independent 0.4.19 source.
- Fixed gameplay direction to adrenaline stamina support.
- Set `MOVEMENT_SPEED_MODIFICATION_METHOD=NONE`.
- Tightened live-zombie trigger rules and scan interval to 0.50 seconds.
- Added `ACTIVE_REFRESH=8.00` and `MEMORY_DURATION=20.00`.
- Ensured READY state does not write `CharacterStat.ENDURANCE`.
- Kept ACTIVE/FADING endurance writes only.
- Added recovery cost log only: no hunger, calories, fatigue, pain, temperature, stress, or time changes.
- Added 8 second status icon visibility probe.
- Added 0.4.18 result summary and 0.4.19 test instructions.

## 0.4.18-b42-moodle-behavior-adrenaline-a

- Created independent 0.4.18 source.
- Replaced full-screen status icon panel with a minimal icon-sized UI element.
- Added measured black tooltip with border and screen clamp.
- Added READY / ACTIVE / FADING F icon states.
- Added live-zombie proximity adrenaline trigger: 4 tiles, 0.25 second scan interval, 20 second memory.
- Changed endurance from passive infinite mode to adrenaline-only CharacterStat.ENDURANCE support.
- Kept RunningShove, zombie state writes, coordinate writes, time writes, and old speed methods disabled.
- Added 0.4.17 result audit, right-click input audit, vanilla Moodle behavior audit, 0.4.18 test plan, static audit, and final report.

## 0.4.17-b42-native-moodle-layout-fix-a

- Accepted 0.4.16 icon result: texture, round style, and tooltip passed, but layout overlapped vanilla Moodles.
- Added local Build 42.19 Moodle layout audit from `projectzomboid.jar`.
- Replaced estimated F position with `VANILLA_LAYOUT_COMPANION_SLOT`.
- Added visible vanilla Moodle counting with `player:getMoodles():getMoodleLevel(MoodleType.<name>)`.
- Added rectangle overlap guard before drawing the F icon.
- Preserved passive unlimited endurance.
- Disabled running shove after the unsafe 0.4.16 runtime failure.
- Disabled movement enhancement work for this layout-only version.

```

## FINAL_REPORT.md

- SHA-256: `1E63A65DAE702E31139EE78F1AEBC7C5E18FEC0561E531517D6E95E9569BD80A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL_REPORT 0.4.19

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
VERSION=0.4.19
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0419_ADRENALINE_STAMINA_A

## Trait

- TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION
- TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner
- Mod ID unchanged: YES
- Character creation cost unchanged: YES
- CN trait text preserved and updated for stamina direction: YES
- Character panel yellow F preserved: YES

## Adrenaline

- ADRENALINE_TRIGGER_METHOD=LIMITED_NEARBY_GRID_SQUARE_SCAN_LIVE_ZOMBIE_DISTANCE
- THREAT_TRIGGER_RADIUS=4.00
- THREAT_SCAN_INTERVAL=0.50
- ADRENALINE_ACTIVE_REFRESH=8.00
- ADRENALINE_MEMORY_DURATION=20.00
- ADRENALINE_STATES=READY,ACTIVE,FADING

## Endurance

- ENDURANCE_SUPPORT_METHOD=CharacterStat.ENDURANCE_ACTIVE_OR_FADING_ONLY
- READY_ENDURANCE_WRITE=NO
- ACTIVE_ENDURANCE_WRITE=YES
- FADING_ENDURANCE_WRITE=YES
- ENDURANCE_TARGET_ACTIVE=1.00
- READY_NATURAL_ENDURANCE_DRAIN=YES

## Recovery

- RECOVERY_COST_METHOD=LOG_ONLY
- Hunger modified: NO
- Calories modified: NO
- Fatigue modified: NO
- Pain modified: NO
- Temperature modified: NO
- Stress modified: NO

## Status Icon

- STATUS_ICON_VISIBILITY_PROBE=YES
- PROBE_DURATION=8
- STATUS_ICON_DRAW_METHOD=MINIMAL_ICON_UI_ELEMENT_WITH_8_SECOND_VISIBILITY_PROBE
- Probe color: high-contrast white/yellow border
- Probe alpha: 1.0
- Probe auto-off: YES

## Disabled Runtime Features

- MOVEMENT_SPEED_MODIFICATION_METHOD=NONE
- RUNNING_SHOVE_STATUS=DISABLED
- Coordinates modified: NO
- Game time modified: NO
- No-trait character affected: NO
- Per-frame logs present: NO

## Counts

- Lua file count: 24
- Lua total lines: 1922

## Static Check

- STATIC_RESULT=PASS_WITH_REAL_GAME_TEST_REQUIRED
- Old movement speed methods: ABSENT
- RunningShove active update: ABSENT
- BumpedState: ABSENT
- Coordinate writes: ABSENT
- Game time modification: ABSENT

## NOT_VERIFIABLE

- Lua execution syntax check.
- User-visible F probe.
- READY natural stamina drain.
- ACTIVE/FADING stamina support timing.
- Full real game behavior.

## Write Safety

- Project Zomboid launched: NO
- Steam launched: NO
- User mods written: NO
- Saves written: NO
- Workshop written: NO
- Game install written: NO
- Old SOURCE modified: NO

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.19_SOURCE_READY_FOR_ADRENALINE_STAMINA_CORE_TEST

```

## README_CN.md

- SHA-256: `470EBA009F5AC67C6F00B0E9CCCEDB906D6E789456995EDBC6E6B810F13850A4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.19 Adrenaline Stamina Core

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

鏈増鏂瑰悜鍥哄畾涓衡€滃簲婵€浣撳姏鏈哄埗鈥濓細闀块€斿琚€呬笉鏄钩鏃舵洿蹇紝鑰屾槸鍦ㄨ繎璺濈娲讳綋鍍靛案濞佽儊涓嬬煭鏃朵繚鎸佹渶楂樺璺戜綋鍔涖€?
0.4.19 涓嶅仛绉诲姩閫熷害鍔犳垚锛屼笉鎭㈠鎾炴帹锛屼笉鐮旂┒瀹屾暣鍘熺増 Moodle 娉ㄥ唽銆?
鏍稿績瑙勫垯锛?
- READY锛氫笉鍐欒€愬姏锛屽厑璁稿師鐗堣嚜鐒舵秷鑰楀拰鎭㈠銆?- ACTIVE锛氭椿浣撳兊灏歌繘鍏?4 鏍煎唴锛屾仮澶嶅苟缁存寔鑰愬姏鍒?1.00銆?- FADING锛氬兊灏哥寮€鍚?20 绉掕蹇嗘湡鍐呯户缁淮鎸佽€愬姏銆?- RECOVERY锛氭湰杞彧璁板綍鏈潵浠ｄ环锛屼笉淇敼楗ラタ銆佸崱璺噷銆佺柌鍔炽€佺柤鐥涖€佹俯搴︺€佸帇鍔涙垨娓告垙鏃堕棿銆?- 鍓?8 绉掑惎鐢?F 鍙鎬ф帰閽堬紝楂樺姣旇竟妗嗚嚜鍔ㄥ叧闂€?
---

# 0.4.18 inherited notes below

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨勭嫭绔?0.4.18 娴嬭瘯 SOURCE銆?
鏈増淇濈暀鍘熺敓 CharacterTrait 娉ㄥ唽銆佽鑹插垱寤烘垚鏈?Cost=1銆佷腑鏂囩炕璇戙€侀粍鑹?F 瑙掕壊闈㈡澘鍥炬爣銆佺洰鏍囩壒璐ㄦ娴嬨€佷互鍙?0.4.17 宸查€氳繃瀹炴満鐨勫師鐗?Moodle 妲戒綅璺熼殢甯冨眬銆?
0.4.18 鍙獙璇侊細

- F 鐘舵€佸浘鏍囨敼涓烘渶灏忓浘鏍?UI 鍖哄煙锛屼笉鍐嶄娇鐢ㄥ叏灞忛€忔槑榧犳爣闈㈡澘銆?- tooltip 鏀逛负娴嬮噺鏂囨湰瀹介珮鍚庣粯鍒堕粦搴曘€佽竟妗嗭紝骞舵寜灞忓箷杈圭晫澶瑰彇銆?- F 鏈?READY / ACTIVE / FADING 涓夋€併€?- 4 鏍煎唴娲讳綋鍍靛案瑙﹀彂 ADRENALINE锛岀寮€鍚庝繚鐣?20 绉掕蹇嗐€?- 鑰愬姏鍐欏叆鍙湪 ACTIVE/FADING 鏃舵墽琛岋紝鐢ㄤ簬绉婚櫎浣庤€愬姏鎱㈣窇鎯╃綒銆?- 涓嶅惎鐢?RunningShove锛屼笉淇敼鍍靛案鐘舵€侊紝涓嶄慨鏀硅鑹插潗鏍囷紝涓嶄慨鏀规椂闂达紝涓嶈皟鐢ㄦ棫閫熷害鏂规硶銆?
鏈疆浠嶉渶鐢ㄦ埛瀹炴満纭 tooltip銆佸彸閿緭鍏ャ€丗 鍔ㄧ敾銆佸兊灏歌Е鍙戙€?0 绉掕蹇嗗拰鑰愬姏鏀彺銆?
---

# 0.4.17 inherited notes below

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨勭嫭绔?0.4.17 娴嬭瘯 SOURCE銆?
鏈増鍙鐞嗭細

- 淇鍙充笂瑙掑渾褰?F 涓庡師鐗堢姸鎬佸浘鏍囬噸鍙犮€?- 淇濈暀宸叉垚鍔熺殑 `CharacterStat.ENDURANCE` 鏃犻檺鑰愬姏銆?- 鍋滅敤 0.4.16 涓嶅畨鍏ㄧ殑璺戝姩鎾炴帹銆?- 鍋滅敤绉诲姩閫熷害淇敼涓庣Щ鍔ㄩ噰鏍枫€?
鏈増淇濇寔锛?
- Mod ID=`XNP_PZ_DistanceRunnerTrait`
- Trait full ID=`XNPDistanceRunnerTrait:XNPDistanceRunner`
- B42 鍘熺敓 `character_trait_definition`
- 浜虹墿鍒涘缓鎴愭湰 Cost=1
- 榛勮壊 F 鍥炬爣璧勬簮
- 鏈湴鐜╁鍘熺敓鐗硅川妫€娴嬪拰缂撳瓨

STATUS_ICON_LAYOUT_METHOD=VANILLA_LAYOUT_COMPANION_SLOT
ENDURANCE_METHOD=`player:getStats():set(CharacterStat.ENDURANCE, 1.0)`
RUNNING_SHOVE_STATUS=DISABLED_AFTER_0_4_16_RUNTIME_FAILURE
MOVEMENT_ENHANCEMENT_STATUS=DISABLED_FOR_LAYOUT_FIX

```

## STATIC_AUDIT.md

- SHA-256: `9C860FB4C52C9AA062EB71878C8D15DE255CF52FCB7183AEEE8FDA0396E49C79`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC_AUDIT 0.4.19

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Identity

- VERSION=0.4.19
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0419_ADRENALINE_STAMINA_A
- Trait full ID unchanged: YES
- Character panel F unchanged: YES
- TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION

## Adrenaline Stamina Rules

- READY_ENDURANCE_WRITE=NO
- ACTIVE_ENDURANCE_WRITE=YES
- FADING_ENDURANCE_WRITE=YES
- READY_NATURAL_ENDURANCE_DRAIN=YES
- THREAT_TRIGGER_RADIUS=4.00
- THREAT_SCAN_INTERVAL=0.50
- ADRENALINE_MEMORY_DURATION=20.00
- ADRENALINE_ACTIVE_REFRESH=8.00
- RECOVERY_COST_METHOD=LOG_ONLY

## Status Icon Probe

- STATUS_ICON_VISIBILITY_PROBE=YES
- PROBE_DURATION=8
- PROBE_AUTO_OFF_AFTER_8_SECONDS=YES
- STATUS_ICON_DRAW_METHOD=MINIMAL_ICON_UI_ELEMENT_WITH_8_SECOND_VISIBILITY_PROBE

## Forbidden Runtime Features

Active Lua grep found no calls to:

- `RunningShove.Update`
- `BumpedState`
- `setFastMoveCheat`
- `setSpeedMod`
- `setMoveSpeed`
- `setPathSpeed`
- `setCombatSpeed`
- `setVariable("WalkSpeed")`
- `player:setX`
- `player:setY`
- `zombie:setX`
- `zombie:setY`
- `GameTime:setMultiplier`

## Logging

- Per-frame endurance logs: ABSENT
- Per-frame zombie distance logs: ABSENT
- Per-frame icon coordinate logs: ABSENT
- State-change logs: PRESENT
- Probe start/end logs: PRESENT

## NOT_VERIFIABLE

- Lua execution syntax check: NOT_VERIFIABLE because no reliable Lua interpreter was used.
- User-visible F probe: REAL_GAME_TEST_REQUIRED_BY_USER
- READY natural endurance drain: REAL_GAME_TEST_REQUIRED_BY_USER
- ACTIVE/FADING stamina support timing: REAL_GAME_TEST_REQUIRED_BY_USER

STATIC_RESULT=PASS_WITH_REAL_GAME_TEST_REQUIRED

```
