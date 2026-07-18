# 0.5.33 Sanitized Evidence Excerpts

## 0.5.33_EXPLICIT_STATE_COMMIT_CONTRACT.md

- SHA-256: `D0E5D99047DCF016A8516D59D9B8F12D8485A17A3D68F1CA75EB734D006DCA6C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.33 Explicit State Commit Contract

BASELINE=0.5.32
FIX_SCOPE=AUDIT_BLOCKER_CLEANUP_ONLY

Runtime file:

- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState.lua`

Explicit contract markers:

- STATE_CHANGED_THIS_TICK=EXPLICIT
- STABLE_STATE_ASSIGNMENT=EXPLICIT
- CANDIDATE_CLEAR_AFTER_COMMIT=YES
- SAME_TICK_RECREATE=BLOCKED

Commit path now contains:

- `stateChangedThisTick`
- `EnduranceBandState.stableState = EnduranceBandState.candidateState`
- `EnduranceBandState.candidateState = nil`
- `EnduranceBandState.candidateFrames = 0`
- `EnduranceBandState.commitFrame = frame`

The confirmed log remains tied to a real stable-state assignment and is not a log-only transition.

```

## 0.5.33_NEUTRAL_RESOURCE_GATE_NAMING.md

- SHA-256: `CD17D9AE0A1BE3E08B2543D4D38CCD0CA3E14151A51D92734C08F981C3A1F70D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.33 Neutral Resource Gate Naming

BASELINE=0.5.32
FIX_SCOPE=AUDIT_BLOCKER_CLEANUP_ONLY

WHITE_VISUAL_STATE=DISABLED
ACTIVE_RESOURCE_GUARD_WHITE_NAME_HITS=ZERO
RESOURCE_GATE_BEHAVIOR=PRESERVED

Old active config names were replaced with neutral resource gate names:

- resource_gate_enabled
- resource_gate_hunger_soft
- resource_gate_hunger_hard
- resource_gate_calorie_floor
- resource_gate_resume_hunger
- resource_gate_resume_calorie
- resource_gate_locked_multiplier
- resource_gate_hard_stop_multiplier
- resource_gate_cancel_refund_when_locked
- resource_gate_cancel_hunger_when_locked
- resource_gate_preserve_color_when_locked

Behavior remains unchanged:

- Resource lock preserves current Green/Blue/Yellow/Red color.
- Resource lock forces refund to 0.
- Resource lock cancels extra hunger write.
- Resource lock does not restore White as a visual state.

```

## 0.5.33_PRESERVE_0.5.32_MECHANICS.md

- SHA-256: `97A6801861B9C13388162136150F42831DA2CD4E2C56194CC5CBFA3889DEE7BE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.33 Preserve 0.5.32 Mechanics

BASELINE=0.5.32
FIX_SCOPE=AUDIT_BLOCKER_CLEANUP_ONLY
NO_RETUNE=YES

Preserved from 0.5.32:

- Endurance-only four band color selection.
- Green/Blue/Yellow/Red states.
- White visual disabled.
- Green refund 0.
- Blue refund 0.28.
- Yellow refund 0.52.
- Red refund 0.70.
- Resource lock preserves color and cancels refund/hunger.
- Locomotion-only refund.
- Action/discrete cost no refund.
- Drag behavior unchanged.
- Walk No Impact.
- Controlled Jog Escape.
- JogBump / SprintVehicle / NativeTrip.
- No bite / no infection / no heal.
- No player position write.

CORE_MECHANICS=PRESERVED
DRAG_BEHAVIOR=UNCHANGED

```

## 0.5.33_STATUS_ICON_SOURCE_ENDURANCE_BAND.md

- SHA-256: `6AF3A82CE335F215ADC4EB0AD0D67BFA7B33DEC7D0C7C787DC7850BB115A4A86`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.33 Status Icon Source Endurance Band

BASELINE=0.5.32
FIX_SCOPE=AUDIT_BLOCKER_CLEANUP_ONLY

ICON_SOURCE=ENDURANCE_BAND
ACTIVE_ENDURANCE_CAPABILITY_SOURCE_HITS=ZERO

Ordinary stamina icon source logs are unified:

- GREEN_READY -> source=ENDURANCE_BAND
- BLUE_STAMINA_SUPPORT -> source=ENDURANCE_BAND
- YELLOW_LOW_STAMINA_SUPPORT -> source=ENDURANCE_BAND
- RED_EXHAUSTED_SUPPORT -> source=ENDURANCE_BAND

Capability diagnostics are not color selectors and are not logged as the source of ordinary stamina color.

```

