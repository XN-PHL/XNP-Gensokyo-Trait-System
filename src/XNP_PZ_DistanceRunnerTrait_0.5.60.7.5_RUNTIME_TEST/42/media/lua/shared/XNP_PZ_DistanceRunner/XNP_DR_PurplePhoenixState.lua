require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTrait"

local Core = XNP_PZ_DistanceRunner
local P = Core.PurplePhoenixConstants
local State = { lastToggleMs = 0, toggleDebounceMs = 250 }

local function nowMs()
    if type(getTimestampMs) == "function" then return getTimestampMs() end
    return os.time() * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function dataFor(player)
    local ok, data = invoke(player, "getModData")
    return ok and type(data) == "table" and data or nil
end

local function isLivingPlayer(player)
    if Core.PhoenixLifeGate and Core.PhoenixLifeGate.IsLivingPlayer then
        return Core.PhoenixLifeGate.IsLivingPlayer(player) == true
    end
    local ok, dead = invoke(player, "isDead")
    return not ok or dead ~= true
end

local function clearLegacyCooldown(data)
    data[P.COOLDOWN_START_MODDATA_KEY] = nil
    data[P.LAST_TRIGGER_MODDATA_KEY] = nil
    data[P.CALM_OBSERVED_MODDATA_KEY] = nil
    data[P.LAST_CREDIT_HOUR_MODDATA_KEY] = nil
    data[P.WELL_FED_HOURS_MODDATA_KEY] = nil
    data[P.HEALTHY_HOURS_MODDATA_KEY] = nil
    data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY] = nil
    data[P.LEGACY_TEST_COOLDOWN_END_MS_MODDATA_KEY] = nil
    data[P.LEGACY_TEST_MIGRATION_MODDATA_KEY] = nil
end

local function migrateToThreeRealSeconds(player, data)
    if data[P.REAL_SECONDS_MIGRATION_MODDATA_KEY] == true then return false, "ALREADY_MIGRATED" end
    if not isLivingPlayer(player) then return false, "DEAD_PLAYER_NOT_MIGRATED" end

    local now = nowMs()
    local configuredMs = Core.PurplePhoenixConfig.Get().cooldownRealSeconds * 1000
    local migrationCapMs = math.min(configuredMs, 3000)
    local deadline = tonumber(data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY])
    local legacyDeadline = tonumber(data[P.TEST_COOLDOWN_END_MS_MODDATA_KEY])
        or tonumber(data[P.LEGACY_TEST_COOLDOWN_END_MS_MODDATA_KEY])
    local legacyProductionCooldown = tonumber(data[P.COOLDOWN_START_MODDATA_KEY]) ~= nil
    local oldCooldownActive = (deadline and deadline > now)
        or (legacyDeadline and legacyDeadline > now)
        or legacyProductionCooldown
    local migratedRemainingMs = 0

    if oldCooldownActive then
        local remainingMs = migrationCapMs
        if deadline and deadline > now then remainingMs = math.min(deadline - now, migrationCapMs) end
        if legacyDeadline and legacyDeadline > now then remainingMs = math.min(legacyDeadline - now, migrationCapMs) end
        migratedRemainingMs = math.max(0, remainingMs)
        data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = now + migratedRemainingMs
        data[P.ENABLED_MODDATA_KEY] = true
    else
        data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
        if data[P.ENABLED_MODDATA_KEY] == nil then data[P.ENABLED_MODDATA_KEY] = true end
    end

    clearLegacyCooldown(data)
    data[P.REAL_SECONDS_MIGRATION_MODDATA_KEY] = true
    print("[XNP PHOENIX MIGRATION] key=" .. P.REAL_SECONDS_MIGRATION_MODDATA_KEY
        .. " migrated=true old_cooldown_active=" .. tostring(oldCooldownActive)
        .. " remaining_real_seconds=" .. tostring(migratedRemainingMs / 1000))
    return true, oldCooldownActive and "LEGACY_COOLDOWN_CAPPED_TO_THREE_REAL_SECONDS" or "NO_ACTIVE_LEGACY_COOLDOWN"
end

local function settleCooldown(player, data)
    migrateToThreeRealSeconds(player, data)
    local deadline = tonumber(data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY])
    if deadline and nowMs() >= deadline then
        data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
        data[P.ENABLED_MODDATA_KEY] = false
        if Core.PhoenixTransaction then Core.PhoenixTransaction.OnCooldownFinished(player) end
        print("[XNP PHOENIX STATE] cooldown_complete=true elapsed_clock=REAL_MILLISECONDS next_state=GREEN")
        if Core.Audio then
            Core.Audio.PlayOnce(player, "RED_USE_OR_PHOENIX_READY", "phoenix-ready:" .. tostring(deadline))
        end
    end
end

