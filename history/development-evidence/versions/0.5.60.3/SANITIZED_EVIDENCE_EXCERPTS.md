# 0.5.60.3 Sanitized Evidence Excerpts

## 0.5.60.3_子弹坠落迟到伤害与多轮状态问题.md

- SHA-256: `019585D815A8C6578F2EA8B38FD88BDF9C5515F8BF77A8E1EADD170F83B1E95F`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] 瀛愬脊鍧犺惤杩熷埌浼ゅ涓庡杞姸鎬侀棶棰?
[IP_REDACTED] 瀹炴満璇佹嵁纭涓夋鎭㈠涓庝笁娆″喎鍗村畬鎴愶紝浣嗘渶缁堝瓨鍦?`OnPlayerGetDamage` 鍒拌揪鏃朵汉鐗╁凡鏄?`ENGINE_DEAD` 鐨勮繜鍒板洖璋冿紝涓旀浜¤瘖鏂疮璁?50 琛屻€傛渶缁堣嚧姝绘簮娌℃湁琚棩蹇楄瘉鏄庯紝涓嶈兘寮鸿鏍囦负瀛愬脊鎴栧潬钀姐€?
[IP_REDACTED] 灏嗘仮澶嶆敹鏁涘埌鍗曚竴浜嬪姟鍏ュ彛銆傚師鐗堣繙绋嬫鍣ㄥ湪 `OnWeaponHitCharacter` 鍓嶇疆杈圭紭澶勭悊锛涘潬钀戒笉鍐嶄緷璧栬繜鍒扮殑 `FALLDOWN` 鍥炶皟锛岃€屽湪钀藉湴鍓嶉娴嬭嚧鍛藉啿鍑诲苟鍙竻闆跺綋鍓嶈惤鍦伴€熷害銆傛浜℃棩蹇楃敱鐢熷懡闂ㄥ叡浜竴浠ｄ竴涓幓閲嶆爣璁般€?
```text
LATE_FATAL_CALLBACK_CONFIRMED=true
EXACT_FATAL_SOURCE_AT_FINAL_DEATH=NOT_PROVEN
POST_DEATH_REVIVE=false
RUNTIME_RETEST_REQUIRED=true
```

```

## 0.5.60.3_B42_FALL_DAMAGE_PREDEATH_ORDER_EVIDENCE.md

- SHA-256: `638E35630922BAC073DD1A68BEC18D6B4C0B48A8CD872E246C924EFD020B6F48`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] B42 Fall Damage Predeath Order Evidence

Inspected artifact: `[LOCAL_PATH_REDACTED]`, Build 42.19.0. Inspection used `javap`; the game was not started.

`IsoGameCharacter.handleLandingImpact(FallDamage)` commits fall damage before the Lua damage callback:

1. bytecode 466 calls `BodyDamage.ReduceGeneralHealth(damage)`;
2. bytecode 519 calls `BodyDamage.Update()`;
3. the dead result is evaluated and `setKilledByFall` may be set;
4. bytecode 545 emits `OnPlayerGetDamage(player, "FALLDOWN", damage)`.

Therefore `OnPlayerGetDamage(FALLDOWN)` is a late notification and is not used as the predeath edge.

`updateFalling()` advances `lastFallSpeed`, detects the floor, calls `DoLand(impactSpeed)`, and then clears fall fields. Public B42 methods confirmed in the JAR include `isFalling`, `isbFalling`, `getHeightAboveFloor`, `getLastFallSpeed`, `getFallSpeedSeverity`, `setFallTime`, and `setLastFallSpeed`.

The implemented predeath edge runs from the existing single `OnPlayerUpdate` handler while the prior frame still reports falling. It predicts impact from current speed and remaining height using the engine acceleration constant, requires a lethal threshold, requires height <= 3.0, commits the Phoenix transaction while the living gate still passes, then calls `setLastFallSpeed(0)`. The remaining fall is below B42's 3.5-height lethal threshold, so the next engine fall step cannot submit the original lethal impact. No god mode, post-trigger invulnerability, or protection pulse is used.

```text
FALL_SOURCE_PROVEN=true
FALL_PREDEATH_EDGE_PROVEN=true
FALL_FATAL_INTERCEPT_BEFORE_DEATH_COMMIT=true
FALL_POST_DEATH_REVIVE=false
SINGLE_LANDING_TRIGGER_MAX=1
WHITE_OR_GREEN_FALL_PROTECTION=false
POST_TRIGGER_CONTINUOUS_INVULNERABILITY=false
FATAL_FALL_USER_TEST=NOT_YET_TESTED
```

Static proof covers the B42 engine order and the Lua admission path. Real fall outcomes remain a required user test.

```

## 0.5.60.3_B42_PROJECTILE_PREDEATH_ORDER_RECHECK.md

