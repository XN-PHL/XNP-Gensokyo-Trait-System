# 0.5.7 Sanitized Evidence Excerpts

## 0.5.7_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `2048F6988DF8CC0EFB73D00DC2701B7754426C0961DE03C8B880D261383193E8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.7 Real Game Result Summary

Accepted user console facts:

```text
0.5.7_LOAD_RESULT=PASS
TRAIT_DETECTION=PASS
SHOULDER_DISTANCE_DETECTION=PASS
SHOULDER_FRONT_DOT_DETECTION=PASS
SHOULDER_TRIGGER_LOGIC=PASS
VISIBLE_EFFECT=FAIL_BECAUSE_DETECT_ONLY_NO_PHYSICS
CONFIG_LOAD_STATUS=FALLBACK_USED_NEEDS_FIX
```

Important observed logs:

```text
[XNP DistanceRunner] loaded version=0.5.7 internal=0.5.7-b42-runner-shoulder-check-experiment-a build=XNP_PZ_DISTANCE_TRAIT_057_RUNNER_SHOULDER_CHECK_EXPERIMENT_A
[XNP TRAIT] detector_method=RESTORED_FROM_0.4.19
[XNP TRAIT] CharacterTrait resolved
[XNP TRAIT] player has target trait=true
[XNP SHOULDER] method=DETECT_ONLY_NO_PHYSICS
[XNP SHOULDER] trigger method=DETECT_ONLY_NO_PHYSICS dist=1.000 dot=0.919 cost=0.000 endurance_before=nil endurance_after=nil
```

Conclusion: 0.5.8 should not rewrite trait detection, adrenaline distance, or front-dot targeting. It must add a visible effect path and fix config fallback logging.

```

## ADRENALINE_DISTANCE_AND_SHOULDER_CHECK_DESIGN_0.5.7.md

- SHA-256: `B4E00F2D2A77F577AEACD204BF3C1BE114416D5759C8EE78D268C15DEF75E50A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Adrenaline Distance and Shoulder Check Design 0.5.7

The adrenaline radius and the shoulder-check radius are intentionally different systems.

## Adrenaline distance system

```text
THREAT_TRIGGER_RADIUS=4.0
ADRENALINE_MEMORY_DURATION=20.0
THREAT_SCAN_INTERVAL=0.50
```

Purpose: detect nearby danger and enter the existing stamina-saving ACTIVE/FADING flow.

When the player keeps running and zombies repeatedly stay within 4 tiles, ACTIVE can remain long. This is not a distance bug.

## Runner Shoulder Check

```text
SHOULDER_CHECK_TRIGGER_RADIUS=1.15
SHOULDER_CHECK_FRONT_DOT_MIN=0.45
SHOULDER_CHECK_COOLDOWN=1.25
```

Purpose: detect close front-contact candidates for a future shoulder-check mechanic.

In 0.5.7 the method is:

```text
SHOULDER_CHECK_METHOD=DETECT_ONLY_NO_PHYSICS
```

This means:

- no zombie pushback
- no zombie coordinate write
- no zombie state write
- no damage
- console trigger and summary logs only

## Relation

- Within 4 tiles: may trigger adrenaline stamina behavior.
- Within about 1.15 tiles and in front of player: may trigger shoulder-check detection.
- These distances are not the same and should not be tuned as one value.

```

## BUILD_MARKER.txt

- SHA-256: `285C22BC4F42DAF2F52750F0549A8E785E2046DEC95C2D66F2D1725D057DB419`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_057_RUNNER_SHOULDER_CHECK_EXPERIMENT_A

```

## CHANGELOG_0.5.7.md

- SHA-256: `4BB7B4E2DBF9EAA0347DE88165BC0F82E6554654EC0C67821507C2AEC8C79A58`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Changelog 0.5.7

## Version

