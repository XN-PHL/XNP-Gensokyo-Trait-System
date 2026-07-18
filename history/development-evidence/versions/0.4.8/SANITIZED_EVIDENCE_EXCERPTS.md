# 0.4.8 Sanitized Evidence Excerpts

## 0.4.8_FALSE_POSITIVE_ANALYSIS.md

- SHA-256: `EAA36B0CCC749CFE9FCB8730ACA90C1C4D304C53DE51E2C629008578B27FDD2D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.8 False Positive Analysis

## Frozen 0.4.8 log

- `baseline_tps=1.970363`
- `active_tps=4.594220`
- `ratio=2.331662`
- `reset_readback=1.000000`
- `restored_tps=5.281911`

## Corrected conclusion

- `0.4.8_MOVEMENT_MODE_CONSISTENCY=FAIL`
- `0.4.8_RATIO_VALID=NO`
- `0.4.8_PARTIAL_WORLD_SPEED_EFFECT=UNPROVEN`
- `0.4.8_SPEEDMOD_WORLD_EFFECT=NOT_CONFIRMED`

## Reason

The restored sample is higher than the active sample. That means the baseline, active, and restored phases may have used different walking / jogging / animation states or different input conditions.

`ratio=2.331662` must not be used as proof that `speed_mod` controls world movement speed. `reset_readback=1.000000` only proves the field could be written back, not that world movement returned to a comparable state.

## 0.4.9 correction

0.4.9 stops trying to infer subtle ratios. It performs an extreme visual hard toggle:

- normal walking at `speed_mod=1.00`
- full stop
- walking at `speed_mod=10.00`
- immediate reset to the original value

The goal is only to answer whether `speed_mod=10` causes obvious world movement change in both coordinates and user-visible motion.

```

## BUILD_MARKER.txt

- SHA-256: `9C69338940EB53DBE710F4036D8318F435E272C0F45B9FE055620322B22C51C2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_048_SIGNATURE_SAFE_A

```

## CHANGELOG.md

- SHA-256: `A8224C0A9657A1BC008CEBF357DC1FDD56B1CBAAB3C75353C58EA31880769B2E`
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

- SHA-256: `E4746D54DD0851E4CC521D8C94EEABEA93A2D3642561F54E36DBF48B7A82513B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.8

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.8`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_048_SIGNATURE_SAFE_A`
- 0.4.7_ROOT_CAUSE: `PARAMETERIZED_JAVA_METHOD_CALLED_WITH_ZERO_ARGUMENTS`
- OFFENDING_METHOD: `isClimbingThroughWindow`
- OFFENDING_REAL_SIGNATURE: `IsoGameCharacter.isClimbingThroughWindow(IsoWindow window)`
- OFFENDING_CALL_ARGUMENT_COUNT: `0`
- DYNAMIC_METHOD_CALL_REMOVED: `YES`
- METHOD_SIGNATURE_AUDIT_COUNT: `15`
- ZERO_ARG_WHITELIST: `getVehicle, isClimbing, isProne, isKnockedDown, isSitOnGround, isAiming, isAttacking, isAsleep, isSprinting, getActionStateName, getAnimationStateName, getSpeedMod`
- PARAMETERIZED_METHOD_BLACKLIST: `isClimbingThroughWindow(IsoWindow window), isClosingWindow(IsoWindow window)`
- SESSION_CIRCUIT_BREAKER: `YES`
- ERROR_LOG_SPAM_BLOCKED: `YES`
- ENABLED_CANDIDATE_COUNT: `1`
- ENABLED_CANDIDATE: `speed_mod`
- MOVEMENT_GATING_SIMPLIFIED: `YES`
- ENDURANCE_ISOLATION_STATUS: `retained; below 0.90 restored to 0.95; explicit calls only`
- TRAIT_CHAIN_MODIFIED: `NO`
- ICON_CHAIN_MODIFIED: `NO`
- COORDINATES_MODIFIED: `NO`
- LUA_FILE_COUNT: `19`
- LUA_TOTAL_LINES: `1899`
- STATIC_CHECK: `PASS_WITH_NOT_VERIFIABLE_ITEMS`
- GAME_STARTED: `NO`
- OLD_SOURCE_MODIFIED: `NO`
- GAME_DIRECTORY_WRITTEN: `NO`
- BLOCKER: `NONE_STATIC`

## NOT_VERIFIABLE

- `REAL_GAME_TEST_REQUIRED_BY_USER`
- `MULTIPLAYER_NOT_YET_VALIDATED`
- `NOT_VERIFIABLE_NO_LOCAL_LUA_5_1`
- Full javap-style Java method emission unavailable because local install has no `javap.exe`; class-file constant-pool evidence and frozen debugger evidence were used.

## Runtime Summary

- Test phase order: `WAIT_MOVING_BASELINE -> BASELINE -> APPLY_SPEED_MOD -> ACTIVE_SAMPLE -> RESTORED_SAMPLE -> COMPLETE`
- Enabled speed calls: `player:getSpeedMod()` and `player:setSpeedMod(value)`
- Disabled candidates: `path_speed`, `combat_speed`, `anim_walk_speed_variable`, `move_speed_failed_control`
- Fatal error behavior: restore speed_mod when possible, set `Harness.disabledForSession=true`, print one `[XNP SPEED TEST] fatal error...` line, and show `XNP TEST DISABLED / CHECK CONSOLE`.

## Complete File Tree

- 0.4.2_RUNTIME_FAILURE_ANALYSIS.md
- 0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md
- 0.4.6_INVALID_TEST_ANALYSIS.md
- 0.4.7_JAVA_METHOD_SIGNATURE_FAILURE_ANALYSIS.md
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_IconProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
- 42\media\lua\shared\translate\CN\UI.json
- 42\media\lua\shared\translate\EN\UI.json
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_B42TraitApiProbe.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
- 42\media\lua\sha
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `2D4138717BAF9DFF2AD300C946318BCF4B6EC786B3BEBAC7F79B7D8E5428201E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.8 Signature Safe Speed Test

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨勭鍚嶅畨鍏ㄧ増閫熷害鍚庣璇婃柇婧愮爜銆?.4.8 涓嶅惎鐢ㄦ寮忕帺娉曪紝鍙仮澶?`speed_mod` 鐨勬湁鏁堢Щ鍔ㄥ熀绾挎祴璇曘€?
## Identity

