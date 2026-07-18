# 0.5.60.1 Sanitized Evidence Excerpts

## 0.5.60.1_死亡后复活错误根因.md

- SHA-256: `D3939C18F7F15F5F36D2EE191D5E363A9A180C9B8F61CC1CB945C15A673E7C59`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] 姝讳骸鍚庡娲婚敊璇牴鍥?
```text
VERSION=0.5.60
USER_RUNTIME_RESULT=FAILED_P0
FAILURE=ENGINE_DEAD_BUT_SCRIPT_REVIVED_GHOST_STATE
ROOT_CAUSE=OnPlayerUpdateThresholdFallback_TRIGGERED_AT_HEALTH_ZERO_AFTER_PLAYER_DEATH
ROOT_CAUSE_CODE=POST_DEATH_THRESHOLD_FALLBACK_HEALTH_WRITE
SEVERITY=P0
```

0.5.60 鐨勫喅瀹氭€ф棩蹇楅『搴忔槸 `player_death` 娓呯悊涔嬪悗锛屾棫鐜╁瀵硅薄鍙堜互 `health=0.0000` 杩涘叆 ThresholdFallback锛岄殢鍚庡紑濮?10 绉掓棤鏁屽苟杈撳嚭 `revive_success`銆傝繖浣垮紩鎿庢浜?鏂拌鑹叉祦绋嬩笌琚剼鏈啓鍥炵敓鍛界殑鏃ц鑹插悓鏃跺瓨鍦ㄣ€?
[IP_REDACTED] 涓嶅皾璇曟竻姝讳骸鏍囧織銆佸垹灏镐綋鎴栦簨鍚庝慨琛ャ€備慨澶嶆柟寮忔槸锛氭浜″洖璋冨厛姘镐箙 tombstone 鏃у疄渚嬶紝鎵€鏈?Phoenix 鐢熷懡璇诲啓鍓嶉€氳繃鍞竴娲讳綋闂ㄧ锛宧ealth<=0 鐩存帴鍙栨秷锛涙灙姊伴槻绉掓潃鍙蛋浼ゅ鎻愪氦鍓嶇殑 `OnWeaponHitCharacter` 涓€娆℃€т簨鍔°€?
璇佹嵁 console SHA256锛歚A7E3F5E913A3E6D351090DF7A489DDC7D27FEC27A5ED5AAAF908AD3EFC27FE78`銆?
WarThunderVehicleLibrary 涓?Bandits Week One 鎶ラ敊浠嶅綊绗笁鏂癸紱鏈?P0 鏄庣‘褰?XNP Phoenix 閫昏緫銆?
```

## 0.5.60.1_B42_PLAYER_DEATH_COMMIT_AND_LIVING_GATE_EVIDENCE.md

- SHA-256: `8DA7962EA5C1A95FDFFAB419362DC374E53D9F386FD62EE381E6433BC20A0838`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] B42 Player Death Commit And Living Gate Evidence

## Evidence Sources

- JAR: `[LOCAL_PATH_REDACTED]`
- Vanilla Lua: `[LOCAL_PATH_REDACTED]`
- Build: Project Zomboid 42.19.0
- Inspection: `javap -c -p` plus vanilla Lua text search

## Engine Order

`IsoPlayer.OnDeath()` invokes `Events.OnPlayerDeath(player)` at bytecode offsets 64-68. Vanilla `ISPostDeathUI.OnPlayerDeath` immediately creates and shows the post-death panel for that player index.

`IsoGameCharacter.die()` calls private `becomeCorpse()` at offset 60. `becomeCorpse()` constructs `IsoDeadBody` and stores it in private `diedBody`; `die()` then calls `setOnDeathDone(true)` at offset 68. The corpse field has no public read accessor exposed to Lua.

`IsoGameCharacter.isDead()` returns true when direct health is nonpositive or `BodyDamage.getHealth()` is nonpositive. `isOnDeathDone()` reads the committed `dead` field. `isAlive()` is the inverse of `isDead()`.

## Central Gate

The one authoritative implementation is `XNP_DR_PhoenixLifeGate.lua`:

