# 0.4.14 Sanitized Evidence Excerpts

## 0.4.14_REAL_GAME_RESULT_ANALYSIS.md

- SHA-256: `A61DC2F666625E5005212CFE514E4D238314FC6DB8594329F22BE31450643FA6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.14 Real Game Result Analysis

## Confirmed

- TRAIT_VISIBLE_IN_CHARACTER_CREATION=YES
- TRAIT_PRESENT_ON_PLAYER=YES
- CHARACTER_INFO_PANEL_F=YES
- RUNNING_DETECTION=YES

Observed runtime log:

- `[XNP RUNNING F] texture_resolved=true`
- `[XNP RUNNING F] panel_created=true`
- `[XNP RUNNING F] visible=true reason=running`
- `[XNP RUNNING F] panel_width=1920`
- `[XNP RUNNING F] panel_height=1009`
- `[XNP RUNNING F] draw_x=1892`
- `[XNP RUNNING F] draw_y=118`
- `[XNP RUNNING F] first_actual_draw=true`

## Failed

- STATUS_ICON_VISUAL_RESULT=FAIL
- ENDURANCE_RESULT=FAIL
- MOVEMENT_TEST_RESULT=NOT_TESTED

## Status Icon Root Cause

0.4.14 drew the raw 18x18 F texture directly on a fullscreen transparent panel. It did not use the vanilla circular Moodle background and did not visually join the right-side Moodle-style status column.

0.4.15 changes this to:

- STATUS_ICON_METHOD=MOODLE_STYLE_CUSTOM_SLOT
- original 32x32 Moodle background textures
- centered 18x18 F texture
- vertical position based on current active Moodle count read from player moodle data

## Endurance Root Cause

0.4.14 assumed `stats:getEndurance()` and `stats:setEndurance()` still existed. Local B42.19 Lua evidence instead shows:

- read: `player:getStats():get(CharacterStat.ENDURANCE)`
- write: `player:getStats():set(CharacterStat.ENDURANCE, value)`

0.4.15 uses this CharacterStat form.

## Trait Logging Root Cause

0.4.14 repeatedly resolved `ResourceLocation` and `CharacterTrait` during Update calls. 0.4.15 caches:

- targetTraitObject
- playerHasTargetTrait

The cache is refreshed only on player creation / world re-entry paths.

```

## BUILD_MARKER.txt

- SHA-256: `F8D7378129D0649B711977BBB03340A86C67E8A97AD064A0D2A218767A9905F0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0414_RUNNING_F_ENDURANCE_A

```

## FINAL_REPORT.md

- SHA-256: `90A4C82FBC24C5EE1797B2EC53DE1344DB1FA37CDD7CE8BD01711A6D2A920F20`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.4.14

## Identity

- SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
- VERSION=0.4.14
- INTERNAL_VERSION=0.4.14-b42-running-f-endurance-fix-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0414_RUNNING_F_ENDURANCE_A
- Display name: `XNP Distance Runner Trait 0.4.14 Running F + Endurance Fix`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 0.4.13 Runtime Result

- 0.4.13_NATIVE_TRAIT_RESULT=PASS
- 0.4.13_CHARACTER_PANEL_F_RESULT=PASS
- 0.4.13_RIGHT_STATUS_F_RESULT=FAIL
- 0.4.13_ICON_ERROR_ROOT_CAUSE=active module still touched rejected Java Moodles UI array path and used an unproven constructor route
- 0.4.13_ENDURANCE_RESULT=FAIL
- 0.4.13_ENDURANCE_ERROR_ROOT_CAUSE=nil/unbound Java method path reached through pcall and repeated Update calls

## 0.4.14 Right Status F

