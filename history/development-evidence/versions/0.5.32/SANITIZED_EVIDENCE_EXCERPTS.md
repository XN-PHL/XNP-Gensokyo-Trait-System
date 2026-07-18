# 0.5.32 Sanitized Evidence Excerpts

## 0.5.32_COLOR_LINKED_STAMINA_MULTIPLIERS.md

- SHA-256: `BDEE12D7614D9511F04D16C1934E02ED129B96D64FF703D8EA6428FD1DD06E69`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.32 Color Linked Stamina Multipliers

Mechanism:

POST_DRAIN_REFUND_BY_ENDURANCE_BAND

The mod observes natural endurance loss, then refunds part of the continuous locomotion drain:

- rawLoss = previous endurance - current endurance
- refund = rawLoss * refundFraction
- finalLoss = rawLoss - refund

Band mapping:

- GREEN_READY: drain multiplier 1.00, refund 0.00.
- BLUE_STAMINA_SUPPORT: drain multiplier 0.72, refund 0.28.
- YELLOW_LOW_STAMINA_SUPPORT: drain multiplier 0.48, refund 0.52.
- RED_EXHAUSTED_SUPPORT: drain multiplier 0.30, refund 0.70.

Safety:

- locomotion_drain_only=true
- discrete_cost_refund_disabled=true
- discrete_drop_threshold=0.012
- no_direct_full_restore=true
- no_infinite_stamina=YES
- no_infinite_sprint=YES

Single-tick discrete drops above threshold are not refunded.

```

## 0.5.32_ENDURANCE_VALUE_ONLY_COLOR_BANDS.md

- SHA-256: `745D78E4FC640C8D2960433953D5F07CF9EFBF3E0C2C38F23271DCDCD52F2683`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.32 Endurance Value Only Color Bands

COLOR_SOURCE=ENDURANCE_VALUE_ONLY

Final ordinary visual states:

- GREEN_READY: endurance >= 0.86, enter green at 0.90 during upgrade hysteresis.
- BLUE_STAMINA_SUPPORT: endurance < 0.86 and >= 0.70.
- YELLOW_LOW_STAMINA_SUPPORT: endurance < 0.70 and >= 0.52.
- RED_EXHAUSTED_SUPPORT: endurance < 0.52.

Capability flags do not select color.
Movement state does not select color.
Idle, getup, jog/sprint capability, and knocked-down state do not force Green.

WHITE_VISUAL_STATE=DISABLED
WHITE_RESOURCE_GUARD is not an ordinary icon color in 0.5.32.

```

## 0.5.32_NO_WHITE_VISUAL_OVERRIDE.md

- SHA-256: `1DD34F9D23A2F3D0150DD74BF8E66352453B18C636D98369A812A2963AD21150`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.32 No White Visual Override

WHITE_VISUAL_STATE=DISABLED

0.5.32 removes White from the ordinary stamina icon state selection. Low food reserve no longer changes icon color to white or green.

Resource lock is represented as internal assist availability only. Tooltip may append:

Assist unavailable: low food reserve

The visual color remains the current numeric endurance band:

- Green
- Blue
- Yellow
- Red

```

## 0.5.32_PRESERVE_DRAG_AND_CORE_MECHANICS.md

- SHA-256: `A7893EC6FB3721550C212EFD528C7527D4FE930FDE7AEF2C3EBDFB2AA2E49433`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.32 Preserve Drag And Core Mechanics

DRAG_BEHAVIOR=UNCHANGED_FROM_0.5.31
CORE_MECHANICS=PRESERVED

Files intentionally not modified:

- `XNP_DR_DraggableStatusIcon.lua`
- `XNP_DR_StatusIconInputBindingGuard.lua`
- JogBump modules
- SprintVehicleImpact
- NativeTripWindow
- SprintTripConsequence
- FallRecoveryInput
- EmergencyBreakout
- DragdownDangerBreakout
- BreakoutActionBus
- ImpactQuotaMeter
- MovementIntentGate

0.5.32 only changes endurance color bands, state commit, stamina refund multipliers, resource lock behavior, version identity, and documentation.

```

## 0.5.32_REAL_GAME_FIX_FROM_0.5.31.md

- SHA-256: `34E97541495DA6199D7A5FCCA07A12EF496CB0D69AD5BD7BE2BBFFDC9C876911`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
BASELINE=0.5.31

# 0.5.32 Real Game Fix From 0.5.31

0.5.31 confirmed that direct icon drag and blue early stamina writes worked, but the state machine still selected colors from capability and movement-like conditions.

