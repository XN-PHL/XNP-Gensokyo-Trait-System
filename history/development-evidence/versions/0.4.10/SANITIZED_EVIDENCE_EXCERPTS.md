# 0.4.10 Sanitized Evidence Excerpts

## 0.4.10_MIDDLE_STOP_GATE_FAILURE_ANALYSIS.md

- SHA-256: `536D319EA7A723703B464C8E0AE38D9C193F0E689E6ADCEC1B77723903F43ADE`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.10 Middle Stop Gate Failure Analysis

## Frozen real-game log

- `phase=NORMAL_WAIT_WALK`
- `phase=NORMAL_SAMPLE`
- `normal_tps=2.208669`
- `phase=WAIT_MIDDLE_STOP`

After that, until the game exited, the log did not show:

- `phase=X10_WAIT_WALK`
- `phase=X10_SAMPLE`
- `readback_speed_mod=10`
- `[XNP ACTIVE F] visible=true`

It only showed:

- `[XNP ACTIVE F] visible=false reason=middle_stop`
- `reset_readback=1.000000`

## Correct conclusion

- `0.4.10_NORMAL_SAMPLE=PASS`
- `0.4.10_NORMAL_TPS=2.208669`
- `0.4.10_MIDDLE_STOP_GATE=FAIL`
- `0.4.10_X10_PHASE_REACHED=NO`
- `0.4.10_SET_SPEEDMOD_10_EXECUTED=NO`
- `0.4.10_SPEED_EFFECT_RESULT=NOT_TESTED`
- `0.4.10_ACTIVE_F_RESULT=NOT_TESTED`

The startup log value `requested_speed_mod=10.000000` was only a configured target. It was not evidence that `setSpeedMod(10)` executed.

0.4.10 must not be described as "X10 took effect but had no user-visible effect." The test never reached the X10 write phase.

## 0.4.11 correction

0.4.11 removes the middle stop gate and all movement-gated activation. It applies X10 by real elapsed time after a fixed preparation period.

```

## B42_19_DIRECT_SPEED_CANDIDATE_MATRIX.md

- SHA-256: `5EA3BAC204F063EC067A189D65074EE21C4997DC2A15C230A2764DD93CBD0CB1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Direct Speed Candidate Matrix

## Evidence Roots

- PZ root: `[LOCAL_PATH_REDACTED]`
- Runtime jar: `[LOCAL_PATH_REDACTED]`
- Lua root: `[LOCAL_PATH_REDACTED]`

## Local Static Evidence

- `IsoGameCharacter`: `getSpeedMod`, `setSpeedMod`, `setPathSpeed`, `getGlobalMovementMod`, `getMovementSpeed`, `getRunSpeedModifier`, `setVariable`.
- `IsoPlayer`: `getPathSpeed`, `getMoveSpeed`, `setMoveSpeed`, `setCombatSpeed`, `getCombatSpeed`.
- Vanilla debug UI reads `getRunSpeedModifier` and `getVariableFloat("WalkSpeed", 0)`.
- `Stats`: `get(CharacterStat)`, `set(CharacterStat, float)`.
- Vanilla endurance sample: `player:getStats():get(CharacterStat.ENDURANCE)`.

## Candidates

