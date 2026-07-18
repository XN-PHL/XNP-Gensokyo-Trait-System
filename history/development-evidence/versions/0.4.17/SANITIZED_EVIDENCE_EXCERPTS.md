# 0.4.17 Sanitized Evidence Excerpts

## 0.4.17_REAL_GAME_UI_AND_INPUT_RESULT.md

- SHA-256: `8D2A177E4E8A1343B8D12BF6D1852DD3126DD53F555502DB1ED22A56E8F8EAE3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.17 Real Game UI And Input Result

## Accepted Real Game Result

- TRAIT_REGISTRATION=PASS
- CHARACTER_PANEL_F=PASS
- ENDURANCE_WRITE=PASS
- STATUS_ICON_DRAW=PASS
- STATUS_ICON_DYNAMIC_SLOT=PASS
- STATUS_ICON_OVERLAP_RESULT=PASS
- PLAYER_DEATH_HIDE=PASS

## Console Evidence

Latest local console showed:

- `vanilla_visible_count=0` through `vanilla_visible_count=6`
- `selected_slot` followed the visible vanilla count.
- `overlap=false`
- `visible=false reason=player_death`
- `ISTimedActionQueue:tick: bugged action, cleared queue ISOpenCloseWindow`

## Interpretation

The 0.4.17 F icon was correctly drawn as a companion icon beside the vanilla Moodle column. It was not proven to be a truly registered vanilla Moodle with native Moodle behavior.

The right-click/window action issue is not proven to be caused by XNP. However, 0.4.17 used a full-screen transparent `ISPanel`, so 0.4.18 removes that risk by switching to a minimal icon-sized UI element with `consumeMouseEvents=false`.

## Required 0.4.18 Changes

- Replace full-screen transparent UI area.
- Keep vanilla slot counting and overlap guard.
- Add measured black tooltip.
- Add READY / ACTIVE / FADING visual states.
- Move endurance support from passive infinite to adrenaline-only.


```

## BUILD_MARKER.txt

- SHA-256: `3DEF400AE3C686BD5CEFA4713EF95F5C95D4DBDBD8128AA8E05AFA4AD4B16959`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0417_NATIVE_MOODLE_LAYOUT_A

```

## CHANGELOG.md

- SHA-256: `C9E1EEE162036CCE0D33B905019589D448416436D1FBA888B3A31544351EDF96`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

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

- SHA-256: `CED5BD15A109980831A6A020DDE3C034707BF805E8A0EA1A47978775C8CDA226`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.4.17

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
VERSION=0.4.17
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0417_NATIVE_MOODLE_LAYOUT_A

TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION
TRAIT_FULL_ID=`XNPDistanceRunnerTrait:XNPDistanceRunner`

## 0.4.16 Accepted Runtime Results

- 0.4.16_STATUS_ICON_RESULT=FAIL_OVERLAPS_VANILLA_MOODLE
- 0.4.16_OVERLAP_ROOT_CAUSE=custom F did not mirror `MoodlesUI` visible slot calculation
- 0.4.16_RUNNING_SHOVE_RESULT=FAIL
- 0.4.16_ZERO_ARGUMENT_ERROR=YES
- 0.4.16_BUMPED_STATE_RESULT=IsoZombie cannot be cast to IsoPlayer
- 0.4.16_ERROR_REPEAT_RESULT=REPEATED_EVERY_UPDATE

## Vanilla Moodle Audit

- VANILLA_MOODLE_SOURCE_PATHS=`[LOCAL_PATH_REDACTED]`; `zombie.ui.MoodlesUI`; `zombie.ui.MoodleTextureSet`; `zombie.characters.Moodles.Moodles`; `zombie.scripting.objects.MoodleType`
- VANILLA_MOODLE_VISIBLE_RULE=`Moodles.getMoodleLevel(MoodleType) > 0`; `FOOD_EATEN` visible from `HighMoodleLevel`
- VANILLA_MOODLE_ORDER=registry/static MoodleType order mirrored by local list
- VANILLA_MOODLE_BASE_X=`screenWidth - 10 - iconSize`
- VANILLA_MOODLE_BASE_Y=120
- VANILLA_MOODLE_ICON_SIZE=`32,48,64,80,96,128`
- VANILLA_MOODLE_VERTICAL_SPACING=`iconSize + 10`
- VANILLA_MOODLE_UI_SCALE_RULE=`Core.getOptionMoodleSize()` with `Core.getOptionFontSizeReal()` fallback
- CUSTOM_MOODLE_REGISTRATION_AVAILABLE=NO_FOR_THIS_SOURCE

## 0.4.17 Status Icon

- STATUS_ICON_LAYOUT_METHOD=VANILLA_LAYOUT_COMPANION_SLOT
- VISIBLE_VANILLA_MOODLE_COUNT_METHOD=`player:getMoodles():getMoodleLevel(MoodleType.<name>)`
- NEXT_FREE_SLOT_METHOD=`visible vanilla Moodle count`
- RECTANGLE_OVERLAP_GUARD=YES
- DYNAMIC_REPOSITION_TRIGGERS=world entry, visible Moodle count/order change, player change, screen size change, Moodle size option change
- STATUS_ICON_TOOLTIP=`Distance Runner` / `Passive active: unlimited endurance.`
- STATUS_ICON_PERSISTENT=YES
- STATUS_ICON_SLOT_RESULT=REAL_GAME_TEST_REQUIRED_BY_USER

## Endurance

- ENDURANCE_METHOD=`player:getStats():set(CharacterStat.ENDURANCE, 1.0)`
- ENDURANCE_TARGET=1.00
- ENDURANCE_INTERVAL=0.20
- PASSIVE_INFINITE_ENDURANCE=YES

## Disabled Areas

- RUNNING_SHOVE_STATUS=DISABLED_AFTER_0_4_16_RUNTIME_FAILURE
- RUNNING_SHOVE_UPDATE_REGISTERED=NO
- BUMPED_STATE_PRESENT=NO in active runtime calls
- DYNAMIC_JAVA_METHOD_CALL_PRESENT=NO
- MOVEMENT_ENHANCEMENT_STATUS=DISABLED_FOR_LAYOUT_FIX

## Safety

- Accessed UIManager.MoodleUI Java array? NO, used public Moodles values and audited class formula
- Player coordinate write? NO
- Zombie coordinate write? NO
- Game time modification? NO
- Affects no-trait characters? NO
- Per-frame logs? NO
- Repeated exception path? NO

## Counts And Static Result

- Lua file count=23
- Lua total lines=1442
- Static check result=PASS_WITH_NOT_VERIFIABLE_LUA_EXECUTION
- NOT_VERIFIABLE: Lua execution check because no `lua` command is installed
- NOT_VERIFIABLE: final F slot behavior until real-game UI test
- Game launched? NO
-
[EXCERPT_TRUNCATED]
```

