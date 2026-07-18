# 0.5.36 Sanitized Evidence Excerpts

## 0.5.36_COST_ROUTE_MATRIX.md

- SHA-256: `C8B32A849046894BDC3ADCD5582AB4AD6AFDA654962AD7391887E374A8592EDA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 Cost Route Matrix

BASELINE=0.5.35
ROUTE_REGISTRY=XNP_DR_CostTuning.lua

Formula for tunable routes:

finalCost = baseCost * globalMultiplier * zombieMultiplier * routeMultiplier

Routes:

| Route | Consumer | Global | ZombieImpact | Route Multiplier | NativeTrip |
| --- | --- | --- | --- | --- | --- |
| JOG_BUMP | XNP_DR_JogBumpLaunch | YES | YES | JogBumpCostMultiplier | NO |
| SPRINT_PRECOLLISION | XNP_DR_BreakoutPush | YES | YES | SprintPrecollisionCostMultiplier | NO |
| SPRINT_VEHICLE_ZOMBIE | XNP_DR_SprintVehicleImpact | YES | YES | SprintVehicleZombieCostMultiplier | NO |
| CONTROLLED_ESCAPE | XNP_DR_BreakoutPush | YES | NO | ControlledEscapeCostMultiplier | NO |
| NATIVE_TRIP | XNP_DR_SprintTripImmunity | YES | NO | NativeTripCostMultiplier | YES |
| WALL_IMPACT | XNP_DR_SprintVehicleImpact | NO | NO | NONE | NO |

Defaults:

- ZombieImpactCostMultiplier=0.40
- SPRINT_PRECOLLISION=0.0500 * 1.00 * 0.40 * 1.00 = 0.0200
- SPRINT_VEHICLE_ZOMBIE=0.0750 * 1.00 * 0.40 * 1.00 = 0.0300
- JOG_BUMP=base * 1.00 * 0.40 * 1.00
- WALL_IMPACT=baseline cost, no sandbox multiplier


```

## 0.5.36_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `949BF6275006102E152556DFDA902585828AEE602E89C0AA0FEF9B3E46A97884`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 Gameplay Preserve Report

BASELINE=0.5.35
FIX_SCOPE=THREE_AUDIT_BLOCKERS_ONLY

Preserved:

- COLOR_SHAKE_DRAG_UNCHANGED=YES
- RELEASE_CURVE_DEFAULT_UNCHANGED=YES
- SMOOTH_REFUND_DEFAULT_UNCHANGED=YES
- RESOURCE_GATE_DEFAULT_UNCHANGED=YES
- STATE_COMMIT_UNCHANGED=YES
- WALK_NO_IMPACT_UNCHANGED=YES
- CONTROLLED_ESCAPE_EFFECT_UNCHANGED=YES
- JOG_BUMP_EFFECT_UNCHANGED=YES
- SPRINT_VEHICLE_EFFECT_UNCHANGED=YES
- NATIVE_TRIP_EFFECT_UNCHANGED=YES
- ACTION_BUS_UNCHANGED=YES
- IMPACT_QUOTA_UNCHANGED=YES
- DANGER_FLASH_UNCHANGED=YES
- NO_BITE_NO_INFECTION_NO_HEAL=YES
- NO_POSITION_WRITE=YES
- MELEE_SCALING_RUNTIME=NO
- GLOBAL_WEAPON_TEMPLATE_WRITE=NO

Changed:

- Cost route mapping only.
- JogBump explicit cost consumer.
- Sandbox CN translation syntax.
- Version identity.


```

## 0.5.36_JOG_BUMP_CONSUMER_REPAIR.md

- SHA-256: `3217AD079397E0620CB57513FBC3B3E85E3BE56BB0CC4BDAF2AF87747FC2B959`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 JogBump Consumer Repair

JOG_BUMP_HAS_DIRECT_CONSUMER=YES

Direct consumer:

- XNP_DR_JogBumpLaunch.lua

Runtime route:

- Core.CostTuning.ComputeFinalCost("JOG_BUMP", Config.JOG_BUMP_COST)

Behavior:

- JogBump still uses the previous target selection and effect route.
- The stamina cost is charged once after the action is accepted and the effect is applied.
- The route logs charged_once status.
- NativeTripCostMultiplier is not applied.
- Explicit cost is marked through LongMigrationStaminaAssist.NotifySkillCost so it is not refunded as smooth locomotion drain.


```

## 0.5.36_NATIVE_TRIP_ONLY_CONSUMER.md