- SHA-256: `1FCFA8FAF88BE6D71154B4111ACB323A9D97E615EFAB7D9638253A70CEB64A8E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] B42 Projectile Predeath Order Recheck

Inspected artifact: `[LOCAL_PATH_REDACTED]`, Build 42.19.0.

In `IsoGameCharacter.Hit(HandWeapon, attacker, damage, ...)`:

1. bytecode 115-125 emits `OnWeaponHitCharacter(attacker, target, weapon, damage)`;
2. bytecode 128-139 emits `OnPlayerGetDamage(target, "WEAPONHIT", damage)`;
3. bytecode 160 checks `avoidDamage`; when true it clears the one-shot flag and returns before `processHitDamage`.

The implementation classifies `weapon:isExplosive()` before `weapon:isRanged()`. A true ranged weapon becomes `PROJECTILE_FATAL_EDGE`; explosion and melee remain distinct. The central transaction commits recovery and arms the engine's one-shot `setAvoidDamage(true)` during `OnWeaponHitCharacter`, before the engine consumes the flag. The paired `WEAPONHIT` callback is correlation-only. Each weapon event gets a fresh serial, so the next bullet in a burst is a new transaction.

Third-party routes that do not call this B42 `Hit` path are not guessed as projectiles and remain `UNKNOWN`.

```text
RANGED_SOURCE_CLASSIFICATION_PROVEN=true
PROJECTILE_PREDEATH_EDGE_PROVEN=true
PROJECTILE_FATAL_INTERCEPT_BEFORE_DEATH_COMMIT=true
SINGLE_PROJECTILE_TRIGGER_MAX=1
BURST_NEXT_PROJECTILE_IS_NEW_TRANSACTION=true
PROJECTILE_POST_DEATH_REVIVE=false
PROJECTILE_FATAL_USER_TEST=NOT_YET_TESTED
```

```

## 0.5.60.3_FATAL_FALL_TRANSACTION_MATRIX.md

- SHA-256: `9B277706831141963C585087F45EBD92A5A5927B8D8D6775E2E4B82B31CE2C41`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Fatal Fall Transaction Matrix

| State/source | Admission | Neutralization |
|---|---|---|
| BLUE, living, predicted lethal, pre-landing | yes | current `lastFallSpeed` set to zero once |
| BLUE, nonlethal fall | no | none |
| WHITE or GREEN | no | none; normal fall damage |
| engine-dead/tombstoned | no | none; no health write |
| duplicate same landing | no | state is already WHITE |
| API/prediction unavailable | no | explicit skip; no guessed write |

```text
FALL_TRANSACTION_ID_PER_LANDING=true
FALL_SPEED_WRITE_TARGET=CURRENT_LANDING_ONLY
FALL_GOD_MODE_USED=false
FALL_PROTECT_PULSE_USED=false
SINGLE_LANDING_TRIGGER_MAX=1
```

```

## 0.5.60.3_FOUR_MARKER_TOOLTIP_CONTENT_REPORT.md

- SHA-256: `729A17C307769A1DCC06BBAA627815A1AFE5C2FDED447AB0E9FD703EB308C2C9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Four Marker Tooltip Content Report

CN and EN `UI.json` now contain complete, marker-specific names and instructions for yellow status/colors/toggle, Phoenix BLUE/WHITE/GREEN behavior, green bomb/melee controls, and red dual modes/use. All four panels call the same `XNP_DR_RoundMarkerTooltip` singleton. Its `ISToolTip` has mouse consumption disabled, hides on drag/map/cleanup, and is refreshed only for the current owner.

```text
YELLOW_TOOLTIP_COMPLETE=true
PURPLE_TOOLTIP_COMPLETE=true
GREEN_TOOLTIP_COMPLETE=true
RED_TOOLTIP_COMPLETE=true
TOOLTIP_SHARED_INSTANCE_COUNT=1
TOOLTIP_VISIBLE_RUNTIME_TEST=NOT_YET_TESTED
FOUR_TOOLTIP_USER_TEST=NOT_YET_TESTED
```