## 0.5.33_TEST_PLAN.md

- SHA-256: `9618C1F366A6E57CD7A2766C58522B5977D3C85455D32F4689322A4192A4CA9E`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.33 Test Plan

1. Confirm console marker:
   `XNP_PZ_DISTANCE_TRAIT_0533_STATE_COMMIT_CONTRACT_CLEANUP_A`
2. Confirm ordinary stamina icon logs use `source=ENDURANCE_BAND`.
3. Confirm no active `ENDURANCE_CAPABILITY` source logs appear.
4. Drain endurance through Green -> Blue -> Yellow -> Red and confirm thresholds match 0.5.32.
5. Confirm `confirmed=true` commits once and logs `stateChangedThisTick=true`.
6. Confirm no same-tick candidate recreation after commit.
7. Trigger resource lock and confirm current color is preserved while refund and hunger writes are cancelled.
8. Confirm no White visual state appears.
9. Confirm drag, Walk No Impact, Controlled Jog Escape, JogBump, SprintVehicle, NativeTrip, ActionBus, and ImpactQuota feel unchanged.

```

## BUILD_MARKER.txt

- SHA-256: `7C751FCB46798190CA92E1D1016679038E7BED6240B6A549B57FB09BF4FE17C6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0533_STATE_COMMIT_CONTRACT_CLEANUP_A

```

## FINAL_REPORT.md

- SHA-256: `4AF8BBD7048F7E4AD8BEBB887CBF0257EB6663B3BEF781345F591B71F9B1D39D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.33
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0533_STATE_COMMIT_CONTRACT_CLEANUP_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.33 State Commit Contract Cleanup

Changed files:

- BUILD_MARKER.txt
- mod.info
- 42/mod.info
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua
- 42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_LongMigrationStaminaAssist.lua
- 0.5.33 documentation and reports

Four blocker cleanup:

- stateChangedThisTick explicit: YES
- stableState=candidateState explicit: YES
- ENDURANCE_CAPABILITY source removed: YES
- RESOURCE_GUARD_WHITE names removed: YES

Commit transaction:

- previous state preserved: YES
- stable state commits from candidate: YES
- candidate cleared: YES
- candidate frames reset: YES
- same tick recreate blocked: YES

Resource rename and runtime reads:

- Neutral resource_gate fields added: YES
- Runtime reads resource_gate_hunger_soft/hard/calorie/resume fields: YES
- Runtime reads resource_gate_enabled/cancel/preserve fields: YES
- Resource lock behavior preserved: YES

0.5.32 mechanics preserve:

- Endurance thresholds: unchanged
- Refund fractions: unchanged
- Hunger conversion: unchanged
- Drag files: unchanged
- Core collision/escape/trip modules: unchanged

No old SOURCE modification. No PZ/Steam launch. No mods/saves/Workshop/game directory write. No package/install.

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.33_SOURCE_READY_FOR_ENDURANCE_BAND_TEST

```

## 0.5.33_FIX_FROM_0.5.32_AUDIT.md

- SHA-256: `C9A6170F75EFF6AB923380C9375852289B8752B2CF9EE91C629D70108D438CB1`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.33 Fix From 0.5.32 Audit

BASELINE=0.5.32
FIX_SCOPE=AUDIT_BLOCKER_CLEANUP_ONLY

0.5.33 fixes only the 0.5.32 second-pass audit blockers:

- STATE_CHANGED_THIS_TICK=EXPLICIT
- STABLE_STATE_ASSIGNMENT=EXPLICIT
- CANDIDATE_CLEAR_AFTER_COMMIT=YES
- SAME_TICK_RECREATE=BLOCKED
- ICON_SOURCE=ENDURANCE_BAND
- ACTIVE_ENDURANCE_CAPABILITY_SOURCE_HITS=ZERO
- WHITE_VISUAL_STATE=DISABLED
- ACTIVE_RESOURCE_GUARD_WHITE_NAME_HITS=ZERO
- RESOURCE_GATE_BEHAVIOR=PRESERVED
- DRAG_BEHAVIOR=UNCHANGED
- CORE_MECHANICS=PRESERVED
- NO_RETUNE=YES

No endurance thresholds, refund fractions, hunger ratios, collision behavior, drag behavior, or core mechanics were retuned.

```

