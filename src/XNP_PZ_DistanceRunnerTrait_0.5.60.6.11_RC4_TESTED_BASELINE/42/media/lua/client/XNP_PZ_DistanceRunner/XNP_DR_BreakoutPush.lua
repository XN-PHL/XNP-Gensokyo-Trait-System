require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_CostTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus"
require "XNP_PZ_DistanceRunner/XNP_DR_MovementIntentGate"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedImpactPath"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactCandidateSnapshot"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local BreakoutPush = {
    disabled = false,
    disabledReason = nil,
    configLogged = false,
    lastSummaryTime = 0,
    lastTriggerTime = 0,
    lastGrabTriggerTime = 0,
    targetLockUntil = 0,
    lastTargetKey = nil,
    lastTargetTime = {},
    rearmRequired = false,
    lastX = nil,
    lastY = nil,
    lastSpeedTime = 0,
    lastSpeed = 0,
    attempts = 0,
    triggered = 0,
    visible = 0,
    successPlayerStayedUp = 0,
    failPlayerFellAfterPush = 0,
    failZombieAiStuck = 0,
    sprintPrecollision = 0,
    contact = 0,
    grab = 0,
    crowd = 0,
    blockedNotClosing = 0,
    blockedBadDot = 0,
    blockedDistance = 0,
    blockedNoContact = 0,
    blockedNoMovementIntent = 0,
    blockedLowSpeedForSprint = 0,
    blockedEndurance = 0,
    blockedPlayerDown = 0,
    blockedCooldown = 0,
    blockedSameZombie = 0,
    blockedNotRearmed = 0,
    routeDisabled = {},
    playerDownLogged = false,
    zombieHistory = {},
    pendingPlayerWatchdogs = {},
    pendingZombieWatchdogs = {},
    triggerSeq = 0,
    recoveryRegistered = 0,
    recoveryNotStuck = 0,
    recoverySuspicious = 0,
    localZombieKeys = {},
    nextLocalZombieId = 1,
    zombieKeyFallbackLogged = false,
    skipLogWindowFrame = 0,
    skipLogNotClosing = 0,
    skipLogBadDot = 0,
    skipLogLowSpeed = 0,
    skipLogTooLate = 0,
    blockedContactWalk = 0,
    blockedContactSide = 0,
    blockedContactLowSpeed = 0,
    blockedPlayerRecoveryState = 0,
    contactJogFront = 0,
    speedSampleFrame = 0,
    speedSampleSprintFrames = 0,
    speedSampleJogFrames = 0,
    speedSampleMaxSpeed = 0,
    lastContactTime = 0,
}

XNP_DR_BreakoutPush = BreakoutPush

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

local function safeCall(route, fn)
    if BreakoutPush.routeDisabled[route] then
        return false, BreakoutPush.routeDisabled[route]
    end
    local ok, result = pcall(fn)
    if not ok then
        BreakoutPush.routeDisabled[route] = tostring(result)
        print("[XNP BREAKOUT ROUTE] disabled route=" .. tostring(route) .. " reason=" .. tostring(result))
        return false, result
    end
    return true, result
end

local function normalize2(x, y)
    if not Constants.IsFiniteNumber(x) or not Constants.IsFiniteNumber(y) then
        return nil, nil
    end
    local len = math.sqrt(x * x + y * y)
    if len <= 0.000001 then
        return nil, nil
    end
    return x / len, y / len
end

local function vectorComponent(vector, key, getter)
    if not vector then
        return nil
    end
    if Constants.IsFiniteNumber(vector[key]) then
        return vector[key]
    end
    if type(vector[getter]) == "function" then
        local ok, value = pcall(function()
            return vector[getter](vector)
        end)
        if ok and Constants.IsFiniteNumber(value) then
            return value
        end
    end
    return nil
end

local function sameZ(player, zombie)
    if not player or not zombie or type(player.getZ) ~= "function" or type(zombie.getZ) ~= "function" then
        return false
    end
    return math.abs(player:getZ() - zombie:getZ()) <= 0.50
end

local function objectIsLiveZombie(obj)
    if not obj or type(instanceof) ~= "function" or not instanceof(obj, "IsoZombie") then
        return false
    end
    if safeBool(obj, "isDead") or safeBool(obj, "isOnFloor") or safeBool(obj, "isCrawling") or safeBool(obj, "isFakeDead") then
        return false
    end
    return true
end

local function targetKey(zombie)
    if not zombie then
        return nil
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
    local objectKey = tostring(zombie)
    if objectKey and objectKey ~= "" and objectKey ~= "nil" then
        if not BreakoutPush.zombieKeyFallbackLogged then
            BreakoutPush.zombieKeyFallbackLogged = true
            print("[XNP ZOMBIE KEY] method=LOCAL_OBJECT_FALLBACK sample=" .. tostring(objectKey))
        end
        return "local:" .. objectKey
    end
    local key = BreakoutPush.localZombieKeys[zombie]
    if not key then
        key = "local_seq:" .. tostring(BreakoutPush.nextLocalZombieId)
        BreakoutPush.nextLocalZombieId = BreakoutPush.nextLocalZombieId + 1
        BreakoutPush.localZombieKeys[zombie] = key
    end
    return key
end

local function logConfigOnce()
    if BreakoutPush.configLogged then
        return
    end
    BreakoutPush.configLogged = true
    if Core.VerifiedStaggerControl and Core.VerifiedStaggerControl.LogConfigOnce then
        Core.VerifiedStaggerControl.LogConfigOnce()
    end
    print("[XNP BREAKOUT] method=FULL_SPRINT_IMMUNITY_STRICT_CONTACT")
    print("[XNP CONTACT GATE] strict_contact_enabled=" .. tostring(Config.STRICT_CONTACT_ENABLED == true))
    print(string.format("[XNP BREAKOUT] predictor closing_frames=%d sprint_min_speed=%.2f front_dot=%.2f cooldown=%.2f", Config.PRECOLLISION_REQUIRED_CLOSING_FRAMES, Config.PRECOLLISION_SPRINT_MIN_SPEED, Config.PRECOLLISION_FRONT_DOT_MIN, Config.BREAKOUT_COOLDOWN))
    Core.LogThrottle.Blocked("BREAKOUT_CONFIG", "RANGE_ONLY_TRIGGER_FALSE")
    print("[XNP BREAKOUT] success_requires_player_stayed_up=true")
    print("[XNP BREAKOUT] zombie_recovery_watchdog=true")
    print("[XNP BREAKOUT] zombie_recovery_strict_confirmation=true")
    Core.LogThrottle.Blocked("BREAKOUT_CONFIG", "PROFILE_PUSH_STRATEGY_FALSE")
    print("[XNP BREAKOUT] visible_is_not_success=true")
    print("[XNP SPRINT ROUTE] preserved_verified_stagger=true")
    print("[XNP SPRINT ROUTE] source=PRESERVED_STRICT_CONTACT")
    print("[XNP SPRINT ROUTE] first_wave_knockdown_capable=true")
    print("[XNP SPRINT ROUTE] preserved=true")
    print("[XNP SPRINT ROUTE] balance=FIRST_WAVE_IMPACT_KEEP")
    print("[XNP SPRINT ROUTE] action_bus=true")
    print("[XNP SPRINT ROUTE] first_wave_knockdown_boost=true")
    print("[XNP SPRINT ROUTE] max_targets=" .. tostring(Config.SPRINT_SWEEP_MAX_TARGETS) .. " primary_knockdown=" .. tostring(Config.SPRINT_SWEEP_PRIMARY_KNOCKDOWN_TARGETS) .. " outer_stagger=" .. tostring(Config.SPRINT_SWEEP_OUTER_STAGGER_TARGETS))
        print("[XNP CONTACT GATE] tune=drag_capture_native_trip_impact dist_max=" .. fmt(Config.CONTACT_TRIGGER_MAX_DISTANCE) .. " dot_min=" .. fmt(Config.CONTACT_TRIGGER_FRONT_DOT_MIN) .. " cooldown=" .. fmt(Config.CONTACT_COOLDOWN))
    print(string.format("[XNP BREAKOUT] sprint_speed_min=%.2f", Config.PRECOLLISION_SPRINT_MIN_SPEED))
    print(string.format("[XNP BREAKOUT] contact_dot_min=%.2f", Config.CONTACT_TRIGGER_FRONT_DOT_MIN))
    print(string.format("[XNP BREAKOUT] crowd_min_zombies=%d", Config.CROWD_BREAKOUT_MIN_ZOMBIES))
    print(string.format("[XNP BREAKOUT] outcome_watch_window=%.2f", Config.PLAYER_OUTCOME_WATCHDOG_WINDOW))
