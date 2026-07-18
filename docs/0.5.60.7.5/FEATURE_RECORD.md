# Feature record

## Green flight and projection

- Uses the selected player's camera offset once, applies the player's zoom, and translates through that player's viewport origin.
- Requires a successful inflight draw proof before impact can resolve.
- Requires at least 500 ms and two drawn frames before impact.
- Fails closed: if the draw proof cannot be established, impact damage is not applied and the consumed cooldown is refunded.
- Can draw a default-on diagnostic border around the inflight sprite during this runtime-test build.

## Targeting and damage

- Scans a bounded square around the lock area instead of enumerating every zombie globally.
- Filters targets to zombie/NPC-compatible entities and excludes players from damage.
- Preserves NPC/Bandit damage, native impact markers, and ownership-safe outline cleanup.

## Preserved behavior

- Green runtime-test no-cooldown remains enabled by default.
- Purple-skill cooldown remains three seconds.
- Existing player immunity and impact feedback are retained.

## Evidence boundary

Source inspection and Kahlua compilation establish implementation presence and syntax validity. The user separately confirmed that the required functions are present. Neither statement is presented as automated exhaustive gameplay coverage.

