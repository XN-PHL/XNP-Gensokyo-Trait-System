# 0.5.55 Sanitized Evidence Excerpts

## 0.5.55_RUNTIME_ERROR_FORENSIC_REPORT.md

- SHA-256: `2DFD5804F783442994A582AE34AFB9A016ADA38850DB4140A3E3B8FE220B8EA0`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.55 Runtime Error Forensic Report

## Evidence source

- Console: `[LOCAL_PATH_REDACTED]`
- Size: 3,695,944 bytes
- Lines containing `ERROR`: 1,745
- `WarThunderVehicleLibrary` hits: 3,490
- XNP log hits: 3
- `Lua((MOD:XNP` stack hits: 0

The repeating stack is `Lua((MOD:WarThunderVehicleLibrary)).helicopterVisualSoundUpdate(HeliSoundUpdate.lua:69)`. It is third-party evidence and was not edited or suppressed by this source.

The three XNP lines are normal status/summary output: Adrenaline READY, Sprint Fail Summary, and Log Throttle Summary. No XNP Lua exception stack was found.

## Conclusion

- `XNP_RUNTIME_ERROR_IN_LATEST_CONSOLE=NOT_FOUND`
- `THIRD_PARTY_WARTHUNDER_ERROR_STORM=CONFIRMED`
- The third-party storm can affect frame time and perceived FPS.
- Runtime behavior after installing 0.5.55 is `NOT_VERIFIABLE_BY_STATIC_AUDIT`.

```

## 0.5.55_GREEN_SKILL_PLACEHOLDER_REPORT.md

- SHA-256: `2AAC993005F39EDBA3593D734AB1C8F630CF721BD89A1C66AA9228660B595B6C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Green Skill Placeholder Report

- Compatibility full ID: `XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage`
- English name: `Green Skill Trigger`
- Chinese name: `\u7eff\u8272\u6280\u80fd`
- Independent asset: `trait_xnpgreenskill.png`
- Dimensions: 18 x 18, `Format32bppArgb`
- SHA256: `9E2B1E532F9DA4243EC3874A9B0AF4DF2C7AF7CBD9AEFDFD6DE072AAF3D0EFD9`
- Position key: `XNP_UI_GREEN_SKILL_POS`

Right-click calls exactly `XNPGreenSkill.RequestActivate(player)`. The placeholder applies no damage, scans, handlers, status changes, or other gameplay effects. Its only output is the throttled line `[XNP GREEN SKILL] clicked=true implemented=false`.

- `GREEN_SKILL_GAMEPLAY_IMPLEMENTED=NO`
- `BLUE_BOMB_INHERITED=NO`

```

## 0.5.55_OLD_FOUR_ICON_SYSTEM_REMOVAL_REPORT.md

- SHA-256: `416AD7325F9CFD533EF11600E9846E61B43F8F87F972F33CC4D606793B8BA1DB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Old Four-Icon System Removal Report

Removed from the new source only:

- `XNP_DR_FourTraitUI.lua`
- `XNP_DR_BlueEcoBarrage.lua`
- `XNP_DR_BlueEcoBarrageRecipe.lua`
- `XNP_DR_FeastGuardian.lua`
- `XNP_DR_DraggableStatusIcon.lua`
- `XNP_DR_StatusIconPosition.lua`
- `XNP_DR_StatusIconInputBindingGuard.lua`
- Blue bomb item/recipe script and texture
- Old blue/red trait icon textures
- Old blue/Feast sandbox options and translations

Runtime grep counts are zero for `BlueEcoBarrageBomb`, `MakeBlueEcoBarrageBomb`, `XNP_DR_FeastGuardian`, `XNP_DR_FourTraitUI`, old blue/red position keys, and old icon texture names.

The string `XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage` remains intentionally as the frozen compatibility full ID for the renamed Green Skill Trigger. It grants no bomb recipe and has no old blue runtime.

- `OLD_BLUE_PANEL_COUNT=0`
- `OLD_RED_PANEL_COUNT=0`
- `BLUE_BOMB_RUNTIME_ENABLED=NO`
- `OLD_FEAST_RUNTIME_ENABLED=NO`

```

## 0.5.55_PERFORMANCE_AND_EVENT_BUDGET_REPORT.md

- SHA-256: `5D26740BFD88A74FDDA64C77F6112535109DE25E7FB089E68073C66B7F553C3C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Performance And Event Budget Report

| Event / route | [IP_REDACTED] baseline | 0.5.55 |
|---|---:|---:|
| `Events.OnTick.Add` | 0 | 0 |
| `Events.OnPlayerUpdate.Add` | 1 | 1 |
| Red/Feast 1Hz food poll | 1 old route | 0 |
| Red fracture event | 0 | 1 `Events.EveryHours` |
| Green continuous handler | 0 | 0 |

`FullFatal` and `ReadSnapshot` are absent. The new green action is click-only. Red context work is inventory-event-only and fracture work is hourly. UI panels are singletons and do not create panels, load textures, or log every frame.

