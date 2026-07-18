# 0.4.16 Sanitized Evidence Excerpts

## 0.4.16_RUNNING_SHOVE_RUNTIME_FAILURE_ANALYSIS.md

- SHA-256: `A89AF044367924C9FAD765FA1A520C0942211F9463A27A205EF82A69F7EECD06`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.16 Running Shove Runtime Failure Analysis

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Runtime Result

- RUNNING_SHOVE_ZERO_ARGUMENT_CALL=FAIL
- RUNNING_SHOVE_ERROR_REPEATED_EVERY_UPDATE=YES
- RUNNING_SHOVE_ERROR_ISOLATION=FAIL
- RUNNING_SHOVE_0_4_16_RESULT=FAIL
- RUNNING_SHOVE_FALSE_SUCCESS_LOG=YES
- BUMPED_STATE_VALID_FOR_ISOZOMBIE=NO
- CURRENT_RUNNING_SHOVE_IMPLEMENTATION_REJECTED=YES

The 0.4.16 console showed `expected 1 argument, got 0` from the dynamic method helper path and then repeated the error across updates.

The 0.4.16 console also showed `java.lang.ClassCastException: zombie.characters.IsoZombie cannot be cast to zombie.characters.IsoPlayer` at `zombie.ai.states.BumpedState.enter(BumpedState.java:48)`.

## 0.4.17 Decision

- RUNNING_SHOVE_STATUS=DISABLED_AFTER_0_4_16_RUNTIME_FAILURE
- RUNNING_SHOVE_UPDATE_REGISTERED=NO
- BUMPED_STATE_PRESENT=NO in active runtime calls
- DYNAMIC_JAVA_METHOD_CALL_PRESENT=NO

`XNP_DR_RunningShove.lua` remains as a disabled status module only. `XNP_DR_Runtime.lua` no longer calls `XNP_DR_RunningShove.Update`.

The only runtime message from this module should be:

`[XNP RUNNING SHOVE] disabled in 0.4.17 after unsafe 0.4.16 result`

```

## 0.4.16_STATUS_ICON_OVERLAP_ANALYSIS.md

- SHA-256: `CABBD4596BD890ABFFF320CC059551F85296C191B4A60A53A28898DF2A6F65C5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.16 Status Icon Overlap Analysis

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Real Game Result

- STATUS_ICON_TEXTURE=PASS
- STATUS_ICON_ROUND_STYLE=PASS
- STATUS_ICON_TOOLTIP=PASS
- STATUS_ICON_LAYOUT=FAIL_OVERLAPS_VANILLA_MOODLE
- STATUS_ICON_CURRENT_POSITION_METHOD=REJECTED

## Root Cause

0.4.16 drew the custom circular F icon at an estimated right-side position. It did not use the local Build 42.19 `MoodlesUI` slot formula and did not use the vanilla visible Moodle count.

When vanilla moodles such as panic, pain, sick, tired, hunger, or other state icons were visible, the custom F used the same visual slot as one vanilla icon.

0.4.16_OVERLAP_ROOT_CAUSE=`custom F position did not mirror MoodlesUI visible slot calculation`

## 0.4.17 Correction

- STATUS_ICON_LAYOUT_METHOD=VANILLA_LAYOUT_COMPANION_SLOT
- VISIBLE_VANILLA_MOODLE_COUNT_METHOD=`player:getMoodles():getMoodleLevel(MoodleType.<type>)`
- NEXT_FREE_SLOT_METHOD=`visible vanilla Moodle count`
- RECTANGLE_OVERLAP_GUARD=YES
- STATUS_ICON_TOOLTIP=`Distance Runner` / `Passive active: unlimited endurance.`

```

## BUILD_MARKER.txt

- SHA-256: `8742E46F66CC9A349860B701CBB4BE05D6B7A92B2CBBCCB7A6AE47461B899801`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0416_PASSIVE_RUNNER_SHOVE_A

```

## CHANGELOG.md

- SHA-256: `836899A5239065308C0CFE07450BC05F2618BA6019A5A7A3842E5FAFFDE395FD`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

