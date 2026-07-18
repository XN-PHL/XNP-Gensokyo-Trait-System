# 0.5.25 Sanitized Evidence Excerpts

## 0.5.25_DRAG_CAPTURE_AND_TOOLTIP_DESIGN.md

- SHA-256: `5AEBB4B3A581CD7408ACCC640A35AF13331964412BB637F3CD29F5348D3AF3C1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.25 Drag Capture And Tooltip Design

ICON_DRAG_STATUS=CAPTURE_UNTIL_MOUSE_UP
ICON_TOOLTIP_STATUS=ENGLISH_ONLY_HOVER_TOOLTIP

Drag capture:
- Hit test is only required on mouse down.
- Mouse down on the icon sets drag_captured=true.
- Movement uses DELTA_FROM_DRAG_START.
- The icon continues to move after the mouse leaves the icon rectangle.
- Mouse up anywhere releases capture and saves the position.
- Ctrl/Alt modifiers are not required.

Required logs:
- [XNP STATUS ICON DRAG] capture_enabled=true
- [XNP STATUS ICON DRAG] begin hit_test=true drag_captured=true icon_start=... mouse_start=...
- [XNP STATUS ICON DRAG] move drag_captured=true hit_test_required=false mouse_abs=... delta=... new=... clamp=FULL_SCREEN
- [XNP STATUS ICON DRAG] end drag_captured=false saved=true x=... y=...
- [XNP STATUS ICON DRAG] lost_hit_test_ignored=true reason=CAPTURE_ACTIVE
- [XNP STATUS ICON DRAG] release_anywhere=true

Tooltip:
- English-only hover text is drawn by the icon panel.
- No player:Say.
- No HaloTextHelper.
- Tooltip hides while dragging.

Tooltip text:
- XNP Distance Runner
- Drag to move
- Red: skill triggered
- Sprint wall: vanilla trip check
- Run / Sprint: break control

```

## 0.5.25_EFFECT_RADIUS_REDUCTION.md

- SHA-256: `7191848E4E83898BDC69E6B45C0727530EC68EC2BBFEE0AF9131A9FC77624CDE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.25 Effect Radius Reduction

RADIUS_STATUS=EFFECT_RADIUS_REDUCED

Reduced effect radius values:
- jog_effect_radius=1.15
- jog_trip_shockwave_radius=1.25
- sprint_light_effect_radius=1.25
- sprint_native_trip_watch_radius=1.35
- sprint_trip_consequence_radius=1.35
- fall_recovery_radius=1.20
- skill_active_effect_radius=1.20
- emergency_control_radius=1.20
- candidate_scan_radius_max=1.65

Rules:
- 1.65 is scan/candidate only.
- Kill/knockdown/stun/recovery effect radius must not exceed 1.35.
- Emergency/Dragdown/FallRecovery concrete effect radius target is 1.20 where possible.

Required logs:
- [XNP RADIUS] mode=SPRINT_TRIP_CONSEQUENCE scan_radius=1.65 effect_radius=1.35
- [XNP RADIUS] mode=FALL_RECOVERY effect_radius=1.20
- [XNP RADIUS] large_scan_no_effect=true

```

## 0.5.25_JOG_NATIVE_TRIP_SHOCKWAVE.md

- SHA-256: `583BE14EE68D9884CBA14A5BCC6720EC5D50FD30D8234ACEC8AF4EE363AE903A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.25 Jog Native Trip Shockwave

JOG_STATUS=NATIVE_TRIP_IF_OVERFLOW_NO_KILL_SHOCKWAVE_ON_FALL

Jog behavior:
- Normal jog bump remains quota-limited.
- Jog overflow no longer forces trip immediately.
- Jog overflow opens NativeTripWindow with source=JOG_OVERFLOW.
- If vanilla/body state causes a real fall, JogFallShockwave runs.
- JogFallShockwave does not kill zombies.
- FallRecoveryInput remains available after fall.

Config:
- jog_overflow_native_trip_enabled=true
- jog_overflow_forced_trip=false
- jog_trip_kill_zombies=false
- jog_trip_shockwave_radius=1.25

Required logs:
- [XNP JOG NATIVE TRIP WINDOW] open forced_trip=false
- [XNP JOG NATIVE TRIP WINDOW] outcome=PLAYER_TRIPPED
- [XNP JOG FALL SHOCKWAVE] targets=... radius=1.25 effect=KNOCKDOWN_STUN no_kill=true
- [XNP JOG RECOVERY] input=RUN_OR_SPRINT result=CONTROL_BREAKOUT_APPLIED

```

## 0.5.25_NATIVE_TRIP_WINDOW_DESIGN.md

- SHA-256: `E5EB0A9BC57E5C4AD28C1EBD30EA2C1A275FDE40C240EF8DC662AB60BAAD2F5E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.25 Native Trip Window Design

SPRINT_WALL_STATUS=NATIVE_TRIP_WINDOW_NOT_FORCED_WALL_CRASH

Runtime module:
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_NativeTripWindow.lua

Sprint overflow behavior:
- Sprint wall/quota overflow no longer calls player:setKnockedDown(true).
- Sprint wall/quota overflow opens NativeTripWindow.
- The window suppresses sprint trip cancel and repeated vehicle impact.
- Vanilla collision/body/stat state decides whether the player actually trips.
- If the player stays up until timeout, no trip consequence is applied.
- If the player falls, SprintTripConsequence runs.

Required logs:
- [XNP NATIVE TRIP WINDOW] open source=SPRINT_OVERFLOW reason=ZOMBIE_WALL_OR_QUOTA_OVERFLOW forced_fall=false
- [XNP NATIVE TRIP WINDOW] release_to_vanilla_collision=true
- [XNP NATIVE TRIP WINDOW] sprint_trip_cancel_suppressed=true reason=NATIVE_TRIP_CHECK
- [XNP NATIVE TRIP WINDOW] outcome=PLAYER_STAYED_UP
- [XNP NATIVE TRIP WINDOW] outcome=PLAYER_TRIPPED state=ON_FLOOR
- [XNP NATIVE TRIP WINDOW] close reason=TIMEOUT_NO_TRIP

```

## 0.5.25_REAL_GAME_FEEDBACK_FROM_0.5.24.md

- SHA-256: `EB515C112D6F9A9E57EAD80931F9D9A9AE2C9D054EE040CA4928B2F05F13E417`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.25 Real Game Feedback From 0.5.24

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.25
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0525_DRAG_CAPTURE_NATIVE_TRIP_IMPACT_A

0.5.24 real-game feedback handled:
- Icon drag worked but lost drag when mouse left icon bounds.
- Icon needed English hover tooltip.
- Sprint wall crash felt like artificial wall impact due to forced fall.
- Sprint overflow should release to vanilla collision/body check first.
- Consequence should happen only after actual trip/fall.
- Sprint trip consequence should kill max 3 zombies, knockdown/stun the rest, and apply minor non-artery scrape.
- Jog overflow should not kill zombies and should only shockwave after real fall.
- Skill effect radii felt too wide and were reduced.

Status:
- ICON_DRAG_STATUS=CAPTURE_UNTIL_MOUSE_UP
- ICON_TOOLTIP_STATUS=ENGLISH_ONLY_HOVER_TOOLTIP
- SPRINT_WALL_STATUS=NATIVE_TRIP_WINDOW_NOT_FORCED_WALL_CRASH
- SPRINT_TRIP_CONSEQUENCE=KILL_MAX_3_REST_KNOCKDOWN_STUN_MINOR_SCRAPE
- JOG_STATUS=NATIVE_TRIP_IF_OVERFLOW_NO_KILL_SHOCKWAVE_ON_FALL
- RADIUS_STATUS=EFFECT_RADIUS_REDUCED
- NO_BITE_NO_INFECTION_NO_HEAL=PRESERVED

```

## 0.5.25_SPRINT_TRIP_CONSEQUENCE_KILL_CAP.md

- SHA-256: `6EE88E7A0B852F750A0F2AA758947CD765BE2578805C184E766002F52BAFA421`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.25 Sprint Trip Consequence Kill Cap

SPRINT_TRIP_CONSEQUENCE=KILL_MAX_3_REST_KNOCKDOWN_STUN_MINOR_SCRAPE

Runtime module:
- 42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_SprintTripConsequence.lua

Rules:
- Runs only after NativeTripWindow detects actual player fall.
- Radius is clamped to 1.35.
- Targets must be front or touching.
- Max kills: 3.
- Remaining relevant targets receive knockdown/stun, not death.
- Player receives minor non-artery scrape through MinorScrapeCost.
- No bite, no infection, no heal.

Required logs:
- [XNP SPRINT TRIP CONSEQUENCE] trigger source=NATIVE_TRIP_WINDOW
- [XNP SPRINT TRIP CONSEQUENCE] targets=... kill_max=3 radius=1.35
- [XNP SPRINT TRIP CONSEQUENCE] zombie=... result=KILLED index=1/3
- [XNP SPRINT TRIP CONSEQUENCE] zombie=... result=KNOCKDOWN_STUN reason=KILL_CAP_REACHED
- [XNP SPRINT TRIP CONSEQUENCE] kill_count=3 knockdown_stun_count=...
- [XNP SCRAPE] type=MINOR_SCRAPE source=SPRINT_NATIVE_TRIP body_part=... no_artery=true result=APPLIED
- [XNP SCRAPE] no_bite=true no_infection=true no_heal=true

```

## 0.5.25_TEST_PLAN.md

