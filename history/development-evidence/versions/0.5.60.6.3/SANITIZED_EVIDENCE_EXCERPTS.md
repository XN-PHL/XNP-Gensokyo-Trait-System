# 0.5.60.6.3 Sanitized Evidence Excerpts

## [IP_REDACTED].3_CHANGED_FILES.md

- SHA-256: `99D3E82E64E2441FDAA3CCC2A1A4ADBF9BB8971394525C41313BD13E5DFA19A8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].3 Changed Files

## Runtime And Identity

- `mod.info`
- `42/mod.info`
- `BUILD_MARKER.txt`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_GreenWorldVisual.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_GreenWorldOrb.lua`

## Public Evidence Added To Runtime Tree

- `42/media/XNP_DevelopmentEvidence/README.md`
- `42/media/XNP_DevelopmentEvidence/VERSION_TIMELINE.md`
- `42/media/XNP_DevelopmentEvidence/KNOWN_ISSUES_AND_FIXES.md`
- `42/media/XNP_DevelopmentEvidence/[IP_REDACTED].2_AUDIT_BLOCKED.md`
- `42/media/XNP_DevelopmentEvidence/[IP_REDACTED].2_RUNTIME_FINDING.md`
- `42/media/XNP_DevelopmentEvidence/console_32_XNP_SANITIZED.txt`
- `42/media/XNP_DevelopmentEvidence/EVIDENCE_MANIFEST.md`

## SOURCE-Only Evidence And Reports

- `閿欒鎶ュ憡/PRIVATE_RAW/[IP_REDACTED].2_console_32.txt`
- `寮€鍙戦樁娈佃瘉鎹?00_EVIDENCE_INDEX.md`
- `寮€鍙戦樁娈佃瘉鎹?[IP_REDACTED].2_AUDIT_BLOCKED.md`
- `寮€鍙戦樁娈佃瘉鎹?[IP_REDACTED].2_RUNTIME_FINDING.md`
- `寮€鍙戦樁娈佃瘉鎹?[IP_REDACTED].2_console_32_XNP_SANITIZED.txt`
- `寮€鍙戦樁娈佃瘉鎹?HISTORICAL_EVIDENCE_SEED.md`
- `寮€鍙戦樁娈佃瘉鎹?EVIDENCE_MANIFEST_COMMAND_PACKAGE.md`
- `[IP_REDACTED].3_NATIVE_WORLD_RENDER_API_EVIDENCE.md`
- `[IP_REDACTED].3_ZERO_POWER_NATIVE_TRAP_SAFETY.md`
- `[IP_REDACTED].3_SOURCE_DROP_MIRROR_REPORT.md`
- `[IP_REDACTED].3_RUNTIME_TEST_PLAN.md`
- `STATIC_AUDIT.md`
- `FINAL_REPORT.md`

All other [IP_REDACTED].2 runtime files are byte-identical. The old SOURCE was not modified.


