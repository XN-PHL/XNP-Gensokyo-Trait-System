# 0.5.15 Sanitized Evidence Excerpts

## 0.5.15_REAL_GAME_FAILURE_ANALYSIS_FROM_0.5.14.md

- SHA-256: `CAD1EB347BB2D1F7BD5257CCB20C3589F3A7DB3FEBDD90556C87DE4CE6A88089`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.15 Real Game Failure Analysis From 0.5.14

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.15
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0515_FULL_SPRINT_IMMUNITY_STRICT_CONTACT_A

## Accepted 0.5.14 Result

- 0.5.14 loaded and verified the 0.5.9 stagger/knockdown route.
- SPRINT_PRECOLLISION could produce visible stagger_knockdown.
- CONTACT could produce visible stagger.
- Zombie key and skip summary behavior improved.

## Remaining Failures

- Ordinary movement around speed 0.60 could still trigger CONTACT and control side zombies.
- CONTACT was too broad and needed a strict jog/run/front gate.
- Sprint stagger alone did not guarantee the player stayed up.
- Crowd rush could stop re-triggering after the first impact.

## 0.5.15 Direction

- CONTACT is now gated by jog/run evidence, speed >= 1.35, dot >= 0.80, and distance window.
- A new SprintTripImmunity runtime module performs full sprint sweep, rearm, and guarded player trip cancel attempts.
- Because safe player cancel API availability is only runtime-probed, static audit cannot prove 100 percent full sprint immunity.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.15_FULL_SPRINT_TRIP_IMMUNITY_DESIGN.md

- SHA-256: `DFCCA5C81DED9373165FBF98816B302D2D784B916ACA0B1379C4655BB9EAE41C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.15 Full Sprint Trip Immunity Design

## Runtime Location

42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_SprintTripImmunity.lua

## Behavior

- Full sprint is detected by trait ownership, speed >= 3.25, and sprint/run evidence.
- A forward sweep checks 0.65 to 2.20 tiles, dot >= 0.55.
- Up to 3 zombies can be controlled per sweep.
- Per-zombie rearm cooldown is 0.25 seconds.
- The sweep uses the verified zombie-side stagger/knockdown controller.
- Player position is not written.
- Damage is not healed or rolled back.

## Trip Guard

The module audits player cancel methods at runtime. If a safe method is present, it logs trip_guard=ENABLED. If not, it logs trip_guard=BLOCKED reason=NO_SAFE_PLAYER_CANCEL_API.

## Static Status

The code path exists, but static audit cannot prove the game runtime exposes a safe player cancel method. Therefore this source cannot honestly claim 100 percent full sprint immunity before real-game validation.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.15_SPRINT_REARM_AND_CROWD_RUSH.md

- SHA-256: `CC2D81856F300FE81F31D066218003EF6E6D15A154B667F56A3890AF1B6BB284`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.15 Sprint Rearm And Crowd Rush

## Runtime Location

42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_SprintTripImmunity.lua

## Behavior

- Full sprint sweep does not rely entirely on BreakoutPush cooldown.
- Same zombie has a short 0.25 second cooldown.
- New targets can be swept while the player remains in full sprint.
- The module logs rearm readiness and same-target blocks.

## Runtime Logs

- [XNP SPRINT IMMUNITY REARM] reason=STILL_SPRINTING_NEW_TARGETS
- [XNP SPRINT IMMUNITY REARM] blocked reason=SAME_TARGET_COOLDOWN
- [XNP SPRINT IMMUNITY REARM] state=READY

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.15_STRICT_CONTACT_GATE_DESIGN.md

- SHA-256: `A78E1BED5E4D8F124132FD54964F3F7B17EE519E3C168EE3EFDA9BB170EDE2C9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.15 Strict Contact Gate Design

## Runtime Location

42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua

## Gate

- contact_min_speed=1.35
- contact_max_speed=3.24
- contact_dot_min=0.80
- contact_min_dist=0.95
- contact_max_dist=1.40
- plain movement is rejected
- getup/recovery state is rejected
- jog/run/front contact is required

## Runtime Logs

- [XNP CONTACT GATE] strict_contact_enabled=true
- [XNP CONTACT GATE] state=BLOCKED reason=WALKING_NOT_JOGGING
- [XNP CONTACT GATE] state=BLOCKED reason=SIDE_CONTACT_REJECTED
- [XNP CONTACT GATE] state=PASS reason=JOG_FRONT_CONTACT

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.15_TEST_PLAN.md

- SHA-256: `CAD70FEB1F0423C4EAC4A50A4CDBF4C0043CD01A3856019A9D6221FF3FED6D3A`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.15 Test Plan

## Load

Confirm:

- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0515_FULL_SPRINT_IMMUNITY_STRICT_CONTACT_A
- [XNP SPRINT IMMUNITY] method=FULL_SPRINT_TRIP_IMMUNITY
- [XNP CONTACT GATE] strict_contact_enabled=true
- [XNP BREAKOUT] method=FULL_SPRINT_IMMUNITY_STRICT_CONTACT
- trip_guard=ENABLED or trip_guard=BLOCKED reason=NO_SAFE_PLAYER_CANCEL_API

## Ordinary Movement

Walk near side zombies. Expected: CONTACT blocked with WALKING_NOT_JOGGING and no visible zombie control.

## Jog / Run Contact

Jog/run front contact. Expected: CONTACT may trigger, but only with strict front gate.

## Full Sprint

Sprint into zombies. Expected: sweep logs, rearm logs, and either trip cancel success or clear blocked-no-safe-api result.

## Result Rule

If trip_guard is blocked, do not treat this build as 100 percent full sprint immunity.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## BUILD_MARKER.txt