## 0.5.33_SECOND_PASS_AUDIT.md

- SHA-256: `A57E57F4727ACCF909A5958833309B4CACC061A039A6B1B7FD8661BBF4DB64E8`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ Distance Runner 0.5.33 Second Pass Audit

Audit command type: read-only audit.  
Code modification performed: NO.  
Only written file: `0.5.33_SECOND_PASS_AUDIT.md`.

## 1. Source And Version

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]

- SOURCE_EXISTS=YES
- BUILD_MARKER_OK=YES
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0533_STATE_COMMIT_CONTRACT_CLEANUP_A
- DISPLAY_NAME_OK=YES
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.33 State Commit Contract Cleanup
- FILE_COUNT_0532=64
- FILE_COUNT_0533=61
- LUA_COUNT_0533=46
- LARGE_COPY_DETECTED=NO
- OLD_ACTIVE_RESIDUE=PASS

Active Lua residue scan:

- `0.5.20~0.5.32`: 0 hits
- `0520~0532`: 0 hits
- `ENDURANCE_CAPABILITY`: 0 hits
- `CAPABILITY_CLASSIFIER`: 0 hits
- `RESOURCE_GUARD_WHITE`: 0 hits
- `resource_guard_white`: 0 hits
- `WHITE_RESOURCE_GUARD`: 0 hits
- `white_guard`: 0 hits

## 2. State Commit Contract

- STATE_CHANGED_THIS_TICK_EXPLICIT=YES
- STABLE_STATE_ASSIGNMENT_EXPLICIT=YES
- PREVIOUS_STATE_SAVED=YES
- CANDIDATE_CLEARED=YES
- CANDIDATE_FRAMES_RESET=YES
- SAME_TICK_RECREATE_BLOCKED=YES
- CONFIRMED_LOG_ONCE=PASS_STATIC
- STATE_COMMIT_STATUS=PASS_STATIC

Evidence in `XNP_DR_EnduranceBandState.lua`:

- `stateChangedThisTick = false` at state table and tick start.
- `EnduranceBandState.previousStableState = previousState`.
- `EnduranceBandState.stableState = EnduranceBandState.candidateState`.
- `EnduranceBandState.candidateState = nil`.
- `EnduranceBandState.candidateFrames = 0`.
- `EnduranceBandState.stateChangedThisTick = true`.
- same-tick guard logs `no_recreate_same_tick=true`.
- `confirmed=true` appears in the commit path after stable assignment.

No audit blocker found in state commit contract.

## 3. StatusIconUI Source

- ACTIVE_ENDURANCE_CAPABILITY_SOURCE_HITS=0
- GREEN_SOURCE_ENDURANCE_BAND=YES
- BLUE_SOURCE_ENDURANCE_BAND=YES
- YELLOW_SOURCE_ENDURANCE_BAND=YES
- RED_SOURCE_ENDURANCE_BAND=YES
- ICON_SOURCE_STATUS=PASS

Evidence in `XNP_DR_StatusIconUI.lua`:

- `[XNP STATUS ICON] color_source=ENDURANCE_BAND`
- `[XNP STAMINA ICON] state=GREEN_READY color=green source=ENDURANCE_BAND`
- `[XNP STAMINA ICON] state=BLUE_STAMINA_SUPPORT color=blue source=ENDURANCE_BAND`
- `[XNP STAMINA ICON] state=YELLOW_LOW_STAMINA_SUPPORT color=yellow source=ENDURANCE_BAND`
- `[XNP STAMINA ICON] state=RED_EXHAUSTED_SUPPORT color=red source=ENDURANCE_BAND`

