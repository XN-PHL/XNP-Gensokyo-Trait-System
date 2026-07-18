# 0.4.2 Sanitized Evidence Excerpts

## 0.4.2_RUNTIME_FAILURE_ANALYSIS.md

- SHA-256: `5B7009D173D89F009847979385AF7186E6926C1400BE40F9CFBA8780DDD91448`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.2 RUNTIME FAILURE ANALYSIS

## Real Game Result

- `0.4.2_TRAIT_DEFINITION_RESULT=PASS`
- `0.4.2_CHARACTER_CREATION_VISIBILITY=PASS`
- `0.4.2_TRAIT_SELECTABLE=PASS`
- `0.4.2_RUNTIME_BINDING_RESULT=FAIL`

0.4.2 proved the native Build 42 script definition backend:

- `42\media\scripts\XNPDistanceRunnerTraits.txt`
- `42\media\registries.lua`
- `BACKEND_C_SCRIPT_DEFINITION`
- `CharacterTrait.register("XNPDistanceRunnerTrait:XNPDistanceRunner")`

## Failure Facts

Successful runtime log:

```text
[XNP DISTANCE RUNNER] native CharacterTrait registered id=XNPDistanceRunnerTrait:XNPDistanceRunner
```

Failed runtime verification:

```text
expected argument of type CharacterTrait, got ResourceLocation
expected argument of type CharacterTrait, got String
```

Failed runtime activation:

```text
[XNP DistanceRunner] player does not have native trait; runtime inactive
[XNP DistanceRunner] preflight failed: native trait definition not verified status=MISSING_SCRIPT_DEFINITION
```

## Frozen Interpretation

The native trait definition route is successful. The remaining failure is runtime binding:

- `TRANSLATION=FAIL`
- `DEFINITION_VERIFIER_ARGUMENT_TYPE=FAIL`
- `PLAYER_TRAIT_DETECTION=FAIL`
- `RUNTIME_ACTIVATION=FAIL`
- `X3_EFFECT_NOT_TESTED_BECAUSE_RUNTIME_INACTIVE`

Do not revert to `TraitFactory`, fake ModData traits, Skill Core points, or unlock UI.

```

## BUILD_MARKER.txt

- SHA-256: `BF2D34A0360C1AF597CD688A8A0E13693EF045A768368E56F841E6FD9523E97D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_042_NATIVE_API_A
0.4.1-native-trait-registration-fix-a
XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.1_REGISTRATION_FIX_SOURCE_CREATED

```

## CHANGELOG.md

- SHA-256: `1788A3BC5E42A25317BB974604726EE65FBBFB4FB4A23B889D70C5C0D2939C2C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

## 0.4.2 - B42 Native Trait API Fix A

- Replaced failed 0.4.1 `TraitFactory.addTrait` registration path with Build 42 script definition backend.
- Added `42\media\scripts\XNPDistanceRunnerTraits.txt` using `character_trait_definition`.
- Added `42\media\registries.lua` using `CharacterTrait.register("XNPDistanceRunnerTrait:XNPDistanceRunner")`, matching the B42 custom trait sample pattern observed in More Traits 42.17.
- Added `XNP_DR_B42TraitApiProbe.lua` as a pure diagnostic module.
- Updated registration verification to read `CharacterTraitDefinition.getCharacterTraitDefinition`.
- Added full trait id support: `XNPDistanceRunnerTrait:XNPDistanceRunner`.
- Kept gameplay formula files unchanged from 0.4.1.

## 0.4.1 - Registration Fix A

- Attempted native Lua registration through `TraitFactory.addTrait`.
- Real runtime result on PZ 42.19.0: module load PASS, event execution PASS, trait API access FAIL.

```

## FINAL_REPORT.md

- SHA-256: `80FB5B775E94015EB357CFE942A47F6DF8D3ACAE81A539A99C35AC4B66E17A1C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT

## Identity

- SOURCE_OUTPUT_PATH: `[LOCAL_PATH_REDACTED]`
- Version: `0.4.2`
- Internal version: `0.4.2-b42-native-trait-api-fix-a`
- Build: `XNP_PZ_DISTANCE_TRAIT_042_NATIVE_API_A`
- Display: `XNP Distance Runner Trait 0.4.2 Native API Fix`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait ID: `XNPDistanceRunner`
- Full trait id: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## Frozen Runtime Input

- 0.4.1 Lua load: `PASS`
- 0.4.1 event execution: `PASS`
- 0.4.1 trait API access: `FAIL`
- 0.4.1 addTrait invoked: `NO`
- 0.4.1 visible: `NO`
- Frozen root cause: `TRAITFACTORY_GLOBAL_OR_METHODS_UNAVAILABLE_IN_B42_19_LUA_ENVIRONMENT`

