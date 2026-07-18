require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus"
require "XNP_PZ_DistanceRunner/XNP_DR_CostTuning"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local SprintTripImmunity = {
    configLogged = false,
    lastX = nil,
    lastY = nil,
    lastTime = 0,
    lastSpeed = 0,
    lastSweepTime = 0,
    lastCollisionTime = 0,
    lastTripCancelTime = 0,
    lastTargetTime = {},
    zombieHistory = {},
    triggerSeq = 0,
    pendingOutcomes = {},
    tripGuardAudited = false,
    tripGuardAvailable = false,
    tripGuardMethod = "none",
    sprintImmunityActive = 0,
    sprintImmunitySweep = 0,
    sprintImmunityTripCancelAttempt = 0,
    sprintImmunityTripCancelOk = 0,
    sprintImmunitySuccess = 0,
    sprintImmunityFail = 0,
    blockedNoSafeTripCancelApi = 0,
    blockedSprintImmunityNotActive = 0,
    blockedNoRecentSprintCollision = 0,
    blockedTripCancelCooldown = 0,
    sprintRearm = 0,
    sprintRearmBlockedSameTarget = 0,
    sprintRearmAfterGetup = 0,
    lastSummaryTime = 0,
    activeSummaryFrames = 0,
    activeSummaryMaxSpeed = 0,
    tooLate = 0,
    fellAfterImmunity = 0,
}

XNP_DR_SprintTripImmunity = SprintTripImmunity

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

local function targetKey(zombie)
    if Core.BreakoutActionBus and Core.BreakoutActionBus.TargetKey then
        return Core.BreakoutActionBus.TargetKey(zombie)
    end
    return zombie and ("local:" .. tostring(zombie)) or nil
end

local function logConfigOnce()
    if SprintTripImmunity.configLogged then
        return
    end
    SprintTripImmunity.configLogged = true
    print("[XNP SPRINT IMMUNITY] method=FULL_SPRINT_TRIP_IMMUNITY_NATIVE_TRIP_WINDOW")
    print("[XNP SPRINT IMMUNITY SWEEP] enabled=" .. tostring(Config.SPRINT_IMMUNITY_SWEEP_ENABLED == true))
    if Config.SPRINT_TRIP_CANCEL_ENABLED == true then
        print("[XNP SPRINT IMMUNITY] trip_cancel_runtime=true")
    else
    Core.LogThrottle.Blocked("SPRINT_IMMUNITY", "TRIP_CANCEL_RUNTIME_FALSE")
    end
    print("[XNP SPRINT IMMUNITY] no_damage_rollback=true")
    print("[XNP SPRINT IMMUNITY] no_position_write=true")
    print("[XNP SPRINT IMMUNITY] precontact_window min=" .. fmt(Config.SPRINT_PRECONTACT_MIN_DIST) .. " max=" .. fmt(Config.SPRINT_PRECONTACT_MAX_DIST) .. " prefer=" .. fmt(Config.SPRINT_PRECONTACT_PREFER_MIN) .. "-" .. fmt(Config.SPRINT_PRECONTACT_PREFER_MAX) .. " closing_frames=" .. tostring(Config.SPRINT_CLOSING_FRAMES_REQUIRED) .. " dot=" .. fmt(Config.SPRINT_DOT_MIN))
    print("[XNP SPRINT ROUTE] first_wave_knockdown_boost=true")
    print("[XNP SPRINT ROUTE] max_targets=" .. tostring(Config.SPRINT_SWEEP_MAX_TARGETS) .. " primary_knockdown=" .. tostring(Config.SPRINT_SWEEP_PRIMARY_KNOCKDOWN_TARGETS) .. " outer_stagger=" .. tostring(Config.SPRINT_SWEEP_OUTER_STAGGER_TARGETS))
    print("[XNP SPRINT TRIP CANCEL] notify_from_breakout_fail=true")
end