- Version: 0.5.7
- Internal version: 0.5.7-b42-runner-shoulder-check-experiment-a
- Build marker: XNP_PZ_DISTANCE_TRAIT_057_RUNNER_SHOULDER_CHECK_EXPERIMENT_A
- Display name: XNP Distance Runner Trait 0.5.7 Runner Shoulder Check Experiment

## Added

- Runner Shoulder Check experiment module.
- Front-distance detection within `SHOULDER_CHECK_TRIGGER_RADIUS=1.15`.
- Direction gate using `SHOULDER_CHECK_FRONT_DOT_MIN=0.45`.
- Cooldown, endurance threshold, summary counters, and trigger logs.
- StaminaDrain shoulder-cost ignore window support.
- B42.19 zombie knockback/stagger safety API audit.

## Decision

No safe high-level zombie knockback API was confirmed by static audit.

0.5.7 therefore uses:

```text
SHOULDER_CHECK_METHOD=DETECT_ONLY_NO_PHYSICS
```

## Preserved

- Trait full ID unchanged.
- Stamina core unchanged.
- Adrenaline distance core unchanged.
- No speed modification.
- No coordinate writes.
- No Halo, right-top icon, or true Moodle.

```

## FINAL_REPORT.md

- SHA-256: `97F5C55826C011D4C4BBE7AEBF109DE013665E41C77C309FEFBDDFB74308A388`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.7

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.7

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_057_RUNNER_SHOULDER_CHECK_EXPERIMENT_A

## Latest real-game evidence

LATEST_REAL_GAME_LOG_VERSION=0.5.5

0.5.6_REAL_GAME_RESULT=NOT_VERIFIED_BY_LATEST_CONSOLE

0.5.5_TRAIT_RESULT=PASS

0.5.5_STAMINA_RESULT=PASS

0.5.5_ADRENALINE_RESULT=PASS

## Preserved stamina/adrenaline core

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

READY_STAMINA_DRAIN_MULTIPLIER=0.40

ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10

ADRENALINE_TRIGGER_RADIUS=4.0

ADRENALINE_MEMORY_DURATION=20.0

## Shoulder Check

SHOULDER_CHECK_ENABLED=true

SHOULDER_CHECK_METHOD=DETECT_ONLY_NO_PHYSICS

SHOULDER_CHECK_SAFE_API_AUDIT_RESULT=NO_SAFE_API_FOUND

SHOULDER_CHECK_TRIGGER_RADIUS=1.15

SHOULDER_CHECK_FRONT_DOT_MIN=0.45

SHOULDER_CHECK_MIN_PLAYER_SPEED=0.06

SHOULDER_CHECK_MIN_ENDURANCE=0.12

SHOULDER_CHECK_ENDURANCE_COST=0.035

SHOULDER_CHECK_COOLDOWN=1.25

SHOULDER_CHECK_REFUND_IGNORE_WINDOW=0.35

SHOULDER_CHECK_DAMAGE=0

## Other systems

METABOLIC_COST_METHOD=DEBT_ONLY

METABOLIC_APPLICATION_STATUS=RECORDED_ONLY

VISUAL_FEEDBACK_METHOD=DISABLED_AFTER_HALO_FAILURE

RIGHT_TOP_ICON_STATUS=DISABLED_NO_SAFE_TRUE_MOODLE

STATUS_MOODLE_METHOD=NOT_CONFIRMED

MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

RUNNING_SHOVE_STATUS=DISABLED

BUMPED_STATE_STATUS=DISABLED

## Safety

鏄惁淇敼鏃?SOURCE=NO

鏄惁鍚姩娓告垙=NO

鏄惁鍐欑敤鎴?mods=NO

鏄惁鍐欐父鎴忕洰褰?NO

鏄惁鍐?saves=NO

鏄惁鍐?Workshop=NO

## Counts

Lua 鏂囦欢鏁伴噺=13

Lua 鎬昏鏁?1409

Markdown 鏂囨。鏁伴噺=92

鎬绘枃浠舵暟閲?112

闈欐€佹鏌ョ粨鏋?STATIC_BLOCKER_NONE

## NOT_VERIFIABLE

- Lua 5.1 syntax execution: NOT_VERIFIABLE
- Real-game runtime: NOT_VERIFIABLE
- Multiplayer/network synchronization: NOT_VERIFIABLE

BLOCKER=NONE

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.7_SOURCE_READY_FOR_SHOULDER_CHECK_EXPERIMENT_TEST

```

