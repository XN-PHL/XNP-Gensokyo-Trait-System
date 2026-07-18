# 0.4.3 Sanitized Evidence Excerpts

## BUILD_MARKER.txt

- SHA-256: `9FE13164242A9E990F95C0610E4F18DB42132F0E20927846EDDAF3085EEB3CB3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_043_RUNTIME_BIND_A
0.4.1-native-trait-registration-fix-a
XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.1_REGISTRATION_FIX_SOURCE_CREATED

```

## CHANGELOG.md

- SHA-256: `5B9F8D7A7E39D41FE19A1826FC88E17FF50E26B08FFB253CE584536B80F47E7F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

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

- SHA-256: `26C655CC3CB148152C01ABEF018B36B4282AD34FC14052867F093F35C500B368`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.3

## Required Fields

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- BASE_SOURCE_PATH: `[LOCAL_PATH_REDACTED]`
- VERSION: `0.4.3`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_043_RUNTIME_BIND_A`
- MOD_ID: `XNP_PZ_DistanceRunnerTrait`
- TRAIT_BARE_ID: `XNPDistanceRunner`
- TRAIT_FULL_ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- 0.4.2_TRAIT_VISIBILITY_RESULT: `PASS`
- 0.4.2_RUNTIME_BIND_RESULT: `FAIL`

## B42 Object Chain

- CharacterTrait.get true signature used: `CharacterTrait.get(ResourceLocation)`
- getCharacterTraitDefinition true signature used: `CharacterTraitDefinition.getCharacterTraitDefinition(CharacterTrait)`
- Canonical CharacterTrait object acquisition: `ResourceLocation.of(TRAIT_FULL_ID)` -> `CharacterTrait.get(location)`
- Player trait collection source: `player:getCharacterTraits():getKnownTraits()`
- Player trait detection method: primary `player:hasTrait(CharacterTrait)`, diagnostic fallback collection object compare.
- Uses full ID: `YES`
- Cleared wrong String definition call: `YES`
- Cleared wrong ResourceLocation definition call: `YES`
- Definition verification result: `STATIC_SAFE_OBJECT_CHAIN_READY`
- Player possession detection result: `REAL_GAME_TEST_REQUIRED_BY_USER`

## Translation

- Translation EN path: `42\media\lua\shared\translate\EN\UI.json`
- Translation CN path: `42\media\lua\shared\translate\CN\UI.json`
- EN key/value: `UI_trait_XNPDistanceRunner=Distance Runner`
- EN desc: `UI_trait_XNPDistanceRunnerDesc=Adapted to sustained running. Builds speed during continuous running, with increased metabolic and recovery costs. X3 diagnostic build.`
- CN key/value: `UI_trait_XNPDistanceRunner=闀块€斿琚€卄
- CN desc: `UI_trait_XNPDistanceRunnerDesc=閫傚簲闀胯窛绂绘寔缁璺戙€傝繛缁璺戞椂閫愭笎鎻愰珮閫熷害锛屼絾浼氬鍔犱唬璋㈡秷鑰椾笌鎭㈠璐熸媴銆俋3娴嬭瘯鐗堟湰銆俙

## Runtime / Movement

- RUNTIME_GAMEPLAY_FORMULAS_CHANGED: `NO`
- MOVEMENT_BACKEND_CHANGED: `NO`
- MOVEMENT_TEST_FACTOR: `3.00`
- VALID_RUN_TRIGGER_SECONDS: `0.50`
- STOP_RESET_DELAY_SECONDS: `1.00`
- Diagnostic HUD/text implementation: temporary `state.hud_text` values and console logs.
- Expected active marker: `XNP DR X3 ACTIVE`
- Expected ready marker: `XNP DR X3 READY`

## Counts

- Lua file count: `15`
- Lua total lines: `1322`
- Total files: `33`

## Static Check

- Static check result: `PASS`
- JSON parse: `PASS`
- Lua text balance: `PASS`
- B42 script brace balance: `PASS`
- Blocking scans: `PASS`
- `BLOCKER_B42_RUNTIME_TRAIT_BIND_UNSAFE`: `NO`

## Safety

- Installation success: `NO, source-only round`
- Game started: `NO`
- Steam started: `NO`
- Old SOURCE modified: `NO`
- Game directory written: `NO`
- User saves/mods directory written: `NO`
- Workshop upload: `NO`

## NOT_VERIFIABLE

- Lua execution syntax: `NOT_VERIFIABLE`, no local `lua` or `luac` command found.
- Real translation display: `NOT_VERIFIABLE_BY_STATIC_AUDIT`
- Real player trait possession: `REAL_GAME_TEST_REQUIRED_BY_USER`
- Real runtime activation: `REAL_GAME_TEST_REQUIRED_BY_USER`
- Real X3 world speed effect: `REA
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `5C7F63C59D0881E4880FF5D621B9C37355DC5FAC7553603BA6A3514DD0D50AFA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.3 Runtime Bind Fix

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

