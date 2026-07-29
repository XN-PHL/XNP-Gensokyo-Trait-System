require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_MasterEffectState"

local Core = XNP_PZ_DistanceRunner
local YellowToggle = {
    MODDATA_KEY = "XNP_DR_YELLOW_ENABLED",
    LEGACY_MODDATA_KEY = "XNPDistanceRunner_MasterEnabled",
    lastToggleMs = 0,
    toggleDebounceMs = 250,
}

local function nowMs()
    if type(getTimestampMs) == "function" then
        return getTimestampMs()
    end
    return os.time() * 1000
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

function YellowToggle.IsEnabled(player)
    return Core.MasterEffectState.IsEnabled(player) == true
end

function YellowToggle.SetEnabled(player, enabled, source)
    return Core.MasterEffectState.SetEnabled(player, enabled, source or "YELLOW_MANUAL_STATE")
end

function YellowToggle.Toggle(player, source)
    local t = nowMs()
    if t - (YellowToggle.lastToggleMs or 0) < YellowToggle.toggleDebounceMs then
        return false, "DEBOUNCE"
    end
    YellowToggle.lastToggleMs = t
    return YellowToggle.SetEnabled(player, not YellowToggle.IsEnabled(player), source or "UNKNOWN")
end

YellowToggle.STATE_OWNER = "YellowManualEnabled"

Core.YellowToggle = YellowToggle
return YellowToggle