| id | Class | Signature | Read | Write | Original value | Test value | Overwritten each frame | Reset | Theoretical scope | Evidence path | Order |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `speed_mod` | `IsoGameCharacter` | `float getSpeedMod(); void setSpeedMod(float)` | `player:getSpeedMod()` | `player:setSpeedMod(original * 3.00)` | runtime read | `original * 3.00` | unknown | `setSpeedMod(original)` | possible world movement input | `projectzomboid.jar javap IsoGameCharacter` | 1 |
| `path_speed` | `IsoPlayer` | `float getPathSpeed(); void setPathSpeed(float)` | `player:getPathSpeed()` | `player:setPathSpeed(original * 3.00)` | runtime read | `original * 3.00` | unknown | `setPathSpeed(original)` | path/NPC or movement candidate | `projectzomboid.jar javap IsoPlayer` | 2 |
| `combat_speed` | `IsoPlayer` | `float getCombatSpeed(); void setCombatSpeed(float)` | `player:getCombatSpeed()` | `player:setCombatSpeed(original * 3.00)` | runtime read | `original * 3.00` | unknown | `setCombatSpeed(original)` | combat or animation only candidate | `projectzomboid.jar javap IsoPlayer` | 3 |
| `anim_walk_speed_variable` | `IsoGameCharacter AnimationVariableSource` | `getVariableFloat("WalkSpeed", 0); setVariable("WalkSpeed", float)` | `player:getVariableFloat("WalkSpeed", 0)` | `player:setVariable("WalkSpeed", original * 3.00)` | runtime read | `original * 3.00` | likely engine overwritten | `setVariable("WalkSpeed", original)` | animation variable candidate | `ISRunningDebugUI.lua` and javap `setVariable` | 4 |
| `move_speed_failed_control` | `IsoPlayer` | `float getMoveSpeed(); void setMoveSpeed(float)` | `player:getMoveSpeed()` | `player:setMoveSpeed(original * 3.00)` | runtime read | `original * 3.00` | suspected | `setMoveSpeed(original)` | known failed control | 0.4.4/0.4.5 real test and javap `IsoPlayer` | 5 |

## Classification Rules

- WORLD_DISPLACEMENT_INPUT: confirmed only if ratio >= 2.50.
- LOCAL_PLAYER_WRITABLE_CANDIDATE: method exists, read/write/reset path exists, and it applies to current local player object.
- ANIMATION_ONLY: visual or variable change without TPS ratio improvement.
- NPC_PATH_ONLY: path speed changes but local manual movement TPS does not change.
- READ_ONLY_DERIVED_VALUE: readable but no safe setter.
- ENGINE_OVERWRITTEN_EACH_FRAME
[EXCERPT_TRUNCATED]
```

## B42_19_PLAYER_STATE_METHOD_SIGNATURE_MATRIX.md

- SHA-256: `F305943BD805C3C6C19D18BA9E7CB120CA6CC74B70FB63FB545760CB4579F5D9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Player State Method Signature Matrix

Audit source:

- `[LOCAL_PATH_REDACTED]`
- Classes inspected as static class-file evidence:
  - `zombie/characters/IsoGameCharacter.class`
  - `zombie/characters/IsoPlayer.class`
  - `zombie/characters/ILuaGameCharacter.class`
  - `se/krka/kahlua/integration/expose/LuaJavaInvoker.class`
  - `se/krka/kahlua/integration/expose/MethodArguments.class`

Important note: no game executable was run. This is a static audit combined with the frozen 0.4.7 real-game error.

## Matrix