0.5.32 fixes the live issue by replacing visual stamina state selection with endurance numeric bands only.

- COLOR_SOURCE=ENDURANCE_VALUE_ONLY
- GREEN=NORMAL_VANILLA_DRAIN
- BLUE=STAMINA_SUPPORT
- YELLOW=HIGH_STAMINA_SUPPORT
- RED=MAXIMUM_STAMINA_SUPPORT
- WHITE_VISUAL_STATE=DISABLED
- RESOURCE_LOCK=PRESERVE_COLOR_CANCEL_REFUND_AND_HUNGER
- STATE_COMMIT_AFTER_CONFIRMED=REQUIRED
- SAME_TICK_CANDIDATE_RECREATE=FORBIDDEN
- DRAG_BEHAVIOR=UNCHANGED_FROM_0.5.31
- CORE_MECHANICS=PRESERVED
- NO_INFINITE_STAMINA=YES
- NO_INFINITE_SPRINT=YES

0.5.32 does not modify the working drag modules and does not change collision, escape, kill, NativeTrip, JogBump, vehicle impact, or action quota mechanics.

```

## 0.5.32_RESOURCE_LOCK_COLOR_PRESERVE.md

- SHA-256: `E8DDBAAD4D8772C87A449334664F306428B97E3281C3125CCC74C735DC7D8FA0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.32 Resource Lock Color Preserve

RESOURCE_LOCK=PRESERVE_COLOR_CANCEL_REFUND_AND_HUNGER

Resource Guard is internal only:

- It does not change icon color.
- It preserves the current endurance band color.
- It cancels refund fraction by forcing it to 0.
- It forces drain multiplier to 1.00.
- It cancels extra hunger writes.
- It does not convert hunger to direct endurance.
- It does not heal or restore full stamina.

Thresholds:

- resource_guard_hunger_soft=0.72
- resource_guard_hunger_hard=0.82
- resource_guard_calorie_floor=-1000
- resource_resume_hunger=0.64
- resource_resume_calorie=-600

Hunger conversion is proportional to actual refund:

- Green ratio 0.00
- Blue ratio 0.35
- Yellow ratio 0.75
- Red ratio 1.20
- max_extra_hunger_per_minute=0.055

```

## 0.5.32_STATE_COMMIT_TRANSACTION_FIX.md

- SHA-256: `E3FFEDE04A662F1ACA75C3B925BFFC252E84A8FAA368604CA872B6E12EEBEC88`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.32 State Commit Transaction Fix

STATE_COMMIT_AFTER_CONFIRMED=REQUIRED
SAME_TICK_CANDIDATE_RECREATE=FORBIDDEN

Implementation:

- Stable state is stored in `XNP_DR_EnduranceBandState.lua`.
- Candidate state is cleared immediately after confirmed commit.
- Same-frame candidate recreation is blocked by `lastCommitFrame`.
- Downgrade confirm frames: 6.
- Upgrade confirm frames: 45.
- Large endurance drop can reclassify immediately.
- Transient action blocks upgrades only.
- Transient action does not block downgrades.

Required runtime log markers are present:

- `[XNP ENDURANCE COMMIT]`
- `stable_state=...`
- `candidate_cleared=true`
- `no_recreate_same_tick=true`
- `downgrade_committed_during_transient=true`

```

## 0.5.32_TEST_PLAN.md

- SHA-256: `AF81E118129F03BD61AD81F9A746333F2225531E767754B256A0F15E8FC3CD23`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.32 Test Plan

1. Confirm console contains `XNP_PZ_DISTANCE_TRAIT_0532_ENDURANCE_BAND_MULTIPLIER_STATE_A`.
2. Confirm Config loaded log appears.
3. Confirm direct icon dragging still works exactly like 0.5.31.
4. Drain endurance through normal movement and observe icon colors:
   - >=0.86/0.90: Green.
   - 0.70 to 0.86: Blue.
   - 0.52 to 0.70: Yellow.
   - below 0.52: Red.
5. At endurance around 0.68 to 0.72, verify Green does not return unless endurance crosses the configured upgrade threshold.
6. Confirm `confirmed=true` commits once and does not recreate the same candidate in the same tick.
7. Confirm Blue/Yellow/Red logs show band-linked drain/refund.
8. Trigger low food reserve and verify current color is preserved while assist is unavailable.
9. Confirm no White visual override appears.
10. Confirm no Project Zomboid files, user mods, saves, Workshop, or old SOURCE directories were modified by Codex.

