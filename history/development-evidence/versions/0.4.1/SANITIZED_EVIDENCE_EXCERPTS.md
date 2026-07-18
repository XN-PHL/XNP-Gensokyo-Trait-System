# 0.4.1 Sanitized Evidence Excerpts

## 0.4.1_REAL_RUNTIME_FAILURE_ANALYSIS.md

- SHA-256: `202D2A2291043E6E6DB1333F3D153FAA192AEE2BB3709F6D12A5548B4CF91214`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.4.1 REAL RUNTIME FAILURE ANALYSIS

## Frozen Runtime Evidence

- PZ version: `Project Zomboid 42.19.0`
- Branch: `steam/release`
- Revision: `1aa820d7bb66c4e55513cae04022bdacdac5b34e`
- 0.4.1 mod load: `PASS`
- 0.4.1 module log: `[XNP DISTANCE RUNNER] module loaded version=0.4.1-native-trait-registration-fix-a build=XNP_PZ_DISTANCE_TRAIT_041_REG_FIX_A`
- 0.4.1 event execution: `[XNP DISTANCE RUNNER] trait registration begin`
- Runtime API result: `[XNP DISTANCE RUNNER] TraitFactory available=false`
- Failure: `[XNP DISTANCE RUNNER] trait registration failed stage=api_check reason=TraitFactory_addTrait_or_getTrait_unavailable`

## Frozen Conclusions

- `0.4.1_LUA_LOAD=PASS`
- `0.4.1_EVENT_EXECUTION=PASS`
- `0.4.1_TRAIT_API_ACCESS=FAIL`
- `0.4.1_ADD_TRAIT_INVOKED=NO`
- `0.4.1_TRAIT_VISIBLE=NO`
- Root cause: `TRAITFACTORY_GLOBAL_OR_METHODS_UNAVAILABLE_IN_B42_19_LUA_ENVIRONMENT`

## Excluded Causes

The failure occurred before any trait was added, so the following are not the primary cause:

- translation key
- search/filter text
- UI category sorting
- cost sign
- Mod ID
- install directory
- `Events.OnGameBoot`
- Chinese localization

## Result

`0.4.1_RESULT=FAILED_AT_NATIVE_TRAIT_API_ACCESS`

```

## B42_TRAIT_WORKING_SAMPLE_MATRIX.md

- SHA-256: `F1253410546810DDCC7EEBAA0E95758A8F9A987CE61F973463CFD44AFFB8E79B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42 TRAIT WORKING SAMPLE MATRIX

## Sample 1: Vanilla Build 42 trait bootstrap

- Mod path: `[LOCAL_PATH_REDACTED]`
- Mod ID: vanilla game
- Version directory: vanilla `media\lua`
- Registration Lua: `media\lua\shared\NPCs\MainCreationMethods.lua`
- Environment: shared
- Registration timing: `Events.OnGameBoot.Add(BaseGameCharacterDetails.DoTraits)`
- addTrait parameter count: vanilla uses Java-side trait definitions in B42; character creation later reads `CharacterTraitDefinition.getTraits()`.
- Cost sign: positive traits are consumed points when `getCost() > 0`.
- Translation method: `getText(...)` in trait definitions and UI.
- Uses OnGameBoot: yes.
- Uses OnInitWorld: no.
- Top-level direct registration: no, event-bound.
- getTrait duplicate guard: not applicable to vanilla baseline.
- Mutual exclusions: handled in trait definitions.
- B42-specific handling: `CharacterTraitDefinition.getTraits()` is the character creation list source.

## Sample 2: More Traits, Build 42

- Mod path: `[LOCAL_PATH_REDACTED]`
- Mod ID: `1299328280/ToadTraits`
- Version directory: `42`
- Registration Lua: `42\media\lua\shared\NPCs\MoreTraitsMainCreationMethods.lua`
- Environment: shared
- Registration timing: `Events.OnGameBoot.Add(initToadTraits)`
- addTrait parameter count: 6 in most calls.
- Cost sign: positive traits use positive values such as `1`, `2`, `5`; negative traits use negative values.
- Translation method: `getText("UI_trait_*")`.
- Uses OnGameBoot: yes.
- Uses OnInitWorld: no.
- Top-level direct registration: no, function is event-bound.
- getTrait duplicate guard: no.
- Mutual exclusions: yes, through `TraitFactory.setMutualExclusive(...)`.
- B42-specific handling: has `42\media\lua\shared` and `42\mod.info`.

