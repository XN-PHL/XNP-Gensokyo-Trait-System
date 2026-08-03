# XNP Gensokyo Trait System V2 2.3.0-test.1

This is the isolated Project Zomboid Build 42.20 test channel.

- Mod ID: `XNP_PZ_DistanceRunnerTrait_Test`
- Internal version: `2.3.0-test.1-multi-record-inheritance-a`
- Build marker: `XNP_V2_230_TEST1_MULTI_RECORD_INHERITANCE_A`
- Test Workshop ID: `3762431102`
- Incompatible channel: `XNP_PZ_DistanceRunnerTrait`
- Runtime status: `NOT_TESTED`

This test increment adds a world-backed, player-owned multi-record Extra Life inheritance library. Every successful starter, manual, or automatic record creates a new immutable record ID with a mutable label, canonical trait objects, profession, snapshot payload, and a canonical content digest. Restore uses the selected record ID, clears the current CharacterTraits collection, applies the selected canonical objects exactly once, validates readback, and grants only a quarter of a positive non-Fitness/Strength XP gap. No record is automatically restored at startup. Runtime validation is still required; do not enable this channel together with the stable channel.
