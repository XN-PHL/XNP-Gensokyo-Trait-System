# 0.5.54 Sanitized Evidence Excerpts

## 0.5.54_CONSOLE_ROOT_CAUSE_REPORT.md

- SHA-256: `31E21DC2B00CB5965384935789252F8C5C7300A0ECFAC3D12A93E19F98C9CE1E`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# 0.5.54 Console Root Cause Report

ROOT_CAUSE_FPS_DROP=FULL_FATAL_TIMING_DIAGNOSTIC_REPEATED_NIL_CALL_ERROR_STORM

## Accepted runtime evidence

- Repeated failures originated from `XNP_DR_FullFatalTimingDiagnostic.lua` around `readSnapshot` and `OnPlayerGetDamage`.
- The same nil-call route repeated thousands of times and was event driven, making it a sufficient explanation for the reported severe frame loss.
- `WarThunderVehicleLibrary/HeliSoundUpdate.lua:69` is a third-party error and was not modified or attributed to XNP.
- Phoenix protected one user-observed high-fall fatal event. The diagnostic module is therefore not required by the formal Phoenix protection path.

XNP_REPEATED_NIL_CALL_ROUTE_REMOVED=true
FULL_FATAL_DIAGNOSTIC_IN_DROP=false
REPEATED_ERROR_ROUTE_COUNT=0


```

## 0.5.54_BLUE_ECO_BARRAGE_IMPLEMENTATION_REPORT.md

- SHA-256: `24B98D7861B11546BB0B7FEDAA7CBD0DBF02EC9ADF784E05642D51BA69B876DE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Blue Eco Barrage Implementation Report

TRAIT_FULL_ID=XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage
TRAIT_COST=1
GRANTED_RECIPE=MakeBlueEcoBarrageBomb
ITEM_FULL_TYPE=XNPBlueEcoBarrage.BlueEcoBarrageBomb
STATE_KEY=XNP_BLUE_BARRAGE_ENABLED

## B42 evidence and route

- Native throwable fields were matched to `[LOCAL_INSTALL_PATH]/ProjectZomboid/media/scripts/generated/items/weapon.txt`, including `PhysicsObject = Base.SmokeBomb`, `SwingAnim = Throw`, `UseSelf`, timer, smoke, noise, and fire/explosion fields.
- All 37 custom item properties were seen in the installed B42 weapon script.
- Craft fields were matched to installed B42 `craftRecipe` files.
- `CraftRecipeData` passes `(recipeData, character)` to `OnCreate`; the callback adds only configured extra outputs.
- `IsoTrap` exposes `getHandWeapon`, `getAttacker`, and `getSquare`; `OnObjectAboutToBeRemoved` supplies the exact native trap object used for the one-shot effect.

Materials verified in installed B42 scripts:

- `Base.TinCanEmpty`
- `Base.ElectronicsScrap`
- `Base.Wire`
- `Base.DuctTape`

## Safety

NATIVE_EXPLOSION_POWER=0
NATIVE_FIRE_POWER=0
FRIENDLY_FIRE=false
PLAYER_BODY_DAMAGE_WRITES=0
PLAYER_COORDINATE_WRITES=0
CONTINUOUS_WORLD_SCANNERS=0
LOCAL_QUERY_PER_DETONATION=1
PROCESSED_INSTANCE_CACHE_CAP=64

The event filters by exact item full type and trait-owning attacker, deduplicates an instance, then queries only local squares and affects only `IsoZombie`. Damage is clamped to leave at least `0.1` zombie health. Visual feedback is a blue projectile texture, short native smoke, and a 650 ms blue UI pulse.

SP_STATIC_ROUTE_VERIFIED=true
SP_REAL_GAME_TEST_REQUIRED=true
MP_NOT_VERIFIED=true


```

## 0.5.54_FATAL_DIAGNOSTIC_REMOVAL_REPORT.md

- SHA-256: `FD7F8D44B35B2EDE8AD0B0288C661409C3263698CC135347C60FE061E64841C5`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Fatal Diagnostic Removal Report

FULL_FATAL_DIAGNOSTIC_IN_SOURCE_RUNTIME=false
FULL_FATAL_DIAGNOSTIC_IN_DROP=false
FULL_FATAL_DIAGNOSTIC_REQUIRE_ACTIVE_HITS=0
FULL_FATAL_DIAGNOSTIC_EVENT_REGISTRATION_ACTIVE_HITS=0
READ_SNAPSHOT_RUNTIME_HITS=0
XNP_REPEATED_NIL_CALL_ROUTE_REMOVED=true

Removed from the 0.5.54 runtime tree:

`42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_FullFatalTimingDiagnostic.lua`

Also removed from `XNP_DR_Bootstrap.lua`:

- diagnostic `require`;
- conflict-gate call;
- diagnostic event registration;
- conditional suppression of the formal runtime and Phoenix guard.

`EnableRuntimeDebug=false` is present as a reserved Sandbox option. No debug event module is registered.


```