`XNP_DR_PhoenixLifeGate.IsLivingPlayer(player)`

It requires all of the following before Phoenix can read or write health:

1. Required player APIs exist.
2. The object is not in the session tombstone set.
3. `getSpecificPlayer(player:getPlayerNum())` is the same object.
4. `isLocalPlayer()` is true.
5. `isOnDeathDone()` is false.
6. `isDead()` is false and `isAlive()` is true.
7. Direct player health is greater than zero.
8. overall BodyDamage health is greater than zero.

`OnPlayerDeath` tombstones the exact object before cleanup. This closes the interval before corpse construction and `OnDeathDone`. A replaced object also fails exact identity comparison. Tombstones and diagnostic tokens use weak object-key tables, so a still-referenced residual callback remains blocked without retaining the old player after all external references are released.

```text
CENTRAL_LIVING_GATE_COUNT=1
DEATH_FLAG_CHECK_PROVEN=true
HEALTH_POSITIVE_CHECK=true
CURRENT_PLAYER_IDENTITY_CHECK=true
CORPSE_OR_DEATH_FLOW_CHECK_PROVEN=true
DEAD_INSTANCE_TOMBSTONE=true
POST_DEATH_WRITE_PATH_COUNT=0
```

Runtime behavior remains `NOT_YET_TESTED`.

```

## 0.5.60.1_DEAD_PLAYER_CLEANUP_AND_NEW_CHARACTER_REINIT_REPORT.md

- SHA-256: `5E55FA037B5E9020954ACCB187C7231433DEF04E9534F91C34D16B779F45CB1B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Dead Player Cleanup And New Character Reinit Report

`Bootstrap.OnPlayerDeath(player)` now performs this order:

1. Tombstone the exact old player identity.
2. Clear the weapon callback transaction.
3. Cancel an in-progress Phoenix transaction.
4. Discard invulnerability/protect compatibility state without writing the player.
5. Clear the five-second test deadline on the old ModData and disable its Phoenix state.
6. Reset Phoenix, Distance Runner, and extra-trait player caches.
7. Call central runtime cleanup with the explicit old player.
8. Hide all four panels, release drag capture, and clear the shared tooltip owner.
9. Release scheduler player-key state and clear world-query references.

Cleanup never calls `setHealth`, `setOverallBodyHealth`, `RestoreToFullHealth`, `setOnDeathDone`, `clearDiedBody`, or `becomeCorpse`.

`OnCreatePlayer` initializes a different object identity, resets trait caches, clears transient compatibility state, and rebuilds UI only after trait detection. A new character without Phoenix does not show or run Purple Phoenix.

```text
DEATH_SCREEN_BLOCKED_BY_XNP=false
DEAD_PLAYER_CAN_MOVE_AFTER_SCRIPT_REVIVE=false
OLD_PLAYER_REFERENCE_RELEASED=true
NEW_PLAYER_IDENTITY_REINITIALIZED=true
OLD_PHOENIX_TRANSACTION_CARRIED_TO_NEW_PLAYER=false
OLD_PLAYER_MODDATA_COPIED_TO_NEW_PLAYER=false
```

These are static control-flow results. Runtime ghost-state regression testing is pending.

