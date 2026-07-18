require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"

local Core = XNP_PZ_DistanceRunner
local MasterEffectState = {
    MODDATA_KEY = "XNP_DR_YELLOW_ENABLED",
    LEGACY_MODDATA_KEY = "XNPDistanceRunner_MasterEnabled",
    lastCleanupState = {},
    lastToggleMs = 0,
    toggleDebounceMs = 250,
}

local function nowMs()
    if type(getTimestampMs) == "function" then
        return getTimestampMs()
    end
    return os.time() * 1000
end

local function playerKey(player)
    if not player then return "nil" end
    if type(player.getOnlineID) == "function" then
        local ok, value = pcall(function() return player:getOnlineID() end)
        if ok and value ~= nil then return tostring(value) end
    end
    if type(player.getPlayerNum) == "function" then
        local ok, value = pcall(function() return player:getPlayerNum() end)
        if ok and value ~= nil then return tostring(value) end
    end
    return tostring(player)
end

local function modData(player)
    if player and type(player.getModData) == "function" then
        local ok, data = pcall(function() return player:getModData() end)
        if ok and type(data) == "table" then
            return data
        end
    end
    return nil
end

local function normalClient()
    return type(isClient) == "function" and isClient() == true
end

local function callCleanup(moduleName, methodName, player, reason)
    local module = Core[moduleName]
    if module and type(module[methodName]) == "function" then
        pcall(function() module[methodName](player, reason) end)
        return true
    end
    return false
end

function MasterEffectState.Load(player)
    local data = modData(player)
    if not data then
        return true
    end
    if data[MasterEffectState.MODDATA_KEY] == nil then
        -- One-time migration preserves the old yellow preference without
        -- sharing the new key with Phoenix.
        data[MasterEffectState.MODDATA_KEY] = data[MasterEffectState.LEGACY_MODDATA_KEY] ~= false
    end
    return data[MasterEffectState.MODDATA_KEY] ~= false
end

function MasterEffectState.Save(player, enabled)
    local data = modData(player)
    if not data then
        return false, "NO_MODDATA"
    end
    data[MasterEffectState.MODDATA_KEY] = enabled == true
    return true, "OK"
end

function MasterEffectState.IsEnabled(player)
    return MasterEffectState.Load(player) == true
end

function MasterEffectState.IsToggleAllowed(player)
    -- This compatibility module now owns yellow Distance Runner only.
    local hasDistanceRunner = player and Core.Trait and Core.Trait.PlayerHasTrait(player) == true
    if not player or not hasDistanceRunner then
        return false, "PLAYER_DOES_NOT_HAVE_TRAIT"
    end
    if normalClient() then
        return false, "SAFE_SERVER_AUTHORITY_REQUIRED"
    end
    return true, "OK"
end

function MasterEffectState.ResetTransientState(player, reason)
    reason = reason or "MASTER_TRANSIENT_RESET"
    callCleanup("Adrenaline", "Clear", player, reason)
    callCleanup("StaminaDrain", "Cleanup", player, reason)
    callCleanup("LongMigrationStaminaAssist", "Cleanup", player, reason)
    callCleanup("FoodReserveConversion", "Cleanup", player, reason)
    callCleanup("TieredFoodRecovery", "Cleanup", player, reason)
    callCleanup("PreBiteJogRescue", "Cleanup", player, reason)
    callCleanup("StaminaTrendMeter", "Cleanup", player, reason)
    callCleanup("EnduranceBandState", "Reset", player, reason)
    callCleanup("EnduranceCapabilityState", "Reset", player, reason)
    callCleanup("NearbyZombieCache", "Cleanup", player, reason)
    callCleanup("CentralWorldQuery", "Clear", player, reason)
    callCleanup("ImpactCandidateSnapshot", "Cleanup", player, reason)
    callCleanup("ImpactQuotaMeter", "Cleanup", player, reason)
    callCleanup("BreakoutPush", "Cleanup", player, reason)
    callCleanup("NativeTripWindow", "Cleanup", player, reason)
    callCleanup("SprintTripImmunity", "Cleanup", player, reason)
    callCleanup("DragdownDangerBreakout", "Cleanup", player, reason)
    callCleanup("DragdownDangerClassifier", "Cleanup", player, reason)
    callCleanup("BreakoutActionBus", "Cleanup", player, reason)
    callCleanup("JogBumpLaunch", "Cleanup", player, reason)
    return true
end

function MasterEffectState.SetEnabled(player, enabled, source)
    enabled = enabled == true
    local ok, reason = MasterEffectState.IsToggleAllowed(player)
    if not ok then
        print("[XNP YELLOW TOGGLE] blocked reason=" .. tostring(reason) .. " source=" .. tostring(source or "UNKNOWN"))
        return false, reason
    end
    local current = MasterEffectState.Load(player)
    if current == enabled then
        return false, "UNCHANGED"
    end
    local saved, saveReason = MasterEffectState.Save(player, enabled)
    if not saved then
        return false, saveReason
    end
    MasterEffectState.ResetTransientState(player, enabled and "MASTER_ON_RESET_TRANSIENT" or "MASTER_OFF_RESET_TRANSIENT")
    MasterEffectState.lastCleanupState[playerKey(player)] = enabled
    print("[XNP YELLOW TOGGLE] enabled=" .. tostring(enabled) .. " source=" .. tostring(source or "UNKNOWN"))
    return true, "OK"
end

function MasterEffectState.Toggle(player, source)
    local t = nowMs()
    if t - (MasterEffectState.lastToggleMs or 0) < MasterEffectState.toggleDebounceMs then
        return false, "DEBOUNCE"
    end
    MasterEffectState.lastToggleMs = t
    return MasterEffectState.SetEnabled(player, not MasterEffectState.IsEnabled(player), source or "UNKNOWN")
end

function MasterEffectState.EnsureDisabledCleanup(player)
    if MasterEffectState.IsEnabled(player) then
        return false
    end
    local key = playerKey(player)
    if MasterEffectState.lastCleanupState[key] ~= false then
        MasterEffectState.ResetTransientState(player, "MASTER_OFF_RUNTIME_GUARD")
        MasterEffectState.lastCleanupState[key] = false
    end
    return true
end

function MasterEffectState.GetUiState(player)
    local enabled = MasterEffectState.IsEnabled(player)
    return {
        enabled = enabled,
        state = enabled and "MASTER_ENABLED" or "MASTER_DISABLED_WHITE",
        color = enabled and "BAND" or "WHITE",
        modDataKey = MasterEffectState.MODDATA_KEY,
    }
end

Core.MasterEffectState = MasterEffectState
return MasterEffectState
