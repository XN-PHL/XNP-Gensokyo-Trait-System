# 0.5.60.4.1 Sanitized Evidence Excerpts

## [IP_REDACTED].1_RED_TRAIT_ICON_ROOT_CAUSE.md

- SHA-256: `AEE1C9656831FBA8859A0ABD5EA791DF81D24F1677862A31CADC0E6E9D6D2979`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Red CharacterTrait Icon Root Cause

## Finding

```text
CURRENT_RED_TRAIT_ICON_REFERENCE=media/ui/Traits/trait_xnpfeastguardian.png
CURRENT_RED_TRAIT_ICON_RESOLVED_PATH=42/media/ui/Traits/trait_xnpfeastguardian.png
ROOT_CAUSE_KIND=WRONG_LEGACY_TRAIT_ART_ASSET_REFERENCED
WORKING_TRAIT_ICON_REFERENCE_PATTERN=Texture = media/ui/<unique-mod-resource>/<square-rgba-png>.png
FIXED_RED_TRAIT_ICON_REFERENCE=media/ui/XNP_Traits/xnp_trait_red_guardian.png
```

The [IP_REDACTED] red `character_trait_definition` resolves successfully, but it resolves to a dedicated 18x18 legacy red F asset. That file is the wrong artwork for the requested red guardian/P identity. The registration, text, cost, Full ID, and runtime trait detection are not the cause.

The green and purple working definitions use direct `media/ui/...png` paths to square RGBA resources. The fixed red definition follows the same direct-path contract and uses a unique mod-owned resource name. Its 16x16 RGB pixels come directly from the existing correct `xnp_marker_red.png`; only four edge-background alpha values are cleared to provide a transparent canvas. No artwork was redrawn or recolored.

## Resolution boundary

- Old asset remains present for compatibility and forensic evidence.
- HUD marker and inventory item texture references remain unchanged.
- Only the red CharacterTrait `Texture` field points to the new isolated asset.
- `RED_TRAIT_ICON_USER_VISUAL_TEST=NOT_YET_TESTED`

```

## [IP_REDACTED].1_红色特质图标异常.md

- SHA-256: `B5D2706D19631DCCB126D32AB220B7C46DF103C22C9E75BF05ACD594E69DF353`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 绾㈣壊鐗硅川鍥炬爣寮傚父

```text
VERSION=[IP_REDACTED]
USER_RUNTIME_RESULT=LONG_STRESS_TEST_PASS_WITH_ONE_VISUAL_ISSUE
MAP_TRAVEL=USER_CONFIRMED_LARGE_AREA
EXPLOSION_TEST=USER_CONFIRMED
NPC_GUNFIRE_TEST=USER_CONFIRMED
SERIOUS_GAMEPLAY_ISSUE=NONE_REPORTED
VISUAL_ISSUE=RED_CHARACTER_TRAIT_ICON_WRONG_ASSET
XNP_RUNTIME_EXCEPTION=NONE_FOUND_IN_CONSOLE_27
```

瑙掕壊鍒涘缓/鎶€鑳介€夋嫨鍒楄〃涓殑绾㈣壊鐗硅川鏂囧瓧銆佺偣鏁般€佽鏄庡拰杩愯鏃惰瘑鍒潎姝ｅ父锛屼絾鍥炬爣鏄剧ず涓洪敊璇殑妫曟鑹茬珫闀胯瑙夈€傞潤鎬佸畾浣嶆樉绀?[IP_REDACTED] 瀹氫箟寮曠敤浜?`trait_xnpfeastguardian.png` 鏃?F 鍥撅紝鑰岄鏈熺孩鑹?P 宸插瓨鍦ㄤ簬 `xnp_marker_red.png`銆?
[IP_REDACTED].1 浠呴殧绂诲苟淇 CharacterTrait 鐨勫浘鏍囪祫婧愬紩鐢ㄣ€備慨澶嶅悗鐨勭敤鎴疯瑙夌粨鏋滀粛涓?`NOT_YET_TESTED`銆?

```

## [IP_REDACTED].1_B42_CHARACTER_TRAIT_ICON_API_EVIDENCE.md