## Sample 3: ProfessionFramework

- Mod path: `[LOCAL_PATH_REDACTED]`
- Mod ID: `ProfessionFramework`
- Version directory: legacy/common style, but installed locally and actively replaces the vanilla OnGameBoot trait loader.
- Registration Lua: `media\lua\shared\2ProfessionFramework.lua`
- Environment: shared
- Registration timing: removes vanilla `oldDoTraits`, then `Events.OnGameBoot.Add(ProfessionFramework.doTraits)`.
- addTrait parameter count: 6.
- Cost sign: caller-supplied; same sign semantics as vanilla.
- Translation method: `getText(details.name)` and `getText(details.description)`.
- Uses OnGameBoot: yes.
- Uses OnInitWorld: no.
- Top-level direct registration: no, event-bound.
- getTrait duplicate guard: uses framework-managed registry and update paths.
- Mutual exclusions: yes, if details define excludes.
- B42-specific handling: not a versioned B42 folder sample, but it is strong API/timing evidence because it hooks the same vanilla `OnGameBoot` path.

## Sample 4: Bandits Week One, Build 42.18

- Mod path: `[LOCAL_PATH_REDACTED]`
- Mod ID: Bandits Week One
- Version directory: `42.18`
- Registration Lua: `42.18\media\lua\shared\NPCs\BWOTraits.lua`
- Environment: shared
- Registration timing: `Events.OnGameBoot.Remove(makeTr
[EXCERPT_TRUNCATED]
```

## BUILD_MARKER.txt

- SHA-256: `2FC596A4F109A19A2839FBBDF1594F902B33424AC564F4A6E464ACF78B946264`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_041_REG_FIX_A
0.4.1-native-trait-registration-fix-a
XNP_PZ_DISTANCE_RUNNER_TRAIT_0.4.1_REGISTRATION_FIX_SOURCE_CREATED

```

## CHANGELOG.md

- SHA-256: `0EC12181BF3556D0324E677F91A128E2E5C2B461D18B68E493516F6FBD9FF653`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# CHANGELOG

## 0.4.1-native-trait-registration-fix-a

- Copied 0.4.0 into an isolated 0.4.1 source directory.
- Kept `Mod ID=XNP_PZ_DistanceRunnerTrait`.
- Kept `Trait ID=XNPDistanceRunner`.
- Added `XNP_DR_TraitRegistration.lua` as a dedicated registration-only module.
- Moved trait registration to the locally evidenced B42 `Events.OnGameBoot` timing.
- Added `RegisterDistanceRunnerTrait()`, `VerifyDistanceRunnerTrait()`, and `GetDistanceRunnerTraitRegistrationStatus()`.
- Added explicit logs for TraitFactory availability, addTrait invocation, getTrait verification, and trait count before/after.
- Added English fallback strings so translation failure cannot block trait existence.
- Repaired EN/CN translation JSON files.
- Preserved gameplay runtime constants and core runtime file hashes for movement, metabolism, and training fatigue.


```

## FINAL_REPORT.md

- SHA-256: `53525D4108B012F1A93890C6DA4D26828719CF03007313292C82553F1B619A50`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.4.1

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

BASE_SOURCE_PATH=`[LOCAL_PATH_REDACTED]`

VERSION=`0.4.1`

BUILD_MARKER=`XNP_PZ_DISTANCE_TRAIT_041_REG_FIX_A`

MOD_ID=`XNP_PZ_DistanceRunnerTrait`

TRAIT_ID=`XNPDistanceRunner`

## 0.4.0 failure

0.4.0 failure position:

`NATIVE_TRAIT_REGISTRATION_NOT_VISIBLE_IN_CHARACTER_CREATION`

0.4.0 actual registration file:

`42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Trait.lua`

0.4.0 actual timing:

- top-level call once
- `Events.OnGameBoot.Add(Trait.Register)`

0.4.0 registration loading chain:

- shared file may auto-load
- client bootstrap requires `XNP_DR_Trait`
- runtime/state require `XNP_DR_Trait`

Confirmed 0.4.0 problem:

