require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_MovementIntentGate"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local DragdownDangerBreakout = {
    configLogged = false,
    lastTriggerTime = 0,
    dangerFrames = 0,
    triggerSeq = 0,
    state = { level = "CLEAR", inner = 0, outer = 0, critical = 0 },
    attempts = 0,
    success = 0,
    fail = 0,
    skippedCooldown = 0,
    warningNoAuto = 0,
    assistNeedsInput = 0,
    blockSummaryFrame = 0,
    lastDangerLogLevel = nil,
    lastAutoLogKey = nil,
}

XNP_DR_DragdownDangerBreakout = DragdownDangerBreakout

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function fmt(value)
    if not Constants.IsFiniteNumber(value) then
        return "NA"
    end
    return string.format("%.4f", value)
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
            return string.lower(tostring(value))
        end
    end
    return ""
end

local function sameZ(player, zombie)
    if not player or not zombie or type(player.getZ) ~= "function" or type(zombie.getZ) ~= "function" then
        return false
    end
    return math.abs(player:getZ() - zombie:getZ()) <= 0.50
end

local function liveZombie(obj)
    if not obj or type(instanceof) ~= "function" or not instanceof(obj, "IsoZombie") then
        return false
    end
    if safeBool(obj, "isDead") or safeBool(obj, "isFakeDead") then
        return false
    end
    return true
end

local function targetKey(zombie)
    if not zombie then
        return "nil"
    end
    if type(zombie.getOnlineID) == "function" then
        local ok, value = pcall(function()
            return zombie:getOnlineID()
        end)
        if ok and value ~= nil then
            return "online:" .. tostring(value)
        end
    end
    if type(zombie.getID) == "function" then
        local ok, value = pcall(function()
            return zombie:getID()
        end)
        if ok and value ~= nil then
            return "id:" .. tostring(value)
        end
    end
    return "local:" .. tostring(zombie)
end

local function playerState(player)
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    if safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown") then
        return "ON_FLOOR", text
    end
    if string.find(text, "getup", 1, true) or string.find(text, "recover", 1, true) then
        return "GETUP", text
    end
    if string.find(text, "grab", 1, true) or string.find(text, "attack", 1, true) or string.find(text, "fall", 1, true) or string.find(text, "trip", 1, true) then
        return "CONTROLLED", text
    end
    return "NORMAL", text
end

