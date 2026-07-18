# 0.4.9 Sanitized Evidence Excerpts

## 0.4.9_INVALID_STATE_MATCH_ANALYSIS.md

- SHA-256: `BD80889C0F25309324C41568093E10D1E241A93875DA03AB7D3A1AD565A823DB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.9 Invalid State Match Analysis

## Frozen 0.4.9 result

- `0.4.9_NORMAL_SAMPLE_VALID=NO`
- `0.4.9_X10_SAMPLE_VALID=NO`
- `0.4.9_RATIO_AVAILABLE=NO`
- `0.4.9_SPEEDMOD_RESULT=NOT_TESTED`
- `0.4.9_USER_INSTRUCTION_LOCALIZATION=FAIL`
- `0.4.9_RESULT=INVALID_TEST_HARNESS`
- `SPEEDMOD_EFFECT_RESULT=UNRESOLVED`

## Failure reason

0.4.9 required the normal phase and X10 phase to have exactly the same `action_state` and `animation_state` strings.

That condition is too strict. `speed_mod` itself may change animation selection, movement state names, animation speed, or related state strings. Therefore:

- `ACTION_STATE_STRING_MISMATCH` cannot invalidate a sample by itself.
- `ANIMATION_STATE_STRING_MISMATCH` cannot invalidate a sample by itself.
- State strings should be logged for diagnosis only.

## 0.4.10 correction

0.4.10 removes the hard state-string match. A sample is valid or invalid based on player existence, target trait, vehicle / unsafe states, sprint rejection, actual world displacement, actual TPS, stop duration, and stable ordinary walking instructions.

State-string differences are logged as:

- `state_string_difference=<true_or_false>`
- `state_string_difference_is_diagnostic_only=true`

```

## BUILD_MARKER.txt

- SHA-256: `70C29B05054091A020982E4F11F2201DD8A3E9F183C5E7F6501666E964EC1983`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_049_SPEEDMOD_HARD_TOGGLE_A

