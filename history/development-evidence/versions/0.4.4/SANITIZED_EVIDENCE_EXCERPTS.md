# 0.4.4 Sanitized Evidence Excerpts

## 0.4.4_MOVEMENT_BACKEND_FAILURE_ANALYSIS.md

- SHA-256: `F9C28437C8B4145B550FB078C246439F1F39109BA828BEB096F1468CBD79AB71`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.4.4 Movement Backend Failure Analysis

## 0.4.4 Real Result

- API_BASE_VALUE: `0.05999999865889549`
- API_WRITTEN_VALUE: `0.17999999597668648`
- API_READBACK_VALUE: `0.17999999225139618`
- RESET_READBACK: `0.019999999552965164`

## Conclusion

- GETMOVESPEED_SETMOVESPEED_READBACK: `PASS`
- GETMOVESPEED_SETMOVESPEED_WORLD_DISPLACEMENT: `FAIL_OR_UNCONFIRMED`
- CURRENT_MOVEMENT_BACKEND_PRODUCTION_READY: `NO`
- BACKEND_GET_SET_MOVE_SPEED: `REJECTED_FOR_WORLD_SPEED`

## Reason

The setter accepted a value and the getter read it back, but there was no measured world coordinate displacement confirming real X3 speed. The read value also changed with running and stopped state, which means it is not a stable baseline for recursive multiplication or safe restoration.

## 0.4.5 Action

- `player:setMoveSpeed(...)` is not called by the production movement module.
- Stop/load/death/menu cleanup no longer tries to restore that field.
- Read-only displacement sampling uses `player:getX()` and `player:getY()`.
- A new speed backend remains blocked until B42.19 evidence proves a writable, resettable world-displacement input.

```

## BUILD_MARKER.txt

- SHA-256: `0E74D1E8DD13D0233CBB5FCA67BA419F63FB1BB74BD188F5AEB206A45DC24D2F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_044_CREATION_COMMIT_ICON_A

```

## CHANGELOG.md

- SHA-256: `8BAE66A081A4F8403A7F2DEE18B529486C00189998853765CC8A5BB43C79A4D0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

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
- Runtime binding failed because verifier passed ResourceLocation/String to an API that expected CharacterTrait.

```

## FINAL_REPORT.md

- SHA-256: `9A9E6AE20D3C5FDD1ECC62B530242F12F5558E900F741EE29E8952EAD28BECD4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.4

## Required Fields

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.4`
- INTERNAL_VERSION: `0.4.4-b42-creation-commit-icon-fix-a`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_044_CREATION_COMMIT_ICON_A`
- MOD_ID: `XNP_PZ_DistanceRunnerTrait`
- TRAIT_BARE_ID: `XNPDistanceRunner`
- TRAIT_FULL_ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- DISPLAY_NAME: `XNP Distance Runner Trait 0.4.4 Creation Commit + Icon Fix`

## Frozen 0.4.3 Result

- TRAIT_DEFINITION_REGISTERED: `PASS`
- TRAIT_VISIBLE_IN_CREATION_UI: `PASS`
- TRAIT_SELECTABLE_AND_COSTED: `PASS`
- CHARACTER_CREATION_COMMIT: `FAIL`
- PLAYER_NATIVE_TRAIT_COLLECTION: `ABSENT`
- RUNTIME_ACTIVATION: `BLOCKED`
- MOVEMENT_EFFECT_NOT_TESTED: `YES`

## B42 Creation Commit Audit

- VANILLA_STOUT_PIPELINE: `definition -> creation UI selected list -> CharacterCreationProfession.initWorld -> getWorld():addLuaTrait(v.item:getType()) -> spawned player known trait collection`
- XNP_0.4.3_PIPELINE: `definition and UI pass, spawned player native trait collection absent`
- FIRST_DIVERGENCE_POINT: `between selected trait UI list and native world/player trait payload`
- CONFIRMED_ROOT_CAUSE: `not a definition, translation, TraitFactory, or movement backend failure; commit from creation selection to native payload was not verified and failed in real 0.4.3 test`
- SELECTED_COMMIT_FIX: `pre-spawn CharacterCreationProfession initWorld probe and native world payload guard`

## 0.4.4 Commit Probe

- CHECKPOINT_A_IMPLEMENTED: `YES`
- CHECKPOINT_B_IMPLEMENTED: `YES`
- CHECKPOINT_C_IMPLEMENTED: `YES`
- CHECKPOINT_D_IMPLEMENTED: `YES`
- PROBE_FILE: `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua`
- Uses post-spawn dynamic trait grant: `NO`
- Uses ModData fake trait: `NO`
- Uses default grant: `NO`
- Uses TraitFactory: `NO`
- Uses SkillCore/Unlock/Second Wind: `NO`

## Icon

