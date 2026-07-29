require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}
local Core = XNP_PZ_DistanceRunner
local P = Core.PurplePhoenixConstants

local State = {
    BLUE = "BLUE",
    WHITE = "WHITE",
    GREEN = "GREEN",
    STATE_READY_ENABLED_BLUE = "READY_ENABLED_BLUE",
    STATE_COOLDOWN_WHITE = "COOLDOWN_WHITE",
    STATE_READY_DISABLED_GREEN = "READY_DISABLED_GREEN",
    STATE_TRIGGER_COMMITTING = "TRIGGER_COMMITTING",
    STATE_VERIFYING_SURVIVAL = "VERIFYING_SURVIVAL",
    STATE_DEAD_TOMBSTONED = "DEAD_TOMBSTONED",
    toggleDebounceMs = 250,
    lastToggleByPlayer = setmetatable({}, { __mode = "k" }),
}

local PERSISTED_STATES = {
    READY_ENABLED_BLUE = true,
    COOLDOWN_WHITE = true,
    READY_DISABLED_GREEN = true,
    DEAD_TOMBSTONED = true,
}

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return (os.time() or 0) * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function dataFor(player)
    local ok, data = invoke(player, "getModData")
    return ok and type(data) == "table" and data or nil
end

local function hasPurple(player)
    return Core.PurplePhoenixTrait
        and Core.PurplePhoenixTrait.PlayerHasTrait(player) == true
end

local function stateIsEnabled(state)
    return state == State.STATE_READY_ENABLED_BLUE
end

local function visibleColor(state)
    if state == State.STATE_READY_ENABLED_BLUE then return State.BLUE end
    if state == State.STATE_COOLDOWN_WHITE
        or state == State.STATE_TRIGGER_COMMITTING
        or state == State.STATE_VERIFYING_SURVIVAL then
        return State.WHITE
    end
    return State.GREEN
end

local function writeState(data, state)
    data[P.PHOENIX_STATE_MODDATA_KEY] = state
    local enabled = stateIsEnabled(state)
    -- These booleans are compatibility mirrors. The state field above is the
    -- only authoritative source after the 0.5.60.7.24 migration.
    data[P.PHOENIX_SURVIVAL_MODDATA_KEY] = enabled
    data[P.ENABLED_MODDATA_KEY] = enabled
end

local function legacyRegistryValue(player)
    local registry = Core.PurpleLifeStockRegistry
    if not registry or type(registry.GetLineage) ~= "function"
        or type(registry.GetRespawnMode) ~= "function" then
        return nil
    end
    local lineage = registry.GetLineage(player, false)
    if not lineage then return nil end
    local value = registry.GetRespawnMode(lineage)
    return type(value) == "boolean" and value or nil
end

function State.GetCooldownSeconds(player)
    local configured = tonumber(
        Core.PurplePhoenixConfig.Get().cooldownRealSeconds)
        or P.COOLDOWN_REAL_SECONDS_DEFAULT
    configured = math.max(1, math.min(300, configured))
    local data = dataFor(player)
    if not data then return configured end

    local legacyMarker = P.COOLDOWN_DEFAULT_REPAIR_MIGRATION_MODDATA_KEY
    local marker = "XNP_V2_200_PhoenixCooldownCanonicalRaw"
    local seenKey = P.COOLDOWN_CONFIG_SEEN_MODDATA_KEY
    local effectiveKey = P.COOLDOWN_EFFECTIVE_SECONDS_MODDATA_KEY
    local seen = tonumber(data[seenKey])
    local effective = tonumber(data[effectiveKey])
    local migratedFrom = "UNCHANGED"

    if data[marker] ~= true then
        -- V2 makes the visible Sandbox value authoritative. This deliberately
        -- removes the old raw=3/effective=5 cache split.
        effective = configured
        migratedFrom = data[legacyMarker] == true
            and "LEGACY_EFFECTIVE_CACHE_REBOUND_TO_RAW"
            or "CANONICAL_RAW_INITIALIZED"
        data[marker] = true
        data[legacyMarker] = true
        data[seenKey] = configured
        data[effectiveKey] = effective
        print("[XNP PHOENIX COOLDOWN MIGRATION] v2_canonical=true migrated_from="
            .. migratedFrom
            .. " raw_seconds=" .. tostring(configured)
            .. " effective_seconds=" .. tostring(effective))
    elseif not effective or not seen
        or math.abs(configured - seen) >= 0.0001 then
        -- A later Sandbox edit is explicit and supersedes the one-time repair.
        effective = configured
        data[seenKey] = configured
        data[effectiveKey] = effective
    end
    return math.max(1, math.min(300, effective or configured))
end