local function playerSpeed(player)
    if not player or type(player.getX) ~= "function" or type(player.getY) ~= "function" then
        return 0
    end
    local t = nowSeconds()
    local x = player:getX()
    local y = player:getY()
    if not SprintTripImmunity.lastX then
        SprintTripImmunity.lastX = x
        SprintTripImmunity.lastY = y
        SprintTripImmunity.lastTime = t
        return SprintTripImmunity.lastSpeed
    end
    local dt = t - SprintTripImmunity.lastTime
    if dt <= 0 then
        return SprintTripImmunity.lastSpeed
    end
    local dx = x - SprintTripImmunity.lastX
    local dy = y - SprintTripImmunity.lastY
    SprintTripImmunity.lastSpeed = math.sqrt(dx * dx + dy * dy) / dt
    SprintTripImmunity.lastX = x
    SprintTripImmunity.lastY = y
    SprintTripImmunity.lastTime = t
    return SprintTripImmunity.lastSpeed
end

local function forwardVector(player)
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

local function playerDown(player)
    if safeBool(player, "isDead") or safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown") then
        return true
    end
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    return string.find(text, "fall", 1, true) ~= nil or string.find(text, "trip", 1, true) ~= nil or string.find(text, "getup", 1, true) ~= nil
end

local function fullSprintActive(player, speed)
    if not Config.SPRINT_FALL_TUNE_ENABLED or not Config.SPRINT_IMMUNITY_ENABLED or not player or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        return false, "TRAIT_OR_CONFIG_INACTIVE"
    end
    if playerDown(player) then
        return false, "PLAYER_DOWN"
    end
    local text = safeString(player, "getActionStateName") .. " " .. safeString(player, "getAnimationStateName")
    local sprintBool = safeBool(player, "isSprinting")
    local sprintText = string.find(text, "sprint", 1, true) ~= nil
    local runText = string.find(text, "run", 1, true) ~= nil
    if speed >= Config.SPRINT_SWEEP_MIN_SPEED and (sprintBool or sprintText or runText) then
        return true, "FULL_SPRINT"
    end
    return false, "NOT_FULL_SPRINT"
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
    if safeBool(obj, "isDead") or safeBool(obj, "isOnFloor") or safeBool(obj, "isCrawling") or safeBool(obj, "isFakeDead") then
        return false
    end
    return true
end

local function updateApproachHistory(zombie, dist)
    local key = targetKey(zombie)
    if not key then
        return nil
    end
    local history = SprintTripImmunity.zombieHistory[key]
    if not history then
        history = { lastDist = dist, closingFrames = 0, lastDelta = 0 }
        SprintTripImmunity.zombieHistory[key] = history
        return history
    end
    local delta = history.lastDist - dist
    if delta >= Config.PRECOLLISION_MIN_DISTANCE_DELTA then
        history.closingFrames = math.min(history.closingFrames + 1, 20)
    else
        history.closingFrames = 0
    end
    history.lastDelta = delta
    history.lastDist = dist
    return history
end

