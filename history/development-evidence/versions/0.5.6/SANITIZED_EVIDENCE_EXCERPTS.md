# 0.5.6 Sanitized Evidence Excerpts

## 0.5.6_REAL_GAME_NOTE_FROM_LATEST_CONSOLE.md

- SHA-256: `C9441CDFCBE7CA43AD0F48BD4C34AB3F5D617B0D23543C24179985F4591CC817`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.6 Real Game Note from Latest Console

Latest user-provided console evidence loaded 0.5.5, not 0.5.6.

```text
[XNP DistanceRunner] loaded version=0.5.5 internal=0.5.5-b42-stable-core-true-moodle-audit-a build=XNP_PZ_DISTANCE_TRAIT_055_STABLE_CORE_MOODLE_AUDIT_A
```

Frozen interpretation:

```text
LATEST_REAL_GAME_LOG_VERSION=0.5.5
0.5.6_REAL_GAME_RESULT=NOT_VERIFIED_BY_LATEST_CONSOLE
0.5.6_SOURCE_EXISTS=YES
0.5.7_BASE_SOURCE_PREFERRED=0.5.6_SOURCE
0.5.7_BASE_SOURCE_FALLBACK=0.5.5_SOURCE_ONLY_IF_0.5.6_SOURCE_MISSING
```

Observed 0.5.5 status:

- No right-top icon.
- No overhead text.
- No-icon route is acceptable.
- Distance adrenaline trigger has evidence: `trigger_zombie_distance=2.944`.

Conclusion:

```text
ADRENALINE_DISTANCE_TRIGGER=PASS
ACTIVE_LONG_DURATION_REASON=THREAT_RADIUS_AND_20S_MEMORY
DISTANCE_SYSTEM_DOES_NOT_NEED_FULL_REWRITE
```

```

## BUILD_MARKER.txt

- SHA-256: `B1A62A2ABAB0ECD86420E70545EA63F8A0A92C50ED59969956E82E2C76022270`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_056_RELEASE_CANDIDATE_CONFIG_A

```

## CHANGELOG_0.5.6.md

- SHA-256: `9296F75F603F8D0E67712F70809D38B8148116C12DBCA0385041EB046289F3CF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Changelog 0.5.6

## Version

- Version: 0.5.6
- Internal version: 0.5.6-b42-release-candidate-config-a
- Build marker: XNP_PZ_DISTANCE_TRAIT_056_RELEASE_CANDIDATE_CONFIG_A
- Display name: XNP Distance Runner Trait 0.5.6 Release Candidate Config

## Changed

- Created a release-candidate config build from the accepted 0.5.5 stamina core.
- Added centralized config fields for stamina, adrenaline, summary logging, visual feedback, true Moodle, metabolic debt, and body-status audit policy.
- Added `ENABLE_MOD` master switch.
- Added `ENABLE_DEBUG_SUMMARY_LOG` as the actual gate for `[XNP STAMINA SUMMARY]`.
- Kept visual feedback, true Moodle, fake status icon, and body-status application disabled.

## Not changed

- Mod ID remains `XNP_PZ_DistanceRunnerTrait`.
- Trait full ID remains `XNPDistanceRunnerTrait:XNPDistanceRunner`.
- Native trait registration and trait detection are preserved.
- No speed modification, coordinate write, or time modification was added.

```

## FINAL_REPORT.md

