# 0.5.30 Sanitized Evidence Excerpts

## 0.5.30_ENDURANCE_CAPABILITY_STATE_MACHINE.md

- SHA-256: `C5BDC5262B118E6F17C7890CB1D03E9CEE1067D9C720504D5A5B68DEEFA0A4A6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.30 Endurance Capability State Machine

Runtime module:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceCapabilityState.lua`

Public methods:

- `Sample(player)`
- `GetEndurance(player)`
- `CanSustainSprint(player, sample)`
- `CanSustainJog(player, sample)`
- `GetFoodReserveState(player, sample)`
- `Classify(player, sample)`
- `GetStableState(player)`
- `Reset(player)`

States:

- GREEN=SPRINT_READY
- BLUE=SPRINT_RESERVE_LOW
- YELLOW=JOG_ONLY_METABOLIC_SUPPORT
- RED=EXHAUSTED_EMERGENCY_METABOLIC_SUPPORT
- WHITE=FOOD_RESERVE_GUARD

Classifier basis:

- normalized endurance
- recent trend from `XNP_DR_StaminaTrendMeter`
- sprint capability
- jog capability
- hunger and food reserve guard
- fatigue as a capability modifier

Movement independence:

- movement state is sampled for diagnostics and recovery activation only
- movement state does not directly select the color tier
- transient action windows keep the previous stable stamina state


```

## 0.5.30_GREEN_BLUE_YELLOW_RED_WHITE_SEMANTICS.md

- SHA-256: `BB5201AC1E8207619560E5DBBDCD2267F8CB747E220F2D5F7A10D56D63E310A3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.30 Green Blue Yellow Red White Semantics

COLOR_SOURCE=ENDURANCE_CAPABILITY_NOT_MOVEMENT

GREEN=SPRINT_READY

- endurance is above the green threshold
- sprint capability is available
- no resource guard is active

BLUE=SPRINT_RESERVE_LOW

- sprint remains possible
- endurance is approaching the sprint failure band
- blue is not selected just because running started

YELLOW=JOG_ONLY_METABOLIC_SUPPORT

- sprint is no longer sustainable
- jog is still sustainable
- moderate metabolic support can run

RED=EXHAUSTED_EMERGENCY_METABOLIC_SUPPORT

- jog is not sustainable or endurance is below the red/yellow boundary
- short emergency metabolic burst can run
- red does not restore to green

WHITE=FOOD_RESERVE_GUARD

- hunger or food reserve guard is active
- conversion is reduced or stopped
- white is not full stamina and not green


```

## 0.5.30_METABOLIC_PROFILE_BY_STATE.md

- SHA-256: `A59475F3F3EF168177A870E457A9AA7D11CAC83F2DED2386D0BFD466A695CE94`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.30 Metabolic Profile By State

NO_INFINITE_STAMINA=YES

NO_INFINITE_SPRINT=YES

GREEN profile:

- restore: 0
- hunger multiplier: 0

BLUE profile:

- no active hunger burn
- drain reduction profile marker: `BLUE_DRAIN_REDUCTION_MULTIPLIER=0.72`

YELLOW profile:

- restore per tick: `YELLOW_RESTORE_PER_TICK=0.0045`
- hunger multiplier: `YELLOW_HUNGER_COST_MULTIPLIER=1.0`
- target max: `YELLOW_RESTORE_TARGET_MAX=0.40`

RED profile:

- restore per tick: `RED_RESTORE_PER_TICK=0.0070`
- hunger multiplier: `RED_HUNGER_COST_MULTIPLIER=1.8`
- target max: `RED_RESTORE_TARGET_MAX=0.26`
- burst max: `RED_BURST_MAX_SECONDS=10`
- cooldown: `RED_BURST_COOLDOWN_SECONDS=25`

WHITE profile:

- conversion multiplier: `WHITE_GUARD_CONVERSION_MULTIPLIER=0.15`
- hard stop multiplier: `WHITE_GUARD_HARD_STOP_MULTIPLIER=0.0`

Global cap:

- `GLOBAL_METABOLIC_MAX_HUNGER_COST_PER_MINUTE=0.07`
- `GLOBAL_NO_FULL_RESTORE=true`
- `GLOBAL_NO_INFINITE_SPRINT=true`


```