end

local function recordSkip(reason)
    local window = Config.SKIP_LOG_WINDOW_FRAMES or 60
    BreakoutPush.skipLogWindowFrame = BreakoutPush.skipLogWindowFrame + 1
    if reason == "NOT_CLOSING" then
        BreakoutPush.skipLogNotClosing = BreakoutPush.skipLogNotClosing + 1
    elseif reason == "BAD_DOT" then
        BreakoutPush.skipLogBadDot = BreakoutPush.skipLogBadDot + 1
    elseif reason == "LOW_SPEED_FOR_SPRINT" then
        BreakoutPush.skipLogLowSpeed = BreakoutPush.skipLogLowSpeed + 1
    elseif reason == "TOO_LATE" then
        BreakoutPush.skipLogTooLate = BreakoutPush.skipLogTooLate + 1
    end
    if BreakoutPush.skipLogWindowFrame >= window then
        print(string.format("[XNP BREAKOUT SKIP SUMMARY] not_closing=%d bad_dot=%d low_speed=%d too_late=%d window_frames=%d", BreakoutPush.skipLogNotClosing, BreakoutPush.skipLogBadDot, BreakoutPush.skipLogLowSpeed, BreakoutPush.skipLogTooLate, window))
        print("[XNP SPRINT FAIL SUMMARY] too_late=" .. tostring(BreakoutPush.skipLogTooLate) .. " fell_after_stagger=see_outcome_watchdog window_frames=" .. tostring(window))
        BreakoutPush.skipLogWindowFrame = 0
        BreakoutPush.skipLogNotClosing = 0
        BreakoutPush.skipLogBadDot = 0
        BreakoutPush.skipLogLowSpeed = 0
        BreakoutPush.skipLogTooLate = 0
    end
end

local function logSummary(currentTime)
    if not Config.IMPACT_DEBUG_LOG then
        return
    end
    if BreakoutPush.lastSummaryTime == 0 then
        BreakoutPush.lastSummaryTime = currentTime
        return
    end
    if currentTime - BreakoutPush.lastSummaryTime < Config.IMPACT_SUMMARY_LOG_INTERVAL then
        return
    end
    BreakoutPush.lastSummaryTime = currentTime
    if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
    BreakoutPush.attempts = 0
    BreakoutPush.triggered = 0
    BreakoutPush.visible = 0
    BreakoutPush.successPlayerStayedUp = 0
    BreakoutPush.failPlayerFellAfterPush = 0
    BreakoutPush.failZombieAiStuck = 0
    BreakoutPush.sprintPrecollision = 0
    BreakoutPush.contact = 0
    BreakoutPush.grab = 0
    BreakoutPush.crowd = 0
    BreakoutPush.blockedNotClosing = 0
    BreakoutPush.blockedBadDot = 0
    BreakoutPush.blockedDistance = 0
    BreakoutPush.blockedNoContact = 0
    BreakoutPush.blockedNoMovementIntent = 0
    BreakoutPush.blockedLowSpeedForSprint = 0
    BreakoutPush.blockedEndurance = 0
    BreakoutPush.blockedPlayerDown = 0
    BreakoutPush.blockedContactWalk = 0
    BreakoutPush.blockedContactSide = 0
    BreakoutPush.blockedContactLowSpeed = 0
    BreakoutPush.blockedPlayerRecoveryState = 0
    BreakoutPush.contactJogFront = 0
    BreakoutPush.blockedCooldown = 0
    BreakoutPush.blockedSameZombie = 0
    BreakoutPush.blockedNotRearmed = 0
    BreakoutPush.recoveryRegistered = 0
    BreakoutPush.recoveryNotStuck = 0
    BreakoutPush.recoverySuspicious = 0
end

function BreakoutPush.IsEnabled()
    return not BreakoutPush.disabled and Config.ENABLE_MOD and Config.ENABLE_BREAKOUT_PUSH
end

function BreakoutPush.HasTrait(player)
    return player ~= nil and Core.Trait and Core.Trait.PlayerHasTrait(player)
end

function BreakoutPush.GetPlayerSpeed(player)
    if not player or type(player.getX) ~= "function" or type(player.getY) ~= "function" then
        return 0
    end
    local currentTime = nowSeconds()
    local x = player:getX()
    local y = player:getY()
    if BreakoutPush.lastX == nil or BreakoutPush.lastY == nil or BreakoutPush.lastSpeedTime <= 0 then
        BreakoutPush.lastX = x
        BreakoutPush.lastY = y
        BreakoutPush.lastSpeedTime = currentTime
        BreakoutPush.lastSpeed = 0
        return 0
    end
    local dt = currentTime - BreakoutPush.lastSpeedTime
    if dt <= 0 then
        return BreakoutPush.lastSpeed
    end
    local dx = x - BreakoutPush.lastX
    local dy = y - BreakoutPush.lastY
    BreakoutPush.lastX = x
    BreakoutPush.lastY = y
    BreakoutPush.lastSpeedTime = currentTime
    BreakoutPush.lastSpeed = math.sqrt(dx * dx + dy * dy) / dt
    return BreakoutPush.lastSpeed
end

function BreakoutPush.GetForwardVector(player)
    if player and type(player.getForwardDirection) == "function" then
        local ok, vector = pcall(function()
            return player:getForwardDirection()
        end)
        if ok and vector then
            return normalize2(vectorComponent(vector, "x", "getX"), vectorComponent(vector, "y", "getY"))
        end
    end
    return nil, nil
end

function BreakoutPush.HasMovementIntent(player)
    if not player then
        return false
    end
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    if safeBool(player, "isSprinting") or safeBool(player, "isRunning") then
        return true
    end
    if string.find(text, "run", 1, true) or string.find(text, "sprint", 1, true) or string.find(text, "jog", 1, true) or string.find(text, "walk", 1, true) then
        return true
    end
    return BreakoutPush.lastSpeed > Config.PRECOLLISION_MIN_PLAYER_SPEED
end