function State.CancelPendingForDeath(player)
    local data = dataFor(player)
    if not data then return false, "NO_MODDATA" end
    data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = nil
    clearLegacyCooldown(data)
    data[P.ENABLED_MODDATA_KEY] = false
    return true, "DEATH_TRANSIENTS_CLEARED"
end

function State.IsEnabled(player)
    local data = dataFor(player)
    if not data then return true end
    settleCooldown(player, data)
    if data[P.ENABLED_MODDATA_KEY] == nil then data[P.ENABLED_MODDATA_KEY] = true end
    return data[P.ENABLED_MODDATA_KEY] ~= false
end

function State.SetEnabled(player, enabled)
    if not player or not Core.PurplePhoenixTrait.PlayerHasTrait(player) then return false, "TRAIT_MISSING" end
    if Core.PurplePhoenixConfig.Get().manualToggleEnabled ~= true then
        return false, "MANUAL_TOGGLE_DISABLED_BY_SANDBOX"
    end
    local data = dataFor(player)
    if not data then return false, "NO_MODDATA" end
    settleCooldown(player, data)
    if tonumber(data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY]) then return false, "COOLDOWN_LOCKED" end
    enabled = enabled == true
    if State.IsEnabled(player) == enabled then return false, "UNCHANGED" end
    data[P.ENABLED_MODDATA_KEY] = enabled
    if Core.PhoenixTransaction then
        if enabled then Core.PhoenixTransaction.OnManualReenabled(player)
        else Core.PhoenixTransaction.OnManualDisabled(player) end
    end
    if not enabled then
        if Core.PurplePhoenixInvulnerability then Core.PurplePhoenixInvulnerability.Cleanup(player, "PHOENIX_TOGGLE_OFF") end
        if Core.PurplePhoenixProtect then Core.PurplePhoenixProtect.Cleanup(player, "PHOENIX_TOGGLE_OFF") end
    end
    print("[XNP PHOENIX TOGGLE] enabled=" .. tostring(enabled))
    return true, "OK"
end

function State.Toggle(player)
    if Core.PurplePhoenixConfig.Get().manualToggleEnabled ~= true then
        return false, "MANUAL_TOGGLE_DISABLED_BY_SANDBOX"
    end
    local now = nowMs()
    if now - State.lastToggleMs < State.toggleDebounceMs then return false, "DEBOUNCE" end
    State.lastToggleMs = now
    local changed, reason = State.SetEnabled(player, not State.IsEnabled(player))
    if changed and Core.Audio then
        Core.Audio.PlayOnce(player, "MARKER_TOGGLE", "phoenix-toggle:" .. tostring(now))
    end
    return changed, reason
end

function State.ValidateBeginRecovery(player)
    if not isLivingPlayer(player) then return false, "PLAYER_NOT_LIVING" end
    if not dataFor(player) then return false, "MODDATA_UNAVAILABLE" end
    if Core.PurplePhoenixConfig.Get().cooldownMode ~= "REAL_SECONDS" then
        return false, "UNSUPPORTED_COOLDOWN_MODE"
    end
    return true, "REAL_TIME_STATE_CONTRACT_READY"
end

function State.BeginRecovery(player)
    local ready, reason = State.ValidateBeginRecovery(player)
    if not ready then return false, reason end
    local data = dataFor(player)
    local config = Core.PurplePhoenixConfig.Get()
    local durationMs = config.cooldownRealSeconds * 1000
    local deadline = nowMs() + durationMs
    data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY] = deadline
    data[P.REAL_SECONDS_MIGRATION_MODDATA_KEY] = true
    data[P.ENABLED_MODDATA_KEY] = true
    clearLegacyCooldown(data)
    print("[XNP PHOENIX STATE] cooldown_started=true mode=REAL_SECONDS seconds="
        .. tostring(config.cooldownRealSeconds) .. " deadline_ms=" .. tostring(deadline))
    return true, deadline
end

function State.UpdateRecovery(player, invulnerabilityActive)
    if not isLivingPlayer(player) then return false end
    local data = dataFor(player)
    if not data then return false end
    settleCooldown(player, data)
    return true
end

function State.GetRecharge(player)
    local data = dataFor(player)
    if not data then return "BLOCKED", math.huge, 0 end
    settleCooldown(player, data)
    local deadline = tonumber(data[P.COOLDOWN_END_REAL_MS_MODDATA_KEY])
    if deadline then return "COOLDOWN", math.max(0, deadline - nowMs()) / 1000, 0 end
    if data[P.ENABLED_MODDATA_KEY] == false then return "READY_DISABLED", 0, 0 end
    return "READY", 0, 0
end

function State.GetVisualState(player)
    local recharge, remaining = State.GetRecharge(player)
    if recharge == "COOLDOWN" then return "WHITE", remaining end
    if recharge == "READY" and State.IsEnabled(player) then return "BLUE", 0 end
    return "GREEN", 0
end

Core.PurplePhoenixState = State
return State
