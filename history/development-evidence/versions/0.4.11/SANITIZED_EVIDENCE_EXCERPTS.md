# 0.4.11 Sanitized Evidence Excerpts

## 0.4.11_ACTIVE_F_POSITION_AND_VISIBILITY_FAILURE.md

- SHA-256: `DF3713406FD334A3F4E1F210D92C92B250C0D8D2FCF5A42158006B9236CB836C`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.11 Active F Position And Visibility Failure

Frozen real-game result:

```text
[XNP ACTIVE F] module_loaded=true
[XNP ACTIVE F] create_begin
[XNP ACTIVE F] texture_resolved=true
[XNP ACTIVE F] texture_width=18
[XNP ACTIVE F] texture_height=18
[XNP ACTIVE F] ui_element_created=true
[XNP ACTIVE F] screen_x=1856
[XNP ACTIVE F] screen_y=48
[XNP ACTIVE F] added_to_ui_manager=true
[XNP ACTIVE F] visible=true reason=ui_self_test
```

Observed by user:

- The first 3-second F self-test rendered.
- The F appeared in the wrong left/top screen area, not beside the vanilla right-side Moodle column.
- During X10, logs said `visible=true`, but the user did not see the F.
- Internal visible state is not enough evidence of actual render success.

Frozen conclusion:

- ACTIVE_F_TEXTURE=PASS
- ACTIVE_F_UI_OBJECT_CREATION=PASS
- ACTIVE_F_UI_MANAGER_ADD=PASS
- ACTIVE_F_SELF_TEST_RENDERED=PASS
- ACTIVE_F_POSITION=FAIL
- ACTIVE_F_X10_VISIBLE_TO_USER=FAIL
- ACTIVE_F_CURRENT_ANCHOR_METHOD=REJECTED

0.4.12 change:

- Do not anchor only by `getCore():getScreenWidth() - fixed_offset`.
- Resolve the live `MoodlesUI` object first.
- Try a Moodle-child backend before absolute fallback.
- Log real Moodle local and absolute coordinates.
- Count actual render calls and log `visible_without_render=true` if visibility does not produce render calls.

```

## 0.4.11_ACTIVE_F_POSITION_AND_VISIBILITY_FAILURE.md

- SHA-256: `90065E3BD0EF7A271462BC623D15F6CC5C560EFC97A94D820AF0A4168E9D8834`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.11 Active F Position And Visibility Failure

Frozen real-game result:

```text
[XNP ACTIVE F] module_loaded=true
[XNP ACTIVE F] create_begin
[XNP ACTIVE F] texture_resolved=true
[XNP ACTIVE F] texture_width=18
[XNP ACTIVE F] texture_height=18
[XNP ACTIVE F] ui_element_created=true
[XNP ACTIVE F] screen_x=1856
[XNP ACTIVE F] screen_y=48
[XNP ACTIVE F] added_to_ui_manager=true
[XNP ACTIVE F] visible=true reason=ui_self_test
```

Observed by user:

- The first 3-second F self-test rendered.
- The F appeared in the wrong left/top screen area, not beside the vanilla right-side Moodle column.
- During X10, logs said `visible=true`, but the user did not see the F.
- Internal visible state is not enough evidence of actual render success.

Frozen conclusion:

- ACTIVE_F_TEXTURE=PASS
- ACTIVE_F_UI_OBJECT_CREATION=PASS
- ACTIVE_F_UI_MANAGER_ADD=PASS
- ACTIVE_F_SELF_TEST_RENDERED=PASS
- ACTIVE_F_POSITION=FAIL
- ACTIVE_F_X10_VISIBLE_TO_USER=FAIL
- ACTIVE_F_CURRENT_ANCHOR_METHOD=REJECTED

0.4.12 change:

- Do not anchor only by `getCore():getScreenWidth() - fixed_offset`.
- Resolve the live `MoodlesUI` object first.
- Try a Moodle-child backend before absolute fallback.
- Log real Moodle local and absolute coordinates.
- Count actual render calls and log `visible_without_render=true` if visibility does not produce render calls.

```

## 0.4.11_RUNTIME_RESULT_CORRECTION.md

- SHA-256: `46F53E042313114A041D122B9E05B788A5FE0E783F26294B732F42299073CF04`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.11 Runtime Result Correction