## 0.4.16-b42-passive-runner-shove-a

- Accepted 0.4.15 real-game results: Moodle-style F icon PASS, `CharacterStat.ENDURANCE` PASS, Fast Move world movement FAIL.
- Removed failed Fast Move runtime path from active 0.4.16 modules.
- Added persistent passive status icon rule for local target-trait player.
- Added passive endurance module using `player:getStats():set(CharacterStat.ENDURANCE, 1.0)`.
- Added movement state observer using read-only X/Y sampling.
- Added first running shove candidate using local B42 debug evidence: `setBumpType("stagger")`, `BumpFall` variables, and optional `knockDown(false)`.
- Added user test plan for persistent icon, endurance, movement state, and shove behavior.

```

## FINAL_REPORT.md

- SHA-256: `8A6DE8FD5094CB9892BF3E22417A32B6219F6D156ECDEB69B897A4E4DC733ED4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.4.16

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
VERSION=0.4.16
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0416_PASSIVE_RUNNER_SHOVE_A

## Trait

- TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION
- TRAIT_FULL_ID=`XNPDistanceRunnerTrait:XNPDistanceRunner`
- TRAIT_OBJECT_CACHED=YES
- PLAYER_TRAIT_RESULT_CACHED=YES
- Character creation cost=1
- Native trait script=`42\media\scripts\XNPDistanceRunnerTraits.txt`

## Status Icon

- STATUS_ICON_METHOD=MOODLE_STYLE_CUSTOM_SLOT
- STATUS_ICON_DISPLAY_RULE=local target-trait player exists and is alive
- STATUS_ICON_PERSISTENT=YES
- STATUS_ICON_HIDE_RULES=main menu, world exit, invalid player, dead character, missing target trait, texture fatal error
- STATUS_ICON_TOOLTIP=`Distance Runner` / `Passive active: endurance, movement and running shove.`
- STATUS_ICON_FAST_MOVE_DEPENDENCY_REMOVED=YES

## Endurance

- ENDURANCE_METHOD=`player:getStats():set(CharacterStat.ENDURANCE, 1.0)`
- ENDURANCE_TARGET=1.00
- ENDURANCE_INTERVAL=0.20 seconds
- PASSIVE_INFINITE_ENDURANCE=YES
- ENDURANCE_REAL_GAME_BASELINE=0.4.15 PASS

## Movement

- MOVEMENT_ENHANCEMENT_METHOD=NO_SAFE_RUNTIME_MOVEMENT_MODIFIER_FOUND_IN_LOCAL_LUA_AUDIT
- VANILLA_MOVEMENT_REFERENCE=`character_traits.txt` XPBoosts, `XpUpdate.lua` Fitness/Sprinting XP logic
- RUN_SPEED_TARGET_RATIO=1.20
- SPRINT_SPEED_TARGET_RATIO=1.35
- PERMANENT_SKILL_CHANGE=NO
- WORLD_COORDINATE_WRITE=NO
- MOVEMENT_MEASUREMENT_METHOD=read-only X/Y distance sampling
- MOVEMENT_MEASUREMENT_RESULT=REAL_GAME_TEST_REQUIRED_BY_USER

## Running Shove

- RUNNING_SHOVE_METHOD=`zombie:setBumpType("stagger")`, `BumpFall` variables, optional `zombie:knockDown(false)`
- VANILLA_SHOVE_REFERENCE=`DebugContextMenu.lua:665`, `DebugContextMenu.lua:1395-1398`
- JOG_TRIGGER=`JOG_OR_RUN` and TPS >= 2.50
- SPRINT_TRIGGER=`SPRINT` and TPS >= 2.50
- CONTACT_RADIUS=0.85
- FRONT_DOT_MIN=0.20
- PER_ZOMBIE_COOLDOWN=0.75 seconds
- GLOBAL_COOLDOWN=0.25 seconds
- MAX_TARGETS_PER_UPDATE=2
- JOG_KNOCKDOWN_CHANCE=0.15
- SPRINT_KNOCKDOWN_CHANCE=0.35
- ZOMBIE_DAMAGE=NO
- ZOMBIE_COORDINATE_WRITE=NO

