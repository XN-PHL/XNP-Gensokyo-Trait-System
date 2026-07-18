# 0.5.60.6.5 Sanitized Runtime Evidence

## Observed Failure

```text
GREEN_ENTITY_METHOD=ISO_BALL_CAPTURED_FROM_EXPOSED_THROW_FACTORY
GREEN_ENTITY_CREATE_FAILED_COUNT=34
FBO_RENDER_EXCEPTION_COUNT=1986
NULL_NAME_SCRIPT_BUCKET_EXCEPTION_COUNT=1986
ACTIVE_ENTITY_CREATE_FAILED:NEW_ISO_BALL_HANDLE_NOT_FOUND
```

The green skill failed to obtain a valid moving-entity handle on every recorded attempt. A malformed world inventory render object then caused repeated exceptions in the world-item/FBO render path. Characters and zombies remained in simulation, but world-character rendering was interrupted.

## Root Cause

```text
ROOT_CAUSE=FAILED_THROW_FACTORY_LEFT_MALFORMED_WORLD_INVENTORY_RENDER_OBJECT
PHOENIX_CAUSAL_ROLE=NONE
RUNTIME_VISUAL_STATUS=FAILED_WORLD_RENDER_INTERRUPTED
```

The prior static assumption that the Throw factory exposed a safely capturable `IsoBall` is rejected by runtime evidence. The target-outline route is also removed from the successor to eliminate render-state ownership risk.

## Privacy

The public `console_35_render_failure_excerpt.txt` contains render-failure evidence only. Local paths and hardware-identifying lines were removed. The complete console remains private in SOURCE.