| METHOD_NAME | DECLARING_CLASS | RETURN_TYPE | PARAMETER_COUNT | PARAMETER_TYPES | SAFE_ZERO_ARG_CALL | CURRENT_USAGE | ACTION |
| --- | --- | --- | ---: | --- | --- | --- | --- |
| `isClimbingThroughWindow` | `IsoGameCharacter` | `boolean` | 1 | `IsoWindow window` | NO | Removed | PARAMETERIZED_METHOD_BLACKLIST |
| `isClosingWindow` | `IsoGameCharacter` | `boolean` | 1 | `IsoWindow window` | NO | Removed | PARAMETERIZED_METHOD_BLACKLIST |
| `isClimbing` | `IsoGameCharacter` | `boolean` | 0 | none | YES | `player:isClimbing()` | ZERO_ARG_WHITELIST |
| `isProne` | `IsoGameCharacter` / `IsoPlayer` evidence | `boolean` | 0 | none | YES | `player:isProne()` | ZERO_ARG_WHITELIST |
| `isKnockedDown` | `IsoGameCharacter` / `IsoPlayer` evidence | `boolean` | 0 | none | YES | `player:isKnockedDown()` | ZERO_ARG_WHITELIST |
| `isSitOnGround` | `IsoGameCharacter` / `IsoPlayer` evidence | `boolean` | 0 | none | YES | `player:isSitOnGround()` | ZERO_ARG_WHITELIST |
| `isAiming` | `IsoGameCharacter` / `IsoPlayer` / `ILuaGameCharacter` evidence | `boolean` | 0 | none | YES | `player:isAiming()` | ZERO_ARG_WHITELIST |
| `isAttacking` | `IsoGameCharacter` / `IsoPlayer` evidence | `boolean` | 0 | none | YES | `player:isAttacking()` | ZERO_ARG_WHITELIST |
| `isRunning` | `IsoGameCharacter` / `IsoPlayer` evidence | `boolean` | 0 | none | YES | Not used for gating | ALLOWED_READ_IF_NEEDED |
| `isSprinting` | `IsoGameCharacter` / `IsoPlayer` evidence | `boolean` | 0 | none | YES | `player:isSprinting()` for mode split | ZERO_ARG_WHITELIST |
| `isAsleep` | `IsoGameCharacter` / `IsoPlayer` / `ILuaGameCharacter` evidence | `boolean` | 0 | none | YES | `player:isAsleep()` | ZERO_ARG_WHITELIST |
| `isbFalling` | `IsoGameCharacter` evidence | `boolean` | NOT_VERIFIED | NOT_VERIFIED | NO | Not used | NOT_CALLED |
| `getVehicle` | `IsoGameCharacter` / `IsoPlayer` / `ILuaGameCharacter` evidence | vehicle object or nil | 0 | none | YES | `player:getVehicle()` | ZERO_ARG_WHITELIST |
| `getActionStateName` | `IsoGameCharacter` evidence | string-like state name | 0 | none | YES | read-only diagnostic | READ_ONLY_DIAGNOSTIC |
| `getAnimationStateName` | `IsoGameCharacter` evidence | string-like state name | 0 | none | YES | read-only diagnostic | READ_ONLY_DIAGNOSTIC |

## Zero-Argument Whitelist

- `getVehicle()`
- `isClimbing()`
- `isProne()`
- `isKnockedDown()`
- `isSitOnGround()`
- `isAiming()`
- `isAttacking()`
- `isAsleep()`
- `isSprinting()`
- `getActionState
[EXCERPT_TRUNCATED]
```

## BUILD_MARKER.txt

- SHA-256: `93B72750B40836ADF14EC8613290B4B7EE9101F32931F87E9714550D5B373FCF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0410_CN_TOGGLE_STATUS_F_A

```

## CHANGELOG.md

- SHA-256: `F147DD2175F12BAA9C14BDCAE909B1CC5E66EEF3AB350627C2541A455F083A33`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

## 0.4.6 - B42 Direct Speed Feasibility A

- Created an isolated experimental direct speed backend test build.
- Preserved the successful 0.4.5 native trait and yellow F icon pipeline.
- Disabled formal Distance Runner gameplay modules at the runtime entrypoint.
- Added `XNP_DR_DirectSpeedBackendHarness.lua`.
- Implemented sequential world-displacement tests for:
  - `speed_mod`: `getSpeedMod` / `setSpeedMod`
  - `path_speed`: `getPathSpeed` / `setPathSpeed`
  - `combat_speed`: `getCombatSpeed` / `setCombatSpeed`
  - `anim_walk_speed_variable`: `getVariableFloat("WalkSpeed")` / `setVariable("WalkSpeed", value)`
  - `move_speed_failed_control`: `getMoveSpeed` / `setMoveSpeed`
- Added endurance isolation through `player:getStats():get(CharacterStat.ENDURANCE)` and `stats:set(CharacterStat.ENDURANCE, value)` when available.
- Fixed reset log spam by logging each candidate reset once and skipping reset when no candidate write occurred.
- Kept direct coordinate modification, teleport acceleration, global time changes, zombie speed changes, and no-trait writes absent.

## 0.4.5 - B42 Native Icon + World Speed Fix A

