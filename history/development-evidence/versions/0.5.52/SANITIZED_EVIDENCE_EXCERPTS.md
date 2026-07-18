# 0.5.52 Sanitized Evidence Excerpts

## 0.5.52_0550_RESIDUE_FORENSIC_REPORT.md

- SHA-256: `3A0C1AD456EE57A165A958690B878E8EFE2AD16A9E8623654400A1FA6527B99A`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP 0.5.52 / 0550 Residue Forensic Report

Audit date: 2026-07-13 (Asia/Shanghai)

This was a read-only forensic audit. No mod, game, Steam, save, Workshop, or user configuration file was modified or deleted. This report is the only file created.

## 1. Root Cause

`ROOT_CAUSE=C. WORKSHOP_3762431102_050_COPY`

The surviving 0.5.50 runtime is the local Workshop upload staging copy below:

`[LOCAL_PATH_REDACTED]`

Its `workshop.txt` binds the staging package to Workshop item `3762431102`, and its runtime constants contain the exact 0550 marker seen in the historical game logs. The staging package has 77 files and is byte-identical to the archived 0.5.50 DIRECT_INSTALL package (77 files, zero SHA256 mismatches).

The currently installed user-mod copy is already 0.5.52 and is byte-identical to the 0.5.52 DIRECT_INSTALL package (85 files, zero SHA256 mismatches). Therefore the old marker is not inside the current 0.5.52 package.

## 2. 0.5.52 Package Audit

### SOURCE

- Path: `[LOCAL_PATH_REDACTED]`
- 0550 runtime hits: `0`
- 0550 documentation hits: `2`, both in the inherited audit document `0.5.50_SECOND_PASS_AUDIT.md`:
  - Line 23: `- Build marker: XNP_PZ_DISTANCE_TRAIT_0550_WORKSHOP_ID_PREVIEW_PUBLISH_A`
  - Line 24: `- Internal version: 0.5.50-b42-workshop-id-preview-publish-a`
- 0552 marker hits: `7` across runtime and reports; authoritative runtime hit:
  - `[LOCAL_PATH_REDACTED]`
  - `BUILD_ID = "XNP_PZ_DISTANCE_TRAIT_0552_DUAL_TRAIT_SELECTABLE_PHOENIX_NAMING_A",`
- Phoenix registration exists:
  - `[LOCAL_PATH_REDACTED]`
  - `[LOCAL_PATH_REDACTED]`

### DIRECT_INSTALL

- Path: `[LOCAL_PATH_REDACTED]`
- 0550 hits: `0`
- 0552 runtime hits: `1`
  - `[LOCAL_PATH_REDACTED]`
  - `BUILD_ID = "XNP_PZ_DISTANCE_TRAIT_0552_DUAL_TRAIT_SELECTABLE_PHOENIX_NAMING_A",`
- Phoenix registration exists in `42\media\scripts\XNPDistanceRunnerTraits.txt` and `42\media\registries.lua`.
- SOURCE/DIRECT runtime comparison: `85/85 files`, `SHA256_MISMATCH_COUNT=0`.

`STALE_050_RUNTIME_INSIDE_052_PACKAGE=false`

## 3. Active PZ Paths

`ACTIVE_PZ_CACHEDIR=[LOCAL_PATH_REDACTED]`

`ACTIVE_PZ_CONSOLE_PATH=[LOCAL_PATH_REDACTED]`

`ACTIVE_PZ_MODS_PATH=[LOCAL_PATH_REDACTED]`

`CACHEDIR_OVERRIDE_FOUND=false`

Evidence:

- Historical logs explicitly state `cachedir set to "[LOCAL_PATH_REDACTED]`.
- Steam launch options contain no `-cachedir`; the active account has `LaunchOptions` values including an empty value and `-debug`, but no cachedir override.
- Latest console uses `[LOCAL_PATH_REDACTED]` as the game runtime (`java.home` evidence).
- Latest console: `[LOCAL_PATH_REDACTED]`, modified 2026-07-13 23:06:56.
- `options.ini` and `logs.zip` are in the same cachedir.

## 4. Surviving 0550 Runtime

Folder: `[LOCAL_PATH_REDACTED]`

Classification: `WORKSHOP_3762431102`

