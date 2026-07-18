# 0.5.57.3 Sanitized Evidence Excerpts

## 0.5.57.3_LINE142_RUNTIME_API_FORENSIC_REPORT.md

- SHA-256: `1150E0E610A5E494DCDF78735CA0F54461FE1B3FC6917F112D906263F9D51556`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Line 142 Runtime API Forensic Report

## Evidence source

- Baseline: `XNP_PZ_DistanceRunnerTrait_0.5.57.2_B42_EVIDENCE_FIELD_STRUCTURE_FIX_SOURCE`
- Runtime console: `EVIDENCE/0.5.57.2_RUNTIME_console.txt` in the supplied command package
- Failing module: `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_RoundMarkerFrame.lua`
- The console identifies XNP `Draw` and all four XNP render callers. This is not a third-party-mod error.

## Original lines 130-150

```lua
        Frame.shellSolid = getTexture(SOLID_PATH)
        Frame.shellOutline = getTexture(OUTLINE_PATH)
    end
    print("[XNP ROUND FRAME] solid=" .. tostring(Frame.shellSolid ~= nil)
        .. " outline=" .. tostring(Frame.shellOutline ~= nil)
        .. " center_tint=false center_size=16 shell_size=32")
    return Frame.shellSolid ~= nil and Frame.shellOutline ~= nil
end

function Frame.Draw(panel, centerTexture, colorName)
    if not panel or not Frame.LoadShellTextures() then return false end
    local color = Frame.COLORS[colorName] or Frame.COLORS.WHITE
    panel:drawTextureScaledColor(Frame.shellSolid, 0, 0, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
        color.a, color.r, color.g, color.b)
    panel:drawTextureScaledColor(Frame.shellOutline, 0, 0, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
        1.0, 1.0, 1.0, 1.0)
    if centerTexture then
        panel:drawTextureScaledColor(centerTexture, Frame.CENTER_OFFSET, Frame.CENTER_OFFSET,
            Frame.CENTER_SIZE, Frame.CENTER_SIZE, 1.0, 1.0, 1.0, 1.0)
    end
    return true
```

## Exact failure

```text
LINE_142_SOURCE_TEXT=panel:drawTextureScaledColor(Frame.shellSolid, 0, 0, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
LINE_142_NIL_CALLEE_EXPRESSION=panel.drawTextureScaledColor
LINE_142_RECEIVER_OBJECT=panel (Lua ISPanel-derived instance)
LINE_142_METHOD_OR_FUNCTION_NAME=drawTextureScaledColor
LINE_142_ARGUMENTS=Frame.shellSolid,0,0,Frame.PANEL_SIZE,Frame.PANEL_SIZE,color.a,color.r,color.g,color.b
LINE_142_NIL_CLASSIFICATION=RECEIVER_METHOD_DOES_NOT_EXIST
```

The receiver itself is valid: every stack trace reaches `Panel:render`, and each panel derives from `ISPanel`. The nil value is the lower-case Lua method lookup. B42 has no `ISUIElement:drawTextureScaledColor` wrapper. A nil texture would be a bad argument, not a nil callee.

The supplied console contains 82 references to the old line 142 and reaches all four callers (yellow 22, purple 20, green 20, red 20). The shared bad method therefore explains the common blank-marker failure.

```text
ROOT_CAUSE_CONFIRMED=true
THIRD_PARTY_ERROR=false
LINE142_ORIGINAL_NIL_CALL_ACTIVE_COUNT=0
```

```

## 0.5.57.3_B42_UI_DRAW_API_EVIDENCE.md

- SHA-256: `CD3DCBF27437D152151BAD6E49DFF9A70C9673A0288C61B39053B97892931A7B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] B42 UI Draw API Evidence

## JAR evidence

- JAR: `[LOCAL_PATH_REDACTED]`
- Inspected class: `zombie.ui.UIElement`
- Tool: `javap -classpath <jar> -s zombie.ui.UIElement`
- Proven Java method:

```text
public void DrawTextureScaledColor(
    zombie.core.textures.Texture,
    java.lang.Double, java.lang.Double, java.lang.Double, java.lang.Double,
    java.lang.Double, java.lang.Double, java.lang.Double, java.lang.Double);
descriptor=(Lzombie/core/textures/Texture;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;)V
```

The method is capitalized. The broken lower-case `drawTextureScaledColor` is not the Java method and is not defined as a Lua wrapper.

## Vanilla Lua evidence

`[LOCAL_PATH_REDACTED]`, lines 1032-1040:

```lua
function ISUIElement:drawTextureScaled(texture, x, y, w, h, a, r, g, b)
    if self.javaObject ~= nil then
        local texture = ISUITextureGetter.checkGetTexture(texture)
        if r==nil then
            self.javaObject:DrawTextureScaled(texture, x, y, w, h, a);
        else
            self.javaObject:DrawTextureScaledColor(texture, x, y, w, h, r, g, b, a);
        end
    end
end
```

This proves the public Lua order `(texture,x,y,w,h,a,r,g,b)` and the internal Java order `(texture,x,y,w,h,r,g,b,a)`. A recursive case-sensitive scan of B42 vanilla Lua found 200 lower-case `:drawTextureScaled(` calls, 0 lower-case `:drawTextureScaledColor(` calls, and 25 direct capital `:DrawTextureScaledColor(` calls.

## Receiver evidence

- `ISPanel.lua:3`: `ISPanel = ISUIElement:derive("ISPanel")`
- `ISPanel.lua:96-98`: `ISPanel:new` delegates to `ISUIElement:new`
- `ISUIElement.lua:993-994`: `instantiate()` creates `UIElement.new(self)` as `javaObject`

Thus an XNP panel receives the proven Lua wrapper through ISUIElement inheritance, and that wrapper reaches the proven B42 Java method.

## Resource evidence

Both vanilla shell textures exist as loose B42 resources:

- `[LOCAL_PATH_REDACTED]`
- `[LOCAL_PATH_REDACTED]`

```text
REPLACEMENT_LUA_METHOD=panel:drawTextureScaled
METHOD_EXISTS_IN_B42_JAR=true
METHOD_CALLED_BY_B42_VANILLA_LUA=true
METHOD_ARGUMENT_ORDER_PROVEN=true
METHOD_RECEIVER_TYPE_PROVEN=true
ROUND_MARKER_DRAW_USES_B42_PROVEN_API=true
```

```

## 0.5.57.3_DRAW_RUNTIME_CALL_CONTRACT.md

- SHA-256: `2B6E3E696A774E58E94188375C84B562349133B89F5C7ADA66F93A8E8F2F03CA`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Draw Runtime Call Contract

Scope: direct calls inside `XNP_DR_RoundMarkerFrame.Draw` after the repair.

| Count | Call | Classification | Evidence |
|---:|---|---|---|
| 3 | `error(message)` | B42_VANILLA_LUA_PROVEN | B42 vanilla Lua contains 25 `error(...)` calls; `shared/env.lua:28` is one direct example. |
| 1 | `Frame.LoadShellTextures()` | MODULE_DEFINED | Defined in the same module at line 128. It caches through `Frame.shellAttempted`. |
| 3 | `panel:drawTextureScaled(...)` | B42_JAR_PROVEN + B42_VANILLA_LUA_PROVEN | ISUIElement wrapper at lines 1032-1040 reaches `UIElement.DrawTextureScaledColor`. |

Nested `LoadShellTextures` dependencies are also established: `getTexture` has 994 B42 vanilla Lua calls, while `print`, `tostring`, and `type` are standard Kahlua globals used throughout the vanilla scripts. The two shell paths exist in the B42 install.

There is no `pcall`, silent return, or optional center-glyph branch in `Draw`. Missing contract inputs now produce explicit errors instead of preserving a blank UI.

```text
DRAW_RUNTIME_CALL_COUNT=7
DRAW_RUNTIME_CALL_PROVEN_COUNT=7
DRAW_RUNTIME_CALL_UNPROVEN_COUNT=0
DRAW_PCAll_ERROR_SUPPRESSION_COUNT=0
DRAW_SILENT_RETURN_BEFORE_GLYPH_COUNT=0
RUNTIME_API_CONTRACT_PASS=true
```

```

