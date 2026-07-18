# 0.5.31 Sanitized Evidence Excerpts

## 0.5.31_CAPABILITY_EVIDENCE_MODEL.md

- SHA-256: `987FA4FEF14635EE4D87DA0374D8193D8DB8BB807D23FB6AACB4690AD847212A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.31 Capability Evidence Model

Sprint capability fields:

- `sprint_capability_source`
- `sprint_capability_confidence`

Jog capability fields:

- `jog_capability_source`
- `jog_capability_confidence`

Expected logs:

- `[XNP CAPABILITY] sprint=true source=ENDURANCE_AND_SPEED confidence=...`
- `[XNP CAPABILITY] jog=true source=ENDURANCE_AND_RUN_INPUT confidence=...`

The capability model is used only for stamina color and stamina assist. It does not change MovementIntentGate, SprintVehicleImpact, JogBump, or NativeTrip decisions.


```

## 0.5.31_EARLY_STAMINA_ASSIST_BLUE_STAGE.md

- SHA-256: `F3950B27C9F960E765D8979EB962107FC54C1D015840E62BB0CFA3DD4FDCB5EB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.31 Early Stamina Assist Blue Stage

GREEN=ASSIST_IDLE_HIGH_RESERVE

BLUE=EARLY_ASSIST_ACTIVE_BEFORE_JOG_ONLY

YELLOW=JOG_ONLY_METABOLIC_SUPPORT

RED=EXHAUSTED_EMERGENCY_SUPPORT

WHITE=RESOURCE_GUARD

EARLY_ASSIST_BEFORE_MAJOR_ENDURANCE_LOSS=YES

GREEN_DOES_NOT_ALWAYS_REFILL=YES

BLUE_HAS_RUNTIME_ENDURANCE_WRITE=YES

Blue entry:

- endurance <= 0.90, or
- sustained running with negative trend

Blue assist:

- restore per tick: `0.0015`
- target max: `0.92`
- hunger multiplier: `0.20`
- max hunger per minute: `0.015`
- not while idle
- not while walking

Safety:

- NO_INFINITE_STAMINA=YES
- NO_INFINITE_SPRINT=YES
- Blue does not refill to 1.0
- Green does not actively refill endurance


```

## 0.5.31_ICON_DRAG_INPUT_RESTORE.md

- SHA-256: `181B8198A14C3B337FA6865CF3D23DC8122BE9AC80E1C39F66427609675A8851`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.31 Icon Drag Input Restore

ICON_INPUT_OWNER=SINGLE_ROOT_PANEL

COLOR_UPDATE_REUSES_PANEL=YES

TOOLTIP_MOUSE_TRANSPARENT=YES

The 0.5.31 route keeps one root status icon panel. The same panel owns:

- render texture
- tint/color
- tooltip hit test
- drag hit test
- onMouseDown
- onMouseMove
- onMouseUp
- right-click reset

New runtime guard:

`XNP_DR_StatusIconInputBindingGuard.lua`

Interfaces:

- `Bind(panel)`
- `Verify(panel)`
- `RebindIfMissing(panel)`
- `GetOwnerId(panel)`

Expected logs:

- `[XNP STATUS ICON INPUT] owner=SINGLE_ROOT_PANEL`
- `[XNP STATUS ICON INPUT] panel_identity=... callbacks_bound=true`
- `[XNP STATUS ICON INPUT] tooltip_mouse_transparent=true`
- `[XNP STATUS ICON INPUT] color_update_reuses_panel=true`
- `[XNP STATUS ICON INPUT] verify=true rebind=false`


```

## 0.5.31_PRESERVE_CORE_MECHANICS.md

- SHA-256: `E57C3C34FC2A2B794A7F9158CE3C1E3CD072EC8038EB9171134BA52342458563`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.31 Preserve Core Mechanics

CORE_MECHANICS_PRESERVED=YES

Preserved:

- Walk No Impact
- Controlled Jog Escape
- JogBump
- SprintVehicleImpact
- NativeTripWindow
- SprintTripConsequence
- Minor scrape safe boundary
- no bite rollback
- no infection rollback
- no heal
- no player coordinate write
- ImpactQuota / ActionBus
- existing shove, knockdown, kill, and dragdown feel
- Safe RGBA
- single right-top icon
- English tooltip
- danger red flash priority


```

