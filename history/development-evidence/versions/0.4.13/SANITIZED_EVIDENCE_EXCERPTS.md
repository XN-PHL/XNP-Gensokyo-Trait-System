# 0.4.13 Sanitized Evidence Excerpts

## 0.4.13_RUNTIME_FAILURE_ANALYSIS.md

- SHA-256: `3C9F550EA645CB688224D1E8253695E1A52552124F3D39BFFE1FFE861EA48D49`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.13 Runtime Failure Analysis

## Accepted 0.4.13 Results

- NATIVE_TRAIT_REGISTRATION=PASS
- PLAYER_TRAIT_COLLECTION=PASS
- CHARACTER_INFO_PANEL_F=PASS
- F_TEXTURE_RESOLUTION=PASS
- RIGHT_STATUS_F_DRAW=FAIL
- INFINITE_ENDURANCE=FAIL
- MOVEMENT_SPEED_CHANGE=NOT_IMPLEMENTED
- SELECTED_NEW_SPEED_BACKEND=NONE
- MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

## Right Status F Failure

Observed errors:

- `attempted index: size of non-table: [Lzombie.ui.MoodlesUI;`
- `attempted index: 0.0 of non-table: [Lzombie.ui.MoodlesUI;`
- `Object tried to call nil in new`
- Final log: `[XNP DistanceRunner] icon fatal error= java.lang.RuntimeException`

Root cause:

- 0.4.13 still touched the Java Moodles UI array and attempted array-style or method-style access that B42.19 runtime rejected.
- The panel construction path also used a constructor route that was not copied from a confirmed local B42 working sample.

0.4.14 correction:

- Active Lua contains no `UIManager.MoodleUI` string.
- Active Lua contains no `MoodlesUI` string.
- RIGHT_STATUS_F_DRAW_METHOD=TOP_LEVEL_FULLSCREEN_TRANSPARENT_ISPANEL
- F position is calculated from the game viewport panel width, not from Moodles UI.

## Infinite Endurance Failure

Observed error:

- `Object tried to call nil in pcall`

Root cause:

- 0.4.13 wrapped or reached a nil/unbound Java method path during endurance restoration.
- Repeated Update calls continued after the first failure and produced repeated errors.

0.4.14 correction:

- ENDURANCE_MODIFICATION_METHOD=player:getStats():setEndurance(1.0)
- The code first obtains `local stats = player:getStats()`.
- The code verifies `stats`, `stats:getEndurance`, and `stats:setEndurance`.
- The only protected call wraps a complete Lua closure.
- On first fatal failure, the endurance module sets `disabled=true`; later Update calls immediately return.

## Movement Speed

0.4.13 did not implement movement speed modification. 0.4.14 continues this rule:

- MOVEMENT_SPEED_MODIFICATION_METHOD=NONE
- No speed method is called.
- No coordinate method is called.
- No time-speed method is called.

```

## B42_19_NATIVE_DEBUG_FAST_MOVE_PIPELINE.md

- SHA-256: `8932342219CF2D907379B72C75B2ED0765EBA9D16912936054EE64E0FCE6BDDE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Native Debug Fast Move Pipeline

## Local Evidence

- Source root searched: `[LOCAL_PATH_REDACTED]`
- `client\ISUI\AdminPanel\ISAdminPowerUI.lua`
  - `ISAdminPowerUI.AddOption("FastMove", "left", Capability.UseFastMoveCheat, ...)`
  - FastMove write path: `self.player:setFastMoveCheat(selected);`
  - FastMove readback path: `ISFastTeleportMove.cheat = getPlayer():isFastMoveCheat();`
  - Persistence helper: `CheatPanel.ini`
- `client\DebugUIs\ISFastTeleportMove.lua`
  - Maintains `ISFastTeleportMove.cheat`
  - Handles key-based fast teleport movement.
  - Uses coordinate/Z mutation style debug movement, including `player:setZ(...)` and `player:setLastZ(...)`.
- Translation evidence:
  - `IGUI_CheatPanel_FastMove`
  - `IGUI_CapabilitiesTooltips_UseFastMoveCheat`

## Answers

