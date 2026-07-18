require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_Trait"
require "XNP_PZ_DistanceRunner/XNP_DR_StaminaTrendMeter"
require "XNP_PZ_DistanceRunner/XNP_DR_EnduranceBandState"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local Assist = {
    frame = 0,
    startupLogged = false,
    lastObservedEndurance = nil,
    lastState = nil,
    lastResourceLocked = false,
    refundDebt = 0,
    smoothLogged = false,
    lastSmoothState = nil,
    lastDebtClearReason = nil,
    lastBlockedReason = nil,
    ignoreRefundUntil = 0,
    ignoreRefundReason = nil,
    minuteWindowFrame = 0,
    hungerCostThisMinute = 0,
    lastStatus = {
        state = "GREEN_READY",
        iconState = "GREEN_READY",
        iconReason = "INITIAL",
        resourceAvailable = true,
    },
    summary = {
        ticks = 0,
        enduranceWrites = 0,
        hungerWrites = 0,
        blockedRefund = 0,
        blockedHunger = 0,
        skipped = 0,
        rawLoss = 0,
        refund = 0,
        debt = 0,
        hungerCost = 0,
        smoothSamples = 0,
    },
}

local refundByState = {
    GREEN_READY = "green_refund_fraction",
    BLUE_STAMINA_SUPPORT = "blue_refund_fraction",
    YELLOW_LOW_STAMINA_SUPPORT = "yellow_refund_fraction",
    RED_EXHAUSTED_SUPPORT = "red_refund_fraction",
}

local hungerRatioByState = {
    GREEN_READY = "hunger_conversion_green",
    BLUE_STAMINA_SUPPORT = "hunger_conversion_blue",
    YELLOW_LOW_STAMINA_SUPPORT = "hunger_conversion_yellow",
    RED_EXHAUSTED_SUPPORT = "hunger_conversion_red",
}

local refundStepCapByState = {
    GREEN_READY = 0.0,
    BLUE_STAMINA_SUPPORT = "blue_refund_step_cap",
    YELLOW_LOW_STAMINA_SUPPORT = "yellow_refund_step_cap",
    RED_EXHAUSTED_SUPPORT = "red_refund_step_cap",
}

local refundBoundaryByState = {
    BLUE_STAMINA_SUPPORT = "release_green_exit",
    YELLOW_LOW_STAMINA_SUPPORT = "release_blue_lower",
    RED_EXHAUSTED_SUPPORT = "release_yellow_lower",
}

local function clamp(value, minValue, maxValue)
    return Constants.Clamp(value, minValue, maxValue)
end

local function getStats(player)
    if player and type(player.getStats) == "function" then
        local ok, stats = pcall(function()
            return player:getStats()
        end)
        if ok then
            return stats
        end
    end
    return nil
end

local function statGet(stats, stat, getter)
    if not stats then
        return nil
    end
    if stat ~= nil and type(stats.get) == "function" then
        local ok, value = pcall(function()
            return stats:get(stat)
        end)
        if ok and Constants.IsFiniteNumber(value) then
            return value
        end
    end
    if getter and type(stats[getter]) == "function" then
        local ok, value = pcall(function()
            return stats[getter](stats)
        end)
        if ok and Constants.IsFiniteNumber(value) then
            return value
        end
    end
    return nil
end

local function statSet(stats, stat, setter, value)
    if not stats or not Constants.IsFiniteNumber(value) then
        return false
    end
    if stat ~= nil and type(stats.set) == "function" then
        local ok = pcall(function()
            stats:set(stat, value)
        end)
        if ok then
            return true
        end
    end
    if setter and type(stats[setter]) == "function" then
        local ok = pcall(function()
            stats[setter](stats, value)
        end)
        if ok then
            return true
        end
    end
    return false
end

function Assist.GetEndurance(player)
    local stats = getStats(player)
    return statGet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "getEndurance")
end

