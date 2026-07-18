# 0.5.8 Sanitized Evidence Excerpts

## 0.5.8_REPEAT_TRIGGER_FAILURE_ANALYSIS.md

- SHA-256: `56A45F7281251B65458959BC59F7A4D7EF97FC984C6A6D291E835FB90DBD4CBF`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.8 Repeat Trigger Failure Analysis

## Problem

0.5.8 proved that the visible impact route can affect zombies, but the module disabled itself after player `Bumped`.

The bad behavior was not a missing trait, not a config-load problem, and not a lack of visible zombie reaction.

## Actual Failure Chain

1. Player runs into target.
2. Zombie receives `stagger_knockdown` route successfully.
3. Player briefly enters a bump/control-loss state.
4. Watchdog interprets `Bumped` as fatal.
5. Module enters disabled state.
6. Future attempts stay at zero and repeat impact cannot trigger.

## Why This Is Wrong

Short `Bumped` is expected after a shoulder impact. It is not equivalent to:

- player death
- player on floor
- true knockdown
- fall state
- Lua exception

Treating `Bumped` as fatal makes the first successful impact self-disable the feature.

## 0.5.9 Fix Direction

- Add `PLAYER_BUMP_IS_FATAL=false`.
- Allow short `Bumped` with a grace window.
- Disable only on true fatal states.
- Keep one disabled summary every 10 seconds when fatal-disabled.
- Keep repeat trigger state separate from player recovery watchdog.

## Frozen Result Labels

- `0.5.8_VISIBLE_IMPACT_RESULT=PASS_FIRST_HIT_GOOD`
- `0.5.8_REPEAT_TRIGGER_RESULT=FAIL_AFTER_PLAYER_BUMPED`
- `0.5.8_FAILURE_CAUSE=WATCHDOG_TREATS_BUMPED_AS_FATAL_AND_DISABLES_MODULE`

```

## 0.5.8_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `0BEE6B36C52D31AA1EE6481BF860D9564D634C5397D68962D7EB4C651023024B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.8 Real Game Result Summary

SOURCE_VERSION=0.5.8
LOADED_BUILD=XNP_PZ_DISTANCE_TRAIT_058_AGGRESSIVE_RUNNER_IMPACT_A

## Accepted Runtime Facts

- Config loaded: PASS
- Native trait detection: PASS
- First visible impact: PASS
- Second visible impact before disable: PASS
- Visible reaction route: `stagger_knockdown`
- Runtime log evidence:
  - `[XNP IMPACT REACTION] type=stagger_knockdown result=ok`
  - `visible_effect=stagger_knockdown`

## Failure After Impact

The player-side recovery watchdog treated the player's `Bumped` state as a fatal recovery failure.

Observed result:

- `player_recovery triggered reason=Bumped`
- module disabled with `PLAYER_STATE_RECOVERY_FAILED`
- attempts became `0` after disable

## Frozen Conclusion

- `0.5.8_VISIBLE_IMPACT_RESULT=PASS_FIRST_HIT_GOOD`
- `0.5.8_REPEAT_TRIGGER_RESULT=FAIL_AFTER_PLAYER_BUMPED`
- `0.5.8_FAILURE_CAUSE=WATCHDOG_TREATS_BUMPED_AS_FATAL_AND_DISABLES_MODULE`

## Meaning For 0.5.9

0.5.9 must preserve the working visible zombie impact route and only fix repeatability/control-loss handling.

Do not revert to detect-only.
Do not remove `stagger_knockdown`.
Do not treat short player `Bumped` as fatal.

