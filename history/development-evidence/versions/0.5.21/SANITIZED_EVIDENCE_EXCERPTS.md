# 0.5.21 Sanitized Evidence Excerpts

## 0.5.21_ICON_RED_FLASH_PRESERVE.md

- SHA-256: `411E5AD64C4A8B5A894C690772D20713157D308886DC7314F1C0672FC712CF2C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Icon Red Flash Preserve

Preserved:

- Dynamic icon route.
- Texture route.
- Red/danger visual behavior.

Added:

- `SKILL_TRIGGERED_FLASH` state.
- Red flash on emergency, dragdown and sprint trip cancel cost events.
- Flash end log and return to normal priority state.

Expected logs:

- `[XNP STATUS ICON] state=SKILL_TRIGGERED_FLASH color=RED`
- `[XNP STATUS ICON] state=DRAGDOWN_DANGER color=RED shake=true`
- `[XNP STATUS ICON] flash_end return_state=...`

Not used:

- Main UI text fallback.
- World-coordinate fake icon.

```

## 0.5.21_JOG_CONTACT_RATE_TUNE.md

- SHA-256: `625DE3EC34E309F21FFA94EE68F7FA0EB33EC85EDBC64F1D8401C13049B0583E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Jog Contact Rate Tune

Goal:

- Jog contact still exists.
- Contact triggers less often than 0.5.20.
- Contact stays light stagger only.
- Sprint route is not weakened by this change.

Parameters:

- contact_min_speed=1.45
- contact_max_speed=2.65
- contact_dot_min=0.86
- contact_dist_max=1.18
- contact_closing_frames_required=3
- contact_cooldown=1.75
- contact_same_target_cooldown=2.50

Expected logs:

- `[XNP CONTACT GATE] state=BLOCKED reason=CONTACT_TOO_FAR`
- `[XNP CONTACT GATE] state=BLOCKED reason=CONTACT_RATE_LIMIT`
- `[XNP CONTACT GATE] state=BLOCKED reason=CONTACT_SPEED_TOO_HIGH_USE_SPRINT`
- `[XNP CONTACT GATE] state=PASS reason=JOG_FRONT_CLOSE_CONTACT`
- `[XNP CONTACT PROFILE] effect=STAGGER_ONLY no_knockdown=true`

```

## 0.5.21_LOG_THROTTLE_CLEANUP.md

- SHA-256: `E40A365E16327C0E12E6553E61AA062019DD379D648C0346B80A11144B246E74`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Log Throttle Cleanup

Changed:

- Speed sample uses summary when debug is off.
- Dragdown warning/assist blocks are summarized.
- Auto dragdown warning/assist blocks are summarized.
- Icon state hold spam is summarized.

Summary logs:

- `[XNP SPEED SAMPLE SUMMARY] sprint_frames=... jog_frames=...`
- `[XNP DRAGDOWN BLOCK SUMMARY] warning_no_auto=...`
- `[XNP AUTO DRAGDOWN SUMMARY] warning_blocked=...`
- `[XNP ICON STATE SUMMARY] current=...`

Critical trigger and failure logs are still immediate.

```

## 0.5.21_REAL_GAME_TUNING_ANALYSIS_FROM_0.5.20.md

- SHA-256: `026C66CC9890A0BFEDBC150C7B9505A37C239FDA0460FD63FE984D4418E293E7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Real Game Tuning Analysis From 0.5.20

0.5.20 confirmed:

- Activation is live.
- Runtime update is live.
- Dynamic right-top icon exists.
- Icon can turn red during skill states.
- Sprint sweep starts working.
- Jog and grab escape remain usable.

0.5.21 target:

- Keep the live chain.
- Fix icon position, not the icon route.
- Increase full sprint zombie impact coverage.
- Connect Breakout sprint fall reports to sprint trip cancel.
- Reduce jog/contact trigger frequency.
- Keep higher 0.5.20 skill costs and safety policy.

Status:

- ICON_FEATURE_STATUS=KEEP_DYNAMIC_ICON_FIX_POSITION
- ICON_RED_FLASH_STATUS=PRESERVED
- SPRINT_STATUS=BOOST_ZOMBIE_KNOCKDOWN_REDUCE_PLAYER_FALL
- JOG_STATUS=REDUCE_CONTACT_RATE_KEEP_LIGHT_STAGGER
- GRAB_ESCAPE_STATUS=PRESERVED

