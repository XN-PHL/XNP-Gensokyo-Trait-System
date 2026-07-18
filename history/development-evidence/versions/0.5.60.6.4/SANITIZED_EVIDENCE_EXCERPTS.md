# 0.5.60.6.4 Sanitized Evidence Excerpts

Runtime status: `NOT_YET_TESTED`. Static source is ready for user visual testing; no runtime visual PASS is claimed.

## 0.5.60.6.4_GREEN_VISUAL_IMPLEMENTATION_REPORT.md  - SHA-256: `21B1608C7D7C0273FDF8556571E576E375EB8BA7C23A7C26D4F4B59EB3B3844E` - Type: 阶段总结 - Runtime status: NOT_YET_TESTED  # 0.5.60.6.4 Green Visual Implementation Report

## Failure carried forward

- 0.5.60.6.3 runtime result: `VISUAL_PIPELINE_FAILED` and `DAMAGE_PIPELINE_WORKING`.
- `OnPostFloorLayerDraw` logged that it ran, but the user saw no orb, glow, ring, or impact effect.
- Callback execution and texture loading are therefore not accepted as visibility evidence.

## Replacement route

- Method: `ISO_WORLD_INVENTORY_OBJECT_ICON`.
- `XNP_DR_GreenWorldVisual.lua` creates engine-managed world objects through `IsoGridSquare:AddWorldInventoryItem`.
- Position authority remains `state.worldX`, `state.worldY`, and `state.worldZ`.
- Motion within a square updates `setOffX`, `setOffY`, and `setOffZ`; crossing a square safely removes and recreates the visual set.
- Cleanup calls both `removeFromWorld` and `removeFromSquare`.
- No `ISPanel`, screen projection, UI coordinate authority, or manual zoom correction is used by the active orb visual route.

## Layers

1. Enemy detection ring: green transparent world-item ring, scale 12.0.
2. Explosion radius ring: green transparent world-item ring, scale 7.0.
3. Outer glow: world-item glow, scale 4.8.
4. Inner glow: world-item glow, scale 4.0.
5. Center: original green orb texture, scale 3.2 and highest local Z offset.

The center is created after the glows and has the highest offset, so it renders above both glow layers.

## Impact visual

- Primary: four temporary engine-managed world objects at the impact coordinates, including a white explosion ring and white center flash.
- Lifetime: 850 ms, then deterministic removal.
- Backup: recovered 0.5.60.2 `instanceItem("Base.PipeBomb") -> IsoTrap.new -> place -> triggerExplosion` route.
- Backup trap is configured to power 0, extra damage 0, fire 0, smoke 0, and one-tile visual range.
- XNP zombie-only damage remains one separate transaction.

## Runtime status

`RUNTIME_VISUAL_STATUS=NOT_YET_TESTED`

The source is ready for a user runtime test; static construction is not proof that pixels are visible in game.
 
## 0.5.60.6.4_B42_WORLD_ENTITY_API_EVIDENCE.md  - SHA-256: `D7E4D29552988E9B8A20F40D549DE07E2596E794E5F4EB1BA4E96F66117E6B87` - Type: 阶段总结 - Runtime status: NOT_YET_TESTED  # 0.5.60.6.4 B42 World Entity API Evidence

Read-only inspection root: `[LOCAL_GAME_INSTALL_REDACTED]`.

## Native Lua evidence

B42 game Lua repeatedly uses `IsoGridSquare:AddWorldInventoryItem` to put inventory items into the rendered world. Extended placement UI adjusts those objects with `setOffX`, `setOffY`, and `setOffZ`.

## Java-exposed signatures

Read-only class inspection confirmed these exposed methods:

- `IsoWorldInventoryObject.setOffX(float)`
- `IsoWorldInventoryObject.setOffY(float)`
- `IsoWorldInventoryObject.setOffZ(float)`
- `IsoWorldInventoryObject.removeFromWorld()`
- `IsoWorldInventoryObject.removeFromSquare()`
- `InventoryItem.setWorldScale(float)`
- `InventoryItem.setWorldAlpha(float)`
- `IsoTrap.new(...)` is callable through the Lua-exposed class.

## Why this route was selected

An `IsoWorldInventoryObject` is owned and rendered by the game world. It is not a UI panel and does not require screen X/Y or camera zoom conversion. This directly addresses the 0.5.60.6.3 callback path that executed without producing visible output.

`RUNTIME_VISUAL_STATUS=NOT_YET_TESTED`
 
## 0.5.60.6.4_OLD_GREEN_EXPLOSION_ROUTE_RECOVERY.md  - SHA-256: `7658AAEABABC0DDDA87811C309DCB384934CCECAFBF32A9B6D3595E55B0E0CD5` - Type: 阶段总结 - Runtime status: NOT_YET_TESTED  # 0.5.60.6.4 Old Green Explosion Route Recovery

