require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_StaminaTrendMeter"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local EnduranceBandState = {
    frame = 0,
    stableState = nil,
    previousStableState = nil,
    candidateState = nil,
    candidateFrames = 0,
    stateChangedThisTick = false,
    commitFrame = -1,
    lastCommitFrame = -1,
    lastEvalFrame = nil,
    lastLogKey = nil,
    lastSummaryFrame = 0,
    lastEndurance = nil,
    lastSample = nil,
}

local validStates = {
    GREEN_READY = true,
    BLUE_STAMINA_SUPPORT = true,
    YELLOW_LOW_STAMINA_SUPPORT = true,
    RED_EXHAUSTED_SUPPORT = true,
}

local rank = {
    GREEN_READY = 1,
    BLUE_STAMINA_SUPPORT = 2,
    YELLOW_LOW_STAMINA_SUPPORT = 3,
    RED_EXHAUSTED_SUPPORT = 4,
}

local function clamp(value, minValue, maxValue)
    return Constants.Clamp(value, minValue, maxValue)
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

local function safeString(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function()
            return obj[method](obj)
        end)
        if ok and value ~= nil then
            return tostring(value)
        end
    end
    return ""
end

local function getStats(player)
    if player and type(player.getStats) == "function" then
        local ok, stats = pcall(function()
            return player:getStats()
        end)
        if ok then
            return stats
        end
    end
    return nil
end

local function statGet(stats, stat, getter)
    if not stats then
        return nil
    end
    if stat ~= nil and type(stats.get) == "function" then
        local ok, value = pcall(function()
            return stats:get(stat)
        end)
        if ok and Constants.IsFiniteNumber(value) then
            return value
        end
    end
    if getter and type(stats[getter]) == "function" then
        local ok, value = pcall(function()
            return stats[getter](stats)
        end)
        if ok and Constants.IsFiniteNumber(value) then
            return value
        end
    end
    return nil
end

function EnduranceBandState.GetEndurance(player)
    local stats = getStats(player)
    return statGet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "getEndurance")
end

local function readMovement(player)
    return {
        isMoving = safeBool(player, "isPlayerMoving") or safeBool(player, "isRunning") or safeBool(player, "isSprinting"),
        isRunning = safeBool(player, "isRunning"),
        isSprinting = safeBool(player, "isSprinting"),
        onFloor = safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown"),
        action_state = safeString(player, "getCurrentActionContext"),
        animation_state = safeString(player, "getActionStateName"),
    }
end

local function transientAction(sample)
    if not sample then
        return false, "NONE"
    end
    if sample.onFloor == true then
        return true, "KNOCKED_DOWN"
    end
    local text = string.lower(tostring(sample.action_state or "") .. " " .. tostring(sample.animation_state or ""))
    local checks = {
        { "knock", "KNOCKED_DOWN" },
        { "fall", "KNOCKED_DOWN" },
        { "trip", "KNOCKED_DOWN" },
        { "getup", "GETUP" },
        { "get up", "GETUP" },
        { "bump", "BUMPED" },
        { "controlled", "CONTROLLED" },
    }
    for i = 1, #checks do
        if string.find(text, checks[i][1], 1, true) ~= nil then
            return true, checks[i][2]
        end
    end
    return false, "NONE"
end

function EnduranceBandState.ClassifyRaw(endurance)
    if not Constants.IsFiniteNumber(endurance) then
        return "RED_EXHAUSTED_SUPPORT"
    end
    endurance = clamp(endurance, 0.0, 1.0)
    if endurance >= (Config.endurance_green_exit or 0.86) then
        return "GREEN_READY"
    elseif endurance >= (Config.endurance_blue_lower or 0.70) then
        return "BLUE_STAMINA_SUPPORT"
    elseif endurance >= (Config.endurance_yellow_lower or 0.52) then
        return "YELLOW_LOW_STAMINA_SUPPORT"
    end
    return "RED_EXHAUSTED_SUPPORT"
end

function EnduranceBandState.ApplyHysteresis(previousState, endurance)
    local raw = EnduranceBandState.ClassifyRaw(endurance)
    if previousState == nil or previousState == raw then
        return raw, raw
    end
    if raw == "GREEN_READY" and endurance < (Config.endurance_green_enter or 0.90) then
        return previousState, raw
    end
    if previousState == "GREEN_READY" and endurance >= (Config.endurance_green_exit or 0.86) then
        return previousState, raw
    end
    return raw, raw
end

