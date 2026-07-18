# 0.5.54.1 Sanitized Evidence Excerpts

## 0.5.54.1_054_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `D723B45E46B7485588858FB8C11B0071B8F3E993A9658601AD4E38A1E8A10D01`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Runtime Preservation Report

## Baseline Comparison

- Baseline: `[LOCAL_PATH_REDACTED]`
- Baseline runtime files: 101
- New runtime files: 102
- Byte-identical baseline runtime files: 93
- Intentionally changed baseline runtime files: 8
- New runtime files: 1

Intentional changes are limited to two `mod.info` identity files, startup identity in Constants/Config/Runtime, yellow right-click routing in `XNP_DR_StatusIconUI.lua`, and alpha repair in the blue/red trait PNGs. `XNP_DR_YellowToggle.lua` is the only added runtime file.

## Preserved Functional Gates

- FULL_FATAL_DIAGNOSTIC_IN_DROP=false
- REPEATED_NIL_CALL_ROUTE_COUNT=0
- XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
- XNP_ON_TICK_HANDLER_COUNT=0
- UI_MAX_REFRESH_HZ=4
- RED_FOOD_CHECK_MAX_HZ=1
- DISTANCE_RUNNER_COST=1
- PHOENIX_COST=1
- BLUE_ECO_BARRAGE_COST=1
- FEAST_GUARDIAN_COST=1
- ALL_FOUR_TRAITS_SELECTABLE_TOGETHER=true
- BLUE_BOMB_RECIPE_PRESENT=true
- BLUE_BOMB_ITEM_PRESENT=true
- BLUE_BOMB_THROW_ROUTE_VERIFIED_STATIC=true
- BLUE_BOMB_CONTINUOUS_SCAN=false
- FEAST_GUARDIAN_EDGE_TRIGGER_PRESENT=true
- FEAST_GUARDIAN_TRIGGER_EVERY_FRAME=false
- FRACTURE_HEAL_USES_GAME_TIME=true
- PHOENIX_FORMAL_RUNTIME_PRESENT=true
- PHOENIX_UI_LIFECYCLE_STATIC_CHAIN_PRESENT=true

Blue bomb gameplay files, Feast Guardian gameplay files, Phoenix gameplay files, item/craft scripts, sandbox settings and translations remain byte-identical to 0.5.54.


```

## 0.5.54.1_BLUE_RED_ICON_ALPHA_FIX_REPORT.md

- SHA-256: `74348A7EC4F6710D62EDD7218BF8958390A497E51817D6411268F915D0855390`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Blue And Red Icon Alpha Fix

## Runtime Texture Paths

| Icon | Runtime path | Size | PNG mode | Corner alpha | Alpha plane SHA256 |
|---|---|---:|---|---|---|
| Yellow | `media/ui/Traits/trait_xnpdistancerunner.png` | 18x18 | RGBA, PNG color type 6 | 255,255,255,255 | `18CBD03D016C3E706E120559B5CBBA2DF58EB41820D292665C0AB277B354C921` |
| Phoenix template | `media/ui/Traits/trait_xnppurplephoenix.png` | 18x18 | RGBA, PNG color type 6 | 0,0,0,0 | `4AD172ACB52849F46D989233D2A7BAF2EFD4F52EC9624C84C281D4895C033406` |
| Blue Eco Barrage | `media/ui/Traits/trait_xnpblueecobarrage.png` | 18x18 | RGBA, PNG color type 6 | 0,0,0,0 | `4AD172ACB52849F46D989233D2A7BAF2EFD4F52EC9624C84C281D4895C033406` |
| Feast Guardian | `media/ui/Traits/trait_xnpfeastguardian.png` | 18x18 | RGBA, PNG color type 6 | 0,0,0,0 | `4AD172ACB52849F46D989233D2A7BAF2EFD4F52EC9624C84C281D4895C033406` |

The Phoenix image was selected as the already-qualified circular alpha template. Yellow and Phoenix source textures were not changed.

## Deterministic Processing

For each blue/red pixel, RGB came from that icon's 0.5.54 source image and alpha came from the Phoenix pixel at the same coordinate. No UI clipping or texture path substitution is used.

| Asset | Before SHA256 | After SHA256 |
|---|---|---|
| Phoenix template | `6273E586EB260B167C236FABDEC4A039973AFDD1D78355A6487F1601101FCDDE` | unchanged |
| Blue | `53B4E6F90FBB21B2603F6B3ECF169DFC808FD05C77AB6549A92543A81F69B4C9` | `4138C65A49260BAC691DF1ED8DAD0A74439A8F471D44B652144EF79D0013D9DD` |
| Red | `8EB15CE11E99750CB597AB1890A7019EE2A78C455DE53C16EC2882F0B41BECC9` | `756EDDF88626D3774E1849E814AA3F09BE6C244B3ECB178546579D6856856133` |

## Pixel Gates

- BLUE_SIZE=18x18
- RED_SIZE=18x18
- BLUE_MODE=RGBA
- RED_MODE=RGBA
- BLUE_CORNER_ALPHA=0,0,0,0
- RED_CORNER_ALPHA=0,0,0,0
- BLUE_ALPHA_MASK_MATCHES_TEMPLATE=true
- RED_ALPHA_MASK_MATCHES_TEMPLATE=true
- BLUE_TRANSPARENT_PIXEL_COUNT=108
- RED_TRANSPARENT_PIXEL_COUNT=108
- BLUE_OPAQUE_OUTSIDE_CIRCLE_COUNT=0
- RED_OPAQUE_OUTSIDE_CIRCLE_COUNT=0
- TEXTURE_PATH_CHANGED=false
- ITEM00_OR_BLACK_FRAME_ASSET_USED=false


```