The registration code did not make `TraitFactory.getTrait("XNPDistanceRunner")` a hard success condition and did not provide enough pre-character-creation logs to distinguish API unavailable, addTrait failure, or getTrait nil.

See `TRAIT_REGISTRATION_FAILURE_AUDIT_0.4.0.md`.

## B42 samples

Found B42/local working evidence count: 4

Selected evidence:

- Vanilla `MainCreationMethods.lua`: `Events.OnGameBoot.Add(BaseGameCharacterDetails.DoTraits)`
- More Traits `42\media\lua\shared\NPCs\MoreTraitsMainCreationMethods.lua`: `Events.OnGameBoot.Add(initToadTraits)`
- ProfessionFramework: replaces vanilla trait setup through `Events.OnGameBoot`
- Bandits Week One `42.18`: comments and event binding show same 6-argument `TraitFactory.addTrait` timing pattern

SELECTED_TRAIT_REGISTRATION_TIMING=`Events.OnGameBoot`

REGISTRATION_TIMING_EVIDENCE=`Vanilla and closest Build 42 workshop sample register character-creation traits from shared Lua on Events.OnGameBoot before character creation list usage.`

## API parameters

TraitFactory actual signature used:

`TraitFactory.addTrait(type, name, cost, description, profession, removeInMP)`

API_COST_ARGUMENT=`1`

UI_EXPECTED_POINT_CHANGE=`-1`

COST_SIGN_EVIDENCE=`[LOCAL_PATH_REDACTED]`: positive list uses `trait:getCost() > 0`; negative list uses `trait:getCost() < 0`.

profession parameter=`false`

removeInMP parameter=`false`

## Registration verification

Before registration:

`TraitFactory.getTrait("XNPDistanceRunner")`

If existing:

`[XNP DISTANCE RUNNER] trait registration skipped reason=already_registered`

After registration:

`TraitFactory.getTrait("XNPDistanceRunner")`

Success log:

`[XNP DISTANCE RUNNER] trait registration verified id=XNPDistanceRunner cost=<n>`

Failure log:

`[XNP DISTANCE RUNNER] trait registration failed stage=<stage> reason=<reason>`

## Fallback display

English fallback name:

`Distance Runner`

English fallback description:

`Adapted to sustained running. Builds pace during continuous movement and converts part of the endurance cost into greater food, calorie and recovery demands. Excessive running can cause delayed training fatigue. X3 test build.`

Translation files:

- `42\media\lua\shared\Translate\EN\XNPDistanceRunnerTrait_EN.json`
- `42\media\lua\shared\Translate\CN\XNPDistance
[EXCERPT_TRUNCATED]
```

## INSTALL_REPORT.md

- SHA-256: `2AA309C7729A1813D7A72E7EF205EF7DBE722B9A17B610F646BE5BE841D85773`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# INSTALL REPORT

## Intended install target

`[LOCAL_PATH_REDACTED]`

## Result

`INSTALL_PERMISSION_BLOCKED`

The copy operation to the Project Zomboid user mods directory required permission outside the current writable workspace. The approval request timed out. No install copy was completed.

## Current target state

`[LOCAL_PATH_REDACTED]`

exists: `false`

## Manual copy source

`[LOCAL_PATH_REDACTED]`

## Important Mod ID warning

0.4.0 and 0.4.1 use the same Mod ID:

`XNP_PZ_DistanceRunnerTrait`

Before testing 0.4.1, disable or move out 0.4.0. Do not enable both versions at the same time.

## Safety statement

- Did not start Project Zomboid.
- Did not start Steam.
- Did not write to the game install directory.
- Did not modify workshop files.
- Did not overwrite 0.4.0.