```

## [IP_REDACTED].3_NATIVE_WORLD_RENDER_API_EVIDENCE.md

- SHA-256: `7D93AA6B0B8FA682151791A3A16E553451DC98D6CB1E4FE94C4F372D9E697628`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].3 Native World Render API Evidence

## Local B42 Evidence

- Build under inspection: Project Zomboid 42.19.0.
- JAR: `[LOCAL_PATH_REDACTED]`.
- Vanilla Lua: `[LOCAL_PATH_REDACTED]`.
- Inspection used `javap`, text search, and the local Kahlua compiler harness. The game was not started.

`IsoCell` bytecode invokes the Lua event `OnPostFloorLayerDraw` after each floor layer. The event receives the rendered Z layer. `IsoSprite.renderTextureWithDepth(Texture, width, height, r, g, b, a, worldX, worldY, worldZ)` is public and uses the active `IsoCamera` frame, `PlayerCamera` offsets, `IsoUtils.XToScreen/YToScreen`, and the engine depth path internally.

The native `IsoMarkers.renderIsoMarkers` implementation uses that same `IsoSprite.renderTextureWithDepth` method for world marker textures. It uses `LineDrawer.DrawIsoCircle` for world-radius circles. These are therefore B42 world render paths, not UI panel coordinates.

## Runtime Design

`XNP_DR_GreenWorldVisual.lua` registers one `Events.OnPostFloorLayerDraw` callback. It renders:

- center orb texture through `IsoSprite.renderTextureWithDepth`;
- two glow layers through the same method;
- explosion and detection radii through `LineDrawer.DrawIsoCircle`;
- the terminal white radius circle at the authoritative explosion world coordinate.

The only positional authority is `worldX`, `worldY`, and `worldZ` from the orb state. There is no `ISPanel`, `XToScreen`, `YToScreen`, camera offset, saved screen coordinate, or manual zoom divisor in the active world visual module.

```text
ACTIVE_GREEN_ORB_ISPANEL_RENDER_ROUTE=0
ACTIVE_GREEN_ORB_SCREEN_POSITION_AUTHORITY=0
NATIVE_WORLD_RENDER_CALLBACK=OnPostFloorLayerDraw
NATIVE_TEXTURE_RENDER=IsoSprite.renderTextureWithDepth
NATIVE_WORLD_RADIUS_RENDER=LineDrawer.DrawIsoCircle
STATIC_WORLD_COORDINATE_AUTHORITY=PASS
ZOOM_INVARIANCE_RUNTIME_RESULT=REAL_GAME_TEST_REQUIRED_BY_USER
```


```

## [IP_REDACTED].3_RUNTIME_RESULT.md

- SHA-256: `B9195B799A905657C90A6EE1268C111B528CE346D88724179998C4B3A7C4E714`
- Type: 阶段总结
- Runtime status: USER_RUNTIME_EVIDENCE

```text
# [IP_REDACTED].3 瀹炴満缁撴灉鎽樿

## 鐢ㄦ埛瀹炴満缁撹

- 缁胯壊鎶€鑳界悆瀹屽叏鐪嬩笉瑙併€?- 鍏夌悆鎾炲埌鍍靛案鏃朵篃瀹屽叏娌℃湁鍙纰版挒鎴栫垎鐐告晥鏋溿€?- 鍍靛案浼ゅ浠嶇劧姝ｅ父鍙戠敓銆?- 鍥犳鏈疆闂涓嶆槸浼ゅ浜嬪姟澶辫触锛岃€屾槸**涓栫晫瑙嗚閾惧拰纰版挒瑙嗚閾惧け璐?*銆?
## 鏃ュ織渚ц瘉鎹?
鏃ュ織鏄剧ず浠ｇ爜灞傛浘璁板綍锛?
- `textures_loaded=true`
- `native_world_callback=OnPostFloorLayerDraw`
- `native_world_anchor=true`
- `spawned=true`
- `impact=true`
- `xnp_zombie_damage_transaction=true`

浣嗙敤鎴峰疄鏈虹湅涓嶅埌鐞冧綋涓庢挒鍑绘晥鏋滐紝璇存槑杩欎簺鏃ュ織鍙兘璇佹槑浠ｇ爜璺緞琚皟鐢紝涓嶈兘璇佹槑鐢婚潰瀹為檯鎴愬姛娓叉煋銆?
鏃ュ織杩樻樉绀哄師鐢熺垎鐐歌矾绾垮け璐ワ細

```text
native_trap_created=false
native_triggered=false
native_method=PIPE_BOMB_ITEM_CREATE_FAILED
```

鍥犳鏈疆蹇呴』鎶婇棶棰樻媶鎴愶細

1. 鍏夌悆涓讳綋涓庢硾鍏夌殑瀹為檯涓栫晫娓叉煋澶辫触锛?2. 纰版挒/鐖嗙偢瑙嗚澶辫触锛?3. 鍍靛案涓撳睘浼ゅ浜嬪姟浠嶅湪宸ヤ綔銆?
绂佹鍐嶇敤鈥滄棩蹇楀啓浜?world_anchored=true鈥濆啋鍏呯敤鎴峰疄闄呯湅鍒颁簡涓栫晫鐗规晥銆?
```

