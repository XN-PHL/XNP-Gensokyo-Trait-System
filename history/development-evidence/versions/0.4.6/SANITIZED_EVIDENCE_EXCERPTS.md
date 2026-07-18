# 0.4.6 Sanitized Evidence Excerpts

## 0.4.6_INVALID_TEST_ANALYSIS.md

- SHA-256: `96D662A11B347B73EF8EA78D1DF8750C9EB5CFD16080168A03365B91397DD997`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.6 Invalid Test Analysis

## Frozen local test result

- 0.4.5 icon / trait / runtime path: PASS.
- 0.4.6 entered the test harness, but the baseline sample started while the character was static.
- Observed baseline phase: `phase=BASELINE`.
- Observed `baseline_tps=0`.

## Frozen candidate output

| Candidate | Original | Requested | Readback | Active TPS | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| speed_mod | 1 | 3 | 3 | 0 | nan |
| path_speed | 0.053999997 | 0.161999993 | 0.053999997 | 1.908685 | inf |
| combat_speed | 1 | 3 | 3 | 2.180753 | inf |
| anim_walk_speed_variable | NA | NA | 1.9499999 | 5.168250 | inf |
| move_speed_failed_control | NA | NA | 0.17999999 | 5.292063 | inf |

## Required conclusions

- `0.4.6_BASELINE_VALID=NO`
- `0.4.6_BASELINE_TPS_ZERO=YES`
- `0.4.6_RATIO_RESULTS_VALID=NO`
- `0.4.6_WINNING_BACKEND_NONE_RESULT=INVALID`
- `0.4.6_DID_NOT_PROVE_ALL_CANDIDATES_FAILED`

## Interpretation

The 0.4.6 harness divided active movement by a zero baseline. Therefore `nan` and `inf` outputs are sample failures, not backend failures. A backend must not be marked invalid only because the sample ratio was non-finite.

0.4.7 distinguishes:

- `SAMPLE_INVALID`
- `SAMPLE_INVALID_BASELINE_TOO_LOW`
- `SAMPLE_INVALID_ACTIVE_TOO_LOW`
- `SAMPLE_INVALID_RATIO_NOT_FINITE`
- `BACKEND_NO_EFFECT`
- `BACKEND_WRITE_REJECTED`
- `BACKEND_ENGINE_OVERWRITTEN`
- `BACKEND_CONFIRMED`

## 0.4.7 correction

0.4.7 cancels automatic timed baseline start. It waits until the player is actually moving in a stable mode, samples a per-candidate baseline, blocks divide-by-zero, and refuses to emit `nan` or `inf`.

```

## BUILD_MARKER.txt

- SHA-256: `3AD4A6D84F55022AA3574F29960EB4D305F129CBA04956C6A968EF0FA2B93806`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_046_DIRECT_SPEED_A

```

## CHANGELOG.md

- SHA-256: `C74AEB3BD5FD56A6918DB031D480AFF2B2ED8BE32B858B26BBDD58DEA8D19C5F`
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

## DIRECT_SPEED_FEASIBILITY_TEST_0.4.6.md

- SHA-256: `D4EDA3231C150D2F21FEE8CA22B91238284DA3956369F11E0EC736E55C0881D7`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Direct Speed Feasibility Test 0.4.6

## Setup

1. Disable or remove 0.4.5.
2. Enable only 0.4.6.
3. Fully restart Project Zomboid.
4. Load a 0.4.4/0.4.5-created test character or create a new character with Distance Runner.
5. Confirm the character panel still shows the yellow F icon.
6. Move to a clear straight road.
7. Keep inventory light.

## Test Action

Hold straight movement and run input. Do not turn, attack, aim, climb, enter a vehicle, collide, or change floor.

0.4.6 automatically runs:

1. Wait stable movement for 1 second.
2. Baseline sample for 2 seconds.
3. Candidate sample for 2 seconds.
4. Reset original value.
5. Reset gap for 1 second.
6. Continue to next candidate.

If any candidate reaches ratio >= 1.50, testing stops on that candidate, keeps it active for 10 seconds, then resets.

## Logs

```text
[XNP DIRECT TEST] candidate begin id=<id>
[XNP DIRECT TEST] original_value=<value>
[XNP DIRECT TEST] requested_value=<value>
[XNP DIRECT TEST] readback_value=<value>
[XNP DIRECT TEST] baseline_tps=<value>
[XNP DIRECT TEST] active_tps=<value>
[XNP DIRECT TEST] ratio=<value>
[XNP DIRECT TEST] candidate result=<CONFIRMED_X3_WORLD_SPEED/PARTIAL_WORLD_SPEED_EFFECT/NO_WORLD_SPEED_EFFECT/INVALID_OR_UNSAFE>
[XNP DIRECT TEST] candidate reset readback=<value>
```

