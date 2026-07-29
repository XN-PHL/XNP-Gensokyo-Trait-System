require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"

XNP_PZ_DistanceRunner = XNP_PZ_DistanceRunner or {}

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants

local Catalog = {}

local KNOWN_XNP_ALIASES = {
    ["xnpdistancerunnertrait:xnpdistancerunner"] = "XNPDistanceRunnerTrait:XNPDistanceRunner",
    ["xnpdistancerunner"] = "XNPDistanceRunnerTrait:XNPDistanceRunner",
    ["xnpdistancerunnertrait"] = "XNPDistanceRunnerTrait:XNPDistanceRunner",
    ["xnpphoenixtrait:xnppurplephoenix"] = "XNPPhoenixTrait:XNPPurplePhoenix",
    ["xnppurplephoenix"] = "XNPPhoenixTrait:XNPPurplePhoenix",
    ["xnpphoenixtrait"] = "XNPPhoenixTrait:XNPPurplePhoenix",
    ["xnpblueecobarragetrait:xnpblueecobarrage"] = "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
    ["xnpblueecobarrage"] = "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
    ["xnpblueecobarragetrait"] = "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
    ["xnpgreenskilltrait:xnpgreenskill"] = "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
    ["xnpgreenskill"] = "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
    ["xnpgreenskilltrait"] = "XNPBlueEcoBarrageTrait:XNPBlueEcoBarrage",
    ["xnpfeastguardiantrait:xnpfeastguardian"] = "XNPFeastGuardianTrait:XNPFeastGuardian",
    ["xnpfeastguardian"] = "XNPFeastGuardianTrait:XNPFeastGuardian",
    ["xnpfeastguardiantrait"] = "XNPFeastGuardianTrait:XNPFeastGuardian",
}

