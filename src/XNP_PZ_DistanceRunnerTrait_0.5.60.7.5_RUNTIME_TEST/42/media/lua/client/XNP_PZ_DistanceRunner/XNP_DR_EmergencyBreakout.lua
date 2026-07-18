require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyBreakoutCost"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_MovementIntentGate"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local EmergencyBreakout = {
    configLogged = false,
    lastTriggerTime = 0,
    triggerSeq = 0,
    playerCancelAudited = false,
    playerCancelMethod = nil,
    attempts = 0,
    success = 0,
    partialSuccess = 0,
    fail = 0,
    noTargets = 0,
    cooldownBlocked = 0,
}

XNP_DR_EmergencyBreakout = EmergencyBreakout

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

local function logConfigOnce()
    if EmergencyBreakout.configLogged then
        return
    end
    EmergencyBreakout.configLogged = true
    print("[XNP EMERGENCY BREAKOUT] method=HELD_RECENT_AUTO_DRAGDOWN_BREAKOUT")
    Core.LogThrottle.Blocked("EMERGENCY_BREAKOUT", "EDGE_ONLY_FALSE")
    print("[XNP EMERGENCY BREAKOUT] max_targets=" .. tostring(Config.EMERGENCY_BREAKOUT_MAX_TARGETS))
    print("[XNP EMERGENCY BREAKOUT] no_position_write=true")
    print("[XNP EMERGENCY BREAKOUT] no_damage_rollback=true")
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
    return "CHECK_NEARBY", text
end

