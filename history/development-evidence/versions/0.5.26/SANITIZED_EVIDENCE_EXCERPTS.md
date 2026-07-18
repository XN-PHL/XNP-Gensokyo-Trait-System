# 0.5.26 Sanitized Evidence Excerpts

## 0.5.26_CONTROLLED_JOG_ESCAPE_PRESERVE.md

- SHA-256: `0E47F6A1ECB9720D8044BF0CAED7D2881166D09E02ED2C757FACDDCEC39720E2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Controlled Jog Escape Preserve

CONTROLLED_ESCAPE_STATUS=PRESERVED_RUN_OR_SPRINT_INPUT_REQUIRED
NO_BITE_NO_INFECTION_NO_HEAL=PRESERVED

Controlled escape requirements:

- Controlled/getup/onFloor/bumped/grab/attack/dragdown state or classifier danger.
- Run or sprint input, including recent input via EmergencyInput.
- Local radius: 1.25.
- Max targets: 2.
- Skill active quota remains in effect.

Preserved routes:

- FallRecoveryInput
- EmergencyBreakout
- DragdownDangerBreakout
- BreakoutPush GRAB/CROWD only after controlled escape gate

Logs:

- [XNP CONTROLLED ESCAPE] enabled=true
- [XNP CONTROLLED ESCAPE] input=RUN_OR_SPRINT state=CONTROLLED result=ALLOW
- [XNP CONTROLLED ESCAPE] target zombie=... reason=CONTROLLED_OR_TOUCHING dist=...
- [XNP CONTROLLED ESCAPE] effect=STAGGER_OR_KNOCKDOWN
- [XNP CONTROLLED ESCAPE] no_bite=true no_infection=true no_heal=true

```

## 0.5.26_JOG_AND_SPRINT_PRESERVE.md

- SHA-256: `162C155FBDB8FECC6281117A58AE7DF6F9324E7C0786C4D80E4303EE99E3E49C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Jog And Sprint Preserve

JOG_STATUS=PRESERVED_WHEN_JOGGING
SPRINT_STATUS=PRESERVED_NON_100_PERCENT_KILL_ALLOWED

Preserved:

- Jog bump when MovementIntentGate returns JOG_INTENT.
- Jog quota and overflow native trip/shockwave.
- SprintVehicleImpact when MovementIntentGate returns SPRINT_INTENT.
- NativeTripWindow.
- Sprint trip consequence kill max 3 and rest knockdown/stun.
- Sprint non-100-percent-kill behavior.
- Drag capture and English tooltip.

Changed:

- Walking/movement no longer reaches JOG_BUMP, CONTACT, or sprint vehicle impact.

```

## 0.5.26_LOG_THROTTLE_CLEANUP.md

- SHA-256: `FE2C1027FBD3C70E435932E3371FC59040D3ABC01EABB4C87D05F11FE0CFEB7D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Log Throttle Cleanup

LOG_THROTTLE_STATUS=LIGHT_CLEANUP_ONLY

Added or preserved summary logs:

- [XNP MOVEMENT GATE SUMMARY] every 60 frames.
- [XNP ACTION BUS SUMMARY] includes movement_gate_blocked.
- [XNP IMPACT QUOTA SUMMARY] includes movement_gate_blocked.
- [XNP STATUS ICON DRAG] full_screen_clamp and anchor_override now log on position/screen change, active drag, or throttle interval.

No gameplay behavior depends on log throttle.

```

## 0.5.26_MOVEMENT_INTENT_GATE_DESIGN.md