## 0.5.30_PRESERVE_CORE_MECHANICS.md

- SHA-256: `3621909946A3160C9D7AD803CEE86A2B5BA99524FC0A5D8B3DA892ED9B7F9289`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.30 Preserve Core Mechanics

CORE_MECHANICS_PRESERVED=YES

Preserved:

- RedStrain and trend meter
- JogFloor
- Metabolic reserve
- Safe RGBA
- Log silence
- Walk No Impact
- Controlled Jog Escape
- JogBump
- SprintVehicle
- NativeTrip
- Drag capture, tooltip, and danger red flash
- no bite rollback
- no infection rollback
- no heal route
- no player coordinate write

0.5.30 scope:

- endurance capability color state
- metabolic recovery profile tuning

Not changed:

- collision feel
- zombie impact logic
- controlled escape radius
- drag capture mechanism
- walking impact rules


```

## 0.5.30_REAL_GAME_COLOR_LOGIC_FIX_FROM_0.5.29.md

- SHA-256: `1A601B5880072101F2247A64B382B1D1D5AADA899B961704077B629BCE6C61A0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.30 Real Game Color Logic Fix From 0.5.29

COLOR_SOURCE=ENDURANCE_CAPABILITY_NOT_MOVEMENT

The 0.5.29 live result showed that the icon could change from blue to green when the player fell or stopped, then back to blue when running started. That made the icon reflect current action state too strongly.

0.5.30 changes the normal stamina icon source to `XNP_DR_EnduranceCapabilityState.lua`.

Key constraints:

- KNOCKDOWN_DOES_NOT_FORCE_GREEN=YES
- RUN_START_DOES_NOT_FORCE_BLUE=YES
- DANGER_OVERRIDE_RESTORES_PREVIOUS_STAMINA_STATE=YES
- CORE_MECHANICS_PRESERVED=YES

Runtime integration:

- `XNP_DR_Runtime.lua` requires `XNP_DR_EnduranceCapabilityState.lua`.
- `XNP_DR_StatusIconUI.lua` reads stable capability state before the legacy stamina assist status.
- `XNP_DR_LongMigrationStaminaAssist.lua` uses the same state to choose metabolic profile.


```

## 0.5.30_RESOURCE_GUARD_WHITE_STATE.md

- SHA-256: `CBBDDF89D718FDCE07255D946F2363842BE930C4977D3C34D033DC8E6EAAA42B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.30 Resource Guard White State

WHITE=FOOD_RESERVE_GUARD

White state means the mod is protecting food reserve. It does not mean stamina is full or safe.

Config:

- `RESOURCE_GUARD_WHITE_ENABLED=true`
- `RESOURCE_GUARD_WHITE_HUNGER_THRESHOLD=0.78`
- `RESOURCE_GUARD_WHITE_HARD_STOP_THRESHOLD=0.88`
- `RESOURCE_GUARD_WHITE_CALORIE_FLOOR=-800`
- `RESOURCE_GUARD_WHITE_CONVERSION_MULTIPLIER=0.15`
- `RESOURCE_GUARD_WHITE_HARD_STOP_MULTIPLIER=0.0`

Behavior:

- soft guard reduces conversion
- hard guard stops conversion
- white state has higher priority than ordinary stamina colors
- danger flash still has higher visual priority


```

## 0.5.30_STATE_HYSTERESIS_AND_TRANSIENT_HOLD.md

- SHA-256: `84F2525F9911D9B03BF6AC9FA31EA6A06204BC2D141302A45AA7BD5640BF4E0C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.30 State Hysteresis And Transient Hold

HYSTERESIS=YES

MINIMUM_HOLD=YES

KNOCKDOWN_GETUP_TRANSIENT_HOLD=YES

DANGER_OVERRIDE_RESTORES_PREVIOUS_STAMINA_STATE=YES

Config:

- `ENDURANCE_STATE_HYSTERESIS=0.035`
- `ENDURANCE_STATE_MIN_HOLD_FRAMES=45`
- `ENDURANCE_STATE_TRANSIENT_HOLD_FRAMES=75`

