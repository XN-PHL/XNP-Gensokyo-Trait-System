# 0.5.58 Sanitized Evidence Excerpts

## 0.5.58_B42_MOUSE_CAPTURE_API_EVIDENCE.md

- SHA-256: `A27BB316CB1C7D1B9F8240619EA95D59DF7318185B726F97F92B4563C2AA1DC5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.58 B42 Mouse Capture API Evidence

## JAR evidence

Resource: `[LOCAL_PATH_REDACTED]`

`javap zombie.ui.UIElement` confirms:

- `public void onMouseUpOutside(double, double);`
- `public void onMouseMoveOutside(double, double);`
- `public java.lang.Boolean isCapture();`
- `public void setCapture(boolean);`

## Vanilla Lua evidence

- `media/lua/client/ISUI/ISUIElement.lua:588-599`: `ISUIElement:setCapture` and `getIsCaptured` delegate to the Java object.
- `media/lua/client/ISUI/ISGameSoundVolumeControl.lua:14`: capture begins on mouse down; lines 24-28 release it in `onMouseUpOutside`.
- `media/lua/client/ISUI/ISWindow.lua:29,40-44`: capture plus `onMouseMoveOutside` is used while resizing.
- `media/lua/client/ISUI/ISResizeWidget.lua:51-58,73-82,92`: outside move, outside release, and capture are used together.
- `media/lua/client/PZAPI/ui/atoms/AtomExtensions.lua:27`: global `getMouseX()` and `getMouseY()` are used for pointer history.
- `media/lua/shared/Fishing/FishingUtils.lua:101`: `isMouseButtonDown(0)` is a live B42 input API.
- `media/lua/client/ISUI/Crafting/ISHandcraftWindow.lua:293-296`: `onKeyRelease` with `Keyboard.KEY_ESCAPE` is a live cancellation route.

Implementation uses these verified APIs directly; no new `pcall` hides capture failures.

DRAG_B42_API_VERIFIED=true
GLOBAL_POINTER_API_VERIFIED=true
OUTSIDE_CALLBACKS_VERIFIED=true
ESC_CANCEL_API_VERIFIED=true

```

## 0.5.58_EVENT_AND_PERFORMANCE_BUDGET.md

- SHA-256: `890D42875CC374D024B3D28E02CDBCDF4540A138E269DC62EB4D6C58C411CD30`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.58 Event And Performance Budget

Static event registration scan:

- `Events.OnTick.Add`: 0.
- `Events.OnPlayerUpdate.Add`: 1 (`Core.Runtime.Update`).
- Dragging uses UI mouse callbacks, not gameplay polling.
- Shared drag controller has no event registration.
- Yellow state refresh interval remains 250 ms (maximum 4 Hz).
- Red inventory refresh interval remains 500 ms (maximum 2 Hz).
- Textures are loaded once through existing `textureAttempted` gates.
- Panels are created once through existing `ensurePanel` gates.
- Render has no logging and no random number generation.
- Four independent panels remain; no duplicate or full-screen capture panel was added.

XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT<=1
UI_MAX_REFRESH_HZ=4
UI_MAX_REFRESH_HZ<=4
RED_INVENTORY_CHECK_MAX_HZ=2
RED_INVENTORY_CHECK_MAX_HZ<=2
TEXTURE_LOAD_PER_FRAME=false
PANEL_CREATE_PER_FRAME=false
RENDER_LOG_PER_FRAME=false
RANDOM_SHAKE_GENERATION_PER_FRAME=false
MOUSE_POSITION_POLLING_ONTICK=false
DUPLICATE_PANEL_CREATION_ROUTE_COUNT=0

