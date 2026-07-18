require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner

local StaminaDrain = {
    startupLogged = false,
}

function StaminaDrain.Update(player)
    if not StaminaDrain.startupLogged then
        StaminaDrain.startupLogged = true
        print("[XNP STAMINA] legacy_ready_refund_disabled=true method=POST_DRAIN_REFUND_BY_ENDURANCE_BAND")
    end
    return true
end

function StaminaDrain.Cleanup(player, reason)
    return true
end

Core.StaminaDrain = StaminaDrain
return StaminaDrain