## 0.4.2 Implementation

- Selected backend: `BACKEND_C_SCRIPT_DEFINITION`
- Trait definition layer: `42\media\scripts\XNPDistanceRunnerTraits.txt`
- Native registry layer: `42\media\registries.lua`
- API probe: `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_B42TraitApiProbe.lua`
- Registration verifier: `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TraitRegistration.lua`
- Trait visibility acceptance target: `TRAIT_VISIBLE_IN_CHARACTER_CREATION`

## Expected Logs

- `[XNP DISTANCE RUNNER] module loaded version=0.4.2-b42-native-trait-api-fix-a build=XNP_PZ_DISTANCE_TRAIT_042_NATIVE_API_A`
- `[XNP TRAIT API PROBE] begin version=0.4.2-b42-native-trait-api-fix-a build=XNP_PZ_DISTANCE_TRAIT_042_NATIVE_API_A`
- `[XNP DISTANCE RUNNER] registration backend selected=BACKEND_C_SCRIPT_DEFINITION`
- `[XNP DISTANCE RUNNER] trait definition begin id=XNPDistanceRunner full_id=XNPDistanceRunnerTrait:XNPDistanceRunner backend=BACKEND_C_SCRIPT_DEFINITION`

## Counts

- Total files: `31`
- Lua files: `15`
- Lua total lines: `1107`
- Document/text files: `12`
- JSON files: `2`

## Runtime Core

- `RUNTIME_GAMEPLAY_CORE_CHANGED=NO`
- Movement/metabolism/training fatigue/XP/HUD hashes match 0.4.1.
- `XNP_DR_Trait.lua` changed only to recognize the B42 namespaced trait id and the old bare id.

## Safety

- Wrote game directory: `NO`
- Wrote user saves/mods directory: `NO`
- Started Project Zomboid: `NO`
- Started Steam: `NO`
- Workshop upload: `NO`
- Modified 0.4.0 source: `NO`
- Modified 0.4.1 source: `NO`
- Installed mod: `NO, source-only round`

## Static Result

- File tree: `PASS`
- JSON parse: `PASS`
- B42 trait script brace balance: `PASS`
- Lua text balance scan: `PASS`
- Runtime `TraitFactory.addTrait` call: `ABSENT`
- Runtime `TraitFactory.getTrait` call: `ABSENT`
- `ThePlayer`: `ABSENT`
- `getModData(`: `ABSENT`
- Static blocker: `NONE`

## NOT_VERIFIABLE

- Lua bytecode/syntax execution: `NOT_VERIFIABLE`, no local `lua`/`luac` command found.
- Native trait visibility: `NOT_VERIFIABLE_BY_STATIC_AUDIT`
- Multiplayer: `MULTIPLAYER_NOT_YET_VALIDATED`
- Real game: `REAL_GAME_TEST_REQUIRED_BY_USER`

## BLOCKER

`NONE_STATIC`

## Ready Marker

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.2_SOURCE_READY_FOR_NATIVE_TRAIT_VISIBILITY_TEST`

```

## INSTALL_REPORT.md

- SHA-256: `B9D06431C5EBD549E8E72809698DAC86243EE9947345C53E1CB56BAB78302F57`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# INSTALL REPORT

Installation was not attempted by Codex for this source-only round.

- Source output only: `YES`
- Wrote game install directory: `NO`
- Wrote user saves/mods directory: `NO`
- Started Project Zomboid: `NO`
- Started Steam: `NO`
- Workshop upload: `NO`

Manual installation/test remains required by the user.

```

## README_CN.md

- SHA-256: `DBA1E7DE424ADBE9F1BD427859F75EDD51CAD50BDD3546CB6760CFFEE42707B7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.2 Native API Fix

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

鏈増鏈彧瑙ｅ喅 Project Zomboid Build 42.19.0 鍘熺敓瑙掕壊鍒涘缓鐗硅川鍙鎬ч棶棰樸€?.4.1 宸茬粡璇佹槑 Lua 妯″潡鍔犺浇鍜?`Events.OnGameBoot` 鎵ц姝ｅ父锛屼絾 `TraitFactory` 鍦ㄥ綋鍓?B42.19 Lua 鐜涓嶅彲鐢紝鍥犳 0.4.2 涓嶅啀灏濊瘯 `TraitFactory.addTrait`銆?
## 韬唤

