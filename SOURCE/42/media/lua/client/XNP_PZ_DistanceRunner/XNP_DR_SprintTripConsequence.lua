require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_ZombieVehicleImpact"
require "XNP_PZ_DistanceRunner/XNP_DR_MinorScrapeCost"
require "XNP_PZ_DistanceRunner/XNP_DR_CostTuning"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local SprintTripConsequence = {}
XNP_DR_SprintTripConsequence = SprintTripConsequence

local function safeZombie(obj)
    if not obj or type(instanceof) ~= "function" or not instanceof(obj, "IsoZombie") then
        return false
    end
    if type(obj.isDead) == "function" then
        local ok, dead = pcall(function()
            return obj:isDead()
        end)
        if ok and dead then
            return false
        end
    end
    return true
end

local function forward(player)
    if player and type(player.getForwardDirection) == "function" then
        local ok, v = pcall(function()
            return player:getForwardDirection()
        end)
        if ok and v then
            local x = type(v.getX) == "function" and v:getX() or v.x
            local y = type(v.getY) == "function" and v:getY() or v.y
            if type(x) == "number" and type(y) == "number" then
                local len = math.sqrt(x * x + y * y)
                if len > 0.0001 then
                    return x / len, y / len
                end
            end
        end
    end
    return nil, nil
end

local function targetKey(zombie)
    if Core.ImpactQuotaMeter and Core.ImpactQuotaMeter.TargetKey then
        return Core.ImpactQuotaMeter.TargetKey(zombie)
    end
    return zombie and tostring(zombie) or "nil"
end

local function collectTargets(player)
    local result = {}
    if not player or not Core.ThreatSnapshot then
        return result
    end
    local px = player:getX()
    local py = player:getY()
    local fx, fy = forward(player)
    local scanRadius = math.min(Config.CANDIDATE_SCAN_RADIUS_MAX or 1.65, 1.65)
    local radius = math.min(Config.SPRINT_TRIP_EFFECT_RADIUS or Config.SPRINT_TRIP_CONSEQUENCE_RADIUS or 1.35, 1.35)
    print("[XNP RADIUS] mode=SPRINT_TRIP_CONSEQUENCE scan_radius=" .. string.format("%.2f", scanRadius) .. " effect_radius=" .. string.format("%.2f", radius))
    print("[XNP RADIUS] large_scan_no_effect=true")
    local zombies = Core.ThreatSnapshot.GetNearbyZombies(scanRadius)
    for i = 1, #zombies do
        local zombie = zombies[i]
        if safeZombie(zombie) and type(zombie.getX) == "function" and type(zombie.getY) == "function" then
            local dx = zombie:getX() - px
            local dy = zombie:getY() - py
            local dist = math.sqrt(dx * dx + dy * dy)
            local dot = 1
            if fx and fy and dist > 0.001 then dot = (dx / dist) * fx + (dy / dist) * fy end
            if dist <= radius and (dist <= 0.85 or dot >= 0.15) then
                result[#result + 1] = { zombie = zombie, key = targetKey(zombie), dist = dist, dot = dot }
            end
        end
    end
    return result
end

function SprintTripConsequence.Apply(player, context)
    if Config.SPRINT_TRIP_CONSEQUENCE_ENABLED ~= true then
        return false
    end
    print("[XNP SPRINT TRIP CONSEQUENCE] trigger source=NATIVE_TRIP_WINDOW")
    local targets = collectTargets(player)
    local killMax = math.min(Config.SPRINT_TRIP_KILL_MAX or 3, 3)
    print("[XNP SPRINT TRIP CONSEQUENCE] targets=" .. tostring(#targets) .. " kill_max=" .. tostring(killMax) .. " radius=" .. tostring(math.min(Config.SPRINT_TRIP_EFFECT_RADIUS or 1.35, 1.35)))
    local killed = 0
    local stunned = 0
    for i, target in ipairs(targets) do
        if killed < killMax then
            local ok = Core.ZombieVehicleImpact and Core.ZombieVehicleImpact.ApplyVehicleDeath(player, target.zombie, { triggerId = "SPRINT_NATIVE_TRIP" })
            if ok then
                killed = killed + 1
                print("[XNP SPRINT TRIP CONSEQUENCE] zombie=" .. tostring(target.key) .. " result=KILLED index=" .. tostring(killed) .. "/" .. tostring(killMax))
            else
                if Core.VerifiedStaggerControl then
                    Core.VerifiedStaggerControl.Apply(player, target.zombie, "SPRINT_PRECOLLISION", { triggerId = "SPRINT_NATIVE_TRIP_FALLBACK" })
                end
                stunned = stunned + 1
                print("[XNP SPRINT TRIP CONSEQUENCE] zombie=" .. tostring(target.key) .. " result=KNOCKDOWN_STUN reason=DEATH_FALLBACK")
            end
        else
            if Core.VerifiedStaggerControl then
                Core.VerifiedStaggerControl.Apply(player, target.zombie, "SPRINT_PRECOLLISION", { triggerId = "SPRINT_NATIVE_TRIP_REST" })
            end
            stunned = stunned + 1
            print("[XNP SPRINT TRIP CONSEQUENCE] zombie=" .. tostring(target.key) .. " result=KNOCKDOWN_STUN reason=KILL_CAP_REACHED")
        end
    end
    if Core.MinorScrapeCost then
        if Core.CostTuning and Core.CostTuning.ComputeFinalCost then
            Core.CostTuning.ComputeFinalCost("NATIVE_TRIP", 0.0)
        end
        Core.MinorScrapeCost.Apply(player, Config.SPRINT_TRIP_SCRAPE_SOURCE or "SPRINT_NATIVE_TRIP")
    end
    print("[XNP SPRINT TRIP CONSEQUENCE] kill_count=" .. tostring(killed) .. " knockdown_stun_count=" .. tostring(stunned))
    return true
end

Core.SprintTripConsequence = SprintTripConsequence
return SprintTripConsequence