Frozen real-game result:

- 0.4.11_X10_PHASE_REACHED=YES
- 0.4.11_SET_SPEEDMOD_EXECUTED=YES
- 0.4.11_SPEEDMOD_READBACK_MAINTAINED=YES
- 0.4.11_RESET_READBACK=PASS
- SPEED_MOD_WRITABLE=YES
- SPEED_MOD_READBACK=YES
- SPEED_MOD_WORLD_MOVEMENT_EFFECT=NOT_CONFIRMED
- SPEED_MOD_USER_VISUAL_EFFECT=FAIL
- SPEED_MOD_PRODUCTION_BACKEND=REJECTED

Confirmed logs included actual write and readback:

```text
[XNP AUTO X10] apply_begin
[XNP AUTO X10] setSpeedMod_invoked=true
[XNP AUTO X10] applied_target=10.000000
[XNP AUTO X10] immediate_readback=10.000000
[XNP AUTO X10] active_state=true
[XNP AUTO X10] SPEED_MOD_X10_WRITE_CONFIRMED
[XNP AUTO X10] maintain_readback=10.000000
[XNP AUTO X10] reset_target=1.000000
[XNP AUTO X10] reset_readback=1.000000
[XNP AUTO X10] active_state=false
```

The logged `world_ratio=4.185548` is not valid success evidence.

Reasons:

1. The user did not feel any obvious movement change during the 10x request.
2. Baseline and active samples were not a direct same-input continuous switch.
3. TPS was not strictly locked to the same sprint/run state.
4. The coordinate sample conflicts with the expected visual effect from a 10x request.
5. Setter readback proves field writability only, not participation in final player displacement.

Final correction:

- 0.4.11_WORLD_RATIO_VALID=NO
- 0.4.11_WORLD_RATIO_RESULT=FALSE_POSITIVE_OR_CONTAMINATED_SAMPLE
- SPEED_MOD_FINAL_STATUS=REJECTED_WRITABLE_BUT_NO_USER_VISIBLE_WORLD_EFFECT

```

## 0.4.11_RUNTIME_RESULT_CORRECTION.md

- SHA-256: `00A33523B3D36F419BE496E9C1F68B208D71C95225A77E54ABDFF0F84396F54B`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.11 Runtime Result Correction

Frozen real-game result:

- 0.4.11_X10_PHASE_REACHED=YES
- 0.4.11_SET_SPEEDMOD_EXECUTED=YES
- 0.4.11_SPEEDMOD_READBACK_MAINTAINED=YES
- 0.4.11_RESET_READBACK=PASS
- SPEED_MOD_WRITABLE=YES
- SPEED_MOD_READBACK=YES
- SPEED_MOD_WORLD_MOVEMENT_EFFECT=NOT_CONFIRMED
- SPEED_MOD_USER_VISUAL_EFFECT=FAIL
- SPEED_MOD_PRODUCTION_BACKEND=REJECTED

Confirmed logs included actual write and readback:

```text
[XNP AUTO X10] apply_begin
[XNP AUTO X10] setSpeedMod_invoked=true
[XNP AUTO X10] applied_target=10.000000
[XNP AUTO X10] immediate_readback=10.000000
[XNP AUTO X10] active_state=true
[XNP AUTO X10] SPEED_MOD_X10_WRITE_CONFIRMED
[XNP AUTO X10] maintain_readback=10.000000
[XNP AUTO X10] reset_target=1.000000
[XNP AUTO X10] reset_readback=1.000000
[XNP AUTO X10] active_state=false
```

The logged `world_ratio=4.185548` is not valid success evidence.

Reasons:

1. The user did not feel any obvious movement change during the 10x request.
2. Baseline and active samples were not a direct same-input continuous switch.
3. TPS was not strictly locked to the same sprint/run state.
4. The coordinate sample conflicts with the expected visual effect from a 10x request.
5. Setter readback proves field writability only, not participation in final player displacement.

Final correction:

- 0.4.11_WORLD_RATIO_VALID=NO
- 0.4.11_WORLD_RATIO_RESULT=FALSE_POSITIVE_OR_CONTAMINATED_SAMPLE
- SPEED_MOD_FINAL_STATUS=REJECTED_WRITABLE_BUT_NO_USER_VISIBLE_WORLD_EFFECT

```

