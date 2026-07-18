# 0.5.49 Sanitized Evidence Excerpts

## 0.5.49_CONSOLE_EVIDENCE_FILENAME_RESOLUTION.md

- SHA-256: `4A9EAB4B0F4D1666630C4065F27C1A35B428DE5D769A50F1B1C05E044B3205D5`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.49 Console Evidence Filename Resolution

- `CONSOLE_EVIDENCE_LABEL=鏈€鏂扮敤鎴峰疄鏈?console 鏃ュ織`
- `CONSOLE_EVIDENCE_CONTENT_MATCH=true`
- `CONSOLE_FILENAME_REQUIRED=false`
- `CONSOLE_FILENAME_MISMATCH_RESOLVED=true`

Evidence was found in the latest accessible user console log. The evidence contract now depends on content rather than a numbered filename. It confirms mod loading, trait registration, module loading, Master ON/OFF behavior, the white disabled state, icon dragging, and real-time log throttling for the latest in-game-validated baseline.

The new release itself was not launched during this build.

```

## 0.5.49_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `5ED9CC561FAF93DA481A77868874AAF736BDE0B1DF73AE2E05B9EB46BDF6B921`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.49 Gameplay Preserve Report

The new runtime was copied from the preceding public-release runtime. Release identity fields and the vehicle history namespace changed. Historical version numbers were also removed from two internal module names, their table keys, require paths, result labels, and diagnostic labels. Their function bodies, conditions, numeric parameters, call order, and side effects were preserved.

- Trait registration: preserved.
- Walk No Impact, Jog Bump, Sprint and Vehicle Impact: preserved.
- Controlled Escape, Emergency, Dragdown, and Pre-Bite: preserved.
- Pre-Bite maximum targets `3`; third target stagger-only: preserved.
- Tiered Food `0.005/0.015` and `0.010/0.020`; reserve floor `0.40`: preserved.
- Endurance refund bands Blue `0.30`, Yellow `0.38`, Red `0.55`: preserved.
- Emergency endurance floor `0.05`: preserved.
- Sprint precollision final cost `0.012`; vehicle impact final cost `0.018`; zombie-impact multiplier `0.24`: preserved.
- Single-player melee enabled by its existing gate; multiplayer melee disabled: preserved.
- Central Scheduler count `1`: preserved.
- CentralWorldQuery remains the sole local world-scan entry point.
- Global zombie-list use, player-coordinate writes, player healing, bite rollback, and infection rollback: absent.
- Right-click Master ON/OFF, white OFF state, dragging while OFF, and re-enable path: preserved.
- OFF gate remains before scheduler/world-query work.
- No food catch-up and no stale target reuse after re-enable: preserved.
- Real-time ten-second summary: preserved.
- Repeated clamp print path: absent.

Baseline-relative changed paths: `12` (`4` identity/content changes, `4` paths representing two module renames, and `4` callers whose require/table-key labels were normalized).

`GAMEPLAY_PRESERVE_STATUS=PASS_STATIC_IDENTITY_AND_LABEL_ONLY`

`REAL_GAME_CURRENT_RELEASE_TEST=NOT_PERFORMED`

```

## 0.5.49_PUBLIC_COPY_CLEANUP_REPORT.md

- SHA-256: `E2D07259BB0CFA4EE59DACC3BE5204C8AE58D212792CB3E9104B122D74328249`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.49 Public Copy Cleanup Report

- `PUBLIC_OLD_VERSION_TOKEN_HITS_BEFORE=17`
- `PUBLIC_OLD_VERSION_TOKEN_HITS_AFTER=0`
- `PUBLIC_RAW_FORBIDDEN_HITS=0`
- `PUBLIC_SEMANTIC_FORBIDDEN_HITS=0`
- `EDITABLE_FILE_HASH_MATCH=true`

The public description and Workshop draft use only the current release identity, 鈥渃urrent version,鈥?鈥渢his update,鈥?and 鈥渓atest in-game-validated functionality.鈥?Historical development-version references remain confined to internal evidence reports.

