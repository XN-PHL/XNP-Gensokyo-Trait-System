# 0.5.60.5 Sanitized Evidence Excerpts

## 0.5.60.5_LATEST_RUNTIME_RECORD.md

- SHA-256: `60020DC2C66AADD01A6AF8EFEBA6B945C2190358C0951DF80760486928081F3F`
- Type: 错误报告
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Latest Runtime Record

Archived log: `console(28)_0.5.60.4.1鏈€鏂版棩蹇?txt`

```text
CONSOLE_SHA256=72913F62FC28B1C4635C3805A3BAA8C150027562C5380D5517A6D0E4C450F0AD
CONSOLE_READALLLINES_COUNT=5449
XNP_LOG_LINE_COUNT=287
XNP_BUILD_MARKER_COUNT=3
NATIVE_TRAIT_REGISTERED_COUNT=4
ALL_FOUR_AVAILABLE_TRUE_COUNT=1
XNP_RUNTIME_EXCEPTION_HINT_COUNT=0
```

The log confirms [IP_REDACTED].1 startup identity, all four native CharacterTrait registrations, `all_four_available=true`, the single OnPlayerUpdate runtime registration, runtime module loading, and all four marker textures/panels loading.

It does not by itself prove every gameplay branch passed. The supplied user record separately reports long-distance travel, bomb use, NPC-mod activity, and extensive incoming gunfire.

The log also contains base-game, map, model/skeleton, missing-tile, recipe-UI, chunk-loading, and third-party errors. No line or stack ties those errors to an XNP Lua callsite, so they are not classified as XNP failures.

```text
XNP_STARTUP_CONFIRMED=true
FOUR_TRAIT_REGISTRATION_CONFIRMED=true
FOUR_MARKER_MODULE_LOAD_CONFIRMED=true
ALL_GAMEPLAY_RUNTIME_PASS_CLAIM=false
THIRD_PARTY_AND_BASE_ERRORS_ATTRIBUTED_TO_XNP=false
```


```

## 0.5.60.5_PREVIEW_ASSET_USAGE.md

- SHA-256: `9D6535FB4ADD165228EAA330C86F0337ED34126EFB213EB510A32B035BC1D4DF`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Preview Asset Usage

## Supplied static source

```text
STATIC_SOURCE_PATH=鍒涙剰宸ュ潑涓婁紶鍥?game_preview_source.jpg
STATIC_SOURCE_SHA256=FBF4F05AFBD70CD2DFA3A29AC491143EC93E46B32EDD84B62195C25A4EC6014C
STATIC_SOURCE_SIZE=1254x1254
```

The supplied JPG was decoded and saved as PNG without cropping, resizing, recoloring, overlays, or compositional edits.

## Functional static paths

```text
ROOT_POSTER_PATH=poster.png
VERSION_POSTER_PATH=42/poster.png
COMPATIBILITY_PREVIEW_PATH=鍒涙剰宸ュ潑涓婁紶鍥?preview.png
STATIC_PNG_SIZE=1254x1254
STATIC_PNG_SHA256=841AD6D303032F51B6884E2A19919D4795A4E57029954EB61C5BF2C5963A0741
STATIC_PATH_HASH_MISMATCH_COUNT=0
GAME_STATIC_PREVIEW_REPLACED=true
```

`mod.info` continues to use `poster=poster.png`, so the game-facing preview route remains the stable PNG path.

## Workshop candidate

```text
WORKSHOP_GIF_PATH=鍒涙剰宸ュ潑涓婁紶鍥?workshop_preview_candidate.gif
WORKSHOP_GIF_SHA256=3060CDD0F0CD8B65BAC5C97E22C31B85F37097B9296284344762423BAB0C9F58
WORKSHOP_GIF_SIZE=400x400
WORKSHOP_GIF_FRAME_COUNT=55
WORKSHOP_GIF_BYTES=955435
WORKSHOP_GIF_ACTUAL_PREVIEW_FIELD=false
WORKSHOP_GIF_STATUS=CANDIDATE_ONLY
```


```

## 0.5.60.5_PRIVACY_SCREENSHOT_CLEANUP_REPORT.md

