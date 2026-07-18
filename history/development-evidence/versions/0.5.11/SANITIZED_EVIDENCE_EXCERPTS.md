# 0.5.11 Sanitized Evidence Excerpts

## BREAKOUT_PUSH_DESIGN_0.5.11.md

- SHA-256: `C2803467AFEE1FEAD3D84735FDBC7A9E5AE6DF6925AA4B11BE79580C60C948AC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Breakout Push Design 0.5.11

## Mechanism

Name: `Breakout Push`

Chinese label: `闀块€斿琚€咃細鐮村洿鎺ㄥ紑`

This is not a range knockdown skill. It is an escape/breakout action for a Distance Runner who is still trying to move through contact, grab, face-block, or crowd pressure.

## Trigger Mode

- `BREAKOUT_TRIGGER_MODE=CONTACT_OR_GRAB_TRIGGER`
- `DISABLE_RANGE_ONLY_TRIGGER=true`
- `REQUIRE_CONTACT_OR_GRAB=true`

Trigger layers:

- `CONTACT`: player has movement intent and contacts a zombie at `0.35` to `1.15`.
- `SPRINT`: sprinting contact; zombie-side only, no player bump chain.
- `GRAB`: player is bumped/collided/grab-like/attack-like and zombie is within `0.85`.
- `CROWD`: player movement is stalled and nearby zombie count is at least `2`; selected zombie count is capped at `2`.

## Effect Route

Default:

- `BREAKOUT_PUSH_METHOD=ZOMBIE_SIDE_PUSH_REACTION`

Route components:

- zombie `setHitReaction("StaggerBack")`
- zombie `setStaggerBack(true)`
- zombie `setHitForce(1.5)`
- zombie-side micro nudge
- optional zombie `setTarget(nil)` interrupt

No player trip/fall/bump state writes are used.

## Push Vector

Priority:

- `PLAYER_FORWARD`
- `PLAYER_TO_ZOMBIE`
- `BREAKOUT_AWAY_FROM_PLAYER`

Logs include:

- `push_vector_source=PLAYER_FORWARD`
- `push_vector_source=PLAYER_TO_ZOMBIE`
- `push_vector_source=BREAKOUT_AWAY_FROM_PLAYER`

## Costs

- `CONTACT_PUSH_ENDURANCE_COST=0.025`
- `SPRINT_PUSH_ENDURANCE_COST=0.035`
- `GRAB_BREAKOUT_ENDURANCE_COST=0.060`
- `CROWD_BREAKOUT_ENDURANCE_COST=0.075`
- `BREAKOUT_COST_REFUND_IGNORE_WINDOW=0.50`

## Explicitly Removed

- the failed read-only bump variable write route
- player bump-state chain
- player fall/trip route
- range-only trigger
- 0.5.10 read-only bumped variable route

## Status

`EXPERIMENTAL_NOT_RELEASE_SAFE`

```

## BREAKOUT_PUSH_TEST_0.5.11.md

- SHA-256: `63045F8C129A1085072ED33CAE566BB045F38957F07785AE805B0218736B3ED4`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Breakout Push Test 0.5.11

## Manual Test Steps

1. Disable every older Distance Runner test source.
2. Enable only this 0.5.11 source and the required translation mod.
3. Restart the game manually.
4. Confirm console contains `XNP_PZ_DISTANCE_TRAIT_0511_BREAKOUT_PUSH_A`.
5. Confirm console contains the existing Config loaded log.
6. Spawn or find one live zombie.
7. Sprint directly into close front contact.
8. Expected result: the player is not forced through the old trip chain by this module, and the zombie is pushed or staggered away from the player's front.
9. Jog into close contact.
10. Expected result: behavior is close to vanilla jog shove, driven on the zombie side.
11. Let a zombie reach face-to-face grab or attack wind-up range.
12. Expected result: GRAB breakout can trigger once if the player is not down.
13. Let multiple zombies crowd very close.
14. Expected result: CROWD breakout can trigger and selects no more than two zombies.
15. Console should contain:
    - `[XNP BREAKOUT] trigger type=CONTACT`
    - `[XNP BREAKOUT] trigger type=GRAB`
    - `[XNP BREAKOUT] trigger type=CROWD`
    - `[XNP BREAKOUT PUSH]`
    - `[XNP BREAKOUT COST]`
    - `[XNP BREAKOUT SUMMARY]`
