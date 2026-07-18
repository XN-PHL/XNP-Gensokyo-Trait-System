# 0.5.29 Sanitized Evidence Excerpts

## 0.5.29_PRESERVE_0.5.28_STAMINA_FEEL.md

- SHA-256: `2108849C8B5271C8BC126C7E96CE07C5F677E1FC869FF3AC2461280D919B4DB2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.29 Preserve 0.5.28 Stamina Feel

RED_STRAIN=PRESERVED

JOG_FLOOR=PRESERVED

METABOLIC_YELLOW=PRESERVED

SAFE_RGBA=PRESERVED

LOG_SILENCE=PRESERVED

WALK_NO_IMPACT=PRESERVED

CONTROLLED_JOG_ESCAPE=PRESERVED

NO_MECHANIC_RETUNE=YES

Preserved runtime evidence:

- `RED_STRAIN`
- `MAX_OUTPUT_NO_RECOVERY`
- `LOW_ENDURANCE_JOG_FAILURE`
- `METABOLIC_CAP_REACHED`
- `StaminaTrendMeter`
- `JOG_FLOOR`
- `YELLOW_METABOLIC`
- `SAFE_RGBA`
- `RELEASE_LOG_LEVEL = "SUMMARY_ONLY"`
- `WALK_NO_IMPACT_ENABLED = true`
- `CONTROLLED_ESCAPE_ENABLED = true`
- `ICON_DRAG_CAPTURE_ENABLED = true`

```

## 0.5.29_RESIDUE_CLEANUP_FROM_0.5.28.md

- SHA-256: `4E14CEEA180D105663EC4DC92EB37FEAF1474EF43FC15E3AE1DE8D0615AEF075`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.29 Residue Cleanup From 0.5.28

BASELINE=0.5.28

FIX_TYPE=ACTIVE_LUA_VERSION_RESIDUE_CLEANUP_ONLY

Known blocker fixed:

- `XNP_DR_Config.lua` no longer contains the old active Lua comment with the previous version number.

Mechanic retune:

- NO_MECHANIC_RETUNE=YES
- RedStrain values unchanged.
- JogFloor values unchanged.
- Metabolic/Yellow values unchanged.
- Safe RGBA unchanged.
- Log silence behavior unchanged.

READY_TARGET:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.29_SOURCE_READY_FOR_STAMINA_FEEL_TEST

```

## 0.5.29_TEST_PLAN.md

- SHA-256: `FB4C607030B6D5CFDFB23DA60EFD4A2A336BFCF19969654F20AACBDA22256C56`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.29 Test Plan

Manual install only. Codex did not launch Project Zomboid and did not write user mods.

Expected startup:

- `[XNP DR] BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0529_STAMINA_FEEL_RESIDUE_CLEAN_A`
- `[XNP DistanceRunner] loaded version=0.5.29 internal=0.5.29-b42-stamina-feel-residue-clean-a build=XNP_PZ_DISTANCE_TRAIT_0529_STAMINA_FEEL_RESIDUE_CLEAN_A`

Regression checks:

1. Confirm RedStrain behavior remains available.
2. Confirm JogFloor behavior remains available.
3. Confirm Yellow/Metabolic state remains available.
4. Confirm Safe RGBA logs are still present and no unregistered yellow named-color warning comes from XNP.
5. Confirm MovementGate/JogBump/Dragdown logs are summary-only.
6. Confirm walk no impact and controlled jog escape still work.

```

## BUILD_MARKER.txt

- SHA-256: `893336E1752A8FDC66CEAE16825078AF073C59A2122AD8C980A6F1D03B4BE283`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0529_STAMINA_FEEL_RESIDUE_CLEAN_A

```

## FINAL_REPORT.md

- SHA-256: `ABB82F7196375E2BA4ED23D90DE81D57F7AB000B014B6FEF928B215792FDA7EA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.29

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0529_STAMINA_FEEL_RESIDUE_CLEAN_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.29 Stamina Feel Residue Clean

FIX_TYPE=ACTIVE_LUA_VERSION_RESIDUE_CLEANUP_ONLY

FILE_COUNT=56

LUA_COUNT=43

LUA_LINES=8990