- SHA-256: `1FEFA01A5E3F94755F911105ED4590F5B7F9AD57441C429759FBCC57A9F3E6A5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.6

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.6

INTERNAL_VERSION=0.5.6-b42-release-candidate-config-a

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056_RELEASE_CANDIDATE_CONFIG_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.6 Release Candidate Config

## Preserved identity

- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- Native trait definition: preserved
- Chinese translation: preserved
- Yellow F trait icon: preserved
- Native trait detection: preserved

## 0.5.5 accepted baseline

- 0.5.5 loaded in real game.
- Trait detection worked.
- Halo disabled.
- True Moodle disabled.
- Stamina and summary logs worked.
- Metabolic debt recorded.
- Body status/muscle strain observation remains not attributable to XNP 0.5.5 by static review.

## 0.5.6 implementation

- Stamina core: frozen from 0.5.5.
- Config surface: centralized in `XNP_DR_Config.lua`.
- Summary log: controlled by `ENABLE_DEBUG_SUMMARY_LOG`.
- Visual feedback: disabled.
- True Moodle: disabled.
- Fake right-top icon: not restored.
- Body status application: disabled audit-only.
- Metabolic application: debt-only record, no penalty.

## Key config

```text
ENABLE_MOD=true
ENABLE_READY_DRAIN_REDUCTION=true
READY_STAMINA_DRAIN_MULTIPLIER=0.40
ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10
MIN_ENDURANCE_FLOOR=0.05
ENDURANCE_SAMPLE_INTERVAL=0.10
THREAT_TRIGGER_RADIUS=4.0
ADRENALINE_MEMORY_DURATION=20.0
THREAT_SCAN_INTERVAL=0.50
METABOLIC_COST_METHOD=DEBT_ONLY
METABOLIC_COST_MULTIPLIER=1.0
ENABLE_METABOLIC_APPLICATION=false
ENABLE_VISUAL_FEEDBACK=false
VISUAL_FEEDBACK_METHOD=DISABLED_AFTER_HALO_FAILURE
ENABLE_TRUE_MOODLE=false
STATUS_MOODLE_METHOD=NOT_CONFIRMED
RIGHT_TOP_ICON_STATUS=DISABLED_NO_SAFE_TRUE_MOODLE
STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT
ENABLE_DEBUG_SUMMARY_LOG=true
STAMINA_SUMMARY_LOG_INTERVAL=10.0
DEBUG=false
ENABLE_BODY_STATUS_APPLICATION=false
BODY_STATUS_APPLICATION_METHOD=DISABLED_AUDIT_ONLY
SANDBOX_OPTIONS_METHOD=DEFERRED_CONFIG_ONLY
```

## File tree

```text
mod.info
BUILD_MARKER.txt
README_CN.md
README_EN.md
CONFIG_GUIDE_CN.md
CONFIG_GUIDE_EN.md
CHANGELOG_0.5.6.md
RELEASE_CANDIDATE_TEST_0.5.6.md
0.5.5_REAL_GAME_RESULT_SUMMARY.md
B42_19_BODY_STATUS_MUSCLE_STRAIN_AUDIT_0.5.6.md
METABOLIC_DEBT_DESIGN_NOTE_0.5.6.md
STATIC_AUDIT.md
FINAL_REPORT.md
42/mod.info
42/media/registries.lua
42/media/scripts/XNPDistanceRunnerTraits.txt
42/media/ui/Traits/trait_xnpdistancerunner.png
42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua
42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua
42/media/lua/shared/translate/CN/UI.json
42/media/lua/shared/translate/EN/UI.json
42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Adrenaline.lua
42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua
42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_MoodleStatus.lua
42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_StaminaDrain.lua
42/media/lua/shared
[EXCERPT_TRUNCATED]
```

## METABOLIC_DEBT_DESIGN_NOTE_0.5.6.md

- SHA-256: `A82E707F455F88C152E0019312D5132A24AC476F2E3EB5EE94AFF3B0504BE4DB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Metabolic Debt Design Note 0.5.6

0.5.6 keeps metabolic cost as recorded diagnostic debt only.

## Current behavior

- `METABOLIC_COST_METHOD=DEBT_ONLY`
- `ENABLE_METABOLIC_APPLICATION=false`
- `METABOLIC_APPLICATION_STATUS=RECORDED_ONLY`
- Summary logs include `debt_total` when summary logging is enabled.

## Explicitly disabled

