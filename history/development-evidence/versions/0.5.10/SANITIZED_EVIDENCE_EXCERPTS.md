# 0.5.10 Sanitized Evidence Excerpts

## 0.5.10_FAILURE_ANALYSIS_READONLY_BUMPED_AND_PLAYER_TRIP.md

- SHA-256: `F831ACB41EDD0B96EDE17E1F109CC604503C36C042C2CAAD5C58A4DB4DB5057A`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.10 Failure Analysis: Readonly Bumped And Player Trip

## Root Problems

1. `bumped` is read-only in the tested runtime path.
2. 0.5.10 treated an attempted write as success.
3. The design still leaned on player collision-chain timing.
4. Sprint impact could naturally drag the player into trip/fall follow-up.
5. The zombie reaction was not sufficiently tied to contact/grab/breakout intent.

## Removed In 0.5.11

- the failed read-only bump variable write route
- player bump-state calls
- player fall/trip chain
- range-only trigger
- normal route based on `PLAYER_BUMP_OR_COLLISION_TIMEOUT`

## Required Status

- `BUMPED_VARIABLE_WRITE_STATUS=REMOVED`
- `PLAYER_COLLISION_CHAIN_ROUTE=DISABLED`
- `VANILLA_BUMP_VARIABLE_ROUTE=DISABLED_AFTER_READ_ONLY_FAILURE`

## Replacement Direction

0.5.11 uses Breakout Push:

- contact trigger;
- grab/face-block trigger;
- crowd breakout trigger;
- zombie-side hit reaction;
- zombie-side AI interrupt;
- zombie-side micro nudge;
- player state remains read-only.

```

## 0.5.10_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `36FB0CD0D341BCE8A00E46ECEF0FBDE94B2965293CFC014EDCC0FB65C0D070D8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.10 Real Game Result Summary

## Accepted Runtime Evidence

- `0.5.10_LOAD_RESULT=PASS`
- `0.5.10_CONFIG_RESULT=PASS`
- Loaded build: `XNP_PZ_DISTANCE_TRAIT_0510_VANILLA_STYLE_RUNNER_IMPACT_A`
- Config path: `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua`

## Failure Evidence

0.5.10 attempted to write a read-only animation variable.

The module then produced misleading success logs:

- an animation-variable log reported success for the read-only bump variable
- `[XNP VANILLA IMPACT REACTION] route=VANILLA_ZOMBIE_BUMP_REACTION result=ok`

Real-game user result:

- almost no visible effect;
- sprinting almost always tripped the player;
- jogging could also trip the player;
- the effect felt like player collision-chain failure, not a deliberate push;
- zombie reaction looked detached from player action;
- trigger should work even when the player is grabbed or face-blocked.

## Frozen Labels

- `0.5.10_VANILLA_BUMP_VARIABLE_RESULT=FAIL_READ_ONLY_VARIABLE`
- `0.5.10_VISIBLE_EFFECT_RESULT=FAIL_USER_SAW_ALMOST_NONE`
- `0.5.10_PLAYER_TRIP_RESULT=FAIL_PLAYER_TRIPS_TOO_OFTEN`
- `0.5.10_ROUTE_RESULT=FAIL_PLAYER_COLLISION_CHAIN_IS_WRONG_TARGET`
- `0.5.11_GOAL=BREAKOUT_PUSH_NO_PLAYER_TRIP_CHAIN`

```

## BUILD_MARKER.txt

- SHA-256: `6872CF315D853CEFBDA62C961F65723A3B5D22ED4484DF9315638A8D2B90C82D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0510_VANILLA_STYLE_RUNNER_IMPACT_A