## AUTOMATIC_X10_STATUS_F_TEST_0.4.11.md

- SHA-256: `2A03A34F752535EF5391878BEDDFAA50EFF2C320CD8AA6F501E2EEAB6AF5B516`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Automatic X10 + Active F Status Test 0.4.11

## Purpose

0.4.11 tests two things independently:

1. Whether the right-side F status icon can be created and shown.
2. Whether `player:setSpeedMod(original * 10.00)` is actually invoked, read back, maintained for 15 seconds, and restored.

## Flow

- Phase A: `UI_SELF_TEST`, 3 seconds. Shows the F icon without changing speed.
- Phase B: `NORMAL_PREP`, 5 seconds. Restores original speed and allows any movement.
- Phase C: `X10_ACTIVE`, 15 seconds. Calls `setSpeedMod(original * 10.00)` immediately and reapplies every 0.10 seconds.
- Phase D: `RESTORE`, 5 seconds. Restores original speed and hides F.
- Phase E: `COMPLETE`. No automatic loop.

## Logging distinction

At startup the harness logs only:

- `[XNP AUTO X10] configured_factor=10.00`
- `[XNP AUTO X10] original_speed_mod=<value>`

It logs actual write evidence only when the X10 phase begins:

- `[XNP AUTO X10] apply_begin`
- `[XNP AUTO X10] setSpeedMod_invoked=true`
- `[XNP AUTO X10] applied_target=<value>`
- `[XNP AUTO X10] immediate_readback=<value>`
- `[XNP AUTO X10] active_state=true`
- `[XNP AUTO X10] SPEED_MOD_X10_WRITE_CONFIRMED`

## World TPS probe

Coordinate TPS may be recorded during normal prep and X10, but it never controls X10 activation. If either probe is invalid, the harness logs:

`WORLD_RATIO=NOT_AVAILABLE_USER_VISUAL_TEST_ONLY`

## Active F icon

`ACTIVE_STATUS_ICON_BACKEND=RIGHT_MOODLE_ADJACENT_ISUI`

The icon uses:

`media/ui/Traits/trait_xnpdistancerunner.png`

It is shown for the F self-test and after X10 write confirmation. It is hidden after self-test, reset, cleanup, exception, death, main menu, missing trait, or disabled harness.

```

## BUILD_MARKER.txt

- SHA-256: `854186D78DEC0C0C2791FF34E7C8DC4DB5BAE01414EFBEB46F611E67A5889C6E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0411_AUTO_X10_STATUS_F_A

```

## FINAL_REPORT.md

- SHA-256: `0F700A7ACB8106082711F8AB0797D3D9C563AD06803C35390449E84E75EB43E4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL_REPORT

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.4.11
INTERNAL_VERSION=0.4.11-b42-automatic-x10-status-f-test-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0411_AUTO_X10_STATUS_F_A
DISPLAY_NAME=XNP Distance Runner Trait 0.4.11 自动X10 + 状态F测试

## Frozen 0.4.10 Result

0.4.10_LAST_REACHED_PHASE=WAIT_MIDDLE_STOP
0.4.10_NORMAL_SAMPLE=PASS
0.4.10_NORMAL_TPS=2.208669
0.4.10_MIDDLE_STOP_GATE=FAIL
0.4.10_X10_PHASE_REACHED=NO
0.4.10_SET_SPEEDMOD_10_EXECUTED=NO
0.4.10_X10_WRITE_EXECUTED=NO
0.4.10_ACTIVE_F_TRIGGERED=NO
0.4.10_SPEED_EFFECT_RESULT=NOT_TESTED
0.4.10_ACTIVE_F_RESULT=NOT_TESTED
0.4.10_REAL_FAILURE=MIDDLE_STOP_GATE_BLOCKED_X10_AND_ACTIVE_F

equested_speed_mod=10.000000 from 0.4.10 is treated only as startup configuration, not evidence of a setSpeedMod(10) write.

## 0.4.11 Implementation