- SOURCE_ICON_PATH: `[LOCAL_PATH_REDACTED]`
- SOURCE_ICON_SIZE: `32x32`
- SOURCE_ICON_SHA256: `EEC5EC1056A03508C2DCAFB07A1521F41376CF987995D9CA8987098B67612B7C`
- ICON_ASSET_OUTPUT_PATH: `42\media\ui\Traits\trait_xnpdistancerunner.png`
- ICON_ASSET_SIZE: `18x18`
- ICON_ASSET_SHA256: `8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9`
- ICON_DEFINITION_FIELD: `Texture = trait_xnpdistancerunner`
- NATIVE_CHARACTER_PANEL_ICON_EXPECTED: `YES`
- ICON_RUNTIME_DISPLAY: `NOT_VERIFIABLE_BY_STATIC_AUDIT`

## Runtime / Movement

- RUNTIME_GAMEPLAY_FORMULAS_CHANGED: `NO`
- MOVEMENT_BACKEND_CHANGED: `NO`
- MOVEMENT_TEST_FACTOR: `3.00`
- VALID_RUN_TRIGGER_SECONDS: `0.50`
- STOP_RESET_DELAY_SECONDS: `1.00`
- Expected active marker: `XNP DR X3 ACTIVE`
- Expected ready marker: `XNP DR X3 READY`

## Static Counts

- Total files: `39`
- Lua file count: `16`
- Lua total lines: `1545`
- Documentation file count: `18`
- JSON file count: `2`
- PNG file count: `1`

## File Tree

```text
0.4.2_RUNTIME_FAILURE_ANALYSIS.md
42\media\lua\client\XNP_PZ_Distance
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `ABFCD3F2B7EB4B4DE8D24AB962522A6B24869FC3923C34CDB215AA6F60FD347A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.4 Creation Commit + Icon Fix

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

杩欐槸 Project Zomboid Build 42.19.0 鐨?source-only 璇婃柇鐗堟湰銆?.4.4 涓嶅洖閫€鍒?TraitFactory锛屼笉鎭㈠ XNP SkillCore锛屼笉鍔犲叆 Unlock/Second Wind锛屼篃涓嶅仛鍑虹敓鍚庤ˉ鍙戠壒璐ㄣ€?
## 韬唤

- Version: `0.4.4`
- Internal version: `0.4.4-b42-creation-commit-icon-fix-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_044_CREATION_COMMIT_ICON_A`
- Display name: `XNP Distance Runner Trait 0.4.4 Creation Commit + Icon Fix`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Script module: `XNPDistanceRunnerTrait`
- Trait bare ID: `XNPDistanceRunner`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 鍐荤粨缁撹

- 0.4.3 宸茶瘉鏄庯細trait definition 娉ㄥ唽鎴愬姛銆?- 0.4.3 宸茶瘉鏄庯細瑙掕壊鍒涘缓 UI 鍙銆佸彲閫夈€佹墸鐐广€?- 0.4.3 宸茶瘉鏄庯細EN/CN 缈昏瘧璺緞鍙敤銆?- 0.4.3 瀹炴満澶辫触鐐癸細杩涘叆涓栫晫鍚庣帺瀹?native trait collection 娌℃湁 `XNPDistanceRunnerTrait:XNPDistanceRunner`銆?- 鍥犳 0.4.4 涓嶅啀浼樺厛鎬€鐤戝畾涔夈€佺炕璇戙€乀raitFactory銆乵ovement factor 鎴栬繍琛屾椂 false negative銆?
## 0.4.4 鐩爣

- 瀹¤骞舵帰娴?B42 瑙掕壊鍒涘缓 selected trait 鍒?native payload 鐨勬彁浜ら摼銆?- 澧炲姞 checkpoint A/B/C/D 鏃ュ織銆?- 濡傛灉鍒涘缓鍓?UI 宸查€夋嫨 XNP锛屼絾 vanilla `initWorld` 鍚?native world payload 涓㈠け瀹冿紝鍒欏湪鍑虹敓鍓嶆妸 canonical CharacterTrait object 鍐欏叆 `getWorld():addLuaTrait`銆?- 澧炲姞 native trait icon 璧勬簮涓庡畾涔夊瓧娈点€?- 淇濇寔 X3 杩愯鍏紡涓?movement backend 涓嶅彉銆?
## 鍏抽敭鏂囦欢

- `42\media\scripts\XNPDistanceRunnerTraits.txt`
- `42\media\registries.lua`
- `42\media\ui\Traits\trait_xnpdistancerunner.png`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CharacterCreationCommitProbe.lua`
- `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TraitRegistration.lua`
- `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Trait.lua`
- `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Movement.lua`

## 鎵嬪姩娴嬭瘯鐩爣

1. 鍙惎鐢?0.4.4銆?2. 鍒涘缓瑙掕壊鏃堕€夋嫨 `Distance Runner`銆?3. 杩涘叆涓栫晫鍚庢煡鐪?`[XNP CREATION COMMIT]` 鏃ュ織銆?4. 鏈熸湜锛?   - `target_present_at_A=true`
   - `target_present_at_B=true`
   - `target_present_at_C=true`
   - `target_present_at_D=true`
5. 鎵撳紑瑙掕壊淇℃伅闈㈡澘锛屾鏌?trait icon 鏄惁鏄剧ず銆?6. 濡傛灉 D 鎴愬姛锛屽啀娴嬭瘯 X3 杩愯鏁堟灉銆?
## 绂佹椤?
- 涓嶅啓鍏ユ父鎴忕洰褰曘€?- 涓嶅啓鍏ョ敤鎴?saves/mods 鐩綍銆?- 涓嶄笂浼?Workshop銆?- 涓嶅惎鍔?Steam / ProjectZomboid銆?- 涓嶇敤 ModData 浼€?trait銆?- 涓嶅仛 post-spawn dynamic trait grant銆?
```