## [IP_REDACTED].3_RUNTIME_TEST_PLAN.md

- SHA-256: `19FEAD3EAB90C5F78F3730D029DA64CA0620188022F44296D30B108681F64B62`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED].3 Runtime Test Plan

1. Confirm console identity:
   `XNP_PZ_DISTANCE_TRAIT_056063_GREEN_ORB_NATIVE_WORLD_ZOOM_EXPLOSION_EVIDENCE_A`.
2. Enable the green mode and cast with no zombie target. The orb must still appear at the player world origin.
3. While the orb is flying, repeatedly zoom in/out and pan. The orb, both glows, and both radius circles must stay on the same world center and must not pull toward the player or screen center.
4. Cast at a moving zombie. Confirm staged movement, tracking, one terminal explosion, and zombie-only damage.
5. At impact, confirm one PipeBomb explosion sound, one native-trap transaction log, and one XNP zombie-damage transaction log.
6. Confirm the player, human NPCs, animals, structures, and vehicles take no explosion damage and no fire appears.
7. Revisit the explosion square and reload the save to confirm no trap object remains.
8. Smoke-test yellow, purple, red, icon dragging, map hiding, tooltips, green melee tiers, and WHITE preparation.

Expected low-noise evidence:

```text
[XNP GREEN ORB ZOOM] native_world_anchor=true
[XNP GREEN ORB ZOOM] screen_authority=false
[XNP GREEN ORB] native_trap_created=true
[XNP GREEN ORB] native_damage_power=0 native_explosion_range=0
[XNP GREEN ORB] native_trigger_explosion=true
[XNP GREEN ORB] xnp_zombie_damage_transaction=true
```


```

## [IP_REDACTED].3_SOURCE_DROP_MIRROR_REPORT.md

- SHA-256: `085FFD197B8EDE08968A348D1D279499859C90280EF5B25512D3BA1221DD75F6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].3 SOURCE / DROP Mirror Report

- SOURCE: `[LOCAL_PATH_REDACTED]`
- DROP: `[LOCAL_PATH_REDACTED]`
- Runtime comparison set: SOURCE `42`, root `mod.info`, and root `poster.png`.
- Files compared: `144`.
- Missing files: `0`.
- SHA-256 mismatches: `0`.
- DROP first-level entries: `42`, `mod.info`, `poster.png`.

Development reports, private raw console evidence, `_kahlua_check`, and the SOURCE-only historical folders are intentionally excluded from the DROP. Sanitized public evidence is included under `42/media/XNP_DevelopmentEvidence` and is part of the 144-file mirror set.


