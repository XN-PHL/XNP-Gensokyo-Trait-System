require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local JogFallShockwave = {}
XNP_DR_JogFallShockwave = JogFallShockwave

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

function JogFallShockwave.Apply(player)
    if not player or not Core.ThreatSnapshot then
        return 0
    end
    local radius = Config.JOG_TRIP_SHOCKWAVE_RADIUS or Config.JOG_FALL_SHOCKWAVE_RADIUS or 1.25
    print("[XNP RADIUS] mode=JOG_FALL_SHOCKWAVE scan_radius=" .. tostring(radius) .. " effect_radius=" .. tostring(radius))
    local count = 0
    local visibleCount = 0
    local zombies = Core.ThreatSnapshot.GetNearbyZombies(radius)
    for i = 1, #zombies do
        local zombie = zombies[i]
        if safeZombie(zombie) then
            local controlType = "SPRINT_PRECOLLISION"
            if Core.ImpactQuotaMeter and Core.ImpactQuotaMeter.Try and not Core.ImpactQuotaMeter.Try("JOG_BUMP", zombie, Config.JOG_KNOCKDOWN_QUOTA or 3, Config.JOG_QUOTA_WINDOW or 1.00) then
                controlType = "CONTACT"
            end
            local visible = Core.VerifiedStaggerControl.Apply(player, zombie, controlType, { triggerId = "JOG_FALL_SHOCKWAVE" })
            if visible then visibleCount = visibleCount + 1 end
            count = count + 1
        end
    end
    if visibleCount > 0 then
        Core.YellowRedSignals.PulseImpact("JOG_FALL_SHOCKWAVE")
    end
    print("[XNP JOG FALL SHOCKWAVE] targets=" .. tostring(count) .. " radius=" .. tostring(radius) .. " effect=KNOCKDOWN_STUN no_kill=true")
    return count
end

Core.JogFallShockwave = JogFallShockwave
return JogFallShockwave