0.5.6 does not write Calories, Hunger, Fatigue, Stress, BodyDamage, BodyPart, Pain, or MuscleStrain.

## Reason

The stamina core has real-game success evidence. Metabolic penalties do not. Applying penalties before validating tuning and UI communication would make the release candidate harder to test and could create hidden side effects.

Any future metabolic application must be implemented in a separate test build with trait gating, recovery behavior, clear player feedback, and no effect on characters without the XNP Distance Runner trait.

```

## README_CN.md

- SHA-256: `4CF695B9CB6ECEF736F7D63C4CDA67C8764B90B8261DA2B9E48A5D34DFE1B119`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.6

Project Zomboid Build 42.19.0 鐨勫彂甯冨€欓€夐厤缃増鏈€?
## 韬唤

- Mod ID锛歚XNP_PZ_DistanceRunnerTrait`
- Trait full ID锛歚XNPDistanceRunnerTrait:XNPDistanceRunner`
- 鐗堟湰锛歚0.5.6`
- 鍐呴儴鐗堟湰锛歚0.5.6-b42-release-candidate-config-a`
- 鏋勫缓鏍囪瘑锛歚XNP_PZ_DISTANCE_TRAIT_056_RELEASE_CANDIDATE_CONFIG_A`

## 鏈増鏈仛浠€涔?
- 淇濈暀 0.5.5 宸查€氳繃瀹炴満楠岃瘉鐨勮€愬姏鏍稿績銆?- 鍙鎷ユ湁 XNP Distance Runner 鍘熺敓鐗硅川鐨勮鑹查檷浣庤€愬姏娑堣€椼€?- 浠ｈ阿鎴愭湰鍙褰曚负 `debt_total`锛屼笉瀹為檯鎯╃綒銆?- 鎵€鏈変笉绋冲畾瑙嗚鍙嶉銆乀rue Moodle銆佸彸涓婅浼浘鏍囥€佽韩浣撶姸鎬佸啓鍏ラ粯璁ゅ叧闂€?
## 鏈増鏈笉鍋氫粈涔?
- 涓嶄慨鏀归€熷害銆?- 涓嶄慨鏀?X/Y 鍧愭爣銆?- 涓嶄慨鏀规椂闂村€嶇巼銆?- 涓嶈皟鐢?HaloTextHelper銆?- 涓嶅垱寤鸿嚜瀹氫箟 ISPanel UI銆?- 涓嶅啓 BodyDamage銆丳ain銆丗atigue銆丮uscleStrain銆丠unger 鎴?Calories銆?
## 娴嬭瘯閲嶇偣

鍏堢‘璁?0.5.5 鐨勮€愬姏浼樺娍浠嶇劧瀛樺湪锛屽啀纭鍏抽棴 `ENABLE_DEBUG_SUMMARY_LOG=false` 鍚?summary 鏃ュ織鍋滄銆?
```

## README_EN.md

- SHA-256: `D08CA60B6EACBFC0EB7B316B9397C87974617C08162F70A5038E6B4601526CC5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.6

Release candidate config build for Project Zomboid Build 42.19.0.

## Identity

- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- Version: `0.5.6`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_056_RELEASE_CANDIDATE_CONFIG_A`

## What this version does

- Preserves the accepted 0.5.5 stamina core.
- Reduces stamina drain for characters with the XNP Distance Runner trait.
- Records metabolic debt for diagnostics only.
- Keeps visual feedback, true Moodle, and body-status application disabled by default.

## What this version does not do

- No speed modification.
- No coordinate write.
- No time multiplier change.
- No Halo text.
- No fake right-top icon.
- No custom UI panel.
- No BodyDamage, Pain, Fatigue, MuscleStrain, Hunger, or Calories write.

## Status

```text
FORMAL_DISTANCE_RUNNER_GAMEPLAY_ENABLED=PARTIAL_STAMINA_CORE_ONLY
RELEASE_CANDIDATE_CONFIG=YES
```

```