16. Console should not show the old read-only bump warning, old shove route, old trait registration failure, halo route, time-scale route, player body stat edits, or cast errors.
17. Return `console.txt` for the next pass.

## Pass Criteria

- Contact or sprint push visibly moves or staggers zombie away from player.
- Grab breakout can trigger while player is not down.
- Player does not enter a forced trip or fall chain from this module.
- No read-only bump write warning appears.
- Costs log with four decimals.

## Fail Criteria

- Player still almost always trips while sprinting into contact.
- Only range proximity triggers without contact, grab, or crowd evidence.
- Any active Lua writes the old bump variable.
- Any active Lua writes player coordinates.

```

## BUILD_MARKER.txt

- SHA-256: `0C25F6F28009D3211E257A3EBB83D9C39E985312C9FD62A492F15AA8710866A9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0511_BREAKOUT_PUSH_A

```

## FINAL_REPORT.md

- SHA-256: `A5ADC287C6266FB8BF40B21C4D09259DC16E9FCC18CA6E273F2C3526B1C6F746`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.11

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

## Identity

- VERSION=0.5.11
- INTERNAL_VERSION=0.5.11-b42-breakout-push-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0511_BREAKOUT_PUSH_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.11 Breakout Push

## 0.5.10 Result

- `0.5.10_LOAD_RESULT=PASS`
- `0.5.10_CONFIG_RESULT=PASS`
- `0.5.10_VISIBLE_EFFECT_RESULT=FAIL_USER_SAW_ALMOST_NONE`
- `0.5.10_PLAYER_TRIP_RESULT=FAIL_PLAYER_TRIPS_TOO_OFTEN`
- `0.5.10_FAILURE_CAUSE=READ_ONLY_BUMPED_VARIABLE_AND_WRONG_PLAYER_COLLISION_CHAIN`

## Breakout Push

- `BREAKOUT_PUSH_METHOD=ZOMBIE_SIDE_PUSH_REACTION`
- `BREAKOUT_TRIGGER_MODE=CONTACT_OR_GRAB_TRIGGER`
- `CONTACT_TRIGGER_STATUS=IMPLEMENTED`
- `GRAB_BREAKOUT_STATUS=IMPLEMENTED`
- `CROWD_BREAKOUT_STATUS=IMPLEMENTED`
- `RANGE_ONLY_TRIGGER_STATUS=DISABLED`

## Removed Routes

- `BUMPED_VARIABLE_WRITE_STATUS=REMOVED`
- `VANILLA_BUMP_VARIABLE_ROUTE=DISABLED_AFTER_READ_ONLY_FAILURE`
- `PLAYER_COLLISION_CHAIN_ROUTE=DISABLED`

## Sprint Guard

- `SPRINT_IMPACT_PLAYER_TRIP_PROTECTION=true`
- `SPRINT_IMPACT_ZOMBIE_SIDE_ONLY=true`

## Breakout Effect

- `BREAKOUT_NUDGE_DISTANCE=0.45`
- `BREAKOUT_USE_ZOMBIE_HIT_REACTION=true`
- `BREAKOUT_USE_AI_INTERRUPT=true`
- `BREAKOUT_USE_MICRO_NUDGE=true`

## Costs

- `CONTACT_PUSH_ENDURANCE_COST=0.025`
- `SPRINT_PUSH_ENDURANCE_COST=0.035`
- `GRAB_BREAKOUT_ENDURANCE_COST=0.060`
- `CROWD_BREAKOUT_ENDURANCE_COST=0.075`

## UI Status

- `ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED`
- `MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED`

## Existing Systems

- `STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND`
- `ADRENALINE_TRIGGER_RADIUS=4.0`
- `ADRENALINE_MEMORY_DURATION=20.0`
- `MOVEMENT_SPEED_MODIFICATION_METHOD=NONE`
- `RUNNING_SHOVE_STATUS=DISABLED`
- `BUMPED_STATE_STATUS=DISABLED`

## Safety

- Modified old SOURCE: NO
- Started Project Zomboid: NO
- Started Steam: NO
- Wrote user mods: NO
- Wrote game directory: NO

## Counts

- Lua files: 15
- Lua total lines: 1875
- Markdown documents: 7
- Total files: 29

## Static Check

- Static check result: `PASS_WITH_RUNTIME_VERIFICATION_REQUIRED`
- JSON parse: PASS
- Text BOM/NULL scan: PASS
- Active forbidden Lua scan: PASS
- Full-tree forbidden literal grep: PASS_NOT_FOUND
- Runtime main update: `Core.BreakoutPush.Update(player)`
- NOT_VERIFIABLE:
  - `NOT_VERIFIABLE_NO_RELIABLE_LUA_5_1_INTERPRETER`
  - `NOT_VERIFIABLE_REAL_B42_RUNTIME_BREAKOUT_PUSH_EFFECT`
  - `NOT_VERIFIABLE_REAL_GRAB_STATE_COVERAGE`
  - `NOT_VERIFIABLE_ZOMBIE_AI_INTERRUPT_RUNTIME_EFFECT`

## Blocker

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.11_SOURCE_READY_FOR_BREAKOUT_PUSH_TEST

```