The latest console contains a large third-party `WarThunderVehicleLibrary` error storm; it can independently affect performance and must not be attributed to XNP without a matching XNP stack.

- `PERFORMANCE_STATIC_GATE=PASS`
- Runtime FPS: `NOT_VERIFIABLE_BY_STATIC_AUDIT`

```

## 0.5.55_PHOENIX_ICON_STATE_MACHINE_REPORT.md

- SHA-256: `2C94833325E21DEA4A869F6C2E05833C122DEDB7D0F1DD388F36253A88B8D3DD`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Phoenix Icon State Machine Report

The panel is a singleton. Visibility is derived from the existing Phoenix state without changing revival gameplay:

| State | Panel |
|---|---|
| READY | visible, original texture |
| manually OFF | visible, dimmed by alpha only |
| INVULNERABLE / triggered | hidden |
| COOLDOWN | hidden |
| WAITING_FOR_CALM | hidden |
| READY after recovery | visible again |

Right-click calls only `PurplePhoenixState.Toggle`, whose persisted field is `XNP_DR_PHOENIX_ENABLED`. Cooldown, trigger, and invulnerability state are not modified by the UI.

- `PHOENIX_PANEL_SINGLETON=YES`
- `VISIBLE_DOES_NOT_MEAN_GAMEPLAY_SUCCESS=ACKNOWLEDGED`
- In-game state transitions: `NOT_VERIFIABLE_BY_STATIC_AUDIT`

```

## 0.5.55_PHOENIX_ORIGINAL_ICON_RESTORE_REPORT.md

- SHA-256: `C54BFE7FDA2F62214197520884C2FC6BC59A76E7D48DD7CA6EE83EF34629E75F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Phoenix Original Icon Restore Report

- Source: `[LOCAL_PATH_REDACTED]`
- Destination: `42\media\ui\Traits\trait_xnppurplephoenix.png`
- Dimensions: 16 x 16
- Pixel format: `Format32bppArgb`
- SHA256: `55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21`

The texture is drawn at native size with white RGB factors. No yellow mask, palette tint, or 18 x 18 resize is used.

- Position key: `XNP_UI_PHOENIX_POS`
- Toggle key: `XNP_DR_PHOENIX_ENABLED`
- `PHOENIX_ORIGINAL_ASSET_RESTORED=YES`

```

## 0.5.55_RED_CONSUMABLE_B42_API_EVIDENCE.md

- SHA-256: `C03C5A9615949E927FA6C6850CC5EA2AA61E64BB204B5491014B5D2E173170E2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Red Consumable B42 API Evidence

Local Build 42 root inspected read-only: `[LOCAL_PATH_REDACTED]`.

JAR inspection confirmed these public methods:

- `BodyDamage:getBodyParts()`
- `BodyDamage:setInfected(boolean)`
- `BodyDamage:setInfectionTime(float)`
- `BodyDamage:setIsFakeInfected(boolean)`
- `BodyPart:SetInfected(boolean)`
- `BodyPart:SetFakeInfected(boolean)`
- `BodyPart:getFractureTime()` / `setFractureTime(float)`
- `BodyPart:setInfectedWound(boolean)`
- `BodyPart:setWoundInfectionLevel(float)`
- `InventoryItem:getFullType()`, `getContainer()`, `Remove()`
- `ItemContainer:AddItem(String)`

Local Lua evidence:

- Inventory context event: `media\lua\client\DebugUIs\ISRemoveItemTool.lua:372`
- TimedAction derive/complete: `media\lua\shared\Farming\TimedActions\ISFertilizeAction.lua:3` and `:59`
- Eat animation: `media\lua\shared\TimedActions\ISEatFoodAction.lua:121`
- Normal item syntax: `media\scripts\generated\items\normal.txt:6`
- Item removal: `media\lua\shared\Items\OnBreak.lua:46`

Recipe ingredient IDs were verified in generated scripts:

- `Base.Bandage`: `normal.txt:8054`
- `Base.RippedSheets`: `normal.txt:10633`
- `Base.AlcoholWipes`: `drainable.txt:1506`

All optional/dangerous calls in the red runtime are guarded through `pcall` and emit a `BLOCKED_SUBFEATURE ... SAFE_SKIP=true` line when unavailable.

```

## 0.5.55_RED_CONSUMABLE_ITEM_REPORT.md