- SHA-256: `D9D65CA377729D1078B671F6A9B4AB381F191559119FB2CFC1B2853FDF7B2B04`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.25 Test Plan

Manual test only. Do not install automatically from Codex.

Checks:
1. Confirm console shows XNP_PZ_DISTANCE_TRAIT_0525_DRAG_CAPTURE_NATIVE_TRIP_IMPACT_A.
2. Drag icon quickly. Expected: capture remains active after mouse leaves icon; mouse up anywhere saves.
3. Hover icon. Expected: English tooltip appears; dragging hides it.
4. Sprint into a zombie wall. Expected: no immediate forced wall fall; NativeTripWindow opens and vanilla decides trip.
5. If player stays up, no sprint trip consequence applies.
6. If player trips during window, max 3 relevant zombies die; rest knockdown/stun; minor non-artery scrape applies.
7. Jog overflow. Expected: no forced trip; if actual fall occurs, jog shockwave fires with no kill.
8. Confirm FallRecovery remains available after jog/sprint fall.
9. Confirm no bite, no infection, no heal.
10. Confirm no player coordinate write, no GameTime, no HaloTextHelper, no player:Say.

```

## BUILD_MARKER.txt

- SHA-256: `6577CE107AFEE33B9FA3728B033C42AD18895C6E5F234F525077774577A8881B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0525_DRAG_CAPTURE_NATIVE_TRIP_IMPACT_A

```

## FINAL_REPORT.md

- SHA-256: `B3A415959AD799EFDD32EDAF341B6D1FD88D7BA81A83F92A59F772CA4BC24237`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.25 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.25
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0525_DRAG_CAPTURE_NATIVE_TRIP_IMPACT_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.25 Drag Capture Native Trip Impact

File counts:
- Total files: 52
- Lua files: 36
- Lua total lines: 7487
- Markdown files: 9

0.5.24 feedback handling:
- Icon drag capture: FIXED
- English tooltip: YES
- Sprint wall feels like wall crash: FIXED
- Vanilla body/stat trip decision: YES
- Consequence only after actual fall: YES
- Kill max 3: YES
- Rest knockdown/stun: YES
- Minor scrape no artery/no bite/no infection/no heal: YES
- Radius reduced: YES

Drag Capture:
- hit_test_only_on_begin: YES
- continue_outside_icon: YES
- release_anywhere: YES
- save/load/reset: YES
- red flash/shake/color preserved: YES

Native Trip:
- sprint forced fall disabled: YES
- native trip window: YES
- trip cancel suppressed during native window: YES
- consequence only after actual fall: YES

Consequence:
- kill max: 3
- rest effect: KNOCKDOWN_STUN
- radius: 1.35
- scrape route: SPRINT_NATIVE_TRIP minor non-artery scrape

Not performed:
- Project Zomboid not launched
- Steam not launched
- User mods not written
- Saves not written
- Workshop not written
- Game directory not written
- Old SOURCE directories not modified
- No packaging/install step

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.25_SOURCE_READY_FOR_DRAG_CAPTURE_NATIVE_TRIP_TEST

```

## 0.5.25_SECOND_PASS_AUDIT.md

- SHA-256: `CF356923190D0B42CF948D1D7F9F1592D2A11054F5518E21C1CF284AB14E4920`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.25 Second Pass Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.25
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0525_DRAG_CAPTURE_NATIVE_TRIP_IMPACT_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.25 Drag Capture Native Trip Impact
AUDIT_MODE=STATIC_SECOND_PASS_ONLY
RUNTIME_MODIFIED=NO
PROJECT_ZOMBOID_LAUNCHED=NO
STEAM_LAUNCHED=NO
USER_MODS_WRITTEN=NO
GAME_DIRECTORY_WRITTEN=NO
PACKAGE_BUILT=NO

## Scope

This audit checks the existing 0.5.25 SOURCE only. It does not add gameplay, does not fix runtime code, does not package, and does not install.

## Identity Check

PASS:

- `BUILD_MARKER.txt` contains `XNP_PZ_DISTANCE_TRAIT_0525_DRAG_CAPTURE_NATIVE_TRIP_IMPACT_A`.
- Shared constants contain `VERSION = "0.5.25"` and `INTERNAL_VERSION = "0.5.25-b42-drag-capture-native-trip-impact-a"`.
- `FINAL_REPORT.md` contains display name `XNP Distance Runner Trait 0.5.25 Drag Capture Native Trip Impact`.
- Existing READY marker is present: `XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.25_SOURCE_READY_FOR_DRAG_CAPTURE_NATIVE_TRIP_TEST`.

## 0.5.24 Baseline Preservation

PASS_WITH_TARGETED_CHANGES:

- The 0.5.25 SOURCE preserves the previous module structure and adds the 0.5.25 drag capture, tooltip, native trip window, sprint trip consequence, jog native trip shockwave, and radius tuning routes.
- Active runtime identity was advanced to 0.5.25.
- Old 0.5.24 identity strings only appear in retrospective documentation, not active Lua identity.

## Icon Drag Capture

PASS_WITH_RUNTIME_RISK:

- `ICON_DRAG_CAPTURE_ENABLED = true`
- `ICON_DRAG_HIT_TEST_ONLY_ON_BEGIN = true`
- `ICON_DRAG_CONTINUE_OUTSIDE_ICON = true`
- `ICON_DRAG_RELEASE_ON_MOUSE_UP_ANYWHERE = true`
- `ICON_DRAG_REQUIRES_MODIFIER = false`
- Drag begin performs the initial hit test and sets `dragCaptured`.
- Drag move logs `lost_hit_test_ignored=true` and `hit_test_required=false`.
- Drag update checks mouse-up globally through `isMouseButtonDown(0)` or fallback.
- Release logs `release_anywhere=true` and saves the final position.
- Full-screen clamp and user-position priority are implemented.

Runtime risk:

- Static audit cannot prove Project Zomboid's UI panel capture APIs behave consistently across all in-game UI layers. The code attempts `panel:setCapture` and `panel:captureMouse`, then falls back to per-update mouse state.

## English Hover Tooltip

PASS:

- Tooltip text is English-only:
  - `XNP Distance Runner`
  - `Drag to move`
  - `Red: skill triggered`
  - `Sprint wall: vanilla trip check`
  - `Run / Sprint: break control`
- Tooltip config uses `ICON_TOOLTIP_ENABLED = true`, `ICON_TOOLTIP_LANGUAGE = "EN"`, and hover display.
- No `HaloTextHelper` route is used.
- No `player:Say` route is used.

## Sprint Overflow / Native Trip Window

PASS_WITH_RUNTIME_RISK:

- `SPRINT_OVERFLOW_NATIVE_TRIP_ENABLED = true`
- `SPRINT_OVERFLOW_FORCED_FALL = false`
- `SPRINT_VEHICLE_WALL_PLAYER_FORCED_FALL = false`
- `XNP_DR_SprintVehicleImpact.lua` opens `NativeTripWindow` instead of forcing 
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `C28F780CC2EF23F422812DB3850969464173B98EF15EF612A5BA0381B0E35729`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.25 Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.25
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0525_DRAG_CAPTURE_NATIVE_TRIP_IMPACT_A

File counts:
- Total files: 52
- Lua files: 36
- Lua total lines: 7487
- Markdown files: 9

Audit checklist:
- Old SOURCE modified: NO
- Build marker grep: PASS
- Old active residue grep: PASS after runtime log rename
- Forbidden route grep: PASS for player-side coordinate/GameTime/Halo/player:Say/TraitFactory routes
- Drag capture runtime grep: PASS
- Drag hit_test_only_on_begin grep: PASS
- Drag continue outside icon grep: PASS
- Drag end save grep: PASS
- English tooltip grep: PASS
- Native trip window grep: PASS
- Forced fall disabled grep: PASS
- Sprint trip cancel suppressed during native trip grep: PASS
- Sprint consequence kill max 3 grep: PASS
- Rest knockdown stun grep: PASS
- Minor scrape no artery/no bite/no infection/no heal grep: PASS
- Jog native trip/shockwave/no kill grep: PASS
- Effect radius <=1.35 grep: PASS for concrete effects
- 1.75/2.10/2.35 not used as effect radius grep: PASS for new consequence/recovery path
- SKILL_ACTIVE quota preserved grep: PASS
- ActionBus accepted-only grep: PASS
- Duplicate target protection grep: PASS
- Per-target cooldown grep: PASS

Runtime files added:
- XNP_DR_NativeTripWindow.lua
- XNP_DR_SprintTripConsequence.lua

Runtime files modified:
- XNP_DR_DraggableStatusIcon.lua
- XNP_DR_StatusIconUI.lua
- XNP_DR_SprintVehicleImpact.lua
- XNP_DR_JogBumpLaunch.lua
- XNP_DR_JogFallShockwave.lua
- XNP_DR_SprintTripImmunity.lua
- XNP_DR_MinorScrapeCost.lua
- XNP_DR_Bootstrap.lua
- XNP_DR_Runtime.lua
- XNP_DR_Config.lua
- XNP_DR_Constants.lua

NOT_VERIFIABLE_BY_STATIC_AUDIT:
- Lua interpreter execution: NOT_VERIFIABLE, no local lua/luac command available
- Exact Project Zomboid UI mouse capture semantics
- Vanilla trip outcome timing
- Zombie death/stun visual consistency
- BodyDamage scrape API behavior

BLOCKER=NONE_STATIC

```
