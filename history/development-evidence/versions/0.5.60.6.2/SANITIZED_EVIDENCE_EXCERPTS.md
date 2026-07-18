# 0.5.60.6.2 Sanitized Evidence Excerpts

## [IP_REDACTED].2_AUDIT_BLOCKED.md

- SHA-256: `4E035AB1A1774368F28BF88B3281394FE7B5D3D7A1F383CB8C2910360125C799`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].2 浜屾瀹¤缁撴灉鎽樿

```text
AUDIT_RESULT=BLOCKED
BLOCKER_COUNT=1
SOURCE_KAHLUA=98_PASS_0_FAIL
DROP_KAHLUA=98_PASS_0_FAIL
DEPLOYMENT_FILE_COUNT=137
SOURCE_DROP_MIRROR=PASS
```

## 鍞竴纭樆鏂?
```text
GREEN_OLD_EXPLOSION_ROUTE_REUSED=false
IsoTrap.new reachable references=0
triggerExplosion() reachable references=0
```

褰撳墠鐗堟湰鍙鐢ㄤ簡锛?
- `Base.PipeBomb` 韬唤锛?- 鎵嬮浄浼ゅ琛板噺锛?- `PipeBombExplode` 闊虫晥銆?
娌℃湁瀹為檯澶嶇敤鏃у師鐢?`IsoTrap / triggerExplosion()` 鐖嗙偢璺嚎銆?
## 宸查€氳繃椤圭洰

- 鐞冧綋璐村浘缁樺埗鍦ㄦ硾鍏変笂鏂癸紱
- 鏃犵洰鏍囦粛鍙敓鎴愶紱
- 涓栫晫鍧愭爣杩愬姩锛?- 涓や釜鑼冨洿鍦堬紱
- 鍒嗘鍔犻€燂紱
- 鍍靛案涓撳睘浼ゅ锛?- WHITE timed action锛?- SOURCE / DROP Kahlua 98 PASS / 0 FAIL锛?- 137 涓儴缃叉枃浠堕暅鍍忎竴鑷淬€?
## 瀹¤椋庨櫓

- 缁胯壊鍏夌悆浠嶉€氳繃涓栫晫鍧愭爣鎶曞奖鍒?`ISPanel`锛?- 1.45 TPS 鍥為€€鍊硷紱
- WHITE 鍔ㄤ綔闊虫晥寰呭疄鏈虹‘璁わ紱
- 鏂囨。绾圭悊灏哄鎻忚堪涓嶅噯纭€?
```

## [IP_REDACTED].2_console_32.txt

- SHA-256: `269B09C0197B878663B2D1171BC890F514FE051063A53595EC473585AFB51F71`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
[PRIVATE_RUNTIME_ENVIRONMENT_HEADER_REMOVED]
```

## [IP_REDACTED].2_REAL_RUNTIME_FIX_SUMMARY.md

- SHA-256: `A5E816D64B437A4079627DAC50163577A6192F8EFBD279C536ADFCF1BE042503`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED].2 Real Runtime Fix Summary

## User-observed failures

- The glow rendered but the sphere body was not readable.
- A first cast could disappear when no zombie was available.
- The apparent spawn did not reliably read as the player's release position.
- The previous speed claim treated a normalized movement value as world TPS.

## Hard fixes

- The renderer now layers the existing complete orb texture from `XNPGreenArc`
  over two glow layers. The incomplete 128 px runtime copy is no longer loaded.
- Cast admission no longer requires a target. Every accepted cast first creates a
  visible world orb at the exact player world coordinates, then scans every 250 ms.
- The orb retains world XYZ state and only projects that state for drawing.
- Explosion and detection circles are rendered together from the first visible frame.
- Walking speed is sampled from real player world displacement. A documented 1.45 TPS
  fallback is used until a valid non-running, non-sprinting walking sample exists.
- Speed remains at walking scale through second three, then grows by 1.5 per second,
  capped at 8 TPS to reduce wall tunneling and runaway flight steps.

## New white-state action

White-state double-click queues a craft animation. `MaleZombieDeath` plays after the
action crosses 50 percent. Completion deducts 0.50 normalized health, 0.50 normalized
endurance, and adds 50 unhappiness. It then arms green mode and stores one preparation
token that the next accepted orb consumes. Interrupted actions pay no cost.

