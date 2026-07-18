# 0.4.18 Sanitized Evidence Excerpts

## 0.4.18_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `6AEFC62E2AC814605336C38484E3CCF8DFF1391C7DD8C92FE677C1C38C4E69F4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.18 Real Game Result Summary

## Accepted Runtime Evidence

- Trait load succeeded:
  - `TraitZ xnpdistancerunnertrait:xnpdistancerunner`
  - `[XNP TRAIT] player has target trait=true`

- Status icon code path ran:
  - `[XNP STATUS ICON] texture resolved=true`
  - `[XNP STATUS ICON] created=true`
  - `[XNP STATUS ICON] visible=true reason=trait_active`
  - `[XNP STATUS ICON] first draw=true`

- Status icon dynamic slot calculation worked:
  - `vanilla_visible_count=0 selected_slot=0 y=120 overlap=false`
  - `vanilla_visible_count=1 selected_slot=1 y=162 overlap=false`
  - `vanilla_visible_count=2 selected_slot=2 y=204 overlap=false`
  - `vanilla_visible_count=3 selected_slot=3 y=246 overlap=false`
  - `vanilla_visible_count=4 selected_slot=4 y=288 overlap=false`

## User-visible Result

- STATUS_ICON_LOGICAL_STATE=PASS
- STATUS_ICON_VISIBLE_TO_USER=FAIL
- STATUS_ICON_PROBLEM=VISIBILITY_OR_DRAW_LAYER_OR_ALPHA

## Adrenaline Result

- `[XNP ADRENALINE] state=READY`
- `[XNP ADRENALINE] state=ACTIVE`
- `[XNP ADRENALINE] state=FADING`
- `[XNP ADRENALINE] state=READY`

## Endurance Result

- `[XNP ADRENALINE] endurance_before=0.989211`
- `[XNP ADRENALINE] endurance_after=1.000000`
- `[XNP ADRENALINE] endurance_support_confirmed=true`

## 0.4.19 Decision

- ENDURANCE_SUPPORT_METHOD=CharacterStat.ENDURANCE
- ENDURANCE_WRITE_REAL_GAME_RESULT=PASS
- CURRENT_ENDURANCE_EFFECT_TOO_BROAD=YES
- 0.4.19 direction: adrenaline stamina support only.
- MOVEMENT_SPEED_MODIFICATION_METHOD=NONE


```

## BUILD_MARKER.txt

- SHA-256: `7FEB1E4EE6ED0A0472B4696A04B3DF0DC232722479D37A59176844A4A9CFF547`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0418_MOODLE_ADRENALINE_A

```

## CHANGELOG.md

- SHA-256: `781A3E82A3B2D00B6BE5578752B8B34DED74C290FFDFE2793E4A6EEA77D5FF82`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

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

- SHA-256: `C029A5DA458804EC6FF40FEC4F1C171C5ADDE68CFFCEB315C437DD4F4A9DD125`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.4.18

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
VERSION=0.4.18
INTERNAL_VERSION=0.4.18-b42-moodle-behavior-adrenaline-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0418_MOODLE_ADRENALINE_A

## 0.4.17 Accepted Results

- TRAIT_REGISTRATION=PASS
- CHARACTER_PANEL_F=PASS
- ENDURANCE_WRITE=PASS
- STATUS_ICON_DRAW=PASS
- STATUS_ICON_DYNAMIC_SLOT=PASS
- STATUS_ICON_OVERLAP_RESULT=PASS
- PLAYER_DEATH_HIDE=PASS

## Moodle Classification

- STATUS_ICON_REAL_CLASSIFICATION=VANILLA_STYLE_COMPANION_ICON
- CUSTOM_MOODLE_REGISTRATION_RESULT=NO_CONFIRMED_LUA_REGISTRATION_PATH
- STATUS_ICON_RENDER_METHOD=MINIMAL_ICON_UI_ELEMENT
- STATUS_ICON_ANIMATION_METHOD=VANILLA_PANIC_STYLE_OSCILLATION_MIMIC
- STATUS_ICON_TOOLTIP_METHOD=MEASURED_BLACK_TOOLTIP_WITH_SCREEN_CLAMP
- VANILLA_PANIC_ANIMATION_EVIDENCE=`MoodlesUI.wiggle(MoodleType)` sets `oscillationLevel = 1`; `MoodlesUI.update()` decays the oscillation.