- SHA-256: `0D2881D26E938D892F8053AE7BE260C9043D11FFCA39E8C71809604D47ABC9F3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 NativeTrip Only Consumer

NATIVE_TRIP_MULTIPLIER_NATIVE_TRIP_ONLY=YES

Allowed consumers:

- XNP_DR_CostTuning.lua route registry.
- XNP_DR_SandboxTuning.lua sandbox value storage and validation.
- XNP_DR_SprintTripImmunity.lua SPRINT_TRIP_CANCEL cost route.
- XNP_DR_SprintTripConsequence.lua zero-base route log for native-trip consequence visibility.

Disallowed consumers checked:

- WALL_IMPACT does not use NativeTripCostMultiplier.
- JOG_BUMP does not use NativeTripCostMultiplier.
- SPRINT_PRECOLLISION does not use NativeTripCostMultiplier.
- SPRINT_VEHICLE_ZOMBIE does not use NativeTripCostMultiplier.
- CONTROLLED_ESCAPE does not use NativeTripCostMultiplier.


```

## 0.5.36_SANDBOX_CN_SYNTAX_REPAIR.md

- SHA-256: `32B6B0DC3D5ACA84828AB6107D3FE9427D51DCC7F41DEB5ED00DE378B57A5C19`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 Sandbox CN Syntax Repair

ORIGINAL_ODD_QUOTE_LINES=35
FINAL_ODD_QUOTE_LINES=0
SMART_QUOTE_HITS=0
DUPLICATE_KEYS=0
CN_ONLY_KEYS=0
EN_ONLY_KEYS=0
EMPTY_KEY=0
MALFORMED_LINES=0
CN_EN_KEY_PARITY=YES

Repair details:

- Replaced the broken CN sandbox translation file in the 0.5.36 source.
- Used paired ASCII double quotes for every string.
- Avoided smart quotes.
- Kept the same key set as EN.
- Did not create a second translation directory.
- Did not hardcode Chinese strings in runtime Lua.


```

## 0.5.36_TEST_PLAN.md

- SHA-256: `44A68B32E4051CF0D6A085C1A6A7C5906D7AC2146E7F0D5E732BB0459AD96B28`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.36 Test Plan

Do not package or install from this report. User performs manual copy/test.

Static checks before game:

- Confirm build marker is XNP_PZ_DISTANCE_TRAIT_0536_SANDBOX_TRANSLATION_ROUTE_REPAIR_A.
- Confirm sandbox options appear under XNP Distance Runner.
- Confirm CN sandbox page loads without translation syntax failure.
- Confirm no WallImpactCostMultiplier option appears.

In-game checks:

- Release preset: sprint precollision cost should be near 0.0200.
- Release preset: sprint vehicle zombie light cost should be near 0.0300.
- Release preset: jog bump should log route=JOG_BUMP and charge once.
- Custom preset: changing JogBumpCostMultiplier affects JogBump only.
- Custom preset: changing NativeTripCostMultiplier does not affect wall impact cost.
- Custom preset: changing global multiplier does not affect wall impact cost.
- Wall impact logs fixed baseline.
- Existing icon color, shake, drag, stamina curve, resource gate, and effects remain unchanged.


```

## 0.5.36_WALL_IMPACT_FIXED_BASELINE.md

- SHA-256: `AF4712589C045A6B1D334A2F29F36C6C5C0577263F4726654763804B2DAD8BE4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 Wall Impact Fixed Baseline

WALL_IMPACT_SANDBOX_TUNING=NO
WALL_IMPACT_BASELINE_PRESERVED=YES

Implementation:

- WALL_IMPACT is registered in XNP_DR_CostTuning.lua as fixedBaseline=true.
- GlobalSkillCostMultiplier is not applied.
- ZombieImpactCostMultiplier is not applied.
- Route-specific multiplier is none.
- NativeTripCostMultiplier is not applied.
- No WallImpactCostMultiplier sandbox option exists.

Expected logs:

- [XNP COST ROUTE] route=WALL_IMPACT tuning=FIXED_BASELINE
- [XNP COST ROUTE] route=WALL_IMPACT sandbox_multiplier_applied=false
- [XNP COST ROUTE] route=WALL_IMPACT native_trip_multiplier_applied=false
- [XNP COST ROUTE] route=WALL_IMPACT final_cost=... baseline_preserved=true


```

## BUILD_MARKER.txt

- SHA-256: `7783785AE3186D9A3EBCBDFC6A7CDD7342E452DEFDF2160167D2E633044977D0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0536_SANDBOX_TRANSLATION_ROUTE_REPAIR_A

```

## FINAL_REPORT.md

