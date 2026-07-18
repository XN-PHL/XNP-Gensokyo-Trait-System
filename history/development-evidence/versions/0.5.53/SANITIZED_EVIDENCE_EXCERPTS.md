# 0.5.53 Sanitized Evidence Excerpts

## 0.5.53_B42_CORE_ARCHIVE_DISCOVERY.md

- SHA-256: `68AA841135F4520ACE32BEBCFEAA6BD665B264CFB65B0B38B16BE8B3E35193AF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Build 42 Core Archive Discovery

## Installation-path findings

- Required scan root: `[LOCAL_PATH_REDACTED]`
- G root scan completed recursively on 2026-07-14.
- Current G contents contain crash logs and a nested Workshop tree only. `media\lua`, launch JSON, and `projectzomboid.jar` are absent.
- G crash logs prove an earlier process image at `[LOCAL_PATH_REDACTED]` and record `java_class_path (initial): .;projectzomboid.jar`; they do not prove those files remain present.
- Current complete readable installation discovered at `[LOCAL_PATH_REDACTED]`.
- F contains `ProjectZomboid64.json`, launch BAT files, `media\lua`, and the readable core JAR.

## Core classpath

`[LOCAL_PATH_REDACTED]`:

```text
mainClass=zombie/gameStates/MainScreenState
classpath=.;projectzomboid.jar
```

`[LOCAL_PATH_REDACTED]`:

```text
PZ_CLASSPATH=./;projectzomboid.jar
-cp %PZ_CLASSPATH% zombie.gameStates.MainScreenState
```

## Archives and class files

Core/runtime archives:

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`

Map-data ZIPs, not executable core:

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`

Loose third-party class under the mandated G scan root:

- `[LOCAL_PATH_REDACTED]`

Core JAR SHA256:

`901A12E3E2E4F3DE841C17D9A30D0E2FE97115D390E8AF577FDCDCB98C5D7D76`

## Relevant classes

All are contained in `[LOCAL_PATH_REDACTED]`:

- `zombie/Lua/LuaEventManager.class`
- `zombie/characters/IsoGameCharacter.class`
- `zombie/characters/IsoPlayer.class`
- `zombie/characters/BodyDamage/BodyDamage.class`
- `zombie/characters/BodyDamage/BodyPart.class`
- `zombie/characters/BodyDamage/Nutrition.class`
- `zombie/vehicles/BaseVehicle.class`

`OnPlayerGetDamage` occurs in the constant pools of LuaEventManager, IsoGameCharacter, IsoPlayer, BodyDamage, BodyPart, Nutrition, and BaseVehicle. `OnWeaponHitCharacter` occurs in LuaEventManager and IsoGameCharacter.

## Lua scan

- `[LOCAL_PATH_REDACTED]`: absent.
- `[LOCAL_PATH_REDACTED]`: recursively scanned.
- No vanilla Lua source contains `OnPlayerGetDamage` or `OnWeaponHitCharacter`; event emission is implemented in Java bytecode.
- Files using health, BodyDamage, isDead, and isInvincible were enumerated, but none establish Java event/death order.

## Tooling and unreadable items

- Existing `javap.exe`: `[LOCAL_PATH_REDACTED]`.
- `javap -classpath ... -c -p` successfully disassembled all relevant classes.
- The bundled PZ JRE contains `java.exe` but not `jar.exe` or `javap.exe`.
- No source-level decompiler was required or downloaded.
- G's missing launch/core files cannot be read because they no longer exist at that path.
- Map pyramid ZIPs are readable archives but irrelevant to damage ordering.

```
CORE_ARCHIVE_SCAN_COMPLETE=true
CLASSPATH_REPORTED=true
DAMAGE_EVENT_CLASSES_REPORTED=true
DEATH_COMMIT_CLASSES_REPORTED=true
EVIDENCE_PATHS_COMPLETE=true
```


```

## 0.5.53_DYNAMIC_RECHARGE_REPORT.md

