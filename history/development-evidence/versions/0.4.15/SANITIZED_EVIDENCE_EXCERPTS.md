# 0.4.15 Sanitized Evidence Excerpts

## 0.4.15_REAL_GAME_RESULT_AND_FEATURE_TRANSITION.md

- SHA-256: `2DF2C241A19E6AAD057F06F87804B6079739A3A3DF1B49F8911CF7321DC42BFD`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.15 Real Game Result And Feature Transition

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Accepted 0.4.15 Result

- ENDURANCE_METHOD=`player:getStats():set(CharacterStat.ENDURANCE,1.0)`
- ENDURANCE_REAL_GAME_RESULT=PASS
- STATUS_ICON_METHOD=MOODLE_STYLE_CUSTOM_SLOT
- STATUS_ICON_CREATION=PASS
- STATUS_ICON_DRAW=PASS
- STATUS_ICON_VISUAL_STYLE=PASS
- normal_dps=4.8349609375
- fast_dps=4.657611986243764
- ratio=0.9633194655450645
- SET_FAST_MOVE_CHEAT_CALL=EXECUTED
- SET_FAST_MOVE_CHEAT_WORLD_SPEED_RESULT=FAIL
- SET_FAST_MOVE_CHEAT_MUST_BE_REMOVED=YES

## 0.4.16 Transition

0.4.16 keeps the successful parts as passive features:

- Persistent right-side circular F icon.
- Passive endurance restoration through `CharacterStat.ENDURANCE`.

0.4.16 removes the failed fast movement experiment from active runtime code. Movement now uses state observation and one per-session world displacement verification only. The first running shove candidate is separated into its own module so a failure there does not disable the icon or endurance.

```

## BUILD_MARKER.txt

- SHA-256: `1C900B4B908093B5E90076F48F550DAAF8D29BD31A5FD0B2D912228763A476EC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0415_MOODLE_FASTMOVE_A

```

## FINAL_REPORT.md

- SHA-256: `508DED354E4B279150B87F7F4B952C2C87033F919C95E4C40AB001500468757B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.4.15

## Required Summary

- SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
- VERSION=0.4.15
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0415_MOODLE_FASTMOVE_A

## Trait

- TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION
- TRAIT_OBJECT_CACHED=YES
- PLAYER_TRAIT_RESULT_CACHED=YES
- PER_FRAME_TRAIT_LOOKUP_REMOVED=YES
- PER_FRAME_TRAIT_LOG_REMOVED=YES

## Status Icon

- STATUS_ICON_METHOD=MOODLE_STYLE_CUSTOM_SLOT
- CUSTOM_MOODLE_REGISTRATION_AVAILABLE=NO
- ORIGINAL_MOODLE_BACKGROUND_TEXTURE=`media/ui/Moodles/32/_Moodles_BGsolid.png` and `media/ui/Moodles/32/_Moodles_BGoutline.png`
- ORIGINAL_MOODLE_SIZE=32x32
- ORIGINAL_MOODLE_SPACING=8px custom slot spacing; exact Java-side spacing NOT_VERIFIABLE_BY_STATIC_AUDIT
- F_TEXTURE=`media/ui/Traits/trait_xnpdistancerunner.png`
- F_CENTERED_INSIDE_CIRCLE=YES
- DYNAMIC_STATUS_POSITIONING=YES, based on active player moodle levels
- TOOLTIP_TEXT=`Distance Runner` / `Fast movement test is active.`

## Movement Test

- MOVEMENT_TEST_METHOD=player:setFastMoveCheat(boolean)
- NORMAL_SAMPLE_DURATION=1.50 seconds
- FAST_SAMPLE_DURATION=3.00 seconds
- FAST_MOVE_RESET_PATHS=sample complete, unsafe player state, player death, main menu, game exit, cleanup
- WORLD_DISPLACEMENT_MEASUREMENT=YES
- MOVEMENT_PASS_RATIO=1.50
- MOVEMENT_TEST_RESULT_AT_STATIC_STAGE=NOT_RUN_STATIC_STAGE

## Endurance

- ENDURANCE_METHOD=STATS_CHARACTERSTAT_ENDURANCE_SET
- ENDURANCE_TARGET=1.00
- ENDURANCE_INTERVAL=0.20 seconds
- ENDURANCE_LOCAL_EVIDENCE=`player:getStats():get(CharacterStat.ENDURANCE)` and `player:getStats():set(CharacterStat.ENDURANCE, value)` found in local B42 Lua files

## Safety

- Calls UIManager.MoodleUI array=NO
- Modifies player coordinates=NO
- Modifies game time=NO
- Affects no-trait characters=NO
- Shows center debug text=NO
- Has per-frame logging=NO
- Game launched=NO
- Steam launched=NO
- Old SOURCE modified=NO
- User mods/saves/Workshop/game directory write=NO

## Counts

- Lua file count: 20
- Lua total lines: 1381

## Static Check

- Static check result: PASS

## NOT_VERIFIABLE