function State.EnsureDefaultMigration(player, source)
    if not player then return false, "PLAYER_MISSING" end
    local data = dataFor(player)
    if not data then return false, "PLAYER_MODDATA_UNAVAILABLE" end
    if not hasPurple(player) then
        return true, "PURPLE_TRAIT_NOT_PRESENT_NO_MIGRATION_REQUIRED"
    end

    local state = data[P.PHOENIX_STATE_MODDATA_KEY]
    if data[P.COLOR_STATE_REPAIR_MIGRATION_MODDATA_KEY] == true
        and PERSISTED_STATES[state] then
        writeState(data, state)
        State.GetCooldownSeconds(player)
        return true, "PHOENIX_COLOR_STATE_ALREADY_MIGRATED"
    end

    local deadline = tonumber(data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY])
    local enabled = type(data[P.PHOENIX_SURVIVAL_MODDATA_KEY]) == "boolean"
        and data[P.PHOENIX_SURVIVAL_MODDATA_KEY] or nil
    local migratedFrom = "NEW_DEFAULT"
    if enabled == nil and type(data[P.ENABLED_MODDATA_KEY]) == "boolean" then
        enabled = data[P.ENABLED_MODDATA_KEY]
        migratedFrom = "PLAYER_LEGACY_ENABLED_FIELD"
    end
    if enabled == nil then
        enabled = legacyRegistryValue(player)
        if enabled ~= nil then migratedFrom = "REGISTRY_READ_ONLY_LEGACY_MODE" end
    end

    if deadline and deadline > nowMs() then
        state = State.STATE_COOLDOWN_WHITE
        migratedFrom = "ACTIVE_COOLDOWN"
    elseif enabled == false then
        state = State.STATE_READY_DISABLED_GREEN
        data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
        migratedFrom = migratedFrom == "NEW_DEFAULT"
            and "EXPLICIT_DISABLED" or migratedFrom
    else
        state = State.STATE_READY_ENABLED_BLUE
        data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
    end

    writeState(data, state)
    data[P.COLOR_STATE_REPAIR_MIGRATION_MODDATA_KEY] = true
    data[P.PHOENIX_SURVIVAL_MIGRATION_MODDATA_KEY] = true
    State.GetCooldownSeconds(player)
    print("[XNP PHOENIX COLOR MIGRATION] key="
        .. P.COLOR_STATE_REPAIR_MIGRATION_MODDATA_KEY
        .. " source=" .. tostring(source or "UNKNOWN")
        .. " migrated_from=" .. migratedFrom
        .. " state=" .. state
        .. " visible_color=" .. visibleColor(state)
        .. " life_stock_registry_changed=false")
    return true, state
end

function State.ResetForNewCharacterCycle(player, source)
    if not player then return false, "PLAYER_MISSING" end
    if not hasPurple(player) then return false, "PURPLE_TRAIT_REQUIRED" end
    local data = dataFor(player)
    if not data then return false, "PLAYER_MODDATA_UNAVAILABLE" end
    data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
    writeState(data, State.STATE_READY_ENABLED_BLUE)
    data[P.COLOR_STATE_REPAIR_MIGRATION_MODDATA_KEY] = true
    data[P.PHOENIX_SURVIVAL_MIGRATION_MODDATA_KEY] = true
    State.GetCooldownSeconds(player)
    print("[XNP PHOENIX CYCLE] fresh_character_cycle=true"
        .. " source=" .. tostring(source or "UNKNOWN")
        .. " state=" .. State.STATE_READY_ENABLED_BLUE
        .. " visible_color=BLUE inherited_transient_state=false")
    return true, State.STATE_READY_ENABLED_BLUE
end

local function settleCooldown(player, data)
    local state = data[P.PHOENIX_STATE_MODDATA_KEY]
    if state ~= State.STATE_COOLDOWN_WHITE then return false end
    local deadline = tonumber(data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY])
    if deadline and nowMs() < deadline then return false end

    data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
    writeState(data, State.STATE_READY_DISABLED_GREEN)
    if Core.PhoenixTransaction
        and type(Core.PhoenixTransaction.OnCooldownFinished) == "function" then
        Core.PhoenixTransaction.OnCooldownFinished(player)
    end
    print("[XNP PHOENIX STATE] cooldown_complete=true"
        .. " elapsed_clock=REAL_MILLISECONDS"
        .. " next_state=" .. State.STATE_READY_DISABLED_GREEN
        .. " visible_color=GREEN auto_rearm=false")
    return true
end

