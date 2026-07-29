require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Authority = {
    foodState = setmetatable({}, { __mode = "k" }),
    warned = {},
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function sideFlag(name)
    local fn = _G[name]
    if type(fn) ~= "function" then
        return false
    end
    local ok, value = pcall(fn)
    return ok and value == true
end

local function statsFor(player)
    if not player or type(player.getStats) ~= "function" then
        return nil
    end
    local ok, stats = pcall(function()
        return player:getStats()
    end)
    return ok and stats or nil
end

local function statGet(stats, stat, getter)
    if not stats then
        return nil
    end
    if stat ~= nil and type(stats.get) == "function" then
        local ok, value = pcall(function()
            return stats:get(stat)
        end)
        if ok and Constants.IsFiniteNumber(value) then
            return value
        end
    end
    if getter and type(stats[getter]) == "function" then
        local ok, value = pcall(function()
            return stats[getter](stats)
        end)
        if ok and Constants.IsFiniteNumber(value) then
            return value
        end
    end
    return nil
end

local function statSet(stats, stat, setter, value)
    value = Constants.Clamp(value, 0.0, 1.0)
    if stat ~= nil and type(stats.set) == "function" then
        local ok = pcall(function()
            stats:set(stat, value)
        end)
        if ok then
            return true
        end
    end
    if setter and type(stats[setter]) == "function" then
        local ok = pcall(function()
            stats[setter](stats, value)
        end)
        if ok then
            return true
        end
    end
    return false
end

local function serverSyncMasks()
    if not Authority.IsServer() then
        return true, nil, nil
    end
    if type(syncPlayerStats) ~= "function"
        or not CharacterStat
        or not SyncPlayerStatsPacket
        or not SyncPlayerStatsPacket.getBitMaskForStat then
        return false, nil, nil
    end
    local okEndurance, enduranceMask = pcall(function()
        return SyncPlayerStatsPacket.getBitMaskForStat(CharacterStat.ENDURANCE)
    end)
    local okHunger, hungerMask = pcall(function()
        return SyncPlayerStatsPacket.getBitMaskForStat(CharacterStat.HUNGER)
    end)
    if not okEndurance or not okHunger
        or not Constants.IsFiniteNumber(enduranceMask)
        or not Constants.IsFiniteNumber(hungerMask)
        or enduranceMask <= 0 or hungerMask <= 0 then
        return false, nil, nil
    end
    return true, enduranceMask, hungerMask
end

local function syncServerStats(player, enduranceMask, hungerMask)
    if not Authority.IsServer() then
        return true
    end
    local okEndurance = pcall(syncPlayerStats, player, enduranceMask)
    local okHunger = pcall(syncPlayerStats, player, hungerMask)
    return okEndurance and okHunger
end

local function stateFor(player)
    local state = Authority.foodState[player]
    if not state then
        state = { active = false, lastTick = 0, lastDiscreteCost = 0 }
        Authority.foodState[player] = state
    end
    return state
end

function Authority.IsClient()
    return sideFlag("isClient")
end

function Authority.IsServer()
    return sideFlag("isServer")
end

function Authority.IsSinglePlayer()
    return not Authority.IsClient() and not Authority.IsServer()
end

function Authority.IsAuthoritativeForStats(player)
    return player ~= nil and not Authority.IsClient()
end

function Authority.ValidateFoodWritePath()
    if Authority.IsClient() then
        return false, "CLIENT_STAT_WRITE_FORBIDDEN"
    end
    return true, Authority.IsServer() and "SERVER_AUTHORITY" or "SINGLEPLAYER_AUTHORITY"
end

function Authority.CanWriteNonFoodStats(player, source)
    if not Authority.IsAuthoritativeForStats(player) then
        if Core.LogThrottle then
            Core.LogThrottle.Blocked("AUTHORITY", "NORMAL_MP_CLIENT_NON_FOOD_STAT_WRITE_FORBIDDEN_" .. tostring(source or "UNKNOWN"))
        end
        return false, "NORMAL_MP_CLIENT_NON_FOOD_STAT_WRITE_FORBIDDEN"
    end
    return true, Authority.IsServer() and "SERVER_OR_HOST_AUTHORITY" or "SINGLEPLAYER_AUTHORITY"
end

function Authority.NotifyFoodDiscreteCost(player)
    if not Authority.IsAuthoritativeForStats(player) then
        return false, "NOT_AUTHORITATIVE"
    end
    stateFor(player).lastDiscreteCost = nowSeconds()
    return true, "RECORDED"
end

function Authority.IsFoodPulseBlockedByDiscreteCost(player, windowSeconds)
    if not player then
        return true
    end
    local state = stateFor(player)
    return nowSeconds() - (state.lastDiscreteCost or 0) < (windowSeconds or 1.0)
end

function Authority.ApplyDiscreteHungerCost(player, amount)
    if not Authority.IsAuthoritativeForStats(player) then
        return false, "NOT_AUTHORITATIVE"
    end
    if not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        return false, "NO_TRAIT"
    end
    if not Constants.IsFiniteNumber(amount) or amount <= 0 or amount > 0.055 then
        return false, "BAD_DISCRETE_HUNGER_COST"
    end
    local syncReady, _, hungerMask = serverSyncMasks()
    if not syncReady then
        return false, "SERVER_STAT_SYNC_UNAVAILABLE"
    end
    local stats = statsFor(player)
    local hunger = statGet(stats, CharacterStat and CharacterStat.HUNGER or nil, "getHunger")
    if not Constants.IsFiniteNumber(hunger) then
        return false, "STAT_READ_FAILED"
    end
    local nextHunger = Constants.Clamp(hunger + amount, 0.0, 1.0)
    if nextHunger <= hunger then
        return false, "HUNGER_CLAMPED"
    end
    if not statSet(stats, CharacterStat and CharacterStat.HUNGER or nil, "setHunger", nextHunger) then
        return false, "HUNGER_WRITE_FAILED"
    end
    if Authority.IsServer() and not pcall(syncPlayerStats, player, hungerMask) then
        statSet(stats, CharacterStat and CharacterStat.HUNGER or nil, "setHunger", hunger)
        pcall(syncPlayerStats, player, hungerMask)
        return false, "SERVER_STAT_SYNC_FAILED_ROLLED_BACK"
    end
    stateFor(player).lastDiscreteCost = nowSeconds()
    return true, "APPLIED", nextHunger - hunger
end

function Authority.ApplyFoodEnduranceTransfer(player, enduranceDelta, hungerDelta, target, reserveFloor)
    local allowed, reason = Authority.ValidateFoodWritePath()
    if not allowed then
        return false, reason
    end
    if not Constants.IsFiniteNumber(enduranceDelta) or not Constants.IsFiniteNumber(hungerDelta) then
        return false, "BAD_DELTA"
    end
    local syncReady, enduranceMask, hungerMask = serverSyncMasks()
    if not syncReady then
        return false, "SERVER_STAT_SYNC_UNAVAILABLE"
    end
    local stats = statsFor(player)
    local endurance = statGet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "getEndurance")
    local hunger = statGet(stats, CharacterStat and CharacterStat.HUNGER or nil, "getHunger")
    if not Constants.IsFiniteNumber(endurance) or not Constants.IsFiniteNumber(hunger) then
        return false, "STAT_READ_FAILED"
    end
    target = Constants.Clamp(target or 0.40, 0.01, 1.0)
    reserveFloor = Constants.Clamp(reserveFloor or 0.40, 0.40, 0.95)
    local nextEndurance = math.min(endurance + math.max(enduranceDelta, 0.0), target)
    local nextHunger = math.min(hunger + math.max(hungerDelta, 0.0), 1.0 - reserveFloor)
    local actualEndurance = math.max(nextEndurance - endurance, 0.0)
    local actualHunger = math.max(nextHunger - hunger, 0.0)
    if actualEndurance <= 0 or actualHunger <= 0 then
        return false, "CLAMPED_TO_ZERO"
    end
    if not statSet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "setEndurance", nextEndurance) then
        return false, "ENDURANCE_WRITE_FAILED"
    end
    if not statSet(stats, CharacterStat and CharacterStat.HUNGER or nil, "setHunger", nextHunger) then
        statSet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "setEndurance", endurance)
        return false, "HUNGER_WRITE_FAILED"
    end
    if not syncServerStats(player, enduranceMask, hungerMask) then
        statSet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "setEndurance", endurance)
        statSet(stats, CharacterStat and CharacterStat.HUNGER or nil, "setHunger", hunger)
        syncServerStats(player, enduranceMask, hungerMask)
        return false, "SERVER_STAT_SYNC_FAILED_ROLLED_BACK"
    end
    return true, "APPLIED", actualEndurance, actualHunger, nextEndurance, 1.0 - nextHunger