- SHA-256: `648882BE95859C9A01504C194640ED277793899F9327ABDFA64856942B10AAF0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42.19 CharacterTrait Icon API Evidence

## Local evidence

```text
PROJECT_ZOMBOID_JAR=[LOCAL_PATH_REDACTED]
PROJECT_ZOMBOID_MEDIA_LUA=[LOCAL_PATH_REDACTED]
CHARACTER_TRAIT_SCRIPT_CLASS=zombie.scripting.objects.CharacterTraitDefinitionScript
TEXTURE_FIELD_NAME=Texture
TEXTURE_RESOLVER=zombie.core.textures.Texture.getSharedTexture(java.lang.String)
TEXTURE_ASSIGNMENT=zombie.characters.traits.CharacterTraitDefinition.setTexture(Texture)
```

Static `javap -p -c` inspection of the local B42.19 JAR shows that `CharacterTraitDefinitionScript` parses the `Texture` key as a string. If present, the loader calls `Texture.getSharedTexture(texturePath)` and passes the result to `CharacterTraitDefinition.setTexture`.

The local generated trait definitions at `media/scripts/generated/characters/character_traits.txt` confirm the native `character_trait_definition` structure. The XNP yellow, purple, green, and red definitions use that same structure and their native `CharacterTrait.register(fullId)` objects are linked through each definition's `CharacterTrait` field.

## Path and image contract used

- Use an exact mod-relative path beginning with `media/ui/`.
- Preserve case exactly.
- Use a square PNG with alpha.
- Use a unique mod-owned filename to avoid shared texture-cache name collisions.
- Do not use the item-world texture path as the CharacterTrait reference.

The local JAR inspection is static API evidence. Actual character-creation rendering remains `NOT_VERIFIABLE_BY_STATIC_AUDIT` until the user tests the new SOURCE.


```

## [IP_REDACTED].1_RED_TRAIT_ICON_ASSET_AND_REFERENCE_REPORT.md

- SHA-256: `9393C056CF259899201FAA4ED2BF8C3CC823217E25A78A1462F189BF202E6FF0`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Red Trait Icon Asset And Reference Report

## CharacterTrait reference

```text
CURRENT_RED_TRAIT_ICON_REFERENCE=media/ui/Traits/trait_xnpfeastguardian.png
CURRENT_RED_TRAIT_ICON_RESOLVED_PATH=42/media/ui/Traits/trait_xnpfeastguardian.png
CURRENT_RED_TRAIT_ICON_SHA256=756EDDF88626D3774E1849E814AA3F09BE6C244B3ECB178546579D6856856133
FIXED_RED_TRAIT_ICON_REFERENCE=media/ui/XNP_Traits/xnp_trait_red_guardian.png
FIXED_RED_TRAIT_ICON_RESOLVED=true
FIXED_RED_TRAIT_ICON_SHA256=596935E226F0FD487C5673E14A49FD37FCEEF5B737424C31FD49AB93F6643456
```

## PNG validation

```text
WIDTH=16
HEIGHT=16
SQUARE=true
PIXEL_FORMAT=Format32bppArgb
ALPHA_MIN=0
ALPHA_MAX=255
HAS_ALPHA_CHANNEL=true
HAS_TRANSPARENT_PIXELS=true
SOURCE_RGB_MISMATCH_COUNT=0
ALPHA_CANVAS_ADAPTATION_PIXEL_COUNT=4
```

The dedicated trait resource preserves every RGB value from `42/media/ui/XNPMarkers/xnp_marker_red.png`. Only four edge-background pixels have alpha cleared. This is canvas adaptation, not a redraw or recolor.

## Registration invariants

```text
CHARACTER_TRAIT_DEFINITION_COUNT=4
RED_TRAIT_DEFINITION_COUNT=1
RED_TRAIT_FULL_ID=XNPFeastGuardianTrait:XNPFeastGuardian
RED_TRAIT_FULL_ID_UNCHANGED=true
RED_TRAIT_COST=1
RED_TRAIT_COST_UNCHANGED=true
RED_TRAIT_DESCRIPTION_UNCHANGED=true
RED_TRAIT_ICON_UNIQUE_RESOURCE_NAME=true
RED_TRAIT_ICON_USES_WORLD_ITEM_TEXTURE=false
RED_TRAIT_ICON_USES_WRONG_ATLAS_REGION=false
```