```

## [IP_REDACTED].3_ZERO_POWER_NATIVE_TRAP_SAFETY.md

- SHA-256: `C9ACDFCA07F7BDF6E76DCE02A3A7861122FC5FB8365CC42ED1901FA25C484D35`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].3 Zero-Power Native Trap Safety

## Reachable Route

The active explosion transaction calls:

```lua
IsoTrap.new(state.player, weapon, cell, square)
trap:triggerExplosion()
```

The trap is created from `Base.PipeBomb`, configured before `place()`, triggered once, and removed through both `removeFromWorld` and `removeFromSquare` after the call.

## Zero-Damage Configuration

Before placement, the code sets:

```text
sensorRange=0
explosionPower=0
extraDamage=0
explosionRange=0
fireRange=0
fireStartingChance=0
fireStartingEnergy=0
smokeRange=0
noiseRange=0
noiseDuration=0
explosionDuration=0
```

It retains only `PipeBombExplode` as the trap's native explosion sound. No second manual explosion sound is played on the success path.

## Java Control-Flow Evidence

Local `IsoTrap.triggerExplosion()` bytecode enters `drawCircleExplosion(..., ExplosionMode.Explosion)` only when `getExplosionRange() > 0`. The active XNP trap sets the range to zero, so the branch that enumerates `IsoGameCharacter`, calls `Hit`, and invokes `CombatManager.processInstantExplosion` is not entered. Fire and smoke are separate positive-range branches and are also disabled.

This proves the native transaction does not call the Java character-hit path for players, NPCs, zombies, or animals. Vehicle and structure mutation are absent from this zero-range path. Zombie-only gameplay damage remains the pre-existing XNP transaction, which enumerates `IsoZombie` only and applies at most one hit per zombie per explosion.

```text
ISO_TRAP_NEW_REACHABLE=YES
TRIGGER_EXPLOSION_REACHABLE=YES
NATIVE_EXPLOSION_POWER=0
NATIVE_EXPLOSION_RANGE=0
NATIVE_FIRE_RANGE=0
NATIVE_SMOKE_RANGE=0
NATIVE_CHARACTER_HIT_BRANCH_REACHABLE_FROM_ACTIVE_CONFIG=NO
XNP_ZOMBIE_DAMAGE_TRANSACTION_SEPARATE=YES
PLAYER_DAMAGE_BY_NATIVE_TRAP=0_BY_CONTROL_FLOW
NPC_DAMAGE_BY_NATIVE_TRAP=0_BY_CONTROL_FLOW
ANIMAL_DAMAGE_BY_NATIVE_TRAP=0_BY_CONTROL_FLOW
STRUCTURE_DAMAGE_BY_NATIVE_TRAP=0_BY_CONTROL_FLOW
VEHICLE_DAMAGE_BY_NATIVE_TRAP=0_BY_CONTROL_FLOW
RUNTIME_TRIGGER_RESULT=REAL_GAME_TEST_REQUIRED_BY_USER
```


```

## 00_EVIDENCE_INDEX.md

- SHA-256: `83197015D5A530C0F1E988727CDBB72AEA70877AA29572DF8112A7820ACA2F70`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Development Evidence Index

Private raw evidence stays in SOURCE. Only sanitized evidence marked `PUBLIC=YES` may enter a DROP or release.

| Version | Stage | Problem | Root cause | Fix version | Static status | Real-game status | Evidence | Public |
|---|---|---|---|---|---|---|---|---|
| [IP_REDACTED] | Four round markers | Historical identity/evidence drift | Incomplete evidence field structure | [IP_REDACTED] | PASS | Historical user-tested chain | `..\0.5.57.2_SECOND_PASS_AUDIT.md` | YES |
| [IP_REDACTED] | Marker runtime draw | Runtime draw call failure | Invalid UI draw route | [IP_REDACTED] | PASS | Historical result retained | `..\0.5.57.3_ROUND_MARKER_DRAW_FIX_REPORT.md` | YES |
| 0.5.58 | Drag and color state | Marker dragging/state feedback | Shared mouse capture and state routing | 0.5.58 | PASS | Historical result retained | `..\0.5.58_SHARED_DRAG_CONTROLLER_REPORT.md` | YES |
| 0.5.59 | Phoenix predeath | Fatal timing and repeat-cycle safety | Recovery occurred after death commit | 0.5.59-[IP_REDACTED] | PASS | Historical result retained | `..\0.5.59_PHOENIX_PREDEATH_TRANSACTION_GATE_REPORT.md` | YES |
| [IP_REDACTED].1 | Red trait icon | Wrong icon reference | CharacterTrait texture route mismatch | [IP_REDACTED].1 | PASS | Historical result retained | `..\[IP_REDACTED].1_RED_TRAIT_ICON_ROOT_CAUSE.md` | YES |
| [IP_REDACTED] | Green arc/melee | Projectile, melee tiers, structure damage | New green active skill route | [IP_REDACTED] | PASS | Historical result retained | `..\0.5.60.6_GREEN_ACTIVE_SKILL_TRANSACTION_AUDIT.md` | YES |
| [IP_REDACTED].1 | Green world orb | Orb center hidden by glow; no-target admission issue | Layer order and admission path | [IP_REDACTED].2 | PASS | Superseded by [IP_REDACTED].2 result | `..\[IP_REDACTED].1_GREEN_ORB_WORLD_RENDER_AND_GLOW_REPORT.md` | YES |
| [IP_REDACTED].2 | Runtime visibility | Orb cast and zombie damage work, but zoom drifts | Full-screen ISPanel held active world visuals | [IP_REDACTED].3 | FAIL in camera anchoring | User confirmed 7 casts and zoom drift | `[IP_REDACTED].2_RUNTIME_FINDING.md`, `[IP_REDACTED].2_console_32_XNP_SANITIZED.txt` | YES |
| [IP_REDACTED].2 | Old explosion route | `IsoTrap.new/triggerExplosion` absent | PipeBomb sound/damage curve was mistaken for route reuse | [IP_REDACTED].3 | BLOCKED in prior audit | Not applicable | `[IP_REDACTED].2_AUDIT_BLOCKED.md` | YES |
| [IP_REDACTED].3 | Native world render | Remove zoom drift and screen authority | Native floor-layer callback plus engine depth render | [IP_REDACTED].3 | PASS | REAL_GAME_TEST_REQUIRED_BY_USER | `..\[IP_REDACTED].3_NATIVE_WORLD_RENDER_API_EVIDENCE.md` | YES |
| [IP_REDACTED].3 | Native explosion transaction | Reuse native trap safely | Zero range/power/fire/smoke; zombie damage separated | [IP_REDACTED].3 | PASS | REAL_GAME_TEST_REQUIRED_BY_USER | `..\[IP_REDACTED].3_ZERO_POWER_NATIVE_TRAP_SAFETY.md` | YES |