Behavior:

- threshold crossings need hysteresis confirmation
- normal color state has a minimum hold
- knocked down, fall, trip, getup, bumped, and controlled windows do not reset color to green
- danger flash can override visually and then restore the previous stable stamina state


```

## 0.5.30_TEST_PLAN.md

- SHA-256: `3C537AD576254A3BB39A8CA4B1EFFA3434925B0C1B6FB41E9AA049FF07FA8DC5`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.30 Test Plan

Status expected in source:

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.30_SOURCE_READY_FOR_ENDURANCE_COLOR_TEST`

Manual real-game checks:

1. Start with high endurance and begin normal long running.
   - Expected: icon remains green until endurance capability actually drops.

2. Continue until sprint reserve is low.
   - Expected: icon becomes blue only near the sprint reserve band.

3. Drain into jog-only capability.
   - Expected: icon becomes yellow and moderate metabolic support is logged.

4. Drain into exhausted capability.
   - Expected: icon becomes red, red burst support is logged, and target cap remains low.

5. Raise hunger / deplete reserve.
   - Expected: icon becomes white and conversion is reduced or stopped.

6. Fall, get up, stop, or transition through brief controlled states.
   - Expected: transient actions do not force green.

7. Trigger danger red flash.
   - Expected: danger visual override ends by returning to the previous stamina state.

Regression checks:

- ordinary walking has no impact
- controlled jog escape remains available
- jog bump remains available
- sprint vehicle impact remains available
- drag icon remains draggable and persistent
- no full stamina restoration loop
- no full sprint infinite loop


```

## BUILD_MARKER.txt

- SHA-256: `3D38381E0B66C32DFB5D8E4CA2ADD163890EB844CE4E3F14785980B86DB60959`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0530_ENDURANCE_CAPABILITY_COLOR_STATE_A

```

## FINAL_REPORT.md

- SHA-256: `2EADA06218F4738433C6558D4BD40479DB6423E1FE009B3AD39AD7A98BB33EC8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.30

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0530_ENDURANCE_CAPABILITY_COLOR_STATE_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.30 Endurance Capability Color State

FILE_COUNT=61

LUA_COUNT=44

LUA_LINES=9632

COLOR_SOURCE=ENDURANCE_CAPABILITY_NOT_MOVEMENT

GREEN=SPRINT_READY

BLUE=SPRINT_RESERVE_LOW

YELLOW=JOG_ONLY_METABOLIC_SUPPORT

RED=EXHAUSTED_EMERGENCY_METABOLIC_SUPPORT

WHITE=FOOD_RESERVE_GUARD

KNOCKDOWN_DOES_NOT_FORCE_GREEN=YES

RUN_START_DOES_NOT_FORCE_BLUE=YES

DANGER_OVERRIDE_RESTORES_PREVIOUS_STAMINA_STATE=YES

NO_INFINITE_STAMINA=YES

NO_INFINITE_SPRINT=YES

CORE_MECHANICS_PRESERVED=YES

## Changed Runtime Files

- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceCapabilityState.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist.lua`
- `mod.info`
- `42/mod.info`
- `BUILD_MARKER.txt`

## Verification

ACTIVE_LUA_OLD_RESIDUE=0

RUNTIME_FORBIDDEN_HITS=0

PROGRESS_YELLOW_HITS=0

UNSAFE_NAMED_COLOR_HITS=0

LUA_EXECUTION_SYNTAX_CHECK=NOT_VERIFIABLE_LOCAL_LUA_NOT_AVAILABLE

OLD_SOURCE_MODIFIED=NO

PROJECT_ZOMBOID_LAUNCHED=NO

STEAM_LAUNCHED=NO

USER_MODS_WRITTEN=NO

SAVES_WRITTEN=NO

WORKSHOP_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

PACKAGED_OR_INSTALLED=NO

FINAL_STATUS:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.30_SOURCE_READY_FOR_ENDURANCE_COLOR_TEST