- RIGHT_STATUS_F_DRAW_METHOD=TOP_LEVEL_FULLSCREEN_TRANSPARENT_ISPANEL
- RIGHT_STATUS_F_TRIGGER=target trait player and `player:isSprinting()==true` or `player:isRunning()==true`
- RIGHT_STATUS_F_HIDE_DELAY=0.30 seconds after running/sprinting stops
- RIGHT_STATUS_F_X_CALCULATION=`panel.width - 28`
- RIGHT_STATUS_F_Y=118
- TOP_LEVEL_ISUI_SAMPLE_PATH=`[LOCAL_PATH_REDACTED]`

## 0.4.14 Endurance

- INFINITE_ENDURANCE_IMPLEMENTED=YES
- ENDURANCE_MODIFICATION_METHOD=player:getStats():setEndurance(1.0)
- ENDURANCE_TARGET=1.00
- ENDURANCE_INTERVAL=0.20 seconds
- Affects no-trait character=NO

## Module Isolation

- MODULE_FAILURE_ISOLATION=YES
- RIGHT_STATUS_F_MODULE has `disabled`, `fatalLogged`, `cleanupDone`.
- ENDURANCE_MODULE has `disabled`, `fatalLogged`, `cleanupDone`.
- Failure of one module does not disable the other.

## Movement Speed

- MOVEMENT_SPEED_MODIFICATION_METHOD=NONE
- Accesses MoodlesUI=NO
- Modifies movement speed=NO
- Modifies coordinates=NO
- Modifies time=NO
- Shows movement speed test HUD=NO

## Counts

- Lua file count: 20
- Lua total lines: 1556
- Root Markdown docs: 47

## Static Check

- Static check result: PASS
- Game launched: NO
- Steam launched: NO
- Old SOURCE modified: NO
- User mods/saves/Workshop/game directory write: NO

## NOT_VERIFIABLE

- Lua 5.1 execution parser: NOT_VERIFIABLE
- Actual in-game top-right visual alignment: REAL_GAME_TEST_REQUIRED_BY_USER
- Actual B42 `isRunning` reliability: REAL_GAME_TEST_REQUIRED_BY_USER
- Long-run endurance behavior: REAL_GAME_TEST_REQUIRED_BY_USER

## BLOCKER

- BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.14_SOURCE_READY_FOR_RUNNING_F_AND_INFINITE_ENDURANCE_TEST

```

## RUNNING_F_AND_INFINITE_ENDURANCE_TEST_0.4.14.md

- SHA-256: `23B19386B0CE8DAA8AFBBEBC8E4A9413589E9353F2742973A56962529F9A3552`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.14 璺戞 F 涓庢棤闄愯€愬姏娴嬭瘯璇存槑

## 娴嬭瘯鐩爣

鏈疆鍙獙璇佷袱涓姛鑳斤細

1. 鎷ユ湁 `XNPDistanceRunnerTrait:XNPDistanceRunner` 鐨勭帺瀹惰窇姝ユ垨鍐插埡鏃讹紝鍙充笂瑙掔姸鎬佸浘鏍囧垪闄勮繎鏄剧ず榛勮壊 F锛涘仠姝㈢Щ鍔ㄨ秴杩?0.30 绉掑悗闅愯棌銆?2. 鎷ユ湁璇ョ壒璐ㄧ殑鏈湴鐜╁鑾峰緱娴嬭瘯鐢ㄦ棤闄愯€愬姏銆?
MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

## 娴嬭瘯姝ラ

1. 鍙惎鐢?0.4.14銆?2. 瀹屽叏閲嶅惎娓告垙銆?3. 鍔犺浇宸叉湁闀块€斿琚€呰鑹层€?4. 鎵撳紑浜虹墿淇℃伅闈㈡澘锛岀‘璁ゅ師鐢?F 浠嶅瓨鍦ㄣ€?5. 鍏抽棴浜虹墿闈㈡澘銆?6. 闈欐鏃剁‘璁ゅ彸涓婅鐘舵€佸垪娌℃湁 F銆?7. 寮€濮嬭窇姝ユ垨鍐插埡銆?8. 纭鍙充笂瑙掔姸鎬佸浘鏍囧垪鍑虹幇 F銆?9. 鍋滄璺戞锛岀‘璁?F 鍦?0.30 绉掑悗娑堝け銆?10. 杩炵画璺戞鑷冲皯涓ゅ垎閽熴€?11. 纭鑰愬姏涓嶄細涓嬮檷鍒板彧鑳芥參璺戙€?12. 纭娌℃湁涓ぎ鏂囧瓧銆?13. 纭娌℃湁 Lua 閿欒寮圭獥鎴栨棩蹇楀埛灞忋€?
## 姝ｇ‘缁撴灉

- 浜虹墿淇℃伅闈㈡澘浠嶆湁鍘熺敓 F銆?- 瑙掕壊闈欐鏃跺彸涓婅鐘舵€佸垪娌℃湁 F銆?- 璺戞鎴栧啿鍒哄悗鍙充笂瑙掔姸鎬佸垪鍑虹幇 F銆?- 鍋滄瓒呰繃 0.30 绉掑悗 F 娑堝け銆?- F 涓嶅嚭鐜板湪宸︿笂瑙掋€?- F 涓嶅嚭鐜板湪灞忓箷涓ぎ銆?- F 涓嶈鐩栦汉鐗╀俊鎭潰鏉裤€?- 涓嶅嚭鐜?Lua 閿欒銆?
## 娉ㄦ剰

浜虹墿淇℃伅闈㈡澘 F 鍜屽彸涓婅杩愯鐘舵€?F 鏄袱涓笉鍚岀敤閫旂殑鏄剧ず銆?
```

