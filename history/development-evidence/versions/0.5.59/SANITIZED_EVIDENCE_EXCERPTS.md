# 0.5.59 Sanitized Evidence Excerpts

## 0.5.59_XNP运行错误检查.md

- SHA-256: `06C93ACCC270498EE20B8BE55774128A8122D30A251D946E9D654FE80A07ECFF`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 XNP 杩愯閿欒妫€鏌?
0.5.58 supplied-console findings:

```text
XNP_LOG_LINES=91
XNP_MOD_STACK_HITS=0
XNP_ROUND_MARKER_FRAME_HITS=0
PHOENIX_ENGINE_DEATH_ALREADY_COMMITTED_HITS=1
```

The Phoenix line is a functional failure, not a Lua exception. 0.5.59 removes that old skip name from runtime and replaces the primary route with predeath edges proven from B42.19 bytecode. Whether it succeeds in world simulation is not statically verifiable.

```text
0.5.59_RUNTIME_ERROR_CHECK=NOT_YET_TESTED
0.5.59_RUNTIME_FUNCTION_CHECK=NOT_YET_TESTED
```

```

## 0.5.59_错误归属矩阵.md

- SHA-256: `E9D73F59FE8ABB08CF6D6944D155350CFD8916EE9A90DA4ADA5BA3FEDEFB14CC`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 閿欒褰掑睘鐭╅樀

Evidence file: `console(22)_0.5.58瀹炴満鏃ュ織.txt`.

| Evidence | Category | Count/status | Ownership |
|---|---|---:|---|
| Phoenix skipped after death commit | XNP_FUNCTIONAL_FAILURE | 1 | XNP 0.5.58 interception was too late |
| XNP Lua stack/error hit | XNP_RUNTIME_ERROR | 0 | No XNP stack in supplied console |
| `WarThunderVehicleLibrary/HeliSoundUpdate.lua:69` | THIRD_PARTY_RUNTIME_ERROR | 599 line-69 hits | WarThunderVehicleLibrary; not modified |
| WarThunder nil-message family | THIRD_PARTY_RUNTIME_ERROR | 239 | WarThunderVehicleLibrary; not modified |
| `FirearmUseDamageChance` parse messages | VANILLA_OR_UNKNOWN_WARNING | 2 | Attribution not proven; not assigned to XNP |

```text
XNP_FUNCTIONAL_FAILURE=PHOENIX_INTERCEPT_TOO_LATE
XNP_RUNTIME_ERROR_STACK_HITS=0
THIRD_PARTY_RUNTIME_ERROR=WARTHUNDERVEHICLELIBRARY_ERROR_STORM
FIREARM_PARSE_ATTRIBUTION=UNPROVEN
```

```

## 0.5.59_低帧率证据报告.md

- SHA-256: `17039FD51AF277DD150C221144257A28D26B25C7529226D498628A527686E79F`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 浣庡抚鐜囪瘉鎹姤鍛?
The supplied 0.5.58 console has 15,231 lines and 451 `ERROR:` prefix lines. It contains 914 WarThunder-related hits, including 599 references to `HeliSoundUpdate.lua:69` and 239 associated nil-message hits. It contains 91 XNP log lines but zero XNP Lua stack hits and zero RoundMarkerFrame hits.

The evidence therefore supports a third-party error storm as the dominant logged low-FPS correlate. It does not prove that XNP has zero performance cost, and it does not permit modifying WarThunderVehicleLibrary.

```text
LOW_FPS_PRIMARY_LOG_CORRELATE=WARTHUNDERVEHICLELIBRARY_ERROR_STORM
XNP_ERROR_STACK_HITS=0
CAUSAL_FPS_PROOF=NOT_VERIFIABLE_FROM_CONSOLE_ONLY
WARTHUNDER_MODIFIED=false
```

```

## 0.5.59_实机测试记录模板.md

- SHA-256: `815013C2D50B3FCEE7FC82C7D86A7B2713451CB83FCFA4C80862FCF77E485270`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 瀹炴満娴嬭瘯璁板綍妯℃澘

Do not mark PASS without console and observed behavior.

| Test | Preconditions | Observed result | Required log | PASS/FAIL |
|---|---|---|---|---|
| Lethal fall | Purple trait, READY, toggle ON |  | `source=FALL`, one transaction |  |
| Lethal projectile | Purple trait, READY, toggle ON |  | `source=PROJECTILE`, one transaction |  |
| 30% threshold | Nonlethal damage crosses 30% |  | one transaction |  |
| Purple OFF | Toggle OFF |  | no intercept |  |
| Purple cooldown | Recharge not READY |  | no intercept |  |
| Duplicate callbacks | One damage event |  | one transaction ID |  |
| Red stamina | Endurance below 0.5 |  | +0.50, max 1.00, one item |  |
| Red treatment | Multiple wounds + zombie infection |  | virus clear, one ordinary infection, fractures remain |  |
| Red interruption | Interrupt at mid-action |  | item remains |  |
| Yellow shake | Yellow state and dragging |  | shake only in expected state; paused while dragging |  |

Record also: game build, enabled mods, exact SOURCE/DROP hash, FPS, full XNP lines, `TOO_LATE`, Lua stack, and third-party error counts.

```