```

## 0.5.58_FAST_DRAG_TEST_MATRIX.md

- SHA-256: `F2D7DA6EDD64FCAF67188C29DB3C5F1AE42545DA1711D6690B20CE5E9BC73586`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.58 Fast Drag Test Matrix

| Case | Static route | Expected runtime result | Status |
|---|---|---|---|
| A center press, slow 200px exit | Start + capture + moveOutside | Continues following | READY_FOR_USER_TEST |
| B center press, fast 500px jump | Global pointer offset | Jumps to correct retained offset | READY_FOR_USER_TEST |
| C release outside | onMouseUpOutside -> Release | Stops, clamps, saves once | READY_FOR_USER_TEST |
| D drag beyond four edges | Unclamped move, release clamp | Final x/y inside viewport | READY_FOR_USER_TEST |
| E drag yellow only | Single active owner | Purple/green/red unchanged | READY_FOR_USER_TEST |
| F right-click after drag | Existing right handlers retained | Toggle/consume still works | READY_FOR_USER_TEST |
| G ESC/focus-loss/release-loss | Cancel, button-state guard, cleanup | No sticky drag; invalid point not saved | READY_FOR_USER_TEST |
| H reload save | Existing per-marker ModData keys | Released position restored | READY_FOR_USER_TEST |

Kahlua compilation proves callback syntax and module linkage. Actual UI dispatch and pointer feel are `NOT_VERIFIABLE_BY_STATIC_AUDIT` because starting PZ is forbidden.

```

## 0.5.58_FOUR_MARKER_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `5D9B8B1D544127D2B5356127582CC1DE73E4320BC69CE64258E0C589507F8374`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.58 Four Marker Runtime Preservation Report

- The proven [IP_REDACTED] `Frame.Draw` function block is byte-identical in 0.5.58.
- A separate `DrawAtOffset` path was added only for yellow shake.
- Center texture paths remain unchanged and untinted.

| Marker | SHA256 |
|---|---|
| yellow | `12029EB6F39F046FA15A0C4663FBF33E985245553FB524902EC045E1E64132D6` |
| purple | `55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21` |
| green | `C9B5A7ED5C04FE2C4A3FC49845FE9D4303A497DAC8A8D4EA2C8D6FA64EE2481F` |
| red magic HUD | `00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3` |

- Yellow keeps five colors and right-click enable/disable.
- Purple keeps WHITE-visible off, GREEN-ready, and hidden active/cooldown states.
- Green remains WHITE off / GREEN on without implementing the deferred ultimate.
- Red magic keeps panel existence, 0 WHITE, >=1 GREEN, right-click whole-item consume, starter count and fracture timing route.
- Gameplay numeric constants were not changed. New calls publish UI-only transient state after existing successful commits.
- [IP_REDACTED] and all older SOURCE directories were not written.

XNP_ROUND_MARKER_RUNTIME_ERROR_ACTIVE_COUNT=0
WARTHUNDER_ERROR_OWNERSHIP=THIRD_PARTY
WARTHUNDER_FILES_MODIFIED=false

```

## 0.5.58_RED_P_ITEM_ICON_ASSET_LOCK_REPORT.md

- SHA-256: `EBFDC43CB2C679B9EEFEB933AB9CAD06B370582B9A2EF8D214BBC178EDE6B2DF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.58 Red P Item Icon Asset Lock Report

Source lock: `Item_XNPRedMagicP_SOURCE_LOCK.png`

Runtime target: `42/media/textures/Item_XNPRedMagicP.png`

Item script: `42/media/scripts/XNPRedGuardianMarkItems.txt`

- Dimensions: 16x16.
- Source lock and runtime target are byte-for-byte copies.
- No redraw, resize, recolor, frame addition, or re-export was performed.
- Item field is `Icon = XNPRedMagicP`.
- Exact old field `Icon = XNPRedGuardianMark` occurs 0 times.
- Existing HUD center files were not changed; the red marker remains a separate UI asset route.

RED_P_EXPECTED_SHA256=00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3
RED_P_SOURCE_SHA256=00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3
RED_P_DROP_SHA256=00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3
RED_P_PIXEL_MODIFICATION_COUNT=0
RED_P_OLD_GENERATED_ICON_REFERENCE_COUNT=0
RED_MAGIC_ITEM_ICON_FIELD=XNPRedMagicP
RED_P_RUNTIME_TEXTURE_PATH=media/textures/Item_XNPRedMagicP.png

