# 0.5.48 Sanitized Evidence Excerpts

## 0.5.48_EXTERNAL_ERROR_SEPARATION.md

- SHA-256: `E0C9B7B62D6CC2ED3B8C8DDF2F900FECA66E285DD6A29528675C7D66C8D9B8A7`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.48 External Error Separation

The accepted 0.5.47 console contains errors and warnings from a heavily modded environment. They are not XNP blockers when the line and associated stack do not reference an XNP file, XNP module, or XNP stack frame.

External categories observed or explicitly identified by the supplied command:

- Bandits2 / BanditsWeekOne and Bandits `AddZombiesInOutfit` spawn warnings.
- `IsoGameCharacter.doDeferredMovement` errors outside XNP stacks.
- Missing clothing XML and outfit definitions.
- ImportedSkeleton bone errors.
- TankTrack, TankMachinegun, Turrent, TruckWaterTank, and other vehicle-template errors.
- FirearmUseDamageChance parsing errors.
- Missing tile, map, or item definitions.
- Randomized World item blacklist messages.
- Other errors with no XNP path, module name, or stack frame.

The mod does not claim to repair those external files or systems. A future error that points to an XNP Lua file, XNP require chain, or XNP stack remains an XNP blocker and must be investigated separately.

`STRICT_XNP_ERROR_COUNT=0`


```

## 0.5.48_CONSOLE10_RUNTIME_EVIDENCE.md

- SHA-256: `B9D511BD05920418A8A687C4FB35C68486CEEE70C2CDD189556917C6165D738C`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.48 Console Runtime Evidence

## Evidence Source

- Requested evidence label: `console(10).txt`.
- Accessible current log used for line-level verification: `[LOCAL_PATH_REDACTED]`.
- The requested filename was not present in the workspace or attachment cache, so this report records the actual accessible path and does not fabricate a filename.
- The command-supplied 0.5.47 result is treated as accepted user evidence; the current console independently contains the required 0.5.47 lines.

## Verified 0.5.47 Runtime Lines

- Line 827: `loading XNP_PZ_DistanceRunnerTrait`.
- Line 835: `native CharacterTrait registered id=XNPDistanceRunnerTrait:XNPDistanceRunner`.
- Line 885: `[XNP DR] BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0547_MASTER_ICON_TOGGLE_WHITE_OFF_A`.
- Line 886: `[XNP DistanceRunner] loaded version=0.5.47 internal=0.5.47-b42-master-icon-toggle-white-off-a build=XNP_PZ_DISTANCE_TRAIT_0547_MASTER_ICON_TOGGLE_WHITE_OFF_A`.
- Lines 888-915 include `module=MasterEffectState loaded=true`, `module=DraggableStatusIcon loaded=true`, `module=PreBiteJogRescue loaded=true`, `module=CentralWorldQuery loaded=true`, `module=PerformanceScheduler loaded=true`, and `module=TieredFoodRecovery loaded=true`.
- Line 865: `[XNP LOG] summary_interval_real_ms=10000 frame_based=false`.
- Line 3539: `[XNP MASTER TOGGLE] enabled=false source=STATUS_ICON_RIGHT_CLICK`.
- Lines 3540-3542: `MASTER_DISABLED_WHITE`, `shake=false`, `color=white`, and `right_click_toggle=true`.
- Line 3545: OFF-state `[XNP STATUS ICON DRAG] begin ... drag_captured=true`.
- Line 3565: OFF-state drag completed with `end saved=true`.
- Line 3568: `[XNP MASTER TOGGLE] enabled=true source=STATUS_ICON_RIGHT_CLICK`.

## XNP Error Check

- Strict lines containing both `ERROR`/`Exception` and `XNP`: `0`.
- No XNP Lua stack, require failure, or XNP runtime exception was identified in the accessible log.
- Lines containing words such as `success_requires` or throttle summary labels are not errors.

## Scope

This evidence validates the 0.5.47 single-player baseline and the tested icon/toggle/log behavior. It does not validate 0.5.48 in game and does not establish complete multiplayer server support.


```

## 0.5.48_PUBLIC_FEATURE_MATRIX.md

- SHA-256: `5A83206CA88EA37D47CE70D52C1948A80D110EB7BCA9F24EEBDAF8C2D04A8695`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.48 Public Feature Matrix