```

## AGGRESSIVE_RUNNER_IMPACT_TEST_0.5.8.md

- SHA-256: `D5A649E7D36BD33A8E9505185144E3CDBC1BBD2FBD784CE2A42A4EBD08E36D02`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Aggressive Runner Impact Test 0.5.8

1. 绂佺敤 0.5.7銆?.5.6銆?.5.5 鍜屾墍鏈夋棫鐗堟湰銆?2. 鍙惎鐢?0.5.8 鍜?B42Trans_CN銆?3. 瀹屽叏閲嶅惎娓告垙銆?4. console 鎼滐細`XNP_PZ_DISTANCE_TRAIT_058_AGGRESSIVE_RUNNER_IMPACT_A`銆?5. 纭涓嶆槸 0.5.7銆?6. 杩涘叆鎷ユ湁闀块€斿琚€呯殑瑙掕壊銆?7. 纭浜虹墿淇℃伅闈㈡澘榛勮壊 F 鐗硅川瀛樺湪銆?8. 涓嶈娴嬭瘯鍙充笂瑙掑浘鏍囷紱鏈疆 UI deferred銆?9. 鎵句竴鍙椿鍍靛案銆?10. 璁╁兊灏镐綅浜庢鍓嶆柟 1 鍒?1.2 鏍笺€?11. 鎸変綇璺戞鍐插悜鍍靛案銆?12. 瑙傚療鍍靛案鏄惁鍑虹幇鍚庝话銆佽笁璺勩€佸€掑湴銆佽鎺ㄥ嚭鍘汇€丄I 鐭殏鍋滈】鎴栧彈鍑诲姩鐢汇€?13. 瑙傚療鐜╁鏄惁缁х画璺戙€?14. 纭鐜╁娌℃湁鍊掑湴銆?15. 纭鐜╁娌℃湁鏄庢樉鍑忛€熴€?16. 纭鐜╁娌℃湁闀跨‖鐩淬€?17. 鏌ョ湅 console 鏄惁鏈夛細

```text
[XNP CONFIG] loaded
[XNP IMPACT] method=
[XNP IMPACT] trigger
[XNP IMPACT SUMMARY]
```

18. 濡傛灉浣跨敤寰綅绉伙紝鏌ョ湅锛歚[XNP IMPACT NUDGE]`銆?19. 濡傛灉浣跨敤鍔ㄧ敾鍙橀噺锛屾煡鐪嬶細`[XNP IMPACT ANIM]`銆?20. 濡傛灉浣跨敤鍙楀嚮/鍊掑湴锛屾煡鐪嬶細`[XNP IMPACT REACTION]`銆?21. 濡傛灉鐜╁杩涘叆鍗遍櫓鐘舵€侊紝鏌ョ湅锛歚[XNP IMPACT] player_recovery`銆?22. 濡傛灉妯″潡 disabled锛岃褰?reason銆?23. 纭娌℃湁锛?
```text
IsoZombie cannot be cast to IsoPlayer
BumpedState
RunningShove
player:hasTrait
CharacterTraitDefinition
GameTime:setMultiplier
HaloTextHelper
BodyDamage
MuscleStrain
```

24. 鎶?console.txt 浜ゅ洖銆?
```

## BUILD_MARKER.txt

- SHA-256: `96EAC674BF485DB625C5DB892237528FBDDF4A0F7410F4BD8B5EE4EBBBE2756F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_058_AGGRESSIVE_RUNNER_IMPACT_A

```

## CONFIG_LOAD_FIX_0.5.8.md

- SHA-256: `62C5AA28736C5B9841A79DBD2CCFC367D01EB31069BA8EB0F3ACCC7AF37A5FD3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Config Load Fix 0.5.8

## 0.5.7 problem

0.5.7 logged:

```text
[XNP CONFIG] fallback_defaults_used=true
```

Cause: `XNP_DR_Config.lua` built `Config` from `Core.Config or {}` and then filled every default field into an empty table. On a normal first load, this made `fallbackUsed=true`, even though the config file itself loaded successfully.

## 0.5.8 fix

0.5.8 now creates a concrete config table from defaults during normal load and logs:

```text
[XNP CONFIG] loaded path=42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua source=shared_config
```

Fallback is now reserved for runtime missing-key access through `Config.Get(key)`:

```text
[XNP CONFIG] fallback_defaults_used=true reason=missing_key_<key>
```

## Path

```text
42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
```

CONFIG_LOAD_STATUS=FIXED_STATIC
CONFIG_LOAD_REASON=0.5.7 false-positive fallback removed

```

## FINAL_REPORT.md

