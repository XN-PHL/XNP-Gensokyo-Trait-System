# 0.4.12 Sanitized Evidence Excerpts

## 0.4.12_UI_RUNTIME_FAILURE_ANALYSIS.md

- SHA-256: `B91B377F7CDE074DFE455B8985C391518E16113C88A5277BA53F4C8336EF96F7`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.12 UI Runtime Failure Analysis

## Frozen Result

- TRAIT_DEFINITION=PASS
- TRAIT_RUNTIME_BIND=PASS
- NATIVE_CHARACTER_PANEL_F=PASS
- F_TEXTURE_RESOLUTION=PASS
- 0.4.12_ICON_RENDER_TEST_COMPLETED=NO
- 0.4.12_MOVEMENT_TEST_STARTED=NO
- 0.4.12_SPEED_BACKEND_WRITTEN=NO
- 0.4.12_RESULT=INVALID_DUE_TO_UI_RUNTIME_ERRORS

## Runtime Errors

1. `attempted index: getX of non-table: [Lzombie.ui.MoodlesUI;`
   - Root cause: `UIManager.MoodleUI` is a Java array of `zombie.ui.MoodlesUI`, not a single Moodle instance.
   - 0.4.12 incorrectly treated the array as the instance and attempted instance coordinate calls.

2. `expected argument of type UIElement, got KahluaTableImpl`
   - Root cause: a Lua `ISUIElement` table was passed into Java MoodlesUI nesting/child APIs.
   - This invalidates the Java parent/child binding route for this diagnostic branch.

3. `__sub not defined for operands in Update`
   - Root cause: coordinate arithmetic received a non-Lua-number operand, most likely Java userdata or nil.
   - 0.4.13 now gates all target coordinate arithmetic through safe numeric conversion.

## 0.4.13 Fix

- BACKEND_A_MOODLESUI_NEST=DISABLED
- BACKEND_B_MOODLESUI_CHILD=DISABLED
- BACKEND_E_TOP_LEVEL_ISUI_SCREEN_SPACE=ENABLED
- `MoodlesUI:Nest`, `MoodlesUI:AddChild`, and `MoodlesUI:setParent` are not used.
- `UIManager.MoodleUI` is treated as an array and only indexed inside `pcall`; no instance method is called on the array object.
- The yellow F is drawn by a standalone top-level `ISUIElement`, positioned by safe screen-space coordinates.
- Disabled-state render spam is removed.
- Center text flicker is replaced by a stable, timed `SPEED BACKEND NOT READY` notice.

```

## B42_PLAYER_SPEED_WORKING_SAMPLE_MATRIX.md

- SHA-256: `7A0E4E93AB67C74EE2071FC374AB6FF839DBA3E5609C800D29ECCF5344319B91`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42 Player Speed Working Sample Matrix

Searched roots:

- [LOCAL_PATH_REDACTED]
- [LOCAL_PATH_REDACTED]

Search terms included B42 markers and movement APIs: `setMoveDelta`, `getMoveDelta`, `getGlobalMovementMod`, `setSpeedMod`, `getSpeedMod`, `setMoveSpeed`, `getMoveSpeed`, `setPathSpeed`, `getPathSpeed`, `moveUnmodded`, `setMomentumScalar`, `setMoveForwardVec`, run/walk speed modifiers.

## Candidate Samples

| Path | Mod ID | B42 evidence | Method/field | Timing | Restore | Coordinate write | Accepted |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `[LOCAL_PATH_REDACTED]` | More Traits | folder `42.17`; comments mention Build 42.13/42.17 | `player:moveUnmodded(x, y)` | player update / movement debug area | not a keyed restorable modifier | yes, next movement/position delta | NO |

Reason for rejection: `moveUnmodded(x,y)` directly adds movement/next-position delta. It is not a safe local-player-only multiplier, can interact with collision and network behavior, and fails the rule forbidding coordinate/teleport-like movement writes.

Other B42 hits were firearms, maps, translations, crafting, journal, and utility mods, not confirmed player world displacement speed backends.

CONFIRMED_B42_PLAYER_SPEED_SAMPLE_COUNT=0
SELECTED_NEW_BACKEND=NONE
BLOCKER_B42_REAL_PLAYER_SPEED_BACKEND_NOT_FOUND

```

## BUILD_MARKER.txt

- SHA-256: `8E2A5E7BA42E28FFBD309DD1CF92E666F97FE14E2EF114331AE36760369A68D0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0412_MOODLE_ANCHOR_PIPELINE_A

```

## ENGLISH_CONTINUOUS_TOGGLE_AND_MOODLE_F_TEST_0.4.12.md