## 0.5.31_REAL_GAME_FIX_FROM_0.5.30.md

- SHA-256: `C2D29A1B54AE5F876DF40FA77A5F14D77031A0C3497738A7B84672CA74F0F378`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.31 Real Game Fix From 0.5.30

BASELINE=0.5.30

DRAG_REFERENCE=0.5.29_WORKING_INPUT_CHAIN

0.5.30 real-game failures addressed:

- icon not draggable: fixed by root panel input ownership and callback guard
- always green: fixed by `BLUE_EARLY_ASSIST`
- writes_e=0 before jog-only: fixed by blue runtime endurance support
- candidate confirmed=false loop: fixed by persistent transition candidate timer

Preserved:

- 0.5.30 five-color design direction
- Safe RGBA
- single right-top icon
- English tooltip
- danger red flash priority
- impact, escape, trip, dragdown, and kill feel


```

## 0.5.31_SINGLE_PANEL_INPUT_OWNER.md

- SHA-256: `0A2D6A87DEA9E507DCECA064132974597E0184FA2E868332C7746EBF1E2DBC8B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.31 Single Panel Input Owner

ICON_INPUT_OWNER=SINGLE_ROOT_PANEL

No second main icon panel is created.

Status icon color updates reuse the existing panel and only change:

- state
- color tint
- tooltip text

The root panel consumes mouse events so `onMouseDown`, `onMouseMove`, `onMouseUp`, and `onRightMouseUp` remain reachable.

Tooltip is rendered inside the same panel and does not create an input-owning overlay.


```

## 0.5.31_STATE_TRANSITION_CONFIRM_FIX.md

- SHA-256: `2A991CB3D13B40498BA513493DB1249CBD978E5C9EEC5A0A86EBFB1BFC69738D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.31 State Transition Confirm Fix

Candidate transition persistence:

- `STATE_TRANSITION_CONFIRM_FRAMES=30`
- `STATE_TRANSITION_CANDIDATE_PERSISTS=true`
- `STATE_TRANSITION_RESET_ONLY_ON_CANDIDATE_CHANGE=true`
- `STATE_TRANSITION_TRANSIENT_PAUSE_NOT_RESET=true`

The candidate timer is stored in `XNP_DR_EnduranceCapabilityState.lua`.

It resets only when the candidate state changes, not every frame.

Expected logs:

- `[XNP ENDURANCE TRANSITION] candidate=BLUE_EARLY_ASSIST start_frame=...`
- `[XNP ENDURANCE TRANSITION] from=GREEN_READY to=BLUE_EARLY_ASSIST confirmed=true`
- `[XNP ENDURANCE TRANSITION] transient_pause=true timer_preserved=true`


```

## 0.5.31_TEST_PLAN.md

- SHA-256: `3BDF38271E170F81BBF975C3D1EE1E49B8F582BFE6F45FA9C72AD4DD24F31BC8`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.31 Test Plan

Expected load logs:

- `[XNP DR] BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0531_EARLY_STAMINA_ASSIST_DRAG_RESTORE_A`
- `[XNP DistanceRunner] loaded version=0.5.31`
- `[XNP STATUS ICON INPUT] owner=SINGLE_ROOT_PANEL`
- `[XNP EARLY STAMINA ASSIST] enabled=true`

Drag test:

- click and drag the icon
- expect hit_test, begin, move, end, saved logs
- drag quickly
- release outside icon bounds
- right-click reset

Stamina test:

- high reserve: GREEN_READY, writes_e=0, writes_h=0
- sustained running before jog-only: BLUE_EARLY_ASSIST and writes_e > 0
- lower endurance: YELLOW_JOG_ONLY
- exhausted: RED_EXHAUSTED
- low food reserve: WHITE_RESOURCE_GUARD

Regression checks:

- walking does not get impact or stamina assist
- controlled jog escape still works
- jog bump still works
- sprint vehicle impact still works
- native trip still works
- no bite / no infection / no heal rollback
- no player coordinate write


```