local function playerIsDown(player)
    if not player then
        return true
    end
    if safeBool(player, "isDead") or safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown") then
        return true
    end
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    return string.find(text, "fall", 1, true) ~= nil or string.find(text, "trip", 1, true) ~= nil
end

local function playerHasCollisionGrace(player)
    if not player then
        return false
    end
    if safeBool(player, "isBumped") then
        return true
    end
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    return string.find(text, "bump", 1, true) ~= nil or string.find(text, "collid", 1, true) ~= nil
end

local function playerLooksGrabbedOrAttacked(player)
    if not player then
        return false
    end
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    if string.find(text, "grab", 1, true) or string.find(text, "grapple", 1, true) or string.find(text, "bite", 1, true) or string.find(text, "scratch", 1, true) or string.find(text, "attack", 1, true) or string.find(text, "hitreaction", 1, true) then
        return true
    end
    return playerHasCollisionGrace(player)
end

local function computeInfo(player, zombie)
    if not player or not zombie or type(player.getX) ~= "function" or type(player.getY) ~= "function" or type(zombie.getX) ~= "function" or type(zombie.getY) ~= "function" then
        return nil
    end
    local dx = zombie:getX() - player:getX()
    local dy = zombie:getY() - player:getY()
    local awayX, awayY = normalize2(dx, dy)
    if not awayX or not awayY then
        awayX, awayY = BreakoutPush.GetForwardVector(player)
    end
    if not awayX or not awayY then
        return nil
    end
    local dist = math.sqrt(dx * dx + dy * dy)
    local fx, fy = BreakoutPush.GetForwardVector(player)
    local dot = -1
    if fx and fy then
        dot = fx * awayX + fy * awayY
    end
    return { distance = dist, dot = dot, awayX = awayX, awayY = awayY, forwardX = fx, forwardY = fy }
end

local function updateZombieApproachHistory(zombie, info, currentTime)
    local key = targetKey(zombie)
    if not key then
        return nil
    end
    local history = BreakoutPush.zombieHistory[key]
    if not history then
        history = {
            lastDistance = info.distance,
            lastTime = currentTime,
            closingFrames = 0,
            lastDelta = 0,
            lastDot = info.dot,
        }
        BreakoutPush.zombieHistory[key] = history
        return history
    end
    local delta = history.lastDistance - info.distance
    if delta >= Config.PRECOLLISION_MIN_DISTANCE_DELTA then
        history.closingFrames = math.min(history.closingFrames + 1, 20)
    else
        history.closingFrames = 0
    end
    history.lastDelta = delta
    history.lastDistance = info.distance
    history.lastTime = currentTime
    history.lastDot = info.dot
    return history
end

