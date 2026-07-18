# 0.5.57 Sanitized Evidence Excerpts

## 0.5.57_CENTER_GLYPH_LOCK_REPORT.md

- SHA-256: `D0C61101450AF3F146F3D8106D8CFBD3A62416C175AD4ECDD328617DF4956B0F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Center Glyph Lock Report

The four command-package PNG entries were extracted byte-for-byte into `42/media/ui/XNPMarkers`. No redraw, recolor, crop, source-file resize, alpha rewrite, or replacement was performed.

| Center | Runtime path | Dimensions | Bytes | SHA256 |
|---|---|---:|---:|---|
| Yellow | `media/ui/XNPMarkers/xnp_marker_yellow.png` | 16x16 | 1460 | `12029EB6F39F046FA15A0C4663FBF33E985245553FB524902EC045E1E64132D6` |
| Purple | `media/ui/XNPMarkers/xnp_marker_purple.png` | 16x16 | 1491 | `55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21` |
| Green | `media/ui/XNPMarkers/xnp_marker_green.png` | 16x16 | 1482 | `C9B5A7ED5C04FE2C4A3FC49845FE9D4303A497DAC8A8D4EA2C8D6FA64EE2481F` |
| Red | `media/ui/XNPMarkers/xnp_marker_red.png` | 16x16 | 1497 | `00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3` |

Runtime composition draws the center at `(8,8)` with size `16x16` and RGBA `(1,1,1,1)`. Color is applied only to the 32x32 outer shell. No source rectangle or cropped UV operation exists.

CENTER_RUNTIME_TINT=NO

CENTER_CROP=NO

CENTER_SOURCE_RESIZE=NO

LOCKED_HASH_MATCH_COUNT=4

```

## 0.5.57_COMPONENT_PROVENANCE_MAP.md

- SHA-256: `16E3F3DCFA0E7F28F569FB0790808186A0810A57CB466A0EDA41620FA5A0AC8D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Component Provenance Map

SOURCE=`[LOCAL_PATH_REDACTED]`

BUILD_MARKER=`XNP_PZ_DISTANCE_TRAIT_0557_EVIDENCE_BASED_ROUND_STATUS_RESTORE_A`

| Recovered component | Source version | Evidence and adaptation in 0.5.57 |
|---|---|---|
| Round chassis | 0.4.15 | Reported successful Moodle-style circular slot. Reimplemented with native `_Moodles_BGsolid.png` and `_Moodles_BGoutline.png`. |
| Top-right anchor | 0.4.17 | Dynamic top-right/overlap work passed. Adapted to four fixed, non-overlapping right-index slots. |
| Drag and viewport clamp | 0.5.49 | Console/source evidence confirms dragging. Reused as direct per-panel capture with viewport clamp and independent persistence. |
| Yellow state colors | 0.5.50 | Existing endurance band fields provide deterministic green/blue/yellow/red states. No claim of complete 0.5.50 visual success is made. |
| Phoenix lifecycle | 0.5.56 | Fatal interception, invulnerability, seven-day cooldown, dynamic recovery, and READY state route are preserved from the audited baseline. |
| Gameplay/runtime baseline | 0.5.56 | Copied once to the new SOURCE, then UI components were replaced without modifying the baseline directory. |

ROUND_CHASSIS_SOURCE_VERSION=0.4.15

TOP_RIGHT_ANCHOR_SOURCE_VERSION=0.4.17

DRAG_CLAMP_SOURCE_VERSION=0.5.49

YELLOW_STATE_COLOR_SOURCE_VERSION=0.5.50

PHOENIX_LIFECYCLE_SOURCE_VERSION=0.5.56

No complete older version was treated as a visually proven final implementation.

```

## 0.5.57_COMPONENT_PROVENANCE_MAP.md

- SHA-256: `CA2F28C72584B0033833F824AF89FAF3CDF83D61B8D92669DC78AF45C48B0A68`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Component Provenance Map

All selected sources below were inspected in the named SOURCE directories. A selected local component does not promote its whole source version above the rating in `0.5.57_HISTORIC_UI_VERSION_EVIDENCE_MATRIX.md`.

