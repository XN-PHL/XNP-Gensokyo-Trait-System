# 0.5.37 Sanitized Evidence Excerpts

## 0.5.37_BLUE_REFUND_30_PERCENT.md

- SHA-256: `F17772B70346CC75CF77B895D5661757D865F347C9BEB70F31163764BCA11542`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.37 Blue Refund 30 Percent

0.5.36锛?
- BlueRefundPercent=18
- drain_multiplier=0.82

0.5.37 Release锛?
- BlueRefundPercent=30
- drain_multiplier=0.70

鐘舵€侊細

- Green: 0%
- Blue: 30%
- Yellow: 38%
- Red: 55%

绾︽潫锛?
- 鍙繑杩樿繛缁?locomotion drain銆?- 鎾炲嚮銆佽В鎺с€佺粖鍊掋€丄ctionBus 绛夌鏁ｆ垚鏈笉杩旇繕銆?- Resource locked 鏃?refund=0銆?- 涓嶇珯绔嬪洖琛€銆?- 涓嶆妸 Blue 鐩存帴鎺ㄥ洖 Green銆?- 涓嶆彁渚涙棤闄?sprint銆?- Hunger 鎴愭湰鎸夊疄闄?refund 鎴愭瘮渚嬭绠椼€?

```

## 0.5.37_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `3C2B3CC34BE6CD9B0D16C09B2F8FAD7C9BB3F0B6FA3AF7B717A69DB89F48FE18`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.37 Gameplay Preserve Report

Changed:

- ZombieImpact release/testing default: 0.40 -> 0.24.
- Blue refund release/testing default: 18 -> 30.
- Blue fallback drain/refund defaults: 0.82 -> 0.70 / 18% -> 30%.
- Release logging throttled for hunger conversion and smooth blocked logs.
- Workshop package and release documents added.

Preserved:

- Mod ID: XNP_PZ_DistanceRunnerTrait.
- Native SandboxVars.XNPDistanceRunner route.
- Cost route registry.
- JogBump direct consumer.
- NativeTrip-only multiplier use.
- Wall fixed baseline.
- Colors, shake, drag.
- Walk No Impact.
- Controlled Escape.
- JogBump/SprintVehicle/NativeTrip effects.
- ActionBus/ImpactQuota.
- no bite / no infection / no heal policy.
- no player position write policy.
- no melee damage scaling runtime.

```

## 0.5.37_REAL_GAME_BALANCE_FROM_0.5.36.md

- SHA-256: `27E116D2EB1B9752E09DC475DD72264A6ACADC08475445C1822151413AFEF106`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.37 Real Game Balance From 0.5.36

鍩虹嚎锛?.5.36 瀹炴満榛樿 ZombieImpactCostMultiplier=0.40銆?
0.5.37 璋冩暣锛?
- ZombieImpactCostMultiplier=0.24銆?- 0.24 = 0.40 * 0.60銆?- SprintPrecollision 榛樿鎴愭湰浠?0.0200 闄嶅埌 0.0120銆?- SprintVehicle zombie 榛樿鎴愭湰浠?0.0300 闄嶅埌 0.0180銆?- JogBump 浣跨敤 base * 1.00 * 0.24 * 1.00銆?- Blue 杩炵画璺戞鑷劧娑堣€楄繑杩樹粠 18% 鎻愰珮鍒?30%銆?- Blue drain multiplier 浠?0.82 鏀逛负 0.70銆?
鏈皟鏁达細棰滆壊銆佹姈鍔ㄣ€佹嫋鍔ㄣ€佹挒鍑荤粨鏋溿€佸嚮鏉€銆佸嚮鍊掋€佽В鎺с€丯ativeTrip銆丄ctionBus銆両mpactQuota銆?