- SHA-256: `3EA4B739048C7BFCF2B1FD7AAE58459DC322D70B183EE2634BAE0A4CB3F659E7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Dynamic Recharge Report

- Base requirement: 7 game days.
- Maximum earned reduction: 2 days.
- Minimum effective requirement: 5 game days.
- Well-fed credit: accumulated game hours, up to 1 day after 24 hours by default.
- Healthy credit: health >=95% and no detected severe wound, up to 1 day after 24 hours by default.
- Hunger direction is handled as lower numeric hunger being fuller.
- Invulnerability time is excluded from credit accumulation.
- Elapsed world hours are checkpointed in player modData, capped per observation, and never counted twice.
- Both credit counters and the last credited world hour persist.
- Formula: `effective_required_days = max(minimum_days, base_days - min(max_early_days, well_fed_credit + healthy_credit))`.
- Panic calm is an independent hard gate. Time/credit completion without a post-trigger calm observation yields `WAITING_FOR_CALM`.


```

## 0.5.53_FATAL_DAMAGE_EVENT_ORDER_PROOF.md

- SHA-256: `BA23660F35F68130FB4C97F6B9200BCDDA40BA02CB81B371B636B02C0DBB2378`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Fatal Damage Event Order Proof

## Result

`EVENT_ORDER_RESULT=D`

`D. STATIC_ORDER_NOT_PROVABLE`

The bytecode proves several route-specific orders, but it does not prove one universal Lua edge that can identify and stop every fatal player-damage route before `Kill(...)`.

## Weapon, firearm, and explosive route

Archive: `[LOCAL_PATH_REDACTED]`

Class/method: `zombie.characters.IsoGameCharacter.Hit(HandWeapon, IsoGameCharacter, float, boolean, float, boolean)`

Bytecode order:

1. offset 115: load `OnWeaponHitCharacter`.
2. offset 125: `LuaEventManager.triggerEvent(attacker, target, weapon, damage)`.
3. offset 128: load `OnPlayerGetDamage`.
4. offset 139: `LuaEventManager.triggerEvent(target, "WEAPONHIT", damage)`.
5. offset 161: read one-shot field `avoidDamage`; offsets 167-173 consume it and return zero.
6. offset 261: call `processHitDamage(...)` only when not cancelled.

Class/method: `IsoGameCharacter.processHitDamage(...)`

- offset 1 checks `HandWeapon.isExplosive()`.
- the non-explosive route contains `HandWeapon.isRanged()` checks at offsets 84, 116, and 404.
- therefore firearm and explosive HandWeapon hits share the pre-hit event route.

Class/method: `IsoGameCharacter.hitConsequences(...)`

1. offsets 4-21 apply global reduction and final `CombatManager.applyDamage(...)`.
2. offset 25 calls `isDead()`.
3. offsets 61-78 call `die()` or `Kill(...)` when dead.
4. no `OnPlayerGetDamage` or other general Lua damage event exists between final damage and `Kill(...)`.

The pre-hit event's float is emitted before later damage processing. Static bytecode does not prove it equals the final post-multiplier damage. Thus a character above 20% can theoretically receive a final lethal result that the pre-event projection did not identify.

## Vehicle route

Class/method: `zombie.characters.IsoPlayer.onHitByVehicleApplyDamage(BaseVehicle, float)`

1. offsets 34-37 call the superclass damage application.
2. offsets 47-58 emit `OnPlayerGetDamage(target, "CARHITDAMAGE", appliedDamage)`.

Caller: `IsoGameCharacter.onHitByVehicleApplyDamage(...)`

1. offset 151 calls virtual `applyDamageFromVehicleHit(...)`.
2. offset 155 checks `isDead()` after the override returns.
3. offset 198 calls `Kill(...)` if death changed from false to true.

This route has a same-stack recovery opportunity before the caller's death check, but that does not establish a universal order for other routes.

## BodyDamage and ongoing-health routes

Class/method: `zombie.characters.BodyDamage.BodyDamage.Update()`

- health reductions occur at offsets 1516, 1906, 2052, and 2127.
- corresponding `OnPlayerGetDamage` events occur at offsets 1526, 1909, 2055, and 2130.
- body-part updates occur at offset 2171.
- `calculateOverallHealth()` runs at offset 2181.
- the overall-health <=0 branch begins at offset 2188.

