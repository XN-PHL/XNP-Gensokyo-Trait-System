# 0.4.0 Sanitized Evidence Excerpts

## TRAIT_REGISTRATION_FAILURE_AUDIT_0.4.0.md

- SHA-256: `56237E1E169FA9C8D8957A5C2C350FA050A19498ECBC14753A70D7F4812C4D37`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# TRAIT REGISTRATION FAILURE AUDIT 0.4.0

## Confirmed real-game symptom

- The mod is detected and can be enabled.
- The Build 42 version folder and `mod.info` discovery chain work.
- In the character creation trait page, `Distance Runner`, `XNPDistanceRunner`, and the Chinese display name are not visible.

CONFIRMED_FAILURE_STAGE=`NATIVE_TRAIT_REGISTRATION_NOT_VISIBLE_IN_CHARACTER_CREATION`

## 0.4.0 registration chain

1. `TraitFactory.addTrait` is written in:
   `[LOCAL_PATH_REDACTED]`
2. The file is under `shared`.
3. It may be scanned as a shared Lua file, but 0.4.0 did not provide a separate registration-only entrypoint or hard verification report.
4. It is required by:
   - `XNP_DR_State.lua`
   - `XNP_DR_Runtime.lua`
   - `XNP_DR_Bootstrap.lua`
5. Require path case matches the file path: `require "XNP_PZ_DistanceRunner/XNP_DR_Trait"`.
6. The registration function is both bound to `Events.OnGameBoot` and called once at file top level.
7. Event bound: `Events.OnGameBoot`.
8. Local B42 evidence shows `Events.OnGameBoot` is the correct early trait-registration timing before character creation list use.
9. `addTrait` receives 6 parameters in 0.4.0.
10. 0.4.0 parameters:
    - type: `Constants.TRAIT_ID` -> `XNPDistanceRunner`
    - name: `getTextSafe(..., "Distance Runner")`
    - cost: `Constants.TRAIT_COST` -> `1`
    - description: `getTextSafe(..., fallback)`
    - profession: `false`
    - removeInMP: `false`
11. Local B42.19 evidence confirms `cost > 0` appears in the positive trait list and costs points.
12. 0.4.0 calls `TraitFactory.getTrait("XNPDistanceRunner")` after registration only for description refresh, but it does not treat nil as failure.
13. 0.4.0 uses `pcall` only around translation and trait query fallback. It does not pcall `TraitFactory.addTrait`, so addTrait exceptions would not be silently swallowed.
14. Translation nil should not block 0.4.0 registration because `getTextSafe` has fallback; however the copied CN JSON was later observed as malformed/mojibake and could affect display language.
15. No local source evidence found for `TraitFactory.Reset` after registration. Vanilla `BaseGameCharacterDetails.DoTraits` is itself bound to `Events.OnGameBoot`.
16. 0.4.0 also attempted top-level registration. If `TraitFactory` was unavailable then, it logged delayed registration and relied on OnGameBoot.

## Most likely cause

MOST_LIKELY_CAUSE=`0.4.0_registration_success_was_not_verified_and_the_registration_module_was_not_registration_only`

0.4.0 did use the right broad API and event, but it did not make `getTrait("XNPDistanceRunner")` a hard success condition. It also mixed registration and runtime trait-query logic in one module and placed `Core.Trait = Trait` after registration attempts. If registration failed or occurred against an unavailable/incomplete API state, the mod could still proceed without a definitive failure log.

## Secondary causes

SECONDARY_CAUSES:

- Top-level registration attempt can run before `TraitF
[EXCERPT_TRUNCATED]
```

## BUILD_MARKER.txt

- SHA-256: `ED5D3B6DB61E705D3535FE44BCBDAA4745CB76BE7AC43700B8CBA35F4BD55D42`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_040_X3_A
0.4.0-native-trait-x3-test-a
XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.0_SOURCE_CREATED


```

## CHANGELOG.md

- SHA-256: `4D5C5A280C3139D7AD65FBAB27D745BDF280A74011C466A477E0DA9320A63DFE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

## 0.4.0-native-trait-x3-test-a

