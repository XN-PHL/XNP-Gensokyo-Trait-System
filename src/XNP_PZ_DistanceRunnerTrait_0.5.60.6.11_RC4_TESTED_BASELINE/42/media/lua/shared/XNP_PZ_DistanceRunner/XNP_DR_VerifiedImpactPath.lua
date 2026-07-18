require "XNP_PZ_DistanceRunner/XNP_DR_Config"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config

local Verified = {
    ID = "VERIFIED_IMPACT_PATH",
}

function Verified.EvaluateSprintPrecollision(distance, dot, closingFrames, speed, isSprinting)
    if distance < Config.PRECOLLISION_MIN_DISTANCE or distance > Config.PRECOLLISION_MAX_DISTANCE then
        return false, "DISTANCE"
    end
    if dot < Config.PRECOLLISION_FRONT_DOT_MIN then
        return false, "DOT"
    end
    if closingFrames < Config.PRECOLLISION_REQUIRED_CLOSING_FRAMES then
        return false, "NOT_CLOSING"
    end
    if isSprinting ~= true and speed < Config.PRECOLLISION_SPRINT_MIN_SPEED then
        return false, "SPEED"
    end
    return speed >= Config.PRECOLLISION_SPRINT_MIN_SPEED, "VERIFIED_SPRINT_PRECOLLISION"
end

function Verified.EvaluateSprintVehicle(distance, dot, closingFrames)
    if distance < Config.SPRINT_VEHICLE_DIST_MIN or distance > Config.SPRINT_VEHICLE_DIST_MAX then
        return false, "DISTANCE"
    end
    if dot < Config.SPRINT_VEHICLE_DOT_MIN then
        return false, "DOT"
    end
    if closingFrames < Config.SPRINT_VEHICLE_CLOSING_FRAMES then
        return false, "NOT_CLOSING"
    end
    return true, "VERIFIED_SPRINT_VEHICLE"
end

function Verified.SelectVehicleMode(targetCount, quotaAccepted)
    if targetCount >= Config.SPRINT_VEHICLE_WALL_COUNT or quotaAccepted ~= true then
        return "WALL_CRASH"
    end
    return "LIGHT"
end

function Verified.InsertVehicleCandidate(result, candidate)
    local inserted = false
    for i = 1, #result do
        local other = result[i]
        if candidate.dot > other.dot or (candidate.dot == other.dot and candidate.dist < other.dist) then
            table.insert(result, i, candidate)
            inserted = true
            break
        end
    end
    if not inserted then
        result[#result + 1] = candidate
    end
end

Core.VerifiedImpactPath = Verified
return Verified