- SHA-256: `0113ECBF9127B8F45B07C2EBFDB945EB8732105D61B76107B5E1EA4AC2EF49C7`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# English Continuous Toggle And Moodle F Test 0.4.12

This 0.4.12 build is not a gameplay build.

## Setup

1. Disable 0.4.11 and all older XNP Distance Runner versions.
2. Enable only 0.4.12.
3. Temporarily disable CheatPanel, trainers, player-speed mods, endurance mods, and animation mods.
4. B42Trans_CN may stay enabled.
5. Fully restart the game.
6. Load a character that already has the Distance Runner trait.

## Icon Test

For the first 5 seconds, only check the F position.

Expected HUD:

```text
ICON TEST
F SHOULD BE NEXT TO MOODLES
```

Expected result:

- F appears next to the right-side vanilla Moodle column.
- F is not in the top-left area.
- F does not cover vanilla Moodle icons.
- Console logs include `first_render=true` and render coordinates.
- After 5 seconds, F hides.

If the HUD says:

```text
ICON TEST FAILED
MOODLES UI NOT FOUND
```

then the Moodle object was not resolved and this build must not guess from screen width.

## Movement Backend Status

0.4.12 has no proven safe player movement backend. The expected HUD after icon test is:

```text
NO SAFE SPEED BACKEND
CHECK FINAL_REPORT
```

The continuous same-input speed test is intentionally not enabled until a safe backend is proven.

```

## ENGLISH_CONTINUOUS_TOGGLE_AND_MOODLE_F_TEST_0.4.12.md

- SHA-256: `FA0F984890E3435DDC09BE831CDAAB80A5FCBA4282B39EBA56819EF26541CE53`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# English Continuous Toggle And Moodle F Test 0.4.12

This 0.4.12 build is not a gameplay build.

## Setup

1. Disable 0.4.11 and all older XNP Distance Runner versions.
2. Enable only 0.4.12.
3. Temporarily disable CheatPanel, trainers, player-speed mods, endurance mods, and animation mods.
4. B42Trans_CN may stay enabled.
5. Fully restart the game.
6. Load a character that already has the Distance Runner trait.

## Icon Test

For the first 5 seconds, only check the F position.

Expected HUD:

```text
ICON TEST
F SHOULD BE NEXT TO MOODLES
```

Expected result:

- F appears next to the right-side vanilla Moodle column.
- F is not in the top-left area.
- F does not cover vanilla Moodle icons.
- Console logs include `first_render=true` and render coordinates.
- After 5 seconds, F hides.

If the HUD says:

```text
ICON TEST FAILED
MOODLES UI NOT FOUND
```

then the Moodle object was not resolved and this build must not guess from screen width.

## Movement Backend Status

0.4.12 has no proven safe player movement backend. The expected HUD after icon test is:

```text
NO SAFE SPEED BACKEND
CHECK FINAL_REPORT
```

The continuous same-input speed test is intentionally not enabled until a safe backend is proven.

```

## FINAL_REPORT.md

- SHA-256: `DF19001DA229441501BACAC852DF3DE85365876E59312D368E0284C7CE87DF07`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL_REPORT

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.4.12
INTERNAL_VERSION=0.4.12-b42-moodle-anchor-movement-pipeline-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0412_MOODLE_ANCHOR_PIPELINE_A
DISPLAY_NAME=XNP Distance Runner Trait 0.4.12 Moodle Anchor + Movement Pipeline

## 0.4.11 Corrections

0.4.11_SPEEDMOD_WRITE_RESULT=PASS
0.4.11_SPEEDMOD_USER_VISUAL_RESULT=FAIL
0.4.11_WORLD_RATIO_VALIDITY=NO
SPEED_MOD_FINAL_STATUS=REJECTED_WRITABLE_BUT_NO_USER_VISIBLE_WORLD_EFFECT
0.4.11_F_SELF_TEST_RESULT=PASS
0.4.11_F_POSITION_RESULT=FAIL
0.4.11_F_X10_VISIBILITY_RESULT=FAIL

## Active F

ACTIVE_F_ANCHOR_BACKEND=BACKEND_B_MOODLESUI_CHILD_WITH_BACKEND_C_FALLBACK
MOODLES_UI_OBJECT_RESOLVED=YES_RUNTIME_REQUIRED
MOODLES_UI_ABSOLUTE_POSITION_AVAILABLE=YES_STATIC_API_CONFIRMED
F_RENDER_COUNTER_IMPLEMENTED=YES
F_VISIBLE_WITHOUT_RENDER_DETECTION=YES
RUNTIME_HUD_LANGUAGE=ASCII_ENGLISH_ONLY

## Audit Scope