1. Does B42.19 have player fast movement debug feature?
   - YES. Native debug/admin FastMove exists.

2. Real switch name?
   - Admin UI option: `FastMove`
   - Capability: `Capability.UseFastMoveCheat`
   - Player API bridge: `player:setFastMoveCheat(boolean)` / `player:isFastMoveCheat()`

3. Works only under `-debug`?
   - It is exposed through debug/admin UI. Static audit shows capability gating. Exact standalone non-debug availability is NOT_VERIFIABLE_BY_STATIC_AUDIT.

4. Affects local player?
   - YES for the current admin/debug player route.

5. Affects all players?
   - NO evidence of global all-player effect in the audited Lua path. Multiplayer safety remains NOT_VERIFIABLE_BY_STATIC_AUDIT.

6. Keeps collision?
   - NOT_VERIFIABLE_BY_STATIC_AUDIT. `ISFastTeleportMove` indicates teleport-style movement, not a normal collision-preserving locomotion multiplier.

7. Fakes via time speed?
   - NO evidence that this route changes world time speed.

8. Modifies X/Y?
   - The debug fast teleport file uses coordinate/Z mutation style movement. This is unsuitable for the trait speed backend.

9. Callable from normal Lua?
   - The method name is visible from Lua, but correct permission behavior outside debug/admin capability is NOT_VERIFIABLE_BY_STATIC_AUDIT.

10. Safely reset?
   - `player:setFastMoveCheat(false)` appears to be the reset route for the cheat flag, but key movement side effects and capability behavior require real-game validation.

11. Suitable experimental backend?
   - LIMITED_DIAGNOSTIC_ONLY. It is useful evidence, not selected as the 0.4.13 backend.

12. Suitable production backend?
   - NO. It is a cheat/admin/debug feature, not a target-trait isolated production movement multiplier.

## Decision

- NATIVE_DEBUG_FAST_MOVE_FOUND=YES
- NATIVE_DEBUG_FAST_MOVE_ENTRY=player:setFastMoveCheat(boolean)
- NATIVE_DEBUG_FAST_MOVE_REQUIRES_DEBUG=YES_OR_ADMIN_CAPABILITY
- SELECTED_NEW_SPEED_BACKEND=NONE
- FAST_MOVE_SELECTED_AS_PRODUCTION_BACKEND=NO

```

## B42_19_PLAYER_MOVEMENT_EVIDENCE_MATRIX_0.4.13.md

- SHA-256: `421FBB27FA14A9499CBEB35EA2B1BEC2D1FEAE89EBDAA2F5185E0E74E0673BCF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Player Movement Evidence Matrix 0.4.13

| Candidate | Evidence | World movement effect | Safety | 0.4.13 decision |
|---|---|---:|---|---|
| `player:setSpeedMod(value)` | Earlier branches could write/read field, but 0.4.8 movement-mode consistency failed | UNPROVEN | Writable field did not prove visible movement speed | DISABLED |
| `getMoveSpeed/setMoveSpeed` | Previous static/runtime attempts rejected | NOT_CONFIRMED | Not selected | DISABLED |
| `path_speed` | Previous candidate scan only | NOT_CONFIRMED | Not selected | DISABLED |
| `combat_speed` | Previous candidate scan only | NOT_CONFIRMED | Not selected | DISABLED |
| animation WalkSpeed variable | Can fake animation state, not proven real movement | NOT_CONFIRMED | Could desync animation from locomotion | DISABLED |
| coordinate displacement | Would move X/Y directly | ARTIFICIAL | Violates no-coordinate-modification rule | DISABLED |
| time speed | Would affect world time | GLOBAL_SIDE_EFFECT | Violates no-time-speed rule | DISABLED |
| native FastMove cheat | `ISAdminPowerUI.lua`, `ISFastTeleportMove.lua` | DEBUG_TELEPORT_STYLE | Debug/admin capability, not trait-isolated | AUDITED_ONLY |

## Frozen Movement Decision

- SELECTED_NEW_SPEED_BACKEND=NONE
- SPEED_BACKEND_STATUS=BLOCKED_B42_REAL_PLAYER_SPEED_BACKEND_NOT_FOUND
- FORMAL_DISTANCE_RUNNER_GAMEPLAY_ENABLED=NO
- OTHER_BACKEND_SEARCH_THIS_BRANCH=NO

