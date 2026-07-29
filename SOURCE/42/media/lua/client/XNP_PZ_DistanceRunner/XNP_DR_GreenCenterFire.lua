local Core = XNP_PZ_DistanceRunner

local Fire = {
    createdCount = 0,
    failedCount = 0,
    failures = {},
    NON_PROPAGATION_RESULT = "BLOCKED_BY_NATIVE_API",
    NATIVE_FIRE_SPREAD_CONTROL_API = "NOT_FOUND_IN_AVAILABLE_B42_19_0_EVIDENCE",
    NATIVE_FIRE_OWNER_ID_AVAILABLE = false,
    NATIVE_FIRE_DESCENDANT_TRACKING_AVAILABLE = false,
}

local function logFailureOnce(reason)
    reason = tostring(reason or "UNKNOWN")
    if Fire.failures[reason] then return end
    Fire.failures[reason] = true
    print("[XNP GREEN CENTER FIRE] degraded_once=true reason=" .. reason
        .. " impact_blocked=false")
end

function Fire.Create(state)
    local options = state and state.options
    if not options or options.centerFireEnabled ~= true then return false, "DISABLED" end
    if options.centerFireSingleSquareOnly ~= true then
        return false, "UNSAFE_MULTI_SQUARE_MODE_REJECTED"
    end
    if options.centerFireAllowManualPropagation == true then
        return false, "MANUAL_PROPAGATION_MODE_REJECTED"
    end
    if not IsoFireManager or type(IsoFireManager.StartFire) ~= "function" then
        Fire.failedCount = Fire.failedCount + 1
        logFailureOnce("ISOFIREMANAGER_STARTFIRE_UNAVAILABLE")
        return false, "API_UNAVAILABLE"
    end
    if type(getCell) ~= "function" then return false, "CELL_API_UNAVAILABLE" end
    local okCell, cell = pcall(getCell)
    if not okCell or not cell or type(cell.getGridSquare) ~= "function" then
        return false, "CELL_UNAVAILABLE"
    end
    local okSquare, square = pcall(function()
        return cell:getGridSquare(math.floor(state.world_x), math.floor(state.world_y),
            math.floor(state.world_z))
    end)
    if not okSquare or not square then return false, "CENTER_SQUARE_UNAVAILABLE" end
    local strength = math.max(5, math.floor((options.centerFireStrength or 5) + 0.5))
    local lifetimeTicks = math.max(1,
        math.floor((options.centerFireLifetimeSeconds or 8.33) * 60 + 0.5))
    local ok = pcall(function()
        IsoFireManager.StartFire(cell, square, true, strength, lifetimeTicks)
    end)
    if not ok then
        Fire.failedCount = Fire.failedCount + 1
        logFailureOnce("STARTFIRE_CALL_FAILED")
        return false, "STARTFIRE_CALL_FAILED"
    end
    Fire.createdCount = Fire.createdCount + 1
    print("[XNP GREEN CENTER FIRE] created=true cast_id=" .. tostring(state.id)
        .. " initial_square_count=1 radius_loop=false strength=" .. tostring(strength)
        .. " native_life_ticks=" .. tostring(lifetimeTicks)
        .. " manual_propagation=false native_propagation_not_overridden=true"
        .. " non_propagation_result=" .. Fire.NON_PROPAGATION_RESULT)
    return true, "ISO_FIRE_MANAGER_START_FIRE_SINGLE_CENTER_SQUARE"
end

function Fire.Shutdown(reason)
    print("[XNP GREEN CENTER FIRE SUMMARY] reason=" .. tostring(reason)
        .. " created=" .. tostring(Fire.createdCount)
        .. " failed=" .. tostring(Fire.failedCount)
        .. " fire_objects_owned_for_forced_removal=0")
    Fire.createdCount = 0
    Fire.failedCount = 0
    Fire.failures = {}
end

Core.GreenCenterFire = Fire
return Fire