local MANDATORY_RUNTIME_FIELDS = {
    "EMACIATED", "VERY_UNDERWEIGHT", "UNDERWEIGHT", "OVERWEIGHT", "OBESE",
    "WEAK", "FEEBLE", "STOUT", "STRONG",
    "UNFIT", "OUT_OF_SHAPE", "FIT", "ATHLETIC",
    "WEIGHT_GAIN", "WEIGHT_LOSS",
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function aliasKey(value)
    return string.lower(trim(value)):gsub("[%s_%-]", "")
end

local function objectFullId(object)
    if object == nil then return "" end
    if type(object) == "string" then return trim(object) end
    local text = trim(tostring(object))
    if text ~= "" then return text end
    local okName, name = invoke(object, "getName")
    return okName and trim(name) or ""
end

local function objectShortId(object)
    local okName, name = invoke(object, "getName")
    if okName and name ~= nil then return trim(name) end
    local full = objectFullId(object)
    return full:match("^[^:]+:(.+)$") or full
end

local function objectRuntimeType(object)
    local okClass, classObject = invoke(object, "getClass")
    local okName, className = invoke(okClass and classObject or nil, "getName")
    if okName and className then return tostring(className) end
    return type(object)
end

local function stableList(values)
    local seen, result = {}, {}
    for _, value in ipairs(values or {}) do
        local id = trim(value)
        if id ~= "" and not seen[id] then
            seen[id] = true
            result[#result + 1] = id
        end
    end
    table.sort(result)
    return result
end

local function eachJava(collection, callback)
    local okSize, size = invoke(collection, "size")
    size = okSize and tonumber(size) or nil
    if not size then return false, "COLLECTION_SIZE_UNAVAILABLE" end
    for index = 0, size - 1 do
        local okValue, value = invoke(collection, "get", index)
        if not okValue then return false, "COLLECTION_READ_FAILED:" .. tostring(index) end
        callback(value, index)
    end
    return true, "COLLECTION_SCANNED"
end

local function registerAlias(map, key, record)
    key = aliasKey(key)
    if key == "" then return end
    if map[key] == nil then
        map[key] = record
    elseif map[key] ~= record then
        map[key] = false
    end
end

local function exactTrait(fullId)
    if not CharacterTrait or type(CharacterTrait.get) ~= "function"
        or not ResourceLocation or type(ResourceLocation.of) ~= "function" then
        return nil
    end
    local okLocation, location = pcall(ResourceLocation.of, fullId)
    if not okLocation or not location then return nil end
    local okTrait, trait = pcall(CharacterTrait.get, location)
    return okTrait and trait or nil
end

local function buildTraitRegistry()
    local byCanonical, aliases = {}, {}
    local function addTrait(trait)
        local canonical = objectFullId(trait)
        if canonical == "" then return end
        local record = byCanonical[canonical]
        if not record then
            record = { object = trait, full_id = canonical, short_id = objectShortId(trait) }
            byCanonical[canonical] = record
        elseif not record.object then
            record.object = trait
        end
        registerAlias(aliases, canonical, record)
        registerAlias(aliases, record.short_id, record)
    end

    if CharacterTraitDefinition and type(CharacterTraitDefinition.getTraits) == "function" then
        local okDefinitions, definitions = pcall(CharacterTraitDefinition.getTraits)
        if okDefinitions and definitions then
            eachJava(definitions, function(definition)
                local okType, trait = invoke(definition, "getType")
                if okType and trait then addTrait(trait) end
            end)
        end
    end
    for _, fullId in ipairs(Constants.XNP_TRAIT_FULL_IDS or {}) do
        local trait = exactTrait(fullId)
        if trait then addTrait(trait) end
    end
    return { by_canonical = byCanonical, aliases = aliases }
end

local function knownCanonical(value)
    return KNOWN_XNP_ALIASES[aliasKey(value)]
end

function Catalog.ResolveTrait(requestedId)
    local requested = trim(requestedId)
    if requested == "" then return nil, nil, nil, "TRAIT_ID_EMPTY" end

    local preferred = knownCanonical(requested) or requested
    if string.find(preferred, ":", 1, true) then
        local trait = exactTrait(preferred)
        if trait then
            return trait, objectFullId(trait), preferred ~= requested and requested or nil,
                preferred ~= requested and "KNOWN_ALIAS_EXACT_REGISTRY" or "EXACT_REGISTRY"
        end
    end

    local registry = buildTraitRegistry()
    local record = registry.by_canonical[preferred]
        or registry.aliases[aliasKey(preferred)]
        or registry.aliases[aliasKey(requested)]
    if record and record ~= false and record.object then
        local matchedAlias = record.full_id ~= requested and requested or nil
        return record.object, record.full_id, matchedAlias, "REGISTRY_ENUMERATION"
    end
    return nil, preferred, preferred ~= requested and requested or nil, "TRAIT_NOT_FOUND"
end

function Catalog.CanonicalizeTraitId(value)
    local requested = trim(value)
    if requested == "" then return "", nil, "TRAIT_ID_EMPTY" end
    local trait, canonical, matchedAlias, route = Catalog.ResolveTrait(requested)
    if trait and canonical then return canonical, matchedAlias, route end
    local known = knownCanonical(requested)
    return known or requested, known and requested or nil,
        known and "KNOWN_ALIAS_WITHOUT_RUNTIME_OBJECT" or route
end

local function canonicalList(values, aliasEvidence)
    local result = {}
    for _, value in ipairs(values or {}) do
        local canonical, matchedAlias = Catalog.CanonicalizeTraitId(value)
        if canonical ~= "" then
            result[#result + 1] = canonical
            if matchedAlias and aliasEvidence then
                aliasEvidence[#aliasEvidence + 1] = tostring(matchedAlias) .. "=>" .. canonical
            end
        end
    end
    return stableList(result)
end

local function resolveProfession(professionId)
    local requested = trim(professionId)
    if requested == "" then return nil, "PROFESSION_ID_EMPTY" end
    if CharacterProfession and type(CharacterProfession.get) == "function"
        and ResourceLocation and type(ResourceLocation.of) == "function" then
        local okLocation, location = pcall(ResourceLocation.of, requested)
        if okLocation and location then
            local okProfession, profession = pcall(CharacterProfession.get, location)
            if okProfession and profession then return profession, "EXACT_PROFESSION_REGISTRY" end
        end
    end
    if CharacterProfessionDefinition
        and type(CharacterProfessionDefinition.getProfessions) == "function" then
        local okDefinitions, definitions = pcall(CharacterProfessionDefinition.getProfessions)
        if okDefinitions and definitions then
            local resolved = nil
            eachJava(definitions, function(definition)
                if resolved then return end
                local okType, profession = invoke(definition, "getType")
                local full = okType and objectFullId(profession) or ""
                local short = okType and objectShortId(profession) or ""
                if requested == full or aliasKey(requested) == aliasKey(short) then
                    resolved = profession
                end
            end)
            if resolved then return resolved, "PROFESSION_REGISTRY_ENUMERATION" end
        end
    end
    return nil, "PROFESSION_NOT_FOUND"
end

function Catalog.ProfessionDerivedTraits(professionId)
    local profession, professionReason = resolveProfession(professionId)
    if not profession then return {}, professionReason end
    if not CharacterProfessionDefinition
        or type(CharacterProfessionDefinition.getCharacterProfessionDefinition) ~= "function" then
        return {}, "PROFESSION_DEFINITION_API_UNAVAILABLE"
    end
    local okDefinition, definition = pcall(
        CharacterProfessionDefinition.getCharacterProfessionDefinition, profession)
    if not okDefinition or not definition then return {}, "PROFESSION_DEFINITION_NOT_FOUND" end
    local okGranted, granted = invoke(definition, "getGrantedTraits")
    if not okGranted or not granted then return {}, "PROFESSION_GRANTED_TRAITS_UNAVAILABLE" end
    local result = {}
    eachJava(granted, function(trait)
        local id = objectFullId(trait)
        if id ~= "" then result[#result + 1] = id end
    end)
    return stableList(result), "PROFESSION_DERIVED_CAPTURED"
end

function Catalog.MandatoryRuntimeTraits()
    local result = {}
    if CharacterTrait then
        for _, field in ipairs(MANDATORY_RUNTIME_FIELDS) do
            local trait = CharacterTrait[field]
            local id = objectFullId(trait)
            if id ~= "" then result[#result + 1] = id end
        end
    end
    return stableList(result)
end

function Catalog.BuildTraitState(professionId, actualTraits, existingState)
    local aliasEvidence = {}
    local actual = canonicalList(actualTraits, aliasEvidence)
    local actualSet = {}
    for _, id in ipairs(actual) do actualSet[id] = true end

    local professionSource = existingState and existingState.profession_derived_traits or nil
    if not professionSource then professionSource = Catalog.ProfessionDerivedTraits(professionId) end
    local professionDerived = canonicalList(professionSource, aliasEvidence)
    local mandatoryCatalog = canonicalList(Catalog.MandatoryRuntimeTraits(), aliasEvidence)
    local mandatory = canonicalList(
        existingState and existingState.mandatory_runtime_traits or mandatoryCatalog,
        aliasEvidence)

    local professionSet, mandatorySet = {}, {}
    for _, id in ipairs(professionDerived) do professionSet[id] = true end
    for _, id in ipairs(mandatory) do mandatorySet[id] = true end

    local explicitSource = existingState and existingState.snapshot_explicit_traits or nil
    local explicit = {}
    if explicitSource then
        explicit = canonicalList(explicitSource, aliasEvidence)
    else
        for _, id in ipairs(actual) do
            if not professionSet[id] and not mandatorySet[id] then explicit[#explicit + 1] = id end
        end
    end

    local presentProfession, presentMandatory = {}, {}
    for _, id in ipairs(professionDerived) do
        if actualSet[id] then presentProfession[#presentProfession + 1] = id end
    end
    for _, id in ipairs(mandatory) do
        if actualSet[id] then presentMandatory[#presentMandatory + 1] = id end
    end

    return {
        snapshot_explicit_traits = stableList(explicit),
        profession_derived_traits = stableList(presentProfession),
        mandatory_runtime_traits = stableList(presentMandatory),
        actual_traits = actual,
        equivalent_alias_traits = stableList(aliasEvidence),
    }
end

function Catalog.CapturePlayerTraitIds(player)
    local okTraits, characterTraits = invoke(player, "getCharacterTraits")
    local okKnown, known = invoke(okTraits and characterTraits or nil, "getKnownTraits")
    if not okKnown or not known then return nil, "KNOWN_TRAITS_UNAVAILABLE" end
    local result = {}
    local scanned, reason = eachJava(known, function(trait)
        local id = objectFullId(trait)
        if id ~= "" then result[#result + 1] = id end
    end)
    if not scanned then return nil, reason end
    return canonicalList(result), "PLAYER_TRAITS_CAPTURED"
end

local function setOf(values)
    local result = {}
    for _, value in ipairs(values or {}) do result[value] = true end
    return result
end

function Catalog.CompareTraitStates(expectedState, actualState)
    expectedState = expectedState or {}
    actualState = actualState or {}
    local aliasEvidence = {}
    local expected = canonicalList(expectedState.actual_traits or {}, aliasEvidence)
    local actual = canonicalList(actualState.actual_traits or {}, aliasEvidence)
    local expectedSet, actualSet = setOf(expected), setOf(actual)
    local allowedExtra = setOf(canonicalList(actualState.profession_derived_traits or {}))
    local mandatoryExtra = setOf(canonicalList(actualState.mandatory_runtime_traits or {}))
    for id in pairs(mandatoryExtra) do allowedExtra[id] = true end

    local missing, unexpected = {}, {}
    for _, id in ipairs(expected) do
        if not actualSet[id] then missing[#missing + 1] = id end
    end
    for _, id in ipairs(actual) do
        if not expectedSet[id] and not allowedExtra[id] then unexpected[#unexpected + 1] = id end
    end

    local expectedRaw = expectedState.actual_traits or {}
    local actualRaw = actualState.actual_traits or {}
    for _, left in ipairs(expectedRaw) do
        local leftCanonical = Catalog.CanonicalizeTraitId(left)
        for _, right in ipairs(actualRaw) do
            local rightCanonical = Catalog.CanonicalizeTraitId(right)
            if leftCanonical == rightCanonical and tostring(left) ~= tostring(right) then
                aliasEvidence[#aliasEvidence + 1] = tostring(left) .. "==" .. tostring(right)
            end
        end
    end

    return #missing == 0 and #unexpected == 0, {
        missing_required_traits = stableList(missing),
        unexpected_nonmandatory_traits = stableList(unexpected),
        equivalent_alias_traits = stableList(aliasEvidence),
        expected_traits = expected,
        snapshot_explicit_traits = canonicalList(
            expectedState.snapshot_explicit_traits or {}),
        profession_derived_traits = canonicalList(
            actualState.profession_derived_traits or {}),
        mandatory_runtime_traits = canonicalList(
            actualState.mandatory_runtime_traits or {}),
        actual_traits = actual,
    }
end

function Catalog.ResolveTraitGroups(traitState)
    traitState = traitState or {}
    local seen = {}
    local result = {
        profession_derived_traits = {},
        snapshot_explicit_traits = {},
        mandatory_runtime_traits = {},
        all = {},
    }
    local function resolveGroup(name)
        for _, requested in ipairs(traitState[name] or {}) do
            local trait, canonical, matchedAlias, route = Catalog.ResolveTrait(requested)
            if not trait then
                print("[XNP PURPLE TRAIT RESTORE RESOLVE] requested_snapshot_id="
                    .. tostring(requested)
                    .. " requested_id=" .. tostring(requested)
                    .. " registry_canonical_id=" .. tostring(canonical or "NONE")
                    .. " canonical_full_id=" .. tostring(canonical or "NONE")
                    .. " resolved_object=false object_resolved=false"
                    .. " object_runtime_type=NONE runtime_readback_id=NONE"
                    .. " add_route=CharacterTraits:add(CharacterTrait)"
                    .. " matched_alias=" .. tostring(matchedAlias or "NONE")
                    .. " resolve_route=" .. tostring(route))
                return false, "TRAIT_NOT_FOUND:" .. tostring(requested)
            end
            local runtimeId = objectFullId(trait)
            print("[XNP PURPLE TRAIT RESTORE RESOLVE] requested_snapshot_id="
                .. tostring(requested)
                .. " requested_id=" .. tostring(requested)
                .. " registry_canonical_id=" .. tostring(canonical)
                .. " canonical_full_id=" .. tostring(canonical)
                .. " resolved_object=true object_resolved=true"
                .. " object_runtime_type=" .. tostring(objectRuntimeType(trait))
                .. " runtime_readback_id=" .. tostring(runtimeId)
                .. " add_route=CharacterTraits:add(CharacterTrait)"
                .. " matched_alias=" .. tostring(matchedAlias or "NONE")
                .. " resolve_route=" .. tostring(route))
            if not seen[canonical] then
                seen[canonical] = true
                result[name][#result[name] + 1] = trait
                result.all[#result.all + 1] = trait
            end
        end
        return true
    end
    for _, name in ipairs({
        "profession_derived_traits", "snapshot_explicit_traits",
        "mandatory_runtime_traits",
    }) do
        local ok, reason = resolveGroup(name)
        if not ok then return nil, reason end
    end
    return result, "TRAIT_GROUPS_RESOLVED"
end

function Catalog.ObjectFullId(object)
    return objectFullId(object)
end

function Catalog.StableList(values)
    return stableList(values)
end

Core.PurpleTraitCatalog = Catalog
return Catalog