| Area | Master ON | Master OFF | Public boundary |
|---|---|---|---|
| Native Distance Runner Trait | Registered and object-detected | Trait remains present; XNP effects stop | Select during character creation |
| Walk No Impact | Enabled | No gameplay tick | No range-only knockdown |
| Jog Bump | Enabled with contact and cost gates | Disabled | Controlled close contact |
| Sprint / Vehicle Impact | Enabled with precollision and quota gates | Disabled | Player coordinates are not written |
| Controlled Escape / Emergency Breakout | Enabled | Disabled | Can fail in extreme surrounds |
| Pre-Bite Jog Rescue | Up to 3 targets; third is stagger-only | Disabled | Does not roll back committed bites |
| Sprint Trip / Native Trip handling | Enabled | Disabled | Does not promise immunity to every fall |
| ImpactQuota / ActionBus | Enabled | Cleared and not submitted | Coordinates priorities, cooldowns and costs |
| Tiered Food Recovery | Green off; Blue 0.005/0.015; Yellow and Red 0.010/0.020 per 2 seconds | No pulses or catch-up | Food reserve floor 0.40 |
| Stamina refund | Blue 30%, Yellow 38%, Red 55% curve | No refund | Discrete skill costs are excluded |
| Emergency endurance floor | 0.05 | No write | Authority-gated |
| SP melee bonus | Enabled for qualifying zombie hits | Multiplier 1.0 | Single-player only |
| MP melee bonus | Disabled | Disabled | Full MP validation not claimed |
| CentralWorldQuery | One local snapshot per player frame | Not built | No global zombie list |
| Status icon | Band color, shake, drag and saved position | White, visible, no shake, draggable | Custom icon, not vanilla Moodle |
| Right-click Master toggle | Can disable | Can re-enable | Press and release inside icon |
| Periodic logs | Real-time 10000 ms throttle | Gameplay summaries stop | Debug summaries default off |

Preserved values: `ZombieImpact=0.24`, `Precollision cost=0.012`, `Vehicle cost=0.018`, `coordinate write=0`, `bite rollback=false`, `infection rollback=false`, `heal=false`.


```

## 0.5.48_RELEASE_CHANGELOG.md

- SHA-256: `5B877244EE99144C6BD84697F1952A9092FA97C6B5DBA521135D16EB0A10BD67`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.48 Release Changelog

- Created an independent 0.5.48 SOURCE from the verified 0.5.47 runtime payload.
- Updated display name, public version, internal version, Build Marker, startup identity, and vehicle history namespace to 0.5.48.
- Updated Sandbox release wording without changing Sandbox keys or gameplay values.
- Preserved the 0.5.47 Master ON/OFF path, white OFF icon, left drag, saved position, and real-time 10000 ms log throttle.
- Preserved movement, impact, escape, Pre-Bite, trip, quota, stamina, food, melee, authority, and scheduler logic.
- Added a complete editable bilingual public description.
- Created a single-layer DIRECT_INSTALL payload.
- Created a Workshop update draft with the established Distance Runner preview and the same runtime payload.
- Did not invent a Workshop Item ID; final public update readiness remains blocked until the existing item ID is supplied.

No gameplay rebalance was introduced in 0.5.48.


```

## 0.5.48_RELEASE_DESCRIPTION_EDITABLE.md

- SHA-256: `24496BF1E5421E4E906EB2BB058243E89FDFB429D59A2060031F936BDEB39B15`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
鏈枃浠跺彲鐩存帴缂栬緫锛涗慨鏀瑰叕寮€鏂囨涓嶄細褰卞搷妯＄粍杩愯鏂囦欢銆?
# XNP Distance Runner Trait 0.5.48

## 涓枃璇存槑

