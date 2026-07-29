require "XNP_PZ_DistanceRunner/XNP_DR_MeleeMode"

local Guard = {}

function Guard.LogIfMultiplayer()
    return XNP_PZ_DistanceRunner.MeleeMode.LogDisabledInMultiplayer()
end

Guard.LogIfMultiplayer()
XNP_PZ_DistanceRunner.MeleeMultiplayerGuard = Guard
return Guard
