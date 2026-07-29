local Core = XNP_PZ_DistanceRunner

local Light = {
    REAL_WORLD_LIGHTING = true,
    ACTUAL_COLOR = "RGB_GREEN",
    FLIGHT_FOLLOW_ROUTE = "BOUNDED_CREATE_BEFORE_REMOVE_REPLACE_IN_ISOCELL",
    OBJECT_REUSE_VERIFIED = false,
    MUTABLE_POSITION_API_PRESENT = true,
    MUTABLE_POSITION_UPDATES_REGISTERED_JNI_LIGHT = false,
    IMPACT_LIGHT_BUDGET = 4,
    REBALANCE_INTERVAL_MS = 250,
    OWNERSHIP_HYSTERESIS_TILES = 1.5,
    candidatesByCast = {},
    flightByCast = {},
    flightHistory = {},
    impacts = {},
    activeCount = 0,
    activeFlightCount = 0,
    activeImpactCount = 0,
    peakActiveCount = 0,
    peakActiveFlightCount = 0,
    totalFollowUpdates = 0,
    totalReregistrations = 0,
    mapOpenReregistrations = 0,
    budgetDeferrals = 0,
    ownershipTransfers = 0,
    addLamppostApiCalls = 0,
    removeLamppostApiCalls = 0,
    positionUpdateAttempts = 0,
    positionUpdateSuccesses = 0,
    replacementFailuresRetainedPrevious = 0,
    nextRebalanceMs = 0,
    mapHidden = false,
    failures = {},
}

local function logFailureOnce(reason)
    reason = tostring(reason or "UNKNOWN")
    if Light.failures[reason] then return end
    Light.failures[reason] = true
    print("[XNP GREEN WORLD LIGHT] degraded_once=true reason=" .. reason
        .. " cast_deleted=false damage_blocked=false")
end

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    return math.max(minimum, math.min(value, maximum))
end

local function invoke(object, method)
    if not object or type(object[method]) ~= "function" then return false, nil end
    return pcall(function() return object[method](object) end)
end

local function coordinate(object, method)
    local ok, value = invoke(object, method)
    return ok and tonumber(value) or nil
end

local function distance(x1, y1, x2, y2)
    local dx = (tonumber(x1) or 0) - (tonumber(x2) or 0)
    local dy = (tonumber(y1) or 0) - (tonumber(y2) or 0)
    return math.sqrt(dx * dx + dy * dy)
end

local function removeRecord(record)
    if not record or record.removed then return true end
    record.removed = true
    local removed = false
    if record.cell and record.light and type(record.cell.removeLamppost) == "function" then
        Light.removeLamppostApiCalls = Light.removeLamppostApiCalls + 1
        removed = pcall(function() record.cell:removeLamppost(record.light) end)
    end
    if record.light and type(record.light.setActive) == "function" then
        pcall(function() record.light:setActive(false) end)
    end
    if record.counted ~= false then
        Light.activeCount = math.max(0, Light.activeCount - 1)
        if record.kind == "FLIGHT" then
            Light.activeFlightCount = math.max(0, Light.activeFlightCount - 1)
        else
            Light.activeImpactCount = math.max(0, Light.activeImpactCount - 1)
        end
        record.counted = false
    end
    if not removed then logFailureOnce("REMOVE_LAMPPOST_FAILED") end
    return removed
end

local function countRecord(record)
    if not record or record.counted == true then return end
    record.counted = true
    Light.activeCount = Light.activeCount + 1
    if record.kind == "FLIGHT" then
        Light.activeFlightCount = Light.activeFlightCount + 1
        Light.peakActiveFlightCount = math.max(Light.peakActiveFlightCount, Light.activeFlightCount)
    else
        Light.activeImpactCount = Light.activeImpactCount + 1
    end
    Light.peakActiveCount = math.max(Light.peakActiveCount, Light.activeCount)
end