local function collectNearbyZombies(player, radius, currentTime, recordHistory)
    local result = {}
    if not player then
        return result
    end
    local zombies = nil
    if recordHistory == true then
        if not Core.ImpactCandidateSnapshot.ClaimEvaluation("SPRINT_PRECOLLISION") then
            return result
        end
        zombies = Core.ImpactCandidateSnapshot.GetRawLocalImpactCandidates()
    elseif Core.ThreatSnapshot then
        zombies = Core.ThreatSnapshot.GetNearbyZombies(radius)
    end
    if not zombies then return result end
    for i = 1, #zombies do
        local obj = zombies[i]
        if objectIsLiveZombie(obj) and sameZ(player, obj) then
            local info = computeInfo(player, obj)
            if info and info.distance <= radius then
                local history = recordHistory == true and updateZombieApproachHistory(obj, info, currentTime) or BreakoutPush.zombieHistory[targetKey(obj)]
                local candidate = { zombie = obj, info = info, history = history }
                local inserted = false
                for j = 1, #result do
                    if info.dot > result[j].info.dot or (info.dot == result[j].info.dot and info.distance < result[j].info.distance) then
                        table.insert(result, j, candidate)
                        inserted = true
                        break
                    end
                end
                if not inserted then result[#result + 1] = candidate end
            end
        end
    end
    return result
end

local function candidateIsClosing(candidate)
    return candidate and candidate.history and candidate.history.closingFrames >= Config.PRECOLLISION_REQUIRED_CLOSING_FRAMES and candidate.history.lastDelta >= Config.PRECOLLISION_MIN_DISTANCE_DELTA
end

local function candidateHasGoodDot(candidate, requiredDot)
    return candidate and candidate.info and candidate.info.dot >= requiredDot
end

local function movementText(player)
    return safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
end

local function contactGate(player, candidate, speed)
    local info = candidate and candidate.info
    local text = movementText(player)
    if Core.MovementIntentGate and Core.MovementIntentGate.CanContactPush then
        local gateOk, reason, intent = Core.MovementIntentGate.CanContactPush(player, { source = "BREAKOUT_CONTACT", speed = speed })
        if not gateOk then
            BreakoutPush.blockedContactWalk = BreakoutPush.blockedContactWalk + 1
            if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            Core.LogThrottle.Blocked("BREAKOUT", reason)
            if Core.BreakoutActionBus and Core.BreakoutActionBus.BlockMovementGate then
                Core.BreakoutActionBus.BlockMovementGate("BREAKOUT_CONTACT", reason)
            end
            return false
        end
    end
    if string.find(text, "getup", 1, true) or string.find(text, "fall", 1, true) or string.find(text, "trip", 1, true) then
        BreakoutPush.blockedPlayerRecoveryState = BreakoutPush.blockedPlayerRecoveryState + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    if not info then
        BreakoutPush.blockedDistance = BreakoutPush.blockedDistance + 1
        return false
    end
    if info.distance > Config.CONTACT_TRIGGER_MAX_DISTANCE then
        BreakoutPush.blockedDistance = BreakoutPush.blockedDistance + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    if info.distance < Config.CONTACT_TRIGGER_MIN_DISTANCE then
        BreakoutPush.blockedDistance = BreakoutPush.blockedDistance + 1
        return false
    end
    if info.dot < Config.CONTACT_TRIGGER_FRONT_DOT_MIN then
        BreakoutPush.blockedContactSide = BreakoutPush.blockedContactSide + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    if speed < Config.CONTACT_MIN_PLAYER_SPEED then
        BreakoutPush.blockedContactLowSpeed = BreakoutPush.blockedContactLowSpeed + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    if speed > Config.CONTACT_MAX_PLAYER_SPEED then
        BreakoutPush.blockedContactLowSpeed = BreakoutPush.blockedContactLowSpeed + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    if not candidateIsClosing(candidate) or not candidate.history or candidate.history.closingFrames < Config.CONTACT_CLOSING_FRAMES_REQUIRED then
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local now = nowSeconds()
    if Config.CONTACT_TRIGGER_RATE_LIMIT_ENABLED and now - BreakoutPush.lastContactTime < Config.CONTACT_COOLDOWN then
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local running = safeBool(player, "isRunning")
    local jogText = string.find(text, "run", 1, true) ~= nil or string.find(text, "jog", 1, true) ~= nil
    local plainMovement = text == "movement " or text == "movement movement" or (string.find(text, "movement", 1, true) ~= nil and not jogText and not running)
    if Config.CONTACT_REJECT_PLAIN_MOVEMENT and plainMovement then
        BreakoutPush.blockedContactWalk = BreakoutPush.blockedContactWalk + 1
        Core.LogThrottle.Blocked("CONTACT_GATE", "WALKING_NOT_JOGGING")
        return false
    end
    if Config.CONTACT_REQUIRES_JOG and not running and not jogText then
        BreakoutPush.blockedContactWalk = BreakoutPush.blockedContactWalk + 1
        Core.LogThrottle.Blocked("CONTACT_GATE", "WALKING_NOT_JOGGING")
        return false
    end
    BreakoutPush.contactJogFront = BreakoutPush.contactJogFront + 1
    BreakoutPush.lastContactTime = now
    print("[XNP CONTACT GATE] state=PASS reason=JOG_FRONT_CLOSE_CONTACT speed=" .. fmt(speed) .. " dot=" .. fmt(info.dot) .. " dist=" .. fmt(info.distance))
    print("[XNP CONTACT PROFILE] effect=STAGGER_ONLY no_knockdown=true")
    return true
end

local function recordSpeedSample(speed, sprintCandidate, contactCandidate)
    if not Config.SPEED_SAMPLE_SUMMARY_ENABLED then
        return
    end
    BreakoutPush.speedSampleFrame = BreakoutPush.speedSampleFrame + 1
    if sprintCandidate then
        BreakoutPush.speedSampleSprintFrames = BreakoutPush.speedSampleSprintFrames + 1
    end
    if contactCandidate then
        BreakoutPush.speedSampleJogFrames = BreakoutPush.speedSampleJogFrames + 1
    end
    if speed > BreakoutPush.speedSampleMaxSpeed then
        BreakoutPush.speedSampleMaxSpeed = speed
    end
    if BreakoutPush.speedSampleFrame >= 60 then
            print("[XNP SPEED SAMPLE SUMMARY] sprint_frames=" .. tostring(BreakoutPush.speedSampleSprintFrames) .. " jog_frames=" .. tostring(BreakoutPush.speedSampleJogFrames) .. " max_speed=" .. fmt(BreakoutPush.speedSampleMaxSpeed) .. " window=sampled")
        BreakoutPush.speedSampleFrame = 0
        BreakoutPush.speedSampleSprintFrames = 0
        BreakoutPush.speedSampleJogFrames = 0
        BreakoutPush.speedSampleMaxSpeed = 0
    end
end

function BreakoutPush.DetectPrecollisionTrigger(player, currentTime)
    if not Config.ENABLE_PRECOLLISION_PREDICTOR or not BreakoutPush.HasMovementIntent(player) then
        return nil
    end
    local candidates = collectNearbyZombies(player, Config.PRECOLLISION_SCAN_RADIUS, currentTime, true)
    local sawClose = false
    local sawClosing = false
    local sawBadDot = false
    local sawLowSprintSpeed = false
    local sawTooLateForSprint = false
    for _, candidate in ipairs(candidates) do
        local info = candidate.info
        if info.distance < 0.85 and BreakoutPush.lastSpeed >= Config.PRECOLLISION_SPRINT_MIN_SPEED then
            sawTooLateForSprint = true
        end
        if info.distance >= Config.PRECOLLISION_MIN_DISTANCE and info.distance <= Config.PRECOLLISION_MAX_DISTANCE then
            sawClose = true
            if candidateIsClosing(candidate) then
                sawClosing = true
                if candidateHasGoodDot(candidate, Config.CONTACT_SIDE_REJECT_DOT or Config.CONTACT_TRIGGER_FRONT_DOT_MIN) then
                    local speed = BreakoutPush.lastSpeed
                    local sprintCandidate = safeBool(player, "isSprinting") or speed >= Config.PRECOLLISION_SPRINT_MIN_SPEED
                    local contactCandidate = speed >= Config.CONTACT_MIN_PLAYER_SPEED and speed <= Config.CONTACT_MAX_PLAYER_SPEED
                    recordSpeedSample(speed, sprintCandidate and speed >= Config.PRECOLLISION_SPRINT_MIN_SPEED, contactCandidate)
                    if Config.SPEED_SAMPLE_DEBUG then
                        print(string.format("[XNP SPEED SAMPLE] speed=%s movement=%s sprint_candidate=%s contact_candidate=%s", fmt(speed), safeString(player, "getActionStateName"), tostring(sprintCandidate and speed >= Config.PRECOLLISION_SPRINT_MIN_SPEED), tostring(contactCandidate)))
                    end
                    local legacySprint = Core.VerifiedImpactPath.EvaluateSprintPrecollision(
                        info.distance,
                        info.dot,
                        candidate.history and candidate.history.closingFrames or 0,
                        speed,
                        safeBool(player, "isSprinting")
                    )
                    if legacySprint then
                        if Core.MovementIntentGate and Core.MovementIntentGate.CanSprintVehicle then
                            local sprintOk, sprintReason = Core.MovementIntentGate.CanSprintVehicle(player, { source = "SPRINT_PRECOLLISION", speed = speed })
                            if not sprintOk then
                                Core.LogThrottle.Blocked("BREAKOUT", sprintReason)
                                return nil
                            end
                        end
                        Core.ImpactCandidateSnapshot.RecordPrecollisionEligible(candidate)
                        return { type = "SPRINT_PRECOLLISION", targets = { candidate }, info = info, reason = "PREDICTED_COLLISION" }
                    end
                    if contactCandidate and contactGate(player, candidate, speed) then
                        return { type = "CONTACT", targets = { candidate }, info = info, reason = "CLOSING_CONTACT" }
                    end
                    if speed < Config.PRECOLLISION_SPRINT_MIN_SPEED then
                        sawLowSprintSpeed = true
                    end
                else
                    sawBadDot = true
                end
            end
        end
    end
    if sawBadDot then
        BreakoutPush.blockedBadDot = BreakoutPush.blockedBadDot + 1
        recordSkip("BAD_DOT")
    elseif sawLowSprintSpeed then
        BreakoutPush.blockedLowSpeedForSprint = BreakoutPush.blockedLowSpeedForSprint + 1
        recordSkip("LOW_SPEED_FOR_SPRINT")
    elseif sawTooLateForSprint then
        BreakoutPush.blockedDistance = BreakoutPush.blockedDistance + 1
        recordSkip("TOO_LATE")
    elseif sawClose and not sawClosing then
        BreakoutPush.blockedNotClosing = BreakoutPush.blockedNotClosing + 1
        recordSkip("NOT_CLOSING")
    elseif #candidates == 0 then
        BreakoutPush.blockedNoContact = BreakoutPush.blockedNoContact + 1
    end
    return nil
end

function BreakoutPush.DetectGrabTrigger(player, currentTime)
    if not Config.ENABLE_GRAB_BREAKOUT_TRIGGER or playerIsDown(player) then
        return nil
    end
    local danger = playerLooksGrabbedOrAttacked(player)
    local candidates = collectNearbyZombies(player, Config.GRAB_BREAKOUT_RADIUS, currentTime, false)
    if danger and #candidates > 0 then
        if Core.MovementIntentGate and Core.MovementIntentGate.CanControlledEscape then
            local gateOk, reason = Core.MovementIntentGate.CanControlledEscape(player, { source = "GRAB", controlled = true, reason = "GRAB_OR_ATTACK_WINDOW", speed = BreakoutPush.lastSpeed })
            if not gateOk then
                Core.LogThrottle.Blocked("BREAKOUT", reason)
                return nil
            end
        end
        return { type = "GRAB", targets = candidates, info = candidates[1].info, reason = "GRAB_OR_ATTACK_WINDOW" }
    end
    return nil
end

function BreakoutPush.DetectCrowdTrigger(player, currentTime)
    if not Config.ENABLE_CROWD_BREAKOUT_TRIGGER or not BreakoutPush.HasMovementIntent(player) or playerIsDown(player) then
        return nil
    end
    local candidates = collectNearbyZombies(player, Config.CROWD_BREAKOUT_RADIUS, currentTime, false)
    if #candidates >= Config.CROWD_BREAKOUT_MIN_ZOMBIES and BreakoutPush.lastSpeed <= Config.CROWD_STALLED_SPEED_MAX then
        if Core.MovementIntentGate and Core.MovementIntentGate.CanControlledEscape then
            local gateOk, reason = Core.MovementIntentGate.CanControlledEscape(player, { source = "CROWD", controlled = true, reason = "CROWD_OR_TOUCHING", speed = BreakoutPush.lastSpeed })
            if not gateOk then
                Core.LogThrottle.Blocked("BREAKOUT", reason)
                return nil
            end
        end
        return { type = "CROWD", targets = candidates, info = candidates[1].info, reason = "CROWD_STALLED" }
    end
    return nil
end

function BreakoutPush.FindBreakoutTargets(player, trigger, currentTime)
    local triggerType = trigger.type
    local radius = Config.PRECOLLISION_SCAN_RADIUS
    local maxCount = 1
    if triggerType == "GRAB" then
        radius = Config.GRAB_BREAKOUT_RADIUS
        maxCount = Config.GRAB_BREAKOUT_MAX_ZOMBIES
    elseif triggerType == "CROWD" then
        radius = Config.CROWD_BREAKOUT_RADIUS
        maxCount = Config.CROWD_BREAKOUT_MAX_ZOMBIES
    end
    local found = trigger.targets or collectNearbyZombies(player, radius, currentTime, false)
    local targets = {}
    for i = 1, math.min(#found, maxCount) do
        table.insert(targets, found[i])
    end
    return targets
end

function BreakoutPush.ComputePushVector(player, zombie, triggerType)
    local info = computeInfo(player, zombie)
    if not info then
        return nil
    end
    if triggerType == "CONTACT" or triggerType == "SPRINT_PRECOLLISION" then
        if info.forwardX and info.forwardY then
            return { x = info.forwardX, y = info.forwardY, source = "PLAYER_FORWARD", info = info }
        end
    end
    return { x = info.awayX, y = info.awayY, source = triggerType == "GRAB" and "BREAKOUT_AWAY_FROM_PLAYER" or "PLAYER_TO_ZOMBIE", info = info }
end

local function costForTrigger(triggerType)
    if Core.CostTuning and Core.CostTuning.ComputeFinalCost then
        if triggerType == "SPRINT_PRECOLLISION" then
            return Core.CostTuning.ComputeFinalCost("SPRINT_PRECOLLISION", Config.SPRINT_PRECOLLISION_BASE_COST)
        elseif triggerType == "CONTACT" then
            return Core.CostTuning.ComputeFinalCost("JOG_BUMP", Config.CONTACT_PUSH_ENDURANCE_COST)
        elseif triggerType == "GRAB" then
            return Core.CostTuning.ComputeFinalCost("CONTROLLED_ESCAPE", Config.GRAB_BREAKOUT_ENDURANCE_COST)
        elseif triggerType == "CROWD" then
            return Core.CostTuning.ComputeFinalCost("CONTROLLED_ESCAPE", Config.CROWD_BREAKOUT_ENDURANCE_COST)
        end
    end
    if triggerType == "GRAB" then
        return Config.GRAB_BREAKOUT_ENDURANCE_COST
    elseif triggerType == "CROWD" then
        return Config.CROWD_BREAKOUT_ENDURANCE_COST
    elseif triggerType == "SPRINT_PRECOLLISION" then
        return Config.SPRINT_PRECOLLISION_BASE_COST
    end
    return Config.CONTACT_PUSH_ENDURANCE_COST
end

function BreakoutPush.ApplyCost(player, triggerType, actionId)
    if not player or type(player.getStats) ~= "function" or not CharacterStat or not CharacterStat.ENDURANCE then
        BreakoutPush.blockedEndurance = BreakoutPush.blockedEndurance + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local stats = player:getStats()
    if not stats or type(stats.get) ~= "function" or type(stats.set) ~= "function" then
        BreakoutPush.blockedEndurance = BreakoutPush.blockedEndurance + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local before = stats:get(CharacterStat.ENDURANCE)
    if not Constants.IsFiniteNumber(before) then
        BreakoutPush.blockedEndurance = BreakoutPush.blockedEndurance + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local minRequired = triggerType == "GRAB" and Config.GRAB_BREAKOUT_REQUIRE_ENDURANCE or Config.SHOULDER_CHECK_MIN_ENDURANCE
    if before < minRequired then
        BreakoutPush.blockedEndurance = BreakoutPush.blockedEndurance + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local cost = costForTrigger(triggerType)
    local after = math.max(Config.MIN_ENDURANCE_FLOOR, before - cost)
    if not Core.Authority or not Core.Authority.CanWriteNonFoodStats(player, "BREAKOUT_PUSH") then
        return false
    end
    stats:set(CharacterStat.ENDURANCE, after)
    if Core.LongMigrationStaminaAssist and Core.LongMigrationStaminaAssist.NotifySkillCost then
        Core.LongMigrationStaminaAssist.NotifySkillCost(triggerType, Config.BREAKOUT_COST_REFUND_IGNORE_WINDOW or 0.50)
    end
    print("[XNP BREAKOUT COST] type=" .. tostring(triggerType) .. " before=" .. fmt(before) .. " after=" .. fmt(after) .. " cost=" .. fmt(cost) .. " result=APPLIED")
    print("[XNP COST] type=" .. tostring(triggerType) .. " before=" .. fmt(before) .. " after=" .. fmt(after) .. " cost=" .. fmt(cost))
    if actionId ~= nil then
        print("[XNP COST] charged action_id=" .. tostring(actionId))
    end
    print("[XNP COST] no_bite=true no_infection=true no_heal=true")
    return true
end

local function squareIsPassable(square)
    if not square then
        return false
    end
    if type(square.isFree) == "function" then
        local ok, value = pcall(function()
            return square:isFree(false)
        end)
        if ok then
            return value == true
        end
    end
    if type(square.isSolid) == "function" then
        local ok, value = pcall(function()
            return square:isSolid()
        end)
        if ok and value == true then
            return false
        end
    end
    return true
end

function BreakoutPush.TryInterruptZombie(zombie, triggerId, triggerType)
    if not Config.BREAKOUT_USE_AI_INTERRUPT or not zombie then
        return false
    end
    local ok = false
    if type(zombie.setHitReaction) == "function" then
        ok = safeCall("BREAKOUT_AI_INTERRUPT_setHitReaction", function()
            zombie:setHitReaction("StaggerBack")
        end) or ok
    end
    if type(zombie.setStaggerBack) == "function" then
        ok = safeCall("BREAKOUT_AI_INTERRUPT_setStaggerBack", function()
            zombie:setStaggerBack(true)
        end) or ok
    end
    print("[XNP BREAKOUT INTERRUPT] mode=SHORT_PULSE trigger_id=" .. tostring(triggerId) .. " type=" .. tostring(triggerType) .. " result=" .. tostring(ok))
    return ok
end

function BreakoutPush.RegisterZombieRecoveryWatchdog(zombie, triggerId, triggerType, currentTime, methodUsed, usedReaction, usedNudge, usedInterrupt)
    if not Config.ZOMBIE_RECOVERY_WATCHDOG_ENABLED or not zombie or type(zombie.getX) ~= "function" or type(zombie.getY) ~= "function" then
        return
    end
    local key = targetKey(zombie)
    local x = zombie:getX()
    local y = zombie:getY()
    table.insert(BreakoutPush.pendingZombieWatchdogs, {
        zombie = zombie,
        key = key,
        triggerId = triggerId,
        triggerType = triggerType,
        methodUsed = methodUsed,
        usedReaction = usedReaction == true,
        usedNudge = usedNudge == true,
        usedInterrupt = usedInterrupt == true,
        startX = x,
        startY = y,
        lastX = x,
        lastY = y,
        checkCount = 0,
        startTime = currentTime,
        expireTime = currentTime + Config.ZOMBIE_RECOVERY_WATCHDOG_WINDOW,
    })
    BreakoutPush.recoveryRegistered = BreakoutPush.recoveryRegistered + 1
    print("[XNP ZOMBIE RECOVERY] registered trigger_id=" .. tostring(triggerId) .. " zombie=" .. tostring(key) .. " type=" .. tostring(triggerType) .. " reaction=" .. tostring(usedReaction == true) .. " nudge=" .. tostring(usedNudge == true) .. " interrupt=" .. tostring(usedInterrupt == true) .. " strict=true")
end

function BreakoutPush.BuildPushProfile(triggerType, reactionAvailable)
    return {
        reaction = false,
        nudge = false,
        interrupt = false,
        reason = "DISABLED_FOR_ICON_RECOVERY_DRAGDOWN_BREAKOUT",
        interruptMode = "NONE",
    }
end

function BreakoutPush.ApplyReaction(zombie)
    local reaction = false
    if Config.BREAKOUT_USE_ZOMBIE_HIT_REACTION and type(zombie.setHitReaction) == "function" then
        reaction = safeCall("BREAKOUT_HIT_REACTION", function()
            zombie:setHitReaction("StaggerBack")
        end) or reaction
    end
    if type(zombie.setStaggerBack) == "function" then
        reaction = safeCall("BREAKOUT_STAGGER_BACK", function()
            zombie:setStaggerBack(true)
        end) or reaction
    end
    if type(zombie.setHitForce) == "function" then
        reaction = safeCall("BREAKOUT_HIT_FORCE", function()
            zombie:setHitForce(1.5)
        end) or reaction
    end
    return reaction
end

function BreakoutPush.ApplyPushProfile(player, zombie, vector, triggerType, currentTime, triggerId)
    local controlType = triggerType == "GRAB" and "GRAB_PREBITE" or triggerType
    local profileReason = "VERIFIED_STAGGER_CONTROL"
    if triggerType == "SPRINT_PRECOLLISION" then
        profileReason = "VERIFIED_STAGGER_KNOCKDOWN"
    elseif triggerType == "CONTACT" then
        profileReason = "LIGHT_VERIFIED_STAGGER"
    elseif triggerType == "GRAB" then
        profileReason = "GRAB_PREBITE_BREAK_VERIFIED_STAGGER"
    elseif triggerType == "CROWD" then
        profileReason = "CROWD_LIGHT_VERIFIED_STAGGER"
    end

    local visible = false
    local effect = "none"
    if Core.VerifiedStaggerControl and Core.VerifiedStaggerControl.Apply then
        visible, effect = Core.VerifiedStaggerControl.Apply(player, zombie, controlType, {
            triggerId = triggerId,
            vector = vector,
        })
    else
        print("[XNP STAGGER CONTROL FAIL] reason=MODULE_NOT_LOADED trigger_id=" .. tostring(triggerId))
    end

    print("[XNP BREAKOUT PROFILE] type=" .. tostring(triggerType) .. " control=" .. tostring(profileReason) .. " nudge=0 interrupt=0")
    print("[XNP BREAKOUT PUSH] trigger_id=" .. tostring(triggerId) .. " control=" .. tostring(effect) .. " nudge=skip interrupt=skip visible=" .. tostring(visible) .. " success=pending")
    BreakoutPush.RegisterZombieRecoveryWatchdog(zombie, triggerId, triggerType, currentTime, profileReason, visible, false, false)
    return visible
end

function BreakoutPush.NextTriggerId()
    BreakoutPush.triggerSeq = BreakoutPush.triggerSeq + 1
    return BreakoutPush.triggerSeq
end

local function playerOutcomeFailed(player)
    return playerIsDown(player) or playerHasCollisionGrace(player)
end

function BreakoutPush.RegisterPlayerOutcomeWatchdog(triggerId, triggerType, currentTime)
    if not Config.PLAYER_OUTCOME_WATCHDOG_ENABLED then
        return
    end
    table.insert(BreakoutPush.pendingPlayerWatchdogs, {
        triggerId = triggerId,
        triggerType = triggerType,
        startTime = currentTime,
        expireTime = currentTime + Config.PLAYER_OUTCOME_WATCHDOG_WINDOW,
        failed = false,
    })
    print("[XNP BREAKOUT OUTCOME] registered trigger_id=" .. tostring(triggerId) .. " type=" .. tostring(triggerType) .. " window=" .. fmt(Config.PLAYER_OUTCOME_WATCHDOG_WINDOW))
end

function BreakoutPush.TryRecoverZombie(zombie)
    local recovered = false
    if zombie and type(zombie.setStaggerBack) == "function" then
        recovered = safeCall("ZOMBIE_RECOVERY_setStaggerBack_false", function()
            zombie:setStaggerBack(false)
        end) or recovered
    end
    if zombie and type(zombie.setHitReaction) == "function" then
        recovered = safeCall("ZOMBIE_RECOVERY_clearHitReaction", function()
            zombie:setHitReaction("")
        end) or recovered
    end
    return recovered
end

function BreakoutPush.UpdatePlayerOutcomeWatchdogs(player, currentTime)
    local keep = {}
    for _, watch in ipairs(BreakoutPush.pendingPlayerWatchdogs) do
        if playerOutcomeFailed(player) then
            BreakoutPush.failPlayerFellAfterPush = BreakoutPush.failPlayerFellAfterPush + 1
            if Core.VerifiedStaggerControl and Core.VerifiedStaggerControl.NotePlayerFall then
                Core.VerifiedStaggerControl.NotePlayerFall(watch.triggerType)
            end
            if watch.triggerType == "SPRINT_PRECOLLISION" then
                if Core.SprintTripImmunity and Core.SprintTripImmunity.NotifySprintFall then
                    Core.SprintTripImmunity.NotifySprintFall(player, watch.triggerId, "PLAYER_FELL_AFTER_STAGGER_CONTROL", { source = "BreakoutPush" })
                end
                print("[XNP BREAKOUT FAIL] reason=PLAYER_FELL_AFTER_STAGGER_CONTROL trigger_id=" .. tostring(watch.triggerId) .. " type=" .. tostring(watch.triggerType))
            else
                print("[XNP BREAKOUT FAIL] reason=PLAYER_FELL_AFTER_PUSH trigger_id=" .. tostring(watch.triggerId) .. " type=" .. tostring(watch.triggerType))
            end
        elseif currentTime >= watch.expireTime then
            BreakoutPush.successPlayerStayedUp = BreakoutPush.successPlayerStayedUp + 1
            print("[XNP BREAKOUT OUTCOME] result=PLAYER_STAYED_UP trigger_id=" .. tostring(watch.triggerId) .. " type=" .. tostring(watch.triggerType))
        else
            table.insert(keep, watch)
        end
    end
    BreakoutPush.pendingPlayerWatchdogs = keep
end

function BreakoutPush.UpdateZombieRecoveryWatchdogs(currentTime)
    local keep = {}
    for _, watch in ipairs(BreakoutPush.pendingZombieWatchdogs) do
        local zombie = watch.zombie
        if not zombie or safeBool(zombie, "isDead") then
            print("[XNP ZOMBIE RECOVERY] result=gone_or_dead trigger_id=" .. tostring(watch.triggerId) .. " zombie=" .. tostring(watch.key))
        elseif currentTime >= watch.expireTime then
            local moved = 0
            if type(zombie.getX) == "function" and type(zombie.getY) == "function" then
                local currentX = zombie:getX()
                local currentY = zombie:getY()
                local baseX = watch.postStartX or watch.startX
                local baseY = watch.postStartY or watch.startY
                local dx = currentX - baseX
                local dy = currentY - baseY
                moved = math.sqrt(dx * dx + dy * dy)
                watch.lastX = currentX
                watch.lastY = currentY
            end
            watch.checkCount = (watch.checkCount or 0) + 1
            local isOnFloor = safeBool(zombie, "isOnFloor")
            if watch.postWatch == true then
                if moved >= Config.ZOMBIE_RECOVERY_MIN_MOVED_DISTANCE or isOnFloor then
                    BreakoutPush.recoveryNotStuck = BreakoutPush.recoveryNotStuck + 1
                    print("[XNP ZOMBIE RECOVERY] result=confirmed_recovered trigger_id=" .. tostring(watch.triggerId) .. " zombie=" .. tostring(watch.key) .. " moved=" .. fmt(moved))
                else
                    BreakoutPush.failZombieAiStuck = BreakoutPush.failZombieAiStuck + 1
                    print("[XNP BREAKOUT FAIL] reason=ZOMBIE_AI_STUCK_AFTER_PUSH trigger_id=" .. tostring(watch.triggerId) .. " zombie=" .. tostring(watch.key) .. " moved=" .. fmt(moved))
                end
            elseif moved < Config.ZOMBIE_RECOVERY_MIN_MOVED_DISTANCE and not isOnFloor then
                BreakoutPush.recoverySuspicious = BreakoutPush.recoverySuspicious + 1
                print("[XNP ZOMBIE RECOVERY] suspicious_stuck trigger_id=" .. tostring(watch.triggerId) .. " zombie=" .. tostring(watch.key) .. " moved=" .. fmt(moved) .. " checks=" .. tostring(watch.checkCount))
                local recovered = BreakoutPush.TryRecoverZombie(zombie)
                if recovered then
                    watch.postWatch = true
                    watch.postStartX = watch.lastX
                    watch.postStartY = watch.lastY
                    watch.expireTime = currentTime + (Config.ZOMBIE_RECOVERY_POST_WATCH_WINDOW or 0.50)
                    print("[XNP ZOMBIE RECOVERY] recovery_attempted method=" .. tostring(watch.methodUsed) .. " trigger_id=" .. tostring(watch.triggerId) .. " zombie=" .. tostring(watch.key) .. " post_watch=0.50")
                    table.insert(keep, watch)
                else
                    BreakoutPush.failZombieAiStuck = BreakoutPush.failZombieAiStuck + 1
                    print("[XNP BREAKOUT FAIL] reason=ZOMBIE_AI_STUCK_AFTER_PUSH trigger_id=" .. tostring(watch.triggerId) .. " zombie=" .. tostring(watch.key))
                end
            else
                BreakoutPush.recoveryNotStuck = BreakoutPush.recoveryNotStuck + 1
                print("[XNP ZOMBIE RECOVERY] result=not_stuck trigger_id=" .. tostring(watch.triggerId) .. " zombie=" .. tostring(watch.key))
            end
        else
            watch.checkCount = (watch.checkCount or 0) + 1
            if type(zombie.getX) == "function" and type(zombie.getY) == "function" then
                watch.lastX = zombie:getX()
                watch.lastY = zombie:getY()
            end
            table.insert(keep, watch)
        end
    end
    BreakoutPush.pendingZombieWatchdogs = keep
end

function BreakoutPush.UpdateCooldowns(zombie, triggerType, currentTime)
    BreakoutPush.lastTriggerTime = currentTime
    if triggerType == "GRAB" then
        BreakoutPush.lastGrabTriggerTime = currentTime
    end
    BreakoutPush.targetLockUntil = currentTime + Config.BREAKOUT_COOLDOWN
    if zombie then
        local key = targetKey(zombie)
        BreakoutPush.lastTargetKey = key
        BreakoutPush.lastTargetTime[key] = currentTime
        BreakoutPush.rearmRequired = triggerType ~= "GRAB" and Config.CONTACT_REQUIRE_EXIT_RADIUS_BEFORE_RETRIGGER
    end
end

local function updateRearm(player, currentTime)
    if not BreakoutPush.rearmRequired or not BreakoutPush.lastTargetKey then
        return
    end
    local candidates = collectNearbyZombies(player, Config.CONTACT_REARM_EXIT_RADIUS, currentTime, false)
    for _, candidate in ipairs(candidates) do
        if targetKey(candidate.zombie) == BreakoutPush.lastTargetKey then
            return
        end
    end
    BreakoutPush.rearmRequired = false
end

local function triggerIsCoolingDown(triggerType, currentTime)
    if triggerType == "GRAB" and currentTime - BreakoutPush.lastGrabTriggerTime < Config.GRAB_BREAKOUT_COOLDOWN then
        return true
    end
    if triggerType == "CONTACT" and currentTime - BreakoutPush.lastTriggerTime < Config.CONTACT_COOLDOWN then
        return true
    end
    if currentTime < BreakoutPush.targetLockUntil then
        return true
    end
    return currentTime - BreakoutPush.lastTriggerTime < Config.BREAKOUT_COOLDOWN
end

local function selectTrigger(player, currentTime)
    local grab = BreakoutPush.DetectGrabTrigger(player, currentTime)
    if grab then
        return grab
    end
    local crowd = BreakoutPush.DetectCrowdTrigger(player, currentTime)
    if crowd then
        return crowd
    end
    return BreakoutPush.DetectPrecollisionTrigger(player, currentTime)
end

function BreakoutPush.Update(player)
    logConfigOnce()
    local currentTime = nowSeconds()
    logSummary(currentTime)
    BreakoutPush.UpdatePlayerOutcomeWatchdogs(player, currentTime)
    BreakoutPush.UpdateZombieRecoveryWatchdogs(currentTime)
    if not BreakoutPush.IsEnabled() then
        return false
    end
    BreakoutPush.attempts = BreakoutPush.attempts + 1
    BreakoutPush.GetPlayerSpeed(player)
    if not BreakoutPush.HasTrait(player) then
        return false
    end
    if playerIsDown(player) then
        BreakoutPush.blockedPlayerDown = BreakoutPush.blockedPlayerDown + 1
        if not BreakoutPush.playerDownLogged then
            BreakoutPush.playerDownLogged = true
            if Core.LogThrottle then Core.LogThrottle.Blocked("BREAKOUTPUSH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        end
        return false
    end
    BreakoutPush.playerDownLogged = false
    updateRearm(player, currentTime)
    local ok, err = pcall(function()
        local trigger = selectTrigger(player, currentTime)
        if not trigger then
            if not BreakoutPush.HasMovementIntent(player) then
                BreakoutPush.blockedNoMovementIntent = BreakoutPush.blockedNoMovementIntent + 1
            end
            return
        end
        if triggerIsCoolingDown(trigger.type, currentTime) then
            BreakoutPush.blockedCooldown = BreakoutPush.blockedCooldown + 1
            return
        end
        local targets = BreakoutPush.FindBreakoutTargets(player, trigger, currentTime)
        if #targets <= 0 then
            BreakoutPush.blockedDistance = BreakoutPush.blockedDistance + 1
            return
        end
        if trigger.type == "CROWD" and #targets < 2 then
            BreakoutPush.blockedDistance = BreakoutPush.blockedDistance + 1
            return
        end
        local busType = trigger.type == "SPRINT_PRECOLLISION" and "SPRINT" or trigger.type
        local busEffect = trigger.type == "SPRINT_PRECOLLISION" and "KNOCKDOWN" or "STAGGER"
        if Core.BreakoutActionBus and Core.BreakoutActionBus.CanStart then
            local busOk = Core.BreakoutActionBus.CanStart(busType, trigger.type, targets, busEffect)
            if not busOk then
                return
            end
        end
        local primary = targets[1]
        local key = targetKey(primary.zombie)
        if trigger.type ~= "GRAB" then
            if BreakoutPush.rearmRequired and key == BreakoutPush.lastTargetKey then
                BreakoutPush.blockedNotRearmed = BreakoutPush.blockedNotRearmed + 1
                return
            end
            local lastTime = BreakoutPush.lastTargetTime[key]
            local sameTargetCooldown = trigger.type == "CONTACT" and Config.CONTACT_SAME_TARGET_COOLDOWN or Config.SAME_ZOMBIE_BREAKOUT_COOLDOWN
            if lastTime and currentTime - lastTime < sameTargetCooldown then
                BreakoutPush.blockedSameZombie = BreakoutPush.blockedSameZombie + 1
                return
            end
        end
        local triggerId = BreakoutPush.NextTriggerId()
        local actionId = nil
        if Core.BreakoutActionBus and Core.BreakoutActionBus.Accept then
            actionId = Core.BreakoutActionBus.Accept(busType, trigger.type, targets, busEffect)
        end
        if trigger.type == "SPRINT_PRECOLLISION" and Core.SprintTripImmunity and Core.SprintTripImmunity.NotifySprintAction then
            Core.SprintTripImmunity.NotifySprintAction(player, triggerId, "BREAKOUT_SPRINT_PRECOLLISION")
        end
        if not BreakoutPush.ApplyCost(player, trigger.type, actionId) then
            return
        end
        local visibleAny = false
        local count = math.min(#targets, trigger.type == "CROWD" and Config.CROWD_BREAKOUT_MAX_ZOMBIES or (trigger.type == "GRAB" and Config.GRAB_BREAKOUT_MAX_ZOMBIES or 1))
        for i = 1, count do
            local target = targets[i]
            local vector = BreakoutPush.ComputePushVector(player, target.zombie, trigger.type)
            if vector then
                if i == 1 then
                    if trigger.type == "GRAB" then
                        if playerHasCollisionGrace(player) then
                            print("[XNP BREAKOUT GUARD] allowed_while_collided=true")
                        end
                        print(string.format("[XNP BREAKOUT] trigger type=GRAB_PREBITE_BREAK trigger_id=%d dist=%s zombies=%d speed=%s cooldown=%.2f reason=%s push_vector_source=%s", triggerId, fmt(target.info.distance), count, fmt(BreakoutPush.lastSpeed), Config.GRAB_BREAKOUT_COOLDOWN, tostring(trigger.reason), vector.source))
                    elseif trigger.type == "CROWD" then
                        print(string.format("[XNP BREAKOUT] trigger type=CROWD trigger_id=%d zombies=%d speed=%s cooldown=%.2f reason=%s push_vector_source=%s", triggerId, count, fmt(BreakoutPush.lastSpeed), Config.BREAKOUT_COOLDOWN, tostring(trigger.reason), vector.source))
                    elseif trigger.type == "SPRINT_PRECOLLISION" then
                        print(string.format("[XNP BREAKOUT] trigger type=SPRINT_PRECOLLISION trigger_id=%d dist=%s dotForward=%s closing_frames=%d speed=%s cooldown=%.2f reason=%s push_vector_source=%s", triggerId, fmt(target.info.distance), fmt(target.info.dot), target.history and target.history.closingFrames or 0, fmt(BreakoutPush.lastSpeed), Config.BREAKOUT_COOLDOWN, tostring(trigger.reason), vector.source))
                    else
                        print(string.format("[XNP BREAKOUT] trigger type=CONTACT trigger_id=%d dist=%s dotForward=%s closing_frames=%d speed=%s cooldown=%.2f reason=%s push_vector_source=%s", triggerId, fmt(target.info.distance), fmt(target.info.dot), target.history and target.history.closingFrames or 0, fmt(BreakoutPush.lastSpeed), Config.BREAKOUT_COOLDOWN, tostring(trigger.reason), vector.source))
                    end
                end
                local visible = BreakoutPush.ApplyPushProfile(player, target.zombie, vector, trigger.type, currentTime, triggerId)
                visibleAny = visibleAny or visible
            end
        end
        BreakoutPush.RegisterPlayerOutcomeWatchdog(triggerId, trigger.type, currentTime)
        BreakoutPush.triggered = BreakoutPush.triggered + 1
        if visibleAny then
            BreakoutPush.visible = BreakoutPush.visible + 1
            Core.YellowRedSignals.PulseImpact("BREAKOUT_PUSH:" .. tostring(trigger.type))
        end
        if trigger.type == "CONTACT" then BreakoutPush.contact = BreakoutPush.contact + 1 end
        if trigger.type == "SPRINT_PRECOLLISION" then BreakoutPush.sprintPrecollision = BreakoutPush.sprintPrecollision + 1 end
        if trigger.type == "GRAB" then BreakoutPush.grab = BreakoutPush.grab + 1 end
        if trigger.type == "CROWD" then BreakoutPush.crowd = BreakoutPush.crowd + 1 end
        BreakoutPush.UpdateCooldowns(primary.zombie, trigger.type, currentTime)
    end)
    if not ok then
        BreakoutPush.disabled = true
        BreakoutPush.disabledReason = tostring(err)
        print("[XNP BREAKOUT ROUTE] disabled route=BREAKOUT_PUSH reason=" .. tostring(err))
        return false
    end
    return true
end

function BreakoutPush.Cleanup(reason)
    BreakoutPush.lastX = nil
    BreakoutPush.lastY = nil
    BreakoutPush.lastSpeedTime = 0
    BreakoutPush.lastSpeed = 0
    BreakoutPush.zombieHistory = {}
    BreakoutPush.pendingPlayerWatchdogs = {}
    BreakoutPush.pendingZombieWatchdogs = {}
end

Core.BreakoutPush = BreakoutPush
return BreakoutPush
