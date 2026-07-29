require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"

local Core = XNP_PZ_DistanceRunner
local Feedback = {
    woundWriteCount = 0,
    infectionWriteCount = 0,
    sessions = 0,
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then
        return false, nil
    end
    return pcall(object[method], object, ...)
end

local function boolean(name, fallback)
    if Core.SandboxTuning and Core.SandboxTuning.GetBoolean then
        return Core.SandboxTuning.GetBoolean(name, fallback)
    end
    return fallback
end

local function number(name, fallback, minimum, maximum)
    if Core.SandboxTuning and Core.SandboxTuning.GetNumber then
        return Core.SandboxTuning.GetNumber(
            name, fallback, minimum, maximum)
    end
    return fallback
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function readProgress(action)
    if action and type(action.getJobDelta) == "function" then
        local ok, value = pcall(function() return action:getJobDelta() end)
        if ok and tonumber(value) then
            return clamp(tonumber(value), 0, 1)
        end
    end
    return 0
end

local function readFatigue(player)
    local statsOk, stats = invoke(player, "getStats")
    if not statsOk or not stats or not CharacterStat
        or not CharacterStat.FATIGUE then return nil, nil end
    local valueOk, value = invoke(stats, "get", CharacterStat.FATIGUE)
    if not valueOk or tonumber(value) == nil then return nil, nil end
    return stats, clamp(tonumber(value), 0, 1)
end

function Feedback.Begin(action, player)
    local bodyOk, body = invoke(player, "getBodyDamage")
    local wetOk, wetness = false, nil
    local tempOk, temperature = false, nil
    if bodyOk and body then
        wetOk, wetness = invoke(body, "getWetness")
        tempOk, temperature = invoke(body, "getTemperature")
    end
    local _, fatigue = readFatigue(player)
    action.xnpRedFeedback = {
        body = bodyOk and body or nil,
        initialWetness = wetOk and tonumber(wetness) or nil,
        initialTemperature = tempOk and tonumber(temperature) or nil,
        initialFatigue = fatigue,
        appliedProgress = 0,
        fatigueSettled = false,
    }
    Feedback.sessions = Feedback.sessions + 1
end

function Feedback.Update(action, player)
    local state = action and action.xnpRedFeedback
    if not state then return false, "SESSION_MISSING" end
    local progress = readProgress(action)
    if progress <= state.appliedProgress then
        return true, "NO_PROGRESS_DELTA"
    end
    state.appliedProgress = progress
    local intensity = math.floor(number(
        "RedCraftSweatIntensity", 2, 1, 3) + 0.5)
    local sweatMaximum = ({ 0.015, 0.030, 0.050 })[intensity] or 0.030
    if boolean("RedCraftSweatEnabled", true)
        and state.body and state.initialWetness ~= nil then
        local target = clamp(
            state.initialWetness + sweatMaximum * progress, 0, 1)
        invoke(state.body, "setWetness", target)
    end
    if boolean("RedCraftBodyHeatEnabled", true)
        and state.body and state.initialTemperature ~= nil then
        local target = clamp(
            state.initialTemperature + 0.12 * progress, 20, 42)
        invoke(state.body, "setTemperature", target)
    end
    if boolean("RedCraftExertionFeedbackEnabled", true)
        and player and type(player.setMetabolicTarget) == "function"
        and Metabolics and Metabolics.LightWork then
        invoke(player, "setMetabolicTarget", Metabolics.LightWork)
    end
    return true, "PROGRESS_APPLIED"
end

function Feedback.Settle(action, player, completed)
    local state = action and action.xnpRedFeedback
    if not state or state.fatigueSettled then
        return false, "ALREADY_SETTLED_OR_MISSING"
    end
    Feedback.Update(action, player)
    state.fatigueSettled = true
    local progress = completed == true and 1
        or clamp(state.appliedProgress or readProgress(action), 0, 1)
    local stats, current = readFatigue(player)
    local percent = number(
        "RedCraftFatigueCostPercent", 10, 0, 100)
    local requested = (percent / 100) * progress
    local after = current
    local written = false
    if stats and current ~= nil then
        after = clamp(current + requested, 0, 1)
        written = invoke(
            stats, "set", CharacterStat.FATIGUE, after) == true
    end
    print("[XNP RED CRAFT FEEDBACK]"
        .. " completed=" .. tostring(completed == true)
        .. " progress=" .. tostring(progress)
        .. " sweat_enabled="
        .. tostring(boolean("RedCraftSweatEnabled", true))
        .. " sweat_intensity="
        .. tostring(number("RedCraftSweatIntensity", 2, 1, 3))
        .. " body_heat_enabled="
        .. tostring(boolean("RedCraftBodyHeatEnabled", true))
        .. " fatigue_before=" .. tostring(current)
        .. " fatigue_requested=" .. tostring(requested)
        .. " fatigue_after=" .. tostring(after)
        .. " fatigue_write=" .. tostring(written)
        .. " wound_writes=0 infection_writes=0 bounded=true")
    return written, written and "SETTLED" or "FATIGUE_API_UNAVAILABLE"
end

function Feedback.GetAuditSnapshot()
    return {
        reachable = true,
        session_count = Feedback.sessions,
        wound_write_count = Feedback.woundWriteCount,
        infection_write_count = Feedback.infectionWriteCount,
        bounded_progress_targets = true,
        cancellation_cost_is_progress_proportional = true,
    }
end

Core.RedCraftFeedback = Feedback
return Feedback