```

## 0.5.21_SPRINT_IMPACT_BOOST_DESIGN.md

- SHA-256: `B2629402BC1AB32EEA60E3655E1AFBCB5C049C7E5D94EAD9FEDE7A6E6D369B46`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Sprint Impact Boost Design

Goal:

- Full sprint should hit zombies more reliably than 0.5.20.
- Front primary targets can use the stronger sprint profile.
- Outer/side-front targets stay stagger-only.
- No screen-wide clearing.

Parameters:

- sprint_sweep_max_targets=3
- sprint_sweep_primary_knockdown_targets=2
- sprint_sweep_outer_stagger_targets=1
- sprint_sweep_dot_min=0.55
- sprint_sweep_outer_dot_min=0.45
- sprint_sweep_closing_frames=1

Target scoring:

- dot contribution
- closing-frame bonus
- preferred-distance bonus

Expected logs:

- `[XNP SPRINT SWEEP SELECT] candidate=... score=...`
- `[XNP SPRINT SWEEP SELECT] accepted=... profile=PRIMARY_KNOCKDOWN`
- `[XNP SPRINT SWEEP SELECT] accepted=... profile=OUTER_STAGGER`
- `[XNP SPRINT ROUTE] first_wave_knockdown_boost=true`

```

## 0.5.21_SPRINT_TRIP_CANCEL_NOTIFY_FIX.md

- SHA-256: `4C201819245A4B49B693305BAFB399DB994593EAB7F6A88BE0A54B071DF0488E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Sprint Trip Cancel Notify Fix

Problem:

- 0.5.20 BreakoutPush could report sprint fall while SprintTripImmunity later reported stayed up.
- This split made trip cancel attempts remain at zero in real tests.

Fix:

- Added `NotifySprintAction`.
- Added `NotifySprintFall`.
- BreakoutPush notifies SprintTripImmunity when sprint precollision starts.
- BreakoutPush notifies SprintTripImmunity when sprint fall is detected.
- SprintTripImmunity marks that outcome as forced fall and corrects the stayed-up path.

Expected logs:

- `[XNP SPRINT TRIP CANCEL] notify_from_action=true`
- `[XNP SPRINT TRIP CANCEL] notified trigger_id=...`
- `[XNP SPRINT IMMUNITY OUTCOME] corrected_from=PLAYER_STAYED_UP`
- `[XNP SPRINT TRIP CANCEL] attempt trigger_id=...`
- `[XNP SPRINT TRIP CANCEL] outcome=TRIP_CANCELLED_AND_STAYED_UP`

Limits:

- Requires recent sprint action.
- Uses existing audited cancel route only.
- Does not write player coordinates.
- Does not heal or reverse injury.

```

## 0.5.21_STATUS_ICON_POSITION_CALIBRATION.md

- SHA-256: `6616633ECA7219E8207B20D73B44054F0CE536EF30FA19D7AB79E12E56B6C1B3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Status Icon Position Calibration

Implementation:

- Added `XNP_DR_StatusIconPosition.lua`.
- Kept the recovered texture route.
- Default anchor mode is `RIGHT_TOP_SAFE_AREA`.
- Single status mode forces slot 0 unless stacking is explicitly enabled.
- Position can be tuned through manual offset config values.

Default position:

- from_right=118
- from_top=76
- manual_offset_x=0
- manual_offset_y=0
- 1920 wide expected x is about 1802.

Expected logs:

- `[XNP STATUS ICON POSITION] mode=RIGHT_TOP_SAFE_AREA`
- `[XNP STATUS ICON POSITION] old_x=... new_x=...`
- `[XNP STATUS ICON POSITION] slot=0`
- `[XNP STATUS ICON POSITION] anchor=...`

Adjustment:

- If the icon is still too far right or left, edit `ICON_BASE_OFFSET_FROM_RIGHT`.
- If the icon is too high or low, edit `ICON_BASE_OFFSET_FROM_TOP`.

```

## 0.5.21_TEST_PLAN.md

- SHA-256: `C2E3FFB00E92B8F476A0AB8ACFA306C98514C1DE9C18727639E3B59AC0193493`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.21 Test Plan

Load:

- Confirm 0.5.21 build marker.
- Confirm activation active.
- Confirm recovered icon route and position logs.

Icon:

- Check right-top icon position.
- Confirm single status icon stays visible.
- Confirm skill red flash remains.
- Tune `ICON_BASE_OFFSET_FROM_RIGHT` or `ICON_BASE_OFFSET_FROM_TOP` if needed.

Sprint:

- Full sprint into one to three front zombies.
- Expect more reliable front impact than 0.5.20.
- If player falls after sprint impact, expect trip cancel attempt logs.

Jog/contact:

- Jog into a zombie at different distances.
- Contact around old far range should be blocked.
- Very close front jog contact should still stagger lightly.

Grab/escape:

- Confirm emergency/dragdown escape still works.
- Confirm higher cost and safety logs remain.

