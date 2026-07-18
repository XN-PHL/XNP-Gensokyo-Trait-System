# 0.5.5 Sanitized Evidence Excerpts

## 0.5.5_REAL_GAME_RESULT_SUMMARY.md

- SHA-256: `49A3C694FFBBAB792072BDE47CE1B6B554C461D90691C2E83CCA41686651DA3C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.5 Real Game Result Summary

0.5.5 is the accepted baseline for 0.5.6.

- The mod loaded in Project Zomboid Build 42.19.0.
- Native trait detection worked.
- Halo feedback stayed disabled.
- True Moodle stayed disabled.
- Stamina refund behavior worked in real-game testing.
- Stamina summary logging worked.
- Metabolic debt was recorded as a diagnostic value.

The user observed possible body status or muscle strain text in the health panel during play. Static review does not attribute that to XNP 0.5.5, because 0.5.5 does not intentionally write BodyDamage, BodyPart, Pain, AdditionalPain, Fatigue, MuscleStrain, stiffness, wounds, bleeding, or infection.

0.5.6 must preserve the 0.5.5 stamina core and keep unstable visual or body-status feedback disabled by default.

```

## FINAL_REPORT.md

- SHA-256: `220A718A61549ED61A8D2A83F34F26CFC75667711E0E7E226AA0125B543B59BB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=0.5.4

VERSION=0.5.5

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_055_STABLE_CORE_MOODLE_AUDIT_A

0.5.4_TRAIT_RESULT=PASS

0.5.4_STAMINA_RESULT=PASS

0.5.4_ADRENALINE_RESULT=PASS

0.5.4_METABOLIC_DEBT_RESULT=PASS

0.5.4_VISUAL_FEEDBACK_RESULT=FAIL_NOT_ACCEPTABLE

0.5.4_RIGHT_TOP_ICON_RESULT=DISABLED_BY_DESIGN

STAMINA_DRAIN_METHOD=POST_DRAIN_PARTIAL_REFUND

READY_STAMINA_DRAIN_MULTIPLIER=0.40

ADRENALINE_STAMINA_DRAIN_MULTIPLIER=0.10

MIN_ENDURANCE_FLOOR=0.05

ENDURANCE_SAMPLE_INTERVAL=0.10

METABOLIC_COST_METHOD=DEBT_ONLY

METABOLIC_COST_MULTIPLIER=1.0

METABOLIC_APPLICATION_STATUS=NO_DIRECT_PLAYER_STAT_WRITE

VISUAL_FEEDBACK_METHOD=DISABLED_AFTER_HALO_FAILURE

HALO_TEXT_HELPER_RELEASE_STATUS=DISABLED

STATUS_MOODLE_METHOD=NOT_CONFIRMED

RIGHT_TOP_ICON_STATUS=DISABLED_NO_SAFE_TRUE_MOODLE

STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT

SANDBOX_OPTIONS_METHOD=DEFERRED_CONFIG_ONLY

MELEE_BONUS_METHOD=DISABLED_FOR_0.5.2

MOVEMENT_SPEED_MODIFICATION_METHOD=NONE

RUNNING_SHOVE_STATUS=DISABLED

OLD_SOURCE_MODIFIED=NO

GAME_LAUNCHED=NO

USER_MODS_WRITTEN=NO

GAME_DIRECTORY_WRITTEN=NO

LUA_FILE_COUNT=11

LUA_TOTAL_LINES=979

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

NOT_VERIFIABLE_BY_STATIC_AUDIT:

- Project Zomboid real boot result for 0.5.5.
- Lua 5.1 execution syntax check.
- Real right-side true Moodle registration, because no safe Lua registration and driving path was confirmed.

Final marker:

XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.5_SOURCE_READY_FOR_STABLE_CORE_MOODLE_AUDIT_TEST

```

## B42_19_TRUE_MOODLE_REGISTRATION_AUDIT_0.5.5.md

- SHA-256: `C587C579AFA2AF71E0C14F64A269222D86784900D6900E2E04F91D9F117A6C67`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 True Moodle Registration Audit 0.5.5

## Evidence Paths

- [LOCAL_PATH_REDACTED]
- [LOCAL_PATH_REDACTED]
- [LOCAL_PATH_REDACTED]

## Java Evidence

File: `zombie/scripting/objects/MoodleType.class`

- Method: `MoodleType.register`
- Parameter count: 1
- Parameter types: `java.lang.String`
- Return type: `zombie.scripting.objects.MoodleType`
- Lua safe call confirmed: NO
- Can register new Moodle: Java side YES, Lua side NOT CONFIRMED

File: `zombie/characters/Moodles/MoodleStat.class`

- Method: `MoodleStat.register`
- Parameter count: 6
- Parameter types: `MoodleType, float, float, float, float, float`
- Return type: `zombie.characters.Moodles.MoodleStat`
- Lua safe call confirmed: NO
- Can register new Moodle stat: Java side YES, Lua side NOT CONFIRMED

File: `zombie/characters/Moodles/Moodles.class`

- Methods observed:
  - `getMoodleLevel(MoodleType)`
  - `getMoodleDisplayString(MoodleType)`
  - `getMoodleDescriptionString(MoodleType)`
  - `isMaxMoodleLevel(MoodleType)`
  - `setMoodlesStateChanged(boolean)`
  - `Update()`
- Public direct setter for arbitrary custom Moodle level: NOT FOUND
- Can only modify existing Moodle: NOT CONFIRMED

File: `zombie/ui/MoodlesUI.class`

- Methods observed:
  - `getInstance()`
  - `setCharacter(IsoGameCharacter)`
  - `wiggle(MoodleType)`
  - `render()`
  - `update()`