```

## 0.5.58_SHARED_DRAG_CONTROLLER_REPORT.md

- SHA-256: `C14C7B3B5027F5C2B0D0B527084D3B806A47F185842583B6516011E8CE1EAA7E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.58 Shared Drag Controller Report

Implementation: `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerDragController.lua`.

- `Start`: rejects a pointer outside the 32x32 owner panel, cancels any previous owner, stores global-pointer-to-panel offset, and calls `setCapture(true)`.
- `Move`: accepts both normal and outside callbacks and computes panel position from global pointer coordinates. It does not clamp or save during movement.
- `Release`: calls `setCapture(false)`, clamps to viewport, saves the owner panel's independent ModData key once, and clears ownership.
- `Cancel`: releases capture, restores the pre-drag position, does not save, and clears ownership.
- Lost release protection: the next move observes `isMouseButtonDown(0) == false` and cancels. ESC and Runtime cleanup also cancel.
- Four UI modules call the same controller; the single `active` record prevents another marker from moving.
- Right-click handlers are unchanged and remain separate from left-button capture.

DRAG_START_REQUIRES_POINTER_INSIDE=true
DRAG_CONTINUES_OUTSIDE_PANEL=true
DRAG_RELEASE_OUTSIDE_SUPPORTED=true
FAST_POINTER_JUMP_SUPPORTED=true
DRAG_USES_GLOBAL_POINTER_OFFSET=true
DRAG_CAPTURE_CANCEL_SAFE=true
DRAG_SAVE_ONLY_ON_RELEASE=true
NO_FULLSCREEN_TRANSPARENT_CAPTURE_PANEL=true
NO_MOUSE_POLLING_ONTICK=true

```

## 0.5.58_YELLOW_RED_STATE_SIGNAL_MAP.md

- SHA-256: `337D3CA0C11D72AC7DE72E3A650F74D37D7CA76A1E070C38056E1620F88F51A9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.58 Yellow RED State Signal Map

Enabled-state priority is RED, YELLOW, BLUE, GREEN. Manual right-click OFF is an absolute WHITE gate.

| Source | Commit function/site | Real success condition | Hold/exit | Gameplay change |
|---|---|---|---|---|
| BreakoutPush | Update / `visibleAny` | At least one push profile returned visible | Impact pulse 0.60s | No |
| EmergencyBreakout | Perform after `applied > 0` | At least one verified stagger visible | Impact pulse 0.60s | No |
| DragdownDangerBreakout | Perform after `applied > 0` | At least one verified control visible | Impact pulse 0.60s | No |
| PreBiteJogRescue | Trigger after `applied > 0` | At least one rescue target visible | Impact pulse 0.60s | No |
| JogBumpLaunch | Apply result | VerifiedStaggerControl returned visible | Impact pulse 0.60s | No |
| JogFallShockwave | Apply / `visibleCount > 0` | At least one target visible | Impact pulse 0.60s | No |
| FallRecoveryInput | Update / `applied > 0` | At least one recovery target visible | Impact pulse 0.60s | No |
| SprintTripImmunity | sweep / `visibleApplied > 0` | At least one sweep target visible | Impact pulse 0.60s | No |
| ZombieVehicleImpact | ApplyVehicleHit | Verified control returned visible | Impact pulse 0.60s | No |
| Vanilla hunger | YellowRedSignals.Resolve | `getMoodleLevel(MoodleType.HUNGRY) >= 3` | Ends on next <=4Hz UI resolve below 3 | No |
| Highest recovery | LongMigrationStaminaAssist actual write | `SetEnduranceSafe` succeeded in `RED_EXHAUSTED_SUPPORT` | Renewed 0.60s while actual writes occur | No |

`XNP_YELLOW_RED_IMPACT_PULSE` extends only to 0.60 seconds after the latest real success. `XNP_YELLOW_RED_MAX_RECOVERY_ACTIVE` is published only after the highest-band endurance write succeeds.

The previous danger-classification RED route was removed. Adrenaline proximity scanning is deliberately not a RED source because proximity is not an effect commit.