- SHA-256: `3EA3AA15E41C90004C86BBE179502BA5AC3AAE3996BAE2C0C9C831EF65191E3C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.36
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0536_SANDBOX_TRANSLATION_ROUTE_REPAIR_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.36 Sandbox Translation Route Repair

## Changed Files

- BUILD_MARKER.txt
- mod.info
- 42/mod.info
- 42/media/lua/shared/translate/EN/Sandbox_EN.txt
- 42/media/lua/shared/translate/CN/Sandbox_CN.txt
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_CostTuning.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_JogBumpLaunch.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintVehicleImpact.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintTripConsequence.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintTripImmunity.lua
- 0.5.36 documentation files

## Results

Sandbox_CN repair:

- ORIGINAL_ODD_QUOTE_LINES=35
- FINAL_ODD_QUOTE_LINES=0
- CN_EN_KEY_PARITY=YES

Route matrix:

- JOG_BUMP -> XNP_DR_JogBumpLaunch
- SPRINT_PRECOLLISION -> XNP_DR_BreakoutPush
- SPRINT_VEHICLE_ZOMBIE -> XNP_DR_SprintVehicleImpact
- CONTROLLED_ESCAPE -> XNP_DR_BreakoutPush
- NATIVE_TRIP -> XNP_DR_SprintTripImmunity / native-trip consequence route
- WALL_IMPACT -> XNP_DR_SprintVehicleImpact fixed baseline

Default final costs:

- SPRINT_PRECOLLISION=0.0200
- SPRINT_VEHICLE_ZOMBIE=0.0300
- JOG_BUMP=base*0.40
- WALL_IMPACT=baseline fixed cost

Preserve:

- Sandbox namespace and all 23 options preserved.
- Server authoritative sandbox path preserved.
- Client local override remains false.
- No WallImpactCostMultiplier option added.
- Color, shake, drag, stamina curve, resource gate, skill effects, ActionBus, and ImpactQuota are preserved by scope.
- Melee scaling runtime remains disabled.
- No global weapon template write.

Boundary:

- Old SOURCE modified: NO
- PZ launched: NO
- Steam launched: NO
- mods/saves/Workshop/game dir written: NO
- packaged or installed: NO

Static status:

- active old residue: 0
- forbidden active Lua hits: 0
- BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.36_SOURCE_READY_FOR_SANDBOX_TUNING_TEST

```

## 0.5.36_FIX_FROM_0.5.35_AUDIT.md

- SHA-256: `CDFF42FD53EA0C09C30E117A23AF3AFDE083B5B133E58FBE3C25AABF2DA4ACD2`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 Fix From 0.5.35 Audit

BASELINE=0.5.35
FIX_SCOPE=THREE_AUDIT_BLOCKERS_ONLY

Fixed blockers:

- Sandbox_CN syntax repaired with UTF-8 text and balanced ASCII quotes.
- Wall impact no longer uses sandbox multipliers.
- Cost routes now use XNP_DR_CostTuning.lua as the single registry.
- JogBump has a direct JOG_BUMP cost consumer in XNP_DR_JogBumpLaunch.lua.
- NativeTripCostMultiplier is isolated to NATIVE_TRIP route consumers.

Not changed:

- Color mapping.
- Status icon drag behavior.
- Status icon shake behavior.
- Release stamina curve defaults.
- Smooth refund design except explicit action cost blocking already introduced before this version.
- Resource gate.
- Breakout effects.
- JogBump effect selection.
- SprintVehicle effect selection.
- NativeTrip effect behavior.
- ActionBus and ImpactQuota behavior.
- Melee scaling remains deferred.


```

## 0.5.36_NO_DOUBLE_MULTIPLIER_AUDIT.md

- SHA-256: `BD46BF37A28C97637FADD0830526615D1C110733D9ECDD4637DF09A65F024082`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.36 No Double Multiplier Audit

NO_DOUBLE_MULTIPLIER=YES

Single formula:

finalCost = baseCost * globalMultiplier * zombieMultiplier * routeMultiplier

ZombieImpact routes:

- JOG_BUMP
- SPRINT_PRECOLLISION
- SPRINT_VEHICLE_ZOMBIE

Non-zombie routes:

- CONTROLLED_ESCAPE
- NATIVE_TRIP

Fixed baseline route:

- WALL_IMPACT

Default checks:

- SPRINT_PRECOLLISION final = 0.0200
- SPRINT_VEHICLE_ZOMBIE final = 0.0300
- JOG_BUMP final = base * 0.40

SandboxTuning no longer maps WALL_IMPACT to NativeTripCostMultiplier.


```

