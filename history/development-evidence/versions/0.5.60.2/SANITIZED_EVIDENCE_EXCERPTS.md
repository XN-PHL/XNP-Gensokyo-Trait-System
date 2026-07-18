# 0.5.60.2 Sanitized Evidence Excerpts

## 0.5.60.2_Phoenix恢复报错根因.md

- SHA-256: `9BF15FD6025F5072482E87D4F6AB9A12A8756FB06D0AD709D4C9795E79407653`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Phoenix 鎭㈠鎶ラ敊鏍瑰洜

[IP_REDACTED] 鐨?`requireLiving()` 鍦ㄦ垚鍔熸椂杩斿洖 `(true, snapshot)`锛屼絾 `applyRecovery()` 鎸?`(living, detail, snapshot)` 鎺ユ敹銆傜涓変釜鍊煎洜姝や负 nil锛屾棫绗?112 琛岃闂?`snapshot.body` 鏃朵骇鐢?`body of non-table: null`銆?
[IP_REDACTED] 鍒犻櫎浜嗚繖鏉￠敊璇绾︺€傛仮澶嶅墠閫氳繃 `ValidateRecoveryContract()` 鏍￠獙娲讳綋銆佽韩浠姐€丅odyDamage銆佺湡瀹?API銆佸悎娉曞€笺€佷簨鍔′笌鐘舵€佸瓨鍌紱BodyDamage 鐢?`player:getBodyDamage()` 鐩存帴鍙栧緱锛屼笉鐚?Java 瀛楁銆?
澶辫触涓嶅啓鍋ュ悍銆佷笉杩涘叆 WHITE銆佷笉娑堣垂浜嬪姟銆佷笉鎾斁閲嶇敓闊虫晥銆傚疄鏈烘仮澶嶄粛寰呯敤鎴烽獙璇併€?
```

## 0.5.60.2_死亡与错误归属.md

- SHA-256: `B03C0795897FCEA7C81584C811BBB2548F9EF8A17F3E257CFC349CB610CC62C1`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] 姝讳骸涓庨敊璇綊灞?
`console(25)` 璇佹槑 [IP_REDACTED] 鐜╁姝讳骸涓?tombstone 鍑虹幇锛屼絾涓嶈兘璇佹槑鏈€缁堣嚧姝绘潵婧愩€備笉寰楁妸鍚庣画姝讳骸鍐欐垚姝诲悗澶嶆椿鍥炲綊銆?
```text
VERSION=[IP_REDACTED]
USER_RUNTIME_RESULT=FAILED
POST_DEATH_GHOST_STATE_REPRODUCED=false
PLAYER_DEATH_CONFIRMED=true
EXACT_KILL_SOURCE=UNKNOWN
XNP_RUNTIME_FAILURE=applyRecovery_BODY_NULL_TABLE_INDEX
RESULT=PHOENIX_TRIGGERED_AT_19.97_PERCENT_BUT_RECOVERY_ABORTED_BY_LUA_ERROR
```

[IP_REDACTED] 鍙湪棰勫垽銆佹仮澶嶅け璐ャ€佸彇娑堝拰 tombstone 杈撳嚭缁撴瀯鍖栬瘖鏂紱鍙栦笉鍒扮殑鏀诲嚮鑰呮垨姝﹀櫒瀛楁鍐?`UNKNOWN`銆?
```

## 0.5.60.2_AUDIO_ASSET_HASH_REPORT.md

- SHA-256: `CCA3E55A35C3126B30163A183810CDCECA9D14DAED740347E31E8ABE8423B50F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Audio Asset Hash Report

The supplied OGG files were copied directly from the command ZIP without conversion.

| File | Bytes | SHA256 |
|---|---:|---|
| `xnp_phoenix_revive.ogg` | 20304 | `CD937F0E672F65B2F7CFD1A4561B835A1B37A565B8C38FEB15A2100A00FEEA80` |
| `xnp_red_use_or_phoenix_ready.ogg` | 22553 | `B7C713E14B05AC73517E00E71B22A2E3FA21A8BFC1ABADB78220F4C0E66D1613` |
| `xnp_marker_toggle.ogg` | 10599 | `3E334B82F3FD320EFF64A798D869BF8EBB0642A03D6BD0896113CE1CF0501FF4` |
| `xnp_green_bomb_skill.ogg` | 21216 | `1F6AA90C8828DFF69BD7D3D490C4925279E1E1D9222F2EC4DC218CF79B0DA60B` |

`SOURCE_AUDIO_NORMALIZED=false`  
`SOURCE_AUDIO_CROPPED=false`  
`SOURCE_AUDIO_REMIXED=false`

```

