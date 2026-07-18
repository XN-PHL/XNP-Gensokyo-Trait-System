# 0.5.51 Sanitized Evidence Excerpts

## 0.5.51_ICON_SELECTION_REPORT.md

- SHA-256: `8EA855CC646625E3F230892BF92DBD3CB99D3245AE99248D32696DB8D6819570`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.51 Icon Selection Report

The five PNG files in `[LOCAL_PATH_REDACTED]` were enumerated and visually inspected at original resolution before selection.

| File | Dimensions | SHA256 | Visual role | Selected |
|---|---:|---|---|---|
| `item00.png` | 16 x 16 | `73885B1445B4C70A7D8DB612EC10E14EE78B938F8593EB4BFCA51995BC2F8908` | Red icon with black outer frame; explicitly excluded | No |
| `item02.png` | 16 x 16 | `00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3` | Red icon without the excluded frame; deferred | No |
| `item03.png` | 16 x 16 | `C9B5A7ED5C04FE2C4A3FC49845FE9D4303A497DAC8A8D4EA2C8D6FA64EE2481F` | Green icon; deferred | No |
| `item04.png` | 16 x 16 | `12029EB6F39F046FA15A0C4663FBF33E985245553FB524902EC045E1E64132D6` | Yellow F icon reserved for existing Distance Runner | No |
| `item05.png` | 16 x 16 | `55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21` | Purple extra-life icon | Yes |

- `ALL_ICON_FILES_FOUND=5`
- `PURPLE_ICON_SELECTED=true`
- `BLACK_FRAME_ICON_EXCLUDED=true`
- `YELLOW_ICON_NOT_REUSED=true`
- `GREEN_RED_ICON_DEFERRED=true`
- `SELECTED_PURPLE_ICON_FILENAME=item05.png`
- `SELECTED_PURPLE_ICON_SHA256=55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21`
- `BLACK_FRAME_ICON_FILENAME=item00.png`
- Runtime destination: `42\media\ui\Traits\trait_xnppurplephoenix.png`
- `RUNTIME_ICON_HASH_MATCH=true`

No generated color block, yellow asset, poster, or prior preview was used.

```

## 0.5.51_OPEN_SOURCE_COMMENTING_REPORT.md

- SHA-256: `E822F41D39CAFA0EBB89EA6D85505B0C46A07C3D92032F58D9BAEA724ED607D7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.51 Open Source Commenting Report

New commented Lua files:

- `XNP_DR_PurplePhoenix_Constants.lua`
- `XNP_DR_PurplePhoenix_Config.lua`
- `XNP_DR_PurplePhoenixTraitRegistration.lua`
- `XNP_DR_PurplePhoenixTrait.lua`
- `XNP_DR_PurplePhoenixRevive.lua`
- `XNP_DR_PurplePhoenixProtect.lua`
- `XNP_DR_PurplePhoenixUI.lua`

Modified Lua files with comments around new behavior:

- `XNP_DR_Bootstrap.lua`
- `XNP_DR_Runtime.lua`
- `XNP_DR_MasterEffectState.lua`

The seven new modules contain `58` functions and `127` full comment lines. Function comments explain purpose, inputs, outputs or state changes, and why the safety boundary exists. Complex sections explicitly document trait isolation, world-time cooldown persistence, pre-death ordering, BodyDamage writes, optional API fallbacks, protection pulse scheduling, target caps, log throttling, independent drag persistence, and Master OFF behavior.

- `NEW_LUA_HIGH_DENSITY_COMMENTS=true`
- `MODIFIED_LOGIC_SURROUNDED_BY_EXPLANATION=true`
- `HEALTH_AND_INFECTION_STEPS_EXPLAINED=true`
- `COOLDOWN_AND_PROTECTION_STEPS_EXPLAINED=true`
- `OPEN_SOURCE_READABILITY_STANDARD=PASS`

