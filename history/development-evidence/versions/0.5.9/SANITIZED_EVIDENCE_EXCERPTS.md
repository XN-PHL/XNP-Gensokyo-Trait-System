# 0.5.9 Sanitized Evidence Excerpts

## 0.5.9_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `0DB0B293EC043222E78BEB8D918E136E4B07CB10835281EB0DF526A4B251FD9F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.9 Real Game Result Summary

## Accepted Runtime Evidence

- Loaded build: `XNP_PZ_DISTANCE_TRAIT_059_REPEATABLE_RUNNER_IMPACT_FIX_A`
- Version log: `loaded version=0.5.9 internal=0.5.9-b42-repeatable-runner-impact-fix-a`
- Config loaded: `source=shared_config`
- Impact method: `STAGGER_KNOCKDOWN_REPEATABLE`
- Repeat trigger: PASS
- Visible reaction: PASS
- Bumped grace: PASS

Observed repeated logs:

- `[XNP IMPACT REACTION] type=stagger_knockdown result=ok`
- `[XNP IMPACT] trigger method=STAGGER_KNOCKDOWN_REPEATABLE ...`
- `[XNP IMPACT WATCHDOG] bumped_grace active`
- `[XNP IMPACT WATCHDOG] bumped_resolved`

## User Feedback

The feature now triggers repeatedly, but the feel is wrong:

- Player can feel dragged into a trip/fall/collision follow-up.
- Frontal impact should look more like vanilla jogging/running shove or high-fitness collision.
- Current behavior feels too close to Workshop-style run-tackle mods.
- The target is not probability-based knockdown; the target is vanilla-style animation/reaction routing.
- The player must not fall, trip, or enter long stun.
- Icon/Moodle remains deferred; this round focuses only on impact animation chain.

## Frozen 0.5.9 Result Labels

- `0.5.9_LOAD_RESULT=PASS`
- `0.5.9_CONFIG_RESULT=PASS`
- `0.5.9_REPEAT_TRIGGER_RESULT=PASS`
- `0.5.9_VISIBLE_EFFECT_RESULT=PASS`
- `0.5.9_PLAYER_TRIP_FEEDBACK=FAIL_PLAYER_CAN_TRIP_OR_FEELS_WRONG`
- `0.5.9_ANIMATION_FEEL_FEEDBACK=FAIL_NOT_VANILLA_EMBEDDED_ENOUGH`
- `0.5.10_GOAL=VANILLA_STYLE_RUNNER_IMPACT_ANIMATION_REWORK`

```

## BUILD_MARKER.txt

- SHA-256: `433F06AC9E42B91EE5F0003B295ABAFF5280852913777CD6EBD8E146D9E8672C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_059_REPEATABLE_RUNNER_IMPACT_FIX_A