```

## 0.5.60.1_FATAL_AND_PROJECTILE_RUNTIME_TEST_MATRIX.md

- SHA-256: `65A5A6399839217DD7F70B13C7AFE56353CD6CFA903BC9EAD9367FE603C70F21`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Fatal And Projectile Runtime Test Matrix

| ID | Setup | Expected |
|---|---|---|
| A | Living BLUE at 21%; small damage predicts 20.1% | no trigger; BLUE remains |
| B | Living BLUE at 21%; damage predicts exactly 20.0% | one trigger; WHITE for 5 real seconds |
| C | Living BLUE at 100%; one ranged hit predicts lethal | intercept before commit; no death UI; WHITE |
| D | Continue firing during WHITE | later bullets damage normally and may kill; no script revival |
| E | Observe fallback after `player_death`, health 0 | one low-noise cancel; zero health writes; zero success |
| F | Corpse/death/new-character flow active | no trigger; vanilla flow continues |
| G | WHITE expires | GREEN; no invulnerability; no protect pulse |
| H | Right-click GREEN | BLUE; no inherited protection |
| I | New character lacks Phoenix | no Purple panel/runtime; no old transaction |
| J | BLUE right-click | GREEN; no protection |
| K | WHITE right-click | remains WHITE and locked |

Required console checks:

- Successful ranged intercept contains `source=PROJECTILE`, `avoid_damage_armed=true`, and one transaction ID.
- Same transaction may print `duplicate_callback_blocked=true` once.
- Death-committed fallback prints `cancel reason=DEATH_ALREADY_COMMITTED` at most once for the old identity.
- No `PHOENIX INVULNERABILITY start` or `protect_pulse` line is allowed.

```text
USER_RUNTIME_TEST=NOT_YET_TESTED
PROJECTILE_RUNTIME_TEST=NOT_YET_TESTED
POST_DEATH_GHOST_STATE_RUNTIME_TEST=NOT_YET_TESTED
```

```

## 0.5.60.1_PHOENIX_20_PERCENT_THRESHOLD_MATRIX.md

- SHA-256: `969DF3370709BA57CA23CF39D471E191AE48FDF411964DD880D4F1E70B8ED8DA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Phoenix 20 Percent Threshold Matrix

Runtime config freezes `triggerHealth` to `0.20`. Sandbox metadata is also fixed to min/max/default 20 so a stale option cannot restore the old 30 percent route.

| Current | Predicted after transaction | Living gate | BLUE/ready | Expected |
|---:|---:|---|---|---|
| 0.2100 | 0.2001 | pass | yes | no trigger |
| 0.2100 | 0.2000 | pass | yes | trigger once |
| 0.2001 | no damage | pass | yes | no trigger |
| 0.2000 | no damage | pass | yes | trigger once |
| 1.0000 | 0.0000 projectile prediction | pass before damage | yes | pre-death trigger once |
| 0.0000 | 0.0000 | fail | any | cancel, no write |
| any | any | tombstoned/death done | any | cancel, no write |
| <=0.20 | <=0.20 | pass | WHITE/GREEN | no trigger |

```text
PHOENIX_LOW_HEALTH_THRESHOLD=0.20
HEALTH_0_2000_CAN_TRIGGER=true
HEALTH_0_2001_CAN_TRIGGER=false
HEALTH_ZERO_POST_UPDATE_TRIGGER=false
THRESHOLD_FALLBACK_DEAD_PLAYER_TRIGGER=false
POST_DEATH_HEALTH_WRITE_COUNT_EXPECTED=0
```

Boundary behavior is statically implemented; user runtime confirmation is pending.

```

## 0.5.60.1_PROJECTILE_ANTI_ONESHOT_MATRIX.md

- SHA-256: `5D60A804179B7B08F766020A0D1F0CA49C7836A3AACA054EB7BF2DB078C0810B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Projectile Anti-Oneshot Matrix

| Scenario | Event result | Health write | avoidDamage | State |
|---|---|---:|---|---|
| Living BLUE, predicted remains above 20% | reject above threshold | 0 | no | BLUE |
| Living BLUE, predicted reaches 20% | one transaction | recovery once | yes, one engine hit | WHITE |
| Living BLUE, predicted lethal | one pre-death transaction | recovery once | yes, one engine hit | WHITE |
| Duplicate WEAPONHIT callback for same bullet | duplicate rejected | 0 | no additional write | WHITE |
| New bullet during WHITE | cooldown rejected | 0 | no | WHITE; damage proceeds |
| New bullet during GREEN | toggle-off rejected | 0 | no | GREEN; damage proceeds |
| Death committed before callback | living gate rejects | 0 | no | no transition |
| Old player callback after replacement | identity/tombstone rejects | 0 | no | no transition |

```text
WHITE_CONTINUOUS_PROTECTION=false
GREEN_CONTINUOUS_PROTECTION=false
POST_TRIGGER_INVULNERABILITY_SECONDS=0
REPEATING_PROTECT_PULSE_SECONDS=0
USER_RUNTIME_TEST=NOT_YET_TESTED
```

```