0.4.3 鍩轰簬 0.4.2 鐨勫疄鏈烘垚鍔熺粨鏋滅户缁慨澶嶃€?.4.2 宸茬粡璇佹槑 B42 鍘熺敓瑙掕壊鍒涘缓鐗硅川瀹氫箟璺嚎鎴愮珛锛屽洜姝?0.4.3 涓嶅洖閫€ `TraitFactory`锛屼笉鎭㈠ XNP 鎶€鑳界偣锛屼篃涓嶅鍔?Unlock 鐣岄潰銆?
## 韬唤

- Version: `0.4.3`
- Internal version: `0.4.3-b42-runtime-trait-bind-fix-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_043_RUNTIME_BIND_A`
- Display name: `XNP Distance Runner Trait 0.4.3 Runtime Bind Fix`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Script module: `XNPDistanceRunnerTrait`
- Trait bare ID: `XNPDistanceRunner`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## 淇濇寔涓嶅彉

- `42\media\scripts\XNPDistanceRunnerTraits.txt`
- `42\media\registries.lua`
- `BACKEND_C_SCRIPT_DEFINITION`
- `CharacterTrait.register("XNPDistanceRunnerTrait:XNPDistanceRunner")`
- Trait cost: `1`
- Positive trait classification
- `MOVEMENT_TEST_FACTOR=3.00`
- Valid run trigger: `0.50` seconds
- Stop reset delay: `1.00` second

## 0.4.3 淇鐐?
- `CharacterTraitDefinition.getCharacterTraitDefinition` 鍙帴鏀?`CharacterTrait` 瀵硅薄銆?- 瑙勮寖瀵硅薄閾撅細`ResourceLocation.of(full_id)` -> `CharacterTrait.get(location)` -> `CharacterTraitDefinition.getCharacterTraitDefinition(traitObject)`銆?- 鐜╁妫€娴嬩紭鍏堜娇鐢?`player:hasTrait(CharacterTrait瀵硅薄)`銆?- 杩涘叆涓栫晫鍚庤緭鍑轰竴娆＄湡瀹炵帺瀹剁壒璐ㄩ泦鍚?dump銆?- 淇缈昏瘧鐩綍涓?B42 鍘熺増鏍煎紡锛歚media\lua\shared\translate\EN\UI.json` 鍜?`CN\UI.json`銆?- 澧炲姞 X3 鍐欏叆/澶嶄綅鐨勭姸鎬佸彉鍖栨棩蹇椼€?- 娣诲姞涓存椂鐘舵€佹枃鏈細`XNP DR X3 READY` / `XNP DR X3 ACTIVE` / `XNP DR READY`銆?
## 鎵嬪姩娴嬭瘯

娴嬭瘯鍓嶈绂佺敤鎴栫Щ鍑?0.4.0銆?.4.1銆?.4.2锛屽彧鍚敤 0.4.3銆傞獙鏀堕『搴忚锛?
`TRAIT_RUNTIME_BIND_AND_X3_TEST_0.4.3.md`

```

## TRAIT_RUNTIME_BIND_AND_X3_TEST_0.4.3.md

- SHA-256: `D09B7B8FA035C273B7383BCA859B57E1EB6E3C62D9BB81704E80A0F405BCC550`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# TRAIT RUNTIME BIND AND X3 TEST 0.4.3

## Setup

1. Disable or move out 0.4.0, 0.4.1, and 0.4.2.
2. Enable only 0.4.3.
3. Fully restart the game.
4. Create a new character.

## Character Creation Acceptance

- Trait appears as `Distance Runner` or `闀块€斿琚€卄.
- Trait no longer appears as `UI_trait_XNPDistanceRunner`.
- Trait description no longer appears as `UI_trait_XNPDistanceRunnerDesc`.
- Trait can be selected and added.

## Runtime Acceptance

After entering the world with the trait:

```text
[XNP DistanceRunner] native trait detected canonical_id=XNPDistanceRunnerTrait:XNPDistanceRunner
[XNP DistanceRunner] runtime activated build=XNP_PZ_DISTANCE_TRAIT_043_RUNTIME_BIND_A
[XNP DistanceRunner] X3 diagnostic movement ready factor=3.00
```

After continuous running for more than 0.5 seconds:

```text
[XNP DistanceRunner] movement apply requested factor=3.00
[XNP DistanceRunner] X3 diagnostic movement active for native trait player
```

After stopping for more than 1.0 seconds:

```text
[XNP DistanceRunner] movement reset requested
```

## Negative Control

Create another character without the trait:

- No runtime activation.
- No X3 application.
- No status marker.
- Expected log:

```text
[XNP DistanceRunner] native trait absent; runtime inactive
```

```

## B42_TRANSLATION_PATH_AUDIT_0.4.3.md

- SHA-256: `3814B01D8569F8F59990B7D96D46218F57D3F77D7BA5F9D887FF14B989648E81`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42 TRANSLATION PATH AUDIT 0.4.3

## Local Vanilla Path

Vanilla Build 42.19 translations are located under:

```text
[LOCAL_PATH_REDACTED]
```