```

## 0.5.60.3_GREEN_BOMB_COOLDOWN_MATRIX.md

- SHA-256: `B60BD3380CA2B3A2C226F81E42CDFCB84F67E1DAFB1B4C1A296AA55D07470846`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Green Bomb Cooldown Matrix

The stable `Base.PipeBomb` creation, three-square layout, `IsoTrap`, 4-second detonation callback, and existing sound key are unchanged. A second central active-seconds task owns the independent 5-second cooldown. Admission is atomic: if the cooldown task cannot register, the detonation task is cancelled and all newly placed traps are rolled back.

| Action | Result |
|---|---|
| accepted double-click | 3 bombs; 4-second detonation; 5-second cooldown |
| double-click during cooldown | no bombs and no skill sound; one low-noise blocked log |
| right-click during cooldown | toggles melee only; cooldown retained |
| cooldown completion | next double-click allowed |
| map/death/drag | no accidental activation; cleanup clears tasks |

```text
GREEN_BOMB_COOLDOWN_REAL_SECONDS=5.00
GREEN_BOMB_COOLDOWN_INDEPENDENT_FROM_MELEE_TOGGLE=true
GREEN_BOMB_COOLDOWN_CHANGES_ICON_COLOR=false
GREEN_BOMB_COOLDOWN_RESETS_ON_RIGHT_CLICK=false
BOMBS_PER_ACCEPTED_ACTIVATION=3
DETONATION_DELAY_REAL_SECONDS=4.00
GREEN_BOMB_COOLDOWN_USES_CENTRAL_SCHEDULER=true
GREEN_BOMB_COOLDOWN_USER_TEST=NOT_YET_TESTED
```

```

## 0.5.60.3_GREEN_MELEE_BOOST_PROVENANCE_AND_TOGGLE_REPORT.md

- SHA-256: `CB3206A78A755261DAE5171B848B5D0C23877776F55126DD48FFA047D270EC63`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Green Melee Boost Provenance and Toggle Report

Existing implementation reused: `server/XNP_DR_MeleePower.lua`, event `OnWeaponHitXp`, strict `XNP_DR_MeleeClassifier`, and the pre-existing endurance curve capped by `HIGH_ENDURANCE_MELEE_MAX_MULTIPLIER` (default 2.0). No multiplier was changed and no second damage route was added.

Green right-click now toggles the existing player ModData key through `XNP_DR_GreenSkill`. `MeleePower.GetEnduranceMultiplier` checks that state before applying the unchanged curve. The strict classifier still excludes ranged weapons, shove, grapple, stomp, bare hands, physics objects, explosion, and vehicle routes. The green panel remains green and opens no context menu.

```text
EXISTING_MELEE_POWER_IMPLEMENTATION_REUSED=true
SECOND_MELEE_POWER_IMPLEMENTATION_CREATED=false
MELEE_MULTIPLIER_UNCHANGED=true
GREEN_RIGHT_CLICK_CONTEXT_MENU=false
GREEN_RIGHT_CLICK_TOGGLES_MELEE_BOOST=true
GREEN_ICON_COLOR_CHANGES_WITH_TOGGLE=false
PUSH_SHOVE_BOOSTED=false
RANGED_BOOSTED=false
EXPLOSION_BOOSTED=false
GREEN_MELEE_TOGGLE_USER_TEST=NOT_YET_TESTED
```

```

## 0.5.60.3_PHOENIX_FIVE_CYCLE_STATE_MACHINE.md

- SHA-256: `FE053D95B9A86AB9D39CF8C00A47F5687A9E1C721C560F76DC7FE27B5C7B7410`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Phoenix Five-Cycle State Machine

Authority: `XNP_DR_PhoenixTransaction.lua`.

Allowed states only:

```text
READY_ENABLED_BLUE
TRIGGER_COMMITTING
COOLDOWN_WHITE
READY_DISABLED_GREEN
DEAD_TOMBSTONED
```

Normal flow is BLUE -> TRIGGER_COMMITTING -> WHITE -> GREEN -> manual right-click -> a new BLUE cycle. Each cycle records `cycle_id`, `player_identity`, `armed_state`, `damage_transaction_id`, `trigger_source`, `trigger_started_at`, `recovery_committed`, `cooldown_started_at`, `cooldown_finished_at`, `manual_reenabled_at`, and `terminal_state`.

The arm generation increments only on a valid GREEN-to-BLUE transition. Runtime transaction, duplicate callback, validation, fall-edge, trigger, and sound-dedup state is released before a later generation can be armed. Trait data, icon positions, the user's enabled choice, and the cumulative success counter are preserved.

```text
FIVE_CONSECUTIVE_CYCLES_STATIC_MATRIX=5_PASS
CROSS_CYCLE_TRANSACTION_REUSE=false
CROSS_CYCLE_DUPLICATE_LOCK_LEAK=false
CROSS_CYCLE_COOLDOWN_TASK_LEAK=false
CROSS_CYCLE_SOUND_DEDUP_LEAK=false
POST_DEATH_CYCLE_RESTART=false
```

Runtime boundary: `PHOENIX_FIVE_CYCLE_USER_TEST=NOT_YET_TESTED`.

```

## 0.5.60.3_PHOENIX_MULTI_CYCLE_TEST_MATRIX.md

- SHA-256: `B857DF90EE9522E235A56189C55865286DD2E53A8F5FB89D1B9B0D6FEE314ADA`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Phoenix Multi-Cycle Test Matrix