```

## 0.5.51_PURPLE_PHOENIX_BODYDAMAGE_SCOPE.md

- SHA-256: `20A843BD34018E106D228ABB35DAD9785B3BABA968B663DB68A3C64FB49BDFD1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.51 Purple Phoenix BodyDamage Scope

All new player health, infection, zombification, wound, and debuff writes are confined to:

`42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_PurplePhoenixRevive.lua`

No recovery write was added to existing yellow Distance Runner modules.

## Always Attempted On Revival

- Overall body health to `100`.
- Endurance to the configured value, default `1.0`.
- Knocked-down and on-floor flags cleared where supported.
- Post-write health verification before success is reported.

## Full Cure Attempts

When `PhoenixFullCureToggle=true`, the module additionally attempts:

- `RestoreToFullHealth` and overall health restoration.
- Body infection, infection level, fake infection, and player-side zombification/infection flags cleared.
- Food sickness, poison, cold strength, unhappiness, and boredom cleared.
- Panic, pain, stress, and fatigue set to zero through Build 42 CharacterStat or legacy fallbacks.
- Every available body part restored to full health.
- Bite, bleeding, deep wound, fracture, scratch, cut, laceration, burn, stiffness, wound infection, bullet, and glass state cleared where the runtime exposes the corresponding method.
- Death-dragdown flag cleared where supported.

## API Boundary

Every operation uses method-existence checks plus `pcall`. Unsupported methods are skipped and counted only when successful. A committed engine death is never reversed by writing a dead flag.

Static audit can verify scope, isolation, ordering, and safe-call coverage. Exact Build 42.19 support for every optional wound setter, complete zombification reversal, and post-revival animation state remain runtime-only risks requiring the user's real-game test.

- `BODYDAMAGE_WRITE_SCOPE=PURPLE_PHOENIX_REVIVE_ONLY`
- `DEATH_FLAG_WRITE=false`
- `HEALTH_VERIFY_REQUIRED=true`
- `RUNTIME_COMPLETE_CURE_NOT_VERIFIABLE_BY_STATIC_AUDIT=true`

```

## 0.5.51_PURPLE_PHOENIX_DESIGN.md

- SHA-256: `5BDFA7B3050AF0019942ADD77BEB5FB1A7DF287B79F1D55B1EEE3214CD300E0E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.51 Purple Phoenix Design

## Trait Identity

- Chinese name: `绱壊涓嶆楦焋
- English name: `Purple Phoenix`
- Full ID: `XNPPhoenixTrait:XNPPurplePhoenix`
- Character creation cost: `8`
- Texture: `media/ui/Traits/trait_xnppurplephoenix.png`

Purple Phoenix is a second native CharacterTrait. It does not replace `XNPDistanceRunnerTrait:XNPDistanceRunner`; both traits may exist on one character, and Purple-Phoenix-only characters do not execute yellow Distance Runner gameplay.

## Trigger Contract

- Main threshold: overall health `<= 0.10`.
- Forced threshold: overall health `<= 0.05`.
- Engine death already committed: fail with `ENGINE_DEATH_ALREADY_COMMITTED`.
- Cooldown: `7` game days, persisted as world-age hours in player `modData`.
- Persistence keys are unique to Purple Phoenix.
- Missing world time or modData blocks activation before any healing write.

The cheap health check runs before the normal dead-character early exit. A successful revival must verify health at or above `0.95`, persist the cooldown, and start protection before it reports `revive_success`.

## Protection Contract

- Duration: `5.0` real seconds.
- Pulse interval: `0.25` seconds under the existing central scheduler.
- Radius: `2.0` tiles by default.
- Candidate source: existing `CentralWorldQuery` local snapshot.
- Target cap: `4` per pulse.
- Controls: stagger, knockdown, or hit-reaction fallback under `pcall`.
- No global zombie list, coordinate write, permanent AI freeze, or target clearing.
- Pulse diagnostics are throttled to approximately one line per second.

## Master And Isolation

The shared Master ON/OFF switch accepts either native trait. Purple UI updates before the OFF gate so the icon remains visible and can re-enable effects. OFF immediately cancels transient protection but never erases the legitimate seven-day cooldown.

`FORMAL_PURPLE_PHOENIX_IMPLEMENTED=true`
`DISTANCE_RUNNER_YELLOW_LOGIC_REPLACED=false`

```