```

## 0.5.30_SECOND_PASS_AUDIT.md

- SHA-256: `37E39CCD30F030AEB96D2609A18FFC7AFA429B15A38790873283157E92D30E42`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.30 Second Pass Audit

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]

AUDIT_TYPE=READ_ONLY_SECOND_PASS

ALLOWED_WRITE=0.5.30_SECOND_PASS_AUDIT.md

PROJECT_ZOMBOID_LAUNCHED=NO

STEAM_LAUNCHED=NO

USER_MODS_WRITTEN=NO

SAVES_WRITTEN=NO

WORKSHOP_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

PACKAGED_OR_INSTALLED=NO

OLD_SOURCE_MODIFIED=NO

## 1. Version And File Count

SOURCE_EXISTS=YES

VERSION_OK=YES

EXPECTED_VERSION=0.5.30

BUILD_MARKER_OK=YES

EXPECTED_BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0530_ENDURANCE_CAPABILITY_COLOR_STATE_A

DISPLAY_NAME_OK=YES

EXPECTED_DISPLAY_NAME=XNP Distance Runner Trait 0.5.30 Endurance Capability Color State

FILE_COUNT_0529=57

FILE_COUNT_0530=61

LUA_COUNT_0530=44

LUA_LINES_0530=9632

LARGE_COPY_DETECTED=NO

OLD_ACTIVE_RESIDUE=PASS

ACTIVE_LUA_OLD_VERSION_HITS=0

## 2. Endurance Capability Classifier Audit

CLASSIFIER_FILE=YES

CLASSIFIER_RUNTIME=YES

CLASSIFIER_INTERFACES=PASS

Verified interfaces:

- Sample
- GetEndurance
- CanSustainSprint
- CanSustainJog
- GetFoodReserveState
- Classify
- GetStableState

FIVE_STATES_PRESENT=YES

Verified states:

- GREEN_READY
- BLUE_SPRINT_RESERVE_LOW
- YELLOW_JOG_ONLY
- RED_EXHAUSTED
- WHITE_RESOURCE_GUARD

MOVEMENT_INDEPENDENT=YES

Evidence:

- `movement_state_does_not_select_color=true` log exists.
- `XNP_DR_StatusIconUI.lua` gets color state from `EnduranceCapabilityState.GetStableState(player)`.
- `FULL_SPRINT_ACTIVE` direct color route hits: 0.
- `return "SPRINT"` direct color route hits: 0.
- `not running -> GREEN` route hits: 0.
- `idle -> GREEN` route hits: 0.

FORBIDDEN_MOVEMENT_COLOR_ROUTE=PASS

CLASSIFIER_STATUS=PASS

## 3. Five Color Semantic Audit

GREEN_SEMANTIC=PASS

Green is tied to high endurance and sprint capability, not current running state.

BLUE_SEMANTIC=PASS

Blue is tied to sprint reserve low while sprint remains possible. It is not selected just because the player starts running.

YELLOW_SEMANTIC=PASS

Yellow represents jog-only capability and has a yellow metabolic support profile.

RED_SEMANTIC=PASS

Red represents exhausted or red-strain failure conditions. Runtime config sets `RED_RESTORE_TARGET_MAX=0.26`, so red does not restore to green.

WHITE_SEMANTIC=PASS

White represents food/resource guard. Runtime config sets `WHITE_GUARD_CONVERSION_MULTIPLIER=0.15` and `WHITE_GUARD_HARD_STOP_MULTIPLIER=0.0`.

STATE_SEMANTIC_STATUS=PASS

## 4. Hysteresis And Transient Hold Audit

HYSTERESIS=PASS

`ENDURANCE_STATE_HYSTERESIS=0.035`

MINIMUM_HOLD=PASS

`ENDURANCE_STATE_MIN_HOLD_FRAMES=45`

TRANSIENT_ACTION_HOLD=PASS

`ENDURANCE_STATE_TRANSIENT_HOLD_FRAMES=75`

Required log strings present:

- `[XNP ENDURANCE STATE HOLD]`
- `reason=TRANSIENT_ACTION`
- `[XNP ENDURANCE STATE RESTORE]`
- `[XNP ENDURANCE STATE HYSTERESIS]`

DANGER_OVERRIDE_RESTORE=PASS

NO_FORCE_GREEN_AFTER_OVERRIDE=PASS

The restore path calls `EnduranceCapabilityState.RestorePreviousAfterOverride()` and does not hardcode green.

STABILITY_STATUS=PASS

## 5. Metabolic Profile Audit

GREEN_PROFILE=PASS

Gre
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `A480AADF920CC1C8AD29F51733FE995FDA9CBC87B6DE9435E0EA25ACF8CF4CE6`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE=[LOCAL_PATH_REDACTED]

BASELINE=0.5.29

OLD_SOURCE_MODIFIED=NO

VERSION=0.5.30

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0530_ENDURANCE_CAPABILITY_COLOR_STATE_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.30 Endurance Capability Color State

FILE_COUNT=61

LUA_COUNT=44

LUA_LINES=9632

ACTIVE_RUNTIME_LUA_COUNT=43

LUA_EXECUTION_SYNTAX_CHECK=NOT_VERIFIABLE_LOCAL_LUA_NOT_AVAILABLE

STRING_BALANCE_SCAN=PASS

ACTIVE_LUA_OLD_RESIDUE=0

RUNTIME_FORBIDDEN_HITS=0

LARGE_COPY_POLLUTION=NO

## Endurance Capability Runtime

ENDURANCE_CAPABILITY_STATE_MODULE=YES

ENDURANCE_CAPABILITY_STATE_RUNTIME_REQUIRE=YES

ENDURANCE_CAPABILITY_STATE_RUNTIME_CALL=YES

COLOR_SOURCE=ENDURANCE_CAPABILITY_NOT_MOVEMENT

MOVEMENT_DIRECT_COLOR_SELECTION=NO

NOT_RUNNING_FORCE_GREEN_ROUTE=NO

RUNNING_FORCE_BLUE_ROUTE=NO

KNOCKDOWN_GETUP_IDLE_FORCE_GREEN_ROUTE=NO

GREEN_READY_RUNTIME_STATE=YES

BLUE_SPRINT_RESERVE_LOW_RUNTIME_STATE=YES

YELLOW_JOG_ONLY_RUNTIME_STATE=YES

RED_EXHAUSTED_RUNTIME_STATE=YES

WHITE_RESOURCE_GUARD_RUNTIME_STATE=YES

HYSTERESIS=YES

MINIMUM_HOLD=YES

TRANSIENT_ACTION_HOLD=YES

DANGER_OVERRIDE_RESTORE_PREVIOUS_STATE=YES

## Metabolic Profiles

GREEN_NO_HUNGER_BURN=YES

BLUE_DRAIN_REDUCTION=YES

YELLOW_METABOLIC_PROFILE=YES

RED_EMERGENCY_BURST=YES

RED_TARGET_MAX=0.26

RED_COOLDOWN_SECONDS=25

WHITE_GUARD_MULTIPLIER=0.15

WHITE_HARD_STOP=YES

NO_FULL_RESTORE=YES

NO_INFINITE_SPRINT=YES

## Icon

SAFE_RGBA=YES

PROGRESS_YELLOW_HITS=0

UNSAFE_NAMED_COLOR_HITS=0

ENGLISH_TOOLTIP_UPDATED=YES

DRAG_CAPTURE_PRESERVED=YES

DANGER_FLASH_PRIORITY=YES

## Core Preserve

RED_STRAIN_PRESERVED=YES

JOG_FLOOR_PRESERVED=YES

METABOLIC_RESERVE_PRESERVED=YES

WALK_NO_IMPACT_PRESERVED=YES

CONTROLLED_JOG_ESCAPE_PRESERVED=YES

JOG_BUMP_PRESERVED=YES

SPRINT_VEHICLE_PRESERVED=YES

NATIVE_TRIP_PRESERVED=YES

DRAG_CAPTURE_TOOLTIP_DANGER_FLASH_PRESERVED=YES

NO_BITE_ROLLBACK=YES

NO_INFECTION_ROLLBACK=YES

NO_HEAL_ROUTE=YES

NO_PLAYER_COORDINATE_WRITE=YES

LOG_SILENCE_PRESERVED=YES

BLOCKER=NONE

```
