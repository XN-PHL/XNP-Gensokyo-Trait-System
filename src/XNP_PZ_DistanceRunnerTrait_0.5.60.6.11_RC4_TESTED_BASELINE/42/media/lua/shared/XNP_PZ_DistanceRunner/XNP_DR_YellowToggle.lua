require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"

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
    local data = modData(player)
    if not data then
        return true
    end
    if data[YellowToggle.MODDATA_KEY] == nil then
        data[YellowToggle.MODDATA_KEY] = data[YellowToggle.LEGACY_MODDATA_KEY] ~= false
    end
    return data[YellowToggle.MODDATA_KEY] ~= false
end

function YellowToggle.SetEnabled(player, enabled, source)
    if not player or not Core.Trait or Core.Trait.PlayerHasTrait(player) ~= true then
        return false, "PLAYER_DOES_NOT_HAVE_TRAIT"
    end
    if normalClient() then
        return false, "SAFE_SERVER_AUTHORITY_REQUIRED"
    end
    local data = modData(player)
    if not data then
        return false, "NO_MODDATA"
    end
    enabled = enabled == true
    if data[YellowToggle.MODDATA_KEY] == enabled then
        return false, "UNCHANGED"
    end
    data[YellowToggle.MODDATA_KEY] = enabled
    print("[XNP YELLOW TOGGLE] enabled=" .. tostring(enabled) .. " source=" .. tostring(source or "UNKNOWN"))
    return true, "OK"
end

function YellowToggle.Toggle(player, source)
    local t = nowMs()
    if t - (YellowToggle.lastToggleMs or 0) < YellowToggle.toggleDebounceMs then
        return false, "DEBOUNCE"
    end
    YellowToggle.lastToggleMs = t
    local changed, reason = YellowToggle.SetEnabled(player, not YellowToggle.IsEnabled(player), source or "UNKNOWN")
    if changed and Core.Audio then
        Core.Audio.PlayOnce(player, "MARKER_TOGGLE", "yellow-toggle:" .. tostring(t))
    end
    return changed, reason
end

Core.YellowToggle = YellowToggle
return YellowToggle