## Deliberately untouched

Yellow, Purple Phoenix, Red, the shared four-icon drag controller, green tiered melee,
and green structure damage retain their [IP_REDACTED].1 bytes. The disabled arc route remains
unreachable.

## Safety boundary

The old native `IsoTrap.triggerExplosion()` path was not restored because the available
static evidence does not expose a player-immunity switch. The current explosion reuses
the old `Base.PipeBomb` weapon identity, radial falloff, and `PipeBombExplode` sound, but
keeps damage in a zombie-only transaction. Runtime visual, sound, and feel still require
the user's game test.

```

## [IP_REDACTED].2_RUNTIME_FINDING.md

- SHA-256: `84AE29D28A30C2BB0ACBBF417C4A11CE49F1443598354E268282E8B0BD78F580`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED].2 鐢ㄦ埛瀹炴満鍙戠幇

## 鑷村懡鏄剧ず闂

缁胯壊鍏夌悆鐨勮窡韪拰浼ゅ璺嚎鍩烘湰鑳借繍琛岋紝浣嗗厜鐞冭瑙変細闅忕潃榧犳爣婊氳疆鏀瑰彉闀滃ご缂╂斁鑰屽彂鐢熼敊璇Щ鍔ㄦ垨婕傜Щ銆?
杩欎笉鏄洰鏍囪窡韪敊璇紝鑰屾槸瑙嗚閿氬畾閿欒锛?
- 鏀惧ぇ闀滃ご鏃讹紝鐞冧綋鐩稿涓栫晫浣嶇疆鍙戠敓鍙樺寲锛?- 缂╁皬闀滃ご鏃讹紝鐞冧綋鐩稿涓栫晫浣嶇疆鍙戠敓鍙樺寲锛?- 鐞冧綋銆佹硾鍏夊拰涓や釜鍦堜粛渚濊禆 `ISPanel` / 灞忓箷鎶曞奖锛?- 瀹冧滑娌℃湁鐪熸杩涘叆鍘熺敓涓栫晫娓叉煋灞傘€?
## 蹇呴』淇鍚庣殑楠屾敹璇箟

- 鍏夌悆閫昏緫浣嶇疆濮嬬粓鏄笘鐣屽潗鏍囷紱
- 鐞冧綋銆佹硾鍏夈€佺垎鐐稿湀銆佹娴嬪湀閮界粦瀹氬悓涓€涓栫晫浣嶇疆锛?- 婊氳疆缂╂斁鍙敼鍙樻甯哥殑涓栫晫鏄剧ず姣斾緥锛?- 涓嶅緱鐩稿鍦扮爾銆佺洰鏍囨垨鐖嗙偢鐐规紓绉伙紱
- 闀滃ご骞崇Щ鍜岀缉鏀鹃兘涓嶈兘鎶婄悆浣撴嫋鍚戝睆骞曚腑蹇冩垨鐜╁锛?- 娲诲姩鍏夌悆瑙嗚涓嶅緱缁х画閫氳繃鏅€?`ISPanel` 淇濆瓨灞忓箷鍧愭爣銆?
```

## [IP_REDACTED].2_SOURCE_DROP_MIRROR_REPORT.md