## README_CN.md

- SHA-256: `55B498B02E2816AA68AB5C8F871880D40DC560C2A0F3011D910C61F40237B7B3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.7

Project Zomboid Build 42.19.0 鐨?Runner Shoulder Check 鐙珛瀹為獙鐗堟湰銆?
## 韬唤

- Mod ID锛歚XNP_PZ_DistanceRunnerTrait`
- Trait full ID锛歚XNPDistanceRunnerTrait:XNPDistanceRunner`
- 鐗堟湰锛歚0.5.7`
- 鍐呴儴鐗堟湰锛歚0.5.7-b42-runner-shoulder-check-experiment-a`
- 鏋勫缓鏍囪瘑锛歚XNP_PZ_DISTANCE_TRAIT_057_RUNNER_SHOULDER_CHECK_EXPERIMENT_A`

## 鏈増鏈繚鐣?
- 0.4.19 鎭㈠鐨勫師鐢?CharacterTrait 娉ㄥ唽閾俱€?- 瀵硅薄寮忕壒璐ㄦ娴嬨€?- 0.5.5/0.5.6 鑰愬姏杩旇繕鏍稿績銆?- READY / ACTIVE / FADING 搴旀縺鑰愬姏绯荤粺銆?- 鏃犲彸涓婅鍥炬爣銆?- 鏃犲ご椤舵枃瀛椼€?- 鏃?True Moodle銆?
## Runner Shoulder Check

鏈増鏈畬鎴愯窛绂汇€佹柟鍚戙€佸喎鍗淬€佽€愬姏闃堝€煎拰鏃ュ織妫€娴嬮摼銆?
褰撳墠瀹夊叏瀹¤缁撹锛?
```text
SHOULDER_CHECK_SAFE_API_AUDIT_RESULT=NO_SAFE_API_FOUND
SHOULDER_CHECK_METHOD=DETECT_ONLY_NO_PHYSICS
```

鍥犳 0.5.7 涓嶄細瀹為檯鎺ㄥ紑鍍靛案锛屼笉浼氬啓鍍靛案鍧愭爣锛屼笉浼氬啓 zombie stagger/knockdown/hit reaction 鐘舵€併€?
## 娴嬭瘯閲嶇偣

闈犺繎鍍靛案 4 鏍煎唴搴斾繚鎸佸師鏈?ACTIVE 鑰愬姏閫昏緫锛涚害 1.15 鏍煎唴涓斿湪鐜╁姝ｅ墠鏂规椂锛孲houlder Check 鍙緭鍑烘娴嬫棩蹇椼€?
```

## README_EN.md

- SHA-256: `6538C45E1F5CFB573A481EA39741C9F51755884AEF441B5938D247E56B543930`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.7

Independent Runner Shoulder Check experiment for Project Zomboid Build 42.19.0.

## Identity

- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- Version: `0.5.7`
- Internal version: `0.5.7-b42-runner-shoulder-check-experiment-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_057_RUNNER_SHOULDER_CHECK_EXPERIMENT_A`

## Preserved core

- Native CharacterTrait registration path restored in 0.4.19.
- Object-based trait detection.
- Accepted stamina refund core from 0.5.5 / 0.5.6.
- READY / ACTIVE / FADING adrenaline stamina flow.
- No right-top icon.
- No overhead text.
- No true Moodle.

## Runner Shoulder Check

0.5.7 implements distance, front-dot, cooldown, endurance-threshold, and logging checks.

Current audit result:

```text
SHOULDER_CHECK_SAFE_API_AUDIT_RESULT=NO_SAFE_API_FOUND
SHOULDER_CHECK_METHOD=DETECT_ONLY_NO_PHYSICS
```

This build does not push zombies, write zombie coordinates, or write stagger/knockdown/hit reaction state.

```