Mod ID: `XNP_PZ_DistanceRunnerTrait`

Display name: `XNP Distance Runner Trait 0.5.50 Release`

Version: `0.5.50`

Build marker file:

- Path: `[LOCAL_PATH_REDACTED]`
- Line 9: `INTERNAL_VERSION = "0.5.50-b42-wo
[EXCERPT_TRUNCATED]
```

## 0.5.52_DUAL_ICON_UI_REPORT.md

- SHA-256: `B46CE1D17993E95DE07D817D6C9D57DD5D1F7D92A9F054934B7BC45BC1459C5D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.52 Dual Icon UI Report

## Assignment

- `YELLOW_ICON_ASSIGNED_TO_DISTANCE_RUNNER=true`
- Yellow texture: `trait_xnpdistancerunner.png`
- `PURPLE_ICON_ASSIGNED_TO_PHOENIX=true`
- Purple texture: `trait_xnppurplephoenix.png`, byte-identical to approved `item05.png`
- `BLACK_FRAME_ICON_EXCLUDED=true`
- `YELLOW_PURPLE_ICON_NOT_SWAPPED=true`

## Independent Layout

- Yellow default: right offset route, default `Y=76`.
- Phoenix default: `screenWidth - 118`, `Y=116`.
- `DEFAULT_ICON_OVERLAP=false`
- Yellow saved keys: `XNP_DR_StatusIcon_X`, `XNP_DR_StatusIcon_Y`, `XNP_DR_StatusIcon_UserPlaced`.
- Phoenix saved keys: `XNP_PurplePhoenix_IconX`, `XNP_PurplePhoenix_IconY`.
- `SHARED_UI_POSITION_KEY=false`
- `BOTH_ICONS_DRAGGABLE=true`

The yellow tooltip remains tied to Distance Runner. The purple tooltip now displays `涓嶆楦?/ Phoenix` and the Phoenix `READY / ACTIVE / COOLDOWN / OFF` state. Visibility is gated by each trait independently.

```

## 0.5.52_DUAL_TRAIT_CHARACTER_CREATION_REPORT.md

- SHA-256: `1A1AF9B241D5DEC987DAFD1A89E0920C4CDD5A56793BF60EEAB20E358DC76D82`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.52 Dual Trait Character Creation Report

## Native Definitions

| Trait | CN / EN | Full ID | Cost | Texture |
|---|---|---|---:|---|
| Distance Runner | 璺濈璺戣€?/ Distance Runner | `XNPDistanceRunnerTrait:XNPDistanceRunner` | 1 | `trait_xnpdistancerunner.png` |
| Phoenix | 涓嶆楦?/ Phoenix | `XNPPhoenixTrait:XNPPurplePhoenix` | 8 | `trait_xnppurplephoenix.png` |

Both entries are independent `character_trait_definition` blocks with distinct module names, CharacterTrait IDs, UI keys, descriptions, costs, textures, and native registry keys. Neither definition declares an exclusion, conflict, replacement, or hide condition.

- `BOTH_TRAITS_PRESENT_IN_POSITIVE_TRAIT_DEFINITIONS=true`
- `BOTH_TRAITS_SIMULTANEOUSLY_SELECTABLE=true`
- `MUTUAL_EXCLUSION_PRESENT=false`
- `SHARED_TRAIT_ID=false`
- `DISTANCE_RUNNER_COST=1`
- `PHOENIX_COST=8`

## Four Runtime Combinations

| Combination | Yellow UI / logic | Phoenix UI / logic |
|---|---|---|
| Neither | hidden / off | hidden / off |
| Distance Runner only | visible / on | hidden / off |
| Phoenix only | hidden / off | visible / on |
| Both | visible / on | visible / on |

`XNP_DR_Runtime.lua` evaluates the two native trait objects independently. A Phoenix-only player stops before yellow gameplay. A dual-trait player continues through both routes. Character-creation rendering and clicking remain `REAL_GAME_TEST_REQUIRED`.