- SHA-256: `278A9B398209C73E3B9C819EBCA0EC2D03FBFA62C1C83A43400E7DB5ED699FC9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].2 SOURCE / DROP Mirror Report

- SOURCE deploy scope: `42 + mod.info + poster.png`
- DROP: `[LOCAL_PATH_REDACTED]`
- DROP top level: `42 | mod.info | poster.png`
- SOURCE deploy files: `137`
- DROP files: `137`
- Missing from DROP: `0`
- Extra in DROP: `0`
- SHA256 mismatches: `0`
- SOURCE Kahlua: `98 PASS / 0 FAIL`
- DROP Kahlua: `98 PASS / 0 FAIL`
- Translation JSON: `8 PASS / 0 FAIL`

Key SOURCE/DROP hashes:

```text
XNP_DR_GreenWorldOrb.lua=6FCB3A6486B839EDF5A17836407FB28E80AB4B5F33C407BE913E01B5341FD9A2
XNP_DR_GreenWorldVisual.lua=EC84E0BB73C5869DB72511B1A52D1CCDEC85B8466C2DC726867F7865CD49103F
XNP_DR_GreenWhiteAction.lua=438DCCD095EE7E2186C853023553868B8E4C12C1BFFB54BAF6650BBC64F2A503
XNP_DR_GreenWhitePrepareAction.lua=79017DD426CEC83BDE8CD49BE3C04E9E8D27E918BFD36CF7773726D955A340FD
xnp_green_projectile_orb.png=3EF7F799D87771ADE8CAAA25C9D3422682C1AC39DACAE59941E0E8E751F14A1C
xnp_green_orb_glow.png=51B7F42B17065B1B6AC51500F3442D9234E5F1E1DACCA70C777B8DBEBB1C7C0B
```

`SOURCE_DROP_MIRROR_RESULT=PASS`

```

## BUILD_MARKER.txt

- SHA-256: `04D8588A7666184A5CEB030758CD00BA3E0702135F4CE6B93FD6824522CE0F38`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_056062_GREEN_ORB_RUNTIME_FIX_WHITE_ACTION_A

```

## FINAL_REPORT.md

- SHA-256: `1267E86F34EBFCACF3F213D9EDBCF52662D8F34787004C24D915C1E19ADA3E06`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ Distance Runner [IP_REDACTED].2 Final Report

## Identity

- `SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]`
- `DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]`
- `VERSION=[IP_REDACTED].2`
- `INTERNAL_VERSION=[IP_REDACTED].2-b42-green-orb-runtime-fix-white-action-a`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056062_GREEN_ORB_RUNTIME_FIX_WHITE_ACTION_A`

## Green Orb Runtime Fix

- `WORLD_SPAWN=PLAYER_RELEASE_WORLD_XYZ_EXACT`
- `ORB_TEXTURE_OVER_GLOW=YES`
- `ORB_CENTER_TEXTURE=media/ui/XNPGreenArc/xnp_green_projectile_orb.png`
- `NO_TARGET_SPAWN_FALLBACK=VISIBLE_SPAWN_AND_250MS_REACQUIRE_SCAN`
- `MOVEMENT_WORLD_BASED=YES`
- `WORLD_RENDERING=ISO_WORLD_TO_SCREEN_PROJECTION_OF_PERSISTENT_WORLD_XYZ`
- `TWO_RINGS=EXPLOSION_RADIUS_7_AND_DETECTION_RADIUS_12`
- `SPEED_STAGE_1_TO_3_SECONDS=OBSERVED_PLAYER_WORLD_WALK_TPS`
- `SPEED_FALLBACK_WHEN_NO_VALID_WALK_SAMPLE=1.45_TILES_PER_SECOND`
- `SPEED_AFTER_3_SECONDS=PREVIOUS_SPEED_CURVE_X_1.5_PER_SECOND`
- `SPEED_CAP=8.00_TILES_PER_SECOND`
- `SPEED_CAP_REASON=LIMIT_FRAME_STEP_TUNNELING_AND_RUNAWAY_TRACKING`
- `FLIGHT_TIMEOUT=8.00_SECONDS`
- `OLD_EXPLOSION_ROUTE_REUSE=BASE_PIPEBOMB_WEAPON_FALLOFF_AND_PIPEBOMBEXPLODE_SOUND`
- `NATIVE_ISOTRAP_TRIGGEREXPLOSION=NOT_USED_BECAUSE_IT_CANNOT_STATICALLY_GUARANTEE_ZOMBIES_ONLY_DAMAGE`
- `ZOMBIES_ONLY_DAMAGE=YES`
- `PLAYER_DAMAGE=NO`
- `OUTLINE_DURATION=500_MS`

The active center texture now uses the existing complete 32 px orb asset. The prior
128 px runtime copy contained only a tiny visible crop in one corner, which explains
why runtime testing showed glow without a readable sphere. No replacement art was made.

## White Double Click Action