```

## BUILD_MARKER.txt

- SHA-256: `52F97F7680B1AA52CF16B50F38C45CFB146415A8D7E713D2DA47C0471C98FBD2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0521_SPRINT_IMPACT_ICON_POSITION_JOG_TUNE_A

```

## FINAL_REPORT.md

- SHA-256: `6288E5DBB0E45D730797EEAAEC2D680BDC07C5D1FE6B6CC741B4D0CAF93BBE62`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.21
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0521_SPRINT_IMPACT_ICON_POSITION_JOG_TUNE_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.21 Sprint Impact Icon Position Jog Tune

0.5.20 feedback handling:

- right-top dynamic icon: PRESERVED
- red skill flash: PRESERVED
- icon position: FIXED_STATIC_RISK_REAL_GAME_REQUIRED
- sprint zombie impact: FIXED_STATIC_RISK_REAL_GAME_REQUIRED
- sprint player fall: FIXED_STATIC_RISK_REAL_GAME_REQUIRED
- jog contact rate: FIXED_STATIC_RISK_REAL_GAME_REQUIRED

Icon position:

- recovered route preserved: YES
- position tuner: YES
- anchor mode: RIGHT_TOP_SAFE_AREA
- old coordinate route configurable: YES
- default x/y at 1920x1000: about 1802/76
- red flash preserved: YES
- red flash priority bypass: YES
- single status icon: YES
- manual offset applied once: YES

Sprint impact:

- sprint sweep max targets: 3
- primary knockdown targets: 2
- outer stagger targets: 1
- target scoring: YES
- first wave boost: YES
- ActionBus same target cooldown preserved: YES

Sprint trip cancel:

- notify from Breakout fail: YES
- notify guard audit before cancel attempt: YES
- trip_cancel runtime path: YES
- correct outcome split: YES
- limited to recent full sprint collision: YES
- cost preserved: YES

Jog contact tune:

- contact_min_speed=1.45
- contact_max_speed=2.65
- contact_dot_min=0.86
- contact_dist_max=1.18
- contact_cooldown=1.75
- CONTACT no knockdown: YES
- movement-only state blocked: YES

Log throttle:

- speed sample summary: YES
- dragdown blocked summary-only: YES
- auto dragdown blocked summary-only: YES
- icon state_hold summary-only: YES

Counts:

- Total files: 43
- Lua files: 26
- Lua total lines: 6135
- Markdown files: 10

Safety:

- Project Zomboid launched: NO
- Steam launched: NO
- user mods written: NO
- saves written: NO
- Workshop written: NO
- game directory written: NO
- old SOURCE modified: NO
- package/install action: NO

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.21_SOURCE_READY_FOR_SPRINT_ICON_JOG_TEST

```

## STATIC_AUDIT.md

- SHA-256: `735D7DC7345F58FA8DAE4EC3B0526E9263493D4BE4029BA5D63E343C51B8394C`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.21 Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.21
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0521_SPRINT_IMPACT_ICON_POSITION_JOG_TUNE_A

Baseline:

- 0.5.20 baseline confirmed.
- Old SOURCE modified: NO.
- Large file pollution: NO.

File counts:

- Total files: 43
- Lua files: 26
- Lua total lines: 6135
- Markdown files: 10

Required static checks:

- forbidden route grep: PASS
- player coordinate writer grep: PASS
- game-time writer grep: PASS
- text/halo helper grep: PASS
- activation logs retained grep: PASS
- recovered icon route grep: PASS
- icon position tune grep: PASS
- old fixed coordinate audit: PASS
- icon red flash grep: PASS
- icon red flash priority bypass grep: PASS
- icon manual offset single-apply audit: PASS
- sprint impact boost grep: PASS
- sprint sweep max targets grep: PASS
- sprint target scoring grep: PASS
- sprint trip cancel notify from Breakout fail grep: PASS
- sprint trip cancel notify guard audit grep: PASS
- outcome split correction grep: PASS
- ActionBus follow-up allow grep: PASS
- contact distance max grep: PASS
- contact dot min grep: PASS
- contact cooldown grep: PASS
- CONTACT no knockdown grep: PASS
- debug speed sample disabled grep: PASS
- dragdown blocked summary-only grep: PASS
- no bite / no infection / no heal grep: PASS
- single zombie no hard-trigger preserved grep: PASS
- close-two warning-only preserved grep: PASS
- BOM scan: PASS
- NULL scan: PASS_TEXT_FILES_ONLY; PNG binary asset contains expected null bytes.

Runtime verification:

- Not run by policy.
- Real in-game position and impact tuning remain REAL_GAME_TEST_REQUIRED.

BLOCKER=NONE_STATIC

```