local function createRecord(kind, castId, x, y, z, options, radius, intensity, expiresMs,
        bypassBudget, deferAccounting)
    if not options or options.dynamicLightEnabled ~= true then return nil, "DISABLED" end
    if bypassBudget ~= true and kind == "FLIGHT"
        and Light.activeFlightCount >= options.maximumActiveDynamicLights then
        return nil, "FLIGHT_LIGHT_BUDGET_FULL"
    end
    if kind == "IMPACT" and Light.activeImpactCount >= Light.IMPACT_LIGHT_BUDGET then
        return nil, "IMPACT_LIGHT_BUDGET_FULL"
    end
    if not IsoLightSource or type(IsoLightSource.new) ~= "function" then
        return nil, "ISOLIGHTSOURCE_API_UNAVAILABLE"
    end
    if type(getCell) ~= "function" then return nil, "CELL_API_UNAVAILABLE" end
    local cellOk, cell = pcall(getCell)
    if not cellOk or not cell or type(cell.addLamppost) ~= "function" then
        return nil, "ADD_LAMPPOST_API_UNAVAILABLE"
    end
    local lightX = math.floor(tonumber(x) or 0)
    local lightY = math.floor(tonumber(y) or 0)
    local level = math.floor(tonumber(z) or 0)
    local strength = clamp(intensity, 0, 1)
    local red = clamp(options.dynamicLightRed or 0.08, 0, 1) * strength
    local green = clamp(options.dynamicLightGreen or 1.00, 0, 1) * strength
    local blue = clamp(options.dynamicLightBlue or 0.18, 0, 1) * strength
    local lightRadius = math.max(1, math.floor((tonumber(radius) or 1) + 0.5))
    local okNew, source = pcall(function()
        return IsoLightSource.new(lightX, lightY, level, red, green, blue, lightRadius)
    end)
    if not okNew or not source then return nil, "ISOLIGHTSOURCE_CONSTRUCTOR_FAILED" end
    Light.addLamppostApiCalls = Light.addLamppostApiCalls + 1
    local okAdd = pcall(function() cell:addLamppost(source) end)
    if not okAdd then
        pcall(function() source:setActive(false) end)
        return nil, "ADD_LAMPPOST_FAILED"
    end
    local record = {
        kind = kind,
        castId = castId,
        light = source,
        cell = cell,
        x = lightX,
        y = lightY,
        z = level,
        expiresMs = expiresMs,
        removed = false,
        counted = false,
    }
    if deferAccounting ~= true then countRecord(record) end
    return record, "ISO_LIGHT_SOURCE_ADDED_TO_CELL"
end

local function historyFor(state)
    local history = Light.flightHistory[state.id]
    if history then return history end
    history = {
        castId = state.id,
        created = false,
        flightLightEnabled = state.options
            and state.options.dynamicLightFlightEnabled == true or false,
        followUpdates = 0,
        lastProjectileX = state.world_x,
        lastProjectileY = state.world_y,
        lastLightX = nil,
        lastLightY = nil,
        followDelta = nil,
        removedOnCleanup = false,
        budgetDeferred = false,
    }
    Light.flightHistory[state.id] = history
    return history
end

local function logFlightSummary(history)
    if not history then return end
    print("[XNP GREEN WORLD LIGHT] cast_id=" .. tostring(history.castId)
        .. " created=" .. tostring(history.created == true)
        .. " flight_light_enabled=" .. tostring(history.flightLightEnabled == true)
        .. " follow_updates=" .. tostring(history.followUpdates or 0)
        .. " last_projectile_x=" .. tostring(history.lastProjectileX)
        .. " last_projectile_y=" .. tostring(history.lastProjectileY)
        .. " last_light_x=" .. tostring(history.lastLightX)
        .. " last_light_y=" .. tostring(history.lastLightY)
        .. " follow_delta=" .. tostring(history.followDelta)
        .. " budget_deferred=" .. tostring(history.budgetDeferred == true)
        .. " removed_on_cleanup=" .. tostring(history.removedOnCleanup == true))
end

local function candidateDistance(state)
    local px = coordinate(state and state.player, "getX")
    local py = coordinate(state and state.player, "getY")
    if not px or not py then return math.huge end
    local score = distance(state.world_x, state.world_y, px, py)
    if Light.flightByCast[state.id] and not Light.flightByCast[state.id].removed then
        score = math.max(0, score - Light.OWNERSHIP_HYSTERESIS_TILES)
    end
    return score
end