- Version: `0.4.8`
- Internal version: `0.4.8-b42-signature-safe-speed-test-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_048_SIGNATURE_SAFE_A`
- Display name: `XNP Distance Runner Trait 0.4.8 Signature Safe Speed Test`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 0.4.7 frozen failure

- `0.4.7_ROOT_CAUSE=PARAMETERIZED_JAVA_METHOD_CALLED_WITH_ZERO_ARGUMENTS`
- Offending method: `isClimbingThroughWindow`
- Real signature: `IsoGameCharacter.isClimbingThroughWindow(IsoWindow window)`
- Offending call argument count: `0`
- Candidate begin reached: `NO`
- Speed write reached: `NO`
- Result: `INVALID`

## 0.4.8 changes

- Removed generic `hasMethodTrue(player, methodName)` from the speed harness.
- Removed runtime Java method calls through string table indexing.
- Removed zero-argument calls to `isClimbingThroughWindow()` and `isClosingWindow()`.
- Added one-shot session circuit breaker.
- Enabled only `speed_mod`.
- Kept native trait ID and icon path unchanged.

## Enabled test

- `ENABLED_CANDIDATE_COUNT=1`
- `ENABLED_CANDIDATE=speed_mod`

The test waits for stable walking, samples baseline TPS, writes `original_speed_mod * 3.00`, samples active TPS, restores the original value, and samples restored TPS.

## Status

- Static source ready.
- Real game test still required by user.
- Multiplayer not yet validated.