## 0.5.59_B42_PREDEATH_DAMAGE_ORDER_EVIDENCE.md

- SHA-256: `A8317BFEF69AE717E35B056F404CFE43BFB4F73CD924B6CE80C17C0942F6EF65`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 B42 Predeath Damage Order Evidence

Evidence source: `[LOCAL_PATH_REDACTED]`, Build 42.19.0, inspected with class signatures and bytecode; vanilla Lua under `[LOCAL_PATH_REDACTED]` was also searched.

## Weapon route

In `zombie.characters.IsoGameCharacter.Hit(HandWeapon, IsoGameCharacter, float, ...)`, bytecode triggers `OnWeaponHitCharacter` near offset 115 and `OnPlayerGetDamage` with `WEAPONHIT` near 128. It then reaches the `avoidDamage` check near 160. When true, the engine clears the one-shot flag and returns before `processHitDamage` near 253 and before `hitConsequences`.

`HandWeapon:isRanged()` and `HandWeapon:isExplosive()` provide PROJECTILE/MELEE/EXPLOSION classification. The selected weapon intercept is `OnWeaponHitCharacter`, followed by `target:setAvoidDamage(true)` only when the Phoenix transaction succeeds.

## Fall and death route

`IsoGameCharacter.handleLandingImpact(FallDamage)` reduces general health near bytecode 466, updates BodyDamage near 519, observes dead health and sets `killedByFall` near 524, then triggers `OnPlayerGetDamage` with `FALLDOWN` near 545. No `die()` or `becomeCorpse()` occurs before that event.

`isDead()` reflects zero health and is therefore not the commit boundary. `isOnDeathDone()` reads the committed death field. `die()` creates the corpse and then sets OnDeathDone. The selected fall intercept accepts zero health only while `isOnDeathDone()==false`, restores health, and clears `killedByFall`.

## Other engine damage events

JAR routes identify `CARHITDAMAGE`, `CARCRASHDAMAGE`, `FIRE`, and BodyDamage periodic types such as POISON, HUNGRY, SICK, BLEEDING, THIRST, HEAVYLOAD, and INFECTION. They use the same pre-commit `OnPlayerGetDamage` recovery edge. Their runtime behavior remains untested.

```text
FALL_PREDEATH_ORDER_PROVEN=true
PROJECTILE_PREDEATH_ORDER_PROVEN=true
DEATH_COMMIT_POINT_PROVEN=true
SELECTED_INTERCEPT_BEFORE_DEATH_COMMIT=true
RUNTIME_CONFIRMATION=NOT_YET_TESTED
```

```

## 0.5.59_FALL_DAMAGE_PREDEATH_ROUTE.md

- SHA-256: `0F955BE950BA5776BAFF39FAF13F59B446198A13DA9103BA113DD75F5C1A1244`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 Fall Damage Predeath Route

```text
ENTRY=IsoGameCharacter.handleLandingImpact(FallDamage)
DAMAGE_WRITE=BodyDamage.ReduceGeneralHealth
HEALTH_UPDATE=BodyDamage.Update
LUA_EDGE=OnPlayerGetDamage(player,FALLDOWN,damage)
COMMIT_EDGE=IsoGameCharacter.die -> becomeCorpse -> setOnDeathDone(true)
SELECTED_INTERCEPT=OnPlayerGetDamage/FALLDOWN
```

At the Lua edge, `isDead()` may already be true because health reached zero. This is not treated as committed death. The route rejects only `isOnDeathDone()==true`. On a READY transaction it restores the existing Phoenix recovery target and clears `killedByFall` before the later death commit can proceed.

The old `ENGINE_DEATH_ALREADY_COMMITTED` skip is not used as a primary route. A committed corpse is never revived.

```text
FALL_PREDEATH_ORDER_PROVEN=true
RUNTIME_FALL_TEST=NOT_YET_TESTED
```

```

