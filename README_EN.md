# XNP Gensokyo Trait System — Development Source and Failure History

Author: **世界第一小脑 / XN-PHL**  
Steam Workshop ID: `3762431102`

This repository preserves reviewed development source, public release material, and failure history:

1. `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/`: the 0.5.60.7.5 Build 42 runtime-test source;
2. `workshop/0.5.60.7.5/`: public Workshop metadata and preview assets for that version;
3. `history/0.5.60.7.5/`: sanitized feature, failure, root-cause, and fix records;
4. the complete 0.5.60.6.11 RC4 development baseline and its earlier history, retained under the existing `src/` and `history/development-evidence/` paths.

Version 0.5.60.7.5 corrects per-player projection for the Green skill, requires at least 500 ms and two drawn frames before impact, fails closed when inflight drawing is not proven, and bounds outline discovery to a local lock-area scan. The user confirmed that the required functions are present; that confirmation is a user runtime-result record, not automated exhaustive runtime proof.

This repository is a development and runtime-test archive, not a stable release channel. Test no-cooldown and the inflight diagnostic border remain enabled by default. `STABLE_RELEASE_ALLOWED=false` and `LICENSE_STATUS=NOT_SELECTED`. Raw console logs, screenshots, saves, private local paths, credentials, and third-party source are excluded; only public Workshop previews and required mod assets are included for 0.5.60.7.5.

No explicit open-source license has been selected. All rights are reserved unless a LICENSE is published later.