## B42_TOP_LEVEL_ISUI_WORKING_SAMPLE_AUDIT.md

- SHA-256: `CFC384FEA4232E2BCF9F4429403A352072BE7E4A68C45B19BEDA3B4B684AD688`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42 Top-Level ISUI Working Sample Audit

## Working Sample

- WORKING_SAMPLE_PATH=`[LOCAL_PATH_REDACTED]`

Relevant local B42 pattern:

```lua
require "ISUI/ISCollapsableWindow"

InterpolationPlayerPeriodDebug.instance = InterpolationPlayerPeriodDebug:new(100, 100, 900, 300, getPlayer())
InterpolationPlayerPeriodDebug.instance:initialise()
InterpolationPlayerPeriodDebug.instance:instantiate()
InterpolationPlayerPeriodDebug.instance:addToUIManager()
InterpolationPlayerPeriodDebug.instance:setVisible(true)
```

## Required Lifecycle

- REQUIRED_IMPORT=`require "ISUI/ISPanel"` for 0.4.14 panel, copied from the same ISUI family.
- CONSTRUCTOR_SIGNATURE=`ISPanel:new(x, y, width, height)`
- INITIALISE_REQUIRED=YES
- INSTANTIATE_REQUIRED=YES
- ADD_TO_UI_MANAGER_CALL=`panel:addToUIManager()`
- DRAW_METHOD=`self:drawTextureScaled(texture, x, y, w, h, a, r, g, b)`

## Draw Method Evidence

- `drawTextureScaled` is defined in `[LOCAL_PATH_REDACTED]`.
- Many vanilla ISUI files call `self:drawTextureScaled(...)`, including `ISUI\ISButton.lua`, `ISUI\ISEquippedItem.lua`, and debug UI files.

## 0.4.14 Use

0.4.14 creates one fullscreen transparent top-level `ISPanel`:

- `panel.x=0`
- `panel.y=0`
- `panel.width=getCore():getScreenWidth()`
- `panel.height=getCore():getScreenHeight()`
- no background
- transparent border
- no mouse handling
- always on top when the API exists
- created once
- resized on resolution change

RIGHT_STATUS_F_DRAW_METHOD=TOP_LEVEL_FULLSCREEN_TRANSPARENT_ISPANEL