```

## BUILD_MARKER.txt

- SHA-256: `3C36BD2758968DEB757D122E2AA494DBFF82EB50B7ED24D2512CC2E5D23135EA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0532_ENDURANCE_BAND_MULTIPLIER_STATE_A

```

## FINAL_REPORT.md

- SHA-256: `E8628D9E8B66E1A4C867C547E883253227E8E5E5F3F2D1722F216EA196FEA4E2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.32
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0532_ENDURANCE_BAND_MULTIPLIER_STATE_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.32 Endurance Band Multiplier State

0.5.31 live issue status:

- Yellow never appeared: FIXED_BY_ENDURANCE_VALUE_ONLY_BAND.
- Red never appeared: FIXED_BY_ENDURANCE_VALUE_ONLY_BAND.
- Low endurance returned Green: FIXED_BY_HYSTERESIS_AND_UPGRADE_CONFIRM.
- confirmed=true repeated without stable commit: FIXED_BY_COMMIT_TRANSACTION.

Color bands:

- source endurance only: YES.
- Green: >=0.86, upgrade enter 0.90.
- Blue: <0.86 and >=0.70.
- Yellow: <0.70 and >=0.52.
- Red: <0.52.
- White visual disabled: YES.

State commit:

- stable state assigned: YES.
- candidate cleared: YES.
- same tick recreate blocked: YES.
- downgrade confirm frames: 6.
- upgrade confirm frames: 45.
- transient downgrade allowed: YES.

Multipliers:

- Green drain 1.00 refund 0.00.
- Blue drain 0.72 refund 0.28.
- Yellow drain 0.48 refund 0.52.
- Red drain 0.30 refund 0.70.
- locomotion only: YES.
- action/discrete cost refund blocked: YES.
- legacy ready/adrenaline refund route disabled: YES.

Resource gate:

- color preserved: YES.
- multiplier cancelled: YES.
- extra hunger cancelled: YES.
- resume hysteresis: YES.
- max hunger per minute: 0.055.

Preserved:

- Direct icon drag from 0.5.31.
- Drag capture/release anywhere.
- Position save/load/reset.
- Safe RGBA.
- Danger red flash.
- Walk No Impact.
- Controlled Jog Escape.
- JogBump.
- SprintVehicleImpact.
- NativeTripWindow.
- SprintTripConsequence.
- ActionBus/ImpactQuota.
- No bite/no infection/no heal rule.

No game, Steam, user mods, saves, Workshop, or old SOURCE writes were performed.

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.32_SOURCE_READY_FOR_ENDURANCE_BAND_TEST