## Input Safety

- FULL_SCREEN_MOUSE_ELEMENT_REMOVED=YES
- MOUSE_EVENTS_CONSUMED=NO
- XNP_RIGHT_CLICK_HANDLER_PRESENT=NO
- XNP_CONTEXT_MENU_EVENT_REGISTERED=NO
- ISOpenCloseWindow_ERROR_LINKED_TO_XNP=NOT_PROVEN

## Tooltip

- TOOLTIP_TEXT_MEASUREMENT=MeasureStringX when available, safe width fallback otherwise
- TOOLTIP_BACKGROUND_SIZE_METHOD=longest line width plus padding, line count times font height plus padding
- TOOLTIP_SCREEN_CLAMP=YES
- TOOLTIP_TEXT_CLIPPING_FIXED=STATIC_IMPLEMENTED_REAL_GAME_TEST_REQUIRED

## Adrenaline

- THREAT_TRIGGER_METHOD=LIMITED_NEARBY_GRID_SQUARE_SCAN
- THREAT_TRIGGER_RADIUS=4.00
- THREAT_SCAN_INTERVAL=0.25
- ADRENALINE_MEMORY_DURATION=20.00
- ADRENALINE_STATES=READY,ACTIVE,FADING
- RETRIGGER_EXTENDS_DURATION=YES

## Endurance And Movement Safety

- PASSIVE_INFINITE_ENDURANCE=NO
- ADRENALINE_ENDURANCE_SUPPORT=YES
- ENDURANCE_SUPPORT_METHOD=CharacterStat.ENDURANCE write only during ACTIVE/FADING
- ENDURANCE_TARGET_ACTIVE=1.00
- RUN_SPEED_SUPPORT_METHOD=ENDURANCE_RESTORATION_TO_REMOVE_LOW_ENDURANCE_SLOWDOWN
- RUNNING_SHOVE_STATUS=DISABLED_AFTER_0_4_16_RUNTIME_FAILURE
- MOVEMENT_MULTIPLIER_STATUS=DISABLED
- WORLD_COORDINATE_WRITE=NO
- GAME_TIME_WRITE=NO
- NO_TRAIT_CHARACTER_AFFECTED=NO
- OTHER_PLAYERS_AFFECTED=NO
- PERMANENT_SKILLS_CHANGED=NO
- PER_FRAME_LOGS=NO

## Counts

- Lua file count: 24
- Lua total lines: 1823
- Document file count: 95

## Static Result

- STATIC_RESULT=PASS_WITH_REAL_GAME_TEST_REQUIRED
- Lua 5.1 execution syntax check: NOT_VERIFIABLE because no reliable local Lua 5.1 interpreter was found.
- In-game tooltip clipping: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Native-style animation feel: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Right-click pass-through in live UI stack: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Adrenaline trigger/runtime endurance support: REAL_GAME_TEST_REQUIRED_BY_USER.

## Write Safety

- GAME_LAUNCHED=NO
- STEAM_LAUNCHED=NO
- USER_MODS_WRITTEN=NO
- SAVE_WRITTEN=NO
- WORKSHOP_WRITTEN=NO
- GAME_DIRECTORY_WRITTEN=NO
- OLD_SOURCE_MODIFIED=NO

## Reports Added

- `0.
[EXCERPT_TRUNCATED]
```

## MOODLE_BEHAVIOR_ADRENALINE_TEST_0.4.18.md

- SHA-256: `4CBCE58E398AF0155F361806F5A2414F3B600A5B540D71FFC4DFE8D585608327`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Moodle Behavior + Adrenaline Test 0.4.18