## B42_19_GRAB_AND_CONTACT_TRIGGER_AUDIT_0.5.11.md

- SHA-256: `1CAD05D2C3AD74CBE31CAFBE861B48F3A21E7297460AAC610AFCD34F9C8E22B0`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Grab And Contact Trigger Audit 0.5.11

## Scan Scope

Read-only scanned:

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`

Keywords included grab, grapple, bite, scratch, attack, target, hit reaction, bumped, collided, state machine, animation variables, and event names.

## Findings

Observed readable or referenceable names:

- `isBumped`
- `getActionStateName`
- `getAnimationStateName`
- `getTarget`
- `setTarget`
- `setHitReaction`
- `setStaggerBack`
- `setHitForce`
- `OnWeaponHitCharacter`
- `OnPlayerGetDamage`
- `ZombieAttack`
- `PlayerHitReaction`
- `bumped` transition definitions in zombie action groups

0.5.10 proved that writing `bumped` is not safe because it can be read-only.

## Required Answers

1. Lua-readable grabbed/attacked state:
   - CONFIRMED through read-only player action/animation state names and nearby zombie proximity.
   - Direct reliable `isGrabbed` style API was not confirmed as a stable public method.

2. Safe readable states:
   - `isBumped` if present;
   - `isOnFloor`;
   - `isKnockedDown`;
   - `isDead`;
   - `getActionStateName`;
   - `getAnimationStateName`;
   - zombie `getTarget` when present.

3. States that must not be written:
   - player `Bumped`;
   - player `BumpFall`;
   - player `FallOnFront`;
   - player `OnFloor`;
   - player `KnockedDown`;
   - zombie/player `bumped` animation variable.

4. How 0.5.11 judges close attack/grab:
   - player state text includes grab/grapple/bite/scratch/attack/hitreaction/bump/collide;
   - live zombie within `GRAB_BREAKOUT_RADIUS=0.85`;
   - nearest zombie is same-z and close enough.

5. How to judge player can still trigger:
   - player has trait;
   - not dead;
   - not OnFloor;
   - not KnockedDown;
   - not fall/trip state text.

6. Avoid triggering while down:
   - `playerIsDown` blocks OnFloor, KnockedDown, Fall, Trip, and dead.

7. Safe interrupt of zombie attack wind-up:
   - CONFIRMED AS EXPERIMENTAL by zombie-side `setTarget(nil)` and hit reaction calls, wrapped in `pcall`.
   - It does not modify player damage or body state.

8. Push zombie only:
   - CONFIRMED by using zombie-side hit reaction, stagger, hit force, and zombie-only nudge.

9. APIs likely to cause player trip and disabled:
- player bump-state chain;
   - player BumpFall;
   - player FallOnFront;
   - player OnFloor;
   - player state-machine writes;
   - player coordinate writes.

## Conclusion

- `CONTACT_OR_GRAB_TRIGGER_CONFIRMED_BY_STATIC_AUDIT`
- `SAFE_READABLE_PLAYER_DANGER_STATE_CONFIRMED`
- `PLAYER_STATE_WRITE_FORBIDDEN`
- `ZOMBIE_SIDE_PUSH_ROUTE_SELECTED`
- `RUNTIME_VALIDATION_REQUIRED`

```