## 1. Round Chassis

```text
COMPONENT=ROUND_CHASSIS
SELECTED_SOURCE_VERSION=0.4.15
SELECTED_SOURCE_PATH=[LOCAL_PATH_REDACTED]
SELECTED_SOURCE_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActiveStatusIcon.lua
SELECTED_SOURCE_FUNCTION=StatusIconPanel:prerender; StatusIconPanel:render
SELECTED_SOURCE_LINE_OR_UNIQUE_SNIPPET=line 95 function StatusIconPanel:prerender(); line 103 function StatusIconPanel:render()
SELECTED_EVIDENCE=The render route loads and composes native _Moodles_BGsolid.png and _Moodles_BGoutline.png around the center texture.
SELECTED_REASON=This is the earliest inspected concrete native round Moodle chassis implementation.
REJECTED_CANDIDATES=0.5.56 XNP_DR_VanillaMarkerFrame.DrawBackground/DrawBorder; 0.5.55 trait-only panels
REJECTION_REASONS=0.5.56 uses a square frame composition; 0.5.55 has no native round chassis.
CURRENT_0.5.57_TARGET_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame.lua
CURRENT_0.5.57_TARGET_FUNCTION=Frame.Draw
CURRENT_IMPLEMENTATION_MATCH=true; native round background/outline composition retained
NEW_GLUE_CODE_PRESENT=true
NEW_GLUE_CODE_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame.lua
NEW_GLUE_CODE_FUNCTION=Frame.Draw
NEW_GLUE_CODE_PURPOSE=Centralize one round-frame renderer for four independent panels.
NEW_GLUE_CODE_DOES_NOT_REWRITE_COMPONENT=true
```

## 2. Top-Right Anchor

```text
COMPONENT=TOP_RIGHT_ANCHOR
SELECTED_SOURCE_VERSION=0.4.17
SELECTED_SOURCE_PATH=[LOCAL_PATH_REDACTED]
SELECTED_SOURCE_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActiveStatusIcon.lua
SELECTED_SOURCE_FUNCTION=layoutForSlot; selectCompanionLayout
SELECTED_SOURCE_LINE_OR_UNIQUE_SNIPPET=line 144 local function layoutForSlot(slot); line 155 local function selectCompanionLayout(player)
SELECTED_EVIDENCE=The functions calculate a right-edge slot and select a non-overlapping companion layout.
SELECTED_REASON=It supplies concrete top-right placement and slot ordering instead of a fixed arbitrary screen coordinate.
REJECTED_CANDIDATES=0.4.16 fixed companion offset; 0.5.54 multi-panel placement
REJECTION_REASONS=0.4.16 has reported overlap; 0.5.54 has negative UI/performance evidence.
CURRENT_0.5.57_TARGET_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame.lua
CURRENT_0.5.57_TARGET_FUNCTION=Frame.DefaultPosition
CURRENT_IMPLEMENTATION_MATCH=true; right-edge indexed placement is retained
NEW_GLUE_CODE_PRESENT=true
NEW_GLUE_CODE_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame.lua
NEW_GLUE_CODE_FUNCTION=Frame.DefaultPosition
NEW_GLUE_CODE_PURPOSE=Convert the historical single/companion slot into four deterministic right-edge slots.
NEW_GLUE_CODE_DOES_NOT_REWRITE_COMPONENT=true
```