```

## 0.5.37_TEST_PLAN.md

- SHA-256: `3A38B2DB1F7753B5F4EBA652305BB96D27AA1756689213DB63B85A6ECA62DCCE`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.37 Test Plan

1. Load the mod from the prepared Workshop upload package after manually copying it to the user Workshop folder.
2. Confirm console prints build marker XNP_PZ_DISTANCE_TRAIT_0537_RELEASE_BALANCE_WORKSHOP_PREP_A.
3. Confirm Config/Sandbox loaded logs appear.
4. Confirm release balance logs:
   - zombie_impact_previous=0.40 scale=0.60 new_default=0.24
   - blue_refund_previous=18 new_default=30
5. In Sandbox Options, verify CN/EN text for ZombieImpact and BlueRefund.
6. With default options, trigger SprintPrecollision and confirm final cost log is 0.0120.
7. Trigger SprintVehicle zombie impact and confirm final cost log is 0.0180.
8. Trigger JogBump and confirm formula uses base * 0.24.
9. Confirm WallImpact cost remains fixed baseline.
10. Confirm NativeTrip and ControlledEscape do not use ZombieImpact.
11. Confirm Blue state logs drain_multiplier=0.70 refund_fraction=0.30.
12. Confirm discrete action costs are not refunded.
13. Confirm colors, shake, drag, impact, kill, knockdown, escape, ActionBus, and ImpactQuota behavior remain unchanged.
14. Confirm no high-frequency hunger conversion / smooth blocked console spam.

```

## 0.5.37_WORKSHOP_CHANGE_NOTES_ZH_EN.md

- SHA-256: `8E61E11FEFBA2164368B51631C2873D64639A25A4BCEE29A63EBB31CFCAF379F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Workshop Change Notes / 鍒涙剰宸ュ潑鏇存柊璇存槑

## 涓枃

0.5.37 Release Balance Workshop Prep

- ZombieImpact 榛樿鍊嶇巼锛?.40 -> 0.24銆?- SprintPrecollision 榛樿鎴愭湰锛?.0200 -> 0.0120銆?- SprintVehicle zombie 榛樿鎴愭湰锛?.0300 -> 0.0180銆?- Blue 鐘舵€佽繛缁窇姝ヨ€愬姏杩旇繕锛?8% -> 30%銆?- Sandbox CN/EN 鏂囨湰宸查噸鏂版鏌ャ€?- 宸插噯澶囧師鐢?Workshop 涓婁紶鍖呫€?- 棰滆壊銆佹姈鍔ㄣ€佹嫋鍔ㄣ€佹挒鍑荤粨鏋滀繚鎸佷笉鍙樸€?
## English

0.5.37 Release Balance Workshop Prep

- ZombieImpact default multiplier: 0.40 -> 0.24.
- SprintPrecollision default cost: 0.0200 -> 0.0120.
- SprintVehicle zombie default cost: 0.0300 -> 0.0180.
- Blue stamina refund: 18% -> 30%.
- Sandbox CN/EN text verified.
- Native Workshop upload package prepared.
- Colors, shake, drag, and impact results are unchanged.

```

## 0.5.37_WORKSHOP_DESCRIPTION_ZH_EN.md

- SHA-256: `D1FD5F205EC3C00CB1DF2EF65E2C7DA612A6A81A6F5AF445CD6818D861AE3B5D`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Workshop Description / 鍒涙剰宸ュ潑鎻忚堪

## 涓枃

XNP Distance Runner Trait / 闀块€斿琚€呯壒鎬?[B42]