- SHA-256: `860DB08B13793D3D5DAFE27AEF880D27AADAC98311D344BE38DD211AA9795C58`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Privacy Screenshot Cleanup Report

## Scope

This pass cleans evidence imagery in the new [IP_REDACTED] SOURCE only. The [IP_REDACTED].1 baseline is unchanged.

## Removed unapproved screenshots

```text
REMOVED_UNAPPROVED_SCREENSHOT_COUNT=3
```

- `鍘熺悊鏃ュ織/璇佹嵁/0.5.57.3_鍥涙爣褰撳墠瀹炴満鎴浘.png`
- `閿欒鎶ュ憡/0.5.60.4_绾㈣壊鐗硅川鍥炬爣寮傚父_鍘熸埅鍥?png`
- `閿欒鎶ュ憡/0.5.60.4_绾㈣壊鐗硅川鍥炬爣寮傚父_灞€閮?png`

Their evidence value is retained in text: the four-marker route had runtime visibility evidence, and the old red CharacterTrait row displayed the wrong brown-orange vertical asset before the [IP_REDACTED].1 resource fix.

## Retained approved screenshot

```text
APPROVED_SCREENSHOT_COUNT=1
APPROVED_SCREENSHOT_PATH=閿欒鎶ュ憡/approved_evidence_screenshot.png
APPROVED_SCREENSHOT_SHA256=FD7724F9B6FB169CD1A6593EBEA3E102C9B6F75C30D0BEE3596EE003ABD73437
APPROVED_SCREENSHOT_SIZE=2048x576
```

This is the exact user-approved file supplied in the command package. It is not cropped, edited, or substituted.

Generated asset sheets, trait icons, item icons, poster art, and Workshop preview media are functional project assets rather than private desktop evidence and remain in their proper locations.

## Public delivery boundary

The direct DROP contains only `42`, `mod.info`, and `poster.png`. Raw console logs, engineering reports, and the approved evidence screenshot are not included in the direct DROP or its RELEASE_READY mod-folder copy.

```text
MARKDOWN_EMBEDDED_PRIVATE_SCREENSHOT_REFERENCE_COUNT=0
PUBLIC_DROP_RAW_EVIDENCE_COUNT=0
PUBLIC_DROP_PRIVATE_SCREENSHOT_COUNT=0
BASELINE_SOURCE_MODIFIED=false
```


```

## 0.5.60.5_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `2B19C7C01B7FC8DDE35DCBB480F13F23EC535C26E58A57B379D5B1BCA77A083F`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Runtime Preservation Report

## Scope

Baseline:

`[LOCAL_PATH_REDACTED]`

New SOURCE:

`[LOCAL_PATH_REDACTED]`

This release is limited to privacy evidence cleanup, preview asset replacement,
release documentation, and version identity updates. Gameplay behavior was not
changed.

## Payload Diff

The recursive SHA256 comparison of both `42` payloads found 122 files on each
side. There were no added or removed payload files. Only these four files differ:

- `42/mod.info`: version and display identity updated to [IP_REDACTED].
- `42/poster.png`: replaced by the approved static preview conversion.
- `42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_Constants.lua`: identity constants and one guarded startup-log key/message updated only.
- `42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_Runtime.lua`: one guarded startup-log key/message updated only.

The two Lua diffs contain no gameplay expression, condition, threshold, state
transition, scheduler, event registration, or skill implementation change.

```text
PAYLOAD_BASELINE_FILE_COUNT=122
PAYLOAD_SOURCE_FILE_COUNT=122
PAYLOAD_ADDED_FILE_COUNT=0
PAYLOAD_REMOVED_FILE_COUNT=0
PAYLOAD_CHANGED_FILE_COUNT=4
GAMEPLAY_LUA_CHANGED_FILE_COUNT=0
RUNTIME_IDENTITY_ONLY_LUA_FILE_COUNT=2
```

## Event Budget

Static callsite counts in the new payload:

```text
Events.OnTick.Add=0
Events.OnPlayerUpdate.Add=1
Events.OnGameStart.Add=1
Events.OnCreatePlayer.Add=1
```

The runtime remains on the established `OnPlayerUpdate` route. No new scheduler
or duplicate update hook was introduced.

## Identity

```text
VERSION=[IP_REDACTED]
INTERNAL_VERSION=[IP_REDACTED]-b42-privacy-evidence-preview-refresh-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05605_PRIVACY_EVIDENCE_PREVIEW_REFRESH_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
```

No `[IP_REDACTED].1`, `056041`, or
`RED_TRAIT_ICON_SURGICAL_FIX` identity remains in deployable Lua.

## Result

```text
RUNTIME_PRESERVATION_STATIC_RESULT=PASS
GAMEPLAY_CHANGE_INTRODUCED=NO
REAL_GAME_RUNTIME_TEST=NOT_RUN_BY_CODEX
```


```