The public safety statement is:

鈥滄湰妯＄粍涓嶈兘淇濊瘉鍦ㄦ墍鏈夊洿鏀讳腑瀛樻椿銆傗€?
鈥淭his mod does not guarantee survival in every encounter.鈥?
```

## 0.5.49_RELEASE_DESCRIPTION_EDITABLE.md

- SHA-256: `D17DF99335DC3FB95FCC04341A0AF2086193ED847DA003EFCEE48E00D8CDF9AA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
鏈枃浠跺彲鐩存帴缂栬緫锛涗慨鏀瑰叕寮€鏂囨涓嶄細褰卞搷妯＄粍杩愯鏂囦欢銆?
# XNP Distance Runner Trait 0.5.49

## 涓枃璇存槑

### 妯＄粍瀹氫綅

XNP Distance Runner Trait 鏄潰鍚?Project Zomboid Build 42.19.0 鐨勭Щ鍔ㄣ€佽€愬姏涓庤繎韬劚鍥?Trait 妯＄粍銆傝鑹查渶瑕佸湪鍒涘缓鏃堕€夋嫨鈥滈暱閫斿琚€呪€濈壒鎬э紝杩愯閫昏緫鎵嶄細鐢熸晥銆?
妯＄粍涓烘琛屻€佹參璺戙€佸啿鍒恒€佽繎韬帴瑙︺€佽鍥村拰鍜激鍓嶅嵄闄╃獥鍙ｆ彁渚涗笉鍚岃鍒欙紝鍚屾椂淇濈暀鑰愬姏銆侀鐗╁偍澶囥€佸喎鍗村拰鐩爣閰嶉绛夋垚鏈€傚畠涓嶄細鍥炴粴宸茬粡鍙戠敓鐨勫挰浼ゃ€佹劅鏌撴垨浼ゅ銆?
### 鏍稿績鍔熻兘