## TRAIT_COMMIT_ICON_X3_TEST_0.4.4.md

- SHA-256: `C4523344D1F5D605F3E62642F475CFA9836F90124B25640E537AB5A844425519`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# TRAIT COMMIT ICON X3 TEST 0.4.4

`OLD_0.4.3_CHARACTER_NOT_VALID_FOR_0.4.4_COMMIT_TEST`

Use a newly created 0.4.4 character. Do not judge 0.4.4 using the old 0.4.3 character because its native trait collection did not contain XNP Distance Runner.

## Steps

1. Disable or move out 0.4.0, 0.4.1, 0.4.2, and 0.4.3.
2. Enable only 0.4.4.
3. Fully quit and restart the game.
4. Create a new character.
5. Select Lumberjack.
6. Select Stout.
7. Select Distance Runner / 闀块€斿琚€?
8. Confirm one point is spent.
9. Confirm creation UI displays the F icon.
10. Create the character.
11. Enter the world.
12. Open the character info panel.
13. Confirm the trait area displays the yellow F icon.
14. Confirm logs contain `xnpdistancerunnertrait:xnpdistancerunner`.
15. Run continuously for more than 0.5 seconds.
16. Verify X3.
17. Stop for more than 1.0 second.
18. Verify reset.
19. Save and quit.
20. Reload the save.
21. Confirm F icon, native trait, and runtime still exist.

## Expected New Character Trait Dump

```text
[XNP TRAIT BIND] player trait dump begin count=3
[XNP TRAIT BIND] canonical_id=base:axeman
[XNP TRAIT BIND] canonical_id=base:stout
[XNP TRAIT BIND] canonical_id=xnpdistancerunnertrait:xnpdistancerunner
[XNP CREATION COMMIT] target_present_at_D=true
```

## Negative Control

Create another character without Distance Runner:

- no F icon
- no X3
- no runtime activation

```

## STATIC_AUDIT.md

- SHA-256: `F80EB44F14B581B47D9573CF8323E5FE0AAFE644396CBEE39967A5BEBB609C57`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.4

## Scope

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.4`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_044_CREATION_COMMIT_ICON_A`

## Counts

- Total files: `39`
- Lua files: `16`
- Lua total lines: `1545`
- Documentation files: `18`
- JSON files: `2`
- PNG files: `1`

## Frozen 0.4.3 Successes

- Backend C script definition retained: `PASS`
- `42\media\scripts\XNPDistanceRunnerTraits.txt` retained as definition backend: `PASS`
- `42\media\registries.lua` retained: `PASS`
- `CharacterTrait.register` retained: `PASS`
- `CharacterTrait.get(ResourceLocation)` retained: `PASS`
- `CharacterTraitDefinition.getCharacterTraitDefinition(CharacterTrait)` retained: `PASS`
- EN/CN translation path retained: `PASS`
- Cost remains 1: `PASS`
- Positive classification retained: `PASS`

## 0.4.4 Changes

- Added creation commit probe: `PASS`
- Added checkpoint A/B/C/D logging: `PASS`
- Added pre-spawn native world payload guard: `PASS`
- Added native icon asset: `PASS`
- Added definition texture field: `PASS`
- Reduced missing-player-trait log spam: `PASS`

## Forbidden Pattern Scan

- TraitFactory API calls: `PASS`
- Post-spawn add trait fallback: `PASS`
- ModData fake trait: `PASS`
- Default grant: `PASS`
- SkillCore / Unlock / Second Wind: `PASS`
- Runtime movement formula changes: `PASS`
- Workshop upload scripts: `PASS`
- Game directory writes: `PASS`

## Event / State Audit

- Duplicate `AddPlayerPostInit`: `NOT_APPLICABLE`
- Every-frame selection scanning: `NO`
- `Events.OnTick` use: `NO`
- Shared global player state table: `NO`
- `ThePlayer` as authoritative state: `NO`
- Probe install retries: `OnGameBoot`, `OnMainMenuEnter`, and immediate guarded install.

## Syntax / Text Checks

- Lua bracket/string/comment text balance: `PASS`
- JSON parse: `PASS`
- B42 script brace balance: `PASS`
- BOM scan: `PASS`
- NULL scan: `PASS`
- Empty-file scan: `PASS`
- Lua 5.1 execution parse: `NOT_VERIFIABLE`, no reliable local Lua 5.1 interpreter used.

## NOT_VERIFIABLE_BY_STATIC_AUDIT

- Whether B42 accepts `Texture = trait_xnpdistancerunner` for runtime native icon display.
- Whether checkpoint C repair causes checkpoint D player native trait collection to contain the target.
- Whether runtime X3 movement effect activates after D becomes present.

## BLOCKER

`NONE`

```