## 0.5.54_FEAST_GUARDIAN_IMPLEMENTATION_REPORT.md

- SHA-256: `E917A023B8B3A472A2D320FCC07EFA8E4D29E95B6FCAF410256F9D9B3C6739C2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Feast Guardian Implementation Report

TRAIT_FULL_ID=XNPFeastGuardianTrait:XNPFeastGuardian
TRAIT_COST=1
STATE_KEY=XNP_FEAST_GUARDIAN_ENABLED
FOOD_CHECK_HZ=1
HIGHEST_FOOD_EATEN_LEVEL=3
DEFAULT_REARM_LEVEL=1
DEFAULT_FRACTURE_HEAL_MULTIPLIER=3

Installed B42 Lua prevents further eating at `MoodleType.FOOD_EATEN >= 3` in `ISInventoryPaneContextMenu.lua:500`; the same threshold is used as the verified highest-food trigger. Purification occurs only on the armed-to-highest edge. The feature rearms only after the level falls to the configured lower threshold, providing hysteresis.

Verified B42 methods used:

- `BodyDamage:setInfected`, `setInfectionTime`, `setIsFakeInfected`, `getBodyParts`
- `BodyPart:SetInfected`, `SetFakeInfected`, `setInfectedWound`, `setWoundInfectionLevel`
- `BodyPart:getFractureTime`, `setFractureTime`, `getSplintFactor`

The three cure settings are independent. Missing required APIs fail closed: state becomes `ERROR`, one error is logged, and only the red feature is disabled.

Fracture acceleration samples once per game hour. It observes actual vanilla fracture-time reduction and adds `(multiplier - 1) * observedVanillaProgress`; it does not guess a base rate or instantly zero fracture time.

RED_PURIFICATION_REAL_GAME_TEST_REQUIRED=true
RED_FRACTURE_MULTIPLIER_REAL_GAME_TEST_REQUIRED=true
MP_NOT_VERIFIED=true


```

## 0.5.54_FOUR_ICON_ASSET_AND_ISOLATION_REPORT.md

- SHA-256: `BEE5FF222432A721200B20189964404BFC641E49F8E43F9BD5F3DD8306B6CFF0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Four Icon Asset And Isolation Report

ICON_CANVAS=18x18
ROUND_ALPHA_TEMPLATE=trait_xnpdistancerunner.png
PANEL_COUNT=4
SHARED_ENABLED_KEYS=0
SHARED_POSITION_KEYS=0
GLOBAL_MASTER_TOGGLE_CALLS_FROM_PURPLE_BLUE_RED=0

Icons and SHA256:

- Yellow `trait_xnpdistancerunner.png`: `8980BEC2904E9646D41473E9EC93D02F1B0C5EAA0D42F1B4EAC9FDCBCF593CA9`
- Phoenix `trait_xnppurplephoenix.png`: `6273E586EB260B167C236FABDEC4A039973AFDD1D78355A6487F1601101FCDDE`
- Blue `trait_xnpblueecobarrage.png`: `53B4E6F90FBB21B2603F6B3ECF169DFC808FD05C77AB6549A92543A81F69B4C9`
- Red `trait_xnpfeastguardian.png`: `8EB15CE11E99750CB597AB1890A7019EE2A78C455DE53C16EC2882F0B41BECC9`
- Blue item `Item_XNPBlueEcoBarrageBomb.png`: `CE2EFFD00FEBA8EB0D1C021CFCE2CF1E0ABF74E3D6E94F8FDA5FF8B862038727`

Blue and red assets are deterministic recolors of the verified yellow 18x18 alpha template. Their transparent outline was preserved. The blue item texture is the same template scaled to 32x32 and deterministically tinted.

Independent position/state ownership:

- Yellow: existing yellow panel and ModData position route
- Phoenix: `XNP_PurplePhoenix_IconX/Y`, `XNP_DR_PHOENIX_ENABLED`
- Blue: `XNP_UI_BLUE_BARRAGE_POS`, `XNP_BLUE_BARRAGE_ENABLED`
- Red: `XNP_UI_FEAST_GUARDIAN_POS`, `XNP_FEAST_GUARDIAN_ENABLED`


```

## 0.5.54_FOUR_TRAIT_REGISTRATION_REPORT.md

