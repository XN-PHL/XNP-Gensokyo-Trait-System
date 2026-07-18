# 0.5.35 Sanitized Evidence Excerpts

## 0.5.35_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `DB45AED98EB7B67C39E51E2D207485228B0A4DE40C7C9DE798F40F99784CED9E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.35 Gameplay Preserve Report

BASELINE=0.5.34
COLOR_UNCHANGED=YES
SHAKE_UNCHANGED=YES
DRAG_UNCHANGED=YES
SKILL_EFFECTS_UNCHANGED=YES
CORE_MECHANICS_PRESERVED=YES

Preserved:

- Green / Blue / Yellow / Red colors
- Green no shake
- Blue low shake
- Yellow medium shake
- Red high shake
- drag suspend/resume
- saved icon position unaffected by shake
- release stamina curve
- smooth post-drain refund
- resource gate
- White visual disabled
- stateChangedThisTick commit contract
- stableState=candidateState
- candidate clear
- same-tick recreate guard
- Walk No Impact
- Controlled Jog Escape
- JogBump effect route
- SprintVehicleImpact effect route
- NativeTrip window/result route
- SprintTripConsequence
- ActionBus
- ImpactQuota
- danger flash
- no bite / no infection / no heal
- no player coordinate write
- single main icon and direct drag

0.5.35 changes are limited to version identity, native sandbox tuning, cost multipliers, runtime reads, and documentation.


```

## 0.5.35_MELEE_SCALING_FUTURE_INTERFACE.md

- SHA-256: `F1024A2524FF4CC414632143FE4FA92D1B0938CF95BB3EDBD8D71445E36227EC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.35 Melee Scaling Future Interface

MELEE_SCALING=DEFERRED_SEPARATE_VERSION

Future Sandbox placeholders documented only:

- EnableEnduranceMeleeScaling
- FullEnduranceMeleePowerMultiplier
- LowEnduranceMeleePowerMultiplier
- MeleeScalingCurve

0.5.35 runtime:

- Does not enable melee scaling.
- Does not modify global weapon templates.
- Does not add an unverified melee damage hook.
- Does not let one player's multiplier contaminate other players.

API investigation status:

DEFERRED_API_NOT_VERIFIED

The `SandboxTuning` framework is ready for a future version to expose verified melee-scaling values, but this release opens only parameters that are actually connected.

```

## 0.5.35_NATIVE_SANDBOX_OPTIONS_ARCHITECTURE.md

- SHA-256: `49CBA8224ED37985925290F47884B5DCA0969E7548FC891D4D0A991432B5D001`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.35 Native Sandbox Options Architecture

NATIVE_SANDBOX_OPTIONS=YES
SANDBOX_NAMESPACE=XNPDistanceRunner
SERVER_AUTHORITATIVE=YES
CLIENT_LOCAL_OVERRIDE=NO

Implemented files:

- `42/media/sandbox-options.txt`
- `42/media/lua/shared/translate/EN/Sandbox_EN.txt`
- `42/media/lua/shared/translate/CN/Sandbox_CN.txt`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning.lua`

The syntax follows installed B42.19.0 examples:

- `VERSION = 1`
- `option Namespace.Name { type = ..., page = ..., translation = ... }`
- enum preset uses `type = enum`, `numValues = 3`, `valueTranslation = XNPDistanceRunner_TuningPreset`

Runtime reads only `SandboxVars.XNPDistanceRunner` through `SandboxTuning`. Gameplay modules do not read scattered local config files or custom UI values.


```

## 0.5.35_REAL_GAME_COST_REDUCTION_FROM_0.5.34.md

- SHA-256: `D42B15E700C72B97AD483214321B87B03CC34EB2BB026483CAD22E441AE7140A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.35 Real Game Cost Reduction From 0.5.34

BASELINE=0.5.34
PREVIOUS_TOOLTIP_COMMAND=SUPERSEDED

User feedback from 0.5.34: current color, shake, drag behavior, stamina curve, and major skill behavior are preserved. The main balance issue is that active zombie-impact endurance cost is too high for release play.