## 0.5.57.3_EVENT_AND_PERFORMANCE_BUDGET.md

- SHA-256: `9D93B91E13B08C03A1C6FCBF82FC2E92FD2C4262EAF2A956654DB734BA701891`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Event and Performance Budget

Static comparison against [IP_REDACTED]:

| Check | [IP_REDACTED] | [IP_REDACTED] | Result |
|---|---:|---:|---|
| `Events.OnTick.Add` | 0 | 0 | PASS |
| `Events.OnPlayerUpdate.Add` | 1 | 1 | PASS |
| UI state refresh interval | 250 ms | 250 ms | PASS (max 4 Hz) |
| Red inventory refresh | 500 ms | 500 ms | PASS (max 2 Hz) |
| Panel creation routes | 4 | 4 | PASS (one per marker) |

Each `ensurePanel` uses a stored panel guard before construction. Each center texture uses a `textureAttempted` guard. Shared shell textures use `Frame.shellAttempted`. `Panel:render` contains only `Frame.Draw`; no render-time logging, texture loading, panel creation, or protected-error suppression was added.

The permitted logs are module-load, one-time texture load, one-time panel creation, or change-keyed state logs outside `render`.

```text
XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
XNP_ON_PLAYER_UPDATE_05572_COUNT=1
UI_MAX_REFRESH_HZ=4
RED_INVENTORY_CHECK_MAX_HZ=2
TEXTURE_LOAD_PER_FRAME=false
PANEL_CREATE_PER_FRAME=false
RENDER_LOG_PER_FRAME=false
DUPLICATE_PANEL_CREATION_ROUTE_COUNT=0
ROUND_DRAW_ERROR_SUPPRESSION_ROUTE_COUNT=0
PERFORMANCE_BUDGET_PASS=true
```

```

## 0.5.57.3_FOUR_RENDER_CALLSITE_CONTRACT_REPORT.md

- SHA-256: `D8626FF349EDC173AB763F5FF3FBA8CA51A4DE96A7F45D47E5C865DBFBB02C60`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Four Render Callsite Contract Report

All callers pass an instantiated ISPanel-derived `self`, a module-cached center texture, and a valid Frame color key.

| Marker | Render call | Texture path | Color contract | Visibility contract |
|---|---|---|---|---|
| Yellow | `XNP_DR_StatusIconUI.lua:81` | `media/ui/XNPMarkers/xnp_marker_yellow.png` | Initial GREEN; resolver emits Frame color names | Visible only for the target trait |
| Purple | `XNP_DR_PurplePhoenixUI.lua:84` | `media/ui/XNPMarkers/xnp_marker_purple.png` | OFF=WHITE, active state=GREEN | READY or OFF state |
| Green | `XNP_DR_GreenSkillUI.lua:79` | `media/ui/XNPMarkers/xnp_marker_green.png` | enabled=GREEN, disabled=WHITE | Visible for green trait owner |
| Red | `XNP_DR_RedMagicUI.lua:97` | `media/ui/XNPMarkers/xnp_marker_red.png` | count>=1 GREEN, otherwise WHITE | Visible after player UI setup |

For every panel:

- `Panel:new` uses `Frame.PANEL_SIZE` (32x32).
- `textureAttempted` prevents per-frame `getTexture`.
- `ensurePanel` creates one panel, stores it, and returns the stored panel thereafter.
- The center PNG exists in SOURCE and DROP.
- `Frame.Draw` applies shell alpha/color and draws the center at 16x16 with alpha 1.0 after both shell layers.
- Visibility is decided by `Update`; `render` only invokes the shared draw contract.

```text
YELLOW_DRAW_ARGUMENTS_VALID=true
PURPLE_DRAW_ARGUMENTS_VALID=true
GREEN_DRAW_ARGUMENTS_VALID=true
RED_DRAW_ARGUMENTS_VALID=true
NIL_CENTER_TEXTURE_CALLSITE_COUNT=0
NIL_COLOR_TABLE_CALLSITE_COUNT=0
NIL_PANEL_CALLSITE_COUNT=0
FOUR_PANEL_STRUCTURE_PRESERVED=true
```

```