- SHA-256: `617BE3A3996E706A2F792B2897355785E7328AA3BED716113701143D02827F7C`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Four Trait Registration Report

DISTANCE_RUNNER_FULL_ID=XNPDistanceRunnerTrait:XNPDistanceRunner
PHOENIX_FULL_ID=XNPPhoenixTrait:XNPPurplePhoenix
BLUE_ECO_BARRAGE_FULL_ID=XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage
FEAST_GUARDIAN_FULL_ID=XNPFeastGuardianTrait:XNPFeastGuardian

DISTANCE_RUNNER_COST=1
PHOENIX_COST=1
BLUE_ECO_BARRAGE_COST=1
FEAST_GUARDIAN_COST=1

ALL_FOUR_TRAITS_VISIBLE=true
ALL_FOUR_TRAITS_SELECTABLE_TOGETHER=true
TRAIT_MUTUAL_EXCLUSION_COUNT=0
TRAIT_ID_COLLISION_COUNT=0
TRANSLATION_KEY_COLLISION_COUNT=0
CHARACTER_TRAIT_DEFINITION_COUNT=4

All traits use B42 `character_trait_definition` plus `CharacterTrait.register`. Runtime ownership detection resolves native trait objects and scans the known-trait object collection; string `player:hasTrait` is not introduced.


```

## 0.5.54_KAHLUA_AND_SCRIPT_SYNTAX_REPORT.md

- SHA-256: `3F167D78E9556A4D0291BB9A3B441E189DF9F172F602F734349B0D15D8BD1393`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Kahlua And Script Syntax Report

PROJECTZOMBOID_JAR=[LOCAL_PATH_REDACTED]
JAVA=[LOCAL_PATH_REDACTED]
COMPILER=se.krka.kahlua.luaj.compiler.LuaCompiler.loadis(Reader,String,KahluaTable)
KAHLUA_RUNTIME_LUA_SYNTAX_PASS_COUNT=80
KAHLUA_RUNTIME_LUA_SYNTAX_FAIL_COUNT=0
REQUIRE_MISSING_COUNT=0
REQUIRE_CYCLE_COUNT=0

ITEM_PROPERTY_COUNT=37
ITEM_PROPERTY_NOT_SEEN_IN_B42_WEAPON_COUNT=0
CRAFT_RECIPE_FIELD_MISMATCH_COUNT=0
SCRIPT_BRACE_BALANCE_ERRORS=0
BLUE_ITEM_DECLARATION_COUNT=1
BLUE_RECIPE_DECLARATION_COUNT=1

JSON_PARSE_FAILURE_COUNT=0
TRANSLATION_PARITY_FAILURE_COUNT=0
TEXT_BOM_COUNT=0
TEXT_NULL_COUNT=0
EMPTY_RUNTIME_FILE_COUNT=0

The final Kahlua output is stored at `_kahlua_check/kahlua_syntax_output_0554_final.txt` in SOURCE only.


```

## 0.5.54_PERFORMANCE_EVENT_BUDGET_REPORT.md

- SHA-256: `8168C4DCF3545B87D59A23FB15D0A5DEAE660CBA899CA597B9BFD81E55829FFC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Performance Event Budget Report

XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_GET_DAMAGE_HANDLER_COUNT=1
XNP_ON_OBJECT_ABOUT_TO_BE_REMOVED_HANDLER_COUNT=1
UI_MAX_REFRESH_HZ=4
RED_FOOD_CHECK_MAX_HZ=1
DIAGNOSTIC_DEFAULT_ENABLED=false
REPEATED_ERROR_ROUTE_COUNT=0

## Budget

- `Bootstrap` owns the single XNP `OnPlayerUpdate` registration.
- All four status UIs use the central scheduler `ui` lane at 0.25 seconds. World entry creates panels once; it does not establish another update loop.
- Feast Guardian uses the central scheduler `food` lane at 1.0 second. Fracture writes are additionally limited to one game-hour boundary.
- Blue Eco Barrage has no tick/update scanner. Its local radius query runs once for an exact XNP trap removal event.
- Existing central threat scan: idle 2 Hz, moving 4 Hz, active 10 Hz; the critical/impact lane can reach 20 Hz only inside a bounded danger window.
- Phoenix threshold/recovery polling now uses the scheduler light/critical lane. Its formal damage guard remains event based.
- UI/state logs are edge logs. Idle gameplay has no new per-frame logging.


```

## 0.5.54_PHOENIX_GAMEPLAY_PRESERVE_REPORT.md

- SHA-256: `53A48C5BF98706F8F9F11790B39253E932DDB7C0DBF3547C738161CD93012D59`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Phoenix Gameplay Preserve Report