function State.GetState(player)
    if not player then return State.STATE_READY_DISABLED_GREEN end
    local migrated = State.EnsureDefaultMigration(player, "PHOENIX_STATE_READ")
    if not migrated then return State.STATE_READY_DISABLED_GREEN end
    local data = dataFor(player)
    if not data then return State.STATE_READY_DISABLED_GREEN end
    settleCooldown(player, data)
    return data[P.PHOENIX_STATE_MODDATA_KEY]
end

function State.IsEnabled(player)
    return State.GetState(player) == State.STATE_READY_ENABLED_BLUE
end

function State.SetEnabled(player, enabled, source)
    if not player then return false, "PLAYER_MISSING" end
    if not hasPurple(player) then return false, "PURPLE_TRAIT_REQUIRED" end
    if Core.PurplePhoenixConfig.Get().manualToggleEnabled ~= true then
        return false, "MANUAL_TOGGLE_DISABLED_BY_SANDBOX"
    end
    local migrated, migrationReason = State.EnsureDefaultMigration(
        player, source or "PHOENIX_SURVIVAL_WRITE")
    if not migrated then return false, migrationReason end
    local data = dataFor(player)
    if not data then return false, "PLAYER_MODDATA_UNAVAILABLE" end
    settleCooldown(player, data)
    local before = data[P.PHOENIX_STATE_MODDATA_KEY]
    if before == State.STATE_COOLDOWN_WHITE then
        local remaining = math.max(0,
            (tonumber(data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY]) or nowMs())
                - nowMs()) / 1000
        return false, "PHOENIX_SURVIVAL_COOLDOWN", remaining
    end
    if before == State.STATE_DEAD_TOMBSTONED then
        return false, "DEAD_TOMBSTONED"
    end
    local after = enabled == true and State.STATE_READY_ENABLED_BLUE
        or State.STATE_READY_DISABLED_GREEN
    if before == after then return false, "TOGGLE_STATE_UNCHANGED" end

    writeState(data, after)
    if Core.PhoenixTransaction then
        if enabled == true
            and type(Core.PhoenixTransaction.OnManualReenabled) == "function" then
            Core.PhoenixTransaction.OnManualReenabled(player)
        elseif enabled ~= true
            and type(Core.PhoenixTransaction.OnManualDisabled) == "function" then
            Core.PhoenixTransaction.OnManualDisabled(player)
        end
    end
    print("[XNP PHOENIX SURVIVAL] source=" .. tostring(source or "SET_ENABLED")
        .. " before=" .. before
        .. " after=" .. after
        .. " enabled=" .. tostring(enabled == true)
        .. " visible_color=" .. visibleColor(after)
        .. " life_stock_registry_changed=false"
        .. " life_stock_gated_by_phoenix=false")
    return true, visibleColor(after)
end

function State.Toggle(player, source)
    local beforeState = State.GetState(player)
    local beforeColor = visibleColor(beforeState)
    if beforeState == State.STATE_COOLDOWN_WHITE then
        local _, remaining = State.GetRecharge(player)
        print("[XNP PHOENIX SURVIVAL INPUT] accepted=false"
            .. " source=" .. tostring(source or "UNKNOWN")
            .. " before=WHITE after=WHITE"
            .. " reject_reason=PHOENIX_SURVIVAL_COOLDOWN"
            .. " remaining_seconds=" .. tostring(remaining))
        return false, "PHOENIX_SURVIVAL_COOLDOWN", remaining
    end

    local now = nowMs()
    local last = State.lastToggleByPlayer[player] or 0
    if now - last < State.toggleDebounceMs then
        print("[XNP PHOENIX SURVIVAL INPUT] accepted=false"
            .. " source=" .. tostring(source or "UNKNOWN")
            .. " before=" .. beforeColor .. " after=" .. beforeColor
            .. " duplicate_same_frame=1 reject_reason=DEBOUNCE")
        return false, "DUPLICATE_SAME_FRAME"
    end
    State.lastToggleByPlayer[player] = now
    local changed, after, remaining = State.SetEnabled(
        player, beforeState ~= State.STATE_READY_ENABLED_BLUE,
        source or "PURPLE_ICON_RIGHT_CLICK")
    print("[XNP PHOENIX SURVIVAL INPUT] accepted=" .. tostring(changed == true)
        .. " source=" .. tostring(source or "UNKNOWN")
        .. " before=" .. beforeColor
        .. " after=" .. tostring(changed and after or beforeColor)
        .. " right_click_controls=PHOENIX_SURVIVAL_ONLY"
        .. " life_stock_registry_changed=false"
        .. " reject_reason=" .. tostring(changed and "NONE" or after))
    return changed, after, remaining
end

