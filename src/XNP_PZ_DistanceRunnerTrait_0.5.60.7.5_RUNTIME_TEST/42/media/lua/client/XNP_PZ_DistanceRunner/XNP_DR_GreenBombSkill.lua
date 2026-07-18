XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local DisabledLegacyRoute = {}

function DisabledLegacyRoute.RequestActivate(player, source)
    return false, "LEGACY_GREEN_BOMB_ROUTE_DISABLED_0.5.60.6"
end

function DisabledLegacyRoute.Cleanup(player, reason)
    return true
end

XNP_PZ_DistanceRunner.GreenBombSkill = DisabledLegacyRoute
return DisabledLegacyRoute
