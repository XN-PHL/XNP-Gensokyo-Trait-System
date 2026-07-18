require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Classifier = {
    configLogged = false,
    state = { level = "SAFE", reason = "INIT", inner = 0, outer = 0, critical = 0, targets = {} },
    frame = 0,
    warning = 0,
    assist = 0,
    trueEmergency = 0,
    fatal = 0,
    lastLoggedLevel = nil,
    tooLate = 0,
}

XNP_DR_DragdownDangerClassifier = Classifier

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
    if Core.BreakoutActionBus and Core.BreakoutActionBus.TargetKey then
        return Core.BreakoutActionBus.TargetKey(zombie)
    end
    return "local:" .. tostring(zombie)
end

local function playerContext(player)
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    local onFloor = safeBool(player, "isOnFloor")
    local knocked = safeBool(player, "isKnockedDown")
    local bumped = safeBool(player, "isBumped") or string.find(text, "bump", 1, true) ~= nil or string.find(text, "collid", 1, true) ~= nil
    local getup = string.find(text, "getup", 1, true) ~= nil or string.find(text, "recover", 1, true) ~= nil
    local grabbed = string.find(text, "grab", 1, true) ~= nil or string.find(text, "attack", 1, true) ~= nil or string.find(text, "bite", 1, true) ~= nil
    local shove = string.find(text, "shove", 1, true) ~= nil or string.find(text, "attack", 1, true) ~= nil
    return {
        movement = text,
        onFloor = onFloor,
        knocked = knocked,
        bumped = bumped,
        getup = getup,
        grabbed = grabbed,
        controlled = onFloor or knocked or bumped or getup or grabbed,
        manualShove = shove,
        running = safeBool(player, "isRunning"),
        sprinting = safeBool(player, "isSprinting"),
    }
end

local function zombieThreat(zombie)
    local text = safeString(zombie, "getActionStateName") .. " " .. safeString(zombie, "getAnimationStateName")
    return string.find(text, "attack", 1, true) ~= nil or string.find(text, "grab", 1, true) ~= nil or string.find(text, "bite", 1, true) ~= nil
end