## Protected assets

```text
RED_HUD_MARKER_SHA256=00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3
RED_ITEM_TEXTURE_SHA256=00FE634429F1709A5C9E169A31991DC5C66FD4C41AEBF8458AB5DB768E955BE3
YELLOW_MARKER_SHA256=12029EB6F39F046FA15A0C4663FBF33E985245553FB524902EC045E1E64132D6
PURPLE_TRAIT_SHA256=55FD1C63FF5EBD4412628D0D15EEDB9EAEFF2DE11B49E06D0FF048D3300F8F21
GREEN_MARKER_SHA256=C9B5A7ED5C04FE2C4A3FC49845FE9D4303A497DAC8A8D4EA2C8D6FA64EE2481F
PROTECTED_ASSET_HASH_MISMATCH_COUNT=0
```

`RED_TRAIT_ICON_USER_VISUAL_TEST=NOT_YET_TESTED`


```

## [IP_REDACTED].1_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `1542382B4C314216EACE7F691042BEF31AEDBE91703415C280E71A92FD47FD9C`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED].1 Runtime Preservation Report

Baseline: `XNP_PZ_DistanceRunnerTrait_0.5.60.4_B42_RED_POSITIVE_DUALMODE_CRAFT_GREEN_MELEE_TIERS_SOURCE`

## Runtime tree delta

```text
ADDED_RUNTIME_ASSET_COUNT=1
REMOVED_RUNTIME_FILE_COUNT=0
CHANGED_RUNTIME_FILE_COUNT=4
ON_TICK_ADD_COUNT=0
ON_PLAYER_UPDATE_ADD_COUNT=1
ALL_EVENT_ADD_COUNT_BASELINE=13
ALL_EVENT_ADD_COUNT_NEW=13
```

Added:

- `42/media/ui/XNP_Traits/xnp_trait_red_guardian.png`

Changed:

- `42/mod.info`: version/display identity only.
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`: version/build/startup identity only.
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`: startup identity only.
- `42/media/scripts/XNPDistanceRunnerTraits.txt`: one red `Texture` line only.

All other files under `42` are SHA256-identical to [IP_REDACTED]. The existing red HUD marker, red item textures, Phoenix, yellow, purple, green bomb, green melee, four-marker UI, tooltips, map hiding, sounds, poster, and preview are unchanged.

```text
OTHER_GAMEPLAY_CHANGED=false
OTHER_GAMEPLAY_RETEST_REQUIRED=false
NEW_EVENT_COUNT=0
NEW_ON_TICK_COUNT=0
BALANCE_VALUE_CHANGED=false
```


```

## [IP_REDACTED].1_SOURCE_DROP_MIRROR_REPORT.md

- SHA-256: `C33127805C851F85F90E9F74DC963EAA5D72DD63DE280AB8755F121132A4C00A`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 SOURCE / DROP Mirror Report

```text
SOURCE=[LOCAL_PATH_REDACTED]
DROP=[LOCAL_PATH_REDACTED]
SOURCE_PACKAGE_FILE_COUNT=180
DROP_PACKAGE_FILE_COUNT=180
MISSING_IN_DROP=0
EXTRA_IN_DROP=0
SHA256_MISMATCH_COUNT=0
SOURCE_LUA_COUNT=91
DROP_LUA_COUNT=91
SOURCE_KAHLUA_FAIL=0
DROP_KAHLUA_FAIL=0
```

The mirrored package set is `42`, `鍒涙剰宸ュ潑涓婁紶鍥綻, `鍘熺悊鏃ュ織`, `瀹¤鎶ュ憡`, `閿欒鎶ュ憡`, root `mod.info`, and root `poster.png`. SOURCE-only engineering reports and `_kahlua_check` evidence are intentionally excluded from the user DROP.

The DROP was created as a plain directory. It was not installed, archived, or published.


```

