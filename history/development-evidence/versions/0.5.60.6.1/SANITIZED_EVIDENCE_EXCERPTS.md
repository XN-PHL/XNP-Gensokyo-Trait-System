# 0.5.60.6.1 Sanitized Evidence Excerpts

## [IP_REDACTED].1_GREEN_ORB_WORLD_RENDER_AND_GLOW_REPORT.md

- SHA-256: `4ACD00D17E5B4789BBF54E17CE44387B7265DBBFBA2949F1BBDDE12FF174FEF2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Green Orb World Render And Glow

- `ORB_WORLD_POSITION_AUTHORITATIVE=true`
- `ORB_SCREEN_POSITION_AUTHORITATIVE=false`
- `ORB_CHARACTER_SCALE_RATIO_MIN=0.70`
- `ORB_CHARACTER_SCALE_RATIO_MAX=1.00`
- Implemented ratio: `0.80`
- `ORB_GLOW_LAYER_COUNT=2`
- `ORB_GLOW_CREATED_IF_MISSING=true`
- `ORB_CENTER_ASSET_REDRAWN=false`
- `ORB_TEXTURE_LOAD_PER_FRAME=false`
- `GREEN_WORLD_RENDER_ENTRYPOINT_COUNT=1`

`XNP_DR_GreenWorldOrb.lua` owns `worldX/worldY/worldZ`; `XNP_DR_GreenWorldVisual.lua` projects those coordinates only while rendering. The billboard is approximately 80% of the standing-character reference height and scales with camera zoom. A smooth pulse is limited to plus or minus 4%.

The locked command-package source remains byte-identical at SHA256 `2356AC8C4AD607FAB4859D46DC9B3EE1B2384FE75936A6F4C6AA965F9A683EE2`. Its 22x26 canvas contains only a 5x8 nontransparent region, so the runtime center strips transparent padding and centers those unchanged pixels in an 8x8 square; runtime SHA256 is `6B07DC00C385B7B754A624AB3565FB2B274DCF77DDD1D55EA0F9B5647F0AD525`. This is transparent-border normalization, not redraw. The separate glow asset was generated from that alpha with alpha expansion, MaxFilter, Gaussian blur, and opacity decay. No center RGB pixels were redrawn into the glow.

`SMOOTH_WORLD_ORB_USER_TEST=NOT_YET_TESTED`
`GREEN_GLOW_USER_TEST=NOT_YET_TESTED`

```

## [IP_REDACTED].1_OLD_GREEN_EXPLOSION_FX_REUSE_REPORT.md

- SHA-256: `A88B99E1C4DBEBFD8B31DB42F055CC0E00674D896B07532ADE060C0ACFB91937`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Old Green Explosion FX Reuse

- `GREEN_OLD_EXPLOSION_FX_REUSED=true`
- `OLD_THREE_BOMB_SPAWN_COUNT=0`
- `EXPLOSION_POSITION_SOURCE=ORB_IMPACT_WORLD_POSITION`
- `VISUAL_DAMAGE_POSITION_MISMATCH=false`

The old verified route was `Base.PipeBomb` plus `triggerExplosion()`, whose visible result and `PipeBombExplode` sound were generated at the trap square. B42 exposes no public visual-only half of `triggerExplosion`; invoking it would also process humans and world squares. This version therefore reuses the old point-explosion contract as a safe visual-only decomposition: a green point flash, radial green particles, and the exact `PipeBombExplode` world sound are emitted at the orb impact coordinates. The same `explosionId` and coordinates drive damage and the white ring.

No `IsoTrap` is spawned, no normal explosion entity exists, and no three-bomb route is reachable.

`IMPACT_POSITION_EXPLOSION_USER_TEST=NOT_YET_TESTED`


