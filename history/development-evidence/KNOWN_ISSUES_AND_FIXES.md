# Known Issues And Fixes

## 0.5.60.6.5 Runtime Failure

- The exposed Throw factory never yielded the expected `IsoBall` handle.
- Its world-item side effect left an object whose model/script name was null.
- The object raised 1,986 FBO render exceptions; actors remained simulated but world-character rendering was interrupted.
- Phoenix continued to execute and was not causal.

## Fixed Statically In 0.5.60.6.6

- Removed all Throw-factory, new-ball search, world-item capture, target-outline, and actor-render mutation routes from the active green skill.
- Disabled tracking-orb runtime and enabled `LOCAL_SAFE_BLAST_FALLBACK`.
- A short-lived local panel uses the established green explosion and white ring assets at a projected world coordinate.
- Damage is gated by a verified panel and two valid texture handles, then filtered to living `IsoZombie` targets only.
- Exact XNP full types and a narrow XNP-texture/null-script signature are the only residue deletion candidates.
- Cleanup starts at player load, retries at most three times at intervals of at least one second, and is never scanned per frame.

## Real-Game Verification Still Required

- The bounded cleanup removes the malformed 0.5.60.6.5 residue from an affected save.
- World actors remain visible after loading and after repeated green casts.
- The local blast is visible for about 0.50 seconds and follows the projected player position closely enough for the fallback contract.
- No damage occurs when either required texture or the panel handle is unavailable.
- Phoenix still completes its five-state recovery without actor-render reset behavior.

## 0.5.60.6.6 Runtime Recurrence

- console(36) proved the active visual was `LOCAL_WORLD_ANCHORED_ISPANEL_GREEN_EXPLOSION`, not a world entity.
- The safe zombie-only transaction remained functional, but zoom-dependent panel projection caused scale/position drift.

## Fixed Statically In 0.5.60.6.7

- Green active-skill `ISPanel`, screen-coordinate authority, `OnPostFloorLayerDraw`, and moving `IsoWorldInventoryObject` routes are zero.
- A local B42.19.0 Exposer check selected `IsoMolotovCocktail`, which inherits `IsoMovingObject` and exposes construction, custom sprite loading, world position, and complete cleanup.
- One entity owns center plus two glow layers and is promoted in place to impact, preventing multi-object trail/ring assembly.
- Native self-explosion parameters are zeroed and held behind an extremely long trigger timer.
- Damage remains gated behind a verified world-entity impact handle and targets living zombies once each.

## 0.5.60.6.7 Real-Game Verification Still Required

- Direct Lua construction succeeds in the shipped B42.19.0 Kahlua environment.
- The entity renders at intended scale and remains stable through camera zoom.
- Attached glow, retargeting, collision, impact promotion, and all terminal cleanup paths work without residue.