## BUILD_MARKER.txt

- SHA-256: `47FA8BA3C574E74A415720AA149279335BFF1312406761C82D69604B266FDDE8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0531_EARLY_STAMINA_ASSIST_DRAG_RESTORE_A

```

## FINAL_REPORT.md

- SHA-256: `7BCE84B2A43C42FB3D240A5D6B183DCBAD881E5A8E6B1C239CA9E25640091AB8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.31

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0531_EARLY_STAMINA_ASSIST_DRAG_RESTORE_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.31 Early Stamina Assist Drag Restore

FILE_COUNT=62

LUA_COUNT=45

LUA_LINES=9891

## 0.5.30 Real Game Issues

ICON_NOT_DRAGGABLE=FIXED

ALWAYS_GREEN=FIXED

WRITES_E_ZERO_BEFORE_JOG_ONLY=FIXED

CANDIDATE_CONFIRMED_FALSE_LOOP=FIXED

## Drag

0.5.29_CALLBACK_CHAIN_RESTORED=YES

SINGLE_ROOT_INPUT_OWNER=YES

TOOLTIP_TRANSPARENT=YES

COLOR_UPDATE_REUSES_PANEL=YES

CAPTURE_RELEASE_ANYWHERE=YES

SAVE_LOAD_RESET=YES

## Stamina

GREEN_ASSIST_IDLE=YES

BLUE_EARLY_ASSIST_RUNTIME=YES

BLUE_ENTRY_THRESHOLD=0.90

BLUE_WRITES_ENDURANCE=YES

BLUE_HUNGER_MULTIPLIER=0.20

YELLOW_PRESERVED=YES

RED_PRESERVED=YES

WHITE_GUARD_PRESERVED=YES

NO_FULL_RESTORE=YES

NO_INFINITE_SPRINT=YES

## Transition

CANDIDATE_PERSISTS=YES

TIMER_RESET_ONLY_ON_STATE_CHANGE=YES

TRANSIENT_PAUSE_PRESERVES_TIMER=YES

## Preserve

WALK_NO_IMPACT=YES

CONTROLLED_JOG_ESCAPE=YES

JOG_BUMP=YES

SPRINT_VEHICLE=YES

NATIVE_TRIP=YES

DRAG_DANGER_FLASH=YES

NO_BITE_NO_INFECTION_NO_HEAL=YES

NO_POSITION_WRITE=YES

## Restrictions

OLD_SOURCE_MODIFIED=NO

PROJECT_ZOMBOID_LAUNCHED=NO

STEAM_LAUNCHED=NO

USER_MODS_WRITTEN=NO

SAVES_WRITTEN=NO

WORKSHOP_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

PACKAGED_OR_INSTALLED=NO

ACTIVE_LUA_OLD_RESIDUE=0

RUNTIME_FORBIDDEN_HITS=0

LUA_EXECUTION_SYNTAX_CHECK=NOT_VERIFIABLE_LOCAL_LUA_NOT_AVAILABLE

FINAL_STATUS:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.31_SOURCE_READY_FOR_EARLY_ASSIST_DRAG_TEST

```

## 0.5.31_SECOND_PASS_AUDIT.md