## NATIVE_MOODLE_LAYOUT_AND_ENDURANCE_TEST_0.4.17.md

- SHA-256: `AEBD41A96533D58FBD625D70F7C5334DFBA2E5FB99DA7347A8C2A707AB4B425C`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.17 鍘熺増鐘舵€佸浘鏍囧竷灞€涓庢棤闄愯€愬姏娴嬭瘯

1. 绂佺敤骞剁Щ鍑?0.4.16 鍜屾墍鏈夋棫鐗堟湰銆?2. 鍙惎鐢?0.4.17銆?3. 瀹屽叏閫€鍑哄苟閲嶆柊鍚姩娓告垙銆?4. 鍔犺浇鎷ユ湁闀块€斿琚€呯殑瑙掕壊銆?5. 纭鍙充笂瑙掑渾褰?F 鎸佺画鏄剧ず銆?6. 闈欐涓€鍒嗛挓锛岀‘璁?F 涓嶆秷澶便€?7. 鍦ㄦ病鏈夊叾浠栬礋闈㈢姸鎬佹椂鎴浘銆?8. 鍒堕€犳垨绛夊緟涓€涓師鐗堢姸鎬佸浘鏍囧嚭鐜帮紝渚嬪鐤插姵銆佺柤鐥涖€侀ゥ楗挎垨鎭愭厡銆?9. 纭 F 鑷姩绉诲姩鍒颁笅涓€涓Ы浣嶃€?10. 纭 F 涓嶈鐩栦换浣曞師鐗堢姸鎬佸浘鏍囥€?11. 鍚屾椂鍑虹幇涓よ嚦涓変釜鍘熺増鐘舵€佹椂鍐嶆纭鎺掑垪銆?12. 灏嗛紶鏍囩Щ鍒?F锛岀‘璁?tooltip 鍙睘浜?F銆?13. 鏀瑰彉绐楀彛澶у皬鎴栧垎杈ㄧ巼锛岀‘璁?F 閲嶆柊瀹氫綅銆?14. 鎸佺画璺戞锛岀‘璁ゆ棤闄愯€愬姏浠嶇劧鐢熸晥銆?15. 鏈疆涓嶈娴嬭瘯鎾炲嚮鍍靛案銆?16. 鏈疆涓嶈鍒ゆ柇绉诲姩閫熷害銆?17. 妫€鏌?console 涓病鏈?`expected 1 argument, got 0`銆?18. 妫€鏌?console 涓病鏈?`IsoZombie cannot be cast to IsoPlayer`銆?19. 妫€鏌ユ病鏈夋瘡甯ч噸澶嶉敊璇€?
```

## README_CN.md

- SHA-256: `EEB42D16C5C0CAC4D2BA708C759ABDFD7C284A2F0EE0858DFDD7D8B4F8147B7B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.17 Native Moodle Layout Fix

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