## STATIC_AUDIT.md

- SHA-256: `3B684D30A86F87E5C634033BB2D46E2882AEB3FB2C0863C1B4738911D5888444`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.11

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

## Required Confirmations

- BASE_SOURCE_PATH=0.5.10: PASS
- Trait full ID unchanged: PASS
- Object-style trait detection unchanged: PASS
- Config loaded route retained: PASS
- 0.5.10 bumped variable route removed: PASS
- `VanillaImpact` is no-op and not main Update: PASS
- `BreakoutPush` is main Update: PASS
- Range-only trigger disabled: PASS
- Contact/grab/crowd trigger implemented: PASS

## Removed Failure Route

- `BUMPED_VARIABLE_WRITE_STATUS=REMOVED`
- `PLAYER_COLLISION_CHAIN_ROUTE=DISABLED`
- `VANILLA_BUMP_VARIABLE_ROUTE=DISABLED_AFTER_READ_ONLY_FAILURE`

## Active Forbidden Route Scan

Blocking routes not found in active Lua or release documents:

- failed read-only bump variable write route
- legacy string-based trait check
- legacy trait factory route
- broken runtime character-trait definition route
- `setFastMoveCheat`
- `setSpeedMod`
- `setMoveSpeed`
- `setPathSpeed`
- `setCombatSpeed`
- player coordinate writes
- game-time multiplier write
- old running shove route
- active player bump-state chain
- fake coordinate status icon
- 8 second probe
- old halo text helper route
- speech bubble debug route
- active `ISPanel`
- direct `Calories`
- direct `Hunger`
- direct pain stat write
- direct stress stat write
- direct body damage API write
- direct `BodyPart`
- direct muscle strain API write
- direct injury wound route
- direct bleeding route
- direct infection route

Legacy training-load state names were renamed so the forbidden stat keyword is absent.

## Allowed Experimental Calls

- zombie-side hit reaction;
- zombie-side AI interrupt;
- zombie-side micro nudge;
- read-only player danger-state checks;
- bump grace read;
- cooldown / target lock;
- endurance cost;
- refund ignore window.

## Micro Nudge Audit

- Moves zombie only: PASS
- Does not move player: PASS
- same-z target collection: PASS
- passable square check: PASS
- wall/water avoidance: `NOT_VERIFIABLE_BY_STATIC_AUDIT`
- pcall: PASS
- status: `EXPERIMENTAL_NOT_RELEASE_SAFE`

## Not Verifiable

- Lua 5.1 execution syntax check if no interpreter is available.
- Real B42 runtime availability of `setTarget(nil)`, `setHitReaction`, `setStaggerBack`, `setHitForce`.
- Whether Breakout Push fully prevents player trip in live sprint collision.
- Whether grab/crowd detection catches all real attack wind-up states.

## Static Result

- Total files: `29`
- Lua files: `15`
- Lua total lines: `1875`
- Markdown documents: `7`
- JSON parse: PASS
- Text BOM/NULL scan: PASS
- Lua execution syntax check: `NOT_VERIFIABLE_NO_RELIABLE_LUA_5_1_INTERPRETER`
- Active forbidden Lua scan: PASS
- Full-tree forbidden literal scan: PASS_NOT_FOUND
- Runtime main update: `Core.BreakoutPush.Update(player)`
- failed bump variable write route scan: PASS_NOT_FOUND
- player coordinate write scan: PASS_NOT_FOUND
- zombie coordinate write scan: FOUND_ALLOWED_SECONDARY_NUDGE_ONLY

STATIC_AUDIT_RESULT=PASS_
[EXCERPT_TRUNCATED]
```