- 鍘熺敓 Trait锛氬垱寤鸿鑹叉椂閫夋嫨鈥滈暱閫斿琚€?/ Distance Runner鈥濄€?- Walk No Impact锛氭櫘閫氭琛屼笉涓诲姩瑙﹀彂 XNP 鍍靛案鎾炲嚮鏁堟灉銆?- Jog Bump锛氭參璺戞弧瓒虫帴瑙﹁秼鍔挎椂浣跨敤鍙楁帶鎺ㄦ尋鎴栫‖鐩磋矾绾匡紝骞舵敮浠樼嫭绔嬫垚鏈€?- Sprint Impact锛氬啿鍒轰娇鐢ㄥ墠鍚戦纰版挒銆佹帴瑙﹂棬妲涘拰鍍靛案渚у弽搴旓紝涓嶅啓鐜╁鍧愭爣銆?- Controlled Escape 涓?Emergency Breakout锛氳繎韬彈闃汇€佹姄鍙栨垨涓ラ噸鍖呭洿鏃舵彁渚涙湁鎴愭湰鍜屽喎鍗寸殑鑴卞洶璇锋眰銆?- Pre-Bite Jog Rescue锛氬湪鍜激鎻愪氦鍓嶅皾璇曞鐞嗘渶澶氫笁涓洰鏍囷紝绗笁涓洰鏍囦粎浣跨敤 stagger銆?- 鍒嗙骇鑰愬姏杈呭姪锛欱lue銆乊ellow銆丷ed 榛樿浣跨敤 30%銆?8%銆?5% 鐨勮繛缁嚜鐒舵秷鑰楄繑杩樻洸绾裤€?- 鍒嗙骇椋熺墿鎭㈠锛欱lue 姣忎釜鑴夊啿娑堣€?0.005 椋熺墿鍌ㄥ骞舵仮澶?0.015 鑰愬姏锛沋ellow 涓?Red 姣忎釜鑴夊啿娑堣€?0.010 骞舵仮澶?0.020銆傚偍澶囩嚎淇濇寔鍦?0.40銆?- 鍗曟満杩戞垬澧炲己锛氫粎鍦ㄥ崟鏈恒€侀珮鑰愬姏涓斿疄闄呭懡涓兊灏告椂浣跨敤浜嬩欢椹卞姩鍔犳垚锛涘浜鸿繎鎴樺寮哄綋鍓嶅叧闂€?- 鐘舵€佸浘鏍囷細Green銆丅lue銆乊ellow銆丷ed 鏄剧ず宸叉彁浜よ€愬姏鍖洪棿锛涘乏閿嫋鍔ㄥ苟淇濆瓨浣嶇疆銆?- Master ON/OFF锛氬彸閿叧闂叏閮?XNP 鏁堟灉鍚庯紝鍥炬爣淇濇寔鏄剧ず鍜屽彲鎷栧姩骞跺彉涓虹函鐧斤紱鍐嶆鍙抽敭鍙紑鍚€?- OFF 鐘舵€侊細鍋滄鐜╂硶銆佹暟鍊煎啓鍏ャ€丄ctionBus銆佸眬閮ㄤ笘鐣屾煡璇€佸兊灏告晥鏋滃拰椋熺墿鑴夊啿銆傞噸鏂板紑鍚椂涓嶈ˉ鍙戞棫鑴夊啿锛屼篃涓嶅鐢ㄦ棫鐩爣銆?- 鎬ц兘锛氫娇鐢ㄤ竴涓腑澶?Scheduler 鍜屼竴涓?CentralWorldQuery 灞€閮ㄤ笘鐣屾壂鎻忓叆鍙ｏ紱鍛ㄦ湡鏃ュ織鎸夌湡瀹炴椂闂村崄绉掕妭娴併€?
### 鐘舵€佸浘鏍?
- Green锛氭甯歌€愬姏鐘舵€併€?- Blue锛氳交搴﹁€愬姏鏀寔鍖洪棿銆?- Yellow锛氳緝寮鸿€愬姏鏀寔鍖洪棿銆?- Red锛氫綆鑰愬姏鏀寔鍖洪棿銆?- White锛氱敤鎴烽€氳繃鍙抽敭鍏抽棴鍏ㄩ儴 XNP 鏁堟灉銆?- 宸﹂敭锛氭嫋鍔ㄥ浘鏍囥€?- 鍙抽敭锛氬垏鎹?Master ON/OFF銆?
杩欎簺棰滆壊鏄?XNP 鑷畾涔夌姸鎬佸浘鏍囷紝涓嶆槸鍘熺増 Moodle銆?
### 鎬ц兘涓庡吋瀹规€?
- 澶氫釜鍔熻兘澶嶇敤鍚屼竴浠界帺瀹堕檮杩戝兊灏稿揩鐓э紝涓嶈鍙栧叏灞€鍍靛案鍒楄〃銆?- 鑰愬姏鍜岄ゥ楗跨瓑鏁板€煎啓鍏ョ粡杩囨潈闄愬垽鏂紝鏅€氬浜哄鎴风涓嶄綔涓烘潈濞佸啓鍏ユ柟銆?- 鍗曟満鍔熻兘宸叉湁鏈€鏂扮敤鎴峰疄鏈?console 鏃ュ織璇佹嵁銆?- 澶氫汉淇濈暀鏈嶅姟鍣ㄦ潈濞佸畨鍏ㄨ璁★紝浣嗗皻鏈畬鎴愬畬鏁存湇鍔″櫒瀹炴祴銆?- 鍏朵粬 NPC銆佸湴鍥俱€佽溅杈嗐€佸姩鐢绘垨鍍靛案鐘舵€佹満妯＄粍浠嶅彲鑳芥敼鍙樿〃鐜版垨浜х敓鍏惰嚜韬敊璇€?
### 瀹夎