```

## [IP_REDACTED].1_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `CCAF72D825BC9FE7E5EDF25BFF6D1B9DD9C33CD8ECE0E7BB0565132D32F1BDC4`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED].1 Runtime Preservation

## Frozen Systems

Green melee tiers, right-click toggle, successful-hit costs, 20-hit-equivalent structure damage, yellow systems, Phoenix, red systems, shared dragging, Tooltip, poster, previews, privacy material, and all unrelated audio remain copied from [IP_REDACTED].

The only green behavior replacement is left-double-click activation. `XNP_DR_GreenProjectileArc.lua` and `XNP_DR_GreenArcVisual.lua` are unreachable disabled history markers.

## Runtime Budget

- `XNP_ON_TICK_HANDLER_COUNT=0`
- `XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1`
- `GREEN_ACTIVE_PROJECTILE_MAX=1`
- `GREEN_TARGET_SCAN_AT_CAST_ONLY=true`
- `GREEN_TARGET_REACQUIRE_MAX_PER_CAST=1`
- `GREEN_WORLD_RENDER_ENTRYPOINT_COUNT=1`
- `GREEN_SCREEN_LINE_RENDER_ENTRYPOINT_COUNT=0`
- `GREEN_ARC_RUNTIME_REACHABLE_COUNT=0`
- `GREEN_BEAM_RUNTIME_TEXTURE_LOAD_COUNT=0`
- `GREEN_SCREEN_FIXED_SKILL_PANEL_COUNT=0`
- `GREEN_ACTIVE_SKILL_LINE_SEGMENT_COUNT=0`
- `TEXTURE_LOAD_PER_FRAME=false`
- `PANEL_CREATE_PER_FRAME=false`
- `NORMAL_IDLE_PER_FRAME_LOGGING=false`

Explosion-radius enumeration is a one-time damage transaction and is not target acquisition. It is never performed while idle or per frame.


```

## [IP_REDACTED].1_SOURCE_DROP_MIRROR_REPORT.md

- SHA-256: `477A41168410B4B12EC4D6016587E82ACC0D2443F9EDC9E112C14D9820C48577`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 SOURCE / DROP Mirror Report

- SOURCE payload: `42/`, `mod.info`, `poster.png`
- DROP: `[LOCAL_PATH_REDACTED]`
- SOURCE payload files: 135
- DROP files: 135
- Missing files: 0
- Extra files: 0
- SHA256 mismatches: 0
- SOURCE Kahlua: `95 PASS / 0 FAIL`
- DROP Kahlua: `95 PASS / 0 FAIL`

`SOURCE_DROP_MIRROR=PASS`


```

## [IP_REDACTED].1_WHITE_EXPLOSION_RADIUS_RING_REPORT.md

- SHA-256: `50F0A70766661A8BA5F1D2FD8814715303BBD6C65CB07A149833DDDB38384CEF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 White Explosion Radius Ring

- `EXPLOSION_RING_COLOR=WHITE`
- `EXPLOSION_RING_CENTER=ORB_IMPACT_WORLD_POSITION`
- `EXPLOSION_RING_RADIUS=GRENADE_BASELINE_RADIUS`
- `EXPLOSION_RING_SEGMENTS_MIN=24`
- `EXPLOSION_RING_SEGMENTS_MAX=32`
- Implemented segments: `32`
- `EXPLOSION_RING_DURATION_REAL_SECONDS=0.50`
- `EXPLOSION_RING_WORLD_ANCHORED=true`
- `EXPLOSION_RING_DAMAGE=0`
- `EXPLOSION_RING_COUNT_PER_EXPLOSION=1`

Thirty-two world-space points at radius seven are projected every render and joined with the B42 `ISUIElement:drawLine` API at 2 px and alpha 0.75. The center and radius remain in world coordinates; camera motion changes only projection. The ring shares the single world renderer and expires after 500 real milliseconds.

`WHITE_RADIUS_RING_USER_TEST=NOT_YET_TESTED`


```

## BUILD_MARKER.txt

- SHA-256: `64D10BB19DC3B6DAEB62C6D949D4E821D442BA1EA9A2B53BC4B788032A726F16`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_056061_GREEN_WORLD_ORB_GRENADE_RING_A

```