- Preserved the successful 0.4.4 native trait pipeline and canonical trait ID.
- Fixed native trait icon definition from bare `trait_xnpdistancerunner` to full B42 texture path `media/ui/Traits/trait_xnpdistancerunner.png`.
- Added `[XNP ICON]` runtime texture resolution probe.
- Reduced the creation commit probe to D-only reporting because 0.4.4 proved A/D success and no first-loss checkpoint.
- Rejected `player:getMoveSpeed()` / `player:setMoveSpeed()` as the production movement backend.
- Added `XNP_DR_WorldDisplacementProbe.lua` to measure real world coordinate displacement with `player:getX()` and `player:getY()`.
- Did not implement a new speed-writing backend because local B42.19 evidence did not prove a safe writable, resettable world-speed multiplier.
- Output status: icon ready, world speed backend blocked.

## 0.4.4 - B42 Creation Commit + Icon Fix A

- Preserved the successful 0.4.3 backend C script definition path and canonical CharacterTrait object chain.
- Added native creation commit probe around `CharacterCreationProfession.addTrait` and `CharacterCreationProfession.initWorld`.
- Added checkpoints A/B/C/D for selected UI, pre-build selected list, native world payload, and spawned player native collection.
- Added a pre-spawn native world payload guard with `getWorld():addLuaTrait(canonical CharacterTrait object)` only when XNP was selected before build but missing from the world payload after vanilla `initWorld`.
- Did not add any post-spawn fake trait, ModData fallback, default grant, or dynamic player trait patch.
- Added native trait icon asset `42/media/ui/Traits/trait_xnpdistancerunner.png`.
- Added `Texture = trait_xnpdistancerunner` to the B42 `character_trait_definition`.
- Reduced 0.4.3 runtime missing-trait log spam to one report per loaded player state.
- Movement, XP, metabolism, fatigue, and X3 gam
[EXCERPT_TRUNCATED]
```

## FINAL_REPORT.md

- SHA-256: `EE7A824A1E16555041BED5871CDC69B354739DDA069CEB155C2FD9F8EAEA227F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.10

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.10`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_0410_CN_TOGGLE_STATUS_F_A`
- 0.4.9_NORMAL_SAMPLE_RESULT: `NO_VALID_SAMPLE`
- 0.4.9_X10_SAMPLE_RESULT: `NO_VALID_SAMPLE`
- 0.4.9_RATIO_RESULT: `NO_RATIO_AVAILABLE`
- 0.4.9_FAILURE_REASON: `ACTION_ANIMATION_STATE_STRING_HARD_MATCH_TOO_STRICT`
- HUD_LANGUAGE: `Chinese`
- ACTION_STATE_HARD_MATCH_REMOVED: `YES`
- ANIMATION_STATE_HARD_MATCH_REMOVED: `YES`
- STATE_NAMES_DIAGNOSTIC_ONLY: `YES`
- CURRENT_STEP_RETRY_IMPLEMENTED: `YES`
- NORMAL_SAMPLE_DURATION: `4s; first 0.50s transition ignored`
- X10_SAMPLE_DURATION: `4s; first 0.50s transition ignored`
- TRANSITION_DATA_IGNORED: `YES; 0.50s after sample start`
- ENABLED_BACKEND: `speed_mod`
- EXTREME_FACTOR: `10.00 * original_speed_mod`
- ACTIVE_STATUS_ICON_IMPLEMENTED: `YES`
- ACTIVE_STATUS_ICON_BACKEND: `RIGHT_MOODLE_ADJACENT_ISUI`
- ACTIVE_STATUS_ICON_TEXTURE: `media/ui/Traits/trait_xnpdistancerunner.png`
- ACTIVE_STATUS_ICON_TOOLTIP: `Chinese tooltip: Distance Runner speed boost active / current mode is X10 diagnostic test`
- ACTIVE_STATUS_ICON_HIDE_CONDITIONS: `normal phase, stop phase, reset, failure, pause, disabled harness, missing trait, cleanup, death, main menu, Lua exception`
- NATIVE_TRAIT_ICON_MODIFIED: `NO`
- TRAIT_ID_MODIFIED: `NO`
- COORDINATES_MODIFIED: `NO`
- TIME_MODIFIED: `NO`
- NO_TRAIT_CHARACTER_AFFECTED: `NO_STATIC_PATH; runtime HUD/icon/speed writes are trait-gated`
- LUA_FILE_COUNT: `20`
- LUA_TOTAL_LINES: `2077`
- STATIC_CHECK_RESULT: `PASS_WITH_NOT_VERIFIABLE_ITEMS`
- GAME_STARTED: `NO`
- OLD_SOURCE_MODIFIED: `NO`
- GAME_DIRECTORY_WRITTEN: `NO`
- BLOCKER: `NONE_STATIC`

