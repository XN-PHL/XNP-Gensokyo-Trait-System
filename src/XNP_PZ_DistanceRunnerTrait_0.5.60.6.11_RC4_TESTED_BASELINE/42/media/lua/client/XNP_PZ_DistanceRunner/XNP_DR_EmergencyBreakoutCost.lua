require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local EmergencyBreakoutCost = {
    debt = 0,
    penaltyApiAudited = false,
    safeMinorPenaltyApi = false,
    chargedActionIds = {},
    preBiteSuppressUntil = 0,
    configLogged = false,
}

XNP_DR_EmergencyBreakoutCost = EmergencyBreakoutCost
    print("[XNP COST] rebalance=drag_capture_native_trip_impact")

local function logConfigOnce()
    if EmergencyBreakoutCost.configLogged then
        return
    end
    EmergencyBreakoutCost.configLogged = true
    print("[XNP COST] action_bus_single_charge=" .. tostring(Config.COST_ACTION_BUS_SINGLE_CHARGE == true))
end

local function fmt(value)
    if not Constants.IsFiniteNumber(value) then
        return "NA"
    end
    return string.format("%.4f", value)
end

local function enduranceStat(player)
    if not player or type(player.getStats) ~= "function" or not CharacterStat or not CharacterStat.ENDURANCE then
        return nil
    end
    local stats = player:getStats()
    if not stats or type(stats.get) ~= "function" or type(stats.set) ~= "function" then
        return nil
    end
    return stats
end

function EmergencyBreakoutCost.AuditMinorPenaltyApi(player)
    if EmergencyBreakoutCost.penaltyApiAudited then
        return EmergencyBreakoutCost.safeMinorPenaltyApi
    end
    EmergencyBreakoutCost.penaltyApiAudited = true
    EmergencyBreakoutCost.safeMinorPenaltyApi = false
    if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUTCOST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
    return false
end

local function chanceForEndurance(before)
    if before <= Config.EMERGENCY_BREAKOUT_CRITICAL_STAMINA_THRESHOLD then
        return Config.EMERGENCY_BREAKOUT_CRITICAL_STAMINA_PENALTY_CHANCE or 0
    end
    if before <= Config.EMERGENCY_BREAKOUT_LOW_STAMINA_THRESHOLD then
        return Config.EMERGENCY_BREAKOUT_LOW_STAMINA_PENALTY_CHANCE or 0
    end
    return 0
end

local function costForType(costType)
    if costType == "PRE_BITE_JOG_RESCUE" then
        return Config.PREBITE_JOG_RESCUE_COST or 0.060
    elseif costType == "EMERGENCY_ASSIST" then
        return Config.EMERGENCY_ASSIST_COST
    elseif costType == "TRUE_EMERGENCY" then
        return Config.DRAGDOWN_TRUE_EMERGENCY_COST
    elseif costType == "FATAL_SURROUNDED" then
        return Config.FATAL_SURROUNDED_COST
    end
    return Config.EMERGENCY_BREAKOUT_BASE_COST
end

