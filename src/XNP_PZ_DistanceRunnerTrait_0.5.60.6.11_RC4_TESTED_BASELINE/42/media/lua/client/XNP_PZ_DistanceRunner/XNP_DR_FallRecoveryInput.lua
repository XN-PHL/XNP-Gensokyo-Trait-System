require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_EmergencyInput"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_MovementIntentGate"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local FallRecoveryInput = {
    activeFallType = nil,
    recoveryUntil = 0,
    configLogged = false,
    selectorLogged = false,
}

XNP_DR_FallRecoveryInput = FallRecoveryInput

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
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
    return zombie and tostring(zombie) or "nil"
end

local function charge(player, cost)
    if not player or type(player.getStats) ~= "function" or not CharacterStat or not CharacterStat.ENDURANCE then
        print("[XNP FALL RECOVERY COST] cost=" .. tostring(cost) .. " result=SKIPPED")
        return false
    end
    local stats = player:getStats()
    if not stats or type(stats.get) ~= "function" or type(stats.set) ~= "function" then
        print("[XNP FALL RECOVERY COST] cost=" .. tostring(cost) .. " result=SKIPPED")
        return false
    end
    local before = stats:get(CharacterStat.ENDURANCE)
    local after = math.max(Config.MIN_ENDURANCE_FLOOR or 0.05, before - cost)
    if not Core.Authority or not Core.Authority.CanWriteNonFoodStats(player, "FALL_RECOVERY_INPUT") then
        return false
    end
    local ok = pcall(function()
        stats:set(CharacterStat.ENDURANCE, after)
    end)
    print("[XNP FALL RECOVERY COST] cost=" .. string.format("%.3f", cost) .. " result=" .. (ok and "APPLIED" or "SKIPPED"))
    return ok
end

local function sameZ(player, zombie)
    if not player or not zombie or type(player.getZ) ~= "function" or type(zombie.getZ) ~= "function" then
        return false
    end
    return math.abs(player:getZ() - zombie:getZ()) <= 0.50
end