## 0.5.54.1_FOUR_ICON_ISOLATION_REPORT.md

- SHA-256: `4D4A879852D87C5C15C5192F6B4593CC64FE886B08E1F35050004AC62ED21EB8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Four Icon Isolation

## Independent Ownership

| Icon | Panel class | Position storage | Enabled storage | Right-click service |
|---|---|---|---|---|
| Yellow | `XNPDistanceRunnerRecoveredStatusIcon` | `XNP_DR_StatusIcon_X`, `XNP_DR_StatusIcon_Y`, `XNP_DR_StatusIcon_UserPlaced` | `XNP_DR_YELLOW_ENABLED` | `YellowToggle` |
| Phoenix | `XNPPurplePhoenixStatusIcon` | `XNP_PurplePhoenix_IconX`, `XNP_PurplePhoenix_IconY` | `XNP_DR_PHOENIX_ENABLED` | `PurplePhoenixState` |
| Blue | `XNPBlueEcoBarrageStatusIcon` | `XNP_UI_BLUE_BARRAGE_POS` | `XNP_BLUE_BARRAGE_ENABLED` | `ExtraTraits` BLUE key |
| Red | `XNPFeastGuardianStatusIcon` | `XNP_UI_FEAST_GUARDIAN_POS` | `XNP_FEAST_GUARDIAN_ENABLED` | `ExtraTraits` RED key |

## Static Gates

- YELLOW_PANEL_UNIQUE=true
- PHOENIX_PANEL_UNIQUE=true
- BLUE_PANEL_UNIQUE=true
- RED_PANEL_UNIQUE=true
- YELLOW_POSITION_KEY_UNIQUE=true
- PHOENIX_POSITION_KEY_UNIQUE=true
- BLUE_POSITION_KEY_UNIQUE=true
- RED_POSITION_KEY_UNIQUE=true
- YELLOW_ENABLED_KEY_UNIQUE=true
- PHOENIX_ENABLED_KEY_UNIQUE=true
- BLUE_ENABLED_KEY_UNIQUE=true
- RED_ENABLED_KEY_UNIQUE=true
- NO_CROSS_ICON_ALPHA_DEPENDENCY=true
- NO_CROSS_ICON_COLOR_DEPENDENCY=true
- NO_CROSS_ICON_VISIBILITY_DEPENDENCY=true
- NO_CROSS_ICON_POSITION_DEPENDENCY=true
- NO_ICON_RIGHT_CLICK_CALLS_GLOBAL_MASTER=true
- NO_INITIAL_OVERLAP=true

Default vertical slots are yellow 76, Phoenix 116, blue 142 and red 168. Every panel is 18 pixels high, so no default rectangles overlap. Saved positions remain independently draggable.


```