OFFICIAL_JAVADOC_CHECK_SCOPE=UIElement, UIManager, MoodlesUI, IsoPlayer, IsoGameCharacter
LOCAL_DECOMPILE_CHECK_SCOPE=projectzomboid.jar javap for MoodlesUI, UIManager, UIElement, IsoPlayer, IsoGameCharacter, IsoMovingObject, PlayerMovementState, ActionContext, AdvancedAnimator, NetworkCharacterAI
B42_SUCCESS_MOD_SAMPLE_COUNT=0
B42_SUCCESS_SAMPLE_SCAN=NO_ACCEPTED_SAMPLE

## Movement Pipeline

FINAL_PLAYER_MOVEMENT_CALCULATION=ENGINE_INTERNAL_INPUT_TO_MOVEMENT_VARS_TO_DEFERRED_OR_REQUESTED_MOVEMENT_TO_COLLISION_TO_NEXT_POSITION
SELECTED_NEW_BACKEND=NONE
SELECTED_NEW_BACKEND_EVIDENCE=NO_CANDIDATE_MET_ALL_SAFETY_RULES
SELECTED_NEW_BACKEND_RESET=NOT_APPLICABLE
CONTINUOUS_INPUT_TEST_IMPLEMENTED=NO_BACKEND_FOUND_SO_BLOCKED
ACTIVE_RATIO_THRESHOLD=1.50
RESTORE_RATIO_THRESHOLD=0.85_TO_1.15

## Safety

Writes speed_mod? NO
Writes coordinates? NO
Modifies time? NO
Affects no-trait character? NO
Native trait chain modified? NO
Character panel icon modified? NO
Project Zomboid started? NO
Steam started? NO
Old SOURCE modified? NO
Game directory written? NO
User mods/saves/Workshop written? NO

## Counts

Lua file count=20
Lua total lines=2034
Document/info file count=43

## Static Checks

STATIC_CHECK_RESULT=PASS_WITH_MOVEMENT_BACKEND_BLOCKED
Old fixed screen-width anchor only=ABSENT
x=1856 hardcode=ABSENT
MoodlesUI real object query=YES
Moodle absolute coordinate logging=YES
F render_call_count=YES
visible_without_render detection=YES
Runtime Chinese HUD=ABSENT
speed_mod write=ABSENT
getMoveSpeed/setMoveSpeed=ABSENT
coordinate write=ABSENT
teleport=ABSENT
game time modification=ABSENT
random candidate write=ABSENT

## NOT_VERIFIABLE

- Live game rendering of the Moodle-anchored F icon.
- Whether Lua can access MoodlesUI.getInstance() exactly as the Java class exposes it.
- Whether child attachment or absolute fallback is the live best backend; runtime logs decide.
- Lua interpreter execution, because no local Lua runtime was used.
- Any new movement speed backend, because none was selected.

## BLOCKER

BLOCKER=BLOCKER_B42_REAL_P
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `11751BA48D3B221248799183F8D288806B0970699AF8150311138F1E2283344C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.12 Moodle Anchor + Movement Pipeline

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

This is a Project Zomboid Build 42.19.0 diagnostic branch.

## Frozen 0.4.11 Conclusions

- speed_mod write/readback succeeded.
- User-visible 10x movement effect failed.
- speed_mod is rejected as a production movement backend.
- The old F self-test rendered, but the anchor method was wrong.

## 0.4.12 Scope

- Keep native B42 trait pipeline unchanged.
- Runtime HUD is ASCII English only.
- Resolve real MoodlesUI and anchor F next to it.
- Count actual F render calls.
- Do not write speed_mod.
- Do not implement random movement candidates.
- Block movement testing until a safe B42 local-player movement backend is proven.

## Runtime HUD

Allowed runtime HUD text is short ASCII English only, such as:

```text
ICON TEST
F SHOULD BE NEXT TO MOODLES
```

or:

```text
NO SAFE SPEED BACKEND
CHECK FINAL_REPORT
```

```

## B42_19_FINAL_PLAYER_MOVEMENT_PIPELINE_AUDIT.md

- SHA-256: `65947BB1EB3D44F3CE61B49DE6C19D4B047D52CDD9D9B938A03A8E292D015042`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Final Player Movement Pipeline Audit

DST_INSTALL_ROOT is not relevant. This audit used Project Zomboid local files only.

PZ_INSTALL_ROOT=[LOCAL_PATH_REDACTED]
LOCAL_JAR=[LOCAL_PATH_REDACTED]

Official JavaDoc checked:

- https://projectzomboid.com/modding/zombie/ui/UIElement.html
- https://projectzomboid.com/modding/zombie/ui/UIManager.html
- https://projectzomboid.com/modding/zombie/characters/IsoGameCharacter.html
- https://projectzomboid.com/modding/zombie/characters/IsoPlayer.html