灏嗗敮涓€鐨勬ā缁勬枃浠跺す鏀惧叆 `Zomboid\mods\XNP_PZ_DistanceRunnerTrait\`銆?
璇ユ枃浠跺す绗竴灞傚簲鐩存帴鍖呭惈锛?
- `42`
- `mod.info`
- `poster.png`

涓嶈棰濆濂椾竴灞傚悓鍚嶆枃浠跺す銆傛洿鏂板墠閫€鍑烘父鎴忥紝骞堕伩鍏嶅悓鏃跺惎鐢ㄥ涓?XNP Distance Runner 鍓湰銆?
### 宸茬煡闄愬埗

- 鏋佺鍥存敾銆佸鏉傚湴褰㈡垨鍏朵粬妯＄粍鏀瑰啓鐘舵€佹満鏃讹紝鑴卞洶浠嶅彲鑳藉け璐ャ€?- 宸茬粡鎻愪氦鐨勫挰浼ゃ€佹劅鏌撳拰浼ゅ涓嶄細琚洖婊氥€?- 绗洓涓強鏇村 Pre-Bite 鐩爣涓嶄繚璇佽澶勭悊銆?- 澶氫汉 Master 鍚屾涓庡浜鸿繎鎴樹粛鏈畬鎴愬畬鏁存湇鍔″櫒瀹炴祴銆?- 鏈ā缁勪笉鑳戒繚璇佸湪鎵€鏈夊洿鏀讳腑瀛樻椿銆?
### 鏈鏇存柊

- 浠ユ渶鏂板疄鏈洪獙璇侀€氳繃鐨勫姛鑳戒负鍩虹嚎銆?- 缁熶竴褰撳墠鍏紑鍙戝竷韬唤銆佸崟灞傜洿瑁呰浇鑽峰拰 Workshop 鑽夌缁撴瀯銆?- 娓呯悊鍏紑鏂囨涓殑鍘嗗彶寮€鍙戠増鏈紩鐢ㄣ€?- 淇濈暀鍙抽敭鎬诲紑鍏炽€乄hite OFF銆佸浘鏍囨嫋鍔ㄥ拰鐪熷疄鏃堕棿鏃ュ織鑺傛祦銆?- 涓嶆敼鍙樼帺娉曞钩琛°€?
## English Description

XNP Distance Runner Trait 0.5.49 adds the native Distance Runner character trait for Project Zomboid Build 42.19.0. Select the trait during character creation to enable its movement, endurance, and close-contact escape rules.

### Features

- Separate walking, jogging, sprinting, and close-contact rules.
- Walk No Impact and controlled Jog Bump behavior.
- Forward sprint precollision and zombie-side impact reactions without writing player coordinates.
- Controlled Escape, Emergency Breakout, and Pre-Bite Jog Rescue with costs, cooldowns, and target quotas.
- Pre-Bite handling for up to three targets, with the third target limited t
[EXCERPT_TRUNCATED]
```

## 0.5.49_RUNTIME_HASH_MANIFEST.md

- SHA-256: `815FBAD69B0088EADF4537B8327F38B1F8564C321E114E2EA55ED19A520FA8F4`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.49 Runtime Hash Manifest