- Custom Moodle registration from Java classes: NOT_VERIFIABLE because requested `zombie.jar` path was not found.
- Exact Java-side vanilla Moodle vertical spacing: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Real in-game Fast Move effect: REAL_GAME_TEST_REQUIRED_BY_USER.
- Real in-game endurance write behavior: REAL_GAME_TEST_REQUIRED_BY_USER.

## BLOCKER

- BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.15_SOURCE_READY_FOR_MOODLE_FASTMOVE_AND_ENDURANCE_TEST

```

## MOODLE_FASTMOVE_ENDURANCE_TEST_0.4.15.md

- SHA-256: `B5F28F705C00B0AD65D53F7F7927ABFAE0BB9BB0CDBD1366CC5BC9DA88C45907`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.15 Moodle + Fast Move + Endurance Test

## 娴嬭瘯姝ラ

1. 鍙惎鐢?0.4.15锛屼笉鍚敤鏃х増鏈€?2. 瀹屽叏閫€鍑哄苟閲嶆柊鍚姩娓告垙銆?3. 杩涘叆鎷ユ湁鈥滈暱閫斿琚€呪€濈殑瑙掕壊銆?4. 鎵撳紑浜虹墿淇℃伅闈㈡澘锛岀‘璁ゅ師鏈夌壒璐?F 浠嶇劧瀛樺湪銆?5. 鍏抽棴浜虹墿淇℃伅闈㈡澘銆?6. 闈欐鏃剁‘璁ゅ彸渚ф病鏈夐澶?F銆?7. 鎵句竴鏉＄洿璺紝鎸佺画鎸夎窇姝ラ敭鍚戝悓涓€鏂瑰悜绉诲姩銆?8. 鍓嶇害 1.5 绉掑簲涓烘櫘閫氶€熷害鏍锋湰銆?9. 闅忓悗绾?3 绉掑簲杩涘叆 Fast Move 娴嬭瘯銆?10. Fast Move 娴嬭瘯鏈熼棿纭鍙充晶鐘舵€佹爮鍑虹幇鍦嗗舰 F銆?11. 纭 F 澶栬鍜屽師鐗堟亹鎱屻€佺柤鐥涖€佺敓鐥呯瓑鍦嗗舰鍥炬爣涓€鑷淬€?12. 3 绉掑悗纭閫熷害鎭㈠锛孎 娑堝け銆?13. 妫€鏌ユ帶鍒跺彴娌℃湁杩炵画閲嶅鏃ュ織銆?14. 妫€鏌ユ棩蹇椾腑鐨?`normal_dps`銆乣fast_dps`銆乣ratio` 鍜?`result`銆?15. 鎸佺画璺戞瑙傚療鑰愬姏鏄惁淇濇寔锛涘鏋滆€愬姏鎺ュ彛澶辫触锛屼互鏃ュ織瀹¤缁撴灉涓哄噯銆?
## Expected Result

- STATUS_ICON_METHOD=MOODLE_STYLE_CUSTOM_SLOT
- MOVEMENT_TEST_METHOD=player:setFastMoveCheat(boolean)
- ENDURANCE_METHOD=STATS_CHARACTERSTAT_ENDURANCE_SET
- No center-screen debug text.
- No repeated trait resolution log spam.

```

## B42_19_CUSTOM_MOODLE_API_AUDIT.md

- SHA-256: `4C759E9BD439F55FF2D806F71F2A3A5C46B21EF8E2767CF7C043D92E9ABD5054`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Custom Moodle API Audit

## Search Scope

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- Requested `[LOCAL_PATH_REDACTED]`: NOT_FOUND_AT_REQUESTED_PATH

## Local Evidence

Lua search found vanilla moodle access through:

- `player:getMoodles()`
- `moodles:getMoodleLevel(MoodleType.ENDURANCE)`
- existing constants such as `MoodleType.PANIC`, `MoodleType.PAIN`, `MoodleType.TIRED`, `MoodleType.ENDURANCE`

Lua search did not find a callable custom registration function matching:

- `MoodleType.register`
- `MoodleType.add`
- `MoodleDefinition`

Vanilla moodle texture files found:

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- Both verified as 32x32.

## Required Answers

1. Does B42.19 allow registering a new MoodleType?
   - NOT_FOUND_IN_LOCAL_LUA_EVIDENCE.

2. Is there a public custom Moodle definition API?
   - NOT_FOUND_IN_LOCAL_LUA_EVIDENCE.

3. Real vanilla circular background texture names and paths.
   - `_Moodles_BGsolid.png`
   - `_Moodles_BGoutline.png`
   - under `media/ui/Moodles/32/`.

4. Vanilla status icon size.
   - 32x32 for the verified 32 Moodle background textures.

5. Vanilla vertical spacing.
   - Not exposed by the searched Lua files. 0.4.15 uses 8 px spacing between 32 px moodle-style slots.

6. How vanilla status icon position is calculated.
   - Java-side Moodle UI calculation was not available from Lua evidence. 0.4.15 does not inspect the Java UI array. It uses a right-side custom slot position and counts active moodles from player data.