- SHA-256: `02DCF4DB38E800A21B65E22ECA8ADD79E8644461D8E7F0C2CDB4CB6A8873C2F3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Red Consumable Item Report

- FullType: `XNP_PZ_DistanceRunner.RedGuardianMark`
- English: `Red Guardian Mark`
- Chinese: `\u7ea2\u8272\u5b88\u62a4\u6807`
- Item type: `base:normal`
- Food: no
- Drainable: no
- Texture: `Item_XNPRedGuardianMark.png`, 32 x 32, `Format32bppArgb`
- Texture SHA256: `F99DD3FF8E7D46A8F6D2EF22666DB3D1E51344BBFAC352358361EE3CC802274C`

The inventory context menu queues `XNPRedGuardianConsumeAction`. An interrupted action only clears job progress. The complete action attempts the effect and removes exactly the selected whole item only after successful application.

On success it safely attempts to clear body/part infection, zombification state, fake infection, infected wound, and wound infection level. It refreshes one nonstacking 24-game-hour fracture recovery window at 3x total recovery. The hourly handler writes only body parts whose current fracture time is above zero.

- `PER_FRAME_FRACTURE_WRITE=NO`
- `LEGACY_FEAST_TRAIT_REQUIRED=NO`
- `MP_STATUS=MP_NOT_VERIFIED`
- Actual cure and recovery behavior: `NOT_VERIFIABLE_BY_STATIC_AUDIT`

```

## 0.5.55_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `DE009583FFD03E6F96F65843E7DF18DB95746A87C4C87D2842FF3C3317139DD4`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.55 Runtime Preservation Report

Preserved from the [IP_REDACTED] baseline:

- Distance Runner native trait full ID and object-based detector
- Distance Runner stamina, impact, food, melee, and scheduler modules
- Phoenix native trait full ID, revival, protection, invulnerability, cooldown, and object-based detector
- One existing `OnPlayerUpdate` registration
- Mod ID `XNP_PZ_DistanceRunnerTrait`

Changed only at the feature boundary:

- Yellow/Phoenix presentation replaced by native original-asset panels.
- Blue gameplay replaced by a no-effect Green Skill compatibility trait.
- Feast trait/runtime replaced by an all-player Red Guardian inventory item.

No old SOURCE was edited. No game, Steam, user mods, saves, Workshop, or Project Zomboid installation path was written.

- `DISTANCE_RUNNER_CORE_PRESERVED=YES_STATIC`
- `PHOENIX_CORE_PRESERVED=YES_STATIC`
- Real gameplay regression test: `NOT_VERIFIABLE_BY_STATIC_AUDIT`

```

## 0.5.55_STARTER_ITEM_ONCE_ONLY_REPORT.md

- SHA-256: `D498E8D521B43453EF5A9AABD69A95E6C20EAE1952A7DE851A69432EE51A14EA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Starter Item Once-Only Report

- Once key: `XNP_RED_GUARDIAN_STARTER_GRANTED_0555`
- Requested count: exactly 3
- Eligibility: every player, no trait requirement
- Entry points: `OnGameStart` and `OnCreatePlayer`

The first successful grant adds three `XNP_PZ_DistanceRunner.RedGuardianMark` items and then stores the key. Later entry calls return without adding items. A partial AddItem failure removes items added during that attempt and leaves the once key unset, allowing a clean retry rather than duplicating a partial grant.

- `STARTER_GRANT_IDEMPOTENT_BY_MODDATA=YES`
- `STARTER_COUNT=3`
- In-game persistence: `NOT_VERIFIABLE_BY_STATIC_AUDIT`

```

## 0.5.55_THREE_ICON_UI_REPORT.md

- SHA-256: `7EAC3A5551201B4BA59C802DB63BBBEFA3F8926EA523815577217AE6630E9143`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Three-Icon UI Report

Final trait icon assets:

1. Yellow Distance Runner: 18 x 18 original asset.
2. Purple Phoenix: 16 x 16 original asset.
3. Green Skill: 18 x 18 independent asset.

There are exactly three PNG files under `42\media\ui\Traits`. Blue and red panel counts are zero. Red Guardian is an inventory texture, not a status panel.

Each icon has its own singleton panel, drag state, saved position table, and right-click target. No position table is shared. Texture loading is attempted once per panel rather than per update.

- `YELLOW_ICON_COUNT=1`
- `PHOENIX_ICON_COUNT=1`
- `GREEN_ICON_COUNT=1`
- `BLUE_ICON_COUNT=0`
- `RED_ICON_COUNT=0`
- `ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED`
- `MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED`
- `HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET`
- `COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET`

```

## 0.5.55_YELLOW_ORIGINAL_ICON_RESTORE_REPORT.md

- SHA-256: `ADF9678B9E9887F272E52DB6EC1AAC64D6835BDAB2262E0B135318EAE3075352`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.55 Yellow Original Icon Restore Report

- Source: `[LOCAL_PATH_REDACTED]`
- Destination: `42\media\ui\Traits\trait_xnpdistancerunner.png`
- Dimensions: 18 x 18
- Pixel format: `Format32bppArgb`
- SHA256: `8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9`

`XNP_DR_StatusIconUI.lua` draws the complete texture at its native 18 x 18 size with RGBA factors `1,1,1,1`. It does not load a moodle mask, tint the icon, crop it, or shake it. The singleton panel remains visible when yellow gameplay is manually disabled.

- Position key: `XNP_UI_YELLOW_POS`
- Toggle key owned by the existing toggle module: `XNP_DR_YELLOW_ENABLED`
- `YELLOW_ORIGINAL_ASSET_RESTORED=YES`

```