## RELEASE_CANDIDATE_TEST_0.5.6.md

- SHA-256: `40236E9075E5C3E2F0D6B076665A9C6C1565C6F92F2EF389946B9E5F17D8552C`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Release Candidate Test 0.5.6

## Install target

Manual copy only. This source was not written to the user mods folder, Workshop, saves, or the game directory.

## Test checklist

1. Confirm the mod appears as `XNP Distance Runner Trait 0.5.6 Release Candidate Config`.
2. Create or load a character with `XNPDistanceRunnerTrait:XNPDistanceRunner`.
3. Confirm the trait is detected.
4. Walk, jog, and run long enough to observe stamina refund behavior.
5. Confirm no Halo text appears.
6. Confirm no custom right-top fake icon appears.
7. Confirm no true Moodle is registered.
8. Confirm `[XNP STAMINA SUMMARY]` appears while `ENABLE_DEBUG_SUMMARY_LOG=true`.
9. Set `ENABLE_DEBUG_SUMMARY_LOG=false`, reload the mod, and confirm summary logs stop.
10. Confirm no visible health-panel injury is created by the mod.

## Expected runtime logs

```text
[XNP FEEDBACK] method=DISABLED_AFTER_HALO_FAILURE
[XNP MOODLE] status=DISABLED_NO_SAFE_TRUE_MOODLE
```

## Failure criteria

Stop testing and report if any of these occur:

- speed or coordinates change unexpectedly
- no-trait character receives stamina changes
- health-panel injury appears immediately after XNP stamina behavior
- Halo, speech bubble, fake status icon, or custom panel appears

```

## B42_19_BODY_STATUS_MUSCLE_STRAIN_AUDIT_0.5.6.md

- SHA-256: `F26A71D94ACC347CE35D4A5217AE165C3E63A2A22A5D96884F207FF16EC0508B`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Body Status / Muscle Strain Audit for 0.5.6

This audit is static only. No game executable, Steam, save, user mods folder, or Workshop path was used.

## Findings

1. Arm or leg muscle strain descriptions can plausibly be vanilla effects from running, vaulting, combat, exercise, heavy load, or the sandbox setting `MuscleStrainFactor`.
2. 0.5.5 does not actively write BodyDamage, BodyPart, Pain, Fatigue, or MuscleStrain fields.
3. B42.19 exposes BodyDamage and BodyPart methods that can affect stiffness and injury state, including `BodyDamage:addStiffness(...)`, `BodyPart:setStiffness(...)`, and `BodyPart:addStiffness(...)`.
4. BodyDamage and BodyPart classes include save/load behavior. Any write to stiffness, pain, wound, bleeding, infection, fracture, or similar fields can persist or produce health-panel symptoms.
5. A light, short-term, recoverable muscle strain system might be possible later, but it requires a separate test version, explicit recovery rules, visible user feedback, and no effect on no-trait characters.
6. No-trait pollution is possible if writes are applied outside a strict trait-gated runtime path.
7. Invisible injury descriptions or unclear health-panel text are possible if body fields are changed without matching UI/status feedback.
8. Recommendation for 0.5.x: do not use body status as a gameplay outlet yet.
9. Frozen config: `BODY_STATUS_APPLICATION_METHOD=DISABLED_AUDIT_ONLY`.
10. Even if a future API path is selected, 0.5.6 must not enable BodyDamage or BodyPart writes.

## Conclusion

```text
ENABLE_BODY_STATUS_APPLICATION=false
BODY_STATUS_APPLICATION_METHOD=DISABLED_AUDIT_ONLY
```

```

## STATIC_AUDIT.md

- SHA-256: `2DE8F06A583B9DD83B80C052E46253D20DF9545ACE6BF1A9F6EBF6951E74CF3D`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.6

## Source

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Counts

- Lua files: 12
- Lua total lines: 1038
- Markdown files: 87
- JSON parse: PASS

