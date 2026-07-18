require "XNP_PZ_DistanceRunner/XNP_DR_PlayerSnapshot"

local Core = XNP_PZ_DistanceRunner

local NearbyZombieCache = {}

function NearbyZombieCache.Update()
    return Core.PlayerSnapshot.GetNearbyZombies()
end

function NearbyZombieCache.GetNearby(player, radius)
    return Core.PlayerSnapshot.GetNearbyZombies(radius)
end


function NearbyZombieCache.Cleanup()
end

Core.NearbyZombieCache = NearbyZombieCache
return NearbyZombieCache