## Proven anchor

Recovered version: `0.5.60.2`.

Recovered file: `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_GreenBombSkill.lua` from the 0.5.60.2 SOURCE.

The accepted route used:

1. `instanceItem("Base.PipeBomb")`;
2. `IsoTrap.new(player, item, cell, square)`;
3. `trap:place()`;
4. delayed `trap:triggerExplosion()`.

## 0.5.60.6.3 root cause

The runtime log recorded `PIPE_BOMB_ITEM_CREATE_FAILED`. The 0.5.60.6.3 implementation had changed item creation to `InventoryItemFactory.CreateItem`. Version 0.5.60.6.4 restores `instanceItem` as the first route and keeps the factory only as a guarded fallback.

## Safety adaptation

The old three-bomb input is not restored. The recovered trap route is used only at the orb impact point. Native trap power, extra damage, fire, and smoke are forced to zero. Actual damage is still applied only by the existing XNP zombie list transaction, once per zombie and once per cast.

`OLD_PROVEN_ROUTE_VERSION=0.5.60.2`
`RUNTIME_VISUAL_STATUS=NOT_YET_TESTED`
 
## 0.5.60.6.4_EVIDENCE_RECOVERY_REPORT.md  - SHA-256: `0CB054B072DFBD1E05D73B4D5674E31CCE8FD1F38C2D6D683F1F636692455C83` - Type: 阶段总结 - Runtime status: NOT_YET_TESTED  # 0.5.60.6.4 Evidence Recovery Report

## Scope

- Project directories discovered: 145 historical SOURCE/DROP/RELEASE directories.
- Version nodes indexed: 100 including the current test version.
- Historical versions with recovered evidence before adding current reports: 99.
- Current version runtime evidence: `NOT_YET_TESTED`.

## Recovered historical evidence

- Raw logs: 45
- Audit reports: 292
- Error reports: 51
- Stage reports: 822
- Screenshots: 19
- Public sanitized archive files before current report refresh: 122

## Separation

- Private originals: `开发阶段证据/FULL_PRIVATE_ARCHIVE`.
- Public sanitized archive: `42/media/XNP_DevelopmentEvidence`.
- Raw console logs and original local paths remain private.
- Public archive contains version timelines, error/audit indexes, sanitized excerpts, screenshot index, and focused Green/Phoenix/UI histories.
- Five established workshop/contact-sheet images were copied publicly; uncertain images remain private.

No missing historical directory was invented. Missing evidence is marked `SOURCE_EVIDENCE_NOT_FOUND`; untested behavior is marked `NOT_YET_TESTED`.
 
## 0.5.60.6.4_RUNTIME_TEST_PLAN.md  - SHA-256: `866C1AAACFD99B7D315722E520363D4F799FC2415AB9BB7F4C3907D9E45F5D14` - Type: 阶段总结 - Runtime status: NOT_YET_TESTED  # 0.5.60.6.4 Runtime Test Plan

## Required user checks

1. Confirm the build marker is `XNP_PZ_DISTANCE_TRAIT_056064_GREEN_ORB_VISIBLE_IMPACT_FULL_EVIDENCE_RECOVERY_A`.
2. Activate the green skill with no target and verify the orb still appears at the player origin.
3. Verify center orb, two glow layers, enemy detection ring, and explosion-radius ring are all visible.
4. Change zoom while the orb is moving and verify all five layers remain locked to one world position.
5. Verify normal walking-speed launch, smooth targeting, wall collision, and staged acceleration after three seconds.
6. Hit a zombie and verify a clear white impact/explosion visual is visible.
7. Confirm the log reports actual `world_visual_created`, impact primary/fallback creation, and old proven route method.
8. Confirm zombie damage still occurs once while player, human NPC, animal, structure, vehicle, and fire damage remain zero.
9. Repeat casts and leave/re-enter the save to detect leaked world items.
10. Recheck yellow, Phoenix, red, three green melee tiers, structure 20x, four-icon drag, map hide, tooltip, and audio regressions.

## Acceptance

- Visual acceptance requires user-observed pixels, not only logs.
- If world visual creation logs true but the user still sees nothing, status remains `VISUAL_PIPELINE_FAILED`.
- If both primary impact and old proven fallback fail, the impact transaction must be treated as incomplete.

`RUNTIME_VISUAL_STATUS=NOT_YET_TESTED`
 
## 0.5.60.6.4_CHANGED_FILES.md  - SHA-256: `68A632F4B5F8A7C602F091E336A7D82C99A4515D21A64800022DF08E056DDD7B` - Type: 阶段总结 - Runtime status: NOT_YET_TESTED  # 0.5.60.6.4 Changed Files