## Layout

- Root `media/lua`: ABSENT
- `42/media/lua`: PRESENT
- `42/media/scripts/XNPDistanceRunnerTraits.txt`: PRESENT
- `42/media/ui/Traits/trait_xnpdistancerunner.png`: PRESENT

## Lua 5.1 syntax execution

NOT_VERIFIABLE: no reliable `lua` or `luac` command was available in this Codex shell. No download or install was attempted.

Static text checks were still completed.

## Forbidden active API scan

Result: PASS with one non-blocking documentation/comment hit.

Only hit:

```text
XNP_DR_Config.lua: -- Body status is audit-only. 0.5.6 never writes BodyDamage or BodyPart fields.
```

No active Lua call was found for:

- `player:hasTrait("...")`
- `TraitFactory`
- `CharacterTraitDefinition`
- speed setters/getters
- coordinate writes
- `GameTime:setMultiplier`
- `RunningShove`
- `BumpedState`
- `HaloTextHelper`
- `player:Say`
- `SayWhisper`
- `AddLineChatElement`
- `ISPanel`
- `UIManager`
- fake right-top icon constants
- Calories/Hunger/Fatigue/Pain/Stress writes
- BodyDamage/BodyPart/MuscleStrain writes
- wound/bleeding/infection writes

## Runtime event scan

Events used:

- `Events.OnGameStart`
- `Events.OnCreatePlayer`
- `Events.OnPlayerUpdate`
- `Events.OnPlayerDeath`
- `Events.OnMainMenuEnter`
- `Events.OnGameExit`

No duplicate `AddPlayerPostInit` issue applies to Project Zomboid. No duplicate runtime event registration was found; code guards with `Core.events_registered`.

## Duplicate function scan

PASS: no duplicate `function Name(...)` definitions detected in active Lua files.

## Require graph

Manual review result: PASS.

The shared modules require constants/config/trait helpers; client bootstrap loads shared modules and runtime. No blocking circular dependency was found for the existing PZ load pattern.

## Config checks

Central config contains:

- `ENABLE_MOD=true`
- `ENABLE_READY_DRAIN_REDUCTION=true`
- `READY_STAMINA_DRAIN_MULTIPLIER=0.40`
- `ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10`
- `MIN_ENDURANCE_FLOOR=0.05`
- `ENDURANCE_SAMPLE_INTERVAL=0.10`
- `THREAT_TRIGGER_RADIUS=4.0`
- `ADRENALINE_MEMORY_DURATION=20.0`
- `THREAT_SCAN_INTERVAL=0.50`
- `METABOLIC_COST_METHOD=DEBT_ONLY`
- `METABOLIC_COST_MULTIPLIER=1.0`
- `ENABLE_METABOLIC_APPLICATION=false`
- `ENABLE_VISUAL_FEEDBACK=false`
- `VISUAL_FEEDBACK_METHOD=DISABLED_AFTER_HALO_FAILURE`
- `ENABLE_TRUE_MOODLE=false`
- `STATUS_MOODLE_METHOD=NOT_CONFIRMED`
- `RIGHT_TOP_ICON_STATUS=DISABLED_NO_SAFE_TRUE_MOODLE`
- `STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT`
- `ENABLE_DEBUG_SUMMARY_LOG=true`
- `STAMINA_SUMMARY_LOG_INTERVAL=10.0`
- `DEBUG=false`
- `ENABLE_BODY_STATUS_APPLICATION=false`
- `BODY_STATUS_APPLICATION_METHOD=DISABLED_AUDIT_ONLY`
- `SANDBOX_OPTIONS_METHOD=DEFERRED_CONFIG_ONLY`

## Summary log gate

PASS: `[XNP STAMINA SUMMARY]` is gated by `Config.ENABLE_DEBUG_SUMMARY_LOG`.

## Binary/text hygiene

- Empty fil
[EXCERPT_TRUNCATED]
```