These callbacks precede the final health calculation in this method, so same-tick repair is plausible and locally ordered. It still does not cover the weapon gap after
[EXCERPT_TRUNCATED]
```

## 0.5.53_FATAL_DAMAGE_INTERCEPTION_REPORT.md

- SHA-256: `2E6024CCCAD549903F8B341DB30EAFA05FC2AFEDCE890F44B05232D51AD0613D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Fatal Damage Interception Report

## Candidate implementation

- Channel A registers `OnPlayerGetDamage` and `OnWeaponHitCharacter` when present.
- Candidate damage magnitude is normalized and used to project post-hit health before the regular health threshold is crossed.
- Channel B calls the same idempotent transaction from central `OnPlayerUpdate` every player update.
- Both routes share trait, sandbox, independent-toggle, readiness, committed-death, and re-entry gates.
- The implementation does not scan the world and does not move player coordinates.

## Local evidence and blocker

- The mandated G path was scanned and currently lacks its former core files.
- A complete readable installation was discovered at `[LOCAL_PATH_REDACTED]`.
- `projectzomboid.jar` was inspected with local `javap`; detailed offsets are recorded in `0.5.53_FATAL_DAMAGE_EVENT_ORDER_PROOF.md`.
- Weapon events are pre-final-damage, vehicle/BodyDamage/fire have route-specific same-stack opportunities, and fall emits after a death predicate/flag write.
- No universal post-final-damage event exists before weapon `Kill(...)`, and pre-event weapon damage is not proven equal to final post-multiplier damage.

```
FATAL_DAMAGE_PREDEATH_EVENT=ROUTE_DEPENDENT
FATAL_DAMAGE_PREDEATH_ORDER=PARTIALLY_PROVEN_NOT_UNIVERSAL
ON_WEAPON_HIT_CHARACTER_ORDER=PROVEN_BEFORE_PROCESS_HIT_DAMAGE
HIGH_FREQUENCY_THRESHOLD_FALLBACK=IMPLEMENTED
FULL_BURST_DAMAGE_COVERAGE=NOT_VERIFIABLE
RELEASE_GATE=BLOCKED
```

This source must not be described as guaranteed protection against one-shot damage. Runtime timing logs from the independent diagnostic package are required to determine a safe final design.

```

## 0.5.53_FATAL_TIMING_RUNTIME_TEST_PLAN.md

- SHA-256: `8E95B5443962CB4C93B1CEC5A74C2FE266237AC3CDC761D3BCCF3EBC6677FF43`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.53 Fatal Timing Runtime Test Plan

## Diagnostic package

`[LOCAL_PATH_REDACTED]`

- Mod ID: `XNP_PZ_DistanceRunnerTrait_FATAL_TIMING_TEST`
- Build marker: `XNP_PZ_053_FATAL_TIMING_DIAGNOSTIC_A`
- ModData namespace: `XNP_FATAL_TIMING_DIAG_053`
- It never creates damage and never writes formal Phoenix cooldown fields.
- It performs at most one diagnostic threshold recovery on naturally received damage, logs the next frame, then stops detailed logging for that character.

## Test setup

1. Use a new test character and disposable test save.
2. Enable only the diagnostic mod; disable the formal Distance Runner/Phoenix build to avoid competing healing or event handlers.
3. Keep God Mode, admin invincibility, debug health locking, and other extra-life mods disabled.
4. Preserve the complete console log after each test.
5. Use a fresh character or clear only the diagnostic character ModData before each independent route.

## Test cases

1. Zombie damage: receive ordinary scratches, then a severe bite/drag-down candidate naturally.
2. NPC/firearm: allow a hostile NPC or legitimate game weapon route to hit the player; do not use a script to apply damage.
3. High-damage melee: receive a naturally generated heavy weapon hit.
4. Fall or vehicle: use normal game physics for a hard fall or collision.

## Required log edges

- `OnPlayerGetDamage`
- `OnWeaponHitCharacter`
- `OnPlayerUpdate` in the same or next frame
- `HEALTH_LE_20_PERCENT`
- `HEALTH_LE_ZERO`
- `IS_DEAD_FIRST_TRUE`
- `PHOENIX_TRIGGER_ATTEMPT`
- `PHOENIX_RECOVERY_WRITE`
- `NEXT_FRAME_STATE`
- `OnPlayerDeath` when death commits

Compare `ms`, `frame`, and `seq`. The decisive observation is whether final lethal weapon damage reaches `OnPlayerDeath` before any post-damage update/recovery opportunity, and whether arming `avoidDamage` during the pre-event prevents the final damage when the dangerous hit is identified.

`XNP_PZ_0.5.53_FATAL_TIMING_DIAGNOSTIC_READY`


```

