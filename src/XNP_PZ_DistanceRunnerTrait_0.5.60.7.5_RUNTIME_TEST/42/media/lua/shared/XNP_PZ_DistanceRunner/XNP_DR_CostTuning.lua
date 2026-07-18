require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_Config"
require "XNP_PZ_DistanceRunner/XNP_DR_SandboxTuning"
require "XNP_PZ_DistanceRunner/XNP_DR_LogThrottle"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants
local Config = Core.Config

local CostTuning = {
    lastLogKey = nil,
}

local registry = {
    JOG_BUMP = {
        consumer = "XNP_DR_JogBumpLaunch",
        baseKey = "JOG_BUMP_COST",
        global = true,
        zombie = true,
        routeKey = "JogBumpCostMultiplier",
    },
    SPRINT_PRECOLLISION = {
        consumer = "XNP_DR_BreakoutPush",
        baseKey = "SPRINT_PRECOLLISION_BASE_COST",
        global = true,
        zombie = true,
        routeKey = "SprintPrecollisionCostMultiplier",
    },
    SPRINT_VEHICLE_ZOMBIE = {
        consumer = "XNP_DR_SprintVehicleImpact",
        baseKey = "SPRINT_VEHICLE_ZOMBIE_BASE_COST",
        global = true,
        zombie = true,
        routeKey = "SprintVehicleZombieCostMultiplier",
    },
    CONTROLLED_ESCAPE = {
        consumer = "XNP_DR_BreakoutPush",
        baseKey = "GRAB_BREAKOUT_ENDURANCE_COST",
        global = true,
        zombie = false,
        routeKey = "ControlledEscapeCostMultiplier",
    },
    NATIVE_TRIP = {
        consumer = "XNP_DR_SprintTripConsequence",
        baseKey = nil,
        global = true,
        zombie = false,
        routeKey = "NativeTripCostMultiplier",
    },
    WALL_IMPACT = {
        consumer = "XNP_DR_SprintVehicleImpact",
        baseKey = "SPRINT_VEHICLE_WALL_COST",
        fixedBaseline = true,
        global = false,
        zombie = false,
        routeKey = nil,
    },
}

local function clampCost(value)
    if not Constants.IsFiniteNumber(value) then
        return 0.0
    end
    return Constants.Clamp(value, 0.0, 1.0)
end

local function values()
    if Core.SandboxTuning and Core.SandboxTuning.GetSnapshot then
        local snapshot = Core.SandboxTuning.GetSnapshot()
        if snapshot and snapshot.values then
            return snapshot.values
        end
    end
    return Config
end

local function routeEntry(route)
    return registry[tostring(route)]
end

function CostTuning.GetBaseCost(route)
    local entry = routeEntry(route)
    if not entry or not entry.baseKey then
        return 0.0
    end
    return Config[entry.baseKey] or Config[string.lower(entry.baseKey)] or 0.0
end

function CostTuning.GetGlobalMultiplier(route)
    local entry = routeEntry(route)
    if not entry or entry.global ~= true or entry.fixedBaseline == true then
        return 1.00
    end
    local v = values()
    return Constants.Clamp(v.GlobalSkillCostMultiplier or 1.00, 0.00, 2.00)
end

function CostTuning.GetZombieImpactMultiplier(route)
    local entry = routeEntry(route)
    if not entry or entry.zombie ~= true or entry.fixedBaseline == true then
        return 1.00
    end
    local v = values()
    return Constants.Clamp(v.ZombieImpactCostMultiplier or 1.00, 0.00, 2.00)
end

function CostTuning.GetRouteMultiplier(route)
    local entry = routeEntry(route)
    if not entry or not entry.routeKey or entry.fixedBaseline == true then
        return 1.00
    end
    local v = values()
    return Constants.Clamp(v[entry.routeKey] or 1.00, 0.00, 3.00)
end

function CostTuning.IsZombieImpactRoute(route)
    local entry = routeEntry(route)
    return entry ~= nil and entry.zombie == true
end

function CostTuning.IsWallImpactRoute(route)
    return tostring(route) == "WALL_IMPACT"
end

function CostTuning.GetConsumerName(route)
    local entry = routeEntry(route)
    return entry and entry.consumer or "UNKNOWN"
end