## FINAL_REPORT.md

- SHA-256: `F2778E6BB4165D6770DAA081C75D87AFAF219AE3C0EAA8A776D8799A496CC64D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ Distance Runner [IP_REDACTED].1 Final Report

## Output

- `SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]`
- `DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]`
- `VERSION=[IP_REDACTED].1`
- `INTERNAL=[IP_REDACTED].1-b42-green-world-orb-grenade-ring-a`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056061_GREEN_WORLD_ORB_GRENADE_RING_A`
- `MOD_ID=XNP_PZ_DistanceRunnerTrait`
- `GREEN_FULL_ID=XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage`

## Implemented Contract

- World-authoritative tracking orb with one center layer and two alpha-derived glow layers.
- Actual-viewport projected primary targeting and 12-tile fallback.
- One cast scan, at most one reacquisition, and one active projectile.
- Proven B42 running-speed base, 0.12-second acceleration, 540-degree/second turn cap, 0.55-tile impact, 2.50-second timeout, and zero rebound.
- Impact-position green point explosion visual and exact `PipeBombExplode` world sound.
- `Base.PipeBomb` power 90/radius 7 damage bounds, deterministic distance falloff, and zombie-only transaction.
- One 32-segment white world ring for 0.50 seconds and one 0.50-second green outline per damaged zombie.
- Human, NPC, animal, structure, vehicle, and fire effects are zero by construction.

## Preservation

Green right-click melee toggle, three melee tiers and costs, 20-hit-equivalent structure damage, yellow, Phoenix, red, dragging, Tooltip, map hiding, poster, previews, privacy material, and unrelated audio are frozen. The map module is byte-identical to [IP_REDACTED].

## Validation

- Lua files: 95
- Lua lines: 16070
- Kahlua SOURCE: `95 PASS / 0 FAIL`
- Kahlua DROP: `95 PASS / 0 FAIL`
- JSON parse: `PASS`
- Empty files: 0
- `OnTick`: 0
- `OnPlayerUpdate`: 1
- SOURCE/DROP payload: `135 / 135`, 0 missing, 0 extra, 0 hash mismatches
- Game launched: `NO`
- Steam launched: `NO`
- Old SOURCE modified: `NO`
- User mods/saves/Workshop/game directories written: `NO`

## Evidence Boundary

- `OLD_ARC_USER_RESULT=TRIGGERED_BUT_DESIGN_REJECTED`
- `SMOOTH_WORLD_ORB_USER_TEST=NOT_YET_TESTED`
- `GREEN_GLOW_USER_TEST=NOT_YET_TESTED`
- `IMPACT_POSITION_EXPLOSION_USER_TEST=NOT_YET_TESTED`
- `GRENADE_EQUIVALENT_DAMAGE_USER_TEST=NOT_YET_TESTED`
- `WHITE_RADIUS_RING_USER_TEST=NOT_YET_TESTED`
- `PLAYER_IMMUNITY_USER_TEST=NOT_YET_TESTED`
- `NPC_IMMUNITY_USER_TEST=NOT_YET_TESTED`

`BLOCKER=NONE_STATIC`

`XNP_PZ_0.5.60.6.1_GREEN_WORLD_ORB_GRENADE_RING_READY`

```

## [IP_REDACTED].1_PACKAGE_VALIDATION.md

- SHA-256: `F738C01A40A23EB1B3820373CEBB49158DF79898E09F4AF8A6ECA62B24471262`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Package Validation

- SOURCE identity files: `PASS`
- SOURCE Kahlua syntax: `PASS (95/95)`
- JSON translation parse: `PASS`
- Required runtime center PNG: `PASS`
- Required generated glow PNG: `PASS`
- Required launch OGG: `PASS`
- Frozen map framework hash: `PASS`
- Old Arc active references: `0`
- DROP mirror: `PASS (135 files, 0 missing, 0 extra, 0 hash mismatches)`
- DROP Kahlua syntax: `PASS (95/95)`
- Game/Steam launched: `NO`
- User mods/saves/Workshop/game directories written: `NO`

`PACKAGE_VALIDATION=PASS`

```

