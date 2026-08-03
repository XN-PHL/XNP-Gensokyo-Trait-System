require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_B42_20_StatsAdapter"
require "XNP_PZ_DistanceRunner/XNP_DR_RedPhysicalLoad"

local Core = XNP_PZ_DistanceRunner
local StatsAdapter = Core.B42_20StatsAdapter
local Feedback = {
    woundWriteCount = 0,
    infectionWriteCount = 0,
    sessions = 0,
    cancelledPhysicalWriteCount = 0,
    failedPhysicalWriteCount = 0,
    physicalLoadExceptionCount = 0,
}

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
    if not StatsAdapter then return nil end
    local value = StatsAdapter.Read(player, "FATIGUE")
    if tonumber(value) == nil then return nil end
    return clamp(tonumber(value), 0, 1)
end

function Feedback.Begin(action, player)
    if not action then return false, "ACTION_MISSING" end
    action.xnpRedFeedback = {
        initialFatigue = readFatigue(player),
        observedProgress = 0,
        settled = false,
        physicalLoadStarted = false,
    }
    Feedback.sessions = Feedback.sessions + 1
    return true, "SESSION_STARTED_NO_PHYSICAL_WRITES"
end

function Feedback.Update(action)
    local state = action and action.xnpRedFeedback
    if not state then return false, "SESSION_MISSING" end
    state.observedProgress = math.max(
        state.observedProgress or 0, readProgress(action))
    return true, "PROGRESS_OBSERVED_NO_PHYSICAL_WRITES"
end

function Feedback.Settle(action, player, completed)
    local state = action and action.xnpRedFeedback
    if not state or state.settled then
        return false, "ALREADY_SETTLED_OR_MISSING"
    end
    state.settled = true
    state.observedProgress = math.max(
        state.observedProgress or 0, readProgress(action))
    if completed == true then
        return false, "COMPLETION_REQUIRES_COMMITTED_TRANSACTION"
    end
    Feedback.cancelledPhysicalWriteCount =
        Feedback.cancelledPhysicalWriteCount + 0
    print("[XNP RED CRAFT FEEDBACK] completed=false"
        .. " progress=" .. tostring(state.observedProgress)
        .. " fatigue_write=false physical_write=false"
        .. " cancellation_cost=ZERO"
        .. " wound_writes=0 infection_writes=0")
    return true, "CANCELLED_ZERO_PHYSICAL_WRITE"
end

function Feedback.MarkCommitted(action, player, transactionInfo)
    local state = action and action.xnpRedFeedback
    if not state or state.settled then
        return false, "ALREADY_SETTLED_OR_MISSING"
    end
    state.settled = true
    state.observedProgress = 1
    local started, reason, summary = false,
        "PHYSICAL_LOAD_MODULE_UNAVAILABLE", nil
    if Core.RedPhysicalLoad
        and type(Core.RedPhysicalLoad.Start) == "function" then
        local callOk
        callOk, started, reason, summary = pcall(
            Core.RedPhysicalLoad.Start, player, transactionInfo)
        if not callOk then
            Feedback.physicalLoadExceptionCount =
                Feedback.physicalLoadExceptionCount + 1
            started = false
            reason = "PHYSICAL_LOAD_EXCEPTION_FAIL_CLOSED"
            summary = nil
        end
    end
    state.physicalLoadStarted = started == true
    print("[XNP RED CRAFT FEEDBACK] completed=true progress=1"
        .. " fatigue_owned_by=CRAFT_TRANSACTION"
        .. " duplicate_fatigue_write=false"
        .. " physical_load_started=" .. tostring(started == true)
        .. " physical_load_reason=" .. tostring(reason)
        .. " wound_writes=0 infection_writes=0")
    return started == true, reason, summary
end

function Feedback.CancelFailedCommit(action)
    local state = action and action.xnpRedFeedback
    if not state or state.settled then
        return false, "ALREADY_SETTLED_OR_MISSING"
    end
    state.settled = true
    Feedback.failedPhysicalWriteCount = Feedback.failedPhysicalWriteCount + 0
    print("[XNP RED CRAFT FEEDBACK] completed=false"
        .. " reason=CRAFT_TRANSACTION_FAILED fatigue_write=false"
        .. " physical_write=false wound_writes=0 infection_writes=0")
    return true, "FAILED_COMMIT_ZERO_PHYSICAL_WRITE"
end

function Feedback.GetAuditSnapshot()
    return {
        reachable = true,
        session_count = Feedback.sessions,
        wound_write_count = Feedback.woundWriteCount,
        infection_write_count = Feedback.infectionWriteCount,
        cancelled_physical_write_count =
            Feedback.cancelledPhysicalWriteCount,
        failed_physical_write_count = Feedback.failedPhysicalWriteCount,
        cancellation_cost_is_zero = true,
        physical_feedback_after_commit_only = true,
        duplicate_fatigue_write_count = 0,
        physical_load_exception_count =
            Feedback.physicalLoadExceptionCount,
    }
end

function Feedback.GetPhysicalLoadModuleForAudit()
    return Core.RedPhysicalLoad
end

Core.RedCraftFeedback = Feedback
return Feedback