- `WHITE_DOUBLE_CLICK=TIMED_ACTION`
- `ACTION_ANIMATION=CharacterActionAnims.Craft`
- `MID_ACTION_SOUND=MaleZombieDeath`
- `HEALTH_COST=50_POINTS`
- `ENDURANCE_COST=50_POINTS`
- `MOOD_COST=UNHAPPINESS_PLUS_50`
- `MOOD_COST_DIRECTION=NEGATIVE_PLAYER_OUTCOME_NOT_REWARD`
- `RESULT_ROUTE=GREEN_MODE_ARMED_AND_ONE_PREPARED_TOKEN_CONSUMED_BY_NEXT_ACCEPTED_ORB`
- `INTERRUPTION_COST=NONE`
- `INSUFFICIENT_COST_REJECTION=YES`

Health and endurance use the game's normalized 0..1 values, therefore 50 points is
written as `0.50`. Unhappiness uses its 0..100 scale and is increased by `50`; the
action is rejected if that exact cost would clamp. All three writes are committed only
at completion and are rolled back if a later write or green-mode arm fails.

## Preserved Routes

- `YELLOW_DEDICATED_DIFF_COUNT_VS_0.[IP_REDACTED]=0`
- `PURPLE_PHOENIX_DEDICATED_DIFF_COUNT_VS_0.[IP_REDACTED]=0`
- `RED_DEDICATED_DIFF_COUNT_VS_0.[IP_REDACTED]=0`
- `FOUR_ICON_DRAG_CONTROLLER=UNCHANGED`
- `GREEN_RIGHT_CLICK_TOGGLE=PRESERVED`
- `OLD_ARC_RUNTIME_ROUTE=DISABLED`

## Validation

- `SOURCE_KAHLUA=98_PASS_0_FAIL`
- `DROP_KAHLUA=98_PASS_0_FAIL`
- `SOURCE_DEPLOY_FILE_COUNT=137`
- `DROP_FILE_COUNT=137`
- `SOURCE_DROP_RUNTIME_SHA256_MISMATCH_COUNT=0`
- `SOURCE_DROP_MISSING_COUNT=0`
- `SOURCE_DROP_EXTRA_COUNT=0`
- `DROP_TOP_LEVEL=42|mod.info|poster.png`
- `PROJECT_ZOMBOID_STARTED
[EXCERPT_TRUNCATED]
```

## [IP_REDACTED].2_SECOND_PASS_AUDIT.md

- SHA-256: `FACB3301C9054995C5C05E55954A2B0926FD4E31DF99C69DB64C419D9347E12B`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].2 Strict Second-Pass Audit

## Scope

```text
SOURCE=[LOCAL_PATH_REDACTED]
DROP=[LOCAL_PATH_REDACTED]
BASELINE=[LOCAL_PATH_REDACTED]
AUDIT_WRITE_SCOPE=THIS_REPORT_ONLY
```

## Verdict

The package, new orb runtime, and white-state action are structurally coherent, but the
hard assertion requiring reuse of the old successful green native explosion route is
false. The current implementation deliberately uses a new visual plus a zombie-only
manual damage transaction. Reusing the `Base.PipeBomb` item identity and
`PipeBombExplode` sound is not equivalent to reusing the old `IsoTrap` explosion route.

## Package And Identity

```text
SOURCE_EXISTS=true
DROP_EXISTS=true
DROP_TOP_LEVEL=42|mod.info|poster.png
DROP_TOP_LEVEL_VALID=true
DISPLAY_NAME=[[IP_REDACTED].2] XNP Green Orb Runtime Fix + White Action
VERSION=[IP_REDACTED].2
INTERNAL_VERSION=[IP_REDACTED].2-b42-green-orb-runtime-fix-white-action-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056062_GREEN_ORB_RUNTIME_FIX_WHITE_ACTION_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
VERSIONED_SOURCE_AND_DROP_NAMES=true
```

## Kahlua And Mirror

The audit independently invoked the installed B42 `LuaCompiler.loadis` through the
existing checker. This was a compiler call only; Project Zomboid was not started.

```text
SOURCE_KAHLUA_PASS_COUNT=98
SOURCE_KAHLUA_FAIL_COUNT=0
DROP_KAHLUA_PASS_COUNT=98
DROP_KAHLUA_FAIL_COUNT=0
SOURCE_DEPLOY_FILE_COUNT=137
DROP_FILE_COUNT=137
SOURCE_DROP_MISSING_COUNT=0
SOURCE_DROP_EXTRA_COUNT=0
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
SOURCE_DROP_RUNTIME_MIRROR=true
```