function CostTuning.GetDetails(route, baseCost)
    local entry = routeEntry(route)
    local base = baseCost
    if not Constants.IsFiniteNumber(base) then
        base = CostTuning.GetBaseCost(route)
    end
    if not entry then
        return {
            route = tostring(route),
            base = clampCost(base),
            global = 1.00,
            zombie = 1.00,
            routeMultiplier = 1.00,
            final = clampCost(base),
            consumer = "UNKNOWN",
            nativeTripMultiplierApplied = false,
            sandboxMultiplierApplied = false,
            fixedBaseline = false,
            valid = false,
        }
    end
    if entry.fixedBaseline == true then
        return {
            route = tostring(route),
            base = clampCost(base),
            global = 1.00,
            zombie = 1.00,
            routeMultiplier = 1.00,
            final = clampCost(base),
            consumer = entry.consumer,
            nativeTripMultiplierApplied = false,
            sandboxMultiplierApplied = false,
            fixedBaseline = true,
            valid = true,
        }
    end
    local global = CostTuning.GetGlobalMultiplier(route)
    local zombie = CostTuning.GetZombieImpactMultiplier(route)
    local routeMultiplier = CostTuning.GetRouteMultiplier(route)
    return {
        route = tostring(route),
        base = clampCost(base),
        global = global,
        zombie = zombie,
        routeMultiplier = routeMultiplier,
        final = clampCost((base or 0.0) * global * zombie * routeMultiplier),
        consumer = entry.consumer,
        nativeTripMultiplierApplied = tostring(route) == "NATIVE_TRIP",
        sandboxMultiplierApplied = true,
        fixedBaseline = false,
        valid = true,
    }
end

function CostTuning.ComputeFinalCost(route, baseCost)
    local details = CostTuning.GetDetails(route, baseCost)
    local key = tostring(details.route) .. "|" .. tostring(details.base) .. "|" .. tostring(details.final)
    if key ~= CostTuning.lastLogKey then
        CostTuning.lastLogKey = key
        print("[XNP COST ROUTE] route=" .. tostring(details.route) .. " consumer=" .. tostring(details.consumer))
        if details.fixedBaseline == true then
            print("[XNP COST ROUTE] route=" .. tostring(details.route) .. " tuning=FIXED_BASELINE")
    Core.LogThrottle.Event("[XNP COST ROUTE] route=" .. tostring(details.route) .. " multiplier_source=BASELINE")
            print(string.format("[XNP COST ROUTE] route=%s final_cost=%.4f baseline_preserved=true", tostring(details.route), details.final))
        else
            print(string.format("[XNP COST TUNING] route=%s base=%.4f global=%.2f zombie=%.2f route_multiplier=%.2f final=%.4f", tostring(details.route), details.base, details.global, details.zombie, details.routeMultiplier, details.final))
            if details.route == "JOG_BUMP" then
        Core.LogThrottle.Event("[XNP COST ROUTE] route=JOG_BUMP multiplier_source=BASELINE")
            elseif details.route == "NATIVE_TRIP" then
                print("[XNP COST ROUTE] route=NATIVE_TRIP native_trip_multiplier_applied=true")
            end
            print("[XNP COST TUNING] no_double_multiplier=true")
        end
    end
    return details.final
end

function CostTuning.ValidateRouteRegistry()
    local required = {
        "JOG_BUMP",
        "SPRINT_PRECOLLISION",
        "SPRINT_VEHICLE_ZOMBIE",
        "CONTROLLED_ESCAPE",
        "NATIVE_TRIP",
        "WALL_IMPACT",
    }
    for i = 1, #required do
        if registry[required[i]] == nil then
            return false, "MISSING_" .. required[i]
        end
    end
    if registry.WALL_IMPACT.routeKey ~= nil or registry.WALL_IMPACT.global == true or registry.WALL_IMPACT.zombie == true then
        return false, "WALL_IMPACT_NOT_ISOLATED"
    end
    if registry.NATIVE_TRIP.routeKey ~= "NativeTripCostMultiplier" then
        return false, "NATIVE_TRIP_ROUTE_KEY_INVALID"
    end
    return true, "OK"
end

function CostTuning.ValidateDefaultCostContract()
    local pre = Config.SPRINT_PRECOLLISION_BASE_COST * 1.00 * Config.ZOMBIE_IMPACT_DEFAULT * 1.00
    local vehicle = Config.SPRINT_VEHICLE_ZOMBIE_BASE_COST * 1.00 * Config.ZOMBIE_IMPACT_DEFAULT * 1.00
    return math.abs(pre - Config.SPRINT_PRECOLLISION_DEFAULT_FINAL_COST) < 0.000001
        and math.abs(vehicle - Config.SPRINT_VEHICLE_ZOMBIE_DEFAULT_FINAL_COST) < 0.000001,
        pre,
        vehicle
end

CostTuning.defaultContractValid, CostTuning.defaultPrecollisionCost, CostTuning.defaultVehicleCost = CostTuning.ValidateDefaultCostContract()

Core.CostTuning = CostTuning
return CostTuning