## 0.5.57.3_GAMEPLAY_RUNTIME_CHAIN_PRESERVATION_REPORT.md

- SHA-256: `7F7E1B8244FF7B688D8DCE7FC274DEDE3212B128512AD9A6A957E99B53ADBFEF`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Gameplay Runtime Chain Preservation Report

## Diff boundary

Runtime SHA comparison against [IP_REDACTED] found exactly eight changed files:

- root `mod.info`
- `42/mod.info`
- `XNP_DR_Constants.lua`
- `XNP_DR_RoundMarkerFrame.lua`
- `XNP_DR_StatusIconUI.lua`
- `XNP_DR_PurplePhoenixUI.lua`
- `XNP_DR_GreenSkillUI.lua`
- `XNP_DR_RedMagicUI.lua`

All non-UI gameplay Lua files are byte-identical to [IP_REDACTED]. The four UI files differ only by the shared draw fix dependency already present and their new one-time panel creation evidence log; right-click and state routes remain present.

## Chain checks

- Distance Runner: bootstrap still requires trait registration, trait detection, runtime, stamina, impact, breakout, food, and scheduler modules. Runtime remains the single `OnPlayerUpdate` target.
- Yellow: `XNP_DR_MasterEffectState.MODDATA_KEY` remains `XNP_DR_YELLOW_ENABLED`; YellowRoundState still resolves the toggle and endurance/breakout state.
- Phoenix: bootstrap requires registration, trait, state, config, protect, invulnerability, revive, damage guard, and UI.
- Phoenix threshold: `TRIGGER_MAIN_DEFAULT=0.30`.
- Phoenix cooldown: `COOLDOWN_DAYS_DEFAULT=7`.
- Phoenix lethal edge: `OnPlayerGetDamage` still delegates to `PurplePhoenixRevive.TryTrigger`, which checks projected health against the threshold before restoration/protection.
- Green: `GreenSkill.RequestActivate` and the round-marker right-click route remain present; gameplay remains the documented placeholder.
- Red Magic: item queue, starter grant, whole-item consumption, central fracture scheduler, and final-interval settlement logs/routes remain present.

```text
DISTANCE_RUNNER_REQUIRE_CHAIN_PRESENT=true
YELLOW_ENABLED_KEY_PRESENT=true
PHOENIX_REQUIRE_CHAIN_PRESENT=true
PHOENIX_30_PERCENT_PRESENT=true
PHOENIX_7_DAY_COOLDOWN_PRESENT=true
PHOENIX_LETHAL_ROUTE_PRESENT=true
GREEN_PLACEHOLDER_ROUTE_PRESENT=true
RED_MAGIC_ROUTE_PRESENT=true
RED_WHOLE_ITEM_CONSUMPTION_PRESENT=true
RED_FRACTURE_FINAL_INTERVAL_FIX_PRESENT=true
GAMEPLAY_SEMANTICS_CHANGED=false
```