end

function Authority.ApplyTieredFoodPulse(player, enduranceGain, foodCost, reserveFloor)
    local allowed, reason = Authority.ValidateFoodWritePath()
    if not allowed then
        return false, reason
    end
    if not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        return false, "NO_TRAIT"
    end
    if not Constants.IsFiniteNumber(enduranceGain) or not Constants.IsFiniteNumber(foodCost)
        or enduranceGain <= 0 or foodCost <= 0 then
        return false, "BAD_TIERED_PULSE"
    end
    local syncReady, enduranceMask, hungerMask = serverSyncMasks()
    if not syncReady then
        return false, "SERVER_STAT_SYNC_UNAVAILABLE"
    end
    local stats = statsFor(player)
    local endurance = statGet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "getEndurance")
    local hunger = statGet(stats, CharacterStat and CharacterStat.HUNGER or nil, "getHunger")
    if not Constants.IsFiniteNumber(endurance) or not Constants.IsFiniteNumber(hunger) then
        return false, "STAT_READ_FAILED"
    end
    reserveFloor = Constants.Clamp(reserveFloor or 0.40, 0.40, 0.95)
    local reserve = Constants.Clamp(1.0 - hunger, 0.0, 1.0)
    local availableFood = math.max(0.0, reserve - reserveFloor)
    local availableEndurance = math.max(0.0, 1.0 - endurance)
    if availableFood <= 0 or availableEndurance <= 0 then
        return false, "NO_TIERED_CAPACITY"
    end
    local scaleByFood = availableFood / foodCost
    local scaleByEndurance = availableEndurance / enduranceGain
    local scale = math.min(1.0, scaleByFood, scaleByEndurance)
    if scale <= 0 then
        return false, "PULSE_SCALE_ZERO"
    end
    local actualEndurance = enduranceGain * scale
    local actualHunger = foodCost * scale
    local nextEndurance = math.min(1.0, endurance + actualEndurance)
    local nextHunger = math.min(1.0 - reserveFloor, hunger + actualHunger)
    actualEndurance = math.max(0.0, nextEndurance - endurance)
    actualHunger = math.max(0.0, nextHunger - hunger)
    if actualEndurance <= 0 or actualHunger <= 0 then
        return false, "CLAMPED_TO_ZERO"
    end
    if not statSet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "setEndurance", nextEndurance) then
        return false, "ENDURANCE_WRITE_FAILED"
    end
    if not statSet(stats, CharacterStat and CharacterStat.HUNGER or nil, "setHunger", nextHunger) then
        statSet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "setEndurance", endurance)
        return false, "HUNGER_WRITE_FAILED"
    end
    if not syncServerStats(player, enduranceMask, hungerMask) then
        statSet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "setEndurance", endurance)
        statSet(stats, CharacterStat and CharacterStat.HUNGER or nil, "setHunger", hunger)
        syncServerStats(player, enduranceMask, hungerMask)
        return false, "SERVER_STAT_SYNC_FAILED_ROLLED_BACK"
    end
    return true, "APPLIED", actualEndurance, actualHunger, nextEndurance, 1.0 - nextHunger