## 0.5.60.1_PROJECTILE_PREDEATH_SOURCE_AND_TRANSACTION_EVIDENCE.md

- SHA-256: `06441B6C2FCB32C7ECB6DD0DDE7988691BD9F5013EFECA3EF1D86018BFD0B3F9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Projectile Predeath Source And Transaction Evidence

## B42.19 Bytecode Contract

In `IsoGameCharacter.Hit(HandWeapon, IsoGameCharacter, float, ...)`:

- offsets 115-125: `OnWeaponHitCharacter(attacker, target, weapon, damage)`
- offsets 128-139: `OnPlayerGetDamage(target, "WEAPONHIT", damage)`
- offsets 161-173: target `avoidDamage` is read, cleared, and the method returns before damage
- offset 261: `processHitDamage(...)`
- offset 275: `hitConsequences(...)`

`HandWeapon.isRanged()` is the proven projectile classifier. `isExplosive()` is checked first for explosion classification. Therefore projectile identity is not guessed from the later `WEAPONHIT` string.

## Selected Route

`OnWeaponHitCharacter` creates one event transaction ID and evaluates predicted health while the target is still living. A successful transaction performs the Phoenix recovery, enters WHITE, then calls `target:setAvoidDamage(true)`. The engine consumes and clears that one-shot bit before `processHitDamage`.

The immediately following `OnPlayerGetDamage(..., WEAPONHIT, ...)` consumes the pending event record as a duplicate callback and cannot spend Phoenix again. The record is removed on that callback. The next bullet begins with a new `OnWeaponHitCharacter`, so no transaction lock persists into future damage.

If the weapon event is missing, the later `WEAPONHIT` callback returns `WEAPON_SOURCE_NOT_PROVEN_WITHOUT_WEAPON_EVENT` rather than guessing PROJECTILE.

```text
PROJECTILE_SOURCE_PROVEN=true
PROJECTILE_PREDEATH_ORDER_PROVEN=true
PROJECTILE_DIRECT_LETHAL_INTERCEPT_BEFORE_COMMIT=true
PROJECTILE_POST_DEATH_REVIVE=false
SINGLE_PROJECTILE_TRANSACTION_TRIGGER_MAX=1
TRANSACTION_LOCK_BLOCKS_ONLY_DUPLICATE_CALLBACK=true
TRANSACTION_LOCK_BLOCKS_FUTURE_DAMAGE=false
BURST_FIRE_GRANTS_PERSISTENT_INVULNERABILITY=false
PROJECTILE_RUNTIME_TEST=NOT_YET_TESTED
```

```

## 0.5.60.1_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `82B3934A2F544D2BDE1ADD57C2103279FD444E4A1AE3166049BF38E27185677E`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Runtime Preservation Report

[IP_REDACTED] was copied from the independent 0.5.60 SOURCE. Runtime changes are limited to identity plus the Phoenix death/threshold/projectile path and explicit old-player reference release.

Changed runtime/config files:

- `XNP_DR_Constants.lua`
- `XNP_DR_Bootstrap.lua`
- `XNP_DR_Runtime.lua`
- `XNP_DR_PerformanceScheduler.lua` (old-player key release only)
- `XNP_DR_PhoenixLifeGate.lua` (new)
- Phoenix constants, config, state, revive, damage guard, invulnerability compatibility, protect compatibility
- `XNP_DR_RoundMarkerFrame.lua` (version log only)
- Phoenix sandbox defaults and English Phoenix option descriptions
- root and `42` mod identity

Unchanged behavior/assets include map-open hiding, map-close restore, shared tooltip, red HUD double-click TimedAction, red dual mode, preview/poster assets, four round center assets, fast drag, yellow five-color/shake, red P source asset, and green placeholder.

```text
XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
DEAD_STATE_CHECK_USES_EXISTING_CENTRAL_UPDATE=true
PROJECTILE_TRANSACTION_GATE_NO_POLLING=true
NORMAL_IDLE_PER_FRAME_LOGGING=false
MAP_HIDE_PRESERVED=true
TOOLTIP_PRESERVED=true
RED_DOUBLE_CLICK_PRESERVED=true
FOUR_MARKER_ASSETS_PRESERVED=true
SOURCE_DERIVED_FROM_0.5.60=true
OLD_SOURCE_MODIFIED=false
```

