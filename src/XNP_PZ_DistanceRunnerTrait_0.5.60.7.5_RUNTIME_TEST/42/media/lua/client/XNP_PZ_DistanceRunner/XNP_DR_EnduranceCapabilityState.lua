require "XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState"

local Core = XNP_PZ_DistanceRunner
local EnduranceBandState = Core.EnduranceBandState

local EnduranceCapabilityState = {}

function EnduranceCapabilityState.GetEndurance(player)
    return EnduranceBandState.GetEndurance(player)
end

function EnduranceCapabilityState.ClassifyRaw(endurance)
    return EnduranceBandState.ClassifyRaw(endurance)
end

function EnduranceCapabilityState.ApplyHysteresis(previousState, endurance)
    return EnduranceBandState.ApplyHysteresis(previousState, endurance)
end

function EnduranceCapabilityState.CommitState(player, newState, reason)
    return EnduranceBandState.CommitState(player, newState, reason)
end

function EnduranceCapabilityState.GetStableState(player)
    return EnduranceBandState.GetStableState(player)
end

function EnduranceCapabilityState.RestorePreviousAfterOverride()
    return EnduranceBandState.RestorePreviousAfterOverride()
end

function EnduranceCapabilityState.Reset(player)
    return EnduranceBandState.Reset(player)
end

function EnduranceCapabilityState.IsValidState(state)
    return EnduranceBandState.IsValidState(state)
end

function EnduranceCapabilityState.CanSustainSprint(player, sample)
    return true
end

function EnduranceCapabilityState.CanSustainJog(player, sample)
    return true
end

Core.EnduranceCapabilityState = EnduranceCapabilityState
return EnduranceCapabilityState
