# Test and audit status

| Check | Result |
|---|---:|
| Second-pass static audit | PASS |
| Source Lua files checked | 101 |
| Source Kahlua failures | 0 |
| Workshop-mirror Lua files checked | 101 |
| Workshop Kahlua failures | 0 |
| Workshop mirror differences | 0 |
| Duplicate mod ID count | 0 |
| Duplicate Workshop ID count | 0 |
| Missing required file count | 0 |
| Source manifest hash mismatch count | 0 |
| Private-data leak count | 0 |
| Raw console file count | 0 |

The Kahlua checks compile every Lua source with the game-compatible runtime. Static audits also inspected required paths, source/Workshop equivalence, projection flow, draw-proof gates, bounded outline scanning, test-default wiring, and publication scope.

`USER_CONFIRMED_FUNCTIONS_PRESENT=true` records the user's runtime confirmation. It does not convert the static checks into an automated full-runtime proof. This build remains `RUNTIME_TEST`, and stable release is blocked while test-only defaults are enabled and the license remains unselected.