閫傜敤浜?Project Zomboid Build 42.19.0銆?
鏈ā缁勬坊鍔犲師鐢熺壒鎬р€滈暱閫斿琚€呪€濄€備綘闇€瑕佸湪鍒涘缓瑙掕壊鏃堕€夋嫨璇ョ壒鎬ф墠鑳藉惎鐢ㄦ晥鏋溿€?
涓昏鍔熻兘锛?
- Walk No Impact锛氭櫘閫氳璧颁笉浼氫富鍔ㄨЕ鍙戞挒鍑诲兊灏告晥鏋溿€?- 鎱㈣窇/鍏ㄩ€熷璺戞挒鍍靛案锛氭參璺戝拰鍏ㄩ€熷璺戞椂鎻愪緵鍙楁帶鎾炲嚮銆佹帹寮€銆佸嚮鍊掓垨杞﹁締寮忛珮閫熸挒鍑婚€昏緫銆?- 鍏ㄩ€熷璺戞姉缁婂€?鎾炲嚮淇濇姢锛氬湪鏈夋晥鏉′欢涓嬪噺灏戝叏閫熷璺戣鍍靛案鐩存帴缁婂€掔殑椋庨櫓銆?- 琚兊灏告帶鍒舵椂鐨勯€冭劚锛氳璐磋劯銆佹嫋鎷芥垨鍖呭洿鏃舵彁渚涙湁闄愮殑瑙ｆ帶绐楀彛銆?- Green / Blue / Yellow / Red 鑰愬姏杈呭姪锛氭牴鎹€愬姏鍖洪棿鎻愪緵涓嶅悓绋嬪害鐨勮繛缁窇姝ヨ€愬姏杈呭姪銆?- Blue 鐘舵€侀粯璁よ繑杩?30% 杩炵画璺戞鑷劧娑堣€楃殑鑰愬姏銆?- 鎾炲兊灏告垚鏈负 0.5.36 榛樿鎴愭湰鐨?60%銆?- 浣跨敤鍘熺敓 Sandbox Options锛屽彲鍦ㄦ湇鍔″櫒鎴栧崟鏈烘矙鐩掕缃腑璋冩暣銆?
澶氫汉璇存槑锛氬浜哄弬鏁扮敱鏈嶅姟鍣ㄥ喅瀹氥€傚鎴风鏈湴璁剧疆涓嶄細瑕嗙洊鏈嶅姟鍣ㄩ厤缃€?
骞宠　璇存槑锛氭湰妯＄粍涓嶅洖婊氬挰浼ゃ€佹劅鏌撴垨浼ゅ锛屼笉鎻愪緵鏃犻檺浣撳姏锛屼笉鎵胯涓庢墍鏈夊叾浠栨ā缁勫吋瀹广€?
## English

XNP Distance Runner Trait [B42]

For Project Zomboid Build 42.19.0.

This mod adds the native trait "Distance Runner". The character must select the trait during character creation to enable the effects.

Main features:

- Walk No Impact: normal walking does not actively trigger zombie-impact effects.
- Jog and full-sprint zombie impact: controlled jog bump, sprint precollision, knockdown, or high-speed zombie impact behavior.
- Full-sprint trip and impact protection under valid conditions.
- Controlled escape when grabbed, pinned, or surrounded by zombies.
- Green / Blue / Yellow / Red stamina support bands.
- Blue band now refunds 30% of continuous natural running drain by default.
- Zombie-impact stamina cost is 60% of the 0.5.36 default.
- Native Sandbox Options for single-player and server tuning.

Multiplayer: parameters are controlled by the server.

Balance notes: this mod does not roll back bites, infection, or damage; it does not provide infinite stamina; compatibility with every other mod is not guaranteed.

```

## 0.5.37_WORKSHOP_PACKAGE_TREE.md

- SHA-256: `21CDE3BFB0A20C61757286D2E654EF3E17552A1FC33C32FD0543606E6EF7E162`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.37 Workshop Package Tree

XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ActivationDiagnostic.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutActionBus.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerBreakout.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerClassifier.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DraggableStatusIcon.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakoutCost.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyInput.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceBandState.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceCapabilityState.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ_DistanceRunnerTrait\42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FallRecoveryInput.lua
XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD\Contents\mods\XNP_PZ
[EXCERPT_TRUNCATED]
```

## 0.5.37_WORKSHOP_PUBLISH_STEPS_ZH.md

- SHA-256: `9998799C428D1AE63D76FCAA823C75E0E7846142715D862A390F9628102469DB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.37 Workshop 鍙戝竷姝ラ

1. 鏈€缁堝鍒舵暣涓枃浠跺す锛?
`XNP_PZ_DistanceRunnerTrait_0.5.37_WORKSHOP_UPLOAD`

鍒帮細

`[LOCAL_PATH_REDACTED]`

2. 澶嶅埗鍚庨鏈熷瓨鍦細

`[LOCAL_PATH_REDACTED]`

3. 鍚姩娓告垙鍚庤繘鍏ワ細

`Workshop -> Create and Update Items -> 閫夋嫨璇ラ」鐩甡

4. 棣栨涓婁紶鍚庡啀璁板綍鐪熷疄 Workshop ID銆?
绂佹鎻愬墠鍦?workshop.txt 涓吉閫?id銆?

