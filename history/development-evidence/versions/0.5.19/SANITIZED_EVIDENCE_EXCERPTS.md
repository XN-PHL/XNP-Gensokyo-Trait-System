# 0.5.19 Sanitized Evidence Excerpts

## 0.5.19_REAL_GAME_FAILURE_ANALYSIS_FROM_0.5.18.md

- SHA-256: `C2DE62125FB70E9B3E106306680D1EEFED28FEC21830952D6E316BAF58754BF7`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 Real Game Failure Analysis From 0.5.18

0.5.18 real game result:

- Mod package loaded.
- Build marker was visible.
- Player trait check reported inactive.
- Runtime icon and effect logs did not enter the expected active path.

Frozen conclusion:

- The primary blocker is activation, not balance.
- The working route must roll back to the 0.5.17 source as baseline.
- 0.5.18 is only used for minimal balance patch concepts after activation is recovered.

0.5.19 target:

- Restore 0.5.17 runtime loading chain.
- Add first-class activation diagnostic logging.
- Preserve the working status icon path.
- Add only the minimal 0.5.18 balance guard layer.

Status:

- ACTIVATION_STATUS=FIRST_CLASS_BLOCKER
- BALANCE_STATUS=MINIMAL_PATCH_AFTER_ACTIVATION_RESCUE
- ICON_FEATURE_STATUS=RESTORE_0_5_17_WORKING_ROUTE

```

## 0.5.19_ACTIVATION_DIAGNOSTIC_DESIGN.md

- SHA-256: `25525E3189A63420EC50C7544DDF21667BAF7F2A3631091A79E32A670D7EC62B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 Activation Diagnostic Design

New module:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActivationDiagnostic.lua`

Required log prefix:

`[XNP ACTIVATION]`

Logged fields:

- build marker
- mod_loaded
- player_found
- trait_registered
- expected full trait id
- expected short trait id
- expected module id
- detector method
- has_trait_object
- has_trait_full
- has_trait_short
- has_trait_any_alias
- active
- fail reason
- help message when inactive

Trait detector:

- Uses object-style trait collection checks.
- Scans trait aliases from player trait objects when available.
- Does not use the old string-only player helper route.

Inactive handling:

- Runtime logs active=false with reason.
- Status icon module may show the inactive debug icon when configured.
- Effects do not run for inactive players.

```

## 0.5.19_ICON_0517_ROUTE_RESTORE.md

- SHA-256: `0F795D23DC78A9F1DCB9006EFEDAE8C548AE718708D5E96B8B2D1C4AFCDAFC77`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 Icon 0.5.17 Route Restore

Status:

- ICON_FEATURE_STATUS=RESTORE_0_5_17_WORKING_ROUTE
- MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
- HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- TEXT_FALLBACK_STATUS=DEBUG_ONLY_NOT_MAIN_UI

Implementation:

- `XNP_DR_StatusIconUI.lua` keeps the 0.5.17 panel/texture route.
- Startup logs identify the recovered route.
- The texture path remains under `media/ui/Traits/trait_xnpdistancerunner.png`.
- Border, shake, slot sort and panel creation logic remain available.

Inactive debug behavior:

- If the player does not have the target trait, the module may still create a debug icon.
- Required log: `[XNP STATUS ICON] inactive_debug_icon=true reason=PLAYER_DOES_NOT_HAVE_TRAIT`
- This is diagnostic only and does not enable effects.

```

## 0.5.19_MINIMAL_BALANCE_PATCH_FROM_0518.md

- SHA-256: `F3D75FE2FD4F72C45A30C84EE1936823E313A6CB1267F06642D1770BD8877E67`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 Minimal Balance Patch From 0.5.18

Patch source:

- 0.5.18 concepts only.
- Not a 0.5.18 baseline copy.

Added guard modules:

- `XNP_DR_DragdownDangerClassifier.lua`
- `XNP_DR_BreakoutActionBus.lua`

Balance intent:

- Normal movement plus close two-zombie proximity does not auto knock down.
- Single-zombie shove/contact does not auto knock down.
- ActionBus blocks same-frame duplicate actions.
- Same-target cooldown prevents repeated hard effects.
- ASSIST profile is stagger-only.
- TRUE_EMERGENCY profile may use stronger emergency response.

Protected behavior:

- no_bite
- no_infection
- no_heal
- no_damage_rollback
- no_player_coordinate_write
- no_game_time_change

Sprint route:

- 0.5.17 sprint route remains the main route.
- Minimal balance guard uses ActionBus without replacing the route.

```

## 0.5.19_RUNTIME_STARTUP_AND_UPDATE_REGISTRATION.md

- SHA-256: `901E2A21B8E9F4989BF7124AE8D1940BFB4D8859868EA40EC43E6A4393D598DB`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.19 Runtime Startup And Update Registration