DEFAULT_ZOMBIE_IMPACT_COST_MULTIPLIER=0.40
NO_DOUBLE_MULTIPLIER=YES
WALL_IMPACT_COST_UNCHANGED=YES

Default release cost results:

- SPRINT_PRECOLLISION: base 0.0500 x global 1.00 x zombie 0.40 x route 1.00 = 0.0200
- SPRINT_VEHICLE_ZOMBIE_LIGHT: base 0.0750 x global 1.00 x zombie 0.40 x route 1.00 = 0.0300
- CONTACT/JOG_BUMP class uses zombie impact multiplier when a direct endurance cost exists.
- GRAB, CROWD, controlled escape, native trip, emergency, and wall impact do not apply the zombie impact multiplier by default.

Skill costs notify the smooth stamina assist ignore window so reduced costs cannot be refunded as normal locomotion drain.


```

## 0.5.35_RELEASE_TESTING_CUSTOM_PRESETS.md

- SHA-256: `FCA70D66FA064B1376A966570FE3E4A683905EE3C4BBA971712B2262D23A1172`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.35 Release Testing Custom Presets

PRESETS=RELEASE_TESTING_CUSTOM

Priority:

1. EnableMod=false disables gameplay activation.
2. Preset=Release uses fixed release defaults.
3. Preset=Testing uses fixed testing values for faster visual diagnosis.
4. Preset=Custom uses editable Sandbox fields.
5. Invalid fields clamp/fallback.
6. Multiplayer uses server SandboxVars as authoritative.

Release:

- 0.5.34 release color thresholds and refund curve.
- ZombieImpactCostMultiplier=0.40.

Testing:

- Higher color thresholds for quicker band visibility.
- Debug summary enabled.
- ZombieImpactCostMultiplier still defaults to 0.40, not higher than Release.

Custom:

- Uses all editable Sandbox fields after validation.


```

## 0.5.35_SANDBOX_RUNTIME_MAPPING.md

- SHA-256: `F41FCF6D783D4537F225E59BB1D80A63343355EFEC46A6DEAAC1F6B675246F2A`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.35 Sandbox Runtime Mapping

NATIVE_SANDBOX_OPTIONS=YES
SANDBOX_NAMESPACE=XNPDistanceRunner
LIVE_REFRESH_CACHED=YES

Runtime consumer map:

- EnableMod -> `Runtime.ActivateForPlayer`
- TuningPreset -> `SandboxTuning` preset resolver
- EnableDebugSummary -> `SandboxTuning` snapshot/config flag
- LiveRefreshTuning -> `SandboxTuning.Tick`
- GlobalSkillCostMultiplier -> `SandboxTuning.GetCostDetails`
- ZombieImpactCostMultiplier -> zombie-impact cost routes
- JogBumpCostMultiplier -> CONTACT/JOG_BUMP route multiplier
- SprintPrecollisionCostMultiplier -> SPRINT_PRECOLLISION route multiplier
- SprintVehicleZombieCostMultiplier -> SPRINT_VEHICLE_ZOMBIE route multiplier
- ControlledEscapeCostMultiplier -> GRAB/CROWD/CONTROLLED_ESCAPE route multiplier
- NativeTripCostMultiplier -> WALL_IMPACT/NATIVE_TRIP route multiplier
- StaminaAssistIntensity -> refund fractions applied to Config
- BlueRefundPercent -> blue refund fraction
- YellowRefundPercent -> yellow refund fraction
- RedRefundPercent -> red refund fraction
- ExtraHungerCostMultiplier -> hunger conversion ratios
- ResourceGateEnabled -> resource gate enabled flag
- GreenExitPercent -> endurance green exit
- GreenEnterPercent -> endurance green enter
- BlueLowerPercent -> blue/yellow boundary
- YellowLowerPercent -> yellow/red boundary
- ShowStatusIcon -> status icon UI enabled
- EnableStatusShake -> status icon shake enabled

No dead Sandbox options are intentionally defined.


