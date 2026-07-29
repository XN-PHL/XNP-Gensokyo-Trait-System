local Core = XNP_PZ_DistanceRunner

local Classifier = {
    VERIFIED_UNDEAD = "VERIFIED_UNDEAD",
    BANDIT = "BANDIT",
    HUMAN_NPC = "HUMAN_NPC",
    PLAYER = "PLAYER",
    AMBIGUOUS_HUMANOID = "AMBIGUOUS_HUMANOID",
    NON_HUMANOID = "NON_HUMANOID",
}

local function invoke(object, method, ...)
    if not object or type(object[method]) ~= "function" then return false, nil end
    local args = { ... }
    return pcall(function() return object[method](object, unpack(args)) end)
end

local function isType(object, className)
    if not object or type(instanceof) ~= "function" then return false end
    local ok, value = pcall(function() return instanceof(object, className) end)
    return ok and value == true
end

local function result(kind, reason)
    return { kind = kind, damageAllowed = kind == Classifier.VERIFIED_UNDEAD, reason = reason }
end

local function markedHuman(modData)
    if type(modData) ~= "table" then return false end
    for _, key in ipairs({
        "isHuman", "IsHuman", "human", "Human", "humanNPC", "isHumanNPC",
        "npc", "NPC", "survivor", "Survivor", "isSurvivor", "faction",
    }) do
        local value = modData[key]
        if value == true or type(value) == "table" or type(value) == "string" then return true end
    end
    return false
end

local function banditBrainPresent(object, modData)
    if type(modData) == "table" and (modData.brain ~= nil or modData.brainId ~= nil) then
        return true, "BANDITS_MODDATA_BRAIN"
    end
    if type(BanditBrain) == "table" and type(BanditBrain.Get) == "function" then
        local ok, brain = pcall(function() return BanditBrain.Get(object) end)
        if ok and brain ~= nil then return true, "BANDITS_API_BRAIN" end
    end
    return false, nil
end

local function banditVariablePresent(object)
    local ok, value = invoke(object, "getVariableBoolean", "Bandit")
    if not ok then return nil, "BANDIT_VARIABLE_UNREADABLE" end
    if value == true then return true, "BANDITS_BOOLEAN_VARIABLE" end
    for _, name in ipairs({ "BanditPrimary", "BanditSecondary", "BanditWalkType" }) do
        local readOk, text = invoke(object, "getVariableString", name)
        if readOk and type(text) == "string" and text ~= "" then
            return true, "BANDITS_STRING_VARIABLE_" .. name
        end
    end
    return false, nil
end

local function banditVoicePresent(object)
    local descriptorOk, descriptor = invoke(object, "getDescriptor")
    if not descriptorOk or not descriptor then return false end
    local voiceOk, voice = invoke(descriptor, "getVoicePrefix")
    return voiceOk and type(voice) == "string" and string.lower(voice):find("bandit", 1, true) ~= nil
end

function Classifier.Classify(object, fromZombieRegistry)
    if not object then return result(Classifier.NON_HUMANOID, "OBJECT_MISSING") end
    if isType(object, "IsoPlayer") then return result(Classifier.PLAYER, "ISO_PLAYER") end
    if not isType(object, "IsoZombie") then
        if isType(object, "IsoGameCharacter") or isType(object, "IsoSurvivor") then
            return result(Classifier.HUMAN_NPC, "NON_ZOMBIE_GAME_CHARACTER")
        end
        return result(Classifier.NON_HUMANOID, "NOT_ISO_GAME_CHARACTER")
    end

    local dataOk, modData = invoke(object, "getModData")
    if not dataOk or type(modData) ~= "table" then
        return result(Classifier.AMBIGUOUS_HUMANOID, "MODDATA_UNAVAILABLE")
    end
    local variableBandit, variableReason = banditVariablePresent(object)
    if variableBandit == nil then return result(Classifier.AMBIGUOUS_HUMANOID, variableReason) end
    if variableBandit == true then return result(Classifier.BANDIT, variableReason) end
    local brainBandit, brainReason = banditBrainPresent(object, modData)
    if brainBandit then return result(Classifier.BANDIT, brainReason) end
    if banditVoicePresent(object) then return result(Classifier.BANDIT, "BANDITS_VOICE_PREFIX") end
    if markedHuman(modData) then return result(Classifier.HUMAN_NPC, "HUMAN_MODDATA_MARKER") end
    if fromZombieRegistry ~= true then
        return result(Classifier.AMBIGUOUS_HUMANOID, "NOT_CONFIRMED_BY_ZOMBIE_REGISTRY")
    end
    return result(Classifier.VERIFIED_UNDEAD,
        "ISO_ZOMBIE_AND_ZOMBIE_REGISTRY_WITHOUT_HUMAN_OR_BANDIT_MARKERS")
end

function Classifier.IsDamageAllowed(classification, policy)
    local kind = classification and classification.kind or Classifier.NON_HUMANOID
    policy = policy or {}
    if kind == Classifier.VERIFIED_UNDEAD then return true end
    if kind == Classifier.BANDIT then return policy.banditDamageEnabled == true end
    if kind == Classifier.HUMAN_NPC then return policy.npcDamageEnabled == true end
    return false
end

function Classifier.NewCounters()
    return {
        verified_undead_damaged = 0,
        bandits_damaged = 0,
        human_npcs_damaged = 0,
        players_skipped = 0,
        bandits_skipped = 0,
        human_npcs_skipped = 0,
        ambiguous_humanoids_skipped = 0,
        non_humanoids_skipped = 0,
        hit_failures = 0,
    }
end

function Classifier.CountDamaged(counters, classification)
    if not counters or not classification then return end
    if classification.kind == Classifier.VERIFIED_UNDEAD then
        counters.verified_undead_damaged = counters.verified_undead_damaged + 1
    elseif classification.kind == Classifier.BANDIT then
        counters.bandits_damaged = counters.bandits_damaged + 1
    elseif classification.kind == Classifier.HUMAN_NPC then
        counters.human_npcs_damaged = counters.human_npcs_damaged + 1
    end
end

function Classifier.CountSkip(counters, classification)
    if not counters or not classification then return end
    if classification.kind == Classifier.PLAYER then
        counters.players_skipped = counters.players_skipped + 1
    elseif classification.kind == Classifier.BANDIT then
        counters.bandits_skipped = counters.bandits_skipped + 1
    elseif classification.kind == Classifier.HUMAN_NPC then
        counters.human_npcs_skipped = counters.human_npcs_skipped + 1
    elseif classification.kind == Classifier.AMBIGUOUS_HUMANOID then
        counters.ambiguous_humanoids_skipped = counters.ambiguous_humanoids_skipped + 1
    else
        counters.non_humanoids_skipped = counters.non_humanoids_skipped + 1
    end
end

Core.GreenHumanSafeClassifier = Classifier
return Classifier