## Isolation

- Affects no-trait characters=NO
- Affects other players=NO, local-player-only runtime branch
- Affects vehicles=NO, running shove rejects vehicle/driving state
- Affects game time=NO
- Center text=NO
- Per-frame logs=NO

## Counts And Static Result

- Lua file count=23
- Lua total lines=1670
- Markdown file count=55
- Static check result=PASS_WITH_NOT_VERIFIABLE_LUA_EXECUTION
- NOT_VERIFIABLE: Lua execution check because no `lua` command is installed
- NOT_VERIFIABLE: movement ratio until real-game test
- NOT_VERIFIABLE: running shove visual reaction until real-game test
- MULTIPLAYER_NOT_YET_VALIDATED
- REAL_GAME_TEST_REQUIRED_BY_USER
- Game launched? NO
- Steam launched? NO
- User mods / save / Workshop / game directory writes? NO
- Old SOURCE modified? NO

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.16_SOURCE_READY_FOR_PERSISTENT_ICON_ENDURANCE_MOVEMENT
[EXCERPT_TRUNCATED]
```

## PASSIVE_RUNNER_MOVEMENT_SHOVE_TEST_0.4.16.md

- SHA-256: `536C843400F70EE3C0C9DCD0686F90AA538BFB8554B43130B5BA92606B2C4CCB`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.16 琚姩濂旇涓庤窇鍔ㄦ挒鎺ㄦ祴璇?
## 娴嬭瘯鍓?
1. 鍙惎鐢?`XNP Distance Runner Trait 0.4.16 Passive Runner + Shove`銆?2. 鍒涘缓鎴栬繘鍏ユ嫢鏈?`XNPDistanceRunnerTrait:XNPDistanceRunner` 鐨勮鑹层€?3. 涓嶈鍚屾椂鍚敤鏃х増 XNP Distance Runner銆?
## 鐘舵€佸浘鏍?
杩涘叆涓栫晫鍚庤瀵熷彸涓婅 Moodle 鍒楅檮杩戯細

- 搴旇鎸佺画鏄剧ず鍦嗗舰榛勮壊 F銆?- 涓嶉渶瑕佽窇姝ユ墠鏄剧ず銆?- 涓嶅簲璇ュ嚑绉掑悗鑷姩闅愯棌銆?- 榧犳爣鎮仠搴旀樉绀?`Distance Runner` 鍜岃鍔ㄦ晥鏋滆鏄庛€?
## 鑰愬姏

鏅€氳璧般€佽窇姝ャ€佸啿鍒哄悗瑙傚療鑰愬姏锛?
- 鎺у埗鍙板簲鍙湪杩涘叆涓栫晫鍚庤緭鍑轰竴娆¤鍔ㄥ惎鐢ㄦ棩蹇椼€?- 绗竴娆″疄闄呮仮澶嶈€愬姏鏃惰緭鍑?before/after/confirmed銆?- 涔嬪悗涓嶅簲鍒峰睆銆?
## 绉诲姩鐘舵€?
渚濇娴嬭瘯绔欏畾銆佹櫘閫氳蛋璺€佽窇姝ユ垨鎱㈣窇銆佸啿鍒恒€傛帶鍒跺彴搴斿彧鍦ㄧ姸鎬佸垏鎹㈡椂杈撳嚭 `STOPPED`銆乣WALK`銆乣JOG_OR_RUN`銆乣SPRINT`銆?
0.4.16 涓嶅啓鐜╁鍧愭爣锛屼笉鏀规椂闂达紝涓嶄娇鐢ㄦ棫閫熷害 setter銆傝嫢绉诲姩閫熷害娌℃湁鎻愬崌锛屽睘浜庡綋鍓嶅璁＄粨璁鸿寖鍥村唴锛氭湰鍦?Lua 鏈壘鍒板畨鍏ㄤ复鏃剁Щ鍔ㄤ慨鏀瑰彛銆?
## 璺戝姩鎾炴帹

