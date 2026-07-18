# 0.5.18 Sanitized Evidence Excerpts

## 0.5.18_ACTION_BUS_DOUBLE_TRIGGER_FIX.md

- SHA-256: `9660BB57B90A798B9D560EBB52677AC6178299C41D014435594B7F3ED04B7BF0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.18 ActionBus Double Trigger Fix

Runtime module:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus.lua`

Purpose:

- One primary action per frame/window for the same target batch.
- Shared cooldown between Sprint, Emergency, and Dragdown routes.
- Same target knockdown cooldown.
- Same target stagger cooldown.
- Prevent Dragdown and Emergency from hitting the same zombies in the same danger window.

Expected logs:

- `[XNP ACTION BUS] enabled=true`
- `[XNP ACTION BUS] accepted source=DRAGDOWN level=TRUE_EMERGENCY action_id=...`
- `[XNP ACTION BUS] blocked source=EMERGENCY reason=ACTION_ALREADY_HANDLED_THIS_WINDOW`
- `[XNP ACTION BUS] blocked target=... reason=RECENTLY_KNOCKED`
- `[XNP ACTION BUS] window_reset reason=DANGER_CLEARED`

```

## 0.5.18_ASSIST_VS_TRUE_EMERGENCY_EFFECT_PROFILES.md

- SHA-256: `D61E9DF6CA482AA2417E17A406BB00AAA2C676AD25C4E5E1AC5EFC4B70BDF648`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.18 Assist Vs True Emergency Effect Profiles

WARNING_ONLY:

- Effect: none.
- Cost: none.
- Player cancel: no.

ASSIST:

- Effect: STAGGER_ONLY.
- Max targets: 2.
- Player cancel: false.
- No knockdown-capable API.
- Allows zombies to continue applying pressure after a short interruption.

TRUE_EMERGENCY:

- Effect: MIXED_STAGGER_KNOCKDOWN.
- Max targets: 6.
- Inner-ring targets may use verified stagger knockdown.
- Outer-ring targets use stagger-only.
- Player cancel only when down/getup/knocked/bumped.

Expected logs:

- `[XNP EFFECT PROFILE] level=WARNING_ONLY effect=NONE`
- `[XNP EFFECT PROFILE] level=ASSIST effect=STAGGER_ONLY max_targets=2 player_cancel=false`
- `[XNP EFFECT PROFILE] level=TRUE_EMERGENCY effect=MIXED_STAGGER_KNOCKDOWN player_cancel=true`

```

## 0.5.18_DANGER_CLASSIFICATION_REDESIGN.md

- SHA-256: `ABDC2E8734B805FC3AB825FA03D95DE6622A2C274104FE971648462EEAA13795`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.18 Danger Classification Redesign

Runtime module:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerClassifier.lua`

Levels:

- SAFE: no effect.
- WARNING_ONLY: icon warning only.
- ASSIST: input/control assisted stagger-only.
- TRUE_EMERGENCY: real fatal-window rescue.

Important guarantees:

- Normal movement plus two close zombies is WARNING_ONLY.
- WARNING_ONLY cannot auto knockdown.
- ASSIST cannot use knockdown-capable route.
- TRUE_EMERGENCY requires down/getup/control state, fatal close ring, or hard override with four inner-ring zombies.

Expected logs:

- `[XNP DANGER CLASSIFIER] enabled=true`
- `[XNP DANGER CLASSIFY] level=WARNING_ONLY reason=NEARBY_BUT_NOT_CONTROLLED`
- `[XNP DANGER SUMMARY] warning=... assist=... true_emergency=... fatal=... window_frames=60`

```

## 0.5.18_MANUAL_SHOVE_AND_SINGLE_ZOMBIE_GUARD.md

- SHA-256: `0F9C2C7FB127CBF45560276A5B94CEBEB40A7117A0745D3867BA2525BFBDF420`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.18 Manual Shove And Single Zombie Guard

Goals:

- Normal standing plus one zombie plus input must not become emergency knockdown.
- Manual shove context must not upgrade to emergency knockdown.
- Distance alone is not enough to classify a zombie as controlling the player.

Runtime behavior:

- Single close zombie without player control state is SAFE or blocked.
- Two nearby zombies during normal movement become WARNING_ONLY.
- ASSIST can provide stagger-only space when there is input or bumped/collided evidence.

Expected logs:

- `[XNP CONTROLLED CHECK] result=false reason=CLOSE_SINGLE_ZOMBIE_NOT_CONTROL`
- `[XNP MANUAL SHOVE GUARD] blocked_emergency_knockdown=true reason=VANILLA_SHOVE_CONTEXT`
- `[XNP EMERGENCY BREAKOUT] blocked reason=NOT_CONTROLLED_ENOUGH`
- `[XNP ASSIST PUSH] effect=stagger_only reason=SOFT_CONTACT`

```

## 0.5.18_NO_AURA_ZOMBIES_CAN_REENTER_BALANCE.md

- SHA-256: `A1CBE880A4C6F062D156A224C45FF60FA8F3D5DAD92551DDE890FA6BFA7BAC2E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.18 No Aura Zombies Can Reenter Balance

0.5.18 must not create a permanent close-range expulsion aura.

Implemented balance:

- WARNING_ONLY has no physical effect.
- ASSIST has short stagger-only interruption.
- TRUE_EMERGENCY is limited by ActionBus and target cooldowns.
- Same target knockdown cooldown: 4.0 seconds.
- Same target stagger cooldown: 1.25 seconds.
- Dragdown window cooldown: 2.5 seconds.
- Fatal window cooldown: 1.5 seconds.

Expected logs:

- `[XNP BALANCE] no_aura=true`
- `[XNP BALANCE] zombies_can_reenter=true`
- `[XNP BALANCE] same_target_knockdown_blocked target=... remaining=...`
- `[XNP BALANCE] danger_window_cooldown active=true`

```

## 0.5.18_REAL_GAME_BALANCE_ANALYSIS_FROM_0.5.17.md

- SHA-256: `E0AA892B24E721FE853C4E053173CF07CD3F8FC750BEB5A4FE3FF2B1A712E436`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.18 Real Game Balance Analysis From 0.5.17

0.5.17 confirmed the recovered status icon route and first-wave sprint impact route, but real-game testing showed the emergency/dragdown system became too strong.

Confirmed problems:

- Normal movement with two close zombies could become automatic dragdown.
- Automatic dragdown used knockdown-capable effects too early.
- Emergency and Dragdown could both act in the same danger window.
- Repeated triggers made zombies unable to re-enter player space.
- Normal push/contact could feel like guaranteed knockdown.

0.5.18 response:

- Add three danger levels: WARNING_ONLY, ASSIST, TRUE_EMERGENCY.
- WARNING_ONLY has no physical effect.
- ASSIST is stagger-only, limited target count, no player cancel.
- TRUE_EMERGENCY keeps knockdown-capable rescue for real fatal windows.
- Add ActionBus shared arbitration to prevent duplicate same-frame/window actions.
- Keep recovered icon route and calibrate anchor/state behavior.

ICON_FEATURE_STATUS=KEEP_RECOVERED_ROUTE_CALIBRATE_ONLY
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
TEXT_FALLBACK_STATUS=DEBUG_ONLY_NOT_MAIN_UI
BALANCE_STATUS=VANILLA_BALANCED_NOT_OBVIOUS_INVINCIBLE

```

## 0.5.18_SPRINT_ROUTE_KEEP_NOT_BUFF.md

- SHA-256: `ACAE1ABABA5D56449E1D7A45B5060F3C18C95D1C8F2F380D9626D873A6EFEA6F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.18 Sprint Route Keep Not Buff

0.5.18 keeps the 0.5.17 first-wave sprint impact feel.

Kept:

- `SPRINT_PRECOLLISION`
- verified stagger knockdown route
- first-wave multi-zombie impact feel
- player can still fall; this is not 100 percent immunity

Changed:

- Sprint route is registered with ActionBus.
- Sprint route cannot duplicate the same target batch with Dragdown in the same window.
- TOO_LATE-style logs are expected to be summarized rather than spammed.

Expected logs:

- `[XNP SPRINT ROUTE] preserved=true`
- `[XNP SPRINT ROUTE] balance=FIRST_WAVE_IMPACT_KEEP`
- `[XNP SPRINT ROUTE] action_bus=true`

```

## 0.5.18_STATUS_ICON_KEEP_AND_CALIBRATE.md

- SHA-256: `C83697D2F05E84B1CA13EEF144B0C3D155A6E6ED8255957C0A83116AA76C3B8F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.18 Status Icon Keep And Calibrate

0.5.17 status icon route is kept.

Kept behavior:

- RECOVERED_ICON_ROUTE
- texture loaded path: `media/ui/Traits/trait_xnpdistancerunner.png`
- border
- state color
- danger shake
- slot_sort
- debug-only text fallback status

0.5.18 changes:

- Anchor is named and configured as `RIGHT_TOP_TRAIT_ADJACENT`.
- Offsets and slot gap are exposed in config.
- Default position preserves the observed 0.5.17 right-top slot stack.
- selected_slot logging remains change-only.
- State shake is limited to TRUE_EMERGENCY, not ordinary nearby zombies.

User observation recorded:

The icon is not a simple overlap failure. It appears near the vanilla trait/status icon column, likely adjacent to the original UI stack. 0.5.18 calibrates this route instead of replacing it.

```

## 0.5.18_TEST_PLAN.md

- SHA-256: `BE665E169D60F97A092185F5E3380957F2166D0B814FC91B51F9378F1DBB1E7B`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.18 Test Plan

1. Confirm startup:
   - `XNP_PZ_DISTANCE_TRAIT_0518_VANILLA_BALANCED_DRAGDOWN_ICON_A`
   - `[XNP STATUS ICON] method=RECOVERED_ICON_ROUTE`
   - `[XNP STATUS ICON] anchor=RIGHT_TOP_TRAIT_ADJACENT`
   - `[XNP DANGER CLASSIFIER] enabled=true`
   - `[XNP ACTION BUS] enabled=true`

2. Icon:
   - Small circular icon remains visible.
   - No yellow text fallback.
   - Border, color, slot sort remain.
   - Shake only during TRUE_EMERGENCY.

3. Normal standing plus one zombie plus input:
   - No emergency knockdown.
   - Expected blocked or stagger-only behavior.

4. Normal movement plus two close zombies:
   - WARNING_ONLY.
   - No automatic knockdown.
   - Zombies can continue to approach.

5. Bumped/collided plus two zombies:
   - ASSIST can trigger.
   - Stagger-only, max 1 to 2 targets.

6. Down/getup/fatal surrounded:
   - TRUE_EMERGENCY can trigger.
   - Mixed stagger knockdown.
   - ActionBus prevents duplicate same-window action.

7. Sprint impact:
   - First-wave sprint knockdown feel remains.
   - Player can still fall.
   - No duplicate Dragdown hit on same target batch.

```

## BUILD_MARKER.txt

- SHA-256: `8C2B5B67D249E2ED6A77456FA33DB569D72AEEB583F8DBFF1E9BD2C697D5DF11`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0518_VANILLA_BALANCED_DRAGDOWN_ICON_A

```

## FINAL_REPORT.md

- SHA-256: `A0D79021EE4A5A94C76377A2B90F3E06231441896E1037C7EEEE7544A5721F41`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.18

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.18
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0518_VANILLA_BALANCED_DRAGDOWN_ICON_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.18 Vanilla Balanced Dragdown Icon

## Changed Files

- `BUILD_MARKER.txt`
- `mod.info`
- `42/mod.info`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_StatusIconUI.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakout.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerClassifier.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ShoulderImpact.lua`
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_VanillaImpact.lua`
- 0.5.18 design/audit/test markdown files

## Problem Handling

- Right-top icon: KEEP
- Icon color: KEEP
- Icon shake/slot_sort: KEEP
- Icon placement calibration: YES
- Zombies unable to re-enter after repeated triggers: FIXED
- Normal push guaranteed knockdown: FIXED
- Normal movement plus two close zombies automatic knockdown: FIXED
- Emergency/Dragdown double trigger: FIXED

## Icon

- recovered route: YES
- texture loaded route: YES
- text fallback main UI: NO
- anchor mode: RIGHT_TOP_TRAIT_ADJACENT
- selected_slot log on change only: YES

## Danger Classification

- WARNING_ONLY: YES
- ASSIST: YES
- TRUE_EMERGENCY: YES
- normal movement plus close two only warning: YES

## Effect Profiles

- WARNING_ONLY no effect: YES
- ASSIST stagger-only: YES
- TRUE_EMERGENCY mixed knockdown: YES
- normal single zombie no knockdown: YES
- manual shove guard: YES

## ActionBus

- Runtime connected: YES
- Same-frame double action block: YES
- same target knockdown cooldown: 4.0
- danger window cooldown: 2.5
- no aura: YES
- zombies can reenter: YES

## Sprint Route

- 0.5.17-style sprint route kept: YES
- verified stagger knockdown still used: YES
- duplicate Dragdown hit avoided: YES

## Low Stamina Cost

- endurance cost: YES
- debt: YES
- wound fallback: YES
- no bite: YES
- no infection: YES
- no heal: YES

## Audits

- forbidden grep result: PASS
- old version active grep result: PASS
- previous SOURCE modified: NO
- game launched: NO
- Steam launched: NO
- user mods written: NO
- saves written: NO
- Workshop written: NO
- game directory written: NO

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.18_SOURCE_READY_FOR_BALANCE_TEST

```

## STATIC_AUDIT.md

- SHA-256: `7486ECBA30DE0CE70464DBD2B09B697640843F7166519F523F5270484B489DDC`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.18

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.18
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0518_VANILLA_BALANCED_DRAGDOWN_ICON_A

## Source Safety

- New independent SOURCE created: YES
- Previous SOURCE modified: NO
- Game launched: NO
- Steam launched: NO
- User mods written: NO
- Saves written: NO
- Workshop written: NO
- Game install directory written: NO
- Package/install action: NO

## File Counts

- Lua files: 24
- Lua total lines: 4898
- Markdown docs: 11
- Lua execution syntax check: NOT_VERIFIABLE_STATIC_ENV_NO_LUA

## Old Version Active Grep

- 0511 active marker: PASS, no active marker in runtime
- 0512 active marker: PASS, no active marker in runtime
- 0513 active marker: PASS, no active marker in runtime
- 0514 active marker: PASS, no active marker in runtime
- 0515 active marker: PASS, no active marker in runtime
- 0516 active marker: PASS, no active marker in runtime
- 0517 active marker: PASS, no active marker in runtime
- Historical docs may mention previous behavior by version number.

## Forbidden Route Grep

- Forbidden legacy route fixed-string scan: PASS, no matches
- Player coordinate write fixed-string scan: PASS, no matches
- Game time mutation route scan: PASS, no matches
- Text/halo route helper scan: PASS, no matches
- Old no-texture text fallback main UI scan: PASS, no matches

## Icon

- Recovered icon route retained: PASS
- Texture path retained: PASS
- Border/shake/slot_sort retained: PASS
- Anchor config exists: PASS
- Anchor mode: RIGHT_TOP_TRAIT_ADJACENT
- Offset config exists: PASS
- Slot gap config exists: PASS
- selected_slot log on change only: PASS
- Main text fallback: DEBUG_ONLY_NOT_MAIN_UI

## Danger Classification

- Runtime classifier module exists: PASS
- Runtime classifier update is called: PASS
- WARNING_ONLY exists: PASS
- WARNING_ONLY physical effect: NONE
- ASSIST exists: PASS
- ASSIST effect: STAGGER_ONLY
- TRUE_EMERGENCY exists: PASS
- TRUE_EMERGENCY condition limited: PASS
- Auto dragdown level minimum: TRUE_EMERGENCY
- Normal movement plus two close zombies: classified as WARNING_ONLY by config/code path

## Action Bus

- Runtime ActionBus module exists: PASS
- Runtime ActionBus update is called: PASS
- Same-frame duplicate action block: PASS
- Same-target knockdown cooldown: 4.0
- Same-target stagger cooldown: 1.25
- Dragdown window cooldown: 2.5
- Fatal window cooldown: 1.5
- Emergency/Dragdown duplicate same target window block: PASS

## Balance

- Normal single zombie no knockdown: PASS
- Manual shove guard: PASS
- No aura config: PASS
- Zombies can reenter config: PASS
- WARNING_ONLY no effect: PASS
- ASSIST no knockdown-capable route: PASS
- TRUE_EMERGENCY mixed route: PASS
- Low stamina endurance cost retained: PASS
- no bite / no infection / no heal policy retained by cost module logs

## Sprint Route

- Sprint first-wave route retained: PASS
- verified stagger knockdown retained for sprint precollision: PASS
- Sprint route uses ActionBus: PASS
- Too-late spam 
[EXCERPT_TRUNCATED]
```