| Case | Static result | Expected runtime result |
|---|---|---|
| Cycle 1 fatal edge | PASS | one recovery, one sound, WHITE |
| After 5 seconds | PASS | WHITE -> GREEN; no protection remains |
| GREEN right-click | PASS | new generation and BLUE |
| Cycles 2-5 | PASS | unique cycle/transaction; one recovery each |
| Duplicate callback | PASS | paired callback is consumed, never a second recovery |
| New projectile in burst | PASS | new event serial and transaction |
| Death already committed | PASS | DEAD_TOMBSTONED; no health write/cooldown |
| WHITE/GREEN fatal damage | PASS | no interception |

```text
CYCLE_1_STATIC=PASS
CYCLE_2_STATIC=PASS
CYCLE_3_STATIC=PASS
CYCLE_4_STATIC=PASS
CYCLE_5_STATIC=PASS
FIVE_CONSECUTIVE_CYCLES_STATIC_MATRIX=5_PASS
PHOENIX_FIVE_CYCLE_USER_TEST=NOT_YET_TESTED
```

```

## 0.5.60.3_PROJECTILE_FATAL_EDGE_MATRIX.md

- SHA-256: `CB9FBB6CF045F3501667E1F6F6DF8BBD8D955BA83F0013BFB4A96720E02AC781`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Projectile Fatal Edge Matrix

| Event | Classification | Result |
|---|---|---|
| `OnWeaponHitCharacter`, ranged=true, BLUE, projected <=20% | projectile | central intercept and one-shot avoid damage |
| next burst event | new projectile | new serial/transaction |
| paired `WEAPONHIT` | duplicate notification | no second recovery |
| explosive weapon | explosion | separate source type |
| non-ranged weapon | melee | separate source type |
| missing/unknown weapon | unknown | reject; never relabel as projectile |
| WHITE/GREEN/dead | blocked | normal engine outcome; no revive |

```text
SINGLE_PROJECTILE_TRIGGER_MAX=1
BURST_NEXT_PROJECTILE_IS_NEW_TRANSACTION=true
EXPLOSION_AND_PROJECTILE_MIXED=false
UNKNOWN_FORCED_TO_PROJECTILE=false
```

```

## 0.5.60.3_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `70BC42B3A49194D9738C2804DABACDBB23F8D65859FF067F2453C850FFA6A503`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Runtime Preservation Report

Preserved from [IP_REDACTED] without redesign: four center textures and round shell, drag controller, map hiding, yellow five colors/shake, Phoenix BLUE/WHITE/GREEN and 5-second test cooldown, red direct right toggle and double-click item use, red dual effects, four audio assets/mappings, green three-bomb layout/4-second detonation, preview/poster, death tombstone, and all unrelated gameplay modules.

```text
XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
DEATH_DIAGNOSTIC_PER_FRAME=false
PHOENIX_DAMAGE_TRANSACTION_NO_WORLD_SCAN=true
TOOLTIP_SINGLE_SHARED_INSTANCE=true
NORMAL_IDLE_PER_FRAME_LOGGING=false
FOUR_AUDIO_FILES_CHANGED=false
FOUR_CENTER_TEXTURES_CHANGED=false
PREVIEW_POSTER_CHANGED=false
```

```

## 0.5.60.3_SOURCE_DROP_MIRROR_REPORT.md

- SHA-256: `12006D2EC8D59AA53EDEADD543A51EA246EF2BB09423DB5A15E30D56883357CB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] SOURCE / DROP Mirror Report

SOURCE:

`[LOCAL_PATH_REDACTED]`

DROP:

`[LOCAL_PATH_REDACTED]`

Mirrored scope: `42`, Workshop preview directory, first-level principle/error/audit directories, root `mod.info`, and root `poster.png`.

```text
MIRROR_FILES_CHECKED=164
MIRROR_SHA256_MISMATCHES=0
SOURCE_LUA_COUNT=90
DROP_LUA_COUNT=90
SOURCE_LUA_LINES=16692
DROP_LUA_LINES=16692
SOURCE_KAHLUA=PASS_90_OF_90
DROP_KAHLUA=PASS_90_OF_90
SOURCE_TEXT_BOM_COUNT=0
DROP_TEXT_BOM_COUNT=0
SOURCE_TEXT_NULL_COUNT=0
DROP_TEXT_NULL_COUNT=0
SOURCE_EMPTY_TEXT_COUNT=0
DROP_EMPTY_TEXT_COUNT=0
STABLE_ASSET_HASH_MISMATCHES=0
```

The four marker PNGs, four OGG files, root/42 poster, and Workshop preview match [IP_REDACTED] byte-for-byte. Development-only root reports and `_kahlua_check` remain SOURCE-only by design.

```