```

## BUMPED_GRACE_AND_REPEATABILITY_FIX_0.5.9.md

- SHA-256: `4D9A8EBE69259FB0662C1A4E765ACA88061A349D8E03AADF6A3CA5EAE663F4DD`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Bumped Grace And Repeatability Fix 0.5.9

VERSION=0.5.9
INTERNAL_VERSION=0.5.9-b42-repeatable-runner-impact-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_059_REPEATABLE_RUNNER_IMPACT_FIX_A

## Purpose

This version fixes the 0.5.8 failure where a successful shoulder impact was followed by player `Bumped`, and the watchdog disabled the entire module.

The visible impact route from 0.5.8 is preserved:

- `SHOULDER_IMPACT_METHOD=STAGGER_KNOCKDOWN_REPEATABLE`
- fallback remains `AUTO_BEST_AVAILABLE`
- log route remains `[XNP IMPACT REACTION] type=stagger_knockdown result=ok`

## Player Recovery Policy

Configured values:

- `PLAYER_BUMP_IS_FATAL=false`
- `PLAYER_BUMP_GRACE_WINDOW=0.65`
- `PLAYER_CONTROL_LOSS_MAX_TIME=0.75`
- `PLAYER_SPEED_STALL_MAX_TIME=0.75`
- `PLAYER_RECOVERY_DISABLE_ON_TRUE_FATAL=true`
- `PLAYER_RECOVERY_LOG_ONCE_PER_IMPACT=true`
- `PLAYER_ALLOW_SHORT_BUMPED=true`
- `PLAYER_DISABLE_ON_FALL=true`
- `PLAYER_DISABLE_ON_ONFLOOR=true`
- `PLAYER_DISABLE_ON_KNOCKEDDOWN=true`
- `PLAYER_RECOVERY_ATTEMPT_ENABLED=false`

Short `Bumped` enters `WATCHDOG_GRACE`, logs once, and returns to `READY` when resolved.

True fatal states still disable:

- `Fall`
- `OnFloor`
- `KnockedDown`
- Lua exception
- `BumpedTimeout` beyond the configured grace window

## Repeat Trigger Controls

Configured values:

- `SHOULDER_CHECK_COOLDOWN=1.10`
- `SHOULDER_SAME_ZOMBIE_COOLDOWN=2.50`
- `SHOULDER_REQUIRE_EXIT_RADIUS_BEFORE_RETRIGGER=true`
- `SHOULDER_REARM_EXIT_RADIUS=1.75`
- `SHOULDER_TARGET_LOCK_TIME=0.80`
- `SHOULDER_MIN_TRIGGER_DISTANCE=0.75`
- `SHOULDER_MAX_TRIGGER_DISTANCE=1.25`
- `SHOULDER_CHECK_FRONT_DOT_MIN=0.35`

Expected diagnostic logs:

- `blocked_too_close`
- `blocked_same_zombie_cooldown`
- `rearmed exit_radius=true`
- `target_lock active` through summary field `target_lock_active`

## State Machine

- `READY`: can attempt impact.
- `COOLDOWN`: impact happened; global cooldown active.
- `WATCHDOG_GRACE`: player is briefly bumped after impact; not fatal yet.
- `DISABLED_FATAL`: true fatal condition or Lua exception; attempts stop.

Only `DISABLED_FATAL` permanently stops attempts in the current session.

## Endurance

Configured cost:

- `SHOULDER_IMPACT_ENDURANCE_COST=0.025`
- `SHOULDER_COST_REFUND_IGNORE_WINDOW=0.35`

Logs format cost and endurance with bounded decimal output to avoid raw floating-point tails.

## Deliberate Non-Goals

- No game launch.
- No Steam launch.
- No user mods write.
- No save write.
- No Workshop write.
- No detect-only regression.
- No deletion of the working `stagger_knockdown` path.

```

## FINAL_REPORT.md

- SHA-256: `47E2F909C723DFEF48FBD2B8498CDE53C6DC83D2BAD969678C34D7F1528CA21F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.9

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

## Identity

- VERSION=0.5.9
- INTERNAL_VERSION=0.5.9-b42-repeatable-runner-impact-fix-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_059_REPEATABLE_RUNNER_IMPACT_FIX_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.9 Repeatable Runner Impact Fix
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

## 0.5.8 Accepted Runtime Result

- 0.5.8 loaded build: `XNP_PZ_DISTANCE_TRAIT_058_AGGRESSIVE_RUNNER_IMPACT_A`
- Config loaded: PASS
- Trait detection: PASS
- Visible impact: PASS
- Visible route: `stagger_knockdown`
- Repeat trigger after player bump: FAIL
- Failure cause: `WATCHDOG_TREATS_BUMPED_AS_FATAL_AND_DISABLES_MODULE`

## 0.5.9 Main Change

0.5.9 keeps the working 0.5.8 visible zombie impact and changes player watchdog/retrigger behavior.

Implemented:

- `PLAYER_BUMP_IS_FATAL=false`
- short `Bumped` grace window
- true fatal-state disable only
- repeat trigger cooldowns
- same-zombie cooldown
- exit-radius rearm
- target lock
- distance gate
- bounded endurance logging

## State Machine

- `READY`
- `COOLDOWN`
- `WATCHDOG_GRACE`
- `DISABLED_FATAL`

Only `DISABLED_FATAL` stops future attempts.

## Impact Route

- SHOULDER_IMPACT_METHOD=STAGGER_KNOCKDOWN_REPEATABLE
- SHOULDER_IMPACT_FALLBACK_METHOD=AUTO_BEST_AVAILABLE
- Visible log preserved: `[XNP IMPACT REACTION] type=stagger_knockdown result=ok`

This source is not detect-only.

## Repeatability Controls

- SHOULDER_CHECK_COOLDOWN=1.10
- SHOULDER_SAME_ZOMBIE_COOLDOWN=2.50
- SHOULDER_REQUIRE_EXIT_RADIUS_BEFORE_RETRIGGER=true
- SHOULDER_REARM_EXIT_RADIUS=1.75
- SHOULDER_TARGET_LOCK_TIME=0.80
- SHOULDER_MIN_TRIGGER_DISTANCE=0.75
- SHOULDER_MAX_TRIGGER_DISTANCE=1.25
- SHOULDER_CHECK_FRONT_DOT_MIN=0.35

Diagnostic fields/logs:

- `blocked_too_close`
- `blocked_same_zombie_cooldown`
- `blocked_not_rearmed`
- `target_lock_active`
- `rearmed exit_radius=true`

## Safety Constraints

- Did not start Project Zomboid.
- Did not start Steam.
- Did not write user mods.
- Did not write saves.
- Did not write Workshop.
- Did not write game install directory.
- Did not modify 0.5.8 old source.
- Did not enable formal distance-runner gameplay.

## Current File Tree Summary

- `mod.info`
- `42/mod.info`
- `42/media/lua/client/XNP_PZ_DistanceRunner/`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/`
- `42/media/textures/`
- documentation reports in source root