local function collectNearby(player)
    local result = {}
    if not player or not Core.ThreatSnapshot then
        return result
    end
    local px = player:getX()
    local py = player:getY()
    local radius = Config.DRAGDOWN_CRITICAL_RADIUS
    local zombies = Core.ThreatSnapshot.GetNearbyZombies(radius)
    for i = 1, #zombies do
        local obj = zombies[i]
        if liveZombie(obj) and sameZ(player, obj) and type(obj.getX) == "function" and type(obj.getY) == "function" then
            local dx = obj:getX() - px
            local dy = obj:getY() - py
            local dist = math.sqrt(dx * dx + dy * dy)
            result[#result + 1] = { zombie = obj, key = targetKey(obj), dist = dist, dx = dx, dy = dy }
        end
    end
    return result
end

local function classify(player, targets)
    local inner = 0
    local outer = 0
    local critical = 0
    for _, target in ipairs(targets) do
        if target.dist <= Config.DRAGDOWN_INNER_RADIUS then
            inner = inner + 1
        end
        if target.dist <= Config.DRAGDOWN_OUTER_RADIUS then
            outer = outer + 1
        end
        if target.dist <= Config.DRAGDOWN_CRITICAL_RADIUS then
            critical = critical + 1
        end
    end
    local pstate, text = playerState(player)
    local level = "CLEAR"
    if inner >= Config.FATAL_SURROUNDED_MIN_ZOMBIES_INNER or outer >= Config.FATAL_SURROUNDED_MIN_ZOMBIES_OUTER then
        level = "FATAL_SURROUNDED"
    elseif inner >= Config.DRAGDOWN_DANGER_MIN_ZOMBIES_INNER or outer >= Config.DRAGDOWN_DANGER_MIN_ZOMBIES_OUTER or ((pstate == "CONTROLLED" or pstate == "GETUP") and inner >= 1) then
        level = "DRAGDOWN_DANGER"
    end
    return { level = level, inner = inner, outer = outer, critical = critical, playerState = pstate, movement = text, targets = targets }
end

local function logConfigOnce()
    if DragdownDangerBreakout.configLogged then
        return
    end
    DragdownDangerBreakout.configLogged = true
    print("[XNP DRAGDOWN DANGER] method=SURROUNDED_FATAL_WINDOW_BREAKOUT")
    print("[XNP DRAGDOWN DANGER] auto_trigger_frames=" .. tostring(Config.DRAGDOWN_AUTO_TRIGGER_FRAMES) .. " max_targets=" .. tostring(Config.DRAGDOWN_MAX_TARGETS) .. " critical_max_targets=" .. tostring(Config.DRAGDOWN_CRITICAL_MAX_TARGETS))
end

local function logBlockSummary()
    DragdownDangerBreakout.blockSummaryFrame = DragdownDangerBreakout.blockSummaryFrame + 1
    if DragdownDangerBreakout.blockSummaryFrame >= 60 then
            print("[XNP DRAGDOWN BLOCK SUMMARY] warning_no_auto=" .. tostring(DragdownDangerBreakout.warningNoAuto) .. " assist_needs_input=" .. tostring(DragdownDangerBreakout.assistNeedsInput) .. " cooldown=" .. tostring(DragdownDangerBreakout.skippedCooldown) .. " window=sampled")
        if Core.LogThrottle then Core.LogThrottle.Blocked("DRAGDOWNDANGERBREAKOUT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        DragdownDangerBreakout.blockSummaryFrame = 0
        DragdownDangerBreakout.warningNoAuto = 0
        DragdownDangerBreakout.assistNeedsInput = 0
        DragdownDangerBreakout.skippedCooldown = 0
    end
end

local function cooldownFor(level)
    if level == "FATAL_SURROUNDED" then
        return Config.FATAL_SURROUNDED_COOLDOWN
    end
    return Config.DRAGDOWN_COOLDOWN
end

local function nextTriggerId()
    DragdownDangerBreakout.triggerSeq = DragdownDangerBreakout.triggerSeq + 1
    return "D" .. tostring(DragdownDangerBreakout.triggerSeq)
end

local function attemptPlayerCancel(player, triggerId, level)
    local ok = false
    local method = "none"
    if player and type(player.setKnockedDown) == "function" then
        method = "setKnockedDown_false"
        ok = pcall(function()
            player:setKnockedDown(false)
        end)
    elseif player and type(player.setOnFloor) == "function" then
        method = "setOnFloor_false"
        ok = pcall(function()
            player:setOnFloor(false)
        end)
    end
    print("[XNP DRAGDOWN BREAKOUT] player_cancel method=" .. tostring(method) .. " result=" .. tostring(ok) .. " trigger_id=" .. tostring(triggerId) .. " level=" .. tostring(level))
end

local function applyBreakout(player, danger, currentTime)
    local cooldown = cooldownFor(danger.level)
    if currentTime - DragdownDangerBreakout.lastTriggerTime < cooldown then
        DragdownDangerBreakout.skippedCooldown = DragdownDangerBreakout.skippedCooldown + 1
        return false
    end
    if Core.MovementIntentGate and Core.MovementIntentGate.CanControlledEscape then
        local gateOk, reason = Core.MovementIntentGate.CanControlledEscape(player, { source = "DRAGDOWN", controlled = true, reason = "CONTROLLED_OR_TOUCHING" })
        if not gateOk then
            Core.LogThrottle.Blocked("DRAGDOWN_BREAKOUT", reason)
            return false
        end
    end
    local triggerId = nextTriggerId()
    local maxTargets = math.min(danger.level == "FATAL_SURROUNDED" and Config.DRAGDOWN_CRITICAL_MAX_TARGETS or Config.DRAGDOWN_MAX_TARGETS, Config.CONTROLLED_ESCAPE_MAX_TARGETS or 2)
    local count = math.min(#danger.targets, maxTargets)
    local selected = {}
    for i = 1, count do
        selected[#selected + 1] = danger.targets[i]
    end
    if Core.BreakoutActionBus and Core.BreakoutActionBus.CanStart then
        local busOk = Core.BreakoutActionBus.CanStart("DRAGDOWN", danger.level, selected, "KNOCKDOWN")
        if not busOk then
            return false
        end
    end
    DragdownDangerBreakout.attempts = DragdownDangerBreakout.attempts + 1
    print("[XNP DRAGDOWN BREAKOUT] level=" .. tostring(danger.level) .. " trigger_id=" .. tostring(triggerId) .. " targets=" .. tostring(count) .. " max_targets=" .. tostring(maxTargets))
    local actionId = nil
    if Core.BreakoutActionBus and Core.BreakoutActionBus.Accept then
        actionId = Core.BreakoutActionBus.Accept("DRAGDOWN", danger.level, selected, "KNOCKDOWN")
    end
    local costType = danger.level == "FATAL_SURROUNDED" and "FATAL_SURROUNDED" or "TRUE_EMERGENCY"
    Core.EmergencyBreakoutCost.Apply(player, triggerId, costType, actionId)
    local applied = 0
    for i = 1, count do
        local target = danger.targets[i]
        print("[XNP CONTROLLED ESCAPE] target zombie=" .. tostring(target.key) .. " reason=CONTROLLED_OR_TOUCHING dist=" .. fmt(target.dist))
        print("[XNP DRAGDOWN TARGET] zombie=" .. tostring(target.key) .. " dist=" .. fmt(target.dist) .. " reason=CLOSE_KILL_RING")
        local visible = false
        local effect = "none"
        local controlType = "SPRINT_PRECOLLISION"
        if Core.ImpactQuotaMeter and Core.ImpactQuotaMeter.TrySkillActive then
            local quotaOk = Core.ImpactQuotaMeter.TrySkillActive("DRAGDOWN", target.zombie, actionId)
            if not quotaOk then
                controlType = "CONTACT"
            end
        end
        if Core.VerifiedStaggerControl and Core.VerifiedStaggerControl.Apply then
            visible, effect = Core.VerifiedStaggerControl.Apply(player, target.zombie, controlType, { triggerId = triggerId })
        end
        if visible then
            applied = applied + 1
        end
        print("[XNP CONTROLLED ESCAPE] effect=STAGGER_OR_KNOCKDOWN")
        print("[XNP DRAGDOWN PUSH] zombie=" .. tostring(target.key) .. " effect=" .. tostring(effect) .. " visible=" .. tostring(visible))
    end
    attemptPlayerCancel(player, triggerId, danger.level)
    Core.LogThrottle.Blocked("CONTROLLED_ESCAPE", "KNOCKDOWN_CANCEL_DEFERRED")
    DragdownDangerBreakout.lastTriggerTime = currentTime
    if applied > 0 then
        DragdownDangerBreakout.success = DragdownDangerBreakout.success + 1
        Core.YellowRedSignals.PulseImpact("DRAGDOWN_BREAKOUT")
        print("[XNP DRAGDOWN BREAKOUT] result=SUCCESS knocked=" .. tostring(applied) .. " staggered=" .. tostring(applied))
    else
        DragdownDangerBreakout.fail = DragdownDangerBreakout.fail + 1
        print("[XNP DRAGDOWN BREAKOUT] result=FAIL reason=NO_VISIBLE_ZOMBIE_CONTROL")
    end
    print("[XNP CONTROLLED ESCAPE] no_bite=true no_infection=true no_heal=true")
    return applied > 0
end

function DragdownDangerBreakout.Update(player)
    logConfigOnce()
    logBlockSummary()
    if not Config.DRAGDOWN_BREAKOUT_ENABLED or not player or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        DragdownDangerBreakout.state = { level = "CLEAR", inner = 0, outer = 0, critical = 0 }
        return false
    end
    local currentTime = nowSeconds()
    local danger = classify(player, collectNearby(player))
    local classified = Core.DragdownDangerClassifier and Core.DragdownDangerClassifier.GetState and Core.DragdownDangerClassifier.GetState() or nil
    if classified and classified.level == "WARNING_ONLY" then
        DragdownDangerBreakout.state = { level = "WARNING_ONLY", inner = classified.inner, outer = classified.outer, critical = classified.critical, targets = classified.targets }
        DragdownDangerBreakout.warningNoAuto = DragdownDangerBreakout.warningNoAuto + 1
        Core.LogThrottle.Blocked("DRAGDOWN_BREAKOUT", "WARNING_ONLY_NO_AUTO")
        Core.LogThrottle.Blocked("AUTO_DRAGDOWN", "NOT_TRUE_EMERGENCY")
        return false
    elseif classified and classified.level == "ASSIST" then
        DragdownDangerBreakout.state = { level = "ASSIST", inner = classified.inner, outer = classified.outer, critical = classified.critical, targets = classified.targets }
        DragdownDangerBreakout.assistNeedsInput = DragdownDangerBreakout.assistNeedsInput + 1
        Core.LogThrottle.Blocked("AUTO_DRAGDOWN", "NEEDS_INPUT_OR_BUMPED")
        return false
    elseif classified and classified.level == "TRUE_EMERGENCY" then
        danger.level = "FATAL_SURROUNDED"
        danger.targets = classified.targets or danger.targets
        danger.inner = classified.inner or danger.inner
        danger.outer = classified.outer or danger.outer
        danger.critical = classified.critical or danger.critical
    end
    DragdownDangerBreakout.state = danger
    if Config.DEBUG_DRAGDOWN_DANGER and danger.level ~= "CLEAR" and danger.level ~= DragdownDangerBreakout.lastDangerLogLevel then
        DragdownDangerBreakout.lastDangerLogLevel = danger.level
        print("[XNP DRAGDOWN DANGER] level=" .. tostring(danger.level) .. " close_1_20=" .. tostring(danger.inner) .. " close_1_65=" .. tostring(danger.outer) .. " close_1_75=" .. tostring(danger.critical) .. " state=" .. tostring(danger.playerState))
    end
    if danger.level == "CLEAR" then
        DragdownDangerBreakout.dangerFrames = 0
        DragdownDangerBreakout.lastDangerLogLevel = "CLEAR"
        return false
    end
    DragdownDangerBreakout.dangerFrames = DragdownDangerBreakout.dangerFrames + 1
    if danger.level == "FATAL_SURROUNDED" then
        local autoKey = tostring(danger.level) .. "|" .. tostring(danger.inner) .. "|" .. tostring(danger.outer)
        if autoKey ~= DragdownDangerBreakout.lastAutoLogKey then
            DragdownDangerBreakout.lastAutoLogKey = autoKey
        print("[XNP DRAGDOWN DANGER] level=FATAL_SURROUNDED auto_trigger=true")
        end
        return applyBreakout(player, danger, currentTime)
    end
    if DragdownDangerBreakout.dangerFrames >= Config.DRAGDOWN_AUTO_TRIGGER_FRAMES then
        local autoKey = tostring(danger.level) .. "|" .. tostring(danger.inner) .. "|" .. tostring(danger.outer)
        if autoKey ~= DragdownDangerBreakout.lastAutoLogKey then
            DragdownDangerBreakout.lastAutoLogKey = autoKey
        print("[XNP DRAGDOWN DANGER] level=DRAGDOWN_DANGER auto_trigger=true frames=" .. tostring(DragdownDangerBreakout.dangerFrames))
        end
        return applyBreakout(player, danger, currentTime)
    end
    return false
end

function DragdownDangerBreakout.GetState()
    return DragdownDangerBreakout.state
end

function DragdownDangerBreakout.Cleanup(reason)
    DragdownDangerBreakout.dangerFrames = 0
    DragdownDangerBreakout.state = { level = "CLEAR", inner = 0, outer = 0, critical = 0 }
    DragdownDangerBreakout.lastDangerLogLevel = nil
    DragdownDangerBreakout.lastAutoLogKey = nil
end

Core.DragdownDangerBreakout = DragdownDangerBreakout
return DragdownDangerBreakout