## SHOULDER_CHECK_EXPERIMENT_TEST_0.5.7.md

- SHA-256: `216F58C34916FBF98F428FA640BC07F3037EBC562988AB63AA5917075BB4A47A`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Shoulder Check Experiment Test 0.5.7

## Manual test steps

1. Disable 0.5.6, 0.5.5, and all older XNP Distance Runner versions.
2. Enable only 0.5.7 and B42Trans_CN if needed.
3. Fully restart the game.
4. Enter a character with the Long Distance Runner trait.
5. Confirm the yellow F trait exists in the character info panel.
6. Confirm there is no overhead text.
7. Confirm there is no right-top icon.
8. Run far from zombies and confirm READY summary behavior.
9. Move within 4 tiles of a zombie and confirm ACTIVE behavior.
10. Place one live zombie about 1 tile in front of the player.
11. Run directly toward the zombie.
12. If method is `DETECT_ONLY_NO_PHYSICS`, do not expect the zombie to move.
13. Confirm console shows:

```text
[XNP SHOULDER] method=
[XNP SHOULDER] trigger
[XNP SHOULDER SUMMARY]
```

14. Confirm there is no:

```text
RunningShove
BumpedState
IsoZombie cannot be cast to IsoPlayer
setX
setY
GameTime:setMultiplier
HaloTextHelper
player:Say
hasTrait error
```

15. Return `console.txt` for review.

## Expected result

For this source:

```text
SHOULDER_CHECK_METHOD=DETECT_ONLY_NO_PHYSICS
```

Expected visible behavior is log-only detection. Real zombie pushback is intentionally not enabled.

```

## B42_19_ZOMBIE_KNOCKBACK_SAFE_API_AUDIT_0.5.7.md

- SHA-256: `CC053407B3A73E2F6147E71FF498A065A84E6FF46FDFC112205DE8F8CA91369F`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Zombie Knockback Safe API Audit 0.5.7

## Scope

Static read-only audit only. No Project Zomboid executable, Steam, save, Workshop write, user mods write, or game directory write was performed.

Scanned:

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`

## Evidence summary

- Original Lua did not expose a clear safe one-call zombie knockback API sample.
- Script data contains weapon hit reaction and `KnockBackOnNoDeath` configuration, but not a simple Lua API for safe runner collision pushback.
- Java class signatures expose low-level methods such as `IsoZombie:knockDown(boolean)`, `IsoZombie:setStaggerBack(boolean)`, `IsoGameCharacter:setKnockedDown(boolean)`, `IsoGameCharacter:setHitReaction(String)`, `IsoMovingObject:setHitForce(float)`, and `IsoMovingObject:setHitDir(Vector2)`.
- These methods are direct state or hit-reaction writes. They are not confirmed as safe for client-side runner contact logic.
- Workshop examples use similar direct methods, but third-party samples are not enough to certify network safety or vanilla compatibility.

## Required answers

