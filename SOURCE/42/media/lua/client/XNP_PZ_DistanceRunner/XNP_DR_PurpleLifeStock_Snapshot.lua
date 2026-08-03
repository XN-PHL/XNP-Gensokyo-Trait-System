require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Constants"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Codec"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleLifeStock_Registry"
require "XNP_PZ_DistanceRunner/XNP_DR_PurpleTraitCatalog"

local Core = XNP_PZ_DistanceRunner
local Constants = Core.PurpleLifeStockConstants
local Codec = Core.PurpleLifeStockCodec
local Registry = Core.PurpleLifeStockRegistry
local TraitCatalog = Core.PurpleTraitCatalog

local Snapshot = {}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function rounded(value, places)
    value = tonumber(value)
    if not value then return nil end
    local factor = 10 ^ (places or 4)
    if value >= 0 then return math.floor(value * factor + 0.5) / factor end
    return math.ceil(value * factor - 0.5) / factor
end

local function javaList(collection, mapper)
    if not collection then return nil, "COLLECTION_MISSING" end
    local okSize, size = invoke(collection, "size")
    size = okSize and tonumber(size) or nil
    if not size then return nil, "COLLECTION_SIZE_UNAVAILABLE" end
    local result = {}
    for index = 0, size - 1 do
        local okValue, value = invoke(collection, "get", index)
        if not okValue then return nil, "COLLECTION_READ_FAILED:" .. tostring(index) end
        local mapped, reason = mapper(value, index)
        if mapped == nil and reason then return nil, reason end
        if mapped ~= nil then result[#result + 1] = mapped end
    end
    return result, "COLLECTION_CAPTURED"
end

local function captureColor(color)
    if not color then return nil end
    local okR, r = invoke(color, "getRedFloat")
    local okG, g = invoke(color, "getGreenFloat")
    local okB, b = invoke(color, "getBlueFloat")
    local okA, a = invoke(color, "getAlphaFloat")
    if not okR or not okG or not okB then return nil end
    return {
        r = rounded(r, 5),
        g = rounded(g, 5),
        b = rounded(b, 5),
        a = rounded(okA and a or 1, 5),
    }
end

local function readValue(object, method, fallback)
    local ok, value = invoke(object, method)
    if ok and value ~= nil then return value end
    return fallback
end

local function stableRegistryId(object)
    local id = readValue(object, "getId", nil)
    if id == nil then id = object end
    return tostring(id or "")
end

local function captureIdentity(player, descriptor)
    local profession = readValue(descriptor, "getCharacterProfession", nil)
    if not profession then return nil, "PROFESSION_UNAVAILABLE" end
    local professionId = stableRegistryId(profession)
    if professionId == "" then return nil, "PROFESSION_ID_EMPTY" end
    return {
        forename = tostring(readValue(descriptor, "getForename", "")),
        surname = tostring(readValue(descriptor, "getSurname", "")),
        female = readValue(player, "isFemale", false) == true,
        profession_id = professionId,
        profession_display = tostring(readValue(profession, "getName", professionId)),
        voice_prefix = tostring(readValue(descriptor, "getVoicePrefix", "")),
        voice_type = tonumber(readValue(descriptor, "getVoiceType", 0)) or 0,
        voice_pitch = rounded(readValue(descriptor, "getVoicePitch", 0), 5) or 0,
    }, "IDENTITY_CAPTURED"
end

local function captureTraits(player)
    return TraitCatalog.CapturePlayerTraitIds(player)
end

local function buildPerkMap()
    if not Perks or not PerkFactory or type(Perks.getMaxIndex) ~= "function"
        or type(Perks.fromIndex) ~= "function"
        or type(PerkFactory.getPerk) ~= "function" then
        return nil, "PERK_REGISTRY_UNAVAILABLE"
    end
    local okMax, maximum = pcall(Perks.getMaxIndex)
    maximum = okMax and tonumber(maximum) or nil
    if not maximum then return nil, "PERK_MAX_INDEX_UNAVAILABLE" end
    local map = {}
    local ordered = {}
    for index = 0, maximum - 1 do
        local okEnum, enumValue = pcall(Perks.fromIndex, index)
        local okPerk, perk = false, nil
        if okEnum then
            okPerk, perk = pcall(PerkFactory.getPerk, enumValue)
        end
        if okPerk and perk then
            local okParent, parent = invoke(perk, "getParent")
            if okParent and parent ~= Perks.None then
                local id = tostring(readValue(perk, "getId", perk))
                if id ~= "" and not map[id] then
                    map[id] = perk
                    ordered[#ordered + 1] = { id = id, perk = perk }
                end
            end
        end
    end
    table.sort(ordered, function(left, right) return left.id < right.id end)
    return { map = map, ordered = ordered }, "PERK_MAP_READY"
end

local function capturePerks(player)
    local perkMap, reason = buildPerkMap()
    if not perkMap then return nil, reason end
    local okXp, xp = invoke(player, "getXp")
    if not okXp or not xp then return nil, "XP_OBJECT_UNAVAILABLE" end
    local result = {}
    for _, entry in ipairs(perkMap.ordered) do
        local okLevel, level = invoke(player, "getPerkLevel", entry.perk)
        local okValue, value = invoke(xp, "getXP", entry.perk)
        if not okLevel or not okValue then
            return nil, "PERK_READ_FAILED:" .. entry.id
        end
        result[#result + 1] = {
            id = entry.id,
            level = math.floor(tonumber(level) or 0),
            xp = rounded(value, 3) or 0,
        }
    end
    return result, "PERKS_CAPTURED"
end

local function captureKnownRecipes(player)
    local okKnown, known = invoke(player, "getKnownRecipes")
    if not okKnown or not known then return {}, "KNOWN_RECIPES_NOT_SUPPORTED" end
    local result, reason = javaList(known, function(recipe)
        return tostring(recipe or "")
    end)
    if not result then return nil, reason end
    table.sort(result)
    return result, "KNOWN_RECIPES_CAPTURED"
end

local function captureNutrition(player)
    local okNutrition, nutrition = invoke(player, "getNutrition")
    if not okNutrition or not nutrition then return nil, "NUTRITION_UNAVAILABLE" end
    local fields = {
        weight = "getWeight",
        carbohydrates = "getCarbohydrates",
        proteins = "getProteins",
        calories = "getCalories",
        lipids = "getLipids",
    }
    local result = {}
    for name, method in pairs(fields) do
        local ok, value = invoke(nutrition, method)
        if not ok or tonumber(value) == nil then
            return nil, "NUTRITION_READ_FAILED:" .. name
        end
        result[name] = rounded(value, 4)
    end
    return result, "NUTRITION_CAPTURED"
end

local function captureVisual(player, descriptor)
    local okVisual, visual = invoke(player, "getHumanVisual")
    if not okVisual or not visual then
        okVisual, visual = invoke(descriptor, "getHumanVisual")
    end
    if not okVisual or not visual then return nil, "HUMAN_VISUAL_UNAVAILABLE" end
    return {
        female = readValue(visual, "isFemale", readValue(player, "isFemale", false)) == true,
        skin_texture_index = tonumber(readValue(visual, "getSkinTextureIndex", 0)) or 0,
        skin_texture_name = tostring(readValue(visual, "getSkinTexture", "")),
        body_hair_index = tonumber(readValue(visual, "getBodyHairIndex", 0)) or 0,
        hair_model = tostring(readValue(visual, "getHairModel", "")),
        beard_model = tostring(readValue(visual, "getBeardModel", "")),
        non_attached_hair = tostring(readValue(visual, "getNonAttachedHair", "")),
        skin_color = captureColor(readValue(visual, "getSkinColor", nil)),
        hair_color = captureColor(readValue(visual, "getHairColor", nil)),
        beard_color = captureColor(readValue(visual, "getBeardColor", nil)),
        natural_hair_color = captureColor(readValue(visual, "getNaturalHairColor", nil)),
        natural_beard_color = captureColor(readValue(visual, "getNaturalBeardColor", nil)),
    }, "VISUAL_CAPTURED"
end

local function xnpTraitFlags(traits)
    local present = {}
    for _, id in ipairs(traits) do present[id] = true end
    local result = {}
    for _, id in ipairs(Constants.XNP_TRAIT_FULL_IDS) do
        result[id] = present[id] == true
    end
    return result
end

function Snapshot.CapturePayload(player)
    if not player then return nil, "PLAYER_MISSING" end
    local okDead, dead = invoke(player, "isDead")
    if okDead and dead == true then return nil, "PLAYER_DEAD" end
    local okDescriptor, descriptor = invoke(player, "getDescriptor")
    if not okDescriptor or not descriptor then return nil, "DESCRIPTOR_UNAVAILABLE" end

    local identity, identityReason = captureIdentity(player, descriptor)
    if not identity then return nil, identityReason end
    local traits, traitsReason = captureTraits(player)
    if not traits then return nil, traitsReason end
    local perks, perksReason = capturePerks(player)
    if not perks then return nil, perksReason end
    local recipes, recipesReason = captureKnownRecipes(player)
    if not recipes then return nil, recipesReason end
    local nutrition, nutritionReason = captureNutrition(player)
    if not nutrition then return nil, nutritionReason end
    local visual, visualReason = captureVisual(player, descriptor)
    if not visual then return nil, visualReason end

    local traitState = TraitCatalog.BuildTraitState(identity.profession_id, traits)
    local payload = {
        identity = identity,
        traits = traitState.actual_traits,
        trait_state = traitState,
        xnp_traits = xnpTraitFlags(traitState.actual_traits),
        perks = perks,
        nutrition = nutrition,
        known_recipes = recipes,
        known_recipes_status = recipesReason,
        visual = visual,
        inventory_included = false,
        worn_items_included = false,
        world_position_included = false,
        body_damage_included = false,
    }
    local normalized, normalizeReason = Codec.NormalizePayload(payload)
    if not normalized then return nil, normalizeReason end
    return normalized, "PAYLOAD_CAPTURED_CANONICAL"
end

function Snapshot.Build(player, lineage, ownerKey, source)
    local payload, reason = Snapshot.CapturePayload(player)
    if not payload then return nil, reason end
    local realTimeMs = os.time() * 1000
    if type(getTimestampMs) == "function" then
        local okTimestamp, timestamp = pcall(getTimestampMs)
        if okTimestamp and tonumber(timestamp) then realTimeMs = tonumber(timestamp) end
    end
    local snapshot = {
        schema_version = Constants.SNAPSHOT_SCHEMA,
        snapshot_id = Registry.NewSnapshotId(ownerKey),
        lineage_id = lineage,
        created_game_time = rounded(Registry.GameDay(), 5),
        created_real_time_ms = realTimeMs,
        source = source,
        build_marker = Core.Constants
            and Core.Constants.BUILD_ID
            or "XNP_PZ_DISTANCE_TRAIT_0560720_PURPLE_SHARED_INPUT_TRAIT_RESTORE_A",
        game_build_baseline = Core.Constants
            and Core.Constants.GAME_BUILD_TARGET or "42.20.0",
        payload = payload,
    }
    local valid, checksumOrReason = Codec.ValidateSnapshot(snapshot)
    if not valid then return nil, checksumOrReason end
    snapshot.checksum = checksumOrReason
    return snapshot, "SNAPSHOT_BUILT"
end

local function resolveProfession(id)
    if not CharacterProfession or type(CharacterProfession.get) ~= "function"
        or not ResourceLocation or type(ResourceLocation.of) ~= "function" then
        return nil, "PROFESSION_REGISTRY_UNAVAILABLE"
    end
    local okLocation, location = pcall(ResourceLocation.of, id)
    if not okLocation or not location then return nil, "PROFESSION_LOCATION_INVALID:" .. tostring(id) end
    local okProfession, profession = pcall(CharacterProfession.get, location)
    if not okProfession or not profession then return nil, "PROFESSION_NOT_FOUND:" .. tostring(id) end
    return profession, "PROFESSION_RESOLVED"
end

local function resolveTraits(traitState)
    return TraitCatalog.ResolveTraitGroups(traitState)
end

local function makeColor(value)
    if type(value) ~= "table" then return nil, "COLOR_MISSING" end
    if not ImmutableColor or type(ImmutableColor.new) ~= "function" then
        return nil, "IMMUTABLE_COLOR_UNAVAILABLE"
    end
    local ok, color = pcall(ImmutableColor.new,
        tonumber(value.r) or 0, tonumber(value.g) or 0,
        tonumber(value.b) or 0, tonumber(value.a) or 1)
    if not ok or not color then return nil, "COLOR_CREATE_FAILED" end
    return color, "COLOR_CREATED"
end

local function applyIdentity(player, descriptor, payload, profession)
    local identity = payload.identity
    local calls = {
        { descriptor, "setForename", identity.forename },
        { descriptor, "setSurname", identity.surname },
        { descriptor, "setCharacterProfession", profession },
        { player, "setFemale", identity.female == true },
        { descriptor, "setFemale", identity.female == true },
        { descriptor, "setVoicePrefix", identity.voice_prefix },
        { descriptor, "setVoiceType", identity.voice_type },
        { descriptor, "setVoicePitch", identity.voice_pitch },
    }
    for _, call in ipairs(calls) do
        local ok = invoke(call[1], call[2], call[3])
        if not ok then return false, "IDENTITY_WRITE_FAILED:" .. call[2] end
    end
    return true, "IDENTITY_APPLIED"
end

local function characterTraits(player)
    local okTraits, traits = invoke(player, "getCharacterTraits")
    if not okTraits or not traits then return nil, "CHARACTER_TRAITS_UNAVAILABLE" end
    return traits, "CHARACTER_TRAITS_RESOLVED"
end

local function traitInventory(player)
    local traits, traitsReason = characterTraits(player)
    if not traits then return false, traitsReason end
    local okKnown, known = invoke(traits, "getKnownTraits")
    if not okKnown or not known then return false, "KNOWN_TRAITS_UNAVAILABLE" end
    local entries, reason = javaList(known, function(trait)
        if not trait then return nil, "NULL_TRAIT" end
        local canonical = TraitCatalog.CanonicalizeTraitId(TraitCatalog.ObjectFullId(trait))
        return { trait = trait, canonical = canonical }
    end)
    if not entries then return false, reason end
    local groups = {}
    for _, entry in ipairs(entries) do
        groups[entry.canonical] = groups[entry.canonical] or {}
        groups[entry.canonical][#groups[entry.canonical] + 1] = entry
    end
    return traits, entries, groups
end

local function reconcileTraits(player, objects, stage)
    local traits, entries, groups = traitInventory(player)
    if not traits then return false, entries end
    local expected, expectedOrder = {}, {}
    for _, trait in ipairs(objects or {}) do
        local canonical = TraitCatalog.CanonicalizeTraitId(TraitCatalog.ObjectFullId(trait))
        if canonical ~= "" and not expected[canonical] then
            expected[canonical] = trait
            expectedOrder[#expectedOrder + 1] = canonical
        end
    end
    table.sort(expectedOrder)
    local adds, removes = 0, 0
    for _, canonical in ipairs(expectedOrder) do
        local current = groups[canonical] or {}
        if #current == 0 then
            local okAdd = invoke(traits, "add", expected[canonical])
            if not okAdd then return false, "TRAIT_ADD_FAILED:" .. canonical end
            adds = adds + 1
        elseif #current > 1 then
            for index = 2, #current do
                if not invoke(traits, "remove", current[index].trait) then
                    return false, "TRAIT_REMOVE_DUPLICATE_FAILED:" .. canonical
                end
                removes = removes + 1
            end
        end
    end
    local postTraits, postEntries, postGroups = traitInventory(player)
    if not postTraits then return false, "TRAIT_POST_INVENTORY_FAILED:" .. tostring(postEntries) end
    local duplicateCount, eachExpectedOne = 0, true
    for _, list in pairs(postGroups) do if #list > 1 then duplicateCount = duplicateCount + (#list - 1) end end
    for _, canonical in ipairs(expectedOrder) do
        if #(postGroups[canonical] or {}) ~= 1 then eachExpectedOne = false end
    end
    print("[XNP PURPLE TRAIT RESTORE MULTIPLICITY] stage=" .. tostring(stage)
        .. " expected_unique=" .. tostring(#expectedOrder)
        .. " actual_total=" .. tostring(#postEntries)
        .. " actual_unique=" .. tostring((function() local n=0;for _ in pairs(postGroups) do n=n+1 end;return n end)())
        .. " duplicate_count=" .. tostring(duplicateCount)
        .. " adds=" .. tostring(adds) .. " removes=" .. tostring(removes)
        .. " each_expected_count_one=" .. tostring(eachExpectedOne))
    if duplicateCount ~= 0 or not eachExpectedOne then return false, "TRAIT_MULTIPLICITY_READBACK_FAILED" end
    return true, "TRAIT_RECONCILED_ONCE"
end

local function replaceTraits(player, objects, stage)
    local traits, entries = traitInventory(player)
    if not traits then return false, entries end
    local removed = 0
    for index = #entries, 1, -1 do
        if not invoke(traits, "remove", entries[index].trait) then
            return false, "TRAIT_REPLACE_CLEAR_FAILED:" .. tostring(entries[index].canonical)
        end
        removed = removed + 1
    end
    local clearedTraits, clearedEntries = traitInventory(player)
    if not clearedTraits then return false, "TRAIT_REPLACE_CLEAR_READBACK_FAILED:" .. tostring(clearedEntries) end
    if #clearedEntries ~= 0 then return false, "TRAIT_REPLACE_CLEAR_INCOMPLETE:" .. tostring(#clearedEntries) end
    local expected, expectedOrder = {}, {}
    for _, trait in ipairs(objects or {}) do
        local canonical = TraitCatalog.CanonicalizeTraitId(TraitCatalog.ObjectFullId(trait))
        if canonical ~= "" and not expected[canonical] then
            expected[canonical] = trait
            expectedOrder[#expectedOrder + 1] = canonical
        end
    end
    table.sort(expectedOrder)
    for _, canonical in ipairs(expectedOrder) do
        if not invoke(traits, "add", expected[canonical]) then
            return false, "TRAIT_REPLACE_ADD_FAILED:" .. canonical
        end
    end
    local postTraits, postEntries, postGroups = traitInventory(player)
    if not postTraits then return false, "TRAIT_REPLACE_POST_READBACK_FAILED:" .. tostring(postEntries) end
    local duplicates, exact = 0, #postEntries == #expectedOrder
    for canonical, list in pairs(postGroups) do
        if #list ~= 1 then duplicates = duplicates + math.max(0, #list - 1) end
        if not expected[canonical] then exact = false end
    end
    for _, canonical in ipairs(expectedOrder) do
        if #(postGroups[canonical] or {}) ~= 1 then exact = false end
    end
    print("[XNP PURPLE TRAIT REPLACEMENT] stage=" .. tostring(stage)
        .. " current_player_traits_cleared=" .. tostring(removed)
        .. " record_traits_applied=" .. tostring(#expectedOrder)
        .. " total_trait_entries=" .. tostring(#postEntries)
        .. " duplicate_count=" .. tostring(duplicates)
        .. " exact_record_set=" .. tostring(exact))
    if duplicates ~= 0 or not exact then return false, "TRAIT_REPLACEMENT_READBACK_FAILED" end
    return true, "TRAITS_REPLACED_FROM_RECORD"
end

function Snapshot.RepairTraitMultiplicity(player, reason)
    local traits, entries, groups = traitInventory(player)
    if not traits then return false, entries end
    local removed, duplicateIds = 0, {}
    for canonical, list in pairs(groups) do
        if #list > 1 then
            duplicateIds[#duplicateIds + 1] = canonical
            for index = 2, #list do
                if not invoke(traits, "remove", list[index].trait) then
                    return false, "TRAIT_MULTIPLICITY_REMOVE_FAILED:" .. canonical
                end
                removed = removed + 1
            end
        end
    end
    local postTraits, postEntries, postGroups = traitInventory(player)
    if not postTraits then return false, "TRAIT_MULTIPLICITY_POST_READ_FAILED:" .. tostring(postEntries) end
    local duplicates, unique, preUnique = 0, 0, 0
    for _ in pairs(groups) do preUnique = preUnique + 1 end
    for _, list in pairs(postGroups) do unique = unique + 1; if #list > 1 then duplicates = duplicates + (#list - 1) end end
    table.sort(duplicateIds)
    local duplicateText = #duplicateIds > 0 and table.concat(duplicateIds, ",") or "NONE"
    print("[XNP TRAIT MULTIPLICITY REPAIR] reason=" .. tostring(reason or "UNSPECIFIED")
        .. " pre_total=" .. tostring(#entries) .. " pre_unique=" .. tostring(preUnique)
        .. " duplicate_ids=" .. duplicateText .. " removed_duplicates=" .. tostring(removed)
        .. " post_total=" .. tostring(#postEntries) .. " post_unique=" .. tostring(unique)
        .. " post_duplicate_count=" .. tostring(duplicates) .. " legitimate_trait_loss=0")
    return duplicates == 0, duplicates == 0 and "TRAIT_MULTIPLICITY_REPAIRED" or "TRAIT_MULTIPLICITY_REMAINS"
end

local function applyPerks(player, perkSnapshots, perkMap)
    local okXp, xp = invoke(player, "getXp")
    if not okXp or not xp then return false, "XP_OBJECT_UNAVAILABLE" end
    for _, saved in ipairs(perkSnapshots or {}) do
        local perk = perkMap.map[saved.id]
        if not perk then return false, "PERK_NOT_FOUND:" .. tostring(saved.id) end
        local level = math.max(0, math.floor(tonumber(saved.level) or 0))
        local okLevel = invoke(player, "setPerkLevelDebug", perk, level)
        if not okLevel then return false, "PERK_LEVEL_WRITE_FAILED:" .. saved.id end
        local okBase = invoke(xp, "setXPToLevel", perk, level)
        if not okBase then return false, "PERK_XP_BASE_WRITE_FAILED:" .. saved.id end
        local okCurrent, current = invoke(xp, "getXP", perk)
        if not okCurrent then return false, "PERK_XP_READ_FAILED:" .. saved.id end
        local delta = (tonumber(saved.xp) or 0) - (tonumber(current) or 0)
        if math.abs(delta) > 0.0001 then
            local okDelta = invoke(xp, "AddXPNoMultiplier", perk, delta)
            if not okDelta then return false, "PERK_XP_DELTA_WRITE_FAILED:" .. saved.id end
        end
    end
    return true, "PERKS_APPLIED"
end

local function applyQuarterDeltaPerks(player, perkSnapshots, perkMap, targets)
    local okXp, xp = invoke(player, "getXp")
    if not okXp or not xp then return false, "XP_OBJECT_UNAVAILABLE" end
    targets = targets or {}
    for _, saved in ipairs(perkSnapshots or {}) do
        local id = tostring(saved.id or "")
        local perk = perkMap.map[id]
        if not perk then return false, "PERK_NOT_FOUND:" .. id end
        local lowerId = string.lower(id)
        local okCurrent, current = invoke(xp, "getXP", perk)
        if not okCurrent or tonumber(current) == nil then return false, "PERK_XP_READ_FAILED:" .. id end
        current = tonumber(current)
        local snapshotXp = tonumber(saved.xp) or current
        local target = current
        if lowerId ~= "fitness" and lowerId ~= "strength" and snapshotXp > current then
            target = current + (snapshotXp - current) * 0.25
        end
        local delta = target - current
        if delta > 0.0001 and not invoke(xp, "AddXPNoMultiplier", perk, delta) then
            return false, "PERK_QUARTER_DELTA_WRITE_FAILED:" .. id
        end
        local okReadback, readback = invoke(xp, "getXP", perk)
        readback = okReadback and tonumber(readback) or nil
        if readback == nil or math.abs(readback - target) > 0.0001 then
            return false, "PERK_QUARTER_DELTA_READBACK_FAILED:" .. id
        end
        targets[id] = target
    end
    return true, "PERKS_QUARTER_DELTA_APPLIED"
end

local function applyKnownRecipes(player, recipes)
    local okKnown, known = invoke(player, "getKnownRecipes")
    if not okKnown or not known then
        return #recipes == 0, #recipes == 0 and "KNOWN_RECIPES_NOT_SUPPORTED_EMPTY"
            or "KNOWN_RECIPES_UNAVAILABLE"
    end
    if not invoke(known, "clear") then return false, "KNOWN_RECIPE_CLEAR_FAILED" end
    for _, recipe in ipairs(recipes or {}) do
        if not invoke(known, "add", recipe) then
            return false, "KNOWN_RECIPE_ADD_FAILED:" .. tostring(recipe)
        end
    end
    return true, "KNOWN_RECIPES_APPLIED"
end

local function applyNutrition(player, saved)
    local okNutrition, nutrition = invoke(player, "getNutrition")
    if not okNutrition or not nutrition then return false, "NUTRITION_UNAVAILABLE" end
    local fields = {
        weight = "setWeight",
        carbohydrates = "setCarbohydrates",
        proteins = "setProteins",
        calories = "setCalories",
        lipids = "setLipids",
    }
    for name, method in pairs(fields) do
        if not invoke(nutrition, method, saved[name]) then
            return false, "NUTRITION_WRITE_FAILED:" .. name
        end
    end
    return true, "NUTRITION_APPLIED"
end

local function applyVisual(player, descriptor, saved)
    local okVisual, visual = invoke(player, "getHumanVisual")
    if not okVisual or not visual then okVisual, visual = invoke(descriptor, "getHumanVisual") end
    if not okVisual or not visual then return false, "HUMAN_VISUAL_UNAVAILABLE" end

    local colorFields = {
        skin_color = "setSkinColor",
        hair_color = "setHairColor",
        beard_color = "setBeardColor",
        natural_hair_color = "setNaturalHairColor",
        natural_beard_color = "setNaturalBeardColor",
    }
    for name, method in pairs(colorFields) do
        if saved[name] then
            local color, colorReason = makeColor(saved[name])
            if not color then return false, name .. ":" .. colorReason end
            if not invoke(visual, method, color) then
                return false, "VISUAL_COLOR_WRITE_FAILED:" .. name
            end
        end
    end
    local calls = {
        { "setSkinTextureIndex", saved.skin_texture_index },
        { "setBodyHairIndex", saved.body_hair_index },
        { "setHairModel", saved.hair_model },
        { "setBeardModel", saved.beard_model },
        { "setNonAttachedHair", saved.non_attached_hair },
    }
    if saved.skin_texture_name and saved.skin_texture_name ~= "" then
        calls[#calls + 1] = { "setSkinTextureName", saved.skin_texture_name }
    end
    for _, call in ipairs(calls) do
        if not invoke(visual, call[1], call[2]) then
            return false, "VISUAL_WRITE_FAILED:" .. call[1]
        end
    end
    if not invoke(player, "resetModel") then return false, "MODEL_RESET_FAILED" end
    local playerNum = tonumber(readValue(player, "getPlayerNum", nil))
    if playerNum and type(getPlayerInfoPanel) == "function" then
        pcall(function()
            local panel = getPlayerInfoPanel(playerNum)
            if panel and panel.charScreen then panel.charScreen.refreshNeeded = true end
        end)
    end
    return true, "VISUAL_APPLIED"
end

local function joinList(values)
    if type(values) ~= "table" or #values == 0 then return "NONE" end
    return table.concat(values, ",")
end

local function applyStage(name, callback)
    local okCall, applied, reason = pcall(callback)
    if not okCall then return false, name .. "_EXCEPTION:" .. tostring(applied) end
    if applied ~= true then return false, name .. "_FAILED:" .. tostring(reason) end
    return true, reason
end

local function refreshDerivedState(player)
    if player and type(player.resetModelNextFrame) == "function" then
        local ok = invoke(player, "resetModelNextFrame")
        if not ok then return false, "RESET_MODEL_NEXT_FRAME_FAILED" end
    elseif player and type(player.resetModel) == "function" then
        local ok = invoke(player, "resetModel")
        if not ok then return false, "RESET_MODEL_FAILED" end
    end
    return true, "DERIVED_STATE_REFRESH_REQUESTED"
end

function Snapshot.ApplyPayload(player, payload, options)
    if not player or type(payload) ~= "table" then return false, "APPLY_INPUT_INVALID" end
    local okDead, dead = invoke(player, "isDead")
    if okDead and dead == true then return false, "TARGET_PLAYER_DEAD" end
    local okDescriptor, descriptor = invoke(player, "getDescriptor")
    if not okDescriptor or not descriptor then return false, "DESCRIPTOR_UNAVAILABLE" end

    local normalized, normalizeReason = Codec.NormalizePayload(payload)
    if not normalized then return false, normalizeReason end
    payload = normalized
    local profession, professionReason = resolveProfession(payload.identity.profession_id)
    if not profession then return false, professionReason end
    local resolvedTraits, traitsReason = resolveTraits(payload.trait_state)
    if not resolvedTraits then return false, traitsReason end
    local perkMap, perkReason = buildPerkMap()
    if not perkMap then return false, perkReason end
    for _, saved in ipairs(payload.perks or {}) do
        if not perkMap.map[saved.id] then return false, "PERK_NOT_FOUND:" .. tostring(saved.id) end
    end

    print("[XNP PURPLE TRAIT RESTORE EXPECTED] count="
        .. tostring(#(payload.trait_state.actual_traits or {}))
        .. " full_ids=" .. joinList(payload.trait_state.actual_traits)
        .. " snapshot_explicit_traits="
        .. joinList(payload.trait_state.snapshot_explicit_traits)
        .. " profession_derived_traits="
        .. joinList(payload.trait_state.profession_derived_traits)
        .. " mandatory_runtime_traits="
        .. joinList(payload.trait_state.mandatory_runtime_traits))

    local stages = {
        { "IDENTITY_PROFESSION_FIRST", function()
            return applyIdentity(player, descriptor, payload, profession)
        end },
        { options and options.replace_traits == true and "TRAIT_REPLACE_FROM_RECORD" or "TRAIT_RECONCILE_ONCE", function()
            if options and options.replace_traits == true then
                return replaceTraits(player, resolvedTraits.all, "CLEAR_CURRENT_APPLY_SELECTED_RECORD")
            end
            return reconcileTraits(player, resolvedTraits.all, "VERIFY_COUNTS_ADD_MISSING_REMOVE_DUPLICATES")
        end },
        { "PERKS_AND_XP", function()
            if options and options.perk_mode == "quarter_delta" then
                options.perk_targets = options.perk_targets or {}
                return applyQuarterDeltaPerks(player, payload.perks, perkMap, options.perk_targets)
            end
            return applyPerks(player, payload.perks, perkMap)
        end },
        { "RECIPES", function()
            return applyKnownRecipes(player, payload.known_recipes or {})
        end },
        { "NUTRITION", function() return applyNutrition(player, payload.nutrition) end },
        { "VISUAL", function() return applyVisual(player, descriptor, payload.visual) end },
        { "DERIVED_STATE_REFRESH", function() return refreshDerivedState(player) end },
    }
    for _, stage in ipairs(stages) do
        local applied, reason = applyStage(stage[1], stage[2])
        if not applied then return false, reason end
    end
    local matches, readbackReason = Snapshot.ReadbackMatches(player, payload, options)
    if not matches then return false, "READBACK_FAILED:" .. tostring(readbackReason) end
    return true, "PAYLOAD_APPLIED_WITH_CHARACTER_TRAIT_OBJECTS"
end

function Snapshot.ReadbackMatches(player, expectedPayload, options)
    local normalizedExpected, expectedNormalizeReason = Codec.NormalizePayload(expectedPayload)
    if not normalizedExpected then return false, expectedNormalizeReason end
    local actual, reason = Snapshot.CapturePayload(player)
    if not actual then return false, reason end
    local inventoryTraits, inventoryEntries, inventoryGroups = traitInventory(player)
    if not inventoryTraits then
        return false, "TRAIT_MULTIPLICITY_INVENTORY_UNAVAILABLE:" .. tostring(inventoryEntries)
    end
    local duplicateCount, missingOrRepeated = 0, {}
    for canonical, entries in pairs(inventoryGroups) do
        if #entries > 1 then duplicateCount = duplicateCount + (#entries - 1) end
    end
    for _, expectedId in ipairs(normalizedExpected.trait_state.actual_traits or {}) do
        local canonical = TraitCatalog.CanonicalizeTraitId(expectedId)
        local count = #(inventoryGroups[canonical] or {})
        if count ~= 1 then
            table.insert(missingOrRepeated, tostring(canonical) .. ":" .. tostring(count))
        end
    end
    print("[XNP PURPLE TRAIT RESTORE MULTIPLICITY] expected_unique="
        .. tostring(#(normalizedExpected.trait_state.actual_traits or {}))
        .. " actual_total=" .. tostring(#inventoryEntries)
        .. " duplicate_count=" .. tostring(duplicateCount)
        .. " required_count_failures=" .. joinList(missingOrRepeated))
    if duplicateCount > 0 or #missingOrRepeated > 0 then
        return false, "TRAIT_MULTIPLICITY_READBACK_FAILED"
    end
    local expectedChecksum, expectedReason = Codec.PayloadChecksum(normalizedExpected)
    if not expectedChecksum then return false, expectedReason end
    local actualChecksum, actualReason = Codec.PayloadChecksum(actual)
    if not actualChecksum then return false, actualReason end

    local traitMatches, traitDetails = Codec.CompareTraitStates(
        normalizedExpected, actual)
    local actualSet = {}
    for _, id in ipairs(traitDetails.actual_traits or {}) do actualSet[id] = true end
    for _, expectedId in ipairs(traitDetails.expected_traits or {}) do
        print("[XNP PURPLE TRAIT RESTORE READBACK] expected_id="
            .. tostring(expectedId)
            .. " present=" .. tostring(actualSet[expectedId] == true)
            .. " matched_runtime_id="
            .. tostring(actualSet[expectedId] and expectedId or "NONE")
            .. " matched_alias="
            .. tostring(joinList(traitDetails.equivalent_alias_traits)))
    end
    print("[XNP PURPLE TRAIT RESTORE READBACK] missing_required_traits="
        .. joinList(traitDetails.missing_required_traits)
        .. " unexpected_nonmandatory_traits="
        .. joinList(traitDetails.unexpected_nonmandatory_traits)
        .. " equivalent_alias_traits="
        .. joinList(traitDetails.equivalent_alias_traits)
        .. " expected_only="
        .. joinList(traitDetails.missing_required_traits)
        .. " actual_only="
        .. joinList(traitDetails.unexpected_nonmandatory_traits)
        .. " normalized_match=" .. tostring(traitMatches == true))

    if options and options.perk_mode == "quarter_delta" then
        local actualPerks = {}
        for _, saved in ipairs(actual.perks or {}) do actualPerks[tostring(saved.id)] = tonumber(saved.xp) end
        for id, target in pairs(options.perk_targets or {}) do
            if actualPerks[id] == nil or math.abs(actualPerks[id] - target) > 0.0001 then
                return false, "QUARTER_DELTA_PERK_READBACK_FAILED:" .. tostring(id)
            end
        end
        if not traitMatches then return false, "TRAIT_REPLACEMENT_SEMANTIC_MISMATCH" end
        return true, "QUARTER_DELTA_TRAIT_AND_PERK_READBACK_MATCH"
    end
    local matches, matchReason = Codec.SemanticPayloadMatches(
        normalizedExpected, actual)
    print("[XNP PURPLE SNAPSHOT READBACK] canonical_expected="
        .. tostring(expectedChecksum)
        .. " canonical_actual=" .. tostring(actualChecksum)
        .. " semantic_match=" .. tostring(matches == true)
        .. " reason=" .. tostring(matchReason))
    if not matches then
        return false, "SEMANTIC_READBACK_MISMATCH:" .. tostring(matchReason)
    end
    return true, "PAYLOAD_SEMANTIC_READBACK_MATCH"
end

Core.PurpleLifeStockSnapshot = Snapshot
return Snapshot
