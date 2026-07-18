# 0.5.46 Sanitized Evidence Excerpts

## 0.5.46_CN_EN_PARITY_REPORT.md

- SHA-256: `2267152ACD10DBE447033A87D0C8E9F56B76D9541042D9DF86E4532FAFE417D1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.46 CN / EN Parity Report

Files checked:

- `42/media/lua/shared/translate/CN/Sandbox_CN.txt`
- `42/media/lua/shared/translate/EN/Sandbox_EN.txt`

Scope:

Only `Sandbox_XNPDistanceRunner_*` option and tooltip keys are compared. Language table headers `Sandbox_CN` and `Sandbox_EN` are intentionally excluded because they are locale namespace identifiers, not option keys.

Results:

- `CN_KEY_COUNT=94`
- `EN_KEY_COUNT=94`
- `CN_EN_KEY_PARITY=true`
- `CN_ONLY=0`
- `EN_ONLY=0`

Updated key:

`Sandbox_XNPDistanceRunner_EnableTieredFoodRecovery_tooltip`

Behavior:

- Option key unchanged.
- Tooltip key unchanged.
- Numeric value text unchanged except version token.
- Line format and quote style preserved.

CN_EN_PARITY_STATUS=PASS_STATIC


```

## 0.5.46_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `5945B3357BBC85AF32166A540C28E2295618B1143547BBD3B84C0A9B0D4EF7BA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.46 Gameplay Preserve Report

Preserved from 0.5.45:

- `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=0`
- `STATUS_ICON_DRAG_CLAMP_DIRECT_PRINT_CALLS=0`
- `STATUS_ICON_DRAG_CLAMP_EDGE_LOG_REACHABLE=1`
- `MISSING_CONFIG_FALLBACK_SILENT=true`
- Clamp / drag / position save / restore unchanged.
- Authority seven legacy non-food write sites still route through `CanWriteNonFoodStats`.
- Food client direct endurance / hunger write remains `0`.
- Normal MP client non-Food write remains unreachable by static authority gate.
- PreBite absolute 0.30 gate remains inactive.
- Blue / Yellow / Red allowed, Green disabled.
- CentralWorldQuery remains the only local world scan owner.
- PlayerSnapshot / ImpactSnapshot / ThreatSnapshot / PreBite direct scan remains `0`.
- Scheduler calls `CentralWorldQuery.BuildPlayerFrame(...)` once.
- Global zombie list remains false.
- Tiered Food remains single food writer.
- Blue food pulse remains `0.005` food for `0.015` endurance per 2 seconds.
- Yellow / Red food pulse remains `0.010` food for `0.020` endurance per 2 seconds.
- Reserve floor remains `0.40`.
- PreBite remains before fatal / bite commit.
- Max targets remains `3`.
- Third target remains stagger-only.
- Emergency endurance floor remains `0.05`.
- Vehicle exact 0.5.37 equivalence preserved.
- Precollision remains `0.012`.
- Vehicle remains `0.018`.
- ZombieImpact remains `0.24`.
- SP Melee preserved.
- MP Melee disabled.
- Coordinate write remains `0`.
- Render scan remains `0`.
- Render print remains `0`.
- Blue30 / Yellow38 / Red55 preserved.
- Colors / shake / drag interaction unchanged.
- Walk No Impact preserved.
- Controlled Escape preserved.
- JogBump preserved.
- NativeTrip preserved.
- ImpactQuota preserved.
- No bite rollback.
- No infection rollback.
- No heal.
- Mod ID stable.
- DIRECT_INSTALL single-layer structure preserved.
- SOURCE / DIRECT_INSTALL runtime hash identical.

GAMEPLAY_PRESERVE_STATUS=PASS_STATIC


```

## 0.5.46_TRANSLATION_VERSION_RESIDUE_REPORT.md

- SHA-256: `47CE4292B946F14F8539D6B6F55538A9C3171AFB88C381F60E0017612104C0B6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.46 Translation Version Residue Report

Before:

- CN old version hits: `1`
- EN old version hits: `1`
- OLD_VERSION_FILE_COUNT: `2`

Before lines:

- CN: `Sandbox_XNPDistanceRunner_EnableTieredFoodRecovery_tooltip` contained `0.5.44`.
- EN: `Sandbox_XNPDistanceRunner_EnableTieredFoodRecovery_tooltip` contained `0.5.44`.

After:

- CN old version hits: `0`
- EN old version hits: `0`
- OLD_VERSION_FILE_COUNT: `0`
- OLD_VERSION_TOKEN_HITS: `0`

Current version text:

- CN_VERSION=`0.5.46`
- EN_VERSION=`0.5.46`

Confirmed absent from active runtime text files:

- `0.5.44`
- `0544`
- `0.5.45`
- `0545`
- `0.5.43`
- `0543`

Text integrity:

- `BOM_COUNT=0`
- `NULL_COUNT=0`
- `ODD_QUOTES=0`
- `ENCODING_ERRORS=0`

TRANSLATION_VERSION_RESIDUE_STATUS=PASS_STATIC


```

## BUILD_MARKER.txt

- SHA-256: `C81810E732226F84565DEACB6153916507875AEB57B286A128426A2EE92A179A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0546_TRANSLATION_VERSION_RESIDUE_CLEANUP_A

```

## FINAL_REPORT.md

- SHA-256: `534D3CCD95567F0DC36DA6464968EFED0F018D4F81325CB964DC259613D5A039`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE:

`[LOCAL_PATH_REDACTED]`

DIRECT_INSTALL:

`[LOCAL_PATH_REDACTED]`

First-level tree:

```text
XNP_PZ_DistanceRunnerTrait
鈹溾攢 42
鈹溾攢 mod.info
鈹斺攢 poster.png
```

Changed files:

- `BUILD_MARKER.txt`
- `mod.info`
- `42/mod.info`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_VehicleLegacy0537Evaluator.lua`
- `42/media/lua/shared/translate/CN/Sandbox_CN.txt`
- `42/media/lua/shared/translate/EN/Sandbox_EN.txt`

CN old version hits:

- before: `1`
- after: `0`

EN old version hits:

- before: `1`
- after: `0`

OLD_VERSION_FILE_COUNT:

`0`

CN / EN key parity:

`true`

Clamp log preserve:

- `STATUS_ICON_DRAG_CLAMP_REPEAT_PRINT_REACHABLE=0`
- `STATUS_ICON_DRAG_CLAMP_DIRECT_PRINT_CALLS=0`
- `STATUS_ICON_DRAG_CLAMP_EDGE_LOG_REACHABLE=1`
- `MISSING_CONFIG_FALLBACK_SILENT=true`

0.5.45 core preserve:

`PASS_STATIC`

DIRECT_INSTALL validation:

- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`
- `DEV_DOC_COUNT=0`
- `OLD_VERSION_FILE_COUNT=0`
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`

Hashes:

- `SOURCE_RUNTIME_42_COMBINED_SHA256=8EC7F210195B57951E03EDA5797917B199816E86F8E92E12211B5D2589A62B08`
- `DIRECT_RUNTIME_42_COMBINED_SHA256=8EC7F210195B57951E03EDA5797917B199816E86F8E92E12211B5D2589A62B08`
- `DIRECT_FULL_COMBINED_SHA256=EE0B53ACD8570EB1E94BE5E29A8A7F12753C7789FD08B6EAAB9199A13BAC9A61`

Modified old SOURCE:

`false`

Started PZ / Steam:

`false`

Wrote user mods / saves / Workshop / game directory:

`false`

Final status:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.46_SOURCE_READY_FOR_DIRECT_INSTALL_TEST

```

## 0.5.46_DIRECT_INSTALL_VALIDATION.md

- SHA-256: `7985F116C0DA57440C5BA74CCE7BFEEA929F12DD10B2EE1E5CA46A490691ECEF`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.46 Direct Install Validation

DIRECT_INSTALL:

`[LOCAL_PATH_REDACTED]`

First-level tree:

```text
XNP_PZ_DistanceRunnerTrait
鈹溾攢 42
鈹溾攢 mod.info
鈹斺攢 poster.png
```

Validation:

- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_42_EXISTS=true`
- `TOP_LEVEL_MOD_INFO_EXISTS=true`
- `TOP_LEVEL_POSTER_EXISTS=true`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`
- `B42_STRUCTURE_VALID=true`
- `RUNTIME_FILES_COMPLETE=true`
- `DEV_DOC_COUNT=0`
- `AUDIT_FILE_COUNT=0`
- `CONSOLE_COUNT=0`
- `WORKSHOP_FILE_COUNT=0`
- `CACHE_COUNT=0` excluding runtime module `XNP_DR_NearbyZombieCache.lua`
- `OLD_VERSION_FILE_COUNT=0`
- `ABSOLUTE_PATH_LEAK_COUNT=0`
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`