1. 鍙惎鐢?`XNP Distance Runner Trait 0.4.18 Moodle Behavior + Adrenaline`锛岀鐢ㄦ棫鐗堟湰锛岄噸鍚父鎴忋€?2. 杞藉叆甯?`闀块€斿琚€卄 鐗硅川鐨勮鑹层€?3. 瑙傚療 READY 鐘舵€侊細F 绋冲畾鏄剧ず锛屼笉鎶栧姩銆?4. 榧犳爣鎮仠 F锛氶粦鑹?tooltip 鍐呭簲瀹屾暣鏄剧ず鍏ㄩ儴鏂囨湰锛屼笉婧㈠嚭榛戞銆?5. 鍦?F 闄勮繎銆佷笘鐣屽湴闈€侀棬銆佺獥銆佸鍣ㄣ€佸兊灏镐笂鍙抽敭锛欶 涓嶅簲闃绘尅鍙抽敭鑿滃崟鎴栧師鐗堜氦浜掋€?6. 鍏堣窇鍔ㄦ秷鑰椾竴浜涜€愬姏銆?7. 璁╂椿浣撳兊灏歌繘鍏?4 鏍煎唴锛欶 杩涘叆 ACTIVE锛屽嚭鐜版姈鍔?鑴夊啿锛岃€愬姏鎭㈠鍒版弧鍊笺€?8. 缁х画璺戝姩锛氫笉搴旇繘鍏ヤ綆鑰愬姏鎱㈣窇銆?9. 绂诲紑鍍靛案锛氭晥鏋滀笉搴旂珛鍒荤粨鏉燂紱绾?20 绉掑唴涓?FADING锛屼箣鍚庡洖 READY銆?10. 20 绉掑唴鍐嶆鎺ヨ繎鍍靛案锛氳鏃跺簲寤堕暱銆?11. 鍚屾椂鍒堕€?panic/pain 绛夊師鐗?Moodle锛欶 浠嶈窡闅忓姩鎬佹Ы浣嶏紝涓嶉噸鍙犮€?12. 瑙掕壊姝讳骸锛欶 鍜?tooltip 闅愯棌锛岃€愬姏鍐欏叆鍋滄銆?13. 鎺у埗鍙颁笉搴斿嚭鐜伴€愬抚鍒峰睆鎴?Lua error銆?
Expected marker:

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.18_SOURCE_READY_FOR_NATIVE_STYLE_MOODLE_AND_ADRENALINE_TEST`

```

## README_CN.md

- SHA-256: `A8DC53EF89A3968807512697224D5EF3E0881712FF9B8C21FD8E8D95B9D3FEAE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.18 Moodle Behavior + Adrenaline

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

## B42_19_VANILLA_MOODLE_BEHAVIOR_AUDIT.md

- SHA-256: `F45731258EEA211949E21F8B7008A10504D8F62A68F52716D52E8869F814FE4E`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Vanilla Moodle Behavior Audit

## Source Basis

This report uses the accepted 0.4.17 local class inspection of:

- `zombie.ui.MoodlesUI`
- `zombie.ui.MoodlesUI$MoodleUIData`
- `zombie.ui.MoodleTextureSet`
- `zombie.characters.Moodles.Moodles`
- `zombie.characters.Moodles.Moodle`
- `zombie.characters.Moodles.Moodle$MoodleLevel`
- `zombie.scripting.objects.MoodleType`

The game was not launched and no game file was modified.

## Required Answers

1. Vanilla status icons have real animation: YES. `MoodlesUI$MoodleUIData` has `oscillationLevel`, `slotsPulse1`, and `slotsPulse2`.
2. Panic wiggle trigger: vanilla `MoodlesUI.wiggle(MoodleType)` sets `oscillationLevel = 1`.
3. Offset/update frequency: `MoodlesUI.update()` moves visible slots toward `slotsDesiredPos` and decays `oscillationLevel` with a frame-rate adjusted factor.
4. Level change scale/blink/alpha: local evidence confirms oscillation/pulse fields; exact per-level art behavior remains NOT_VERIFIABLE_BY_STATIC_AUDIT without running the game.
5. Tooltip class/draw functions: `MoodlesUI.render()` draws title/description text when `mouseOverSlot` targets a visible slot.
6. Black bg width/height: vanilla measures title and description width and draws a black scaled rectangle using longest line width plus padding.
7. Text line wrapping: vanilla uses title/description lines rather than automatic long-line wrapping.
8. Tooltip screen clamp: vanilla tooltip appears left of the right-side Moodle stack; 0.4.18 adds explicit screen clamp for the companion icon tooltip.
9. Moodle intercepts left/right mouse: local evidence only showed hover/mouse-over state. No XNP context-menu registration is used.
10. Hides tooltip on mouse out: vanilla `onMouseMoveOutside` clears mouse-over state; 0.4.18 hides tooltip when local mouse is outside the icon.
11. Can current F truly register as vanilla Moodle: NOT_PROVEN. No complete safe Lua path was confirmed for custom Moodle registration with texture, level, tooltip, and lifecycle.
12. If not registered, mimic accurately: count visible vanilla Moodles, draw F in the next non-overlapping slot, use vanilla round background/outline textures, use measured black tooltip, and mimic panic-style oscillation locally.

