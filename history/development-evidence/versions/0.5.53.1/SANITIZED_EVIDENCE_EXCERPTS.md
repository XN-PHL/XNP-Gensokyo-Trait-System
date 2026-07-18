# 0.5.53.1 Sanitized Evidence Excerpts

## 0.5.53.1_CONFLICT_GATE_REPORT.md

- SHA-256: `0C678C988483131C700202D784C2C98017345A1F6B0CB14388227E7907313D3C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Conflict Gate Report

Conflict gate module: XNP_DR_FullFatalTimingDiagnostic.lua
Blocked Mod IDs:
- XNP_PZ_DistanceRunnerTrait
- XNP_PZ_DistanceRunnerTrait_FATAL_TIMING_TEST

Block log:
- [XNP FULL DIAG BLOCK] conflicting_xnp_mod_loaded=true ids=<ids>

When blocked:
- Runtime OnPlayerUpdate is not registered.
- PurplePhoenixDamageGuard is not registered.
- Diagnostic event handlers return without gameplay or diagnostic writes.
- This prevents double trait/runtime registration while another XNP package is active.

```

## 0.5.53.1_DIAGNOSTIC_EVENT_REPORT.md

- SHA-256: `98B9E1FB5826BE069B8CF115B8D03F858FF501AABC7899A94CEF638CAE7278F6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Diagnostic Event Report

DIAGNOSTIC_MODULE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_FullFatalTimingDiagnostic.lua
MODDATA_NAMESPACE=XNP_FATAL_TIMING_FULL_DIAG_0531
AUTO_DAMAGE=false
AUTO_KILL=false
AUTO_HEAL_TEST=false

Events registered:
- OnTick
- OnGameBoot
- OnGameStart
- OnPlayerGetDamage
- OnWeaponHitCharacter
- OnPlayerUpdate
- OnPlayerDeath
- OnGameExit

Logged fields include frame, monotonic_ms, health, overall health, isDead, isAlive, isInvincible, Phoenix enabled, Phoenix ready/cooldown, event name, damage source/type, raw damage parameter, predicted damage, and recovery result.

Critical logs retained:
- OnPlayerGetDamage
- OnWeaponHitCharacter
- OnPlayerUpdate same/next frame
- HEALTH_LE_20_PERCENT
- HEALTH_LE_ZERO
- IS_DEAD_FIRST_TRUE
- PHOENIX_TRIGGER_ATTEMPT
- PHOENIX_RECOVERY_WRITE
- NEXT_FRAME_STATE
- OnPlayerDeath

```

## 0.5.53.1_FULL_DIAGNOSTIC_RUNTIME_INVENTORY.md

- SHA-256: `03A9EF661B2CC7028114658BF1149B70FEEAE38420D9EC017BCCC3CDFD1C1612`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Full Diagnostic Runtime Inventory

SOURCE_OUTPUT_PATH=
[LOCAL_PATH_REDACTED]
DROP_FOLDER=
[LOCAL_PATH_REDACTED]
MOD_ID=XNP_PZ_DistanceRunnerTrait_FATAL_TIMING_FULL_TEST
DISPLAY_NAME=XNP Distance Runner + Phoenix Full Timing Diagnostic [IP_REDACTED]
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05531_FATAL_TIMING_FULL_DIAGNOSTIC_A

MISSING_BASE_RUNTIME_FILE_COUNT=
0
SOURCE_DROP_SHA256_MISMATCH_COUNT=
0
REGISTRIES_LUA_PRESENT=true
DISTANCE_RUNNER_RUNTIME_PRESENT=true
PHOENIX_RUNTIME_PRESENT=true
YELLOW_UI_PRESENT=true
PURPLE_UI_PRESENT=true

## Required Runtime Files

- registries.lua: present
- Distance Runner trait registration: present
- Phoenix trait registration: present
- yellow runtime and UI: present
- Phoenix runtime and purple UI: present
- Sandbox and translations: present
- trait icons: present
- fatal timing diagnostic module: present

## Drop File Tree