## 0.5.60.2_B42_BODYDAMAGE_AND_BODYPART_API_EVIDENCE.md

- SHA-256: `93E8B3EDA6240F3C97697BF0CBEBDA7361DD3183722D8B21CD124D66BA79CA78`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] B42 BodyDamage / BodyPart API Evidence

- Game JAR: `[LOCAL_PATH_REDACTED]`
- JAR SHA256: `901A12E3E2E4F3DE841C17D9A30D0E2FE97115D390E8AF577FDCDCB98C5D7D76`
- Inspection: `javap -public/-c/-p`, no game launch.

## Proven API

`zombie.characters.BodyDamage.BodyDamage` exposes:

- `RestoreToFullHealth()`
- `getBodyParts()`
- `getOverallBodyHealth()`
- `setOverallBodyHealth(float)`
- `setInfected(boolean)`
- `setIsFakeInfected(boolean)`

`zombie.characters.BodyDamage.BodyPart` exposes `RestoreToFullHealth()` and the individual wound APIs. Bytecode proves `BodyDamage.RestoreToFullHealth()` iterates every BodyPart, calls its restore method, resets stats, clears real/fake infection, and writes overall body health to 100.

`IsoGameCharacter` exposes `getBodyDamage()`, `getHealth()`, `setHealth(float)`, `isDead()`, `isAlive()`, and `isOnDeathDone()`.

## Implementation boundary

The recovery path obtains BodyDamage directly from `player:getBodyDamage()`. It does not index Java userdata and does not guess `.body` or `.parts` fields. The old optional per-part write table was removed.

`NULL_BODY_TABLE_INDEX_REACHABLE_COUNT=0`  
`JAVA_USERDATA_TABLE_FIELD_GUESS_COUNT=0`  
`RECOVERY_API_VALIDATED_BEFORE_WRITE=true`

Runtime behavior remains `PHOENIX_RECOVERY_USER_RUNTIME_TEST=NOT_YET_TESTED`.

```

## 0.5.60.2_B42_CRAFTED_BOMB_ID_AND_DETONATION_API_EVIDENCE.md

- SHA-256: `A2C3401546E2D426C914B082522885CC0D2F62DDD2BE3840BD6C918B39B32BF0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] B42 Crafted Bomb and Detonation API Evidence

- CN `ItemName.json:1267` maps `Base.PipeBomb` to `鍦熷埗鐐稿脊`.
- `media/scripts/generated/items/weapon.txt` defines `item PipeBomb` with explosion power 90, range 7, `PipeBombExplode`, `PhysicsObject = Base.PipeBomb`, and the placed sprite.
- Vanilla `ISPlaceTrap.lua:47-48` uses `IsoTrap.new(character, weapon, square:getCell(), square)` then `trap:place()`.
- Vanilla tests use `instanceItem("Base.PipeBombRemote")` and an `IsoTrap` constructor.
- JAR javap proves the matching constructors, `place()`, and both `triggerExplosion()` overloads.

The skill creates `Base.PipeBomb`, places real `IsoTrap` objects, and calls their native no-argument `triggerExplosion()` after the scheduler delay. It does not emulate blast damage, fire, noise, or player immunity.

`GREEN_BOMB_FULL_TYPE_PROVEN=true`  
`GREEN_BOMB_DETONATION_API_PROVEN=true`

