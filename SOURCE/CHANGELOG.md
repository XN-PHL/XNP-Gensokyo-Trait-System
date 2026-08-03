# Changelog

## 2.3.0-test.1 multi-record inheritance A

- Added the world-backed, owner-scoped `XNP_PurpleInheritanceRecordLibraryV2` schema with immutable IDs, ordered records, mutable display names, legacy migration state, selected-record state, and canonical content digests.
- Creates a new record for successful starter, manual, and auto-record transactions; legacy single-slot state migrates once without automatic startup restoration.
- Added right-click direct selection, random selection, and two-step deletion for record IDs.
- Restore now replaces current CharacterTrait objects from the selected record exactly once, reads back multiplicity, and applies only a quarter positive XP delta outside Fitness and Strength.
- Added rollback-aware record transaction tracking, a Test230 static harness, and CN/EN/JP record menu labels.
- Runtime and multiplayer validation remain `NOT_TESTED`.

## 2.2.0 stable inheritance trait dedupe C

- Replaced the two-pass Purple inheritance trait write with one canonical-ID reconciliation pass.
- Repairs polluted current saves by removing only duplicate CharacterTrait objects while retaining one canonical copy.
- Makes post-restore readback multiplicity-aware so present-but-duplicated traits fail closed.
- Preserves Green continuous rolling, strict double click, Red, Yellow, Phoenix combat, sandbox schema, and translations unchanged.

## 2.2.0 stable continuous rolling repair B

- Keeps the strict green double-click ticket gate unchanged.
- Lets production continuous rolling casts saturate configured fatigue and endurance costs.
- Preserves normal resource rejection when continuous rolling is disabled.

## 2.2.0-test.8

- Restored the one-second Green burst route before normal cooldown admission: requests at 0/150/300/500/800 ms share one burst, while a request after the window remains subject to the original five-second cooldown.
- Kept the first projectile on player-forward heading and changed only same-burst continuation projectiles to independent random world directions from the player's current position.
- Preserved independent fatigue, endurance, sound, light, simulation, active-slot, and cleanup ownership for every accepted projectile; maximum fatigue remains a valid saturated no-op.
- Added `CORE_ONLY_PROJECTILE` Style 6 with one opaque core draw per orb and no flight ring, rotation, arc band, glow, trail, crosshair, reticle, target outline, or debug border.
- Changed the effective Green guidance owner to 150 degrees per second and the time-driven acceleration curve to reach the existing speed cap of 8 in 4.5 seconds.
- Added exact-provenance test.7 migration, 1000-angle deterministic coverage, burst/cooldown/cost transaction coverage, 15/30/60/120 FPS motion equivalence checks, and 20-orb Style 6 render coverage.
- Yellow, Purple, Red, Green melee, collision, damage, fire, structure, lifetime, and stable-channel behavior remain unchanged. Runtime status remains `NOT_TESTED`.

## 2.2.0-test.7

- Removed the maximum-fatigue Green admission block; saturated fatigue cost is now a successful no-op while endurance admission remains enforced.
- Added one accepted/rejected outcome for every Green input request, including resource, cooldown, trait, concurrency, and identity snapshots.
- Made Green visual creation, tracking, and impact rendering fail soft so gameplay transactions are not cancelled by visual faults.
- Added `EMERALD_ARC_ORB` Style 5 with a round core, two asymmetric arc bands, 24 pre-rotated frames, bounded glow, one-to-two trails, and no crosshair or target reticle.
- Unified all four marker inputs on screen coordinates with a 12 px drag threshold and a real move-event requirement.
- Restored Yellow, Purple, Red, and Green melee mechanics to test.5-equivalent routes while disabling test.6 VFX defaults.
- Added exact-default-only test.7 migration, Kahlua syntax coverage, and dedicated admission, input, migration, visual, pixel, and slot-leak harnesses.
- Runtime and multiplayer validation remain `NOT_TESTED`.

## 2.2.0-test.6

- Rebuilt Green projectile visuals around an opaque rotating core, continuous bloom, two-to-three bounded trail segments, and an expanding impact ring.
- Added sixteen pre-rotated ring frames plus generated core, glow, trail, impact, Yellow contact, and Purple Phoenix assets with transparent-background audits.
- Added one pooled global VFX manager with a single `OnPostUIDraw` owner, quality tiers, 500 ms hysteresis, reduced-flashing behavior, fail-soft texture fallbacks, and deterministic cleanup.
- Added read-only Yellow momentum decay, strict-contact impact feedback, and a test-preset-only Alt crowd escape route with zero damage.
- Added Purple final-success bloom, invulnerability/cooldown rings, Life Stock provenance/readability, footwear recovery feedback, and retained independent Phoenix/Life Stock semantics.
- Added a Red physical-load expiry ring while freezing the test.5 post-commit cost, wetness, metabolic heat, fatigue, Unhappiness, and Boredom behavior.
- Added a provenance-gated one-time style migration from exact test.5 style 1 to test.6 style 4 without overwriting explicit user choices.
- Preserved reciprocal stable/test channel exclusion; runtime and multiplayer visual validation remain pending.

## 2.2.0-test.5

- Added a post-commit Red P craft physical-load pulse using verified B42.20 metabolic heat, body wetness, and endurance APIs.
- Enabled sweat, body heat, and exertion feedback by default with a 20-second duration, three-layer cap, safe intensity controls, and native visibility modes.
- Changed cancelled and failed Red P crafting to perform zero fatigue or physical-state writes; successful fatigue remains owned by the craft transaction only.
- Added a one-time, test-channel-only migration for the exact test.4 false/false/false default triplet while preserving partial or explicit custom configurations.
- Preserved the corrected Unhappiness decrease, Boredom decrease, no-Halo behavior, and all green/yellow/purple gameplay routes.

## 2.2.0-test.4

- Corrected P Point crafting to decrease raw Unhappiness by the configured amount and removed its overhead success text.
- Added the canonical `RedCraftUnhappinessReductionPoints` sandbox option while retaining the old cost key as hidden deprecated compatibility data only.
- Added persistent-center green rendering with Stable Core, Energy Effect, and Low Cost styles, interpolation snapshots, a 100 ms projection hold, and 1/10/20-cast render budgets.
- Added continuity, frame interval, allocation, projection, center submission, and missing-center diagnostics.
- Configuration migration now reports `NOT_ATTEMPTED` separately from `WRITE_FAILED`.

## 2.2.0-test.3

- Added the test-only XNP Configuration Health Center.
- Added classified raw/effective sandbox inspection, filtering, safe repair, five-entry world backup/restore, and sanitized diagnostics export.
- Added the test-channel + developer-tools + development-preset gate for every green runtime bypass.
- Changed canonical migration refresh to read-only planning; writes now require host authority and explicit confirmation.

## 2.2.0-test.2

- Rebuilt from the stable 2.0.1 behavior baseline through the shared B42.20 Production Core.
- Restored the separate test Mod ID and reciprocal channel incompatibility.
- Added B42.20 runtime diagnostics and opt-in test tools.
- Added explicit sandbox classification and provenance-gated migration.
- Preserved formal gameplay defaults; all development bypasses remain off.
- Runtime validation remains `NOT_TESTED`.