## 0.5.54.1_YELLOW_TOGGLE_ISOLATION_FIX_REPORT.md

- SHA-256: `11BB6DE5B25A463434FC862DFDE911EDDCBA9EE4F3B14B0CC8193B2E0250CA72`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Yellow Toggle Isolation Fix

## Result

- YELLOW_RIGHT_CLICK_CALLS_MASTER=false
- PHOENIX_RIGHT_CLICK_CALLS_MASTER=false
- BLUE_RIGHT_CLICK_CALLS_MASTER=false
- RED_RIGHT_CLICK_CALLS_MASTER=false
- NO_ICON_RIGHT_CLICK_CALLS_GLOBAL_MASTER=true
- CROSS_ICON_STATE_WRITE_COUNT=0

## Before And After

Baseline `0.5.54` called `Core.MasterEffectState.Toggle(player, "STATUS_ICON_RIGHT_CLICK")` from `XNP_DR_StatusIconUI.lua` at approximately lines 417-418.

The `[IP_REDACTED]` route is:

`XNP_DR_StatusIconUI.Panel:onRightMouseUp -> Core.YellowToggle.Toggle -> Core.YellowToggle.SetEnabled -> player ModData[XNP_DR_YELLOW_ENABLED]`

The new `XNP_DR_YellowToggle.lua` service validates trait ownership, keeps the existing 250 ms debounce and client-authority guard, and writes only the yellow enabled key. After a successful toggle, `StatusIconUI` clears only its own state hold and immediately refreshes only the yellow panel.

## Four Right-Click Handlers

| Icon | Handler | Toggle service | Enabled key |
|---|---|---|---|
| Yellow / Distance Runner | `XNP_DR_StatusIconUI.lua` | `Core.YellowToggle.Toggle` | `XNP_DR_YELLOW_ENABLED` |
| Phoenix | `XNP_DR_PurplePhoenixUI.lua` | `Core.PurplePhoenixState.Toggle` | `XNP_DR_PHOENIX_ENABLED` |
| Blue Eco Barrage | `XNP_DR_FourTraitUI.lua` BLUE instance | `Core.ExtraTraits.Toggle(player, "BLUE")` | `XNP_BLUE_BARRAGE_ENABLED` |
| Feast Guardian | `XNP_DR_FourTraitUI.lua` RED instance | `Core.ExtraTraits.Toggle(player, "RED")` | `XNP_FEAST_GUARDIAN_ENABLED` |

## Full-Tree Master Search

- `MasterEffectState.Toggle` text hits: 1
- Hit type: compatibility function definition in `XNP_DR_MasterEffectState.lua`
- Active call sites: 0
- `global master` text hits: 0
- Icon handlers calling a global Master route: 0

`XNP_DR_MasterEffectState` remains as the preserved yellow runtime compatibility gate and cleanup owner. No icon calls its `Toggle` function in this build.

## Isolation Gate

The yellow setter does not reference Phoenix, ExtraTraits, Blue Eco Barrage, Feast Guardian, other enabled keys, other panels, other positions, other alpha values, or other color states.


```

## BUILD_MARKER.txt

- SHA-256: `0B17A3FA30E3D9A12099F34EA2272DAFC28336730FD8FEE0C489AB9E9B88B47C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_05541_ICON_ISOLATION_ALPHA_FIX_A