1. 鎵?1-2 鍙珯绔嬪兊灏搞€?2. 淇濇寔璺戞鎴栧啿鍒猴紝浠庢闈㈤潬杩戙€?3. 涓嶈鏀诲嚮銆佷笉瑕佺瀯鍑嗐€佷笉瑕佽繘杞︺€佷笉瑕佹攢鐖€?4. 瑙傚療鍍靛案鏄惁鍑虹幇 stagger 鎴栧€掑湴鍙嶅簲銆?
棣栨鎴愬姛鏃跺簲杈撳嚭锛?
`[XNP RUNNING SHOVE] success=true mode=<JOG_OR_RUN/SPRINT>`

鑻ュ浘鏍囧拰鑰愬姏姝ｅ父浣嗘挒鎺ㄦ棤鏁堬紝涓嬩竴杞彧璋冩暣 `XNP_DR_RunningShove.lua`锛屼笉瑕佸洖閫€鐘舵€佸浘鏍囨垨鑰愬姏瀹炵幇銆?
```

## README_CN.md

- SHA-256: `32F118AC713ED24109EDAD788070F0EE0C2309BEC5E7857246E431FB43E471C8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.16 Passive Runner + Shove

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨勭嫭绔?0.4.16 娴嬭瘯 SOURCE銆?
鏈増淇濈暀锛?
- Mod ID=`XNP_PZ_DistanceRunnerTrait`
- Trait full ID=`XNPDistanceRunnerTrait:XNPDistanceRunner`
- B42 鍘熺敓 `character_trait_definition`
- 浜虹墿鍒涘缓鎴愭湰 Cost=1
- 榛勮壊 F 鍥炬爣璧勬簮
- 鏈湴鐜╁鍘熺敓鐗硅川妫€娴?
鏈増鏂板鎴栧浐瀹氾細

- 鍙充笂瑙?Moodle 椋庢牸鍦嗗舰 F 鎸佷箙鏄剧ず銆?- 琚姩鑰愬姏缁存寔锛歚player:getStats():set(CharacterStat.ENDURANCE, 1.0)`銆?- 杩愬姩鐘舵€佹娴嬶細STOPPED/WALK/JOG_OR_RUN/SPRINT銆?- 璺戝姩鎾炴帹鍊欓€夋ā鍧楋細鍙綔鐢ㄤ簬姝ｅ墠鏂规帴瑙﹁窛绂诲唴鐨勭珯绔嬪兊灏搞€?
鏈増涓嶅仛锛?
- 涓嶅惎鍔ㄦ父鎴忔垨 Steam銆?- 涓嶅啓鍏ョ敤鎴?mods銆佸瓨妗ｃ€乄orkshop 鎴栨父鎴忕洰褰曘€?- 涓嶅啓鐜╁鎴栧兊灏稿潗鏍囥€?- 涓嶄慨鏀规父鎴忔椂闂淬€?- 涓嶆案涔呬慨鏀?Fitness/Sprinting/XP/瑙掕壊鐗硅川銆?- 涓嶄娇鐢?0.4.15 澶辫触鐨?Fast Move 鏂规硶銆?
```

## B42_19_VANILLA_FITNESS_RUNNING_LOGIC_AUDIT.md

- SHA-256: `F6E752BE3A90B10CFC8856C9396959A7047D515FBF2D39F76435949550CEBE32`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Vanilla Fitness And Running Logic Audit

SEARCH_ROOT=`[LOCAL_PATH_REDACTED]`

## Local Evidence