```

## BUILD_MARKER.txt

- SHA-256: `9093388479565634DE1961B98FB136BC71E34771FC0627ABBC8796D4A053F569`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_05601_PHOENIX_LIVING_ONLY_20_THRESHOLD_PROJECTILE_GUARD_A

```

## FINAL_REPORT.md

- SHA-256: `23FDD1114C5A5647750D5138C506B07BED2BB1DCFC9822804500A2C9AEEEE40C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ [IP_REDACTED] Final Report

```text
SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=[IP_REDACTED]
INTERNAL=[IP_REDACTED]-b42-phoenix-living-only-20-threshold-projectile-guard-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05601_PHOENIX_LIVING_ONLY_20_THRESHOLD_PROJECTILE_GUARD_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
DISPLAY_NAME=[[IP_REDACTED]] XNP Phoenix Living-Only Guard
```

## P0 Resolution

The supplied console is preserved byte-for-byte at `閿欒鎶ュ憡\console(24)_0.5.60涓ラ噸姝讳骸澶嶆椿閿欒.txt`.

```text
CONSOLE_SHA256=A7E3F5E913A3E6D351090DF7A489DDC7D27FEC27A5ED5AAAF908AD3EFC27FE78
ROOT_CAUSE=POST_DEATH_THRESHOLD_FALLBACK_HEALTH_WRITE
SEVERITY=P0
POST_DEATH_REVIVE_ALLOWED=false
THRESHOLD_FALLBACK_HEALTH_ZERO_TRIGGER=false
THRESHOLD_FALLBACK_DEAD_PLAYER_TRIGGER=false
DEAD_INSTANCE_TOMBSTONE=true
POST_DEATH_HEALTH_WRITE_COUNT_EXPECTED=0
POST_DEATH_REVIVE_SUCCESS_COUNT_EXPECTED=0
```

## Living Gate And Death Flow

```text
CENTRAL_LIVING_GATE=XNP_DR_PhoenixLifeGate.IsLivingPlayer
CENTRAL_LIVING_GATE_COUNT=1
DEATH_FLAG_CHECK_PROVEN=true
HEALTH_POSITIVE_CHECK=true
CURRENT_PLAYER_IDENTITY_CHECK=true
CORPSE_OR_DEATH_FLOW_CHECK_PROVEN=true
POST_DEATH_WRITE_PATH_COUNT=0
DEATH_SCREEN_BLOCKED_BY_XNP=false
OLD_PLAYER_REFERENCE_RELEASED=true
NEW_PLAYER_IDENTITY_REINITIALIZED=true
OLD_PHOENIX_TRANSACTION_CARRIED_TO_NEW_PLAYER=false
```

## Threshold And State

```text
PHOENIX_LOW_HEALTH_THRESHOLD=0.20
HEALTH_0_2000_CAN_TRIGGER=true
HEALTH_0_2001_CAN_TRIGGER=false
PHOENIX_TEST_COOLDOWN_REAL_SECONDS=5.00
BLUE=READY_ENABLED
WHITE=COOLDOWN_LOCKED_NO_PROTECTION
GREEN=READY_DISABLED_NO_PROTECTION
```

## Projectile Transaction

```text
PROJECTILE_SOURCE_PROVEN=true
PROJECTILE_SOURCE=HandWeapon.isRanged
PROJECTILE_PREDEATH_ORDER_PROVEN=true
PROJECTILE_DIRECT_LETHAL_INTERCEPT_BEFORE_COMMIT=true
PROJECTILE_POST_DEATH_REVIVE=false
SINGLE_PROJECTILE_TRANSACTION_TRIGGER_MAX=1
TRANSACTION_LOCK_BLOCKS_ONLY_DUPLICATE_CALLBACK=true
TRANSACTION_LOCK_BLOCKS_FUTURE_DAMAGE=false
```

## Removed Continuous Protection

```text
POST_TRIGGER_INVULNERABILITY_SECONDS=0
REPEATING_PROTECT_PULSE_SECONDS=0
INVULNERABILITY_START_CALL_REACHABLE_COUNT=0
REPEATING_PROTECT_PULSE_REACHABLE_COUNT=0
WHITE_DAMAGE_NEGATION=false
GREEN_DAMAGE_NEGATION=false
STALE_0.5.60_INVULNERABILITY_MIGRATION_CLEARED=true
INVULNERABILITY_PER_FRAME_WRITE=false
PROTECT_PULSE_SCHEDULER_ACTIVE=false
```

## Validation

```text
SOURCE_LUA_COUNT=86
SOURCE_LUA_LINES=14593
SOURCE_KAHLUA_PASS=86
SOURCE_KAHLUA_FAIL=0
DROP_KAHLUA_PASS=86
DROP_KAHLUA_FAIL=0
XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
SOURCE_DROP_MIRROR_MISMATCH=0
SOURCE_PUBLIC_PAYLOAD_SHA256=40B35EAD935415B2FB7C1056C9EE99CCEAB38EBDED813903B5AEB03DCE7F3D05
DROP_TREE_SHA256=40B35EAD935415B2FB7C1056C9EE99CCEAB38EBDED813903B5AEB03DCE7F3D05
PROJECTZOMBOID_JAR_SHA256=901A12E3E2E4F3DE841C17D9A30D0E2FE97115D390E8AF577FDCDCB98C5D7D76
OLD_SOURCE_TREE_SHA256=97B6A62754F70762251F2E53880208BBCB2A2249ADC642B4BEB8AF2B3569E
[EXCERPT_TRUNCATED]
```

## sandbox-options.txt

- SHA-256: `A538DC106F03DBACF167483BE8E74115B02481062F181CB6D47005F6C66A44D6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
VERSION = 1,