```

## CONFIG_GUIDE_CN.md

- SHA-256: `C3308F8E7B3637D23976075E54011302E4893E465B08F93B1B3449DA7E116A63`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner 0.5.6 閰嶇疆璇存槑

閰嶇疆鏂囦欢锛?
```text
42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
```

## 榛樿鍚敤椤?
- `ENABLE_MOD=true`
- `ENABLE_READY_DRAIN_REDUCTION=true`
- `READY_STAMINA_DRAIN_MULTIPLIER=0.40`
- `ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10`
- `MIN_ENDURANCE_FLOOR=0.05`
- `ENDURANCE_SAMPLE_INTERVAL=0.10`
- `THREAT_TRIGGER_RADIUS=4.0`
- `ADRENALINE_MEMORY_DURATION=20.0`
- `THREAT_SCAN_INTERVAL=0.50`

## 璇婃柇鏃ュ織

- `ENABLE_DEBUG_SUMMARY_LOG=true`
- `STAMINA_SUMMARY_LOG_INTERVAL=10.0`
- `DEBUG=false`

鍏抽棴 `ENABLE_DEBUG_SUMMARY_LOG` 鍚庯紝涓嶅啀杈撳嚭 `[XNP STAMINA SUMMARY]`銆?
## 榛樿绂佺敤椤?
- `ENABLE_METABOLIC_APPLICATION=false`
- `ENABLE_VISUAL_FEEDBACK=false`
- `ENABLE_TRUE_MOODLE=false`
- `ENABLE_BODY_STATUS_APPLICATION=false`

0.5.6 涓嶅啓鍏ラ€熷害銆佸潗鏍囥€佹椂闂村€嶇巼銆丅odyDamage銆丳ain銆丗atigue銆丮uscleStrain 鎴?Hunger/Calories銆?
```

## CONFIG_GUIDE_EN.md

- SHA-256: `296EFBFE990486AB08A090F1257606B6C9602014898B2C8E3CC6E0C91E7D7F74`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner 0.5.6 Config Guide

Config file:

```text
42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua
```

## Enabled by default

- `ENABLE_MOD=true`
- `ENABLE_READY_DRAIN_REDUCTION=true`
- `READY_STAMINA_DRAIN_MULTIPLIER=0.40`
- `ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10`
- `MIN_ENDURANCE_FLOOR=0.05`
- `ENDURANCE_SAMPLE_INTERVAL=0.10`
- `THREAT_TRIGGER_RADIUS=4.0`
- `ADRENALINE_MEMORY_DURATION=20.0`
- `THREAT_SCAN_INTERVAL=0.50`

## Diagnostic summary

- `ENABLE_DEBUG_SUMMARY_LOG=true`
- `STAMINA_SUMMARY_LOG_INTERVAL=10.0`
- `DEBUG=false`

When `ENABLE_DEBUG_SUMMARY_LOG=false`, `[XNP STAMINA SUMMARY]` output is disabled.

## Disabled by default

- `ENABLE_METABOLIC_APPLICATION=false`
- `ENABLE_VISUAL_FEEDBACK=false`
- `ENABLE_TRUE_MOODLE=false`
- `ENABLE_BODY_STATUS_APPLICATION=false`

0.5.6 does not write speed, coordinates, time multiplier, BodyDamage, Pain, Fatigue, MuscleStrain, Hunger, or Calories.

```

## FINAL_REPORT.md

- SHA-256: `F62F0847F292E0175F5350D349D7209DCA34EF6E58856A0B21FB5A4C08DF18BE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report 0.5.10

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
BASE_SOURCE_PATH=[LOCAL_PATH_REDACTED]

## Identity

- VERSION=0.5.10
- INTERNAL_VERSION=0.5.10-b42-vanilla-style-runner-impact-a
- BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0510_VANILLA_STYLE_RUNNER_IMPACT_A
- DISPLAY_NAME=XNP Distance Runner Trait 0.5.10 Vanilla Style Runner Impact
- MOD_ID=XNP_PZ_DistanceRunnerTrait
- TRAIT_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner

## 0.5.9 Runtime Results

- `0.5.9_LOAD_RESULT=PASS`
- `0.5.9_CONFIG_RESULT=PASS`
- `0.5.9_REPEAT_TRIGGER_RESULT=PASS`
- `0.5.9_VISIBLE_EFFECT_RESULT=PASS`
- `0.5.9_PLAYER_TRIP_FEEDBACK=FAIL_PLAYER_CAN_TRIP_OR_FEELS_WRONG`
- `0.5.9_ANIMATION_FEEL_FEEDBACK=FAIL_NOT_VANILLA_EMBEDDED_ENOUGH`

## 0.5.10 Vanilla Impact

- `VANILLA_IMPACT_METHOD=AUTO_VANILLA_ANIM_FIRST`
- `VANILLA_ROUTE_AUDIT_RESULT=VANILLA_ZOMBIE_BUMP_REACTION_CONFIRMED+VANILLA_ZOMBIE_SHOVE_REACTION_CONFIRMED+VANILLA_HIT_REACTION_NO_DAMAGE_CONFIRMED+VANILLA_ANIM_VARIABLE_REACTION_CONFIRMED+MICRO_NUDGE_SECONDARY_REQUIRED`
- `VANILLA_ZOMBIE_BUMP_REACTION_STATUS=ENABLED`
- `VANILLA_ZOMBIE_SHOVE_REACTION_STATUS=ENABLED`
- `VANILLA_HIGH_STRENGTH_COLLISION_STATUS=ENABLED_AS_COMPOSITE_ZOMBIE_REACTION`
- `VANILLA_HIT_REACTION_NO_DAMAGE_STATUS=ENABLED`
- `VANILLA_ANIM_VARIABLE_REACTION_STATUS=ENABLED`
- `MICRO_NUDGE_SECONDARY_STATUS=ENABLED_SECONDARY_ONLY`

## Trip Guard

- `PLAYER_TRIP_GUARD_ENABLED=true`
- `PLAYER_ALLOW_BUMPED_GRACE=true`
- `PLAYER_DISABLE_ON_FALL=true`
- `PLAYER_DISABLE_ON_ONFLOOR=true`
- `PLAYER_DISABLE_ON_KNOCKEDDOWN=true`
- `PLAYER_RECOVERY_ATTEMPT_ENABLED=false`

## Originality

- `ORIGINALITY_STATUS=PASS_XNP_OWN_LOGIC`
- `THIRD_PARTY_CODE_COPY_STATUS=NO_CONTIGUOUS_5_LINE_COPY`
- `XNP_IMPLEMENTATION_STATUS=OWN_LOGIC_USING_VANILLA_API_REFERENCES`

## Deferred UI Status

- `ICON_FEATURE_STATUS=DEFERRED_NOT_ABANDONED`
- `MOODLE_FEATURE_STATUS=DEFERRED_NOT_ABANDONED`
- `HALO_TEXT_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET`
- `COORDINATE_ICON_STATUS=FAILED_ROUTE_NOT_CURRENT_TARGET`

## Existing Systems

- `STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND`
- `ADRENALINE_TRIGGER_RADIUS=4.0`
- `ADRENALINE_MEMORY_DURATION=20.0`
- `MOVEMENT_SPEED_MODIFICATION_METHOD=NONE`
- `RUNNING_SHOVE_STATUS=DISABLED`
- `BUMPED_STATE_STATUS=DISABLED`

## Safety

- Modified old SOURCE: NO
- Started Project Zomboid: NO
- Started Steam: NO
- Wrote user mods: NO
- Wrote saves: NO
- Wrote Workshop: NO
- Wrote game directory: NO

## Counts

- Lua files: 14
- Lua total lines: 1854
- Markdown documents: 107
- Total files: 128

## Static Check

- Static check result: `PASS_WITH_RUNTIME_VERIFICATION_REQUIRED`
- JSON parse: PASS
- Text BOM/NULL scan: PASS
- Active forbidden Lua scan: PASS_WITH_ALLOWED_ZOMBIE_SECONDARY_NUDGE
- `NOT_VERIFIABLE_NO_RELIABLE_LUA_5_1_INTERPRETER`
- `NOT_VERIFIABLE_REAL_B42_RUNTIME_REACTION_ROUTE`
- `NOT_VERIFIABLE_TRIP_GUARD_REAL_GAME_EFFECT`

## Blocker

BLOCKER=NONE_STATIC

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.10_SOURCE_READY_FOR_VANILLA_STYLE_RUNNER_IMPAC
[EXCERPT_TRUNCATED]
```

## README_CN.md

- SHA-256: `FA471758ABF5E40A62B084D292ADAAF4B64B33507592B6B5B6BC70E2F52EA60C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.8

Project Zomboid Build 42.19.0 鐨勭嫭绔嬫縺杩涘疄楠岀増鏈€?
## 韬唤