local function insertSweepCandidate(result, player, zombie, fx, fy)
    if not liveZombie(zombie) or not sameZ(player, zombie) or type(zombie.getX) ~= "function" or type(zombie.getY) ~= "function" then
        return
    end
    local dx = zombie:getX() - player:getX()
    local dy = zombie:getY() - player:getY()
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < Config.SPRINT_SWEEP_MIN_DIST then
        if dist < Config.SPRINT_TOO_LATE_DIST then
            SprintTripImmunity.tooLate = SprintTripImmunity.tooLate + 1
        end
        return
    end
    if dist > Config.SPRINT_SWEEP_MAX_DIST then
        return
    end
    local ax, ay = normalize2(dx, dy)
    if not ax then
        return
    end
    local dot = ax * fx + ay * fy
    if dot < Config.SPRINT_SWEEP_OUTER_DOT_MIN then
        return
    end
    local history = updateApproachHistory(zombie, dist)
    if not history or history.closingFrames < Config.SPRINT_SWEEP_CLOSING_FRAMES then
        return
    end
    local preferred = dist >= Config.SPRINT_SWEEP_PREFER_MIN and dist <= Config.SPRINT_SWEEP_PREFER_MAX
    local closingBonus = math.min(history.closingFrames, 4) * 0.12
    local distanceBonus = preferred and 0.35 or 0
    local score = dot + closingBonus + distanceBonus
    local profile = dot >= Config.SPRINT_SWEEP_DOT_MIN and "PRIMARY_KNOCKDOWN" or "OUTER_STAGGER"
    print("[XNP SPRINT SWEEP SELECT] candidate=" .. tostring(targetKey(zombie)) .. " dist=" .. fmt(dist) .. " dot=" .. fmt(dot) .. " closing=" .. tostring(history.closingFrames) .. " score=" .. fmt(score))
    table.insert(result, { zombie = zombie, key = targetKey(zombie), dist = dist, dot = dot, closingFrames = history.closingFrames, preferred = preferred, score = score, profile = profile })
end

local function collectSweepTargets(player)
    local result = {}
    if not player or not Core.ThreatSnapshot or Config.SPRINT_IMMUNITY_SWEEP_ENABLED ~= true then
        return result
    end
    local fx, fy = forwardVector(player)
    if not fx then
        return result
    end
    local zombies = Core.ThreatSnapshot.GetNearbyZombies(Config.SPRINT_SWEEP_MAX_DIST)
    for i = 1, #zombies do insertSweepCandidate(result, player, zombies[i], fx, fy) end
    return result
end

local function nextTriggerId()
    SprintTripImmunity.triggerSeq = SprintTripImmunity.triggerSeq + 1
    return SprintTripImmunity.triggerSeq
end

local function auditTripGuard(player)
    if SprintTripImmunity.tripGuardAudited then
        return
    end
    SprintTripImmunity.tripGuardAudited = true
    if not Config.SPRINT_TRIP_CANCEL_ENABLED then
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return
    end
    if player and type(player.setKnockedDown) == "function" then
        SprintTripImmunity.tripGuardAvailable = true
        SprintTripImmunity.tripGuardMethod = "setKnockedDown_false"
    elseif player and type(player.setOnFloor) == "function" then
        SprintTripImmunity.tripGuardAvailable = true
        SprintTripImmunity.tripGuardMethod = "setOnFloor_false"
    end
    if SprintTripImmunity.tripGuardAvailable then
        print("[XNP SPRINT IMMUNITY] trip_guard=ENABLED method=" .. SprintTripImmunity.tripGuardMethod)
    else
        SprintTripImmunity.blockedNoSafeTripCancelApi = SprintTripImmunity.blockedNoSafeTripCancelApi + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
    end
end