## 0.5.51_PURPLE_PHOENIX_UI_AND_TOOLTIP.md

- SHA-256: `46A91C93E561944D948C29B74B363E82D6ECC3CB3471975A64B8F17DD8C989C8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.51 Purple Phoenix UI And Tooltip

The Purple Phoenix panel is independent from the yellow Distance Runner panel and uses `trait_xnppurplephoenix.png`, copied byte-for-byte from `item05.png`.

## States

- `READY`: full purple icon; one extra life is available.
- `ACTIVE`: pulsing purple icon during the five-second protection window.
- `COOLDOWN`: muted grey-purple icon with remaining world hours in the tooltip.
- `OFF`: dimmed icon while the shared Master switch or Phoenix Sandbox logic is disabled.

## Interaction

- Left drag moves only this UI panel and stores independent X/Y keys in player `modData`.
- Right click uses the existing shared Master toggle.
- Default placement is below the yellow slot so both icons can coexist.
- Drag clamping uses screen coordinates only; player and zombie world coordinates are never changed.

## Tooltip

The tooltip contains Chinese and English text, current state, active seconds or cooldown hours, and interaction help. `PhoenixTooltipEnable` controls it without disabling the icon.

- `PURPLE_UI_INDEPENDENT=true`
- `YELLOW_TEXTURE_REUSED=false`
- `PURPLE_UI_DRAGGABLE=true`
- `MASTER_OFF_COMPATIBLE=true`
- `TOOLTIP_BILINGUAL=true`

```

## 0.5.51_TEST_PLAN.md

- SHA-256: `72FA9046729255E99A1BEFA02073D46AAD263164821C0414B176A24B36A525BB`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.51 Purple Phoenix Test Plan

No test in this plan was run by Codex. The user installs the DIRECT_INSTALL folder and performs the real-game checks.

## 1. Character Creation

1. Confirm both `Distance Runner` and `Purple Phoenix` appear with different icons.
2. Create a Purple-only character and confirm only the purple icon appears.
3. Create a yellow-only character and confirm no Purple Phoenix logic or icon appears.
4. Create a character with both and confirm both icons coexist.

## 2. Ready And Trigger

1. Confirm the purple icon starts in `READY`.
2. Reduce overall health through controlled testing.
3. Confirm the main attempt occurs at or below 10% and the forced path is identified at or below 5%.
4. Confirm logs contain `trigger`, `revive_success`, `cooldown_started`, and `cooldown_remaining`.
5. Confirm a genuinely committed death logs `fail reason=ENGINE_DEATH_ALREADY_COMMITTED` rather than fake success.

## 3. Cure Verification

Before triggering, create a controlled combination of bleeding, scratch, bite/infection test state, pain, panic, fatigue, and low endurance. After triggering, record which states clear and compare against `0.5.51_PURPLE_PHOENIX_BODYDAMAGE_SCOPE.md`.

Any unsupported or uncleared state is a runtime API result and must be reported with the console log; do not assume static success.

## 4. Protection

1. Trigger while several zombies are within two tiles.
2. Confirm local zombies stagger or fall repeatedly for approximately five seconds.
3. Confirm distant zombies are unaffected.
4. Confirm protection stops after five seconds and does not become a permanent aura.
5. Confirm `protect_pulse` logs are throttled and no global performance spike occurs.

## 5. Cooldown And Master OFF