```

## FINAL_REPORT.md

- SHA-256: `57672632160E84FB04C7C3B334867C52227E6ED2AC48E4571FD6C626CF658075`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

## Delivery

- SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
- USER_DROP_PATH=[LOCAL_PATH_REDACTED]
- DROP_TOP_LEVEL=42|mod.info|poster.png
- VERSION=[IP_REDACTED]
- INTERNAL_VERSION=[IP_REDACTED]-b42-icon-isolation-alpha-fix-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05541_ICON_ISOLATION_ALPHA_FIX_A
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- DISPLAY_NAME=[[IP_REDACTED]] XNP Distance Runner + Phoenix + Blue Barrage + Feast Guardian

## Fixed Blockers

- YELLOW_BEFORE_ROUTE=StatusIconUI -> MasterEffectState.Toggle
- YELLOW_AFTER_ROUTE=StatusIconUI -> YellowToggle.Toggle -> XNP_DR_YELLOW_ENABLED
- FOUR_RIGHT_CLICK_ROUTES_INDEPENDENT=true
- NO_ICON_RIGHT_CLICK_CALLS_GLOBAL_MASTER=true
- BLUE_ICON=18x18 RGBA corners 0,0,0,0
- RED_ICON=18x18 RGBA corners 0,0,0,0
- BLUE_ALPHA_MASK_SHA256=4AD172ACB52849F46D989233D2A7BAF2EFD4F52EC9624C84C281D4895C033406
- RED_ALPHA_MASK_SHA256=4AD172ACB52849F46D989233D2A7BAF2EFD4F52EC9624C84C281D4895C033406
- BLUE_ALPHA_MASK_MATCHES_PHOENIX=true
- RED_ALPHA_MASK_MATCHES_PHOENIX=true
- FOUR_ICON_ISOLATION=PASS_STATIC

## Preserved Runtime

- 0.5.54_ACCEPTED_FUNCTIONS_PRESERVED=true
- XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
- XNP_ON_TICK_HANDLER_COUNT=0
- UI_MAX_REFRESH_HZ=4
- RED_FOOD_CHECK_MAX_HZ=1
- ALL_FOUR_TRAIT_COSTS=1
- BLUE_BOMB_ROUTE_PRESERVED=true
- FEAST_GUARDIAN_ROUTE_PRESERVED=true
- PHOENIX_RUNTIME_AND_UI_LIFECYCLE_PRESERVED=true
- FULL_FATAL_DIAGNOSTIC_IN_DROP=false

## Validation

- SOURCE_KAHLUA=81 PASS / 0 FAIL
- DROP_KAHLUA=81 PASS / 0 FAIL
- RESOURCE_STATIC_CHECK=PASS
- SOURCE_RUNTIME_FILE_COUNT=102
- DROP_RUNTIME_FILE_COUNT=102
- SOURCE_DROP_SHA256_MISMATCH_COUNT=0
- MISSING_FROM_DROP=0
- EXTRA_IN_DROP=0
- TOP_LEVEL_ENTRY_COUNT=3
- DEV_DOC_COUNT_IN_DROP=0
- AUDIT_FILE_COUNT_IN_DROP=0
- ZIP_COUNT_IN_DROP=0

## Safety And Risk

- OLD_SOURCE_MODIFIED=false
- PROJECT_ZOMBOID_STARTED=false
- STEAM_STARTED=false
- USER_DIRECTORY_WRITTEN=false
- GAME_DIRECTORY_WRITTEN=false
- WORKSHOP_WRITTEN=false
- BLOCKER=NONE_STATIC
- RISK=In-game rendering, click behavior and multiplayer authority remain user-run tests.
- REAL_GAME_TEST_REQUIRED_BY_USER=true

XNP_PZ_0.5.54.1_ICON_ISOLATION_ALPHA_FIX_READY

```

## sandbox-options.txt

- SHA-256: `B8C7A25B3D802F6FB37D059BC2C6D9A5B11D62BC1D5E10F0D8E3FC5614E79148`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
VERSION = 1,

option XNPDistanceRunner.EnableMod
{
    type = boolean, default = true,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_EnableMod,
}

option XNPDistanceRunner.TuningPreset
{
    type = enum, numValues = 3, default = 1,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_TuningPreset,
    valueTranslation = XNPDistanceRunner_TuningPreset,
}

option XNPDistanceRunner.EnableDebugSummary
{
    type = boolean, default = false,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_EnableDebugSummary,
}

