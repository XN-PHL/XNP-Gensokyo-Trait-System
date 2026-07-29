require "XNP_PZ_DistanceRunner/XNP_DR_MapVisibility"

local Core = XNP_PZ_DistanceRunner
local Visibility = {}

function Visibility.Update(force, playerIndex)
    return Core.MapVisibility.Update(force, playerIndex)
end

function Visibility.IsMapHidden(playerIndex)
    return Core.MapVisibility.IsMapHidden(playerIndex)
end

function Visibility.IsWorldGameplayVisible(playerIndex)
    return Core.MapVisibility.IsWorldGameplayVisible(playerIndex)
end

function Visibility.Cleanup(reason)
    return Core.MapVisibility.Cleanup(reason)
end

Core.RoundMarkerMapVisibility = Visibility
return Visibility