```

## 0.5.52_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `68D237EC8CD74CAC2EA4A0F5406F4E807AE5E688FD98CCBEDACA4838E83B8591`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.52 Gameplay Preserve Report

## Phoenix Preserved From 0.5.51

- Main / forced thresholds: `0.10 / 0.05`.
- Cooldown: seven game days in Phoenix-only player modData.
- Protection: five real seconds using the shared local zombie snapshot.
- Full health/endurance restoration and optional major negative-state, infection, and zombification clearing.
- Zombie-side stagger, knockdown, and hit-reaction control.
- BodyDamage recovery writes remain confined to `XNP_DR_PurplePhoenixRevive.lua`.
- Trait and cooldown gates remain before revival.

`PHOENIX_GAMEPLAY_PRESERVED=true`

## Distance Runner Preserved

All unchanged baseline runtime files remain hash-identical. The existing calls for Walk No Impact, Jog Bump, Sprint/Vehicle Impact, Controlled Escape, Emergency, PreBite Rescue, tiered food recovery, endurance bands, SP melee, MP melee disablement, draggable UI, CentralWorldQuery, central scheduler, and ten-second summary throttling remain present.

`DISTANCE_RUNNER_GAMEPLAY_PRESERVED=true`

The 0.5.52 edits are limited to identity, visible naming, explanatory comments, and the vehicle history version namespace. Gameplay equivalence remains subject to user real-game testing.

```

## 0.5.52_MASTER_TOGGLE_DUAL_TRAIT_REPORT.md

- SHA-256: `375F6B970E04AA99460D45C71D7A39D694FB736E5A67F5618B08806B9DAEDB8B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.52 Master Toggle Dual Trait Report

The existing white Master state accepts a player owning either native trait. Both icon routes update before the effect gate, allowing OFF to remain visible and reversible.

- `MASTER_OFF_STOPS_DISTANCE_RUNNER_EFFECTS=true`
- `MASTER_OFF_STOPS_PHOENIX_TRIGGER=true`
- `MASTER_OFF_STOPS_ACTIVE_PHOENIX_PROTECTION=true`
- `MASTER_OFF_PRESERVES_PHOENIX_COOLDOWN=true`
- `MASTER_OFF_PRESERVES_DISTANCE_RUNNER_STATE_DATA=true`
- `MASTER_ON_DOES_NOT_RETRIGGER_PHOENIX=true`
- `MASTER_ON_DOES_NOT_BACKFILL_FOOD_PULSES=true`

Cleanup ends transient effects only. Phoenix cooldown remains in its dedicated player modData world-hour key, and the yellow route retains its existing state tables and position data. Actual toggle interaction remains `REAL_GAME_TEST_REQUIRED`.

```

## 0.5.52_OPEN_SOURCE_COMMENTING_REPORT.md

- SHA-256: `301C1F73612309BBCBBAC55185AEB30C425F2E6FA23BAC1852A9B2EF18C6C5E1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.52 Open Source Commenting Report

The 0.5.51 high-density comments remain intact. This version adds or updates comments at the exact integration points affected by dual selection:

- `XNP_DR_Runtime.lua` documents all four trait combinations and their independent gates.
- `XNP_DR_Runtime.lua` documents dual UI persistence and Master behavior.
- `XNP_DR_PurplePhoenix_Constants.lua` documents separate identity, cost, cooldown, and UI namespaces.
- Registration, detection, Bootstrap, revival, UI, and Master comments use the final visible name `Phoenix` while stable internal IDs remain unchanged.

No function implementation was replaced with an unexplained shortcut. Existing comments continue to cover input/output responsibilities, object-based trait detection, cooldown persistence, BodyDamage boundaries, protection scheduling, UI drag persistence, and cleanup.

- `NEW_OR_MODIFIED_LOGIC_COMMENTED=true`
- `FOUR_COMBINATION_GATE_EXPLAINED=true`
- `DUAL_ICON_STATE_ISOLATION_EXPLAINED=true`
- `MASTER_DUAL_TRAIT_EFFECT_EXPLAINED=true`
- `OPEN_SOURCE_READABILITY_STANDARD=PASS`

```

## 0.5.52_TRAIT_ID_AND_POINT_COST_REPORT.md

