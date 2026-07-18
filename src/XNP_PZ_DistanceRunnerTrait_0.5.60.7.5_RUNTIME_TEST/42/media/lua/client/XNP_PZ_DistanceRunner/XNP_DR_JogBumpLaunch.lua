require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_VerifiedStaggerControl"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_JogFallShockwave"
require "XNP_PZ_DistanceRunner/XNP_DR_FallRecoveryInput"
require "XNP_PZ_DistanceRunner/XNP_DR_NativeTripWindow"
require "XNP_PZ_DistanceRunner/XNP_DR_CostTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_MovementIntentGate"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local JogBumpLaunch = {
    configLogged = false,
    lastX = nil,
    lastY = nil,
    lastTime = 0,
    lastSpeed = 0,
    history = {},
    summaryFrame = 0,
    applied = 0,
    overflow = 0,
}

XNP_DR_JogBumpLaunch = JogBumpLaunch

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

local function playerSpeed(player)
    local t = nowSeconds()
    local x = player:getX()
    local y = player:getY()
    if not JogBumpLaunch.lastX then
        JogBumpLaunch.lastX = x
        JogBumpLaunch.lastY = y
        JogBumpLaunch.lastTime = t
        return 0
    end
    local dt = t - JogBumpLaunch.lastTime
    if dt <= 0 then
        return JogBumpLaunch.lastSpeed
    end
    local dx = x - JogBumpLaunch.lastX
    local dy = y - JogBumpLaunch.lastY
    JogBumpLaunch.lastSpeed = math.sqrt(dx * dx + dy * dy) / dt
    JogBumpLaunch.lastX = x
    JogBumpLaunch.lastY = y
    JogBumpLaunch.lastTime = t
    return JogBumpLaunch.lastSpeed
end

local function forward(player)
    if player and type(player.getForwardDirection) == "function" then
        local ok, v = pcall(function()
            return player:getForwardDirection()
        end)
        if ok and v then
            local x = Constants.IsFiniteNumber(v.x) and v.x or (type(v.getX) == "function" and v:getX() or nil)
            local y = Constants.IsFiniteNumber(v.y) and v.y or (type(v.getY) == "function" and v:getY() or nil)
            if Constants.IsFiniteNumber(x) and Constants.IsFiniteNumber(y) then
                local len = math.sqrt(x * x + y * y)
                if len > 0.0001 then
                    return x / len, y / len
                end
            end
        end
    end
    return nil, nil
end

local function liveZombie(obj)
    if not obj or type(instanceof) ~= "function" or not instanceof(obj, "IsoZombie") then
        return false
    end
    if safeBool(obj, "isDead") then
        return false
    end
    return true
end

local function targetKey(zombie)
    return Core.ImpactQuotaMeter and Core.ImpactQuotaMeter.TargetKey(zombie) or tostring(zombie)
end

local function updateHistory(zombie, dist)
    local key = targetKey(zombie)
    local history = JogBumpLaunch.history[key]
    if not history then
        history = { lastDist = dist, closing = 0 }
        JogBumpLaunch.history[key] = history
        return history
    end
    if history.lastDist - dist >= (Config.PRECOLLISION_MIN_DISTANCE_DELTA or 0.015) then
        history.closing = math.min(history.closing + 1, 20)
    else
        history.closing = 0
    end
    history.lastDist = dist
    return history
end