## 0.4.17_RIGHT_CLICK_INPUT_AUDIT.md

- SHA-256: `2FBBDA7B711CA23E44C574D385EC50E73937C1601C6749A3D85E3C53B7A4ABEE`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.17 Right Click Input Audit

## Files Checked

- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActiveStatusIcon.lua`
- Latest local `console.txt`

## Results

- XNP_CONTEXT_MENU_EVENT_REGISTERED=NO
- XNP_FULL_SCREEN_MOUSE_ELEMENT_PRESENT=YES_IN_0_4_17
- XNP_RIGHT_CLICK_HANDLER_PRESENT=NO
- XNP_LEFT_CLICK_HANDLER_PRESENT=YES_IN_0_4_17_AS_FALSE_RETURN_CALLBACK
- XNP_MOUSE_WHEEL_HANDLER_PRESENT=YES_IN_0_4_17_AS_FALSE_RETURN_CALLBACK
- ISOpenCloseWindow_ERROR_LINKED_TO_XNP=NOT_PROVEN

## Notes

0.4.17 did not register `OnFillWorldObjectContextMenu`, `OnPreFillWorldObjectContextMenu`, or `ISContextMenu` handlers. The only latest console line related to the user-observed issue was:

`ISTimedActionQueue:tick: bugged action, cleared queue ISOpenCloseWindow`

That line alone does not prove XNP caused the action queue issue. The full-screen transparent panel was still an input risk, so 0.4.18 removes it.

## 0.4.18 Input Design

- FULL_SCREEN_MOUSE_ELEMENT_REMOVED=YES
- STATUS_ICON_RENDER_METHOD=MINIMAL_ICON_UI_ELEMENT
- MOUSE_EVENTS_CONSUMED=NO
- XNP_RIGHT_CLICK_HANDLER_PRESENT=NO
- XNP_CONTEXT_MENU_EVENT_REGISTERED=NO
- WORLD_RIGHT_CLICK_SHOULD_PASS_THROUGH=YES


```

## B42_19_VANILLA_MOODLE_LAYOUT_AUDIT.md

- SHA-256: `AF7F6C0D8A0C5D4F24084F43DAF98FD12D5E6541DC274B46FDEBCBBF014D52E9`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Vanilla Moodle Layout Audit

SEARCH_ROOT=`[LOCAL_PATH_REDACTED]`

## Source Paths

- `[LOCAL_PATH_REDACTED]`
- `zombie.ui.MoodlesUI`
- `zombie.ui.MoodlesUI$MoodleUIData`
- `zombie.ui.MoodleTextureSet`
- `zombie.characters.Moodles.Moodles`
- `zombie.characters.Moodles.Moodle`
- `zombie.characters.Moodles.Moodle$MoodleLevel`
- `zombie.scripting.objects.MoodleType`
- Texture assets under `[LOCAL_PATH_REDACTED]`
- Texture assets under `[LOCAL_PATH_REDACTED]`

Class inspection was done with `javap` against `projectzomboid.jar`. The game was not launched and no game file was modified.

## Required Answers

1. Player Moodles object:
   - Evidence: `MoodlesUI.update()` calls `IsoGameCharacter.getMoodles()`.
   - Lua-facing equivalent already used locally: `player:getMoodles()`.
   - Method: `zombie.characters.IsoGameCharacter.getMoodles()`.
   - Conclusion: 0.4.17 uses `player:getMoodles()`.

2. MoodleType enumeration:
   - Evidence: `javap zombie.scripting.objects.MoodleType`.
   - Names include `ENDURANCE`, `TIRED`, `HUNGRY`, `PANIC`, `SICK`, `BORED`, `UNHAPPY`, `BLEEDING`, `WET`, `HAS_A_COLD`, `ANGRY`, `STRESS`, `THIRST`, `INJURED`, `PAIN`, `HEAVY_LOAD`, `DRUNK`, `DEAD`, `ZOMBIE`, `HYPERTHERMIA`, `HYPOTHERMIA`, `WINDCHILL`, `CANT_SPRINT`, `UNCOMFORTABLE`, `NOXIOUS_SMELL`, `FOOD_EATEN`.
   - Method: static fields on `zombie.scripting.objects.MoodleType`.
   - Conclusion: 0.4.17 checks these named fields through Lua `MoodleType.<name>`.

3. Visible rule:
   - Evidence: `MoodlesUI.update()` calls `Moodles.getMoodleLevel(MoodleType)` and checks `> 0`.
   - Method: `Moodles.getMoodleLevel(MoodleType)`.
   - Conclusion: level greater than zero is visible, except `FOOD_EATEN`.

