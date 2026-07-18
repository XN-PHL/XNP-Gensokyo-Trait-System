# 0.5.28 Sanitized Evidence Excerpts

## 0.5.28_JOG_FLOOR_SUPPORT_DESIGN.md

- SHA-256: `CB6AF9F183CA3093C5615C94085964586DE775F2170E10293C1B51225A6CB167`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.28 Jog Floor Support Design

JOG_FLOOR_SUPPORT=ADDED

Jog floor gives a low, capped endurance floor for jog/run intent while endurance is poor. It is not available to full sprint and cannot restore to high stamina.

Config:

- `jog_floor_target_endurance=0.24`
- `jog_floor_min_endurance=0.12`
- `jog_floor_max_endurance=0.30`
- `jog_floor_restore_per_tick=0.0045`
- `jog_floor_red_restore_per_tick=0.0020`
- `jog_floor_not_for_full_sprint=true`
- `jog_floor_max_active_seconds=18`
- `jog_floor_cooldown_seconds=25`

Safety:

- Full sprint is blocked from jog floor.
- Active duration is capped.
- Cooldown prevents infinite support.
- Hunger guard reduces support via guard multiplier.

```

## 0.5.28_LOG_SILENCE_AND_FPS_OPTIMIZATION.md

- SHA-256: `7A76FF303DF9F77A3D263C744752F1F6A28628CD217E645900210D9DEA92D371`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.28 Log Silence And FPS Optimization

LOG_SILENCE=STRICT_SUMMARY_ONLY

Release logging changes:

- `release_log_level="SUMMARY_ONLY"`
- `movement_gate_immediate_log=false`
- `movement_gate_log_on_state_change_only=true`
- `movement_gate_summary_interval_frames=120`
- `jog_bump_block_log_summary_only=true`
- `action_bus_block_log_summary_only=true`
- `impact_quota_block_log_summary_only=true`
- `dragdown_warning_log_summary_only=true`
- `auto_dragdown_warning_log_summary_only=true`
- `status_icon_state_hold_log_enabled=false`
- `stamina_assist_tick_log_enabled=false`

Required logs are summary/state-change only:

- `[XNP LOG SILENCE] release_summary_only=true`
- `[XNP MOVEMENT GATE SUMMARY] ...`
- `[XNP JOG BUMP BLOCK SUMMARY] ...`
- `[XNP ACTION BUS SUMMARY] ...`
- `[XNP DRAGDOWN BLOCK SUMMARY] ...`
- `[XNP AUTO DRAGDOWN SUMMARY] ...`
- `[XNP STATUS ICON SUMMARY] ...`
- `[XNP STAMINA ASSIST SUMMARY] ...`

```

## 0.5.28_METABOLIC_RESERVE_HAND_FEEL_TUNE.md

- SHA-256: `4855DE8CE22297CC2C6D1D2A8AFD32DAB68F2098977FF8F480F9B13E6F60714F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.28 Metabolic Reserve Hand Feel Tune

YELLOW_STATUS=METABOLIC_ACTIVE

Changes from 0.5.27:

- Metabolic trigger moved earlier to endurance <= 0.50.
- Strong trigger moved to endurance <= 0.35.
- Red strain trigger uses endurance <= 0.42 with trend failure.
- Hunger cost per tick is slightly lower.
- Per-minute hunger cost cap reduced to 0.06.
- Hard stop added at hunger >= 0.88.

Required behavior:

- Hunger writes are attempted only through safe wrappers.
- API failure logs `hunger_write_result=SKIPPED_API_UNAVAILABLE`.
- Hunger guard and hard stop prevent starvation-style conversion.
- No healing, bite rollback, infection rollback, or damage rollback is added.

NO_HEAL_NO_BITE_ROLLBACK_NO_INFECTION_ROLLBACK=YES

```

## 0.5.28_PRESERVE_0.5.27_CORE_MECHANICS.md

- SHA-256: `7DD49E2390A70179686FC6CA9BA55756862900364B0416ED12503C404B48E1E4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.28 Preserve 0.5.27 Core Mechanics

WALK_NO_IMPACT=PRESERVED

CONTROLLED_JOG_ESCAPE=PRESERVED

JOG_BUMP=PRESERVED

SPRINT_VEHICLE_IMPACT=PRESERVED

DRAG_CAPTURE=PRESERVED

Preserved modules:

- MovementIntentGate
- JogBumpLaunch
- SprintVehicleImpact
- NativeTripWindow
- FallRecoveryInput
- DragdownDangerBreakout
- EmergencyBreakout
- StatusIconUI
- DraggableStatusIcon

0.5.28 does not rewrite collision, breakout, native trip, or controlled escape behavior.

```

