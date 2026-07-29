local Core = XNP_PZ_DistanceRunner
local MeleeMode = { multiplayerDisabledLogged = false }

local function flag(name)
    local fn = _G[name]
    if type(fn) ~= "function" then return false end
    local ok, value = pcall(fn)
    return ok and value == true
end

function MeleeMode.IsMultiplayerProcess()
    return flag("isClient") or flag("isServer")
end

function MeleeMode.LogDisabledInMultiplayer()
    if MeleeMode.multiplayerDisabledLogged or not MeleeMode.IsMultiplayerProcess() then
        return false
    end
    MeleeMode.multiplayerDisabledLogged = true
    print("[XNP MELEE POWER] disabled_in_multiplayer=true reason=NO_VERIFIED_SERVER_DAMAGE_EVENT")
    return true
end

Core.MeleeMode = MeleeMode
return MeleeMode