## BUILD_MARKER.txt

- SHA-256: `ADCA12C7B8E0C7D63F36FA8EEC1D4DF5B3BAF1EC3AEFE26C0CD55A9CDD833C30`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_056041_RED_TRAIT_ICON_SURGICAL_FIX_A

```

## FINAL_REPORT.md

- SHA-256: `E6CB6255512B19F2E6460700F5046422A0AC7F7BA395A5E55889D28C6DEDF633`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ [IP_REDACTED].1 Final Report

```text
SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
VERSION=[IP_REDACTED].1
INTERNAL=[IP_REDACTED].1-b42-red-trait-icon-surgical-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056041_RED_TRAIT_ICON_SURGICAL_FIX_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
FIX_SCOPE=RED_CHARACTER_TRAIT_ICON_ONLY
```

## Root cause and fix

```text
CURRENT_RED_TRAIT_ICON_REFERENCE=media/ui/Traits/trait_xnpfeastguardian.png
CURRENT_RED_TRAIT_ICON_RESOLVED_PATH=42/media/ui/Traits/trait_xnpfeastguardian.png
ROOT_CAUSE_KIND=WRONG_LEGACY_TRAIT_ART_ASSET_REFERENCED
WORKING_TRAIT_ICON_REFERENCE_PATTERN=Texture = media/ui/<unique-mod-resource>/<square-rgba-png>.png
FIXED_RED_TRAIT_ICON_REFERENCE=media/ui/XNP_Traits/xnp_trait_red_guardian.png
```

The new 16x16 RGBA trait-only asset preserves every RGB pixel from the existing correct red P marker. Four edge-background alpha values were cleared to provide a transparent canvas. HUD and inventory item assets were not modified.

## Registration invariants

```text
RED_TRAIT_DEFINITION_COUNT=1
RED_TRAIT_FULL_ID=XNPFeastGuardianTrait:XNPFeastGuardian
RED_TRAIT_FULL_ID_UNCHANGED=true
RED_TRAIT_COST_UNCHANGED=true
RED_TRAIT_DESCRIPTION_UNCHANGED=true
RED_TRAIT_ICON_UNIQUE_RESOURCE_NAME=true
RED_TRAIT_ICON_USES_WORLD_ITEM_TEXTURE=false
RED_TRAIT_ICON_USES_WRONG_ATLAS_REGION=false
```

## Validation

```text
SOURCE_KAHLUA_PASS=91
SOURCE_KAHLUA_FAIL=0
DROP_KAHLUA_PASS=91
DROP_KAHLUA_FAIL=0
SOURCE_PACKAGE_FILE_COUNT=180
DROP_PACKAGE_FILE_COUNT=180
SOURCE_DROP_MISSING=0
SOURCE_DROP_EXTRA=0
SOURCE_DROP_SHA256_MISMATCH=0
ON_TICK_ADD_COUNT=0
ON_PLAYER_UPDATE_ADD_COUNT=1
PROTECTED_ASSET_HASH_MISMATCH_COUNT=0
STATIC_BLOCKER_COUNT=0
```

## Evidence boundary

```text
RED_TRAIT_ICON_USER_VISUAL_TEST=NOT_YET_TESTED
OTHER_GAMEPLAY_RETEST_REQUIRED=false
OTHER_GAMEPLAY_CHANGED=false
PROJECT_ZOMBOID_STARTED=false
STEAM_STARTED=false
USER_MODS_WRITTEN=false
SAVES_WRITTEN=false
GAME_DIRECTORY_WRITTEN=false
WORKSHOP_WRITTEN=false
OLD_SOURCE_MODIFIED=false
BLOCKER=NONE
```

`XNP_PZ_0.5.60.4.1_RED_TRAIT_ICON_SURGICAL_FIX_READY`


```

## [IP_REDACTED].1_PACKAGE_VALIDATION.md

- SHA-256: `168B5260C49DA6FBCECCDB8053FB5CB1EFCA981EBB6C7E4BE55D152828992A2E`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Package Validation