1. Lua safe zombie knockback / push / knockback API exists: NO CONFIRMED SAFE API.
2. Real method name: no safe high-level method confirmed. Low-level risky methods exist: `setStaggerBack`, `setKnockedDown`, `setHitForce`, `setHitReaction`, `knockDown`.
3. Parameter signatures observed: booleans, floats, strings, and vector objects depending on method.
4. Applies to `IsoZombie`: some low-level methods are available on `IsoZombie` or inherited from `IsoGameCharacter` / `IsoMovingObject`.
5. Requires `IsoPlayer`: not always, but previous failed branches show player-state routes can cause `IsoZombie cannot be cast to IsoPlayer`; those routes remain banned.
6. Enters `BumpedState`: not used by 0.5.7. Bumped-state routes remain banned.
7. Writes coordinates: safe API not confirmed. 0.5.7 does not write coordinates.
8. Network desync risk: unknown for low-level state writes; treated as unsafe.
9. Save impact: unknown for low-level hit/floor/stagger state; treated as unsafe.
10. Damage: low-level hit routes can be tied to damage systems; 0.5.7 uses no damage.
11. Zombie AI impact: low-level stagger/knockdown methods can affect AI state; treated as unsafe until validated.
12. Vanilla call sample: no acceptable high-level runner knockback Lua sample found.
13. B42 mod sample: third-party direct state writes found, but not accepted as safe proof.
14. `pcall` wrapping: possible, but `pcall` only catches Lua errors and does not prove gameplay/network safety.
15. Failure shutdown: implemented for the detect module; fatal ShoulderCheck errors disable only that module.
16. Final conclusion: `NO_SAFE_API_FOUND`.

## Decision

```text
SHOULDER_CHECK_SAFE_API_AUDIT_RESULT=NO_SAFE_API_FOUND
SHOULDER_CHECK_METHOD=DETECT_ONLY_NO_PHYSICS
```

0.5.7 must not call direct zombie state/physics writers.

```

## STATIC_AUDIT.md

- SHA-256: `4A878823CD8025027DD05387871C46CF3804ECA899E9765639A5845F34946E1B`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.7

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

## Counts

- Lua files: 13
- Lua total lines: 1409
- Markdown files: 92
- Total files: 112
- JSON parse: PASS

## Layout

- Root `media/lua`: ABSENT
- `42/media/lua`: PRESENT
- `42/media/scripts/XNPDistanceRunnerTraits.txt`: PRESENT
- `42/media/ui/Traits/trait_xnpdistancerunner.png`: PRESENT

## Lua execution syntax

NOT_VERIFIABLE: no reliable local `lua` or `luac` command was available. No download or install was attempted.

## Forbidden active API scan

PASS with one non-blocking comment hit:

```text
XNP_DR_Config.lua: -- Body status is audit-only. 0.5.7 never writes BodyDamage or BodyPart fields.
```

No active Lua call was found for:

- `player:hasTrait("...")`
- `TraitFactory`
- runtime `CharacterTraitDefinition`
- `setFastMoveCheat`
- `setSpeedMod`
- `setMoveSpeed`
- `setPathSpeed`
- `setCombatSpeed`
- player coordinate writes
- zombie coordinate writes
- `GameTime:setMultiplier`
- `RunningShove`
- `BumpedState`
- fake right-top icon coordinates
- 8-second probe
- active `HaloTextHelper`
- active `player:Say`
- custom `ISPanel` UI
- direct Calories/Hunger/Fatigue/Pain/Stress writes
- direct BodyDamage/BodyPart/MuscleStrain/Wound/Bleeding/Infection writes
- `setKnockedDown`
- `setStaggerBack`
- `setHitForce`
- `setHitReaction`
- `knockDown(...)`

## Shoulder Check safety

```text
SHOULDER_CHECK_SAFE_API_AUDIT_RESULT=NO_SAFE_API_FOUND
SHOULDER_CHECK_METHOD=DETECT_ONLY_NO_PHYSICS
```

The module only reads player/zombie positions and states, computes distance/direction, and logs detection. It does not apply physics or zombie state changes.

## Preserved systems

- Trait full ID unchanged.
- Trait detection route unchanged.
- Stamina core unchanged.
- Adrenaline distance core unchanged.
- Visual feedback policy unchanged.

## Directory safety

- Old SOURCE modified: NO
- Project Zomboid launched: NO
- Steam launched: NO
- User mods written: NO
- Saves written: NO
- Workshop written: NO
- Game directory written: NO

## NOT_VERIFIABLE

- Lua syntax execution by Lua 5.1 interpreter.
- Real-game behavior.
- Multiplayer/network synchronization.

STATIC_BLOCKER=NONE

```
