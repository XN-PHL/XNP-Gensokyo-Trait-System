require "XNP_PZ_DistanceRunner/XNP_DR_VehicleVerifiedEvaluator"

local Core = XNP_PZ_DistanceRunner

local SprintVehicleImpact = {}

function SprintVehicleImpact.Update(player)
    return false
end

function SprintVehicleImpact.SummaryTick()
end

Core.SprintVehicleImpact = SprintVehicleImpact
XNP_DR_SprintVehicleImpact = SprintVehicleImpact
return SprintVehicleImpact