## Why FastMove Is Not Selected

FastMove is real in B42.19, but the audited Lua path is an admin/debug cheat path. It is not a clean trait-owned movement multiplier, and the debug teleport helper indicates non-normal movement semantics. This branch records the evidence and keeps the actual movement backend blocked.

```

## B42_PLAYER_SPEED_WORKING_SAMPLE_MATRIX.md

- SHA-256: `5AC7BFD755ADA4130BE6016E44B4ABCE2400D8A444A1697DEAA060F9E4F046DF`
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

- SHA-256: `53E9BB87B6039AE5D64F5255024793899EB1A9942805D161FB1E6B0188839907`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0413_RIGHT_STATUS_STAMINA_FASTMOVE_A

```

## FINAL_REPORT.md

- SHA-256: `93372FA7B8E2FC118629C8A06A9E68F26D1E63A69CEE2327A8349ED4C75A2DA9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.4.13

## Identity

- SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
- VERSION=0.4.13
- INTERNAL_VERSION=0.4.13-b42-right-status-stamina-fastmove-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0413_RIGHT_STATUS_STAMINA_FASTMOVE_A
- Display name: `XNP Distance Runner Trait 0.4.13 Right Status F + Infinite Stamina Test`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## Frozen 0.4.12 Result

- TRAIT_DEFINITION=PASS
- TRAIT_RUNTIME_BIND=PASS
- NATIVE_CHARACTER_PANEL_F=PASS
- F_TEXTURE_RESOLUTION=PASS
- 0.4.12_ICON_RENDER_TEST_COMPLETED=NO
- 0.4.12_MOVEMENT_TEST_STARTED=NO
- 0.4.12_SPEED_BACKEND_WRITTEN=NO
- 0.4.12_RESULT=INVALID_DUE_TO_UI_RUNTIME_ERRORS

## 0.4.13 Changes

- Runtime F icon moved to a standalone top-level `ISUIElement` screen-space backend.
- Java MoodlesUI parent/child binding routes are disabled.
- Disabled-state log spam is fixed.
- Center text flicker is fixed.
- Infinite endurance test module was added.
- Movement backend remains blocked; no speed backend writes are performed.
- Native Debug/Admin FastMove was audited and rejected as a production backend.

## Runtime Modules

- STATUS_ICON_MODULE=`XNP_DR_ActiveStatusIcon.lua`
- ENDURANCE_MODULE=`XNP_DR_InfiniteEnduranceTest.lua`
- MOVEMENT_BACKEND_MODULE=`XNP_DR_DirectSpeedBackendHarness.lua`
- HUD_MODULE=`XNP_DR_HUD.lua`

## Right Status F

- TARGET_REGION=RIGHT_SIDE_STATUS_ICON_COLUMN
- Render backend: BACKEND_E_TOP_LEVEL_ISUI_SCREEN_SPACE
- Top-level panel creation: one-time
- Mouse interception: disabled when API exists
- MoodlesUI array handling: safe indexed evidence only
- F self-test: 5 seconds on target trait character
- Active-speed F after self-test: not enabled because speed backend is blocked

## Infinite Endurance

- INFINITE_ENDURANCE_TEST_MODE=YES
- TEST_ONLY_INFINITE_ENDURANCE=YES
- PRODUCTION_INFINITE_ENDURANCE=NO
- ENDURANCE_TARGET=1.00
- ENDURANCE_MINIMUM=0.99
- Update interval: 0.15 seconds
- Trait-gated: YES
- Affects no-trait characters: NO
- Modifies fatigue/hunger/thirst/calories/pain/injury/encumbrance/time: NO

## Movement Backend

- SELECTED_NEW_SPEED_BACKEND=NONE
- SPEED_BACKEND_STATUS=BLOCKED_B42_REAL_PLAYER_SPEED_BACKEND_NOT_FOUND
- NATIVE_DEBUG_FAST_MOVE_FOUND=YES
- NATIVE_DEBUG_FAST_MOVE_ENTRY=player:setFastMoveCheat(boolean)
- NATIVE_DEBUG_FAST_MOVE_REQUIRES_DEBUG=YES_OR_ADMIN_CAPABILITY
- FAST_MOVE_SELECTED_AS_BACKEND=NO
- FORMAL_DISTANCE_RUNNER_GAMEPLAY_ENABLED=NO

## Safety

- Modifies player X/Y coordinates: NO
- Modifies time speed: NO
- Writes user mods directory: NO
- Writes saves: NO
- Writes Workshop: NO
- Writes game install directory: NO
- Launches game: NO
- Launches Steam: NO
- Modifies 0.4.12 old SOURCE: NO

## Counts

- Lua file count: 20
- Lua total lines: 1655
- Root Markdown docs: 43

## Static Check

- Static audit result: PASS_WITH_SPEED_BACKEND_BLOCKED
- Lua execution parser: NOT_VERIFIABLE
- In-game UI placement: REAL_GAME_TEST_REQUIRED_BY_USER
- Multiplayer status: MU
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `6AF01B8C79CDBECBE5A4DA03F7DCEB4AD600F3FD45E65B16123F6E1AA5B166C1`
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

## RIGHT_STATUS_F_INFINITE_ENDURANCE_TEST_0.4.13.md

- SHA-256: `D1D276BD1CC65CBC4BF3873ABFE343BB610EA5B9D48DFE93AF462618108E1632`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Right Status F + Infinite Endurance Test 0.4.13

## Identity

- VERSION=0.4.13
- INTERNAL_VERSION=0.4.13-b42-right-status-stamina-fastmove-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0413_RIGHT_STATUS_STAMINA_FASTMOVE_A
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

## Runtime Status F

- TARGET_REGION=RIGHT_SIDE_STATUS_ICON_COLUMN
- CHARACTER_PANEL_NATIVE_F=UNCHANGED
- RUNTIME_RIGHT_STATUS_F=TEST_ONLY
- BACKEND_A_MOODLESUI_NEST=DISABLED
- BACKEND_B_MOODLESUI_CHILD=DISABLED
- BACKEND_E_TOP_LEVEL_ISUI_SCREEN_SPACE=ENABLED
- Java MoodlesUI parent/child APIs are not used.
- The F icon is a single top-level `ISUIElement` and draws the yellow F texture only when active.
- The initial self-test shows the icon for 5 seconds, then hides it.
- Because no real speed backend is selected, the active-speed F does not remain visible after the self-test.

## Infinite Endurance Test

- INFINITE_ENDURANCE_TEST_MODE=YES
- TEST_ONLY_INFINITE_ENDURANCE=YES
- PRODUCTION_INFINITE_ENDURANCE=NO
- ENDURANCE_TARGET=1.00
- ENDURANCE_MINIMUM=0.99
- UPDATE_INTERVAL=0.15s
- Only players with `XNPDistanceRunnerTrait:XNPDistanceRunner` are affected.
- The module uses `player:getStats():getEndurance()` and `stats:setEndurance(1.00)`.
- It does not modify fatigue, hunger, thirst, calories, pain, injuries, encumbrance, time, coordinates, or animation variables.

## Movement Backend

- SELECTED_NEW_SPEED_BACKEND=NONE
- SPEED_BACKEND_STATUS=BLOCKED_B42_REAL_PLAYER_SPEED_BACKEND_NOT_FOUND
- NATIVE_DEBUG_FAST_MOVE_FOUND=YES
- FAST_MOVE_SELECTED_AS_BACKEND=NO
- FORMAL_DISTANCE_RUNNER_GAMEPLAY_ENABLED=NO

## Expected In-Game Flow

1. Select/create a character with the native `XNPDistanceRunnerTrait:XNPDistanceRunner` trait.
2. On entering the game, the native character panel F should remain unchanged.
3. The right-side runtime F should appear for the 5-second icon self-test, near the right status icon column.
4. The center HUD should show stable `ICON TEST`.
5. After the self-test, the F hides.
6. If the movement backend is still blocked, the HUD may show stable `SPEED BACKEND NOT READY` for up to 5 seconds, then remain hidden.
7. Endurance should be restored toward 1.00 for the target trait character only.

```