- `RUNTIME_FILE_COUNT=77`
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`
- `SOURCE_WORKSHOP_HASH_MISMATCH_COUNT=0`
- `DIRECT_WORKSHOP_HASH_MISMATCH_COUNT=0`

| SHA256 | Relative path |
|---|---|
| `18718D17FFDCB890FA77AC2D82A1E8B1FCADE6287048039C5CADC268FD1236A7` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActivationDiagnostic.lua` |
| `B26549958F97A397A674F12ABFFCC8FAA7802A879753D07E1E214B32E24A47C6` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua` |
| `1F577575B5F42F2FC114D573BE9CD33FE2A8AF2382DDA9C9640F0BBD910FAD44` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus.lua` |
| `2BBB6F45AF6F9896216D338DAFC3D10DA30D60B469FB962F86B93EE276E85C33` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua` |
| `E23D253843B8D77DAAA98164F22B46D4F77B5D8F24D80F100A965D4DD58EEB33` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_CentralWorldQuery.lua` |
| `F519378E9DDB4D0EA27848482B1F3D3CF05DD75FB7AE2924EC4708ECF5A70E50` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_CriticalWindow.lua` |
| `D44747A3317F895D966844367F4D988FA2C6EFCEE1C52D2AA5977D658822960E` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout.lua` |
| `66EEFCCA2C8C14F683B63FC87A098BB70D0FDE7884265FE7AD8F0A0DF7797583` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerClassifier.lua` |
| `80333270A88BD000D046DDBB4F21A8364E3AFB19C28A36D0FD719D5A4AB5BDE0` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DraggableStatusIcon.lua` |
| `7437193A3F0F20770CFD406DBE0374ECC3A245F1F8F7827B13A84AC798553822` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakout.lua` |
| `D9AB4AC2ADD927B7ECAB9C195B708B1D8B02A2087CE23559BD87F410702A49D7` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost.lua` |
| `2FBB0832363E0F5F98CACAF42C1022DB7EE8794ACF36107AB7D8B21FD1EA4DD7` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput.lua` |
| `EF358C62E0E4FBDA99329E23C49AE3851BBD2AA30E7438A68583A5165877AFE2` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState.lua` |
| `51B350AB1EE9A0ACEE5EAD80A8A11C02D322D0CDAD6C2B1CBB54952B809F4473` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceCapabilityState.lua` |
| `BD35C4C9FE836E980345C906F4B5C21ECD631DFBDD669BB68A3FD2929CFC1FD0` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput.lua` |
| `E234851419C87572FA347F980A4348C891CF993969BC523033E2D9C4434A979D` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_FoodReserveConversion.lua` |
| `F7933096B64322DAF1E7353AA60EA18C632BB5BCAA6DA357449FECC813E0D156` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ImpactCandidateSnapshot.lua` |
| `2412BB836713B13FFB253F52AA328AFAC12B1D251056500D97F9659F551FB8DB` | `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter.lua` |
| `4116EA75B3676B0E1D5EEF8E188F13D04A60FB704BE2C94ED6E34486DA5239D4` | `42/media/lua/client/XNP_PZ_Distanc
[EXCERPT_TRUNCATED]
```

## 0.5.49_WORKSHOP_IDENTITY_SEARCH_REPORT.md

- SHA-256: `2E0D69CA1CF5BAF43028E60B6BF20DEF11C669E25371E21F0FEC731B7755C39B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.49 Workshop Identity Search Report

## Result

`WORKSHOP_ITEM_ID=NOT_FOUND`

No unique existing published Item ID could be tied simultaneously to AppID `108600`, Mod ID `XNP_PZ_DistanceRunnerTrait`, and the Distance Runner title. No ID was guessed or copied from an unrelated subscription.

## Search Scope

- `[LOCAL_PATH_REDACTED]` related `workshop.txt`, manifest, metadata, config, Markdown, and text files.
- `[LOCAL_PATH_REDACTED]`.
- `[LOCAL_PATH_REDACTED]`.
- Standard Steam library patterns on `C:`, `D:`, `E:`, `F:`, `G:`, `Y:`, and `Z:`.
- `[LOCAL_PATH_REDACTED]`.
- `[LOCAL_PATH_REDACTED]`.
- `[LOCAL_PATH_REDACTED]` and its staging/template content.
- `[LOCAL_PATH_REDACTED]`.
- `[LOCAL_PATH_REDACTED]`.
- Steam userdata text metadata containing `publishedfileid`, `itemid`, `workshopid`, or the project identity.

## Existing Files And Findings

- Workspace `workshop.txt` files found: `2`.
- The project template at `0.5.37_WORKSHOP_UPLOAD\workshop.txt` contains no Item ID field.
- The prior release draft contains no Item ID field.
- Steam AppID `108600` manifest exists only in the discovered `G:` library.
- Installed Workshop content directories checked: `167`.
- Content identity matches for `XNP_PZ_DistanceRunnerTrait`, `XNP Distance Runner`, or `闀块€斿琚€卄: `0`.
- Userdata subscription files checked: `2`.
- Unique subscription candidate IDs: `207`.
- Project identity matches in userdata metadata: `0`.
- `[LOCAL_PATH_REDACTED]` is a generic map template and contains no project identity or Item ID.