## Frozen Successful Parts Kept

- NATIVE_TRAIT_PIPELINE_CHANGED: `NO`
- NATIVE_TRAIT_ICON_CHANGED: `NO`
- TRAIT_FULL_ID_CHANGED: `NO`
- speed_mod backend retained.
- endurance isolation retained.

## NOT_VERIFIABLE

- `REAL_GAME_TEST_REQUIRED_BY_USER`
- `ACTIVE_STATUS_ICON_SCREENSHOT_REQUIRED_BY_USER`
- `USER_VISUAL_EFFECT_NOT_CONFIRMED`
- `MULTIPLAYER_NOT_YET_VALIDATED`
- `NOT_VERIFIABLE_NO_LOCAL_LUA_5_1`
- Native custom Moodle registration safety was not proven; icon backend is intentionally adjacent ISUI, not native Moodle.

## Complete File Tree

- 0.4.2_RUNTIME_FAILURE_ANALYSIS.md
- 0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md
- 0.4.6_INVALID_TEST_ANALYSIS.md
- 0.4.7_JAVA_METHOD_SIGNATURE_FAILURE_ANALYSIS.md
- 0.4.8_FALSE_POSITIVE_ANALYSIS.md
- 0.4.9_INVALID_STATE_MATCH_ANALYSIS.md
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ActiveStatusIcon.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_IconProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_
[EXCERPT_TRUNCATED]
```

## INSTALL_REPORT.md

- SHA-256: `976F33D2F4F37DB0CD3A9807390AEF6F14871DE26589015EDF88FBE55ADAEE44`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# INSTALL REPORT

Installation was not attempted by Codex for this source-only round.

- Wrote source output directory: `YES`
- Wrote game install directory: `NO`
- Wrote user saves/mods directory: `NO`
- Started Project Zomboid: `NO`
- Started Steam: `NO`
- Workshop upload: `NO`

Manual installation/test remains required by the user.

```

## README_CN.md

- SHA-256: `62E12D38B32F8C93A2EA594C17B5B36A66A65FA70CB0E65C9FB99FDEFA3D9F88`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.10 涓枃纭垏鎹?+ 鐘舵€丗鍥炬爣

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨勪腑鏂囩‖鍒囨崲娴嬭瘯鐗堟湰锛屼笉鏄寮忕帺娉曠増鏈€?
## 韬唤

- Version: `0.4.10`
- Internal version: `0.4.10-b42-cn-hard-toggle-status-f-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_0410_CN_TOGGLE_STATUS_F_A`
- Display name: `XNP Distance Runner Trait 0.4.10 涓枃纭垏鎹?+ 鐘舵€丗鍥炬爣`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 0.4.9 缁撹淇

0.4.9 鐨?`SAMPLE_INVALID_MOVEMENT_STATE_MISMATCH` 鏉ヨ嚜娴嬭瘯鍣ㄨ繃搴﹁姹?action state 鍜?animation state 瀹屽叏涓€鑷淬€?
0.4.10 涓細

- action / animation 瀛楃涓插彧璁板綍锛屼笉鍐嶇‖闃绘柇銆?- 鏃犳晥鎿嶄綔鍙噸璇曞綋鍓嶆楠ゃ€?- HUD 鍏ㄩ儴鏀逛负涓枃銆?- X10 鐪熸鍐欏叆鎴愬姛鏃讹紝鍙充笂瑙掓樉绀洪粍鑹?F 鐘舵€佸浘鏍囥€?
## 淇濇寔涓嶅彉