4. level=0:
   - Evidence: `MoodlesUI.update()` sets `slotsPos` and `slotsDesiredPos` to `10000.0f` when level is not positive.
   - Conclusion: level 0 is hidden and does not occupy a normal visible slot.

5. Display order:
   - Evidence: `MoodlesUI` builds a state map from `Registries.MOODLE_TYPE.values()` and then assigns sequential slots as visible entries are processed.
   - Conclusion: vanilla display order follows the registry iteration order. 0.4.17 mirrors the local registered static order exposed by `MoodleTextureSet` and `MoodleType`.

6. First icon X and Y:
   - Evidence: `MoodlesUI` constructor sets `x = Core.getScreenWidth() - 10` and `y = 120.0`.
   - Evidence: render draws textures at local x approximately `-width`, giving absolute left edge `screenWidth - 10 - iconSize`.
   - Conclusion: 0.4.17 uses `screenWidth - 10 - iconSize` and base Y `120`.

7. Vertical spacing:
   - Evidence: `MoodlesUI.update()` sets `moodleDistY = 10.0f + width`.
   - Conclusion: slot vertical distance is `iconSize + 10`.

8. UI scale and size:
   - Evidence: `MoodlesUI.getTextureSizeForOption()` uses `Core.getOptionMoodleSize() - 1` to select `32,48,64,80,96,128`; option index 6 follows `Core.getOptionFontSizeReal() - 1`.
   - Conclusion: 0.4.17 uses the same size table and font-siz
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `691A77E1E3584CBE07934EA765600EC73640D835A113A298D8EAE772B2DD8F2A`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.4.17

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
VERSION=0.4.17
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0417_NATIVE_MOODLE_LAYOUT_A

## Identity

- Old SOURCE modified=NO
- Trait full ID unchanged=`XNPDistanceRunnerTrait:XNPDistanceRunner`
- Character creation cost unchanged=YES
- Character info panel F unchanged=YES
- TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION

## Status Icon

- Local vanilla Moodle files audited=YES
- Vanilla layout formula evidence=YES
- STATUS_ICON_LAYOUT_METHOD=VANILLA_LAYOUT_COMPANION_SLOT
- CUSTOM_MOODLE_REGISTRATION_AVAILABLE=NO_FOR_THIS_SOURCE
- Fixed F slot=ABSENT
- Fixed F_Y=ABSENT
- Fixed `screenWidth - 28`=ABSENT
- Dynamic vanilla visible state count=YES
- Dynamic slot selection=YES
- RECTANGLE_OVERLAP_GUARD=YES
- Reposition after vanilla state changes=YES
- Reposition after resolution change=YES
- UI scale change recalculation=YES through `Core.getOptionMoodleSize()` and `Core.getOptionFontSizeReal()`
- F persistent display=YES
- Timed F hide=ABSENT
- Running dependency=ABSENT
- Movement test dependency=ABSENT
- Tooltip=`Distance Runner` / `Passive active: unlimited endurance.`

## Endurance

- Passive unlimited endurance=YES
- ENDURANCE_METHOD=`player:getStats():set(CharacterStat.ENDURANCE, 1.0)`
- ENDURANCE_TARGET=1.00
- ENDURANCE_INTERVAL=0.20
- Fatigue/Hunger/Thirst/Calories/Pain/Panic/Stress/Injury/Encumbrance/GameTime/Fitness/Sprinting writes=ABSENT

## Disabled Runtime Areas

- RUNNING_SHOVE_STATUS=DISABLED_AFTER_0_4_16_RUNTIME_FAILURE
- RunningShove Update registration=ABSENT
- BumpedState call=ABSENT
- Zombie state modification=ABSENT
- Dynamic Java method call=ABSENT
- Zero-argument unknown Java call=ABSENT
- Unbound Java method pcall=ABSENT
- Per-frame pcall error retry=ABSENT
- Per-frame error log=ABSENT
- MOVEMENT_ENHANCEMENT_STATUS=DISABLED_FOR_LAYOUT_FIX
- Movement speed modification=ABSENT
- Player coordinate write=ABSENT
- Zombie coordinate write=ABSENT
- Game time modification=ABSENT

## Counts And Checks

- Lua files=23
- Lua total lines=1442
- Empty Lua files=NO
- NULL bytes=NO
- Lua execution check=NOT_VERIFIABLE because no `lua` command is installed
- Game launched=NO
- Steam launched=NO
- User mods/saves/Workshop/game directory writes=NO

STATIC_CHECK_RESULT=PASS_WITH_NOT_VERIFIABLE_LUA_EXECUTION

```