option XNPDistanceRunner.LiveRefreshTuning
{
    type = boolean, default = true,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_LiveRefreshTuning,
}

option XNPDistanceRunner.GlobalSkillCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_GlobalSkillCostMultiplier,
}

option XNPDistanceRunner.ZombieImpactCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 0.24,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_ZombieImpactCostMultiplier,
}

option XNPDistanceRunner.JogBumpCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_JogBumpCostMultiplier,
}

option XNPDistanceRunner.SprintPrecollisionCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_SprintPrecollisionCostMultiplier,
}

option XNPDistanceRunner.SprintVehicleZombieCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_SprintVehicleZombieCostMultiplier,
}

option XNPDistanceRunner.ControlledEscapeCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_ControlledEscapeCostMultiplier,
}

option XNPDistanceRunner.NativeTripCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_NativeTripCostMultiplier,
}

option XNPDistanceRunner.StaminaAssistIntensity
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_StaminaAssistIntensity,
}

option XNPDistanceRunner.BlueRefundPercent
{
    type = integer, min = 0, max = 90, default = 30,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_BlueRefundPercent,
}

option XNPDistanceRunner.YellowRefundPercent
{
    type = integer, min = 0, max = 90, default = 38,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_YellowRefundPercent,
}

option XNPDistanceRunner.RedRefundPercent
{
    type = integer, min = 0, max = 90, default = 55,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_RedRefundPercent,
}