COMPLEX_MOVEMENT_GATE_REMOVED=YES
AUTOMATIC_X10_ACTIVATION=YES
NORMAL_PREP_DURATION=5s
X10_ACTIVE_DURATION=15s
SPEED_MOD_REAPPLY_INTERVAL=0.10s
ACTUAL_WRITE_LOGGING=YES
READBACK_VERIFICATION=YES
ACTIVE_F_SELF_TEST=YES, 3s before speed write
ACTIVE_F_UI_CREATION_VERIFICATION=YES
ACTIVE_F_POSITIONING=dynamic right edge, approximately screen_width - 64, y=48
WORLD_TPS_PROBE_BLOCKS_ACTIVATION=NO
ENDURANCE_ISOLATION=ONLY_DURING_X10_FOR_TRAIT_PLAYER

## Backend

ENABLED_BACKEND=speed_mod
ENABLED_BACKEND_COUNT=1
BACKEND_DISCOVERY_PHASE=COMPLETE_FOR_THIS_TEST
NORMAL_VALUE=original_speed_mod
EXTREME_TEST_VALUE=original_speed_mod * 10.00
FORMAL_DISTANCE_RUNNER_GAMEPLAY_ENABLED=NO
AUTOMATIC_X10_STATUS_F_TEST=YES
PRODUCTION_READY=NO

## Preserved Identity

MOD_ID=XNP_PZ_DistanceRunnerTrait
TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner
B42_NATIVE_TRAIT_DEFINITION=UNCHANGED
CHARACTER_PANEL_ICON=UNCHANGED_YELLOW_F
PLAYER_NATIVE_TRAIT_DETECTION=UNCHANGED
TRAIT_CHAIN_CHANGED=NO
TRAIT_ID_CHANGED=NO

## Safety

Coordinates changed? NO
Time changed? NO
Affects no-trait character? NO_STATIC, trait gate retained
Game started? NO
Steam started? NO
Old SOURCE modified? NO
User mods/saves/Workshop/game directory written? NO

## Counts

Lua file count=20
Lua total lines=2065
Document/info file count=38

## Static Checks

STATIC_CHECK_RESULT=PASS_WITH_RUNTIME_NOT_VERIFIABLE
Old movement gate phases in active Lua=ABSENT
Premature requested_speed_mod log in active Lua=ABSENT
getMoveSpeed/setMoveSpeed in active Lua=ABSENT
TraitFactory in active Lua=ABSENT
player coordinate writes=ABSENT
Game time writes=ABSENT
setSpeedMod actual write=PRESENT
F icon UI manager add log=PRESENT
Translation JSON parse=PASS
Lua interpreter execution=NOT_VERIFIABLE

## NOT_VERIFIABLE

- Project Zomboid real-game load and execution.
- Whether player:setSpeedMod(original*10) changes world movement speed visibly.
- Whether PZ runtime renders the ISUI F icon at the intended screen position.
- Whether UI manager addition succeeds in the live game beyond static call presence.
- Lua runtime syntax execution, because no reliable local Lua interpreter was available.
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `D5FDC7D4EE171E107F98F2C4CEB181771C0EC612EBE6C1381782057D9D7BFB63`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.11 鑷姩X10 + 鐘舵€丗娴嬭瘯

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨勮嚜鍔ㄥ畾鏃?X10 涓庡彸涓婅 F 鐘舵€佸浘鏍囪嚜妫€鐗堟湰锛屼笉鏄寮忕帺娉曠増鏈€?
## 韬唤

- Version: `0.4.11`
- Internal version: `0.4.11-b42-automatic-x10-status-f-test-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_0411_AUTO_X10_STATUS_F_A`
- Display name: `XNP Distance Runner Trait 0.4.11 鑷姩X10 + 鐘舵€丗娴嬭瘯`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 0.4.10 缁撹淇

0.4.10 宸茬粡瀹屾垚 normal 閲囨牱锛屼絾鍗″湪涓棿鍋滄闂ㄦ帶锛屾湭杩涘叆 X10 闃舵銆?
鍥犳锛?
- `0.4.10_NORMAL_SAMPLE=PASS`
- `0.4.10_NORMAL_TPS=2.208669`
- `0.4.10_MIDDLE_STOP_GATE=FAIL`
- `0.4.10_X10_PHASE_REACHED=NO`
- `0.4.10_SET_SPEEDMOD_10_EXECUTED=NO`
- `0.4.10_SPEED_EFFECT_RESULT=NOT_TESTED`
- `0.4.10_ACTIVE_F_RESULT=NOT_TESTED`

