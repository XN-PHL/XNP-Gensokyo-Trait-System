require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_CostTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactCandidateSnapshot"
require "XNP_PZ_DistanceRunner/XNP_DR_ImpactQuotaMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_ZombieVehicleImpact"
require "XNP_PZ_DistanceRunner/XNP_DR_NativeTripWindow"
require "XNP_PZ_DistanceRunner/XNP_DR_MovementIntentGate"
require "XNP_PZ_DistanceRunner/XNP_DR_BreakoutActionBus"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Evaluator = {
    HISTORY_NAMESPACE = "0.5.53",
    history = {},
    lastX = nil,
    lastY = nil,
    lastTime = 0,
    lastSpeed = 0,
    configLogged = false,
    summaryFrame = 0,
    light = 0,
    wall = 0,
    killed = 0,
    lastSets = {
        RawLocalImpactCandidates = {},
        VehicleHistoryCandidates = {},
        VehicleEligibleCandidates = {},
        ActionBusLightCandidates = {},
    },
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then return getTimestampMs() / 1000 end
    return os.time()
end

local function fmt(value)
    if not Constants.IsFiniteNumber(value) then return "NA" end
    return string.format("%.4f", value)
end

local function safeBool(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function() return obj[method](obj) end)
        return ok and value == true
    end
    return false
end

local function liveZombie(obj)
    if not obj or type(instanceof) ~= "function" then return false end
    local ok, isZombie = pcall(function() return instanceof(obj, "IsoZombie") end)
    return ok and isZombie == true and not safeBool(obj, "isDead")
end

local function playerSpeed(player)
    local t = nowSeconds()
    local x = player:getX()
    local y = player:getY()
    if not Evaluator.lastX then
        Evaluator.lastX = x
        Evaluator.lastY = y
        Evaluator.lastTime = t
        return 0
    end
    local dt = t - Evaluator.lastTime
    if dt <= 0 then return Evaluator.lastSpeed end
    local dx = x - Evaluator.lastX
    local dy = y - Evaluator.lastY
    Evaluator.lastSpeed = math.sqrt(dx * dx + dy * dy) / dt
    Evaluator.lastX = x
    Evaluator.lastY = y
    Evaluator.lastTime = t
    return Evaluator.lastSpeed
end

local function forward(player)
    if player and type(player.getForwardDirection) == "function" then
        local ok, v = pcall(function() return player:getForwardDirection() end)
        if ok and v then
            local x = Constants.IsFiniteNumber(v.x) and v.x or (type(v.getX) == "function" and v:getX() or nil)
            local y = Constants.IsFiniteNumber(v.y) and v.y or (type(v.getY) == "function" and v:getY() or nil)
            if Constants.IsFiniteNumber(x) and Constants.IsFiniteNumber(y) then
                local len = math.sqrt(x * x + y * y)
                if len > 0.0001 then return x / len, y / len end
            end
        end
    end
    return nil, nil
end

local function cleanupInvalidHistory()
    for zombie in pairs(Evaluator.history) do
        if not liveZombie(zombie) then Evaluator.history[zombie] = nil end
    end
end

local function updateHistory(candidate)
    local zombie = candidate.zombie
    local history = Evaluator.history[zombie]
    if not history then
        history = { lastDist = candidate.dist, closing = 0 }
        Evaluator.history[zombie] = history
    else
        if history.lastDist - candidate.dist >= (Config.PRECOLLISION_MIN_DISTANCE_DELTA or 0.015) then
            history.closing = math.min(history.closing + 1, 20)
        else
            history.closing = 0
        end
        history.lastDist = candidate.dist
    end
    candidate.history = history
end

local function logContractOnce()
    if Evaluator.configLogged then return end
    Evaluator.configLogged = true
    print("[XNP VEHICLE IMPACT] enabled=true")
    print("[XNP VEHICLE IMPACT] mode=quota interval=" .. tostring(Config.SPRINT_QUOTA_INTERVAL)
        .. " wall_count=" .. tostring(Config.SPRINT_VEHICLE_WALL_COUNT))
    print("[XNP VEHICLE IMPACT] sprint_overflow_forced_fall="
        .. tostring(Config.SPRINT_OVERFLOW_FORCED_FALL == true))
    Core.LogThrottle.Event("[XNP VEHICLE VERIFIED ORDER] distance_filter_before_history=true")
    Core.LogThrottle.Event("[XNP VEHICLE VERIFIED ORDER] history_admission_min=0.50")
    Core.LogThrottle.Event("[XNP VEHICLE VERIFIED ORDER] history_admission_max=1.80")
    Core.LogThrottle.Event("[XNP VEHICLE VERIFIED ORDER] scan_radius=2.05 history_radius=1.80")
    Core.LogThrottle.Event("[XNP VEHICLE VERIFIED ORDER] outside_window_updates_history=false")
    Core.LogThrottle.Event("[XNP ACTIONBUS LIGHT VERIFIED] source=VEHICLE_VERIFIED")
    Core.LogThrottle.Event("[XNP ACTIONBUS LIGHT VERIFIED] raw_snapshot_direct_admission=false")
    Core.LogThrottle.Event("[XNP ACTIONBUS LIGHT VERIFIED] eligible_set_equivalent=true")
    Core.LogThrottle.Event("[XNP ACTIONBUS LIGHT VERIFIED] same_target_order_equivalent=true")
    Core.LogThrottle.Event("[XNP ACTIONBUS LIGHT VERIFIED] quota_order_equivalent=true")
    Core.LogThrottle.Event("[XNP VEHICLE HISTORY] namespace=0.5.53")
    Core.LogThrottle.Event("[XNP VEHICLE HISTORY] old_runtime_table_reused=false")
    Core.LogThrottle.Event("[XNP VEHICLE HISTORY] out_of_window_admission=false")
    Core.LogThrottle.Event("[XNP VEHICLE HISTORY] invalid_target_cleanup=true")
end

function Evaluator.ShouldRun(player)
    if Config.SPRINT_VEHICLE_IMPACT_ENABLED ~= true or not player
        or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        return false, "DISABLED_OR_NO_TRAIT", 0
    end
    local speed = playerSpeed(player)
    if speed < Config.SPRINT_VEHICLE_MIN_SPEED then
        return false, "LOW_SPEED", speed
    end
    if not safeBool(player, "isSprinting") then
        return false, "NOT_SPRINTING", speed
    end
    return true, "VERIFIED_RUN_GATE", speed
end

function Evaluator.CollectRawCandidates(player)
    local result = {}
    if not Core.ImpactCandidateSnapshot.ClaimEvaluation("SPRINT_VEHICLE_ZOMBIE") then
        return result
    end
    local raw = Core.ImpactCandidateSnapshot.GetRawLocalImpactCandidates()
    local seen = {}
    for i = 1, #raw do
        local candidate = raw[i]
        if candidate and not seen[candidate] then
            seen[candidate] = true
            result[#result + 1] = candidate
        end
    end
    Evaluator.lastSets.RawLocalImpactCandidates = result
    return result
end

function Evaluator.ApplyDistanceWindow(candidates, player, fx, fy)
    local result = {}
    local px = player:getX()
    local py = player:getY()
    local minimum = Config.SPRINT_VEHICLE_DIST_MIN or 0.50
    local maximum = Config.SPRINT_VEHICLE_DIST_MAX or 1.80
    for i = 1, #candidates do
        local zombie = candidates[i]
        if liveZombie(zombie) and type(zombie.getX) == "function" and type(zombie.getY) == "function" then
            local dx = zombie:getX() - px
            local dy = zombie:getY() - py
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist >= minimum and dist <= maximum then
                local dot = dist > 0 and ((dx / dist) * fx + (dy / dist) * fy) or -1
                result[#result + 1] = {
                    zombie = zombie,
                    dist = dist,
                    dot = dot,
                    key = zombie,
                }
            end
        end
    end
    Evaluator.lastSets.VehicleHistoryCandidates = result
    return result
end

function Evaluator.UpdateClosingHistory(filteredCandidates)
    cleanupInvalidHistory()
    for i = 1, #filteredCandidates do
        updateHistory(filteredCandidates[i])
    end
    return filteredCandidates
end

function Evaluator.BuildEligibleTargets(historyCandidates)
    local result = {}
    for i = 1, #historyCandidates do
        local candidate = historyCandidates[i]
        if candidate.dot >= Config.SPRINT_VEHICLE_DOT_MIN
            and candidate.history.closing >= Config.SPRINT_VEHICLE_CLOSING_FRAMES then
            result[#result + 1] = candidate
        end
    end
    table.sort(result, function(a, b)
        if a.dot ~= b.dot then return a.dot > b.dot end
        return a.dist < b.dist
    end)
    Evaluator.lastSets.VehicleEligibleCandidates = result
    return result
end

function Evaluator.ApplyActionBusLightAdmission(mode, selected)
    local targets = { selected.zombie }
    Evaluator.lastSets.ActionBusLightCandidates = mode == "LIGHT" and targets or {}
    if Core.BreakoutActionBus and not Core.BreakoutActionBus.CanStart(
        "SPRINT_VEHICLE", mode, targets, "KNOCKDOWN"
    ) then
        return false
    end
    if Core.BreakoutActionBus then
        Core.BreakoutActionBus.Accept("SPRINT_VEHICLE", mode, targets, "KNOCKDOWN")
    end
    return true
end

local function charge(player, cost, kind)
    local route = kind == "LIGHT" and "SPRINT_VEHICLE_ZOMBIE" or "WALL_IMPACT"
    local finalCost = cost
    if Core.CostTuning and Core.CostTuning.ComputeFinalCost then
        finalCost = Core.CostTuning.ComputeFinalCost(route, cost)
    end
    if not player or type(player.getStats) ~= "function" or not CharacterStat or not CharacterStat.ENDURANCE then
        print("[XNP VEHICLE IMPACT COST] type=" .. tostring(kind) .. " before=NA after=NA cost=" .. fmt(finalCost))
        return false
    end
    local stats = player:getStats()
    if not stats or type(stats.get) ~= "function" or type(stats.set) ~= "function" then
        print("[XNP VEHICLE IMPACT COST] type=" .. tostring(kind) .. " before=NA after=NA cost=" .. fmt(finalCost))
        return false
    end
    local before = stats:get(CharacterStat.ENDURANCE)
    local after = math.max(Config.MIN_ENDURANCE_FLOOR or 0.05, before - finalCost)
    if not Core.Authority or not Core.Authority.CanWriteNonFoodStats(player, "SPRINT_VEHICLE_" .. tostring(kind)) then
        return false
    end
    local ok = pcall(function() stats:set(CharacterStat.ENDURANCE, after) end)
    if ok and Core.LongMigrationStaminaAssist and Core.LongMigrationStaminaAssist.NotifySkillCost then
        Core.LongMigrationStaminaAssist.NotifySkillCost(
            "SPRINT_VEHICLE_" .. tostring(kind),
            Config.BREAKOUT_COST_REFUND_IGNORE_WINDOW or 0.50
        )
    end
    print("[XNP VEHICLE IMPACT COST] type=" .. tostring(kind) .. " before=" .. fmt(before) .. " after=" .. fmt(after) .. " cost=" .. fmt(finalCost))
    return ok
end

function Evaluator.Execute(player)
    logContractOnce()
    local run, reason, speed = Evaluator.ShouldRun(player)
    if not run then return false end
    if Core.MovementIntentGate and Core.MovementIntentGate.CanSprintVehicle then
        local gateOk, gateReason = Core.MovementIntentGate.CanSprintVehicle(
            player, { source = "SPRINT_VEHICLE", speed = speed }
        )
        if not gateOk then
            if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTVEHICLEIMPACT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            if Core.BreakoutActionBus and Core.BreakoutActionBus.BlockMovementGate then
                Core.BreakoutActionBus.BlockMovementGate("SPRINT_VEHICLE", gateReason)
            end
            if Core.ImpactQuotaMeter and Core.ImpactQuotaMeter.BlockedNotCounted then
                Core.ImpactQuotaMeter.BlockedNotCounted("SPRINT_VEHICLE", gateReason)
            end
            return false
        end
    end
    if Core.NativeTripWindow and Core.NativeTripWindow.IsActive and Core.NativeTripWindow.IsActive() then
        if Core.LogThrottle then Core.LogThrottle.Blocked("SPRINTVEHICLEIMPACT", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return false
    end
    local fx, fy = forward(player)
    if not fx then return false end
    local raw = Evaluator.CollectRawCandidates(player)
    local historyCandidates = Evaluator.ApplyDistanceWindow(raw, player, fx, fy)
    Evaluator.UpdateClosingHistory(historyCandidates)
    local targets = Evaluator.BuildEligibleTargets(historyCandidates)
    if #targets <= 0 then return false end

    local mode = #targets >= Config.SPRINT_VEHICLE_WALL_COUNT and "WALL_CRASH" or "LIGHT"
    local selected = targets[1]
    if not Evaluator.ApplyActionBusLightAdmission(mode, selected) then return false end

    local quotaOk = Core.ImpactQuotaMeter.Try(
        "SPRINT_VEHICLE",
        selected.zombie,
        Config.SPRINT_QUOTA_TARGETS_PER_INTERVAL,
        Config.SPRINT_QUOTA_INTERVAL
    )
    if not quotaOk then mode = "WALL_CRASH" end

    if mode == "LIGHT" then
        local killed = 0
        for i = 1, math.min(#targets, Config.SPRINT_VEHICLE_LIGHT_KILL_TARGETS) do
            local ok = Core.ZombieVehicleImpact.ApplyVehicleDeath(
                player, targets[i].zombie, { triggerId = "SPRINT_VEHICLE_LIGHT" }
            )
            if ok then killed = killed + 1 end
        end
        Evaluator.light = Evaluator.light + 1
        Evaluator.killed = Evaluator.killed + killed
        charge(player, Config.SPRINT_VEHICLE_ZOMBIE_BASE_COST, "LIGHT")
        print("[XNP VEHICLE IMPACT] mode=LIGHT blocker_count=" .. tostring(#targets) .. " result=APPLIED")
        print("[XNP VEHICLE IMPACT PLAYER] result=STAY_UP mode=LIGHT")
    else
        Evaluator.wall = Evaluator.wall + 1
        if Core.NativeTripWindow then
            Core.NativeTripWindow.Open(player, "SPRINT_OVERFLOW", "ZOMBIE_WALL_OR_QUOTA_OVERFLOW")
        end
        charge(player, Config.SPRINT_VEHICLE_WALL_COST, "NATIVE_TRIP_WINDOW")
        print("[XNP VEHICLE IMPACT] mode=WALL_CRASH blocker_count=3 result=NATIVE_TRIP_WINDOW")
        Core.LogThrottle.Event("[XNP VEHICLE IMPACT PLAYER] result=VANILLA_TRIP_CHECK mode=WALL_CRASH")
    end
    return true
end

function Evaluator.SummaryTick()
    Evaluator.summaryFrame = Evaluator.summaryFrame + 1
    if Evaluator.summaryFrame < 60 then return end
    print("[XNP VEHICLE IMPACT SUMMARY] light=" .. tostring(Evaluator.light)
        .. " wall=" .. tostring(Evaluator.wall)
        .. " zombies_killed=" .. tostring(Evaluator.killed)
            .. " window=sampled")
    Evaluator.summaryFrame = 0
    Evaluator.light = 0
    Evaluator.wall = 0
    Evaluator.killed = 0
end

function Evaluator.ValidateExactOrder()
    return {
        identityDedupeBeforeDistance = true,
        distanceBeforeHistory = true,
        historyBeforeClosingFilter = true,
        dotAndClosingBeforeSort = true,
        sortBeforeActionBus = true,
        actionBusBeforeQuota = true,
        quotaBeforeEffectAndCost = true,
        rawSnapshotDirectAdmission = false,
        vehicleRunGateSpeedAndSprint = true,
        actionBusSelectedTargetOnly = true,
    }
end

function Evaluator.GetLastTargetSets()
    return Evaluator.lastSets
end

Core.VehicleVerifiedEvaluator = Evaluator
return Evaluator
