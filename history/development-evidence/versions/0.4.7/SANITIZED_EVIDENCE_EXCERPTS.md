# 0.4.7 Sanitized Evidence Excerpts

## 0.4.7_JAVA_METHOD_SIGNATURE_FAILURE_ANALYSIS.md

- SHA-256: `70FEA38E2027220F7C72177B4AA4ED1BC9EDA4DFEF487CABA568CE6F5CB7B5FD`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.7 Java Method Signature Failure Analysis

## Frozen real-game evidence

- Game version: `Project Zomboid 42.19.0`
- 0.4.7 loaded successfully:
  - `[XNP MOVING BASELINE TEST] MOVING_BASELINE_SPEED_TEST_ACTIVE`
- Trait, icon, and player binding were successful.
- First frame error:
  - `expected 1 argument, got 0`

## Call chain

- `XNP_DR_DirectSpeedBackendHarness.lua:43 pcall`
- `XNP_DR_DirectSpeedBackendHarness.lua:42 hasMethodTrue`
- `XNP_DR_DirectSpeedBackendHarness.lua:71 unsafePlayerState`
- `XNP_DR_DirectSpeedBackendHarness.lua:587 / 604 Update`
- `XNP_DR_Runtime.lua:94 Update`

## Offending method

- Method name seen in debugger: `isClimbingThroughWindow`
- 0.4.7 effective call: `player:isClimbingThroughWindow()`
- Build 42.19 real signature: `IsoGameCharacter.isClimbingThroughWindow(IsoWindow window)`
- Actual argument count required: `1`
- Offending call argument count: `0`

## Root cause

`0.4.7_ROOT_CAUSE=PARAMETERIZED_JAVA_METHOD_CALLED_WITH_ZERO_ARGUMENTS`

The 0.4.7 helper `hasMethodTrue(player, name)` treated every Java-exposed method name as a zero-argument boolean getter. That assumption is unsafe for Project Zomboid Java methods because some boolean-looking names require parameters.

## Reached phase

- `0.4.7_TEST_PHASE_REACHED=WAIT_MOVING_BASELINE_ONLY`
- `0.4.7_CANDIDATE_BEGIN_REACHED=NO`
- `0.4.7_SPEED_WRITE_REACHED=NO`
- `0.4.7_RESULT=INVALID`

## 0.4.8 correction

- Generic `hasMethodTrue(player, methodName)` removed.
- Runtime string-index Java method calls removed from the speed harness.
- `isClimbingThroughWindow()` and `isClosingWindow()` zero-argument calls are absent.
- 0.4.8 only uses explicit, whitelisted zero-argument state calls.
- 0.4.8 only tests `getSpeedMod()` / `setSpeedMod(float)`.
- A session circuit breaker disables the harness after one unexpected error and prevents per-frame stack spam.

```

## BUILD_MARKER.txt

- SHA-256: `283BF320AEF69A07549958126D118C777E7D8B8C0CB478B99B28782DA64150B5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_047_MOVING_BASELINE_A