### 涓€銆佹ā缁勫畾浣?
XNP Distance Runner Trait 鏄潰鍚?Project Zomboid Build 42.19.0 鐨勭Щ鍔ㄣ€佽€愬姏涓庤繎韬劚鍥?Trait 妯＄粍銆傝鑹查渶瑕佸湪鍒涘缓鏃堕€夋嫨鈥滈暱閫斿琚€呪€濈壒鎬э紝杩愯閫昏緫鎵嶄細鐢熸晥銆?
瀹冧笉鏄崟绾殑绉诲姩閫熷害鍊嶇巼锛屼篃涓嶆槸鏃犳晫妯＄粍銆傛牳蹇冪洰鏍囨槸鍦ㄦ琛屻€佹參璺戙€佸啿鍒恒€佽繎韬帴瑙︺€佽鍥村拰鍜激鍓嶅嵄闄╃獥鍙ｄ腑浣跨敤涓嶅悓瑙勫垯锛岃闀胯窛绂荤Щ鍔ㄥ拰杩戣韩鑴卞洶鏇存湁灞傛锛屽悓鏃朵繚鐣欒€愬姏銆侀鐗╁偍澶囥€佸喎鍗村拰鐩爣閰嶉绛夋垚鏈€?
### 浜屻€佹牳蹇冭璁″師鐞?
- 杈撳叆鎰忓浘涓庣湡瀹炵Щ鍔ㄧ姸鎬佸垎绂伙細鎸夐敭鎰忓浘鍙槸涓€椤硅瘉鎹紝绯荤粺杩樹細缁撳悎瑙掕壊鍔ㄤ綔銆佺Щ鍔ㄧ姸鎬併€佹帴杩戣秼鍔垮拰灞€閮ㄥ▉鑳佸垽鏂€?- 姝ヨ銆佹參璺戜笌鍐插埡浣跨敤涓嶅悓瑙勫垯锛氭琛屼笉涓诲姩鍒堕€犳挒鍑伙紱鎱㈣窇浣跨敤鍙楁帶鎺ヨЕ锛涘啿鍒轰娇鐢ㄦ洿涓ユ牸鐨勯纰版挒鍜屽悗鏋滀繚鎶よ矾绾裤€?- 鎺ヨЕ寮忔挒鍑伙細鍍靛案蹇呴』浣嶄簬灞€閮ㄥ墠鏂广€佽冻澶熸帴杩戝苟鍛堟寔缁帴杩戣秼鍔匡紝涓嶄娇鐢ㄨ繙璺濈鑼冨洿鍑诲€掍唬鏇跨湡瀹炴帴瑙︺€?- Pre-Bite 鏁戞彺锛氬湪鍜激鎻愪氦鍓嶇殑鐭獥鍙ｅ皾璇曟墦鏂繎韬嵄闄╋紱宸茬粡鍙戠敓鐨勫挰浼ゃ€佷激瀹虫垨鎰熸煋涓嶄細琚洖婊氥€?- ActionBus锛氱粺涓€澶勭悊鍔ㄤ綔浼樺厛绾с€佺洰鏍囬厤棰濄€佸悓鐩爣鍐峰嵈銆佷綋鍔涙垚鏈拰閲嶅璇锋眰锛屽噺灏戝涓ā鍧楀悓鏃朵綔鐢ㄤ簬鍚屼竴鐩爣銆?- CentralWorldQuery锛氭瘡鍚嶇帺瀹舵瘡甯ф渶澶氭瀯寤轰竴娆″眬閮ㄤ笘鐣屽揩鐓э紝骞朵緵澶氫釜妯″潡澶嶇敤銆?- 涓嶄娇鐢ㄥ叏灞€鍍靛案鍒楄〃锛氬▉鑳佹娴嬩緷璧栫帺瀹堕檮杩戠殑灞€閮ㄦ壂鎻忎笌缂撳瓨銆?- Authority gate锛氳€愬姏銆侀ゥ楗跨瓑鏁板€煎啓鍏ョ粡杩囨潈闄愬垽鏂紱澶氫汉鐜涓笉鎶婃櫘閫氬鎴风褰撲綔鏉冨▉鍐欏叆鏂广€?- MasterEffectState锛氬彸閿姸鎬佸浘鏍囨帶鍒跺敮涓€鎬诲紑鍏炽€傚叧闂椂锛岃繍琛屾椂鍦ㄤ腑澶皟搴﹀拰涓栫晫鏌ヨ涔嬪墠鎻愬墠閫€鍑恒€?- Committed endurance band锛氱姸鎬佸浘鏍囬鑹叉潵鑷凡缁忔彁浜ょ殑鑰愬姏鍖洪棿鐘舵€侊紝閬垮厤鐬椂鏍锋湰璁╅鑹查绻佹姈鍔ㄣ€?- Food recovery锛氭寜鐪熷疄鏃堕棿鑴夊啿缁撶畻锛屼笉鎸?FPS 閫掑綊琛ュ彂銆?- 鏃ュ織鑺傛祦锛氬懆鏈熸憳瑕佹寜鐪熷疄鏃堕棿 10 绉掔獥鍙ｈ緭鍑猴紝涓嶄娇鐢?120 甯ф憳瑕佽鏃躲€?
### 涓夈€佸畬鏁村姛鑳?
- 鍘熺敓 Trait锛氬湪鍒涘缓瑙掕壊鏃堕€夋嫨鈥滈暱閫斿琚€?/ Distance Runner鈥濓紱妯＄粍閫氳繃瀵硅薄寮忕壒璐ㄦ娴嬬‘璁よ鑹叉槸鍚︽嫢鏈夎 Trait銆?- Walk No Impact锛氭櫘閫氭琛屼笉涓诲姩瑙﹀彂 XNP 鍍靛案鎾炲嚮鏁堟灉銆?- Jog Bump锛氭參璺戝苟婊¤冻鎺ヨЕ瓒嬪娍鏃讹紝浣跨敤鍙楁帶鎺ㄦ尋鎴栫‖鐩磋矾绾匡紝骞舵敮浠樼嫭绔嬫垚鏈€?- Sprint Impact锛氬叏鍔涘啿鍒烘椂浣跨敤鍓嶅悜棰勭鎾炪€佹帴瑙﹂棬妲涗笌鍍靛案渚у弽搴旓紝涓嶉€氳繃鍐欑帺瀹跺潗鏍囧埗閫犱綅绉汇€?- Vehicle/Precollision 璺嚎锛氫繚鐣欏凡楠岃瘉鐨勮溅杈嗙瓑浠峰垽瀹氬拰鍐插埡棰勭鎾炴垚鏈紱棰勭鎾炴渶缁堟垚鏈负 0.012锛岃溅杈嗘挒鍑绘渶缁堟垚鏈负 0.018銆?- Controlled Escape锛氳鑹蹭繚鎸佽窇鍔ㄦ垨鍐插埡杈撳叆骞跺浜庤繎韬彈闃荤獥鍙ｆ椂锛屽彲璇锋眰鍙楁帶鑴卞洶銆?- Emergency Breakout锛氫弗閲嶅寘鍥存垨鎶撳彇鍗遍櫓浣跨敤鐙珛绱ф€ヨ矾绾匡紝骞朵繚鐣?5% 绱ф€ヨ€愬姏涓嬮檺銆?- Pre-Bite Jog Rescue锛氬湪鍜激鎻愪氦鍓嶅皾璇曞鐞嗘渶澶?3 涓洰鏍囷紱绗?3 鐩爣浠呬娇鐢?stagger锛屼笉鎵胯澶勭悊绗?4 涓強鏇村鐩爣銆?- Sprint Trip Immunity锛氬啿鍒烘帴瑙﹀悗鐩戞帶鐜╁鍚庢灉锛屽湪绗﹀悎鏉′欢鐨勫嵄闄╃獥鍙ｄ腑灏濊瘯鍑忓皯缁婂€掗摼缁х画鍙戝睍銆?- Native Trip锛氬師鐢熺粖鍊掑悗鏋滅敱鐙珛娑堣垂璺嚎澶勭悊锛屼笉浼€犵帺瀹?bumped 鐘舵€併€?- ImpactQuota锛氶檺鍒剁煭鏃堕棿鍐呴珮寮哄害鍍靛案鏁堟灉锛岄厤棰濅笉瓒虫椂鍙檷绾т负杈冭交鍙嶅簲銆?- SP Melee bonus锛氬崟鏈轰腑锛岄珮鑰愬姏涓斿懡涓兊灏哥殑鍚堟牸杩戞垬鏀诲嚮鍙幏寰椾簨浠堕┍鍔ㄥ姞鎴愩€?- MP Melee锛氬綋鍓嶅叧闂紝涓嶆妸鏈粡澶氫汉瀹炴祴鐨勪激瀹冲啓鍏ヤ綔涓烘寮忓姛鑳姐€?- Tiered Food Recovery锛欸reen 涓嶈繘琛岀洿鎺ヨ浆鎹紱Blue 姣?2 绉掓秷鑰?0.005 椋熺墿鍌ㄥ骞舵仮澶?0.015 鑰愬姏锛沋ellow 姣?2 绉掓秷鑰?0.010 骞舵仮澶?0.020锛汻ed 姣?2 绉掓秷鑰?0.010 骞舵仮澶?0.020銆傞鐗╁偍澶囦笉浼氬洜璇ヨ剦鍐蹭綆浜?0.40銆?- 杩炵画濂旇窇鑰愬姏杩旇繕锛欱lue銆乊ellow銆丷ed 榛樿鍒嗗埆鎸?30%銆?8%銆?5% 鐨勫尯闂存洸绾垮鐞嗚繛缁嚜鐒舵秷鑰楋紱涓诲姩鎶€鑳姐€佹挒鍑汇€佽劚鍥板拰缁婂€掓垚鏈笉浼氳褰撲綔鑷劧娑堣€楄繑杩樸€?- 鐘舵€佸浘鏍囷細Green銆丅lue銆乊ellow銆丷ed 鏄剧ず宸叉彁浜よ€愬姏鍖洪棿锛涗綆鑰愬姏鍖洪棿鍙惎鐢ㄦ姈鍔ㄣ€?- 宸﹂敭鎷栧姩锛氱洿鎺ユ嫋鍔ㄥ浘鏍囧苟淇濆瓨浣嶇疆锛屾澗寮€浣嶇疆涓嶅繀浠嶅湪鍥炬爣鑼冨洿鍐呫€?- 鍙抽敭鎬诲紑鍏筹細鍦ㄥ浘鏍囧唴鎸変笅骞堕噴鏀惧彸閿垏鎹?Master ON/OFF銆?- OFF 绾櫧鐘舵€侊細鍥炬爣淇濇寔鏄剧ず銆佷繚鎸佸彲鎷栧姩骞跺厑璁稿彸閿噸鏂板紑鍚紝浣嗕笉杩愯 XNP 鐜╂硶鏁堟灉銆?- OFF 鍋滄鑼冨洿锛氳€愬姏/楗ラタ鍐欏叆銆佹垚鏈€丄ctionBus 璇锋眰銆佸眬閮ㄤ笘鐣屾煡璇€佽繎鎴樺€嶇巼銆佸兊灏告晥鏋滃拰椋熺墿鑴夊啿鍋滄銆?- 鍐嶅紑鍚涓猴細涓嶈ˉ鍙戝叧闂湡闂寸殑椋熺墿鑴夊啿锛屼笉澶嶇敤鏃х洰鏍囥€佹棫鍗遍櫓绐楀彛鎴栨棫鍔ㄤ綔璇锋眰銆?- Sandbox锛氬彲璋冩暣鎶€鑳芥垚鏈€佹挒鍑绘垚鏈€佽€愬姏杈呭姪銆侀鐗╂仮澶嶃€佸浘鏍囨樉绀恒€佸浘鏍囨姈鍔ㄥ拰璋冨害鍙傛暟锛涘浜哄弬鏁颁互鏈嶅姟鍣ㄦ潈濞佽缃负鍑嗐€?
### 鍥涖€佺姸鎬佸浘鏍囪鏄?
- Green锛氭甯歌€愬姏鐘舵€侊紝鏈惎鐢ㄥ垎绾ц€愬姏鏀寔銆?- Blue锛氳交搴﹁€愬姏鏀寔
[EXCERPT_TRUNCATED]
```

## 0.5.48_RUNTIME_HASH_MANIFEST.md

- SHA-256: `3DBF2C33FE8871957A3555311C21DD879537AFE5A9AB252B1736C7728F4B893B`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.48 Runtime SHA256 Manifest

Canonical root: `[LOCAL_PATH_REDACTED]`

The same 77 relative paths and hashes were verified in SOURCE, DIRECT_INSTALL, and Workshop payload.

```text
18718D17FFDCB890FA77AC2D82A1E8B1FCADE6287048039C5CADC268FD1236A7  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ActivationDiagnostic.lua
5EB7FEEDFC069B5079847FD6254DE45A52645E13A47B592FD4FED2A51E32E415  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
1F577575B5F42F2FC114D573BE9CD33FE2A8AF2382DDA9C9640F0BBD910FAD44  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutActionBus.lua
4149AB8F3EF94810F00F6788646EF873288EDEFCA054F8FB61E795CCDC7F6C5E  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua
E23D253843B8D77DAAA98164F22B46D4F77B5D8F24D80F100A965D4DD58EEB33  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CentralWorldQuery.lua
F519378E9DDB4D0EA27848482B1F3D3CF05DD75FB7AE2924EC4708ECF5A70E50  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CriticalWindow.lua
D44747A3317F895D966844367F4D988FA2C6EFCEE1C52D2AA5977D658822960E  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerBreakout.lua
66EEFCCA2C8C14F683B63FC87A098BB70D0FDE7884265FE7AD8F0A0DF7797583  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerClassifier.lua
80333270A88BD000D046DDBB4F21A8364E3AFB19C28A36D0FD719D5A4AB5BDE0  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DraggableStatusIcon.lua
7437193A3F0F20770CFD406DBE0374ECC3A245F1F8F7827B13A84AC798553822  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua
D9AB4AC2ADD927B7ECAB9C195B708B1D8B02A2087CE23559BD87F410702A49D7  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakoutCost.lua
2FBB0832363E0F5F98CACAF42C1022DB7EE8794ACF36107AB7D8B21FD1EA4DD7  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyInput.lua
EF358C62E0E4FBDA99329E23C49AE3851BBD2AA30E7438A68583A5165877AFE2  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceBandState.lua
51B350AB1EE9A0ACEE5EAD80A8A11C02D322D0CDAD6C2B1CBB54952B809F4473  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceCapabilityState.lua
BD35C4C9FE836E980345C906F4B5C21ECD631DFBDD669BB68A3FD2929CFC1FD0  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FallRecoveryInput.lua
E234851419C87572FA347F980A4348C891CF993969BC523033E2D9C4434A979D  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FoodReserveConversion.lua
F7933096B64322DAF1E7353AA60EA18C632BB5BCAA6DA357449FECC813E0D156  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactCandidateSnapshot.lua
2412BB836713B13FFB253F52AA328AFAC12B1D251056500D97F9659F551FB8DB  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactQuotaMeter.lua
4116EA75B3676B0E1D5EEF8E188F13D04A60FB704BE2C94ED6E34486DA5239D4  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_JogBumpLaunch.lua
A9CB666E47997E98CA38A7275A5153CD65AD216A1992A156C5C2D423AB92B199  42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_JogFallShockwave.lua
1D6C0E8EA466846CEBFD439C45334E968DBBBDC000413E0102C0AA79A8F20
[EXCERPT_TRUNCATED]
```

## 0.5.48_SP_MP_SUPPORT_BOUNDARY.md

- SHA-256: `C670E545B2E71DD4D116D2313A8B55A1F3CA2E970394181915C84130F3190513`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.48 Single-Player / Multiplayer Boundary

## Single-Player

- 0.5.47 loading, module startup, native trait registration, right-click OFF/ON, white OFF state, OFF-state dragging, and real-time 10-second log throttling have in-game evidence.
- 0.5.48 preserves that runtime logic and changes release identity and documentation only.
- 0.5.48 itself still requires user in-game confirmation after installation.

## Multiplayer

- Endurance and hunger writes use authority gates.
- Normal clients are not treated as authoritative zombie/stat writers.
- MP melee bonus is disabled.
- Server-side food and melee routes honor Master disabled state.
- Per-player Master state is stored in player modData.
- Full server/client synchronization, reconnect behavior, dedicated-server operation, and multi-player toggle propagation are `NOT_VERIFIABLE_BY_STATIC_AUDIT` and have not been validated in a real multiplayer server session.

Public claim: server-authority safeguards are present. Public claim not made: complete multiplayer support.


```