## 0.5.28_REAL_GAME_TUNING_FROM_0.5.27.md

- SHA-256: `4D6CFCC8EBD0C689127A02A1712280FD04B916F2A5F955D1802008D156D2098B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.28 Real Game Tuning From 0.5.27

BASELINE=0.5.27

0.5.27 loaded correctly and kept the 0.5.26 gameplay fixes, but real-game feedback showed three issues:

- RED_GUARD / YELLOW_METABOLIC rarely appeared.
- Low endurance could still leave the runner unable to keep jogging.
- Console logging was still too noisy for low-FPS play.

0.5.28 keeps the 0.5.27 mechanics and tunes only stamina feel, red strain feedback, safe icon colors, and release logging.

RED_STATUS=MAX_OUTPUT_NO_RECOVERY

YELLOW_STATUS=METABOLIC_ACTIVE

JOG_FLOOR_SUPPORT=ADDED

PROGRESS_YELLOW_WARNING=FIXED_BY_SAFE_RGBA

LOG_SILENCE=STRICT_SUMMARY_ONLY

```

## 0.5.28_RED_STRAIN_STATE_DESIGN.md

- SHA-256: `4B372A8974E1D456D4B010CE4432AF2486445B9696AF50A43C85232500DFDBF7`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.28 Red Strain State Design

RED_STRAIN is a feedback state for high effort with poor endurance recovery. It is not an infinite stamina mode and not a punitive damage route.

Runtime checks:

- MAX_OUTPUT_NO_RECOVERY: run or sprint input, endurance at or below 0.42, recent trend result is NO_RECOVERY.
- LOW_ENDURANCE_JOG_FAILURE: endurance at or below 0.22, player is still trying to jog/run, stamina assist is active.
- METABOLIC_CAP_REACHED: per-minute metabolic cap reached while endurance remains low.
- HUNGER_TOO_HIGH: hard hunger stop remains red guard behavior.

Required logs:

- `[XNP STAMINA ASSIST] state=RED_STRAIN reason=MAX_OUTPUT_NO_RECOVERY ...`
- `[XNP STAMINA ASSIST] state=RED_STRAIN reason=LOW_ENDURANCE_JOG_FAILURE ...`
- `[XNP STAMINA ASSIST] state=RED_STRAIN reason=METABOLIC_CAP_REACHED ...`
- `[XNP STAMINA TREND] window=4 ... result=NO_RECOVERY`

NO_INFINITE_STAMINA=YES

NO_INFINITE_SPRINT=YES

```

## 0.5.28_SAFE_RGBA_ICON_COLOR_FIX.md

- SHA-256: `D468156F58D5AED50C0F04D4256A6CF7F89F04BB58A314DDB57BB84BEEB4A38D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.28 Safe RGBA Icon Color Fix

PROGRESS_YELLOW_WARNING=FIXED_BY_SAFE_RGBA

The UI no longer depends on unverified named color strings. `XNP_DR_StaminaColorSafeRGBA.lua` provides explicit RGBA tables:

- green `{r=0.15,g=0.95,b=0.25,a=1}`
- blue `{r=0.20,g=0.55,b=1.00,a=1}`
- yellow `{r=1.00,g=0.80,b=0.10,a=1}`
- red `{r=1.00,g=0.15,b=0.10,a=1}`

Priority remains:

1. Skill/danger red flash.
2. RED_STRAIN / RED_GUARD.
3. YELLOW_METABOLIC.
4. BLUE_CRUISE.
5. GREEN_READY.
6. DEFAULT_READY.

Unregistered yellow named-color active Lua hits: 0.

```

## 0.5.28_TEST_PLAN.md

- SHA-256: `7E36274F58644A28625B1FF6EA2E4C52E862B92DDC8B7DDF5FF0BF16E4417BA2`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.28 Test Plan

Manual install only. Codex did not launch the game and did not write user mods.

Expected startup:

- `[XNP DR] BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0528_STAMINA_FEEL_RED_STRAIN_LOG_SILENCE_A`
- `[XNP DistanceRunner] loaded version=0.5.28`
- `[XNP STAMINA ASSIST] red_strain_enabled=true`
- `[XNP JOG FLOOR] enabled=true`
- `[XNP STAMINA ICON COLOR] mode=SAFE_RGBA no_named_color=true`
- `[XNP LOG SILENCE] release_summary_only=true`

Test focus:

1. Normal jogging: green/blue states and no log spam.
2. Max output with no recovery: RED_STRAIN appears before hunger starvation.
3. Low endurance jogging: jog floor support prevents total failure but does not allow infinite sprint.
4. Metabolic: yellow can appear earlier, hunger guard/hard stop still work.
5. Logging: MovementGate/Dragdown/AutoDragdown/state_hold should not print every frame.

```