- 42
- 42\media
- 42\media\lua
- 42\media\lua\client
- 42\media\lua\client\XNP_PZ_DistanceRunner
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ActivationDiagnostic.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutActionBus.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CentralWorldQuery.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CriticalWindow.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerBreakout.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerClassifier.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DraggableStatusIcon.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakoutCost.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyInput.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceBandState.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceCapabilityState.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FallRecoveryInput.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FoodReserveConversion.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FullFatalTimingDiagnostic.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactCandidateSnapshot.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactQuotaMeter.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_JogBumpLaunch.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_JogFallShockwave.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_LongMigrationStaminaAssist.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_MeleeMultiplayerGuard.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_MinorScrapeCost.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_MovementIntentGate.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_NativeTripWindow.lua
- 42\media\lua\client\XNP
[EXCERPT_TRUNCATED]
```

## 0.5.53.1_TRAIT_REGISTRATION_REPORT.md

- SHA-256: `EC164E43046439731B7E9341894504049D6FEA6F3257F88AE43B8E3DA720E837`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Trait Registration Report

Distance Runner Full ID: XNPDistanceRunnerTrait:XNPDistanceRunner
Distance Runner Cost: 1
Phoenix Full ID: XNPPhoenixTrait:XNPPurplePhoenix
Phoenix Cost: 1
DISTANCE_RUNNER_TRAIT_REGISTERED_STATIC=true
PHOENIX_TRAIT_REGISTERED_STATIC=true
BOTH_TRAITS_AVAILABLE_STATIC=true
MUTUAL_EXCLUSION_DECLARED=false

Runtime logs added:
- [XNP FULL DIAG] distance_runner_trait_registered=true cost=1
- [XNP FULL DIAG] phoenix_trait_registered=true cost=1
- [XNP FULL DIAG] both_traits_available=true

Object-style trait detection is preserved. No player:hasTrait(string), TraitFactory, or CharacterTraitDefinition runtime route was added.

```

## BUILD_MARKER.txt

- SHA-256: `2D76CF3C12F62CF5E4C63D88985686E6177664E917C4C0C917B09DA9B2C18492`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_05531_FATAL_TIMING_FULL_DIAGNOSTIC_A

```

## FINAL_REPORT.md

- SHA-256: `71C558AD475441149ACD7178A40A37589BC4AC8BCD8952479A99726EB257B432`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=
[LOCAL_PATH_REDACTED]
USER_DRAG_FOLDER=
[LOCAL_PATH_REDACTED]
VERSION=[IP_REDACTED]
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05531_FATAL_TIMING_FULL_DIAGNOSTIC_A
MOD_ID=XNP_PZ_DistanceRunnerTrait_FATAL_TIMING_FULL_TEST
DISPLAY_NAME=XNP Distance Runner + Phoenix Full Timing Diagnostic [IP_REDACTED]

DISTANCE_RUNNER_TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner
DISTANCE_RUNNER_COST=1
PHOENIX_TRAIT_FULL_ID=XNPPhoenixTrait:XNPPurplePhoenix
PHOENIX_COST=1
BOTH_TRAITS_AVAILABLE_STATIC=true

FULL_RUNTIME_INCLUDED=true
FATAL_TIMING_DIAGNOSTIC_INCLUDED=true
CONFLICT_GATE_INCLUDED=true
MISSING_BASE_RUNTIME_FILE_COUNT=
0
SOURCE_DROP_SHA256_MISMATCH_COUNT=
0
TEXT_BOM_FILES=
0
TEXT_NULL_FILES=
0

BLOCKER=NONE_STATIC
FINAL_STATUS=XNP_PZ_0.5.53.1_FATAL_TIMING_FULL_DIAGNOSTIC_READY

```

## 0.5.53.1_PACKAGE_VALIDATION.md

- SHA-256: `D3DEE47502CF6829249A3053F07D5C3AF5C1BA1303A4D046E2EF43E7404DC96A`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Package Validation

PARENT_DIRECTORY=
[LOCAL_PATH_REDACTED]
PARENT_FIRST_LEVEL=
XNP_PZ_DistanceRunnerTrait_FATAL_TIMING_FULL_TEST
DROP_DIRECTORY=
[LOCAL_PATH_REDACTED]
DROP_FIRST_LEVEL=
42, mod.info, poster.png

PARENT_FIRST_LEVEL_VALID=true
DROP_FIRST_LEVEL_VALID=true
NO_PACKAGE_NESTING=true
ONE_DRAG_READY_CREATED=false
DIAGNOSTIC_VERSION=true

MISSING_BASE_RUNTIME_FILE_COUNT=
0
SOURCE_DROP_SHA256_MISMATCH_COUNT=
0
DROP_EXTRA_FILE_COUNT=
0

## SHA256

- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ActivationDiagnostic.lua = 18718D17FFDCB890FA77AC2D82A1E8B1FCADE6287048039C5CADC268FD1236A7
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua = DA8961612DBE0537929E9B58831501FE156DD80F9BF8FE73467DFFB33ED6B3B4
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutActionBus.lua = 1F577575B5F42F2FC114D573BE9CD33FE2A8AF2382DDA9C9640F0BBD910FAD44
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua = 2BBB6F45AF6F9896216D338DAFC3D10DA30D60B469FB962F86B93EE276E85C33
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CentralWorldQuery.lua = E23D253843B8D77DAAA98164F22B46D4F77B5D8F24D80F100A965D4DD58EEB33
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CriticalWindow.lua = F519378E9DDB4D0EA27848482B1F3D3CF05DD75FB7AE2924EC4708ECF5A70E50
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerBreakout.lua = D44747A3317F895D966844367F4D988FA2C6EFCEE1C52D2AA5977D658822960E
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerClassifier.lua = 66EEFCCA2C8C14F683B63FC87A098BB70D0FDE7884265FE7AD8F0A0DF7797583
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DraggableStatusIcon.lua = 80333270A88BD000D046DDBB4F21A8364E3AFB19C28A36D0FD719D5A4AB5BDE0
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua = 7437193A3F0F20770CFD406DBE0374ECC3A245F1F8F7827B13A84AC798553822
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakoutCost.lua = D9AB4AC2ADD927B7ECAB9C195B708B1D8B02A2087CE23559BD87F410702A49D7
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyInput.lua = 2FBB0832363E0F5F98CACAF42C1022DB7EE8794ACF36107AB7D8B21FD1EA4DD7
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceBandState.lua = EF358C62E0E4FBDA99329E23C49AE3851BBD2AA30E7438A68583A5165877AFE2
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceCapabilityState.lua = 51B350AB1EE9A0ACEE5EAD80A8A11C02D322D0CDAD6C2B1CBB54952B809F4473
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FallRecoveryInput.lua = BD35C4C9FE836E980345C906F4B5C21ECD631DFBDD669BB68A3FD2929CFC1FD0
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FoodReserveConversion.lua = E234851419C87572FA347F980A4348C891CF993969BC523033E2D9C4434A979D
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FullFatalTimingDiagnostic.lua = 082B8C97D4D5CE7B8C831A8AE4EB98D5B4DA84D864D14F1A0509547DE6EAC977
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactCandidateSnapshot.lua = F
[EXCERPT_TRUNCATED]
```

## 0.5.53.1_PREINSTALL_AUDIT.md

- SHA-256: `478DFF1D6BEA01AB51D0EDB0EFF5CE97ACA86604FD099CC5C54B3247132C69D6`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Preinstall Audit

1. SOURCE: [LOCAL_PATH_REDACTED]
2. PRODUCT: [LOCAL_PATH_REDACTED]
3. PARENT_FIRST_LEVEL=XNP_PZ_DistanceRunnerTrait_FATAL_TIMING_FULL_TEST
4. DROP_FIRST_LEVEL=42|mod.info|poster.png
5. VERSION=[IP_REDACTED]; INTERNAL=[IP_REDACTED]-b42-fatal-timing-full-diagnostic-a; BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05531_FATAL_TIMING_FULL_DIAGNOSTIC_A; MOD_ID=XNP_PZ_DistanceRunnerTrait_FATAL_TIMING_FULL_TEST
6. TRAITS: DISTANCE_RUNNER_REGISTERED=true; DISTANCE_RUNNER_CN_NAME=\u8ddd\u79bb\u8dd1\u8005; DISTANCE_RUNNER_EN_NAME=Distance Runner; DISTANCE_RUNNER_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner; DISTANCE_RUNNER_COST=1; PHOENIX_REGISTERED=true; PHOENIX_CN_NAME=\u4e0d\u6b7b\u9e1f; PHOENIX_EN_NAME=Phoenix; PHOENIX_FULL_ID=XNPPhoenixTrait:XNPPurplePhoenix; PHOENIX_COST=1
7. BOTH_TRAITS_SELECTABLE_BY_STATIC_RULE=true; TRAIT_MUTUAL_EXCLUSION_COUNT=0; TRAIT_ID_COLLISION_COUNT=0; TRANSLATION_KEY_COLLISION_COUNT=0
8. COMPLETE_RUNTIME_TREE: BASE_053_RUNTIME_INVENTORIED=true; MISSING_BASE_RUNTIME_FILE_COUNT=0; REGISTRIES_LUA_PRESENT=True; DISTANCE_RUNNER_RUNTIME_PRESENT=True; PHOENIX_RUNTIME_PRESENT=True; YELLOW_UI_PRESENT=True; PURPLE_UI_PRESENT=True
9. YELLOW_FEATURES: WALK_NO_IMPACT_PRESENT=true; JOG_BUMP_PRESENT=True; SPRINT_VEHICLE_IMPACT_PRESENT=True; CONTROLLED_ESCAPE_PRESENT=True; EMERGENCY_PRESENT=True; PREBITE_RESCUE_PRESENT=True; SPRINT_TRIP_IMMUNITY_PRESENT=True; TIERED_FOOD_RECOVERY_PRESENT=True; SP_MELEE_PRESENT=True; MP_MELEE_DISABLED=True; CENTRAL_SCHEDULER_PRESENT=True; CENTRAL_WORLD_QUERY_PRESENT=True; YELLOW_INDEPENDENT_TOGGLE_PRESENT=True; YELLOW_UI_PRESENT=true
10. PHOENIX_FEATURES: PHOENIX_TRAIT_COST=1; PHOENIX_TRIGGER_DEFAULT_PERCENT=20; PHOENIX_INVULNERABILITY_DEFAULT_SECONDS=10; PHOENIX_BASE_COOLDOWN_DAYS=7; PHOENIX_REQUIRE_PANIC_ZERO_DEFAULT=True; PHOENIX_EARLY_RECHARGE_ENABLED_DEFAULT=true; PHOENIX_EARLY_RECHARGE_MAX_DAYS=2; PHOENIX_MINIMUM_COOLDOWN_DAYS=5; PHOENIX_WELL_FED_MAX_CREDIT_DAYS=1; PHOENIX_HEALTHY_MAX_CREDIT_DAYS=1; PHOENIX_INDEPENDENT_TOGGLE_PRESENT=True; PHOENIX_ROUND_ICON_PRESENT=True; PHOENIX_OFF_COLOR_WHITE=True; PHOENIX_READY_COLOR_BLUE=true; PHOENIX_INVULNERABLE_STATE_PRESENT=True; PHOENIX_COOLDOWN_STATE_PRESENT=True; PHOENIX_WAITING_FOR_CALM_STATE_PRESENT=True
11. INDEPENDENCE: YELLOW_ENABLED_KEY=XNP_DR_YELLOW_ENABLED; PHOENIX_ENABLED_KEY=XNP_DR_PHOENIX_ENABLED; YELLOW_TOGGLE_CHANGES_ONLY_YELLOW=true; PHOENIX_TOGGLE_CHANGES_ONLY_PHOENIX=true; PURPLE_RIGHT_CLICK_CALLS_GLOBAL_MASTER=false; YELLOW_ALPHA_DEPENDS_ON_PHOENIX=false; PHOENIX_ALPHA_DEPENDS_ON_YELLOW=false; YELLOW_COLOR_DEPENDS_ON_PHOENIX=false; PHOENIX_COLOR_DEPENDS_ON_YELLOW=false; YELLOW_POSITION_KEY_UNIQUE=true; PHOENIX_POSITION_KEY_UNIQUE=true; YELLOW_PANEL_INSTANCE_UNIQUE=true; PHOENIX_PANEL_INSTANCE_UNIQUE=true
12. DIAGNOSTIC: DIAGNOSTIC_MODULE_PRESENT=True; DIAGNOSTIC_MODDATA=XNP_FATAL_TIMING_FULL_DIAG_0531; AUTO_DAMAGE=false; AUTO_KILL=false; AUTO_HEAL_TEST=false; NO_FORCED_TELEPORT=True; NO_SAVE_DAMAGE=t
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `7839C2689769D99B91A593B3A394C2D564E4B06F25662E6672B6A473B2178B07`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_OUTPUT_PATH=
[LOCAL_PATH_REDACTED]
DROP_FOLDER=
[LOCAL_PATH_REDACTED]
LUA_FILE_COUNT=
76
LUA_TOTAL_LINES=
15446
SOURCE_FILE_COUNT=
112
DROP_FILE_COUNT=
89

Checks:
- Missing required runtime files: 
0
- SOURCE to DROP SHA256 mismatches: 
0
- Drop extra files: 
0
- Text BOM files: 
0
- Text NULL-containing files: 
0
- Distance Runner Cost=1: 
True
- Phoenix Cost=1: 
True
- Diagnostic module required by Bootstrap: 
True
- AUTO_DAMAGE=false present: 
True
- AUTO_KILL=false present: 
True
- AUTO_HEAL_TEST=false present: 
True
- Conflict gate present: 
True

Forbidden actions:
- Project Zomboid launched: NO
- Steam launched: NO
- User mods written: NO
- Workshop written: NO
- Old 0.5.53 SOURCE modified: NO
- Formal ONE_DRAG_READY created: NO

Lua syntax execution: NOT_VERIFIABLE_NO_LOCAL_PZ_LUA_RUNTIME_EXECUTED
Static text balance: PASS_BASIC_GENERATION_CHECK
BLOCKER=NONE_STATIC

```