```

## 0.5.35_SERVER_AUTHORITATIVE_TUNING.md

- SHA-256: `07C314107C5756C5BDB3874FBC5083ADF2ED087AE2F816AC11A0CD72078AB2FC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.35 Server Authoritative Tuning

SERVER_AUTHORITATIVE=YES
CLIENT_LOCAL_OVERRIDE=NO
LEGACY_SAVE_FALLBACK=RELEASE
LIVE_REFRESH_CACHED=YES

Rules:

- Multiplayer uses the synced server `SandboxVars.XNPDistanceRunner`.
- Normal clients do not override gameplay values with local-only settings.
- Missing namespace or old saves fall back to Release defaults.
- Invalid fields are clamped or replaced with fallback values.
- Live refresh checks every 120 frames and only reapplies values when the snapshot hash changes.
- Large per-frame SandboxVars reads are avoided.

Runtime logs:

- `[XNP SANDBOX] namespace=XNPDistanceRunner`
- `[XNP SANDBOX] preset=... source=SERVER_SANDBOX_VARS`
- `[XNP SANDBOX] multiplayer_authority=SERVER`
- `[XNP SANDBOX] client_local_override=false`
- `[XNP SANDBOX TUNING] refresh_interval_frames=120`


```

## 0.5.35_TEST_PLAN.md

- SHA-256: `5EDBC3D64ED6372706C2AD7ED5CF68639C45A5DB1D3FF5E3390DD5F6F76698CF`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.35 Test Plan

1. Confirm build marker:
   `XNP_PZ_DISTANCE_TRAIT_0535_SANDBOX_TUNING_IMPACT_COST_A`

2. Confirm native Sandbox page:
   - Page name: XNP Distance Runner
   - Namespace: XNPDistanceRunner
   - Presets: Release, Testing, Custom

3. Release default cost:
   - Sprint precollision zombie impact logs final about 0.0200.
   - Sprint vehicle light zombie impact logs final about 0.0300.
   - Wall impact, NativeTrip, Grab, and Emergency behavior remains unchanged.

4. Custom cost:
   - Change ZombieImpactCostMultiplier.
   - Confirm logs show changed snapshot hash.
   - Confirm final cost changes once and does not double multiply.

5. Threshold validation:
   - Intentionally use invalid ordering in Custom.
   - Confirm normalized/fallback warning and no crash.

6. Multiplayer:
   - Host/server SandboxVars values are authoritative.
   - Clients do not use local override values.

7. Preserve checks:
   - Colors and shake match 0.5.34.
   - Drag behavior remains stable.
   - Smooth refund still blocks skill-cost refund.

PZ_LAUNCHED_BY_CODEX=NO
STEAM_LAUNCHED_BY_CODEX=NO
MODS_WRITTEN_BY_CODEX=NO


```

## 0.5.35_ZOMBIE_IMPACT_COST_MATRIX.md

- SHA-256: `509DACF40882CB07142895119416CBE62F18CB2801DA02616D0CB5A87C4B2D21`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.35 Zombie Impact Cost Matrix

DEFAULT_ZOMBIE_IMPACT_COST_MULTIPLIER=0.40
NO_DOUBLE_MULTIPLIER=YES
WALL_IMPACT_COST_UNCHANGED=YES

Formula:

`finalCost = baseCost * GlobalSkillCostMultiplier * ZombieImpactCostMultiplier * RouteSpecificMultiplier`

Only zombie-impact routes use `ZombieImpactCostMultiplier`.

| Route | Base | Global | Zombie | Route | Default Final | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| SPRINT_PRECOLLISION | 0.0500 | 1.00 | 0.40 | 1.00 | 0.0200 | Reduced release cost |
| SPRINT_VEHICLE_ZOMBIE | 0.0750 | 1.00 | 0.40 | 1.00 | 0.0300 | Light zombie impact |
| CONTACT | 0.0250 | 1.00 | 0.40 | 1.00 | 0.0100 | Active contact push cost |
| JOG_BUMP | 0.0000 | 1.00 | 0.40 | 1.00 | 0.0000 | Current jog route has no direct endurance cost |
| GRAB/CROWD/CONTROLLED_ESCAPE | existing | 1.00 | 1.00 | 1.00 | unchanged | No zombie multiplier |
| WALL_IMPACT/NATIVE_TRIP | existing | 1.00 | 1.00 | 1.00 | unchanged | No zombie multiplier |


