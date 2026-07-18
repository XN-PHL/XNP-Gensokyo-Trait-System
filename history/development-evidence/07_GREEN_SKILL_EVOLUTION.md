# Green Skill Evolution

- 0.5.60.2: three crafted `Base.PipeBomb` traps used the native trap route.
- 0.5.60.4 through 0.5.60.5: green skill assets and stable audio remained packaged.
- 0.5.60.6: active projectile work began while melee and structure functions were retained.
- 0.5.60.6.1 through 0.5.60.6.3: world-orb, targeting and render callback experiments.
- 0.5.60.6.3 runtime: zombie damage worked, but orb and impact visuals were not visible.
- 0.5.60.6.4 runtime: world inventory icon objects became giant concentric rings and left trails. Audit also found a silent-damage path after visual failure.
- 0.5.60.6.5 static design attempted one captured `IsoBall`, but runtime evidence proved every factory capture failed. The side-effect route left malformed world inventory render residue, causing 1,986 FBO exceptions and interrupting world-character rendering.
- 0.5.60.6.6 removes the factory route and target outline entirely. Tracking remains disabled. A world-coordinate-anchored local green blast is verified before sound and zombie-only damage; legacy XNP residue cleanup is exact, bounded, and never called from the per-frame update path.
- 0.5.60.6.6 runtime (console 36): the safe damage transaction worked, but its `ISPanel` visual again changed apparent scale/position with camera zoom.
- 0.5.60.6.7 performs a local JAR hard gate. `IsoBall` is not Lua-exposed, while `IsoMolotovCocktail` is explicitly exposed and inherits `IsoMovingObject`. One direct moving entity now owns the center, both glow layers, movement, and impact visual; active green world UI/screen/world-inventory routes are zero.

0.5.60.6.5 runtime visual status: FAILED_WORLD_RENDER_INTERRUPTED.

0.5.60.6.6 runtime render recovery status: NOT_YET_TESTED.

0.5.60.6.7 entity route status: NOT_YET_TESTED.

0.5.60.6.7 real-game result: tracking accepted and target lock worked, but the dynamic entity model path caused a null model-script exception in the FBO renderer at approximately per-frame cadence.

0.5.60.6.8 retires visible entity rendering from the public runtime. It preserves one virtual cast table, world-coordinate movement, nearest valid target, retargeting, low-speed opening stage, per-second acceleration, wall/target/timeout resolution, optional outline, sounds, and zombie-only radial impact. Modes are OFF, VIRTUAL_TRACKING_BLAST, and LOCAL_BLAST. Runtime status: NOT_YET_TESTED.