## 3. D
[EXCERPT_TRUNCATED]
```

## 0.5.57_FOUR_PANEL_LAYOUT_REPORT.md

- SHA-256: `A2202490D0FA95610B0E62DF350DF92673364A1E5AA9A17861CF1DF52C55D316`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Four Panel Layout Report

All panels are independent 32x32 ISPanel singletons. Defaults are computed from the current Project Zomboid viewport, never desktop coordinates.

At viewport width `W`, height `H`, panel size 32, gap 4, right margin 8, and Y=76:

| Panel | Right index | Default X | Position key |
|---|---:|---:|---|
| Yellow | 3 | `W - 148` | `XNP_UI_YELLOW_ROUND_POS_0557` |
| Purple | 2 | `W - 112` | `XNP_UI_PHOENIX_ROUND_POS_0557` |
| Green | 1 | `W - 76` | `XNP_UI_GREEN_ROUND_POS_0557` |
| Red | 0 | `W - 40` | `XNP_UI_RED_ROUND_POS_0557` |

Adjacent panels have a four-pixel gap. Every move clamps X to `0..W-32` and Y to `0..H-32`.

Each module owns its own drag flag, right-click arming flag, player reference, state, panel class, and new persistence key. Old position keys are read only. A valid old coordinate is copied into the new key; an invalid/out-of-viewport old coordinate falls back to the default. No old ModData key is deleted or rewritten.

PANEL_COUNT=4

DEFAULT_OVERLAP_COUNT=0

VIEWPORT_CLAMP=YES

INDEPENDENT_RIGHT_CLICK=YES

GLOBAL_MASTER_CALLS_FROM_PANELS=0

```

## 0.5.57_GREEN_RED_STATE_REPORT.md

- SHA-256: `70D7D3AF40D08ABBFC21E38BF25B90CC4D3CAF8710E5DDB24166FA89978085D9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Green And Red State Report

## Green

- State key: `XNP_DR_GREEN_ENABLED`, independent in player ModData.
- Default: enabled.
- WHITE: manually disabled.
- GREEN: enabled.
- Right-click toggles only the green marker state.
- `gameplay_implemented=false`; no lightning, damage, cooldown, or continuous gameplay handler was added.

## Red

- WHITE: complete-item inventory count is zero.
- GREEN: count is at least one.
- Inventory source remains `RedGuardianMark.GetInventorySnapshot`.
- Right-click remains `RedGuardianMark.QueueConsumeOne`, consuming one complete mark through the existing route.
- Inventory scan interval is 500 ms maximum (2 Hz), with event-driven dirty refresh.
- Starter quantity remains 3 in the preserved red guardian route.
- Partial consumption is not introduced.
- Central game-hour fracture scheduler and the [IP_REDACTED] final-interval correction remain unchanged.

GREEN_GAMEPLAY_IMPLEMENTED=NO

GREEN_LIGHTNING_PRESENT=NO

RED_WHOLE_ITEM_CONSUMPTION=YES

RED_STARTER_COUNT=3

RED_FRACTURE_REPAIR_PRESERVED=YES

```

## 0.5.57_HISTORIC_UI_VERSION_EVIDENCE_MATRIX.md

- SHA-256: `0ADD7FD0D58896B1BB93DB5F7B2DE04882470943C544662B2EFED5051BD0BFEA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Historic UI Version Evidence Matrix

This matrix separates complete visual success from component-level evidence. A module-load log, a texture-load log, or a panel-created log is not complete visual proof.

| Version | Evidence reviewed | Supported conclusion | Contradiction / limitation | Component eligible for recovery |
|---|---|---|---|---|
| 0.4.14 | Raw icon experiment reports | Runtime route existed | User-visible icon failed | No |
| 0.4.15 | `0.4.15_REAL_GAME_RESULT_AND_FEATURE_TRANSITION.md` | Moodle-style custom slot was reported circular and visible | Does not prove the later four-panel layout | Native round shell only |
| 0.4.16 | Runtime/UI reports | Round texture and tooltip passed | Layout overlapped vanilla UI | Shell evidence only |
| 0.4.17 | Dynamic-slot and overlap reports | Top-right anchoring and overlap avoidance passed | Full-screen panel input risk remained | Anchor logic only |
| 0.4.18 | Runtime reports | Logical state route passed | User did not see the icon | No complete UI recovery |
| 0.5.48 | Source and audit reports | White/off and local panel routes existed | No complete visual-success evidence | State semantics only |
| 0.5.49 | Console evidence and source | Dragging and white master-off state were observed | Not a complete four-marker visual approval | Drag/clamp component |
| 0.5.50 | Source/audit reports | Deterministic endurance color fields existed | No evidence that the complete icon was visually successful | Yellow state-color mapping only |
| 0.5.51 | Purple runtime chain | Phoenix panel/module route existed | No complete purple visual success proof | Lifecycle evidence only |
| 0.5.52 | `PurplePhoenixUI loaded=true`, texture and READY logs | Purple runtime chain reached READY | Load/READY logs do not prove an intact visible icon | Lifecycle evidence only |
| 0.5.54 | Audit and user result | Multi-trait chain persisted | Purple icon was reported missing | No complete UI recovery |
| 0.5.56 | Baseline source and audits | Four independent center assets and gameplay chain persisted | Square-marker presentation was not the requested final result | Runtime/gameplay baseline only |

YELLOW_CONFIRMED_SUCCESS_VERSION=NOT_PROVEN

PURPLE_CONFIRMED_SUCCESS_VERSION=NOT_PROVEN

The 0.5.57 implementation therefore reconstructs the UI from individually evidenced components. It does not copy 0.5.50 or 0.5.52 as a supposedly proven complete visual version.

Latest available console read-only boundary: `[LOCAL_PATH_REDACTED]` contained 6 XNP lines and no XNP error-pattern line. The high-frequency errors were from `WarThunderVehicleLibrary` / `HeliSoundUpdate.lua:69` (1015 matching lines); no third-party file was modified.

```