```

## 0.5.60.2_B42_CUSTOM_SOUND_API_EVIDENCE.md

- SHA-256: `815D5474E70D1FC333B800D66F0EED8BE1AA021DB74F4997523AEC08E80A6790`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] B42 Custom Sound API Evidence

Local B42 evidence:

- Vanilla sound definition: `media\scripts\generated\sounds\zombies\sounds_zombie_voice_tutorial.txt` uses `sound`, nested `clip`, and `file = media/sound/...`.
- Native `SoundBanks.lua` contains OGG paths under `media/sound`.
- Vanilla Lua repeatedly calls `player:playSound("SoundName")` and `player:getEmitter():playSound("SoundName")`.
- `IsoGameCharacter` javap exposes `playSound(String)` and `playSoundLocal(String)`.

The mod defines four unique names in `42/media/scripts/XNPSkillSounds.txt`, stores the supplied bytes in `42/media/sound`, and uses `player:playSound` through `XNP_DR_Audio.PlayOnce`. Event tokens prevent duplicate playback.

`ONE_SHOT=true`  
`LOOP=false`  
`PER_FRAME_PLAY=false`  
`MAX_SAME_EVENT_PLAYS=1`  
`OVERLAP_STORM_PREVENTED=true`  
`AUDIO_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60.2_GREEN_BOMB_FOUR_SECOND_SCHEDULER_REPORT.md

- SHA-256: `F9D63F1A667E6FA98F7120E1FD8437360B0DD02E6CA26837E798EED339B74749`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Green Bomb Four-second Scheduler

`XNP_DR_PerformanceScheduler` now accepts uniquely keyed active-real-second tasks. It advances them from the existing single `OnPlayerUpdate` route using `GameTime:getRealworldSecondsSinceLastUpdate()`.

The global, vanilla-used `isGamePaused()` blocks advancement while paused. A 0.25-second per-frame cap prevents a resume/background gap from consuming the delay. The task is removed before its callback, and each trap also has a `detonated` guard.

`GREEN_BOMB_USES_CENTRAL_SCHEDULER=true`  
`DETONATION_DELAY_REAL_SECONDS=4.00`  
`NEW_ONTICK_COUNT=0`  
`ONPLAYERUPDATE_HANDLER_COUNT=1`  
`EACH_TRAP_DETONATES_AT_MOST_ONCE=true`

```

## 0.5.60.2_GREEN_BOMB_SKILL_INPUT_AND_SPAWN_MATRIX.md

- SHA-256: `A42D227B36CDA827934AEBAB0F2AD9D053FCF66E736380DC07189FD8B6A21A42`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Green Bomb Input and Spawn Matrix

| Input/state | Result |
|---|---|
| First left click | Records click; no activation |
| Second close left click within 350 ms | Requests one activation |
| Left drag beyond 5 px | Cancels click sequence |
| Right click | No action |
| Map hidden / panel hidden | No activation |
| Dead player / missing green trait / pause | Rejected |
| Accepted activation | Three real traps, one scheduler task, one sound |

The first trap uses the current square. The next two prefer deterministic radius-1 solid-floor, non-solid neighbors and fall back to the current square. Every actual coordinate is logged. Partial creation is rolled back and does not play audio.

`GREEN_SINGLE_CLICK_ACTIVATES=false`  
`GREEN_DOUBLE_CLICK_ACTIVATES=true`  
`GREEN_DRAG_ACTIVATES=false`  
`BOMBS_PER_ACTIVATION=3`  
`SOUND_PLAYS_AFTER_THREE_SPAWNS=true`  
`GREEN_BOMB_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60.2_LEGACY_SANDBOX_ZERO_RUNTIME_MIGRATION_REPORT.md

- SHA-256: `A3A5AA99BA9FB71B68A51816FD5B4EA451D4A006F3835FE101FD6772A8F98F45`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Legacy Sandbox Zero Runtime Migration

The legacy field names are retained. Parser maxima now accept the historical saved values:

- `PhoenixInvulnerabilitySeconds`: max 10, default 0.
- `PhoenixProtectDurationSeconds`: max 5, default 0.

`XNP_DR_PurplePhoenix_Config.lua` continues to force both runtime values to logical zero and never writes SandboxVars per frame. Compatibility shells discard old transient state and do not start protection.

`LEGACY_10_SECOND_VALUE_PARSE_ERROR=false`  
`LEGACY_5_SECOND_VALUE_PARSE_ERROR=false`  
`RUNTIME_INVULNERABILITY_SECONDS=0`  
`RUNTIME_PROTECT_DURATION_SECONDS=0`  
`INVULNERABILITY_START_REACHABLE_COUNT=0`  
`PROTECT_PULSE_REACHABLE_COUNT=0`