## 0.5.48_WORKSHOP_ITEM_ID_PROOF.md

- SHA-256: `56541E3946C90E46B44D742A688D78970EFA9074E3C5AE43DF8440AFC626BD29`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.48 Workshop Item ID Proof

## Search Scope

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`
- Related `workshop.txt` files under `[LOCAL_PATH_REDACTED]`
- Read-only `[LOCAL_PATH_REDACTED]`
- Related files under `[LOCAL_PATH_REDACTED]`

## Result

- The only Distance Runner upload configuration found is the 0.5.37 first-upload template.
- Its title and payload identify `XNP_PZ_DistanceRunnerTrait` correctly.
- It contains no `id=`, `itemid=`, `publishedfileid=`, or `workshopid=` field.
- The 0.5.37 audit explicitly says: first upload, then record the real Workshop ID.
- The user Workshop directory contains only `ModTemplate\workshop.txt`, also without a published item ID.
- Unique existing Distance Runner Workshop Item ID count: `0`.

No ID was invented and no L4D2 or other mod ID was used.

`WORKSHOP_ITEM_ID_STATUS=BLOCKED_MISSING_EXISTING_ID`

This is the only release gate blocker found in the current static build. The Workshop directory is a reviewable update draft, not a directly submit-ready update until the real existing item ID is supplied.


```