PHOENIX_FALL_FATAL_PROTECTION_USER_VERIFIED=true
PHOENIX_TRAIT_COST=1
PHOENIX_DEFAULT_TRIGGER_HEALTH=20_PERCENT
PHOENIX_INVULNERABILITY_SECONDS=10
PHOENIX_BASE_COOLDOWN_GAME_DAYS=7

Preserved formal modules cover critical-health/fall candidates, finite invulnerability, panic-zero recharge gating, well-fed and healthy early credit, infection/zombification cleanup, endurance restoration, local zombie displacement, independent ModData, and an independent right-click toggle.

The FullFatal diagnostic was not a dependency of these formal modules and was removed without removing the damage guard, revive, protection, invulnerability, state, or UI modules.

USER_VERIFIED_SCOPE=ONE_HIGH_FALL_SAMPLE
FIREARM_FATAL_PROTECTION=REAL_GAME_TEST_REQUIRED
FIRE_FATAL_PROTECTION=REAL_GAME_TEST_REQUIRED
VEHICLE_FATAL_PROTECTION=REAL_GAME_TEST_REQUIRED


```

## 0.5.54_PHOENIX_UI_LIFECYCLE_FIX_REPORT.md

- SHA-256: `B26B1AB2C99497119BC091E4AD595E9930B91463E74FBABBF775B791DC89AF28`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Phoenix UI Lifecycle Fix Report

PHOENIX_PANEL_CREATED_ON_WORLD_ENTRY=true
PHOENIX_PANEL_SINGLETON=true
PHOENIX_PANEL_VISIBLE_DURING_COOLDOWN=true
PHOENIX_PANEL_POSITION_CLAMPED=true
PHOENIX_PANEL_RECREATE_PER_FRAME=false
PHOENIX_TEXTURE_LOAD_VERIFIED=true
PHOENIX_UI_DEPENDS_ON_YELLOW=false
PHOENIX_ICON_SIZE=18x18

`Bootstrap.OnGameStart` and `Bootstrap.OnCreatePlayer` call `PurplePhoenixUI.Update` after trait-cache refresh. The panel is stored in one module-local singleton and is only removed during cleanup transitions.

The UI displays `OFF`, `READY`, `INVULNERABLE`, `COOLDOWN`, and `WAITING_FOR_CALM`. Cooldown changes color but does not hide the panel. Saved coordinates are clamped to the current screen, and the panel is always-on-top independently of the yellow panel.

Texture: `42/media/ui/Traits/trait_xnppurplephoenix.png`

SHA256: `6273E586EB260B167C236FABDEC4A039973AFDD1D78355A6487F1601101FCDDE`

If texture loading fails, one explicit error is logged and a visible safe fallback is rendered instead of silently skipping panel creation.


```

## 0.5.54_SANDBOX_CONFIGURATION_REPORT.md

- SHA-256: `825F0703FE21FBFD32B256F774C7D3B724C20A42725293CF94222FD00B55CBC3`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.54 Sandbox Configuration Report

SANDBOX_OPTION_COUNT=84
NEW_BLUE_RED_DEBUG_OPTION_COUNT=17
CN_TRANSLATION_KEY_COUNT=174
EN_TRANSLATION_KEY_COUNT=174
CN_EN_KEY_PARITY=true
SANDBOX_TYPE_ERRORS=0
ODD_QUOTES=0
BOM_COUNT=0
NULL_COUNT=0

Added blue options:

`EnableBlueEcoBarrage`, `BlueBarrageRadius`, `BlueBarrageZombieDamage`, `BlueBarrageKnockback`, `BlueBarrageFriendlyFire`, `BlueBarrageFire`, `BlueBarrageCraftCount`, `BlueBarrageShowStatusIcon`.

Added red options:

`EnableFeastGuardian`, `FeastGuardianRequireHighestFoodMoodle`, `FeastGuardianCureInfection`, `FeastGuardianCureZombification`, `FeastGuardianCureFakeInfection`, `FeastGuardianFractureHealMultiplier`, `FeastGuardianRearmThreshold`, `FeastGuardianShowStatusIcon`.

Added performance/debug option:

`EnableRuntimeDebug=false`.

All values are present in RELEASE, TESTING, and CUSTOM schema handling in `XNP_DR_SandboxTuning.lua`.


```

## BUILD_MARKER.txt

- SHA-256: `03E7BEC8C2069DE77E8150EA21F3C0D54294974483CD034A3AC47A805B1B696E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_0554_UI_PERFORMANCE_BLUE_RED_TRAITS_A

```