Observed files:

```text
media\lua\shared\translate\EN\UI.json
media\lua\shared\translate\CN\UI.json
```

## 0.4.2 Problem

0.4.2 placed translation files under a copied `Translate` directory and custom filenames. Character creation displayed raw keys:

```text
UI_trait_XNPDistanceRunner
UI_trait_XNPDistanceRunnerDesc
```

## 0.4.3 Fix

0.4.3 now uses vanilla-style paths:

```text
42\media\lua\shared\translate\EN\UI.json
42\media\lua\shared\translate\CN\UI.json
```

## Keys

English:

```json
{
  "UI_trait_XNPDistanceRunner": "Distance Runner",
  "UI_trait_XNPDistanceRunnerDesc": "Adapted to sustained running. Builds speed during continuous running, with increased metabolic and recovery costs. X3 diagnostic build."
}
```

Chinese:

```json
{
  "UI_trait_XNPDistanceRunner": "闀块€斿琚€?,
  "UI_trait_XNPDistanceRunnerDesc": "閫傚簲闀胯窛绂绘寔缁璺戙€傝繛缁璺戞椂閫愭笎鎻愰珮閫熷害锛屼絾浼氬鍔犱唬璋㈡秷鑰椾笌鎭㈠璐熸媴銆俋3娴嬭瘯鐗堟湰銆?
}
```

## Expected Behavior

- Without B42Trans_CN: English should display.
- With B42Trans_CN: Chinese should display if load order allows.
- Raw UI keys should no longer display.

```

## STATIC_AUDIT.md

- SHA-256: `5B8343604E936EECBFB89A6482294518EFE50AF5B94B82B5C5A7F0C92D6499CE`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.3

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Counts

- Total files: `33`
- Lua files: `15`
- Lua total lines: `1322`
- Document/text files: `14`
- JSON files: `2`

## File Tree

```text
0.4.2_RUNTIME_FAILURE_ANALYSIS.md
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
42\media\lua\shared\translate\CN\UI.json
42\media\lua\shared\translate\EN\UI.json
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_B42TraitApiProbe.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Debug.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Metabolism.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Movement.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Preflight.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_State.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TrainingFatigue.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Trait.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TraitRegistration.lua
42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_XP.lua
42\media\registries.lua
42\media\scripts\XNPDistanceRunnerTraits.txt
42\mod.info
B42_19_CUSTOM_TRAIT_SAMPLE_REAUDIT.md
B42_19_VANILLA_TRAIT_PIPELINE_AUDIT.md
B42_CHARACTER_TRAIT_OBJECT_CHAIN_AUDIT.md
B42_TRANSLATION_PATH_AUDIT_0.4.3.md
BUILD_MARKER.txt
CHANGELOG.md
FINAL_REPORT.md
INSTALL_REPORT.md
LOCAL_B42_TRAIT_API_AUDIT.md
mod.info
README_CN.md
STATIC_AUDIT.md
TRAIT_RUNTIME_BIND_AND_X3_TEST_0.4.3.md
```

## Blocking Conditions

- Direct `getCharacterTraitDefinition(String)`: `ABSENT`
- Direct `getCharacterTraitDefinition(ResourceLocation)`: `ABSENT`
- Runtime `TraitFactory.addTrait`: `ABSENT`
- Runtime `TraitFactory.getTrait`: `ABSENT`
- Runtime `HasTrait(String)` / `player:HasTrait(String)`: `ABSENT`
- Runtime only-bare-id trait detection: `ABSENT`
- `UnlockSkill`: `ABSENT`
- `XNP_PZ_SkillCore`: `ABSENT`
- `available_points` / `spent_points`: `ABSENT`

## Translation

- EN path: `42\media\lua\shared\translate\EN\UI.json`
- CN path: `42\media\lua\shared\translate\CN\UI.json`
- EN JSON parse: `PASS`
- CN JSON parse: `PASS`
- BOM: `PASS`
- NULL bytes: `PASS`
- Empty files: `PASS`

## Lua / Script

- B42 trait script brace balance: `PASS`
- Lua text parentheses/quote balance scan: `PASS`
- `lua` interpreter: `NOT_VERIFIABLE`
- `luac` interpreter: `NOT_VERIFIABLE`

## Runtime Formula Impact

- `RUNTIME_GAMEPLAY_FORMULAS_CHANGED=NO`
- `MOVEMENT_BACKEND_CHANGED=NO`
- `MOVEMENT_DIAGNOSTIC_LOGGING_CHANGED=YES`
- `HUD_DIAGNOSTIC_TEXT_CHANGED=YES`
- Metabolism hash matches 0.4.2: `YES`
- Training fatigue hash matches 0.4.2: `YES`
- XP hash matches 0.4.2: `YES`

Movement and HUD changed for observability only: X3 apply/reset logging and temporary status text.

## Static Result

- Static blocker: `NONE`
- Real runtime binding: `NOT_VERIFIABLE_BY_STATIC_AUDIT`
- Real translati
[EXCERPT_TRUNCATED]
```