```

## README_CN.md

- SHA-256: `C545D3ACB227D60FF3E10388FD628FFD12A4224623C0AADDCDF6E7C111538034`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.4.1 Registration Fix

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

This branch is copied from 0.4.0 and only repairs the native Build 42 trait registration chain.

## Identity

- Version: `0.4.1`
- Internal version: `0.4.1-native-trait-registration-fix-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_041_REG_FIX_A`
- Display name: `XNP Distance Runner Trait 0.4.1 Registration Fix`
- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait ID: `XNPDistanceRunner`

The Mod ID and Trait ID are intentionally unchanged. This fixes registration instead of dodging it with a new ID.

## What changed from 0.4.0

- Added a dedicated early shared registration module:
  `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TraitRegistration.lua`
- Registration now follows local B42 evidence:
  `Events.OnGameBoot.Add(RegisterDistanceRunnerTrait)`
- Registration verifies itself with:
  `TraitFactory.getTrait("XNPDistanceRunner")`
- Registration logs begin/API/addTrait/verify/count stages before character creation.
- Translation can no longer block registration because English fallback strings are passed to `TraitFactory.addTrait` if `getText` fails.

## What did not change

- X3 factor remains `3.00`.
- Run trigger remains `0.50` seconds.
- Stop reset remains `1.00` second.
- Movement, metabolism, training fatigue, XP disabled state, HUD state, emergency reset, and single-player restriction are unchanged except for registration dependency ordering.

## Manual test warning

0.4.0 and 0.4.1 use the same Mod ID. Before testing 0.4.1, disable or move out 0.4.0. Do not enable both at the same time.


```

## TRAIT_REGISTRATION_TEST_0.4.1.md

- SHA-256: `C361AA07AA137BADBBDC64CE924918463D8AC03C5BA9D21A3DAD26DBAFBE9CB3`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# TRAIT REGISTRATION TEST 0.4.1

## Before testing

0.4.0 and 0.4.1 use the same Mod ID:

`XNP_PZ_DistanceRunnerTrait`

Disable or move out 0.4.0 before enabling 0.4.1. Do not enable both at once.

## Test flow

1. Disable or move out 0.4.0.
2. Install and enable 0.4.1.
3. Fully quit and restart Project Zomboid.
4. Create a new character.
5. Enter `Select Occupation and Traits`.
6. Search available traits for:
   - `Distance Runner`
   - `闀块€斿琚€卄
   - `XNPDistanceRunner`
7. Confirm the trait exists.
8. Add the trait.
9. Confirm available points decrease by 1.
10. Remove the trait.
11. Confirm 1 point is returned.
12. Add it again and create the character.
13. After entering the world, run directly.

## If step 7 fails

Do not enter the world. Extract `console.txt` lines containing:

- `[XNP DISTANCE RUNNER]`
- `XNPDistanceRunner`
- `TraitFactory`
- `ERROR`

## First acceptance marker

`TRAIT_VISIBLE_IN_CHARACTER_CREATION`


```

## TRAIT_UI_TEST_PLAN.md

- SHA-256: `4306B9E5B5186CDFF6BF176046FD5094846CD9C3CFE2BBDD2F17DA440F34C8FF`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# TRAIT UI TEST PLAN 0.4.1

Use `TRAIT_REGISTRATION_TEST_0.4.1.md` as the primary test plan.

Minimum acceptance:

`TRAIT_VISIBLE_IN_CHARACTER_CREATION`

Do not proceed to X3 runtime testing until the trait is visible in the vanilla character creation available-traits list and adding it reduces available points by 1.


```

## LOCAL_B42_TRAIT_API_AUDIT.md

- SHA-256: `C432E187EB6C9ECD04BCA78B692DC869695CDFBCB39A35B73F989E6CCCA7E129`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# LOCAL B42 TRAIT API AUDIT 0.4.1

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Local evidence roots

- Project Zomboid: `[LOCAL_PATH_REDACTED]`
- Workshop: `[LOCAL_PATH_REDACTED]`
- User mods scanned read-only: `[LOCAL_PATH_REDACTED]`

## Confirmed character creation list source

File:

`[LOCAL_PATH_REDACTED]`

Evidence:

- Available positive traits are read from `CharacterTraitDefinition.getTraits()`.
- Positive list condition: `trait:getCost() > 0`.
- Negative list condition: `trait:getCost() < 0`.

Conclusion:

`API_COST_ARGUMENT=1` should consume 1 character creation point.

## Confirmed registration timing

File:

`[LOCAL_PATH_REDACTED]`

Evidence:

- Vanilla binds `BaseGameCharacterDetails.DoTraits` to `Events.OnGameBoot`.

Closest B42 workshop sample:

`[LOCAL_PATH_REDACTED]`

Evidence:

- Custom traits are registered in a shared Lua function bound with `Events.OnGameBoot.Add(initToadTraits)`.
- Calls use `TraitFactory.addTrait(id, getText(name), cost, getText(desc), false, false)`.
- Positive examples use positive cost values.
- Negative examples use negative cost values.
- The function calls `TraitFactory.sortList()`.

Selected timing:

`SELECTED_TRAIT_REGISTRATION_TIMING=Events.OnGameBoot`

## Confirmed addTrait signature

From local workshop evidence:

`TraitFactory.addTrait(type, name, cost, description, profession, removeInMP)`

0.4.1 uses:

`TraitFactory.addTrait("XNPDistanceRunner", name, 1, description, false, false)`

## Translation safety

0.4.1 passes English fallback strings if `getText` returns nil, an empty string, or the untranslated key. Translation failure can affect display language but cannot block trait registration.

## Verification

0.4.1 requires post-registration verification:

`TraitFactory.getTrait("XNPDistanceRunner")`

If this returns nil, status becomes `MISSING` and the log reports:

`trait registration failed stage=verify reason=getTrait_returned_nil`

## Static limits

- Real character creation visibility is `NOT_VERIFIABLE_BY_STATIC_AUDIT`.
- Real point consumption is `NOT_VERIFIABLE_BY_STATIC_AUDIT`.
- No game executable was started.


```

