# 0.4.5 Sanitized Evidence Excerpts

## BUILD_MARKER.txt

- SHA-256: `287709EAC3B99BF704B8FA251ED086168B959941DC1D0E7A8CCCFB27E134446A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_045_ICON_WORLD_SPEED_A

```

## CHANGELOG.md

- SHA-256: `CA35E0E0BF2C1755EAB7BEE629BFCB2260FBD2DC0E46E69B61DBD440EC00C50B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

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
- Movement, XP, metabolism, fatigue, and X3 gameplay formulas are unchanged from 0.4.3.

## 0.4.3 - B42 Runtime Trait Bind Fix A

- Kept the successful B42 script definition backend from 0.4.2.
- Fixed definition verification to pass `CharacterTrait` objects to `CharacterTraitDefinition.getCharacterTraitDefinition`.
- Removed direct String and ResourceLocation definition verifier calls.
- Fixed runtime player detection to prefer `player:hasTrait(CharacterTrait)`.
- Added one-time player trait collection dump with `[XNP TRAIT BIND]` logs.
- Fixed translations to vanilla B42 paths:
  - `42\media\lua\shared\translate\EN\UI.json`
  - `42\media\lua\shared\translate\CN\UI.json`
- Added runtime activation logs for native trait detection and X3 readiness.
- Added movement write/readback diagnostics for X3 apply/reset transitions.
- Added temporary non-interactive status text values.

## 0.4.2 - B42 Native Trait API Fix A

- Proved native character creation visibility through `character_trait_definition`.
- Real game result: trait visible and selectable.
- Runtime binding failed because verifier passed ResourceLocation
[EXCERPT_TRUNCATED]
```

## FINAL_REPORT.md

- SHA-256: `861208CE81BB9DA78591AF2E4C4674D2CDC4663615D6F787480EE4EF8F99D318`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.5

## Required Fields

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.5`
- INTERNAL_VERSION: `0.4.5-b42-native-icon-world-speed-fix-a`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_045_ICON_WORLD_SPEED_A`
- MOD_ID: `XNP_PZ_DistanceRunnerTrait`
- TRAIT_FULL_ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- 0.4.4_TRAIT_COMMIT_RESULT: `PASS`
- 0.4.4_RUNTIME_BIND_RESULT: `PASS`
- 0.4.4_ICON_RESULT: `FAIL`
- 0.4.4_MOVEMENT_BACKEND_RESULT: `GET_SET_MOVE_SPEED_READBACK_PASS_WORLD_DISPLACEMENT_UNCONFIRMED`
- NATIVE_TRAIT_PIPELINE_CHANGED: `NO`

## Icon Result

- CONFIRMED_ICON_FIELD: `Texture`
- CONFIRMED_ICON_DIRECTORY: `media/ui/Traits`
- CONFIRMED_ICON_FILENAME: `trait_xnpdistancerunner.png`
- CONFIRMED_ICON_VALUE: `media/ui/Traits/trait_xnpdistancerunner.png`
- ICON_TEXTURE_RUNTIME_RESOLVED: `REAL_GAME_TEST_REQUIRED_BY_USER`
- SOURCE_ICON_PATH: `[LOCAL_PATH_REDACTED]`
- SOURCE_ICON_SHA256: `EEC5EC1056A03508C2DCAFB07A1521F41376CF987995D9CA8987098B67612B7C`
- GENERATED_ICON_SHA256: `8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9`

## Movement Result

- BACKEND_GET_SET_MOVE_SPEED_STATUS: `REJECTED_FOR_WORLD_SPEED`
- FINAL_WORLD_DISPLACEMENT_CALCULATION: `distance += sqrt(dx*dx + dy*dy); tiles_per_second = distance / elapsed_seconds`
- SELECTED_WORLD_SPEED_BACKEND: `NONE_CONFIRMED`
- BACKEND_EVIDENCE: `No local B42.19 evidence proved a safe writable, resettable player-only world displacement speed multiplier.`
- BACKEND_RESET_METHOD: `NOT_APPLICABLE`
- WORLD_DISPLACEMENT_PROBE_IMPLEMENTED: `YES`
- BASELINE_SAMPLE_DURATION: `1.50`
- ACTIVE_SAMPLE_DURATION: `1.50 requested by spec, not executed without a confirmed backend`
- WORLD_SPEED_RATIO_EXPECTED: `>=2.50 for future X3 confirmation`
- BLOCKER: `BLOCKER_B42_WORLD_MOVEMENT_BACKEND_UNCONFIRMED`

## Runtime Flags

- CREATION_COMMIT_PROBE_REDUCED: `YES`
- RUNTIME_GAMEPLAY_FORMULAS_CHANGED: `YES, movement backend writes removed; metabolism/fatigue/XP retained`
- Compatible with 0.4.4-created character: `YES, Mod ID and trait full ID unchanged`
- Installation success: `NO, source-only round`
- Game started: `NO`
- Steam started: `NO`
- Old SOURCE modified: `NO`
- Game directory written: `NO`
- User mods/saves/workshop written: `NO`