## 0.5.59_PHOENIX_PREDEATH_TEST_MATRIX.md

- SHA-256: `BAD2EAEFA8AD5FAAFC8A7E29B98E284FB3F62A6230A23EE01DD7E3C049073B4C`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.59 Phoenix Predeath Test Matrix

| Case | Setup | Expected | Development status |
|---|---|---|---|
| A | Purple READY, lethal fall | survives; one trigger; purple marker hides; cooldown starts | NOT_YET_TESTED |
| B | Purple READY, lethal projectile | survives; one trigger | NOT_YET_TESTED |
| C | Nonlethal hit crosses 30% | existing threshold route triggers once | NOT_YET_TESTED |
| D | Purple manually OFF | no interception | NOT_YET_TESTED |
| E | Purple cooling down | no interception | NOT_YET_TESTED |
| F | One hit produces several callbacks | one transaction and one life maximum | NOT_YET_TESTED |
| G | Health stays above threshold | no false trigger | NOT_YET_TESTED |
| H | OnDeathDone/corpse already committed | no fake revive; one TOO_LATE diagnostic | NOT_YET_TESTED |

```text
RUNTIME_FALL_TEST=NOT_YET_TESTED
RUNTIME_PROJECTILE_TEST=NOT_YET_TESTED
RUNTIME_TESTS_PASSED=false
```

```

## 0.5.59_PHOENIX_PREDEATH_TRANSACTION_GATE_REPORT.md

- SHA-256: `91476CEDB184187BD6E3CD8A437994191BC09B6C08F15963DA35D68F162F5133`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 Phoenix Predeath Transaction Gate Report

Atomic eligibility order:

1. sandbox enabled;
2. purple trait object present;
3. manual Phoenix toggle enabled;
4. no transaction already running;
5. no active protection transaction;
6. death not committed (`isOnDeathDone()==false`);
7. current/projected health reaches the fatal or 30% threshold;
8. recharge state is READY.

A successful transaction allocates one ID, applies the existing recovery target, starts recovery/cooldown and the existing finite invulnerability window, then records one success. `triggering` rejects re-entry during application; active invulnerability rejects later callbacks from the same hit.

The weapon route arms one-shot engine `avoidDamage`; the fall route repairs zero health before death commit. No permanent cheat flag is introduced.

```text
SINGLE_DAMAGE_TRANSACTION_TRIGGER_MAX=1
DAMAGE_TRANSACTION_GATE_DUPLICATE_TRIGGER=false
PHOENIX_PERMANENT_INVULNERABILITY=false
POST_DEATH_REVIVE_PRIMARY_ROUTE=false
TOO_LATE_WHILE_READY_EXPECTED=false
RUNTIME_TRANSACTION_DUPLICATE_TEST=NOT_YET_TESTED
```

```

## 0.5.59_PROJECTILE_DAMAGE_PREDEATH_ROUTE.md

- SHA-256: `9DF856F9E4FAF294CE155ED8E14D4384287574322EAA0C07A3E7E88DFBA5BCCA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 Projectile Damage Predeath Route

```text
ENTRY=IsoGameCharacter.Hit(HandWeapon,...)
LUA_EDGE_1=OnWeaponHitCharacter(attacker,target,weapon,damage)
LUA_EDGE_2=OnPlayerGetDamage(target,WEAPONHIT,damage)
ONE_SHOT_ENGINE_GATE=target.avoidDamage
DAMAGE_COMMIT=processHitDamage/hitConsequences after avoidDamage gate
SELECTED_INTERCEPT=OnWeaponHitCharacter
```

`weapon:isRanged()` maps to PROJECTILE, `weapon:isExplosive()` maps to EXPLOSION, and the remaining weapon path maps to MELEE. When and only when the Phoenix transaction succeeds, the handler writes `setAvoidDamage(true)`. The engine consumes and clears this one-shot value before damage processing. Subsequent callbacks see the existing short invulnerability transaction and cannot consume a second life.

Setter readback is not used as proof; the proof is the JAR bytecode ordering. World behavior still requires user testing.

```text
PROJECTILE_PREDEATH_ORDER_PROVEN=true
RUNTIME_PROJECTILE_TEST=NOT_YET_TESTED
```

```

## 0.5.59_RED_DUAL_MODE_AND_USE_TIME_REPORT.md

- SHA-256: `959D73FF2135034DD0D3E3375E9F8131467690C3824DF28E4B84F25D723EDC53`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 Red Dual Mode and Use Time Report