local function transitionDirection(fromState, toState)
    local fromRank = rank[fromState] or 1
    local toRank = rank[toState] or 1
    if toRank > fromRank then
        return "DOWNGRADE"
    elseif toRank < fromRank then
        return "UPGRADE"
    end
    return "SAME"
end

local function logBand(endurance, raw)
    local key = tostring(raw) .. "|" .. tostring(math.floor((endurance or -1) * 1000))
    if key == EnduranceBandState.lastLogKey then
        return
    end
    EnduranceBandState.lastLogKey = key
    if Config.endurance_band_sample_logging_enabled == true then
        print("[XNP ENDURANCE BAND SAMPLE] raw=" .. tostring(raw))
    end
end

local function makeInfo(state, reason, endurance, sample)
    return {
        state = state,
        reason = reason,
        endurance = endurance,
        raw = sample and sample.raw or state,
        hunger = sample and sample.hunger or nil,
        fatigue = sample and sample.fatigue or nil,
        calories = sample and sample.calories or nil,
        trend = sample and sample.trend or nil,
        sprint_capable = nil,
        jog_capable = nil,
        movement_independent = true,
        color_source = "ENDURANCE_VALUE_ONLY",
        resource = sample and sample.resource or nil,
        transient = sample and sample.transient or false,
        transientAction = sample and sample.transientAction or "NONE",
    }
end

function EnduranceBandState.CommitState(player, newState, reason)
    local current = EnduranceBandState.stableState and EnduranceBandState.stableState.state or nil
    local frame = EnduranceBandState.frame
    if EnduranceBandState.stateChangedThisTick then
        print("[XNP ENDURANCE COMMIT] no_recreate_same_tick=true")
        return false
    end
    if current == nil or current == newState then
        EnduranceBandState.candidateState = nil
        EnduranceBandState.candidateFrames = 0
        if EnduranceBandState.stableState == nil then
            EnduranceBandState.stableState = makeInfo(newState, reason or "INITIAL", EnduranceBandState.lastSample and EnduranceBandState.lastSample.endurance or nil, EnduranceBandState.lastSample)
        end
        return true
    end
    if EnduranceBandState.lastCommitFrame == frame then
        print("[XNP ENDURANCE COMMIT] no_recreate_same_tick=true")
        return false
    end
    local direction = transitionDirection(current, newState)
    local needed = Config.endurance_band_downgrade_confirm_frames or 6
    if direction == "UPGRADE" then
        needed = Config.endurance_band_upgrade_confirm_frames or 45
    end
    if EnduranceBandState.candidateState ~= newState then
        if EnduranceBandState.stateChangedThisTick then
            return false
        end
        EnduranceBandState.candidateState = newState
        EnduranceBandState.candidateFrames = 1
        return false
    end
    EnduranceBandState.candidateFrames = EnduranceBandState.candidateFrames + 1
    if EnduranceBandState.candidateFrames < needed then
        return false
    end
    local previousState = EnduranceBandState.stableState
    local candidateState = makeInfo(newState, reason or direction, EnduranceBandState.lastSample and EnduranceBandState.lastSample.endurance or nil, EnduranceBandState.lastSample)
    EnduranceBandState.candidateState = candidateState
    EnduranceBandState.previousStableState = previousState
    EnduranceBandState.stableState = EnduranceBandState.candidateState
    EnduranceBandState.candidateState = nil
    EnduranceBandState.candidateFrames = 0
    EnduranceBandState.stateChangedThisTick = true
    EnduranceBandState.commitFrame = frame
    EnduranceBandState.lastCommitFrame = frame
    print("[XNP ENDURANCE COMMIT] from=" .. tostring(current) .. " to=" .. tostring(newState) .. " endurance=" .. tostring(EnduranceBandState.stableState.endurance) .. " confirmed=true")
    print("[XNP ENDURANCE COMMIT] stable_state=" .. tostring(newState) .. " candidate_cleared=true")
    print("[XNP ENDURANCE COMMIT] stateChangedThisTick=true")
    print("[XNP ENDURANCE COMMIT] no_recreate_same_tick=true")
    return true
end

local function sample(player)
    local endurance = EnduranceBandState.GetEndurance(player)
    local movement = readMovement(player)
    local trend = Core.StaminaTrendMeter and Core.StaminaTrendMeter.Get and Core.StaminaTrendMeter.Get() or nil
    local result = {
        endurance = Constants.IsFiniteNumber(endurance) and clamp(endurance, 0.0, 1.0) or nil,
        trend = trend,
        isMoving = movement.isMoving,
        isRunning = movement.isRunning,
        isSprinting = movement.isSprinting,
        onFloor = movement.onFloor,
        action_state = movement.action_state,
        animation_state = movement.animation_state,
    }
    result.transient, result.transientAction = transientAction(result)
    result.raw = EnduranceBandState.ClassifyRaw(result.endurance)
    return result