## 0.5.60.5_SANDBOX_ADVANCED_CUSTOMIZATION_PLAN.md

- SHA-256: `2978347EFCC6910AA46CF82F09F72024AFC4B28C95A9037F65AC877F5779C852`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Sandbox Advanced Customization Plan

Deferred, not implemented in [IP_REDACTED]:

1. Expose red craft reserves/costs and green recovery values with validated server-authoritative ranges.
2. Expose the three green endurance thresholds, multipliers, and hit costs while preserving monotonic tiers.
3. Add migration from fixed [IP_REDACTED] defaults without rewriting existing player ModData.
4. Validate single-player first, then explicitly test multiplayer authority before enabling shared settings.

`[IP_REDACTED]` intentionally ignores the old max-x2 melee tuning and uses its frozen x8/x5/x2.5 design constants.

```

## 0.5.60.5_SOURCE_DROP_MIRROR_REPORT.md

- SHA-256: `17A60773C31E9021DBD49AD6B1187C0FA139A12626ACDA07BA13BFE042C265EE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] SOURCE / DROP Mirror Report

## Paths

```text
SOURCE=[LOCAL_PATH_REDACTED]
DROP=[LOCAL_PATH_REDACTED]
RELEASE_MOD_COPY=[LOCAL_PATH_REDACTED]
```

The SOURCE deployable payload is defined as root `42`, root `mod.info`, and root
`poster.png`. Reports, raw logs, approved evidence, audit harnesses, and Workshop
candidate material are intentionally SOURCE-only.

## SHA256 Mirror Check

```text
SOURCE_DEPLOYABLE_FILE_COUNT=124
DROP_FILE_COUNT=124
RELEASE_MOD_COPY_FILE_COUNT=124
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
DROP_RELEASE_MOD_SHA256_MISMATCH_COUNT=0
```

## DROP Shape

The DROP first level contains exactly:

```text
42
mod.info
poster.png
```

```text
DROP_TOP_LEVEL_ENTRY_COUNT=3
DROP_TOP_LEVEL_SHAPE=PASS
DEPLOY_PRIVATE_EVIDENCE_MATCH_COUNT=0
```

## Result

```text
SOURCE_DROP_MIRROR=PASS
DROP_RELEASE_MOD_MIRROR=PASS
BLOCKER=NONE
```


```

## 0.5.60.5_VERSION_HISTORY_UPDATE.md

- SHA-256: `C6F3C443F1BA0D70FB03FDA7C94A794A255CBAB4CE92925F7AF2844A733AF243`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Version History Update

## [IP_REDACTED]

- Second-pass audit passed.
- The red positive dual-mode craft and green melee tier implementation remained the gameplay baseline.
- User long-distance evidence records travel across more than half a map, bomb use, an NPC-mod environment, and extensive incoming gunfire.
- No serious XNP gameplay issue was reported in that long sample; the confirmed visible issue was the red icon previously shown incorrectly in the skill-selection panel.

## [IP_REDACTED].1

- Red CharacterTrait icon surgical fix passed static second-pass audit.
- The definition now uses its isolated red P trait resource.
- The audit result does not substitute for a separate user visual confirmation of the corrected character-creation row.

## [IP_REDACTED]

- Cleans unapproved privacy-revealing evidence screenshots.
- Retains exactly one command-package-approved evidence screenshot.
- Archives the latest [IP_REDACTED].1 console record with attribution boundaries.
- Replaces static poster/preview media and prepares a separate Workshop GIF candidate.
- Does not roll back or alter gameplay.

```text
VERSION_0_5_60_4_SECOND_PASS_AUDIT=PASS
VERSION_0_5_60_4_1_ICON_FIX_SECOND_PASS_AUDIT=PASS
VERSION_0_5_60_5_SCOPE=DOCUMENT_EVIDENCE_PREVIEW_RELEASE_LAYER
GAMEPLAY_ROLLBACK=false
```


```