YELLOW_RED_PRIORITY_HIGHEST=true
YELLOW_RED_SUCCESSFUL_IMPACT_PULSE=true
YELLOW_RED_IMPACT_PULSE_SECONDS=0.60
YELLOW_RED_HUNGER_LEVEL_THRESHOLD=3
YELLOW_RED_MAX_RECOVERY_SIGNAL=true
YELLOW_RED_RANDOM_ROUTE_COUNT=0
YELLOW_RED_WORLD_SCAN_ROUTE_COUNT=0
YELLOW_RED_STUCK_ROUTE_COUNT=0
YELLOW_RED_CHANGES_GAMEPLAY=false

```

## 0.5.58_YELLOW_SHAKE_HISTORY_AND_IMPLEMENTATION_REPORT.md

- SHA-256: `F1BD3AC58F473381E5844BCA1C228881CD56669BEDCAB205C54B91FDEA766987`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.58 Yellow Shake History And Implementation Report

## Historical source

Recovered from:

`XNP_PZ_DistanceRunnerTrait_0.5.53.1_B42_FATAL_TIMING_FULL_DIAGNOSTIC_SOURCE/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua:491-552`

Historical profiles restored:

| State | ampX | ampY | speed |
|---|---:|---:|---:|
| BLUE | 1.0 | 0.6 | 0.12 |
| YELLOW | 1.8 | 1.2 | 0.18 |
| RED | 2.8 | 2.0 | 0.26 |

The phase remains deterministic (`sin`/`cos` with `getTimestampMs`), with no per-frame random generation.

## 0.5.58 implementation

- Only `XNP_DR_StatusIconUI.lua` computes a shake offset.
- WHITE/GREEN have no profile and therefore offset 0.
- Dragging forces offset 0.
- `Frame.DrawAtOffset` draws the same shell, outline, and locked center at the offset.
- `Frame.Draw` itself is byte-identical to the [IP_REDACTED] function block.
- The yellow panel x/y, 32x32 hitbox, drag offset and saved ModData position never receive shake values.
- Purple, green and red-magic UI continue to call the original `Frame.Draw`.

YELLOW_SHAKE_ONLY=true
PURPLE_SHAKE_ACTIVE=false
GREEN_SHAKE_ACTIVE=false
RED_MAGIC_SHAKE_ACTIVE=false
SHAKE_CHANGES_DRAW_OFFSET_ONLY=true
SHAKE_CHANGES_PANEL_POSITION=false
SHAKE_DISABLED_WHILE_DRAGGING=true
SHAKE_RANDOM_PER_FRAME=false
YELLOW_BLUE_SHAKE_MAX_PX<=1
YELLOW_YELLOW_SHAKE_MAX_PX<=2
YELLOW_RED_SHAKE_MAX_PX<=3

```

## BUILD_MARKER.txt

- SHA-256: `2F0216D2CB7D664E804CDAED0F0E7A314A2AD7DAD262FB690986DCC3BD0D07F7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0558_DRAG_CAPTURE_YELLOW_SHAKE_RED_STATE_RED_P_ASSET_A

```

## FINAL_REPORT.md