- SHA-256: `4BDF31FDA160C15C0DF0933D7ECE3A8C2E3C6A400347885B2356631007CD4CC3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.52 Trait ID And Point Cost Report

- Yellow name: `璺濈璺戣€?/ Distance Runner`
- Yellow Full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- Yellow cost: `1`
- Phoenix name: `涓嶆楦?/ Phoenix`
- Phoenix Full ID: `XNPPhoenixTrait:XNPPurplePhoenix`
- Phoenix cost: `8`

The Phoenix cost is preserved from 0.5.51. Both costs are positive and live in separate native definitions, so selecting both consumes nine trait points in total. No runtime alias, registry entry, or translation key causes one definition to replace the other.

- `TRAIT_ID_COLLISION=false`
- `REGISTRY_KEY_COLLISION=false`
- `TRANSLATION_KEY_COLLISION=false`
- `POINT_COST_SHARED=false`

```

## BUILD_MARKER.txt

- SHA-256: `F9B0074BE1028FB326DE0F3C4F27477A2702E50DF598EA6CC87124EF86C95E67`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0552_DUAL_TRAIT_SELECTABLE_PHOENIX_NAMING_A

```

## FINAL_REPORT.md

- SHA-256: `72C4C0E13CD2AC046169ACFC27B4DDE741C14836839146A748C5A695C4163B64`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.52 Final Report

- Source: `[LOCAL_PATH_REDACTED]`
- Direct install: `[LOCAL_PATH_REDACTED]`
- Version: `0.5.52`
- Build: `XNP_PZ_DISTANCE_TRAIT_0552_DUAL_TRAIT_SELECTABLE_PHOENIX_NAMING_A`
- Display name: `XNP Distance Runner Trait 0.5.52 Dual Trait Selectable`

## Delivered Contract

- Distance Runner: `璺濈璺戣€?/ Distance Runner`, Full ID `XNPDistanceRunnerTrait:XNPDistanceRunner`, cost `1`.
- Phoenix: `涓嶆楦?/ Phoenix`, Full ID `XNPPhoenixTrait:XNPPurplePhoenix`, cost `8`.
- Two native definitions, no exclusion/conflict declaration, independent object-based detection.
- Four runtime combinations explicitly gated.
- Approved yellow and purple icons retained without swapping.
- Yellow and Phoenix panels use distinct default positions and persistence keys.
- Master OFF stops effects without deleting Phoenix cooldown or saved yellow state.
- 0.5.51 Phoenix mechanics and 0.5.50/0.5.51 Distance Runner mechanics preserved.
- Strict no-yellow-icon behavior added for traitless and Phoenix-only characters.

## Verification

- SOURCE/DIRECT runtime files: `85 / 85`.
- SHA256 mismatches: `0`.
- Direct first level: `42 | mod.info | poster.png`.
- Lua: `73` files, `14744` lines.
- Project requires missing: `0`.
- CN/EN Sandbox and UI key differences: `0`.
- BOM/NULL/empty/UTF-8 errors: `0 / 0 / 0 / 0`.
- Old active version/display-name hits: `0 / 0`.
- Blocker: `NONE`.

PZ/Steam were not launched. No user mod, save, Workshop, or game directory was written. Runtime behavior still requires the user's game test.

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.52_SOURCE_READY_FOR_DUAL_TRAIT_TEST`

```

## 0.5.52_DIRECT_INSTALL_VALIDATION.md

- SHA-256: `0F9F9C19AA45751D061FC681D6E7B75991324E71F6DDEB9E78D72835E9BA8846`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.52 Direct Install Validation

- Source runtime files: `85`
- Direct-install runtime files: `85`
- Source/direct SHA256 mismatches: `0`
- First level: `42 | mod.info | poster.png`
- Unexpected first-level entries: `0`
- Nested same-name wrapper: `0`
- Development/audit documents in direct install: `0`

`NO_EXTRA_WRAPPER=true`

User drag target:

`[LOCAL_PATH_REDACTED]`

No package was installed, archived, uploaded, or copied to a user mod directory.

```

## 0.5.52_SECOND_PASS_AUDIT.md

- SHA-256: `49FDC6ADECE22F6528401EC9FF5ACEDB8F0148CAAEC4DBDE244E6DA6053F1BD5`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.52 Second-Pass Read-Only Audit

Audit date: 2026-07-13

Audit scope was limited to the existing 0.5.52 SOURCE and DIRECT_INSTALL. No runtime code, DIRECT_INSTALL content, 0.5.51 SOURCE, user directory, save, Workshop directory, or game installation was modified. Project Zomboid and Steam were not launched.

