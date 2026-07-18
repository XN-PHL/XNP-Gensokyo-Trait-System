require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Config = Core.Config
local Constants = Core.Constants

local Food = {
    startupLogged = false,
    lastRequest = 0,
}

local function nowSeconds()
    if type(getTimestampMs) == "function" then
        return getTimestampMs() / 1000
    end
    return os.time()
end

local function logStartup()
    if Food.startupLogged then
        return
    end
    Food.startupLogged = true
    Core.LogThrottle.Event("[XNP FOOD RESERVE] state=ARMED write_path=AUTHORITY_ONLY trigger=0.30 target=0.40 reserve_floor_min=0.40 rate_per_second=0.01 ratio=1.00")
end

local function sendRequest(player, command, args)
    if type(sendClientCommand) ~= "function" then
        return false
    end
    local ok = pcall(function()
        sendClientCommand(player, "XNPDistanceRunner", command, args or {})
    end)
    return ok == true
end

function Food.NotifyDiscreteCost(source, player)
    player = player or (type(getSpecificPlayer) == "function" and getSpecificPlayer(0) or nil)
    if Core.Authority.IsClient() then
        if not sendRequest(player, "foodDiscreteCost", { source = tostring(source or "SKILL_COST") }) then
            Core.LogThrottle.Blocked("FOOD_RESERVE", "DISCRETE_COST_NOTIFY_FAILED")
        end
        return
    end
    Core.Authority.NotifyFoodDiscreteCost(player)
end

function Food.ApplyDiscreteCost(amount, source, player)
    player = player or (type(getSpecificPlayer) == "function" and getSpecificPlayer(0) or nil)
    if not player or not Constants.IsFiniteNumber(amount) or amount <= 0 then
        return false
    end
    amount = math.min(amount, 0.055)
    if Core.Authority.IsClient() then
        local sent = sendRequest(player, "foodApplyDiscreteCost", {
            amount = amount,
            source = tostring(source or "SKILL_COST"),
        })
        if not sent then
            Core.LogThrottle.Blocked("FOOD_RESERVE", "DISCRETE_COST_REQUEST_FAILED")
        end
        return sent
    end
    local ok, reason = Core.Authority.ApplyDiscreteHungerCost(player, amount)
    if not ok then
        Core.LogThrottle.Blocked("FOOD_RESERVE", reason)
    end
    return ok
end

function Food.Tick(player)
    logStartup()
    if Config.ENABLE_TIERED_FOOD_RECOVERY == true then
        return false
    end
    if Config.ENABLE_LOW_ENDURANCE_FOOD_CONVERSION ~= true or not player then
        return false
    end
    local now = nowSeconds()
    if now - Food.lastRequest < 1.0 then
        return false
    end
    Food.lastRequest = now
    if Core.Authority.IsClient() then
        if not sendRequest(player, "foodTick", {}) then
            Core.LogThrottle.Blocked("FOOD_RESERVE", "AUTHORITY_REQUEST_FAILED")
        end
        return false
    end
    local ok, reason, enduranceDelta, foodCost = Core.Authority.ProcessFoodTick(player)
    if ok then
        print("[XNP FOOD RESERVE] transfer side=SINGLEPLAYER_AUTHORITY endurance_delta=" .. string.format("%.4f", enduranceDelta or 0) .. " food_reserve_delta=-" .. string.format("%.4f", foodCost or 0))
        return true
    end
    Core.LogThrottle.Blocked("FOOD_RESERVE", reason)
    return false
end

function Food.Cleanup()
    Food.lastRequest = 0
end

Core.FoodReserveConversion = Food
return Food
