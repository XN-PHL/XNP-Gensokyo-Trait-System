# Baseline Status — 0.5.60.6.11 RC4

## Why this source was selected

The supplied archive identifies `0.5.60.6.11 RC4` as the branch whose runtime tree matched the Workshop mirror and whose features were reported as working in prior real-game use.

```text
ARCHIVE_ROLE=PREVIOUSLY_USED_DEVELOPMENT_BASELINE
VERSION=0.5.60.6.11
BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_0560611_RED_ITEM_USE_RELEASE_WORKSHOP_RC4_A
MOD_ID=XNP_PZ_DistanceRunnerTrait
WORKSHOP_ID=3762431102
SOURCE_TEXT_FILES_INCLUDED=true
BINARY_ASSETS_INCLUDED=false
```

## Do not mislabel this as production-ready

The later independent second-pass static audit blocked formal release for three reasons:

```text
BLOCKER_1=PHOENIX_TEST_COOLDOWN_MODE_STILL_ACTIVE_5000MS
BLOCKER_2=PHOENIX_RECOVERY_HEALTH_REPORTED_35_BUT_RUNTIME_FULL_HEAL_100
BLOCKER_3=WORKSHOP_PUBLIC_README_CONTAINED_PRIVATE_LOCAL_PATHS
```

The third blocker belonged to the old Workshop helper README and is not present in this cleaned repository. The first two remain historical behavior facts about this source baseline.

Additional boundaries:

- prior runtime status was user-reported; the packaging process did not run the game again;
- Lua compilation had passed in the supplied audit material;
- the green Java/world-entity rendering experiment was forced off;
- this archive must not be used as proof that later versions or all Sandbox mappings are correct.

## Development rule

Treat `src/` as a frozen reference. New work should be created in a new branch/version. Before reusing a mechanism, search `history/` for the version, API, module, or failure signature.
