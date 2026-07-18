XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local RETRY_MS = 750

local ExtraTraits = {
    RED = {
        id = "XNPFeastGuardian",
        fullId = "XNPFeastGuardianTrait:XNPFeastGuardian",
        aliases = {
            "XNPFeastGuardianTrait:XNPFeastGuardian",
            "XNPFeastGuardian",
            "XNPFeastGuardianTrait",
        },
        icon = "media/ui/Traits/trait_xnpfeastguardian.png",
        positionKey = "XNP_UI_RED_ROUND_POS_0557",
    },
    GREEN = {
        id = "XNPBlueEcoBarrage",
        fullId = "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
        aliases = {
            "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
            "XNPBlueEcoBarrage",
            "XNPBlueEcoBarrageTrait",
        },
        icon = "media/ui/XNPMarkers/xnp_marker_green.png",
        positionKey = "XNP_UI_GREEN_ULTIMATE_POS",
    },
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return (os.time() or 0) * 1000
end

local function resetDefinition(definition)
    definition.cachePlayer = nil
    definition.cacheResult = nil
    definition.cacheMethod = nil
    definition.canonical = nil
    definition.nextCheckMs = 0
    definition.loggedResult = nil
    definition.snapshot = nil
end

for _, definition in pairs({ ExtraTraits.RED, ExtraTraits.GREEN }) do
    resetDefinition(definition)
end

local function resolveCanonical(definition)
    if definition.canonical then return definition.canonical end
    if not ResourceLocation or type(ResourceLocation.of) ~= "function" then return nil end
    if not CharacterTrait or type(CharacterTrait.get) ~= "function" then return nil end
    local ok, value = pcall(function()
        return CharacterTrait.get(ResourceLocation.of(definition.fullId))
    end)
    if ok and value then definition.canonical = value end
    return definition.canonical
end

local function addCollection(out, seen, value)
    if value and not seen[value] then
        seen[value] = true
        out[#out + 1] = value
    end
end

local function traitCollections(player)
    local out, seen = {}, {}
    local okCharacterTraits, characterTraits = invoke(player, "getCharacterTraits")
    if okCharacterTraits and characterTraits then
        addCollection(out, seen, characterTraits)
        local okKnown, known = invoke(characterTraits, "getKnownTraits")
        if okKnown then addCollection(out, seen, known) end
    end
    local okLegacy, legacy = invoke(player, "getTraits")
    if okLegacy then addCollection(out, seen, legacy) end
    return out
end

local function valueName(value, method)
    local ok, result = invoke(value, method)
    return ok and result ~= nil and tostring(result) or nil
end

local function matchesAlias(definition, name)
    if not name then return false end
    for _, alias in ipairs(definition.aliases) do
        if name == alias then return true end
    end
    return false
end

local function scanCollection(collection, definition, canonical)
    if canonical and type(collection.contains) == "function" then
        local ok, found = pcall(function() return collection:contains(canonical) end)
        if ok and found == true then return true, "CANONICAL_OBJECT", 0 end
    end

    local sizeOk, size = invoke(collection, "size")
    size = sizeOk and tonumber(size) or 0
    for index = 0, size - 1 do
        local itemOk, item = invoke(collection, "get", index)
        if itemOk and item then
            if canonical and item == canonical then return true, "CANONICAL_COLLECTION_OBJECT", size end
            local names = { tostring(item) }
            for _, method in ipairs({ "getType", "getId", "getID", "getFullType", "getFullName", "getName" }) do
                names[#names + 1] = valueName(item, method)
            end
            for _, name in ipairs(names) do
                if matchesAlias(definition, name) then return true, "STABLE_ID_ALIAS", size end
            end
        end
    end
    return false, "NOT_FOUND", size
end

local function detect(player, definition)
    local canonical = resolveCanonical(definition)
    local collections = traitCollections(player)
    local totalSize = 0
    for _, collection in ipairs(collections) do
        local found, method, size = scanCollection(collection, definition, canonical)
        totalSize = totalSize + (tonumber(size) or 0)
        if found then
            return true, method, #collections, totalSize, canonical ~= nil
        end
    end
    return false, #collections > 0 and "NOT_FOUND" or "COLLECTION_UNAVAILABLE", #collections, totalSize, canonical ~= nil
end

local function refresh(player, key, definition)
    local found, method, collectionCount, traitCount, canonicalAvailable = detect(player, definition)
    definition.cachePlayer = player
    definition.cacheResult = found == true
    definition.cacheMethod = method
    definition.nextCheckMs = found and math.huge or (nowMs() + RETRY_MS)
    definition.snapshot = {
        fullId = definition.fullId,
        method = method,
        collectionCount = collectionCount,
        traitCount = traitCount,
        canonicalAvailable = canonicalAvailable,
    }
    if definition.loggedResult ~= definition.cacheResult then
        definition.loggedResult = definition.cacheResult
        print("[XNP " .. key .. " TRAIT] full_id=" .. definition.fullId
            .. " detected=" .. tostring(definition.cacheResult)
            .. " method=" .. tostring(method))
    end
    return definition.cacheResult
end

function ExtraTraits.Refresh(player, key)
    local definition = ExtraTraits[key]
    if not definition then return false end
    return refresh(player, key, definition)
end

function ExtraTraits.PlayerHas(player, key)
    local definition = ExtraTraits[key]
    if not definition or not player then return false end
    if definition.cachePlayer ~= player or definition.cacheResult == nil
        or (definition.cacheResult == false and nowMs() >= definition.nextCheckMs) then
        return refresh(player, key, definition)
    end
    return definition.cacheResult == true
end

function ExtraTraits.GetDebugSnapshot(key)
    local definition = ExtraTraits[key]
    return definition and definition.snapshot or nil
end

function ExtraTraits.ResetCaches()
    for _, definition in pairs({ ExtraTraits.GREEN, ExtraTraits.RED }) do
        resetDefinition(definition)
    end
end

Core.ExtraTraits = ExtraTraits
return ExtraTraits