```

## CHANGELOG.md

- SHA-256: `FCA913C850393E55FF15CECA51E47CE927DC5422CFC0264A46BB4DFF0D105B61`
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

- SHA-256: `A1570B3668C1EEE6289A831E0D6CA715703556D5097154BF3E1D210BE147B6A4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.7

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- DST_INSTALL_ROOT: `N/A - this is a Project Zomboid source package`
- VERSION: `0.4.7`
- INTERNAL_VERSION: `0.4.7-b42-moving-baseline-speed-test-a`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_047_MOVING_BASELINE_A`
- MOD_ID: `XNP_PZ_DistanceRunnerTrait`
- TRAIT_FULL_ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## Frozen 0.4.6 Result

- 0.4.6_BASELINE_TPS: `0`
- 0.4.6_BASELINE_VALID: `NO`
- 0.4.6_BASELINE_TPS_ZERO: `YES`
- 0.4.6_RATIO_VALIDITY: `INVALID`
- 0.4.6_WINNER_RESULT_VALIDITY: `INVALID`
- 0.4.6_DID_NOT_PROVE_ALL_CANDIDATES_FAILED: `YES`

## 0.4.7 Implementation

- MOVEMENT_GATING_IMPLEMENTED: `YES`
- MINIMUM_VALID_TPS: `0.50`
- PER_CANDIDATE_BASELINE_IMPLEMENTED: `YES`
- DIVIDE_BY_ZERO_BLOCKED: `YES`
- NAN_INF_OUTPUT_BLOCKED: `YES`
- SPEED_MOD_PRIORITY_TEST: `YES; candidate order starts with speed_mod`
- SPEED_MOD_REAPPLY_POLICY: `reapply during settle and active sampling; readback checked`
- WALK_ONLY_TEST: `YES; first pass`
- SPRINT_ONLY_TEST: `YES; second pass after walking candidates`
- MODE_CHANGE_REJECTION: `YES; sample rejected and candidate retried`
- ENDURANCE_ISOLATION: `YES; below 0.90 restored to 0.95 only`
- RESET_LOG_SPAM_FIXED: `YES; logs only candidate reset / phase / sample events`

## Safety

- Coordinates modified: `NO`
- No-trait affected: `NO; runtime activates only when target trait detected`
- Game started: `NO`
- Old source modified: `NO`
- Game directory written: `NO`
- Workshop upload: `NO`

## Counts

- Lua file count: `19`
- Lua total lines: `2069`
- Document file count: `26` (`24 .md + 2 .txt`)
- Mod info files: `2`
- JSON translation files: `2`
- adopted mod version: `0.4.7`

## Runtime Hooks

- Player component / state source: local player state table via `Core.State.Get(player)`; no shared all-player state table for the test harness.
- Player update hook: `Events.OnPlayerUpdate.Add(Core.Runtime.Update)`.
- Cleanup hooks: player death and main menu cleanup call `Core.Runtime.Cleanup`.
- Trait gate: `Core.Trait.PlayerHasTrait(player)`.

## Candidate Order

1. `speed_mod`
2. `path_speed`
3. `combat_speed`
4. `anim_walk_speed_variable`
5. `move_speed_failed_control`

## Static Check Result

- Static check: `PASS_WITH_NOT_VERIFIABLE_ITEMS`
- BLOCKER: `NONE_STATIC`

## NOT_VERIFIABLE

- `REAL_GAME_TEST_REQUIRED_BY_USER`
- `MULTIPLAYER_NOT_YET_VALIDATED`
- `Lua 5.1 syntax execution NOT_VERIFIABLE_NO_LOCAL_LUA_5_1`
- Actual B42.19 movement backend effect cannot be proven without real game testing.

## Complete File Tree

- 0.4.2_RUNTIME_FAILURE_ANALYSIS.md
- 0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md
- 0.4.6_INVALID_TEST_ANALYSIS.md
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
- 42\media\lua\client\XNP_P
[EXCERPT_TRUNCATED]
```

## MOVING_BASELINE_SPEED_TEST_0.4.7.md

- SHA-256: `4A98582C0DAA79D34C204BEAED966A5A6C80B1D849913B43D7A07E03E5EB9BBB`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Moving Baseline Speed Test 0.4.7

## Purpose

0.4.7 tests Project Zomboid Build 42.19 movement speed write candidates only after real player displacement is detected. It is a diagnostic source package, not a production gameplay build.

## Identity

- `VERSION=0.4.7`
- `INTERNAL_VERSION=0.4.7-b42-moving-baseline-speed-test-a`
- `BUILD_ID=XNP_PZ_DISTANCE_TRAIT_047_MOVING_BASELINE_A`
- Display name: `XNP Distance Runner Trait 0.4.7 Moving Baseline Test`
- Mod ID remains `XNP_PZ_DistanceRunnerTrait`
- Trait full ID remains `XNPDistanceRunnerTrait:XNPDistanceRunner`

## Movement gate

The harness waits for all of the following before sampling baseline:

- Player has the target trait.
- Player is not in a vehicle.
- Player is not aiming, attacking, climbing, vaulting, falling, or dead.
- Coordinates show continuous displacement.
- Recent 0.75 second TPS is at least `0.50`.
- Stop time inside the 0.75 second window is at most `0.15`.
- Movement mode is stable.

## Candidate sequence

The first pass is `WALK_ONLY_TEST`:

1. `speed_mod`
2. `path_speed`
3. `combat_speed`
4. `anim_walk_speed_variable`
5. `move_speed_failed_control`

After walking candidates are complete, the harness allows `SPRINT_ONLY_TEST` and repeats the same order. Walking baseline is never divided by sprint active output.

## Per-candidate workflow

For each candidate:

1. Restore / preserve candidate original value.
2. Wait for stable movement.
3. Sample `candidate_baseline_tps` for 2 seconds.
4. Reject if baseline is below `0.50`.
5. Write requested x3 value.
6. Reapply during settle and active sampling to detect or resist engine overwrite.
7. Wait 0.25 seconds.
8. Sample `candidate_active_tps` for 2 seconds.
9. Compute ratio only when baseline and active TPS are finite and valid.
10. Restore the original candidate value before advancing.

## Validity rules

- `nan` output is blocked.
- `inf` output is blocked.
- Divide-by-zero is blocked.
- Mode changes reject the current sample.
- Static baseline rejects the current sample.
- Backend readback rejection or engine overwrite is recorded separately from sample invalidity.

## Endurance isolation

Endurance isolation from 0.4.6 is retained but softened:

- Enabled once per harness state.
- If endurance is below `0.90`, it is restored to `0.95`.
- It does not force every-frame full `1.0` endurance.

## Safety

The harness does not modify coordinates, teleport the player, change global game time speed, or apply effects without the target trait. Cleanup restores the active candidate value on exit / death / vehicle / runtime cleanup.

```

## README_CN.md

- SHA-256: `DE856462A0EC4272939789BBE752A9FFBB67DCAAA5526D3721B765AF4E6CB682`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.7 Moving Baseline Test

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19 鐨勯潤鎬佸噯澶囩増璇婃柇婧愮爜銆?.4.7 涓嶅惎鐢ㄦ寮忕帺娉曪紝鍙敤浜庨獙璇佸摢涓Щ鍔ㄩ€熷害鍚庣鑳藉湪鐪熷疄浣嶇Щ涓骇鐢熶笘鐣岄€熷害鍙樺寲銆?
## Identity

- Version: `0.4.7`
- Internal version: `0.4.7-b42-moving-baseline-speed-test-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_047_MOVING_BASELINE_A`
- Display name: `XNP Distance Runner Trait 0.4.7 Moving Baseline Test`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 0.4.6 frozen result

0.4.6 鐨勬祴璇曠粨鏋滃凡琚喕缁撲负鏃犳晥锛氬熀绾块噰鏍锋椂瑙掕壊闈欐锛宍baseline_tps=0`锛屽洜姝?`nan` / `inf` 姣斿€间笉鑳借瘉鏄庝换浣曞€欓€夋垚鍔熸垨澶辫触銆?
鍐荤粨缁撹锛?
- `0.4.6_BASELINE_VALID=NO`
- `0.4.6_BASELINE_TPS_ZERO=YES`
- `0.4.6_RATIO_RESULTS_VALID=NO`
- `0.4.6_WINNING_BACKEND_NONE_RESULT=INVALID`
- `0.4.6_DID_NOT_PROVE_ALL_CANDIDATES_FAILED`

## 0.4.7 change

0.4.7 鏀逛负绛夊緟鐪熷疄杩炵画绉诲姩锛屽苟涓烘瘡涓€欓€夊崟鐙噰闆嗗熀绾裤€?
娴嬭瘯閲嶇偣锛?
- 鍏堣蛋璺祴璇?`speed_mod`銆?- 姣忎釜鍊欓€夐兘鏈夌嫭绔?baseline銆?- 涓嶈緭鍑?`nan` / `inf`銆?- 涓嶅仛闄や互闆躲€?- 涓嶄慨鏀瑰潗鏍囷紝涓嶄紶閫侊紝涓嶆敼娓告垙閫熷害銆?- 娌℃湁鐩爣 trait 鐨勭帺瀹朵笉鍙楀奖鍝嶃€?- Endurance 浣庝簬 `0.90` 鏃跺彧鎭㈠鍒?`0.95`锛屼笉姣忓抚寮哄埗婊″€笺€?
## Candidate order

