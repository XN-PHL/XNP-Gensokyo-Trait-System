# 0.5.38 Sanitized Evidence Excerpts

## 0.5.38_AB_PERFORMANCE_TEST_PLAN.md

- SHA-256: `56EBD2F375FD698E5226BAAADFA085AF4E14E378068E18B1E7613EAD4D3FBABF`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.38 A/B Performance Test Plan

Compare:
- 0.5.37 baseline
- 0.5.38 local performance build

Use the same save, position, camera, zombie/NPC density, and loaded mod set.

Record:
- FPS range
- total console log lines over 10 minutes
- XNP log lines over 10 minutes
- XNP summary lines over 10 minutes
- skill success/fail equivalence
- food conversion state changes
- melee hit event logs

Expected:
- XNP blocked event prints reduced substantially.
- No guarantee that external Bandits/NPC/zombie load is fixed.
- Gameplay effect outcomes should remain equivalent except new food reserve conversion and high-endurance melee bonus.
```

## 0.5.38_CENTRAL_SCHEDULER_ARCHITECTURE.md

- SHA-256: `1D28363A3FEA5271ABC17C4DF2780353137D2CF125CFCFC9128460CF8064D7B5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Central Scheduler Architecture

Module: 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_PerformanceScheduler.lua

Groups:
- sandbox: default 2000 ms
- light snapshot/gameplay: 50-250 ms by activity
- threat scan: 100-500 ms by activity/threat
- critical: 50 ms only while sprinting, moving fast, down, or near threat
- food: 1000 ms
- ui: 250 ms

Real-time scheduling uses getTimestampMs()/1000 when available and does not assume 60 FPS.

Default caps:
- PERFORMANCE_MAX_NEARBY_CANDIDATES=16
- IDLE_THREAT_SCAN=500ms
- ACTIVE_THREAT_SCAN=100ms
- CRITICAL_SCAN=50ms

PerformanceMode is sandbox-visible and affects scheduling/caching only, not gameplay outcomes.
```

## 0.5.38_DIRECT_INSTALL_TREE.md

- SHA-256: `559E2063DC1B362CF40FBB0B88BA648BFEBACDE58F53C8543D6A70F0D01A88F9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Direct Install Tree

DIRECT_INSTALL=YES
WORKSHOP_PACKAGE=NO

Folder to copy manually:
$install

`	ext
mod.info
poster.png
42\mod.info
42\poster.png
42\media\registries.lua
42\media\sandbox-options.txt
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ActivationDiagnostic.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutActionBus.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerBreakout.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerClassifier.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DraggableStatusIcon.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakoutCost.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyInput.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceBandState.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceCapabilityState.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FallRecoveryInput.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FoodReserveConversion.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactQuotaMeter.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_JogBumpLaunch.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_JogFallShockwave.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_LongMigrationStaminaAssist.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_MinorScrapeCost.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_MovementIntentGate.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_NativeTripWindow.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_NearbyZombieCache.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_PerformanceBudget.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_PerformanceScheduler.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_PlayerSnapshot.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ShoulderImpact.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_SprintTripConsequence.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_SprintTripImmunity.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_SprintVehicleImpact.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_StaminaColorSafeRGBA.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_StaminaTrendMeter.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_StatusIconInputBindingGuard.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_StatusIconPosition.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_StatusIconUI.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_VanillaImpact.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_VerifiedStaggerControl.lua
42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ZombieVehicleImpact.lua
42\media\lua\server\XNP_
[EXCERPT_TRUNCATED]
```

## 0.5.38_FOOD_RESERVE_CONVERSION_SPEC.md

- SHA-256: `95EEE8230FEC52254F605AA2D71127572A4C15BAB8FA213342BDAE6B19A5A920`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Food Reserve Conversion Spec

System: XNP Low Endurance Food Reserve Conversion

FOOD_TRIGGER=30
FOOD_TARGET=40
FOOD_RESERVE_FLOOR=40
FOOD_TO_ENDURANCE_RATIO=1_TO_1
FOOD_TRANSFER_RATE=1_PERCENT_PER_REAL_SECOND
FOOD_PER_FRAME_WRITE=NO
SERVER_AUTHORITATIVE=YES

Definition:
- foodReserve = clamp(1.0 - hunger, 0.0, 1.0)
- Active starts when endurance < 30%.
- Hysteresis remains active until endurance >= 40%.
- Conversion stops before foodReserve would fall below 40%.
- Tick interval is real-time 1000 ms.
- Catch-up is capped at 2 seconds.
- Recent XNP discrete skill costs delay first conversion by at least 1.0 second.

Runtime module:
- XNP_DR_FoodReserveConversion.lua

