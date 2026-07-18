require "TimedActions/ISTimedActionQueue"
require "XNP_PZ_DistanceRunner/XNP_DR_ExtraTraits"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenSkill"
require "XNP_PZ_DistanceRunner/XNP_DR_GreenWhitePrepareAction"

local Core = XNP_PZ_DistanceRunner

local WhiteAction = {
    HEALTH_COST = 0.50,
    ENDURANCE_COST = 0.50,
    UNHAPPINESS_COST = 50.0,
    activeByPlayer = setmetatable({}, { __mode = "k" }),
    lastCompletedByPlayer = setmetatable({}, { __mode = "k" }),
}

local function healthCostAllowed(values, cost)
    if values.health <= cost.health then return false end
    return cost.safetyFloor <= 0 or values.health - cost.health >= cost.safetyFloor
end

local function costs()
    local tuning = Core.SandboxTuning
    return {
        health = tuning.GetNumber("GreenWhiteHealthCost", WhiteAction.HEALTH_COST, 0.0, 0.50),
        endurance = tuning.GetNumber("GreenWhiteEnduranceCost", WhiteAction.ENDURANCE_COST, 0.0, 1.0),
        unhappiness = tuning.GetNumber("GreenWhiteUnhappinessCost", WhiteAction.UNHAPPINESS_COST, 0.0, 100.0),
        boredom = tuning.GetNumber("GreenWhiteBoredomCost", 5.0, 0.0, 100.0),
        hunger = tuning.GetNumber("GreenWhiteHungerCost", 0.0, 0.0, 1.0),
        safetyFloor = tuning.GetNumber("GreenWhiteSafetyFloorPercent", 0.0, 0.0, 95.0) / 100.0,
    }
end

local function nowMs()
    return type(getTimestampMs) == "function" and getTimestampMs() or os.time() * 1000
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function stats(player)
    local ok, value = invoke(player, "getStats")
    return ok and value or nil
end

local function readStat(statsObject, stat)
    if not statsObject or not stat then return nil end
    local ok, value = pcall(function() return statsObject:get(stat) end)
    return ok and tonumber(value) or nil
end

local function writeStat(statsObject, stat, value)
    if not statsObject or not stat then return false end
    return pcall(function() statsObject:set(stat, value) end)
end

local function snapshot(player)
    local statsObject = stats(player)
    if not statsObject or not CharacterStat or not CharacterStat.ENDURANCE or not CharacterStat.UNHAPPINESS then
        return nil, "COST_STATS_UNAVAILABLE"
    end
    local health = nil
    local healthOk, healthValue = invoke(player, "getHealth")
    if healthOk then health = tonumber(healthValue) end
    local endurance = readStat(statsObject, CharacterStat.ENDURANCE)
    local unhappiness = readStat(statsObject, CharacterStat.UNHAPPINESS)
    local boredom = CharacterStat.BOREDOM and readStat(statsObject, CharacterStat.BOREDOM) or nil
    local hunger = CharacterStat.HUNGER and readStat(statsObject, CharacterStat.HUNGER) or nil
    if not health or not endurance or not unhappiness then return nil, "COST_VALUES_UNAVAILABLE" end
    return { stats = statsObject, health = health, endurance = endurance,
        unhappiness = unhappiness, boredom = boredom, hunger = hunger }, "READY"
end