local function collectTargets(player, radius)
    local result = {}
    if not player or not Core.ThreatSnapshot then
        return result
    end
    local px = player:getX()
    local py = player:getY()
    local zombies = Core.ThreatSnapshot.GetNearbyZombies(radius)
    for i = 1, #zombies do
        local obj = zombies[i]
        if liveZombie(obj) and sameZ(player, obj) and type(obj.getX) == "function" and type(obj.getY) == "function" then
            local dx = obj:getX() - px
            local dy = obj:getY() - py
            local dist = math.sqrt(dx * dx + dy * dy)
            local reason = dist <= Config.EMERGENCY_BREAKOUT_RADIUS_CONTROL and "CONTROLLING_PLAYER" or "SURROUNDING_PLAYER"
            result[#result + 1] = { zombie = obj, key = targetKey(obj), dist = dist, reason = reason }
        end
    end
    return result
end

local function auditPlayerCancel(player)
    if EmergencyBreakout.playerCancelAudited then
        return
    end
    EmergencyBreakout.playerCancelAudited = true
    if player and type(player.setKnockedDown) == "function" then
        EmergencyBreakout.playerCancelMethod = "setKnockedDown_false"
    elseif player and type(player.setOnFloor) == "function" then
        EmergencyBreakout.playerCancelMethod = "setOnFloor_false"
    end
end

local function attemptPlayerCancel(player)
    auditPlayerCancel(player)
    if not Config.EMERGENCY_BREAKOUT_PLAYER_CANCEL_ENABLED or not EmergencyBreakout.playerCancelMethod then
        if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local ok = false
    if EmergencyBreakout.playerCancelMethod == "setKnockedDown_false" then
        ok = pcall(function()
            player:setKnockedDown(false)
        end)
    elseif EmergencyBreakout.playerCancelMethod == "setOnFloor_false" then
        ok = pcall(function()
            player:setOnFloor(false)
        end)
    end
    print("[XNP EMERGENCY BREAKOUT] player_cancel_attempt method=" .. tostring(EmergencyBreakout.playerCancelMethod) .. " result=" .. tostring(ok))
    return ok
end

local function cooldownForPlayer(player)
    if not player or type(player.getStats) ~= "function" or not CharacterStat or not CharacterStat.ENDURANCE then
        return Config.EMERGENCY_BREAKOUT_COOLDOWN
    end
    local stats = player:getStats()
    if not stats or type(stats.get) ~= "function" then
        return Config.EMERGENCY_BREAKOUT_COOLDOWN
    end
    local endurance = stats:get(CharacterStat.ENDURANCE)
    if not Constants.IsFiniteNumber(endurance) then
        return Config.EMERGENCY_BREAKOUT_COOLDOWN
    end
    if endurance <= Config.EMERGENCY_BREAKOUT_CRITICAL_STAMINA_THRESHOLD then
        return Config.EMERGENCY_BREAKOUT_CRITICAL_STAMINA_COOLDOWN
    end
    if endurance <= Config.EMERGENCY_BREAKOUT_LOW_STAMINA_THRESHOLD then
        return Config.EMERGENCY_BREAKOUT_LOW_STAMINA_COOLDOWN
    end
    return Config.EMERGENCY_BREAKOUT_COOLDOWN
end

local function nextTriggerId()
    EmergencyBreakout.triggerSeq = EmergencyBreakout.triggerSeq + 1
    return EmergencyBreakout.triggerSeq
end

function EmergencyBreakout.Update(player)
    logConfigOnce()
    if not Config.EMERGENCY_BREAKOUT_ENABLED or not player or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        return false
    end

    local currentTime = nowSeconds()
    local state, movement = playerState(player)
    local dangerInfo = Core.DragdownDangerBreakout and Core.DragdownDangerBreakout.GetState and Core.DragdownDangerBreakout.GetState() or nil
    local classified = Core.DragdownDangerClassifier and Core.DragdownDangerClassifier.GetState and Core.DragdownDangerClassifier.GetState() or nil
    local inputAccepted, inputReason = Core.EmergencyInput.Evaluate(player, state, dangerInfo)
    if not inputAccepted then
        return false
    end
    if Core.MovementIntentGate and Core.MovementIntentGate.CanControlledEscape then
        local gateOk, reason = Core.MovementIntentGate.CanControlledEscape(player, { source = "EMERGENCY", controlled = state ~= "CHECK_NEARBY", reason = "CONTROLLED_OR_TOUCHING" })
        if not gateOk then
            if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            return false
        end
    end
    if classified and (classified.level == "SAFE" or classified.level == "WARNING_ONLY") then
        if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end

    local cooldown = cooldownForPlayer(player)
    if dangerInfo and (dangerInfo.level == "DRAGDOWN_DANGER" or dangerInfo.level == "FATAL_SURROUNDED") and Config.DRAGDOWN_COOLDOWN_OVERRIDE_ENABLED then
        cooldown = math.min(cooldown, dangerInfo.level == "FATAL_SURROUNDED" and Config.FATAL_SURROUNDED_COOLDOWN or Config.DRAGDOWN_COOLDOWN)
    end
    if currentTime - EmergencyBreakout.lastTriggerTime < cooldown then
        EmergencyBreakout.cooldownBlocked = EmergencyBreakout.cooldownBlocked + 1
        print("[XNP EMERGENCY BREAKOUT FAIL] reason=COOLDOWN cooldown=" .. fmt(cooldown))
        return false
    end

    local radius = math.min(Config.EMERGENCY_BREAKOUT_OUTER_RADIUS or Config.EMERGENCY_BREAKOUT_RADIUS_CROWD, Config.CONTROLLED_ESCAPE_RADIUS or 1.25)
    local targets = collectTargets(player, radius)
    if classified and classified.targets and #classified.targets > 0 then
        targets = classified.targets
    end
    if state == "CHECK_NEARBY" and #targets >= Config.EMERGENCY_BREAKOUT_CROWD_MIN_ZOMBIES then
        state = "SURROUNDED"
    elseif state == "CHECK_NEARBY" and dangerInfo and (dangerInfo.level == "DRAGDOWN_DANGER" or dangerInfo.level == "FATAL_SURROUNDED") then
        state = dangerInfo.level
    elseif state == "CHECK_NEARBY" and #targets > 0 then
        state = "CONTROLLED"
    end
    if #targets <= 0 then
        EmergencyBreakout.noTargets = EmergencyBreakout.noTargets + 1
        print("[XNP EMERGENCY BREAKOUT FAIL] reason=NO_CONTROLLING_ZOMBIES input=" .. tostring(inputReason) .. " movement=" .. tostring(movement))
        return false
    end

    local triggerId = nextTriggerId()
    EmergencyBreakout.attempts = EmergencyBreakout.attempts + 1
    local isAssist = classified and classified.level == "ASSIST"
    local effectType = isAssist and "STAGGER" or "KNOCKDOWN"
    local count = math.min(#targets, isAssist and Config.ASSIST_MAX_TARGETS or Config.EMERGENCY_BREAKOUT_MAX_TARGETS, Config.CONTROLLED_ESCAPE_MAX_TARGETS or 2)
    local selected = {}
    for i = 1, count do
        selected[#selected + 1] = targets[i]
    end
    if Core.BreakoutActionBus and Core.BreakoutActionBus.CanStart then
        local busOk = Core.BreakoutActionBus.CanStart("EMERGENCY", isAssist and "ASSIST" or state, selected, effectType)
        if not busOk then
            return false
        end
    end
    print("[XNP EMERGENCY BREAKOUT] trigger id=" .. tostring(triggerId) .. " state=" .. tostring(state) .. " input=" .. tostring(inputReason) .. " targets=" .. tostring(count))
    local actionId = nil
    local busLevel = isAssist and "ASSIST" or state
    if Core.BreakoutActionBus and Core.BreakoutActionBus.Accept then
        actionId = Core.BreakoutActionBus.Accept("EMERGENCY", busLevel, selected, effectType)
    end
    local costType = isAssist and "EMERGENCY_ASSIST" or "TRUE_EMERGENCY"
    if dangerInfo and dangerInfo.level == "FATAL_SURROUNDED" then
        costType = "FATAL_SURROUNDED"
    end
    Core.EmergencyBreakoutCost.Apply(player, triggerId, costType, actionId)

    local applied = 0
    for i = 1, count do
        local target = targets[i]
        print("[XNP CONTROLLED ESCAPE] target zombie=" .. tostring(target.key) .. " reason=" .. tostring(target.reason) .. " dist=" .. fmt(target.dist))
        print("[XNP EMERGENCY BREAKOUT TARGET] zombie=" .. tostring(target.key) .. " dist=" .. fmt(target.dist) .. " reason=" .. tostring(target.reason))
        local controlType = isAssist and "CONTACT" or "SPRINT_PRECOLLISION"
        if not isAssist and Core.ImpactQuotaMeter and Core.ImpactQuotaMeter.TrySkillActive then
            local quotaOk = Core.ImpactQuotaMeter.TrySkillActive("EMERGENCY", target.zombie, actionId)
            if not quotaOk then
                controlType = "CONTACT"
            end
        end
        local visible, effect = Core.VerifiedStaggerControl.Apply(player, target.zombie, controlType, { triggerId = triggerId })
        if visible then
            applied = applied + 1
        end
        if isAssist then
            print("[XNP ASSIST PUSH] effect=stagger_only reason=SOFT_CONTACT zombie=" .. tostring(target.key) .. " result=" .. (visible and "ok" or "fail"))
        else
            print("[XNP CONTROLLED ESCAPE] effect=STAGGER_OR_KNOCKDOWN")
            print("[XNP EMERGENCY BREAKOUT PUSH] trigger_id=" .. tostring(triggerId) .. " zombie=" .. tostring(target.key) .. " effect=" .. tostring(effect) .. " result=" .. (visible and "ok" or "fail"))
        end
    end

    if applied <= 0 then
        EmergencyBreakout.fail = EmergencyBreakout.fail + 1
        print("[XNP EMERGENCY BREAKOUT FAIL] reason=NO_VERIFIED_STAGGER_API")
        return false
    end
    Core.YellowRedSignals.PulseImpact("EMERGENCY_BREAKOUT")
    local canceled = attemptPlayerCancel(player)
    EmergencyBreakout.lastTriggerTime = currentTime
    if canceled then
            Core.LogThrottle.Event("[XNP CONTROLLED ESCAPE] player_cancel result=SUCCESS")
        EmergencyBreakout.success = EmergencyBreakout.success + 1
        print("[XNP EMERGENCY BREAKOUT OUTCOME] result=SUCCESS targets=" .. tostring(applied))
    else
            Core.LogThrottle.Blocked("CONTROLLED_ESCAPE", "PLAYER_CANCEL_FAILED")
        EmergencyBreakout.partialSuccess = EmergencyBreakout.partialSuccess + 1
        print("[XNP EMERGENCY BREAKOUT OUTCOME] result=PARTIAL_SUCCESS targets=" .. tostring(applied))
    end
    print("[XNP CONTROLLED ESCAPE] no_bite=true no_infection=true no_heal=true")
    return true
end

function EmergencyBreakout.GetState()
    return {
        attempts = EmergencyBreakout.attempts,
        success = EmergencyBreakout.success,
        partial = EmergencyBreakout.partialSuccess,
        cooldown = EmergencyBreakout.lastTriggerTime + Config.EMERGENCY_BREAKOUT_COOLDOWN - nowSeconds(),
    }
end

Core.EmergencyBreakout = EmergencyBreakout
return EmergencyBreakout