```

## SIGNATURE_SAFE_SPEED_MOD_TEST_0.4.8.md

- SHA-256: `D3055CE85FC8C6C74670B08D1304262797B83D218C238FD65ED134D369B640C2`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Signature Safe Speed Mod Test 0.4.8

## Goal

0.4.8 resumes only the valid part of the 0.4.7 moving-baseline test and removes the Java signature hazard.

## Enabled Candidate

- `ENABLED_CANDIDATE_COUNT=1`
- `ENABLED_CANDIDATE=speed_mod`
- Tested calls:
  - `player:getSpeedMod()`
  - `player:setSpeedMod(original_speed_mod * 3.00)`

Disabled for this round:

- `path_speed`
- `combat_speed`
- `anim_walk_speed_variable`
- `move_speed_failed_control`

## Flow

1. Wait for stable ordinary walking.
2. Lock movement after 0.75 seconds of real coordinate displacement.
3. Sample baseline for 2 seconds.
4. Require `baseline_tps >= 0.50`.
5. Read `original_speed_mod`.
6. Write `original_speed_mod * 3.00`.
7. Maintain the write during active sampling.
8. Sample `active_tps` for 2 seconds.
9. Compute finite ratio only when baseline and active TPS are valid.
10. Restore original speed mod.
11. Sample restored movement for 2 seconds.

## Result Rules

- `ratio >= 2.50`: `CONFIRMED_X3_WORLD_SPEED`
- `ratio >= 1.50 and < 2.50`: `PARTIAL_WORLD_SPEED_EFFECT`
- `ratio >= 0.85 and < 1.50`: `NO_WORLD_SPEED_EFFECT`
- Readback cannot stay near requested x3: `ENGINE_OVERWRITTEN`
- `baseline_tps < 0.50`: `SAMPLE_INVALID`
- Unexpected runtime error: `HARNESS_FATAL_ERROR`

`SAMPLE_INVALID` is a sample failure, not a backend failure.

## Safety

- No coordinate writes.
- No teleport.
- No global game speed changes.
- No dynamic Java method calls by string name.
- No `isClimbingThroughWindow()` zero-argument call.
- No `isClosingWindow()` zero-argument call.
- Session circuit breaker prevents repeated stack spam after one fatal harness error.

```

## STATIC_AUDIT.md

- SHA-256: `C61CD8F58970B59DB8F24928AF7A45D02F4A9C67294280219EF952F7C6AD1FEC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.8

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.8`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_048_SIGNATURE_SAFE_A`
- Static audit date: 2026-07-02

## Required Static Checks

| Check | Result |
| --- | --- |
| `isClimbingThroughWindow()` zero-arg call | ABSENT |
| `isClosingWindow()` zero-arg call | ABSENT |
| dynamic `player[name]()` Java call | ABSENT |
| per-frame pcall unknown method probing | ABSENT |
| generic `hasMethodTrue` caller | ABSENT |
| speed_mod enabled | YES |
| candidates other than speed_mod enabled | NO |
| outer one-shot circuit breaker | YES |
| repeated execution after fatal error | NO |
| restore candidate after fatal error | YES |
| NAN output | BLOCKED |
| INF output | BLOCKED |
| coordinate write | ABSENT |
| teleport | ABSENT |
| game speed write | ABSENT |
| ThePlayer usage | ABSENT |
| Trait ID changed | NO |
| icon chain changed | NO |
| game executable launched | NO |
| old SOURCE modified | NO |
| game directory written | NO |

## Signature Audit

- METHOD_SIGNATURE_AUDIT_COUNT: `15`
- ZERO_ARG_WHITELIST: `getVehicle, isClimbing, isProne, isKnockedDown, isSitOnGround, isAiming, isAttacking, isAsleep, isSprinting, getActionStateName, getAnimationStateName, getSpeedMod`
- PARAMETERIZED_METHOD_BLACKLIST: `isClimbingThroughWindow(IsoWindow window), isClosingWindow(IsoWindow window)`
- Static matrix: `B42_19_PLAYER_STATE_METHOD_SIGNATURE_MATRIX.md`

## Counts

- Lua file count: `19`
- Lua total lines: `1899`
- Markdown file count: `27`
- Text file count: `2`
- Document file count: `29`

## Not Verifiable

- Real game behavior is `REAL_GAME_TEST_REQUIRED_BY_USER`.
- Multiplayer behavior is `MULTIPLAYER_NOT_YET_VALIDATED`.
- Lua 5.1 execution parser is `NOT_VERIFIABLE_NO_LOCAL_LUA_5_1`.
- Exact full Java method table could not be emitted by a local javap tool because no `javap.exe` was present; matrix combines class-file evidence with frozen debugger signature evidence.

## File Tree

- 0.4.2_RUNTIME_FAILURE_ANALYSIS.md
- 0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md
- 0.4.6_INVALID_TEST_ANALYSIS.md
- 0.4.7_JAVA_METHOD_SIGNATURE_FAILURE_ANALYSIS.md
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
- 42\media\lua\shared\XNP_PZ_DistanceRunn
[EXCERPT_TRUNCATED]
```