## 0.5.36_SECOND_PASS_AUDIT.md

- SHA-256: `D1374C60243249D4F61FB53AEDF1D975186B4466B22B5AF2E8DFF4D4BEF96C75`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.36 Second Pass Audit

SOURCE:
`[LOCAL_PATH_REDACTED]`

AUDIT_MODE:
Static audit only. No code changes, no packaging, no installation, no Project Zomboid launch, no Steam launch.

FINAL_STATUS:
`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.36_SECOND_PASS_AUDIT_RISK_TEST_ALLOWED`

## 1. Version And Source Identity

SOURCE_EXISTS=YES

EXPECTED_VERSION=0.5.36

EXPECTED_BUILD_MARKER=`XNP_PZ_DISTANCE_TRAIT_0536_SANDBOX_TRANSLATION_ROUTE_REPAIR_A`

EXPECTED_DISPLAY_NAME=`XNP Distance Runner Trait 0.5.36 Sandbox Translation Route Repair`

BUILD_MARKER_OK=YES

DISPLAY_NAME_OK=YES

Checked locations:

- `BUILD_MARKER.txt`: expected marker present.
- `mod.info`: expected name, version, modversion present.
- `42\mod.info`: expected name, version, modversion present.
- `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua`: expected display name, version, internal version, build id present.

File count comparison:

| Source | File count | Lua files | Lua lines | Markdown |
|---|---:|---:|---:|---:|
| 0.5.34 | 63 | 46 | 9593 | 10 |
| 0.5.35 | 69 | 47 | 10081 | 12 |
| 0.5.36 | 69 | 48 | 10347 | 11 |

LARGE_COPY_DETECTED=NO

0.5.36 adds one Lua module and 266 Lua lines over 0.5.35. This is consistent with the CostTuning route repair scope.

ACTIVE_LUA_VERSION_SCAN:

- `0.5.34`: 0
- `0.5.35`: 0
- `0534`: 0
- `0535`: 0
- `0.5.36`: 3
- `0536`: 1

OLD_ACTIVE_RESIDUE=NO

OLD_SOURCE_MODIFIED=NO

0.5.35 source scan for 0.5.36 marker/report/CostTuning pollution: 0 hits.

## 2. Sandbox_CN Syntax

Active CN translation:
`42\media\lua\shared\translate\CN\Sandbox_CN.txt`

Reference EN translation:
`42\media\lua\shared\translate\EN\Sandbox_EN.txt`

ORIGINAL_ODD_QUOTE_LINES=35

FINAL_ODD_QUOTE_LINES=0

SMART_QUOTE_HITS=0

MALFORMED_LINES=0

DUPLICATE_KEYS=0

EMPTY_KEYS=0

EMPTY_VALUES=0

CN_ONLY_KEYS=0

EN_ONLY_KEYS=0

DUPLICATE_TRANSLATION_PATHS=NO

Translation path counts:

- CN Sandbox files: 1
- EN Sandbox files: 1

HARDCODED_CN_RUNTIME_HITS=0

SANDBOX_CN_STATUS=PASS

## 3. Cost Route Registry

COST_TUNING_MODULE=YES

Module:
`42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_CostTuning.lua`

ROUTE_REGISTRY_COMPLETE=YES

Registered routes:

| Route | Consumer | Global | ZombieImpact | Route-specific field | Fixed/Tunable | Default final formula |
|---|---|---|---|---|---|---|
| JOG_BUMP | XNP_DR_JogBumpLaunch | YES | YES | JogBumpCostMultiplier | Tunable | base * Global * ZombieImpact * JogBump |
| SPRINT_PRECOLLISION | XNP_DR_BreakoutPush | YES | YES | SprintPrecollisionCostMultiplier | Tunable | 0.0500 * 1.00 * 0.40 * 1.00 = 0.0200 |
| SPRINT_VEHICLE_ZOMBIE | XNP_DR_SprintVehicleImpact | YES | YES | SprintVehicleZombieCostMultiplier | Tunable | 0.0750 * 1.00 * 0.40 * 1.00 = 0.0300 |
| CONTROLLED_ESCAPE | XNP_DR_BreakoutPush | YES | NO | ControlledEscapeCostMultiplier | Tunable | base * Global * ControlledEscape |
| NATIVE_TRIP | XNP_DR_SprintTripConsequence / XNP_DR_SprintTripImmunity | YES | NO | NativeTripCostMultiplier | Tunable | base * 
[EXCERPT_TRUNCATED]
```