- SHA-256: `F8176067545D84EDEB739412A96151B3B9B7DD681497482282B0066F9086F6A3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.8

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.8

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_058_AGGRESSIVE_RUNNER_IMPACT_A

## 0.5.7 facts

0.5.7_LOAD_RESULT=PASS

0.5.7_TRAIT_RESULT=PASS

0.5.7_SHOULDER_DETECTION_RESULT=PASS

0.5.7_VISIBLE_EFFECT_RESULT=FAIL_BECAUSE_DETECT_ONLY_NO_PHYSICS

0.5.7_CONFIG_RESULT=FALLBACK_USED_NEEDS_FIX

## Local scan

LOCAL_MOD_SCAN_STATUS=COMPLETE_STATIC_READ_ONLY

LOCAL_MOD_SCAN_PATHS=[LOCAL_PATH_REDACTED]

THIRD_PARTY_CODE_COPY_STATUS=NO_CONTIGUOUS_5_LINE_COPY

## Config

CONFIG_LOAD_STATUS=FIXED_STATIC

CONFIG_LOAD_REASON=0.5.7 normal-load fallback false positive removed

CONFIG_FILE_PATH=42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua

Expected log:

```text
[XNP CONFIG] loaded path=42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua source=shared_config
```

## Shoulder Impact

SHOULDER_IMPACT_METHOD=AUTO_BEST_AVAILABLE

SHOULDER_IMPACT_AUDIT_RESULT=MICRO_POSITION_NUDGE_EXPERIMENT

SHOULDER_IMPACT_VISIBLE_EFFECT_TARGET=zombie stagger/knockdown/hit reaction/micro nudge

SHOULDER_IMPACT_TRIGGER_RADIUS=1.20

SHOULDER_IMPACT_FRONT_DOT_MIN=0.35

SHOULDER_IMPACT_COOLDOWN=0.85

SHOULDER_IMPACT_ENDURANCE_COST=0.015 base, raised to at least 0.025 when knockdown or micro nudge routes are enabled

ZOMBIE_HIT_REACTION_ENABLED=true

ZOMBIE_KNOCKDOWN_ENABLED=true

ZOMBIE_ANIM_VARIABLE_ENABLED=true

MICRO_NUDGE_ENABLED=true

MINIMAL_DAMAGE_HIT_REACTION_ENABLED=true

MICRO_NUDGE_DISTANCE=0.35

MICRO_NUDGE_RELEASE_STATUS=EXPERIMENTAL_NOT_RELEASE_SAFE

PLAYER_RECOVERY_WATCHDOG_ENABLED=true

PLAYER_FALL_ALLOWED=false

PLAYER_SPEED_REDUCTION_ALLOWED=false

PLAYER_BODY_DAMAGE_ALLOWED=false

ZOMBIE_DAMAGE_ALLOWED=only minimal experimental 0.01 fallback

SHOULDER_IMPACT_CAN_KILL=false

## Preserved core

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

ADRENALINE_TRIGGER_RADIUS=4.0

ADRENALINE_MEMORY_DURATION=20.0

## UI/status

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED

MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED

HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET

COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET

VISUAL_FEEDBACK_METHOD=DEFERRED_NOT_ABANDONED

RIGHT_TOP_ICON_STATUS=DEFERRED_NOT_ABANDONED

STATUS_MOODLE_METHOD=DEFERRED_NOT_ABANDONED

## Movement safety

MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

RUNNING_SHOVE_STATUS=DISABLED

BUMPED_STATE_STATUS=DISABLED

鏄惁淇敼鏃?SOURCE=NO

鏄惁鍚姩娓告垙=NO

鏄惁鍐欑敤鎴?mods=NO

鏄惁鍐欐父鎴忕洰褰?NO

鏄惁鍐?saves=NO

鏄惁鍐?Workshop=NO

## Counts

Lua 鏂囦欢鏁伴噺=13

Lua 鎬昏鏁?1724

Markdown 鏂囨。鏁伴噺=98

鎬绘枃浠舵暟閲?118

闈欐€佹鏌ョ粨鏋?STATIC_BLOCKER_NONE

## NOT_VERIFIABLE

- Lua 5.1 syntax execution: NOT_VERIFIABLE
- Real-game visible impact: NOT_VERIFIABLE
- Multiplayer/network synchronization: NOT_VERIFIABLE
- Long-run stability of zombie state writes: NOT_VERIFIABLE

BLOCKER=NONE

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.8_SOURCE_READY_FOR_AGGRESSIVE_RUNNER_IMPACT_TEST

```

## ICON_AND_MOODLE_DEFERRED_PLAN_0.5.8.md

- SHA-256: `8A7BF731C9A04B9E9A1AB9D2265E3C6D525415905D07254879B05E0D78C7EA97`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Icon and Moodle Deferred Plan 0.5.8

## Status

```text
ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
```

## Why temporarily disabled

Earlier 0.5.x work found that:

- coordinate fake icons drifted or did not align reliably with the vanilla UI;
- Halo feedback produced poor text-only results and did not satisfy the desired status-feedback goal;
- true Moodle registration still needs a separate B42-specific implementation pass.

## Not abandoned

Icons, Moodles, and status feedback remain future feature lines. 0.5.8 does not implement them because the current target is visible runner impact behavior.

## Later plan