## 0.5.57_HISTORIC_UI_VERSION_EVIDENCE_MATRIX.md

- SHA-256: `8540BF318418C651DD374B867DFB0A7A384B99A73E90A06439676AE9A59795F6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Historic UI Version Evidence Matrix

Evidence is recorded per version. Runtime/static PASS is not treated as user visual approval. Ratings are limited to `CONFIRMED_SUCCESS`, `PARTIAL_SUCCESS`, `RUNTIME_ONLY`, `VISUAL_FAILURE`, and `UNKNOWN`.

## 0.4.15

```text
VERSION=0.4.15
SOURCE_PATH=[LOCAL_PATH_REDACTED]
SOURCE_EXISTS=true
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0415_MOODLE_FASTMOVE_A
BUILD_MARKER_SOURCE_FILE=42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua:12
UI_ENTRY_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActiveStatusIcon.lua
UI_ENTRY_FUNCTION=StatusIcon.SetVisible
UI_REQUIRE_CALLER_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua:4
UI_REQUIRE_CALLER_FUNCTION=module_initialization
UI_REQUIRE_CHAIN=Bootstrap require ActiveStatusIcon -> Runtime.Update -> StatusIcon.SetVisible
PANEL_CLASS_OR_TABLE=XNPDistanceRunnerMoodleSlot / StatusIcon
PANEL_CREATE_FUNCTION=ensurePanel
PANEL_CREATE_EVENT=Events.OnPlayerUpdate -> Runtime.Update -> StatusIcon.SetVisible
STATE_UPDATE_FUNCTION=StatusIcon.SetVisible
DRAW_FUNCTION=StatusIconPanel:prerender; StatusIconPanel:render
TEXTURE_PATHS=media/ui/Moodles/32/_Moodles_BGsolid.png; media/ui/Moodles/32/_Moodles_BGoutline.png; media/ui/Traits/trait_xnpdistancerunner.png
ROUND_CHASSIS_PRESENT=true
SQUARE_TRAIT_FRAME_PRESENT=false
TOP_RIGHT_ANCHOR_PRESENT=true
DRAG_PRESENT=false
POSITION_SAVE_KEY=NONE
VIEWPORT_CLAMP_PRESENT=false
WHITE_STATE_PRESENT=false
GREEN_STATE_PRESENT=false
BLUE_STATE_PRESENT=false
YELLOW_STATE_PRESENT=false
RED_STATE_PRESENT=false
PHOENIX_READY_PRESENT=false
PHOENIX_TRIGGER_HIDE_PRESENT=false
PHOENIX_COOLDOWN_HIDE_PRESENT=false
RUNTIME_LOG_EVIDENCE=0.4.15_REAL_GAME_RESULT_AND_FEATURE_TRANSITION.md records icon creation/draw/style PASS
USER_POSITIVE_FEEDBACK=STATUS_ICON_VISUAL_STYLE=PASS; STATUS_ICON_DRAW=PASS
USER_NEGATIVE_FEEDBACK=NONE_FOUND_FOR_STATUS_ICON
CONTRADICTORY_EVIDENCE=Fast-move world-speed route failed, but that is not a status-icon visual contradiction
RATING=PARTIAL_SUCCESS
RATING_REASON=Single circular Moodle-style icon was user-observed as visually successful; later four-panel/state requirements did not exist
EXCLUSION_REASON=NOT_A_FOUR_PANEL_OR_FIVE_COLOR_IMPLEMENTATION
```

## 0.4.16

```text
VERSION=0.4.16
SOURCE_PATH=[LOCAL_PATH_REDACTED]
SOURCE_EXISTS=true
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0416_PASSIVE_RUNNER_SHOVE_A
BUILD_MARKER_SOURCE_FILE=42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua:12
UI_ENTRY_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActiveStatusIcon.lua
UI_ENTRY_FUNCTION=StatusIcon.SetVisible
UI_REQUIRE_CALLER_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua:4
UI_REQUIRE_CALLER_FUNCTION=module_initialization
UI_REQUIRE_CHAIN=Bootstrap require ActiveStatusIcon -> Runtime.Update -> StatusIcon.SetVisible
PANEL_CLASS_OR_TABLE=XNPDistanceRunnerMoodleSlot / StatusIcon
PANEL_CREATE_FUNCTION=ensurePanel
PANEL_CREATE_EVENT=Events.OnPlayerUpdate -> Runtime.Update
STATE_U
[EXCERPT_TRUNCATED]
```

## 0.5.57_HISTORIC_UI_VERSION_EVIDENCE_MATRIX.md

- SHA-256: `FD15ED1BFF8F629907B0934F00D75C97ACF78AFADFF28754EF3E4973F4DA89FE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Historic UI Version Evidence Matrix

