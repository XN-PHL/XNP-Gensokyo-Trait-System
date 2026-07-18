require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local CentralWorldQuery = {
    frame = -1,
    builtThisFrame = false,
    threatEntries = {},
    threatZombies = {},
    impactCandidates = {},
    environment = {},
    rawCount = 0,
    uniqueObjectCount = 0,
    duplicateCount = 0,
    startupLogged = false,
}

local function safeCall(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function() return obj[method](obj) end)
        if ok then return value end
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

local function isLiveZombie(obj)
    if not obj then return false end
    if type(instanceof) == "function" then
        local ok, zombie = pcall(function() return instanceof(obj, "IsoZombie") end)
        if not ok or zombie ~= true then return false end
    elseif type(obj.isZombie) ~= "function" or safeBool(obj, "isZombie") ~= true then
        return false
    end
    return not safeBool(obj, "isDead") and not safeBool(obj, "isFakeDead")
end

local function insertNearest(entries, entry, cap)
    local index = #entries + 1
    for i = 1, #entries do
        if entry.distSq < entries[i].distSq then
            index = i
            break
        end
    end
    if index <= cap then
        table.insert(entries, index, entry)
        if #entries > cap then table.remove(entries) end
    end
end

local function logStartupOnce()
    if CentralWorldQuery.startupLogged then return end
    CentralWorldQuery.startupLogged = true
    if Core.LogThrottle then
        Core.LogThrottle.Event("[XNP CENTRAL WORLD QUERY] enabled=true direct_world_scan_owner=XNP_DR_CentralWorldQuery")
        Core.LogThrottle.Event("[XNP CENTRAL WORLD QUERY] frame_contract=ONE_BUILD_PER_PLAYER_FRAME threat_cap=16 impact_radius=2.05")
        Core.LogThrottle.Event("[XNP CENTRAL WORLD QUERY] loaded_zombie_list_used=false")
    end
end

function CentralWorldQuery.BuildPlayerFrame(player, frame)
    logStartupOnce()
    frame = tonumber(frame) or -1
    if CentralWorldQuery.frame == frame and CentralWorldQuery.builtThisFrame then
        return true, "ALREADY_BUILT_THIS_FRAME"
    end

    CentralWorldQuery.frame = frame
    CentralWorldQuery.builtThisFrame = true
    CentralWorldQuery.threatEntries = {}
    CentralWorldQuery.threatZombies = {}
    CentralWorldQuery.impactCandidates = {}
    CentralWorldQuery.environment = {}
    CentralWorldQuery.rawCount = 0
    CentralWorldQuery.uniqueObjectCount = 0
    CentralWorldQuery.duplicateCount = 0

    if not player then
        return false, "NO_PLAYER"
    end

    local px = number(player, "getX")
    local py = number(player, "getY")
    local pz = number(player, "getZ")
    local cell = safeCall(player, "getCell")
    if not cell and type(getCell) == "function" then
        local okCell, globalCell = pcall(getCell)
        if okCell then cell = globalCell end
    end
    if not cell or type(cell.getGridSquare) ~= "function" then
        return false, "LOCAL_CELL_UNAVAILABLE"
    end

    local threatRadius = math.max(3.5, Config.DRAGDOWN_CRITICAL_RADIUS or 1.75)
    local impactRadius = math.max(Config.PRECOLLISION_SCAN_RADIUS or 2.05, Config.SPRINT_VEHICLE_DIST_MAX or 1.80)
    local radius = math.max(threatRadius, impactRadius)
    local cap = math.min(math.max(tonumber(Config.PERFORMANCE_MAX_NEARBY_CANDIDATES) or 16, 1), 16)
    local seen = {}
    local uniqueObjects = {}
    local raw = 0
    local duplicates = 0
    local z = math.floor(pz + 0.5)

    for sx = math.floor(px - radius), math.floor(px + radius) do
        for sy = math.floor(py - radius), math.floor(py + radius) do
            local okSquare, square = pcall(function()
                return cell:getGridSquare(sx, sy, z)
            end)
            local moving = okSquare and square and type(square.getMovingObjects) == "function" and square:getMovingObjects() or nil
            local size = moving and type(moving.size) == "function" and moving:size() or 0
            for i = 0, size - 1 do
                local obj = moving:get(i)
                if obj then
                    raw = raw + 1
                    if seen[obj] then
                        duplicates = duplicates + 1
                    else
                        seen[obj] = true
                        uniqueObjects[#uniqueObjects + 1] = obj
                    end
                end
            end
        end
    end

    local maxThreatDistSq = threatRadius * threatRadius
    local maxImpactDistSq = impactRadius * impactRadius
    local threatEntries = {}
    local threatZombies = {}
    local impactCandidates = {}

    for i = 1, #uniqueObjects do
        local obj = uniqueObjects[i]
        if isLiveZombie(obj) then
            local zx = number(obj, "getX")
            local zy = number(obj, "getY")
            local dx = zx - px
            local dy = zy - py
            local distSq = dx * dx + dy * dy
            if distSq <= maxImpactDistSq then
                impactCandidates[#impactCandidates + 1] = obj
            end
            if distSq <= maxThreatDistSq then
                insertNearest(threatEntries, {
                    zombie = obj,
                    dx = dx,
                    dy = dy,
                    distSq = distSq,
                    distance = math.sqrt(distSq),
                }, cap)
            end
        end
    end
    for i = 1, #threatEntries do
        threatZombies[i] = threatEntries[i].zombie
    end

    CentralWorldQuery.threatEntries = threatEntries
    CentralWorldQuery.threatZombies = threatZombies
    CentralWorldQuery.impactCandidates = impactCandidates
    CentralWorldQuery.environment = {
        x = px,
        y = py,
        z = pz,
        frame = frame,
        threatRadius = threatRadius,
        impactRadius = impactRadius,
    }
    CentralWorldQuery.rawCount = raw
    CentralWorldQuery.uniqueObjectCount = #uniqueObjects
    CentralWorldQuery.duplicateCount = duplicates
    return true, "BUILT"
end

function CentralWorldQuery.GetThreatCandidates()
    return CentralWorldQuery.threatEntries
end

function CentralWorldQuery.GetImpactCandidates()
    return CentralWorldQuery.impactCandidates
end

function CentralWorldQuery.GetPlayerEnvironment()
    return CentralWorldQuery.environment
end

function CentralWorldQuery.GetFrame()
    return CentralWorldQuery.frame
end

function CentralWorldQuery.Clear()
    CentralWorldQuery.frame = -1
    CentralWorldQuery.builtThisFrame = false
    CentralWorldQuery.threatEntries = {}
    CentralWorldQuery.threatZombies = {}
    CentralWorldQuery.impactCandidates = {}
    CentralWorldQuery.environment = {}
end

Core.CentralWorldQuery = CentralWorldQuery
return CentralWorldQuery
