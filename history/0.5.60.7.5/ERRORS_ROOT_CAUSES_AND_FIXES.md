# Errors, root causes, and fixes

## Inflight sprite drift or disappearance

**Symptom:** the Green projectile could appear offset, vary with zoom, or become effectively invisible in split-screen/player-specific views.

**Root cause:** an earlier projection path mixed panel-space assumptions with world projection and deducted the camera offset more than once. It also did not consistently apply the selected player's zoom and viewport origin.

**Fix:** the 0.5.60.7.5 path deducts the selected player's camera offset exactly once, divides by that player's zoom, then adds that player's global-UI viewport origin.

## Damage could resolve without visible flight proof

**Symptom:** a target could be hit even when no inflight sprite was visibly established.

**Root cause:** impact resolution was not coupled tightly enough to evidence that drawing had succeeded for a meaningful interval.

**Fix:** every impact route now requires a successful draw, at least 500 ms of flight, and at least two drawn frames. Failure is closed: no damage is applied and cooldown consumption is refunded.

## Global target enumeration and outline ownership

**Symptom:** target outlining risked excessive scans and could interfere with render state owned by another system.

**Root cause:** prior approaches considered broad zombie enumeration and outline manipulation without sufficiently local ownership boundaries.

**Fix:** target discovery uses a bounded square scan around the lock area. Cleanup only releases outline state owned by this feature. Players remain excluded from the damage target set.

## Rejected entity/factory route

**Symptom:** earlier experiments attempted to represent the projectile through engine entity/factory assumptions that were not safe or portable for this use.

**Root cause:** the assumed factory/entity contract was not supported by reliable Build 42 behavior.

**Fix:** the Green flight representation remains a virtual, pure-Lua visual route using the established draw API contract.

## Test defaults can be mistaken for release behavior

**Symptom:** no-cooldown and diagnostic-border behavior can look like intended stable defaults.

**Root cause:** both switches intentionally default to `true` for this runtime-test build.

**Fix:** the flags and exact wiring are recorded in `KNOWN_TEST_ONLY_FLAGS.md`; stable publication remains blocked until they are set to `false` and re-audited.