## Counts

- Lua files: `18`
- Lua total lines: `1567`
- Documentation files: `22`
- Total files: `45`

## Static Check

- JSON parse: `PASS`
- Lua text balance: `PASS`
- B42 script brace balance: `PASS`
- Text BOM/NULL/empty scan: `PASS`
- Forbidden `setMoveSpeed` runtime write calls: `ABSENT`
- Forbidden post-spawn trait grant: `ABSENT`
- Forbidden ModData fake trait: `ABSENT`

## File Tree

```text
0.4.2_RUNTIME_FAILURE_ANALYSIS.md
0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
42\media\lua\clien
[EXCERPT_TRUNCATED]
```

## NATIVE_ICON_WORLD_SPEED_TEST_0.4.5.md

- SHA-256: `29593824FCDC2904C2C067267495644C7A087561A73EA6230AB4378D97B07382`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Native Icon + World Speed Test 0.4.5

## Setup

1. Disable or remove 0.4.4.
2. Enable only 0.4.5.
3. Fully restart Project Zomboid.
4. Do not load the save without 0.4.4 or 0.4.5 enabled, because the canonical trait ID must remain available.

## Icon Test

1. Open new character creation.
2. Confirm Distance Runner shows the yellow F icon in the available trait list.
3. Select it.
4. Confirm the selected trait list also shows the yellow F icon.
5. Return to menu if only testing creation UI.
6. Load the 0.4.4-created test character with 0.4.5 enabled.
7. Open the character info panel.
8. Confirm the trait area shows the yellow F icon.

Expected icon logs:

```text
[XNP ICON] requested_name=media/ui/Traits/trait_xnpdistancerunner.png
[XNP ICON] resolved=true
[XNP ICON] width=18
[XNP ICON] height=18
[XNP ICON] definition_icon_value=<value>
```

## World Displacement Test

1. Move to an unobstructed straight road.
2. Hold straight run input without turning.
3. Wait for the baseline probe to complete.
4. Read the console logs.

Expected 0.4.5 status:

```text
[XNP WORLD SPEED TEST] baseline_begin
[XNP WORLD SPEED TEST] baseline_distance=<n> elapsed=<n> tiles_per_second=<n>
[XNP WORLD SPEED TEST] active_begin backend=NONE_CONFIRMED factor=3.00
[XNP WORLD SPEED TEST] sample rejected reason=BLOCKER_B42_WORLD_MOVEMENT_BACKEND_UNCONFIRMED
[XNP WORLD SPEED TEST] ratio=NOT_AVAILABLE
```

0.4.5 does not claim X3 success. A future version may only claim success when `WORLD_SPEED_RATIO >= 2.50` from real coordinate displacement.

## Acceptance

- Native icon visible in creation list: `PASS_REQUIRED`
- Native icon visible in selected list: `PASS_REQUIRED`
- Native icon visible in character panel: `PASS_REQUIRED`
- World displacement measurement exists: `PASS_REQUIRED`
- World speed backend: `BLOCKED_EXPECTED_IN_0.4.5`

```

## README_CN.md

- SHA-256: `1446ACCE207BAF6C6D8AACA5FE0A338E7EC83E1838DA165EDB7E1EC23EE35CF1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.5 Native Icon + World Speed Fix

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨?source-only 璇婃柇鐗堟湰銆?.4.5 淇濇寔 0.4.4 宸茬粡瀹炴満閫氳繃鐨?native trait 閾撅紝涓嶆敼鍙?Mod ID锛屼笉鏀瑰彉 trait full ID銆?
## 韬唤

- Version: `0.4.5`
- Internal version: `0.4.5-b42-native-icon-world-speed-fix-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_045_ICON_WORLD_SPEED_A`
- Display name: `XNP Distance Runner Trait 0.4.5 Native Icon + World Speed Fix`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 鍐荤粨缁撹

- 0.4.4 trait definition: `PASS`
- 0.4.4 translation: `PASS`
- 0.4.4 character creation visible/cost/commit: `PASS`
- 0.4.4 player native trait collection: `PASS`
- 0.4.4 runtime activation: `PASS`
- 0.4.4 native trait icon: `FAIL`
- 0.4.4 movement backend: `GET_SET_MOVE_SPEED_READBACK_PASS_WORLD_DISPLACEMENT_UNCONFIRMED`

## 0.4.5 淇