## 0.5.53_INDEPENDENT_TOGGLE_REPORT.md

- SHA-256: `8D881C85FC5A459F3021679E3E3569A4E6F728392E117F8496C72C9BE911B8CE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Independent Toggle Report

- Yellow persisted key: `XNP_DR_YELLOW_ENABLED`.
- Phoenix persisted key: `XNP_DR_PHOENIX_ENABLED`.
- Yellow right click calls the yellow compatibility state only.
- Purple right click calls `PurplePhoenixState.Toggle` only.
- Purple OFF cleans only Phoenix invulnerability and zombie protection; it does not clear cooldown or recovery credits.
- Yellow transient cleanup no longer calls Phoenix cleanup.
- Expected logs: `[XNP YELLOW TOGGLE]` and `[XNP PHOENIX TOGGLE]`.

```
YELLOW_TOGGLE_CHANGES_PHOENIX_ENABLED=false
PHOENIX_TOGGLE_CHANGES_YELLOW_ENABLED=false
YELLOW_ALPHA_DEPENDS_ON_PHOENIX=false
PHOENIX_ALPHA_DEPENDS_ON_YELLOW=false
YELLOW_COLOR_DEPENDS_ON_PHOENIX=false
PHOENIX_COLOR_DEPENDS_ON_YELLOW=false
```


```

## 0.5.53_INVULNERABILITY_REPORT.md

- SHA-256: `E0479F1E9C95E8F72BB696371C2781E0B211BE32D176DEEBBFF3B8EF0C1D9197`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Invulnerability Report

- Default duration: 10 seconds; sandbox range: 0-60.
- Scope: local Phoenix player only.
- Method: save `isInvincible()`, set player-local `setInvincible(true)`, maintain health during the finite window, then restore the exact prior invincible value.
- No global God Mode, time multiplier, coordinate rollback, other-player write, or zombie invulnerability is used.
- Start, throttled protection, and end logs are implemented.
- Active-window state is not stored in modData.
- Game start, death, menu entry, game exit, manual Phoenix OFF, and runtime cleanup all restore the prior value.
- Runtime execution remains `NOT_VERIFIABLE_BY_STATIC_AUDIT`.


```

## 0.5.53_OPEN_SOURCE_COMMENTING_REPORT.md

- SHA-256: `A560D73448DCA352D5C90BF196F8F7B5F7E05A1171386FC08525CE7283896007`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Open Source Commenting Report

New modules document their ownership and safety boundaries:

- `PurplePhoenixState`: independent toggle, persisted recovery contract, world-hour credit formula, hunger direction, panic hard gate.
- `PurplePhoenixInvulnerability`: saved prior state, finite local protection, health fallback, cleanup guarantees.
- `PurplePhoenixDamageGuard`: event signatures, projected damage, and explicit unverified pre-death ordering.
- `PurplePhoenixRevive`: single transaction, cure isolation, verification, and re-entry prevention.
- `PurplePhoenixUI`: independent state ownership, colors, dragging, and right-click scope.

Comments do not claim that static inspection proves runtime event ordering. Existing useful baseline comments were retained except where they described the removed shared-master behavior.


```

## 0.5.53_PHOENIX_ICON_ASSET_REPORT.md