Bootstrap file:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua`

Startup logs:

- `[XNP DR] BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0519_ACTIVATION_RESCUE_WORKING_ROUTE_A`
- Config loaded log remains present through the existing constants/config path.
- Runtime module startup logs are enabled.

Module startup coverage:

- StatusIconUI
- EmergencyInput
- EmergencyBreakout
- DragdownDangerBreakout
- DragdownDangerClassifier
- BreakoutActionBus
- BreakoutPush
- SprintTripImmunity
- ActivationDiagnostic

Update registration:

- Runtime update is registered on `Events.OnPlayerUpdate`.
- Registration log: `[XNP RUNTIME] update_registered=true event=OnPlayerUpdate`

Runtime active/inactive behavior:

- Activation diagnostic runs during player update.
- Active players run the restored 0.5.17 module route plus minimal balance guards.
- Inactive players log reason and may show the debug icon.

```

## 0.5.19_TEST_PLAN.md

- SHA-256: `8E1589867473F502EF38B793BE8E005864E2EE1CABE5067765187FA40A7CAC1E`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.19 Test Plan

Install manually:

- User copies the SOURCE to the test mods location.
- Codex does not install, package, or launch the game.

Test 1: load confirmation

- Console must show build marker `XNP_PZ_DISTANCE_TRAIT_0519_ACTIVATION_RESCUE_WORKING_ROUTE_A`.
- Console must show Config loaded.
- Console must show runtime module startup logs.
- Console must show update registration.

Test 2: activation diagnostic

- Create or load a character with the target trait.
- Confirm `[XNP ACTIVATION] active=true`.
- If active=false, inspect expected trait ids and reported player trait names.

Test 3: icon route

- Confirm status icon route logs `RECOVERED_ICON_ROUTE_0517_RESTORED`.
- Confirm texture loaded log appears.
- If trait inactive, confirm inactive debug icon log appears.

Test 4: runtime route

- Sprint toward zombie contact and confirm restored sprint route logs.
- Trigger emergency/dragdown situations and confirm emergency/dragdown logs.
- Confirm ActionBus logs appear when duplicate actions are blocked.

Test 5: minimal balance

- Normal movement near one or two zombies should not immediately hard-trigger.
- ASSIST should stay stagger-only.
- TRUE_EMERGENCY should remain reserved for controlled or dangerous close contact.

Expected final status:

- Activation restored first.
- Balance judged only after activation and icon/runtime logs are visible.

```

## BUILD_MARKER.txt

- SHA-256: `4F75390682426F025D90F7E75B91C19BDC5E98EB70E82BBCC1A6DFD360714209`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0519_ACTIVATION_RESCUE_WORKING_ROUTE_A

```

## FINAL_REPORT.md

- SHA-256: `CA09068E2EA764B3BC3A25378E4C661E58D7532A5E51E9B1CBC965F770F70E01`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.19
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0519_ACTIVATION_RESCUE_WORKING_ROUTE_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.19 Activation Rescue Working Route

Baseline:

- Primary baseline: 0.5.17 working source.
- Minimal patch source: 0.5.18 balance guard concepts only.
- 0.5.18 inactive activation route was not used as baseline.

Implemented:

- Activation diagnostic module added.
- Trait detector expanded to object collection plus alias scanning.
- Runtime startup module logs added.
- Update registration log added.
- 0.5.17 status icon route restored.
- Inactive debug icon path added for activation diagnosis.
- 0.5.17 sprint/emergency/dragdown route retained.
- ActionBus and classifier added as minimal balance guards.
- Normal proximity is separated from true emergency handling.

Counts:

- Total files: 43
- Lua files: 25
- Lua total lines: 5399
- Markdown files: 11

Safety:

- Project Zomboid launched: NO
- Steam launched: NO
- User mods written: NO
- Saves written: NO
- Workshop written: NO
- Game install directory written: NO
- Old SOURCE modified: NO
- Packaging performed: NO

Feature status:

- ACTIVATION_STATUS=FIRST_CLASS_BLOCKER
- BALANCE_STATUS=MINIMAL_PATCH_AFTER_ACTIVATION_RESCUE
- ICON_FEATURE_STATUS=RESTORE_0_5_17_WORKING_ROUTE
- MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
- HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
- TEXT_FALLBACK_STATUS=DEBUG_ONLY_NOT_MAIN_UI

Not verifiable by static audit:

- Real game activation.
- Actual icon rendering.
- Actual zombie/player interaction timing.
- Actual balance feel.

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.19_SOURCE_READY_FOR_ACTIVATION_RESCUE_TEST

