require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local ActionBus = {
    configLogged = false,
    frameToken = nil,
    lastActionId = 0,
    lastActionFrame = nil,
    lastActionTime = 0,
    lastSource = nil,
    lastDangerLevel = "SAFE",
    lastTargetKeys = {},
    knockedTargets = {},
    staggeredTargets = {},
    blockedSameFrame = 0,
    blockedTarget = 0,
    blockedCooldown = 0,
    allowFollowup = 0,
    emergencyOverride = 0,
    movementGateBlocked = 0,
    summaryFrame = 0,
}

XNP_DR_BreakoutActionBus = ActionBus

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function frameToken()
    if type(getTimestampMs) == "function" then
        return math.floor(getTimestampMs() / 16)
    end
    return os.time()
end

local function fmt(value)
    if not Constants.IsFiniteNumber(value) then
        return "NA"
    end
    return string.format("%.2f", value)
end

function ActionBus.TargetKey(zombie)
    if not zombie then
        return "nil"
    end
    if type(zombie.getOnlineID) == "function" then
        local ok, value = pcall(function()
            return zombie:getOnlineID()
        end)
        if ok and value ~= nil and tonumber(value) ~= nil and tonumber(value) >= 0 then
            return "online:" .. tostring(value)
        end
    end
    if type(zombie.getID) == "function" then
        local ok, value = pcall(function()
            return zombie:getID()
        end)
        if ok and value ~= nil and tonumber(value) ~= nil and tonumber(value) >= 0 then
            return "id:" .. tostring(value)
        end
    end
    return "local:" .. tostring(zombie)
end