```

## FINAL_REPORT.md

- SHA-256: `7ACE1570426088B5F36FEE254275020DE5C4CFE85BD19466F0AEDE16494D5316`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.9

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.9`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_049_SPEEDMOD_HARD_TOGGLE_A`
- 0.4.8_RATIO_VALIDITY: `NO`
- 0.4.8_FALSE_POSITIVE_REASON: `restored_tps=5.281911 exceeded active_tps=4.594220; baseline, active, and restored samples may have used different walking/running/animation states`
- ENABLED_BACKEND: `speed_mod`
- NORMAL_VALUE: `1.00`
- EXTREME_TEST_VALUE: `10.00`
- STOP_BETWEEN_PHASES: `YES; TPS < 0.10 for 1.00s required before each walk phase`
- MOVEMENT_STATE_MATCH_REQUIRED: `YES; action_state and animation_state must match normal vs x10`
- SPRINT_REJECTION: `YES; SAMPLE_REJECTED_SPRINT_DETECTED`
- USER_VISUAL_CONFIRMATION_REQUIRED: `YES; x10 must be obviously visible to the user`
- HARD_TOGGLE_RATIO_RULE: `>=2.00 confirmed, 1.20-1.99 small/limited, 0.85-1.19 writable but ineffective, state mismatch invalid`
- RESET_METHOD: `player:setSpeedMod(original_value)`
- COORDINATES_MODIFIED: `NO`
- TIME_SPEED_MODIFIED: `NO`
- NO_TRAIT_PLAYER_AFFECTED: `NO_STATIC_PATH; runtime activates only after target trait detection`
- LUA_FILE_COUNT: `19`
- LUA_TOTAL_LINES: `1950`
- STATIC_CHECK: `PASS_WITH_NOT_VERIFIABLE_ITEMS`
- GAME_STARTED: `NO`
- OLD_SOURCE_MODIFIED: `NO`
- GAME_DIRECTORY_WRITTEN: `NO`
- BLOCKER: `NONE_STATIC`

## NOT_VERIFIABLE

- `REAL_GAME_TEST_REQUIRED_BY_USER`
- `USER_VISUAL_EFFECT_NOT_CONFIRMED` until the user tests visual difference in game.
- `MULTIPLAYER_NOT_YET_VALIDATED`
- `NOT_VERIFIABLE_NO_LOCAL_LUA_5_1`

## Runtime Summary

- State machine: `WAIT_INITIAL_STOP -> NORMAL_WAIT_WALK -> NORMAL_SAMPLE -> WAIT_MIDDLE_STOP -> X10_WAIT_WALK -> X10_SAMPLE -> FINAL_RESET -> COMPLETE`
- Logs: `normal_tps`, `x10_tps`, `ratio`, `normal_action`, `x10_action`, `normal_animation`, `x10_animation`, `result`.
- Formal gameplay remains disabled: no momentum, metabolism, fatigue, XP, calibration, or backend scanning.

## Complete File Tree

- 0.4.2_RUNTIME_FAILURE_ANALYSIS.md
- 0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md
- 0.4.6_INVALID_TEST_ANALYSIS.md
- 0.4.7_JAVA_METHOD_SIGNATURE_FAILURE_ANALYSIS.md
- 0.4.8_FALSE_POSITIVE_ANALYSIS.md
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_IconProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
- 42\media\lua\shared\translate\CN\UI.json
- 42\media\lua\shared\translate\EN\UI.json
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_B42TraitApiProbe.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Debug.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_DirectSpeedBackendHarness.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Metabolism.lua
- 42\media\lua\shared\XN
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `AE350DF8FEEFDDF86B47C14DDEF8923DE66F2DEF5F3CABEBF35FBCC769CE4341`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.9 SpeedMod Hard Toggle Test

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨?`speed_mod=10` 鏋佺鑲夌溂楠岃瘉鐗堟湰锛屼笉鏄寮忕帺娉曠増鏈€?
## Identity

- Version: `0.4.9`
- Internal version: `0.4.9-b42-speedmod-hard-toggle-test-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_049_SPEEDMOD_HARD_TOGGLE_A`
- Display name: `XNP Distance Runner Trait 0.4.9 SpeedMod Hard Toggle Test`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## Corrected 0.4.8 conclusion

0.4.8 鐨?`ratio=2.331662` 涓嶅啀浣滀负 `speed_mod` 鏈夋晥璇佹嵁銆傚洜涓?`restored_tps=5.281911` 楂樹簬 `active_tps=4.594220`锛岃鏄?baseline / active / restored 鍙兘娣峰叆浜嗕笉鍚岀Щ鍔ㄧ姸鎬併€?
## 0.4.9 test

鍙祴璇曪細

- `player:getSpeedMod()`
- `player:setSpeedMod(value)`

娴嬭瘯鍊硷細

- normal: `1.00`
- x10: `10.00`

娴佺▼锛?
- 鍋滄
- 鏅€氭琛岄噰鏍?- 鍐嶆鍋滄
- x10 姝ヨ閲囨牱
- 绔嬪嵆澶嶄綅
- 杈撳嚭 normal TPS銆亁10 TPS銆乺atio 鍜?result

濡傛灉 x10 鑲夌溂浠嶄笉鏄庢樉锛屼笉鑳借繘鍏ユ寮忕帺娉曘€?
```

## SPEEDMOD_HARD_TOGGLE_TEST_0.4.9.md

- SHA-256: `D89CF6B33E6889491A55D23008BE69C840280D591DEEB5BC73A3443523F7A1C6`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# SpeedMod Hard Toggle Test 0.4.9

## Purpose

This is an extreme diagnostic test, not a balance build. It tests whether `player:setSpeedMod(10.00)` produces an obvious world movement effect compared with normal walking.

## Enabled Backend

- `ENABLED_BACKEND=speed_mod`
- `NORMAL_VALUE=1.00`
- `EXTREME_TEST_VALUE=10.00`
- `EXPERIMENTAL_HARD_TOGGLE_TEST=YES`
- `PRODUCTION_READY=NO`

Disabled:

- `path_speed`
- `combat_speed`
- `anim_walk_speed_variable`
- `move_speed_failed_control`
- `getMoveSpeed/setMoveSpeed`

## State Machine

1. `WAIT_INITIAL_STOP`
2. `NORMAL_WAIT_WALK`
3. `NORMAL_SAMPLE`
4. `WAIT_MIDDLE_STOP`
5. `X10_WAIT_WALK`
6. `X10_SAMPLE`
7. `FINAL_RESET`
8. `COMPLETE`