No active `ENDURANCE_CAPABILITY` or `CAPABILITY_CLASSIFIER` hit was found.

## 4. Neutral Resource Gate Naming

- RESOURCE_GUARD_WHITE_HITS=0
- RESOURCE_GUARD_WHITE_LOWER_HITS=0
- WHITE_RESOURCE_GUARD_HITS=0
- WHITE_GUARD_HITS=0
- NEUTRAL_RESOURCE_NAMES_PRESENT=YES
- RUNTIME_READS_NEUTRAL_NAMES=YES
- COLOR_PRESERVED=YES
- REFUND_CANCELLED=YES
- HUNGER_CANCELLED=YES
- WHITE_VISUAL_DISABLED=YES
- RESOURCE_NAMING_STATUS=PASS

Neutral names present in Config:

- `resource_gate_enabled`
- `resource_gate_hunger_soft`
- `resource_gate_hunger_hard`
- `resource_gate_calorie_floor`
- `resource_gate_resume_hunger`
- `resource_gate_resume_calorie`
- `resource_gate_locke
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `2493BCD444F4B8622E185810FE35C55EFE692799C179D50C55C6988E1D409AFF`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_PATH=[LOCAL_PATH_REDACTED]
BASELINE=0.5.32
VERSION=0.5.33
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0533_STATE_COMMIT_CONTRACT_CLEANUP_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.33 State Commit Contract Cleanup

Required markers:

- FIX_SCOPE=AUDIT_BLOCKER_CLEANUP_ONLY
- STATE_CHANGED_THIS_TICK=EXPLICIT
- STABLE_STATE_ASSIGNMENT=EXPLICIT
- CANDIDATE_CLEAR_AFTER_COMMIT=YES
- SAME_TICK_RECREATE=BLOCKED
- ICON_SOURCE=ENDURANCE_BAND
- ACTIVE_ENDURANCE_CAPABILITY_SOURCE_HITS=ZERO
- WHITE_VISUAL_STATE=DISABLED
- ACTIVE_RESOURCE_GUARD_WHITE_NAME_HITS=ZERO
- RESOURCE_GATE_BEHAVIOR=PRESERVED
- DRAG_BEHAVIOR=UNCHANGED
- CORE_MECHANICS=PRESERVED
- NO_RETUNE=YES

Static checks:

- SOURCE exists: PASS
- Old SOURCE modified: NO
- Marker/display name: PASS
- Active old version residue: PASS
- Explicit `stateChangedThisTick`: PASS
- Explicit `stableState = candidateState`: PASS
- `candidateState = nil`: PASS
- `candidateFrames = 0`: PASS
- Same-tick recreate guard: PASS
- Confirmed log once per commit path: PASS_STATIC
- StatusIcon source=ENDURANCE_BAND: PASS
- Active ENDURANCE_CAPABILITY hits: 0
- Active RESOURCE_GUARD_WHITE hits: 0
- Active resource_guard_white hits: 0
- Active WHITE_RESOURCE_GUARD hits: 0
- Active white_guard hits: 0
- Runtime reads neutral resource_gate fields: PASS
- Runtime reads resource_gate_enabled: PASS
- Runtime reads resource_gate_hard_stop_multiplier: PASS
- Runtime reads resource_gate_cancel_refund_when_locked: PASS
- Runtime reads resource_gate_cancel_hunger_when_locked: PASS
- Runtime reads resource_gate_preserve_color_when_locked: PASS
- Resource lock preserve color / cancel refund / cancel hunger: PASS
- Four bands preserved: PASS
- Multipliers preserved: PASS
- Locomotion-only preserved: PASS
- Action/discrete refund blocked: PASS
- Drag unchanged: PASS
- Walk no impact / controlled escape / Jog/Sprint/NativeTrip preserved: PASS
- No bite/no infection/no heal: PASS
- No player position write: PASS

No PZ/Steam launch. No mods/saves/Workshop/game directory write. No packaging or install.

```