- SHA-256: `E62C4E2C6DE656DB0E0369181BE5BB63BE01E5FB14563215A7828CF78A56F3CC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.31 Second Pass Audit

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]

AUDIT_TYPE=READ_ONLY_SECOND_PASS

ALLOWED_WRITE=0.5.31_SECOND_PASS_AUDIT.md

PROJECT_ZOMBOID_LAUNCHED=NO

STEAM_LAUNCHED=NO

USER_MODS_WRITTEN=NO

SAVES_WRITTEN=NO

WORKSHOP_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

PACKAGED_OR_INSTALLED=NO

OLD_SOURCE_MODIFIED=NO

## 1. Version And File Audit

SOURCE_EXISTS=YES

BUILD_MARKER_OK=YES

EXPECTED_BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0531_EARLY_STAMINA_ASSIST_DRAG_RESTORE_A

DISPLAY_NAME_OK=YES

EXPECTED_DISPLAY_NAME=XNP Distance Runner Trait 0.5.31 Early Stamina Assist Drag Restore

FILE_COUNT_0530=62

FILE_COUNT_0531=62

LUA_COUNT_0531=45

LUA_LINES_0531=9891

LARGE_COPY_DETECTED=NO

OLD_ACTIVE_RESIDUE=PASS

ACTIVE_LUA_OLD_VERSION_HITS=0

## 2. Drag Input Audit

DRAG_MODULE_RUNTIME=YES

WORKING_CALLBACK_CHAIN_RESTORED=YES

0.5.29 drag module and 0.5.30 drag module have no direct file diff. 0.5.31 keeps that drag module and adds a root-panel input binding guard.

SINGLE_ROOT_INPUT_OWNER=YES

TOOLTIP_TRANSPARENT=YES_WITH_DYNAMIC_LOG

OVERLAY_TRANSPARENT=YES_NO_SEPARATE_INPUT_OVERLAY

COLOR_REUSES_PANEL=YES_WITH_DYNAMIC_LOG

MOUSE_DOWN=YES

MOUSE_MOVE=YES

MOUSE_UP=YES

RIGHT_CLICK_RESET=YES

CAPTURE=YES

RELEASE_ANYWHERE=YES

FULL_SCREEN_CLAMP=YES

SAVE_LOAD_RESET=YES

BINDING_GUARD=YES

DRAG_STATUS=RISK_TEST_ALLOWED

Notes:

- `onMouseDown`, `onMouseMove`, `onMouseUp`, and `onRightMouseUp` exist on the root panel.
- `XNP_DR_StatusIconInputBindingGuard.lua` exists and is required by runtime.
- The literal strings `callbacks_bound=true`, `tooltip_mouse_transparent=true`, and `color_update_reuses_panel=true` are not static literals; the code logs those values dynamically with `tostring(...)`.
- This is a static log-string risk, not evidence of a missing callback route.

## 3. Early Blue Assist Audit

GREEN_ASSIST_IDLE=YES

BLUE_STATE_PRESENT=YES

BLUE_RUNTIME=YES

BLUE_BEFORE_JOG_ONLY=YES

BLUE_ENTRY_THRESHOLD=0.90

BLUE_ENDURANCE_WRITE=YES

BLUE_HUNGER_MULTIPLIER=0.20

BLUE_TARGET_CAP=0.92

BLUE_NOT_IDLE=YES

BLUE_NOT_WALKING=YES

BLUE_NOT_DURING_ESCAPE_IMPACT=YES

NO_FULL_RESTORE=YES

NO_INFINITE_SPRINT=YES

YELLOW_PRESERVED=YES

RED_PRESERVED=YES

WHITE_PRESERVED=YES

EARLY_ASSIST_STATUS=PASS

Evidence:

- `BLUE_EARLY_ASSIST` runtime hits: present.
- `SetEnduranceSafe` runtime write path exists.
- `endurance_before=` and `endurance_after=` log strings exist.
- blue target max config exists and is 0.92.
- blue hunger multiplier config exists and is 0.20.
- idle/walking blocks exist.

## 4. Transition Audit

CANDIDATE_PERSISTS=YES

TIMER_ACCUMULATES=YES

RESET_ONLY_ON_CHANGE=YES

TRANSIENT_PAUSE_PRESERVES=YES

CONFIRM_PATH=YES

NO_CONFIRMED_FALSE_SPAM=RISK_STATIC_LITERAL_PRESENT

TRANSITION_STATUS=RISK_TEST_ALLOWED

Evidence:

- `candidateState` storage exists.
- `candidateFrames` storage exists.
- `STATE_TRANSITION_CANDIDATE_PERSISTS` config exists.
- `STATE_TRANSITION_RESET_ONLY_ON_CANDIDATE_CHANGE` config exists.
- `transient_pause=true time
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `D93171A95D93F87A00E07EAE6DDB1150AF866A4F42466685ABEC7510C52A95C3`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE=[LOCAL_PATH_REDACTED]