- Can register new right-side Moodle UI entry from Lua: NOT CONFIRMED

File: `zombie/ui/MoodleTextureSet.class`

- Methods observed:
  - `getTexture(MoodleType)`
  - `getBorder()`
  - `getBackground()`
- Can bind new texture from Lua: NOT CONFIRMED

## Local Lua Evidence

Vanilla Lua search found calls that read or wiggle existing Moodles, for example:

- `playerObj:getMoodles():getMoodleLevel(MoodleType.PAIN)`
- `MoodlesUI.getInstance():wiggle(MoodleType.PANIC)`
- `MoodlesUI.getInstance():wiggle(MoodleType.ENDURANCE)`

No local vanilla Lua example was found that safely registers a new Moodle type, binds a new Moodle texture, and drives a new custom right-side Moodle level.

Workshop/local mod scan did not provide a reliable B42.19 custom Moodle registration pattern suitable for copying into this release candidate.

## Risk Questions

- Is Lua safe call confirmed: NO
- Can register new Moodle: NOT CONFIRMED
- Can only modify existing Moodle: POSSIBLE BUT NOT SAFE FOR THIS MOD
- Would modifying existing Moodle pollute vanilla Moodle: YES, if reusing ENDURANCE/PANIC/etc.
- Would it affect no-trait characters: YES, if implemented by modifying vanilla Moodle type/state globally.
- Would it save into save data: NOT CONFIRMED
- Can it be cleared safely: NOT CONFIRMED

## Conclusion

STATUS_MOODLE_METHOD=NOT_CONFIRMED

RIGHT_TOP_ICON_STATUS=DISABLED_NO_SAFE_TRUE_MOODLE

STATUS_ICON_FALLBACK=DISABLED_BY_DEFAULT

0.5.5 does not implement true Moodle. It also does not restore coordinate fake icons.

```

## STABLE_CORE_MOODLE_AUDIT_TEST_0.5.5.md

- SHA-256: `E9490E304B063F29EBC7EACFA2AD36DE884986BF3CDB9C0531027C15A1B7F561`
- Type: 审计报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.5 Stable Core Moodle Audit Test

1. 绂佺敤 0.5.4 鍜屾墍鏈夋棫鐗堟湰銆?2. 鍙惎鐢?0.5.5 鍜?B42Trans_CN銆?3. 瀹屽叏閲嶅惎娓告垙銆?4. 杩涘叆鏈夆€滈暱閫斿琚€呪€濈殑瑙掕壊銆?5. 鎵撳紑浜虹墿淇℃伅闈㈡澘纭榛勮壊 F 鐗硅川瀛樺湪銆?6. 涓嶈鏈熷緟澶撮《鏂囧瓧锛?.5.5 宸插叧闂?HaloTextHelper銆?7. 杩滅鍍靛案璺戞锛岀‘璁よ€愬姏涓嬮檷鏄庢樉鍙樻參銆?8. 鐪?console 鏄惁鏈?READY summary 鍜?debt_total銆?9. 闈犺繎鍍靛案锛岀‘璁?ACTIVE 鍚庤€愬姏涓嬮檷鏇存參銆?10. 鐪?console 鏄惁鏈?ACTIVE summary 鍜?debt_total銆?11. 濡傛灉鎶ュ憡鍐?TRUE_MOODLE_ENABLED锛岃瀵熷彸渚ф槸鍚﹀嚭鐜板師鐗堥鏍肩姸鎬佹爣绛俱€?12. 濡傛灉鎶ュ憡鍐?DISABLED_NO_SAFE_TRUE_MOODLE锛屽彸渚ф病鏈夋爣绛炬槸姝ｅ父缁撴灉銆?13. 纭娌℃湁澶撮《 T/t銆?14. 纭娌℃湁 hasTrait 閿欒銆?15. 纭娌℃湁鍙充笂瑙掑潗鏍囧亣鍥炬爣銆?16. 纭娌℃湁绉诲姩閫熷害鍔犳垚銆?17. 纭娌℃湁鎾炴帹銆?
```

## STATIC_AUDIT.md

- SHA-256: `FE9E51D2E1C954BAA65AB9F3540D11A733B4352D52E34B3EC495E8C692FE4646`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Static Audit

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]

BASE_SOURCE_PATH=0.5.4

## Checks

- Trait full ID unchanged: PASS
- trait detection route from 0.5.4 / 0.4.19 restored route: PASS
- player:hasTrait(string): ABSENT
- TraitFactory: ABSENT
- CharacterTraitDefinition runtime call: ABSENT
- setFastMoveCheat: ABSENT
- setSpeedMod: ABSENT
- setMoveSpeed: ABSENT
- setPathSpeed: ABSENT
- setCombatSpeed: ABSENT
- player coordinate write: ABSENT
- zombie coordinate write: ABSENT
- GameTime:setMultiplier: ABSENT
- RunningShove: ABSENT
- BumpedState: ABSENT
- right-top coordinate fake icon: ABSENT
- 8 second probe: ABSENT
- HaloTextHelper active call: ABSENT
- player:Say active call: ABSENT
- intended per-frame log: ABSENT
- direct write Calories: ABSENT
- direct write Hunger: ABSENT
- direct write Fatigue: ABSENT
- direct write Pain: ABSENT
- direct write Stress: ABSENT

## Counts

LUA_FILE_COUNT=11

LUA_TOTAL_LINES=979

TOTAL_FILE_COUNT=98

STATIC_AUDIT_RESULT=PASS_REAL_GAME_TEST_REQUIRED

```