function Assist.SetEnduranceSafe(player, value, reason)
    if not Core.Authority or not Core.Authority.CanWriteNonFoodStats(player, "LONG_MIGRATION_STAMINA_ASSIST") then
        return false
    end
    local stats = getStats(player)
    local ok = statSet(stats, CharacterStat and CharacterStat.ENDURANCE or nil, "setEndurance", clamp(value, 0.0, 1.0))
    if ok then
        Assist.summary.enduranceWrites = Assist.summary.enduranceWrites + 1
    else
        if Core.LogThrottle then Core.LogThrottle.Blocked("LONGMIGRATIONSTAMINAASSIST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
    end
    return ok
end

function Assist.GetHunger(player)
    local stats = getStats(player)
    return statGet(stats, CharacterStat and CharacterStat.HUNGER or nil, "getHunger")
end

function Assist.GetFatigue(player)
    local stats = getStats(player)
    return statGet(stats, CharacterStat and CharacterStat.FATIGUE or nil, "getFatigue")
end

local function getCalories(player)
    local stats = getStats(player)
    return statGet(stats, CharacterStat and CharacterStat.CALORIES or nil, "getCalories")
end

local function safeBool(player, method)
    if player and type(player[method]) == "function" then
        local ok, value = pcall(function()
            return player[method](player)
        end)
        return ok and value == true
    end
    return false
end

local function safeString(player, method)
    if player and type(player[method]) == "function" then
        local ok, value = pcall(function()
            return player[method](player)
        end)
        if ok and value ~= nil then
            return tostring(value)
        end
    end
    return ""
end

function Assist.GetRunningState(player)
    local sprinting = safeBool(player, "isSprinting")
    local running = safeBool(player, "isRunning")
    local moving = safeBool(player, "isPlayerMoving") or running or sprinting
    return {
        isSprinting = sprinting,
        isRunning = running,
        isMoving = moving,
        action_state = safeString(player, "getCurrentActionContext"),
        animation_state = safeString(player, "getActionStateName"),
    }
end

local function isLocomotion(runningState)
    if not runningState or runningState.isMoving ~= true then
        return false
    end
    if runningState.isRunning == true or runningState.isSprinting == true then
        return true
    end
    local text = string.lower(tostring(runningState.action_state or "") .. " " .. tostring(runningState.animation_state or ""))
    return string.find(text, "run", 1, true) ~= nil or string.find(text, "jog", 1, true) ~= nil or string.find(text, "sprint", 1, true) ~= nil
end

local function skipReason(player, runningState)
    if not player or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        return "NO_TRAIT"
    end
    if safeBool(player, "isDead") then
        return "DEAD"
    end
    if type(player.getVehicle) == "function" then
        local ok, vehicle = pcall(function()
            return player:getVehicle()
        end)
        if ok and vehicle ~= nil then
            return "IN_VEHICLE"
        end
    end
    if safeBool(player, "isAiming") or safeBool(player, "isAttacking") then
        return "ATTACK_OR_AIM"
    end
    return nil
end

local function resetMinuteWindow()
    if Assist.frame - Assist.minuteWindowFrame >= 3600 then
        Assist.minuteWindowFrame = Assist.frame
        Assist.hungerCostThisMinute = 0
    end
end

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function resourceState(hunger, calories)
    if Config.resource_gate_enabled ~= true then
        return {
            available = true,
            locked = false,
            reason = "RESOURCE_GATE_DISABLED",
            changed = Assist.lastResourceLocked == true,
            resumed = Assist.lastResourceLocked == true,
        }
    end
    local locked = Assist.lastResourceLocked == true
    local reason = "RESOURCE_AVAILABLE"
    if locked then
        if hunger ~= nil and hunger <= (Config.resource_gate_resume_hunger or 0.64) and (calories == nil or calories >= (Config.resource_gate_resume_calorie or -600)) then
            locked = false
            reason = "RESUMED"
        else
            reason = "RESOURCE_STILL_LOCKED"
        end
    else
        if hunger ~= nil and hunger >= (Config.resource_gate_hunger_hard or 0.82) then
            locked = true
            reason = "HUNGER_LOW"
        elseif calories ~= nil and calories <= (Config.resource_gate_calorie_floor or -1000) then
            locked = true
            reason = "CALORIE_RESERVE_LOW"
        elseif hunger ~= nil and hunger >= (Config.resource_gate_hunger_soft or 0.72) then
            locked = true
            reason = "HUNGER_LOW"
        end
    end
    local changed = locked ~= Assist.lastResourceLocked
    Assist.lastResourceLocked = locked
    return {
        available = not locked,
        locked = locked,
        reason = reason,
        changed = changed,
        resumed = changed and not locked,
    }
end

local function multiplierFor(state)
    local refund = Config[refundByState[state] or "green_refund_fraction"] or 0.0
    return 1.0 - refund, refund
end

local function hungerRatioFor(state)
    return Config[hungerRatioByState[state] or "hunger_conversion_green"] or 0.0
end

local function refundStepCapFor(state)
    local key = refundStepCapByState[state]
    if type(key) == "string" then
        return Config[key] or 0.0
    end
    return key or 0.0
end

local function refundBoundaryFor(state)
    local key = refundBoundaryByState[state]
    if type(key) == "string" then
        return Config[key] or 1.0
    end
    return 1.0
end

local function logMultiplier(state, multiplier, refund)
    if state == Assist.lastState then
        return
    end
    Assist.lastState = state
    print(string.format("[XNP STAMINA MULTIPLIER] state=%s drain_multiplier=%.2f refund_fraction=%.2f", tostring(state), multiplier, refund))
end

local function clearRefundDebt(reason)
    if Assist.refundDebt > 0 then
        Assist.refundDebt = 0
        if Assist.lastDebtClearReason ~= reason then
            Assist.lastDebtClearReason = reason
            print("[XNP STAMINA SMOOTH] debt_cleared reason=" .. tostring(reason))
        end
    end
end

local function logSmoothStartupOnce()
    if Assist.smoothLogged then
        return
    end
    Assist.smoothLogged = true
    print("[XNP STAMINA SMOOTH] enabled=true sample_interval_frames=" .. tostring(Config.assist_sample_interval_frames or 3))
end

local function logSmoothSample(state, rawLoss, refundStep)
    if Assist.lastSmoothState ~= state then
        Assist.lastSmoothState = state
        print(string.format("[XNP STAMINA SMOOTH] state=%s raw_loss=%.6f refund_step=%.6f debt=%.6f", tostring(state), rawLoss or 0, refundStep or 0, Assist.refundDebt or 0))
    end
end

local function logBlockedOnce(reason)
    Core.LogThrottle.Blocked("STAMINA_SMOOTH", reason)
end

local function applyHungerCost(player, hunger, state, refund, resource)
    if Config.OLD_HUNGER_CONVERSION_COST_ACTIVE ~= true then
        return 0
    end
    if refund <= 0 then
        return 0
    end
    if resource.locked and Config.resource_gate_cancel_hunger_when_locked == true then
        Assist.summary.blockedHunger = Assist.summary.blockedHunger + 1
        if Core.Log and Core.Log.EveryFrames then
            Core.LogThrottle.Blocked("HUNGER_CONVERSION", "RESOURCE_LOCKED")
        end
        return 0
    end
    resetMinuteWindow()
    local ratio = hungerRatioFor(state)
    local cost = refund * ratio
    local cap = Config.max_extra_hunger_per_minute or 0.055
    if Assist.hungerCostThisMinute + cost > cap then
        cost = math.max(0, cap - Assist.hungerCostThisMinute)
    end
    if cost <= 0 or hunger == nil then
        return 0
    end
    if Core.FoodReserveConversion
        and Core.FoodReserveConversion.ApplyDiscreteCost
        and Core.FoodReserveConversion.ApplyDiscreteCost(cost, state, player) then
        Assist.hungerCostThisMinute = Assist.hungerCostThisMinute + cost
        if Core.Log and Core.Log.EveryFrames then
            Core.Log.EveryFrames("hunger_conversion_summary", Config.SUMMARY_LOG_INTERVAL_FRAMES or 120, string.format("[XNP HUNGER CONVERSION SUMMARY] state=%s refund=%.6f ratio=%.2f cost=%.6f", tostring(state), refund, ratio, cost))
        end
        return cost
    end
    return 0
end

local function logStartupOnce()
    if Assist.startupLogged then
        return
    end
    Assist.startupLogged = true
    print("[XNP STAMINA ASSIST] method=POST_DRAIN_REFUND_BY_ENDURANCE_BAND")
    print("[XNP STAMINA ASSIST] locomotion_drain_only=true discrete_cost_refund_disabled=true no_direct_full_restore=true no_infinite_sprint=true")
    print("[XNP RESOURCE GATE] naming=NEUTRAL_NO_WHITE_STATE")
    Core.LogThrottle.Event("[XNP RESOURCE GATE] color_preserved=true")
    logSmoothStartupOnce()
end

function Assist.Tick(player)
    if Config.LONG_MIGRATION_STAMINA_ENABLED ~= true then
        return false
    end
    logStartupOnce()
    Assist.frame = (Core.PerformanceBudget and Core.PerformanceBudget.Frame and Core.PerformanceBudget.Frame()) or (Assist.frame + 1)
    local interval = Config.assist_sample_interval_frames or Config.LONG_MIGRATION_TICK_INTERVAL_FRAMES or 3
    if Core.PerformanceBudget and Core.PerformanceBudget.ShouldRun then
        if not Core.PerformanceBudget.ShouldRun("long_migration_stamina", interval) then
            return true
        end
    elseif Assist.frame % interval ~= 0 then
        return true
    end

    Assist.summary.ticks = Assist.summary.ticks + 1
    local runningState = Assist.GetRunningState(player)
    local skip = skipReason(player, runningState)
    local endurance = Assist.GetEndurance(player)
    local hunger = Assist.GetHunger(player)
    local fatigue = Assist.GetFatigue(player)
    local calories = getCalories(player)
    local band = Core.EnduranceBandState and Core.EnduranceBandState.GetStableState and Core.EnduranceBandState.GetStableState(player) or nil
    local state = band and band.state or "GREEN_READY"
    local resource = resourceState(hunger, calories)
    local multiplier, refundFraction = multiplierFor(state)
    if resource.locked then
        multiplier = Config.resource_gate_locked_multiplier or Config.resource_gate_hard_stop_multiplier or 1.0
        if Config.resource_gate_cancel_refund_when_locked == true then
            refundFraction = 0.0
        end
        if Core.Log and Core.Log.EveryFrames then
            Core.Log.EveryFrames("resource_gate_locked_summary", Config.SUMMARY_LOG_INTERVAL_FRAMES or 120, "[XNP RESOURCE GATE SUMMARY] locked=true assist_multiplier_cancelled=true hunger_write_cancelled=true")
        end
        if Config.resource_gate_preserve_color_when_locked == true then
            print("[XNP RESOURCE GATE] color_preserved=true")
        end
        clearRefundDebt("RESOURCE_LOCKED")
    elseif resource.changed or resource.resumed then
        print("[XNP RESOURCE GATE] available=true color_preserved=true resumed=" .. tostring(resource.resumed == true))
    end
    logMultiplier(state, multiplier, refundFraction)

    local rawLoss = 0
    local refund = 0
    local hungerCost = 0
    if skip then
        Assist.summary.skipped = Assist.summary.skipped + 1
    elseif Constants.IsFiniteNumber(endurance) and Constants.IsFiniteNumber(Assist.lastObservedEndurance) then
        rawLoss = Assist.lastObservedEndurance - endurance
        if rawLoss > 0 then
            if nowSeconds() < (Assist.ignoreRefundUntil or 0) then
                Assist.summary.blockedRefund = Assist.summary.blockedRefund + 1
                clearRefundDebt("SKILL_COST")
                logBlockedOnce("ACTION_OR_DISCRETE_COST")
                if Core.Log and Core.Log.EveryFrames then
                    Core.LogThrottle.Blocked("STAMINA_SMOOTH", "ACTION_OR_DISCRETE_COST")
                end
            elseif rawLoss > (Config.discrete_drop_threshold or 0.012) then
                Assist.summary.blockedRefund = Assist.summary.blockedRefund + 1
                logBlockedOnce("ACTION_OR_DISCRETE_COST")
                if Core.Log and Core.Log.EveryFrames then
                    Core.LogThrottle.Blocked("STAMINA_SMOOTH", "DISCRETE_LARGE_DROP")
                end
            elseif Config.locomotion_drain_only == true and not isLocomotion(runningState) then
                Assist.summary.blockedRefund = Assist.summary.blockedRefund + 1
                clearRefundDebt("NOT_LOCOMOTION")
                logBlockedOnce("NOT_LOCOMOTION")
            elseif refundFraction > 0 and resource.available == true then
                local wantedRefund = (rawLoss * refundFraction) + Assist.refundDebt
                local stepCap = refundStepCapFor(state)
                local boundary = refundBoundaryFor(state)
                refund = math.min(wantedRefund, stepCap)
                Assist.refundDebt = math.max(0, wantedRefund - refund)
                local cap = math.min(Assist.lastObservedEndurance, boundary)
                local target = clamp(endurance + refund, endurance, cap)
                refund = math.max(0, target - endurance)
                if target > endurance and Assist.SetEnduranceSafe(player, target, "LOCOMOTION_BAND_REFUND") then
                    if state == "RED_EXHAUSTED_SUPPORT" then
                        Core.YellowRedSignals.PulseMaxRecovery("LONG_MIGRATION_STAMINA_ASSIST")
                    end
                    hungerCost = applyHungerCost(player, hunger, state, refund, resource)
                    Assist.summary.rawLoss = Assist.summary.rawLoss + rawLoss
                    Assist.summary.refund = Assist.summary.refund + refund
                    Assist.summary.debt = Assist.refundDebt
                    Assist.summary.smoothSamples = Assist.summary.smoothSamples + 1
                    Assist.summary.hungerCost = Assist.summary.hungerCost + hungerCost
                    logSmoothSample(state, rawLoss, refund)
                    endurance = target
                elseif Assist.refundDebt > 0 then
                    logSmoothSample(state, rawLoss, 0)
                end
            elseif resource.locked then
                Assist.summary.blockedRefund = Assist.summary.blockedRefund + 1
                clearRefundDebt("RESOURCE_LOCKED")
                if Core.Log and Core.Log.EveryFrames then
                    Core.LogThrottle.Blocked("RESOURCE_GATE", tostring(resource.reason or "LOCKED"))
                end
            end
        elseif rawLoss <= 0 and not isLocomotion(runningState) then
            clearRefundDebt("NOT_LOCOMOTION")
        end
    end

    if Constants.IsFiniteNumber(endurance) then
        Assist.lastObservedEndurance = endurance
    end

    Assist.lastStatus = {
        state = state,
        iconState = state,
        iconReason = "ENDURANCE_VALUE_ONLY",
        resourceAvailable = resource.available,
        resourceLocked = resource.locked,
        resourceReason = resource.reason,
        endurance = endurance,
        hunger = hunger,
        fatigue = fatigue,
        calories = calories,
        running = runningState,
        skip = skip,
        rawLoss = rawLoss,
        refund = refund,
        refundDebt = Assist.refundDebt,
        hungerCost = hungerCost,
    }

    if Core.Log and Core.Log.EveryRealMs then
        local hasSummaryWork = rawLoss > 0 or refund > 0 or hungerCost > 0
            or (Assist.summary.smoothSamples or 0) > 0
            or (Assist.summary.blockedRefund or 0) > 0
            or (Assist.summary.blockedHunger or 0) > 0
        if hasSummaryWork then
            Core.Log.EveryRealMs("stamina_summary", Config.SUMMARY_INTERVAL_REAL_MS or 10000, string.format("[XNP STAMINA SUMMARY] state=%s raw_loss=%.6f refund=%.6f debt=%.6f hunger_cost=%.6f samples=%d blocked_refund=%d blocked_hunger=%d", tostring(state), Assist.summary.rawLoss, Assist.summary.refund, Assist.refundDebt, Assist.summary.hungerCost, Assist.summary.smoothSamples, Assist.summary.blockedRefund, Assist.summary.blockedHunger))
        end
        if resource.locked == true then Core.LogThrottle.Blocked("RESOURCE_GATE", "LOCKED_SUMMARY") end
    end
    return true
end

function Assist.GetStatus(player)
    return Assist.lastStatus
end

function Assist.NotifySkillCost(source, windowSeconds)
    local window = windowSeconds or Config.BREAKOUT_COST_REFUND_IGNORE_WINDOW or 0.50
    Assist.ignoreRefundUntil = math.max(Assist.ignoreRefundUntil or 0, nowSeconds() + window)
    Assist.ignoreRefundReason = source or "SKILL_COST"
    clearRefundDebt("SKILL_COST")
    if Core.FoodReserveConversion then
        Core.FoodReserveConversion.NotifyDiscreteCost(Assist.ignoreRefundReason)
    end
    Core.LogThrottle.Blocked("STAMINA_SMOOTH", "ACTION_OR_DISCRETE_COST_" .. tostring(Assist.ignoreRefundReason))
end

function Assist.Cleanup(reason)
    Assist.lastObservedEndurance = nil
    Assist.lastState = nil
    Assist.refundDebt = 0
    Assist.lastSmoothState = nil
    Assist.lastDebtClearReason = nil
    Assist.lastBlockedReason = nil
    Assist.ignoreRefundUntil = 0
    Assist.ignoreRefundReason = nil
    Assist.lastStatus = {
        state = "GREEN_READY",
        iconState = "GREEN_READY",
        iconReason = "CLEANUP",
        resourceAvailable = true,
        cleanupReason = reason,
    }
end

Core.LongMigrationStaminaAssist = Assist
return Assist
