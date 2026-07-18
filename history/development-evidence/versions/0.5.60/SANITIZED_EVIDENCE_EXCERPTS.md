# 0.5.60 Sanitized Evidence Excerpts

## 0.5.60_XNP运行错误检查.md

- SHA-256: `2FA021AB666A016B3FF67F7F1EF29DCF2DEBCB5599996424AA3FDEACE38E2C4D`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.60 XNP Runtime Error Check

Evidence file: `console(23)_0.5.59瀹炴満鏃ュ織.txt`

`CONSOLE_SHA256=20026E6CC7749482560D8B7401F2F221BB01E54B32D7FD394C1A3CDF7E5EC743`
`XNP_RUNTIME_STACK_ERROR_ACTIVE=false`
`XNP_ROUND_MARKER_RUNTIME_ERROR_ACTIVE=false`
`XNP_LOG_LINES=1`
`XNP_MOD_STACK_HITS=0`
`XNP_ROUND_MARKER_HITS=0`

0.5.60 itself has not yet been run by the user.

```

## 0.5.60_错误归属矩阵.md

- SHA-256: `EA50E97983D0CEBCEF7625A0073E6D4C3FE68F02A40CFCCA7839D92FB9B6C24B`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.60 Error Ownership Matrix

`XNP_FUNCTIONAL_ISSUE=鍦板浘鏈熼棿涓嶉殣钘弢缂哄皯tooltip|缂哄皯绾㈣壊鍙屽嚮`
`XNP_RUNTIME_STACK_ERROR_COUNT=0`
`WARTHUNDER_RUNTIME_ERROR=THIRD_PARTY`
`BANDITS_WEEK_ONE_RUNTIME_ERROR=THIRD_PARTY`
`LOW_FPS_FULLY_FIXED_BY_0.5.60=false`

The supplied console has 21,243 lines, 931 error-prefix lines, one XNP log line, zero XNP stack hits, and zero round-marker hits. WarThunderVehicleLibrary has 131 exceptions/655 stack-line hits; Bandits Week One has 131 exceptions/524 stack-line hits. Neither third-party mod was changed.

```

## 0.5.60_低帧率证据报告.md

- SHA-256: `18BF940DAB3715A5AB2FCFD2EA840DB6D2BC102165989C096590B5305EBE801E`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.60 Low FPS Evidence

The supplied 0.5.59 console contains repeated third-party exceptions from WarThunderVehicleLibrary and Bandits Week One. Static ownership does not prove a single cause for all low FPS, and 0.5.60 does not modify those mods.

`LOW_FPS_FULLY_FIXED_BY_0.5.60=false`
`WARTHUNDER_EXCEPTION_COUNT=131`
`BANDITS_WEEK_ONE_EXCEPTION_COUNT=131`
`XNP_PER_FRAME_RESOURCE_CREATION_ADDED=false`

```

## 0.5.60_实机测试记录模板.md

- SHA-256: `42446C2C2B347CB952F0BDC700CDEB925F154C9912D836B677BBADA6B53B9FE4`
- Type: 错误报告
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# 0.5.60 User Runtime Test Record

- Map open hides all four markers and blocks no map input: NOT_YET_TESTED
- Map close restores correct state and saved positions: NOT_YET_TESTED
- Four CN/EN tooltips, drag/right-click unaffected: NOT_YET_TESTED
- Phoenix BLUE -> trigger -> WHITE 5s -> GREEN -> right-click BLUE: NOT_YET_TESTED
- WHITE right-click remains WHITE: NOT_YET_TESTED
- Red single click does nothing; double-click starts TimedAction: NOT_YET_TESTED
- Red drag never consumes; interruption preserves item; duplicate queue rejected: NOT_YET_TESTED
- New poster/preview visible: NOT_YET_TESTED
- Yellow shake unchanged: NOT_YET_TESTED

Attach the new console and note save/reload timing if any result fails.

```

## 0.5.60_B42_MAP_UI_VISIBILITY_API_EVIDENCE.md

- SHA-256: `76B65F99E35AF64AA0B9C319511E70FB18447B937EB12938C13A2E00C9D6A01E`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# B42 Map UI Visibility API Evidence

