# 0.5.60.6.8 Sanitized Evidence Excerpts

BUILD_MARKER=XNP_PZ_DISTANCE_TRAIT_056068_WORKSHOP_RC1_RENDER_DISABLED_SANDBOX_A

Accepted prior failure: 0.5.60.6.7 target tracking worked, but the dynamic entity model-script name was null inside the FBO render chain and produced about 641 repeated exceptions.

Correction: the 0.5.60.6.8 runtime tree has no entity constructor and no green world render callback. Green active mode uses pure Lua world coordinates and IsoZombie-only hit transactions.

Static status: SOURCE_KAHLUA_FAIL=0. Runtime status: NOT_YET_TESTED.