```

## STATIC_AUDIT.md

- SHA-256: `D8FB76E6F6CE6831567E264A58863FE24CF43997E3135DEF1840706CE826259F`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.4.14

- SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
- VERSION=0.4.14
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0414_RUNNING_F_ENDURANCE_A
- RIGHT_STATUS_F_DRAW_METHOD=TOP_LEVEL_FULLSCREEN_TRANSPARENT_ISPANEL
- ENDURANCE_MODIFICATION_METHOD=player:getStats():setEndurance(1.0)
- MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

## Results

- UIManager.MoodleUI=ABSENT_IN_ACTIVE_LUA
- MoodlesUI=ABSENT_IN_ACTIVE_LUA
- Java array read=ABSENT_IN_ACTIVE_LUA
- top-level ISPanel local sample evidence=YES
- fullscreen transparent panel=YES
- fixed right margin dynamic positioning=YES
- running F show=YES
- stop F hide=YES
- per-frame UI creation=ABSENT
- per-frame log=ABSENT
- pcall(nil)=ABSENT
- unbound Java method passed into pcall=ABSENT
- infinite endurance direct call=YES
- module isolated fuse=YES
- movement speed modification=ABSENT
- central debug text=ABSENT
- Trait ID changed=NO
- character panel F changed=NO

## NOT_VERIFIABLE

- Lua 5.1 execution parser: NOT_VERIFIABLE
- Actual in-game top-right visual alignment: REAL_GAME_TEST_REQUIRED_BY_USER
- Actual B42 `isRunning` reliability: REAL_GAME_TEST_REQUIRED_BY_USER
- Long-run endurance behavior: REAL_GAME_TEST_REQUIRED_BY_USER

STATIC_AUDIT_RESULT=PASS
BLOCKER=NONE_STATIC

```

## STATIC_AUDIT_0.4.14.md

- SHA-256: `575399A1E30CCDFEBD6E9F1FF42DA450EA78AFC3F7B14F9B04A0D8B41D4889EA`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.4.14

## Scope

- SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
- VERSION=0.4.14
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0414_RUNNING_F_ENDURANCE_A

## Required Checks

- UIManager.MoodleUI=ABSENT_IN_ACTIVE_LUA
- MoodlesUI=ABSENT_IN_ACTIVE_LUA
- Java array read=ABSENT_IN_ACTIVE_LUA
- unknown new call=ABSENT_BY_LOCAL_SAMPLE_MATCH
- top-level ISPanel local sample evidence=YES
- fullscreen transparent panel=YES
- fixed right margin dynamic positioning=YES
- running F show=YES
- stop F hide=YES
- per-frame UI creation=ABSENT
- per-frame log=ABSENT
- pcall(nil)=ABSENT
- unbound Java method passed into pcall=ABSENT
- infinite endurance direct call=YES
- module isolated fuse=YES
- movement speed modification=ABSENT
- central debug text=ABSENT
- Trait ID changed=NO
- character panel F changed=NO

## Active Lua Forbidden String Scan

The active Lua tree was scanned for:

- `UIManager.MoodleUI`
- `MoodlesUI`
- `setSpeedMod`
- `setMoveSpeed`
- `setPathSpeed`
- `setCombatSpeed`
- `setFastMoveCheat`
- coordinate write patterns
- time speed write patterns
- center HUD text strings

Result: PASS

## Lua Syntax Risk

- Lua 5.1 execution parser: NOT_VERIFIABLE
- Quote/comment balance text scan: PASS
- BOM in text files: PASS after cleanup
- NULL in text files: PASS

## NOT_VERIFIABLE

- Actual in-game top-right visual alignment: REAL_GAME_TEST_REQUIRED_BY_USER
- Actual B42 `isRunning` reliability: REAL_GAME_TEST_REQUIRED_BY_USER
- Long-run endurance behavior: REAL_GAME_TEST_REQUIRED_BY_USER

## Result

STATIC_AUDIT_RESULT=PASS
BLOCKER=NONE_STATIC

```