- Created independent native Project Zomboid Build 42 trait branch.
- Added `XNPDistanceRunner` as a character creation positive trait with cost `1`.
- Removed Skill Core points, unlock flow, panel requirements, and Second Wind runtime.
- Added X3 visual movement test with non-stacking Class C `getMoveSpeed` / `setMoveSpeed` handling.
- Added runtime-only state, preflight, emergency reset, status HUD text, metabolism cruise, training load, delayed fatigue placeholders, and disabled sprinting XP module.
- Added local B42 trait API audit and static audit targets.


```

## FINAL_REPORT.md

- SHA-256: `049FB0294C57FF832C513E5D644DD27DD6A5947C8665BC8CF34D60EE5411C7D7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT

## Source

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Project Zomboid roots

- PZ install scanned: `[LOCAL_PATH_REDACTED]`
- Workshop scanned: `[LOCAL_PATH_REDACTED]`
- Install target attempted: `[LOCAL_PATH_REDACTED]`

## Complete file tree

```text
.
.\42
.\BUILD_MARKER.txt
.\CHANGELOG.md
.\FINAL_REPORT.md
.\INSTALL_REPORT.md
.\LOCAL_B42_TRAIT_API_AUDIT.md
.\mod.info
.\README_CN.md
.\STATIC_AUDIT.md
.\TRAIT_UI_TEST_PLAN.md
.\42\media
.\42\mod.info
.\42\media\lua
.\42\media\lua\client
.\42\media\lua\shared
.\42\media\lua\client\XNP_PZ_DistanceRunner
.\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
.\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
.\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
.\42\media\lua\shared\Translate
.\42\media\lua\shared\XNP_PZ_DistanceRunner
.\42\media\lua\shared\Translate\CN
.\42\media\lua\shared\Translate\EN
.\42\media\lua\shared\Translate\CN\XNPDistanceRunnerTrait_CN.json
.\42\media\lua\shared\Translate\EN\XNPDistanceRunnerTrait_EN.json
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Debug.lua
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Metabolism.lua
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Movement.lua
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Preflight.lua
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_State.lua
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TrainingFatigue.lua
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Trait.lua
.\42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_XP.lua
```

## Counts

- Lua files: 12
- Lua total lines: 777
- Document/text files: 8
- Total files: 24

## Native trait

- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Namespace: `XNP_PZ_DistanceRunner`
- Version: `0.4.0`
- Internal version: `0.4.0-native-trait-x3-test-a`
- Build ID: `XNP_PZ_DISTANCE_TRAIT_040_X3_A`
- Trait ID: `XNPDistanceRunner`
- Trait display EN: `Distance Runner`
- Trait display CN: `闀块€斿琚€卄
- Positive trait cost: `1`
- Registration: `TraitFactory.addTrait(...)`
- Registration timing: `Events.OnGameBoot` plus immediate idempotent attempt.

## Runtime

- Runtime activation: native trait ownership only.
- No Skill Core points.
- No unlock flow.
- No skill panel.
- No old ModData migration.
- No persistent ModData writes.
- Movement API: `player:getMoveSpeed()` / `player:setMoveSpeed(value)`.
- X3 key parameters:
  - `MOVEMENT_TEST_MODE=true`
  - `MOVEMENT_TEST_FACTOR=3.00`
  - `VALID_RUN_TRIGGER_SECONDS=0.50`
  - `STOP_RESET_DELAY_SECONDS=1.00`
- Speed stacking guard: removes own previous `last_applied_factor` before reapplying.
- Debug interface: `XNP_PZ_DistanceRunner.Debug.GetState(player)`, `EmergencyReset(player, reason)`, `GetStatus(player)`.
- Status HUD: lightweight text state only, no formal UI panel.
- Sprinting XP: disabled, self-reward path not proven.
- Excluded feature: fixed disabled and not exposed in HUD.

## API evidence

See `LOCAL_B4
[EXCERPT_TRUNCATED]
```

## INSTALL_REPORT.md

- SHA-256: `02D75ED0469B2D832FAA7D630B34B12A9E37ED7CE06F635ECE00117625BB0422`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# INSTALL REPORT

## Intended install target

`[LOCAL_PATH_REDACTED]`

## Result

`INSTALL_PERMISSION_BLOCKED`

The copy operation to the Project Zomboid user mods directory required permission outside the current writable workspace. The approval request timed out, so no install copy was completed.

## Old install detection

Detected old install:

`[LOCAL_PATH_REDACTED]`

Action taken: none. It was not modified, deleted, moved, or overwritten.

## Source still ready

Use this source directory for manual install if needed:

`[LOCAL_PATH_REDACTED]`

## Safety statement

- Did not write to the Project Zomboid game install directory.
- Did not modify workshop files.
- Did not overwrite old Skill Core installs.
- Did not create or modify runtime files outside the current workspace.


```