local function createFlightRecord(state, now, bypassBudget, deferAccounting)
    local record, reason = createRecord("FLIGHT", state.id, state.world_x, state.world_y,
        state.world_z, state.options, state.options.dynamicLightRadius,
        state.options.dynamicLightIntensity, nil, bypassBudget, deferAccounting)
    if not record then return nil, reason end
    record.nextUpdateMs = (tonumber(now) or 0) + state.options.dynamicLightUpdateIntervalMs
    Light.flightByCast[state.id] = record
    local history = historyFor(state)
    history.created = true
    history.budgetDeferred = false
    history.lastProjectileX = state.world_x
    history.lastProjectileY = state.world_y
    history.lastLightX = record.x
    history.lastLightY = record.y
    history.followDelta = distance(state.world_x, state.world_y, record.x, record.y)
    return record, reason
end

local function validCandidate(state)
    return state and state.finished ~= true and state.cleanupComplete ~= true
        and state.options and state.options.dynamicLightEnabled == true
        and state.options.dynamicLightFlightEnabled == true
end

function Light.Rebalance(now, force)
    now = tonumber(now) or 0
    if Light.mapHidden then return true, "MAP_HIDDEN_REBALANCE_PAUSED" end
    if force ~= true and now < Light.nextRebalanceMs then return true, "REBALANCE_INTERVAL_WAIT" end
    Light.nextRebalanceMs = now + Light.REBALANCE_INTERVAL_MS
    local candidates = {}
    local budget = 0
    for castId, state in pairs(Light.candidatesByCast) do
        if validCandidate(state) then
            budget = math.max(budget, state.options.maximumActiveDynamicLights or 0)
            candidates[#candidates + 1] = { castId = castId, state = state, score = candidateDistance(state) }
        else
            Light.candidatesByCast[castId] = nil
        end
    end
    table.sort(candidates, function(a, b)
        if a.score == b.score then return tostring(a.castId) < tostring(b.castId) end
        return a.score < b.score
    end)
    budget = math.max(0, math.min(math.floor(budget + 0.5), 20))
    local selected = {}
    for index = 1, math.min(#candidates, budget) do selected[candidates[index].castId] = true end
    for castId, record in pairs(Light.flightByCast) do
        if not selected[castId] then
            removeRecord(record)
            Light.flightByCast[castId] = nil
            Light.ownershipTransfers = Light.ownershipTransfers + 1
        end
    end
    for _, entry in ipairs(candidates) do
        local history = historyFor(entry.state)
        if selected[entry.castId] then
            if not Light.flightByCast[entry.castId] then
                local record, reason = createFlightRecord(entry.state, now)
                if not record then logFailureOnce(reason) end
            end
        else
            if history.budgetDeferred ~= true then Light.budgetDeferrals = Light.budgetDeferrals + 1 end
            history.budgetDeferred = true
        end
    end
    return true, "NEAREST_FLIGHT_LIGHT_BUDGET_REBALANCED"
end

function Light.CreateFlight(state, now)
    if not state or not state.options or state.options.dynamicLightFlightEnabled ~= true then
        if state and state.id ~= nil then historyFor(state) end
        return false, "FLIGHT_LIGHT_DISABLED"
    end
    Light.candidatesByCast[state.id] = state
    historyFor(state)
    Light.Rebalance(now, true)
    if Light.flightByCast[state.id] then
        print("[XNP GREEN WORLD LIGHT] created=true kind=FLIGHT cast_id=" .. tostring(state.id)
            .. " method=IsoLightSource+IsoCell.addLamppost color=RGB_GREEN"
            .. " follow_route=" .. Light.FLIGHT_FOLLOW_ROUTE)
        return true, "FLIGHT_LIGHT_ALLOCATED"
    end
    return true, "FLIGHT_CONTINUES_WITHOUT_LIGHT_BUDGET"
end

local function syncRecordToState(state, now, force)
    local record = Light.flightByCast[state.id]
    if not record or record.removed then return false, "NO_ALLOCATED_FLIGHT_LIGHT" end
    if Light.mapHidden then return true, "MAP_HIDDEN_REREGISTRATION_PAUSED" end
    now = tonumber(now) or 0
    if force ~= true and now < (record.nextUpdateMs or 0) then return true, "UPDATE_INTERVAL_WAIT" end
    local lightX = math.floor(tonumber(state.world_x) or 0)
    local lightY = math.floor(tonumber(state.world_y) or 0)
    local lightZ = math.floor(tonumber(state.world_z) or 0)
    if lightX == record.x and lightY == record.y and lightZ == record.z then
        record.nextUpdateMs = now + state.options.dynamicLightUpdateIntervalMs
        return true, "LIGHT_TILE_UNCHANGED"
    end
    Light.positionUpdateAttempts = Light.positionUpdateAttempts + 1
    local previous = record
    local replacement, reason = createFlightRecord(state, now, true, true)
    if not replacement then
        previous.nextUpdateMs = now + state.options.dynamicLightUpdateIntervalMs
        Light.flightByCast[state.id] = previous
        Light.replacementFailuresRetainedPrevious =
            Light.replacementFailuresRetainedPrevious + 1
        logFailureOnce("FOLLOW_REREGISTER_FAILED:" .. tostring(reason))
        return false, reason
    end
    removeRecord(previous)
    countRecord(replacement)
    Light.flightByCast[state.id] = replacement
    local history = historyFor(state)
    history.followUpdates = (history.followUpdates or 0) + 1
    history.lastProjectileX = state.world_x
    history.lastProjectileY = state.world_y
    history.lastLightX = replacement.x
    history.lastLightY = replacement.y
    history.followDelta = distance(state.world_x, state.world_y, replacement.x, replacement.y)
    Light.totalFollowUpdates = Light.totalFollowUpdates + 1
    Light.totalReregistrations = Light.totalReregistrations + 1
    Light.positionUpdateSuccesses = Light.positionUpdateSuccesses + 1
    return true, "ISOCELL_LAMPPOST_REREGISTERED_AT_PROJECTILE_TILE"
end

function Light.UpdateFlight(state, now)
    if not state or not state.options then return false, "STATE_MISSING" end
    Light.candidatesByCast[state.id] = state
    historyFor(state)
    Light.Rebalance(now, false)
    local record = Light.flightByCast[state.id]
    if not record then return true, "FLIGHT_CONTINUES_WITHOUT_LIGHT_BUDGET" end
    if state.options.dynamicLightFollowEnabled ~= true then return true, "FOLLOW_DISABLED" end
    return syncRecordToState(state, now, false)
end

function Light.RemoveFlight(castId, reason)
    Light.candidatesByCast[castId] = nil
    local record = Light.flightByCast[castId]
    local history = Light.flightHistory[castId]
    Light.flightByCast[castId] = nil
    local removed = true
    if record then removed = removeRecord(record) end
    if history then
        history.removedOnCleanup = record == nil or record.removed == true
        history.cleanupReason = reason
        logFlightSummary(history)
        Light.flightHistory[castId] = nil
    end
    Light.nextRebalanceMs = 0
    return removed, record and "FLIGHT_LIGHT_REMOVED_BY_CAST_ID" or "NO_FLIGHT_LIGHT"
end

local function makeImpactRoom()
    if Light.activeImpactCount < Light.IMPACT_LIGHT_BUDGET then return end
    local oldestIndex, oldestExpiry = nil, math.huge
    for index, record in ipairs(Light.impacts) do
        if (record.expiresMs or 0) < oldestExpiry then
            oldestIndex, oldestExpiry = index, record.expiresMs or 0
        end
    end
    if oldestIndex then
        removeRecord(Light.impacts[oldestIndex])
        table.remove(Light.impacts, oldestIndex)
    end
end

function Light.CreateImpact(state, now)
    if not state or not state.options or state.options.dynamicLightImpactEnabled ~= true then
        return false, "IMPACT_LIGHT_DISABLED"
    end
    Light.RemoveFlight(state.id, "IMPACT")
    makeImpactRoom()
    local expires = now + state.options.impactDynamicLightLifetimeMs
    local record, reason = createRecord("IMPACT", state.id, state.world_x, state.world_y,
        state.world_z, state.options, state.options.impactDynamicLightRadius,
        state.options.impactDynamicLightIntensity, expires)
    if not record then logFailureOnce(reason); return false, reason end
    Light.impacts[#Light.impacts + 1] = record
    print("[XNP GREEN WORLD LIGHT] created=true kind=IMPACT cast_id=" .. tostring(state.id)
        .. " lifetime_ms=" .. tostring(state.options.impactDynamicLightLifetimeMs)
        .. " impact_budget=" .. tostring(Light.IMPACT_LIGHT_BUDGET))
    return true, reason
end

function Light.SetMapHidden(hidden, now)
    local wasHidden = Light.mapHidden
    Light.mapHidden = hidden == true
    if wasHidden and not Light.mapHidden then
        Light.nextRebalanceMs = 0
        Light.Rebalance(now, true)
        for castId, record in pairs(Light.flightByCast) do
            local state = Light.candidatesByCast[castId]
            if state and record then syncRecordToState(state, now, true) end
        end
    end
end

function Light.Update(now)
    for index = #Light.impacts, 1, -1 do
        local record = Light.impacts[index]
        if record.removed or now >= (record.expiresMs or 0) then
            removeRecord(record)
            table.remove(Light.impacts, index)
        end
    end
    Light.Rebalance(now, false)
end

function Light.GetMetrics()
    local staleFlightLightCount = 0
    for castId, record in pairs(Light.flightByCast) do
        if not record or record.removed == true or Light.candidatesByCast[castId] == nil then
            staleFlightLightCount = staleFlightLightCount + 1
        end
    end
    return {
        activeCount = Light.activeCount,
        peakActiveCount = Light.peakActiveCount,
        activeFlightCount = Light.activeFlightCount,
        peakActiveFlightCount = Light.peakActiveFlightCount,
        activeImpactCount = Light.activeImpactCount,
        followUpdates = Light.totalFollowUpdates,
        totalReregistrations = Light.totalReregistrations,
        mapOpenReregistrations = Light.mapOpenReregistrations,
        budgetDeferrals = Light.budgetDeferrals,
        ownershipTransfers = Light.ownershipTransfers,
        staleFlightLightCount = staleFlightLightCount,
        objectReuseVerified = Light.OBJECT_REUSE_VERIFIED,
        mutablePositionApiPresent = Light.MUTABLE_POSITION_API_PRESENT,
        mutablePositionUpdatesRegisteredJniLight =
            Light.MUTABLE_POSITION_UPDATES_REGISTERED_JNI_LIGHT,
        addLamppostApiCalls = Light.addLamppostApiCalls,
        removeLamppostApiCalls = Light.removeLamppostApiCalls,
        positionUpdateAttempts = Light.positionUpdateAttempts,
        positionUpdateSuccesses = Light.positionUpdateSuccesses,
        replacementFailuresRetainedPrevious = Light.replacementFailuresRetainedPrevious,
        flightFollowRoute = Light.FLIGHT_FOLLOW_ROUTE,
    }
end

function Light.Shutdown(reason)
    local castIds = {}
    for castId in pairs(Light.candidatesByCast) do castIds[#castIds + 1] = castId end
    for _, castId in ipairs(castIds) do Light.RemoveFlight(castId, reason or "SHUTDOWN") end
    for index = #Light.impacts, 1, -1 do
        removeRecord(Light.impacts[index])
        table.remove(Light.impacts, index)
    end
    Light.candidatesByCast = {}
    Light.flightByCast = {}
    Light.flightHistory = {}
    print("[XNP GREEN WORLD LIGHT SUMMARY] reason=" .. tostring(reason)
        .. " peak_active_dynamic_lights=" .. tostring(Light.peakActiveCount)
        .. " peak_active_flight_lights=" .. tostring(Light.peakActiveFlightCount)
        .. " follow_updates=" .. tostring(Light.totalFollowUpdates)
        .. " reregistrations=" .. tostring(Light.totalReregistrations)
        .. " map_open_reregistrations=" .. tostring(Light.mapOpenReregistrations)
        .. " stale_light_count_after_shutdown=" .. tostring(Light.activeCount))
    Light.activeCount = 0
    Light.activeFlightCount = 0
    Light.activeImpactCount = 0
    Light.peakActiveCount = 0
    Light.peakActiveFlightCount = 0
    Light.totalFollowUpdates = 0
    Light.totalReregistrations = 0
    Light.mapOpenReregistrations = 0
    Light.budgetDeferrals = 0
    Light.ownershipTransfers = 0
    Light.addLamppostApiCalls = 0
    Light.removeLamppostApiCalls = 0
    Light.positionUpdateAttempts = 0
    Light.positionUpdateSuccesses = 0
    Light.replacementFailuresRetainedPrevious = 0
    Light.nextRebalanceMs = 0
    Light.mapHidden = false
    Light.failures = {}
end

Core.GreenWorldLight = Light
return Light
