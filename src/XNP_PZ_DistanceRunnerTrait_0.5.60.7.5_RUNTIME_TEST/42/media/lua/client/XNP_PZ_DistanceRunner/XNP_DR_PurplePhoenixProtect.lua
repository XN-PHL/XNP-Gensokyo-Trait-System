local Core = XNP_PZ_DistanceRunner

-- Compatibility shell only. WHITE and GREEN do not schedule zombie-control
-- pulses, damage negation, or any repeating protection in 0.5.60.1.
local Protect = {
    active = false,
    endAt = 0,
    nextPulseAt = 0,
    nextPulseLogAt = 0,
    pulseCount = 0,
    triggerId = 0,
}

function Protect.IsActive()
    return false
end

function Protect.GetRemainingSeconds()
    return 0
end

function Protect.DiscardTransient(reason)
    local hadState = Protect.active == true or Protect.endAt ~= 0 or Protect.nextPulseAt ~= 0 or Protect.triggerId ~= 0
    Protect.active = false
    Protect.endAt = 0
    Protect.nextPulseAt = 0
    Protect.nextPulseLogAt = 0
    Protect.pulseCount = 0
    Protect.triggerId = 0
    if hadState then
        print("[XNP PHOENIX MIGRATION] stale_protect_state_cleared=true reason=" .. tostring(reason or "RESET"))
    end
    return hadState
end

function Protect.Cleanup(player, reason)
    return Protect.DiscardTransient(reason or "CLEANUP")
end

Core.PurplePhoenixProtect = Protect
return Protect