- B42 鍘熺敓鐗硅川瀹氫箟
- 浜虹墿鍒涘缓娑堣€?- 涓枃鍚嶇О鍜屾弿杩?- 榛勮壊 F 鍘熺敓鐗硅川鍥炬爣璧勬簮
- CharacterTrait 娉ㄥ唽閾?- 鍘熺敓鐗硅川妫€娴?- 鑰愬姏闅旂
- `speed_mod` 鍚庣

## 涓嶅惎鐢?
- TraitFactory
- Skill Core
- XNP 鎶€鑳界偣
- Unlock 鎸夐挳
- 鍑虹敓鍚庤ˉ鍙戠壒璐?- ModData 浼€犵壒璐?- `getMoveSpeed/setMoveSpeed`
- 姝ｅ紡闀块€斿琚帺娉?
```

## STOUT_VS_XNP_TRAIT_COMMIT_MATRIX.md

- SHA-256: `528733F41F45B3C8B07155C88AE6C128137E123D771ACC23F3BC11E6112C91E6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STOUT VS XNP TRAIT COMMIT MATRIX

| Area | base:stout | XNP 0.4.4 | Difference |
|---|---|---|---|
| Registry object | Vanilla `base:stout` | `CharacterTrait.register("XNPDistanceRunnerTrait:XNPDistanceRunner")` | RELEVANT: custom namespace |
| CharacterTrait object | `base:stout` | `xnpdistancerunnertrait:xnpdistancerunner` verified in 0.4.3 | NOT_RELEVANT: object resolves |
| CharacterTraitDefinition | Visible in `getTraits()` | Visible in `getTraits()` and creation UI | NOT_RELEVANT: definition exists |
| Script field `CharacterTrait` | `base:stout` | `XNPDistanceRunnerTrait:XNPDistanceRunner` | RELEVANT: full custom id |
| Cost | `6` | `1` | NOT_RELEVANT: both positive/costed |
| Positive/negative | Positive | Positive | NOT_RELEVANT |
| UI list data | `CharacterTraitDefinition` | `CharacterTraitDefinition` | NOT_RELEVANT |
| Selected list data | `CharacterTraitDefinition` | `CharacterTraitDefinition` expected; probe A verifies | RELEVANT until runtime-confirmed |
| Commit call | `getWorld():addLuaTrait(definition:getType())` | same vanilla call plus pre-spawn canonical payload guard | RELEVANT |
| Player collection | present in 0.4.3 test | absent in 0.4.3 test | RELEVANT root failure |
| Icon | `getTexture()` native | `Texture = trait_xnpdistancerunner` and `media/ui/Traits/trait_xnpdistancerunner.png` | RELEVANT |
| Save/reload | expected native persistence | requires 0.4.4 real test | NOT_VERIFIABLE |

## First Structural Difference To Fix

The first difference that explains "UI selectable but player does not have it" is the creation commit payload. 0.4.4 therefore adds checkpoints A/B/C and a pre-spawn payload guard in `initWorld()`.