## BUILD_MARKER.txt

- SHA-256: `990850121678E75C9D42DF621AA08BE51C2C20DC9163E34B775B6009D6A88651`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0548_PUBLIC_RELEASE_A

```

## FILE_HASHES_SHA256.txt

- SHA-256: `7C6B8679B117AE71EC12BEC415367EDB476B28C48C66F45F7D7AFC72E25B86CB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# SHA256 manifest for XNP Distance Runner Trait 0.5.48
# Generated from final files; this manifest intentionally excludes itself.
# SOURCE_RUNTIME, DIRECT_INSTALL, and WORKSHOP_RUNTIME are listed separately.
18718D17FFDCB890FA77AC2D82A1E8B1FCADE6287048039C5CADC268FD1236A7  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ActivationDiagnostic.lua
5EB7FEEDFC069B5079847FD6254DE45A52645E13A47B592FD4FED2A51E32E415  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_Bootstrap.lua
1F577575B5F42F2FC114D573BE9CD33FE2A8AF2382DDA9C9640F0BBD910FAD44  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutActionBus.lua
4149AB8F3EF94810F00F6788646EF873288EDEFCA054F8FB61E795CCDC7F6C5E  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_BreakoutPush.lua
E23D253843B8D77DAAA98164F22B46D4F77B5D8F24D80F100A965D4DD58EEB33  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CentralWorldQuery.lua
F519378E9DDB4D0EA27848482B1F3D3CF05DD75FB7AE2924EC4708ECF5A70E50  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_CriticalWindow.lua
D44747A3317F895D966844367F4D988FA2C6EFCEE1C52D2AA5977D658822960E  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerBreakout.lua
66EEFCCA2C8C14F683B63FC87A098BB70D0FDE7884265FE7AD8F0A0DF7797583  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DragdownDangerClassifier.lua
80333270A88BD000D046DDBB4F21A8364E3AFB19C28A36D0FD719D5A4AB5BDE0  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_DraggableStatusIcon.lua
7437193A3F0F20770CFD406DBE0374ECC3A245F1F8F7827B13A84AC798553822  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakout.lua
D9AB4AC2ADD927B7ECAB9C195B708B1D8B02A2087CE23559BD87F410702A49D7  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyBreakoutCost.lua
2FBB0832363E0F5F98CACAF42C1022DB7EE8794ACF36107AB7D8B21FD1EA4DD7  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EmergencyInput.lua
EF358C62E0E4FBDA99329E23C49AE3851BBD2AA30E7438A68583A5165877AFE2  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceBandState.lua
51B350AB1EE9A0ACEE5EAD80A8A11C02D322D0CDAD6C2B1CBB54952B809F4473  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_EnduranceCapabilityState.lua
BD35C4C9FE836E980345C906F4B5C21ECD631DFBDD669BB68A3FD2929CFC1FD0  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FallRecoveryInput.lua
E234851419C87572FA347F980A4348C891CF993969BC523033E2D9C4434A979D  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_FoodReserveConversion.lua
F7933096B64322DAF1E7353AA60EA18C632BB5BCAA6DA357449FECC813E0D156  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactCandidateSnapshot.lua
2412BB836713B13FFB253F52AA328AFAC12B1D251056500D97F9659F551FB8DB  SOURCE_RUNTIME::42\media\lua\client\XNP_PZ_DistanceRunner\XNP_DR_ImpactQuotaMeter.lua
4116EA75B3676B0E1D5
[EXCERPT_TRUNCATED]
```

## FINAL_REPORT.md

- SHA-256: `D2376591F6351C6CF8123DD8E13E7B7DC1C2E9C0C6B49B464C11CB1EB8D70751`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner Trait 0.5.48 Final Report

## Outputs

- SOURCE: `[LOCAL_PATH_REDACTED]`
- DIRECT_INSTALL root: `[LOCAL_PATH_REDACTED]`
- User drag folder: `[LOCAL_PATH_REDACTED]`
- RELEASE_READY: `[LOCAL_PATH_REDACTED]`
- WORKSHOP_UPDATE draft: `[LOCAL_PATH_REDACTED]`
- Workshop runtime: `[LOCAL_PATH_REDACTED]`
- Editable public description: `[LOCAL_PATH_REDACTED]`

## Release Identity

- `VERSION=0.5.48`
- `INTERNAL_VERSION=0.5.48-b42-public-release-a`
- `BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0548_PUBLIC_RELEASE_A`
- `DISPLAY_NAME=XNP Distance Runner Trait 0.5.48 Release`
- `MOD_ID=XNP_PZ_DistanceRunnerTrait`

## Direct Install Tree

```text
XNP_PZ_DistanceRunnerTrait
鈹溾攢 42
鈹溾攢 mod.info
鈹斺攢 poster.png
```

- `NO_EXTRA_WRAPPER=true`
- `TOP_LEVEL_UNEXPECTED_ENTRY_COUNT=0`

## Workshop Configuration

- Item ID: `NOT_FOUND`.
- Search proof: `0.5.48_WORKSHOP_ITEM_ID_PROOF.md`.
- The 0.5.37 upload package is a first-upload template and contains no published ID.
- Preview source: `[LOCAL_PATH_REDACTED]`.
- Preview: PNG, 256x256, SHA256 `BC7E41DE78015D949807310F8FD6CF9E3E0D050BFCB19DF95D3B3C69B1A3921A`.
- `workshop.txt`: `version=1`, bilingual Distance Runner title/description, 0.5.48 changenote, tags `Build 42;Multiplayer;Traits;Balance`, visibility `public`.
- No local absolute path is present in public workshop fields.
- WORKSHOP_UPDATE is a structurally complete draft but is not a directly submit-ready update without the existing Item ID.

## Runtime Evidence And Preservation

- 0.5.47 loaded and registered the native CharacterTrait.
- Required modules loaded, including MasterEffectState, DraggableStatusIcon, CentralWorldQuery, PerformanceScheduler, TieredFoodRecovery, and PreBiteJogRescue.
- Right-click produced OFF and ON transitions.
- OFF entered white state, remained active, and accepted a complete drag before re-enable.
- Log throttle initialized with `summary_interval_real_ms=10000 frame_based=false`.
- Strict XNP ERROR/Exception count in the accessible current console: `0`.
- Bandits/NPC/XML/skeleton/vehicle/map errors without XNP paths are separated as external.
- ON gameplay matrix, OFF early exit, white icon priority, dragging, no catch-up, and authority gates are preserved from 0.5.47.

## Public Feature And SP/MP Boundary

- Complete public feature matrix: `0.5.48_PUBLIC_FEATURE_MATRIX.md`.
- SP/MP boundary: `0.5.48_SP_MP_SUPPORT_BOUNDARY.md`.
- Single-player baseline has in-game evidence.
- Full multiplayer server behavior is not claimed as verified.
- MP melee remains disabled.

## Static And Hash Results

- `LUA_FILE_COUNT=66`
- `LUA_TOTAL_LINES=12560`
- `OLD_IDENTITY_RESIDUE_COUNT=0`
- `SANDBOX_KEY_DIFF=0`
- `UI_KEY_DIFF=0`
- `BANNED_COUNT=0`
- `SOURCE_DIRECT_HASH_MISMATCH_COUNT=0`
- `SOURCE_WORKSHOP_HASH_MISMATCH_COUNT=0`
- `DIRECT_WORKSHOP_HASH_MISMATCH_COUNT=0`
- `RUNTIME_FILE_COUNT_MATCH=true`
- `POSTER_HASH_MATCH=true`
- `MOD_INFO_ID_MATCH=true`
- Lua 5.1 executable syntax test: `NOT_VERIFIABLE_BY_STATIC_AUDIT` because no 
[EXCERPT_TRUNCATED]
```