function WhiteAction.CanStart(player)
    if not player then return false, "PLAYER_MISSING" end
    if Core.SandboxTuning.GetBoolean("GreenWhiteActionEnabled", true) ~= true then return false, "WHITE_ACTION_DISABLED" end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then return false, "GREEN_TRAIT_MISSING" end
    local deadOk, dead = invoke(player, "isDead")
    if deadOk and dead == true then return false, "PLAYER_DEAD" end
    if Core.GreenSkill and Core.GreenSkill.IsEnabled(player) == true then return false, "GREEN_MODE_NOT_WHITE" end
    if WhiteAction.activeByPlayer[player] then return false, "WHITE_ACTION_ALREADY_ACTIVE" end
    local cooldownMs = Core.SandboxTuning.GetNumber("GreenWhiteCooldownSeconds", 0.0, 0.0, 300.0) * 1000
    local lastCompleted = WhiteAction.lastCompletedByPlayer[player]
    if lastCompleted and nowMs() - lastCompleted < cooldownMs then
        return false, "WHITE_ACTION_COOLDOWN"
    end
    local values, reason = snapshot(player)
    if not values then return false, reason end
    local cost = costs()
    if not healthCostAllowed(values, cost) then return false, "HEALTH_SAFETY_FLOOR" end
    if values.endurance < cost.endurance then return false, "INSUFFICIENT_ENDURANCE_FOR_COST" end
    if values.unhappiness + cost.unhappiness > 100.0 then return false, "UNHAPPINESS_COST_WOULD_CLAMP" end
    if values.boredom and values.boredom + cost.boredom > 100.0 then return false, "BOREDOM_COST_WOULD_CLAMP" end
    if cost.hunger > 0 and (not values.hunger or values.hunger + cost.hunger > 1.0) then return false, "HUNGER_COST_WOULD_CLAMP" end
    return true, "READY"
end

function WhiteAction.IsActionValid(player, action)
    if WhiteAction.activeByPlayer[player] ~= action then return false end
    if not Core.ExtraTraits or Core.ExtraTraits.PlayerHas(player, "GREEN") ~= true then return false end
    local deadOk, dead = invoke(player, "isDead")
    if deadOk and dead == true then return false end
    return Core.GreenSkill and Core.GreenSkill.IsEnabled(player) ~= true
end

function WhiteAction.ClearAction(player, action)
    if player and WhiteAction.activeByPlayer[player] == action then WhiteAction.activeByPlayer[player] = nil end
end