## [IP_REDACTED].1_PREVIOUS_AUDIT_BLOCKER_CLOSURE_REPORT.md

- SHA-256: `B921113890DD86CF37B0E39E6224626EE4DBAE3056DC2135E35042BB6FB845AA`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Previous Audit Blocker Closure

## Result

- `MAP_HIDE_FRAMEWORK_DIFF_COUNT=0`
- [IP_REDACTED] reference SHA256: `39189E79D59BF39E92D614CCA69A286839393E697D70378B73E3CB916727DD2F`
- [IP_REDACTED].1 SHA256: `39189E79D59BF39E92D614CCA69A286839393E697D70378B73E3CB916727DD2F`
- `TARGET_PRIMARY_FILTER=PROJECTED_INSIDE_VIEWPORT`
- `TARGET_AABB_ONLY=false`
- `ORB_SPEED_SOURCE=PROVEN_PLAYER_RUN_SPEED`

## Closure Evidence

1. `XNP_DR_RoundMarkerMapVisibility.lua` was copied byte-for-byte from the frozen [IP_REDACTED] framework baseline.
2. The old screen-corner-to-world AABB code is absent from the active runtime. Every primary candidate is projected with `IsoUtils.XToScreen/YToScreen`, camera offsets are removed, and the resulting pixel is checked against the current screen width and height.
3. The B42.19 `IsoPlayer` bytecode sets `currentSpeed=1.0f` while `isRunning()` and `currentSpeed=1.5f` while sprinting. The orb uses the stable running value `1.0` multiplied by the public `getRunSpeedModifier()` value; it never samples walking, standing, or transient displacement.

`OLD_ARC_USER_RESULT=TRIGGERED_BUT_DESIGN_REJECTED`


```

## [IP_REDACTED].1_RUNTIME_TEST_CHECKLIST.md

- SHA-256: `83026CC2414E338F1959A88D6D2B996A256751B641A0AAA4BABBC87754B411C8`
- Type: 审计报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED].1 Runtime Test Checklist

All items below require user testing. No item is pre-marked as passed.

1. Confirm build marker and Config-loaded logs appear without Lua exceptions.
2. Confirm right-click still toggles only green melee and all three melee tiers/costs remain unchanged.
3. Confirm a single click and a drag over 5 px do not cast.
4. With no zombie visible or within 12 tiles, double-click and confirm no sound and no cooldown.
5. With a visible zombie, confirm one near-character-height orb spawns at the character world position with two clear green glow layers.
6. Move the player and camera while the orb flies; confirm the orb remains world anchored.
7. Confirm smooth 0.12-second acceleration and bounded turning without teleporting, snapping, or bouncing.
8. Confirm target loss permits at most one reacquisition.
9. Confirm target, wall, and timeout explosions occur at the orb's actual stopping point.
10. Confirm the launch sound and `PipeBombExplode` each play once.
11. Confirm nearby infected receive distance-scaled grenade-equivalent damage once and show a green outline for 0.5 seconds.
12. Confirm players, NPCs, other humans, animals, structures, doors, windows, and vehicles are unaffected and no fire starts.
13. Confirm one 32-segment white ring appears at the impact world position for 0.5 seconds and moves correctly with camera projection.
14. Confirm yellow, Phoenix, red, marker dragging, map hiding, Tooltip, poster, and preview behavior remain unchanged.


```

## [IP_REDACTED].1_SECOND_PASS_AUDIT.md

- SHA-256: `6F657570923F25D8D171DBF08508FCF4750B4A7F0286795ECD0C500D376E1208`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 杞婚噺瀹氬悜浜屾鍙瀹¤

## 瀹¤缁撹