```

## 0.5.60.2_PHOENIX_RECOVERY_TRANSACTION_REPORT.md

- SHA-256: `14EE5780ED5B8D72D78E4E43BA45454979BBC44651DB3B0711BCEC8AFB7BC290`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Phoenix Recovery Transaction

The [IP_REDACTED] crash came from a return contract mismatch: `requireLiving()` returned `(true, snapshot)`, while `applyRecovery()` read `(living, detail, snapshot)`. The third value was nil and line 112 indexed `snapshot.body`.

[IP_REDACTED] uses `ValidateRecoveryContract(player, transactionId, config, source)` before every recovery write. It verifies living/tombstone state, current player identity, transaction uniqueness, BodyDamage presence, exact recovery methods, legal target values, modData, and cooldown-state prerequisites.

Commit order:

1. Validate without writing.
2. Restore BodyDamage and direct player health once.
3. Re-run the living gate and verify both health readings.
4. Start WHITE only after verified recovery.
5. Mark the transaction consumed.
6. Play Phoenix sound once with the transaction ID as dedupe token.

Failed validation or failed recovery does not start cooldown, consume the transaction, or play audio. Death tombstones and non-positive health remain hard rejects.

`PARTIAL_RECOVERY_CONSUMES_PHOENIX=false`  
`FAILED_RECOVERY_STARTS_COOLDOWN=false`  
`FAILED_RECOVERY_PLAYS_SOUND=false`  
`POST_DEATH_HEALTH_WRITE_REACHABLE_COUNT=0`  
`PHOENIX_THRESHOLD=0.20`

`PHOENIX_RECOVERY_USER_RUNTIME_TEST=NOT_YET_TESTED`  
`POST_DEATH_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60.2_RED_DIRECT_RIGHT_CLICK_TOGGLE_REPORT.md

- SHA-256: `67FDE17DBDD1509AD34C40A149D90394FB63F7CA0FC5EDB66D6E8E3C60448A86`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Direct Right-click Toggle

The round red panel no longer calls `ISContextMenu.get()` and contains no panel context-menu builder. A valid right-button down/up edge directly swaps `STAMINA` and `TREATMENT`, marks the UI dirty, and plays one marker-toggle sound.

Map-hidden, invisible, and dragging states reject the edge. Holding the button cannot retrigger because the armed flag is consumed on mouse-up. Existing left-double-click queueing and all red-item effects remain unchanged.

`RED_RIGHT_CLICK_CONTEXT_MENU_CREATED=false`  
`RED_RIGHT_CLICK_TOGGLES_MODE=true`  
`RED_RIGHT_CLICK_SINGLE_EDGE=true`  
`RED_LEFT_DOUBLE_CLICK_USE_PRESERVED=true`  
`RED_MODE_EFFECTS_UNCHANGED=true`  
`RED_RIGHT_TOGGLE_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60.2_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `5C8E6C8813374F6BC0CB0A997221DA526BD75D912528EE2DC3C4BAD7BBF994F4`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Runtime Preservation

Preserved from [IP_REDACTED]: trait identities, death tombstone and player identity isolation, exact 20% Phoenix threshold, projectile pre-death route, 5-second WHITE test cooldown, purple BLUE/WHITE/GREEN states, no sustained protection, map hiding, four-marker rendering/dragging, yellow states/shake, red item effects and timing, center art, poster, and preview assets.

Scoped changes are limited to the recovery contract, legacy sandbox parse ranges, direct red right-toggle, event audio, green double-click bomb skill, and central delayed tasks.

`XNP_ON_TICK_HANDLER_COUNT=0`  
`XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1`  
`NORMAL_IDLE_PER_FRAME_DEATH_LOGGING=false`  
`AUDIO_PER_FRAME_TRIGGER=false`  
`CONTEXT_MENU_CREATE_ON_RED_RIGHT_CLICK=false`  
`PZ_OR_STEAM_STARTED=false`  
`USER_MODS_WRITTEN=false`

```