end

function Authority.ProcessFoodTick(player)
    if not Authority.IsAuthoritativeForStats(player) then
        return false, "NOT_AUTHORITATIVE"
    end
    if not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        return false, "NO_TRAIT"
    end
    if Config.ENABLE_LOW_ENDURANCE_FOOD_CONVERSION ~= true then
        return false, "DISABLED"
    end
    local stats = statsFor(player)
    local endurance = statGet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "getEndurance")
    local hunger = statGet(stats, CharacterStat and CharacterStat.HUNGER or nil, "getHunger")
    if not Constants.IsFiniteNumber(endurance) or not Constants.IsFiniteNumber(hunger) then
        return false, "STAT_READ_FAILED"
    end
    local trigger = Constants.Clamp(Config.LOW_ENDURANCE_FOOD_CONVERSION_TRIGGER or 0.30, 0.01, 0.98)
    local target = Constants.Clamp(Config.LOW_ENDURANCE_FOOD_CONVERSION_TARGET or 0.40, trigger + 0.01, 1.0)
    local reserveFloor = Constants.Clamp(Config.LOW_ENDURANCE_FOOD_CONVERSION_MIN_RESERVE or 0.40, 0.40, 0.95)
    local ratio = math.max(Config.LOW_ENDURANCE_FOOD_CONVERSION_RATIO or 1.0, 0.01)
    local rate = math.max(Config.LOW_ENDURANCE_FOOD_CONVERSION_RATE or 0.01, 0.0001)
    local reserve = Constants.Clamp(1.0 - hunger, 0.0, 1.0)
    local state = stateFor(player)
    local now = nowSeconds()
    if now - state.lastDiscreteCost < (Config.LOW_ENDURANCE_FOOD_CONVERSION_DISCRETE_COST_DELAY or 1.0) then
        return false, "DISCRETE_COST_DELAY"
    end
    if endurance < trigger then
        state.active = true
    elseif endurance >= target then
        state.active = false
    end
    if not state.active then
        state.lastTick = now
        return false, "NOT_ACTIVE"
    end
    if reserve <= reserveFloor then
        state.active = false
        state.lastTick = now
        return false, "RESERVE_FLOOR"
    end
    if state.lastTick == 0 then
        state.lastTick = now
        return false, "ARMED"
    end
    local elapsed = now - state.lastTick
    if elapsed < (Config.LOW_ENDURANCE_FOOD_CONVERSION_TICK_SECONDS or 1.0) then
        return false, "NOT_DUE"
    end
    state.lastTick = now
    local seconds = math.min(elapsed, Config.LOW_ENDURANCE_FOOD_CONVERSION_MAX_CATCHUP_SECONDS or 2.0)
    local enduranceDelta = math.min(rate * seconds, target - endurance, (reserve - reserveFloor) * ratio)
    if enduranceDelta <= 0 then
        return false, "NO_TRANSFER_CAPACITY"
    end
    return Authority.ApplyFoodEnduranceTransfer(player, enduranceDelta, enduranceDelta / ratio, target, reserveFloor)
end

Core.Authority = Authority
return Authority