Runtime counts:

- `SOURCE_42_FILE_COUNT=74`
- `DIRECT_42_FILE_COUNT=74`

Hashes:

- `SOURCE_RUNTIME_42_COMBINED_SHA256=8EC7F210195B57951E03EDA5797917B199816E86F8E92E12211B5D2589A62B08`
- `DIRECT_RUNTIME_42_COMBINED_SHA256=8EC7F210195B57951E03EDA5797917B199816E86F8E92E12211B5D2589A62B08`
- `DIRECT_FULL_COMBINED_SHA256=EE0B53ACD8570EB1E94BE5E29A8A7F12753C7789FD08B6EAAB9199A13BAC9A61`

DIRECT_INSTALL_STATUS=PASS_STATIC


```

## 0.5.46_FIX_FROM_0.5.45_AUDIT.md

- SHA-256: `DAF95A24B44A8445AC6D304F2BAC192E6FDC23204D12B66C4F94B8B5CADE12F2`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.46 Fix From 0.5.45 Audit

Baseline SOURCE:

`[LOCAL_PATH_REDACTED]`

New SOURCE:

`[LOCAL_PATH_REDACTED]`

0.5.45 second-pass blocker:

`OLD_VERSION_FILE_COUNT=2`

Blocking files:

- `42/media/lua/shared/translate/CN/Sandbox_CN.txt`
- `42/media/lua/shared/translate/EN/Sandbox_EN.txt`

Fix:

- CN tooltip `0.5.44` changed to `0.5.46`.
- EN tooltip `0.5.44` changed to `0.5.46`.
- Build marker and version identity advanced to 0.5.46.
- Vehicle runtime history namespace string advanced to 0.5.46 as version identity text.

Not changed:

- Lua business logic.
- Clamp behavior.
- Clamp edge state machine.
- Sandbox option keys.
- Default values.
- Gameplay numbers.
- World scan ownership.
- Authority gates.

0.5.45 old SOURCE modified:

`false`


```

## 0.5.46_SECOND_PASS_AUDIT.md

- SHA-256: `7FAD9813E1A45213823F33DC9882228AA87C2FC6F74F495A26C0975EF4F882DA`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.46 Second Pass Audit

Audit mode:

`READ_ONLY_SECOND_PASS_AUDIT`

Allowed write performed:

`[LOCAL_PATH_REDACTED]`

No code was modified. DIRECT_INSTALL was not rebuilt. Project Zomboid and Steam were not launched. User mods, saves, Workshop, and game directories were not written.

## 1. Audit SOURCE

SOURCE:

`[LOCAL_PATH_REDACTED]`

SOURCE_EXISTS=true

BUILD_MARKER_OK=true

Observed marker:

`XNP_PZ_DISTANCE_TRAIT_0546_TRANSLATION_VERSION_RESIDUE_CLEANUP_A`

DISPLAY_NAME_OK=true

Observed display name:

`XNP Distance Runner Trait 0.5.46 Translation Version Residue Cleanup`

MOD_ID_STABLE=true

Observed Mod ID:

`XNP_PZ_DistanceRunnerTrait`

Version fields:

- `version=0.5.46`
- `modversion=0.5.46`

SOURCE_RUNTIME_COMPLETE=true

OLD_SOURCE_UNCHANGED=true

No 0.5.46 / 0546 / TRANSLATION_VERSION_RESIDUE residue was found in the 0.5.45 reference SOURCE runtime files.

USER_DIR_NOT_WRITTEN=true

## 2. Audit DIRECT_INSTALL

DIRECT_INSTALL:

`[LOCAL_PATH_REDACTED]`

DIRECT_INSTALL_EXISTS=true

First-level entries:

```text
XNP_PZ_DistanceRunnerTrait
鈹溾攢 42
鈹溾攢 mod.info
鈹斺攢 poster.png
```

Validation:

- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_42_EXISTS=true`
- `TOP_LEVEL_MOD_INFO_EXISTS=true`
- `TOP_LEVEL_POSTER_EXISTS=true`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`
- `B42_STRUCTURE_VALID=true`
- `RUNTIME_FILES_COMPLETE=true`
- `DEV_DOC_COUNT=0`
- `AUDIT_FILE_COUNT=0`
- `CONSOLE_COUNT=0`
- `WORKSHOP_FILE_COUNT=0`
- `OLD_VERSION_FILE_COUNT=0`
- `ABSOLUTE_PATH_LEAK_COUNT=0`
- `CACHE_COUNT=0` excluding runtime module `XNP_DR_NearbyZombieCache.lua`