- Game evidence root: `[LOCAL_PATH_REDACTED]`
- JAR: `projectzomboid.jar` (63,890,567 bytes)
- Native Lua: `media/lua/client/ISUI/Maps/ISWorldMap.lua`
- B42 world-map singleton: `ISWorldMap_instance`
- Native visibility query: `ISWorldMap_instance:isVisible()`; the same query is used by `ISChat.lua` and `ISZoneDisplay.lua`.
- The implementation queries only this world/full-screen map singleton. Inventory, health, pause, and main-menu panels do not satisfy the test.
- Query interval: 250 ms, through the existing single `OnPlayerUpdate` route; no `OnTick` was added.

`MAP_UI_API_STATICALLY_VERIFIED=true`
`MAP_HIDE_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60_FOUR_MARKER_MAP_HIDE_STATE_MACHINE.md

- SHA-256: `D48D502485F776CB73FFBFEAE120F977BA341BA044DCAB8A9237101A1325C7C8`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Four Marker Map Hide State Machine

`RoundMarkerMapVisibility` caches the B42 map state at 4 Hz. A transition publishes `SetMapHidden` to all four persistent panels. Opening the map cancels active drag capture, hides the shared tooltip, sets each panel invisible, and disables mouse consumption. Closing it restores only each panel's saved `desiredVisible` state.

`MAP_OPEN_HIDES_YELLOW=true`
`MAP_OPEN_HIDES_PURPLE=true`
`MAP_OPEN_HIDES_GREEN=true`
`MAP_OPEN_HIDES_RED=true`
`MAP_CLOSE_RESTORES_MARKERS=true`
`MAP_HIDE_DESTROYS_PANEL=false`
`MAP_HIDE_RESETS_POSITION=false`
`MAP_HIDDEN_MOUSE_INTERCEPTION=false`
`MAP_CHECK_USES_NEW_ONTICK=false`
`MAP_HIDE_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60_FOUR_MARKER_TOOLTIP_REPORT.md

- SHA-256: `682825979AB7EBFA967B8EA2544C598BE1E1319E796FCE9FD4222C769A759DB4`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Four Marker Tooltip Report

The four panels share one lazily-created `ISToolTip`. It has one changing owner, `setConsumeMouseEvents(false)`, translated CN/EN descriptions, and dynamic state/count text refreshed by the existing UI cadence. Mouse-down, mouse-out, map-open, hidden-owner, and cleanup paths hide it.

`YELLOW_TOOLTIP_PRESENT=true`
`PURPLE_TOOLTIP_PRESENT=true`
`GREEN_TOOLTIP_PRESENT=true`
`RED_TOOLTIP_PRESENT=true`
`TOOLTIP_MOUSE_TRANSPARENT=true`
`TOOLTIP_SINGLETON_REUSED=true`
`TOOLTIP_CREATE_PER_FRAME=false`
`TOOLTIP_HIDDEN_WITH_MAP=true`
`TOOLTIP_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60_PHOENIX_5_SECOND_TEST_COOLDOWN_REPORT.md

- SHA-256: `75F81023B9903252FBE7FFEA08B6EBD2E554FA5B500E105F279A30D069979A8F`
- Type: 阶段总结
- Runtime status: SEE_EVIDENCE_FILE

```text
# Phoenix 5 Second Test Cooldown Report

The production world-hour cooldown and dynamic credit algorithm remains in `XNP_DR_PurplePhoenixState.lua` as `productionRecharge`. The 0.5.60 constant selects an overlay deadline stored as epoch milliseconds in player ModData. A successful trigger writes `now + 5000`; load/reload compares the persisted deadline with `getTimestampMs()` and therefore neither restarts nor follows game-time acceleration.

`PHOENIX_TEST_COOLDOWN_MODE=true`
`PHOENIX_PRODUCTION_COOLDOWN_CODE_PRESERVED=true`
`PHOENIX_TEST_OVERRIDE_ONLY=true`
`PHOENIX_TRIGGER_LOGIC_CHANGED=false`
`PHOENIX_REALTIME_COOLDOWN_SECONDS=5.00`
`PHOENIX_AUTO_REENABLE_AFTER_COOLDOWN=false`
`PHOENIX_5_SECOND_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60_PHOENIX_RIGHT_CLICK_LOCK_REPORT.md

- SHA-256: `A1DB7DE1E08917F720F7DAC6BC48836803135FF45CA2D3A1124BFCBB33D909EA`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Phoenix Right Click Lock Report

`SetEnabled` settles migration/expiry first, then rejects any live test deadline with stable reason `COOLDOWN_LOCKED`. Thus white cannot switch. Green right-click enables blue; blue right-click disables to green. Debounce remains 250 ms.

`PURPLE_WHITE_RIGHT_CLICK_STATE_CHANGE=false`
`PURPLE_GREEN_RIGHT_CLICK_TO_BLUE=true`
`PURPLE_BLUE_RIGHT_CLICK_TO_GREEN=true`
`PURPLE_THREE_COLOR_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60_PHOENIX_THREE_COLOR_STATE_MIGRATION.md