7. Can a custom status enter the vanilla list?
   - NOT_CONFIRMED. No local callable registration API was found.

8. If custom registration is unavailable, how to make a visually consistent custom slot?
   - Draw a 32x32 vanilla moodle circular background.
   - Draw the 18x18 F texture centered inside it.
   - Place it on the same right-side column.
   - Read active moodle levels from player data and place the custom slot after currently active moodles.

## Decision

- CUSTOM_MOODLE_REGISTRATION_AVAILABLE=NO
- STATUS_ICON_METHOD=MOODLE_STYLE_CUSTOM_SLOT

```

## B42_19_ENDURANCE_METHOD_AUDIT.md

- SHA-256: `6340741D22ADB8F7404EB37050ADCC00E14D3E783EA42F69B0D18E1D4BD409C8`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Endurance Method Audit

## Search Scope

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- Requested `[LOCAL_PATH_REDACTED]`: NOT_FOUND_AT_REQUESTED_PATH

## Local Lua Evidence

Found endurance read/write examples:

- `media\lua\shared\Foraging\forageSystem.lua`
  - read: `_character:getStats():get(CharacterStat.ENDURANCE)`
  - write: `_character:getStats():set(CharacterStat.ENDURANCE, enduranceLevel)`
- `media\lua\shared\Camping\ISCampingMenu.lua`
  - read: `playerObj:getStats():get(CharacterStat.ENDURANCE)`
- `media\lua\client\DebugUIs\ISRunningDebugUI.lua`
  - reset: `self.chr:getStats():reset(CharacterStat.ENDURANCE)`
- `media\lua\client\Tutorial\Tutorial1.lua`
  - alternate test helper: `chr:setUnlimitedEndurance(true)`

## Method Decision

- Actual object path: `player:getStats()`
- Actual read method: `stats:get(CharacterStat.ENDURANCE)`
- Actual write method: `stats:set(CharacterStat.ENDURANCE, value)`
- Parameter count for write: 2
- Parameter types for write: `CharacterStat.ENDURANCE`, numeric value
- Return type: NOT_VERIFIABLE_BY_STATIC_AUDIT

## 0.4.15 Implementation

ENDURANCE_METHOD=STATS_CHARACTERSTAT_ENDURANCE_SET

Runtime call shape:

```lua
local ok, err = pcall(function()
    local stats = player:getStats()
    local before = stats:get(CharacterStat.ENDURANCE)
    stats:set(CharacterStat.ENDURANCE, 1.0)
    local after = stats:get(CharacterStat.ENDURANCE)
end)
```

No unbound Java instance method is passed directly into `pcall`.

## Limitations

- Java class audit was not possible because `zombie.jar` was not found at the requested path.
- Real-game write behavior remains REAL_GAME_TEST_REQUIRED_BY_USER.

```

## STATIC_AUDIT.md

- SHA-256: `3D5D19D0EE299E2E600E96D270684DA7F52401149FFF8ABB340A336D975B7CA1`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.4.15

## Identity

- SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
- VERSION=0.4.15
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0415_MOODLE_FASTMOVE_A

## Static Checks

- Old SOURCE modified=NO
- Trait full ID changed=NO
- Character creation cost changed=NO
- Character info panel F changed=NO
- Raw fixed 18x18 top-right image implementation removed=YES
- Fixed `screenWidth - 28` drawing removed=YES
- Fixed `draw_y=118` drawing removed=YES
- Original circular moodle background used=YES
- F centered inside circle=YES
- Status icon placed in right-side vertical column=YES
- UIManager.MoodleUI Java array indexing=ABSENT
- Dynamic Java method call by name=ABSENT
- player[name] call=ABSENT
- Per-frame CharacterTrait resolution=ABSENT
- Per-frame trait logging=ABSENT
- Movement test method only uses `setFastMoveCheat`=YES
- setSpeedMod=ABSENT
- setMoveSpeed=ABSENT
- setPathSpeed=ABSENT
- setCombatSpeed=ABSENT
- Player coordinate writes=ABSENT
- Game time modification=ABSENT
- World displacement comparison=YES
- Normal sample=YES
- Fast sample=YES
- Ratio calculation=YES
- Divide-by-zero protection=YES
- NaN protection=YES
- Exit reset=YES
- Endurance method local audit=YES
- Missing endurance method does not repeat log=YES
- Center debug text=ABSENT
- Per-frame log spam=ABSENT

## Counts

- Lua file count: 20
- Lua total lines: 1381

## NOT_VERIFIABLE

- Custom Moodle registration from Java classes: NOT_VERIFIABLE because requested `zombie.jar` path was not found.
- Exact Java-side vanilla Moodle vertical spacing: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- Real in-game Fast Move effect: REAL_GAME_TEST_REQUIRED_BY_USER.
- Real in-game endurance write behavior: REAL_GAME_TEST_REQUIRED_BY_USER.

## Result

STATIC_AUDIT_RESULT=PASS
CODE_ISSUE=NONE_FOUND_BY_STATIC_SCAN

```