```

## 中文硬切换与F状态图标测试_0.4.10.md

- SHA-256: `2ACBF905940047C5BD1F66C1E3FB2A68F28614C44F00D3F05041A092118CFAFD`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 涓枃纭垏鎹笌F鐘舵€佸浘鏍囨祴璇?0.4.10

1. 鍙惎鐢?0.4.10銆?2. 瀹屽叏閲嶅惎娓告垙銆?3. 鍔犺浇甯﹂粍鑹?F 鐗硅川鐨勮鑹层€?4. 鍒扮┖鏃风洿璺€?5. 鎸夊乏涓婅涓枃鎻愮ず鎿嶄綔銆?6. 鈥滆瀹屽叏绔欎綇鈥濇椂涓嶈绉诲姩銆?7. 鈥滆鏅€氭琛屸€濇椂鍙寜涓€涓Щ鍔ㄦ柟鍚戙€?8. 涓嶈濂旇窇銆佸啿鍒恒€佽浆鍚戙€佸共鎵版垨鎾炲銆?9. X10 婵€娲绘椂妫€鏌ュ彸涓婅鏄惁鍑虹幇 F銆?10. 娴嬭瘯缁撴潫鍚庢鏌?F 鏄惁娑堝け銆?11. 璁板綍姝ｅ父閫熷害銆乆10 閫熷害鍜屽€嶇巼銆?12. 濡傛灉鎻愮ず褰撳墠姝ラ鏃犳晥锛屽彧闇€閲嶆柊鎵ц褰撳墠姝ラ锛屼笉蹇呴€€鍑烘父鎴忋€?
## 棰勬湡

- X10 鏈縺娲伙細鍙充笂瑙掓病鏈?F銆?- X10 婵€娲伙細鍙充笂瑙掑嚭鐜?F銆?- X10 澶嶄綅锛欶 绔嬪嵆娑堝け銆?- HUD 鍏ㄧ▼浣跨敤涓枃銆?- 涓嶆樉绀?`NORMAL TPS: NA`銆乣X10 TPS: NA` 鎴?`RATIO: NA`銆?
```

## ACTIVE_STATUS_ICON_AUDIT_0.4.10.md

- SHA-256: `47FA9C708D9FD506B8E22C2692A82283A79C71F8DBB4E96971CCB01CFC65DBFB`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Active Status Icon Audit 0.4.10

## Backend choice

`ACTIVE_STATUS_ICON_BACKEND=RIGHT_MOODLE_ADJACENT_ISUI`

Static local audit did not find a clearly safe public custom Moodle registration path for this Build 42.19 source task. Therefore 0.4.10 uses a separate `ISUIElement` adjacent to the right-side moodle/status area. It is not claimed to be a native Moodle.

## Texture

`ACTIVE_STATUS_ICON_TEXTURE=media/ui/Traits/trait_xnpdistancerunner.png`

The runtime status icon reuses the already successful yellow F trait icon resource. It does not create a new icon.

## Display Conditions

The icon is shown only when:

- the local player has `XNPDistanceRunnerTrait:XNPDistanceRunner`;
- the X10 speed backend is active;
- `speed_mod` target write succeeds;
- the harness is not resetting, paused, failed, or disabled.

The icon is hidden on reset, sample failure, death, main menu, cleanup, Lua exception, missing trait, and disabled harness.

## Tooltip

`闀块€斿琚€咃細閫熷害澧炲己宸叉縺娲籤

Second line:

`褰撳墠涓篨10璇婃柇娴嬭瘯`

```

## B42_19_CUSTOM_TRAIT_SAMPLE_REAUDIT.md

- SHA-256: `6BC39F43149E21C8190968029DE668561E3B573EDF61E7FA9E447E087E87BDBE`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 CUSTOM TRAIT SAMPLE REAUDIT

## Sample

- Workshop sample: More Traits
- Closest modern B42 folder found locally: `[LOCAL_PATH_REDACTED]`
- Mod info path: `[LOCAL_PATH_REDACTED]`
- Script definitions: `[LOCAL_PATH_REDACTED]`
- Registry file: `[LOCAL_PATH_REDACTED]`

## Observed Pattern

The sample uses B42 script definitions:

```text
module ToadTraits {
    character_trait_definition ToadTraits:actionhero
    {
        IsProfessionTrait = false,
        DisabledInMultiplayer = false,
        CharacterTrait = ToadTraits:actionhero,
        Cost = 8,
        UIName = UI_trait_actionhero,
        UIDescription = UI_trait_actionherodesc,
    }
}
```

It also registers native character trait ids in `media\registries.lua`:

```lua
ToadTraitsRegistries = {}
ToadTraitsRegistries.swift = CharacterTrait.register("ToadTraits:swift")
```

## 0.4.2 Application

0.4.2 mirrors that B42 pattern:

- `42\media\scripts\XNPDistanceRunnerTraits.txt`
- `42\media\registries.lua`
- `CharacterTrait.register("XNPDistanceRunnerTrait:XNPDistanceRunner")`
- `character_trait_definition XNPDistanceRunnerTrait:XNPDistanceRunner`

## Important Exclusion

Older sample files that call `TraitFactory.addTrait` are not treated as valid for 0.4.2 because the user-provided real PZ 42.19.0 console log already proved `TraitFactory` was unavailable for this mod branch.

```