0.5.28 blocker fix:

- active Lua old residue: FIXED
- known Config line fixed: YES
- active Lua old version hits: 0

Version:

- build marker: YES
- display name: YES
- runtime version: YES

Preserve:

- RedStrain: PRESERVED
- MAX_OUTPUT_NO_RECOVERY: PRESERVED
- JogFloor: PRESERVED
- Metabolic/Yellow: PRESERVED
- Safe RGBA: PRESERVED
- Log silence: PRESERVED
- walk no impact: PRESERVED
- controlled jog escape: PRESERVED
- jog bump: PRESERVED
- sprint vehicle: PRESERVED
- drag capture: PRESERVED

Forbidden grep:

- runtime forbidden route hits: 0 blocking hits
- player coordinate write: 0
- ProgressYellow active hits: 0
- namedColorToTable active hits: 0

Restrictions:

- old SOURCE modified: NO
- Project Zomboid launched: NO
- Steam launched: NO
- user mods written: NO
- saves written: NO
- Workshop written: NO
- game directory written: NO
- packaged/installed: NO

FINAL_STATUS:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.29_SOURCE_READY_FOR_STAMINA_FEEL_TEST

```

## 0.5.29_ACTIVE_LUA_OLD_VERSION_RESIDUE_AUDIT.md

- SHA-256: `501BBBAFD5977B94E67E2702ABCAAA82DC5ABDADE0075038025814C62896D29F`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.29 Active Lua Old Version Residue Audit

OLD_ACTIVE_RESIDUE=ZERO

Active Lua scan scope:

- `42/media/lua/client/**/*.lua`
- `42/media/lua/shared/**/*.lua`

Forbidden historical runtime version tokens:

- 0.5.20 / 0520
- 0.5.21 / 0521
- 0.5.22 / 0522
- 0.5.23 / 0523
- 0.5.24 / 0524
- 0.5.25 / 0525
- 0.5.26 / 0526
- 0.5.27 / 0527
- previous version / previous marker family

Result:

- active old version residue hits: 0
- current active marker hits: present in `XNP_DR_Constants.lua`
- known blocker line fixed: YES

Current allowed marker:

`XNP_PZ_DISTANCE_TRAIT_0529_STAMINA_FEEL_RESIDUE_CLEAN_A`

```

## 0.5.29_SECOND_PASS_AUDIT.md

- SHA-256: `E4B5D1B106C116864F326CBF5AAC952513E3E3E1E2A43464FB99D53145F9E54C`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.29 Second Pass Audit

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]

AUDIT_TYPE=READ_ONLY_SECOND_PASS

ALLOWED_WRITE=0.5.29_SECOND_PASS_AUDIT.md

PROJECT_ZOMBOID_LAUNCHED=NO

STEAM_LAUNCHED=NO

USER_MODS_WRITTEN=NO

SAVES_WRITTEN=NO

WORKSHOP_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

PACKAGED_OR_INSTALLED=NO

## 1. Version And File Count

SOURCE_EXISTS=YES

EXPECTED_VERSION=0.5.29

VERSION_OK=YES

EXPECTED_BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0529_STAMINA_FEEL_RESIDUE_CLEAN_A

BUILD_MARKER_OK=YES

EXPECTED_DISPLAY_NAME=XNP Distance Runner Trait 0.5.29 Stamina Feel Residue Clean

DISPLAY_NAME_OK=YES

FILE_COUNT_0528=61

FILE_COUNT_0529=56

LUA_COUNT_0529=43

ACTIVE_RUNTIME_LUA_COUNT=42

LARGE_COPY_DETECTED=NO

FILE_COUNT_RISK=NO

FILE_COUNT_BLOCKER=NO

## 2. Active Lua Old Version Residue

Scanned runtime Lua locations:

- 42/media/lua/client
- 42/media/lua/shared
- media/lua/client if present
- media/lua/shared if present
- scripts/vscripts if present

OLD_ACTIVE_RESIDUE=PASS

ACTIVE_LUA_OLD_VERSION_HITS=0

KNOWN_CONFIG_RESIDUE_FIXED=YES

ACTIVE_LUA_CURRENT_VERSION_MARKER=YES

