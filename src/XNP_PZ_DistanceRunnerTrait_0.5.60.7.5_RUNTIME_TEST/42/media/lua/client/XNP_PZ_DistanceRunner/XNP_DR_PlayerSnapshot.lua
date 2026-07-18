require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_CentralWorldQuery"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants

local Snapshot = {
    current = {
        frame = 0,
        nearbyZombies = {},
        threatEntries = {},
        nearbyZombieCount = 0,
        threatRefreshedAt = 0,
    },
    forceRefresh = false,
    forceReason = nil,
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function safeCall(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function()
            return obj[method](obj)
        end)
        if ok then
            return value
        end
    end
    return nil
end

local function safeBool(obj, method)
    return safeCall(obj, method) == true
end

local function number(obj, method)
    local value = safeCall(obj, method)
    return Constants.IsFiniteNumber(value) and value or 0
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
    return safeCall(stats, getter)
end

local function movementText(player)
    local action = safeCall(player, "getActionStateName") or safeCall(player, "getCurrentActionContext") or ""
    local animation = safeCall(player, "getAnimationStateName") or action
    return string.lower(tostring(action) .. " " .. tostring(animation)), tostring(action), tostring(animation)
end

function Snapshot.RefreshLight(player)
    local current = Snapshot.current
    local now = nowSeconds()
    local x = number(player, "getX")
    local y = number(player, "getY")
    local speed = 0
    if Constants.IsFiniteNumber(current.x) and Constants.IsFiniteNumber(current.y) and Constants.IsFiniteNumber(current.time) and now > current.time then
        local dx = x - current.x
        local dy = y - current.y
        speed = math.sqrt(dx * dx + dy * dy) / math.max(now - current.time, 0.001)
    end
    local stats = safeCall(player, "getStats")
    local text, action, animation = movementText(player)
    current.frame = current.frame + 1
    current.time = now
    current.x = x
    current.y = y
    current.z = number(player, "getZ")
    current.endurance = statGet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "getEndurance") or 0
    current.hunger = statGet(stats, CharacterStat and CharacterStat.HUNGER or nil, "getHunger") or 0
    current.foodReserve = Constants.Clamp(1.0 - current.hunger, 0.0, 1.0)
    current.isRunning = safeBool(player, "isRunning")
    current.isSprinting = safeBool(player, "isSprinting")
    current.isMoving = safeBool(player, "isPlayerMoving") or current.isRunning or current.isSprinting or speed > 0.05
    current.onFloor = safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown")
    current.dead = safeBool(player, "isDead")
    current.vehicle = safeCall(player, "getVehicle") ~= nil
    current.actionState = action
    current.animationState = animation
    current.movementText = text
    current.speed = speed
    return current
end

function Snapshot.RefreshThreat(player)
    Snapshot.RefreshLight(player)
    local entries = Core.CentralWorldQuery and Core.CentralWorldQuery.GetThreatCandidates and Core.CentralWorldQuery.GetThreatCandidates() or {}
    local zombies = {}
    for i = 1, #entries do
        zombies[i] = entries[i].zombie
    end
    Snapshot.current.threatEntries = entries
    Snapshot.current.nearbyZombies = zombies
    Snapshot.current.nearbyZombieCount = #zombies
    Snapshot.current.threatRefreshedAt = nowSeconds()
    Snapshot.current.threatRefreshReason = Snapshot.forceReason
    Snapshot.forceRefresh = false
    Snapshot.forceReason = nil
    return Snapshot.current
end

function Snapshot.GetCurrent()
    return Snapshot.current
end

function Snapshot.GetThreatEntries(radius)
    local result = {}
    local radiusSq = (tonumber(radius) or 3.5) ^ 2
    for i = 1, #(Snapshot.current.threatEntries or {}) do
        local entry = Snapshot.current.threatEntries[i]
        if entry.distSq <= radiusSq then
            result[#result + 1] = entry
        end
    end
    return result
end

function Snapshot.GetNearbyZombies(radius)
    local result = {}
    local entries = Snapshot.GetThreatEntries(radius)
    for i = 1, #entries do
        result[i] = entries[i].zombie
    end
    return result
end

function Snapshot.GetNearestThreats(radius)
    return Snapshot.GetNearbyZombies(radius)
end

function Snapshot.GetEndurance()
    return Snapshot.current.endurance or 0
end

function Snapshot.GetFoodReserve()
    return Snapshot.current.foodReserve or 0
end

function Snapshot.GetMovementMode()
    if Snapshot.current.isSprinting then return "SPRINT" end
    if Snapshot.current.isRunning then return "RUN" end
    if Snapshot.current.isMoving then return "MOVE" end
    return "IDLE"
end

function Snapshot.GetDangerLevel()
    if Snapshot.current.onFloor then return "PLAYER_DOWN" end
    if (Snapshot.current.nearbyZombieCount or 0) > 0 then return "NEARBY_THREAT" end
    return "SAFE"
end

Core.PlayerSnapshot = Snapshot
Core.ThreatSnapshot = Snapshot
return Snapshot
