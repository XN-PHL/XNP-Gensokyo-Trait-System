require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_SprintTripConsequence"
require "XNP_PZ_DistanceRunner/XNP_DR_JogFallShockwave"
require "XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local NativeTripWindow = {
    active = false,
    source = nil,
    reason = nil,
    untilTime = 0,
    consequenceDone = false,
}

XNP_DR_NativeTripWindow = NativeTripWindow

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function safeBool(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function()
            return obj[method](obj)
        end)
        return ok and value == true
    end
    return false
end

function NativeTripWindow.Open(player, source, reason)
    NativeTripWindow.active = true
    NativeTripWindow.source = source
    NativeTripWindow.reason = reason or "ZOMBIE_WALL_OR_QUOTA_OVERFLOW"
    NativeTripWindow.consequenceDone = false
    NativeTripWindow.untilTime = nowSeconds() + (Config.SPRINT_OVERFLOW_NATIVE_TRIP_WATCH_WINDOW or 0.90)
    if source == "JOG_OVERFLOW" then
        NativeTripWindow.untilTime = nowSeconds() + (Config.SPRINT_OVERFLOW_NATIVE_TRIP_WATCH_WINDOW or 0.90)
        Core.LogThrottle.Event("[XNP JOG NATIVE TRIP WINDOW] open")
    else
        Core.LogThrottle.Event("[XNP NATIVE TRIP WINDOW] open source=SPRINT_OVERFLOW reason=" .. tostring(NativeTripWindow.reason))
        print("[XNP NATIVE TRIP WINDOW] release_to_vanilla_collision=true")
        print("[XNP NATIVE TRIP WINDOW] sprint_trip_cancel_suppressed=true reason=NATIVE_TRIP_CHECK")
    end
    return true
end

function NativeTripWindow.IsActive()
    return NativeTripWindow.active == true and nowSeconds() <= NativeTripWindow.untilTime
end

function NativeTripWindow.IsTripCancelSuppressed()
    return NativeTripWindow.IsActive()
end

function NativeTripWindow.Update(player)
    if not NativeTripWindow.active then
        return false
    end
    local now = nowSeconds()
    local down = safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown")
    if down and not NativeTripWindow.consequenceDone then
        NativeTripWindow.consequenceDone = true
        if NativeTripWindow.source == "JOG_OVERFLOW" then
            print("[XNP JOG NATIVE TRIP WINDOW] outcome=PLAYER_TRIPPED")
            if Core.JogFallShockwave then
                Core.JogFallShockwave.Apply(player)
            end
            if Core.FallRecoveryInput then
                Core.FallRecoveryInput.Classify("JOG_OVERFLOW_TRIP")
            end
        else
            print("[XNP NATIVE TRIP WINDOW] outcome=PLAYER_TRIPPED state=ON_FLOOR")
            if Core.SprintTripConsequence then
                Core.SprintTripConsequence.Apply(player, { source = NativeTripWindow.source, reason = NativeTripWindow.reason })
            end
            if Core.FallRecoveryInput then
                Core.FallRecoveryInput.Classify("SPRINT_OVERFLOW_WALL_CRASH")
            end
        end
        NativeTripWindow.active = false
        return true
    end
    if now > NativeTripWindow.untilTime then
        if NativeTripWindow.source == "JOG_OVERFLOW" then
            print("[XNP JOG NATIVE TRIP WINDOW] outcome=PLAYER_STAYED_UP")
        else
            print("[XNP NATIVE TRIP WINDOW] outcome=PLAYER_STAYED_UP")
            print("[XNP NATIVE TRIP WINDOW] close reason=TIMEOUT_NO_TRIP")
        end
        NativeTripWindow.active = false
        return false
    end
    return false
end

function NativeTripWindow.Cleanup(reason)
    NativeTripWindow.active = false
end

Core.NativeTripWindow = NativeTripWindow
return NativeTripWindow