Private evidence:

- `..\閿欒鎶ュ憡\PRIVATE_RAW\[IP_REDACTED].2_console_32.txt` (`PUB
[EXCERPT_TRUNCATED]
```

## BUILD_MARKER.txt

- SHA-256: `A4B2A665BBF700F4EAF434D6450CE43AC7F620A558980750BAE8925291729735`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_056063_GREEN_ORB_NATIVE_WORLD_ZOOM_EXPLOSION_EVIDENCE_A

```

## EVIDENCE_MANIFEST.md

- SHA-256: `487D74E1E942B5BC18D9B50D5B5BDBF7E304F763637256B81B832F6008FAB5C1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Public Evidence Manifest

| File | Source | Privacy |
|---|---|---|
| `README.md` | [IP_REDACTED].3 | Public |
| `VERSION_TIMELINE.md` | Historical reports and command evidence | Public summary |
| `KNOWN_ISSUES_AND_FIXES.md` | [IP_REDACTED].3 | Public |
| `[IP_REDACTED].2_AUDIT_BLOCKED.md` | Command evidence package | Public |
| `[IP_REDACTED].2_RUNTIME_FINDING.md` | Command evidence package | Public |
| `console_32_XNP_SANITIZED.txt` | Sanitized command evidence | Public sanitized excerpt |
| `EVIDENCE_MANIFEST.md` | [IP_REDACTED].3 | Public |

The private raw console file is stored only under SOURCE `閿欒鎶ュ憡/PRIVATE_RAW` and is forbidden from this folder.


```

## EVIDENCE_MANIFEST_COMMAND_PACKAGE.md

- SHA-256: `D3AF115D389DB1E0F9E51BE713A17658113E842E32B230407836C8DD7B3BD3B7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Evidence Manifest

```text
PROJECT=XNP_PZ_DistanceRunnerTrait
TARGET_VERSION=[IP_REDACTED].3
SOURCE_CONSOLE=console(32).txt
SOURCE_CONSOLE_SHA256=D6B155BBC4B6194184489B9EBBCF7C65BA00D6908E0534A42FF9CE0512FDBE6B
RAW_CONSOLE_PUBLIC_RELEASE_ALLOWED=false
SANITIZED_EXCERPT_PUBLIC_RELEASE_ALLOWED=true
PREVIOUS_AUDIT_RESULT=BLOCKED
PRIMARY_RUNTIME_BLOCKER=CAMERA_ZOOM_VISUAL_DRIFT
PRIMARY_STATIC_BLOCKER=NATIVE_ISOTRAP_EXPLOSION_ROUTE_NOT_REUSED
```

## Required SOURCE folders

- `鍘熺悊鏃ュ織`
- `閿欒鎶ュ憡`
- `瀹¤鎶ュ憡`
- `寮€鍙戦樁娈佃瘉鎹甡
- `鍒涙剰宸ュ潑涓婁紶鍥綻

## Required runtime-package evidence location

- `42/media/XNP_DevelopmentEvidence/`

Public runtime package must contain only sanitized summaries and approved safe images.

```

## FINAL_REPORT.md

- SHA-256: `0F3C8FF7ACFD7FA94986476085025B2BDFEAF735AAF3FFE4492E8482E3C6AAD9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ Distance Runner [IP_REDACTED].3 Final Report

```text
SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=[IP_REDACTED].3
INTERNAL_VERSION=[IP_REDACTED].3-b42-green-orb-native-world-zoom-explosion-evidence-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056063_GREEN_ORB_NATIVE_WORLD_ZOOM_EXPLOSION_EVIDENCE_A
```

## Delivery

- Active orb rendering uses B42 `OnPostFloorLayerDraw`, `IsoSprite.renderTextureWithDepth`, and `LineDrawer.DrawIsoCircle`.
- `ACTIVE_GREEN_ORB_ISPANEL_RENDER_ROUTE=0`.
- `ACTIVE_GREEN_ORB_SCREEN_POSITION_AUTHORITY=0`.
- A single zero-power `IsoTrap.new(...):triggerExplosion()` transaction is reachable per orb explosion.
- Native character-hit, fire, and smoke branches are disabled by zero ranges.
- Zombie-only damage remains a separate de-duplicated XNP transaction.
- [IP_REDACTED].2 runtime outside the explicit green/identity whitelist is unchanged.
- SOURCE and DROP Kahlua both pass `98/98`.
- SOURCE/DROP runtime mirror passes `144/144`.
- Public DROP evidence contains seven sanitized files; private raw console is SOURCE-only.
- The explicit changed-file inventory is `[IP_REDACTED].3_CHANGED_FILES.md`.

## Not Verifiable Statically

- exact zoom behavior on the user's renderer;
- audible single-sound result;
- visible native callback ordering and depth;
- runtime trap creation/removal success;
- complete cross-feature gameplay regression result.

```text
PROJECT_ZOMBOID_STARTED=NO
STEAM_STARTED=NO
USER_MODS_WRITTEN=NO
SAVES_WRITTEN=NO
WORKSHOP_WRITTEN=NO
GAME_DIRECTORY_WRITTEN=NO
OLD_SOURCE_MODIFIED=NO
REAL_GAME_TEST_REQUIRED_BY_USER
BLOCKER=NONE_STATIC
FINAL_STATUS=READY_FOR_USER_RUNTIME_TEST
```

`XNP_PZ_0.5.60.6.3_GREEN_ORB_NATIVE_WORLD_ZOOM_EXPLOSION_EVIDENCE_SOURCE_READY`

```

## HISTORICAL_EVIDENCE_SEED.md

- SHA-256: `6A6BF0C3C83DCA36DF0BBFFFFA1DCA687FB2422662377CC4F6BC29F35B5C6104`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ 鍏抽敭寮€鍙戣瘉鎹仮澶嶇瀛?
姝ゆ枃浠剁敤浜庢仮澶嶆鍓嶈杩囧害鍒犻櫎鐨勫伐绋嬭瘉鎹€侰odex 蹇呴』缁х画浠庢棫 SOURCE 涓洖鏀剁湡瀹炴枃浠讹紝涓嶈兘浠呬繚鐣欐湰鎽樿銆?
## 宸插彂鐢熷苟澶勭悊鐨勯噸瑕侀棶棰?
1. RoundMarker Draw nil-call 閿欒椋庢毚銆?2. Phoenix 鎭㈠瀵硅薄涓虹┖瀵艰嚧浜嬪姟鎶ラ敊銆?3. 寮曟搸纭姝讳骸鍚庤剼鏈啀娆″啓娲伙紝褰㈡垚姝讳骸 UI 涓庡彲绉诲姩瑙掕壊骞跺瓨鐨勫菇鐏电姸鎬併€?4. 鍧犺惤涓庤繙绋嬭嚧姝诲洖璋冭繃鏅氥€?5. Phoenix 澶氳疆寰幆鐘舵€佹硠婕忋€?6. WHITE 鍐峰嵈缁撴潫鍚庝繚鎶ゆ畫鐣欍€?7. 绾㈣壊 CharacterTrait 鍥炬爣寮曠敤閿欒銆?8. 鍦板浘闅愯棌鍏变韩妗嗘灦鍙戠敓婕傜Щ銆?9. 缁胯壊鐢靛姬闅忓睆骞曠Щ鍔紝璁捐琚惁鍐炽€?10. 灞忓箷鍥涜 AABB 涓嶈兘璇佹槑鐪熷疄鍙鍖哄煙銆?11. 琛岃蛋閫熷害閲囨牱娣峰叆閿欒璇箟銆?12. [IP_REDACTED].1 鍙湅鍒版硾鍏夈€佺悆浣撲富浣撲笉鏄庢樉銆?13. 鏃犵洰鏍囨椂鏇炬嫆缁濋噴鏀炬垨棣栦釜鍏夌悆涓嶅嚭鐜般€?14. [IP_REDACTED].2 鍘熺敓鏃х垎鐐歌矾绾挎湭鐪熷疄澶嶇敤銆?15. [IP_REDACTED].2 鍏夌悆瑙嗚闅忛暅澶寸缉鏀炬紓绉汇€?
## 宸查獙璇佺殑閲嶈闃舵

- 鍥涗釜 CharacterTrait 鍧囧彲娉ㄥ唽銆?- 鍥涙灇鍦嗗舰鐘舵€佹爣璁板彲鍒涘缓銆?- 榛勮壊璺戝姩銆佸啿鎾炪€佹專鑴变笌鐘舵€佸弽棣堛€?- Phoenix 澶氳疆鎭㈠涓庢浜?tombstone銆?- 缁胯壊鏃т笁鐐稿脊澶氭鎴愬姛鍙楃悊鍜屽紩鐖嗐€?- 缁胯壊杩戞垬涓夋。涓庣粨鏋勪激瀹宠矾绾裤€?- 绾㈣壊鍒朵綔銆佸弻妯″紡涓庡浘鏍囦慨澶嶃€?- 澶氳疆 Kahlua 0 fail銆?- 澶氳疆 SOURCE / DROP SHA-256 闀滃儚涓€鑷淬€?- [IP_REDACTED].2 鏃ュ織涓嚭鐜?7 娆＄豢鑹插厜鐞冮噴鏀俱€佺敓鎴愬拰缁堟浜嬪姟銆?- [IP_REDACTED].2 绗竴鏋氬厜鐞冨鍍靛案閫犳垚浼ゅ锛屾棩蹇楄褰?humans_damaged=0銆乻tructures_damaged=0銆?
## 鎭㈠鍘熷垯

- 鍒犻櫎闅愮锛屼笉鍒犻櫎宸ョ▼璇佹嵁銆?- 鏈変环鍊间絾鍚殣绉佺殑鎴浘搴旇鍒囨垨鎵撶爜銆?- 鍘熷 console 鍙繘鍏?SOURCE 绉佹湁璇佹嵁鍖恒€?- DROP / RELEASE 鍙惡甯﹁劚鏁忔憳瑕佸拰瀹夊叏鍥剧墖銆?- 鏃?SOURCE 涓兘璇佹槑闂涓庝慨澶嶇殑鎴浘銆佹姤鍛婂拰鏃ュ織搴斿洖鏀躲€?
```