## STATIC_AUDIT.md

- SHA-256: `5B1671F1EF19F25CF9A2018A341AB557796DEF4BC73A671344D0BEF720949EC2`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# STATIC AUDIT 0.4.1

SOURCE_OUTPUT_PATH=`[LOCAL_PATH_REDACTED]`

## Counts

- Lua files: 13
- Lua total lines: 914
- Document/text files: 11
- Total files: 28

## Layout

- root `mod.info`: present
- `42\mod.info`: present
- `42\media\lua\shared`: present
- `42\media\lua\client`: present
- `42\media\lua\shared\Translate\EN`: present
- `42\media\lua\shared\Translate\CN`: present
- root `media\lua`: absent
- `common`: absent
- Java: absent

## Registration module

- File: `42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_TraitRegistration.lua`
- Environment: shared
- Scope: registration, verification, duplicate guard, logs only.
- Does not run movement, endurance, nutrition, HUD, training fatigue, or player detection.
- Exposes:
  - `RegisterDistanceRunnerTrait()`
  - `VerifyDistanceRunnerTrait()`
  - `GetDistanceRunnerTraitRegistrationStatus()`
- Timing: `Events.OnGameBoot`
- Duplicate guard: `TraitFactory.getTrait("XNPDistanceRunner")` before `addTrait`.
- Post-registration verification: hard `TraitFactory.getTrait("XNPDistanceRunner")` check.
- Failure status if nil: `MISSING`, reason `getTrait_returned_nil`.

## Runtime restrictions

Runtime Lua scan:

- `XNP_PZ_SkillCore`: absent
- `getModData(`: absent
- `available_points`: absent
- `spent_points`: absent
- `UnlockSkill`: absent
- `ThePlayer`: absent
- `OnInitWorld`: absent
- `TraitFactory.Reset`: absent
- `AddPlayerPostInit`: absent
- local absolute game/user paths in runtime Lua: absent

## Translation checks

- EN JSON: valid
- CN JSON: valid
- BOM: none detected
- NULL: none detected
- Empty files: none
- Registration uses English fallback strings if `getText` fails.

## Lua syntax checks

- `lua`: NOT_VERIFIABLE, no local command found.
- `luac`: NOT_VERIFIABLE, no local command found.
- Text balance scan: PASS after repairing damaged copied CN string in `XNP_DR_Constants.lua`.

## Gameplay hash comparison

RUNTIME_GAMEPLAY_CORE_CHANGED=`NO`

Unchanged from 0.4.0 by SHA256:

- `XNP_DR_Movement.lua`
- `XNP_DR_Metabolism.lua`
- `XNP_DR_TrainingFatigue.lua`
- `XNP_DR_XP.lua`
- `XNP_DR_HUD.lua`

Only registration/identity/bootstrap dependency files changed.

## B42 API confirmation

- `TraitFactory.addTrait` signature evidence: 6 parameters in local workshop samples.
- Cost sign evidence: vanilla character creation puts `trait:getCost() > 0` in the positive list.
- Selected timing: `Events.OnGameBoot`.
- Sample matrix: see `B42_TRAIT_WORKING_SAMPLE_MATRIX.md`.

## BLOCKER

No static blocker found.


```