local function chargeTripCancelCost(player, triggerId)
    if not player or type(player.getStats) ~= "function" or not CharacterStat or not CharacterStat.ENDURANCE then
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local stats = player:getStats()
    if not stats or type(stats.get) ~= "function" or type(stats.set) ~= "function" then
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local before = stats:get(CharacterStat.ENDURANCE)
    if not Constants.IsFiniteNumber(before) then
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local cost = Config.SPRINT_TRIP_CANCEL_COST
    if Core.CostTuning and Core.CostTuning.ComputeFinalCost then
        cost = Core.CostTuning.ComputeFinalCost("NATIVE_TRIP", cost)
    end
    local debt = 0
    if before <= Config.EMERGENCY_BREAKOUT_LOW_STAMINA_THRESHOLD then
        debt = Config.SPRINT_TRIP_CANCEL_LOW_STAMINA_DEBT
        cost = cost + debt
    end
    local after = math.max(Config.MIN_ENDURANCE_FLOOR, before - cost)
    if not Core.Authority or not Core.Authority.CanWriteNonFoodStats(player, "SPRINT_TRIP_CANCEL") then
        return false
    end
    local ok = pcall(function()
        stats:set(CharacterStat.ENDURANCE, after)
    end)
    if not ok then
        print("[XNP COST] type=SPRINT_TRIP_CANCEL before=" .. fmt(before) .. " after=" .. fmt(before) .. " cost=" .. fmt(cost) .. " result=set_failed")
        return false
    end
    if Core.LongMigrationStaminaAssist and Core.LongMigrationStaminaAssist.NotifySkillCost then
        Core.LongMigrationStaminaAssist.NotifySkillCost("NATIVE_TRIP", Config.BREAKOUT_COST_REFUND_IGNORE_WINDOW or 0.50)
    end
    print("[XNP COST] type=SPRINT_TRIP_CANCEL before=" .. fmt(before) .. " after=" .. fmt(after) .. " cost=" .. fmt(cost) .. " trigger_id=" .. tostring(triggerId))
    print("[XNP COST] low_stamina=" .. tostring(debt > 0) .. " debt=" .. fmt(debt))
    print("[XNP COST] no_bite=true no_infection=true no_heal=true")
    if Core.StatusIconUI and Core.StatusIconUI.NotifySkillTriggered then
        Core.StatusIconUI.NotifySkillTriggered("SPRINT_TRIP_CANCEL")
    end
    return true
end

local function attemptTripCancel(player, triggerId, currentTime)
    if Core.NativeTripWindow and Core.NativeTripWindow.IsTripCancelSuppressed and Core.NativeTripWindow.IsTripCancelSuppressed() then
        print("[XNP NATIVE TRIP WINDOW] sprint_trip_cancel_suppressed=true reason=NATIVE_TRIP_CHECK")
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    SprintTripImmunity.sprintImmunityTripCancelAttempt = SprintTripImmunity.sprintImmunityTripCancelAttempt + 1
    if currentTime - SprintTripImmunity.lastCollisionTime > Config.SPRINT_TRIP_CANCEL_WINDOW then
        SprintTripImmunity.blockedNoRecentSprintCollision = SprintTripImmunity.blockedNoRecentSprintCollision + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    if currentTime - SprintTripImmunity.lastTripCancelTime < Config.SPRINT_TRIP_CANCEL_COOLDOWN then
        SprintTripImmunity.blockedTripCancelCooldown = SprintTripImmunity.blockedTripCancelCooldown + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    if not SprintTripImmunity.tripGuardAvailable then
        SprintTripImmunity.blockedNoSafeTripCancelApi = SprintTripImmunity.blockedNoSafeTripCancelApi + 1
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    if Core.BreakoutActionBus and Core.BreakoutActionBus.AllowFollowup then
        Core.BreakoutActionBus.AllowFollowup("SPRINT_TRIP_CANCEL", "SAME_SPRINT_WINDOW")
    end
    print("[XNP SPRINT TRIP CANCEL] attempt trigger_id=" .. tostring(triggerId) .. " method=" .. tostring(SprintTripImmunity.tripGuardMethod) .. " recent_sprint=true")
    local ok = false
    local method = SprintTripImmunity.tripGuardMethod
    if method == "setKnockedDown_false" then
        ok = pcall(function()
            player:setKnockedDown(false)
        end)
    elseif method == "setOnFloor_false" then
        ok = pcall(function()
            player:setOnFloor(false)
        end)
    end
    if ok then
        SprintTripImmunity.lastTripCancelTime = currentTime
        SprintTripImmunity.sprintImmunityTripCancelOk = SprintTripImmunity.sprintImmunityTripCancelOk + 1
        chargeTripCancelCost(player, triggerId)
        print("[XNP SPRINT TRIP CANCEL] result=ok trigger_id=" .. tostring(triggerId))
        print("[XNP SPRINT IMMUNITY] trip_cancel_result=ok")
        print("[XNP SPRINT IMMUNITY] prevented_trip trigger_id=" .. tostring(triggerId) .. " method=" .. method)
        return true
    end
    print("[XNP SPRINT TRIP CANCEL FAIL] reason=PLAYER_STILL_DOWN_AFTER_CANCEL")
    print("[XNP SPRINT IMMUNITY] trip_cancel_result=fail method=" .. tostring(method))
    return false