- `media\scripts\generated\characters\character_traits.txt:66`: Athletic gives `XPBoosts = Fitness=4`.
- `media\scripts\generated\characters\character_traits.txt:370`: Fit gives `XPBoosts = Fitness=2`.
- `media\scripts\generated\characters\character_traits.txt:609`: Runner gives `XPBoosts = Sprinting=1`.
- `media\scripts\generated\characters\character_traits.txt:764,797,809,1000,1012,1024`: negative traits reduce Fitness XP boosts.
- `media\scripts\generated\characters\character_professions.txt:102,122,218`: some professions add Fitness or Sprinting XP boosts.
- `media\lua\server\XpSystem\XpUpdate.lua:14-20`: running or sprinting with endurance above warning grants Fitness/Sprinting XP.
- `media\lua\server\XpSystem\XpUpdate.lua:226-228`: local comments state Fitness can grant traits that help running and recovery.
- `media\lua\shared\defines.lua:6`: sprinting endurance drain is a vanilla global define.

## Result

TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION

Vanilla Athletic, Fit, and Runner are not temporary runtime movement switches. They are character trait and perk/XP systems. Using them for a reversible 0.4.16 movement feature would require permanent skill, XP, or trait mutation, which is forbidden for this test version.

The local Lua audit did not find a safe, temporary, keyed movement modifier comparable to a reversible speed multiplier. The known failed or forbidden movement calls are not used in active 0.4.16 runtime code.

MOVEMENT_ENHANCEMENT_METHOD=NO_SAFE_RUNTIME_MOVEMENT_MODIFIER_FOUND_IN_LOCAL_LUA_AUDIT

## Consequence For 0.4.16

0.4.16 does not write player X/Y/Z, does not change game time, does not change animation speed variables, does not add Fitness/Sprinting XP, does not add or remove Athletic/Fit/Runner, and does not alter save skills. It only observes world displacement for verification and keeps the module isolated from endurance and status icon behavior.

```

## B42_19_VANILLA_SHOVE_LOGIC_AUDIT.md

- SHA-256: `37F1D8F22C390C88CBA357BE21FAFD2EB3CE693B949F3F54A63A54F738DAA0B3`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Vanilla Shove Logic Audit

SEARCH_ROOT=`[LOCAL_PATH_REDACTED]`

## Local Evidence

- `media\lua\client\DebugUIs\DebugContextMenu.lua:665`: debug selected zombie helper calls `zombie:knockDown(hitFromBehind)`.
- `media\lua\client\DebugUIs\DebugContextMenu.lua:1395`: debug stagger loop calls `chr:setBumpType("stagger")`.
- `media\lua\client\DebugUIs\DebugContextMenu.lua:1396-1398`: same loop sets `BumpDone=false`, `BumpFall=true`, and `BumpFallType="pushedFront"`.
- `media\lua\shared\Fishing\FishingRod.lua:286` and `media\lua\client\Foraging\ISBaseIcon.lua:216`: local Lua uses `character:getForwardDirection():getDirection()` for facing-related calculations.

## 0.4.16 Running Shove Candidate

RUNNING_SHOVE_METHOD=`zombie:setBumpType("stagger")` plus `BumpFall` variables; optional `zombie:knockDown(false)` when the method exists and chance roll passes.

The module does not write zombie X/Y/Z and does not damage or kill zombies. It filters to the local target-trait player, requires movement state `JOG_OR_RUN` or `SPRINT`, requires TPS >= 2.50, uses same-level nearby zombies, contact radius 0.85, and a front cone dot product >= 0.20.

The candidate is intentionally conservative:

- JOG_OR_RUN knockdown chance: 15%, strength adjusted.
- SPRINT knockdown chance: 35%, strength adjusted.
- Per-zombie cooldown: 0.75 seconds.
- Global cooldown: 0.25 seconds.
- Max targets per update: 2.

REAL_GAME_TEST_REQUIRED_BY_USER: static audit confirms callable names in local Lua, but the exact visual reaction and balance must be validated in-game.

```

## STATIC_AUDIT.md