- SHA-256: `557FA197F3B98BB6BCE5F5A8BACE121764ED5B36418EB9D4BDB4703FAB9A970A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Movement Intent Gate Design

MOVEMENT_GATE_MODULE=XNP_DR_MovementIntentGate.lua
RUNTIME_CONNECTED=YES

Intents:

- WALK_IDLE_OR_MOVEMENT: blocks active impact.
- JOG_INTENT: allows JOG_BUMP and CONTACT.
- SPRINT_INTENT: allows SPRINT_VEHICLE and sprint precollision.
- CONTROLLED_ESCAPE_INTENT: allows recovery/emergency/dragdown/grab escape only with control state plus run/sprint input.

Public API:

- MovementIntentGate.GetIntent(player, context)
- MovementIntentGate.CanJogBump(player, context)
- MovementIntentGate.CanContactPush(player, context)
- MovementIntentGate.CanSprintVehicle(player, context)
- MovementIntentGate.CanControlledEscape(player, context)
- MovementIntentGate.BlockReason(player, context)

Important logs:

- [XNP MOVEMENT GATE] intent=WALK_IDLE_OR_MOVEMENT movement=... result=BLOCK_ACTIVE_IMPACT
- [XNP MOVEMENT GATE] block source=JOG_BUMP reason=WALKING_NOT_JOGGING
- [XNP MOVEMENT GATE] intent=JOG_INTENT result=ALLOW_JOG_BUMP
- [XNP MOVEMENT GATE] intent=SPRINT_INTENT result=ALLOW_SPRINT_VEHICLE
- [XNP MOVEMENT GATE] intent=CONTROLLED_ESCAPE_INTENT result=ALLOW_ESCAPE reason=CONTROLLED_OR_TOUCHING input=RUN_OR_SPRINT
- [XNP MOVEMENT GATE SUMMARY] walk_blocked=... jog_allowed=... sprint_allowed=... escape_allowed=... window_frames=60

```

## 0.5.26_REAL_GAME_TUNING_FROM_0.5.25.md

- SHA-256: `76565D6EA2F5A2AEC12FA6E7148B3513144426CCA74CE678928CBA2DE2FA7AE8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Real Game Tuning From 0.5.25

SOURCE_BASELINE=0.5.25
WALK_STATUS=NO_ACTIVE_IMPACT
JOG_STATUS=PRESERVED_WHEN_JOGGING
SPRINT_STATUS=PRESERVED_NON_100_PERCENT_KILL_ALLOWED
CONTROLLED_ESCAPE_STATUS=PRESERVED_RUN_OR_SPRINT_INPUT_REQUIRED
DRAG_ICON_STATUS=PRESERVED
NO_BITE_NO_INFECTION_NO_HEAL=PRESERVED

0.5.25 real-game feedback accepted:

- Activation works.
- Drag capture works.
- Jog impact is useful and should stay when the player is actually jogging.
- Sprint impact and native trip window are useful and should stay.
- Sprint not being 100 percent lethal is acceptable.
- Walking causing active zombie stagger/knockdown is too strong and must be blocked.
- Controlled/getup/fall/grab recovery with run or sprint input must stay.

0.5.26 targeted fix:

- Add MovementIntentGate.
- Block walking from JOG_BUMP, CONTACT, BREAKOUT_CONTACT, and SPRINT_VEHICLE before ActionBus, quota, cost, or effect.
- Preserve controlled escape only when control state and run/sprint input are both present.

```

## 0.5.26_TEST_PLAN.md

- SHA-256: `2CF05C0DEB272EC0E5472E9B09759AF2070BF88F2AAF26B487E1B5635801A33F`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.26 Test Plan

1. Search source for `XNP_PZ_DISTANCE_TRAIT_0526_WALK_NO_IMPACT_CONTROLLED_JOG_ESCAPE_A`.
2. Load mod and confirm:
   - [XNP DR] BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0526_WALK_NO_IMPACT_CONTROLLED_JOG_ESCAPE_A
   - [XNP ACTIVATION] active=true
   - [XNP RUNTIME] module=MovementIntentGate loaded=true
   - [XNP MOVEMENT GATE] enabled=true
   - [XNP WALK NO IMPACT] enabled=true
3. Walk into zombies:
   - no stagger, knockdown, cost, quota, JOG_BUMP accepted, or CONTACT trigger.
4. Jog into zombies:
   - 0.5.25 JOG_BUMP behavior remains.
5. Sprint into zombies:
   - 0.5.25 SprintVehicleImpact and NativeTripWindow behavior remains.
6. Get grabbed/controlled and press run/sprint:
   - controlled escape applies to close controlling zombies only.
   - no bite/infection/heal rollback occurs.

```

## BUILD_MARKER.txt

- SHA-256: `B7EF707F424DBADDA2605620F21A5F828F59BB1E83EB9816AF8EBADCE24A93E0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0526_WALK_NO_IMPACT_CONTROLLED_JOG_ESCAPE_A

```

## FINAL_REPORT.md

- SHA-256: `21529B51CBB29E1D60961A703E03F6E9679E56E8BEE93B234D2229873E99A4FC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.26
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0526_WALK_NO_IMPACT_CONTROLLED_JOG_ESCAPE_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.26 Walk No Impact Controlled Jog Escape