```text
AUDIT_MODE=SECOND_PASS_READ_ONLY
SOURCE=[LOCAL_PATH_REDACTED]
DROP=[LOCAL_PATH_REDACTED]
BASELINE=[LOCAL_PATH_REDACTED]
SHARED_FRAMEWORK_REFERENCE=[LOCAL_PATH_REDACTED]
AUDIT_RESULT=BLOCKED
BLOCKER_COUNT=2
```

涓嶈兘杈撳嚭 `AUDIT_PASS`銆備袱涓‖鎬ц姹傜己灏戜唬鐮佽瘉鎹細

1. `ORB_SPEED_SOURCE=PROVEN_PLAYER_RUN_SPEED` 涓嶆垚绔嬨€傚疄鐜版妸 `RUN_SPEED_TILES_PER_SECOND=1.0` 鐩存帴褰撲綔涓栫晫鏍?绉掞紱鏈満 B42.19 瀛楄妭鐮佸彧璇佹槑濂旇窇鏃舵妸 `currentSpeed` 璁句负 `1.0f`锛岄殢鍚庤皟鐢?`playerMoveDir.setLength(currentSpeed)`銆傝繖璇佹槑鐨勬槸褰掍竴鍖栫Щ鍔ㄨ緭鍏ュ悜閲忛暱搴︼紝涓嶆槸鏈€缁堜笘鐣屼綅绉婚€熷害銆傚姩鐢汇€佸熀纭€閫熷害銆佺姸鎬佸拰鍏朵粬绉诲姩绠＄嚎浠嶄細鍙備笌瑙掕壊鐪熷疄浣嶇Щ锛屽洜姝や笉鑳芥妸璇ユ爣閲忓懡鍚嶄负 tiles/s銆?2. `GREEN_OLD_EXPLOSION_FX_REUSED=true` 涓嶆垚绔嬨€?.5.60.5 鏃х豢鑹茬偣瑙嗚鏉ヨ嚜 `IsoTrap.new(... Base.PipeBomb ...)` 鍚庤皟鐢?`triggerExplosion()`锛?.[IP_REDACTED] 鐨勬椿鍔ㄦ爲涓?`IsoTrap` 鍜?`triggerExplosion` 鍧囦负闆跺紩鐢紝鏂扮増鍦?`XNP_DR_GreenWorldVisual.lua` 涓嚜琛岀粯鍒朵腑蹇冪汗鐞嗐€佹硾鍏夊拰寰勫悜绮掑瓙銆傚畠澶嶇敤浜?`PipeBombExplode` 澹伴煶鍙娾€滀笘鐣岀偣鐖嗙偢鈥濈殑姒傚康锛屼絾娌℃湁澶嶇敤鏃х垎鐐歌瑙夊疄鐜般€佹棫闂厜鎴栨棫绮掑瓙璺嚎銆?
## 涓婁竴杞笁涓?BLOCKER

```text
MAP_HIDE_FRAMEWORK_DIFF_COUNT_VS_05605=0
MAP_HIDE_REFERENCE_SHA256=39189E79D59BF39E92D614CCA69A286839393E697D70378B73E3CB916727DD2F
MAP_HIDE_SOURCE_SHA256=39189E79D59BF39E92D614CCA69A286839393E697D70378B73E3CB916727DD2F
TARGET_AABB_ONLY=false
TARGET_PRIMARY_FILTER=PROJECTED_INSIDE_VIEWPORT
WALK_SPEED_CLAIM_REMOVED=true
ORB_SPEED_SOURCE=UNPROVEN_NORMALIZED_RUNNING_INPUT_SCALAR
ORB_SPEED_SOURCE_PROVEN_PLAYER_RUN_SPEED=false
```