- Mod ID锛歚XNP_PZ_DistanceRunnerTrait`
- Trait full ID锛歚XNPDistanceRunnerTrait:XNPDistanceRunner`
- 鐗堟湰锛歚0.5.8`
- 鍐呴儴鐗堟湰锛歚0.5.8-b42-aggressive-runner-impact-a`
- 鏋勫缓鏍囪瘑锛歚XNP_PZ_DISTANCE_TRAIT_058_AGGRESSIVE_RUNNER_IMPACT_A`

## 鏈疆鐩爣

0.5.7 宸茶瘉鏄庤窛绂汇€佹柟鍚戝拰瑙﹀彂閫昏緫鍙敤锛屼絾娌℃湁鍙鐗╃悊鏁堟灉銆?.5.8 鏂板 `Runner Impact Burst`锛岀洰鏍囨槸鍦ㄧ帺瀹跺璺戞挒鍚戞鍓嶆柟杩戣窛绂诲兊灏告椂浜х敓鑲夌溂鍙鐨勫兊灏稿弽搴斻€?
## 瀹為獙璺嚎

褰撳墠榛樿锛?
```text
SHOULDER_IMPACT_METHOD=AUTO_BEST_AVAILABLE
```

灏濊瘯椤哄簭锛?
1. 鍍靛案韪夎穭 / 鍊掑湴銆?2. 鍍靛案鍙楀嚮鍙嶅簲銆?3. 鍍靛案鍔ㄧ敾鍙橀噺銆?4. 鍍靛案寰綅绉汇€?5. 鏋佷綆浼ゅ瑙﹀彂鍙楀嚮鍔ㄧ敾銆?
杩欐槸瀹為獙鍒嗘敮锛屼笉鏄彂甯冨€欓€夛細

```text
EXPERIMENTAL_NOT_RELEASE_SAFE
```

## 浠嶇劧淇濈暀

- 鍘熺敓 CharacterTrait 娉ㄥ唽閾俱€?- 瀵硅薄寮忕壒璐ㄦ娴嬨€?- 榛勮壊 F 鐗硅川銆?- 0.5.5 / 0.5.6 鑰愬姏鏍稿績銆?- 4 鏍?adrenaline 濞佽儊璺濈绯荤粺銆?
## UI 鍙ｅ緞

鍥炬爣銆丮oodle銆佺姸鎬佸弽棣堟病鏈夋斁寮冦€?.5.8 鍙槸鏆傛椂鑱氱劍鍙鍐叉挒鏁堟灉銆?
```

## README_EN.md

- SHA-256: `5DD62DB5082B4C3386CE59716D2BE91F5366644AB3AE15886FE1D1A824A4756E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.8

Independent aggressive experiment for Project Zomboid Build 42.19.0.

## Identity

- Mod ID: `XNP_PZ_DistanceRunnerTrait`
- Trait full ID: `XNPDistanceRunnerTrait:XNPDistanceRunner`
- Version: `0.5.8`
- Internal version: `0.5.8-b42-aggressive-runner-impact-a`
- Build marker: `XNP_PZ_DISTANCE_TRAIT_058_AGGRESSIVE_RUNNER_IMPACT_A`

## Goal

0.5.7 verified distance, front-dot, and trigger logic, but produced logs only. 0.5.8 adds `Runner Impact Burst`, aiming for visible zombie reaction when the trait player runs into a close zombie ahead.

## Experimental method

Default:

```text
SHOULDER_IMPACT_METHOD=AUTO_BEST_AVAILABLE
```

Attempt order:

1. zombie stagger / knockdown
2. zombie hit reaction
3. zombie animation variable
4. zombie micro position nudge
5. minimal-damage hit reaction

This is not release-safe:

```text
EXPERIMENTAL_NOT_RELEASE_SAFE
```

Icons, Moodles, and status feedback are deferred, not abandoned.

```

## VANILLA_FEEL_IMPLEMENTATION_NOTE_0.5.10.md

- SHA-256: `6E973C1F3B8AADDA63D4AECB6B243A80D6FD63E0129E1745869D7AD1828525FB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Vanilla Feel Implementation Note 0.5.10

## Why 0.5.9 Felt Like Workshop Style

0.5.9 proved repeat trigger and visible impact, but its main route was still a direct `stagger_knockdown` reaction. In real play this can feel like a mechanical run-tackle: collision happens, zombie reacts, and the player can still feel dragged into a dangerous vanilla bump/fall follow-up.

That solves visibility, but not vanilla-feel integration.

## 0.5.10 Direction

0.5.10 moves the main effect into:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_VanillaImpact.lua`

The old `ShoulderImpact` file is kept as a no-op compatibility module. Runtime now calls `Core.VanillaImpact.Update(player)`.

## Vanilla-First Route Priority

The new route priority is:

1. `VANILLA_ZOMBIE_BUMP_REACTION`
2. `VANILLA_ZOMBIE_SHOVE_REACTION`
3. `VANILLA_HIGH_STRENGTH_COLLISION_REACTION`
4. `VANILLA_ZOMBIE_HIT_REACTION_NO_DAMAGE`
5. `VANILLA_ANIM_VARIABLE_REACTION`
6. `MICRO_NUDGE_AS_SECONDARY_ONLY`