local function collectRecoveryTargets(player)
    local selected = {}
    local radius = math.min(Config.FALL_RECOVERY_RADIUS or 1.35, Config.CONTROLLED_ESCAPE_RADIUS or 1.25, 1.35)
    local scanRadius = math.max(radius, Config.FALL_RECOVERY_SCAN_RADIUS or 1.75)
    local maxTargets = math.min(Config.FALL_RECOVERY_MAX_TARGETS or 3, Config.CONTROLLED_ESCAPE_MAX_TARGETS or 2, 3)
    if not FallRecoveryInput.selectorLogged then
        FallRecoveryInput.selectorLogged = true
        print("[XNP FALL RECOVERY TARGET] selector=LOCAL_LOCKED_RADIUS radius=" .. string.format("%.2f", radius))
        print("[XNP RADIUS] mode=FALL_RECOVERY scan_radius=" .. string.format("%.2f", scanRadius) .. " effect_radius=" .. string.format("%.2f", radius))
        print("[XNP RADIUS] large_scan_no_effect=true")
    Core.LogThrottle.Blocked("FALL_RECOVERY", "OLD_EMERGENCY_RADIUS_FALSE")
    end
    if not player or not Core.ThreatSnapshot then
        return selected
    end
    local px = player:getX()
    local py = player:getY()
    local zombies = Core.ThreatSnapshot.GetNearbyZombies(scanRadius)
    for i = 1, #zombies do
        local zombie = zombies[i]
        if liveZombie(zombie) and sameZ(player, zombie) and type(zombie.getX) == "function" and type(zombie.getY) == "function" then
            local dx = zombie:getX() - px
            local dy = zombie:getY() - py
            local dist = math.sqrt(dx * dx + dy * dy)
            local target = { zombie = zombie, key = targetKey(zombie), dist = dist }
            if target.dist <= radius and #selected < maxTargets then
                print("[XNP CONTROLLED ESCAPE] target zombie=" .. tostring(target.key) .. " reason=CONTROLLED_OR_TOUCHING dist=" .. string.format("%.3f", target.dist))
                print("[XNP FALL RECOVERY TARGET] accepted zombie=" .. tostring(target.key) .. " dist=" .. string.format("%.3f", target.dist) .. " reason=CONTROLLED_OR_TOUCHING")
                selected[#selected + 1] = target
            end
        end
    end
    return selected
end

function FallRecoveryInput.LogConfigOnce()
    if FallRecoveryInput.configLogged then
        return
    end
    FallRecoveryInput.configLogged = true
    print("[XNP FALL RECOVERY] input=RUN_OR_SPRINT enabled=true")
end

function FallRecoveryInput.Classify(fallType)
    FallRecoveryInput.activeFallType = fallType
    FallRecoveryInput.recoveryUntil = nowSeconds() + 2.0
    if fallType == "JOG_OVERFLOW_TRIP" then
        Core.LogThrottle.Event("[XNP FALL CLASSIFY] type=JOG_OVERFLOW_TRIP recovery_input=true")
    elseif fallType == "SPRINT_OVERFLOW_WALL_CRASH" then
        Core.LogThrottle.Event("[XNP FALL CLASSIFY] type=SPRINT_OVERFLOW_WALL_CRASH recovery_input=true")
    else
        print("[XNP FALL CLASSIFY] type=CONTROLLED_AFTER_FALL cancel_allowed=true recovery_input=true")
    end
end

function FallRecoveryInput.Update(player)
    FallRecoveryInput.LogConfigOnce()
    if not FallRecoveryInput.activeFallType or nowSeconds() > FallRecoveryInput.recoveryUntil then
        return false
    end
    if not (safeBool(player, "isOnFloor") or safeBool(player, "isKnockedDown")) then
        return false
    end
    local accepted = false
    if Core.EmergencyInput and Core.EmergencyInput.Update then
        local input = Core.EmergencyInput.Update(player)
        accepted = input and input.down == true
    end
    if not accepted then
        return false
    end
    if Core.MovementIntentGate and Core.MovementIntentGate.CanControlledEscape then
        local gateOk, reason = Core.MovementIntentGate.CanControlledEscape(player, { source = "FALL_RECOVERY", controlled = true, reason = "CONTROLLED_OR_TOUCHING" })
        if not gateOk then
            if Core.LogThrottle then Core.LogThrottle.Blocked("FALLRECOVERYINPUT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            return false
        end
    end
    local targets = collectRecoveryTargets(player)
    local actionId = nil
    if #targets > 0 and Core.BreakoutActionBus and Core.BreakoutActionBus.CanStart then
        if not Core.BreakoutActionBus.CanStart("FALL_RECOVERY", FallRecoveryInput.activeFallType, targets, "KNOCKDOWN") then
            if Core.LogThrottle then Core.LogThrottle.Blocked("FALLRECOVERYINPUT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            return false
        end
    end
    if #targets > 0 and Core.BreakoutActionBus and Core.BreakoutActionBus.Accept then
        actionId = Core.BreakoutActionBus.Accept("FALL_RECOVERY", FallRecoveryInput.activeFallType, targets, "KNOCKDOWN")
    end
    local applied = 0
    for _, target in ipairs(targets) do
        local controlType = "SPRINT_PRECOLLISION"
        if Core.ImpactQuotaMeter and Core.ImpactQuotaMeter.TrySkillActive then
            local quotaOk = Core.ImpactQuotaMeter.TrySkillActive("FALL_RECOVERY", target.zombie, actionId)
            if not quotaOk then
                controlType = "CONTACT"
            end
        end
        if Core.VerifiedStaggerControl and Core.VerifiedStaggerControl.Apply then
            local visible = Core.VerifiedStaggerControl.Apply(player, target.zombie, controlType, { triggerId = "FALL_RECOVERY" })
            if visible then
                applied = applied + 1
            end
        end
    end
    charge(player, 0.120)
    if applied > 0 then
        Core.YellowRedSignals.PulseImpact("FALL_RECOVERY")
    end
    print("[XNP FALL RECOVERY] input=RUN_OR_SPRINT result=BREAKOUT_APPLIED targets=" .. tostring(applied))
    print("[XNP JOG RECOVERY] input=RUN_OR_SPRINT result=CONTROL_BREAKOUT_APPLIED")
    print("[XNP FALL RECOVERY] no_bite=true no_infection=true no_heal=true")
    FallRecoveryInput.activeFallType = nil
    return true
end

function FallRecoveryInput.Cleanup(reason)
    FallRecoveryInput.activeFallType = nil
end

Core.FallRecoveryInput = FallRecoveryInput
return FallRecoveryInput