Evidence is recorded per version. Runtime/static PASS is not treated as user visual approval. Ratings are limited to `CONFIRMED_SUCCESS`, `PARTIAL_SUCCESS`, `RUNTIME_ONLY`, `VISUAL_FAILURE`, and `UNKNOWN`.

## 0.4.15

```text
VERSION=0.4.15
SOURCE_PATH=[LOCAL_PATH_REDACTED]
SOURCE_EXISTS=true
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0415_MOODLE_FASTMOVE_A
BUILD_MARKER_SOURCE_FILE=42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua:12
BUILD_MARKER_SOURCE_LINE_OR_UNIQUE_SNIPPET=line 12: BUILD_ID = "XNP_PZ_DISTANCE_TRAIT_0415_MOODLE_FASTMOVE_A",
UI_ENTRY_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActiveStatusIcon.lua
UI_ENTRY_FUNCTION=StatusIcon.SetVisible
UI_REQUIRE_CALLER_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua:4
UI_REQUIRE_CALLER_FUNCTION=module_initialization
UI_REQUIRE_CHAIN=Bootstrap require ActiveStatusIcon -> Runtime.Update -> StatusIcon.SetVisible
PANEL_CLASS_OR_TABLE=XNPDistanceRunnerMoodleSlot / StatusIcon
PANEL_CREATE_FUNCTION=ensurePanel
PANEL_CREATE_EVENT=Events.OnPlayerUpdate -> Runtime.Update -> StatusIcon.SetVisible
STATE_UPDATE_FUNCTION=StatusIcon.SetVisible
DRAW_FUNCTION=StatusIconPanel:prerender; StatusIconPanel:render
TEXTURE_PATHS=media/ui/Moodles/32/_Moodles_BGsolid.png; media/ui/Moodles/32/_Moodles_BGoutline.png; media/ui/Traits/trait_xnpdistancerunner.png
ROUND_CHASSIS_PRESENT=true
SQUARE_TRAIT_FRAME_PRESENT=false
TOP_RIGHT_ANCHOR_PRESENT=true
DRAG_PRESENT=false
POSITION_SAVE_KEY=NONE
VIEWPORT_CLAMP_PRESENT=false
WHITE_STATE_PRESENT=false
GREEN_STATE_PRESENT=false
BLUE_STATE_PRESENT=false
YELLOW_STATE_PRESENT=false
RED_STATE_PRESENT=false
PHOENIX_READY_PRESENT=false
PHOENIX_TRIGGER_HIDE_PRESENT=false
PHOENIX_COOLDOWN_HIDE_PRESENT=false
RUNTIME_LOG_EVIDENCE=0.4.15_REAL_GAME_RESULT_AND_FEATURE_TRANSITION.md records icon creation/draw/style PASS
USER_POSITIVE_FEEDBACK=STATUS_ICON_VISUAL_STYLE=PASS; STATUS_ICON_DRAW=PASS
USER_NEGATIVE_FEEDBACK=NONE_FOUND_FOR_STATUS_ICON
CONTRADICTORY_EVIDENCE=Fast-move world-speed route failed, but that is not a status-icon visual contradiction
RATING=PARTIAL_SUCCESS
RATING_REASON=Single circular Moodle-style icon was user-observed as visually successful; later four-panel/state requirements did not exist
EXCLUSION_REASON=NOT_A_FOUR_PANEL_OR_FIVE_COLOR_IMPLEMENTATION
```