function WhiteAction.Commit(player, action)
    if WhiteAction.activeByPlayer[player] ~= action then return false, "ACTION_OWNERSHIP_MISMATCH" end
    local values, reason = snapshot(player)
    if not values then return false, reason end
    local cost = costs()
    if not healthCostAllowed(values, cost) then return false, "HEALTH_SAFETY_FLOOR" end
    if values.endurance < cost.endurance then return false, "INSUFFICIENT_ENDURANCE_FOR_COST" end
    if values.unhappiness + cost.unhappiness > 100.0 then return false, "UNHAPPINESS_COST_WOULD_CLAMP" end
    if values.boredom and values.boredom + cost.boredom > 100.0 then return false, "BOREDOM_COST_WOULD_CLAMP" end
    if cost.hunger > 0 and (not values.hunger or values.hunger + cost.hunger > 1.0) then return false, "HUNGER_COST_WOULD_CLAMP" end

    local nextHealth = values.health - cost.health
    local nextEndurance = values.endurance - cost.endurance
    local nextUnhappiness = values.unhappiness + cost.unhappiness
    local healthWritten = invoke(player, "setHealth", nextHealth)
    if not healthWritten then return false, "HEALTH_COST_WRITE_FAILED" end
    if not writeStat(values.stats, CharacterStat.ENDURANCE, nextEndurance) then
        invoke(player, "setHealth", values.health)
        return false, "ENDURANCE_COST_WRITE_FAILED_ROLLED_BACK"
    end
    if not writeStat(values.stats, CharacterStat.UNHAPPINESS, nextUnhappiness) then
        writeStat(values.stats, CharacterStat.ENDURANCE, values.endurance)
        invoke(player, "setHealth", values.health)
        return false, "MOOD_COST_WRITE_FAILED_ROLLED_BACK"
    end
    if values.boredom and cost.boredom > 0 and not writeStat(values.stats, CharacterStat.BOREDOM, values.boredom + cost.boredom) then
        writeStat(values.stats, CharacterStat.UNHAPPINESS, values.unhappiness)
        writeStat(values.stats, CharacterStat.ENDURANCE, values.endurance)
        invoke(player, "setHealth", values.health)
        return false, "BOREDOM_COST_WRITE_FAILED_ROLLED_BACK"
    end
    if cost.hunger > 0 and not writeStat(values.stats, CharacterStat.HUNGER, values.hunger + cost.hunger) then
        if values.boredom then writeStat(values.stats, CharacterStat.BOREDOM, values.boredom) end
        writeStat(values.stats, CharacterStat.UNHAPPINESS, values.unhappiness)
        writeStat(values.stats, CharacterStat.ENDURANCE, values.endurance)
        invoke(player, "setHealth", values.health)
        return false, "HUNGER_COST_WRITE_FAILED_ROLLED_BACK"
    end
    local enabled, enabledState = Core.GreenSkill.SetEnabled(player, true)
    if not enabled then
        if values.hunger then writeStat(values.stats, CharacterStat.HUNGER, values.hunger) end
        if values.boredom then writeStat(values.stats, CharacterStat.BOREDOM, values.boredom) end
        writeStat(values.stats, CharacterStat.UNHAPPINESS, values.unhappiness)
        writeStat(values.stats, CharacterStat.ENDURANCE, values.endurance)
        invoke(player, "setHealth", values.health)
        return false, "GREEN_ARM_FAILED_ROLLED_BACK:" .. tostring(enabledState)
    end
    local dataOk, data = invoke(player, "getModData")
    if dataOk and type(data) == "table" then data.XNP_DR_GREEN_WHITE_PREPARED_056062 = true end
    WhiteAction.lastCompletedByPlayer[player] = nowMs()
    print("[XNP GREEN WHITE ACTION] complete=true health_cost=" .. tostring(cost.health)
        .. " endurance_cost=" .. tostring(cost.endurance)
        .. " unhappiness_cost=" .. tostring(cost.unhappiness)
        .. " boredom_cost=" .. tostring(cost.boredom)
        .. " hunger_cost=" .. tostring(cost.hunger)
        .. " cost_direction=DECREASE_HEALTH_AND_ENDURANCE_INCREASE_MOOD_COSTS result=GREEN_MODE_ARMED")
    return true, "GREEN_MODE_ARMED"
end

function WhiteAction.Request(player, source)
    local allowed, reason = WhiteAction.CanStart(player)
    if not allowed then
        print("[XNP GREEN WHITE ACTION] accepted=false reason=" .. tostring(reason))
        return false, reason
    end
    local action = XNPDRGreenWhitePrepareAction:new(player)
    WhiteAction.activeByPlayer[player] = action
    ISTimedActionQueue.add(action)
    local cost = costs()
    print("[XNP GREEN WHITE ACTION] accepted=true source=" .. tostring(source or "WHITE_LEFT_DOUBLE_CLICK")
        .. " timed_action=true health_cost=" .. tostring(cost.health)
        .. " endurance_cost=" .. tostring(cost.endurance)
        .. " unhappiness_cost=" .. tostring(cost.unhappiness)
        .. " boredom_cost=" .. tostring(cost.boredom))
    return true, "QUEUED"
end

function WhiteAction.GetDurationTicks()
    return math.max(1, math.floor(Core.SandboxTuning.GetNumber("GreenWhiteActionDurationSeconds", 4.0, 0.5, 30.0) * 25 + 0.5))
end

function WhiteAction.MidActionSoundEnabled()
    return Core.SandboxTuning.GetBoolean("EnableSounds", true)
        and Core.SandboxTuning.GetBoolean("GreenWhiteMidActionSoundEnabled", true)
end

function WhiteAction.Cleanup(player)
    if player then WhiteAction.activeByPlayer[player] = nil end
end

Core.GreenWhiteAction = WhiteAction
return WhiteAction