```

## BUILD_MARKER.txt

- SHA-256: `7C529CF45FDE912B262EC5AF6F173DBB9087E47BDB976616F016A37BFEB047D9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0535_SANDBOX_TUNING_IMPACT_COST_A

```

## FINAL_REPORT.md

- SHA-256: `A5007F1A3F404F394D5F868299C79C124DE3D75BFD846ACE6E6DE0CD093F4864`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner 0.5.35 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Version

- VERSION=0.5.35
- INTERNAL_VERSION=0.5.35-b42-sandbox-tuning-impact-cost-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0535_SANDBOX_TUNING_IMPACT_COST_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.35 Sandbox Tuning Impact Cost

## Main Delivery

0.5.35 creates a standalone source based on 0.5.34 and adds native Build 42 sandbox tuning for stamina/cost balancing.

Implemented:

- Native sandbox-options.txt.
- CN/EN sandbox option translations.
- Server-authoritative SandboxVars reader.
- Release / Testing / Custom presets.
- Runtime refresh every 120 frames.
- Reduced zombie impact stamina cost default.
- Cost route mapping with no double multiplier.
- Stamina assist refund block for explicit skill/action costs.
- Future melee scaling interface documented but not implemented.

## New Or Changed Files

Identity and config:

- BUILD_MARKER.txt
- mod.info
- 42/mod.info
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua

Native sandbox:

- 42/media/sandbox-options.txt
- 42/media/lua/shared/translate/EN/Sandbox_EN.txt
- 42/media/lua/shared/translate/CN/Sandbox_CN.txt
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning.lua

Runtime integration:

- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua

Cost integration:

- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintVehicleImpact.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist.lua

Reports:

- 0.5.35_REAL_GAME_COST_REDUCTION_FROM_0.5.34.md
- 0.5.35_NATIVE_SANDBOX_OPTIONS_ARCHITECTURE.md
- 0.5.35_SERVER_AUTHORITATIVE_TUNING.md
- 0.5.35_RELEASE_TESTING_CUSTOM_PRESETS.md
- 0.5.35_ZOMBIE_IMPACT_COST_MATRIX.md
- 0.5.35_SANDBOX_RUNTIME_MAPPING.md
- 0.5.35_MELEE_SCALING_FUTURE_INTERFACE.md
- 0.5.35_GAMEPLAY_PRESERVE_REPORT.md
- 0.5.35_TEST_PLAN.md
- STATIC_AUDIT.md
- FINAL_REPORT.md

## Default Cost Results

Release preset defaults:

- GlobalSkillCostMultiplier=1.00
- ZombieImpactCostMultiplier=0.40
- Route multipliers=1.00

Expected default outputs:

- SPRINT_PRECOLLISION: 0.020 endurance
- SPRINT_VEHICLE_ZOMBIE/LIGHT: 0.030 endurance
- WALL_IMPACT: unchanged
- GRAB/CROWD/CONTROLLED_ESCAPE/NATIVE_TRIP: no zombie multiplier unless changed by their own route multiplier.

## Runtime Consumer Map

SandboxTuning consumes every opened gameplay option and maps it into:

- Config enable/disable state
- UI show/hide state
- shake enable state
- resource gate state
- release/endurance thresholds
- stamina refund fractions
- hunger conversion multiplier
- global cost multiplier
- zombie impact cost multiplier
- route-specific cost multipliers

No option is intentionally dead.

## Preserved Behavior

Preserved from the working previous release:

- trait identity

[EXCERPT_TRUNCATED]
```

## sandbox-options.txt

- SHA-256: `4B603D36A37AEAA4F1AFF8FE76A0F9446A757FDBC7348E4D2E2BD03022E0BC83`
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
    type = double, min = 0.00, max = 2.00, default = 0.40,
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
    type = integer, min = 0, max = 90, default = 18,
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