## 0.4.16

```text
VERSION=0.4.16
SOURCE_PATH=[LOCAL_PATH_REDACTED]
SOURCE_EXISTS=true
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0416_PASSIVE_RUNNER_SHOVE_A
BUILD_MARKER_SOURCE_FILE=42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua:12
BUILD_MARKER_SOURCE_LINE_OR_UNIQUE_SNIPPET=line 12: BUILD_ID = "XNP_PZ_DISTANCE_TRAIT_0416_PASSIVE_RUNNER_SHOVE_A",
UI_ENTRY_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActiveStatusIcon.lua
UI_ENTRY_FUNCTION=StatusIcon.SetVisible
UI_REQUIRE_CALLER_FILE=42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua:4
UI_REQUIRE_CALLER_FUNCTION=module_initialization
UI_REQUIRE_CHAIN=Bootstrap r
[EXCERPT_TRUNCATED]
```

## 0.5.57_PERFORMANCE_AND_EVENT_BUDGET_REPORT.md

- SHA-256: `3F08F32F1AD5D0B873C4045F5E715103E1F9C083A804A1EAA3D6DEA7B4F546FE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Performance And Event Budget Report

Static comparison against the untouched 0.5.56 baseline:

| Metric | 0.5.56 | 0.5.57 | Result |
|---|---:|---:|---|
| `Events.OnTick.Add` | 0 | 0 | unchanged |
| `Events.OnPlayerUpdate.Add` | 1 | 1 | unchanged |
| All `Events.*.Add` sites | 13 | 13 | unchanged |

- Four UI state refreshes are bounded by the existing scheduler and local 250 ms gates (maximum 4 Hz).
- Red inventory refresh is bounded at 500 ms (maximum 2 Hz).
- Red's duplicate scheduled UI call was removed; its trait-independent low-frequency Runtime call remains.
- Center and shell textures are attempted once per module/helper, never per render frame.
- Each panel is created once and reused.
- Green has no continuous gameplay handler.
- State logs are change-driven; no idle per-frame UI log was added.
- No event registration was added by the new round frame or state mapper.

ON_TICK_ADD_COUNT=0

ON_PLAYER_UPDATE_ADD_COUNT=1

UI_MAX_HZ=4

RED_INVENTORY_MAX_HZ=2

NEW_EVENT_REGISTRATION_COUNT=0

```

## 0.5.57_PHOENIX_30_PERCENT_VISIBILITY_REPORT.md

