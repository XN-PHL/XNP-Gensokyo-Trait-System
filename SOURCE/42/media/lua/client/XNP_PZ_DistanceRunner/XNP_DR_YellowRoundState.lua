require "XNP_PZ_DistanceRunner/XNP_DR_YellowToggle"
require "XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState"
require "XNP_PZ_DistanceRunner/XNP_DR_YellowRedSignals"

local Core = XNP_PZ_DistanceRunner

local YellowRoundState = {}

local BAND_TO_COLOR = {
    GREEN_READY = "GREEN",
    BLUE_STAMINA_SUPPORT = "BLUE",
    YELLOW_LOW_STAMINA_SUPPORT = "YELLOW",
    RED_EXHAUSTED_SUPPORT = "YELLOW",
}

function YellowRoundState.Resolve(player)
    if Core.YellowToggle and Core.YellowToggle.IsEnabled
        and Core.YellowToggle.IsEnabled(player) ~= true then
        return "WHITE", "MANUAL_OFF"
    end

    local red, redReason = Core.YellowRedSignals.Resolve(player)
    if red then
        return "RED", redReason
    end

    local band = Core.EnduranceBandState and Core.EnduranceBandState.GetStableState
        and Core.EnduranceBandState.GetStableState(player) or nil
    local state = band and band.state or nil
    return BAND_TO_COLOR[state] or "GREEN", "ENDURANCE_BAND:" .. tostring(state or "FALLBACK_READY")
end

Core.YellowRoundState = YellowRoundState
return YellowRoundState