- SHA-256: `3DFF8D58AF50EA5822C55D464FA74D0E7948F86D852E8431B3BB28634ABF5A6C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0515_FULL_SPRINT_IMMUNITY_STRICT_CONTACT_A

```

## FINAL_REPORT.md

- SHA-256: `B4E2E187C781134F4F7200445C21795D05A6164364D689B64C806CA0AF07F6D8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.15

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.15
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0515_FULL_SPRINT_IMMUNITY_STRICT_CONTACT_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.15 Full Sprint Immunity Strict Contact

## Changed Files

- BUILD_MARKER.txt
- mod.info
- 42\mod.info
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Config.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_SprintTripImmunity.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_VanillaImpact.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ShoulderImpact.lua
- 0.5.15_REAL_GAME_FAILURE_ANALYSIS_FROM_0.5.14.md
- 0.5.15_STRICT_CONTACT_GATE_DESIGN.md
- 0.5.15_FULL_SPRINT_TRIP_IMMUNITY_DESIGN.md
- 0.5.15_PLAYER_TRIP_CANCEL_API_AUDIT.md
- 0.5.15_SPRINT_REARM_AND_CROWD_RUSH.md
- 0.5.15_TEST_PLAN.md
- STATIC_AUDIT.md
- FINAL_REPORT.md

## 0.5.14 Issue Fix Result

- Ordinary movement controlling side zombies: FIXED_STATIC.
- CONTACT too broad: FIXED_STATIC.
- Full sprint still falls: RISK, runtime guard exists but safe cancel API is not statically proven.
- Crowd rush stops re-triggering: RISK, sprint rearm exists but needs real-game validation.

## Full Sprint Trip Immunity

- Runtime attached: YES.
- Trip guard enabled: RUNTIME_PROBED.
- Writes player coordinates: NO.
- Repairs damage: NO.
- Static guarantee of full sprint immunity: NO.

## Strict Contact Gate

- contact_min_speed=1.35.
- contact_dot_min=0.80.
- Rejects movement=movement: YES.
- Rejects getup/recovery: YES.
- Requires jog/run/front contact: YES.

## Sprint Rearm

- Implemented: YES.
- Rearm cooldown: 0.25.
- Max targets: 3.

## Safety

- Project Zomboid launched: NO.
- Steam launched: NO.
- User mods write: NO.
- Saves write: NO.
- Workshop write: NO.
- Game directory write: NO.
- Old source modified: NO.
- Package/install/copy to mods: NO.

## Blocker

BLOCKER_NO_STATIC_PROOF_OF_SAFE_PLAYER_TRIP_CANCEL_API

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.15_BLOCKED_NOT_READY


```

## 0.5.15_PLAYER_TRIP_CANCEL_API_AUDIT.md

- SHA-256: `4163171A2523151D700E7D28436E4500C91BF775F10A1894F00FE61A37812EF1`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.15 Player Trip Cancel API Audit

## Candidate Runtime Methods

- player set knocked-down false route, if exposed.
- player set on-floor false route, if exposed.

## Implementation

- The module checks method existence at runtime.
- Every call is protected.
- The route only runs for trait player, full sprint state, and recent sweep/outcome window.
- It does not write player coordinates.
- It does not repair damage.

## Static Conclusion

NO_STATIC_PROOF_OF_SAFE_PLAYER_CANCEL_API

The source contains a runtime guarded implementation, but the workspace does not contain verified B42.19.0 player API evidence proving these methods are safely exposed for IsoPlayer. Because the user requires 100 percent full sprint immunity, final status is BLOCKED_NOT_READY until real-game or local API evidence proves the cancel path.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## STATIC_AUDIT.md

- SHA-256: `E41BC4FF77AFAFC2551F9D88B743567FB108AB77EF0AB930B8AD9517F0A1CBDD`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.15

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.15
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0515_FULL_SPRINT_IMMUNITY_STRICT_CONTACT_A

## Identity

- New source path confirmed.
- Old sources were not edited.
- Active build marker grep: PASS.
- Historical version mentions exist only in docs describing previous real-game results.
- Active Lua old-marker scan: PASS.

## Strict Contact Gate

- Runtime gate exists in XNP_DR_BreakoutPush.lua.
- contact_min_speed=1.35.
- contact_max_speed=3.24.
- contact_dot_min=0.80.
- plain movement rejected.
- getup/recovery state rejected.
- jog/run/front contact required.
- movement=movement speed=0.60 should be blocked by speed and plain movement checks.

## SprintTripImmunity

- Runtime module exists: XNP_DR_SprintTripImmunity.lua.
- Runtime requires it.
- Runtime calls it before and after BreakoutPush.
- Full sprint sweep exists.
- Per-target rearm exists.
- Summary fields exist.
- Player coordinate write: PASS_NO_HITS.
- Damage repair route: PASS_NO_HITS.
- Time manipulation route: PASS_NO_HITS.

## Trip Cancel API Audit

- Runtime audit checks player set knocked-down false route.
- Runtime audit checks player set on-floor false route.
- Calls are protected.
- Static proof of safe B42.19.0 IsoPlayer cancel API: NOT_PROVEN.
- BLOCKER: NO_STATIC_PROOF_OF_SAFE_PLAYER_CANCEL_API.

## Grep Results

- Forbidden route grep: PASS_NO_HITS.
- Player coordinate write grep: PASS_NO_HITS.
- Legacy impact active route: no Runtime call.
- VanillaImpact no-op: PASS.
- ShoulderImpact no-op: PASS.

## Counts

- Lua files: 17.
- Lua lines: 2881.
- Markdown docs before this audit: 6.

## Status

Because 100 percent full sprint trip immunity requires a proven player cancel fallback and that proof is unavailable by static audit, this source is not READY.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.15_BLOCKED_NOT_READY


```