## Final Counts

- Total files: 122
- Lua files: 13
- Lua total lines: 1720
- Markdown files: 102

## Static Check Result

- Lua 5.1 execution syntax check: `NOT_VERIFIABLE_NO_RELIABLE_LUA_5_1_INTERPRETER`
- Static text scan: PASS
- Forbidden speed backend modification: not found
- Coordinate modification: not found
- Time speed modification: not found
- Root media/lua layout error: not found
- Build 42 media/lua layout: present

## Runtime Verification Required

The following must be validated in game:

- short `Bumped` resolves without disabling module;
- secon
[EXCERPT_TRUNCATED]
```

## REPEATABLE_RUNNER_IMPACT_TEST_0.5.9.md

- SHA-256: `1EDD2ED604EAC4EE509E6B91A87A9BD8660F6B5C519DDC06937A012A1C26248E`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Repeatable Runner Impact Test 0.5.9

## Test Goal

Verify that the 0.5.8 visible shoulder impact remains visible and that 0.5.9 no longer disables itself after short player `Bumped`.

## Expected Build

- Display name: `XNP Distance Runner Trait 0.5.9 Repeatable Runner Impact Fix`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_059_REPEATABLE_RUNNER_IMPACT_FIX_A`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## Setup

Use a character with the native XNP Distance Runner trait.

Do not compare against 0.5.8 in the same save session unless the old mod is removed first.

## Expected Logs

On load:

- `XNP_PZ_DISTANCE_TRAIT_059_REPEATABLE_RUNNER_IMPACT_FIX_A`
- config loaded from shared config
- trait detection success

On successful impact:

- `[XNP IMPACT REACTION] type=stagger_knockdown result=ok`
- `[XNP IMPACT] trigger method=STAGGER_KNOCKDOWN_REPEATABLE ... visible_effect=stagger_knockdown`

After short player bump:

- `[XNP IMPACT WATCHDOG] bumped_grace active`
- `[XNP IMPACT WATCHDOG] bumped_resolved`

Repeatability controls:

- `blocked_too_close` when the target is inside `0.75`
- `blocked_same_zombie_cooldown` when re-hitting the same zombie too quickly
- `rearmed exit_radius=true` after backing out beyond `1.75`

## Pass Criteria

PASS if:

1. First impact visibly staggers or knocks down the zombie.
2. Player `Bumped` does not immediately disable the module.
3. Attempts continue after the grace window resolves.
4. A second impact can trigger after cooldown/rearm rules are satisfied.
5. No per-frame disabled log spam appears.

## Fail Criteria

FAIL if:

- module disables immediately on short `Bumped`;
- summary repeatedly shows `DISABLED_FATAL` after non-fatal bump;
- no second impact can trigger after backing out and re-entering;
- visible route regresses to detect-only;
- `stagger_knockdown` no longer appears in logs.

## Stop Testing Conditions

Stop and report the exact console lines if:

- `PLAYER_BUMP_TIMEOUT` appears after a normal short bump;
- `PLAYER_TRUE_FATAL_Fall`, `PLAYER_TRUE_FATAL_OnFloor`, or `PLAYER_TRUE_FATAL_KnockedDown` appears without the player visibly falling;
- Lua exception disables the module.