```

## 0.5.57.3_ROUND_MARKER_DRAW_FIX_REPORT.md

- SHA-256: `9416977FC0AA167CD2336A9E41D6B3052F218CB025D196A36DCE8D28F6C01695`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Round Marker Draw Fix Report

The repair replaces all three unreachable lower-case `panel:drawTextureScaledColor(...)` calls with B42-proven `panel:drawTextureScaled(...)` calls. It does not remove or bypass `Frame.Draw`.

Current draw order:

1. Validate panel.
2. Validate center texture.
3. Load and validate the cached vanilla shell textures.
4. Draw `_Moodles_BGsolid.png` at 32x32 with state RGBA.
5. Draw `_Moodles_BGoutline.png` at 32x32 in opaque white.
6. Draw the original center PNG at offset 8, size 16x16, opaque white.
7. Return true.

Geometry and semantics remain fixed: `PANEL_SIZE=32`, `CENTER_SIZE=16`, `CENTER_OFFSET=8`, round chassis retained, state-color shell retained, center glyph retained and untinted.

The repair also adds one module-load contract log and one panel-creation log per panel. None is emitted from `render`.

```text
LINE142_ORIGINAL_NIL_CALL_ACTIVE_COUNT=0
LOWERCASE_DRAW_TEXTURE_SCALED_COLOR_COUNT=0
PROVEN_DRAW_TEXTURE_SCALED_CALL_COUNT=3
ROUND_LAYER_DRAW_ROUTE_PRESENT=true
CENTER_GLYPH_DRAW_ROUTE_PRESENT=true
CENTER_GLYPH_DRAW_AFTER_BACKGROUND=true
DRAW_SILENT_RETURN_BEFORE_GLYPH_COUNT=0
DRAW_PCAll_ERROR_SUPPRESSION_COUNT=0
PANEL_SIZE=32
CENTER_SIZE=16
USER_RUNTIME_TEST_PASS=NOT_YET_TESTED
```

```

## BUILD_MARKER.txt

- SHA-256: `5F2E32A2F525F493D8FC33C08FF1F4C6705B17E786DEE59384C0E8C10B23CC3B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_05573_ROUND_MARKER_RUNTIME_DRAW_FIX_A

```

## FINAL_REPORT.md

- SHA-256: `7FB299E7995ACC8A1FA45B1C2BE4B113C35F622EDEFEE3BF62BF0BA544CA48BB`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Final Report - XNP PZ [IP_REDACTED]

```text
SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=[IP_REDACTED]
INTERNAL=[IP_REDACTED]-b42-round-marker-runtime-draw-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05573_ROUND_MARKER_RUNTIME_DRAW_FIX_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
DISPLAY_NAME=[[IP_REDACTED]] XNP Four Round Markers Runtime Fix
```

## Delivered repair

- Identified old line 142 callee as missing Lua method `panel.drawTextureScaledColor`.
- Proved the replacement route with B42.19 `projectzomboid.jar` and vanilla `ISUIElement.lua`.
- Replaced three bad calls with `panel:drawTextureScaled(texture,x,y,w,h,a,r,g,b)`.
- Preserved the round solid shell, outline, original center glyph, draw order, geometry, and state colors.
- Added one-time draw-contract and panel-creation evidence logs outside render.
- Preserved gameplay runtime chains; no gameplay module was changed.

## Validation summary

```text
LINE142_ORIGINAL_NIL_CALL_ACTIVE_COUNT=0
ROUND_MARKER_DRAW_USES_B42_PROVEN_API=true
DRAW_RUNTIME_CALL_UNPROVEN_COUNT=0
YELLOW_DRAW_ARGUMENTS_VALID=true
PURPLE_DRAW_ARGUMENTS_VALID=true
GREEN_DRAW_ARGUMENTS_VALID=true
RED_DRAW_ARGUMENTS_VALID=true
SOURCE_KAHLUA_PASS_COUNT=81
SOURCE_KAHLUA_FAIL_COUNT=0
DROP_KAHLUA_PASS_COUNT=81
DROP_KAHLUA_FAIL_COUNT=0
SOURCE_RUNTIME_FILE_COUNT=107
DROP_RUNTIME_FILE_COUNT=107
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
XNP_ON_TICK_HANDLER_COUNT=0
XNP_ON_PLAYER_UPDATE_HANDLER_COUNT=1
KAHLUA_SYNTAX_PASS=true
RUNTIME_API_CONTRACT_PASS=true
USER_RUNTIME_TEST_PASS=NOT_YET_TESTED
STATUS=STATIC_READY_FOR_RUNTIME_TEST
BLOCKER=NONE_STATIC
```

