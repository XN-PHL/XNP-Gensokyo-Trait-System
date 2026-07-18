require "XNP_PZ_DistanceRunner/XNP_DR_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_TraitRegistration"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.Constants

local Trait = {
    targetTraitObject = nil,
    playerHasTargetTrait = nil,
    cachedPlayer = nil,
    loggedMethod = false,
    loggedValue = false,
    detectorFailed = false,
    detectorErrorLogged = false,
    runtime_enabled = true,
    lastSnapshot = nil,
}

local traitAliases = {
    "XNPDistanceRunnerTrait:XNPDistanceRunner",
    "XNPDistanceRunner",
    "XNPDistanceRunnerTrait",
}

local function collectionContains(collection, trait_object)
    if collection and trait_object and type(collection.contains) == "function" then
        local ok, result = pcall(function()
            return collection:contains(trait_object)
        end)
        return ok and result == true
    end
    return false
end

local function getKnownTraits(player)
    if player and type(player.getCharacterTraits) == "function" then
        local ok, known = pcall(function()
            return player:getCharacterTraits():getKnownTraits()
        end)
        if ok and known then
            return known
        end
    end
    if player and type(player.getTraits) == "function" then
        local ok, traits = pcall(function()
            return player:getTraits()
        end)
        if ok and traits then
            return traits
        end
    end
    return nil
end

local function collectionSize(collection)
    if collection and type(collection.size) == "function" then
        local ok, value = pcall(function()
            return collection:size()
        end)
        if ok and type(value) == "number" then
            return value
        end
    end
    return 0
end

local function collectionGet(collection, index)
    if collection and type(collection.get) == "function" then
        local ok, value = pcall(function()
            return collection:get(index)
        end)
        if ok then
            return value
        end
    end
    return nil
end

local function valueFromMethod(obj, method)
    if obj and type(obj[method]) == "function" then
        local ok, value = pcall(function()
            return obj[method](obj)
        end)
        if ok and value ~= nil then
            return tostring(value)
        end
    end
    return nil
end

local function namesForTrait(value)
    local names = {}
    if value ~= nil then
        names[#names + 1] = tostring(value)
    end
    local methods = { "getType", "getId", "getID", "getFullType", "getFullName", "getName" }
    for _, method in ipairs(methods) do
        local name = valueFromMethod(value, method)
        if name then
            names[#names + 1] = name
        end
    end
    return names
end

local function nameMatchesAlias(name)
    for _, alias in ipairs(traitAliases) do
        if name == alias then
            return true, alias
        end
    end
    return false, nil
end

local function scanTraitAliases(collection)
    local snapshot = {
        aliases = traitAliases,
        names = {},
        found = false,
        matchedAlias = nil,
        count = 0,
    }
    local size = collectionSize(collection)
    snapshot.count = size
    for i = 0, math.max(size - 1, -1) do
        local item = collectionGet(collection, i)
        local names = namesForTrait(item)
        for _, name in ipairs(names) do
            snapshot.names[#snapshot.names + 1] = name
            local matched, alias = nameMatchesAlias(name)
            if matched then
                snapshot.found = true
                snapshot.matchedAlias = alias
            end
        end
    end
    return snapshot
end

local function logDetectorMethodOnce()
    if not Trait.loggedMethod then
        Trait.loggedMethod = true
        print("[XNP TRAIT] detector_method=" .. Constants.TRAIT_DETECTION_METHOD)
    end
end

local function detectorError(err)
    Trait.detectorFailed = true
    Trait.runtime_enabled = false
    Trait.playerHasTargetTrait = false
    if not Trait.detectorErrorLogged then
        Trait.detectorErrorLogged = true
        print("[XNP TRAIT] detector_error_once=" .. tostring(err))
    end
    return false
end

function Trait.ResetCache()
    Trait.targetTraitObject = nil
    Trait.playerHasTargetTrait = nil
    Trait.cachedPlayer = nil
    Trait.loggedValue = false
    Trait.lastSnapshot = nil
end

function Trait.RefreshForPlayer(player)
    if Trait.detectorFailed then
        return false
    end

    logDetectorMethodOnce()

    local ok, result = pcall(function()
        Trait.cachedPlayer = player
        Trait.targetTraitObject = Core.GetCanonicalDistanceRunnerCharacterTrait and Core.GetCanonicalDistanceRunnerCharacterTrait() or nil
        if not player or not Trait.targetTraitObject then
            return false
        end
        local known = getKnownTraits(player)
        local objectFound = collectionContains(known, Trait.targetTraitObject)
        local aliasSnapshot = scanTraitAliases(known)
        Trait.lastSnapshot = {
            objectFound = objectFound,
            aliasFound = aliasSnapshot.found,
            matchedAlias = aliasSnapshot.matchedAlias,
            aliases = aliasSnapshot.aliases,
            names = aliasSnapshot.names,
            count = aliasSnapshot.count,
        }
        return objectFound or aliasSnapshot.found
    end)

    if not ok then
        return detectorError(result)
    end

    Trait.playerHasTargetTrait = result == true
    if not Trait.loggedValue then
        Trait.loggedValue = true
        print("[XNP TRAIT] player has target trait=" .. tostring(Trait.playerHasTargetTrait))
        if Trait.lastSnapshot then
            print("[XNP TRAIT] object_found=" .. tostring(Trait.lastSnapshot.objectFound) .. " alias_found=" .. tostring(Trait.lastSnapshot.aliasFound) .. " matched_alias=" .. tostring(Trait.lastSnapshot.matchedAlias or "none"))
        end
    end
    return Trait.playerHasTargetTrait
end

function Trait.PlayerHasTrait(player)
    if Trait.detectorFailed then
        return false
    end
    if player ~= Trait.cachedPlayer or Trait.playerHasTargetTrait == nil then
        return Trait.RefreshForPlayer(player)
    end
    return Trait.playerHasTargetTrait == true
end

function Trait.HasDistanceRunnerTrait(player)
    return Trait.PlayerHasTrait(player)
end

function Trait.IsRuntimeEnabled()
    return Trait.runtime_enabled == true
end

function Trait.GetDebugSnapshot(player)
    if player ~= Trait.cachedPlayer or Trait.playerHasTargetTrait == nil then
        Trait.RefreshForPlayer(player)
    end
    return Trait.lastSnapshot or {
        objectFound = false,
        aliasFound = false,
        matchedAlias = nil,
        aliases = traitAliases,
        names = {},
        count = 0,
    }
end

Core.Trait = Trait
Core.HasDistanceRunnerTrait = Trait.HasDistanceRunnerTrait
return Trait