This means the zombie carries the visible reaction, while the player remains in their own movement intent.

## APIs / Variables Used

Zombie-side only:

- `setBumpType("stagger")`
- `setVariable("bumped", true)`
- `setStaggerBack(true)`
- `setHitReaction("StaggerBack")`
- `setHitForce(2.0)`
- `setKnockedDown(true)`
- `knockDown(false)`
- `setVariable("ZombieHitReaction", "StaggerBack")`
- `setVariable("bStaggerBack", true)`

Secondary only:

- zombie `setX`
- zombie `setY`

The secondary nudge checks same-z, target square, and passability before moving the zombie.

## Player Trip Guard

0.5.10 does not:

- call player `BumpedState`;
- set player `BumpFall`;
- set player `FallOnFront`;
- set player `OnFloor`;
- write player coordinates;
- attempt forced player recovery.

If player Trip/Fall/OnFloor/KnockedDown is detected, `VanillaImpact` disables itself for the session.

## Originality Statement

No third-party implementation was copied. Workshop and game scans were used only to identify API names, animation variables, and risk patterns.

## Release Status

This is still an experimental branch, not a release-safe version.

```

## VANILLA_STYLE_RUNNER_IMPACT_TEST_0.5.10.md

- SHA-256: `FDFC203166C2F020346854841F155F86CE4D5D901FFAE003A83B2C1427141C80`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Vanilla Style Runner Impact Test 0.5.10

## 涓枃娴嬭瘯姝ラ

1. 绂佺敤 0.5.9銆?.5.8銆?.5.7 鍜屾墍鏈夋棫鐗堟湰銆?2. 鍙惎鐢?0.5.10 鍜?B42Trans_CN銆?3. 瀹屽叏閲嶅惎娓告垙銆?4. console 鎼滐細
   `XNP_PZ_DISTANCE_TRAIT_0510_VANILLA_STYLE_RUNNER_IMPACT_A`
5. 纭 Config loaded锛?   `[XNP CONFIG] loaded path=42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Config.lua source=shared_config`
6. 杩涘叆鏈夐暱閫斿琚€呯殑瑙掕壊銆?7. 涓嶆祴璇曞彸涓婅鍥炬爣锛屾湰杞浘鏍囦粛鏄?deferred銆?8. 鎵句竴鍙椿鍍靛案銆?9. 姝ｉ潰 1.0 鍒?1.2 鏍硷紝鎱㈣窇/璺戞鎾炲悜鍍靛案銆?10. 瑙傚療鍍靛案鏄惁鏇村儚鍘熺増琚帹寮€銆佹挒椋炪€佽笁璺勩€?11. 瑙傚療鐜╁鏄惁娌℃湁缁婂€掋€?12. 瑙傚療鐜╁鏄惁娌℃湁闀跨‖鐩淬€?13. 杩炵画娴嬭瘯 5 娆℃闈㈠啿鎾炪€?14. 鍐嶆祴璇曚晶杈瑰垏鍏?3 娆°€?15. 鏌ョ湅 console 鏄惁鏈夛細
    - `[XNP VANILLA IMPACT] trigger`
    - `[XNP VANILLA IMPACT REACTION]`
    - `[XNP VANILLA IMPACT ANIM]`
    - `[XNP TRIP GUARD]`
16. 濡傛灉鍑虹幇鐜╁琚粖鍊掞紝璁板綍 console 涓槸鍚︽湁锛?    `[XNP TRIP GUARD] fatal_player_trip_or_fall disabled=true`
17. 纭娌℃湁锛?    - `player:hasTrait`
    - `CharacterTraitDefinition`
    - `RunningShove`
    - 涓诲姩 `BumpedState`
    - `IsoZombie cannot be cast to IsoPlayer`
    - `HaloTextHelper`
    - `GameTime:setMultiplier`
    - `BodyDamage`
    - `MuscleStrain`
18. 鎶?`console.txt` 浜ゅ洖銆?
## Pass Criteria

- 0.5.10 姝ｇ‘鍔犺浇銆?- Config 姝ｅ父 loaded 涓旀病鏈?missing-key fallback銆?- 鍍靛案鍑虹幇鍘熺増鎰熸帹寮€銆佹挒椋炪€佽笁璺勬垨鍙楀嚮鍙嶅簲銆?- 鐜╁涓嶅€掑湴銆佷笉缁婂€掋€佷笉闀跨‖鐩淬€?- 閲嶅瑙﹀彂鎺у埗浠嶆湁鏁堛€?- blocked 淇℃伅鍙繘鍏?summary锛屼笉姣忓抚鍒峰睆銆?
## Fail Criteria

- 鐜╁琚粖鍊掓垨鍊掑湴銆?- 鍑虹幇 `IsoZombie cannot be cast to IsoPlayer`銆?- 娌℃湁浠讳綍 `[XNP VANILLA IMPACT] trigger`銆?- 鍙嚭鐜?nudge锛屾病鏈変换浣?vanilla reaction/anim route銆?- 鍑虹幇鏃?`STAGGER_KNOCKDOWN_REPEATABLE` 涓昏矾绾裤€?
```