## Results

- ratio >= 2.50: `CONFIRMED_X3_WORLD_SPEED`
- ratio >= 1.50 and < 2.50: `PARTIAL_WORLD_SPEED_EFFECT`
- ratio >= 0.85 and < 1.50: `NO_WORLD_SPEED_EFFECT`
- ratio invalid or > 4.5: `INVALID_OR_UNSAFE`

## No-Trait Control

With a character that does not have Distance Runner:

- No endurance isolation.
- No candidate writes.
- No direct test HUD.
- Native movement should remain unchanged.

```

## FINAL_REPORT.md

- SHA-256: `30D92FD2BB9FFF76373AC417B07FDBB915502E7A455CBE0BF3D95CBF7064A225`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.6

## Required Fields

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.6`
- INTERNAL_VERSION: `0.4.6-b42-direct-speed-feasibility-a`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_046_DIRECT_SPEED_A`
- TRAIT_FULL_ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- NATIVE_TRAIT_PIPELINE_CHANGED: `NO`
- NATIVE_ICON_PIPELINE_CHANGED: `NO`
- ICON_RUNTIME_RESULT: `PASS_BY_USER_REAL_TEST_0.4.5`
- 0.4.5_NO_EFFECT_ROOT_CAUSE: `SPEED_WRITE_ATTEMPTED=NO because SELECTED_WORLD_SPEED_BACKEND=NONE_CONFIRMED`
- DIRECT_SPEED_FEASIBILITY_MODE: `YES`
- DIRECT_TEST_FACTOR: `3.00`
- ENDURANCE_ISOLATION_STATUS: `ON_IF_API_AVAILABLE`
- ENDURANCE_API: `player:getStats():get(CharacterStat.ENDURANCE)` and `player:getStats():set(CharacterStat.ENDURANCE, value)`
- Found candidate count: `5`
- Implemented candidate count: `5`
- getMoveSpeed/setMoveSpeed status: `KNOWN_FAILED_CONTROL_ONLY`
- WORLD_DISPLACEMENT_PROBE_STATUS: `IMPLEMENTED_IN_DIRECT_HARNESS`
- WALK_TEST_IMPLEMENTED: `YES, movement mode logged per candidate`
- RUN_TEST_IMPLEMENTED: `YES, running/sprinting state logged per candidate`
- RESET_LOG_SPAM_FIXED: `YES`
- Coordinates modified: `NO`
- Global time modified: `NO`
- No-trait character modified: `NO`
- FORMAL_GAMEPLAY_ENABLED: `NO`

## Candidates

| id | Evidence | Reset |
|---|---|---|
| `speed_mod` | `IsoGameCharacter getSpeedMod/setSpeedMod` from local B42.19 jar | `setSpeedMod(original_value)` |
| `path_speed` | `IsoPlayer getPathSpeed/setPathSpeed` from local B42.19 jar | `setPathSpeed(original_value)` |
| `combat_speed` | `IsoPlayer getCombatSpeed/setCombatSpeed` from local B42.19 jar | `setCombatSpeed(original_value)` |
| `anim_walk_speed_variable` | Vanilla debug UI reads `WalkSpeed`; `IsoGameCharacter setVariable(String,float)` exists | `setVariable("WalkSpeed", original_value)` |
| `move_speed_failed_control` | `IsoPlayer getMoveSpeed/setMoveSpeed`; 0.4.4/0.4.5 showed no confirmed world displacement | `setMoveSpeed(original_value)` |

## Runtime Behavior

- Enters `DIRECT_SPEED_TEST_ACTIVE` immediately after native trait detection.
- Waits 1 second for stable movement.
- Samples baseline TPS for 2 seconds.
- Applies one candidate using `target = original_value * 3.00`.
- Samples active TPS for 2 seconds.
- Computes ratio from actual `getX/getY` world displacement.
- Resets candidate before moving to the next candidate.
- Stops on first ratio >= 1.50, holds it for 10 seconds, then resets.

## Counts

- Lua files: `19`
- Lua total lines: `2046`
- Documentation files: `24`
- Total files: `48`

## Static Check

- JSON parse: `PASS`
- Lua text balance: `PASS`
- B42 script brace balance: `PASS`
- Text BOM/NULL/empty scan: `PASS`
- Runtime identity stale 0.4.5 scan: `PASS`
- TraitFactory calls: `NO`, only old API probe log text remains.
- Skill Core / Unlock / ModData fake trait: `ABSENT`

## Install / Run Safety

- Installed by Codex: `NO`
- Game started: `NO`
- Steam started: `NO`
- Modi
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `95DA3A5A6C1BE79E9EEBFB0315ABB20AC7BA163B73F020470C9345E5D059B534`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.6 Direct Speed Test

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨勯殧绂诲疄楠岀増銆傚畠涓嶅疄鐜版寮?Distance Runner 鐜╂硶锛屽彧楠岃瘉鍝簺鏈満 B42.19 Lua 鍙皟鐢ㄥ悗绔兘鐪熷疄鏀瑰彉鐜╁涓栫晫鍧愭爣浣嶇Щ閫熷害銆?
## 韬唤

- Version: `0.4.6`
- Internal version: `0.4.6-b42-direct-speed-feasibility-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_046_DIRECT_SPEED_A`
- Display name: `XNP Distance Runner Trait 0.4.6 Direct Speed Test`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 鍐荤粨鎴愬姛鍐呭

- Native trait pipeline: unchanged.
- Native icon pipeline: unchanged.
- Texture: `media/ui/Traits/trait_xnpdistancerunner.png`
- 0.4.4/0.4.5 created character compatibility: expected, because Mod ID and trait full ID are unchanged.

## 0.4.6 Direct Test

- DIRECT_SPEED_FEASIBILITY_MODE: `YES`
- FORMAL_DISTANCE_RUNNER_GAMEPLAY_ENABLED: `NO`
- EXPERIMENTAL_TEST_ONLY: `YES`
- PRODUCTION_READY: `NO`
- DIRECT_TEST_FACTOR: `3.00`

Implemented candidates:

- `speed_mod`
- `path_speed`
- `combat_speed`
- `anim_walk_speed_variable`
- `move_speed_failed_control`

The last candidate is a known failed control, not the preferred backend.

## Test

See `DIRECT_SPEED_FEASIBILITY_TEST_0.4.6.md`.

```