- Version: `0.4.2`
- Internal version: `0.4.2-b42-native-trait-api-fix-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_042_NATIVE_API_A`
- Display name: `XNP Distance Runner Trait 0.4.2 Native API Fix`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait ID: `XNPDistanceRunner`
- Full trait id: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- Backend: `BACKEND_C_SCRIPT_DEFINITION`

## 瀹氫箟灞?
- `42\media\scripts\XNPDistanceRunnerTraits.txt`
- `42\media\registries.lua`
- `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_B42TraitApiProbe.lua`
- `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TraitRegistration.lua`

瀹氫箟灞備笉渚濊禆鐜╁銆丠UD銆佺Щ鍔ㄣ€佽€愬姏銆佷唬璋㈡垨璁粌鐤插姵妯″潡銆傚畠鍙礋璐ｆ敞鍐?楠岃瘉瑙掕壊鍒涘缓鐗硅川瀹氫箟锛屽苟杈撳嚭鏄庣‘鏃ュ織銆?
## 鐜╂硶鏍稿績

绉诲姩銆佷唬璋€佽缁冪柌鍔炽€乆P銆丠UD 鐜╂硶鏂囦欢浠?0.4.1 澶嶅埗锛屽叕寮忔湭鏀广€俙XNP_DR_Trait.lua` 鍙鍔犲畬鏁?ResourceLocation 涓庤８ ID 鍙岃矾寰勬煡璇紝浠ラ€傞厤 B42 鑴氭湰瀹氫箟鐨勫懡鍚嶇┖闂寸壒璐ㄣ€?
## 鎵嬪姩娴嬭瘯

0.4.2 涓?0.4.1 浣跨敤鐩稿悓 Mod ID銆傛祴璇曞墠璇风鐢ㄦ垨绉诲嚭鏃х増鏈紝涓嶈鍚屾椂鍚敤澶氫釜鐗堟湰銆傞獙鏀舵爣鍑嗗彧鏈変竴涓細瑙掕壊鍒涘缓鐗硅川鍒楄〃涓兘鐪嬪埌 `Distance Runner` / `闀块€斿琚€卄锛屽苟涓旈€夋嫨鍚庤繘娓告垙瑙﹀彂鏃㈡湁 Distance Runner 杩愯鏃舵晥鏋溿€?
```

## TRAIT_VISIBILITY_TEST_0.4.2.md

- SHA-256: `1BE24DCF54425D5B60FE81712AA04B34244F09930C0E37FE82D5A25E0DE7EAA0`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# TRAIT VISIBILITY TEST 0.4.2

## Goal

Verify whether `XNPDistanceRunnerTrait:XNPDistanceRunner` is visible in Project Zomboid Build 42.19 character creation.

## Expected Logs

- `[XNP DISTANCE RUNNER] module loaded version=0.4.2-b42-native-trait-api-fix-a build=XNP_PZ_DISTANCE_TRAIT_042_NATIVE_API_A`
- `[XNP TRAIT API PROBE] begin version=0.4.2-b42-native-trait-api-fix-a build=XNP_PZ_DISTANCE_TRAIT_042_NATIVE_API_A`
- `[XNP DISTANCE RUNNER] registration backend selected=BACKEND_C_SCRIPT_DEFINITION`
- `[XNP DISTANCE RUNNER] trait definition begin id=XNPDistanceRunner full_id=XNPDistanceRunnerTrait:XNPDistanceRunner backend=BACKEND_C_SCRIPT_DEFINITION`

## Acceptance

`TRAIT_VISIBLE_IN_CHARACTER_CREATION`

The trait must appear in native character creation as `Distance Runner` or `闀块€斿琚€卄.

## Failure Interpretation

If the log says definition lookup is not visible, the script definition or registry load order is still wrong.

If the definition verifies but the trait is absent from the UI, the next target is `CharacterCreationProfession.lua` filtering/category behavior, not `TraitFactory`.

If the trait is visible but runtime does not activate after spawn, inspect trait ownership query output around `XNP_DR_Trait.lua`; 0.4.2 checks both `XNPDistanceRunnerTrait:XNPDistanceRunner` and `XNPDistanceRunner`.

## Not Tested Here

- No game executable was run by Codex.
- No Steam process was started by Codex.
- No workshop upload was attempted.
- No save or game installation directory was modified.