## 0.5.60.5_WORKSHOP_GIF_COMPATIBILITY.md

- SHA-256: `22ED9E2E79CC2D5F941C31FA2AF208CC6A2345E2E62F18AAEF075E4387D4D022`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Workshop GIF Compatibility

The local project does not contain a statically verified upload-field contract proving that an animated GIF is accepted by the active Project Zomboid Workshop publishing flow. No upload or Steam test was performed.

Therefore:

- The functional default remains the static PNG poster generated from `game_preview.jpg`.
- `workshop_preview_candidate.gif` is copied unchanged into `RELEASE_READY/WORKSHOP_UPDATE`.
- The GIF is not forced into `mod.info`, a Workshop preview field, or any game runtime path.
- During manual publishing, use the GIF only if the uploader visibly accepts it. Otherwise use `preview_static_fallback.png` and retain the GIF for external description/display use.

```text
GIF_UPLOAD_SUPPORT_STATICALLY_VERIFIED=false
GIF_FORCED_INTO_PREVIEW_FIELD=false
STATIC_PREVIEW_FALLBACK_READY=true
WORKSHOP_UPDATE_REQUIRES_USER_MANUAL_UPLOAD=true
```


```

## BUILD_MARKER.txt

- SHA-256: `B7200E65CF8E6D9785B1E81C4CDD5D4F2395890F2F6A5429B540398B79ED34F8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_05605_PRIVACY_EVIDENCE_PREVIEW_REFRESH_A

```

## FINAL_REPORT.md

- SHA-256: `35BB64959776E361C41EB97801E440197CB490857E1A03317B7AE5AB8F9560DE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP PZ Distance Runner [IP_REDACTED] Final Report

## Deliverables

```text
SOURCE_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
DROP_OUTPUT_PATH=[LOCAL_PATH_REDACTED]
RELEASE_READY_PATH=[LOCAL_PATH_REDACTED]
WORKSHOP_UPDATE_PATH=[LOCAL_PATH_REDACTED]
VERSION=[IP_REDACTED]
INTERNAL_VERSION=[IP_REDACTED]-b42-privacy-evidence-preview-refresh-a
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_05605_PRIVACY_EVIDENCE_PREVIEW_REFRESH_A
```

## Privacy Evidence Cleanup

Three unapproved screenshots were removed from the independent [IP_REDACTED] SOURCE:

- `鍘熺悊鏃ュ織/璇佹嵁/0.5.57.3_鍥涙爣褰撳墠瀹炴満鎴浘.png`
- `閿欒鎶ュ憡/0.5.60.4_绾㈣壊鐗硅川鍥炬爣寮傚父_鍘熸埅鍥?png`
- `閿欒鎶ュ憡/0.5.60.4_绾㈣壊鐗硅川鍥炬爣寮傚父_灞€閮?png`

One approved screenshot was retained in SOURCE only:

`閿欒鎶ュ憡/approved_evidence_screenshot.png`

```text
PRIVACY_SCREENSHOT_REMOVED_COUNT=3
APPROVED_EVIDENCE_RETAINED_COUNT=1
DEPLOY_PRIVATE_EVIDENCE_MATCH_COUNT=0
```

The supplied latest console log was archived under `閿欒鎶ュ憡` and summarized
without attributing base-game, map, model, tile, or third-party errors to XNP.

## Version Record

- [IP_REDACTED] second-pass static audit passed.
- [IP_REDACTED].1 red-trait icon fix second-pass static audit passed.
- User long-run evidence records more than half-map travel, bomb use, an NPC mod,
  and extensive gunfire damage exposure.
