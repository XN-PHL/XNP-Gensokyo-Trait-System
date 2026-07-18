# Version Timeline

- `0.5.57.2-0.5.57.3`: four-marker evidence and runtime drawing repair.
- `0.5.58`: shared drag controller and state feedback.
- `0.5.59-0.5.60.3`: Phoenix predeath, recovery, and multi-cycle work.
- `0.5.60.4-0.5.60.5`: red/green modes, trait icon repair, and privacy evidence handling.
- `0.5.60.6`: green arc projectile, melee tiers, and structure interaction.
- `0.5.60.6.1-0.5.60.6.3`: world-orb, ring and native render experiments.
- `0.5.60.6.4`: world inventory icon visuals were visible in game but produced giant concentric rings and persistent trails; audit blocked damage without a valid visual.
- `0.5.60.6.5`: attempted one `IsoBall` per cast, but runtime capture failed and malformed world-inventory residue interrupted the FBO world render chain.
- `0.5.60.6.6`: removes the Throw factory and tracking route, uses a verified local safe blast with zombie-only damage, and performs exact bounded cleanup of 0.5.60.6.4/0.5.60.6.5 XNP residue.
- `0.5.60.6.7`: rejects the recurring green-world `ISPanel` route, proves six local B42.19.0 entity gates, and uses one directly constructed `IsoMolotovCocktail` moving entity with same-entity impact promotion and fail-closed zombie-only damage.
- 0.5.60.6.8: accepts the 0.5.60.6.7 entity-render failure, removes the constructor/render route from the runtime tree, restores pure Lua virtual tracking and zombie-only blast logic, adds the 100-option public Sandbox layer, and prepares Workshop RC1 files without uploading.