BASELINE=0.5.30

DRAG_REFERENCE=0.5.29_WORKING_INPUT_CHAIN

OLD_SOURCE_MODIFIED=NO

VERSION=0.5.31

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0531_EARLY_STAMINA_ASSIST_DRAG_RESTORE_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.31 Early Stamina Assist Drag Restore

FILE_COUNT=62

LUA_COUNT=45

LUA_LINES=9891

ACTIVE_RUNTIME_LUA_COUNT=44

ACTIVE_LUA_OLD_RESIDUE=0

RUNTIME_FORBIDDEN_HITS=0

LUA_EXECUTION_SYNTAX_CHECK=NOT_VERIFIABLE_LOCAL_LUA_NOT_AVAILABLE

## Drag Input

DRAG_CALLBACK_DIFF_0529_TO_0530=NO_DIFF_IN_DRAG_MODULE

INPUT_BINDING_GUARD_RUNTIME=YES

SINGLE_ROOT_PANEL_INPUT_OWNER=YES

TOOLTIP_MOUSE_TRANSPARENT=YES

COLOR_UPDATE_REUSES_PANEL=YES

ON_MOUSE_DOWN=YES

ON_MOUSE_MOVE=YES

ON_MOUSE_UP=YES

DRAG_CAPTURE_RELEASE_ANYWHERE=YES

SAVE_LOAD_RESET=YES

PANEL_RECREATE_ON_COLOR_UPDATE=NO

SECOND_MAIN_ICON=NO

## Early Assist

EARLY_ASSIST_RUNTIME=YES

BLUE_EARLY_ASSIST_RUNTIME=YES

BLUE_ENDURANCE_WRITE_RUNTIME=YES

BLUE_HUNGER_LOW_MULTIPLIER=0.20

GREEN_ASSIST_IDLE=YES

BLUE_TARGET_MAX=0.92

BLUE_NOT_WHILE_IDLE=YES

BLUE_NOT_WHILE_WALKING=YES

BLUE_NOT_DURING_CONTROLLED_ESCAPE=YES

BLUE_NOT_DURING_VEHICLE_IMPACT=YES

NO_FULL_RESTORE=YES

NO_INFINITE_SPRINT=YES

## Transition

CANDIDATE_PERSISTS=YES

TIMER_RESET_ONLY_ON_STATE_CHANGE=YES

TRANSIENT_PAUSE_PRESERVES_TIMER=YES

STATE_TRANSITION_CONFIRM_FRAMES=30

## Capability

CAPABILITY_MULTI_EVIDENCE=YES

SPRINT_CAPABILITY_SOURCE=YES

JOG_CAPABILITY_SOURCE=YES

SPRINT_CAPABILITY_CONFIDENCE=YES

JOG_CAPABILITY_CONFIDENCE=YES

## Preserve

NO_CHANGE_TO_IMPACT_ESCAPE_CORE=YES

SAFE_RGBA=YES

PROGRESS_YELLOW_ACTIVE_HITS=0

WALK_NO_IMPACT_PRESERVED=YES

CONTROLLED_JOG_ESCAPE_PRESERVED=YES

JOG_BUMP_PRESERVED=YES

SPRINT_VEHICLE_PRESERVED=YES

NATIVE_TRIP_PRESERVED=YES

NO_BITE_NO_INFECTION_NO_HEAL=YES

NO_PLAYER_COORDINATE_WRITE=YES

LOG_SUMMARY_PATHS=YES

BLOCKER=NONE


```