option XNPDistanceRunner.ExtraHungerCostMultiplier
{
    type = double, min = 0
[EXCERPT_TRUNCATED]
```

## 0.5.54.1_KAHLUA_AND_RESOURCE_VALIDATION.md

- SHA-256: `8BCFA34399C60D010A4A821F0DB13BE2F99E4C3546C994426CBE3CF05C55B047`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Kahlua And Resource Validation

## Kahlua

- Compiler route: `LuaCompiler.loadis`
- JAR: `[LOCAL_PATH_REDACTED]`
- ALL_RUNTIME_LUA_ENUMERATED=true
- SOURCE_RUNTIME_LUA_COUNT=81
- SOURCE_KAHLUA_PASS_COUNT=81
- SOURCE_KAHLUA_FAIL_COUNT=0
- DROP_RUNTIME_LUA_COUNT=81
- DROP_KAHLUA_PASS_COUNT=81
- DROP_KAHLUA_FAIL_COUNT=0
- KAHLUA_RUNTIME_LUA_SYNTAX_FAIL_COUNT=0

## Resources And Static Routes

- Total Lua `require` statements checked: 376
- XNP require targets missing: 0
- XNP require case mismatches: 0
- Translation JSON files parsed: 6
- Translation JSON parse failures: 0
- Sandbox CN keys: 176
- Sandbox EN keys: 176
- Sandbox asymmetric keys: 0
- Trait texture references: 4
- Missing trait textures: 0
- Duplicate event-add signatures: 0
- Duplicate trait full IDs in the B42 trait script: 0
- Duplicate panel class names: 0
- `item BlueEcoBarrageBomb`: present
- `craftRecipe MakeBlueEcoBarrageBomb`: present
- Blue item/craft callback route: present
- Sandbox options file: present
- Trait costs: four definitions, all Cost 1
- PNG size/mode/corner/alpha-mask gates: pass

Static validation cannot prove Project Zomboid runtime behavior. REAL_GAME_TEST_REQUIRED_BY_USER=true.


```

## 0.5.54.1_PACKAGE_VALIDATION.md

- SHA-256: `6EA8E90B1B90B150DC63CCDA4121A8E14DA5CB00C045371DC89A80B1C419A2EF`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Package Validation

## Paths

- SOURCE: `[LOCAL_PATH_REDACTED]`
- DROP: `[LOCAL_PATH_REDACTED]`

## Drop Structure

- DROP_FOLDER_NAME_STARTS_WITH_VERSION=true
- DROP_FOLDER_PREFIX=0.5.54.1_
- NO_PARENT_WRAPPER=true
- NO_NESTED_SAME_NAME_FOLDER=true
- NO_NESTED_VERSION_FOLDER=true
- TOP_LEVEL_ENTRY_COUNT=3
- TOP_LEVEL_ENTRIES=42|mod.info|poster.png
- DEV_DOC_COUNT_IN_DROP=0
- AUDIT_FILE_COUNT_IN_DROP=0
- ZIP_COUNT_IN_DROP=0

Runtime `.txt` files under `42/media` are required game resources and are not development documents.

## Source And Drop Equality

- SOURCE_RUNTIME_FILE_COUNT=102
- DROP_RUNTIME_FILE_COUNT=102
- SOURCE_DROP_FILE_COUNT_MATCH=true
- SOURCE_DROP_SHA256_MISMATCH_COUNT=0
- MISSING_FROM_DROP=0
- EXTRA_IN_DROP=0


```

## 0.5.54.1_SECOND_PASS_AUDIT.md

- SHA-256: `77E1E1200CD1DDE6C2F624C244B724FB0829A2251AB8C76AA5C97CEE822A9166`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Second-Pass Read-Only Audit

## Audit Scope

- SOURCE=`[LOCAL_PATH_REDACTED]`
- DROP=`[LOCAL_PATH_REDACTED]`
- BASELINE=`[LOCAL_PATH_REDACTED]`
- AUDIT_MODE=READ_ONLY_EXCEPT_THIS_REPORT
- AUTOMATIC_FIX_PERFORMED=false

## Version And Package Structure

- VERSION=[IP_REDACTED]
- INTERNAL=[IP_REDACTED]-b42-icon-isolation-alpha-fix-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05541_ICON_ISOLATION_ALPHA_FIX_A
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- DISPLAY_NAME_STARTS_WITH=[[IP_REDACTED]]
- DROP_PATH_IS_DIRECT_DRAG_OBJECT=true
- NO_PARENT_WRAPPER=true
- TOP_LEVEL_ENTRY_COUNT=3
- TOP_LEVEL_ENTRIES=42|mod.info|poster.png
- TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0
- NESTED_SAME_NAME_FOLDER_COUNT=0
- NESTED_VERSION_FOLDER_COUNT=0
- DEV_DOC_COUNT_IN_DROP=0
- AUDIT_FILE_COUNT_IN_DROP=0

## Yellow Right-Click Isolation

The yellow handler route is:

`XNP_DR_StatusIconUI.Panel:onRightMouseUp -> Core.YellowToggle.Toggle -> YellowToggle.SetEnabled -> player ModData[XNP_DR_YELLOW_ENABLED]`

`YellowToggle.SetEnabled` writes only `XNP_DR_YELLOW_ENABLED`. Its legacy key is read only during one-time default migration and is not written by the right-click route. A successful toggle resets and refreshes only `StatusIconUI` state.

- YELLOW_RIGHT_CLICK_CALLS_MASTER=false
- PHOENIX_RIGHT_CLICK_CALLS_MASTER=false
- BLUE_RIGHT_CLICK_CALLS_MASTER=false
- RED_RIGHT_CLICK_CALLS_MASTER=false
- NO_ICON_RIGHT_CLICK_CALLS_GLOBAL_MASTER=true
- YELLOW_RIGHT_CLICK_WRITES_ONLY=XNP_DR_YELLOW_ENABLED
- PHOENIX_RIGHT_CLICK_WRITES_ONLY=XNP_DR_PHOENIX_ENABLED
- BLUE_RIGHT_CLICK_WRITES_ONLY=XNP_BLUE_BARRAGE_ENABLED
- RED_RIGHT_CLICK_WRITES_ONLY=XNP_FEAST_GUARDIAN_ENABLED
- YELLOW_RIGHT_CLICK_CROSS_STATE_WRITE_COUNT=0
- PHOENIX_RIGHT_CLICK_CROSS_STATE_WRITE_COUNT=0
- BLUE_RIGHT_CLICK_CROSS_STATE_WRITE_COUNT=0
- RED_RIGHT_CLICK_CROSS_STATE_WRITE_COUNT=0

The full runtime tree contains one `MasterEffectState.Toggle` text hit. It is the compatibility function definition in `XNP_DR_MasterEffectState.lua`; active calls to it are 0. The remaining MasterEffectState API is a yellow-only runtime compatibility gate and transient cleanup owner. No icon handler can reach its Toggle function.

## Four Right-Click Routes

| Icon | Handler target | Enabled key |
|---|---|---|
| Yellow | `Core.YellowToggle.Toggle` | `XNP_DR_YELLOW_ENABLED` |
| Phoenix | `Core.PurplePhoenixState.Toggle` | `XNP_DR_PHOENIX_ENABLED` |
| Blue | `Core.ExtraTraits.Toggle(player, "BLUE")` | `XNP_BLUE_BARRAGE_ENABLED` |
| Red | `Core.ExtraTraits.Toggle(player, "RED")` | `XNP_FEAST_GUARDIAN_ENABLED` |

## Blue And Red Pixel Audit

The actual runtime PNG data was decoded and inspected pixel by pixel. PNG color type 6 is RGBA. The circular template is the existing Phoenix texture.

- TEMPLATE_TEXTURE_PATH=`42/media/ui/Traits/trait_xnppurplephoenix.png`
- TEMPLATE_FILE_SHA256=`6273E586EB260B167C236FABDEC4A039973AFDD1D78355A6487F1601101FCDDE`
- TEMPLATE_ALPHA_MASK_SHA256=`4AD172ACB52849F46D989233D2A7BAF2EFD4F52EC9624C84C281D4895C033
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `E265A1286D4200F1AD317E02134914560091324A33D53F398D654F59282A92E4`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

## Identity

- VERSION=[IP_REDACTED]
- INTERNAL_VERSION=[IP_REDACTED]-b42-icon-isolation-alpha-fix-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05541_ICON_ISOLATION_ALPHA_FIX_A
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- DISPLAY_NAME=[[IP_REDACTED]] XNP Distance Runner + Phoenix + Blue Barrage + Feast Guardian
- RUNTIME_OLD_IDENTITY_HIT_COUNT=0

## Blocking Gates

- Yellow icon active calls to `MasterEffectState.Toggle`: 0
- Any icon active calls to global Master: 0
- Cross-icon state writes from yellow setter: 0
- Blue corner alpha failures: 0
- Red corner alpha failures: 0
- Blue/red alpha-mask mismatches: 0
- Blue/red opaque pixels outside template circle: 0
- FullFatalTimingDiagnostic runtime hits: 0
- Repeated nil-call route hits: 0
- OnPlayerUpdate registrations: 1
- OnTick registrations: 0
- Duplicate event-add signatures: 0
- Kahlua failures: 0
- Missing/case-invalid XNP require targets: 0
- Missing trait texture targets: 0
- Translation JSON failures: 0
- Sandbox CN/EN asymmetry: 0
- SOURCE/DROP SHA256 mismatches: 0

## Preservation

All four B42 trait definitions remain independent, Cost 1 and simultaneously selectable. Blue bomb, Feast Guardian, Phoenix, performance scheduler, sandbox and translation runtime files remain unchanged from 0.5.54. UI refresh remains 4 Hz maximum and the red food check remains 1 Hz maximum.

## Environment Safety

- OLD_SOURCE_MODIFIED=false
- PROJECT_ZOMBOID_STARTED=false
- STEAM_STARTED=false
- USER_MODS_WRITTEN=false
- SAVES_WRITTEN=false
- WORKSHOP_WRITTEN=false
- GAME_DIRECTORY_WRITTEN=false
- WORKSHOP_UPLOAD_PERFORMED=false

## Verification Boundary

- NOT_VERIFIABLE_BY_STATIC_AUDIT=actual in-game icon rendering and click behavior
- NOT_VERIFIABLE_BY_STATIC_AUDIT=multiplayer authority behavior
- REAL_GAME_TEST_REQUIRED_BY_USER=true
- BLOCKER=NONE_STATIC

STATIC_AUDIT_RESULT=PASS


```
