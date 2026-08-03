XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Guard = Core.ChannelGuard or {}

Guard.STABLE_MOD_ID = "XNP_PZ_DistanceRunnerTrait"
Guard.TEST_MOD_ID = "XNP_PZ_DistanceRunnerTrait_Test"
Guard.warningEmitted = Guard.warningEmitted == true
Guard.warningCount = tonumber(Guard.warningCount) or 0
Guard.lastStatus = Guard.lastStatus or "NOT_EVALUATED"

local function addId(ids, value)
    local id = tostring(value or ""):match("^%s*(.-)%s*$")
    if id ~= "" then
        ids[id] = true
    end
end

local function addDelimited(ids, value)
    local text = tostring(value or "")
    for token in string.gmatch(text, "[^;,]+") do
        addId(ids, token)
    end
end

local function absorbCollection(ids, collection)
    if collection == nil then
        return
    end

    if type(collection) == "table" then
        for key, value in pairs(collection) do
            if type(key) == "string" and value == true then
                addId(ids, key)
            elseif type(value) == "string" then
                addId(ids, value)
            end
        end
        return
    end

    local sizeOk, size = pcall(function()
        return collection:size()
    end)
    if sizeOk and type(size) == "number" then
        for index = 0, size - 1 do
            local valueOk, value = pcall(function()
                return collection:get(index)
            end)
            if valueOk then
                addId(ids, value)
            end
        end
    end
end

local function absorbActiveModsProfile(ids, profile)
    if ActiveMods == nil then
        return
    end
    local ok, activeMods = pcall(function()
        return ActiveMods.getById(profile)
    end)
    if not ok or activeMods == nil then
        return
    end
    local modsOk, mods = pcall(function()
        return activeMods:getMods()
    end)
    if modsOk then
        absorbCollection(ids, mods)
    end
end

function Guard.collectActiveIds()
    local ids = {}

    if type(getActivatedMods) == "function" then
        local ok, activated = pcall(getActivatedMods)
        if ok then
            absorbCollection(ids, activated)
        end
    end

    for _, profile in ipairs({
        "loaded",
        "default",
        "currentGame",
        "serversettings",
    }) do
        absorbActiveModsProfile(ids, profile)
    end

    if type(getServerOptions) == "function" then
        local optionsOk, options = pcall(getServerOptions)
        if optionsOk and options ~= nil then
            local modsOk, mods = pcall(function()
                return options:getOption("Mods")
            end)
            if modsOk then
                addDelimited(ids, mods)
            end
        end
    end

    return ids
end

function Guard.evaluateIds(ids)
    ids = ids or {}
    local stableActive = ids[Guard.STABLE_MOD_ID] == true
    local testActive = ids[Guard.TEST_MOD_ID] == true
    return not (stableActive and testActive), stableActive, testActive
end

local function emitConflictOnce()
    if Guard.warningEmitted then
        return
    end
    Guard.warningEmitted = true
    Guard.warningCount = Guard.warningCount + 1
    print("[XNP CHANNEL CONFLICT] 测试版与稳定版不能同时启用，请只保留一个版本。")
    print("[XNP CHANNEL CONFLICT] Test and stable channels cannot run together; enable only one.")
end

function Guard.allowRuntime()
    local allowed, stableActive, testActive =
        Guard.evaluateIds(Guard.collectActiveIds())
    Guard.stableActive = stableActive
    Guard.testActive = testActive
    Guard.conflict = not allowed
    Guard.lastStatus = allowed and "SINGLE_CHANNEL_ALLOWED"
        or "BOTH_CHANNELS_BLOCKED"

    if not allowed then
        emitConflictOnce()
        return false
    end
    return true
end

function Guard.getStatus()
    return {
        allowed = Guard.conflict ~= true,
        conflict = Guard.conflict == true,
        stableActive = Guard.stableActive == true,
        testActive = Guard.testActive == true,
        warningCount = Guard.warningCount,
        status = Guard.lastStatus,
    }
end

Core.ChannelGuard = Guard
return Guard