## BUILD_MARKER.txt

- SHA-256: `1E4A8970E3CC10A778B9390CEDA401BB4C18B42E24CB65D602A83FE5FA082133`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0528_STAMINA_FEEL_RED_STRAIN_LOG_SILENCE_A

```

## FINAL_REPORT.md

- SHA-256: `DB0F4CBA2241DF50E7CB86B5D1BC56015361B6798E8C3B5631CB2560F78C2AD4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

VERSION=0.5.28

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0528_STAMINA_FEEL_RED_STRAIN_LOG_SILENCE_A

DISPLAY_NAME=XNP Distance Runner Trait 0.5.28 Stamina Feel Red Strain Log Silence

FILE_COUNT=60

LUA_FILES=42

LUA_LINES=8969

0.5.27 feedback handling:

- red never triggered: FIXED
- max output no recovery red: YES
- low endurance cannot run: TUNED
- unregistered yellow named-color warning: FIXED
- log spam: REDUCED

Stamina:

- RedStrain runtime: YES
- trend meter: YES
- jog floor: YES
- metabolic yellow earlier: YES
- hunger guard / hard stop: YES
- no infinite stamina: YES
- no infinite sprint: YES

Icon:

- safe RGBA: YES
- unregistered yellow named-color active hits: 0
- green/blue/yellow/red: YES
- danger red flash priority: YES
- dragged position preserved: YES

Log / FPS:

- release summary only: YES
- MovementGate per-frame disabled: YES
- Dragdown per-frame disabled: YES
- AutoDragdown per-frame disabled: YES
- state_hold per-frame disabled: YES
- stamina tick log disabled: YES

Preserve:

- walk no impact: PRESERVED
- controlled jog escape: PRESERVED
- jog bump: PRESERVED
- sprint vehicle: PRESERVED
- drag capture: PRESERVED

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

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.28_SOURCE_READY_FOR_STAMINA_FEEL_TEST