## Candidate IDs

The following `207` numeric IDs occur in AppID `108600` subscription metadata. Every one is excluded because the local evidence identifies it only as a subscription/content candidate and none is linked to this Mod ID and title:

`1254546530, 1299328280, 1343686691, 1827428289, 2004998206, 2127583399, 2169435993, 2183283602, 2186592938, 2196102849, 2216172287, 2252982049, 2256623447, 2261236052, 2313387159, 2322470605, 2337452747, 2377867605, 2384329562, 2392709985, 2392987599, 2398253681, 2423266708, 2434425002, 2445720450, 2463499011, 2478247379, 2478768005, 2487022075, 2503622437, 2506921282, 2507161010, 2517394050, 2522940210, 2529746725, 2536865912, 2553809727, 2554699200, 2566953935, 2571222705, 2590662055, 2592897465, 2599752664, 2603239477, 2613146550, 2619072426, 2625625421, 2625989913, 2634426926, 2640569820, 2642541073, 2667899942, 2670674997, 2671890843, 2672560941, 2673713236, 2674031168, 2678285725, 2680488822, 2687180786, 2687798127, 2688538916, 2694448564, 2707905930, 2712632417, 2714198296, 2714850307, 2725378876, 2730430010, 2730975264, 2732594572, 2732804047, 2734679675, 2734683361, 2737787862, 2752895143, 2756636139, 2760035814, 2762213537, 2774834715, 2775825898, 2776898170, 2778576730, 2778799110, 2782415851, 2785427414, 2793308803, 2796134549, 2798170078, 2799152995, 2803624504, 2810320955, 2810771031, 2811259189, 2814253005, 2820363371, 2822154449, 2830301361, 2837923608, 2839214341, 2844685624, 28448291
[EXCERPT_TRUNCATED]
```

## 0.5.49_WORKSHOP_ITEM_ID_PROOF.md

- SHA-256: `CD5F02199B1FF51BF82C8911BF5F9A2FE3D3770349B7064FE8A084B030EA3881`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.49 Workshop Item ID Proof

`APP_ID=108600`

`MOD_ID=XNP_PZ_DistanceRunnerTrait`

`WORKSHOP_ITEM_ID=NOT_FOUND`

`ITEM_ID_PROOF=FAILED_MISSING_AUTHORITATIVE_IDENTITY_LINK`

The local Steam manifest and userdata contain subscription IDs, but no existing file links any numeric ID to all three required identities: AppID `108600`, Mod ID `XNP_PZ_DistanceRunnerTrait`, and the Distance Runner title. Subscription folder names are not accepted as proof of ownership or publication identity.

The generated `workshop.txt` is therefore a release draft without an Item ID. It must not be described as ready for direct update.

Required resolution: provide the existing Workshop page URL or the exact numeric Item ID for this mod.

```

## BUILD_MARKER.txt

- SHA-256: `F046C4DA57F9DC9B122D12B284BF5D10D9E55E7AE02DE59EE1D786195EFBACA0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0549_WORKSHOP_IDENTITY_PUBLIC_COPY_REPAIR_A