function State.ValidateBeginRecovery(player)
    if not player then return false, "PLAYER_MISSING" end
    if not hasPurple(player) then return false, "PURPLE_TRAIT_REQUIRED" end
    local state = State.GetState(player)
    if state ~= State.STATE_READY_ENABLED_BLUE then
        if state == State.STATE_COOLDOWN_WHITE then
            return false, "PHOENIX_SURVIVAL_COOLDOWN"
        end
        return false, "PHOENIX_SURVIVAL_DISABLED"
    end
    return true, "PHOENIX_SURVIVAL_BLUE_ARMED"
end

function State.BeginRecovery(player)
    local ready, reason = State.ValidateBeginRecovery(player)
    if not ready then return false, reason end
    local data = dataFor(player)
    if not data then return false, "PLAYER_MODDATA_UNAVAILABLE" end
    local seconds = State.GetCooldownSeconds(player)
    local deadline = nowMs() + seconds * 1000
    data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = deadline
    writeState(data, State.STATE_COOLDOWN_WHITE)
    print("[XNP PHOENIX STATE] cooldown_started=true"
        .. " mode=REAL_SECONDS seconds=" .. tostring(seconds)
        .. " deadline_ms=" .. tostring(deadline)
        .. " state=" .. State.STATE_COOLDOWN_WHITE
        .. " visible_color=WHITE enabled_after_trigger=false"
        .. " life_stock_gated_by_phoenix=false")
    return true, deadline
end

function State.ForceDisabledAfterConsumedRecovery(player, source)
    local data = dataFor(player)
    if not data then return false, "PLAYER_MODDATA_UNAVAILABLE" end
    data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
    writeState(data, State.STATE_READY_DISABLED_GREEN)
    print("[XNP PHOENIX STATE] forced_disabled=true"
        .. " source=" .. tostring(source or "RECOVERY_FAIL_CLOSED")
        .. " visible_color=GREEN")
    return true, State.STATE_READY_DISABLED_GREEN
end

function State.UpdateRecovery(player)
    local data = dataFor(player)
    if not data then return false, "PLAYER_MODDATA_UNAVAILABLE" end
    settleCooldown(player, data)
    return true, data[P.PHOENIX_STATE_MODDATA_KEY]
end

function State.GetRecharge(player)
    local state = State.GetState(player)
    if state == State.STATE_COOLDOWN_WHITE then
        local data = dataFor(player)
        local deadline = data
            and tonumber(data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY]) or nil
        return "COOLDOWN",
            math.max(0, (deadline or nowMs()) - nowMs()) / 1000, 0
    end
    if state == State.STATE_READY_ENABLED_BLUE then return "READY", 0, 0 end
    if state == State.STATE_DEAD_TOMBSTONED then return "DEAD", 0, 0 end
    return "READY_DISABLED", 0, 0
end

function State.GetVisualState(player)
    local state = State.GetState(player)
    local remaining = 0
    if state == State.STATE_COOLDOWN_WHITE then
        local _, value = State.GetRecharge(player)
        remaining = value
    end
    return visibleColor(state), remaining
end

function State.GetTooltipState(player)
    local state = State.GetState(player)
    if state == State.STATE_COOLDOWN_WHITE then
        return "PHOENIX_SURVIVAL_COOLDOWN"
    end
    return state == State.STATE_READY_ENABLED_BLUE
        and "PHOENIX_SURVIVAL_ENABLED"
        or "PHOENIX_SURVIVAL_DISABLED"
end

function State.AuditConsistency(player, source)
    local state = State.GetState(player)
    local recharge, remaining = State.GetRecharge(player)
    local audit = {
        state = state,
        visible_color = visibleColor(state),
        tooltip_state = State.GetTooltipState(player),
        phoenix_survival_enabled = stateIsEnabled(state),
        cooldown_state = recharge,
        cooldown_remaining_seconds = remaining,
        life_stock_gated_by_phoenix = false,
    }
    print("[XNP PHOENIX SURVIVAL AUDIT] source="
        .. tostring(source or "AUDIT")
        .. " state=" .. audit.state
        .. " visible_color=" .. audit.visible_color
        .. " tooltip_state=" .. audit.tooltip_state
        .. " cooldown_state=" .. audit.cooldown_state
        .. " cooldown_remaining_seconds="
        .. tostring(audit.cooldown_remaining_seconds)
        .. " life_stock_gated_by_phoenix=false")
    return audit.phoenix_survival_enabled, "PHOENIX_SURVIVAL_AUDIT", audit
end

function State.CancelPendingForDeath(player)
    local data = dataFor(player)
    if data then
        data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
        writeState(data, State.STATE_DEAD_TOMBSTONED)
    end
    return true, "PHOENIX_SURVIVAL_TRANSIENTS_CLEARED"
end

Core.PurplePhoenixState = State
return State