## RELEASE_CHECKLIST.md

- SHA-256: `E8B897A4171F9DBD998AD49AC6F33948CAE002A39CC0B46AE2C968BCBAC8D1E3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner 0.5.48 Release Checklist

- [x] Independent 0.5.48 SOURCE created.
- [x] Version, internal version, display name, Build Marker and startup identity updated.
- [x] 0.5.47 gameplay runtime preserved apart from identity/release wording.
- [x] Single-layer DIRECT_INSTALL created.
- [x] Workshop payload created without an extra wrapper.
- [x] Existing Distance Runner 256x256 preview copied and hash verified.
- [x] Editable bilingual public description created outside runtime payloads.
- [x] Three runtime payloads contain 77 files and have matching hashes.
- [x] CN/EN Sandbox and UI key parity passed.
- [x] Old 0.5.47/0547/0.5.46/0546 active identity residue count is zero.
- [x] No PZ or Steam launch, user-directory write, or upload performed.
- [ ] Insert the unique existing Distance Runner Workshop Item ID after the user supplies authoritative evidence.
- [ ] Re-run Workshop ID validation.
- [ ] Perform user-controlled 0.5.48 in-game test.
- [ ] Perform multiplayer server validation before claiming full MP support.

Current gate: `XNP_PZ_DISTANCE_RUNNER_TRAIT_0.5.48_BLOCKED_NOT_READY`.


```