```text
SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
SOURCE_LUA_COUNT=91
DROP_LUA_COUNT=91
SOURCE_KAHLUA_PASS=91
SOURCE_KAHLUA_FAIL=0
DROP_KAHLUA_PASS=91
DROP_KAHLUA_FAIL=0
RED_TRAIT_ICON_PATH_RESOLVED=true
RED_TRAIT_ICON_SIZE=16x16
RED_TRAIT_ICON_ALPHA=true
RED_TRAIT_ICON_REFERENCE_MATCH=true
```

The package set is `42`, `鍒涙剰宸ュ潑涓婁紶鍥綻, `鍘熺悊鏃ュ織`, `瀹¤鎶ュ憡`, `閿欒鎶ュ憡`, root `mod.info`, and root `poster.png`. The package is a directory DROP only; no archive, Workshop upload, or installation was performed.

```text
PROJECT_ZOMBOID_STARTED=false
STEAM_STARTED=false
USER_MODS_WRITTEN=false
GAME_DIRECTORY_WRITTEN=false
WORKSHOP_WRITTEN=false
PACKAGE_BLOCKER_COUNT=0
```


```

## [IP_REDACTED].1_RUNTIME_TEST_CHECKLIST.md

- SHA-256: `62734B8729DC0CA9B82408CDCBE4CBB6BDDDA3AB3C7779022A61A0D6CEF29473`
- Type: 审计报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED].1 Runtime Test Checklist

## Required visual check

1. Install only the user-provided [IP_REDACTED].1 DROP.
2. Open character creation and locate `XNPFeastGuardianTrait:XNPFeastGuardian`.
3. Confirm the row shows the square red P/guardian mark rather than the legacy F or brown-orange vertical image.
4. Confirm name, description, cost `1`, ordering, and compatibility remain unchanged.

## Regression boundary

- Confirm the red HUD marker still uses its existing center image.
- Confirm the red inventory item icon remains unchanged.
- Confirm one right click changes red mode, double left click queues crafting, and inventory context performs use.
- Other gameplay does not require a full retest because its runtime files are byte-preserved, but startup and basic load should still be observed.

```text
RED_TRAIT_ICON_USER_VISUAL_TEST=NOT_YET_TESTED
OTHER_GAMEPLAY_RETEST_REQUIRED=false
OTHER_GAMEPLAY_CHANGED=false
```