- SHA-256: `CFE28EBE8730D89BA1C6223AB93B1561312E18F4CC13D2FB6DFA355A77E6CC6D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Phoenix Icon Asset Report

- Yellow reference: `42/media/ui/Traits/trait_xnpdistancerunner.png`
- Yellow SHA256: `8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9`
- Purple content source: `[LOCAL_PATH_REDACTED]`
- Purple output: `42/media/ui/Traits/trait_xnppurplephoenix.png`
- Purple SHA256: `6273E586EB260B167C236FABDEC4A039973AFDD1D78355A6487F1601101FCDDE`
- Yellow canvas: 18x18; purple canvas: 18x18.
- Purple nontransparent bounding box: `(1,1)-(16,16)`.
- Purple transparent pixels: 108 of 324.
- All four corner pixels are transparent by construction; circular exterior check passed.
- The source content was uniformly scaled to a square before applying a circular alpha mask; aspect ratio was not changed.
- `item00.png` was not read or used.

The yellow source itself is fully opaque across its 18x18 canvas, so it does not contain a reusable alpha mask. Its canvas and UI slot were used as the dimensional template; the required circular transparency was generated explicitly for the purple asset.


```

## 0.5.53_SANDBOX_CONFIGURATION_REPORT.md

- SHA-256: `C8250F24BC7CAAF645CC37C0BD56DE0C627B7505F9C6FE73D4E79F420FE46A61`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Sandbox Configuration Report

All required Phoenix options are present with typed defaults: enable, informational point cost 1, trigger 20%, invulnerability 10 seconds, base cooldown 7 days, panic gate and threshold, early-credit enable/max/minimum, well-fed and healthy caps/hours/health threshold, full cure, zombification clearing, endurance restore, zombie-protection radius/duration, icon visibility, tooltip, and invulnerability flashing.

- Option-to-CN key parity: PASS.
- Option-to-EN key parity: PASS.
- Boolean/integer/double declarations: PASS by text audit.
- Old active keys for 10% main, 5% forced, old cooldown name, and old endurance name: absent.
- Configuration refresh prints the effective summary.
- Live game option parsing: `NOT_VERIFIABLE_BY_STATIC_AUDIT`.


```

## 0.5.53_TRAIT_COST_REPORT.md

- SHA-256: `26A91ABF55DC068969A06D3D42C4FFA21F7E0267E90CDB1FC320A27F2235DE5E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 Trait Cost Report

- `PHOENIX_TRAIT_COST=1`
- `DISTANCE_RUNNER_TRAIT_COST=1`
- `BOTH_TRAITS_SELECTABLE=true`
- Phoenix full ID remains `XNPPhoenixTrait:XNPPurplePhoenix`.
- Distance Runner identity is unchanged.
- Script definition and Phoenix constants both use cost 1.
- English and Chinese descriptions contain no active 8-point statement.
- `PhoenixTraitPointCost` is exposed as an informational sandbox value. Build 42 trait registration occurs before character creation, so changing it is not treated as a live runtime mutation.


```

## 0.5.53_UI_STATE_ISOLATION_REPORT.md

- SHA-256: `B31F4ACA84CF6225E97EB863DBAB27A1840AA90B8B4045FC9D06B75335124A1F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.53 UI State Isolation Report

```
YELLOW_TOGGLE_CHANGES_PHOENIX_ENABLED=false
PHOENIX_TOGGLE_CHANGES_YELLOW_ENABLED=false
YELLOW_ALPHA_DEPENDS_ON_PHOENIX=false
PHOENIX_ALPHA_DEPENDS_ON_YELLOW=false
YELLOW_COLOR_DEPENDS_ON_PHOENIX=false
PHOENIX_COLOR_DEPENDS_ON_YELLOW=false
YELLOW_POSITION_KEY_UNIQUE=true
PHOENIX_POSITION_KEY_UNIQUE=true
YELLOW_PANEL_INSTANCE_UNIQUE=true
PHOENIX_PANEL_INSTANCE_UNIQUE=true
```

Phoenix presentation states are: OFF white, READY blue, INVULNERABLE bright blue/pulse, COOLDOWN dark blue, and WAITING_FOR_CALM calm blue-grey. The purple panel has its own class, player reference, drag state, texture, and position keys. No square background or border is drawn behind the circular asset.


```
