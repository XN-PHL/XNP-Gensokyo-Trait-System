require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_Authority"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"
require "XNP_PZ_DistanceRunner/XNP_DR_MasterEffectState"

local Core = XNP_PZ_DistanceRunner
local Server = { registered = false }

function Server.OnClientCommand(module, command, player, args)
    if module ~= "XNPDistanceRunner" or not player then
        return
    end
    if Core.Authority.IsClient() then
        Core.LogThrottle.Blocked("FOOD_AUTHORITY", "CLIENT_HANDLER_REJECTED")
        return
    end
    if command == "foodDiscreteCost" then
        if Core.MasterEffectState and Core.MasterEffectState.IsEnabled(player) ~= true then
            Core.LogThrottle.Blocked("FOOD_AUTHORITY", "MASTER_DISABLED")
            return
        end
        Core.Authority.NotifyFoodDiscreteCost(player)
        return
    end
    if command == "foodApplyDiscreteCost" then
        if Core.MasterEffectState and Core.MasterEffectState.IsEnabled(player) ~= true then
            Core.LogThrottle.Blocked("FOOD_AUTHORITY", "MASTER_DISABLED")
            return
        end
        local amount = args and tonumber(args.amount) or nil
        local ok, reason = Core.Authority.ApplyDiscreteHungerCost(player, amount)
        if not ok then
            Core.LogThrottle.Blocked("FOOD_AUTHORITY", reason)
        end
        return
    end
    if command == "foodTick" then
        if Core.MasterEffectState and Core.MasterEffectState.IsEnabled(player) ~= true then
            Core.LogThrottle.Blocked("FOOD_AUTHORITY", "MASTER_DISABLED")
            return
        end
        local ok, reason, enduranceDelta, foodCost = Core.Authority.ProcessFoodTick(player)
        if ok then
            print("[XNP FOOD RESERVE] transfer side=SERVER_AUTHORITY endurance_delta=" .. string.format("%.4f", enduranceDelta or 0) .. " food_reserve_delta=-" .. string.format("%.4f", foodCost or 0))
        else
            Core.LogThrottle.Blocked("FOOD_AUTHORITY", reason)
        end
        return
    end
    if command == "tieredFoodPulse" then
        if Core.MasterEffectState and Core.MasterEffectState.IsEnabled(player) ~= true then
            Core.LogThrottle.Blocked("FOOD_AUTHORITY", "MASTER_DISABLED")
            return
        end
        local enduranceGain = args and tonumber(args.enduranceGain) or nil
        local foodCost = args and tonumber(args.foodCost) or nil
        local reserveFloor = args and tonumber(args.reserveFloor) or nil
        local ok, reason, enduranceDelta, foodDelta = Core.Authority.ApplyTieredFoodPulse(player, enduranceGain, foodCost, reserveFloor)
        if ok then
            if Core.Config.DEBUG == true then
                print("[XNP TIERED FOOD] transfer side=SERVER_AUTHORITY endurance_delta=" .. string.format("%.4f", enduranceDelta or 0) .. " food_reserve_delta=-" .. string.format("%.4f", foodDelta or 0))
            end
        else
            Core.LogThrottle.Blocked("FOOD_AUTHORITY", reason)
        end
    end
end

function Server.Register()
    if Server.registered then
        return true
    end
    if Core.SandboxTuning and Core.SandboxTuning.loaded ~= true then
        Core.SandboxTuning.Load()
    end
    if Events and Events.OnClientCommand and type(Events.OnClientCommand.Add) == "function" then
        Events.OnClientCommand.Add(Server.OnClientCommand)
    end
    Server.registered = true
    Core.LogThrottle.Event("[XNP FOOD AUTHORITY] registered=true write_side=AUTHORITATIVE_ONLY")
    return true
end

Server.Register()
Core.FoodAuthorityServer = Server
return Server