Sandbox options:
- EnableLowEnduranceFoodConversion
- FoodConversionTriggerPercent
- FoodConversionTargetPercent
- MinimumFoodReservePercent
- FoodToEnduranceRatioPercent
- FoodConversionRatePercentPerSecond
```

## 0.5.38_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `51C200511E8925E3907DB38313983CBB2DBF95F06D7024F1743DE1E1DD785367`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Gameplay Preserve Report

BASELINE=0.5.37
GAMEPLAY_EFFECTS_PRESERVED=YES

Preserved defaults/effects:
- ZombieImpact default 0.24
- SprintPrecollision route multiplier preserved
- SprintVehicleZombie route multiplier preserved
- Blue refund 30%, Yellow 38%, Red 55%
- Cost route registry preserved
- Wall Impact fixed baseline preserved
- NativeTrip-only multiplier preserved
- JogBump direct consumer preserved
- no-double multiplier model preserved
- Green/Blue/Yellow/Red colors preserved
- non-green shake preserved
- drag behavior preserved
- state commit preserved
- smooth refund preserved
- resource gate preserved
- Walk No Impact preserved
- Controlled Escape preserved
- JogBump preserved
- SprintVehicleImpact preserved except setHealth(0) fallback disabled for nonlethal safety in this test build
- NativeTrip preserved
- SprintTripConsequence preserved
- ActionBus preserved with blocked-log throttling
- ImpactQuota preserved
- danger flash preserved
- no bite/no infection/no heal preserved
- no player coordinate write added
- server authoritative Sandbox preserved
- client local override=false preserved

New systems are additive:
- low-endurance food reserve conversion
- high-endurance melee power
- central scheduler/shared snapshot/log throttle
```

## 0.5.38_HIGH_ENDURANCE_MELEE_EVENT_CONTRACT.md

- SHA-256: `73F10282A0C9A6BE15846DB7F79E8266E159474A1475C1B646E0B837A1D590A0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 High Endurance Melee Event Contract

Module: 42/media/lua/server/XNP_PZ_DistanceRunner/XNP_DR_MeleePower.lua

Verified B42.19.0 local event evidence:
- [LOCAL_PATH_REDACTED]
- Signature: xpUpdate.onWeaponHitXp = function(owner, weapon, hitObject, damage, hitCount)
- Registered at line 385: Events.OnWeaponHitXp.Add(xpUpdate.onWeaponHitXp);
- DamageModelDefinitions.OnHitZombie = function(zombie, wielder, bodyPart, weapon) also exists, but does not expose damage.

Selected event:
- OnWeaponHitXp(owner, weapon, hitObject, damage, hitCount)

Reason:
- Provides attacker, weapon, target, base/final damage value, and hit count token input.

MELEE_EVENT_DRIVEN=YES
MELEE_ON_TICK_TARGET_SCAN=NO
```

## 0.5.38_HIGH_ENDURANCE_MELEE_SAFETY.md

- SHA-256: `1189C5D0933B8B4153B67891246D15F5F672E44F6FFF56748691EB33349D144D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 High Endurance Melee Safety

Defaults:
- MELEE_START=80
- MELEE_FULL=95
- MELEE_MAX_MULTIPLIER=2.00
- MELEE_FORCED_EXECUTE=NO
- MELEE_ZOMBIE_ONLY=YES
- NPC_PLAYER_ANIMAL_EXCLUDED=YES
- GLOBAL_WEAPON_WRITE=NO

Safety rules implemented:
- Attacker must be an IsoPlayer with the XNP trait via object-style trait detector.
- Target must be IsoZombie and not already dead.
- Unarmed and stomp are disabled by default.
- No global HandWeapon or ScriptItem modification.
- No target polling.
- Duplicate token guard blocks repeated settlement inside a short event window.
- Extra damage lowers target health with a 0.0001 floor; it does not call setHealth(0).
- One-hit kills may happen only naturally if base game damage plus bonus exceeds remaining health.

Public API names:
- MeleePower.GetEnduranceMultiplier(player)
- MeleePower.IsValidAttacker(player)
- MeleePower.IsValidZombieTarget(target)
- MeleePower.IsValidMeleeWeapon(weapon)
- MeleePower.OnVerifiedMeleeHit(attacker, target, weapon, baseDamage, hitToken)
- MeleePower.ApplyExtraDamageOnce(...)
- MeleePower.ValidateEventContract()
```

## 0.5.38_HOT_PATH_INVENTORY_AFTER.md

- SHA-256: `17BFE12D4CEB0A1DA25DA47A1ED52B927F2B55ADF862FB461501A8462A25825A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Hot Path Inventory After

ACTIVE_GAMEPLAY_ONTICK_HANDLER_COUNT=1
CENTRAL_GAMEPLAY_TICK_COUNT<=1

Only central gameplay scheduler remains:
- Events.OnPlayerUpdate.Add(Core.Runtime.Update) in XNP_DR_Bootstrap.lua.
- No Events.OnTick in active Lua.
- Render/UI routes are not used for world scanning by the new modules.

After refactor:
- XNP_DR_PerformanceScheduler.lua gates light, threat, critical, food, UI, and sandbox groups.
- XNP_DR_PlayerSnapshot.lua supplies shared movement/endurance/food/threat state.
- XNP_DR_FoodReserveConversion.lua runs on a 1000 ms real-time cadence.
- XNP_DR_MeleePower.lua is event-driven through OnWeaponHitXp; no target scan.
- Blocked logs route through XNP_DR_LogThrottle.lua counters where patched.

FULL_LOADED_ZOMBIE_SCAN_DEFAULT=NO
SHARED_THREAT_SNAPSHOT=YES
DEBUG_DEFAULT=OFF
BLOCKED_EVENT_PRINT=NO
```

