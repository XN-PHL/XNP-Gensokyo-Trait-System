require "XNP_PZ_DistanceRunner/XNP_DR_PhoenixTransaction"

local Core = XNP_PZ_DistanceRunner
local Revive = {}

function Revive.TryTrigger(player, source, sourceType, anticipatedDamage, options)
    options = options or {}
    local mapped = tostring(sourceType or "DAMAGE_THRESHOLD_EDGE")
    if mapped == "PROJECTILE" then mapped = "PROJECTILE_FATAL_EDGE"
    elseif mapped == "FALL" then mapped = "FALL_FATAL_EDGE"
    elseif mapped == "EXPLOSION" then mapped = "EXPLOSION_FATAL_EDGE"
    elseif mapped == "MELEE" then mapped = "MELEE_FATAL_EDGE" end
    return Core.PhoenixTransaction.TryPredeathIntercept(player, {
        sourceEvent = source,
        sourceType = mapped,
        anticipatedDamage = anticipatedDamage,
        preDamage = options.preDamage == true,
        allowAvoidDamage = options.allowAvoidDamage == true,
        damageScale = options.damageScale,
        transactionId = options.transactionId,
        forceFatalEdge = options.forceFatalEdge == true,
    })
end

function Revive.PreUpdate(player)
    if Core.PurplePhoenixDamageGuard
        and type(Core.PurplePhoenixDamageGuard.Update) == "function" then
        Core.PurplePhoenixDamageGuard.Update(player)
    end
    Core.PhoenixTransaction.Update(player)
    local fallTriggered, fallReason =
        Core.PhoenixTransaction.UpdateFallPredeathEdge(player)
    if fallTriggered then return true, fallReason end
    return Core.PhoenixTransaction.TryPredeathIntercept(player, {
        sourceEvent = "OnPlayerUpdateThresholdFallback",
        sourceType = "DAMAGE_THRESHOLD_EDGE",
        preDamage = false,
    })
end

function Revive.GetCooldownRemainingHours(player)
    local _, remaining = Core.PurplePhoenixState.GetRecharge(player)
    return remaining == math.huge and 0 or remaining
end

function Revive.GetState(player)
    local state = Core.PhoenixTransaction.GetState(player)
    if state == Core.PhoenixTransaction.STATE_READY_ENABLED_BLUE then
        return "READY", 0, 0
    end
    if state == Core.PhoenixTransaction.STATE_COOLDOWN_WHITE
        or state == Core.PhoenixTransaction.STATE_VERIFYING_SURVIVAL then
        local _, remaining = Core.PurplePhoenixState.GetRecharge(player)
        return "COOLDOWN", remaining, 0
    end
    if state == Core.PhoenixTransaction.STATE_READY_DISABLED_GREEN then
        return "READY_DISABLED", 0, 0
    end
    return "OFF", 0, 0
end

function Revive.CancelPendingForDeath(player, reason)
    return Core.PhoenixTransaction.OnDeath(player, reason)
end

function Revive.Cleanup(player, reason)
    return Core.PhoenixTransaction.Cleanup(player, reason)
end

Core.PurplePhoenixRevive = Revive
return Revive
