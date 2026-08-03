XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Gate = {}

function Gate.IsDevelopmentPreset(value)
    return value == "DEVELOPMENT_TEST" or tonumber(value) == 2
end

function Gate.Evaluate(isTestChannel, developerToolsEnabled,
        generalGameplayPreset, rawFlag)
    return isTestChannel == true
        and developerToolsEnabled == true
        and Gate.IsDevelopmentPreset(generalGameplayPreset)
        and rawFlag == true
end

Core.DeveloperBypassGate = Gate
return Gate