1. Confirm a second critical-health event during cooldown does not revive again.
2. Advance seven game days in a disposable test save and confirm `READY` returns.
3. Right-click the purple icon to turn Master OFF; confirm icon state `OFF`, no revival occurs, and active protection stops.
4. Re-enable and confirm cooldown is preserved rather than reset.

## 6. Regression

Repeat the established yellow tests for Walk No Impact, Jog Bump, Sprint/Vehicle Impact, Controlled Escape, Emergency, PreBite, tiered food, SP melee, MP-disabled boundary, White OFF, and yellow icon dragging.

`REAL_GAME_TEST_REQUIRED_BY_USER=true`

```

## BUILD_MARKER.txt

- SHA-256: `098AB85666EB880E8E8B0E677C4BBF5ECC9AA7D4D555A661811C9575BA88AC2B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0551_PURPLE_PHOENIX_EXTRA_LIFE_A

```

## FINAL_REPORT.md

- SHA-256: `E9D5C5A7BA113F4F8FAAA0FA8CA81759116657338C8F37F8FD6AC755463EA864`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.51 Final Report

## Outputs

- SOURCE: `[LOCAL_PATH_REDACTED]`
- DIRECT_INSTALL: `[LOCAL_PATH_REDACTED]`
- DIRECT_INSTALL first level: `42`, `mod.info`, `poster.png`

## New Feature

- Trait: `绱壊涓嶆楦?/ Purple Phoenix`
- Full ID: `XNPPhoenixTrait:XNPPurplePhoenix`
- Selected source icon: `item05.png`
- Excluded black-frame icon: `item00.png`
- Trigger thresholds: `10%` main, `5%` forced.
- Cooldown: `7` game days.
- Protection: `5` real seconds, `2.0` tile local radius, `0.25` second pulses.

Successful revival restores overall health, restores endurance, optionally invokes full-health recovery, clears infection/zombification flags where supported, resets major mood debuffs, and iterates body parts to clear wounds where supported. Every optional write is method-checked and `pcall` wrapped inside the Purple Phoenix revive module.

## UI

An independent purple panel supports `READY`, `ACTIVE`, `COOLDOWN`, and `OFF`, independent dragging, bilingual tooltip text, and the shared right-click Master toggle. It does not reuse or overwrite the yellow icon.

## Preservation

The original yellow trait ID, texture, movement, endurance, impact, escape, PreBite, food, melee, scheduler, Master OFF, and drag routes are retained. Baseline comparison found no unexpected changed files.

## Validation

- Source/direct runtime files: `85/85`.
- Source/direct hash mismatches: `0`.
- Direct-install wrapper errors: `0`.
- Project `require` misses: `0`.
- Lexical balance problems: `0`.
- CN/EN Sandbox and UI key differences: `0`.
- BOM, NULL, empty runtime text, UTF-8 decode errors: `0`.
- Active old-version token hits: `0`.

## Runtime Risks

- Current 0.5.51 was not launched.
- No executable Lua parser/compiler was available.
- Exact optional BodyDamage and zombification method support requires real-game verification.
- Revival must occur before the engine commits death; committed death correctly fails.
- Complete multiplayer authority behavior is not claimed.

## Safety

- Old SOURCE modified: `NO`.
- Project Zomboid or Steam launched: `NO`.
- User mods, saves, Workshop, or game installation written: `NO`.
- Packed, installed, or uploaded: `NO`.

`BLOCKER=NONE`

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.51_SOURCE_READY_FOR_PURPLE_PHOENIX_TEST`

```

## sandbox-options.txt

- SHA-256: `4C88BC56BE5F03D0A76390DA0FE353273708390F26E01903F5A8F61BA66ADBB9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
VERSION = 1,

option XNPDistanceRunner.EnableMod
{
    type = boolean, default = true,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_EnableMod,
}

option XNPDistanceRunner.TuningPreset
{
    type = enum, numValues = 3, default = 1,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_TuningPreset,
    valueTranslation = XNPDistanceRunner_TuningPreset,
}