## 1. Version And Structure

- `SOURCE_EXISTS=true`
- `DIRECT_INSTALL_EXISTS=true`
- `VERSION=0.5.52`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0552_DUAL_TRAIT_SELECTABLE_PHOENIX_NAMING_A`
- `BUILD_MARKER_OK=true`
- `DISPLAY_NAME=XNP Distance Runner Trait 0.5.52 Dual Trait Selectable`
- `DISPLAY_NAME_OK=true`
- `MOD_ID=XNP_PZ_DistanceRunnerTrait`
- `MOD_ID_STABLE=true`
- `OLD_SOURCE_UNCHANGED=true`
- `ACTIVE_RUNTIME_OLD_VERSION_TOKEN_HITS=0`
- `SOURCE_RUNTIME_FILE_COUNT=85`
- `DIRECT_RUNTIME_FILE_COUNT=85`
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`
- `DIRECT_INSTALL_FIRST_LEVEL=42|mod.info|poster.png`
- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`

The 0.5.51 behavior baseline still matches its corresponding 0.5.51 DIRECT runtime with zero SHA256 differences, supporting the old-source-unchanged result.

## 2. Distance Runner Trait

- `YELLOW_TRAIT_REGISTERED=true`
- `YELLOW_TRAIT_CN_NAME=璺濈璺戣€卄
- `YELLOW_TRAIT_EN_NAME=Distance Runner`
- `YELLOW_TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner`
- `YELLOW_TRAIT_POINT_COST_PRESENT=true`
- `YELLOW_TRAIT_POINT_COST=1`
- `YELLOW_ICON_ASSIGNED=true`
- `YELLOW_ICON_FILE=trait_xnpdistancerunner.png`
- `YELLOW_ICON_SHA256=8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9`

The native script definition, registry call, runtime constants, CN/EN UI keys, cost, and yellow texture all resolve to the Distance Runner identity.

## 3. Phoenix Trait

- `PURPLE_TRAIT_REGISTERED=true`
- `PURPLE_TRAIT_CN_NAME=涓嶆楦焋
- `PURPLE_TRAIT_EN_NAME=Phoenix`
- `PURPLE_TRAIT_FULL_ID=XNPPhoenixTrait:XNPPurplePhoenix`
- `PURPLE_TRAIT_POINT_COST_PRESENT=true`
- `PURPLE_TRAIT_POINT_COST=8`
- `PURPLE_ICON_ASSIGNED=item05.png`
- `PURPLE_RUNTIME_ICON=trait_xnppurplephoenix.png`
- `PURPLE_ICON_SHA256=55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21`
- `PURPLE_ICON_ITEM05_HASH_MATCH=true`
- `OLD_CN_NAME_PURPLE_PHOENIX_HITS=0`
- `BLACK_FRAME_ICON_USED=false`

The stable internal `XNPPurplePhoenix` ID remains intentionally unchanged for save compatibility; the player-visible CN/EN name is exclusively `涓嶆楦?/ Phoenix`.

## 4. Simultaneous Character-Creation Selection

Evidence was checked against the two native definitions, registries, translations, runtime gates, and `0.5.52_DUAL_TRAIT_CHARACTER_CREATION_REPORT.md`.

- `BOTH_TRAITS_VISIBLE_IN_CHARACTER_CREATION=true` (static native-definition contract)
- `BOTH_TRAITS_CAN_BE_SELECTED_TOGETHER=true` (two independent positive definitions with no exclusion declaration)
- `TRAIT_MUTUAL_EXCLUSION_COUNT=0`
- `TRAIT_ID_COLLISION_COUNT=0`
- `TRAIT_TRANSLATION_KEY_COLLISION_COUNT=0`

[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `7CC1E82A1F1B1BED4137F84EB4DD60ECE131C51300665011B913109ECA1E2F0D`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.52 Static Audit

## Identity

- `VERSION=0.5.52`
- `INTERNAL_VERSION=0.5.52-b42-dual-trait-selectable-phoenix-naming-a`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0552_DUAL_TRAIT_SELECTABLE_PHOENIX_NAMING_A`
- `DISPLAY_NAME=XNP Distance Runner Trait 0.5.52 Dual Trait Selectable`
- `MOD_ID=XNP_PZ_DistanceRunnerTrait`
- `ACTIVE_RUNTIME_OLD_VERSION_TOKEN_HITS=0`
- `ACTIVE_RUNTIME_OLD_DISPLAY_NAME_HITS=0`