end

local function registerOutcome(triggerId, currentTime)
    table.insert(SprintTripImmunity.pendingOutcomes, {
        triggerId = triggerId,
        expireTime = currentTime + Config.SPRINT_IMMUNITY_OUTCOME_WINDOW,
        postCancelExpireTime = nil,
        cancelAttempted = false,
        forcedFall = false,
    })
end

local function updateOutcomes(player, currentTime)
    if Core.FallRecoveryInput and Core.FallRecoveryInput.activeFallType == "SPRINT_OVERFLOW_WALL_CRASH" then
        if #SprintTripImmunity.pendingOutcomes > 0 then
            if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        end
        SprintTripImmunity.pendingOutcomes = {}
        return
    end
    local keep = {}
    for _, watch in ipairs(SprintTripImmunity.pendingOutcomes) do
        if playerDown(player) or watch.forcedFall then
            if not watch.cancelAttempted then
                watch.cancelAttempted = true
                if watch.forcedFall then
                    print("[XNP SPRINT IMMUNITY OUTCOME] corrected_from=PLAYER_STAYED_UP reason=BREAKOUT_REPORTED_FALL")
                end
                if attemptTripCancel(player, watch.triggerId, currentTime) then
                    watch.postCancelExpireTime = currentTime + Config.SPRINT_TRIP_CANCEL_WATCH_AFTER
                    table.insert(keep, watch)
                else
                    SprintTripImmunity.sprintImmunityFail = SprintTripImmunity.sprintImmunityFail + 1
                    SprintTripImmunity.fellAfterImmunity = SprintTripImmunity.fellAfterImmunity + 1
                    print("[XNP SPRINT IMMUNITY FAIL] reason=PLAYER_FELL_AFTER_IMMUNITY trigger_id=" .. tostring(watch.triggerId))
                end
            elseif watch.postCancelExpireTime and currentTime < watch.postCancelExpireTime then
                table.insert(keep, watch)
            else
                SprintTripImmunity.sprintImmunityFail = SprintTripImmunity.sprintImmunityFail + 1
                SprintTripImmunity.fellAfterImmunity = SprintTripImmunity.fellAfterImmunity + 1
                print("[XNP SPRINT IMMUNITY FAIL] reason=PLAYER_FELL_AFTER_IMMUNITY trigger_id=" .. tostring(watch.triggerId))
            end
        elseif watch.cancelAttempted and watch.postCancelExpireTime and currentTime >= watch.postCancelExpireTime then
            SprintTripImmunity.sprintImmunitySuccess = SprintTripImmunity.sprintImmunitySuccess + 1
            print("[XNP SPRINT IMMUNITY OUTCOME] result=TRIP_CANCELLED_AND_STAYED_UP trigger_id=" .. tostring(watch.triggerId))
            print("[XNP SPRINT TRIP CANCEL] outcome=TRIP_CANCELLED_AND_STAYED_UP trigger_id=" .. tostring(watch.triggerId))
        elseif currentTime >= watch.expireTime then
            SprintTripImmunity.sprintImmunitySuccess = SprintTripImmunity.sprintImmunitySuccess + 1
            print("[XNP SPRINT IMMUNITY OUTCOME] result=PLAYER_STAYED_UP trigger_id=" .. tostring(watch.triggerId))
        else
            table.insert(keep, watch)
        end
    end
    SprintTripImmunity.pendingOutcomes = keep
end