```

## FILE_HASHES_SHA256.txt

- SHA-256: `6B352E3207BDB4D30225C49431ED3C1BD3741D13DC0B7D6B7E0447D9678D64CF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# SHA256 release manifest
# Generated without launching Project Zomboid or Steam.
CFEA888D8943A5F6D1BEA693A278527CEFFEF97E901CF1F96B084064283ECC0F  RELEASE_CHECKLIST.md
50EE84F41584D2FE0CAE55CE78D185796F5BF8D267D281C48424A3B2403315E9  RUNTIME_EVIDENCE_SUMMARY.md
18718D17FFDCB890FA77AC2D82A1E8B1FCADE6287048039C5CADC268FD1236A7  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_ActivationDiagnostic.lua
B26549958F97A397A674F12ABFFCC8FAA7802A879753D07E1E214B32E24A47C6  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Bootstrap.lua
1F577575B5F42F2FC114D573BE9CD33FE2A8AF2382DDA9C9640F0BBD910FAD44  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus.lua
2BBB6F45AF6F9896216D338DAFC3D10DA30D60B469FB962F86B93EE276E85C33  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_BreakoutPush.lua
E23D253843B8D77DAAA98164F22B46D4F77B5D8F24D80F100A965D4DD58EEB33  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_CentralWorldQuery.lua
F519378E9DDB4D0EA27848482B1F3D3CF05DD75FB7AE2924EC4708ECF5A70E50  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_CriticalWindow.lua
D44747A3317F895D966844367F4D988FA2C6EFCEE1C52D2AA5977D658822960E  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerBreakout.lua
66EEFCCA2C8C14F683B63FC87A098BB70D0FDE7884265FE7AD8F0A0DF7797583  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DragdownDangerClassifier.lua
80333270A88BD000D046DDBB4F21A8364E3AFB19C28A36D0FD719D5A4AB5BDE0  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_DraggableStatusIcon.lua
7437193A3F0F20770CFD406DBE0374ECC3A245F1F8F7827B13A84AC798553822  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakout.lua
D9AB4AC2ADD927B7ECAB9C195B708B1D8B02A2087CE23559BD87F410702A49D7  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost.lua
2FBB0832363E0F5F98CACAF42C1022DB7EE8794ACF36107AB7D8B21FD1EA4DD7  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput.lua
EF358C62E0E4FBDA99329E23C49AE3851BBD2AA30E7438A68583A5165877AFE2  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState.lua
51B350AB1EE9A0ACEE5EAD80A8A11C02D322D0CDAD6C2B1CBB54952B809F4473  WORKSHOP_UPDATE/Contents/mods/XNP_PZ_DistanceRunnerTrait/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_EnduranceCapabilityStat
[EXCERPT_TRUNCATED]
```

## FINAL_REPORT.md

- SHA-256: `B335E82CFDDF432EB5213ABB1C442D51CE88C60F21E52B09686535E356A39F0A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.49 Final Report

## Outputs

- SOURCE: `[LOCAL_PATH_REDACTED]`
- DIRECT_INSTALL: `[LOCAL_PATH_REDACTED]`
- RELEASE_READY: `[LOCAL_PATH_REDACTED]`
- WORKSHOP_UPDATE: `[LOCAL_PATH_REDACTED]`
- Editable public description: `[LOCAL_PATH_REDACTED]`

## Release Identity