option XNPDistanceRunner.EnableDebugSummary
{
    type = boolean, default = false,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_EnableDebugSummary,
}

option XNPDistanceRunner.LiveRefreshTuning
{
    type = boolean, default = true,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_LiveRefreshTuning,
}

option XNPDistanceRunner.GlobalSkillCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_GlobalSkillCostMultiplier,
}

option XNPDistanceRunner.ZombieImpactCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 0.24,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_ZombieImpactCostMultiplier,
}

option XNPDistanceRunner.JogBumpCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_JogBumpCostMultiplier,
}

option XNPDistanceRunner.SprintPrecollisionCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_SprintPrecollisionCostMultiplier,
}

option XNPDistanceRunner.SprintVehicleZombieCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_SprintVehicleZombieCostMultiplier,
}

option XNPDistanceRunner.ControlledEscapeCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_ControlledEscapeCostMultiplier,
}

option XNPDistanceRunner.NativeTripCostMultiplier
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_NativeTripCostMultiplier,
}

option XNPDistanceRunner.StaminaAssistIntensity
{
    type = double, min = 0.00, max = 2.00, default = 1.00,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_StaminaAssistIntensity,
}

option XNPDistanceRunner.BlueRefundPercent
{
    type = integer, min = 0, max = 90, default = 30,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_BlueRefundPercent,
}

option XNPDistanceRunner.YellowRefundPercent
{
    type = integer, min = 0, max = 90, default = 38,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_YellowRefundPercent,
}

option XNPDistanceRunner.RedRefundPercent
{
    type = integer, min = 0, max = 90, default = 55,
    page = XNPDistanceRunner, translation = XNPDistanceRunner_RedRefundPercent,
}