## 0.4.18 Classification

- CUSTOM_MOODLE_REGISTRATION_RESULT=NO_CONFIRMED_LUA_REGISTRATION_PATH
- STATUS_ICON_REAL_CLASSIFICATION=VANILLA_STYLE_COMPANION_ICON
- STATUS_ICON_ANIMATION_METHOD=VANILLA_PANIC_STYLE_OSCILLATION_MIMIC
- VANILLA_PANIC_ANIMATION_EVIDENCE=`MoodlesUI.wiggle(MoodleType)` sets `oscillationLevel = 1`; `MoodlesUI.update()` decays the oscillation.


```

## STATIC_AUDIT.md

- SHA-256: `2872C3A37BD3A6C1185A62A8B415A38845FF0AE295A6F0B89B85EA797A187508`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.4.18

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Scope

Checked active Lua and new reports for the 0.4.18 Moodle behavior + adrenaline source. The game was not launched.

## Lua File Count

- Lua files: 24
- Lua total lines: 1823

## Checks

- VERSION=0.4.18
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0418_MOODLE_ADRENALINE_A
- Mod ID unchanged: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID unchanged: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- B42 native trait definition preserved: YES
- Character creation cost preserved: 1
- CN/EN translations present: YES
- Yellow F icon resource preserved: YES
- Player native trait detection/cache preserved: YES
- 0.4.17 dynamic visible Moodle count preserved: YES
- 0.4.17 dynamic slot selection preserved: YES
- 0.4.17 rectangle overlap guard preserved: YES
- Hide on player death preserved: YES

## Input Safety

- FULL_SCREEN_MOUSE_ELEMENT_REMOVED=YES
- STATUS_ICON_RENDER_METHOD=MINIMAL_ICON_UI_ELEMENT
- MOUSE_EVENTS_CONSUMED=NO
- XNP_RIGHT_CLICK_HANDLER_PRESENT=NO
- XNP_CONTEXT_MENU_EVENT_REGISTERED=NO
- `OnFillWorldObjectContextMenu` found: NO
- `OnPreFillWorldObjectContextMenu` found: NO
- `ISContextMenu` usage found: NO

## Disabled Methods

Static grep found no active Lua calls to:

- `setFastMoveCheat`
- `setSpeedMod`
- `setMoveSpeed`
- `setPathSpeed`
- `setCombatSpeed`
- `getMoveSpeed`
- `setGameSpeed`
- player/world `setX`, `setY`, `setZ`
- zombie shove state write methods
- XP award methods

## Adrenaline

- THREAT_TRIGGER_METHOD=LIMITED_NEARBY_GRID_SQUARE_SCAN
- THREAT_TRIGGER_RADIUS=4.00
- THREAT_SCAN_INTERVAL=0.25
- ADRENALINE_MEMORY_DURATION=20.00
- ADRENALINE_STATES=READY,ACTIVE,FADING
- RETRIGGER_EXTENDS_DURATION=YES
- PASSIVE_INFINITE_ENDURANCE=NO
- ADRENALINE_ENDURANCE_SUPPORT=YES
- ENDURANCE_SUPPORT_METHOD=CharacterStat.ENDURANCE write only during ACTIVE/FADING
- ENDURANCE_TARGET_ACTIVE=1.00
- RUN_SPEED_SUPPORT_METHOD=ENDURANCE_RESTORATION_TO_REMOVE_LOW_ENDURANCE_SLOWDOWN

## Logs

- State change logs only for adrenaline state transitions.
- First endurance confirmation logs only once.
- Texture, first draw, tooltip method, and layout logs are not per-frame logs.
- No zombie distance, alpha, mouse, or endurance per-frame spam was added.

## NOT_VERIFIABLE

- Lua 5.1 execution syntax check: NOT_VERIFIABLE because no reliable local Lua 5.1 interpreter was found.
- In-game tooltip clipping: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Native-style animation feel: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Right-click pass-through in live UI stack: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Adrenaline trigger/runtime endurance support: REAL_GAME_TEST_REQUIRED_BY_USER.

## Result

STATIC_RESULT=PASS_WITH_REAL_GAME_TEST_REQUIRED
BLOCKER=NONE

```