## README_CN.md

- SHA-256: `946715B87DA9150B40A81B062B3A9F3696A08952B003537E682FE2A31EA296CF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP 闀块€斿琚€呯壒璐?0.4.0 涓夊€嶆祴璇曠増

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

杩欐槸涓€涓柊鐨?Project Zomboid Build 42 鍘熺敓瑙掕壊鍒涘缓鐗硅川鍒嗘敮锛屼笉鏄棫 Skill Core 鎶€鑳界偣绯荤粺銆?
## 韬唤

- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- 鍛藉悕绌洪棿: `XNP_PZ_DistanceRunner`
- 鐗堟湰: `0.4.0`
- 鍐呴儴鐗堟湰: `0.4.0-native-trait-x3-test-a`
- Build ID: `XNP_PZ_DISTANCE_TRAIT_040_X3_A`
- 鐗硅川 ID: `XNPDistanceRunner`
- 鑻辨枃鏄剧ず鍚? `Distance Runner`
- 涓枃鏄剧ず鍚? `闀块€斿琚€卄
- 鍘熺敓姝ｉ潰鐗硅川 cost: `1`

## 褰撳墠鐩爣

鍦ㄨ鑹插垱寤虹晫闈㈡樉绀轰竴涓師鐢熸闈㈢壒璐ㄣ€傜帺瀹堕€夋嫨璇ョ壒璐ㄥ苟杩涘叆娓告垙鍚庯紝闀块€斿琚€呰繍琛屾椂鑷姩鍚敤锛屼笉鍐嶉渶瑕?XNP 鎶€鑳界偣銆佽В閿佹寜閽€佹妧鑳介潰鏉挎垨 Second Wind銆?
## X3 娴嬭瘯鍙傛暟

- `MOVEMENT_TEST_MODE=true`
- `MOVEMENT_TEST_FACTOR=3.00`
- `VALID_RUN_TRIGGER_SECONDS=0.50`
- `STOP_RESET_DELAY_SECONDS=1.00`

杩愯鏃朵娇鐢?`player:getMoveSpeed()` / `player:setMoveSpeed(value)` Class C 璺緞銆傛瘡娆″簲鐢ㄥ墠浼氬厛绉婚櫎鏈ā缁勪笂涓€娆″啓鍏ョ殑鍊嶇巼锛岄伩鍏?`current * 3` 杩炵画鍙犲姞銆?
## 鏄庣‘鎺掗櫎

- 涓嶈鍐欐棫 Skill Core 鏁版嵁銆?- 涓嶈縼绉绘棫鎶€鑳界偣銆?- 涓嶆樉绀烘妧鑳界偣銆佹妧鑳介潰鏉裤€佽В閿佹寜閽€?- `FEATURE_SECOND_WIND=false`锛屼笉鏄剧ず銆佷笉瑙ｉ攣銆佷笉鎵ц Second Wind銆?- 涓嶅寘鍚?Java銆?- 涓嶅寘鍚?root `media\lua`銆?- 澶氫汉鐘舵€? `MULTIPLAYER_NOT_YET_VALIDATED`銆?- 瀹炴満鐘舵€? `REAL_GAME_TEST_REQUIRED_BY_USER`銆?
## 瀹夎娴嬭瘯

鐩爣瀹夎鐩綍锛?
`[LOCAL_PATH_REDACTED]`

濡傛灉 Codex 娌℃湁鏉冮檺澶嶅埗鍒拌鐩綍锛岃鎸夋湰 SOURCE 鐩綍鍐呭鎵嬪姩澶嶅埗銆備笉瑕佽鐩栨棫 Skill Core 瀹夎鐩綍銆?