function SprintTripImmunity.NotifySprintAction(player, triggerId, reason)
    local currentTime = nowSeconds()
    auditTripGuard(player)
    SprintTripImmunity.lastCollisionTime = currentTime
    registerOutcome(triggerId, currentTime)
    print("[XNP SPRINT TRIP CANCEL] notify_from_action=true trigger_id=" .. tostring(triggerId) .. " reason=" .. tostring(reason))
end

function SprintTripImmunity.NotifySprintFall(player, triggerId, reason, context)
    local currentTime = nowSeconds()
    auditTripGuard(player)
    SprintTripImmunity.lastCollisionTime = currentTime
    print("[XNP SPRINT TRIP CANCEL] notified trigger_id=" .. tostring(triggerId) .. " reason=" .. tostring(reason))
    local matched = false
    for _, watch in ipairs(SprintTripImmunity.pendingOutcomes) do
        if tostring(watch.triggerId) == tostring(triggerId) then
            watch.forcedFall = true
            watch.expireTime = currentTime
            matched = true
        end
    end
    if not matched then
        table.insert(SprintTripImmunity.pendingOutcomes, {
            triggerId = triggerId,
            expireTime = currentTime,
            postCancelExpireTime = nil,
            cancelAttempted = false,
            forcedFall = true,
        })
    end
    updateOutcomes(player, currentTime)
end

local function logSummary(currentTime)
    if SprintTripImmunity.lastSummaryTime == 0 then
        SprintTripImmunity.lastSummaryTime = currentTime
        return
    end
    if currentTime - SprintTripImmunity.lastSummaryTime < Config.IMPACT_SUMMARY_LOG_INTERVAL then
        return
    end
    SprintTripImmunity.lastSummaryTime = currentTime
    if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
    print("[XNP SPRINT FAIL SUMMARY] too_late=" .. tostring(SprintTripImmunity.tooLate) .. " fell_after_stagger=" .. tostring(SprintTripImmunity.fellAfterImmunity) .. " window=sampled")
    SprintTripImmunity.tooLate = 0
    SprintTripImmunity.fellAfterImmunity = 0
end