local function collect(player)
    local result = {}
    local fx, fy = forward(player)
    if not fx or not Core.ThreatSnapshot then
        return result
    end
    local px = player:getX()
    local py = player:getY()
    local radius = Config.JOG_EFFECT_RADIUS or 1.25
    local zombies = Core.ThreatSnapshot.GetNearbyZombies(radius)
    for i = 1, #zombies do
        local zombie = zombies[i]
        if liveZombie(zombie) and type(zombie.getX) == "function" then
            local dx = zombie:getX() - px
            local dy = zombie:getY() - py
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist >= Config.JOG_BUMP_DIST_MIN and dist <= radius then
                local dot = (dx / dist) * fx + (dy / dist) * fy
                local hist = updateHistory(zombie, dist)
                if dot >= Config.JOG_BUMP_DOT_MIN and hist.closing >= Config.JOG_BUMP_CLOSING_FRAMES then
                    result[#result + 1] = { zombie = zombie, dist = dist, dot = dot, key = targetKey(zombie) }
                end
            end
        end
    end
    return result
end

local function forceTrip(player)
    if Core.NativeTripWindow and Config.JOG_OVERFLOW_NATIVE_TRIP_ENABLED == true then
        Core.NativeTripWindow.Open(player, "JOG_OVERFLOW", "JOG_QUOTA_OVERFLOW")
    Core.LogThrottle.Event("[XNP JOG OVERFLOW] result=NATIVE_TRIP_WINDOW")
        return
    end
    print("[XNP JOG OVERFLOW] result=NO_FORCED_TRIP reason=NATIVE_TRIP_DISABLED")
end

function JogBumpLaunch.LogConfigOnce()
    if JogBumpLaunch.configLogged then
        return
    end
    JogBumpLaunch.configLogged = true
    print("[XNP JOG BUMP] enabled=true")
end

local function chargeJogBump(player)
    local base = Config.JOG_BUMP_COST or Config.jog_bump_cost or 0.030
    local cost = base
    if Core.CostTuning and Core.CostTuning.ComputeFinalCost then
        cost = Core.CostTuning.ComputeFinalCost("JOG_BUMP", base)
    end
    if not player or type(player.getStats) ~= "function" or not CharacterStat or not CharacterStat.ENDURANCE then
        Core.LogThrottle.Blocked("JOG_BUMP_COST", "NO_ENDURANCE_API")
        return false
    end
    local stats = player:getStats()
    if not stats or type(stats.get) ~= "function" or type(stats.set) ~= "function" then
        Core.LogThrottle.Blocked("JOG_BUMP_COST", "NO_STATS_API")
        return false
    end
    local before = stats:get(CharacterStat.ENDURANCE)
    if not Core.Constants.IsFiniteNumber(before) then
        Core.LogThrottle.Blocked("JOG_BUMP_COST", "BAD_ENDURANCE")
        return false
    end
    local after = math.max(Config.MIN_ENDURANCE_FLOOR or 0.05, before - cost)
    if not Core.Authority or not Core.Authority.CanWriteNonFoodStats(player, "JOG_BUMP") then
        return false
    end
    local ok = pcall(function()
        stats:set(CharacterStat.ENDURANCE, after)
    end)
    if ok and Core.LongMigrationStaminaAssist and Core.LongMigrationStaminaAssist.NotifySkillCost then
        Core.LongMigrationStaminaAssist.NotifySkillCost("JOG_BUMP", Config.BREAKOUT_COST_REFUND_IGNORE_WINDOW or 0.50)
    end
    print("[XNP COST ROUTE] route=JOG_BUMP charged_once=" .. tostring(ok == true))
    print("[XNP JOG BUMP COST] before=" .. fmt(before) .. " after=" .. fmt(after) .. " cost=" .. fmt(cost))
    return ok
end

function JogBumpLaunch.Update(player)
    JogBumpLaunch.LogConfigOnce()
    if Config.JOG_BUMP_LAUNCH_ENABLED ~= true or not player or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        return false
    end
    local speed = playerSpeed(player)
    if speed < Config.JOG_BUMP_MIN_SPEED or speed > Config.JOG_BUMP_MAX_SPEED or safeBool(player, "isSprinting") then
        return false
    end
    if Core.MovementIntentGate and Core.MovementIntentGate.CanJogBump then
        local gateOk, reason, intent = Core.MovementIntentGate.CanJogBump(player, { source = "JOG_BUMP", speed = speed })
        if not gateOk then
            if Config.JOG_BUMP_BLOCK_LOG_SUMMARY_ONLY ~= true then
                if Core.LogThrottle then Core.LogThrottle.Blocked("JOGBUMPLAUNCH", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            end
            if Core.BreakoutActionBus and Core.BreakoutActionBus.BlockMovementGate then
                Core.BreakoutActionBus.BlockMovementGate("JOG_BUMP", reason)
            end
            if Core.ImpactQuotaMeter and Core.ImpactQuotaMeter.BlockedNotCounted then
                Core.ImpactQuotaMeter.BlockedNotCounted("JOG_BUMP", reason)
            end
            return false
        end
    end
    local targets = collect(player)
    if #targets <= 0 then
        return false
    end
    local target = targets[1]
    if Core.BreakoutActionBus and not Core.BreakoutActionBus.CanStart("JOG_BUMP", "JOG_BUMP", { target.zombie }, "STAGGER") then
        return false
    end
    if Core.BreakoutActionBus then
        Core.BreakoutActionBus.Accept("JOG_BUMP", "JOG_BUMP", { target.zombie }, "STAGGER")
    end
    local allowed = Core.ImpactQuotaMeter.Try("JOG_BUMP", target.zombie, Config.JOG_KNOCKDOWN_QUOTA, Config.JOG_QUOTA_WINDOW)
    if not allowed then
        JogBumpLaunch.overflow = JogBumpLaunch.overflow + 1
        forceTrip(player)
        return true
    end
    local roll = ZombRandFloat and ZombRandFloat(0.0, 1.0) or math.random()
    local effect = "STAGGER_ONLY"
    if roll >= Config.JOG_BUMP_STAGGER_CHANCE + Config.JOG_BUMP_KNOCKDOWN_CHANCE then
        effect = "JOG_LAUNCH"
    elseif roll >= Config.JOG_BUMP_STAGGER_CHANCE then
        effect = "JOG_KNOCKDOWN"
    end
    print("[XNP JOG BUMP] trigger target=" .. tostring(target.key) .. " speed=" .. fmt(speed) .. " dist=" .. fmt(target.dist) .. " dot=" .. fmt(target.dot) .. " roll=" .. fmt(roll))
    local visible = Core.VerifiedStaggerControl.Apply(player, target.zombie, effect == "STAGGER_ONLY" and "CONTACT" or "SPRINT_PRECOLLISION", { triggerId = "JOG_BUMP" })
    if visible then
        Core.YellowRedSignals.PulseImpact("JOG_BUMP")
    end
    chargeJogBump(player)
    print("[XNP JOG BUMP] effect=" .. effect)
    JogBumpLaunch.applied = JogBumpLaunch.applied + 1
    return true
end

function JogBumpLaunch.SummaryTick()
    JogBumpLaunch.summaryFrame = JogBumpLaunch.summaryFrame + 1
    local interval = Config.SUMMARY_LOG_INTERVAL_FRAMES or 120
    if JogBumpLaunch.summaryFrame >= interval then
        print("[XNP JOG BUMP BLOCK SUMMARY] applied=" .. tostring(JogBumpLaunch.applied) .. " overflow=" .. tostring(JogBumpLaunch.overflow) .. " radius=" .. tostring(Config.JOG_EFFECT_RADIUS) .. " window_frames=" .. tostring(interval))
        JogBumpLaunch.summaryFrame = 0
        JogBumpLaunch.applied = 0
        JogBumpLaunch.overflow = 0
    end
end

Core.JogBumpLaunch = JogBumpLaunch
return JogBumpLaunch