鍦板浘鍏变韩鏂囦欢鍜岀湡瀹炶鍙ｆ姇褰变袱涓棫闃绘柇宸茬粡鍏抽棴銆俙projectToViewport()` 浣跨敤 `XToScreen/YToScreen`銆佹憚鍍忔満鍋忕Щ鍜屽綋鍓嶅睆骞曞楂樿繘琛屽儚绱犵煩褰㈠垽鏂紱娲诲姩鏍戜腑 `XToIso`銆乣YToIso`銆乣captureScreenBounds` 鍧囦负闆跺懡涓€?
姝ヨ閫熷害澹版槑宸茬粡绉婚櫎锛屼絾鏇夸唬瀹冪殑濂旇窇閫熷害澹版槑浠嶇己灏戜笘鐣屾牸/绉掕瘉鏄庯紝鎵€浠ョ涓変釜闃绘柇鍙畬鎴愪簡鈥滅Щ闄ゆ棫閿欒鈥濓紝娌℃湁瀹屾垚鈥滆瘉鏄庢柊閫熷害鈥濄€?
## 杈撳叆涓庡喕缁撶郴缁?
```text
GREEN_LEFT_DOUBLE_CLICK_ACTIVE_SKILL=true
GREEN_SINGLE_CLICK_ACTIVE_SKILL=false
GREEN_DRAG_OVER_5PX_ACTIVE_SKILL=false
GREEN_RIGHT_CLICK_MELEE_TOGGLE=true
GREEN_MELEE_DEFAULT_ENABLE_UNCHANGED=true
GREEN_MELEE_TIER_VALUES_UNCHANGED=true
GREEN_STRUCTURE_20_HIT_UNCHANGED=true
GREEN_PASSIVE_RUNTIME_DIFF_COUNT=0
YELLOW_RUNTIME_DIFF_COUNT=0
PHOENIX_RUNTIME_DIFF_COUNT=0
RED_RUNTIME_DIFF_COUNT=0
```

`GreenSkillUI` 鐩稿 [IP_REDACTED] 鍙湁涓夊涓诲姩妯″潡鎺ョ嚎鏇挎崲锛歳equire銆佸弻鍑昏姹傚拰鍦板浘鐘舵€佽浆鍙戙€傚彸閿粛璋冪敤 `GreenSkill.ToggleEnabled`銆傜豢鑹茶鍔ㄤ簲涓笓灞炴枃浠堕€愭枃浠跺搱甯屼竴鑷淬€?
缁胯壊妗ｄ綅浠嶄负锛?
```text
GREEN_THRESHOLD=0.65
GREEN_MULTIPLIER=8.0
GREEN_COST=0.03
YELLOW_THRESHOLD=0.30
YELLOW_MULTIPLIER=5.0
YELLOW_COST=0.02
RED_MULTIPLIER=2.5
RED_COST=0.01
STRUCTURE_TOTAL_EQUIVALENT_HITS=20
STRUCTURE_ADDITIONAL_EQUIVALENT_HITS=19
```

涓撳睘鏂囦欢姣旇緝鑼冨洿涓洪粍鑹?9 涓€丳hoenix 12 涓€佺孩鑹?8 涓紝鍏ㄩ儴涓?[IP_REDACTED] 鐩稿悓銆?
## 鏃х數寮т笉鍙揪

```text
GREEN_ARC_RUNTIME_REACHABLE_COUNT=0
GREEN_BEAM_RUNTIME_TEXTURE_LOAD_COUNT=0
GREEN_SCREEN_LINE_RENDER_ENTRYPOINT_COUNT=0
GREEN_ACTIVE_SKILL_LINE_SEGMENT_COUNT=0
OLD_ARC_START_LOG_REACHABLE=false
OLD_ARC_COMPLETE_LOG_REACHABLE=false
```

鏃т袱涓枃浠跺彧鍓╂湭娉ㄥ唽鐨?disabled 鍘嗗彶鍗犱綅銆傛椿鍔ㄦ爲娌℃湁 require銆佹ā鍧楀瓧娈点€丅eam 绾圭悊璺緞銆乣arc_start` 鎴?`arc_complete`銆傛柊瑙嗚涓殑鍞竴 `drawLine` 璋冪敤灞炰簬蹇呴』瀛樺湪鐨勪笘鐣屽潗鏍囩櫧鑹茶寖鍥村湀锛屼笉鏄睆骞曞浐瀹氭縺鍏
[EXCERPT_TRUNCATED]
```

## [IP_REDACTED].1_STATIC_AUDIT.md

- SHA-256: `0609599DE3F7471E2A7D7F37D955B85ECBD26B047CC6A373957AC994B535C1FD`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Static Audit

## Identity

- `VERSION=[IP_REDACTED].1`
- `INTERNAL=[IP_REDACTED].1-b42-green-world-orb-grenade-ring-a`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056061_GREEN_WORLD_ORB_GRENADE_RING_A`
- `MOD_ID=XNP_PZ_DistanceRunnerTrait`
- `GREEN_FULL_ID=XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage`