```

## TRAIT_UI_TEST_PLAN.md

- SHA-256: `FAF29703D07C074D44DEA2CB47745CCA5482A8D1101DBE1BEBF9840EA6E491F7`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# TRAIT UI TEST PLAN

## Goal

Verify that `XNPDistanceRunner` appears in vanilla Build 42 character creation as a positive trait and activates the runtime after spawn.

## Steps

1. Enable `XNP Distance Runner Trait 0.4.0 X3 Test`.
2. Start a new single-player character.
3. Open the vanilla trait selection screen.
4. Confirm `Distance Runner` / `闀块€斿琚€卄 appears in the positive trait list.
5. Add the trait.
6. Confirm available points are reduced by 1.
7. Remove the trait.
8. Confirm available points are restored by 1.
9. Add it again and finish character creation.
10. In-game, run continuously for at least 0.5 seconds.
11. Confirm X3 visual movement is obvious.
12. Stop for at least 1 second.
13. Confirm the extra speed is removed.

## Expected

- No XNP skill panel.
- No XNP skill points.
- No unlock button.
- No Second Wind display or action.
- Runtime activates only if the native trait is present.
- X3 movement does not stack after repeated running/stopping.

## Stop conditions

Stop testing and report if:

- The trait does not appear in character creation.
- The trait appears as negative or refunds points instead of costing 1.
- In-game speed increases repeatedly without reset.
- The runtime affects a player who did not select the trait.


```

## LOCAL_B42_TRAIT_API_AUDIT.md

- SHA-256: `374993296ACDF960F6676B7230B5547596AF03841AB060354E903C33C88951B5`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# LOCAL B42 TRAIT API AUDIT

## Local roots

- Project Zomboid install scanned: `[LOCAL_PATH_REDACTED]`
- Workshop scanned: `[LOCAL_PATH_REDACTED]`
- Source output: `[LOCAL_PATH_REDACTED]`

## Confirmed vanilla character creation path

Evidence file:

`[LOCAL_PATH_REDACTED]`

Observed:

- `CharacterCreationProfession:populateTraitList(list)` fetches `CharacterTraitDefinition.getTraits()`.
- Positive traits are added when `trait:getCost() > 0`.
- Negative traits are added when `trait:getCost() < 0`.
- UI color selection also treats `trait:getCost() > 0` as good/positive.

Conclusion:

For Build 42 local evidence, this branch uses `cost=1` for the positive trait.

## Confirmed workshop custom trait registration evidence

Evidence file:

`[LOCAL_PATH_REDACTED]`

Observed:

- `ProfessionFramework.addTrait = function(type, details)` stores custom traits.
- Registration calls `TraitFactory.addTrait(ttype, getText(details.name), (details.cost or 0), getText(details.description), (details.profession or false), remove)`.
- After registration it calls `TraitFactory.sortList()`.
- It refreshes descriptions through `BaseGameCharacterDetails.SetTraitDescription(TraitFactory.getTrait(ttype))`.

Conclusion:

The native trait registration route is confirmed well enough for a source test branch:

`TraitFactory.addTrait(trait_id, display_name, cost, description, profession, remove)`

## Trait query evidence

Vanilla scripts show trait ownership checks through `player:hasTrait(CharacterTrait.X)` and `CharacterTrait.get(ResourceLocation.of(trait))` patterns. This source prefers the typed B42 query when available and falls back to string-based `player:HasTrait("XNPDistanceRunner")` / trait collection checks for compatibility.

## Translation keys

The trait registration uses:

- `UI_trait_XNPDistanceRunner`
- `UI_trait_XNPDistanceRunnerDesc`

Files created:

- `42\media\lua\shared\Translate\EN\XNPDistanceRunnerTrait_EN.json`
- `42\media\lua\shared\Translate\CN\XNPDistanceRunnerTrait_CN.json`

## Icon necessity

No local evidence found that a custom trait icon is mandatory for registration or listing. This source does not include an icon. Character creation visibility is the first real-game validation target.

## Registration timing

The source registers on `Events.OnGameBoot` and also attempts immediate registration if `TraitFactory` is already available. The function is idempotent and does not add the same trait twice when `TraitFactory.getTrait` can find it.

## Risks

- `TraitFactory.addTrait` is confirmed from local workshop evidence, but this source has not been run in-game.
- Typed `CharacterTrait.get(ResourceLocation.of(id))` may fail for custom IDs in some B42 builds; the runtime includes fallback string checks.
- Character creation trait UI behavior is locally confirmed, but final visibility is `REAL_GAME_TEST_REQUIRED_BY_USER`.

## Static status

- Native trait path: CONFIRMED_BY_LOCAL_SOURCE_EVIDENCE
- Positive cost sign: CONFIRMED_BY_LOCAL_CHARACTER_CREAT
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `BE664CDF876955FB31F4D54B9B74731F32CD67BB99FF09D19F524E0668E28DCC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT

## Scope

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## File counts

- Lua files: 12
- Lua total lines: 777
- Document/text files: 8
- Total files: 24

## Layout

- `root\mod.info`: present
- `root\42\mod.info`: present
- `root\42\media\lua\shared`: present
- `root\42\media\lua\client`: present
- `root\42\media\lua\shared\Translate\EN`: present
- `root\42\media\lua\shared\Translate\CN`: present
- root `media\lua`: absent
- `common`: absent
- Java files: absent

## Lua syntax checks

- `lua`: NOT_VERIFIABLE, no local command found.
- `luac`: NOT_VERIFIABLE, no local command found.
- Text balance scan for parentheses, double quotes, and single quotes: PASS.

## Identity and old-state checks

Runtime Lua scan results:

- `XNP_PZ_SkillCore`: absent
- `getModData`: absent
- `getModData().XNP_PZ_SkillCore`: absent
- `available_points`: absent
- `spent_points`: absent
- `UnlockSkill`: absent
- `ThePlayer`: absent
- old MovementLab identity: absent
- old build IDs: absent

The only runtime references to the excluded second feature are the fixed guard `FEATURE.SECOND_WIND=false` and a preflight assertion that fails if the flag is accidentally enabled.

## Trait registration checks

- Trait ID: `XNPDistanceRunner`
- Cost: `1`
- Registration API: `TraitFactory.addTrait(Constants.TRAIT_ID, name, Constants.TRAIT_COST, desc, false, false)`
- Sort call: `TraitFactory.sortList()` if available.
- Description refresh: `BaseGameCharacterDetails.SetTraitDescription(TraitFactory.getTrait(Constants.TRAIT_ID))` if available.
- Registration timing: `Events.OnGameBoot` plus immediate idempotent attempt.

## Runtime behavior checks

- Player state source: local player lookup through `getSpecificPlayer(0)` / `getPlayer()`, not `ThePlayer`.
- Runtime activation source: native trait ownership only.
- Speed API: `player:getMoveSpeed()` / `player:setMoveSpeed(value)`.
- Stacking guard: removes this branch's `last_applied_factor` before reapplying X3.
- Runtime state: in-memory only.
- Persistent ModData writes: none.
- Second feature display/use/unlock: absent.
- Sprinting XP: disabled with degraded status.
- Multiplayer: disabled for active runtime and marked `MULTIPLAYER_NOT_YET_VALIDATED`.

## Event checks

- `Events.OnGameBoot`: used for trait registration.
- `Events.OnGameStart`: used for preflight/runtime activation.
- `Events.OnCreatePlayer`: used for runtime activation.
- `Events.OnPlayerUpdate`: used for runtime update.
- `Events.OnPlayerDeath`: used for speed cleanup.
- `Events.OnMainMenuEnter`: used for runtime cleanup.
- Duplicate AddPlayerPostInit: not applicable to PZ and absent.

## File health

- Empty files: none.
- BOM: none detected.
- NULL bytes: none detected.

## Absolute paths

Runtime Lua contains no local absolute install paths. Documentation contains local audit evidence and install target paths by design.

## NOT_VERIFIABLE

- Lua parser execution: NOT_VERIFIABLE.
- Real game character creation listing: NOT_VERIFIABLE_BY_STATIC_AUDIT
[EXCERPT_TRUNCATED]
```