```

## 0.5.19_BASELINE_SELECTION_AND_ROLLBACK_AUDIT.md

- SHA-256: `7B9124AA63AC159DC060CD46E817460E29C24B6FDC64237A1456D11775FC10EA`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 Baseline Selection And Rollback Audit

Baseline decision:

- Source baseline: 0.5.17 working source.
- Patch source: 0.5.18 balance-only concepts.
- 0.5.18 activation route is not used as baseline.

Reason:

- 0.5.17 had the working icon/runtime route.
- 0.5.18 loaded but failed active trait/runtime behavior in real game.
- A full 0.5.18 forward-port would risk preserving the inactive path.

Rollback scope:

- 0.5.17 loading chain retained.
- 0.5.17 status icon route retained.
- 0.5.17 sprint/emergency/dragdown modules retained.
- 0.5.18 classifier and action bus added as limited balance guards.

Old source policy:

- No old SOURCE directory was modified.
- 0.5.19 is an independent directory under [LOCAL_PATH_REDACTED]

```

## 0.5.19_FILE_COUNT_AND_COPY_SCOPE_AUDIT.md

- SHA-256: `64D691BCC33AED647745FEED4936832F363B1CDB67E7D0B6106632EA88967BCA`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 File Count And Copy Scope Audit

Source path:

`[LOCAL_PATH_REDACTED]`

Observed baseline counts:

- 0.5.17 source files before copy: 40
- 0.5.18 source files before patch extraction: 42

0.5.19 expected static count after documentation:

- Total files: 43
- Lua files: 25
- Lua total lines: 5399
- Markdown files: 11

Copy scope:

- Full directory copied from 0.5.17 into the new 0.5.19 SOURCE.
- Two balance modules copied from 0.5.18 into 0.5.19.
- One activation diagnostic module added in 0.5.19.
- Old 0.5.17 markdown reports removed from the 0.5.19 SOURCE and replaced with 0.5.19 reports.

Write scope:

- No user mods directory write.
- No saves write.
- No Workshop write.
- No game install directory write.
- No old SOURCE modification.

```

## 0.5.19_TRAIT_DETECTOR_ALIAS_AUDIT.md

- SHA-256: `A07797F8A3E884D0411421DDBF7E5D9C4AB6DF9018306AC955861BC212D8C1D2`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 Trait Detector Alias Audit

Expected trait ids:

- Full id: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- Short id: `XNPDistanceRunner`
- Module id: `XNPDistanceRunnerTrait`

Detector implementation:

- `XNP_DR_Trait.lua` keeps an alias list.
- Collection membership is checked when the game exposes object collections.
- Object names are extracted through safe method probes.
- A debug snapshot is exposed for activation diagnostics.

Accepted result fields:

- object_found
- alias_found
- matched_alias
- detector_method

Static decision:

- Object-style and alias collection scanning is the current route.
- Legacy string helper detection remains absent.

```

## STATIC_AUDIT.md

- SHA-256: `76A42A36B2C7E3034A89689659F684B038CB944A2B56CB6D95709CEF67C94EEC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.19 Static Audit

Source:

`[LOCAL_PATH_REDACTED]`

Identity:

- VERSION=0.5.19
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0519_ACTIVATION_RESCUE_WORKING_ROUTE_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.19 Activation Rescue Working Route

File counts:

- Total files: 43
- Lua files: 25
- Lua total lines: 5399
- Markdown files: 11

Static checks:

- Old SOURCE modified: NO
- Game launched: NO
- Steam launched: NO
- User mods written: NO
- Saves written: NO
- Workshop written: NO
- Game install directory written: NO
- Packaging performed: NO

Required grep results:

- Build marker present: PASS
- Activation diagnostic log prefix present: PASS
- Runtime startup module logs present: PASS
- Update registration log present: PASS
- 0.5.17 icon route restore log present: PASS
- Texture load log present: PASS
- Inactive debug icon log present: PASS
- Emergency runtime route present: PASS
- Dragdown runtime route present: PASS
- ActionBus runtime route present: PASS
- Classifier minimal balance patch present: PASS
- Sprint route preservation log present: PASS
- no_bite/no_infection/no_heal policy documented: PASS
- Forbidden exact runtime calls scan: PASS
- Large copy audit completed: PASS

Lua structure scan:

- Parenthesis count mismatch: none found.
- UTF-8 BOM in Lua files: none found.
- NULL bytes in Lua files: none found.
- Lua interpreter execution: NOT_RUN_BY_POLICY

Runtime verification:

- Real game behavior: NOT_VERIFIABLE_BY_STATIC_AUDIT
- Activation recovery: REAL_GAME_TEST_REQUIRED

Final static status:

STATIC_AUDIT_PASS_WITH_REAL_GAME_TEST_REQUIRED

```