```

## LOCAL_B42_TRAIT_API_AUDIT.md

- SHA-256: `54A68A5E62A9BDD376676D1398CF2CE1E6C9670EC01733B967DCAD330E17D57D`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# LOCAL B42 TRAIT API AUDIT

## Runtime Failure Input

The latest real console evidence is treated as frozen:

- PZ version: `Project Zomboid 42.19.0`
- Branch: `steam/release`
- Revision: `1aa820d7bb66c4e55513cae04022bdacdac5b34e`
- 0.4.1 module loaded: `PASS`
- 0.4.1 `Events.OnGameBoot` registration function executed: `PASS`
- `TraitFactory available=false`
- 0.4.1 failure stage: `api_check`
- 0.4.1 reason: `TraitFactory_addTrait_or_getTrait_unavailable`

## Local Vanilla Evidence

- Vanilla trait file: `[LOCAL_PATH_REDACTED]`
- Vanilla UI file: `[LOCAL_PATH_REDACTED]`
- Vanilla data API observed in UI: `CharacterTraitDefinition.getTraits()`
- Positive trait UI branch: `trait:getCost() > 0`
- Negative trait UI branch: `trait:getCost() < 0`

## Local Custom Trait Sample Evidence

- More Traits B42.17 script definitions: `[LOCAL_PATH_REDACTED]`
- More Traits B42.17 registry: `[LOCAL_PATH_REDACTED]`
- Sample registry pattern: `CharacterTrait.register("ToadTraits:<id>")`
- Sample definition pattern: `character_trait_definition ToadTraits:<id>`

## 0.4.2 Decision

- Selected backend: `BACKEND_C_SCRIPT_DEFINITION`
- 0.4.2 script: `42\media\scripts\XNPDistanceRunnerTraits.txt`
- 0.4.2 registry: `42\media\registries.lua`
- 0.4.2 verification: `CharacterTraitDefinition.getCharacterTraitDefinition(...)`

## Static Limit

`NOT_VERIFIABLE_BY_STATIC_AUDIT`: actual trait visibility in character creation still requires a real game run.

```

## STATIC_AUDIT.md

- SHA-256: `F7FF62D2DA3601243502C3BB84B9C055239E9F3EA04EA2E53A8D86AAE7E2D1DC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.2

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Counts

- Total files: `31`
- Lua files: `15`
- Lua total lines: `1107`
- Document/text files: `12`
- JSON files: `2`

## File Tree

```text
0.4.1_REAL_RUNTIME_FAILURE_ANALYSIS.md
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_HUD.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
42\media\lua\shared\Translate\CN\XNPDistanceRunnerTrait_CN.json
42\media\lua\shared\Translate\EN\XNPDistanceRunnerTrait_EN.json
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
BUILD_MARKER.txt
CHANGELOG.md
FINAL_REPORT.md
INSTALL_REPORT.md
LOCAL_B42_TRAIT_API_AUDIT.md
mod.info
README_CN.md
STATIC_AUDIT.md
TRAIT_VISIBILITY_TEST_0.4.2.md
```

## Definition Backend

- Selected backend: `BACKEND_C_SCRIPT_DEFINITION`
- Trait script: `42\media\scripts\XNPDistanceRunnerTraits.txt`
- Registry: `42\media\registries.lua`
- Runtime verifier: `XNP_DR_TraitRegistration.lua`
- Diagnostic probe: `XNP_DR_B42TraitApiProbe.lua`

The definition layer does not require player, HUD, movement, endurance, metabolism, XP, or training fatigue modules.

## Static Checks

- File tree check: `PASS`
- Root `mod.info`: `PASS`
- `42\mod.info`: `PASS`
- `42\media\scripts`: `PASS`
- `42\media\registries.lua`: `PASS`
- Root `media\lua`: `ABSENT`
- Empty files: `PASS`
- BOM: `PASS`
- NULL bytes: `PASS`
- EN JSON parse: `PASS`
- CN JSON parse: `PASS`
- B42 trait script brace balance: `PASS`
- Lua text parentheses/quote balance scan: `PASS`
- `lua` interpreter: `NOT_VERIFIABLE`
- `luac` interpreter: `NOT_VERIFIABLE`

## Runtime Lua Risk Scan

- `TraitFactory.addTrait`: only present in diagnostic probe text log, not called.
- `TraitFactory.getTrait`: only present in diagnostic probe text log, not called.
- `ThePlayer`: `ABSENT`
- `getModData(`: `ABSENT`
- `UnlockSkill`: `ABSENT`
- `AddPlayerPostInit`: `ABSENT`
- `OnInitWorld`: `ABSENT`
- `XNP_PZ_SkillCore`: `ABSENT`
- `available_points`: `ABSENT`
- `spent_points`: `ABSENT`

## Gameplay Hash Comparison

`RUNTIME_GAMEPLAY_CORE_CHANGED=NO`

- `XNP_DR_Movement.lua`: `DF5BD73FAC2096DF368B2FAD8676C57B62CA14E9BE77B8510A521E90E6611
[EXCERPT_TRUNCATED]
```