function SprintTripImmunity.Update(player)
    logConfigOnce()
    local currentTime = nowSeconds()
    auditTripGuard(player)
    updateOutcomes(player, currentTime)
    logSummary(currentTime)
    if Core.NativeTripWindow and Core.NativeTripWindow.IsTripCancelSuppressed and Core.NativeTripWindow.IsTripCancelSuppressed() then
        print("[XNP NATIVE TRIP WINDOW] sprint_trip_cancel_suppressed=true reason=NATIVE_TRIP_CHECK")
        return false
    end
    local speed = playerSpeed(player)
    local active = fullSprintActive(player, speed)
    if not active then
        SprintTripImmunity.blockedSprintImmunityNotActive = SprintTripImmunity.blockedSprintImmunityNotActive + 1
        return false
    end
    SprintTripImmunity.sprintImmunityActive = SprintTripImmunity.sprintImmunityActive + 1
    SprintTripImmunity.activeSummaryFrames = SprintTripImmunity.activeSummaryFrames + 1
    if speed > SprintTripImmunity.activeSummaryMaxSpeed then
        SprintTripImmunity.activeSummaryMaxSpeed = speed
    end
    local activeWindow = Config.SPRINT_IMMUNITY_ACTIVE_SUMMARY_FRAMES or 60
    if SprintTripImmunity.activeSummaryFrames >= activeWindow then
        print("[XNP SPRINT IMMUNITY ACTIVE SUMMARY] active_frames=" .. tostring(SprintTripImmunity.activeSummaryFrames) .. " max_speed=" .. fmt(SprintTripImmunity.activeSummaryMaxSpeed) .. " window_frames=" .. tostring(activeWindow))
        SprintTripImmunity.activeSummaryFrames = 0
        SprintTripImmunity.activeSummaryMaxSpeed = 0
    end
    if currentTime - SprintTripImmunity.lastSweepTime < Config.SPRINT_IMMUNITY_REARM_SECONDS then
        return false
    end
    local targets = collectSweepTargets(player)
    if #targets <= 0 then
        return false
    end
    local triggerId = nextTriggerId()
    local applied = 0
    local visibleApplied = 0
    local selected = {}
    local knockdown = 0
    local stagger = 0
    for i = 1, math.min(#targets, Config.SPRINT_SWEEP_MAX_TARGETS) do
        local target = targets[i]
        local lastTime = SprintTripImmunity.lastTargetTime[target.key]
        if lastTime and currentTime - lastTime < Config.SPRINT_IMMUNITY_REARM_SECONDS then
            SprintTripImmunity.sprintRearmBlockedSameTarget = SprintTripImmunity.sprintRearmBlockedSameTarget + 1
            if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTTRIPIMMUNITY", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        else
            local profile = target.profile
            if profile == "PRIMARY_KNOCKDOWN" and knockdown >= Config.SPRINT_SWEEP_PRIMARY_KNOCKDOWN_TARGETS then
                profile = "OUTER_STAGGER"
            end
            local controlType = profile == "PRIMARY_KNOCKDOWN" and "SPRINT_PRECOLLISION" or "CONTACT"
            local visible, effect = Core.VerifiedStaggerControl.Apply(player, target.zombie, controlType, { triggerId = triggerId })
            if visible then visibleApplied = visibleApplied + 1 end
            SprintTripImmunity.lastTargetTime[target.key] = currentTime
            selected[#selected + 1] = target
            applied = applied + 1
            if profile == "PRIMARY_KNOCKDOWN" then
                knockdown = knockdown + 1
            else
                stagger = stagger + 1
            end
            print("[XNP SPRINT SWEEP SELECT] accepted=" .. tostring(target.key) .. " profile=" .. tostring(profile))
            print("[XNP SPRINT IMMUNITY SWEEP] target=" .. tostring(target.key) .. " dist=" .. fmt(target.dist) .. " dot=" .. fmt(target.dot) .. " closing_frames=" .. tostring(target.closingFrames) .. " control=" .. tostring(effect) .. " visible=" .. tostring(visible))
        end
    end
    if applied > 0 then
        SprintTripImmunity.sprintImmunitySweep = SprintTripImmunity.sprintImmunitySweep + 1
        SprintTripImmunity.sprintRearm = SprintTripImmunity.sprintRearm + 1
        SprintTripImmunity.lastSweepTime = currentTime
        SprintTripImmunity.lastCollisionTime = currentTime
        if Core.BreakoutActionBus and Core.BreakoutActionBus.Accept then
            Core.BreakoutActionBus.Accept("SPRINT_IMMUNITY", "SPRINT_SWEEP", selected, "STAGGER")
        end
        print("[XNP SPRINT IMMUNITY SWEEP] trigger_id=" .. tostring(triggerId) .. " targets=" .. tostring(applied) .. " knockdown=" .. tostring(knockdown) .. " stagger=" .. tostring(stagger) .. " speed=" .. fmt(speed) .. " result=APPLIED")
        print("[XNP SPRINT IMMUNITY REARM] reason=STILL_SPRINTING_NEW_TARGETS")
        print("[XNP SPRINT IMMUNITY REARM] state=READY")
        registerOutcome(triggerId, currentTime)
    end
    if visibleApplied > 0 then
        Core.YellowRedSignals.PulseImpact("SPRINT_IMMUNITY_SWEEP")
    end
    return applied > 0
end

function SprintTripImmunity.Cleanup(reason)
    SprintTripImmunity.lastX = nil
    SprintTripImmunity.lastY = nil
    SprintTripImmunity.lastTime = 0
    SprintTripImmunity.lastSpeed = 0
    SprintTripImmunity.zombieHistory = {}
    SprintTripImmunity.pendingOutcomes = {}
end

Core.SprintTripImmunity = SprintTripImmunity
return SprintTripImmunity