## B42_19_FINAL_PLAYER_MOVEMENT_PIPELINE_AUDIT.md

- SHA-256: `9DD14D3DF5489C64DDB388D4B9D6BA2C362567B743C84161F70A11BC2B683F63`
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

- SHA-256: `7AB271378229614BC084D648202DD65A18A1502C46FC5331FB5DDDDDA810750A`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.4.13

## Scope

- SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`
- VERSION=0.4.13
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0413_RIGHT_STATUS_STAMINA_FASTMOVE_A
- Game was not launched.
- Steam was not launched.
- No user mods, saves, Workshop, or game install directory writes were performed.

## File Counts

- Lua files: 20
- Lua total lines: 1655
- Root Markdown docs: 43

## Lua Syntax Risk Scan

- Lua 5.1 execution parser: NOT_VERIFIABLE. No trusted Lua 5.1 interpreter was run or installed.
- Text quote-balance scan: PASS
- Empty text/Lua files: PASS
- NULL in text/Lua files: PASS
- UTF-8 BOM in text/Lua/Markdown/info/json after cleanup: PASS
- PNG contains NULL bytes: EXPECTED_BINARY_ASSET

## Prohibited Runtime Patterns

- `MoodlesUI:Nest`: PASS, absent
- `MoodlesUI:AddChild`: PASS, absent
- `MoodlesUI:setParent`: PASS, absent
- Direct instance method call on `UIManager.MoodleUI` array: PASS, absent
- `UIManager.DrawTexture`: PASS, absent
- Per-frame UI creation: PASS, only one top-level panel is created by `ensurePanel()`
- Disabled-state render/log spam: PASS
- `NO SAFE SPEED BACKEND` / `CHECK FINAL_REPORT` center flicker text: PASS, absent
- `player:setSpeedMod`: PASS, absent from active source
- `player:getSpeedMod`: PASS, absent from active source
- `setMoveSpeed/getMoveSpeed`: PASS, absent
- `path_speed/combat_speed/WalkSpeed`: PASS, absent
- Player coordinate writes: PASS. `setX/setY` matches only top-level UI panel positioning, not player movement.
- Time speed writes: PASS, absent

## Allowed Runtime Writes

- `stats:setEndurance(Constants.RUNNER.ENDURANCE_TARGET)` exists only in `XNP_DR_InfiniteEnduranceTest.lua`.
- This write is gated by native trait detection and `INFINITE_ENDURANCE_TEST_MODE`.
- No hunger, thirst, fatigue, calories, pain, injury, encumbrance, coordinate, time, or animation-variable writes remain.

## UI Static Check

- STATUS_ICON_MODULE=PASS
- Render backend: `BACKEND_E_TOP_LEVEL_ISUI_SCREEN_SPACE`
- Target region: `RIGHT_SIDE_STATUS_ICON_COLUMN`
- Character panel F path untouched.
- Runtime F path is independent, top-level, and screen-space.
- `UIManager.MoodleUI[playerIndex]` is used only inside `pcall` for evidence and optional coordinate resolution.
- All coordinate arithmetic passes through `safeNumber`.
- Fallback coordinate is dynamic: `screenWidth - 52`, not hardcoded `x=1856`.

## Module Isolation

- STATUS_ICON_MODULE=ISOLATED
- ENDURANCE_MODULE=ISOLATED
- MOVEMENT_BACKEND_MODULE=ISOLATED_BLOCKED
- No global `disabledForSession` kills all modules.
- Each module has one-time fatal logging behavior.

## Fast Move Audit

- NATIVE_DEBUG_FAST_MOVE_FOUND=YES
- Native entry observed: `player:setFastMoveCheat(boolean)`
- Capability observed: `Capability.UseFastMoveCheat`
- Debug/admin route observed in `ISAdminPowerUI.lua`
- Teleport-style helper observed in `ISFastTeleportMove.lua`
- FAST_MOVE_SELECTED_AS_BACKEND=NO

## Require/Loop Risk

- Bootstrap requires constants, trait registration/probes, act
[EXCERPT_TRUNCATED]
```