## Kahlua And Resources

- Kahlua compiler: `PASS`, 95 Lua files, 0 failures.
- Lua lines: 16070.
- Empty files: 0.
- Locked source SHA256 preserved: `PASS`; runtime center is a transparent-border-only 8x8 normalization with unchanged source pixels.
- Launch OGG SHA256: `55F431F59FA1B1AD1D069B1D7823B559646F4436C905C9395AB3962BCE55BF4C`.
- Map framework byte identity against [IP_REDACTED]: `PASS`.
- `OnTick` registrations: 0.
- `OnPlayerUpdate` registrations: 1.

## B42 Evidence

`[LOCAL_PATH_REDACTED]` defines `Base.PipeBomb` with `ExplosionPower=90`, `ExplosionRange=7`, `ExplosionSound=PipeBombExplode`, `FireStartingEnergy=0`, and `FireStartingChance=0`.

`IsoTrap.explosion` computes the native hit amount from `power/20` to `(power/20)*2`, which is 4.5 to 9.0 for PipeBomb. Native square enumeration uses a hard radius rather than radial attenuation. To satisfy the requested distance falloff without creating a normal explosion entity, this module maps the proven bounds deterministically from 9.0 at the center to 4.5 at radius seven and calls `Hit` only on validated `IsoZombie` instances.

The B42 `IsoPlayer` movement bytecode sets running `currentSpeed` to 1.0 and sprinting to 1.5. The orb uses the running value multiplied by public `getRunSpeedModifier()`.

## Active Skill Contract

- Primary target: projected inside actual viewport.
- Fallback: nearest valid zombie within 12 tiles.
- Reacquire: at most once.
- Acceleration: 0.12 seconds.
- Turn rate: 540 degrees/second.
- Impact distance: 0.55 tiles.
- Flight timeout: 2.50 seconds.
- Wall rebound: 0.
- Damage: zombie only, once per zombie per explosion.
- Ring: 32 white segments, radius 7, 0.50 seconds.
- Human, NPC, animal, structure, vehicle, and fire writes: absent from the active module.

## Legacy Route Grep

All active-tree counts are zero for `arc_start`, `arc_complete`, Beam texture names, `GreenProjectileArc`, `GreenArcVisual`, `captureScreenBounds`, `XToIso`, `YToIso`, `IsoTrap`, and `triggerExplosion`.

## Evidence Boundary

- `OLD_ARC_USER_RESULT=TRIGGERED_BUT_DESIGN_REJECTED`
- `SMOOTH_WORLD_ORB_USER_TEST=NOT_YET_TESTED`
- `GREEN_GLOW_USER_TEST=NOT_YET_TESTED`
- `IMPACT_POSITION_EXPLOSION_USER_TEST=NOT_YET_TESTED`
- `GRENADE_EQUIVALENT_DAMAGE_USER_TEST=NOT_YET_TESTED`
- `WHITE_RADIUS_RING_USER_TEST=NOT_YET_TESTED`
- `PLAYER_IMMUNITY_USER_TEST=NOT_YET_TESTED`
- `NPC_IMMUNITY_USER_TEST=NOT_YET_TESTED`

`STATIC_BLOCKER=NONE`

```
