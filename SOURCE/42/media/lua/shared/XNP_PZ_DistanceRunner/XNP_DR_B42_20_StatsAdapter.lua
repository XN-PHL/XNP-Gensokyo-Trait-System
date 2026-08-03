XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Adapter = {}

local function resolveStat(statName)
    if CharacterStat == nil then
        return nil
    end
    return CharacterStat[statName]
end

function Adapter.Read(player, statName)
    if not player or type(player.getStats) ~= "function" then
        return nil, "PLAYER_STATS_UNAVAILABLE"
    end
    local stat = resolveStat(statName)
    if stat == nil then
        return nil, "CHARACTER_STAT_UNAVAILABLE:" .. tostring(statName)
    end
    local ok, value = pcall(function()
        return player:getStats():get(stat)
    end)
    if not ok or type(value) ~= "number" then
        return nil, "STAT_READ_FAILED:" .. tostring(statName)
    end
    return value, "B42_20_STATS_CHARACTER_STAT"
end

function Adapter.Write(player, statName, value)
    if type(value) ~= "number" or value ~= value then
        return false, "INVALID_VALUE"
    end
    if not player or type(player.getStats) ~= "function" then
        return false, "PLAYER_STATS_UNAVAILABLE"
    end
    local stat = resolveStat(statName)
    if stat == nil then
        return false, "CHARACTER_STAT_UNAVAILABLE:" .. tostring(statName)
    end
    local ok = pcall(function()
        player:getStats():set(stat, value)
    end)
    return ok, ok and "B42_20_STATS_CHARACTER_STAT"
        or "STAT_WRITE_FAILED:" .. tostring(statName)
end

Core.B42_20StatsAdapter = Adapter
return Adapter