```

## 0.5.28_SECOND_PASS_AUDIT.md

- SHA-256: `49ADCB051A17839D3A717A4C57671EF42CD54B67F84140047EFE1D1D279DB79A`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.28 Second Pass Audit

AUDIT_SOURCE=[LOCAL_PATH_REDACTED]

WRITE_TARGET=0.5.28_SECOND_PASS_AUDIT.md

CODE_MODIFIED_BY_THIS_AUDIT=NO

GAME_STARTED=NO

STEAM_STARTED=NO

USER_MODS_WRITTEN=NO

SAVES_WRITTEN=NO

WORKSHOP_WRITTEN=NO

GAME_DIR_WRITTEN=NO

PACKAGED=NO

## 1. Version And File Count

- SOURCE_EXISTS=PASS
- BUILD_MARKER_OK=PASS: `XNP_PZ_DISTANCE_TRAIT_0528_STAMINA_FEEL_RED_STRAIN_LOG_SILENCE_A`
- DISPLAY_NAME_OK=PASS: `XNP Distance Runner Trait 0.5.28 Stamina Feel Red Strain Log Silence`
- FILE_COUNT_0527=58
- FILE_COUNT_0528=60
- LUA_COUNT_0528=42
- LARGE_COPY_DETECTED=NO
- OLD_ACTIVE_RESIDUE=BLOCKER

Runtime old active residue hit:

`42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua:737: -- 0.5.27 long migration stamina assist`

Per command, active Lua runtime marker residue from 0.5.27/0527 is not allowed. This alone forces `BLOCKED_NOT_READY`.

## 2. Red Strain Audit

- RED_STRAIN_CONFIG=YES
- RED_STRAIN_RUNTIME=YES
- MAX_OUTPUT_NO_RECOVERY=YES
- LOW_ENDURANCE_JOG_FAILURE=YES
- METABOLIC_CAP_RED=YES
- TREND_METER=YES
- ICON_RED_STRAIN=YES
- RED_STRAIN_STATUS=RISK

Evidence:

- `red_strain_enabled`: present.
- `RED_STRAIN`: present in runtime.
- `MAX_OUTPUT_NO_RECOVERY`: present.
- `LOW_ENDURANCE_JOG_FAILURE`: present.
- `METABOLIC_CAP_REACHED`: present.
- `StaminaTrendMeter`: present.
- `[XNP STAMINA TREND]`: present.
- `[XNP STAMINA ICON] state=RED_STRAIN color=red`: present.

Risk:

- Exact static string `[XNP STAMINA ASSIST] state=RED_STRAIN reason=MAX_OUTPUT_NO_RECOVERY` was not found because the runtime log concatenates the reason value. The runtime can print this when `strainReason == "MAX_OUTPUT_NO_RECOVERY"`, but exact-string audit is not satisfied.

## 3. Jog Floor Audit

- JOG_FLOOR_RUNTIME=YES
- JOG_ONLY=YES
- NOT_FOR_FULL_SPRINT=YES
- NO_FULL_RESTORE=YES
- ACTIVE_WINDOW_CAP=YES
- COOLDOWN=YES
- LOW_HUNGER_GUARD_MULTIPLIER=YES
- JOG_FLOOR_STATUS=PASS

Evidence:

- `jog_floor_support_enabled`: present.
- `isJogIntent`: present.
- `SPRINT_ONLY_NO_JOG_FLOOR`: present.
- `JOG_FLOOR_TARGET_ENDURANCE`: present.
- `JOG_FLOOR_MAX_ACTIVE_SECONDS`: present.
- `JOG_FLOOR_COOLDOWN_SECONDS`: present.
- `JOG_FLOOR_GUARD_MULTIPLIER`: present.
- `[XNP JOG FLOOR] active=true`: present.
- `[XNP JOG FLOOR] cooldown active=true`: present.
- `sprint_limited=true jog_floor=true no_full_restore=true`: present.

## 4. Metabolic / Yellow Audit

- METABOLIC_TRIGGER_EARLIER=YES: `METABOLIC_TRIGGER_ENDURANCE = 0.50`.
- YELLOW_ICON_RUNTIME=YES
- HUNGER_WRITE_RESULT_LOG=YES
- MINUTE_CAP=YES
- SOFT_GUARD=YES
- HARD_STOP=YES
- NO_INFINITE_STAMINA=YES
- NO_INFINITE_SPRINT=YES
- METABOLIC_STATUS=PASS

Evidence:

- `YELLOW_METABOLIC`: present.
- `[XNP STAMINA ICON] state=YELLOW_METABOLIC`: present.
- `hunger_write_result=SKIPPED_API_UNAVAILABLE`: present.
- `[XNP METABOLIC RESERVE] write endurance_result=... hunger_result=...`: present.
- `METABOLIC_MAX_HUNGER_COST_PER_MINUTE = 0.06`: present.
- `METABOLIC_SOFT_GUARD_HUNGER`: present.
- `METABO
[EXCERPT_TRUNCATED]
```

## STATIC_AUDIT.md

- SHA-256: `03D82DEF49B9DDECCA8CD18CACF305E49D284DDFA8A8B515122F6E7663984046`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE=[LOCAL_PATH_REDACTED]

BASELINE=0.5.27

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0528_STAMINA_FEEL_RED_STRAIN_LOG_SILENCE_A

Files: 60; Lua files: 42; Lua lines: 8969.

Old SOURCE modified: NO.

Forbidden runtime Lua grep:

- bumped variable writes: 0
- `player:hasTrait(`: 0
- TraitFactory / CharacterTraitDefinition: 0
- RunningShove / BumpedState: 0
- GameTime multiplier: 0
- HaloTextHelper / player:Say: 0
- player coordinate setters: 0
- unregistered yellow named-color active Lua hits: 0

Required runtime grep:

- RedStrain runtime: PRESENT
- StaminaTrendMeter: PRESENT
- MAX_OUTPUT_NO_RECOVERY: PRESENT
- LOW_ENDURANCE_JOG_FAILURE: PRESENT
- METABOLIC_CAP_REACHED: PRESENT
- JogFloor support: PRESENT
- no infinite stamina: capped by targetCap/jog floor target
- no infinite sprint: sprint low-endurance guard and jog floor sprint block
- hunger guard / hard stop: PRESENT
- safe RGBA color: PRESENT
- danger red flash priority: PRESERVED
- MovementGate preserve: PRESENT
- controlled jog escape preserve: PRESENT
- walk no impact preserve: PRESENT
- log silence: PRESENT
- MovementGate immediate log disabled: PRESENT
- Dragdown warning summary only: PRESENT
- AutoDragdown warning summary only: PRESENT
- StatusIcon state_hold disabled: PRESENT
- no per-frame endurance/hunger write: throttled by stamina tick and PerformanceBudget.

BLOCKER=NONE

```
