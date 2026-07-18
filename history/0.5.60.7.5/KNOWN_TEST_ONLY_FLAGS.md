# Known test-only flags

```text
GreenRuntimeTestNoCooldown_DEFAULT=true
GreenInflightDiagnosticBorderEnabled_DEFAULT=true
TEST_BUILD_ONLY=true
MUST_BE_FALSE_BEFORE_STABLE_RELEASE=true
STABLE_RELEASE_ALLOWED=false
```

## `GreenRuntimeTestNoCooldown`

- Definition/default: `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/42/media/sandbox-options.txt` defines the option and `default=true`.
- Schema fallback: `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_SandboxSchema.lua` reads it with fallback `true`.
- Runtime read: `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_GreenWorldOrb.lua` reads the value into the Green-orb options.
- Call behavior: the same file bypasses the cooldown gate while enabled, records zero cooldown after use, and reports the test state through its diagnostic path.

## `GreenInflightDiagnosticBorderEnabled`

- Definition/default: `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/42/media/sandbox-options.txt` defines the option and `default=true`.
- Schema fallback: `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/42/media/lua/shared/XNP_PZ_DistanceRunner/XNP_DR_SandboxSchema.lua` reads it with fallback `true`.
- Runtime option read: `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_GreenWorldOrb.lua` includes it in the Green-orb runtime options.
- Draw call: `src/XNP_PZ_DistanceRunnerTrait_0.5.60.7.5_RUNTIME_TEST/42/media/lua/client/XNP_PZ_DistanceRunner/XNP_DR_GreenSmoothVisual.lua` reads the value with fallback `true` and controls the inflight diagnostic border.

These values match the source. Any future source/documentation mismatch is a release blocker. Both defaults must be changed to `false`, their schema fallbacks reviewed, and the package re-audited before a stable release.