```

## STATIC_AUDIT.md

- SHA-256: `8DD1DC3490A04E268071662C6181E9FB6CE634D6C56A444C153592F93DA06729`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.9

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
BASE_SOURCE=[LOCAL_PATH_REDACTED]

## Scope

Created an independent 0.5.9 source tree from 0.5.8 and changed only the copied 0.5.9 source.

No game directory, user mods directory, save directory, Workshop directory, or 0.5.8 source was modified.

## Metadata

- Version: `0.5.9`
- Internal version: `0.5.9-b42-repeatable-runner-impact-fix-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_059_REPEATABLE_RUNNER_IMPACT_FIX_A`
- Display name: `XNP Distance Runner Trait 0.5.9 Repeatable Runner Impact Fix`
- Mod ID unchanged: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID unchanged: `XNPDistanceRunnerTrait:XNPDistanceRunner`

## Lua Static Checks

- Lua syntax execution: `NOT_VERIFIABLE_NO_RELIABLE_LUA_5_1_INTERPRETER`
- Total file count after documentation update: `122`
- Lua file count: `13`
- Lua total lines: `1720`
- Markdown file count: `102`
- Root `media/lua`: absent
- Build 42 `42/media/lua`: present
- Duplicate active mod ID: none introduced
- Duplicate active trait ID: none introduced
- Active `ThePlayer` state source: not found in active Lua scan
- Active coordinate modification: not found
- Active time speed modification: not found
- Active speed backend modification: not found
- Active formal distance runner gameplay: not enabled

## Required 0.5.9 Config Values

- `PLAYER_BUMP_IS_FATAL=false`
- `PLAYER_BUMP_GRACE_WINDOW=0.65`
- `PLAYER_CONTROL_LOSS_MAX_TIME=0.75`
- `PLAYER_SPEED_STALL_MAX_TIME=0.75`
- `PLAYER_RECOVERY_DISABLE_ON_TRUE_FATAL=true`
- `PLAYER_RECOVERY_LOG_ONCE_PER_IMPACT=true`
- `PLAYER_ALLOW_SHORT_BUMPED=true`
- `PLAYER_DISABLE_ON_FALL=true`
- `PLAYER_DISABLE_ON_ONFLOOR=true`
- `PLAYER_DISABLE_ON_KNOCKEDDOWN=true`
- `PLAYER_RECOVERY_ATTEMPT_ENABLED=false`
- `SHOULDER_CHECK_COOLDOWN=1.10`
- `SHOULDER_SAME_ZOMBIE_COOLDOWN=2.50`
- `SHOULDER_REQUIRE_EXIT_RADIUS_BEFORE_RETRIGGER=true`
- `SHOULDER_REARM_EXIT_RADIUS=1.75`
- `SHOULDER_TARGET_LOCK_TIME=0.80`
- `SHOULDER_MIN_TRIGGER_DISTANCE=0.75`
- `SHOULDER_MAX_TRIGGER_DISTANCE=1.25`
- `SHOULDER_CHECK_FRONT_DOT_MIN=0.35`
- `SHOULDER_IMPACT_METHOD=STAGGER_KNOCKDOWN_REPEATABLE`
- `SHOULDER_IMPACT_FALLBACK_METHOD=AUTO_BEST_AVAILABLE`
- `SHOULDER_IMPACT_ENDURANCE_COST=0.025`
- `SHOULDER_COST_REFUND_IGNORE_WINDOW=0.35`

## Preserved Visible Impact Route

The active impact implementation still calls the `stagger_knockdown` route before fallback:

- `zombie:setStaggerBack(true)`
- `zombie:setKnockedDown(true)` or `zombie:knockDown(false)`
- log: `[XNP IMPACT REACTION] type=stagger_knockdown result=ok`

This is not a detect-only build.

## Bumped Watchdog Audit

Short `Bumped` is no longer treated as immediate fatal.

The watchdog now:

- enters `WATCHDOG_GRACE` on short bump;
- logs `bumped_grace active` once per impact;
- logs `bumped_resolved` when the state clears;
- disables only for configured true fatal states or bump timeout.

Fatal disable states:

- `PLAYER_TRUE_FATAL_Fall`
- `PLAYER_TRUE_FATAL_OnFloor`
- `PLAYER_TRUE_FATAL_Knocke
[EXCERPT_TRUNCATED]
```