- This iteration does not claim a gameplay change or a new in-game pass. It is a
  privacy evidence and release-preview refresh.

## Preview Assets

The supplied `game_preview.jpg` was converted without crop or resize into the
functional static PNG poster. Root poster, `42/poster.png`, and the SOURCE static
preview copy are byte-identical.

```text
GAME_STATIC_PREVIEW_REPLACED=YES
STATIC_POSTER_DIMENSIONS=1254x1254
STATIC_POSTER_SHA256=841AD6D303032F51B6884E2A19919D4795A4E57029954EB61C5BF2C5963A0741
WORKSHOP_GIF_STATUS=CANDIDATE_ONLY_NOT_CONFIGURED
WORKSHOP_GIF_FIELD_COMPATIBILITY=NOT_VERIFIABLE_BY_STATIC_AUDIT
```

## Validation

```text
LUA_FILE_COUNT=90
LUA_TOTAL_LINE_COUNT=16794
SOURCE_KAHLUA_PASS=90
SOURCE_KAHLUA_FAIL=0
DROP_KAHLUA_PASS=90
DROP_KAHLUA_FAIL=0
PAYLOAD_CHANGED_FILES_AGAINST_0.[IP_REDACTED]=4
GAMEPLAY_LUA_CHANGED_FILE_COUNT=0
SOURCE_DROP_SHA256_MISMATCH_COUNT=0
DROP_RELEASE_MOD_SHA256_MISMATCH_COUNT=0
DROP_TOP_LEVEL_ENTRIES=42,mod.info,poster.png
STATIC_AUDIT=PASS
PACKAGE_VALIDATION=PASS
```

## Safety

```text
PROJECT_ZOMBOID_LAUNCHED=NO
STEAM_LAUNCHED=NO
PACKED=NO
INSTALLED_TO_USER_MODS=NO
WROTE_SAVES=NO
WROTE_WORKSHOP=NO
WROTE_GAME_DIRECTORY=NO
MODIFIED_OLD_SOURCE=NO
BLOCKER=NONE
```

## Final Status

```text
XNP_PZ_0.5.60.5_PRIVACY_EVIDENCE_PREVIEW_REFRESH_READY
```


```

## RELEASE_READY_README.md

- SHA-256: `149CE5393EB215197F5A099541AEA1E2CBA5DF0B250D205FFA8FB4EBE9F1C1B1`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# XNP Distance Runner [IP_REDACTED] Release Ready

This directory contains two separate delivery areas:

- `0.5.60.5_XNP_PZ_PrivacyEvidencePreviewRefresh`: installable DROP mirror.
- `WORKSHOP_UPDATE`: upload-side preview candidates and compatibility notes.

The installable folder has exactly `42`, `mod.info`, and `poster.png` at its
first level. It is byte-identical to the standalone DROP at:

`[LOCAL_PATH_REDACTED]`

No packing, installation, game launch, Steam launch, or Workshop upload was
performed by Codex.


```

## WORKSHOP_UPDATE_README.md

- SHA-256: `68EAF36B808FB63468B8776000934524979138564F1A6AFF5B7A33247A4E2ABC`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Workshop Preview Update

## Functional Default

Use `preview_static_fallback.png` whenever the upload field requires a static
preview. It is the same image used by the mod's `poster.png`.

```text
preview_static_fallback.png
SHA256=841AD6D303032F51B6884E2A19919D4795A4E57029954EB61C5BF2C5963A0741
```

## GIF Candidate

`workshop_preview_candidate.gif` is supplied as an upload candidate only.
Project Zomboid/Steam Workshop field compatibility was not proven by static
inspection, so no config or `preview` field has been forced to use it.

```text
workshop_preview_candidate.gif
SIZE=955435
SHA256=3060CDD0F0CD8B65BAC5C97E22C31B85F37097B9296284344762423BAB0C9F58
STATUS=CANDIDATE_ONLY_NOT_CONFIGURED
```

`game_preview_source.jpg` is retained as the unconverted supplied static source.


```