0.4.11 鍒犻櫎澶嶆潅浜や簰闂ㄦ帶锛屾敼鎴愭寜瀹炴椂鏃堕棿鑷姩鎵ц X10銆?
## 淇濇寔涓嶅彉

- B42 鍘熺敓鐗硅川瀹氫箟
- 浜虹墿鍒涘缓娑堣€?- 涓枃鍚嶇О鍜屾弿杩?- 榛勮壊 F 鍘熺敓鐗硅川鍥炬爣璧勬簮
- CharacterTrait 娉ㄥ唽閾?- 鍘熺敓鐗硅川妫€娴?- 鑰愬姏闅旂
- `speed_mod` 鍚庣

## 0.4.11 鑷姩娴佺▼

1. F 鍥炬爣鑷 3 绉掞紝涓嶆敼 speed_mod銆?2. 姝ｅ父鍑嗗 5 绉掞紝淇濇寔鍘熷 speed_mod銆?3. X10 寮哄埗婵€娲?15 绉掞紝姣?0.10 绉掗噸鍐欎竴娆°€?4. 鎭㈠ 5 绉掞紝鍐欏洖鍘熷 speed_mod 骞堕殣钘?F銆?5. 瀹屾垚锛屼笉寰幆銆?
## 涓嶅惎鐢?
- TraitFactory
- Skill Core
- XNP 鎶€鑳界偣
- Unlock 鎸夐挳
- 鍑虹敓鍚庤ˉ鍙戠壒璐?- ModData 浼€犵壒璐?- `getMoveSpeed/setMoveSpeed`
- 姝ｅ紡闀块€斿琚帺娉?
```

## STATIC_AUDIT.md

- SHA-256: `11BB57CC9C53BBB9F40C8ADB7F307CA9AA053F6FA02D9B51929B56E529D8589D`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC_AUDIT

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.4.11
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0411_AUTO_X10_STATUS_F_A
AUDIT_DATE=2026-07-03

## Scope

This is a static text audit only. Project Zomboid, Steam, Workshop, user mods, saves, and game directories were not opened or modified.

## File Counts

- Lua files: 20
- Lua total lines: 2065
- Document/info files: 38
- Empty files: 0
- NULL bytes in Lua/text: ABSENT
- NULL bytes in binary PNG: PRESENT_EXPECTED_BINARY_ICON_ONLY

## Active Lua Checks

| Check | Result |
| --- | --- |
| 0.4.11 build marker present | PASS |
| Automatic phases present: UI_SELF_TEST / NORMAL_PREP / X10_ACTIVE / RESTORE / COMPLETE | PASS |
| Old STOP/WALK gate phases in active Lua | ABSENT |
| equested_speed_mod premature log in active Lua | ABSENT |
| player:setSpeedMod actual write call | PRESENT |
| getMoveSpeed/setMoveSpeed in active Lua | ABSENT |
| TraitFactory in active Lua | ABSENT |
| Player coordinate writes player:setX/setY | ABSENT |
| Game time writes | ABSENT |
| Right-side F icon module load log | PRESENT |
| UI creation logging | PRESENT |
| UI manager add logging | PRESENT |
| Endurance isolation only during X10 phase | PASS_STATIC |
| No-trait status icon display gate | PASS_STATIC |

## Syntax Risk Scan

- Lua interpreter execution: NOT_VERIFIABLE, no reliable local Lua command was available.
- Bracket/brace/parenthesis balance text scan: PASS_STATIC
- JSON translation parse: PASS
- BOM scan: no text-level blocker found.
- Active Lua circular require review: PASS_STATIC, same copied module topology as 0.4.10 with updated harness.

## Safety Scan

- Did not start Project Zomboid: YES
- Did not start Steam: YES
- Did not write user mods/saves/Workshop/game directory: YES
- Did not modify 0.4.8 or 0.4.10 SOURCE: YES
- New SOURCE only: YES

## Lua Files

- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ActiveStatusIcon.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_IconProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
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
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TraitRegistration.lua
- 42\media
[EXCERPT_TRUNCATED]
```