Local B42.19 evidence from `javap`:

- `zombie.ui.MoodlesUI.getInstance()` exists.
- `zombie.ui.UIManager.MoodleUI[]` and `UIManager.getMoodleUI(double)` exist.
- `zombie.ui.UIElement.AddChild(UIElement)`, `setParent(UIElement)`, `getAbsoluteX()`, `getAbsoluteY()`, `setConsumeMouseEvents(boolean)`, `setAlwaysOnTop(boolean)`, and `setRenderThisPlayerOnly(int)` exist.
- `MoodlesUI.Nest(...)` was not found in the local B42.19 class signature.
- `IsoPlayer.updateMovementFromInput(MoveVars)` reads input via `getInputMoveVector`, updates `playerMoveDir`, and prepares movement vars.
- `PlayerMovementState` records `run` and `sprint` params from `isRunning()` and `isSprinting()`.
- `IsoPlayer.getPathSpeed()` derives from `getMoveSpeed()` with endurance/load modifiers, but no safe persistent Lua setter was proven for final local displacement.
- `IsoGameCharacter.setSpeedMod(float)` only writes field `speedMod`; 0.4.11 proved writable/readback but no user-visible 10x movement effect.
- `IsoGameCharacter.setMoveDelta(float)` only writes field `moveDelta`; the local code shows movement rates are recalculated by engine code, so same-frame overwrite risk is high.
- `IsoMovingObject.moveUnmoddedInternal(float,float)` adds to next X/Y and records `reqMovement`; this is a direct movement vector/next-position write, rejected by 0.4.12 safety rules.

Pipeline answer:

- INPUT_STAGE=IsoPlayer.updateMovementFromInput reads input vectors and writes movement vars / playerMoveDir.
- MOVEMENT_MODE_STAGE=PlayerMovementState stores run/sprint params from local character state.
- SPEED_CALC_STAGE=IsoGameCharacter movement-rate methods and IsoPlayer path/getMoveSpeed logic combine endurance/load/clothing/traits.
- GLOBAL_MODIFIER_STAGE=getGlobalMovementMod participates as environmental/current-square modifiers, not as a safe standalone Lua multiplier.
- COLLISION_STAGE=IsoMovingObject next-position/requested movement passes through collision and square update logic.
- FINAL_POSITION_STAGE=IsoMovingObject next X/Y and current square update after movement/collision.
- FIRST_LUA_WRITABLE_STAGE=No safe pre-collision local-player-only multiplier was proven.
- SELECTED_CANDIDATE=NONE
- SELECTED_CANDIDATE_EVIDENCE=No candidate satisfied all safety criteria.
- RESET_METHOD=No backend implemented; no movement value is written.
- ENGINE_OVERWRITE_BEHAVIOR=setMoveDelta/move vars are likely derived/recalculated by engine update; moveUnmodded writes next movement directly.

Required questions:


[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `CFF7B93D5DDFD57A315ABEC7B67E844DF667A49A60F8753E1F31A5729C56B8DA`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC_AUDIT

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.4.12
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0412_MOODLE_ANCHOR_PIPELINE_A

## Active Lua Checks

| Check | Result |
| --- | --- |
| Old fixed screen-width anchor only | ABSENT |
| Hardcoded x=1856 | ABSENT |
| MoodlesUI real object query | YES |
| Moodle absolute coordinate logging | YES |
| F actual render_call_count | YES |
| visible_without_render detection | YES |
| F mouse blocking | NO, setConsumeMouseEvents(false) used when available |
| Runtime Chinese HUD | ABSENT |
| speed_mod write | ABSENT |
| speed_mod official backend | REJECTED |
| getMoveSpeed/setMoveSpeed active Lua | ABSENT |
| coordinate write active Lua | ABSENT |
| teleport active Lua | ABSENT |
| game-time modification active Lua | ABSENT |
| random candidate write | ABSENT |
| continuous input test | NO_BACKEND_FOUND_SO_BLOCKED |
| no-trait character runs backend | NO |
| cleanup hides F | YES |

## Counts

Lua files=20
Lua total lines=2034
Document/info files=43

## Syntax Risk

Lua interpreter execution=NOT_VERIFIABLE, no reliable local Lua runtime was used.
Bracket and text scan=PASS_STATIC
JSON parse=PASS

## Static Result

STATIC_CHECK_RESULT=PASS_WITH_MOVEMENT_BACKEND_BLOCKED
BLOCKER=BLOCKER_B42_REAL_PLAYER_SPEED_BACKEND_NOT_FOUND

```