## Required Structure

The player must fully stop between normal and x10 samples. Stop means actual coordinate TPS below `0.10` for at least `1.00` second.

Both walking samples require:

- `isSprinting=false`
- actual TPS above `0.50`
- stable movement for `0.75` second before sampling
- 4 second sample duration
- matching action state and animation state between normal and x10 samples

## Result Rules

- `HARD_TOGGLE_RATIO = X10_TPS / NORMAL_TPS`
- If either sample enters sprint: `SAMPLE_REJECTED_SPRINT_DETECTED`
- If action or animation state differs: `SAMPLE_INVALID_MOVEMENT_STATE_MISMATCH`
- If readback cannot stay near 10: `SPEEDMOD_ENGINE_OVERWRITTEN`
- `ratio >= 2.00`: `SPEEDMOD_WORLD_EFFECT_CONFIRMED`
- `1.20 <= ratio < 2.00`: `SPEEDMOD_EFFECT_SMALL_OR_ENGINE_LIMITED`
- `0.85 <= ratio < 1.20`: `SPEEDMOD_WRITABLE_BUT_WORLD_SPEED_INEFFECTIVE`

Even if automated TPS rises, the user must visually confirm the x10 phase. If the user cannot see an obvious difference, mark the result as `USER_VISUAL_EFFECT_NOT_CONFIRMED` outside the static source.

## Safety

The harness saves the original speed mod before testing and restores that value on completion, rejected samples, unsafe player state, death / main-menu cleanup, and Lua exception. It does not modify X/Y coordinates, time speed, animation variables, or players without the target trait.

```

## STATIC_AUDIT.md

- SHA-256: `B3307FD70269E404204E646EA7B9BE38A978FD52D0C23A59DACE9096EEB72C5F`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.9

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.9`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_049_SPEEDMOD_HARD_TOGGLE_A`
- Static audit date: 2026-07-03

## Required Checks

| Check | Result |
| --- | --- |
| selected backend | `speed_mod` |
| enabled backend count | `1` |
| `getMoveSpeed/setMoveSpeed` active use | ABSENT |
| `path_speed` active use | DISABLED_ONLY |
| `combat_speed` active use | DISABLED_ONLY |
| animation variable speed write | ABSENT |
| hard toggle values | `1.00 -> 10.00 -> original` |
| stop between phases | IMPLEMENTED |
| sprint rejection | IMPLEMENTED |
| action / animation state match required | IMPLEMENTED |
| user stop over 2s reset | IMPLEMENTED |
| reset method | `player:setSpeedMod(original_value)` |
| coordinate write | ABSENT |
| time speed write | ABSENT |
| dynamic Java method call by string | ABSENT |
| ThePlayer usage | ABSENT |
| formal gameplay modules enabled | NO |
| no-trait player affected | NO_STATIC_PATH; runtime gated by trait detection |
| game executable launched | NO |
| old 0.4.8 source modified | NO |
| game directory written | NO |
| Workshop / user mods / saves written | NO |

## Counts

- Lua file count: `19`
- Lua total lines: `1950`
- Markdown file count: `29`
- Text file count: `2`

## Not Verifiable

- `REAL_GAME_TEST_REQUIRED_BY_USER`
- `USER_VISUAL_EFFECT_NOT_CONFIRMED` must be decided by the user after playing the hard toggle test.
- `MULTIPLAYER_NOT_YET_VALIDATED`
- `NOT_VERIFIABLE_NO_LOCAL_LUA_5_1`

## File Tree

- 0.4.2_RUNTIME_FAILURE_ANALYSIS.md
- 0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md
- 0.4.6_INVALID_TEST_ANALYSIS.md
- 0.4.7_JAVA_METHOD_SIGNATURE_FAILURE_ANALYSIS.md
- 0.4.8_FALSE_POSITIVE_ANALYSIS.md
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_IconProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
- 42\media\lua\shared\translate\CN\UI.json
- 42\media\lua\shared\translate\EN\UI.json
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_B42TraitApiProbe.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Debug.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_DirectSpeedBackendHarness.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Metabolism.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Movement.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Preflight.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_State.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TrainingFatigue.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Trait.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TraitRegis
[EXCERPT_TRUNCATED]
```