```

## 0.5.37_WORKSHOP_RELEASE_CHECKLIST_ZH.md

- SHA-256: `90F1983383D7F0B5A6F2ECFC5CB76DBDE3465495E909D48D547A2E08427BA906`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.37 Workshop 鍙戝竷妫€鏌ユ竻鍗?
- SOURCE 宸茬嫭绔嬪垱寤猴紝涓嶄慨鏀?0.5.36銆?- Workshop 涓婁紶鍖呭凡鐙珛鍒涘缓銆?- 鏍圭洰褰曞瓨鍦?workshop.txt銆?- 鏍圭洰褰曞瓨鍦?preview.png锛?56x256锛岀湡 PNG銆?- Contents 鍐呭彧鍖呭惈 mods銆?- Mod ID 鏂囦欢澶逛负 XNP_PZ_DistanceRunnerTrait銆?- mod.info / poster.png / 42 缁撴瀯瀛樺湪銆?- workshop.txt 鏈啓鍏ヤ吉閫?id銆?- 涓嶅寘鍚?SOURCE 澶栧３銆佸璁℃姤鍛娿€佸懡浠ゆ枃浠躲€乧onsole 鎴栨棫鐗堟湰鐩綍銆?- ZombieImpact 榛樿 0.24銆?- Blue 榛樿 30%锛宒rain multiplier 0.70銆?- Sandbox CN/EN key 瀹屽叏涓€鑷淬€?- 鏈惎鍔ㄦ父鎴忔垨 Steam銆?- 鏈啓鐢ㄦ埛 mods銆乻aves銆乄orkshop 鐩綍鎴栨父鎴忕洰褰曘€?

```

## 0.5.37_ZOMBIE_IMPACT_060_SCALE.md

- SHA-256: `30C39605197D42910BDE75F50BEAB528390E57317FDC0C97804AB782167BA85E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.37 ZombieImpact 0.60 Scale

鐩爣锛氬皢鎾炲兊灏镐綋鍔涙垚鏈檷浣庝负 0.5.36 褰撳墠榛樿鐨?60%銆?
- Previous ZombieImpactCostMultiplier: 0.40
- Scale: 0.60
- New release default: 0.24

榛樿鎴愭湰锛?
- SPRINT_PRECOLLISION: 0.0500 * 1.00 * 0.24 * 1.00 = 0.0120
- SPRINT_VEHICLE_ZOMBIE: 0.0750 * 1.00 * 0.24 * 1.00 = 0.0180
- JOG_BUMP: base * 1.00 * 0.24 * 1.00

纭锛歓ombieImpact 鍙湪 JOG_BUMP銆丼PRINT_PRECOLLISION銆丼PRINT_VEHICLE_ZOMBIE 璺嚎搴旂敤涓€娆°€?
WALL_IMPACT 淇濇寔 fixed baseline锛屼笉浣跨敤 Global銆乑ombieImpact銆乺oute-specific 鎴?NativeTrip 鍊嶇巼銆?

```

## BUILD_MARKER.txt

- SHA-256: `143E0CC4BBD58F69FFC9D5BB86F12FB2E442D63978A1E0F7736D4C07382454E9`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0537_RELEASE_BALANCE_WORKSHOP_PREP_A

```

## FINAL_REPORT.md

- SHA-256: `6C492C514F7FEA0B2D74229129F2732C20215AACD93E5F36E8E17054E31D4F7F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# FINAL REPORT 0.5.37

SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
WORKSHOP_UPLOAD_PATH=[LOCAL_PATH_REDACTED]
VERSION=0.5.37
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0537_RELEASE_BALANCE_WORKSHOP_PREP_A
DISPLAY_NAME=XNP Distance Runner Trait 0.5.37 Release Balance Workshop Prep

ZombieImpact:

- previous=0.40
- scale=0.60
- new=0.24
- SprintPrecollision final=0.0120
- SprintVehicle zombie final=0.0180
- JogBump final=base*0.24

Blue stamina:

- previous=18%
- new=30%
- drain_multiplier=0.70

Workshop:

- workshop.txt present
- preview.png present, 256x256
- Contents contains only mods
- Mod ID folder fixed
- no fake Workshop id

Runtime preservation:

- colors/shake/drag preserved
- impact results preserved
- ActionBus/ImpactQuota preserved
- NativeTrip preserved
- WallImpact fixed baseline preserved
- no player coordinate write added
- no heal/rollback added
- no melee scaling runtime added

Not performed:

- Project Zomboid launch
- Steam launch
- install to user mods
- write to user Workshop
- upload

Status:
XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.37_SOURCE_READY_FOR_FINAL_WORKSHOP_TEST

```