option XNPDistanceRunner.ExtraHungerCostMultiplier
{
    type = double, min = 0
[EXCERPT_TRUNCATED]
```

## 0.5.51_SECOND_PASS_AUDIT.md

- SHA-256: `40FD7C021D7DC2667EEA0023C06AB3A4D37AD7BD904E52C8F6D207170D77016E`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.51 Second-Pass Read-Only Audit

Audit date: 2026-07-13

This audit was performed without changing runtime code, rebuilding `DIRECT_INSTALL`, launching Project Zomboid or Steam, or writing to user mod, save, Workshop, or game-installation directories.

## 1. Version And Structure

- `SOURCE_EXISTS=true`
- `DIRECT_INSTALL_EXISTS=true`
- `VERSION=0.5.51`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0551_PURPLE_PHOENIX_EXTRA_LIFE_A`
- `BUILD_MARKER_OK=true`
- `DISPLAY_NAME=XNP Distance Runner Trait 0.5.51 Purple Phoenix Extra Life`
- `DISPLAY_NAME_OK=true`
- `MOD_ID=XNP_PZ_DistanceRunnerTrait`
- `MOD_ID_STABLE=true`
- `OLD_SOURCE_UNCHANGED=true` (the 0.5.50 SOURCE still matches its corresponding 0.5.50 DIRECT runtime, with zero hash mismatches)
- `ACTIVE_RUNTIME_OLD_VERSION_TOKEN_HITS=0`
- `SOURCE_RUNTIME_FILE_COUNT=85`
- `DIRECT_INSTALL_RUNTIME_FILE_COUNT=85`
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`
- `DIRECT_INSTALL_FIRST_LEVEL=42|mod.info|poster.png`
- `NO_EXTRA_WRAPPER=true`
- `NESTED_SAME_NAME_FOLDER_COUNT=0`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`
- `DEV_DOC_COUNT_IN_DIRECT_INSTALL=0`
- `AUDIT_FILE_COUNT_IN_DIRECT_INSTALL=0`

Relative to the 0.5.50 behavior baseline, 14 expected integration/identity files changed, eight Purple Phoenix runtime files were added, no baseline runtime file is missing, and no unexpected baseline file changed.

## 2. Icon Material Audit

Evidence source: `0.5.51_ICON_SELECTION_REPORT.md` plus an independent SHA256 check.

- `ALL_ICON_FILES_FOUND=5`
- `PURPLE_ICON_SELECTED=true`
- `BLACK_FRAME_ICON_EXCLUDED=true`
- `YELLOW_ICON_NOT_REUSED=true`
- `GREEN_RED_ICON_DEFERRED=true`
- `SELECTED_PURPLE_ICON_FILENAME=item05.png`
- `SELECTED_PURPLE_ICON_SHA256=55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21`
- `BLACK_FRAME_ICON_FILENAME=item00.png`
- `RUNTIME_ICON=42\media\ui\Traits\trait_xnppurplephoenix.png`
- `RUNTIME_ICON_HASH_MATCH=true`

The existing yellow Distance Runner icon remains separate. The red and green images remain deferred.

## 3. Purple Trait Audit

- `PURPLE_TRAIT_NAME_CN=绱壊涓嶆楦焋
- `PURPLE_TRAIT_NAME_EN=Purple Phoenix`
- `PURPLE_TRAIT_FULL_ID=XNPPhoenixTrait:XNPPurplePhoenix`
- `PURPLE_TRAIT_REGISTERED=true`
- `PURPLE_TRAIT_VISIBLE_IN_CHARACTER_CREATION=true` (static definition: independent `character_trait_definition`, native registry entry, UI name, description, cost, and texture)
- `PURPLE_TRAIT_FULL_ID_PRESENT=true`
- `PURPLE_TRAIT_COEXISTS_WITH_DISTANCE_RUNNER=true`
- `NO_PURPLE_LOGIC_WITHOUT_PURPLE_TRAIT=true`
- `OBJECT_BASED_TRAIT_DETECTION=true`
- `PLAYER_STRING_HAS_TRAIT_HITS=0`

Runtime code obtains the native known-trait collection, compares the canonical registered object first, and uses stable object IDs only as fallback aliases. A Purple-only character stops before the yellow movement, impact, stamina, food, and melee routes.

## 4. Trigger And Cooldown

- `PHOENIX_MAIN_TRIGGER_THRESHOLD=0.10`
- `PHOENIX_FORCED_TRIGGER_THRESHOLD=0.05`
- `PHOENIX_SINGLE_
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `EF2829D1CBBDC10FAC35D1B2DCE788063D3C7C72DF33BA87A713C114AD7AFA48`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.51 Static Audit

## Identity And Outputs

- `VERSION=0.5.51`
- `INTERNAL_VERSION=0.5.51-b42-purple-phoenix-extra-life-a`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0551_PURPLE_PHOENIX_EXTRA_LIFE_A`
- `DISPLAY_NAME=XNP Distance Runner Trait 0.5.51 Purple Phoenix Extra Life`
- `MOD_ID=XNP_PZ_DistanceRunnerTrait`
- `SOURCE_EXISTS=true`
- `DIRECT_INSTALL_EXISTS=true`
- `OLD_SOURCE_MODIFIED=false`
- `ACTIVE_RUNTIME_OLD_VERSION_TOKEN_HITS=0`

## Icon Selection

- `ALL_ICON_FILES_FOUND=5`
- `PURPLE_ICON_SELECTED=true`
- `SELECTED_PURPLE_ICON_FILENAME=item05.png`
- `SELECTED_PURPLE_ICON_SHA256=55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21`
- `RUNTIME_PURPLE_ICON_HASH_MATCH=true`
- `BLACK_FRAME_ICON_EXCLUDED=true`
- `BLACK_FRAME_ICON_FILENAME=item00.png`
- `YELLOW_ICON_NOT_REUSED=true`
- `GREEN_RED_ICON_DEFERRED=true`

## Native Trait And Isolation

- `PURPLE_TRAIT_FULL_ID=XNPPhoenixTrait:XNPPurplePhoenix`
- `PURPLE_NATIVE_CHARACTER_TRAIT_DEFINITION=true`
- `PURPLE_NATIVE_REGISTRY_CALL=true`
- `PURPLE_OBJECT_BASED_DETECTION=true`
- `PLAYER_STRING_HAS_TRAIT_HITS=0`
- `DISTANCE_RUNNER_TRAIT_ID_PRESERVED=true`
- `DISTANCE_RUNNER_YELLOW_ICON_PRESERVED=true`
- `PURPLE_AND_YELLOW_CAN_COEXIST=true`
- `PURPLE_ONLY_SKIPS_YELLOW_GAMEPLAY=true`

## Extra-Life Contract

- `PHOENIX_TRIGGER_HEALTH_MAIN=0.10`
- `PHOENIX_TRIGGER_HEALTH_FORCED=0.05`
- `PHOENIX_COOLDOWN_DAYS=7`
- `COOLDOWN_PERSISTENCE=PLAYER_MODDATA_WORLD_HOURS`
- `PREDEATH_CHECK_BEFORE_DEAD_EARLY_EXIT=true`
- `COMMITTED_DEATH_REPORTS_FAIL=true`
- `HEALTH_VERIFY_BEFORE_SUCCESS=true`
- `PERSISTENCE_VALIDATED_BEFORE_HEALING=true`
- `PHOENIX_PROTECT_DURATION_SEC=5.0`
- `PHOENIX_PROTECT_RADIUS=2.0`
- `PHOENIX_PULSE_INTERVAL_SEC=0.25`
- `PHOENIX_TARGET_CAP_PER_PULSE=4`

Required log tokens are present: `trigger`, `revive_success`, `protect_pulse`, `cooldown_started`, `cooldown_remaining`, and `fail reason=` under the `[XNP PHOENIX]` prefix.

## BodyDamage And Infection Scope

- `NEW_PLAYER_RECOVERY_WRITE_SCOPE=XNP_DR_PurplePhoenixRevive.lua_ONLY`
- `YELLOW_BODYDAMAGE_RECOVERY_WRITE_ADDED=false`
- `OVERALL_HEALTH_FULL_ATTEMPT=true`
- `INFECTION_CLEAR_ATTEMPT=true`
- `ZOMBIFICATION_CLEAR_ATTEMPT=true`
- `BODY_PART_WOUND_CLEAR_ATTEMPT=true`
- `PANIC_PAIN_STRESS_FATIGUE_CLEAR_ATTEMPT=true`
- `ENDURANCE_RESTORE_ATTEMPT=true`
- `DEATH_FLAG_WRITE=false`
- `DANGEROUS_API_PCALL_WRAPPED=true`

The existing `XNP_DR_MinorScrapeCost.lua` still reads BodyDamage but does not receive any recovery write. Optional wound and zombification setters remain runtime API risks.

## Protection, Scheduler, And Safety

- `CENTRAL_SCHEDULER_COUNT=1`
- `CENTRAL_WORLD_QUERY_REUSED=true`
- `NEW_GLOBAL_ZOMBIE_LIST_SCAN=false`
- `GLOBAL_ZOMBIE_LIST_HITS=0`
- `PLAYER_WORLD_COORDINATE_WRITE_HITS=0`
- `ZOMBIE_WORLD_COORDINATE_WRITE_HITS=0`
- `PERMANENT_AI_FREEZE=false`
- `ZOMBIE_TARGET_CLEAR=false`
- `PROTECTION_LOG_THROTTLED=true`
- `MASTER_OFF_EARLY_EXIT=true`
- `MASTER_OFF_STOPS_PROTECTION=true`
- `MASTER_OFF_PRESERVES_COOLD
[EXCERPT_TRUNCATED]
```