Expected startup lines are produced by Bootstrap and the version constants:

```text
[XNP DR] BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0552_DUAL_TRAIT_SELECTABLE_PHOENIX_NAMING_A
[XNP DistanceRunner] loaded version=0.5.52 internal=0.5.52-b42-dual-trait-selectable-phoenix-naming-a build=XNP_PZ_DISTANCE_TRAIT_0552_DUAL_TRAIT_SELECTABLE_PHOENIX_NAMING_A
```

## Dual Trait Contract

- `CHARACTER_TRAIT_DEFINITION_COUNT=2`
- `UNIQUE_CHARACTER_TRAIT_ID_COUNT=2`
- `DISTANCE_RUNNER_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner`
- `DISTANCE_RUNNER_NAME_CN_EN=璺濈璺戣€厊Distance Runner`
- `DISTANCE_RUNNER_COST=1`
- `PHOENIX_FULL_ID=XNPPhoenixTrait:XNPPurplePhoenix`
- `PHOENIX_NAME_CN_EN=涓嶆楦焲Phoenix`
- `PHOENIX_COST=8`
- `MUTUAL_EXCLUSION_HITS=0`
- `PLAYER_STRING_HAS_TRAIT_HITS=0`
- `FOUR_COMBINATION_RUNTIME_GATE=PASS`
- `YELLOW_INACTIVE_DEBUG_RUNTIME_CALLS=0`

The two traits use separate native objects, aliases, UI keys, textures, and point costs. Yellow UI is hidden non-destructively when yellow is absent; Phoenix UI performs its own trait check.

## Icon And State Isolation

- `YELLOW_ICON_SHA256=8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9`
- `PURPLE_ICON_SHA256=55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21`
- `PURPLE_ICON_MATCHES_APPROVED_ITEM05=true`
- `BLACK_FRAME_ICON_USED=false`
- `YELLOW_PURPLE_ICON_SWAPPED=false`
- `DEFAULT_ICON_OVERLAP=false`
- `SHARED_UI_POSITION_KEY=false`
- `SHARED_COOLDOWN_KEY=false`

Yellow defaults to `Y=76`; Phoenix defaults to `Y=116`. Yellow uses `XNP_DR_StatusIcon_*`; Phoenix uses `XNP_PurplePhoenix_Icon*` and `XNP_PurplePhoenix_CooldownUntilWorldHours`.

## Gameplay Preservation

- `PHOENIX_MAIN_TRIGGER_THRESHOLD=0.10`
- `PHOENIX_FORCED_TRIGGER_THRESHOLD=0.05`
- `PHOENIX_COOLDOWN_DAYS=7`
- `PHOENIX_PROTECT_DURATION_SEC=5`
- `PHOENIX_FULL_HEALTH_AND_CURE_ROUTE_PRESENT=true`
- `PHOENIX_ZOMBIE_CONTROL_ROUTE_PRESENT=true`
- `BODYDAMAGE_RECOVERY_WRITE_LEAK=0`
- `DISTANCE_RUNNER_CALL_CHAIN_PRESERVED=true`
- `CENTRAL_SCHEDULER_PRESERVED=true`
- `CENTRAL_WORLD_QUERY_PRESERVED=true`
- `TEN_SECOND_SUMMARY_THROTTLE_PRESERVED=true`

Relative to 0.5.51, 18 runtime/identity files changed intentionally for version identity, visible naming, comments, strict yellow UI gating, and the vehicle history namespace. No file was added to or removed from the 85-file runtime set. All other baseline runtime files remain hash-identical.

## Translation And Sandbox

- `SANDBOX_OPTION_COUNT=53`
- `SANDBOX_DUPLICATE_OPTION_COUNT=0`
- `SANDBOX_CN_KEYS=113`
- `SANDBOX_EN_KEYS=113`
- `SANDBOX_CN
[EXCERPT_TRUNCATED]
```