## Changed Files

- `BUILD_MARKER.txt`
- `mod.info`
- `42\mod.info`
- `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua`
- `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Config.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_MovementIntentGate.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_JogBumpLaunch.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutActionBus.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactQuotaMeter.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_SprintVehicleImpact.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FallRecoveryInput.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerBreakout.lua`
- `42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DraggableStatusIcon.lua`
- `0.5.26_REAL_GAME_TUNING_FROM_0.5.25.md`
- `0.5.26_MOVEMENT_INTENT_GATE_DESIGN.md`
- `0.5.26_WALK_NO_IMPACT_AUDIT.md`
- `0.5.26_CONTROLLED_JOG_ESCAPE_PRESERVE.md`
- `0.5.26_JOG_AND_SPRINT_PRESERVE.md`
- `0.5.26_LOG_THROTTLE_CLEANUP.md`
- `0.5.26_TEST_PLAN.md`
- `STATIC_AUDIT.md`
- `FINAL_REPORT.md`

## 0.5.25 Feedback Handling

- Jog trigger good: PRESERVED
- Sprint trigger good: PRESERVED
- Sprint non-100-percent kill: PRESERVED
- Walking zombie push/knockdown: FIXED_STATIC_GATE
- Controlled jog push while grabbed: PRESERVED

## MovementIntentGate

- runtime: YES
- walk blocks contact: YES
- walk blocks jog bump: YES
- walk blocks vehicle impact: YES
- controlled escape exception: YES

## Walk No Impact

- movement=movement JOG_BUMP accepted possible: NO_STATIC_PATH_AFTER_GATE
- movement=movement CONTACT trigger possible: NO_STATIC_PATH_AFTER_GATE
- walking action counted quota: NO_STATIC_PATH_AFTER_GATE
- walking action charged cost: NO_STATIC_PATH_AFTER_GATE

## Controlled Escape

- requires control state: YES
- requires run/sprint input: YES
- radius: 1.25
- max targets: 2
- no bite/no infection/no heal: YES

## Preserve

- jog bump preserved: YES
- sprint vehicle preserved: YES
- native trip preserved: YES
- drag capture preserved: YES

## Forbidden Grep

Forbidden route grep: PASS
Player coordinate write grep: PASS
Healing / bite rollback route grep: PASS

Expected preserved non-player hits:

- zombie-side `setKnockedDown(true)`
- zombie death route `setHealth(0)` for sprint vehicle / sprint trip consequence
- controlled recovery `player:setKnockedDown(false)`

## Environment

Modified old SOURCE: NO
Launched Project Zomboid: NO
Launched Ste
[EXCERPT_TRUNCATED]
```

## 0.5.26_SECOND_PASS_AUDIT.md

- SHA-256: `51458A731A42A00E0473FB6F6203E2B7B6CB4D9F3D267F3257F2304D8CE8633C`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Second Pass Audit

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]
AUDIT_MODE=STATIC_READ_ONLY_WITH_REPORT
PROJECT_ZOMBOID_LAUNCHED=NO
STEAM_LAUNCHED=NO
USER_MODS_WRITTEN=NO
SAVES_WRITTEN=NO
WORKSHOP_WRITTEN=NO
GAME_DIRECTORY_WRITTEN=NO
RUNTIME_CODE_MODIFIED=NO
PACKAGE_BUILT=NO

## Version And File Count

SOURCE_EXISTS=YES
BUILD_MARKER_OK=YES
DISPLAY_NAME_OK=YES
READY_MARKER_PRESENT=YES

Expected marker:

`XNP_PZ_DISTANCE_TRAIT_0526_WALK_NO_IMPACT_CONTROLLED_JOG_ESCAPE_A`

Expected READY:

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.26_SOURCE_READY_FOR_WALK_GATE_TEST`

VERSION_FILE_STATUS=PASS
OLD_ACTIVE_RESIDUE=NO_ACTIVE_RUNTIME_RESIDUE
FILE_COUNT_0525=53
FILE_COUNT_0526=53
LUA_COUNT_0526=37
MARKDOWN_COUNT_0526=10_AFTER_THIS_REPORT
LARGE_COPY_DETECTED=NO

Notes:

- Active Lua and `mod.info` use 0.5.26 identity.
- 0.5.25 strings remain only as baseline/history references in Markdown.
- No 150+ file risk, no 300+ or 1000+ file blocker.

