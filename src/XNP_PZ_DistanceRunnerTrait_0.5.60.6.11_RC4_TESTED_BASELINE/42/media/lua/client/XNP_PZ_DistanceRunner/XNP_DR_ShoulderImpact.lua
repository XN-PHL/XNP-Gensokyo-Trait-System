require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

local Core = XNP_PZ_DistanceRunner

local ShoulderImpact = {
    status = "DISABLED_FOR_ICON_RECOVERY_DRAGDOWN_BREAKOUT",
}

function ShoulderImpact.Update(player)
    return false
end

function ShoulderImpact.Cleanup(reason)
    return true
end

Core.ShoulderImpact = ShoulderImpact
return ShoulderImpact