## STATIC_AUDIT.md

- SHA-256: `ABA9C5F9D7D4673D869147EDDF977129D34CCE225FD5C8DC6D6372A005F0498A`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.6

## Scope

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.6`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_046_DIRECT_SPEED_A`

## Counts

- Total files: `48`
- Lua files: `19`
- Lua total lines: `2046`
- Documentation files: `24`
- JSON files: `2`
- PNG files: `1`

## Frozen Pipelines

- NATIVE_TRAIT_PIPELINE_CHANGED: `NO`
- NATIVE_ICON_PIPELINE_CHANGED: `NO`
- Mod ID unchanged: `PASS`
- Trait full ID unchanged: `PASS`
- Texture path unchanged from successful 0.4.5: `media/ui/Traits/trait_xnpdistancerunner.png`

## Direct Speed Mode

- DIRECT_SPEED_FEASIBILITY_MODE: `YES`
- EXPERIMENTAL_TEST_ONLY: `YES`
- PRODUCTION_READY: `NO`
- FORMAL_DISTANCE_RUNNER_GAMEPLAY_ENABLED: `NO`
- DIRECT_TEST_FACTOR: `3.00`
- Harness file: `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_DirectSpeedBackendHarness.lua`
- Minimal diagnostic HUD draw: `Events.OnPostUIDraw` / `getTextManager():DrawString`

## Candidates

- Found candidates: `5`
- Implemented candidates: `5`
- `speed_mod`: `getSpeedMod` / `setSpeedMod`
- `path_speed`: `getPathSpeed` / `setPathSpeed`
- `combat_speed`: `getCombatSpeed` / `setCombatSpeed`
- `anim_walk_speed_variable`: `getVariableFloat("WalkSpeed", 0)` / `setVariable("WalkSpeed", value)`
- `move_speed_failed_control`: `getMoveSpeed` / `setMoveSpeed`, known failed control only.

## Safety

- Direct coordinate writes: `ABSENT`
- Teleport acceleration: `ABSENT`
- Global time speed changes: `ABSENT`
- No-trait character writes: guarded by native trait check.
- Reset log spam fix: `PASS`
- Reset target uses `original_value * 1`, never `current_value / factor`.
- Each candidate stores original value before write.
- Each candidate resets before the next candidate.

## Checks

- JSON parse: `PASS`
- Lua text parentheses/quote balance: `PASS`
- B42 script brace balance: `PASS`
- Text BOM/NULL/empty scan: `PASS`
- Runtime identity stale 0.4.5 scan: `PASS`
- Lua execution parse: `NOT_VERIFIABLE`

## NOT_VERIFIABLE

- Actual candidate TPS ratio: `REAL_GAME_TEST_REQUIRED_BY_USER`
- Whether any candidate affects world displacement: `REAL_GAME_TEST_REQUIRED_BY_USER`
- Whether endurance isolation succeeds in game: `REAL_GAME_TEST_REQUIRED_BY_USER`

## Static Result

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.6_SOURCE_READY_FOR_DIRECT_SPEED_FEASIBILITY_TEST`

```