- SHA-256: `F3B2D9E867889C32E052ACC293D854D76FF2FEEBD4CB202C75FA3214274B41C8`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.4.16

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`
VERSION=0.4.16
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0416_PASSIVE_RUNNER_SHOVE_A

## Identity

- Mod ID unchanged: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID unchanged: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- TRAIT_DEFINITION_METHOD=B42_SCRIPT_CHARACTER_TRAIT_DEFINITION
- Character creation cost: 1
- Character info panel F icon path unchanged: `media/ui/Traits/trait_xnpdistancerunner.png`
- PLAYER_TRAIT_RESULT_CACHED=YES

## Active Runtime Modules

- TRAIT_MODULE=`XNP_DR_Trait.lua`
- STATUS_ICON_MODULE=`XNP_DR_ActiveStatusIcon.lua`
- ENDURANCE_MODULE=`XNP_DR_InfiniteEndurancePassive.lua`
- MOVEMENT_MODULE=`XNP_DR_MovementPassive.lua`
- RUNNING_SHOVE_MODULE=`XNP_DR_RunningShove.lua`

Old active Fast Move sample logic is not required by `XNP_DR_Bootstrap.lua` or `XNP_DR_Runtime.lua`. The old movement and endurance test files are inert compatibility stubs.

## Status Icon

- STATUS_ICON_METHOD=MOODLE_STYLE_CUSTOM_SLOT
- STATUS_ICON_PERSISTENT=YES
- STATUS_ICON_DISPLAY_RULE=local target-trait player exists and is alive
- STATUS_ICON_HIDE_RULES=main menu, world exit, invalid player, dead character, missing target trait, texture fatal error
- STATUS_ICON_TOOLTIP=`Distance Runner` / `Passive active: endurance, movement and running shove.`
- STATUS_ICON_FAST_MOVE_DEPENDENCY_REMOVED=YES
- Auto 3-second hide=ABSENT
- Center HUD text=ABSENT

## Endurance

- ENDURANCE_METHOD=`player:getStats():set(CharacterStat.ENDURANCE, 1.0)`
- ENDURANCE_TARGET=1.00
- ENDURANCE_INTERVAL=0.20 seconds
- PASSIVE_INFINITE_ENDURANCE=YES
- ENDURANCE_TEST_MODE=NO
- Only target-trait local player affected=YES
- Fatigue/hunger/thirst/calories/pain/stress/panic/injury/encumbrance/game time/fitness/sprinting writes=ABSENT

## Movement

- MOVEMENT_ENHANCEMENT_METHOD=NO_SAFE_RUNTIME_MOVEMENT_MODIFIER_FOUND_IN_LOCAL_LUA_AUDIT
- MOVEMENT_MEASUREMENT_METHOD=read-only world X/Y sampling every 0.20 seconds
- MOVEMENT_MEASUREMENT_RESULT=REAL_GAME_TEST_REQUIRED_BY_USER
- `setFastMoveCheat`=ABSENT from active Lua
- `setSpeedMod`=ABSENT from active Lua
- `setMoveSpeed`=ABSENT from active Lua
- `setPathSpeed`=ABSENT from active Lua
- `setCombatSpeed`=ABSENT from active Lua
- `setVariable("WalkSpeed")`=ABSENT from active Lua
- Player coordinate writes=ABSENT
- Game time writes=ABSENT
- Permanent Fitness/Sprinting/XP changes=ABSENT

## Running Shove

- RUNNING_SHOVE_METHOD=`zombie:setBumpType("stagger")`, `BumpFall` variables, optional `zombie:knockDown(false)`
- VANILLA_SHOVE_REFERENCE=`DebugContextMenu.lua:665`, `DebugContextMenu.lua:1395-1398`
- JOG_TRIGGER=movement state `JOG_OR_RUN`, TPS >= 2.50
- SPRINT_TRIGGER=movement state `SPRINT`, TPS >= 2.50
- CONTACT_RADIUS=0.85
- FRONT_DOT_MIN=0.20
- PER_ZOMBIE_COOLDOWN=0.75 seconds
- GLOBAL_COOLDOWN=0.25 seconds
- MAX_TARGETS_PER_UPDATE=2
- JOG_KNOCKDOWN_CHANCE=0.15 before Strength multiplier
- SPRINT_KNOCKDOWN_CHANCE=0.35 before Strength m
[EXCERPT_TRUNCATED]
```
