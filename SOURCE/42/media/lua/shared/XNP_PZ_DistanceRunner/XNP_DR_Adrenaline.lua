require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_VisualFeedback"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Adrenaline = {
    state = "READY",
    expireTime = 0,
    activeUntil = 0,
    lastScan = 0,
    failed = false,
    fatalLogged = false,
    lastLoggedState = nil,
    triggerPulse = 0,
    triggerDistance = nil,
    currentPlayer = nil,
    supportStartedLogged = false,
    adrenalineTotalSeconds = 0,
    lastTotalUpdate = 0,
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function playerIsDead(player)
    if player and type(player.isDead) == "function" then
        local ok, dead = pcall(function()
            return player:isDead()
        end)
        return ok and dead == true
    end
    return false
end

local function playerIsInVehicle(player)
    if player and type(player.getVehicle) == "function" then
        local ok, vehicle = pcall(function()
            return player:getVehicle()
        end)
        return ok and vehicle ~= nil
    end
    return false
end

local function logState(newState)
    if Adrenaline.lastLoggedState ~= newState then
        Adrenaline.lastLoggedState = newState
        print("[XNP ADRENALINE] state=" .. tostring(newState))
    end
end

local function setState(newState)
    local oldState = Adrenaline.state
    if Adrenaline.state ~= newState or Adrenaline.lastLoggedState == nil then
        Adrenaline.state = newState
        if newState == "ACTIVE" then
            Adrenaline.triggerPulse = 1.0
            if oldState == "READY" then
                Adrenaline.supportStartedLogged = false
                if Core.VisualFeedback then
                    Core.VisualFeedback.ShowOnce(Adrenaline.currentPlayer, "active", "XNP Runner")
                end
            end
        elseif newState == "READY" and oldState == "FADING" then
            if Core.VisualFeedback then
                Core.VisualFeedback.ShowOnce(Adrenaline.currentPlayer, "ready_recovered", "Runner Ready")
            end
            Adrenaline.adrenalineTotalSeconds = 0
            Adrenaline.lastTotalUpdate = 0
        end
        logState(newState)
    end
end

local function objectIsLiveZombie(obj)
    if not obj or not IsoZombie or not instanceof(obj, "IsoZombie") then
        return false
    end
    if type(obj.isDead) == "function" then
        local ok, dead = pcall(function()
            return obj:isDead()
        end)
        if ok and dead == true then
            return false
        end
    end
    if type(obj.isOnFloor) == "function" then
        local ok, onFloor = pcall(function()
            return obj:isOnFloor()
        end)
        if ok and onFloor == true then
            return false
        end
    end
    if type(obj.isZombieDead) == "function" then
        local ok, dead = pcall(function()
            return obj:isZombieDead()
        end)
        if ok and dead == true then
            return false
        end
    end
    return true
end

local function scanNearbyThreat(player)
    if not player or not Core.ThreatSnapshot then
        return false
    end
    local radius = Config.THREAT_TRIGGER_RADIUS
    local entries = Core.ThreatSnapshot.GetThreatEntries(radius)
    return #entries > 0, entries[1] and entries[1].distance or nil
end

function Adrenaline.Update(player)
    if Adrenaline.failed or not Config.ENABLE_MOD or not Constants.FEATURE.ADRENALINE then
        return false
    end
    Adrenaline.currentPlayer = player
    if not player or playerIsDead(player) or playerIsInVehicle(player) or not Core.Trait.PlayerHasTrait(player) then
        Adrenaline.Clear("inactive_player")
        return false
    end
    local current = nowSeconds()
    if Adrenaline.state == "ACTIVE" or Adrenaline.state == "FADING" then
        if Adrenaline.lastTotalUpdate > 0 then
            Adrenaline.adrenalineTotalSeconds = Adrenaline.adrenalineTotalSeconds + math.max(0, current - Adrenaline.lastTotalUpdate)
        end
        Adrenaline.lastTotalUpdate = current
    else
        Adrenaline.lastTotalUpdate = current
    end
    if current - Adrenaline.lastScan >= Config.THREAT_SCAN_INTERVAL then
        Adrenaline.lastScan = current
        local ok, hasThreat, distance = pcall(function()
            return scanNearbyThreat(player)
        end)
        if ok and hasThreat then
            Adrenaline.expireTime = current + Config.ADRENALINE_MEMORY_DURATION
            Adrenaline.activeUntil = current + Constants.ADRENALINE.ACTIVE_REFRESH
            Adrenaline.triggerDistance = distance
            setState("ACTIVE")
            if not Adrenaline.supportStartedLogged then
                Adrenaline.supportStartedLogged = true
                if Constants.IsFiniteNumber(distance) then
                    print("[XNP ADRENALINE] trigger_zombie_distance=" .. string.format("%.3f", distance))
                else
                    print("[XNP ADRENALINE] trigger_zombie_distance=unknown")
                end
            end
        elseif not ok and not Adrenaline.fatalLogged then
            Adrenaline.fatalLogged = true
            Adrenaline.failed = true
            print("[XNP ADRENALINE] fatal error=" .. tostring(hasThreat))
        end
    end
    if current < Adrenaline.activeUntil then
        setState("ACTIVE")
    elseif Adrenaline.expireTime > 0 and current < Adrenaline.expireTime then
        setState("FADING")
    else
        Adrenaline.expireTime = 0
        Adrenaline.activeUntil = 0
        setState("READY")
    end
    return true
end

function Adrenaline.GetState()
    return Adrenaline.state
end

function Adrenaline.GetRemainingSeconds()
    local remaining = Adrenaline.expireTime - nowSeconds()
    if remaining < 0 then
        return 0
    end
    return remaining
end

function Adrenaline.IsSupportingEndurance()
    return Adrenaline.state == "ACTIVE" or Adrenaline.state == "FADING"
end

function Adrenaline.ConsumePulse()
    local pulse = Adrenaline.triggerPulse
    Adrenaline.triggerPulse = 0
    return pulse
end

function Adrenaline.Clear(reason)
    Adrenaline.expireTime = 0
    Adrenaline.activeUntil = 0
    Adrenaline.triggerPulse = 0
    Adrenaline.triggerDistance = nil
    Adrenaline.supportStartedLogged = false
    Adrenaline.adrenalineTotalSeconds = 0
    Adrenaline.lastTotalUpdate = 0
    setState("READY")
end

Core.Adrenaline = Adrenaline
return Adrenaline