```

## 0.5.32_SECOND_PASS_AUDIT.md

- SHA-256: `3A9182E39931F14B195A0FF1DDBB45A37CD635D7786BFCD19F72CA0C8E6E4A09`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ Distance Runner 0.5.32 Second Pass Audit

Audit command type: read-only audit.  
Code modification performed: NO.  
Only written file: `0.5.32_SECOND_PASS_AUDIT.md`.

## 1. Source And Version

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]

- SOURCE_EXISTS=YES
- BUILD_MARKER_OK=YES
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0532_ENDURANCE_BAND_MULTIPLIER_STATE_A
- DISPLAY_NAME_OK=YES
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.32 Endurance Band Multiplier State
- FILE_COUNT_0531=63
- FILE_COUNT_0532=63
- LUA_COUNT_0532=46
- LARGE_COPY_DETECTED=NO
- OLD_ACTIVE_RESIDUE=RISK

Active Lua version residue scan:

- `0.5.20~0.5.31`: 0 hits.
- `0520~0531`: 0 hits.
- `BLUE_EARLY_ASSIST`: 0 hits.
- `YELLOW_JOG_ONLY`: 0 hits.
- `WHITE_RESOURCE_GUARD`: 0 hits.
- Risk: `XNP_DR_StatusIconUI.lua` still logs Green source as `ENDURANCE_CAPABILITY`.
- Risk: legacy `RESOURCE_GUARD_WHITE_*` config names remain, although not used as visible icon states.

## 2. Endurance-Only Color Audit

- ENDURANCE_ONLY_CLASSIFIER=YES
- FOUR_STATES_PRESENT=YES
- WHITE_VISUAL_DISABLED=YES_FOR_ICON_ROUTE
- CAPABILITY_NOT_COLOR_SELECTOR=YES_RUNTIME / RISK_LOG_RESIDUE
- MOVEMENT_NOT_COLOR_SELECTOR=YES_FOR_COLOR_CLASSIFIER
- LOW_ENDURANCE_CANNOT_GREEN=YES_BY_CLASSIFY_RAW
- YELLOW_RUNTIME=YES
- RED_RUNTIME=YES
- COLOR_BAND_STATUS=RISK_TEST_ALLOWED

Evidence:

- `XNP_DR_EnduranceBandState.lua` exists and `ClassifyRaw(endurance)` uses endurance thresholds only.
- Four runtime states exist:
  - `GREEN_READY`
  - `BLUE_STAMINA_SUPPORT`
  - `YELLOW_LOW_STAMINA_SUPPORT`
  - `RED_EXHAUSTED_SUPPORT`
- `ClassifyRaw`: `<0.86 && >=0.70` maps Blue, `<0.70 && >=0.52` maps Yellow, `<0.52` maps Red.
- `sprint_capable` and `jog_capable` are nil diagnostics in `makeInfo`, not color selectors.
- `movement` is sampled only for transient upgrade/downgrade handling, not raw color selection.

Risks:

- `XNP_DR_StatusIconUI.lua` line with Green log still prints `source=ENDURANCE_CAPABILITY`.
- `XNP_DR_StatusIconUI.lua` still contains fallback `STAMINA_GREEN_READY` path from `LongMigrationStaminaAssist.GetStatus`; current band path runs first, but fallback residue exists.

BLOCKER assessment for this section: NO hard runtime blocker found, but active logging residue should be fixed before clean PASS.

## 3. State Commit Transaction Audit

- CANDIDATE_ACCUMULATES=YES
- STABLE_STATE_ASSIGNED=YES
- CANDIDATE_CLEARED=YES
- SAME_TICK_RECREATE_BLOCKED=PARTIAL
- CONFIRMED_LOG_ONCE=PARTIAL
- DOWNGRADE_CONFIRM=6
- UPGRADE_CONFIRM=45
- TRANSIENT_DOWNGRADE_ALLOWED=YES
- STATE_COMMIT_STATUS=BLOCKED

Evidence:

- `candidateState` and `candidateFrames` exist.
- `candidateFrames = candidateFrames + 1` exists.
- Confirmed commit assigns `EnduranceBandState.stableState = makeInfo(...)`.
- `candidateState = nil` and `candidateFrames = 0` are present after confirmed commit.
- `lastCommitFrame` blocks same-frame recreation and logs `no_recreate_same_tick=true`.
- Config has `transient_hold_blocks_upgrade = true`.
- Config has `transient_hol
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `E680600C85FDE787FA56EFB71F5C2E51AA180A0D7AAEB2E76B478CB42C6788FF`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_PATH=[LOCAL_PATH_REDACTED]
BASELINE=0.5.31
VERSION=0.5.32
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0532_ENDURANCE_BAND_MULTIPLIER_STATE_A

Checks:

- Old SOURCE modified: NO.
- Game directory written: NO.
- User mods written: NO.
- Steam or Project Zomboid launched: NO.
- Lua file count: 46.
- Lua total lines: 9374.
- Endurance value-only classifier runtime: PASS.
- Capability/movement cannot select color: PASS.
- White visual disabled: PASS.
- Four color states present: PASS.
- Thresholds centralized in Config: PASS.
- Confirmed commit assigns stableState: PASS.
- Candidate cleared after commit: PASS.
- Same-tick recreate blocked: PASS.
- Downgrade confirm frames: 6.
- Upgrade confirm frames: 45.
- Transient downgrade allowed: PASS.
- Multipliers/refund runtime: PASS.
- Legacy ready/adrenaline stamina refund route disabled: PASS.
- Locomotion-only refund: PASS.
- Discrete/action cost refund blocked: PASS.
- Hunger conversion proportional to refund: PASS.
- Resource lock preserves color: PASS.
- Resource lock cancels refund: PASS.
- Resource lock cancels extra hunger: PASS.
- No infinite stamina/sprint: PASS.
- Drag files behavior unchanged: PASS.
- Core collision/escape modules preserved: PASS.

Forbidden grep notes:

- `player:hasTrait(`: 0.
- `TraitFactory`: 0.
- `CharacterTraitDefinition`: 0.
- `RunningShove`: 0.
- `BumpedState`: 0.
- `GameTime:setMultiplier`: 0.
- `HaloTextHelper`: 0.
- `player:Say`: 0.
- Player coordinate writes: 0.
- Zombie-side `setX/setY` remains in preserved BreakoutPush only; this is not a player coordinate write.

NOT_VERIFIABLE:

- Lua runtime execution was not performed because no local Lua interpreter was found.
- Real game behavior remains REAL_GAME_TEST_REQUIRED_BY_USER.

```