- `VERSION=0.5.49`
- `INTERNAL_VERSION=0.5.49-b42-workshop-identity-public-copy-repair-a`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0549_WORKSHOP_IDENTITY_PUBLIC_COPY_REPAIR_A`
- `DISPLAY_NAME=XNP Distance Runner Trait 0.5.49 Release`
- `MOD_ID=XNP_PZ_DistanceRunnerTrait`

## Blocker Repair Results

### Public old-version cleanup

- Before: `17` historical public token hits.
- After: `0`.
- Public forbidden raw hits: `0`.
- Public forbidden semantic hits: `0`.
- SOURCE/release editable-description hash match: `true`.

This blocker is repaired.

### Workshop identity

- Workspace project configurations: no Item ID.
- AppID `108600` installed content directories checked: `167`.
- Userdata subscription candidates checked: `207` unique IDs.
- Candidates linked to this Mod ID and title: `0`.
- Accepted existing Item ID: `NOT_FOUND`.

This blocker remains. No ID was invented, inferred from a directory name, or borrowed from another mod.

## Payload Validation

- Direct-install first level: `42`, `mod.info`, `poster.png`.
- Release-ready first level: the required five entries.
- Workshop first level: `Contents`, `preview.png`, `workshop.txt`.
- Workshop runtime first level: `42`, `mod.info`, `poster.png`.
- Runtime files: `77/77/77`.
- All three pairwise runtime hash mismatches: `0`.
- Preview source: `[LOCAL_PATH_REDACTED]`.
- Preview SHA256: `BC7E41DE78015D949807310F8FD6CF9E3E0D050BFCB19DF95D3B3C69B1A3921A`.

## Evidence And Boundaries

- Console evidence is content-based and labeled 鈥滄渶鏂扮敤鎴峰疄鏈?console 鏃ュ織鈥?
- A fixed numbered console filename is not required.
- Latest in-game-validated gameplay is statically preserved.
- The current release was not launched during packaging.
- Complete multiplayer server behavior remains unverified.
- Lua execution syntax remains unverified because no local `lua` or `luac` exists.

## Safety Statement

- Old SOURCE modified: `NO`.
- Project Zomboid or Steam launched: `NO`.
- User mods, saves, Workshop staging, game installation, or Workshop upload written: `NO`.
- Package installed or uploaded: `NO`.

## Required Resolution

Provide the existing Project Zomboid Workshop page link or exact numeric Item ID for `XNP_PZ_DistanceRunnerTrait`. After that identity is proven, the draft `workshop.txt` can be converted into an existing-item update configuration.

`BLOCKER=MISSING_UNIQUE_EXISTING_WORKSHOP_ITEM_ID`

`XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.49_BLOCKED_NOT_READY`

```

## RELEASE_CHECKLIST.md

- SHA-256: `CFEA888D8943A5F6D1BEA693A278527CEFFEF97E901CF1F96B084064283ECC0F`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Release Checklist

- [x] Current version, display name, internal version, and build marker are consistent.
- [x] Mod ID remains `XNP_PZ_DistanceRunnerTrait`.
- [x] SOURCE, DIRECT_INSTALL, and Workshop runtime contain the same 77 files.
- [x] DIRECT_INSTALL has one runtime layer with `42`, `mod.info`, and `poster.png` at the first level.
- [x] Workshop runtime has one runtime layer with `42`, `mod.info`, and `poster.png` at the first level.
- [x] Preview provenance and SHA256 are verified.
- [x] Public copy contains no historical version token or prohibited promotional claim.
- [x] Console evidence is identified by content as the latest user in-game console log, not by a fixed filename.
- [x] Gameplay behavior is statically preserved from the latest validated baseline.
- [ ] Existing Workshop Item ID has authoritative proof.

This package is a release draft. It is not ready for an existing-item update until the exact Workshop page URL or numeric Item ID is supplied and verified.

```

## RUNTIME_EVIDENCE_SUMMARY.md

- SHA-256: `50EE84F41584D2FE0CAE55CE78D185796F5BF8D267D281C48424A3B2403315E9`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Runtime Evidence Summary

Evidence label: `鏈€鏂扮敤鎴峰疄鏈?console 鏃ュ織`

- Content match: `true`.
- Fixed console filename required: `false`.
- Mod loading and trait registration evidence: present.
- Master ON/OFF evidence: present.
- White OFF state evidence: present.
- Icon drag evidence: present.
- Central runtime module evidence: present.
- Real-time ten-second log throttle evidence: present.
- Current release launched during packaging: `false`.
- Complete multiplayer server validation: `false`.

The runtime payload preserves the latest in-game-validated behavior. This packaging pass did not launch Project Zomboid or Steam.

```