local function collectKeys(targets)
    local keys = {}
    if targets then
        for i = 1, #targets do
            local zombie = targets[i].zombie or targets[i]
            keys[#keys + 1] = ActionBus.TargetKey(zombie)
        end
    end
    return keys
end

local function hasSharedTarget(keys)
    for _, key in ipairs(keys) do
        for _, lastKey in ipairs(ActionBus.lastTargetKeys) do
            if key == lastKey then
                return true, key
            end
        end
    end
    return false, nil
end

local function windowCooldownFor(level)
    if level == "TRUE_EMERGENCY" or level == "FATAL_SURROUNDED" then
        return Config.FATAL_WINDOW_COOLDOWN
    elseif level == "ASSIST" then
        return Config.ASSIST_COOLDOWN
    end
    return Config.DRAGDOWN_WINDOW_COOLDOWN
end

local function logConfigOnce()
    if ActionBus.configLogged then
        return
    end
    ActionBus.configLogged = true
    print("[XNP ACTION BUS] enabled=true")
    print("[XNP ACTION BUS] same_frame_double_action_block=" .. tostring(Config.SAME_FRAME_DOUBLE_ACTION_BLOCK == true))
    print("[XNP ACTION BUS] cost_single_charge=" .. tostring(Config.COST_ACTION_BUS_SINGLE_CHARGE == true))
    print("[XNP BALANCE] no_aura=" .. tostring(Config.NO_AURA == true))
    print("[XNP BALANCE] zombies_can_reenter=" .. tostring(Config.ZOMBIES_CAN_REENTER_AFTER_BREAKOUT == true))
end

function ActionBus.ResetWindow(reason)
    ActionBus.lastActionFrame = nil
    ActionBus.lastTargetKeys = {}
    ActionBus.lastDangerLevel = "SAFE"
    if reason then
        print("[XNP ACTION BUS] window_reset reason=" .. tostring(reason))
    end
end

function ActionBus.Update(danger)
    logConfigOnce()
    if danger and danger.level == "SAFE" then
        if ActionBus.lastDangerLevel ~= "SAFE" then
            ActionBus.ResetWindow("DANGER_CLEARED")
        end
        ActionBus.lastDangerLevel = "SAFE"
    elseif danger and danger.level then
        ActionBus.lastDangerLevel = danger.level
    end
    ActionBus.summaryFrame = ActionBus.summaryFrame + 1
    if (Config.DEBUG_COOLDOWN_SUMMARY or Config.THROTTLE_ACTION_BUS_BLOCK_LOGS) and ActionBus.summaryFrame >= 60 then
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTACTIONBUS", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        ActionBus.summaryFrame = 0
        ActionBus.blockedSameFrame = 0
        ActionBus.blockedTarget = 0
        ActionBus.blockedCooldown = 0
        ActionBus.allowFollowup = 0
        ActionBus.emergencyOverride = 0
        ActionBus.movementGateBlocked = 0
    end
end

function ActionBus.BlockMovementGate(source, reason)
    ActionBus.movementGateBlocked = ActionBus.movementGateBlocked + 1
    Core.LogThrottle.Blocked("ACTION_BUS", tostring(source) .. "_" .. tostring(reason))
    return false, reason
end

function ActionBus.AllowFollowup(source, reason)
    ActionBus.allowFollowup = ActionBus.allowFollowup + 1
    if source == "SPRINT_TRIP_CANCEL" then
        print("[XNP ACTION BUS] allow_followup source=SPRINT_TRIP_CANCEL reason=SAME_SPRINT_WINDOW")
        return true
    end
    print("[XNP ACTION BUS] allow_followup source=" .. tostring(source) .. " reason=" .. tostring(reason))
    return true
end

function ActionBus.CanStart(source, level, targets, effect)
    logConfigOnce()
    if not Config.BREAKOUT_ACTION_BUS_ENABLED then
        return true, "DISABLED"
    end
    if source == "SPRINT_IMMUNITY_CANCEL" then
        return ActionBus.AllowFollowup(source, "SAME_SPRINT_WINDOW"), "SAME_SPRINT_WINDOW"
    end
    local now = nowSeconds()
    local frame = frameToken()
    local keys = collectKeys(targets)
    if Config.SAME_FRAME_DOUBLE_ACTION_BLOCK and ActionBus.lastActionFrame == frame then
        local shared, key = hasSharedTarget(keys)
        if shared then
            ActionBus.blockedSameFrame = ActionBus.blockedSameFrame + 1
            Core.LogThrottle.Blocked("ACTION_BUS", "ACTION_ALREADY_HANDLED_THIS_WINDOW")
            return false, "ACTION_ALREADY_HANDLED_THIS_WINDOW"
        end
    end
    local windowCooldown = windowCooldownFor(level)
    if ActionBus.lastActionTime > 0 and now - ActionBus.lastActionTime < windowCooldown then
        local shared, key = hasSharedTarget(keys)
        if shared then
            if (source == "DRAGDOWN" or source == "EMERGENCY") and (level == "TRUE_EMERGENCY" or level == "FATAL_SURROUNDED") and (ActionBus.lastSource == "SPRINT" or ActionBus.lastSource == "SPRINT_IMMUNITY") then
                ActionBus.emergencyOverride = ActionBus.emergencyOverride + 1
                print("[XNP ACTION BUS] emergency_override=true reason=PLAYER_FELL_AFTER_SPRINT")
                return true, "EMERGENCY_OVERRIDE_AFTER_SPRINT"
            end
            ActionBus.blockedCooldown = ActionBus.blockedCooldown + 1
            Core.LogThrottle.Blocked("ACTION_BUS", "WINDOW_COOLDOWN")
            return false, "WINDOW_COOLDOWN"
        end
    end
    local targetTable = effect == "KNOCKDOWN" and ActionBus.knockedTargets or ActionBus.staggeredTargets
    local targetCooldown = effect == "KNOCKDOWN" and Config.SAME_TARGET_KNOCKDOWN_COOLDOWN or Config.SAME_TARGET_STAGGER_COOLDOWN
    for _, key in ipairs(keys) do
        local last = targetTable[key]
        if last and now - last < targetCooldown then
            ActionBus.blockedTarget = ActionBus.blockedTarget + 1
            Core.LogThrottle.Blocked("ACTION_BUS", "RECENTLY_KNOCKED")
            return false, "RECENTLY_KNOCKED"
        end
    end
    return true, "OK"
end

function ActionBus.Accept(source, level, targets, effect)
    local now = nowSeconds()
    ActionBus.lastActionId = ActionBus.lastActionId + 1
    ActionBus.lastActionFrame = frameToken()
    ActionBus.lastActionTime = now
    ActionBus.lastSource = source
    ActionBus.lastDangerLevel = level
    ActionBus.lastTargetKeys = collectKeys(targets)
    local targetTable = effect == "KNOCKDOWN" and ActionBus.knockedTargets or ActionBus.staggeredTargets
    for _, key in ipairs(ActionBus.lastTargetKeys) do
        targetTable[key] = now
    end
    print("[XNP ACTION BUS] accepted source=" .. tostring(source) .. " level=" .. tostring(level) .. " action_id=" .. tostring(ActionBus.lastActionId))
    return ActionBus.lastActionId
end

function ActionBus.Cleanup(reason)
    ActionBus.ResetWindow(reason or "cleanup")
end

Core.BreakoutActionBus = ActionBus
return ActionBus
