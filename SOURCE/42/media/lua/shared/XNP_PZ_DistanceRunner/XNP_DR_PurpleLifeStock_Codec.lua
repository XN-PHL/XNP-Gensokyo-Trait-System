require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleTraitCatalog"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants
local TraitCatalog = Core.PurpleTraitCatalog
local Codec = { lastTraitComparison = nil }

local function finiteNumber(value)
    return type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge
end

local function rounded(value, places)
    value = tonumber(value)
    if not value or not finiteNumber(value) then return value end
    local factor = 10 ^ (places or 6)
    if value >= 0 then return math.floor(value * factor + 0.5) / factor end
    return math.ceil(value * factor - 0.5) / factor
end

local function scalarKey(value)
    local kind = type(value)
    if kind == "string" then return "s:" .. value end
    if kind == "number" and finiteNumber(value) then
        return "n:" .. string.format("%.9f", value)
    end
    if kind == "boolean" then return value and "b:1" or "b:0" end
    return kind .. ":" .. tostring(value)
end

local function sortedKeys(value)
    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys, function(left, right)
        return scalarKey(left) < scalarKey(right)
    end)
    return keys
end

local function canonical(value, seen)
    local kind = type(value)
    if kind == "nil" then return "z;" end
    if kind == "boolean" then return value and "b1;" or "b0;" end
    if kind == "number" then
        if not finiteNumber(value) then error("NON_FINITE_NUMBER") end
        return "n" .. string.format("%.9f", value) .. ";"
    end
    if kind == "string" then return "s" .. tostring(#value) .. ":" .. value .. ";" end
    if kind ~= "table" then error("UNSUPPORTED_SERIALIZABLE_TYPE:" .. kind) end
    if seen[value] then error("CYCLIC_TABLE") end
    seen[value] = true
    local output = { "t{" }
    for _, key in ipairs(sortedKeys(value)) do
        output[#output + 1] = canonical(key, seen)
        output[#output + 1] = canonical(value[key], seen)
    end
    output[#output + 1] = "};"
    seen[value] = nil
    return table.concat(output)
end

local function checksumString(text)
    local hash = 2166136261
    for index = 1, #text do
        hash = (hash * 16777619 + string.byte(text, index)) % 4294967291
    end
    local digits = tostring(math.floor(hash + 0.5))
    while #digits < 10 do digits = "0" .. digits end
    return "XNP1-" .. digits .. "-" .. tostring(#text)
end

local function copySerializable(value, seen)
    local kind = type(value)
    if kind == "nil" or kind == "string" or kind == "boolean" then return value end
    if kind == "number" then
        if not finiteNumber(value) then error("NON_FINITE_NUMBER") end
        return value
    end
    if kind ~= "table" then error("UNSUPPORTED_SERIALIZABLE_TYPE:" .. kind) end
    if seen[value] then error("CYCLIC_TABLE") end
    seen[value] = true
    local result = {}
    for key, child in pairs(value) do
        local keyKind = type(key)
        if keyKind ~= "string" and keyKind ~= "number" then
            error("UNSUPPORTED_TABLE_KEY:" .. keyKind)
        end
        result[copySerializable(key, seen)] = copySerializable(child, seen)
    end
    seen[value] = nil
    return result
end

local function stableStringList(values)
    local seen = {}
    local result = {}
    for _, value in ipairs(values or {}) do
        local id = tostring(value or "")
        if id ~= "" and not seen[id] then
            seen[id] = true
            result[#result + 1] = id
        end
    end
    table.sort(result)
    return result
end

local function normalizedPerks(values)
    local byId = {}
    for _, value in ipairs(values or {}) do
        if type(value) == "table" then
            local id = tostring(value.id or "")
            if id ~= "" then
                byId[id] = {
                    id = id,
                    level = math.max(0, math.floor(tonumber(value.level) or 0)),
                    xp = rounded(value.xp, 3) or 0,
                }
            end
        end
    end
    local result = {}
    for _, id in ipairs(sortedKeys(byId)) do result[#result + 1] = byId[id] end
    return result
end

local function normalizeNumbers(value, seen)
    local kind = type(value)
    if kind == "number" then return rounded(value, 6) end
    if kind ~= "table" then return value end
    if seen[value] then error("CYCLIC_TABLE") end
    seen[value] = true
    local result = {}
    for key, child in pairs(value) do
        result[key] = normalizeNumbers(child, seen)
    end
    seen[value] = nil
    return result
end

function Codec.CopySerializable(value)
    local ok, copied = pcall(copySerializable, value, {})
    if not ok then return nil, tostring(copied) end
    return copied, "COPIED"
end

function Codec.NormalizePayload(payload)
    if type(payload) ~= "table" then return nil, "PAYLOAD_NOT_TABLE" end
    local ok, normalized = pcall(normalizeNumbers, payload, {})
    if not ok then return nil, tostring(normalized) end
    local sourceTraits = payload.traits
        or (payload.trait_state and payload.trait_state.actual_traits) or {}
    normalized.trait_state = TraitCatalog.BuildTraitState(
        normalized.identity and normalized.identity.profession_id,
        sourceTraits, payload.trait_state)
    normalized.traits = normalized.trait_state.actual_traits
    normalized.known_recipes = stableStringList(payload.known_recipes)
    normalized.perks = normalizedPerks(payload.perks)
    normalized.xnp_traits = {}
    local present = {}
    for _, id in ipairs(normalized.traits) do present[id] = true end
    for _, id in ipairs(Constants.XNP_TRAIT_FULL_IDS or {}) do
        local canonical = TraitCatalog.CanonicalizeTraitId(id)
        normalized.xnp_traits[canonical] = present[canonical] == true
    end
    normalized.inventory_included = false
    normalized.worn_items_included = false
    normalized.world_position_included = false
    normalized.body_damage_included = false
    return normalized, "PAYLOAD_NORMALIZED"
end

function Codec.Canonical(value)
    local ok, text = pcall(canonical, value, {})
    if not ok then return nil, tostring(text) end
    return text, "CANONICAL"
end

function Codec.PayloadChecksum(payload)
    local normalized, normalizeReason = Codec.NormalizePayload(payload)
    if not normalized then return nil, normalizeReason end
    local text, reason = Codec.Canonical(normalized)
    if not text then return nil, reason end
    return checksumString(text), "CHECKSUMMED"
end

function Codec.SnapshotChecksum(snapshot)
    if type(snapshot) ~= "table" then return nil, "SNAPSHOT_NOT_TABLE" end
    local normalized, reason = Codec.NormalizePayload(snapshot.payload)
    if not normalized then return nil, reason end
    local text, canonicalReason = Codec.Canonical({
        identity = {
            schema_version = snapshot.schema_version,
            snapshot_id = snapshot.snapshot_id,
            lineage_id = snapshot.lineage_id,
            created_game_time = rounded(snapshot.created_game_time, 5),
            source = snapshot.source,
        },
        payload = normalized,
    })
    if not text then return nil, canonicalReason end
    return checksumString(text), "CHECKSUMMED"
end

function Codec.MigrateSnapshot(snapshot)
    if type(snapshot) ~= "table" then return nil, "SNAPSHOT_NOT_TABLE" end
    local migrated, copyReason = Codec.CopySerializable(snapshot)
    if not migrated then return nil, copyReason end
    local normalized, normalizeReason = Codec.NormalizePayload(migrated.payload)
    if not normalized then return nil, normalizeReason end
    migrated.payload = normalized
    migrated.schema_version = Constants.SNAPSHOT_SCHEMA
    migrated.checksum = nil
    local checksum, checksumReason = Codec.SnapshotChecksum(migrated)
    if not checksum then return nil, checksumReason end
    migrated.checksum = checksum
    migrated.canonical_migration = Constants.MIGRATION_MARKER
    return migrated, checksum
end

function Codec.ValidateSnapshot(snapshot)
    if type(snapshot) ~= "table" then return false, "SNAPSHOT_NOT_TABLE" end
    if snapshot.schema_version ~= Constants.SNAPSHOT_SCHEMA then
        return false, "SCHEMA_MISMATCH"
    end
    if type(snapshot.snapshot_id) ~= "string" or snapshot.snapshot_id == "" then
        return false, "SNAPSHOT_ID_MISSING"
    end
    if type(snapshot.lineage_id) ~= "string" or snapshot.lineage_id == "" then
        return false, "LINEAGE_ID_MISSING"
    end
    if snapshot.source ~= Constants.SOURCE_MANUAL
        and snapshot.source ~= Constants.SOURCE_AUTO
        and snapshot.source ~= Constants.SOURCE_INITIAL
        and snapshot.source ~= Constants.SOURCE_DEATH_FINAL
        and snapshot.source ~= Constants.SOURCE_DEATH_FALLBACK then
        return false, "SNAPSHOT_SOURCE_INVALID"
    end
    local payload = snapshot.payload
    if type(payload) ~= "table" then return false, "PAYLOAD_MISSING" end
    if type(payload.identity) ~= "table" then return false, "IDENTITY_MISSING" end
    if type(payload.identity.profession_id) ~= "string"
        or payload.identity.profession_id == "" then
        return false, "PROFESSION_ID_MISSING"
    end
    if type(payload.traits) ~= "table" then return false, "TRAITS_MISSING" end
    if type(payload.perks) ~= "table" then return false, "PERKS_MISSING" end
    if type(payload.visual) ~= "table" then return false, "VISUAL_MISSING" end
    if type(payload.nutrition) ~= "table" then return false, "NUTRITION_MISSING" end
    local checksum, checksumReason = Codec.SnapshotChecksum(snapshot)
    if not checksum then return false, checksumReason end
    if snapshot.checksum and snapshot.checksum ~= checksum then
        return false, "CHECKSUM_MISMATCH"
    end
    return true, checksum
end

local function listEqual(left, right)
    left = stableStringList(left)
    right = stableStringList(right)
    if #left ~= #right then return false end
    for index = 1, #left do
        if left[index] ~= right[index] then return false end
    end
    return true
end

local function near(left, right, tolerance)
    left, right = tonumber(left), tonumber(right)
    return left ~= nil and right ~= nil
        and math.abs(left - right) <= (tolerance or 0.001)
end

local function colorEqual(left, right)
    if left == nil and right == nil then return true end
    if type(left) ~= "table" or type(right) ~= "table" then return false end
    for _, key in ipairs({ "r", "g", "b", "a" }) do
        if not near(left[key], right[key], 0.002) then return false end
    end
    return true
end

local function perksEqual(left, right)
    left, right = normalizedPerks(left), normalizedPerks(right)
    if #left ~= #right then return false, "PERK_COUNT" end
    for index = 1, #left do
        if left[index].id ~= right[index].id then return false, "PERK_ID" end
        if left[index].level ~= right[index].level then return false, "PERK_LEVEL" end
        if not near(left[index].xp, right[index].xp, 0.02) then return false, "PERK_XP" end
    end
    return true, "PERKS_MATCH"
end

function Codec.CompareTraitStates(expected, actual)
    local expectedIdentity = expected and expected.identity or {}
    local actualIdentity = actual and actual.identity or {}
    local expectedState = expected and expected.trait_state
        or TraitCatalog.BuildTraitState(expectedIdentity.profession_id,
            expected and expected.traits or {})
    local actualState = actual and actual.trait_state
        or TraitCatalog.BuildTraitState(actualIdentity.profession_id,
            actual and actual.traits or {})
    local matches, details = TraitCatalog.CompareTraitStates(expectedState, actualState)
    Codec.lastTraitComparison = details
    return matches, details
end

function Codec.GetLastTraitComparison()
    return Codec.lastTraitComparison
end

function Codec.SemanticPayloadMatches(expected, actual)
    if type(expected) ~= "table" or type(actual) ~= "table" then
        return false, "PAYLOAD_NOT_TABLE"
    end
    local ei, ai = expected.identity or {}, actual.identity or {}
    for _, key in ipairs({ "forename", "surname", "profession_id", "voice_prefix" }) do
        if tostring(ei[key] or "") ~= tostring(ai[key] or "") then
            return false, "IDENTITY_MISMATCH:" .. key
        end
    end
    if (ei.female == true) ~= (ai.female == true) then
        return false, "IDENTITY_MISMATCH:female"
    end
    if not near(ei.voice_type or 0, ai.voice_type or 0, 0.001)
        or not near(ei.voice_pitch or 0, ai.voice_pitch or 0, 0.002) then
        return false, "IDENTITY_MISMATCH:voice"
    end
    local expectedState = expected.trait_state
        or TraitCatalog.BuildTraitState(ei.profession_id, expected.traits or {})
    local actualState = actual.trait_state
        or TraitCatalog.BuildTraitState(ai.profession_id, actual.traits or {})
    local traitsMatch, traitDetails = TraitCatalog.CompareTraitStates(
        expectedState, actualState)
    Codec.lastTraitComparison = traitDetails
    if not traitsMatch then
        return false, "TRAITS_MISMATCH"
    end
    local perksMatch, perksReason = perksEqual(expected.perks, actual.perks)
    if not perksMatch then return false, perksReason end
    if not listEqual(expected.known_recipes, actual.known_recipes) then
        return false, "KNOWN_RECIPES_MISMATCH"
    end
    for _, key in ipairs({ "weight", "carbohydrates", "proteins", "calories", "lipids" }) do
        if not near((expected.nutrition or {})[key],
            (actual.nutrition or {})[key], 0.05) then
            return false, "NUTRITION_MISMATCH:" .. key
        end
    end
    local ev, av = expected.visual or {}, actual.visual or {}
    for _, key in ipairs({
        "female", "skin_texture_index", "body_hair_index",
        "hair_model", "beard_model", "non_attached_hair",
    }) do
        if tostring(ev[key]) ~= tostring(av[key]) then
            return false, "VISUAL_MISMATCH:" .. key
        end
    end
    for _, key in ipairs({
        "skin_color", "hair_color", "beard_color",
        "natural_hair_color", "natural_beard_color",
    }) do
        if not colorEqual(ev[key], av[key]) then
            return false, "VISUAL_MISMATCH:" .. key
        end
    end
    return true, "SEMANTIC_PAYLOAD_MATCH"
end

Core.PurpleLifeStockCodec = Codec
return Codec
