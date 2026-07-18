require "XNP_PZ_DistanceRunner/XNP_DR_Constants"

local Core = XNP_PZ_DistanceRunner

local VanillaImpact = {
    status = "DISABLED_FOR_ICON_RECOVERY_DRAGDOWN_BREAKOUT",
}

function VanillaImpact.Update(player)
    return false
end

function VanillaImpact.Cleanup(reason)
    return true
end

Core.VanillaImpact = VanillaImpact
return VanillaImpact