- SHA-256: `02F8A288199DCC7A61B57EA69D28E517A60E216C12A33C8EDA914D11F3B3B2ED`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Phoenix Three Color State Migration

- `BLUE=READY_ENABLED`
- `WHITE=COOLDOWN_LOCKED`
- `GREEN=READY_DISABLED`

Fresh/old ready-enabled data becomes blue; ready-disabled becomes green. An old production cooldown or waiting-for-calm state receives one 5-second test migration deadline and remains white until expiry. Expiry clears the deadline and sets enabled false, so the next state is green and never auto-blue.

The finite post-trigger invulnerability/protect transaction is preserved. White and green cannot start a new Phoenix transaction; only blue is armed.

`PURPLE_PANEL_ALWAYS_EXISTS=true`
`PURPLE_TRIGGER_HIDES_PANEL=false`
`PURPLE_BLUE_PROTECTION_ACTIVE=true`
`PURPLE_GREEN_PROTECTION_ACTIVE=false`
`PURPLE_WHITE_PROTECTION_ACTIVE=false`
`PURPLE_THREE_COLOR_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60_PREVIEW_ASSET_LOCK_AND_ROUTE_REPORT.md

- SHA-256: `4D56FB08A293A680C1A561D3675026597CC934B5F4C2A8D142EE9432941DEFED`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Preview Asset Lock and Route Report

The command-package `绱犳潗_绂佹淇敼/preview.png` was copied byte-for-byte, without image decoding or encoding, to SOURCE root `poster.png`, `42/poster.png`, and first-level `鍒涙剰宸ュ潑涓婁紶鍥?preview.png`. The same files are mirrored to DROP. No Workshop path was written and no upload occurred.

`WIDTH=512`
`HEIGHT=512`
`BYTES=491092`
`GAME_POSTER_SOURCE_SHA256=9C91BDB92E08C7C3E2DE6162F2F7C9DCC19D32A9F9DE0189799BB710D7178B9E`
`GAME_POSTER_DROP_SHA256=9C91BDB92E08C7C3E2DE6162F2F7C9DCC19D32A9F9DE0189799BB710D7178B9E`
`WORKSHOP_PREVIEW_READY_SHA256=9C91BDB92E08C7C3E2DE6162F2F7C9DCC19D32A9F9DE0189799BB710D7178B9E`
`PREVIEW_PIXEL_OR_BYTE_MODIFICATION_COUNT=0`
`WORKSHOP_UPLOAD_PERFORMED=false`
`PREVIEW_USER_RUNTIME_TEST=NOT_YET_TESTED`

```

## 0.5.60_RED_DOUBLE_CLICK_DRAG_CONFLICT_MATRIX.md

- SHA-256: `506AE119F04177F5509F299FDC6DF6A730454F91ED4ACF7D0982ED78E114E330`
- Type: 阶段总结
- Runtime status: NOT_YET_TESTED_OR_NOT_STATED

```text
# Red Double Click / Drag Conflict Matrix

| Input | Result |
|---|---|
| Single left click | Save first click only; no use |
| Two clicks <=350 ms and <=5 px | Queue one current-mode TimedAction |
| Movement >5 px | Mark drag, clear click candidate, no use |
| Mouse-up outside | Release drag and clear click candidate |
| Right-click | Clear click candidate and open existing menu |
| Map open | Cancel drag, hide/disable panel, clear click candidate |
| Action already queued | Reject `ACTION_ALREADY_QUEUED` |

`DOUBLE_CLICK_USES_ONTICK=false`
`RED_DOUBLE_CLICK_USER_RUNTIME_TEST=NOT_YET_TESTED`

```