## Safety and delivery

```text
PROJECT_ZOMBOID_STARTED=false
STEAM_STARTED=false
OLD_SOURCE_MODIFIED=false
USER_MODS_WRITTEN=false
SAVES_WRITTEN=false
WORKSHOP_WRITTEN=false
GAME_DIRECTORY_WRITTEN=false
PACKAGED_OR_UPLOADED=false
```

The direct drag-and-test object has exactly `42`, `mod.info`, and `poster.png` at its top level. This report does not claim that the four markers have passed a new user runtime test.

```text
XNP_PZ_0.5.57.3_ROUND_MARKER_RUNTIME_DRAW_FIX_READY
```

```

## 0.5.57.3_四标当前实机截图.png

- SHA-256: `455F84DF47D4BFBE229871B1CAD19BBE421CD2E99CCCD33B61E667F31D6D9C2F`
- Type: 截图
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

## 0.5.57.3_KAHLUA_RESOURCE_PACKAGE_VALIDATION.md

- SHA-256: `9CAD2ED7BFDFACB5A2DAB70762AF0F4271E347942D9C9D3017F1069CF60F4446`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Kahlua, Resource, and Package Validation

## Kahlua compilation

Compiler source: `[LOCAL_PATH_REDACTED]`

Method invoked through the local checker: `se.krka.kahlua.luaj.compiler.LuaCompiler.loadis(java.io.Reader, String, KahluaTable)`.

The first attempt with JDK 21 correctly failed before compilation because the B42.19 JAR is Java class version 69. The check was rerun with the game's bundled OpenJDK 25 runtime (`jre64/bin/java.exe`), without launching Project Zomboid.

```text
SOURCE_KAHLUA_PASS_COUNT=81
SOURCE_KAHLUA_FAIL_COUNT=0
DROP_KAHLUA_PASS_COUNT=81
DROP_KAHLUA_FAIL_COUNT=0
KAHLUA_SYNTAX_PASS=true
```

## Center asset lock

| Asset | SHA256 | Baseline unchanged | SOURCE/DROP match |
|---|---|---|---|
| `xnp_marker_yellow.png` | `12029EB6F39F046FA15A0C4663FBF33E985245553FB524902EC045E1E64132D6` | true | true |
| `xnp_marker_purple.png` | `55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21` | true | true |
| `xnp_marker_green.png` | `C9B5A7ED5C04FE2C4A3FC49845FE9D4303A497DAC8A8D4EA2C8D6FA64EE2481F` | true | true |
| `xnp_marker_red.png` | `00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3` | true | true |

All four center paths exist. Both vanilla 32px Moodle shell paths exist. Local XNP `require` scan found 0 missing modules and 0 case mismatches. Runtime files contain 0 BOMs, 0 NUL bytes, and 0 empty files.

## SOURCE/DROP package

```text
SOURCE_RUNTIME_FILE_COUNT=107
DROP_RUNTIME_FILE_COUNT=107
SOURCE_DROP_FILE_COUNT_MATCH=true
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
MISSING_FROM_DROP=0
EXTRA_IN_DROP=0
DROP_TOP_LEVEL=42,mod.info,poster.png
DROP_TOP_LEVEL_CONTRACT_PASS=true
REPORTS_INSIDE_DROP=0
```

No game, Steam, Workshop, save, user-mod, or game-install write occurred.

```

## 0.5.57.3_SECOND_PASS_AUDIT.md

