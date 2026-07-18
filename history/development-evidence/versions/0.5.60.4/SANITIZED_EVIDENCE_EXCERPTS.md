# 0.5.60.4 Sanitized Evidence Excerpts

## 0.5.60.4_GREEN_CLASSIFIER_AND_COST_REPORT.md

- SHA-256: `8391EB571868C46D2B57F23BDBF1DB69976DC902BAB8E571A27E10C60445958B`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Green Classifier And Cost

The existing single `XNP_DR_MeleePower.lua` and strict classifier remain in use. Admission requires a local single-player post-hit `OnWeaponHitXp` event, green trait, living zombie target, verified non-ranged `HandWeapon`, positive engine damage, and no shove, grapple, bare-hand, thrown, vehicle, or firearm route.

One target token prevents duplicate processing. Endurance is sampled before extra damage; its tier cost is written only after extra damage succeeds. A failed classifier, duplicate token, zero damage, disabled toggle, or failed target health write costs nothing. Runtime event equivalence: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_GREEN_MELEE_TIERS_REPORT.md

- SHA-256: `4474CF9F0E5245B0DA01B75BE3670E20F8E7797B739F7AFB568AB218F7712A4E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Green Melee Tiers

The shared tier resolver is the single source for icon color, multiplier, and endurance cost:

| State | Pre-hit endurance | Total multiplier | Successful-hit cost |
|---|---:|---:|---:|
| GREEN | >= 0.65 | x8.0 | 0.03 |
| YELLOW | >= 0.30 and < 0.65 | x5.0 | 0.02 |
| RED | < 0.30 | x2.5 | 0.01 |
| WHITE | toggle disabled / unavailable | x1.0 | 0 |

The right-click toggle remains independent from the preserved three-bomb double-click route. Runtime damage values: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_RED_CRAFT_COST_REPORT.md

- SHA-256: `6C56F63532DB5EC274170F740BA7E696F04CCE30DC6E325ECFDDC9C154A4D6BE`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Craft Cost

Craft eligibility requires the red trait, a living player, overall health above 30%, and satiety above 30%. Satiety is `1 - CharacterStat.HUNGER`, matching the B42 stat range where hunger is 0 when full and 1 when starving.

- Health cost: `min(0.70, currentHealth - 0.30)`.
- Satiety cost: `min(0.20, currentSatiety - 0.30)`.
- Both reserves therefore stop at 30%.
- The old material recipe was removed so it cannot bypass this cost contract.
- Actual in-game cost feel: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_RED_CRAFT_TRANSACTION_REPORT.md

- SHA-256: `2ABE4A986FD7613DEA78475AE630012C43FAF77FBB5016326CF2ED3BD4FD1218`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Craft Transaction

Left double-click queues exactly one `XNPRedGuardianCraftAction`; it never inserts an item directly. The action uses `CharacterActionAnims.Craft`, blocks concurrent red consume/craft actions, and cancels on walking, running, aiming, attacking, hit reaction, death, replacement, or normal timed-action cancellation.

On completion, the transaction creates one item, commits the calculated health and satiety costs, and removes the item plus restores the prior values if either write fails. Interrupted actions create no item and apply no cost. The frame is transiently blue and the existing `RED_USE_OR_PHOENIX_READY` sound is played once at action start.

Runtime transaction ordering: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_RED_GREEN_MODE_API_REPORT.md

- SHA-256: `48E1B2F1402383B431B8EF6889EBDB02BC2172007D4C1220DBD25DFE10703485`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Green Mode API

Green consumption is positive-only and writes B42 `Stats` fields through `CharacterStat`:

- endurance: `+0.40`, clamped to 1;
- fatigue: `-0.50`, clamped to 0;
- panic, boredom, unhappiness: each multiplied by 0.5;
- no health, wound, infection, movement, coordinate, or time write occurs.

The mode remains selected in player ModData and requires the red trait at both queue and completion gates. Runtime value verification: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_RED_GREEN_REGEN_REPORT.md

- SHA-256: `A5491018BAEEFE04E4C377A0D674C8FD287E50EA0F4DC20C5CB24AA57A3BF0C2`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Green Regeneration

One stable central active-second task ID drives regeneration. Every two active real seconds it adds 0.01 endurance, up to 30 ticks / 60 active seconds. Paused frames do not advance the scheduler, and long resume gaps are capped by the existing scheduler.

Using another mark cancels and refreshes the same chain. Death, player replacement, main-menu/game cleanup, and invalid trait ownership cancel it. No `OnTick` listener was added. Runtime duration and pause behavior: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_RED_TRAIT_GATE_AND_SAVE_COMPATIBILITY_REPORT.md

- SHA-256: `0290D454374DC688D570AC56077915CD25A4ED3F356427C012BA4C8493206119`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red Trait Gate And Save Compatibility

- Canonical full ID: `XNPFeastGuardianTrait:XNPFeastGuardian`.
- Registration uses the B42 `character_trait_definition` plus `CharacterTrait.register` object route.
- Detection uses `getCharacterTraits():getKnownTraits()` and a canonical trait object; no string `player:hasTrait` route exists.
- The prior icon asset was restored byte-for-byte as `media/ui/Traits/trait_xnpfeastguardian.png`.
- Players without the trait see a low-alpha discovery panel, but cannot toggle, craft, consume, or receive the three starter items.
- Existing saves using the same full ID remain addressable; no replacement ID or migration rewrite is introduced.

Runtime save compatibility: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_RED_WHITE_MODE_API_REPORT.md

- SHA-256: `D8D38524FE528022842EBCD0B74FDD97AE2405B2A90E4FEE62B5671770209CED`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red White Mode API

White treatment reads `BodyDamage:getOverallBodyHealth()` and writes a target of `min(100, before + 50)` with `setOverallBodyHealth`. It clears body, body-part, fake, and `CharacterStat.ZOMBIE_INFECTION` zombie-infection flags.

It deliberately does not call `setWoundInfectionLevel` and does not clear `isInfectedWound`, preserving ordinary wound infection. It does not heal every body part, grant invulnerability, or modify player coordinates/time. Runtime API behavior: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_RED_WHITE_SELECTION_REPORT.md

- SHA-256: `A0A1A4E81B95E719F6CC1DA8B67F04CC484CB1B8AF9362743556BE6D556E83F6`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] Red White Selection

Candidates are classified once per body part:

- fracture: fracture time above zero;
- major: bite, deep wound, then burn priority;
- minor: cut, then scratch priority, only when the part is not already a major candidate.

`ZombRand` selects at most one candidate per category. A used-index set prevents the same body part from being selected twice across fracture, major, and minor categories. Selected wounds clear their own wound and bleeding state only. Runtime selection distribution: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_RUNTIME_PRESERVATION_REPORT.md

- SHA-256: `13CC7D11137A534DE1998E0B5109BBBBB42D7888709A9DE15182AD72D3D86930`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# [IP_REDACTED] Runtime Preservation

Explicitly changed runtime surfaces are identity, red trait registration/detection, red mark item definition, red mark/craft/consume/UI behavior, green tier state/UI, melee tier damage/cost, and red lifecycle cleanup.

Phoenix, yellow Distance Runner gameplay, drag controller, map hiding, tooltip framework, GreenBomb generation/layout/three-bomb count/4-second detonation/5-second cooldown, sound definitions, four OGG files, poster, preview, and unrelated runtime modules were not intentionally changed. Their exact baseline comparison is recorded during package validation.

Preserved feature runtime behavior: `NOT_YET_TESTED_IN_GAME`.

```

## 0.5.60.4_SOURCE_DROP_MIRROR_REPORT.md

- SHA-256: `AE8B3FF421EEB0B6D8DF3F109B04CCEC61EC6DC9760A56D69D40D17875C81FED`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# [IP_REDACTED] SOURCE / DROP Mirror Report

SOURCE: `[LOCAL_PATH_REDACTED]`

DROP: `[LOCAL_PATH_REDACTED]`

- DROP contains `42`, `mod.info`, `poster.png`, and the four delivery-document directories only.
- DROP file count: 171.
- Every DROP file has an identically addressed SOURCE file with the same SHA256.
- Mirror mismatch count: 0.
- SOURCE Kahlua: 91 pass / 0 fail.
- DROP Kahlua: 91 pass / 0 fail.
- No package, install, Workshop, game-directory, save, or user-mod write was performed.

```

## BUILD_MARKER.txt

- SHA-256: `A4BC1FBAE461BFF7C68BE288ADCB4DD574CE8285476C088A7FB64168A543CA89`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
XNP_PZ_DISTANCE_TRAIT_05604_RED_POSITIVE_CRAFT_GREEN_MELEE_TIERS_A

```