- SHA-256: `42708F5C3DE3C456E12EC567A44217315C79D6194B02FF2E3191203F3AFABF4A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Phoenix 30 Percent Visibility Report

Default trigger threshold is aligned in both configuration sources:

- `XNP_DR_PurplePhoenix_Constants.lua`: `TRIGGER_MAIN_DEFAULT = 0.30`
- `sandbox-options.txt`: `PhoenixTriggerHealthPercent default = 30`
- CN/EN sandbox tooltips both state 30%.

The fatal interception route remains in `XNP_DR_PurplePhoenixRevive.lua`: projected damage can cross the configured threshold before engine death is committed. Recovery is verified before cooldown is committed. No death flag is cleared after finalized death.

Visibility mapping:

| Lifecycle state | Outer shell | Panel visibility |
|---|---|---|
| Manual OFF | WHITE | visible, so right-click can re-enable |
| READY | GREEN | visible |
| INVULNERABLE | n/a | hidden |
| COOLDOWN / waiting recovery | n/a | hidden |

`PurplePhoenixState.UpdateRecovery` and invulnerability updates remain in Runtime independently of panel visibility. Hiding the panel does not stop cooldown or dynamic recovery. When `GetRecharge` returns READY, the next <=4 Hz UI update shows the green panel again.

BASE_COOLDOWN_DAYS=7

DYNAMIC_RECOVERY_ROUTE_PRESERVED=YES

FATAL_INTERCEPTION_ROUTE_PRESERVED=YES

PHOENIX_DEFAULT_TRIGGER_PERCENT=30

```

## 0.5.57_ROUND_CHASSIS_SELECTION_REPORT.md

- SHA-256: `A4811C3622060207AA7BA91252F8C820E14D8151D8E3A45B729250B2F0DEA6C8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.57 Round Chassis Selection Report

Selected chassis: Project Zomboid's native 32px Moodle shell, recovered from the 0.4.15 component route.

- Solid runtime texture: `media/ui/Moodles/32/_Moodles_BGsolid.png`
- Outline runtime texture: `media/ui/Moodles/32/_Moodles_BGoutline.png`
- Installed evidence path: `[LOCAL_PATH_REDACTED]`
- Solid SHA256: `13DB6174B1934EB4E23551835CF666AC4861038B9F597D9443C72345A98ACE28`
- Outline SHA256: `71FF423040B762BB41D9B570EB11675890A5A0D668ABD60E56E3EA1F29E2F2AF`

`XNP_DR_RoundMarkerFrame.lua` loads these textures once, draws a state-colored circular solid, draws the native outline, then draws the complete untinted center. There is no square Trait frame and no rectangular fallback.

The final UI consists of four distinct singleton panel classes, each 32x32. The old `XNP_DR_VanillaMarkerFrame.lua` square helper is absent from the new SOURCE and has no require site.

ROUND_CHASSIS_SOURCE_VERSION=0.4.15

ROUND_CHASSIS_STATIC_EVIDENCE=PASS

REAL_GAME_VISUAL_CONFIRMATION_REQUIRED_BY_USER=true

```

## 0.5.57_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `F2F3CFA9F757996F4FB09565FB6B21AE3BC160C16D490AF5B7464A7632006486`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.57 Runtime Preservation Report

Baseline: `[LOCAL_PATH_REDACTED]`.

The baseline was copied to a new independent SOURCE. The baseline directory was not modified. Changes are limited to UI composition, identity, new position keys, the green marker-only toggle, Phoenix default threshold, and removal of one duplicate red UI call.

Preserved routes:

- Object-based native trait detection and all trait full IDs.
- Distance Runner stamina, food, melee, impact, breakout, drag recovery, and scheduler routes.
- Phoenix projected/fatal interception, verified recovery, invulnerability, seven-day base cooldown, and dynamic recovery.
- Red complete-item consumption, starter count 3, central fracture scheduler, and final-interval repair.
- Runtime `OnPlayerUpdate` count and total event registration count.

Not introduced:

- No global Master call from any of the four panel modules.
- No cross-panel state write.
- No green gameplay, lightning, or persistent action handler.
- No player coordinate, GameTime, third-party mod, user mods, save, Workshop, or game-directory write.

Latest console boundary was read only. `WarThunderVehicleLibrary` / `HeliSoundUpdate.lua:69` errors were classified as third-party and were not modified or attributed to XNP.

OLD_SOURCE_MODIFIED=NO

GAME_DIRECTORY_WRITTEN=NO

PROJECT_ZOMBOID_STARTED=NO

STEAM_STARTED=NO

```