The known old Config comment was checked directly in:

`42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`

Result: fixed. The old versioned comment is not present in active Lua.

## 3. 0.5.28 Mechanism Preserve Audit

RED_STRAIN_PRESERVED=YES

Evidence:

- red_strain_enabled present
- MAX_OUTPUT_NO_RECOVERY present
- LOW_ENDURANCE_JOG_FAILURE present
- METABOLIC_CAP_REACHED present
- StaminaTrendMeter present
- RED_STRAIN icon state present

JOG_FLOOR_PRESERVED=YES

Evidence:

- jog_floor_support_enabled present
- JOG_FLOOR path present
- low hunger guard and capped assist settings present

METABOLIC_YELLOW_PRESERVED=YES

Evidence:

- YELLOW_METABOLIC present
- hunger write result logging present
- METABOLIC_HARD_STOP_HUNGER present
- cap and guard settings present

SAFE_RGBA_PRESERVED=YES

Evidence:

- SAFE_RGBA present
- unsafe yellow named-color route active Lua hits: 0
- unsafe named color conversion active Lua hits: 0
- dragged icon position config preserved

LOG_SILENCE_PRESERVED=YES

Evidence:

- release summary mode present
- movement gate immediate log disabled
- movement gate summary interval present
- JOG bump block summary only present
- dragdown warning summary only present
- auto dragdown warning summary only present
- status icon state hold log disabled
- stamina assist tick log disabled

WALK_NO_IMPACT_PRESERVED=YES

CONTROLLED_ESCAPE_PRESERVED=YES

JOG_BUMP_PRESERVED=YES

SPRINT_VEHICLE_PRESERVED=YES

DRAG_CAPTURE_PRESERVED=YES

PRESERVE_STATUS=PASS

## 4. Forbidden Route Audit

Runtime Lua forbidden route hits: 0 blocking hits.

PLAYER_COORD_WRITE=NO

HEAL_ROLLBACK_ROUTE=NO

BODYDAMAGE_SCOPE=MINOR_SCRAPE_COST_ONLY

INFINITE_STAMINA_ROUTE=NO

INFINITE_SPRINT_ROUTE=NO

PER_FRAME_PRINT_ROUTE=NO_BLOCKING_ROUTE_FOUND

FORBIDDEN_HITS_RUNTIME=0

Full-source note:

- Existing documentation files contain literal banned route names only as
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `08C0F629CCFA74F263C2C8C7A780E6835A3A5339839AEF4E91A479EDD721CF21`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE=[LOCAL_PATH_REDACTED]

BASELINE=0.5.28

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0529_STAMINA_FEEL_RESIDUE_CLEAN_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.29 Stamina Feel Residue Clean

FILE_COUNT=56

LUA_COUNT=43

LUA_LINES=8990

OLD_SOURCE_MODIFIED=NO

ACTIVE_OLD_VERSION_RESIDUE=ZERO

Known blocker line fixed:

- `XNP_DR_Config.lua` no longer contains the old active Lua version comment.

Markdown historical references:

- Allowed and separated from active Lua.

Forbidden route grep:

- bumped variable writes: 0
- `player:hasTrait(`: 0
- TraitFactory / CharacterTraitDefinition: 0
- RunningShove / BumpedState: 0
- GameTime multiplier: 0
- HaloTextHelper / player:Say: 0
- player coordinate setters: 0

Preserve grep:

- RED_STRAIN: present
- MAX_OUTPUT_NO_RECOVERY: present
- LOW_ENDURANCE_JOG_FAILURE: present
- METABOLIC_CAP_REACHED: present
- StaminaTrendMeter: present
- JOG_FLOOR: present
- YELLOW_METABOLIC: present
- hunger write result log: present
- METABOLIC_HARD_STOP_HUNGER: present
- SAFE_RGBA: present
- ProgressYellow active hits: 0
- namedColorToTable active hits: 0
- Log silence config: present
- MovementGate preserve: present
- Controlled escape preserve: present
- Walk no impact preserve: present
- no infinite stamina/sprint guard: present
- no heal/no bite/no infection logs: present
- active Lua current marker: present

BLOCKER=NONE

```
