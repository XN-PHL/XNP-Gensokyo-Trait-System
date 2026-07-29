local Core = XNP_PZ_DistanceRunner

local Break = { windows = 0, doors = 0, failures = 0, failureReasons = {} }

local function isType(object, className)
    if not object or type(instanceof) ~= "function" then return false end
    local ok, result = pcall(function() return instanceof(object, className) end)
    return ok and result == true
end

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function logFailureOnce(reason)
    reason = tostring(reason or "UNKNOWN")
    if Break.failureReasons[reason] then return end
    Break.failureReasons[reason] = true
    print("[XNP GREEN CENTER STRUCTURE] degraded_once=true reason=" .. reason
        .. " impact_blocked=false")
end

local function hasProperty(object, name)
    local propertiesOk, properties = invoke(object, "getProperties")
    if not propertiesOk or not properties then return false end
    local hasOk, present = invoke(properties, "has", name)
    return hasOk and present == true
end

local function isGlassDoor(object)
    return hasProperty(object, "doorTrans")
end

local function isThumpableWindow(object)
    local northOk, north = invoke(object, "isWindowN")
    local westOk, west = invoke(object, "isWindowW")
    return (northOk and north == true) or (westOk and west == true)
end

local function breakObject(object, options)
    if isType(object, "IsoWindow") and options.centerBreakWindowsEnabled == true then
        local readOk, smashed = invoke(object, "isSmashed")
        if readOk and smashed == true then return false, "WINDOW_ALREADY_SMASHED" end
        local ok, result = invoke(object, "smashWindow", false, false)
        if not ok or result == false then ok, result = invoke(object, "setSmashed", true) end
        if ok and result ~= false then Break.windows = Break.windows + 1; return true, "ISOWINDOW_SMASH" end
        Break.failures = Break.failures + 1
        return false, "ISOWINDOW_SMASH_FAILED"
    end
    if isType(object, "IsoDoor") then
        local glass = isGlassDoor(object)
        local admitted = (glass and options.centerBreakGlassDoorsEnabled == true)
            or (not glass and options.centerBreakDoorsEnabled == true)
        if not admitted then return false, glass and "GLASS_DOOR_DISABLED" or "DOOR_DISABLED" end
        local readOk, destroyed = invoke(object, "isDestroyed")
        if readOk and destroyed == true then return false, "DOOR_ALREADY_DESTROYED" end
        local ok, result = invoke(object, "destroy")
        if ok and result ~= false then
            Break.doors = Break.doors + 1
            return true, glass and "ISODOOR_GLASS_DESTROY" or "ISODOOR_DESTROY"
        end
        Break.failures = Break.failures + 1
        return false, "ISODOOR_DESTROY_FAILED"
    end
    if isType(object, "IsoThumpable") then
        if isThumpableWindow(object) and options.centerBreakWindowsEnabled == true then
            local ok, result = invoke(object, "destroy")
            if ok and result ~= false then
                Break.windows = Break.windows + 1
                return true, "ISOTHUMPABLE_WINDOW_DESTROY"
            end
            Break.failures = Break.failures + 1
            return false, "ISOTHUMPABLE_WINDOW_DESTROY_FAILED"
        end
        local doorOk, isDoor = invoke(object, "isDoor")
        if doorOk and isDoor == true then
            local glass = isGlassDoor(object)
            local admitted = (glass and options.centerBreakGlassDoorsEnabled == true)
                or (not glass and options.centerBreakDoorsEnabled == true)
            if not admitted then
                return false, glass and "GLASS_THUMPABLE_DOOR_DISABLED" or "THUMPABLE_DOOR_DISABLED"
            end
            local ok, result = invoke(object, "destroy")
            if ok and result ~= false then
                Break.doors = Break.doors + 1
                return true, glass and "ISOTHUMPABLE_GLASS_DOOR_DESTROY"
                    or "ISOTHUMPABLE_DOOR_DESTROY"
            end
            Break.failures = Break.failures + 1
            return false, "ISOTHUMPABLE_DOOR_DESTROY_FAILED"
        end
    end
    if isType(object, "IsoWindowFrame") then return false, "WINDOW_FRAME_HAS_NO_GLASS" end
    return false, "TYPE_NOT_ADMITTED"
end

local function processObjectList(list, processed, options)
    local brokenWindows, brokenDoors = 0, 0
    if not list or type(list.size) ~= "function" or type(list.get) ~= "function" then
        return brokenWindows, brokenDoors
    end
    local okSize, size = pcall(function() return list:size() end)
    size = okSize and tonumber(size) or 0
    for index = 0, size - 1 do
        local okObject, object = pcall(function() return list:get(index) end)
        if okObject and object and not processed[object] then
            processed[object] = true
            local broken, method = breakObject(object, options)
            if broken and (method == "ISOWINDOW_SMASH"
                or method == "ISOTHUMPABLE_WINDOW_DESTROY") then
                brokenWindows = brokenWindows + 1
            elseif broken then
                brokenDoors = brokenDoors + 1
            end
            if method and string.find(method, "FAILED", 1, true) then logFailureOnce(method) end
        end
    end
    return brokenWindows, brokenDoors
end

function Break.Apply(state)
    local options = state and state.options
    if not options or options.centerStructureBreakEnabled ~= true then return false, "DISABLED" end
    if type(getCell) ~= "function" then return false, "CELL_API_UNAVAILABLE" end
    local okCell, cell = pcall(getCell)
    if not okCell or not cell or type(cell.getGridSquare) ~= "function" then
        return false, "CELL_UNAVAILABLE"
    end
    local radius = math.max(0.1, tonumber(options.centerStructureBreakRadius) or 1.5)
    local level = math.floor(state.world_z)
    local processed = setmetatable({}, { __mode = "k" })
    local brokenWindows, brokenDoors = 0, 0
    for x = math.floor(state.world_x - radius), math.ceil(state.world_x + radius) do
        for y = math.floor(state.world_y - radius), math.ceil(state.world_y + radius) do
            local dx = (x + 0.5) - state.world_x
            local dy = (y + 0.5) - state.world_y
            if math.sqrt(dx * dx + dy * dy) <= radius then
                local okSquare, square = pcall(function() return cell:getGridSquare(x, y, level) end)
                if okSquare and square then
                    for _, methodName in ipairs({ "getObjects", "getSpecialObjects" }) do
                        local okList, list = invoke(square, methodName)
                        if okList then
                            local windows, doors = processObjectList(list, processed, options)
                            brokenWindows = brokenWindows + windows
                            brokenDoors = brokenDoors + doors
                        end
                    end
                end
            end
        end
    end
    print("[XNP GREEN CENTER STRUCTURE] cast_id=" .. tostring(state.id)
        .. " radius=" .. tostring(radius)
        .. " windows_broken=" .. tostring(brokenWindows)
        .. " doors_broken=" .. tostring(brokenDoors)
        .. " walls_broken=0 furniture_broken=0 vehicles_damaged=0 players_damaged=0")
    return true, "NATIVE_TYPED_DOOR_WINDOW_BREAK_COMPLETE"
end

function Break.Shutdown(reason)
    print("[XNP GREEN CENTER STRUCTURE SUMMARY] reason=" .. tostring(reason)
        .. " windows=" .. tostring(Break.windows)
        .. " doors=" .. tostring(Break.doors)
        .. " failures=" .. tostring(Break.failures))
    Break.windows, Break.doors, Break.failures = 0, 0, 0
    Break.failureReasons = {}
end

Core.GreenCenterStructureBreak = Break
return Break