## MovementIntentGate Audit

MOVEMENT_GATE_FILE=YES
MOVEMENT_GATE_RUNTIME=YES
MOVEMENT_GATE_CONFIG=YES
MOVEMENT_GATE_INTERFACES=YES
MOVEMENT_GATE_STATUS=PASS

Confirmed:

- `XNP_DR_MovementIntentGate.lua` exists.
- `XNP_DR_Bootstrap.lua` requires it and logs `module=MovementIntentGate loaded=...`.
- `XNP_DR_Runtime.lua` requires it and calls `MovementIntentGate.SummaryTick()`.
- Config contains:
  - `movement_intent_gate_enabled = true`
  - `walk_no_impact_enabled = true`
  - `walk_blocks_contact = true`
  - `walk_blocks_jog_bump = true`
  - `walk_blocks_breakout_contact = true`
  - `walk_blocks_vehicle_impact = true`
  - `walk_allows_controlled_escape = true`
- Interfaces exist:
  - `GetIntent`
  - `CanJogBump`
  - `CanContactPush`
  - `CanSprintVehicle`
  - `CanControlledEscape`
- Logs exist for:
  - `[XNP MOVEMENT GATE]`
  - `intent=WALK_IDLE_OR_MOVEMENT`
  - `result=BLOCK_ACTIVE_IMPACT`
  - `intent=CONTROLLED_ESCAPE_INTENT`

## Walk No Impact Audit

JOG_BUMP_GATE_BEFORE_ACCEPT=YES
CONTACT_GATE_BEFORE_COST=YES
VEHICLE_GATE=YES
WALK_NOT_COUNTED_QUOTA=YES
WALK_NO_COST=YES
WALK_NO_EFFECT=YES
WALK_NO_IMPACT_STATUS=PASS_STATIC_WITH_RUNTIME_RISK

Confirmed order:

- `XNP_DR_JogBumpLaunch.lua` calls `CanJogBump` before target collection result reaches `BreakoutActionBus.Accept`, `ImpactQuotaMeter.Try("JOG_BUMP")`, endurance cost, or `VerifiedStaggerControl.Apply`.
- `XNP_DR_BreakoutPush.lua` calls `CanContactPush` inside `contactGate` before CONTACT trigger, ActionBus accept, cost, or push profile.
- `XNP_DR_BreakoutPush.lua` calls `CanSprintVehicle` before returning `SPRINT_PRECOLLISION`.
- `XNP_DR_SprintVehicleImpact.lua` calls `CanSprintVehicle` before ActionBus accept, quota, cost, or zombie effect.
- `BreakoutActionBus.BlockMovementGate` logs blocked walk actions.
- `ImpactQuotaMeter.BlockedNotCounted` logs `not_counted=true`.

Expected walking block logs exist:

- `WALKING_NOT_JOGGING`
- `no_cost=true`
- `no_effect=true`
- `not_counted=true`

Static caveat:

- Preserved jog/sprint code still contains `accepted source=JOG_BUMP`
[EXCERPT_TRUNCATED]
```

## 0.5.26_WALK_NO_IMPACT_AUDIT.md

- SHA-256: `1929F9CE0FB550A877FB362CC73D50B1E3A698EEE8248D5832CF54E501D3E3E5`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Walk No Impact Audit

WALK_STATUS=NO_ACTIVE_IMPACT

Implemented blocks:

- JOG_BUMP calls MovementIntentGate.CanJogBump before target collection, ActionBus, quota, cost, or effect.
- BreakoutPush CONTACT calls MovementIntentGate.CanContactPush before contact trigger.
- SprintVehicleImpact calls MovementIntentGate.CanSprintVehicle before target collection, ActionBus, quota, cost, or effect.
- BreakoutActionBus exposes BlockMovementGate for blocked logs.
- ImpactQuotaMeter exposes BlockedNotCounted for not-counted walk blocks.

Expected walking logs:

- [XNP CONTACT GATE] state=BLOCKED reason=WALKING_NOT_JOGGING
- [XNP JOG BUMP] blocked reason=WALKING_NOT_JOGGING
- [XNP ACTION BUS] blocked source=JOG_BUMP reason=WALKING_NOT_JOGGING
- [XNP IMPACT QUOTA] blocked mode=JOG_BUMP reason=WALKING_NOT_JOGGING not_counted=true
- [XNP BREAKOUT] blocked reason=WALKING_NOT_JOGGING no_cost=true no_effect=true

Forbidden walking outcomes:

- accepted source=JOG_BUMP
- JOG_BUMP trigger
- CONTACT trigger
- STAGGER_CONTROL visible_effect from walking
- quota counted
- stamina cost charged

```