function EmergencyBreakoutCost.Apply(player, triggerId, costType, actionId)
    logConfigOnce()
    if not Config.EMERGENCY_BREAKOUT_COST_ENABLED then
        return true, 0
    end
    local resolvedType = costType or "TRUE_EMERGENCY"
    local now = type(getTimestampMs) == "function" and getTimestampMs() / 1000 or os.time()
    if resolvedType ~= "PRE_BITE_JOG_RESCUE" and now < (EmergencyBreakoutCost.preBiteSuppressUntil or 0) then
        print("[XNP EMERGENCY COST FLOOR] duplicate_charge_same_window=false source=" .. tostring(resolvedType) .. " suppressed_by=PRE_BITE_JOG_RESCUE")
        return true, 0
    end
    if Config.COST_ACTION_BUS_SINGLE_CHARGE and actionId ~= nil then
        if EmergencyBreakoutCost.chargedActionIds[actionId] then
            if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUTCOST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            return true, 0
        end
    elseif Config.COST_ACTION_BUS_SINGLE_CHARGE and actionId == nil then
        if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUTCOST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return true, 0
    end
    local stats = enduranceStat(player)
    if not stats then
        if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUTCOST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUTCOST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return true, 0
    end
    local before = stats:get(CharacterStat.ENDURANCE)
    if not Constants.IsFiniteNumber(before) then
        if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUTCOST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUTCOST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
        return true, 0
    end
    local cost = costForType(resolvedType)
    if before <= Config.EMERGENCY_BREAKOUT_CRITICAL_STAMINA_THRESHOLD then
        cost = cost * Config.EMERGENCY_CRITICAL_STAMINA_COST_MULTIPLIER
    elseif before <= Config.EMERGENCY_BREAKOUT_LOW_STAMINA_THRESHOLD then
        cost = cost * Config.EMERGENCY_LOW_STAMINA_COST_MULTIPLIER
    end
    local floor = Config.EMERGENCY_ENDURANCE_FLOOR or 0.05
    local appliedCost = math.min(cost, math.max(0, before - floor))
    local after = before - appliedCost
    if not Core.Authority or not Core.Authority.CanWriteNonFoodStats(player, resolvedType) then
        return true, 0
    end
    local ok = pcall(function()
        stats:set(CharacterStat.ENDURANCE, after)
    end)
    if not ok then
        print("[XNP EMERGENCY COST] endurance_before=" .. fmt(before) .. " endurance_after=" .. fmt(before) .. " cost=" .. fmt(cost) .. " result=set_failed")
        print("[XNP COST] type=" .. tostring(resolvedType) .. " before=" .. fmt(before) .. " after=" .. fmt(before) .. " cost=" .. fmt(cost) .. " result=set_failed")
        return true, 0
    end
    if actionId ~= nil then
        EmergencyBreakoutCost.chargedActionIds[actionId] = true
    end
    if resolvedType == "PRE_BITE_JOG_RESCUE" then
        EmergencyBreakoutCost.preBiteSuppressUntil = now + (Config.PREBITE_JOG_RESCUE_WINDOW_COOLDOWN or 0.75)
    end
    print("[XNP EMERGENCY COST FLOOR] nominal=" .. fmt(cost) .. " before=" .. fmt(before) .. " applied=" .. fmt(appliedCost) .. " after=" .. fmt(after))
    print("[XNP EMERGENCY COST FLOOR] floor=" .. fmt(floor))
    print("[XNP EMERGENCY COST FLOOR] duplicate_charge_same_window=false")
    print("[XNP EMERGENCY COST] endurance_before=" .. fmt(before) .. " endurance_after=" .. fmt(after) .. " cost=" .. fmt(appliedCost))
    print("[XNP COST] type=" .. tostring(resolvedType) .. " before=" .. fmt(before) .. " after=" .. fmt(after) .. " cost=" .. fmt(appliedCost))
    if Core.StatusIconUI and Core.StatusIconUI.NotifySkillTriggered then
        Core.StatusIconUI.NotifySkillTriggered(resolvedType)
    end
    if actionId ~= nil then
        print("[XNP COST] charged action_id=" .. tostring(actionId))
    end

    local penaltyChance = chanceForEndurance(before)
    if Config.EMERGENCY_BREAKOUT_LOW_STAMINA_PENALTY_ENABLED and penaltyChance > 0 then
        local roll = ZombRandFloat and ZombRandFloat(0, 1) or math.random()
        print("[XNP EMERGENCY COST] low_stamina=true penalty_roll=" .. fmt(roll) .. " chance=" .. fmt(penaltyChance))
        if roll <= penaltyChance then
            if EmergencyBreakoutCost.AuditMinorPenaltyApi(player) then
                print("[XNP EMERGENCY COST] penalty_result=minor_debt no_bite=true no_infection=true no_heal=true")
            else
                EmergencyBreakoutCost.debt = EmergencyBreakoutCost.debt + appliedCost
                if Core.LogThrottle then Core.LogThrottle.Blocked("EMERGENCYBREAKOUTCOST", "DIRECT_BLOCKED_LOG_SUPPRESSED") end
            end
        end
    end
    print("[XNP EMERGENCY COST] no_bite=true no_infection=true no_heal=true")
    print("[XNP COST] no_bite=true no_infection=true no_heal=true")
    return true, appliedCost
end

function EmergencyBreakoutCost.GetDebt()
    return EmergencyBreakoutCost.debt
end

Core.EmergencyBreakoutCost = EmergencyBreakoutCost
return EmergencyBreakoutCost
