require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenix_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurplePhoenixTraitRegistration"

local Core = XNP_PZ_DistanceRunner
local PhoenixConstants = Core.PurplePhoenixConstants

local PhoenixTrait = {
    cachedPlayer = nil,
    cachedResult = nil,
    loggedResult = false,
}

local aliases = {
    PhoenixConstants.TRAIT_FULL_ID,
    PhoenixConstants.TRAIT_ID,
    "XNPPhoenixTrait",
}

-- Calls a no-argument object method under pcall and returns a string suitable
-- for alias comparison. Build 42 collection objects differ across contexts.
local function nameFromMethod(value, method)
    if value and type(value[method]) == "function" then
        local ok, result = pcall(function() return value[method](value) end)
        if ok and result ~= nil then return tostring(result) end
    end
    return nil
end

-- Reads the native known-trait collection. The legacy list is only a fallback;
-- no string-form player:hasTrait call is introduced.
local function knownTraits(player)
    if player and type(player.getCharacterTraits) == "function" then
        local ok, result = pcall(function()
            return player:getCharacterTraits():getKnownTraits()
        end)
        if ok and result then return result end
    end
    if player and type(player.getTraits) == "function" then
        local ok, result = pcall(function() return player:getTraits() end)
        if ok then return result end
    end
    return nil
end

-- Compares canonical object identity first, then scans stable IDs exposed by the
-- collection. This preserves the established object-based trait contract.
local function collectionHasTrait(collection, canonical)
    if collection and canonical and type(collection.contains) == "function" then
        local ok, found = pcall(function() return collection:contains(canonical) end)
        if ok and found == true then return true, "CANONICAL_OBJECT" end
    end
    local size = 0
    if collection and type(collection.size) == "function" then
        local ok, value = pcall(function() return collection:size() end)
        if ok and type(value) == "number" then size = value end
    end
    for index = 0, size - 1 do
        local ok, item = pcall(function() return collection:get(index) end)
        if ok and item then
            local names = { tostring(item) }
            for _, method in ipairs({ "getType", "getId", "getID", "getFullType", "getFullName", "getName" }) do
                names[#names + 1] = nameFromMethod(item, method)
            end
            for _, name in ipairs(names) do
                for _, alias in ipairs(aliases) do
                    if name == alias then return true, "ALIAS:" .. alias end
                end
            end
        end
    end
    return false, "NOT_FOUND"
end

-- Refreshes the cached result for one player. Input is the IsoPlayer-like
-- object; output is a boolean and a stable diagnostic reason.
function PhoenixTrait.Refresh(player)
    PhoenixTrait.cachedPlayer = player
    local collection = knownTraits(player)
    local canonical = Core.PurplePhoenixTraitRegistration.GetCanonicalTrait()
    local found, reason = collectionHasTrait(collection, canonical)
    PhoenixTrait.cachedResult = found == true
    if not PhoenixTrait.loggedResult then
        PhoenixTrait.loggedResult = true
        print("[XNP PHOENIX TRAIT] player_has_trait=" .. tostring(PhoenixTrait.cachedResult) .. " method=" .. tostring(reason))
    end
    return PhoenixTrait.cachedResult, reason
end

-- Returns whether this exact player owns Phoenix. A different player or
-- an empty cache triggers a fresh object-based lookup.
function PhoenixTrait.PlayerHasTrait(player)
    if player ~= PhoenixTrait.cachedPlayer or PhoenixTrait.cachedResult == nil then
        return PhoenixTrait.Refresh(player)
    end
    return PhoenixTrait.cachedResult == true
end

-- Clears only per-session detection caches on player creation or menu exit.
function PhoenixTrait.ResetCache()
    PhoenixTrait.cachedPlayer = nil
    PhoenixTrait.cachedResult = nil
    PhoenixTrait.loggedResult = false
end

Core.PurplePhoenixTrait = PhoenixTrait
return PhoenixTrait