The next UI/status branch should scan B42 UI and Moodle examples separately, then implement one focused version for real icon/status feedback without restoring the failed coordinate-icon or HaloTextHelper route.

```

## LOCAL_MOD_SCAN_REPORT_0.5.8.md

- SHA-256: `C799695453262F7D8113FB2E337AC95F1C027F71373B2A3073C9D900DD16D863`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Local Mod Scan Report 0.5.8

## Scanned paths

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`

## User XNP samples

- `XNP_PZ_DistanceRunnerTrait_0.4.16_B42_PASSIVE_RUNNER_SHOVE_SOURCE`
  - Found old `RunningShove` route using zombie bump variables and bump type.
  - This route is not reused because old real-game branches showed unsafe state/cast failures.
- `XNP_PZ_DistanceRunnerTrait_0.4.10` to `0.4.13`
  - Found coordinate-based fake status icon experiments.
  - Not reused in 0.5.8.
- `XNP_PZ_DistanceRunnerTrait_0.5.7`
  - Used as base for distance/front-dot target detection.

## Third-party references

- `[LOCAL_PATH_REDACTED]`
  - Shows `getHitReaction`, action state, target, and attacker logging around zombie death/hit observations.
- `[LOCAL_PATH_REDACTED]`
  - Shows B42 mod usage of direct zombie stagger/knockdown style calls.
- `[LOCAL_PATH_REDACTED]`
  - Shows direct use of low-level zombie state/hit force methods.
- UI references found in third-party display-bar and trait mods, but 0.5.8 does not implement UI.

## Game API names worth testing

- `IsoZombie:setStaggerBack(boolean)`
- `IsoGameCharacter:setKnockedDown(boolean)`
- `IsoZombie:knockDown(boolean)`
- `IsoGameCharacter:setHitReaction(string)`
- `IsoMovingObject:setHitForce(float)`
- `IsoMovingObject:setX(float)`
- `IsoMovingObject:setY(float)`
- `IsoGameCharacter:setVariable(key, value)`
- `IsoGameCharacter:Hit(...)`

## Code reuse status

- User-owned 0.5.7 target detection structure was reused conceptually and rewritten into `XNP_DR_ShoulderImpact.lua`.
- Third-party code copied continuously over 5 lines: NO.
- Third-party code copied as implementation: NO.

THIRD_PARTY_CODE_COPY_STATUS=NO_CONTIGUOUS_5_LINE_COPY

```

## B42_19_IMPACT_ANIMATION_AND_KNOCKBACK_AUDIT_0.5.8.md

- SHA-256: `FAC71F79887B1925EFAA3123BC9245576EA0A7CC0709D4DE6EB680C80936E5D0`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Impact Animation and Knockback Audit 0.5.8

## Static evidence

Java signatures expose:

- `IsoZombie:setStaggerBack(boolean)`
- `IsoZombie:knockDown(boolean)`
- `IsoGameCharacter:setKnockedDown(boolean)`
- `IsoGameCharacter:setHitReaction(string)`
- `IsoMovingObject:setHitForce(float)`
- `IsoMovingObject:setX(float)`
- `IsoMovingObject:setY(float)`
- `IsoGameCharacter:setVariable(key, value)`
- `IsoGameCharacter:Hit(...)`

Lua and Workshop samples show hit reaction logging and third-party use of direct stagger/knockdown-style methods, but no fully validated vanilla runner-collision API was found.

## Required answers

1. Original player-zombie bump state chain exists: YES, but previous XNP branches proved it is risky.
2. State/animation causing player fall: bump / fall / hit-reaction style player states are the danger zone.
3. Trigger zombie reaction without player fall: POSSIBLE_EXPERIMENTALLY through zombie-only methods, not proven release-safe.
4. Lua trigger IsoZombie hit reaction: ZOMBIE_HIT_REACTION_REUSABLE as experiment.
5. Lua trigger IsoZombie knockdown/on-floor: ZOMBIE_KNOCKDOWN_REUSABLE as experiment.
6. Animation variable route: ZOMBIE_ANIM_VARIABLE_REUSABLE as experiment.
7. pcall safety: YES for Lua errors, NO for guaranteeing network/gameplay safety.
8. Requires IsoPlayer type: the selected 0.5.8 routes do not intentionally pass zombie into player-only state code.
9. Triggers BumpedState: 0.5.8 does not call BumpedState or RunningShove.
10. IsoZombie cannot be cast to IsoPlayer risk: reduced by avoiding player-state bump route.
11. Original vanilla sample: no clean high-level Lua API found.
12. User old sample: 0.4.16 RunningShove found but not reused.
13. Third-party B42 sample: direct low-level methods found; used as API reference only.
14. Recommended route: AUTO_BEST_AVAILABLE with zombie-only stagger/knockdown, hit reaction, anim variable, micro nudge, and minimal damage fallback.

## Selected conclusions

```text
ZOMBIE_HIT_REACTION_REUSABLE
ZOMBIE_KNOCKDOWN_REUSABLE
ZOMBIE_ANIM_VARIABLE_REUSABLE
MICRO_POSITION_NUDGE_EXPERIMENT
DETECT_ONLY_STILL_REQUIRED=false
NO_SAFE_ROUTE=false
```

## Release status

These routes are experimental:

```text
EXPERIMENTAL_NOT_RELEASE_SAFE
```

```