```text
MODE_KEY=XNP_RED_MAGIC_MODE
DEFAULT_MODE=STAMINA
RED_STAMINA_MODE_COLOR=GREEN
RED_TREATMENT_MODE_COLOR=WHITE
RED_STAMINA_RECOVERY_POINTS_100_SCALE=50
RED_STAMINA_RECOVERY_NORMALIZED=0.50
RED_STAMINA_CLAMP_MAX=1.00
RED_STAMINA_CHANGES_HEALTH=false
BASELINE_USE_TIME=120
NEW_USE_TIME=96
RED_USE_TIME_RATIO_VS_0.5.58=0.80
RED_PARTIAL_CONSUMPTION=false
RED_INTERRUPTED_ACTION_CONSUMES=false
RED_COMPLETION_CONSUMES_EXACTLY_ONE=true
```

`Stats:get/set(CharacterStat.ENDURANCE)` is the selected stamina route. JAR static initialization defines ENDURANCE minimum 0, maximum 1, default 1; the implementation adds 0.50 and clamps to 1.00.

The context menu changes mode without consuming. The action captures the selected mode, revalidates at completion, applies the effect, and only then removes one item. Stop/interruption does not remove it. These contracts require runtime confirmation.

```

## 0.5.59_RED_ORDINARY_INFECTION_RESIDUE_REPORT.md

- SHA-256: `BF5BF5ED4C64B7FF84488D2D9663EA4F169810894EA84BD117F2E05C4B67AF69`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 Red Ordinary Infection Residue Report

B42.19 stores zombie infection and ordinary wound infection separately:

- zombie/fake infection: BodyDamage `infected/isFakeInfected`, BodyPart `IsInfected/IsFakeInfected`, and `CharacterStat.ZOMBIE_INFECTION`;
- ordinary wound infection: BodyPart `infectedWound` and `woundInfectionLevel`.

`BodyPart:setWoundInfectionLevel(value)` controls ordinary wound infection. Vanilla debug health UI uses a positive value to create ordinary infection and a negative value to remove it. This field does not set BodyDamage zombie infection or the zombie infection CharacterStat.

Treatment clears ordinary infection on every part, then writes level 10 to the single preselected most-severe carrier. Verification counts `isInfectedWound()==true` and rejects completion unless the count is exactly one and every zombie/fake flag remains clear.

```text
ORDINARY_WOUND_INFECTION_REMAINS_EXACTLY_ONE=true
ORDINARY_INFECTION_CAN_ZOMBIFY=false
ORDINARY_INFECTION_CARRIER=PRETREATMENT_MOST_SEVERE_PART
RUNTIME_RESIDUE_TEST=NOT_YET_TESTED
```

```

## 0.5.59_RED_WHOLE_BODY_TREATMENT_API_EVIDENCE.md

- SHA-256: `748B278F7F15E5B9E505CB9C018F2D5575E526AA106D9B638394A33465FF5AA4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.59 Red Whole Body Treatment API Evidence

JAR source: `[LOCAL_PATH_REDACTED]`.

Verified B42.19 public methods:

- `BodyDamage:getBodyParts`, `isInfected/setInfected`, `isIsFakeInfected/setIsFakeInfected`, `setInfectionTime`, `setReduceFakeInfection`, `calculateOverallHealth`;
- `BodyPart:getHealth/SetHealth`, `IsInfected/SetInfected`, `IsFakeInfected/SetFakeInfected`, `setBleeding`, `setBleedingTime`, `get/setFractureTime`;
- `BodyPart:isInfectedWound`, `setInfectedWound`, `get/setWoundInfectionLevel`;
- `Stats:get/set(CharacterStat, float)` and `CharacterStat.ZOMBIE_INFECTION`.

White mode snapshots all parts and chooses the highest treatment-time severity as carrier. It clears body and part zombie/fake infection plus the zombie-infection CharacterStat, restores part health and bleeding state, preserves physical wound flags and fractures, and finally writes ordinary wound infection level 10 to exactly one carrier. It then calls `calculateOverallHealth`.

No `RestoreToFullHealth` is used by red treatment because that would erase physical wounds and fractures.

```text
RED_TREATMENT_SCOPE=WHOLE_BODY
RED_ITEM_CONSUMED_PER_ACTION=1
ZOMBIE_INFECTION_CLEARED=true
ZOMBIFICATION_CLEARED=true
FAKE_INFECTION_CLEARED=true
FRACTURE_INSTANT_CURE=false
NO_TREATABLE_STATE_CONSUMES_ITEM=false
RUNTIME_TREATMENT_TEST=NOT_YET_TESTED
```

```