Hash validation:

- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`
- `SOURCE_RUNTIME_42_COMBINED_SHA256=8EC7F210195B57951E03EDA5797917B199816E86F8E92E12211B5D2589A62B08`
- `DIRECT_RUNTIME_42_COMBINED_SHA256=8EC7F210195B57951E03EDA5797917B199816E86F8E92E12211B5D2589A62B08`
- `DIRECT_FULL_COMBINED_SHA256=EE0B53ACD8570EB1E94BE5E29A8A7F12753C7789FD08B6EAAB9199A13BAC9A61`

DIRECT_INSTALL_STATUS=PASS_STATIC

## 3. Old Version Token Hits

Active runtime scope:

- `*.lua`
- `*.txt`
- `mod.info`
- `42/mod.info`
- `BUILD_MARKER.txt`

Historical `.md` documents in SOURCE are not counted as active runtime. DIRECT_INSTALL contains no `.md`.

Results:

- `OLD_VERSION_FILE_COUNT=0`
- `OLD_VERSION_TOKEN_HITS=0`
- `CN_OLD_VERSION_HITS=0`
- `EN_OLD_VERSION_HITS=0`
- `0.5.44=0`
- `0544=0`
- `0.5.45=0`
- `0545=0`

CN / EN version:

- `CN_VERSION=0.5.46`
- `EN_VERSION=0.5.46`

OLD_VERSION_STATUS=PASS_STATIC

## 4. CN / EN Parity

Files checked:

- `42/media/lua/shared/translate/CN/Sandbox_CN.txt`
- `42/media/lua/shared/translate/EN/Sandbox_EN.txt`

Results:

- `CN_SANDBOX_FILE_PRESENT=true`
- `EN_SANDBOX_FILE_PRESENT=true`
- `CN_OPTION_COUNT=94`
- `EN_OPTION_COUNT=94`
- `CN_EN_KEY_PARITY=true`
- `MISSING_CN_KEYS=0`
- `MISSING_EN_KEYS=0`
- `DUPLICATE_KEYS=0`
- `ODD_QUOTES=0`
- `EMPTY_VALUES=0`
- `BOM_COUNT=0`
- `NULL_COUNT=0`
- `ENCODING_ERRORS=0`

Scope note:

Only `Sandbox_XNPDistanceRunner_*` option a
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `94FE9302EA4380E96F4777A7DC8C7B62D7CD695D3AF632EC6D970281A22C2460`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

Version:

`0.5.46`

Build marker:

`XNP_PZ_DISTANCE_TRAIT_0546_TRANSLATION_VERSION_RESIDUE_CLEANUP_A`

Lua files:

`64`

Lua total lines:

`12268`

Active runtime old version token scan:

- `OLD_VERSION_FILE_COUNT=0`
- `OLD_VERSION_TOKEN_HITS=0`
- `CN_OLD_VERSION_HITS=0`
- `EN_OLD_VERSION_HITS=0`
- `CN_VERSION=0.5.46`
- `EN_VERSION=0.5.46`

Translation integrity:

- `CN_EN_KEY_PARITY=true`
- `ODD_QUOTES=0`
- `BOM_COUNT=0`
- `NULL_COUNT=0`
- `ENCODING_ERRORS=0`

Forbidden grep:

- `direct_clamp_print=0`
- `coordinate_write=0`
- `player:hasTrait=0`
- `TraitFactory=0`
- `CharacterTraitDefinition=0`
- `RunningShove=0`
- `BumpedState=0`
- `GameTime:setMultiplier=0`
- `HaloTextHelper=0`
- `player:Say=0`
- `setVariable("bumped")=0`
- `getZombieList=0`
- `state_hold active=0`
- `PREBITE_JOG_RESCUE_MIN_ENDURANCE=0`
- `PreBite 0.30 active gate=0`

Central world query:

- direct scan modules: `1`
- allowed module: `XNP_DR_CentralWorldQuery.lua`
- scheduler call sites: `1`

Lua interpreter / luac:

`NOT_AVAILABLE_IN_CURRENT_SHELL`

Lua execution syntax check:

`NOT_VERIFIABLE_BY_STATIC_AUDIT`

STATIC_AUDIT_STATUS=PASS_STATIC_WITH_LUA_EXEC_NOT_VERIFIABLE


```