## STATIC_AUDIT.md

- SHA-256: `4A9A451F66A525CCF6C0A14F0EDC563E588F279955D89027AA50C39FC215BA9E`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.8

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

## Counts

- Lua files: 13
- Lua total lines: 1724
- Markdown files: 98
- Total files: 118
- JSON parse: PASS

## Layout

- Root `media/lua`: ABSENT
- `42/media/lua`: PRESENT
- `42/media/scripts/XNPDistanceRunnerTraits.txt`: PRESENT
- `42/media/ui/Traits/trait_xnpdistancerunner.png`: PRESENT

## Lua execution syntax

NOT_VERIFIABLE: no reliable local `lua` or `luac` command was available. No download or install was attempted.

## Preserved systems

- Trait full ID unchanged.
- CharacterTrait object detection route unchanged.
- 0.5.7 shoulder distance/front-dot logic preserved inside `XNP_DR_ShoulderImpact.lua`.
- Stamina refund core preserved.
- Adrenaline distance core preserved.
- Config fallback false-positive fixed.
- Icon/Moodle status changed to `DEFERRED_NOT_ABANDONED`.

## Forbidden active Lua scan

PASS: no active Lua call found for:

- `player:hasTrait("...")`
- `TraitFactory`
- runtime `CharacterTraitDefinition`
- `setFastMoveCheat`
- `setSpeedMod`
- `setMoveSpeed`
- `setPathSpeed`
- `setCombatSpeed`
- player coordinate writes
- `GameTime:setMultiplier`
- `RunningShove`
- `BumpedState`
- right-top coordinate fake icon
- 8-second probe
- active `HaloTextHelper`
- active `player:Say`
- custom status `ISPanel`
- per-frame detailed zombie logs
- direct Calories/Hunger/Fatigue/Pain/Stress writes
- direct BodyDamage/BodyPart/MuscleStrain/Wound/Bleeding/Infection writes

## Allowed experimental calls

The following calls exist only in:

```text
42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ShoulderImpact.lua
```

They are experimental and documented as not release-safe:

- `zombie:setHitReaction("StaggerBack")`
- `zombie:setHitForce(2.0)`
- `zombie:setStaggerBack(true)`
- `zombie:setKnockedDown(true)`
- `zombie:knockDown(false)`
- `zombie:setVariable("ZombieHitReaction", "StaggerBack")`
- `zombie:setVariable("BumpFall", true)`
- `zombie:setX(toX)`
- `zombie:setY(toY)`
- `zombie:Hit(nil, player, 0.01, false, 0)`

Required safeguards present:

- only in 0.5.8 experiment module
- gated by config
- pcall wrapped
- one zombie per trigger
- same z check
- passable target square check for micro nudge
- no player coordinate writes
- `EXPERIMENTAL_NOT_RELEASE_SAFE` load log

## Player recovery watchdog

Present in `XNP_DR_ShoulderImpact.lua`.

- Runs only after an impact trigger for `PLAYER_RECOVERY_WINDOW=0.50`.
- Does not write BodyDamage.
- Does not move player coordinates.
- Uses get-up/run variables only if dangerous player state is detected.
- Disables ShoulderImpact on recovery failure.

## File hygiene

- Empty files: none found.
- Text BOM: none found.
- Text NULL: none found.

## Directory safety

- Old SOURCE modified: NO
- Project Zomboid launched: NO
- Steam launched: NO
- User mods written: NO
- Saves written: NO
- Workshop written: NO
- Game directory written: NO

## NOT_VERIFIABLE

- Lua 5.1 syntax execution.
- Real-game visible e
[EXCERPT_TRUNCATED]
```