```

## [IP_REDACTED].1_SECOND_PASS_AUDIT.md

- SHA-256: `3F0600CF3E3F8B099E31121007EC90D3733AF70DBBA2C08D59A1FE7A8E3E6FC4`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Second-Pass Read-Only Audit

## Scope

```text
SOURCE=[LOCAL_PATH_REDACTED]
DROP=[LOCAL_PATH_REDACTED]
BASELINE=[LOCAL_PATH_REDACTED]
AUDIT_WRITE_SCOPE=SOURCE/[IP_REDACTED].1_SECOND_PASS_AUDIT.md_ONLY
```

This audit did not modify SOURCE runtime files, DROP, the baseline, third-party mods, user directories, saves, Workshop, or the game directory. Project Zomboid and Steam were not launched.

## Supplied runtime evidence

The supplied original and cropped screenshots were visually inspected. The red trait row displays the reported brown-orange vertical glyph rather than the intended red P/guardian marker.

The supplied console log has SHA256 `4DB0F2077E7F58998F416498D3EE846F72CA171BDEEC22CB8C67C23051C15C0C` and 34,794 lines. Independent searches found two successful red Full ID registrations, three object-collection detections with `player_has_trait=true`, and one `starter_grant=true count=3 trait_gate=true` record. No XNP Lua exception or XNP error stack was found. Unrelated engine/third-party errors remain outside this audit conclusion.

```text
RED_TRAIT_FULL_ID_REGISTERED=true
RED_TRAIT_FULL_ID_REGISTERED_COUNT=2
RED_TRAIT_RUNTIME_DETECTED=true
RED_TRAIT_RUNTIME_DETECTED_COUNT=3
RED_STARTER_GRANT_TRAIT_GATE_ACTIVE=true
RED_STARTER_GRANT_TRAIT_GATE_COUNT=1
XNP_RUNTIME_EXCEPTION_COUNT=0
```

## Version identity

```text
VERSION=[IP_REDACTED].1
INTERNAL=[IP_REDACTED].1-b42-red-trait-icon-surgical-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056041_RED_TRAIT_ICON_SURGICAL_FIX_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
```

Root and `42/mod.info`, `BUILD_MARKER.txt`, constants, and startup identity agree.

## Root cause evidence

Both required reports exist and contain concrete local evidence:

- `[IP_REDACTED].1_RED_TRAIT_ICON_ROOT_CAUSE.md`
- `[IP_REDACTED].1_B42_CHARACTER_TRAIT_ICON_API_EVIDENCE.md`

Local `projectzomboid.jar` bytecode was independently inspected. `CharacterTraitDefinitionScript` recognizes `Texture`, calls `Texture.getSharedTexture(String)`, and assigns it through `CharacterTraitDefinition.setTexture(Texture)`.

```text
CURRENT_RED_TRAIT_ICON_REFERENCE=media/ui/Traits/trait_xnpfeastguardian.png
CURRENT_RED_TRAIT_ICON_RESOLVED_PATH=42/media/ui/Traits/trait_xnpfeastguardian.png
ROOT_CAUSE_KIND=WRONG_LEGACY_TRAIT_ART_ASSET_REFERENCED
WORKING_TRAIT_ICON_REFERENCE_PATTERN=Texture = media/ui/<unique-mod-resource>/<square-rgba-png>.png
FIXED_RED_TRAIT_ICON_REFERENCE=media/ui/XNP_Traits/xnp_trait_red_guardian.png
```

The old path resolved correctly but contained obsolete F artwork. This is a wrong-art reference, not a missing-resource or trait-registration failure.

## Icon asset audit

The fixed SOURCE and DROP icon hashes are both `596935E226F0FD487C5673E14A49FD37FCEEF5B737424C31FD49AB93F6643456`. It is a 16x16 `Format32bppArgb` PNG with alpha range 0-255. All 144 pixels in the inner 12x12 region are nontransparent.

Every RGB pixel matches `42/media/ui/XNPMarkers/xnp_marker_red.png`. Exactly four corner alpha values, at `(0
[EXCERPT_TRUNCATED]
```

## [IP_REDACTED].1_STATIC_AUDIT.md

- SHA-256: `1B24643A2120F7D5EE0ADA3848EFE9B3B5A4A1CFC70BB33A976BE7ED5E9534A6`
- Type: 审计报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED].1 Static Audit

```text
VERSION=[IP_REDACTED].1
INTERNAL=[IP_REDACTED].1-b42-red-trait-icon-surgical-fix-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056041_RED_TRAIT_ICON_SURGICAL_FIX_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
SOURCE_KAHLUA_PASS=91
SOURCE_KAHLUA_FAIL=0
LUA_NULL_FILE_COUNT=0
LUA_BOM_FILE_COUNT=0
CHARACTER_TRAIT_DEFINITION_COUNT=4
RED_TRAIT_DEFINITION_COUNT=1
ON_TICK_ADD_COUNT=0
ON_PLAYER_UPDATE_ADD_COUNT=1
```

The local B42.19 `projectzomboid.jar` and its Java 25 runtime were used only to invoke `LuaCompiler.loadis`; Project Zomboid itself was not launched. All runtime Lua compiled successfully.

Static comparisons found one new PNG and four intentional runtime-file differences: two version-only Lua identities, one mod metadata identity, and one red CharacterTrait Texture line. There are no removed runtime files, new event registrations, gameplay-value changes, or protected-asset hash changes.

```text
RED_TRAIT_ICON_USER_VISUAL_TEST=NOT_YET_TESTED
OTHER_GAMEPLAY_RETEST_REQUIRED=false
OTHER_GAMEPLAY_CHANGED=false
PROJECT_ZOMBOID_STARTED=false
STEAM_STARTED=false
STATIC_BLOCKER_COUNT=0
```


```