## Runtime identity

- `mod.info`
- `42/mod.info`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `BUILD_MARKER.txt`

## Green visual and impact

- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_GreenWorldVisual.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_GreenWorldOrb.lua`
- `42/media/scripts/XNPGreenWorldVisualItems.txt`
- `42/media/textures/Item_XNPGreenOrbWorldCenter.png`
- `42/media/textures/Item_XNPGreenOrbWorldGlow.png`
- `42/media/textures/Item_XNPGreenOrbWorldRing.png`
- `42/media/textures/Item_XNPGreenOrbWorldExplosion.png`

## Evidence

- `开发阶段证据/FULL_PRIVATE_ARCHIVE/**`
- `开发阶段证据/00_FULL_EVIDENCE_INDEX.md`
- `42/media/XNP_DevelopmentEvidence/**`
- 0.5.60.6.4 reports at SOURCE root.

No frozen yellow, Phoenix, red, green melee, structure, marker drag, map-hide, tooltip, or audio runtime file differs from the 0.5.60.6.3 baseline outside the listed identity files.
 
## STATIC_AUDIT.md  - SHA-256: `D971F6596B091E6D211E21575703A12C1D8E2CA4DFFD1B0E9666E8F24408632A` - Type: 阶段总结 - Runtime status: NOT_YET_TESTED  # Static Audit 0.5.60.6.4

- SOURCE Kahlua: `97 pass / 0 fail`.
- DROP Kahlua: `97 pass / 0 fail`.
- SOURCE/DROP runtime mirror: `262 files / 0 differences` at the measured checkpoint.
- DROP top level: exactly `42`, `mod.info`, `poster.png`.
- New `Events.OnTick.Add`: 0.
- Total `Events.OnPlayerUpdate.Add`: 1.
- Per-frame texture loads in green world visual: 0.
- World object creation: only on cast, impact, or square crossing.
- World object cleanup: `removeFromWorld` and `removeFromSquare` on hide, expiry, failure, and shutdown.
- Baseline non-whitelist runtime differences: 0.
- Private raw files in public DROP: 0.
- Active green orb `ISPanel` route: 0.
- Active green orb screen-position authority: 0.
- Player/NPC/animal/structure/vehicle/fire XNP damage transactions: 0.
- Zombie XNP damage transaction: one guarded transaction per cast.

Static blocker: none.

`RUNTIME_VISUAL_STATUS=NOT_YET_TESTED`
 
## FINAL_REPORT.md  - SHA-256: `6436E7BBB7AE8BB67CFA003745B9879A24E56A44F862AE0907DB6238D953CC2F` - Type: 阶段总结 - Runtime status: NOT_YET_TESTED  # XNP PZ 0.5.60.6.4 Final Report

- VERSION: `0.5.60.6.4`
- INTERNAL_VERSION: `0.5.60.6.4-b42-green-orb-visible-impact-full-evidence-recovery-a`
- BUILD_MARKER: `XNP_PZ_DISTANCE_TRAIT_056064_GREEN_ORB_VISIBLE_IMPACT_FULL_EVIDENCE_RECOVERY_A`
- WORLD_VISUAL_METHOD: `ISO_WORLD_INVENTORY_OBJECT_ICON`
- IMPACT_PRIMARY: engine-managed white explosion world entities
- IMPACT_BACKUP: `0.5.60.2_INSTANCE_ITEM_ISOTRAP_TRIGGER`
- XNP_DAMAGE_SCOPE: zombie only
- NON_ZOMBIE_DAMAGE: zero
- SOURCE_KAHLUA: `97 pass / 0 fail`
- DROP_KAHLUA: `97 pass / 0 fail`
- SOURCE_DROP_MIRROR_DIFF: 0
- HISTORICAL_VERSIONS_INDEXED: 100 including current
- RAW_LOGS_RECOVERED: 45
- AUDIT_REPORTS_RECOVERED: 292
- ERROR_REPORTS_RECOVERED: 51
- STAGE_REPORTS_RECOVERED: 830
- SCREENSHOTS_RECOVERED: 19
- PUBLIC_SANITIZED_FILES_CREATED: 122
- MISSING_VERSION_EVIDENCE_COUNT: 0
- PRIVATE_PUBLIC_EVIDENCE_SEPARATED: YES
- OLD_SOURCE_MODIFIED: NO
- PROJECT_ZOMBOID_STARTED: NO
- STEAM_STARTED: NO
- USER_MODS_OR_SAVES_WRITTEN: NO
- GAME_DIRECTORY_WRITTEN: NO
- RUNTIME_VISUAL_STATUS: `NOT_YET_TESTED`

Final status: `READY`.

Readiness scope: SOURCE and DROP are ready for the user's runtime visual test. This does not claim a runtime visual PASS.
 