## 0.5.38_HOT_PATH_INVENTORY_BEFORE.md

- SHA-256: `A072026D5480B42435F44BD75566BB4BB84430F50A4B8DAD0337D4802C04C032`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Hot Path Inventory Before

Baseline copied from 0.5.37 showed one central OnPlayerUpdate entry, but Runtime called many modules every update.

| handler | module | frequency before | world scan | zombie iteration | print risk | can cache |
|---|---|---:|---|---|---|---|
| Events.OnPlayerUpdate | XNP_DR_Runtime.Update | every player update | indirect | indirect | yes | yes |
| runtime call | NearbyZombieCache | every update | local square scan | local moving objects | low | yes |
| runtime call | DragdownDangerClassifier | every update | local square scan | local moving objects | blocked logs | yes |
| runtime call | BreakoutPush | every update | local candidate query | local candidates | summaries | yes |
| runtime call | ActionBus | every update | no | no | blocked logs | yes |
| runtime call | StatusIconUI | every update | no | no | state logs | yes |
| runtime call | LongMigrationStaminaAssist | every update with internal frame gate | no | no | blocked logs | yes |

Known pressure points:
- Multiple modules independently read player movement/endurance/state.
- Threat-related modules all ran from the same high-frequency Runtime path.
- Blocked reasons could print repeatedly.
- Food/endurance logic had no dedicated 1000 ms real-time cadence.
```

## 0.5.38_LOCAL_ZOMBIE_QUERY_OPTIMIZATION.md

- SHA-256: `2838ACBDC800FAD598AC6702BE701C0CEB9538EA9E5AED108CC4AA5F98213293`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Local Zombie Query Optimization

Default query route:
- player local cell
- grid squares around the player
- square moving objects
- live IsoZombie candidates only
- hard candidate cap 16

No default getLoadedZombieList usage was introduced.

The optimization does not expand effect quota. ImpactQuota, ActionBus, and old gameplay limits remain preserved.

Fallback to full loaded zombie list: NOT_IMPLEMENTED_BY_DEFAULT
```

## 0.5.38_LOG_THROTTLE_REPORT.md

- SHA-256: `BC7D54DABAB0EFAFC5B4DC89E049E9CE128A86FF802AFD7B72315E196B3C5F37`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Log Throttle Report

Module: XNP_DR_LogThrottle.lua

Default behavior:
- Startup, build marker, sandbox load, true skill success, true cost, and true errors may print.
- Blocked reasons are counted through LogThrottle.Blocked where patched.
- Summary interval default: 10 seconds.
- Zero-count categories do not print.

Patched routes include:
- ActionBus blocked paths
- MovementIntentGate blocked paths
- LongMigrationStaminaAssist blocked path and NotifySkillCost path
- FoodReserve blocked paths
- MeleePower blocked paths

DEBUG_DEFAULT=OFF
BLOCKED_EVENT_PRINT=NO
PER_FRAME_PRINT_TARGET=NO
```

## 0.5.38_REAL_GAME_LOG_PERFORMANCE_EVIDENCE.md

- SHA-256: `CE70D6D9BBD4B26D8F52E826671475336D5C96D37D457429807CA96EBD39EA82`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.38 Real Game Log Performance Evidence

BASELINE=0.5.37
RELEASE_VERSION=NO
WORKSHOP_PACKAGE=NO
DIRECT_INSTALL=YES

Accepted user evidence from the rebuild environment:
- Total console log around 7570 lines.
- XNP logs around 5856 lines, about 77% of total.
- In about 14707 frames, XNP produced about 398 lines per 1000 frames.
- XNP SUMMARY class logs around 2480 lines.
- Direct [XNP DRAGDOWN BREAKOUT], [XNP AUTO DRAGDOWN], [XNP ACTION BUS], and [XNP STATUS ICON] logs were high-volume.
- Breakout summary attempts could reach 300-400 inside 60-frame windows.
- Sprint immunity blocked counter exceeded 35000 in the provided log sample.

External load acknowledgement:
- 20-30 FPS cannot be fully attributed to XNP.
- Bandits/NPC pathing, 200+ active zombies, and other large mods remain likely major load sources.
- 0.5.38 only reduces XNP's own polling, repeated nearby checks, and log I/O.

EXTERNAL_NPC_LOAD_ACKNOWLEDGED=YES
```