- `Texture = media/ui/Traits/trait_xnpdistancerunner.png`
- 鍥炬爣鏂囦欢淇濈暀锛歚42\media\ui\Traits\trait_xnpdistancerunner.png`
- 鏂板鍥炬爣瑙ｆ瀽鏃ュ織锛歚[XNP ICON] ...`
- `getMoveSpeed/setMoveSpeed` 涓嶅啀浣滀负姝ｅ紡鍚庣鍐欏叆銆?- 鏂板涓栫晫鍧愭爣浣嶇Щ鎺㈤拡锛歚XNP_DR_WorldDisplacementProbe.lua`
- 鍥犳病鏈夊畨鍏ㄥ彲澶嶄綅鐨?B42.19 涓栫晫绉婚€熷悗绔瘉鎹紝X3 鍐欏叆琚樆鏂€?
## 鎵嬪姩娴嬭瘯

璇﹁ `NATIVE_ICON_WORLD_SPEED_TEST_0.4.5.md`銆?
棰勬湡鍥炬爣鏃ュ織锛?
```text
[XNP ICON] requested_name=media/ui/Traits/trait_xnpdistancerunner.png
[XNP ICON] resolved=true
[XNP ICON] width=18
[XNP ICON] height=18
```

棰勬湡绉婚€熺姸鎬侊細

```text
BACKEND_GET_SET_MOVE_SPEED=REJECTED_FOR_WORLD_SPEED
SELECTED_WORLD_SPEED_BACKEND=NONE_CONFIRMED
BLOCKER_B42_WORLD_MOVEMENT_BACKEND_UNCONFIRMED
```

## 绂佹椤?
- 涓嶅啓鍏ユ父鎴忕洰褰曘€?- 涓嶅啓鍏ョ敤鎴?saves/mods 鐩綍銆?- 涓嶄笂浼?Workshop銆?- 涓嶅惎鍔?Steam / ProjectZomboid銆?- 涓嶇敤 TraitFactory銆?- 涓嶆仮澶?Skill Core / Unlock / Second Wind銆?- 涓嶇敤 ModData 浼€?trait銆?- 涓嶅仛 post-spawn dynamic trait grant銆?- 涓嶇敤淇敼鍧愭爣鎴?teleport 鍋囪鍔犻€熴€?
```

## STATIC_AUDIT.md

- SHA-256: `7F6BE38A7B5F6E4B32ACF23F0329BBE94CFE3222D3C8D5CA220031BBF33EC199`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.5

## Scope

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.5`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_045_ICON_WORLD_SPEED_A`

## Counts

- Total files: `45`
- Lua files: `18`
- Lua total lines: `1567`
- Documentation files: `22`
- JSON files: `2`
- PNG files: `1`

## Frozen Native Trait Pipeline

- Mod ID unchanged: `PASS`
- Trait full ID unchanged: `PASS`
- B42 script definition backend retained: `PASS`
- `42\media\registries.lua` retained: `PASS`
- Creation commit wrapper reduced: `PASS`
- Post-spawn dynamic trait grant: `ABSENT`
- ModData fake trait: `ABSENT`

## Icon

- CONFIRMED_ICON_FIELD: `Texture`
- CONFIRMED_ICON_DIRECTORY: `media/ui/Traits`
- CONFIRMED_ICON_FILENAME: `trait_xnpdistancerunner.png`
- CONFIRMED_ICON_VALUE: `media/ui/Traits/trait_xnpdistancerunner.png`
- Icon probe implemented: `PASS`
- ICON_TEXTURE_RUNTIME_RESOLVED: `NOT_VERIFIABLE_BY_STATIC_AUDIT`

## Movement

- BACKEND_GET_SET_MOVE_SPEED_STATUS: `REJECTED_FOR_WORLD_SPEED`
- `setMoveSpeed(` runtime write calls: `ABSENT`
- `getMoveSpeed(` backend reads: `ABSENT`
- SELECTED_WORLD_SPEED_BACKEND: `NONE_CONFIRMED`
- WORLD_DISPLACEMENT_PROBE_IMPLEMENTED: `PASS`
- Direct player coordinate modification: `ABSENT`
- Teleport-style acceleration: `ABSENT`
- BLOCKER: `BLOCKER_B42_WORLD_MOVEMENT_BACKEND_UNCONFIRMED`

## Text Checks

- JSON parse: `PASS`
- B42 trait script brace balance: `PASS`
- Lua text parentheses/quote balance: `PASS`
- Empty files: `PASS`
- Text BOM/NULL scan: `PASS`
- Lua 5.1 execution parse: `NOT_VERIFIABLE`

## NOT_VERIFIABLE

- Native icon resolved in actual UI: `REAL_GAME_TEST_REQUIRED_BY_USER`
- Character panel icon visible for 0.4.4-created character: `REAL_GAME_TEST_REQUIRED_BY_USER`
- World speed backend: `BLOCKED_UNCONFIRMED`
- X3 world displacement ratio: `NOT_AVAILABLE`

## Static Result

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.5_ICON_READY_WORLD_SPEED_BACKEND_BLOCKED`

```
