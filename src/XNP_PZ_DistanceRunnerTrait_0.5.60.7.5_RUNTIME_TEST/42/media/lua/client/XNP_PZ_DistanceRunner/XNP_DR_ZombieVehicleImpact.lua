require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"

local Core = XNP_PZ_DistanceRunner

local ZombieVehicleImpact = {
    cooldown = {},
}

XNP_DR_ZombieVehicleImpact = ZombieVehicleImpact

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function key(zombie)
    if Core.BreakoutActionBus and Core.BreakoutActionBus.TargetKey then
        return Core.BreakoutActionBus.TargetKey(zombie)
    end
    return zombie and tostring(zombie) or "nil"
end

function ZombieVehicleImpact.RegisterVehicleHitCooldown(zombie)
    ZombieVehicleImpact.cooldown[key(zombie)] = nowSeconds()
end

function ZombieVehicleImpact.OnCooldown(zombie)
    local last = ZombieVehicleImpact.cooldown[key(zombie)]
    return last ~= nil and nowSeconds() - last < 0.30
end

function ZombieVehicleImpact.ApplyVehicleHit(player, zombie, context)
    if not zombie or ZombieVehicleImpact.OnCooldown(zombie) then
        return false, "COOLDOWN"
    end
    if Core.VerifiedStaggerControl then
        local visible = Core.VerifiedStaggerControl.Apply(player, zombie, "SPRINT_PRECOLLISION", context or {})
        if visible then
            Core.YellowRedSignals.PulseImpact("ZOMBIE_VEHICLE_IMPACT")
        end
    end
    ZombieVehicleImpact.RegisterVehicleHitCooldown(zombie)
    return true, "LAUNCH_KNOCKDOWN"
end

function ZombieVehicleImpact.ApplyVehicleDeath(player, zombie, context)
    local hitOk = ZombieVehicleImpact.ApplyVehicleHit(player, zombie, context)
    if not hitOk then
        return false, "COOLDOWN"
    end
    local method = "none"
    local ok = false
    if type(zombie.Kill) == "function" then
        ok = pcall(function()
            zombie:Kill(nil)
        end)
        method = "Kill"
    elseif type(zombie.setHealth) == "function" then
        ok = pcall(function()
            zombie:setHealth(0)
        end)
        method = "setHealth_zero"
    elseif type(zombie.DoDeath) == "function" then
        ok = pcall(function()
            zombie:DoDeath(nil)
        end)
        method = "DoDeath"
    end
    if ok then
        print("[XNP VEHICLE IMPACT ZOMBIE] death_result=ok method=" .. tostring(method))
        return true, method
    end
    print("[XNP VEHICLE IMPACT ZOMBIE] death_result=fallback_knockdown method=NO_SAFE_ZOMBIE_DEATH_API")
    return false, "fallback_knockdown"
end

Core.ZombieVehicleImpact = ZombieVehicleImpact
return ZombieVehicleImpact