1. `speed_mod`
2. `path_speed`
3. `combat_speed`
4. `anim_walk_speed_variable`
5. `move_speed_failed_control`

鍏堟墽琛?`WALK_ONLY_TEST`锛岃蛋璺€欓€夌粨鏉熷悗鎵嶈繘鍏?`SPRINT_ONLY_TEST`銆傝蛋璺?baseline 涓嶄細鍜屽啿鍒?active 鐩搁櫎銆?
## Test status

- Static source ready.
- Real game test still required by user.
- Multiplayer not yet validated.

```

## STATIC_AUDIT.md

- SHA-256: `7631F0F4FE7F144A092C4BB8C1771E820527D14927A2AACCD5359D9A1971877A`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.7

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.7`
- INTERNAL_VERSION: `0.4.7-b42-moving-baseline-speed-test-a`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_047_MOVING_BASELINE_A`
- Static audit date: 2026-07-02

## Counts

- Lua files: 19
- Lua total lines: 2069
- Markdown files: 24
- Text files: 2
- JSON files: 2
- mod.info files: 2
- PNG files: 1

## Static checks

| Check | Result |
| --- | --- |
| Output stayed inside workspace | PASS |
| Game directory write | NO |
| Old 0.4.6 source modified | NO |
| Project Zomboid / Steam started | NO |
| Lua 5.1 execution syntax check | NOT_VERIFIABLE_NO_LOCAL_LUA_5_1 |
| Text bracket / brace / parenthesis balance scan | PASS |
| JSON translation parse | PASS |
| BOM scan | PASS |
| NULL scan | PASS_TEXT_FILES; PNG contains binary NULL as expected |
| Empty file scan | PASS |
| setX / setY / setZ coordinate writes | ABSENT |
| teleportTo | ABSENT |
| global game speed write | ABSENT |
| ThePlayer usage | ABSENT |
| 0.4.7 identity in runtime constants | PASS |
| 0.4.7 mod.info identity | PASS |
| Build marker | PASS |
| Native trait script retained | PASS |
| Trait icon path retained | PASS |
| CN / EN translation JSON parse | PASS |
| Movement gating constants present | PASS |
| Per-candidate baseline logic present | PASS |
| Divide-by-zero guard | PASS |
| non-finite ratio guard | PASS |
| speed_mod first candidate | PASS |
| speed_mod reapply during settle / active | PASS |
| WALK_ONLY_TEST before SPRINT_ONLY_TEST | PASS |
| Mode-change rejection | PASS |
| Endurance isolation 0.90 -> 0.95 | PASS |
| Reset log spam fixed | PASS |

## Notes

Duplicate local helper function names such as `log`, `nowSeconds`, and `getLocalPlayer` exist in separate Lua chunks and are scoped local. They are not shared mutable global functions.

The historical 0.4.6 documentation is retained for comparison. Runtime identity files and final reports have been updated to 0.4.7.

## Not Verifiable By Static Audit

- Real game behavior.
- Whether a candidate truly changes world TPS in B42.19.
- Multiplayer behavior.
- Lua 5.1 bytecode/parser execution, because no reliable local Lua 5.1 interpreter was found.

## File Tree

- 0.4.2_RUNTIME_FAILURE_ANALYSIS.md
- 0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md
- 0.4.6_INVALID_TEST_ANALYSIS.md
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_IconProbe.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
- 42\media\lua\shared\translate\CN\UI.json
- 42\media\lua\shared\translate\EN\UI.json
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_B42TraitApiProbe.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
- 42\media\lua\shared\XNP_PZ_DistanceR
[EXCERPT_TRUNCATED]
```
