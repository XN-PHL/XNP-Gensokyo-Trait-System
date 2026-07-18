require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local TieredFoodRecovery = {
    startupLogged = false,
    nextDue = 0,
    pulseCount = 0,
    lastBand = nil,
}

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

local function playerDeadOrSleeping(player)
    if not player then
        return true
    end
    if type(player.isDead) == "function" then
        local ok, dead = pcall(function() return player:isDead() end)
        if ok and dead == true then return true end
    end
    if type(player.isAsleep) == "function" then
        local ok, asleep = pcall(function() return player:isAsleep() end)
        if ok and asleep == true then return true end
    end
    return false
end

local function sendPulseRequest(player, band, enduranceGain, foodCost, reserveFloor)
    if type(sendClientCommand) ~= "function" then
        return false
    end
    return pcall(function()
        sendClientCommand(player, "XNPDistanceRunner", "tieredFoodPulse", {
            band = tostring(band),
            enduranceGain = enduranceGain,
            foodCost = foodCost,
            reserveFloor = reserveFloor,
        })
    end) == true
end

local function pulseForBand(band)
    if band == "BLUE_STAMINA_SUPPORT" then
        return Config.BLUE_ENDURANCE_GAIN_PER_PULSE or 0.015, Config.BLUE_FOOD_COST_PER_PULSE or 0.005
    elseif band == "YELLOW_LOW_STAMINA_SUPPORT" then
        return Config.YELLOW_RED_ENDURANCE_GAIN_PER_PULSE or 0.020, Config.YELLOW_RED_FOOD_COST_PER_PULSE or 0.010
    elseif band == "RED_EXHAUSTED_SUPPORT" then
        return Config.RED_ENDURANCE_GAIN_PER_PULSE or Config.YELLOW_RED_ENDURANCE_GAIN_PER_PULSE or 0.020,
            Config.RED_FOOD_COST_PER_PULSE or Config.YELLOW_RED_FOOD_COST_PER_PULSE or 0.010
    end
    return 0, 0
end

local function logStartupOnce()
    if TieredFoodRecovery.startupLogged then
        return
    end
    TieredFoodRecovery.startupLogged = true
    Core.LogThrottle.Event("[XNP TIERED FOOD] active=true writer_count=1 old_hunger_conversion_cost_active=false")
    Core.LogThrottle.Event("[XNP TIERED FOOD] blue_food=0.005 blue_endurance=0.015 yellow_red_food=0.010 yellow_red_endurance=0.020 pulse_seconds=2.0")
end

function TieredFoodRecovery.NotifyDiscreteCost(source, player)
    if Core.FoodReserveConversion and Core.FoodReserveConversion.NotifyDiscreteCost then
        Core.FoodReserveConversion.NotifyDiscreteCost(source, player)
    end
end

function TieredFoodRecovery.Tick(player)
    logStartupOnce()
    if Config.ENABLE_TIERED_FOOD_RECOVERY ~= true or Config.TIERED_FOOD_RECOVERY_ACTIVE ~= true then
        return false
    end
    if playerDeadOrSleeping(player) or not Core.Trait or not Core.Trait.PlayerHasTrait(player) then
        TieredFoodRecovery.nextDue = 0
        return false
    end

    local band = Core.EnduranceBandState and Core.EnduranceBandState.GetStableState and Core.EnduranceBandState.GetStableState(player) or nil
    local state = band and band.state or "GREEN_READY"
    if state == "GREEN_READY" then
        TieredFoodRecovery.nextDue = 0
        TieredFoodRecovery.lastBand = state
        return false
    end
    if state ~= TieredFoodRecovery.lastBand then
        TieredFoodRecovery.nextDue = nowSeconds() + math.max(Config.FOOD_RECOVERY_PULSE_SECONDS or 2.0, 0.5)
        TieredFoodRecovery.lastBand = state
        return false
    end

    local now = nowSeconds()
    if TieredFoodRecovery.nextDue == 0 then
        TieredFoodRecovery.nextDue = now + math.max(Config.FOOD_RECOVERY_PULSE_SECONDS or 2.0, 0.5)
        return false
    end
    if now < TieredFoodRecovery.nextDue then
        return false
    end
    TieredFoodRecovery.nextDue = now + math.max(Config.FOOD_RECOVERY_PULSE_SECONDS or 2.0, 0.5)

    if Core.Authority.IsFoodPulseBlockedByDiscreteCost
        and Core.Authority.IsFoodPulseBlockedByDiscreteCost(player, Config.LOW_ENDURANCE_FOOD_CONVERSION_DISCRETE_COST_DELAY or 1.0) then
        Core.LogThrottle.Blocked("TIERED_FOOD", "DISCRETE_COST_DELAY")
        return false
    end

    local enduranceGain, foodCost = pulseForBand(state)
    local reserveFloor = math.max(Config.MINIMUM_TIERED_FOOD_RESERVE or Config.LOW_ENDURANCE_FOOD_CONVERSION_MIN_RESERVE or 0.40, 0.40)
    if enduranceGain <= 0 or foodCost <= 0 then
        Core.LogThrottle.Blocked("TIERED_FOOD", "INVALID_PULSE_CONFIG")
        return false
    end

    if Core.Authority.IsClient() then
        if not sendPulseRequest(player, state, enduranceGain, foodCost, reserveFloor) then
            Core.LogThrottle.Blocked("TIERED_FOOD", "AUTHORITY_REQUEST_FAILED")
        end
        return false
    end

    local ok, reason, actualEndurance, actualFood, nextEndurance, nextReserve =
        Core.Authority.ApplyTieredFoodPulse(player, enduranceGain, foodCost, reserveFloor)
    if not ok then
        Core.LogThrottle.Blocked("TIERED_FOOD", reason)
        return false
    end
    TieredFoodRecovery.pulseCount = TieredFoodRecovery.pulseCount + 1
    if Config.DEBUG == true then
        print("[XNP TIERED FOOD] pulse band=" .. tostring(state)
            .. " endurance_delta=" .. fmt(actualEndurance)
            .. " food_reserve_delta=-" .. fmt(actualFood)
            .. " endurance_after=" .. fmt(nextEndurance)
            .. " reserve_after=" .. fmt(nextReserve))
    end
    return true
end

function TieredFoodRecovery.Cleanup()
    TieredFoodRecovery.nextDue = 0
    TieredFoodRecovery.lastBand = nil
end

Core.TieredFoodRecovery = TieredFoodRecovery
return TieredFoodRecovery