- SHA-256: `0F60D588229D1AFAF522618AD71E57E54A966E5A5713F96DCA4C8BBCEF8DDB74`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Second-Pass Read-Only Audit

Audit date: 2026-07-14

Audit scope:

- SOURCE: `[LOCAL_PATH_REDACTED]`
- DROP: `[LOCAL_PATH_REDACTED]`
- Baseline: `[LOCAL_PATH_REDACTED]`
- This audit added only this report. It did not modify runtime files, the DROP, the baseline, third-party mods, or user/game directories.

## 1. Confirmed runtime root cause

The supplied [IP_REDACTED] console evidence identifies XNP's shared renderer, not WarThunderVehicleLibrary or another mod:

```text
ROOT_CAUSE_FILE=XNP_DR_RoundMarkerFrame.lua
ROOT_CAUSE_LINE=142
ROOT_CAUSE_KIND=RUNTIME_NIL_CALL
ROOT_CAUSE_SHARED_BY_FOUR_RENDERERS=true
```

The baseline line 142 starts this call:

```lua
panel:drawTextureScaledColor(Frame.shellSolid, 0, 0, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
    color.a, color.r, color.g, color.b)
```

`panel` is an ISPanel-derived Lua object. The nil callee is the absent lower-case method `panel.drawTextureScaledColor`. A nil texture would have been an argument failure, not `Object tried to call nil in Draw`.

The forensic report contains non-empty, source-consistent values:

```text
LINE_142_SOURCE_TEXT=panel:drawTextureScaledColor(Frame.shellSolid, 0, 0, Frame.PANEL_SIZE, Frame.PANEL_SIZE,
LINE_142_NIL_CALLEE_EXPRESSION=panel.drawTextureScaledColor
LINE_142_RECEIVER_OBJECT=panel (Lua ISPanel-derived instance)
LINE_142_METHOD_OR_FUNCTION_NAME=drawTextureScaledColor
LINE_142_ARGUMENTS=Frame.shellSolid,0,0,Frame.PANEL_SIZE,Frame.PANEL_SIZE,color.a,color.r,color.g,color.b
```

## 2. Independent B42 API verification

The audit directly inspected:

- `[LOCAL_PATH_REDACTED]`
- `zombie.ui.UIElement` with `javap -s`
- B42 vanilla `ISUIElement.lua`, `ISPanel.lua`, and an actual `ISChat.lua` caller

JAR method:

```text
public void DrawTextureScaledColor(Texture, Double, Double, Double, Double, Double, Double, Double, Double)
descriptor=(Lzombie/core/textures/Texture;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;Ljava/lang/Double;)V
```

Vanilla wrapper at `media/lua/client/ISUI/ISUIElement.lua:1032-1038`:

```lua
function ISUIElement:drawTextureScaled(texture, x, y, w, h, a, r, g, b)
    -- ...
    self.javaObject:DrawTextureScaledColor(texture, x, y, w, h, r, g, b, a);
end
```

Actual vanilla call at `media/lua/client/Chat/ISChat.lua:418`:

```lua
self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, titlebarAlpha, 1, 1, 1);
```

Receiver proof: `ISPanel.lua:3` derives from `ISUIElement`; `ISPanel.lua:98` delegates to `ISUIElement:new`; `ISUIElement.lua:994` creates `UIElement.new(self)`.

```text
METHOD_EXISTS_IN_B42_JAR=true
METHOD_CALLED_BY_B42_VANILLA_LUA=true
METHOD_ARGUMENT_ORDER_PROVEN=true
METHOD_RECEIVER_TYPE_PROVEN=true
ROUND_MARKER_DRAW_USES_B42_PROVEN_API=true
```

## 3. Draw implementation and runtime-call contract

Current `Frame.Draw` has three explicit input/resource errors, one same-module texture-loader call, and three proven `pane
[EXCERPT_TRUNCATED]
```