end

function EnduranceBandState.GetStableState(player)
    local evalFrame = Core.PerformanceBudget and Core.PerformanceBudget.Frame and Core.PerformanceBudget.Frame() or (EnduranceBandState.frame + 1)
    if EnduranceBandState.lastEvalFrame == evalFrame and EnduranceBandState.stableState ~= nil then
        return EnduranceBandState.stableState
    end
    EnduranceBandState.lastEvalFrame = evalFrame
    EnduranceBandState.frame = evalFrame
    EnduranceBandState.stateChangedThisTick = false
    local s = sample(player)
    EnduranceBandState.lastSample = s
    local previous = EnduranceBandState.stableState and EnduranceBandState.stableState.state or nil
    local proposed, raw = EnduranceBandState.ApplyHysteresis(previous, s.endurance)
    logBand(s.endurance, raw)
    local direction = transitionDirection(previous, proposed)
    local largeDrop = false
    if Constants.IsFiniteNumber(EnduranceBandState.lastEndurance) and Constants.IsFiniteNumber(s.endurance) then
        largeDrop = (EnduranceBandState.lastEndurance - s.endurance) >= (Config.large_endurance_drop_threshold or 0.025)
    end
    if largeDrop and Config.large_endurance_drop_immediate_reclassify == true then
        proposed = s.raw
        direction = transitionDirection(previous, proposed)
        print("[XNP ENDURANCE BAND] large_drop=true before=" .. tostring(EnduranceBandState.lastEndurance) .. " after=" .. tostring(s.endurance) .. " reclassify=true")
    end
    EnduranceBandState.lastEndurance = s.endurance
    if s.transient == true and previous ~= nil then
        if direction == "UPGRADE" and Config.transient_hold_blocks_upgrade == true then
            if Core.LogThrottle then Core.LogThrottle.Blocked("ENDURANCEBANDSTATE", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            return EnduranceBandState.stableState
        elseif direction == "DOWNGRADE" then
            print("[XNP ENDURANCE BAND] transient_action=" .. tostring(s.transientAction) .. " downgrade_allowed=true")
            print("[XNP ENDURANCE BAND] downgrade_committed_during_transient=true")
        end
    end
    if EnduranceBandState.stateChangedThisTick then
        print("[XNP ENDURANCE COMMIT] no_recreate_same_tick=true")
        return EnduranceBandState.stableState
    elseif EnduranceBandState.stableState == nil then
        EnduranceBandState.stableState = makeInfo(proposed, "INITIAL", s.endurance, s)
    else
        EnduranceBandState.CommitState(player, proposed, direction)
    end
    if EnduranceBandState.frame - EnduranceBandState.lastSummaryFrame >= (Config.SUMMARY_LOG_INTERVAL_FRAMES or 120) then
        EnduranceBandState.lastSummaryFrame = EnduranceBandState.frame
        print("[XNP ENDURANCE BAND SUMMARY] state=" .. tostring(EnduranceBandState.stableState.state) .. " endurance=" .. tostring(s.endurance) .. " resource_available=NA")
    end
    return EnduranceBandState.stableState
end

function EnduranceBandState.RestorePreviousAfterOverride()
    if EnduranceBandState.stableState then
        print("[XNP ENDURANCE STATE RESTORE] restored=" .. tostring(EnduranceBandState.stableState.state) .. " after=SKILL_TRIGGERED_FLASH")
    end
    return EnduranceBandState.stableState
end

function EnduranceBandState.Reset(player)
    EnduranceBandState.stableState = nil
    EnduranceBandState.previousStableState = nil
    EnduranceBandState.candidateState = nil
    EnduranceBandState.candidateFrames = 0
    EnduranceBandState.stateChangedThisTick = false
    EnduranceBandState.commitFrame = -1
    EnduranceBandState.lastCommitFrame = -1
    EnduranceBandState.lastEvalFrame = nil
    EnduranceBandState.lastLogKey = nil
    EnduranceBandState.lastSummaryFrame = 0
    EnduranceBandState.lastEndurance = nil
    EnduranceBandState.lastSample = nil
end

function EnduranceBandState.IsValidState(state)
    return validStates[state] == true
end

Core.EnduranceBandState = EnduranceBandState
return EnduranceBandState