## B42_19_SAFE_VISUAL_FEEDBACK_AUDIT.md

- SHA-256: `6AE3DC1BDC8851B313372F5C26C8D79887559B63530EC3CE6F1ABC89A69522EA`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Safe Visual Feedback Audit

Checked file:

- [LOCAL_PATH_REDACTED]

Static class evidence:

```text
zombie/characters/HaloTextHelper.class
zombie/characters/HaloTextHelper$ColorRGB.class
```

Static public methods confirmed by javap:

```text
public static void addGoodText(zombie.characters.IsoPlayer, java.lang.String);
public static void addText(zombie.characters.IsoPlayer, java.lang.String);
```

0.5.3 result:

VISUAL_FEEDBACK_METHOD=HALO_TEXT_HELPER

Runtime safety:

- Calls are wrapped in `pcall`.
- If HaloTextHelper is not exposed in Lua, feedback downgrades to `[XNP FEEDBACK]` log lines.
- It displays only once per key.
- It does not create a UI panel.
- It does not draw a right-top icon.
- It does not use coordinate icon placement.
- It does not block mouse input.

Messages:

- ACTIVE: `闀块€斿琚€咃細搴旀縺`
- READY after FADING: `闀块€斿琚€咃細鎭㈠`
- First READY stamina refund: `闀块€斿琚€咃細鑰愬姏鑺傜渷`

NOT_VERIFIABLE_BY_STATIC_AUDIT:

- Whether `HaloTextHelper` is exposed to Lua under the same global name in the user's enabled mod environment.
- Whether Chinese halo text renders correctly with the user's font/mod stack.

```

## B42_19_VISUAL_FEEDBACK_TEXT_FIX_AUDIT.md

- SHA-256: `4ECB46537DADBFC3748421DEFFA82E5339683A2BE332531E989A7F52753854D6`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 Visual Feedback Text Fix Audit

VISUAL_FEEDBACK_TRIGGERED=YES

VISUAL_FEEDBACK_TEXT_RESULT=FAIL_ONLY_T

## Answers

1. Why did 0.5.3 show only T/t?

Most likely cause: the long Chinese text with punctuation hit a text encoding or overload conversion issue in the HaloTextHelper Lua bridge. The call was triggered, so the visual path exists, but the rendered text was not reliable.

2. Was argument order wrong?

The Java signatures include:

```text
HaloTextHelper.addText(IsoPlayer, String)
HaloTextHelper.addGoodText(IsoPlayer, String)
```

0.5.3 used a valid-looking player/string route. There is no static evidence that argument order was reversed. The stronger suspect is string encoding or overload selection.

3. Was the Chinese string truncated incorrectly?

Yes, that is plausible. The failed output looked like a single Latin character, which is consistent with non-ASCII text being mishandled by the UI text path or Lua-to-Java overload conversion.

4. Is HaloTextHelper only suitable for short English or color arguments?

Static Java evidence does not say it is English-only. Real-game evidence says the long Chinese message is unsafe in this mod context. 0.5.4 uses short ASCII English only.

5. Is there a more stable local player prompt?

No safer non-UI, non-coordinate, non-panel player prompt was confirmed this round. Chat/system message alternatives were not enabled because they may depend on chat UI state and can be more intrusive.

6. What does 0.5.4 use?

VISUAL_FEEDBACK_METHOD=HALO_TEXT_HELPER_SAFE

VISUAL_FEEDBACK_TEXT_LANGUAGE=SHORT_ENGLISH_SAFE

Expected texts:

- ACTIVE: XNP Runner
- FADING/READY recovery: Runner Ready
- first stamina refund: Stamina Saved

Runtime safety:

- one-time text per key
- pcall wrapped
- fallback to log
- no right-top icon
- no coordinate drawing
- no UI panel
- no per-frame text

```