- SHA-256: `679EE40BDF0287AF9BBACA9F3F28C653CD1B4064A0D8181A96F35B1069B9C6EB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.58
INTERNAL=0.5.58-b42-drag-capture-yellow-shake-red-state-red-p-asset-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0558_DRAG_CAPTURE_YELLOW_SHAKE_RED_STATE_RED_P_ASSET_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
DISPLAY_NAME=[0.5.58] XNP Four Round Markers Drag Shake Red State

DRAG_CONTROLLER=SHARED_B42_CAPTURE_GLOBAL_POINTER_OFFSET
DRAG_OUTSIDE_MOVE=true
DRAG_OUTSIDE_RELEASE=true
DRAG_CANCEL_SAFE=true
YELLOW_SHAKE_ONLY=true
YELLOW_SHAKE_DRAW_OFFSET_ONLY=true
YELLOW_RED_REAL_SUCCESS_PULSE_SECONDS=0.60
YELLOW_RED_HUNGRY_LEVEL_THRESHOLD=3
YELLOW_RED_MAX_RECOVERY_REAL_WRITE=true
YELLOW_RED_PROXIMITY_OR_RANDOM_ROUTES=0

RED_P_SHA256=00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3
RED_MAGIC_ITEM_ICON_FIELD=XNPRedMagicP

LUA_FILE_COUNT=83
LUA_TOTAL_LINES=13948
SOURCE_KAHLUA=PASS_83_FAIL_0
DROP_KAHLUA=PASS_83_FAIL_0
SOURCE_RUNTIME_FILE_COUNT=110
DROP_RUNTIME_FILE_COUNT=110
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1

OLD_SOURCE_MODIFIED=false
GAME_DIRECTORY_WRITTEN=false
USER_MODS_WRITTEN=false
SAVES_WRITTEN=false
WORKSHOP_WRITTEN=false
WARTHUNDER_FILES_MODIFIED=false
PZ_STARTED=false
STEAM_STARTED=false

NOT_VERIFIABLE_BY_STATIC_AUDIT=REAL_FAST_DRAG_SHAKE_VISUAL_RED_SIGNAL_AND_RIGHT_CLICK_RUNTIME_BEHAVIOR
BLOCKER=NONE_STATIC

XNP_PZ_0.5.58_DRAG_CAPTURE_YELLOW_SHAKE_RED_STATE_RED_P_READY

```

## 0.5.58_KAHLUA_API_RESOURCE_VALIDATION.md

- SHA-256: `0510C09959E3EEE3425EEB0AB3A269D67178BFCE54E2C85866D8661696BBEE17`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.58 Kahlua API Resource Validation

## Kahlua

- Compiler resource: `[LOCAL_PATH_REDACTED]`
- Entry point: `se.krka.kahlua.luaj.compiler.LuaCompiler.loadis`
- Java runtime: bundled `[LOCAL_PATH_REDACTED]`
- SOURCE: 83 PASS, 0 FAIL.
- DROP: 83 PASS, 0 FAIL.

## API and resources

- `zombie.ui.UIElement`: capture, moveOutside, upOutside methods present.
- Vanilla Lua: capture/outside callbacks and global pointer APIs have active examples.
- `zombie.characters.Moodles.Moodles#getMoodleLevel(MoodleType)` present.
- `MoodleType.HUNGRY` present.
- Require strings: 80 unique, 0 unresolved against mod or B42 Lua roots.
- Vanilla Moodle shell textures both exist.
- Four center textures exist.
- `media/textures/Item_XNPRedMagicP.png` exists and item field resolves by PZ `Item_` naming convention.
- UTF-8 BOM files: 0; empty runtime files: 0; text NULL files: 0.

NOT_VERIFIABLE_BY_STATIC_AUDIT:

- B42 UI event dispatch under real fast pointer motion.
- Visual shake feel and clipping on the user's UI scale.
- Hungry RED transition in a running save.
- Actual gameplay success pulse timing and right-click behavior.

PZ_STARTED=false
STEAM_STARTED=false

```

## 0.5.58_PACKAGE_VALIDATION.md

- SHA-256: `36BFB90F8CAF0448997F4AD6E00E4E10C5E157F8EC3D8B62AFD05FD5350142AD`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.58 Package Validation

SOURCE: `[LOCAL_PATH_REDACTED]`

DROP: `[LOCAL_PATH_REDACTED]`

DROP first level contains exactly:

```text
42
mod.info
poster.png
```

- Reports in DROP: 0.
- Console/evidence logs in DROP: 0.
- Parent wrapper directory inside DROP: 0.
- SOURCE runtime and DROP runtime were compared by relative path and SHA256.

SOURCE_RUNTIME_FILE_COUNT=110
DROP_RUNTIME_FILE_COUNT=110
SOURCE_DROP_FILE_COUNT_MATCH=true
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
MISSING_FROM_DROP=0
EXTRA_IN_DROP=0
DROP_TOP_LEVEL_VALID=true

```