function Classifier.CollectTargets(player)
    local result = {}
    if not player or not Core.ThreatSnapshot then
        return result
    end
    local px = player:getX()
    local py = player:getY()
    local radius = Config.DRAGDOWN_CRITICAL_RADIUS or 1.75
    local zombies = Core.ThreatSnapshot.GetNearbyZombies(radius)
    for i = 1, #zombies do
        local obj = zombies[i]
        if liveZombie(obj) and sameZ(player, obj) and type(obj.getX) == "function" and type(obj.getY) == "function" then
            local dx = obj:getX() - px
            local dy = obj:getY() - py
            local dist = math.sqrt(dx * dx + dy * dy)
            result[#result + 1] = { zombie = obj, key = targetKey(obj), dist = dist, attacking = zombieThreat(obj) }
        end
    end
    return result
end

local function countRings(targets)
    local inner = 0
    local outer = 0
    local critical = 0
    local attacking = 0
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
        if target.attacking then
            attacking = attacking + 1
        end
    end
    return inner, outer, critical, attacking
end

local function classify(player, targets)
    local ctx = playerContext(player)
    local inner, outer, critical, attacking = countRings(targets)
    local level = "SAFE"
    local reason = "NO_DANGER"
    local fatal = false
    if inner >= Config.FATAL_SURROUNDED_HARD_OVERRIDE_MIN_ZOMBIES_INNER then
        level = "TRUE_EMERGENCY"
        reason = "HARD_OVERRIDE_CLOSE_RING"
        fatal = true
    elseif (ctx.onFloor or ctx.knocked or ctx.getup) and inner >= 1 then
        level = "TRUE_EMERGENCY"
        reason = "ON_FLOOR_OR_GETUP_CLOSE"
    elseif ctx.controlled and inner >= Config.FATAL_SURROUNDED_MIN_ZOMBIES_INNER then
        level = "TRUE_EMERGENCY"
        reason = "FATAL_SURROUNDED_CONTROL_STATE"
        fatal = true
    elseif ctx.controlled and inner >= Config.DRAGDOWN_TRUE_EMERGENCY_MIN_ZOMBIES_INNER and attacking > 0 then
        level = "TRUE_EMERGENCY"
        reason = "CONTROLLED_ATTACK_WINDOW"
    elseif ctx.controlled and inner >= Config.DRAGDOWN_ASSIST_MIN_ZOMBIES_INNER then
        level = "ASSIST"
        reason = "BUMPED_OR_COLLIDED_CLOSE"
    elseif attacking > 0 and inner >= 1 then
        level = "ASSIST"
        reason = "ZOMBIE_ATTACK_WINDOW"
    elseif outer >= Config.DRAGDOWN_WARNING_MIN_ZOMBIES_OUTER then
        level = "WARNING_ONLY"
        reason = "NEARBY_BUT_NOT_CONTROLLED"
    end
    if Config.NORMAL_SINGLE_ZOMBIE_NO_KNOCKDOWN and #targets <= 1 and not ctx.controlled and level ~= "SAFE" then
        level = "SAFE"
        reason = "CLOSE_SINGLE_ZOMBIE_NOT_CONTROL"
        Core.LogThrottle.Blocked("CONTROLLED_CHECK", "CLOSE_SINGLE_ZOMBIE_NOT_CONTROL")
    end
    if Config.NORMAL_TWO_ZOMBIES_WARNING_ONLY and not ctx.controlled and inner <= 2 and outer >= 2 then
        level = "WARNING_ONLY"
        reason = "NEARBY_BUT_NOT_CONTROLLED"
    end
    return {
        level = level,
        reason = reason,
        fatal = fatal,
        inner = inner,
        outer = outer,
        critical = critical,
        attacking = attacking,
        targets = targets,
        context = ctx,
    }
end

local function logConfigOnce()
    if Classifier.configLogged then
        return
    end
    Classifier.configLogged = true
    print("[XNP DANGER CLASSIFIER] enabled=true")
    print("[XNP EFFECT PROFILE] level=WARNING_ONLY effect=NONE")
    Core.LogThrottle.Blocked("EFFECT_PROFILE", "PLAYER_CANCEL_FALSE")
    print("[XNP EFFECT PROFILE] level=TRUE_EMERGENCY effect=MIXED_STAGGER_KNOCKDOWN player_cancel=true")
end

function Classifier.Update(player)
    logConfigOnce()
    if not Config.DANGER_CLASSIFIER_ENABLED or not player or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        Classifier.state = { level = "SAFE", reason = "DISABLED_OR_NO_TRAIT", inner = 0, outer = 0, critical = 0, targets = {} }
        return Classifier.state
    end
    local state = classify(player, Classifier.CollectTargets(player))
    Classifier.state = state
    if state.level == "WARNING_ONLY" then
        Classifier.warning = Classifier.warning + 1
    elseif state.level == "ASSIST" then
        Classifier.assist = Classifier.assist + 1
    elseif state.level == "TRUE_EMERGENCY" then
        Classifier.trueEmergency = Classifier.trueEmergency + 1
        if state.fatal then
            Classifier.fatal = Classifier.fatal + 1
        end
    end
    if state.level ~= Classifier.lastLoggedLevel and state.level ~= "SAFE" then
        Classifier.lastLoggedLevel = state.level
        print("[XNP DANGER CLASSIFY] level=" .. tostring(state.level) .. " reason=" .. tostring(state.reason) .. " close_1_20=" .. tostring(state.inner) .. " close_1_65=" .. tostring(state.outer))
    elseif state.level == "SAFE" then
        Classifier.lastLoggedLevel = "SAFE"
    end
    Classifier.frame = Classifier.frame + 1
    if Config.DEBUG_DANGER_SUMMARY and Classifier.frame >= 60 then
        print("[XNP DANGER SUMMARY] warning=" .. tostring(Classifier.warning) .. " assist=" .. tostring(Classifier.assist) .. " true_emergency=" .. tostring(Classifier.trueEmergency) .. " fatal=" .. tostring(Classifier.fatal) .. " window=sampled")
        Classifier.frame = 0
        Classifier.warning = 0
        Classifier.assist = 0
        Classifier.trueEmergency = 0
        Classifier.fatal = 0
    end
    return state
end

function Classifier.GetState()
    return Classifier.state
end

function Classifier.Cleanup(reason)
    Classifier.state = { level = "SAFE", reason = "CLEANUP", inner = 0, outer = 0, critical = 0, targets = {} }
    Classifier.lastLoggedLevel = nil
end

Core.DragdownDangerClassifier = Classifier
return Classifier