## Green Orb Assertions

```text
GREEN_ORB_WORLD_SPAWN_FROM_PLAYER=true
GREEN_ORB_TEXTURE_OVER_GLOW=true
GREEN_ORB_NO_TARGET_STILL_SPAWNS=true
GREEN_ORB_WORLD_MOVEMENT_ONLY=true
GREEN_ORB_TWO_RINGS_PRESENT=true
GREEN_ORB_EXPLOSION_RING_PRESENT=true
GREEN_ORB_TARGET_RING_PRESENT=true
GREEN_ORB_SPEED_STAGE_1_TO_3_PRESENT=true
GREEN_ORB_SPEED_AFTER_3S_ACCEL_PRESENT=true
ORB_SPEED_SOURCE_NOT_INPUT_NORMALIZED=true
GREEN_OLD_EXPLOSION_ROUTE_REUSED=false
GREEN_DAMAGE_ZOMBIES_ONLY=true
GREEN_OLD_BOMB_DIRECT_ENTRY_REACHABLE=0
```

Evidence:

- `RequestActivate` reads player `getX/getY/getZ`, stores those values in both the active
  world and spawn fields, and calls `ShowOrb` even when `nearestTarget` returns nil.
- A targetless orb receives player-forward direction, remains active, and searches every
  250 ms. The previous `cast_rejected=true reason=NO_ZOMBIE_TARGET` path is absent.
- Flight integration updates `state.worldX/state.worldY`. Screen projection occurs only in
  the renderer and does not feed back into movement or targeting.
- The renderer loads `XNPGreenArc/xnp_green_projectile_orb.png`, draws two glow layers,
  then draws the center texture at alpha 1.0. Pixel inspection found a 17x19 image with
  201 nontransparent pixels, full-width visible bounds, and maximum alpha 255.
- The active renderer draws radius 7 and radius 12 rings from the orb's world coordinates.
- Through second 3, `stagedSpeed` returns the observed
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `07854CE1896C22ADBD4794E099429AA14A26052FB5EAC0E967BD3CE4DCB9144E`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit [IP_REDACTED].2

- Build marker: `XNP_PZ_DISTANCE_TRAIT_056062_GREEN_ORB_RUNTIME_FIX_WHITE_ACTION_A`
- B42 Kahlua `LuaCompiler.loadis`: `SOURCE=98 PASS / 0 FAIL`, `DROP=98 PASS / 0 FAIL`
- Runtime Lua files: `97`, plus `42/media/registries.lua`
- New event registrations: `0`
- Active orb renderer panels: `1`
- Orb center texture loads: once, behind `texturesAttempted`
- No-target target scan: one scan per `250 ms` only while an orb is active
- Orb movement: delta-time world-coordinate integration; player coordinates are read only
- Speed source: observed player world displacement while walking; documented fallback `1.45 TPS`
- Active rings: explosion radius `7`, target radius `12`
- Damage enumeration: `IsoZombie` only with per-explosion weak-table deduplication
- Native `IsoTrap.triggerExplosion`: not called because its old route cannot prove player immunity
- White action: one queued timed action; costs commit at completion with rollback on failure
- White mood direction: `UNHAPPINESS + 50` (cost, not benefit)
- Yellow dedicated files changed: `0`
- Purple Phoenix dedicated files changed: `0`
- Red dedicated files changed: `0`
- Old arc runtime requires/calls: `0`
- `OnTick` additions: `0`
- High-frequency per-frame logging additions: `0`
- SOURCE/DROP deploy files: `137 / 137`
- SOURCE/DROP missing, extra, SHA256 mismatch: `0 / 0 / 0`
- Translation JSON parse: `8 PASS / 0 FAIL`
- Runtime Lua empty, BOM, NULL files: `0 / 0 / 0`
- Syntax validation does not prove runtime API behavior, visual layering, sound playback, or game balance.

`STATIC_AUDIT_RESULT=PASS_WITH_RUNTIME_TEST_REQUIRED`

```