## STATIC_AUDIT.md

- SHA-256: `6C7823659596EE9EBAE76C672B1EE6492BD643EA2F6A74E3909D488710BCE1F7`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.26 Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
BASELINE_SOURCE=[LOCAL_PATH_REDACTED]
OLD_SOURCE_MODIFIED=NO
VERSION=0.5.26
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0526_WALK_NO_IMPACT_CONTROLLED_JOG_ESCAPE_A

## File Count

TOTAL_FILES=53
LUA_FILES=37
LUA_TOTAL_LINES=8494
DOCUMENT_FILES=9
LARGE_COPY_POLLUTION=NO

## 0.5.25 Feedback Handling

- Jog trigger good: PRESERVED.
- Sprint trigger good: PRESERVED.
- Sprint non-100-percent kill: PRESERVED.
- Walking zombie push/knockdown: BLOCKED_BY_MOVEMENT_INTENT_GATE.
- Controlled jog/sprint escape while grabbed/controlled: PRESERVED_WITH_GATE.

## Grep Audit

Active old version residue:

- Runtime identity updated to 0.5.26.
- Remaining 0.5.25 mentions are baseline/tuning references in 0.5.26 documentation only.

Forbidden route grep:

- `setVariable("bumped"`: PASS
- `setVariable('bumped'`: PASS
- `player:hasTrait(`: PASS
- `TraitFactory`: PASS
- `CharacterTraitDefinition`: PASS
- `RunningShove`: PASS
- `BumpedState`: PASS
- `GameTime:setMultiplier`: PASS
- `HaloTextHelper`: PASS
- `player:Say`: PASS
- `player:setX/setY/setZ`: PASS

Expected non-blocking hits:

- `zombie:setKnockedDown(true)` remains zombie-side stagger/knockdown only.
- `zombie:setHealth(0)` remains sprint vehicle / sprint trip consequence zombie death route.
- `player:setKnockedDown(false)` remains controlled recovery/cancel route only.

## MovementIntentGate Checks

MovementIntentGate module grep: PASS
Runtime module load grep: PASS
JOG_BUMP gate grep: PASS
CONTACT gate grep: PASS
BreakoutPush gate grep: PASS
ImpactQuota WALK blocked not counted grep: PASS
ActionBus WALKING_NOT_JOGGING block grep: PASS
Controlled escape gate grep: PASS
controlled_escape_requires_control_state grep: PASS
controlled_escape_requires_run_or_sprint_input grep: PASS
FallRecovery RUN_OR_SPRINT preserve grep: PASS
Emergency/Dragdown controlled escape preserve grep: PASS

Specific wiring:

- `XNP_DR_JogBumpLaunch.lua` calls `MovementIntentGate.CanJogBump` before collect, ActionBus, quota, cost, or effect.
- `XNP_DR_BreakoutPush.lua` calls `MovementIntentGate.CanContactPush` before CONTACT trigger.
- `XNP_DR_BreakoutPush.lua` calls `MovementIntentGate.CanSprintVehicle` before SPRINT_PRECOLLISION.
- `XNP_DR_BreakoutPush.lua` calls `MovementIntentGate.CanControlledEscape` before GRAB/CROWD triggers.
- `XNP_DR_SprintVehicleImpact.lua` calls `MovementIntentGate.CanSprintVehicle` before collect, ActionBus, quota, cost, or effect.
- `XNP_DR_FallRecoveryInput.lua`, `XNP_DR_EmergencyBreakout.lua`, and `XNP_DR_DragdownDangerBreakout.lua` call `CanControlledEscape`.

## Walk No Impact

movement=movement JOG_BUMP accepted possible: NO_STATIC_PATH_AFTER_GATE
movement=movement CONTACT trigger possible: NO_STATIC_PATH_AFTER_GATE
walking action counted quota: NO_STATIC_PATH_AFTER_GATE
walking action charged cost: NO_STATIC_PATH_AFTER_GATE
walking action STAGGER_CONTROL visible_effect: NO_STATIC_PATH_AFTER_GATE

Important caveat:

- Static grep still finds litera
[EXCERPT_TRUNCATED]
```