option XNPDistanceRunner.EnableMod
{
    type = boolean, default = true,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_EnableMod,
}

option XNPDistanceRunner.TuningPreset
{
    type = enum, numValues = 3, default = 1,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_TuningPreset,
    valueTranslation = XNPDistanceRunner_TuningPreset,
}

option XNPDistanceRunner.EnableDebugSummary
{
    type = boolean, default = false,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_EnableDebugSummary,
}

option XNPDistanceRunner.LiveRefreshTuning
{
    type = boolean, default = true,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_LiveRefreshTuning,
}

option XNPDistanceRunner.GlobalSkillCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_GlobalSkillCostMultiplier,
}

option XNPDistanceRunner.ZombieImpactCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 0.24,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_ZombieImpactCostMultiplier,
}

option XNPDistanceRunner.JogBumpCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_JogBumpCostMultiplier,
}

option XNPDistanceRunner.SprintPrecollisionCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_SprintPrecollisionCostMultiplier,
}

option XNPDistanceRunner.SprintVehicleZombieCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_SprintVehicleZombieCostMultiplier,
}

option XNPDistanceRunner.ControlledEscapeCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_ControlledEscapeCostMultiplier,
}

option XNPDistanceRunner.NativeTripCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_NativeTripCostMultiplier,
}

option XNPDistanceRunner.StaminaAssistIntensity
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_StaminaAssistIntensity,
}

option XNPDistanceRunner.BlueRefundPercent
{
    type = integer, min = 0, max = 90, default = 30,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_BlueRefundPercent,
}

option XNPDistanceRunner.YellowRefundPercent
{
    type = integer, min = 0, max = 90, default = 38,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_YellowRefundPercent,
}

option XNPDistanceRunner.RedRefundPercent
{
    type = integer, min = 0, max = 90, default = 55,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_RedRefundPercent,
}

option XNPDistanceRunner.ExtraHungerCostMultiplier
{
    type = double, min = 0
[EXCERPT_TRUNCATED]
```

## preview.png

- SHA-256: `9C91BDB92E08C7C3E2DE6162F2F7C9DCC19D32A9F9DE0189799BB710D7178B9E`
- Type: 截图
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED
