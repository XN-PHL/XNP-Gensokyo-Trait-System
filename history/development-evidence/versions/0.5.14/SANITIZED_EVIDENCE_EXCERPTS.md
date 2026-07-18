# 0.5.14 Sanitized Evidence Excerpts

## 0.5.14_REAL_GAME_FAILURE_ANALYSIS_FROM_0.5.13.md

- SHA-256: `F85D26E5844A0C738811EA08A70E71526CA066EB86CA1FC74255D1E8FDF2F8E9`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.14 Real Game Failure Analysis From 0.5.13

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.14
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0514_VERIFIED_STAGGER_CONTROL_A

## Accepted 0.5.13 Runtime Result

- The previous source loaded and reached its runtime route.
- SPRINT_PRECOLLISION prediction produced visible zombie-side reaction, but the player could still fall afterward.
- GRAB attempts that used reaction plus secondary movement and interrupt routes could still fail and could leave zombie AI looking stuck.
- CONTACT was mixed: some cases succeeded, some cases failed.
- Zombie recovery could log suspicious_stuck and then immediately log ok, while the live visual result still looked stuck.
- Local zombie key fallback could collapse to the same invalid online id.
- NOT_CLOSING skip logging was too noisy.

## 0.5.14 Correction

- Visible zombie reaction is no longer treated as success.
- SPRINT_PRECOLLISION now routes through verified stagger control.
- GRAB is redesigned as GRAB_PREBITE_BREAK and does not default to secondary movement or AI interrupt.
- Zombie recovery requires a post-watch confirmation window before success is logged.
- Local zombie keys now reject invalid online ids and use local object fallback.
- Skip logs are summarized every configured window instead of printed every frame.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.14_GRAB_PREBITE_BREAK_REDESIGN.md

- SHA-256: `EA4984BF7494CED20065565DDD12D20C0B2B518F8B0AB43E84A76A20306DF4F3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.14 GRAB_PREBITE_BREAK Redesign

## Problem

The previous GRAB route attempted visible reaction, secondary movement, and short interrupt by default. In real testing this could still fail and could create zombie recovery ambiguity.

## 0.5.14 Behavior

- The log-visible trigger name is GRAB_PREBITE_BREAK.
- Default route is verified lightweight stagger only.
- Secondary movement is disabled by config.
- AI interrupt is disabled by config.
- Minimal damage fallback is disabled by config.
- The route is an attempt to break a pre-bite / close-grab window, not a damage rollback.

## Failure Handling

- If the player falls after the route, the controller records a grab failure.
- Repeated grab failures set an internal interrupt-disabled diagnostic flag.
- This does not write player state and does not force player-side collision state.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.14_TEST_PLAN.md

- SHA-256: `A561864EF57E757391FB5AC924CE355C7C95907E573071166270FE589F905522`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.14 Test Plan

## Scope

This source is ready for manual source-copy testing only. It was not installed, packed, or launched by Codex.

## Checks

1. Confirm the console prints BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0514_VERIFIED_STAGGER_CONTROL_A.
2. Confirm Config loaded still prints.
3. Sprint directly toward one zombie and verify SPRINT_PRECOLLISION appears before the player falls.
4. If the zombie reacts but the player falls, expect PLAYER_FELL_AFTER_STAGGER_CONTROL.
5. Jog into one zombie and verify CONTACT uses lightweight verified stagger.
6. Let a zombie close in before a bite and verify GRAB_PREBITE_BREAK.
7. Stand near multiple close zombies and verify CROWD selects at least two candidates but applies to at most two.
8. Watch zombie recovery logs. suspicious_stuck must be followed by recovery_attempted and then confirmed_recovered or ZOMBIE_AI_STUCK_AFTER_PUSH.
9. Verify NOT_CLOSING / BAD_DOT / LOW_SPEED skip messages are summarized instead of spamming every frame.

## Acceptance

- Success is based on player stayed up outcome, not visible reaction alone.
- A visible zombie reaction followed by player fall is a failure.
- Any stuck zombie after the post-watch window is a failure.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.14_VERIFIED_STAGGER_CONTROL_DESIGN.md

- SHA-256: `47EF51DAF1F6C93FF741A6524D5EDB609926ADD0CD8CA0D3F6B1E91737CCFFA1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.14 Verified Stagger Control Design

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0514_VERIFIED_STAGGER_CONTROL_A

## Purpose

0.5.14 stops escalating the soft reaction route and instead reuses the verified 0.5.9 visible zombie-side stagger path.

## Runtime Module

42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_VerifiedStaggerControl.lua

Public functions:

- applySprintStaggerKnockdown
- applyContactStagger
- applyCrowdStagger
- applyGrabPreBiteBreak
- verifyVisibleControlCandidate
- registerControlOutcome
- Apply
- NotePlayerFall

## Trigger Policy

- SPRINT_PRECOLLISION requires strong speed, forward sector, closing frames, and valid dot.
- CONTACT requires closing contact, valid dot, and contact speed band.
- CROWD requires at least two close zombies and selects at most two.
- GRAB_PREBITE_BREAK is only a pre-bite breakout attempt and is not a guaranteed escape from already completed damage.

## Success Policy

- visible=true means visible zombie reaction only.
- Final success requires Player Outcome Watchdog result PLAYER_STAYED_UP.
- Failure after a sprint route logs PLAYER_FELL_AFTER_STAGGER_CONTROL.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.14_ZOMBIE_KEY_FALLBACK.md

- SHA-256: `5E2BF16412631CC20DAD9495B4F340D0C2EDD56A165785685BB082832B65F75A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.14 Zombie Key Fallback

## Problem

Local single-player zombies can expose an invalid online id. Reusing that value for every zombie pollutes cooldowns, history, and recovery watchdogs.

## 0.5.14 Behavior

- Valid online id is used only when it is numeric and non-negative.
- Valid local id is used only when it is numeric and non-negative.
- Otherwise a local object string fallback is used.
- A local sequence fallback exists as the last resort.
- The first local fallback logs [XNP ZOMBIE KEY] method=LOCAL_OBJECT_FALLBACK.

## Result

Recovery, cooldown, and closing-frame history no longer collapse unrelated local zombies into one invalid key.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## 0.5.14_ZOMBIE_RECOVERY_STRICT_CONFIRMATION.md

- SHA-256: `B11F8AE4FB2F706288904D332FA2AF2D6E2704315ABCF473097EDCC15EDD2A2D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.14 Zombie Recovery Strict Confirmation

## Change

Zombie recovery no longer logs success immediately after suspicious_stuck.

## Runtime Flow

1. Register every controlled zombie with a recovery watchdog.
2. At the first watch expiration, measure movement or floor state.
3. If suspicious_stuck is detected, attempt a safe recovery pulse.
4. Start a post-watch window of at least 0.50 seconds.
5. Only after the post-watch can recovery be confirmed.
6. If the zombie still has no movement and is not safely resolved, log ZOMBIE_AI_STUCK_AFTER_PUSH.

## Expected Logs

- [XNP ZOMBIE RECOVERY] suspicious_stuck
- [XNP ZOMBIE RECOVERY] recovery_attempted
- [XNP ZOMBIE RECOVERY] result=confirmed_recovered
- [XNP BREAKOUT FAIL] reason=ZOMBIE_AI_STUCK_AFTER_PUSH

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## BUILD_MARKER.txt

- SHA-256: `FA624BE36D058FB1235FF228C92874235FB6BE0B7569F9038BB502EE6C0DBB5B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0514_VERIFIED_STAGGER_CONTROL_A

```

## FINAL_REPORT.md

- SHA-256: `017277B9AA0910745396BA637F62D86F5DA5986F7ED1358340B0D43DAD3F6A01`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.14

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.14
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0514_VERIFIED_STAGGER_CONTROL_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.14 Verified Stagger Control

## Changed Files

- BUILD_MARKER.txt
- mod.info
- 42\mod.info
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Constants.lua
- 42\media\lua\shared\XNP_PZ_DistanceRunner\XNP_DR_Config.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Runtime.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_VerifiedStaggerControl.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_VanillaImpact.lua
- 42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ShoulderImpact.lua
- 0.5.14_REAL_GAME_FAILURE_ANALYSIS_FROM_0.5.13.md
- 0.5.14_0.5.9_STAGGER_ROUTE_AUDIT.md
- 0.5.14_VERIFIED_STAGGER_CONTROL_DESIGN.md
- 0.5.14_GRAB_PREBITE_BREAK_REDESIGN.md
- 0.5.14_ZOMBIE_RECOVERY_STRICT_CONFIRMATION.md
- 0.5.14_ZOMBIE_KEY_FALLBACK.md
- 0.5.14_TEST_PLAN.md
- STATIC_AUDIT.md
- FINAL_REPORT.md

## 0.5.9 Route Audit

- Reference source was read only.
- Verified route found in 0.5.9 shoulder impact source.
- 0.5.14 ports that route into XNP_DR_VerifiedStaggerControl.lua.
- Runtime now reaches verified stagger control through BreakoutPush only.

## 0.5.13 Failure Fixes

- SPRINT reaction-only route: FIXED.
- GRAB default secondary movement plus interrupt route: FIXED.
- suspicious_stuck immediate ok: FIXED.
- invalid online zombie key pollution: FIXED.
- NOT_CLOSING frame spam: FIXED.

## Mechanisms

- Verified Stagger Control: PASS_STATIC.
- Player Outcome Watchdog: PASS_STATIC.
- Zombie Recovery Strict Confirmation: PASS_STATIC.

## Classification

- SPRINT speed below 3.25 is blocked from sprint classification.
- SPRINT forward dot requires at least 0.70.
- CONTACT forward dot requires at least 0.55.
- CROWD requires at least two close zombies.
- CROWD applies to at most two zombies.
- LOW_SPEED, BAD_DOT, and NOT_CLOSING are tracked and summarized.

## Safety

- Project Zomboid launched: NO.
- Steam launched: NO.
- Game directory write: NO.
- User mods write: NO.
- Saves write: NO.
- Workshop write: NO.
- Old SOURCE modified: NO.
- Package/install/copy to mods: NO.

## Static Result

- Lua file count: 16.
- Lua line count before final docs: 2395.
- Runtime forbidden pattern grep: PASS_NO_HITS.
- Old build marker grep: PASS_NO_HITS.
- Lua execution syntax: NOT_VERIFIABLE_NO_LOCAL_INTERPRETER.
- Real-game result: NOT_VERIFIABLE_BY_STATIC_AUDIT.
- BLOCKER: NONE_STATIC.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.14_SOURCE_READY_FOR_VERIFIED_STAGGER_CONTROL_TEST


```

## 0.5.14_0.5.9_STAGGER_ROUTE_AUDIT.md

- SHA-256: `9CF5FC3C722335A27300AA28F3BA8486D7F33C5CEA59C2D7090F9A5C185AAEAD`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.14 Audit Of 0.5.9 Stagger Route

READ_ONLY_REFERENCE_SOURCE=[LOCAL_PATH_REDACTED]
REFERENCE_FILE=42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ShoulderImpact.lua

## Verified Reference Route

The 0.5.9 source contains a visible zombie-side route in the shoulder impact module:

- Function: Impact.TryStaggerKnockdown
- Primary visible effect: zombie stagger flag
- Strong effect when allowed: zombie knockdown method
- Fallback visible effect: hit reaction with StaggerBack
- Reference log: type=stagger_knockdown

## 0.5.14 Port

New module:

42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_VerifiedStaggerControl.lua

Runtime route:

- XNP_DR_Runtime.lua requires the new module.
- XNP_DR_Runtime.lua calls only Core.BreakoutPush.Update(player) for impact handling.
- BreakoutPush.ApplyPushProfile delegates zombie-side control to Core.VerifiedStaggerControl.Apply.

## Route Mapping

- SPRINT_PRECOLLISION: verified stagger plus knockdown-capable control.
- CONTACT: lightweight verified stagger.
- CROWD: lightweight verified stagger for at most two zombies.
- GRAB_PREBITE_BREAK: lightweight verified stagger, no default secondary movement, no default interrupt.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```

## STATIC_AUDIT.md

- SHA-256: `4928E0C83948080A66D72B0E3BDA1F8D7858BF4113A2579D3555267970EBA705`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit 0.5.14

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.14
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0514_VERIFIED_STAGGER_CONTROL_A

## Identity

- Display name: XNP Distance Runner Trait 0.5.14 Verified Stagger Control
- Mod ID: XNP_PZ_DistanceRunnerTrait
- Trait full ID: XNPDistanceRunnerTrait:XNPDistanceRunner
- Build marker grep: PASS
- Old build marker grep: PASS_NO_HITS

## Runtime Route

- Runtime requires XNP_DR_VerifiedStaggerControl.
- Runtime calls Core.BreakoutPush.Update(player).
- VanillaImpact module exists as no-op status only.
- ShoulderImpact module exists as no-op status only.
- No main update call to VanillaImpact or ShoulderImpact was found.

## 0.5.14 Required Fixes

- SPRINT soft reaction-only route: FIXED.
- GRAB default secondary movement plus interrupt route: FIXED.
- suspicious_stuck immediate ok: FIXED.
- invalid online zombie key pollution: FIXED.
- NOT_CLOSING frame spam: FIXED by skip summary window.

## Mechanism Status

- Verified Stagger Control: PASS_STATIC.
- Player Outcome Watchdog: PASS_STATIC.
- Zombie Recovery Strict Confirmation: PASS_STATIC.
- SPRINT_PRECOLLISION speed floor: PASS_STATIC, 3.25.
- CONTACT dot floor: PASS_STATIC, 0.55.
- CROWD minimum zombies: PASS_STATIC, 2.
- CROWD maximum zombies: PASS_STATIC, 2.
- Range-only trigger: DISABLED_BY_LOGIC.

## Static Scans

- Lua file count: 16.
- Lua total lines before final docs: 2395.
- Runtime forbidden pattern set: PASS_NO_HITS.
- Old build marker pattern set: PASS_NO_HITS.
- Lua 5.1 interpreter availability: NOT_VERIFIABLE_NO_LOCAL_INTERPRETER.
- Lua execution syntax check: NOT_VERIFIABLE_NO_LOCAL_INTERPRETER.
- Text block balance scan: RISK_TEXT_ONLY, no reliable Lua parser available.
- BOM scan: PASS_FOR_TEXT_FILES.
- NULL scan: PASS_FOR_TEXT_FILES; binary PNG contains null bytes as expected.
- Empty file scan: PASS.

## Write Safety

- Project Zomboid was not launched.
- Steam was not launched.
- User mods directory was not written.
- Saves directory was not written.
- Workshop directory was not written.
- Game installation directory was not written.
- 0.5.10 / 0.5.11 / 0.5.12 / 0.5.13 sources were not edited.

ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED
HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET
COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET


```
